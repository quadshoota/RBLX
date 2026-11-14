--[[
    kesosense — client-side pathfinding for Roblox characters.

    Load it like any other library:
        local kesosense = loadstring(game:HttpGet("<raw url>/kesosense.lua"))()
        local kesosense = loadstring(readfile("kesosense.lua"))()

    Read README.md before changing anything; it explains why each piece exists.

    Layout of this file (search for the banner to jump to a section):
        [1] SETUP        services, constants, defaults
        [2] UTIL         signal, binary heap
        [3] WORLD        lazy grid over the live world: columns, surfaces, links, gaps, line checks
        [4] SEARCH       weighted A* over the lazy grid, time-sliced
        [5] PATH         Roblox-like Path object (ComputeAsync / GetWaypoints / Status / Blocked)
        [6] NAVIGATOR    follows a path with a Humanoid: jumps, replans, stuck recovery
        [7] DEBUG        in-world drawing and HUD
        [8] EXPORT       public table, unload
]]

----------------------------------------------------------------------------------------------------
-- [1] SETUP
----------------------------------------------------------------------------------------------------

local VERSION = "1.3.0"

local Environment = (getgenv and getgenv()) or _G
local Previous = rawget(Environment, "kesosense")

if (type(Previous) == "table" and type(Previous.Unload) == "function") then
    pcall(Previous.Unload, Previous)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Action = Enum.PathWaypointAction
local Status = Enum.PathStatus
local Water = Enum.Material.Water
local Terrain = Workspace.Terrain

local floor, ceil, abs, sqrt, max, min, huge = math.floor, math.ceil, math.abs, math.sqrt, math.max, math.min, math.huge
local clock = os.clock

-- How a node was reached. Also the waypoint labels.
local WALK, JUMP, DROP, GAP, CLIMB = 1, 2, 3, 4, 5
local LABELS = { "Walk", "Jump", "Drop", "Gap", "Climb" }

-- Link codes, cached per pair of neighbouring nodes (direction is resolved when the link is used).
local L_BLOCKED, L_WALK, L_LEDGE, L_DROP_ONLY, L_JUMP_ONLY, L_HOLE = 0, 1, 2, 3, 4, 5

-- Node keys pack (cell x, cell z, height layer) into one number so every table is number-keyed.
--   column key = (ix + OFF) * COLS + (iz + OFF)          30 bits
--   node key   = column key * LAYERS + layer             40 bits
--   link key   = node key * 2048 + layer_b * 2 + axis    51 bits   (doubles are exact to 53)
local OFF, COLS, LAYERS, LAYER_H = 16384, 32768, 1024, 4
local COL_DELTA = { COLS, 1, -COLS, -1 }    -- +x, +z, -x, -z
local DIR_X = { 1, 0, -1, 0 }
local DIR_Z = { 0, 1, 0, -1 }
local SCAN_PAD = 6

local F_WATER = 1

local Defaults =
{
    -- Agent shape. nil = measured from the character every compute.
    AgentRadius = 1.25,         -- half width that must fit; gaps narrower than 2x this are walls
    ComfortRadius = 2,          -- nodes closer than this to a wall get pushed away and cost more
    AgentHeight = nil,          -- feet to top of head
    BodyClear = nil,            -- height under the body that never collides (legs); obstacles lower than this are stepped over
    StepHeight = nil,           -- tallest rise walked without jumping
    MaxSlope = 50,              -- degrees; steeper ground needs a jump or is avoided
    AgentCanJump = true,
    AgentCanGapJump = false,    -- jump across open air between platforms; needs AgentCanJump
    JumpHeight = nil,          -- tallest ledge to jump onto; nil = 80% of the humanoid's real apex
    JumpSafety = 0.9,           -- fraction of the theoretical jump distance trusted for gap jumps
    MaxDrop = 12,               -- tallest ledge to walk off
    AgentCanClimb = true,       -- use TrussParts as ladders
    MaxClimb = 80,              -- tallest truss worth climbing
    WalkSpeed = nil,            -- nil = Humanoid.WalkSpeed

    -- Grid.
    CellSize = 3,
    CacheTime = 12,             -- seconds a probed world is trusted before it is thrown away

    -- Costs (studs of extra path length).
    Costs = { Water = huge },   -- per Enum.Material name or PathfindingModifier label; math.huge = never
    TightCost = 1.6,            -- multiplier for nodes squeezed between walls
    RimCost = 1.25,             -- multiplier for nodes next to a drop
    JumpCost = 4,
    DropCost = 3,
    GapCost = 8,
    ClimbCost = 6,
    AvoidCost = 80,             -- added to cells the navigator got stuck in
    WadeDepth = 1.5,            -- water shallower than this is walked through

    -- Search.
    HeuristicWeight = 1.35,     -- >1 searches faster, paths at most this much longer than optimal (before smoothing)
    MaxNodes = 12000,           -- hard cap on expanded nodes per compute
    FrameBudget = 0.003,        -- seconds of work per frame before yielding
    AllowPartial = true,        -- return the closest reachable point when the goal cannot be reached
    GoalTolerance = 0,          -- accept any node within this many studs of the goal

    -- World filtering.
    Character = nil,            -- nil = LocalPlayer.Character
    Ignore = nil,               -- instances whose descendants never block
    Hazards = nil,              -- instances that must never be touched (kill bricks); may be non-colliding
    IgnoreCharacters = true,    -- other players never block
    RespectCollisionGroups = true,
}

----------------------------------------------------------------------------------------------------
-- [2] UTIL
----------------------------------------------------------------------------------------------------

local Signal = {}
Signal.__index = Signal

function Signal.new()
    return setmetatable({ handlers = {} }, Signal)
end

function Signal:Connect(handler)
    local handlers = self.handlers
    local connection = { Connected = true }

    function connection.Disconnect()
        connection.Connected = false

        local index = table.find(handlers, handler)

        if (index) then
            table.remove(handlers, index)
        end
    end

    table.insert(handlers, handler)

    return connection
end

function Signal:Once(handler)
    local connection

    connection = self:Connect(function(...)
        connection.Disconnect()
        handler(...)
    end)

    return connection
end

function Signal:Wait()
    local thread = coroutine.running()

    self:Once(function(...)
        task.spawn(thread, ...)
    end)

    return coroutine.yield()
end

function Signal:Fire(...)
    for _, handler in ipairs(table.clone(self.handlers)) do
        task.spawn(handler, ...)
    end
end

function Signal:Count()
    return #self.handlers
end

function Signal:Destroy()
    table.clear(self.handlers)
end

-- Binary min-heap over two parallel arrays; the size lives with the caller.
local function HeapPush(priorities, keys, size, priority, key)
    size += 1

    local index = size

    while (index > 1) do
        local parent = index // 2

        if (priorities[parent] <= priority) then
            break
        end

        priorities[index] = priorities[parent]
        keys[index] = keys[parent]
        index = parent
    end

    priorities[index] = priority
    keys[index] = key

    return size
end

local function HeapPop(priorities, keys, size)
    local top = keys[1]
    local priority = priorities[size]
    local key = keys[size]

    priorities[size] = nil
    keys[size] = nil
    size -= 1

    if (size > 0) then
        local index = 1

        while (true) do
            local child = index * 2

            if (child > size) then
                break
            end

            if (child < size and priorities[child + 1] < priorities[child]) then
                child += 1
            end

            if (priorities[child] >= priority) then
                break
            end

            priorities[index] = priorities[child]
            keys[index] = keys[child]
            index = child
        end

        priorities[index] = priority
        keys[index] = key
    end

    return top, size
end

-- Every TrussPart and PathfindingModifier in the place, kept current as instances come and go
-- (streaming, scripts adding zones). Shared by all Worlds; started on the first compute.
local Tracked = { trusses = {}, modifiers = {}, version = 0, connections = nil }

function Tracked:Add(instance)
    if (instance:IsA("TrussPart")) then
        self.trusses[instance] = true
        self.version += 1
    elseif (instance:IsA("PathfindingModifier")) then
        self.modifiers[instance] = true
    end
end

function Tracked:Start()
    if (self.connections) then
        return
    end

    for _, instance in ipairs(Workspace:GetDescendants()) do
        self:Add(instance)
    end

    self.connections =
    {
        Workspace.DescendantAdded:Connect(function(instance)
            self:Add(instance)
        end),

        Workspace.DescendantRemoving:Connect(function(instance)
            if (self.trusses[instance]) then
                self.trusses[instance] = nil
                self.version += 1
            end

            self.modifiers[instance] = nil
        end),
    }
end

function Tracked:Stop()
    for _, connection in ipairs(self.connections or {}) do
        connection:Disconnect()
    end

    self.connections = nil
    table.clear(self.trusses)
    table.clear(self.modifiers)
end

----------------------------------------------------------------------------------------------------
-- [3] WORLD
--
-- Nothing is precomputed. The world is sampled on demand with raycasts and box sweeps, and every
-- answer is cached for CacheTime seconds:
--
--   Column  one grid cell seen from above: every surface a ray finds inside a height window.
--   Surface a place to stand (a node): ground, headroom, not a hazard; nudged away from walls
--           and drops so nodes sit in the middle of corridors and platforms.
--   Link    whether the body fits between two neighbouring nodes and how (walk / ledge / hole).
--   Gap     a jump across open air from a node at a platform rim to a node further out.
--
-- Engine facts this design depends on (verified in game, see README "Engine behaviour"):
--   * a shapecast or raycast never hits what it starts inside of, so links are swept both ways
--   * rays starting inside Terrain pass through it, so a column scan can continue below a surface
----------------------------------------------------------------------------------------------------

local World = {}
World.__index = World

function World.new(options)
    local self = setmetatable({}, World)

    self.options = options
    self.cell = options.CellSize
    self.radius = options.AgentRadius
    self.comfort = max(options.ComfortRadius, options.AgentRadius)
    self.maxDrop = options.MaxDrop
    self.tanSlope = math.tan(math.rad(options.MaxSlope))
    self.minNormalY = math.cos(math.rad(min(options.MaxSlope + 12, 89)))
    self.wade = options.WadeDepth
    self.hWeight = options.HeuristicWeight
    self.queries = 0
    self.avoid = {}
    self.avoidCount = 0

    -- Costs by material (fast path) and by PathfindingModifier label.
    self.materialCost = {}
    self.labelCost = nil

    for name, cost in pairs(options.Costs or {}) do
        local ok, material = pcall(function()
            return Enum.Material[name]
        end)

        if (ok and material) then
            self.materialCost[material] = cost
        else
            self.labelCost = self.labelCost or {}
            self.labelCost[name] = cost
        end
    end

    local water = self.materialCost[Water]

    self.waterBlocked = (water == huge)
    self.waterMult = (water and water ~= huge) and water or 6

    -- rayParams sees water (to find its surface); solidParams ignores it (bodies, headroom, beds).
    self.rayParams = RaycastParams.new()
    self.rayParams.FilterType = Enum.RaycastFilterType.Exclude
    self.rayParams.IgnoreWater = false
    self.rayParams.RespectCanCollide = true

    self.solidParams = RaycastParams.new()
    self.solidParams.FilterType = Enum.RaycastFilterType.Exclude
    self.solidParams.IgnoreWater = true
    self.solidParams.RespectCanCollide = true

    self:SetHazards(options.Hazards)
    self:Measure()
    self:Flush()

    return self
end

function World:Flush()
    self.cache =
    {
        born = clock(),
        colLo = {}, colHi = {}, colNodes = {},
        NX = {}, NY = {}, NZ = {}, NM = {}, NF = {},
        links = {},
        diag = {},
        gaps = {},
    }
end

-- Hazards are matched two ways: a set for "the thing I am standing on is deadly" and an Include
-- raycast filter for deadly parts that do not collide (lava planes, kill fog).
function World:SetHazards(list)
    if (not list or #list == 0) then
        self.hazardSet = nil
        self.hazardParams = nil
        return
    end

    local set = {}

    for _, instance in ipairs(list) do
        if (instance:IsA("BasePart")) then
            set[instance] = true
        end

        for _, descendant in ipairs(instance:GetDescendants()) do
            if (descendant:IsA("BasePart")) then
                set[descendant] = true
            end
        end
    end

    local params = RaycastParams.new()

    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = list
    params.RespectCanCollide = false
    params.IgnoreWater = true

    self.hazardSet = set
    self.hazardParams = params

    if (self.cache) then
        self:Flush()
    end
end

function World:Rig()
    local character = self.options.Character or (Players.LocalPlayer and Players.LocalPlayer.Character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = humanoid and humanoid.RootPart

    return character, humanoid, root
end

-- Reads the agent's real size and jump from the character. Anything set in options wins.
function World:Measure()
    local options = self.options
    local _, humanoid, root = self:Rig()
    local gravity = Workspace.Gravity
    local speed, jump, clear, height, offset = 16, 50, 1.9, 5.5, 3

    if (humanoid and root) then
        speed = humanoid.WalkSpeed
        jump = humanoid.UseJumpPower and humanoid.JumpPower or sqrt(2 * gravity * humanoid.JumpHeight)

        if (humanoid.RigType == Enum.HumanoidRigType.R15) then
            clear = math.clamp(humanoid.HipHeight - 0.1, 1, 3)
            height = humanoid.HipHeight + root.Size.Y + 1.5
            offset = humanoid.HipHeight + root.Size.Y * 0.5
        else
            clear = 1.9
            height = 5.2
            offset = humanoid.HipHeight + root.Size.Y * 0.5 + 2
        end
    end

    if (speed <= 0) then
        speed = 16
    end

    speed = options.WalkSpeed or speed
    clear = options.BodyClear or clear
    height = options.AgentHeight or height

    local step = options.StepHeight or min(1.5, clear - 0.2)
    local apex = (jump * jump) / (2 * gravity)
    local canJump = options.AgentCanJump and jump > 0
    local jumpUp = canJump and (options.JumpHeight or apex * 0.8) or 0
    local signature = string.format("%.1f|%.1f|%.1f|%.2f|%.0f|%.0f", clear, height, step, jumpUp, speed, jump)

    self.speed = speed
    self.jumpVelocity = jump
    self.gravity = gravity
    self.apex = apex
    self.canJump = canJump
    self.jumpUp = jumpUp
    self.clear = clear
    self.height = height
    self.step = step
    self.groundOffset = offset
    self.bodyH = max(height - clear, 1)
    self.box = Vector3.new(self.radius * 2, self.bodyH, self.radius * 2)
    self.lineBox = Vector3.new(self.radius * 2 + 0.5, self.bodyH, self.radius * 2)
    -- Slimmer than the body so rising past a ledge face the node was nudged away from does not graze it.
    self.shaftBox = Vector3.new(max(self.radius * 2 - 0.4, 0.5), self.bodyH, max(self.radius * 2 - 0.4, 0.5))

    -- Height window searched around a node for neighbours.
    local ramp = self.cell * 1.6 * self.tanSlope

    self.windowUp = max(jumpUp, ramp)
    self.windowDown = max(self.maxDrop, ramp)

    if (self.signature and self.signature ~= signature and self.cache) then
        self:Flush()
    end

    self.signature = signature
end

function World:RefreshFilter()
    local options = self.options
    local character, _, root = self:Rig()
    local list = {}

    if (character) then
        list[#list + 1] = character
    end

    if (options.Ignore) then
        for _, instance in ipairs(options.Ignore) do
            list[#list + 1] = instance
        end
    end

    if (options.IgnoreCharacters) then
        for _, player in ipairs(Players:GetPlayers()) do
            if (player.Character and player.Character ~= character) then
                list[#list + 1] = player.Character
            end
        end
    end

    -- PathfindingModifier.PassThrough means the same as it does to Roblox: not an obstacle.
    for modifier in pairs(Tracked.modifiers) do
        if (modifier.PassThrough and modifier.Parent) then
            list[#list + 1] = modifier.Parent
        end
    end

    self.rayParams.FilterDescendantsInstances = list
    self.solidParams.FilterDescendantsInstances = list

    if (options.RespectCollisionGroups and root) then
        self.rayParams.CollisionGroup = root.CollisionGroup
        self.solidParams.CollisionGroup = root.CollisionGroup
    end
end

-- Cost volumes: parts carrying a PathfindingModifier whose Label has a cost in Costs, and that do
-- not physically block (PassThrough, or not collidable, or not queryable). Read fresh for every
-- search because scripts move them around (zones that follow enemies).
function World:Zones()
    local costs = self.labelCost

    if (not costs) then
        return nil
    end

    local zones = nil

    for modifier in pairs(Tracked.modifiers) do
        local cost = costs[modifier.Label]
        local part = modifier.Parent

        if (cost and part and part:IsA("BasePart") and (modifier.PassThrough or not part.CanCollide or not part.CanQuery)) then
            local frame, half = part.CFrame, part.Size * 0.5
            local right, up, look = frame.RightVector, frame.UpVector, frame.LookVector
            local ex = abs(right.X) * half.X + abs(up.X) * half.Y + abs(look.X) * half.Z
            local ey = abs(right.Y) * half.X + abs(up.Y) * half.Y + abs(look.Y) * half.Z
            local ez = abs(right.Z) * half.X + abs(up.Z) * half.Y + abs(look.Z) * half.Z
            local position = frame.Position

            zones = zones or {}
            zones[#zones + 1] = { position.X - ex, position.X + ex, position.Y - ey, position.Y + ey, position.Z - ez, position.Z + ez, cost }
        end
    end

    return zones
end

-- The cost multiplier of the zones a point is inside of (1 when none).
local function ZoneCost(zones, x, y, z)
    local cost = 1

    for _, zone in ipairs(zones) do
        if (x >= zone[1] and x <= zone[2] and y >= zone[3] and y <= zone[4] and z >= zone[5] and z <= zone[6] and zone[7] > cost) then
            cost = zone[7]
        end
    end

    return cost
end

function World:Prepare(position)
    local now = clock()

    Tracked:Start()
    self:Measure()
    self:RefreshFilter()

    -- The grid is anchored where it was first used so keys stay small anywhere in the world.
    if (not self.ox or abs(position.X - self.ox) > 30000 or abs(position.Z - self.oz) > 30000 or abs(position.Y - self.oy - 2048) > 1500) then
        self.ox = floor(position.X / self.cell) * self.cell
        self.oz = floor(position.Z / self.cell) * self.cell
        self.oy = floor(position.Y) - 2048
        self:Flush()
    elseif (now - self.cache.born > self.options.CacheTime) then
        self:Flush()
    end

    if (self.avoidCount > 0) then
        for column, expires in pairs(self.avoid) do
            if (expires < now) then
                self.avoid[column] = nil
                self.avoidCount -= 1
            end
        end
    end
end

function World:ColumnOf(x, z)
    local cell = self.cell

    return (floor((x - self.ox) / cell + 0.5) + OFF) * COLS + (floor((z - self.oz) / cell + 0.5) + OFF)
end

-- Marks the cell at a position as trouble for a while; the search routes around it.
function World:Avoid(position, seconds)
    if (not self.ox) then
        return
    end

    local column = self:ColumnOf(position.X, position.Z)

    if (not self.avoid[column]) then
        self.avoidCount += 1
    end

    self.avoid[column] = clock() + (seconds or 25)
end

function World:ClearAvoid()
    table.clear(self.avoid)
    self.avoidCount = 0
end

-- Ground straight below a point, ignoring the grid. Returns y and the hit.
function World:GroundAt(x, y, z, up, down)
    local hit = Workspace:Raycast(Vector3.new(x, y + up, z), Vector3.new(0, -(up + down), 0), self.rayParams)

    self.queries += 1

    if (hit) then
        return hit.Position.Y, hit
    end

    return nil
end

-- One side of a node: a slanted ray from the torso out and down tells a wall (returns its
-- distance), solid ground (false) and a drop (nil) apart. A level ray at head height catches what
-- the slanted ray passes under: cave walls that lean over the floor, low ceilings, overhangs.
function World:Side(origin, head, x, z, y, dx, dz)
    local reach = self.comfort
    local solid = self.solidParams
    local hit = Workspace:Raycast(origin, Vector3.new(dx * reach, -(self.clear + 1.6), dz * reach), solid)
    local over = Workspace:Raycast(head, Vector3.new(dx * reach, 0, dz * reach), solid)
    local result = nil

    self.queries += 2

    if (hit) then
        local position = hit.Position

        if (hit.Normal.Y >= 0.5 and position.Y <= y + self.step) then
            result = false
        else
            result = sqrt((position.X - x) ^ 2 + (position.Z - z) ^ 2)
        end
    end

    if (over and (not result or over.Distance < result)) then
        result = over.Distance
    end

    return result
end

local FIT_X = { 1, 0, -1, 0, 0.7071, 0.7071, -0.7071, -0.7071 }
local FIT_Z = { 0, 1, 0, -1, 0.7071, -0.7071, 0.7071, -0.7071 }

-- Does the body fit at a standing point? Level rays out from the centre line at knee and head
-- height. The centre line is known to be open (headroom ray), so every ray starts in air: this
-- stays reliable inside Terrain, where a box test is not (see Engine behaviour).
function World:Fits(x, y, z)
    local reach = self.radius - 0.1
    local solid = self.solidParams

    for level = 1, 2 do
        local origin = Vector3.new(x, (level == 1) and (y + self.clear + 0.2) or (y + self.height - 0.3), z)

        for d = 1, 8 do
            self.queries += 1

            if (Workspace:Raycast(origin, Vector3.new(FIT_X[d] * reach, 0, FIT_Z[d] * reach), solid)) then
                return false
            end
        end
    end

    return true
end

-- Is there floor around a point? Short rays down at four points a little inside the body's
-- edge must find walkable ground within a step; at least three of them. A bump on a rock face has
-- rock above it on one side (the ray starts inside Terrain and finds nothing) and a drop on the
-- other. A ramp up to MaxSlope still passes.
function World:Footing(x, y, z)
    local reach = self.radius * 0.8
    local step = self.step
    local solid = self.solidParams
    local count = 0

    for d = 1, 4 do
        local hit = Workspace:Raycast(Vector3.new(x + DIR_X[d] * reach, y + step + 0.5, z + DIR_Z[d] * reach), Vector3.new(0, -(step * 2 + 1), 0), solid)

        self.queries += 1

        if (hit and hit.Normal.Y >= self.minNormalY) then
            count += 1
        elseif (d - count >= 2) then
            return false
        end
    end

    return true
end

-- Turns a ray hit into a node, or nil when nobody could stand there. Cached by key either way.
function World:Surface(C, column, cx, cz, x, y, z, hit)
    local flags = 0
    local mult = 1
    local material = hit.Material

    if (material == Water) then
        local bed = Workspace:Raycast(Vector3.new(x, y, z), Vector3.new(0, -self.wade, 0), self.solidParams)

        self.queries += 1

        if (bed) then
            hit = bed
            y = bed.Position.Y
            material = bed.Material
        else
            flags = F_WATER
            mult = self.waterMult
        end
    end

    local layer = floor((y - self.oy) / LAYER_H)

    if (layer < 0 or layer >= LAYERS) then
        return nil
    end

    local key = column * LAYERS + layer
    local known = C.NY[key]

    if (known ~= nil) then
        return known and key or nil
    end

    C.NY[key] = false

    if (flags == 0) then
        if (hit.Normal.Y < self.minNormalY) then
            return nil
        end

        local cost = self.materialCost[material]

        if (cost) then
            if (cost == huge) then
                return nil
            end

            mult = cost
        end

        if (self.labelCost) then
            local modifier = hit.Instance:FindFirstChildOfClass("PathfindingModifier")
            local labelled = modifier and self.labelCost[modifier.Label]

            if (labelled) then
                if (labelled == huge) then
                    return nil
                end

                mult *= labelled
            end
        end
    end

    if (self.hazardSet and self.hazardSet[hit.Instance]) then
        return nil
    end

    -- Headroom.
    self.queries += 1

    if (Workspace:Raycast(Vector3.new(x, y + 0.05, z), Vector3.new(0, self.height, 0), self.solidParams)) then
        return nil
    end

    -- A non-colliding hazard anywhere in the standing volume.
    if (self.hazardParams) then
        self.queries += 1

        if (Workspace:Raycast(Vector3.new(x, y + self.height, z), Vector3.new(0, -(self.height + 0.5), 0), self.hazardParams)) then
            return nil
        end
    end

    -- Nudge: push the node away from walls and drops so it sits where a body actually fits.
    if (flags == 0) then
        local origin = Vector3.new(x, y + self.clear + 0.6, z)
        local head = Vector3.new(x, y + self.height - 0.3, z)
        local comfort = self.comfort
        local tight, rim, near = false, false, false
        local sx, sz = 0, 0

        for axis = 1, 2 do
            local dx, dz = (axis == 1) and 1 or 0, (axis == 1) and 0 or 1
            local plus = self:Side(origin, head, x, z, y, dx, dz)
            local minus = self:Side(origin, head, x, z, y, -dx, -dz)
            local shift = 0

            if (plus or minus) then
                near = true
            end

            if (plus and minus) then
                shift = (plus - minus) * 0.5
                tight = true
            elseif (plus) then
                shift = -(comfort - plus)

                if (minus == nil) then
                    shift = max(shift, -0.5)
                    rim = true
                end
            elseif (minus) then
                shift = comfort - minus

                if (plus == nil) then
                    shift = min(shift, 0.5)
                    rim = true
                end
            elseif (plus == nil and minus == nil) then
                rim = true
            elseif (plus == nil) then
                shift = -0.75
                rim = true
            elseif (minus == nil) then
                shift = 0.75
                rim = true
            end

            if (axis == 1) then
                sx = shift
            else
                sz = shift
            end
        end

        if (sx ~= 0 or sz ~= 0) then
            local limit = self.cell * 0.45
            local nx = math.clamp(x + sx, cx - limit, cx + limit)
            local nz = math.clamp(z + sz, cz - limit, cz + limit)
            local ny, ground = self:GroundAt(nx, y, nz, 1.5, 1.5)

            -- The new spot needs its own headroom: in a cave the ground ray can start inside a
            -- leaning wall, pass through it and find the floor of the hollow underneath.
            if (ny and abs(ny - y) <= 1 and ground.Material ~= Water and not (self.hazardSet and self.hazardSet[ground.Instance])) then
                self.queries += 1

                if (not Workspace:Raycast(Vector3.new(nx, ny + 0.05, nz), Vector3.new(0, self.height, 0), self.solidParams)) then
                    x, y, z = nx, ny, nz
                end
            end
        end

        -- Something was close: make sure the body is not inside it. A node half inside a wall
        -- sends the navigator into the wall, and link sweeps ignore what they start inside of.
        if (near and not self:Fits(x, y, z)) then
            return nil
        end

        -- Steep Terrain is built from little stair-like facets, and the ones facing up pass the
        -- slope test. Standing on one means being stuck halfway up a cave wall.
        if ((near or rim) and hit.Instance == Terrain and not self:Footing(x, y, z)) then
            return nil
        end

        if (tight) then
            mult *= self.options.TightCost
        elseif (rim) then
            mult *= self.options.RimCost
        end
    end

    C.NX[key] = x
    C.NY[key] = y
    C.NZ[key] = z
    C.NM[key] = mult
    C.NF[key] = flags

    return key
end

-- Casts down through a column, collecting every surface inside [lo, hi].
function World:Scan(C, column, cx, cz, x, z, lo, hi, list)
    local y = hi
    local params = self.rayParams

    for _ = 1, 8 do
        local hit = Workspace:Raycast(Vector3.new(x, y, z), Vector3.new(0, lo - y, 0), params)

        self.queries += 1

        if (not hit) then
            break
        end

        local height = hit.Position.Y
        local key = self:Surface(C, column, cx, cz, x, height, z, hit)

        if (key) then
            if (not list) then
                list = { key }
            elseif (not table.find(list, key)) then
                list[#list + 1] = key
            end
        end

        -- Nothing under a water surface is somewhere to stand.
        if (hit.Material == Water) then
            break
        end

        y = height - 0.3

        if (y <= lo + 0.05) then
            break
        end
    end

    return list
end

-- Nodes of a column inside a height window (an array, or false). Scans lazily and widens the
-- cached window when asked for more than it has seen.
function World:Column(C, column, lo, hi)
    local seenLo = C.colLo[column]

    if (seenLo) then
        local seenHi = C.colHi[column]

        if (seenLo <= lo and seenHi >= hi) then
            return C.colNodes[column]
        end

        lo = min(lo, seenLo)
        hi = max(hi, seenHi)
    else
        lo -= SCAN_PAD
        hi += SCAN_PAD
    end

    local cell = self.cell
    local iz = column % COLS
    local ix = (column - iz) / COLS
    local cx = self.ox + (ix - OFF) * cell
    local cz = self.oz + (iz - OFF) * cell
    local list = self:Scan(C, column, cx, cz, cx, cz, lo, hi, nil)

    -- The centre saw nothing: look off-centre so walkways thinner than a cell are not invisible.
    if (not list) then
        local offset = cell / 3

        list = self:Scan(C, column, cx, cz, cx + offset, cz, lo, hi, list)
        list = self:Scan(C, column, cx, cz, cx - offset, cz, lo, hi, list)
        list = self:Scan(C, column, cx, cz, cx, cz + offset, lo, hi, list)
        list = self:Scan(C, column, cx, cz, cx, cz - offset, lo, hi, list)
    end

    C.colLo[column] = lo
    C.colHi[column] = hi
    C.colNodes[column] = list or false

    return list or false
end

-- How two neighbouring nodes connect. `a` is the node with the smaller index along `axis`
-- (0 = x, 1 = z), which makes the cache key unique per pair.
function World:Link(C, a, b, axis)
    local linkKey = a * 2048 + (b % LAYERS) * 2 + axis
    local code = C.links[linkKey]

    if (code) then
        return code
    end

    local NX, NY, NZ = C.NX, C.NY, C.NZ
    local ax, ay, az = NX[a], NY[a], NZ[a]
    local bx, by, bz = NX[b], NY[b], NZ[b]
    local rise = by - ay
    local absRise = abs(rise)
    local top = max(ay, by)
    local height = top + self.clear + self.bodyH * 0.5 + 0.05
    local from = Vector3.new(ax, height, az)
    local to = Vector3.new(bx, height, bz)
    local delta = to - from
    local solid = self.solidParams

    code = L_BLOCKED
    self.queries += 2

    -- The body, swept both ways at the level of the higher node. One direction is not enough:
    -- a sweep never reports what it starts inside of.
    if (delta.Magnitude < 0.05 or (not Workspace:Blockcast(CFrame.new(from), self.box, delta, solid) and not Workspace:Blockcast(CFrame.new(to), self.box, -delta, solid))) then
        local dx, dz = bx - ax, bz - az
        local run = sqrt(dx * dx + dz * dz)
        local hazard = self.hazardParams and (Workspace:Raycast(from, delta, self.hazardParams) or Workspace:Raycast(Vector3.new(ax, ay + 0.6, az), Vector3.new(dx, rise, dz), self.hazardParams))

        if (hazard) then
            code = L_HOLE
        elseif (absRise <= self.step or absRise <= run * self.tanSlope + 0.25) then
            -- Walk or ramp: the ground has to actually be there in between.
            local samples = ceil(run / 1.25)
            local tolerance = (absRise <= self.step) and self.step or (0.75 + absRise * 0.25)
            local bottom = min(ay, by) - self.step - 0.5
            local set = self.hazardSet

            code = L_WALK

            for index = 1, samples - 1 do
                local t = index / samples
                local hit = Workspace:Raycast(Vector3.new(ax + dx * t, top + 1, az + dz * t), Vector3.new(0, bottom - top - 1, 0), self.rayParams)

                self.queries += 1

                if (not hit or abs(hit.Position.Y - (ay + rise * t)) > tolerance or hit.Material == Water or (set and set[hit.Instance])) then
                    code = L_HOLE
                    break
                end
            end

            -- A step too tall to walk that failed the ramp test is still a ledge.
            if (code == L_HOLE and absRise > self.step) then
                code = L_BLOCKED
            end
        end

        if (code == L_BLOCKED and absRise > self.step) then
            local lx, ly, lz = ax, ay, az

            if (rise < 0) then
                lx, ly, lz = bx, by, bz
            end

            -- The shaft above the lower node, up to the body at the higher level, must be open
            -- both for jumping up and for dropping down. Without it a hillside node a few studs
            -- above a cave links straight down through the cave roof. The ray starts on the
            -- lower node's open centre line, so it is reliable inside Terrain.
            self.queries += 2

            local shaft = not Workspace:Raycast(Vector3.new(lx, ly + self.clear, lz), Vector3.new(0, absRise + self.bodyH, 0), solid)
                and not Workspace:Blockcast(CFrame.new(lx, ly + self.clear + self.bodyH * 0.5 + 0.05, lz), self.shaftBox, Vector3.new(0, absRise, 0), solid)

            if (shaft) then
                local canJump = self.canJump and absRise <= self.jumpUp
                local canDrop = absRise <= self.maxDrop

                if (canJump) then
                    code = canDrop and L_LEDGE or L_JUMP_ONLY
                elseif (canDrop) then
                    code = L_DROP_ONLY
                end
            end
        end
    end

    C.links[linkKey] = code

    return code
end

-- The node one cell over in direction d (1..4) that can be walked to, if any.
function World:WalkTo(C, key, d)
    local layer = key % LAYERS
    local y = C.NY[key]
    local nodes = self:Column(C, (key - layer) / LAYERS + COL_DELTA[d], y - self.windowDown, y + self.windowUp)

    if (not nodes) then
        return nil
    end

    local axis = (d == 1 or d == 3) and 0 or 1

    for _, other in ipairs(nodes) do
        local code = (d <= 2) and self:Link(C, key, other, axis) or self:Link(C, other, key, axis)

        if (code == L_WALK) then
            return other
        end
    end

    return nil
end

-- Can the body walk the diagonal between two nodes in corner-touching cells? Both ways round the
-- corner being walkable says nothing about the diagonal itself: a rock that juts into the corner
-- (every cave has them) sits right on that line. Cached per pair like Link.
function World:Diagonal(C, a, b)
    local columnA = (a - a % LAYERS) / LAYERS
    local columnB = (b - b % LAYERS) / LAYERS

    -- Canonical order: the node in the lower x cell first; one bit says which way z goes.
    if (columnB < columnA) then
        a, b = b, a
        columnA, columnB = columnB, columnA
    end

    local diagKey = a * 2048 + (b % LAYERS) * 2 + ((columnB - columnA > COLS) and 1 or 0)
    local known = C.diag[diagKey]

    if (known ~= nil) then
        return known
    end

    local NX, NY, NZ = C.NX, C.NY, C.NZ
    local ax, ay, az = NX[a], NY[a], NZ[a]
    local bx, by, bz = NX[b], NY[b], NZ[b]
    local top = max(ay, by)
    local height = top + self.clear + self.bodyH * 0.5 + 0.05
    local from = Vector3.new(ax, height, az)
    local to = Vector3.new(bx, height, bz)
    local delta = to - from
    local solid = self.solidParams
    local ok = true

    self.queries += 3

    if (delta.Magnitude > 0.05) then
        local rotation = CFrame.lookAt(Vector3.zero, delta)

        ok = not Workspace:Blockcast(rotation + from, self.box, delta, solid) and not Workspace:Blockcast(rotation + to, self.box, -delta, solid)
    end

    -- Ground in the middle, where neither cardinal link looked.
    if (ok) then
        local mx, mz = (ax + bx) * 0.5, (az + bz) * 0.5
        local hit = Workspace:Raycast(Vector3.new(mx, top + 1, mz), Vector3.new(0, min(ay, by) - self.step - top - 1.5, 0), self.rayParams)

        ok = hit ~= nil and abs(hit.Position.Y - (ay + by) * 0.5) <= self.step and hit.Material ~= Water and not (self.hazardSet and self.hazardSet[hit.Instance])
    end

    if (ok and self.hazardParams) then
        self.queries += 1
        ok = not Workspace:Raycast(from, delta, self.hazardParams)
    end

    C.diag[diagKey] = ok

    return ok
end

-- Horizontal distance a jump covers when it lands `rise` studs above the take-off.
function World:Reach(rise)
    local velocity = self.jumpVelocity
    local under = velocity * velocity - 2 * self.gravity * rise

    if (under < 0) then
        return 0
    end

    return self.speed * ((velocity + sqrt(under)) / self.gravity) * self.options.JumpSafety + 0.8
end

function World:Solid(x, y, z)
    local height, hit = self:GroundAt(x, y, z, 1.5, 1.5)

    return height ~= nil and abs(height - y) <= 1 and hit.Material ~= Water and not (self.hazardSet and self.hazardSet[hit.Instance])
end

-- A jump through open air from a to b: finds where the ground really ends on both sides,
-- checks the distance against the jump physics and sweeps the arc.
function World:GapEdge(C, a, b)
    local NX, NY, NZ = C.NX, C.NY, C.NZ
    local ax, ay, az = NX[a], NY[a], NZ[a]
    local bx, by, bz = NX[b], NY[b], NZ[b]
    local rise = by - ay

    if (rise > self.jumpUp) then
        return nil
    end

    local dx, dz = bx - ax, bz - az
    local distance = sqrt(dx * dx + dz * dz)
    local reach = self:Reach(rise)

    if (distance < 0.5 or distance - self.cell - 1 > reach) then
        return nil
    end

    local ux, uz = dx / distance, dz / distance
    local half = distance * 0.5

    -- Ground still there half way: this is not a gap in this direction.
    if (self:Solid(ax + ux * half, ay, az + uz * half) or self:Solid(bx - ux * half, by, bz - uz * half)) then
        return nil
    end

    local takeoff, landing = 0, 0
    local lo, hi = 0, half

    for _ = 1, 4 do
        local mid = (lo + hi) * 0.5

        if (self:Solid(ax + ux * mid, ay, az + uz * mid)) then
            lo = mid
        else
            hi = mid
        end
    end

    takeoff = lo
    lo, hi = 0, half

    for _ = 1, 4 do
        local mid = (lo + hi) * 0.5

        if (self:Solid(bx - ux * mid, by, bz - uz * mid)) then
            lo = mid
        else
            hi = mid
        end
    end

    landing = lo

    local gap = distance - takeoff - landing

    if (gap + 0.3 > reach) then
        return nil
    end

    local tx, tz = ax + ux * max(takeoff - 0.3, 0), az + uz * max(takeoff - 0.3, 0)
    local lx, lz = bx - ux * max(landing - 1, 0), bz - uz * max(landing - 1, 0)
    local body = self.clear + self.bodyH * 0.5
    local start = Vector3.new(tx, ay + body + 0.1, tz)
    local peak = Vector3.new((tx + lx) * 0.5, max(ay + self.apex * 0.85, by + 0.5) + body, (tz + lz) * 0.5)
    local finish = Vector3.new(lx, by + body + 0.3, lz)
    local solid = self.solidParams

    self.queries += 2

    if (Workspace:Blockcast(CFrame.new(start), self.box, peak - start, solid) or Workspace:Blockcast(CFrame.new(peak), self.box, finish - peak, solid)) then
        return nil
    end

    if (self.hazardParams and (Workspace:Raycast(start, peak - start, self.hazardParams) or Workspace:Raycast(peak, finish - peak, self.hazardParams))) then
        return nil
    end

    return
    {
        node = b,
        kind = GAP,
        tx = tx, ty = ay, tz = tz,
        lx = lx, ly = by, lz = lz,
        cost = distance + max(rise, 0) + self.options.GapCost,
    }
end

-- Upright trusses by the column they stand in, rebuilt per cache generation.
function World:TrussMap(C)
    if (C.trussMap == nil or C.trussVersion ~= Tracked.version) then
        local map = false

        for truss in pairs(Tracked.trusses) do
            if (truss.CanCollide and truss.CFrame.UpVector.Y > 0.9) then
                local position = truss.Position
                local column = self:ColumnOf(position.X, position.Z)

                map = map or {}
                map[column] = map[column] or {}
                table.insert(map[column], truss)
            end
        end

        C.trussMap = map
        C.trussVersion = Tracked.version
    end

    return C.trussMap
end

-- Truss climbs available from a node: walk to the foot of the truss, climb, step off at the top.
function World:Climbs(C, a, result)
    local map = self:TrussMap(C)

    if (not map) then
        return result
    end

    local ax, ay, az = C.NX[a], C.NY[a], C.NZ[a]
    local layer = a % LAYERS
    local column = (a - layer) / LAYERS
    local done = nil

    for d = 0, 4 do
        local list = map[column + (COL_DELTA[d] or 0)]

        if (list) then
            for _, truss in ipairs(list) do
                local position = truss.Position
                local stack = floor(position.X * 2 + 0.5) * 4096 + floor(position.Z * 2 + 0.5)

                if (not (done and done[stack])) then
                    done = done or {}
                    done[stack] = true

                    local edge = self:ClimbEdge(C, a, ax, ay, az, truss, list)

                    if (edge) then
                        result = result or {}
                        result[#result + 1] = edge
                    end
                end
            end
        end
    end

    return result
end

function World:ClimbEdge(C, a, ax, ay, az, truss, list)
    local position, size = truss.Position, truss.Size
    local bottom, top = position.Y - size.Y * 0.5, position.Y + size.Y * 0.5

    -- Trusses stacked on this one extend the climb.
    local grew = true

    while (grew) do
        grew = false

        for _, other in ipairs(list) do
            local p, s = other.Position, other.Size

            if (abs(p.X - position.X) < 0.6 and abs(p.Z - position.Z) < 0.6) then
                local b, t = p.Y - s.Y * 0.5, p.Y + s.Y * 0.5

                if (b <= top + 0.5 and t > top + 0.1) then
                    top = t
                    grew = true
                elseif (t >= bottom - 0.5 and b < bottom - 0.1) then
                    bottom = b
                    grew = true
                end
            end
        end
    end

    local climb = top - ay

    if (bottom > ay + 2.5 or climb < self.step + 1 or climb > self.options.MaxClimb) then
        return nil
    end

    -- Approach along the axis the node is most in line with.
    local dx, dz = position.X - ax, position.Z - az
    local ux, uz, half = 0, 0, 0

    if (abs(dx) >= abs(dz)) then
        ux, half = (dx >= 0) and 1 or -1, size.X * 0.5

        if (abs(dz) > 2.2) then
            return nil
        end
    else
        uz, half = (dz >= 0) and 1 or -1, size.Z * 0.5

        if (abs(dx) > 2.2) then
            return nil
        end
    end

    if (abs(dx * ux + dz * uz) > self.cell + 2.5) then
        return nil
    end

    local standoff = half + self.radius + 0.1
    local bx, bz = position.X - ux * standoff, position.Z - uz * standoff
    local baseY = self:GroundAt(bx, ay, bz, 1.5, 1.5)

    if (not baseY or abs(baseY - ay) > self.step or not self:WalkLine(ax, ay, az, bx, baseY, bz, true, huge)) then
        return nil
    end

    -- Where to step off: the nearest standing place around the top of the truss.
    local trussColumn = self:ColumnOf(position.X, position.Z)
    local d = (ux == 1 and 1) or (uz == 1 and 2) or (ux == -1 and 3) or 4
    local landing, landingDistance = nil, huge

    for ring = 0, 2 do
        local nodes = self:Column(C, trussColumn + COL_DELTA[d] * ring, top - 3, top + 2.5)

        if (nodes) then
            for _, node in ipairs(nodes) do
                local y = C.NY[node]
                local distance = sqrt((C.NX[node] - position.X) ^ 2 + (C.NZ[node] - position.Z) ^ 2)

                if (y >= top - 2.5 and y <= top + 1.6 and distance < landingDistance and C.NF[node] ~= F_WATER) then
                    landing, landingDistance = node, distance
                end
            end
        end
    end

    if (not landing or landing == a) then
        return nil
    end

    -- The shaft in front of the truss, then across to the landing.
    local lx, ly, lz = C.NX[landing], C.NY[landing], C.NZ[landing]
    local body = self.clear + self.bodyH * 0.5 + 0.1
    local from = Vector3.new(bx, baseY + body, bz)
    local over = Vector3.new(bx, max(top, ly) + body + 0.2, bz)
    local onto = Vector3.new(lx, max(top, ly) + body + 0.2, lz)
    local solid = self.solidParams

    self.queries += 2

    if (Workspace:Blockcast(CFrame.new(from), self.box, over - from, solid) or Workspace:Blockcast(CFrame.new(over), self.box, onto - over, solid)) then
        return nil
    end

    if (self.hazardParams and (Workspace:Raycast(from, over - from, self.hazardParams) or Workspace:Raycast(over, onto - over, self.hazardParams))) then
        return nil
    end

    return
    {
        node = landing,
        kind = CLIMB,
        tx = bx, ty = baseY, tz = bz,
        cost = climb * 1.5 + landingDistance + self.options.ClimbCost,
    }
end

-- Every gap jump available from a node. Only looked for where the ground ends: a direction
-- whose next cell has nothing at this level to walk or hop onto and no wall in the way.
function World:Gaps(C, a)
    local result = false

    if (self.options.AgentCanClimb) then
        result = self:Climbs(C, a, nil) or false
    end

    if (self.canJump and self.options.AgentCanGapJump) then
        local NX, NY, NZ = C.NX, C.NY, C.NZ
        local ax, ay, az = NX[a], NY[a], NZ[a]
        local layer = a % LAYERS
        local column = (a - layer) / LAYERS
        local lo, hi = ay - self.windowDown, ay + self.windowUp
        local cell = self.cell
        local rings = max(2, ceil((self:Reach(0) + cell) / cell))
        local seen = nil

        for d = 1, 4 do
            local nodes = self:Column(C, column + COL_DELTA[d], lo, hi)
            local axis = (d == 1 or d == 3) and 0 or 1
            local open = true
            local hole = false
            local below = nil

            if (nodes) then
                for _, other in ipairs(nodes) do
                    local y = NY[other]

                    if (y > ay - self.step - 0.25) then
                        local code = (d <= 2) and self:Link(C, a, other, axis) or self:Link(C, other, a, axis)

                        if (code == L_HOLE) then
                            hole = true
                        elseif (y <= hi) then
                            open = false
                        end
                    elseif (not below or y > below) then
                        below = y
                    end
                end
            end

            if (open and not hole) then
                self.queries += 1
                open = not Workspace:Raycast(Vector3.new(ax, ay + self.clear + 0.8, az), Vector3.new(DIR_X[d] * cell * 1.5, 0, DIR_Z[d] * cell * 1.5), self.solidParams)
            end

            if (open) then
                local side = (axis == 0) and 1 or COLS

                for ring = 1, rings do
                    for lateral = -ring, ring do
                        local nodes2 = self:Column(C, column + COL_DELTA[d] * ring + side * lateral, lo, hi)

                        if (nodes2) then
                            for _, other in ipairs(nodes2) do
                                local y = NY[other]

                                -- Landings a plain drop already reaches are not worth a jump.
                                if (not (seen and seen[other]) and y <= ay + self.jumpUp and y >= ay - self.maxDrop and (not below or y > below + self.step)) then
                                    seen = seen or {}
                                    seen[other] = true

                                    local edge = self:GapEdge(C, a, other)

                                    if (edge) then
                                        result = result or {}
                                        result[#result + 1] = edge
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    C.gaps[a] = result

    return result
end

-- Can the body walk the straight line between two ground points? Used to smooth paths, to seed
-- the search from the agent's real position and to notice a path that has become blocked.
-- Deliberately uncached: it is also the check for "has the world changed".
function World:WalkLine(x1, y1, z1, x2, y2, z2, allowWater, maxMult)
    local dx, dz = x2 - x1, z2 - z1
    local distance = sqrt(dx * dx + dz * dz)
    local step = self.step

    if (distance < 0.05) then
        return abs(y2 - y1) <= step
    end

    local steps = ceil(distance / 1.5)
    local sx, sz = dx / steps, dz / steps
    local rotation = CFrame.lookAt(Vector3.zero, Vector3.new(dx, 0, dz))
    local body = self.clear + self.bodyH * 0.5 + 0.05
    local px, py, pz = x1, y1, z1
    local ray, solid, hazards, set = self.rayParams, self.solidParams, self.hazardParams, self.hazardSet
    local avoid = (self.avoidCount > 0) and self.avoid or nil
    local materialCost = self.materialCost
    local zones = self.lineZones

    for index = 1, steps do
        local qx, qz = x1 + sx * index, z1 + sz * index
        local hit = Workspace:Raycast(Vector3.new(qx, py + step + 0.5, qz), Vector3.new(0, -(step * 2 + 1), 0), ray)

        self.queries += 2

        if (not hit) then
            return false
        end

        local qy = hit.Position.Y

        if (hit.Material == Water) then
            local bed = Workspace:Raycast(Vector3.new(qx, qy, qz), Vector3.new(0, -self.wade, 0), solid)

            if (bed) then
                qy = bed.Position.Y
            elseif (not allowWater) then
                return false
            end
        else
            local cost = materialCost[hit.Material]

            if (cost and cost > (maxMult or 1)) then
                return false
            end
        end

        if (abs(qy - py) > step or (set and set[hit.Instance])) then
            return false
        end

        if (avoid and avoid[self:ColumnOf(qx, qz)]) then
            return false
        end

        if (zones and ZoneCost(zones, qx, qy + 2, qz) > (maxMult or 1)) then
            return false
        end

        local level = max(py, qy) + body
        local from = Vector3.new(px, level, pz)
        local move = Vector3.new(qx - px, 0, qz - pz)

        if (Workspace:Blockcast(rotation + from, self.lineBox, move, solid)) then
            return false
        end

        if (hazards and (Workspace:Raycast(from, move, hazards) or Workspace:Raycast(Vector3.new(px, py + 0.6, pz), Vector3.new(qx - px, qy - py, qz - pz), hazards))) then
            return false
        end

        px, py, pz = qx, qy, qz
    end

    return abs(py - y2) <= step + 0.5
end

----------------------------------------------------------------------------------------------------
-- [4] SEARCH
--
-- Weighted A* straight over World. Returns raw points (start, every node, goal) tagged with how
-- each was reached; Path turns those into waypoints.
----------------------------------------------------------------------------------------------------

-- Cost multipliers above this are what a relaxed search clamps them to.
local RELAXED = 2

-- A goal that sits in (or behind) heavily costed ground makes A* expand everything cheaper first:
-- with a 30x zone over a cave that is the whole map, the budget runs out, and the "closest point"
-- that comes back is wherever the flood happened to get nearest (the plateau above the cave, the
-- far side of a wall). When that happens the search runs again with the multipliers clamped, so
-- costed ground is still disliked but no longer worth any detour. The verdict is remembered for
-- a few seconds because callers replan about once a second.
function World:Search(startPosition, goalPosition, tolerance, token)
    local memo = self.relaxedFor
    local direct = memo ~= nil and clock() < memo.expires and (goalPosition - memo.goal).Magnitude < 6
    local result = self:Explore(startPosition, goalPosition, tolerance, token, direct and RELAXED or huge)

    if (not direct and result.Reason == "Budget" and result.Costed) then
        local first = result.Stats

        self.relaxedFor = { goal = goalPosition, expires = clock() + 3 }
        result = self:Explore(startPosition, goalPosition, tolerance, token, RELAXED)

        for name, value in pairs(first) do
            result.Stats[name] += value
        end
    end

    return result
end

function World:Explore(startPosition, goalPosition, tolerance, token, cap)
    local began = clock()
    local slice = began
    local work = 0
    local queriesBefore = self.queries

    self:Prepare(startPosition)

    local C = self.cache
    local NX, NY, NZ, NM, NF = C.NX, C.NY, C.NZ, C.NM, C.NF
    local options = self.options
    local cell = self.cell
    local step = self.step
    local windowUp, windowDown = self.windowUp, self.windowDown
    local jumpUp, maxDrop = self.jumpUp, self.maxDrop
    local jumpCost, dropCost, avoidCost = options.JumpCost, options.DropCost, options.AvoidCost
    local weight = self.hWeight
    local avoid = self.avoid
    local zones = self:Zones()
    local zoneOf = {}

    local result =
    {
        Status = Status.NoPath,
        Reason = nil,
        Partial = false,
        Points = nil,
        Explored = nil,
        Cache = C,
        Stats = { Nodes = 0, Queries = 0, Time = 0, Work = 0 },
    }

    local function finish(reason)
        local stats = result.Stats

        work += clock() - slice
        stats.Queries = self.queries - queriesBefore
        stats.Time = clock() - began
        stats.Work = work
        result.Reason = reason

        return result
    end

    -- Start: the ground under the agent, then every node around it the agent can walk straight to.
    local sx, sz = startPosition.X, startPosition.Z
    local sy = self:GroundAt(sx, startPosition.Y, sz, 1, self.groundOffset + 8) or (startPosition.Y - self.groundOffset)
    local startColumn = self:ColumnOf(sx, sz)

    -- Goal: the ground under it, and the node of its cell when there is one.
    local gx, gz = goalPosition.X, goalPosition.Z
    -- (Goals are often a part's centre or a point slightly inside the ground: look up as well.)
    local groundGoal = self:GroundAt(gx, goalPosition.Y, gz, 1.5, 14) or self:GroundAt(gx, goalPosition.Y, gz, 8, 0)
    local gy = groundGoal or goalPosition.Y
    local goalColumn = self:ColumnOf(gx, gz)
    local goalKey = nil

    if (groundGoal) then
        local nodes = self:Column(C, goalColumn, gy - step - 1, gy + step + 1)

        if (nodes) then
            for _, key in ipairs(nodes) do
                if (abs(NY[key] - gy) <= step + 1) then
                    goalKey = key
                    break
                end
            end
        end
    end

    -- Water is off limits unless the agent is already in it (then it may swim out).
    local startInWater = false

    do
        local _, hit = self:GroundAt(sx, sy + 1, sz, 1, 2)

        startInWater = (hit ~= nil and hit.Material == Water and not Workspace:Raycast(Vector3.new(sx, hit.Position.Y, sz), Vector3.new(0, -self.wade, 0), self.solidParams))
    end

    local allowWater = startInWater or not self.waterBlocked

    local g, parent, via, gapOf, closed = {}, {}, {}, {}, {}
    local priorities, keys, size = {}, {}, 0

    local function heuristic(key)
        local hx, hz = abs(NX[key] - gx), abs(NZ[key] - gz)

        return ((hx > hz) and (hx + 0.41421356 * hz) or (hz + 0.41421356 * hx)) + abs(NY[key] - gy) * 0.5
    end

    local seeds, nearest, nearestDistance = 0, nil, huge

    for ox = -1, 1 do
        for oz = -1, 1 do
            local nodes = self:Column(C, startColumn + ox * COLS + oz, sy - step - 2, sy + step + 2)

            if (nodes) then
                for _, key in ipairs(nodes) do
                    local distance = sqrt((NX[key] - sx) ^ 2 + (NZ[key] - sz) ^ 2)

                    if (abs(NY[key] - sy) <= step + 1 and (allowWater or NF[key] ~= F_WATER)) then
                        if (distance < nearestDistance) then
                            nearest, nearestDistance = key, distance
                        end

                        -- Ground cost is the search's business; this only asks "can I get there".
                        -- With the default limit a costed floor (Lunacy prices Rock at 6) failed
                        -- every seed in a rock cave.
                        if (self:WalkLine(sx, sy, sz, NX[key], NY[key], NZ[key], allowWater, huge)) then
                            g[key] = distance
                            via[key] = WALK
                            size = HeapPush(priorities, keys, size, distance + weight * heuristic(key), key)
                            seeds += 1
                        end
                    end
                end
            end
        end
    end

    -- Wedged against something: start from the nearest node anyway rather than give up.
    if (seeds == 0 and nearest) then
        g[nearest] = nearestDistance
        via[nearest] = WALK
        size = HeapPush(priorities, keys, size, nearestDistance + weight * heuristic(nearest), nearest)
        seeds = 1
    end

    -- Nothing to stand on at this level: the agent is on a ledge too small to be a node (halfway
    -- up a cave wall, say). Start with a drop to the ground below, nearest first, rather than
    -- give up: NoStart left the caller with no way down at all.
    -- The fall may be longer than MaxDrop here: being stranded is worse than a long drop.
    if (seeds == 0) then
        local escape = max(maxDrop, 40)

        for ox = -1, 1 do
            for oz = -1, 1 do
                local nodes = self:Column(C, startColumn + ox * COLS + oz, sy - escape, sy - step)

                if (nodes) then
                    for _, key in ipairs(nodes) do
                        local fall = sy - NY[key]

                        if (fall > step and fall <= escape and (allowWater or NF[key] ~= F_WATER)) then
                            local distance = sqrt((NX[key] - sx) ^ 2 + (NZ[key] - sz) ^ 2)

                            g[key] = distance + fall * 0.25 + dropCost
                            via[key] = DROP
                            size = HeapPush(priorities, keys, size, g[key] + weight * heuristic(key), key)
                            seeds += 1
                        end
                    end
                end
            end
        end
    end

    if (seeds == 0) then
        return finish("NoStart")
    end

    local function relax(from, to, kind, cost, edge)
        if (closed[to] or (NF[to] == F_WATER and not allowWater)) then
            return
        end

        local mult = NM[to]

        if (zones) then
            local zone = zoneOf[to]

            if (not zone) then
                zone = ZoneCost(zones, NX[to], NY[to] + 2, NZ[to])
                zoneOf[to] = zone
            end

            if (zone == huge) then
                return
            end

            mult *= zone
        end

        if (mult > RELAXED) then
            result.Costed = true
            mult = min(mult, cap)
        end

        cost *= mult

        if (self.avoidCount > 0) then
            local layer = to % LAYERS

            if (avoid[(to - layer) / LAYERS]) then
                cost += avoidCost
            end
        end

        local total = g[from] + cost
        local known = g[to]

        if (known and known <= total) then
            return
        end

        g[to] = total
        parent[to] = from
        via[to] = kind
        gapOf[to] = edge
        size = HeapPush(priorities, keys, size, total + weight * heuristic(to), to)
    end

    local walkable = {}

    local function expand(a)
        local layer = a % LAYERS
        local column = (a - layer) / LAYERS
        local ax, ay, az = NX[a], NY[a], NZ[a]
        local lo, hi = ay - windowDown, ay + windowUp

        for d = 1, 4 do
            local nodes = self:Column(C, column + COL_DELTA[d], lo, hi)
            local found = nil

            if (nodes) then
                local axis = (d == 1 or d == 3) and 0 or 1

                for _, b in ipairs(nodes) do
                    local by = NY[b]

                    if (by >= lo and by <= hi) then
                        local code = (d <= 2) and self:Link(C, a, b, axis) or self:Link(C, b, a, axis)

                        if (code ~= L_BLOCKED and code ~= L_HOLE) then
                            local rise = by - ay
                            local run = sqrt((NX[b] - ax) ^ 2 + (NZ[b] - az) ^ 2)

                            if (code == L_WALK) then
                                found = found or b
                                relax(a, b, WALK, run + abs(rise) * 0.5)
                            elseif (rise > 0) then
                                if (code ~= L_DROP_ONLY and rise <= jumpUp) then
                                    relax(a, b, JUMP, run + rise + jumpCost)
                                end
                            elseif (code ~= L_JUMP_ONLY and -rise <= maxDrop) then
                                relax(a, b, DROP, run - rise * 0.25 + dropCost)
                            end
                        end
                    end
                end
            end

            walkable[d] = found
        end

        -- Diagonals only where both ways round the corner are walkable, so corners are never cut.
        for dxDir = 1, 3, 2 do
            local b = walkable[dxDir]

            if (b) then
                for dzDir = 2, 4, 2 do
                    local c = walkable[dzDir]

                    if (c) then
                        local corner = self:WalkTo(C, b, dzDir)

                        if (corner and corner == self:WalkTo(C, c, dxDir) and self:Diagonal(C, a, corner)) then
                            relax(a, corner, WALK, sqrt((NX[corner] - ax) ^ 2 + (NZ[corner] - az) ^ 2) + abs(NY[corner] - ay) * 0.5)
                        end
                    end
                end
            end
        end

        local gaps = C.gaps[a]

        if (gaps == nil) then
            gaps = self:Gaps(C, a)
        end

        if (gaps) then
            for _, edge in ipairs(gaps) do
                relax(a, edge.node, edge.kind, edge.cost, edge)
            end
        end
    end

    local straight = sqrt((gx - sx) ^ 2 + (gz - sz) ^ 2)
    local budget = min(options.MaxNodes, floor((straight / cell) ^ 2 * 0.75) + 700)

    -- No node at the goal means it can only ever be approached; do not flood the map trying.
    if (not goalKey and tolerance <= 0) then
        budget = min(budget, 1500)
    end

    local expanded = 0
    local best, bestH = nil, huge
    local reached = nil
    local frame = options.FrameBudget
    local yieldable = coroutine.isyieldable()
    local near = cell * 1.5

    while (size > 0) do
        local a

        a, size = HeapPop(priorities, keys, size)

        if (not closed[a]) then
            closed[a] = true
            expanded += 1

            local hx, hz = NX[a] - gx, NZ[a] - gz
            local flat = sqrt(hx * hx + hz * hz)
            -- Closest for a partial path: height counts for more than it does in the heuristic,
            -- or the spot straight above or below the goal on another level wins.
            local h = flat + abs(NY[a] - gy) * 1.5

            if (h < bestH) then
                best, bestH = a, h
            end

            if (a == goalKey) then
                reached = a
                break
            end

            if (tolerance > 0 and flat <= tolerance and abs(NY[a] - gy) <= tolerance + self.height) then
                reached = a
                break
            end

            if (groundGoal and flat <= near and abs(NY[a] - gy) <= step + 1 and self:WalkLine(NX[a], NY[a], NZ[a], gx, gy, gz, allowWater, huge)) then
                reached = a
                goalKey = a
                break
            end

            -- A goal with no ground under it (mid-air, inside something): right beside it is
            -- as reached as it will ever get.
            if (not groundGoal and flat <= near and abs(NY[a] - gy) <= self.height + 2) then
                reached = a
                break
            end

            expand(a)

            if (expanded >= budget) then
                break
            end

            if (yieldable and expanded % 12 == 0 and clock() - slice > frame) then
                work += clock() - slice
                task.wait()
                slice = clock()

                if (token.cancelled) then
                    return finish("Cancelled")
                end
            end
        end
    end

    result.Stats.Nodes = expanded
    result.Explored = closed

    local last = reached

    if (not last) then
        if (not options.AllowPartial or not best) then
            return finish((expanded >= budget) and "Budget" or "Unreachable")
        end

        last = best
        result.Partial = true
    end

    -- Walk the parents back, then lay the points out start to end.
    local chain = {}
    local key = last

    while (key) do
        chain[#chain + 1] = key
        key = parent[key]
    end

    local points = { { x = sx, y = sy, z = sz, kind = WALK, mult = 1 } }

    for index = #chain, 1, -1 do
        local node = chain[index]
        local kind = via[node]

        if (kind == GAP) then
            local edge = gapOf[node]

            points[#points + 1] = { x = edge.tx, y = edge.ty, z = edge.tz, kind = WALK, mult = 1 }
            points[#points + 1] = { x = edge.lx, y = edge.ly, z = edge.lz, kind = GAP, mult = 1 }
            kind = WALK
        elseif (kind == CLIMB) then
            local edge = gapOf[node]

            points[#points + 1] = { x = edge.tx, y = edge.ty, z = edge.tz, kind = WALK, mult = 1 }
        end

        points[#points + 1] = { x = NX[node], y = NY[node], z = NZ[node], kind = kind, mult = NM[node] * (zoneOf[node] or 1) }
    end

    if (reached and reached == goalKey and groundGoal) then
        local tail = points[#points]

        if (sqrt((tail.x - gx) ^ 2 + (tail.z - gz) ^ 2) > 0.5 and self:WalkLine(tail.x, tail.y, tail.z, gx, gy, gz, allowWater, huge)) then
            points[#points + 1] = { x = gx, y = gy, z = gz, kind = WALK, mult = 1 }
        end
    end

    result.Points = points
    result.Zones = zones
    result.AllowWater = allowWater
    result.Status = reached and Status.Success or Status.ClosestNoPath

    return finish(reached and "Reached" or ((expanded >= budget) and "Budget" or "Unreachable"))
end

-- String pulling: inside every run of walked points, drop the ones a straight line can skip.
-- Jumps, drops and gap landings always survive because they start a new run.
function World:Smooth(points, allowWater)
    local out = { points[1] }
    local count = #points
    local anchor = 1

    while (anchor < count) do
        local stop = anchor + 1

        -- The run ends at the next point that is not a plain walk.
        while (stop < count and points[stop].kind == WALK and points[stop + 1].kind == WALK) do
            stop += 1
        end

        if (points[stop].kind == WALK and stop > anchor + 1) then
            local from = points[anchor]
            local limit = min(stop, anchor + 30)
            local mults = {}
            local mult = 1

            -- A shortcut may cross ground as costly as what the route up to that point crossed,
            -- and no more: a route that skirts a zone before entering it keeps skirting it.
            for index = anchor, limit do
                mult = max(mult, points[index].mult)
                mults[index] = mult
            end

            -- Furthest point visible from the anchor, by bisection.
            local lo, hi = anchor + 1, limit

            while (lo < hi) do
                local mid = ceil((lo + hi) / 2)
                local target = points[mid]

                if (self:WalkLine(from.x, from.y, from.z, target.x, target.y, target.z, allowWater, mults[mid])) then
                    lo = mid
                else
                    hi = mid - 1
                end
            end

            stop = lo
        end

        out[#out + 1] = points[stop]
        anchor = stop
    end

    return out
end

----------------------------------------------------------------------------------------------------
-- [5] PATH
----------------------------------------------------------------------------------------------------

local Debug -- defined in [7]

local Worlds = {}

local function Resolve(params)
    local options = {}

    for name, value in pairs(Defaults) do
        options[name] = value
    end

    for name, value in pairs(params or {}) do
        options[name] = value
    end

    return options
end

-- Paths created with the same settings share one World, and so one cache.
local function WorldFor(options)
    local parts = {}

    for name, value in pairs(options) do
        parts[#parts + 1] = name .. "=" .. tostring(value)
    end

    table.sort(parts)

    local signature = table.concat(parts, ";")
    local world = Worlds[signature]

    if (not world) then
        world = World.new(options)
        Worlds[signature] = world
    end

    return world
end

local Path = {}
Path.__index = Path

local PathCount = 0

function Path.new(params)
    local self = setmetatable({}, Path)

    PathCount += 1

    self.Id = PathCount
    self.Options = Resolve(params)
    self.World = WorldFor(self.Options)
    self.Status = Status.NoPath
    self.Reason = "NotComputed"
    self.Partial = false
    self.Blocked = Signal.new()
    self.Stats = { Nodes = 0, Queries = 0, Time = 0, Work = 0, Length = 0 }
    self.waypoints = {}
    self.token = nil

    return self
end

-- Yields. Sets Status to Enum.PathStatus.Success, ClosestNoPath (partial) or NoPath.
-- `tolerance` (studs) accepts any reachable point that close to the goal, for goals that are
-- inside something solid (a tree, an ore, an NPC).
function Path:ComputeAsync(start, goal, tolerance)
    -- Debounce: the same question again within a tenth of a second gets the same answer. Callers
    -- written against Roblox's slow compute tend to ask every frame once the answer is instant.
    local now = clock()

    if (self.askedAt and now - self.askedAt < 0.1 and tolerance == self.askedTolerance and (start - self.askedStart).Magnitude < 1 and (goal - self.askedGoal).Magnitude < 1) then
        return self.Status == Status.Success
    end

    if (self.token) then
        self.token.cancelled = true
    end

    local token = { cancelled = false }
    local world = self.World

    self.token = token

    local ok, result = pcall(world.Search, world, start, goal, tolerance or self.Options.GoalTolerance, token)

    if (token.cancelled) then
        return false
    end

    self.token = nil

    if (not ok) then
        self.Status = Status.NoPath
        self.Reason = "Error: " .. tostring(result)
        self.Partial = false
        self.waypoints = {}
        warn("[kesosense] compute failed: " .. tostring(result))

        return false
    end

    local waypoints = {}
    local length = 0

    if (result.Points) then
        local before = world.queries
        local smoothStart = clock()
        -- Smoothing must not cut through a zone the search paid to go around.
        world.lineZones = result.Zones

        local points = world:Smooth(result.Points, result.AllowWater)

        world.lineZones = nil

        result.Stats.Queries += world.queries - before
        result.Stats.Work += clock() - smoothStart
        result.Stats.Time += clock() - smoothStart

        for index, point in ipairs(points) do
            local position = Vector3.new(point.x, point.y, point.z)

            if (index > 1) then
                length += (position - waypoints[index - 1].Position).Magnitude
            end

            waypoints[index] =
            {
                Position = position,
                Action = ((point.kind == JUMP or point.kind == GAP) and Action.Jump) or ((point.kind == CLIMB) and Action.Custom) or Action.Walk,
                Label = LABELS[point.kind],
            }
        end
    end

    self.waypoints = waypoints
    self.Status = result.Status
    self.Reason = result.Reason
    self.Partial = result.Partial
    self.Stats = result.Stats
    self.Stats.Length = length
    self.Goal = goal
    self.askedAt = clock()
    self.askedStart = start
    self.askedGoal = goal
    self.askedTolerance = tolerance

    if (Debug.Enabled) then
        Debug:Search(self, result)
    end

    return self.Status == Status.Success
end

function Path:GetWaypoints()
    return self.waypoints
end

-- Index of the first waypoint (from `from`) that can no longer be walked to, or -1.
function Path:CheckOcclusionAsync(from)
    local waypoints = self.waypoints
    local world = self.World

    for index = max(from or 2, 2), #waypoints do
        local waypoint = waypoints[index]

        if (waypoint.Label == "Walk") then
            local a, b = waypoints[index - 1].Position, waypoint.Position

            if (not world:WalkLine(a.X, a.Y, a.Z, b.X, b.Y, b.Z, true, huge)) then
                return index
            end
        end
    end

    return -1
end

function Path:Destroy()
    if (self.token) then
        self.token.cancelled = true
    end

    self.Blocked:Destroy()
    self.waypoints = {}
    Debug:Clear("path" .. self.Id)
end

----------------------------------------------------------------------------------------------------
-- [6] NAVIGATOR
--
-- Drives a Humanoid along a Path. This is where "does not get stuck" comes from:
--   * waypoints count as reached by distance OR by having run past them
--   * gap jumps fire when the ground ahead actually ends, not at a guessed spot
--   * progress is measured; no progress escalates: hop -> avoid the cell and replan -> back off
--     and replan -> give up and say so (it never spins forever)
--   * the segment ahead is re-checked against the live world, falling off the route replans
--   * moving goals replan on a budget, and the old route keeps being followed meanwhile
----------------------------------------------------------------------------------------------------

local Navigator = {}
Navigator.__index = Navigator

local Navigators = {}

local NavigatorDefaults =
{
    StopDistance = 1.5,     -- done when this close to the goal (flat studs)
    RepathDistance = 4,     -- a moving goal replans after it moved this far
    RepathInterval = 0.5,   -- and no more often than this
    ReachRadius = 1.5,      -- a waypoint is reached within this distance
    StuckInterval = 0.4,    -- how often progress is measured
    MaxFailures = 3,        -- failed computes in a row before giving up
    OffPathDistance = 7,    -- further than this from the route replans
    Timeout = nil,          -- seconds before MoveTo gives up
}

-- Humanoid.Jump is ignored by some games' control scripts; forcing the state always works.
-- Only ever called while grounded, so it cannot double jump.
local function Leap(humanoid)
    humanoid.Jump = true
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end

function Navigator.new(params)
    local self = setmetatable({}, Navigator)

    self.Options = {}

    for name, value in pairs(NavigatorDefaults) do
        self.Options[name] = value
    end

    local pathParams = {}

    for name, value in pairs(params or {}) do
        if (NavigatorDefaults[name] ~= nil or name == "Timeout") then
            self.Options[name] = value
        else
            pathParams[name] = value
        end
    end

    self.Path = Path.new(pathParams)
    self.State = "Idle"
    self.Finished = Signal.new()            -- (reached: boolean, reason: string)
    self.Stuck = Signal.new()               -- (level: number)
    self.WaypointReached = Signal.new()     -- (index: number, waypoint)
    self.Computed = Signal.new()            -- (path)
    self.OnStuck = nil                      -- optional function(navigator, level) -> true when it handled it
    self.active = false
    self.serial = 0

    Navigators[self] = true

    return self
end

function Navigator:Goal()
    local target = self.target
    local kind = typeof(target)

    if (kind == "Vector3") then
        return target
    elseif (kind == "function") then
        return target()
    elseif (kind == "Instance") then
        if (not target.Parent) then
            return nil
        end

        if (target:IsA("BasePart")) then
            return target.Position
        elseif (target:IsA("Model")) then
            return target:GetPivot().Position
        end
    end

    return nil
end

-- target: Vector3, BasePart, Model, or a function returning a Vector3 (a moving goal).
-- options: StopDistance, Timeout, Tolerance (how far from the goal a path may end).
-- Returns immediately; listen to Finished or use MoveToAsync.
function Navigator:MoveTo(target, options)
    options = options or {}

    self.serial += 1
    self.target = target
    self.stop = options.StopDistance or self.Options.StopDistance
    self.tolerance = options.Tolerance or max(self.stop - 1, 0)
    self.deadline = (options.Timeout or self.Options.Timeout) and (clock() + (options.Timeout or self.Options.Timeout)) or nil

    self.waypoints = nil
    self.index = 1
    self.partial = false
    self.computing = false
    self.replan = true
    self.planAfter = 0
    self.nextRepath = 0
    self.planGoal = nil
    self.failures = 0
    self.partials = 0
    self.closest = huge
    self.moveAt = 0
    self.jumpedAt = 0
    self.stuck = 0
    self.stuckAt = clock() + self.Options.StuckInterval
    self.stuckFrom = nil
    self.backUntil = 0
    self.checkAt = 0
    self.blockedHits = 0
    self.blockedIndex = nil
    self.hopAt = 0
    self.safe = nil
    self.State = "Computing"

    if (not self.active) then
        self.active = true

        self.connection = RunService.Heartbeat:Connect(function()
            local ok, problem = pcall(self.Step, self)

            if (not ok) then
                warn("[kesosense] navigator error: " .. tostring(problem))
                self:Finish(false, "Error")
            end
        end)
    end
end

function Navigator:MoveToAsync(target, options)
    self:MoveTo(target, options)

    return self.Finished:Wait()
end

function Navigator:Finish(reached, reason)
    if (not self.active) then
        return
    end

    self.active = false
    self.serial += 1
    self.State = "Idle"
    self.waypoints = nil

    if (self.connection) then
        self.connection:Disconnect()
        self.connection = nil
    end

    local _, humanoid, root = self.Path.World:Rig()

    if (humanoid and root) then
        humanoid:MoveTo(root.Position)
    end

    Debug:Clear("nav" .. self.Path.Id)
    Debug:Text(string.format("nav #%d  finished: %s (%s)", self.Path.Id, tostring(reached), tostring(reason)), 2)
    self.Finished:Fire(reached, reason)
end

function Navigator:Stop()
    self:Finish(false, "Stopped")
end

-- Replaces the list of things that must never be touched. Safe to call between moves.
function Navigator:SetHazards(list)
    self.Path.World:SetHazards(list)
end

function Navigator:Destroy()
    self:Stop()
    self.Path:Destroy()
    Navigators[self] = nil
end

function Navigator:Plan(position, goal)
    local serial = self.serial
    local path = self.Path

    self.computing = true
    self.replan = false
    self.planGoal = goal
    self.nextRepath = clock() + self.Options.RepathInterval

    task.spawn(function()
        local ok = path:ComputeAsync(position, goal, self.tolerance)

        if (self.serial ~= serial or not self.active) then
            return
        end

        self.computing = false

        local waypoints = path:GetWaypoints()
        local usable = ok

        -- A partial path is worth walking only while it keeps getting closer to the goal.
        if (not ok and path.Partial and #waypoints >= 2) then
            local remaining = (waypoints[#waypoints].Position - goal).Magnitude

            if (remaining < self.closest - 2) then
                self.closest = remaining
                self.partials = 0
                usable = true
            else
                self.partials += 1
                usable = self.partials < 2 and remaining < (position - goal).Magnitude - 2
            end
        end

        if (usable) then
            if (ok) then
                self.failures = 0
            end

            self.waypoints = waypoints
            self.index = 2
            self.partial = path.Partial
            self.moveAt = 0
            self.blockedIndex = nil
            self.blockedHits = 0
            self.State = "Moving"
            self.Computed:Fire(path)
        else
            self.failures += 1

            if (self.failures >= self.Options.MaxFailures) then
                self:Finish(false, "NoPath")
            else
                self.replan = true
                self.planAfter = clock() + 0.4
            end
        end
    end)
end

function Navigator:Recover(level, humanoid, root, world, direction)
    self.Stuck:Fire(level)

    if (self.OnStuck and self.OnStuck(self, level)) then
        self.stuck = 0
        return
    end

    if (level == 2) then
        -- Probably caught on a lip.
        Leap(humanoid)
        self.moveAt = 0
    elseif (level == 4) then
        -- Whatever is ahead is not what the map said: forget the map, avoid the spot, plan again.
        world:Avoid(root.Position + direction * 2.5)
        world:Flush()
        self.replan = true
        self.planAfter = 0
    elseif (level == 6) then
        local position = root.Position
        local back = self.safe

        if (not back or (back - position).Magnitude < 2 or (back - position).Magnitude > 20) then
            back = position - direction * 5
        end

        world:Avoid(position + direction * 2.5)
        world:Avoid(position)
        world:Flush()
        self.backTo = back
        self.backUntil = clock() + 0.7
        self.replan = true
        self.planAfter = clock() + 0.6
        self.waypoints = nil
    elseif (level >= 9) then
        self:Finish(false, "Stuck")
    end
end

function Navigator:Step()
    local path = self.Path
    local world = path.World
    local _, humanoid, root = world:Rig()

    if (not root or humanoid.Health <= 0) then
        return self:Finish(false, "NoCharacter")
    end

    local now = clock()
    local goal = self:Goal()

    if (not goal) then
        return self:Finish(false, "TargetLost")
    end

    if (self.deadline and now > self.deadline) then
        return self:Finish(false, "Timeout")
    end

    local options = self.Options
    local position = root.Position
    local feet = position.Y - world.groundOffset
    local state = humanoid:GetState()
    local swimming = (state == Enum.HumanoidStateType.Swimming)
    local climbing = (state == Enum.HumanoidStateType.Climbing)
    local grounded = ((humanoid.FloorMaterial ~= Enum.Material.Air) or swimming) and not climbing
    local goalFlat = sqrt((goal.X - position.X) ^ 2 + (goal.Z - position.Z) ^ 2)

    if (goalFlat <= self.stop and abs(goal.Y - feet) <= max(self.stop, world.height + 2)) then
        return self:Finish(true, "Reached")
    end

    if (not self.computing and now >= self.planAfter) then
        local need = self.replan or not self.waypoints

        if (not need and now >= self.nextRepath and self.planGoal and (goal - self.planGoal).Magnitude > max(options.RepathDistance, goalFlat * 0.12)) then
            need = true
        end

        -- Planning from mid-air snaps the start to whatever is underneath; wait for the landing.
        if (need and (grounded or not self.waypoints)) then
            self:Plan(position, goal)
        end
    end

    if (now < self.backUntil) then
        if (now >= self.moveAt) then
            self.moveAt = now + 0.2
            humanoid:MoveTo(self.backTo)
        end

        return
    end

    local waypoints = self.waypoints

    if (not waypoints) then
        return
    end

    local index = self.index
    local waypoint = waypoints[index]

    if (not waypoint) then
        -- Walked the whole route. Done, unless it was partial or the goal has moved on.
        if (not self.partial and self.planGoal and (goal - self.planGoal).Magnitude <= options.RepathDistance) then
            return self:Finish(true, "Reached")
        end

        self.waypoints = nil
        self.replan = true

        return
    end

    local target = waypoint.Position
    local dx, dz = target.X - position.X, target.Z - position.Z
    local flat = sqrt(dx * dx + dz * dz)
    local label = waypoint.Label
    local nextWaypoint = waypoints[index + 1]
    local previous = waypoints[index - 1].Position
    local direction = (flat > 0.05) and Vector3.new(dx / flat, 0, dz / flat) or (root.CFrame.LookVector * Vector3.new(1, 0, 1))

    -- Reached?
    local reached = false
    local level = abs(feet - target.Y) <= world.step + 2.5

    if (label == "Walk") then
        local radius = options.ReachRadius

        if (not nextWaypoint) then
            radius = 1
        elseif (nextWaypoint.Label == "Gap") then
            radius = 0.9
        end

        if (level and flat <= radius) then
            reached = true
        elseif (level and nextWaypoint and nextWaypoint.Label ~= "Gap" and flat < 5) then
            -- Ran past it: on the far side of the plane through the waypoint.
            reached = ((position.X - target.X) * (target.X - previous.X) + (position.Z - target.Z) * (target.Z - previous.Z)) > 0
        end
    else
        -- Landings count once the feet are actually on them.
        reached = grounded and flat <= 2.2 and feet >= target.Y - 1 and feet <= target.Y + world.step + 2.5
    end

    if (reached) then
        self.index = index + 1
        self.moveAt = 0

        if (grounded) then
            self.safe = position
        end

        self.WaypointReached:Fire(index, waypoint)

        return
    end

    -- Jumps.
    if (waypoint.Action == Action.Jump and grounded and now - self.jumpedAt > 0.45) then
        local jump = false

        if (swimming) then
            humanoid.Jump = true
            self.jumpedAt = now
        else
            -- Take off where the ground ends, wherever that turns out to be. A ledge with no
            -- hole in front of it is jumped once its face is right ahead.
            local ahead = world:GroundAt(position.X + direction.X * 1.2, feet, position.Z + direction.Z * 1.2, 1.5, 2.5)

            jump = (ahead == nil or ahead < feet - 1.5)

            if (not jump and label == "Jump" and feet < target.Y - 0.5) then
                jump = flat <= 3 or Workspace:Raycast(Vector3.new(position.X, feet + world.step + 0.3, position.Z), direction * 2, world.solidParams) ~= nil
            end
        end

        if (jump) then
            self.jumpedAt = now
            Leap(humanoid)
            humanoid:MoveTo(target)
            self.moveAt = now + 0.2
        end
    end

    if (swimming and target.Y > feet + 0.5) then
        humanoid.Jump = true
    end

    if (now >= self.moveAt) then
        self.moveAt = now + 0.2
        humanoid:MoveTo(target)
    end

    -- A low thing in the way that the route did not know about: hop it.
    if (label == "Walk" and grounded and now >= self.hopAt) then
        self.hopAt = now + 0.2

        local low = Workspace:Raycast(Vector3.new(position.X, feet + 0.7, position.Z), direction * 2.2, world.solidParams)

        if (low and low.Normal.Y < 0.4 and not Workspace:Raycast(Vector3.new(position.X, feet + world.jumpUp + 0.5, position.Z), direction * 2.5, world.solidParams)) then
            Leap(humanoid)
        end
    end

    -- Route checks.
    if (now >= self.checkAt and grounded) then
        self.checkAt = now + 0.5

        -- Fell below the route or drifted far off it.
        local along = (target - previous) * Vector3.new(1, 0, 1)
        local offset = (position - previous) * Vector3.new(1, 0, 1)
        local lateral = (along.Magnitude > 0.1) and abs(along.Unit:Cross(offset).Y) or 0

        if ((label ~= "Drop" and feet < min(target.Y, previous.Y) - world.jumpUp - 3) or lateral > options.OffPathDistance) then
            self.replan = true
            self.planAfter = 0
        elseif (label == "Walk" and self.blockedIndex ~= index) then
            -- Is the stretch ahead still walkable in the live world?
            local ground = world:GroundAt(position.X, feet, position.Z, 1.5, 3)

            if (ground) then
                local reachAhead = min(flat, 14)
                local clear = world:WalkLine(position.X, ground, position.Z, position.X + direction.X * reachAhead, (flat <= 14) and target.Y or ground, position.Z + direction.Z * reachAhead, true, huge)

                if (clear or flat > 14) then
                    self.blockedHits = clear and 0 or self.blockedHits
                end

                if (not clear and flat <= 14) then
                    self.blockedHits += 1

                    if (self.blockedHits >= 2) then
                        self.blockedHits = 0
                        self.blockedIndex = index
                        world:Flush()
                        path.Blocked:Fire(index)
                        self.replan = true
                        self.planAfter = 0
                    end
                end
            end
        end
    end

    -- Progress.
    if (now >= self.stuckAt) then
        local moved = self.stuckFrom and (position - self.stuckFrom).Magnitude or huge

        if ((grounded or climbing) and moved < max(0.6, humanoid.WalkSpeed * options.StuckInterval * 0.2)) then
            self.stuck += 1
            self:Recover(self.stuck, humanoid, root, world, direction)
        else
            self.stuck = 0
        end

        self.stuckAt = now + options.StuckInterval
        self.stuckFrom = position
    end

    if (Debug.Enabled and self.active) then
        if (now >= (self.drawAt or 0)) then
            self.drawAt = now + 0.1

            local group = "nav" .. path.Id
            local layer = Debug:Layer(group, "Target", 2)

            layer:Clear()
            layer:AddLine(position - Vector3.new(0, world.groundOffset - 0.4, 0), target + Vector3.new(0, 0.4, 0))
            Debug:Marker(layer, target + Vector3.new(0, 0.4, 0), 0.7)
            Debug:Text(string.format("nav #%d  %s  waypoint %d/%d (%s)  %.1f studs to it  %.0f to goal  stuck %d%s",
                path.Id, self.State, index, #waypoints, label, flat, goalFlat, self.stuck, self.computing and "  [replanning]" or ""), 2)
        end
    end
end

----------------------------------------------------------------------------------------------------
-- [7] DEBUG
--
-- Everything is drawn with WireframeHandleAdornments parented outside Workspace (gethui/CoreGui)
-- and adorned to Terrain: one instance per colour, thousands of lines each, invisible to the game.
----------------------------------------------------------------------------------------------------

Debug =
{
    Enabled = false,
    Explored = true,        -- draw every node the search closed
    OnTop = true,           -- draw through walls
    Hud = true,
    Thickness = 3,
    MaxExplored = 4000,

    Colors =
    {
        Path = Color3.fromRGB(0, 255, 170),
        Walk = Color3.fromRGB(255, 255, 255),
        Jump = Color3.fromRGB(255, 221, 0),
        Drop = Color3.fromRGB(255, 140, 0),
        Gap = Color3.fromRGB(255, 0, 200),
        Climb = Color3.fromRGB(0, 200, 255),
        Goal = Color3.fromRGB(0, 255, 0),
        Explored = Color3.fromRGB(70, 130, 255),
        Costly = Color3.fromRGB(170, 90, 255),
        Avoid = Color3.fromRGB(255, 40, 40),
        Target = Color3.fromRGB(255, 255, 0),
    },

    layers = {},
    root = nil,
    label = nil,
}

function Debug:Root()
    if (self.root and self.root.Parent) then
        return self.root
    end

    local folder = Instance.new("Folder")
    local parent = nil

    folder.Name = "kesosense"

    if (gethui) then
        parent = gethui()
    else
        local ok, core = pcall(game.GetService, game, "CoreGui")

        parent = ok and core or Workspace
    end

    local ok = pcall(function()
        folder.Parent = parent
    end)

    if (not ok) then
        folder.Parent = Workspace
    end

    self.root = folder

    return folder
end

function Debug:Layer(group, color, thickness)
    local name = group .. "/" .. color
    local layer = self.layers[name]

    if (layer and layer.Parent) then
        return layer
    end

    layer = Instance.new("WireframeHandleAdornment")
    layer.Name = name
    layer.Adornee = Workspace.Terrain
    layer.AlwaysOnTop = self.OnTop
    layer.Color3 = self.Colors[color]
    layer.Thickness = thickness or self.Thickness
    layer.ZIndex = 5
    layer.Parent = self:Root()

    self.layers[name] = layer

    return layer
end

function Debug:Clear(group)
    for name, layer in pairs(self.layers) do
        if (not group or name:sub(1, #group + 1) == group .. "/") then
            layer:Destroy()
            self.layers[name] = nil
        end
    end
end

function Debug:Marker(layer, position, size)
    local x, z = Vector3.new(size, 0, 0), Vector3.new(0, 0, size)

    layer:AddPath({ position + x, position + z, position - x, position - z }, true)
    layer:AddLine(position, position + Vector3.new(0, size * 2, 0))
end

function Debug:Search(path, result)
    local group = "path" .. path.Id
    local lift = Vector3.new(0, 0.35, 0)

    self:Clear(group)

    if (self.Explored and result.Explored) then
        local C = result.Cache
        local plain, costly = {}, {}
        local count = 0

        for key in pairs(result.Explored) do
            local position = Vector3.new(C.NX[key], C.NY[key] + 0.1, C.NZ[key])
            local list = (C.NM[key] > 1) and costly or plain

            list[#list + 1] = position - Vector3.new(0.3, 0, 0)
            list[#list + 1] = position + Vector3.new(0.3, 0, 0)
            list[#list + 1] = position - Vector3.new(0, 0, 0.3)
            list[#list + 1] = position + Vector3.new(0, 0, 0.3)
            count += 1

            if (count >= self.MaxExplored) then
                break
            end
        end

        if (#plain > 0) then
            self:Layer(group, "Explored", 1):AddLines(plain)
        end

        if (#costly > 0) then
            self:Layer(group, "Costly", 1):AddLines(costly)
        end
    end

    local waypoints = path.waypoints

    for index = 2, #waypoints do
        local from, to = waypoints[index - 1], waypoints[index]
        local a, b = from.Position + lift, to.Position + lift

        if (to.Label == "Walk") then
            self:Layer(group, "Path"):AddLine(a, b)
        else
            -- Jumps, drops and gaps are drawn as an arc in their own colour.
            local apex = (to.Label == "Drop") and 0.5 or (path.World.apex * 0.6)
            local mid = (a + b) * 0.5 + Vector3.new(0, max(a.Y, b.Y) - (a.Y + b.Y) * 0.5 + apex, 0)

            self:Layer(group, to.Label):AddPath({ a, (a + mid) * 0.5 + Vector3.new(0, apex * 0.25, 0), mid, (mid + b) * 0.5 + Vector3.new(0, apex * 0.25, 0), b }, false)
        end

        self:Marker(self:Layer(group, (index == #waypoints) and "Goal" or to.Label), b, (index == #waypoints) and 0.9 or 0.5)
    end

    if (path.World.avoidCount > 0) then
        local world = path.World
        local layer = self:Layer(group, "Avoid")
        local half = world.cell * 0.5

        for column in pairs(world.avoid) do
            local iz = column % COLS
            local ix = (column - iz) / COLS
            local x, z = world.ox + (ix - OFF) * world.cell, world.oz + (iz - OFF) * world.cell
            local y = waypoints[1] and waypoints[1].Position.Y or 0

            layer:AddPath({ Vector3.new(x - half, y, z - half), Vector3.new(x + half, y, z - half), Vector3.new(x + half, y, z + half), Vector3.new(x - half, y, z + half) }, true)
        end
    end

    local stats = path.Stats

    self:Text(string.format("path #%d  %s (%s)  %d waypoints  %.0f studs  |  %d nodes  %d queries  %.1f ms work  %.0f ms wall",
        path.Id, path.Status.Name, tostring(path.Reason), #waypoints, stats.Length, stats.Nodes, stats.Queries, stats.Work * 1000, stats.Time * 1000), 1)
end

function Debug:Text(text, line)
    if (not self.Enabled or not self.Hud) then
        return
    end

    if (not (self.label and self.label.Parent)) then
        local gui = Instance.new("ScreenGui")

        gui.Name = "kesosense_hud"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 9999

        local label = Instance.new("TextLabel")

        label.Size = UDim2.new(0, 760, 0, 44)
        label.Position = UDim2.new(0.5, -380, 1, -150)
        label.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
        label.BackgroundTransparency = 0.25
        label.BorderSizePixel = 0
        label.TextColor3 = Color3.fromRGB(0, 255, 170)
        label.Font = Enum.Font.Code
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.Text = ""
        label.Parent = gui

        local padding = Instance.new("UIPadding")

        padding.PaddingLeft = UDim.new(0, 8)
        padding.PaddingTop = UDim.new(0, 5)
        padding.Parent = label

        gui.Parent = self:Root()
        self.label = label
        self.lines = { "kesosense " .. VERSION, "" }
    end

    self.lines[line] = text
    self.label.Text = self.lines[1] .. "\n" .. self.lines[2]
end

function Debug:Set(enabled)
    if (type(enabled) == "table") then
        for name, value in pairs(enabled) do
            self[name] = value
        end
    else
        self.Enabled = enabled and true or false
    end

    if (not self.Enabled) then
        self:Clear()

        if (self.label) then
            self.label.Parent:Destroy()
            self.label = nil
        end
    end
end

----------------------------------------------------------------------------------------------------
-- [8] EXPORT
----------------------------------------------------------------------------------------------------

local kesosense =
{
    Version = VERSION,
    Defaults = Defaults,
    Debug = Debug,
    Navigator = Navigator,
    Path = Path,
    World = World,
    Signal = Signal,
}

function kesosense:CreatePath(params)
    return Path.new(params)
end

function kesosense:CreateNavigator(params)
    return Navigator.new(params)
end

function kesosense:SetDebug(enabled)
    Debug:Set(enabled)
end

-- Throws away everything every World believes about the map.
function kesosense:Invalidate()
    for _, world in pairs(Worlds) do
        world:Flush()
    end
end

function kesosense:Unload()
    for navigator in pairs(Navigators) do
        pcall(navigator.Destroy, navigator)
    end

    Debug:Set(false)

    if (Debug.root) then
        Debug.root:Destroy()
        Debug.root = nil
    end

    table.clear(Worlds)
    Tracked:Stop()

    if (rawget(Environment, "kesosense") == self) then
        Environment.kesosense = nil
    end
end

Environment.kesosense = kesosense

return kesosense
