

repeat task.wait() until game:IsLoaded()

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local virtualUser = game:GetService("VirtualUser")
local IdledConnection = LocalPlayer.Idled:Connect(function()
    virtualUser:CaptureController()
    virtualUser:ClickButton2(Vector2.new())
end)

local libfile = readfile("lib.lua")
local Library = loadstring(libfile)()
--local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/quadshoota/RBLX/refs/heads/main/ServerlistDatabase.lua"))()
local Storage =
{
    Icons = {},
    ConfigsPath = nil,
}

local Services = 
{
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    VirtualUser = game:GetService("VirtualUser"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Debris = game:GetService("Debris"),
    UserInputService = game:GetService("UserInputService"),
}


local Helpers =
{
    FrameConnections =
    {
        Hiteffects = nil,
    },

    FrameData =
    {
        Storage = {},
    },


    BoostFrames = function(self)
        for _, obj in pairs(Workspace:GetDescendants()) do
            if (obj:IsA("BasePart")) then
                table.insert(self.FrameData.Storage, {obj, obj.Material, obj.Reflectance, obj.CastShadow})
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.CastShadow = false
            elseif (obj:IsA("Decal") or obj:IsA("Texture")) then
                table.insert(self.FrameData.Storage, {obj, obj.Transparency})
                obj.Transparency = 1
            elseif (obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire")) then
                table.insert(self.FrameData.Storage, {obj, obj.Enabled})
                obj.Enabled = false
            end
        end

        for _, effect in pairs(Lighting:GetChildren()) do
            if (effect:IsA("PostEffect")) then
                table.insert(self.FrameData.Storage, {effect, effect.Enabled})
                table.insert(self.FrameData.Storage, {effect, effect.Enabled})
                effect.Enabled = false
            end
        end

        table.insert(self.FrameData.Storage, {Lighting, Lighting.GlobalShadows})
        table.insert(self.FrameData.Storage, {Lighting, Lighting.FogEnd})
        table.insert(self.FrameData.Storage, {settings().Rendering, settings().Rendering.QualityLevel})

        Lighting.GlobalShadows = false
        Lighting.FogEnd = math.huge
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level05

        local monit = workspace
        self.FrameConnections.Hiteffects = monit.ChildAdded:Connect(function(child)
            if (child:IsA("Part")) then
                child:Destroy()
            end
        end)
    end,



    RestoreBoost = function(self)
        if (self.FrameConnections.Hiteffects) then
            self.FrameConnections.Hiteffects:Disconnect()
            self.FrameConnections.Hiteffects = nil
        end

        for _, data in ipairs(self.FrameData.Storage) do
            local obj = data[1]
            if (obj) then
                pcall(function()
                    if (#data == 4) then
                        obj.Material = data[2]
                        obj.Reflectance = data[3]
                        obj.CastShadow = data[4]
                    elseif (#data == 2) then
                        if (obj:IsA("Decal") or obj:IsA("Texture")) then
                            obj.Transparency = data[2]
                        elseif (obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire")) then
                            obj.Enabled = data[2]
                        elseif (obj:IsA("PostEffect")) then
                            obj.Enabled = data[2]
                        elseif (obj == Lighting) then
                            if (typeof(data[2]) == "boolean") then
                                obj.GlobalShadows = data[2]
                            elseif (typeof(data[2]) == "number") then
                                obj.FogEnd = data[2]
                            end
                        elseif (tostring(obj) == "Rendering") then
                            obj.QualityLevel = data[2]
                        end
                    end
                end)
            end
        end

        self.FrameData.Storage = {}
    end,

    ConvertToNumbers = function(self, text)
        -- remove all non-numeric characters.
        text = text:gsub("%D", "")
        return tonumber(text) or 0
    end,

    Contains = function(self, tbl, val)
        for i,v in pairs(tbl) do
            if (v == val) then
                return true
            end
        end

        return false
    end,

    ReturnSeedStock = function(self, seedName)
        local seedpath = game:GetService("Players").LocalPlayer.PlayerGui.Main.Seeds.Frame.ScrollingFrame
        local stock = seedpath:FindFirstChild(seedName).Stock.ContentText
        if (not stock) then
            --warn("Failed to find stock for seed: " .. seedName)
            return 0
        end

        --warn("Seed stock for " .. seedName .. ": " .. self:ConvertToNumbers(stock))
        return self:ConvertToNumbers(stock)
    end,

    ReturnGearStock = function(self, gearName)
        local gearpath = game:GetService("Players").LocalPlayer.PlayerGui.Main.Gears.Frame.ScrollingFrame
        local stock = gearpath:FindFirstChild(gearName).Stock.ContentText
        if (not stock) then
            --warn("Failed to find stock for gear: " .. gearName)
            return 0
        end

        --warn("Gear stock for " .. gearName .. ": " .. self:ConvertToNumbers(stock))
        return self:ConvertToNumbers(stock)
    end,

    GetHighestFromTable = function(self, tbl, amount)
        local sorted = {}
        for key, value in pairs(tbl) do
            table.insert(sorted, {Key = key, Value = value})
        end
        
        table.sort(sorted, function(a, b)
            return a.Value > b.Value
        end)
        
        local result = {}
        for i = 1, math.min(amount, #sorted) do
            result[sorted[i].Key] = sorted[i].Value
        end
        
        return result
    end,

    GetHighestDamageTable = function(self, tbl, amount)
        table.sort(tbl, function(a, b)
            return (a.Damage or 0) > (b.Damage or 0)
        end)
        
        local result = {}
        for i = 1, math.min(amount, #tbl) do
            table.insert(result, tbl[i])
        end
        
        return result
    end,
}

local Globals =
{
    InterfaceKey = Enum.KeyCode.RightControl,
    Rarities = {"Common", "Rare", "Epic", "Legendary", "Mythic", "Godly", "Limited", "Secret"},
    RarityOrder =
    {
        Rare = 1,
        Epic = 2,
        Legendary = 3,
        Mythic = 4,
        Godly = 5,
        Limited = 6,
        Secret = 7,
    },

    --Mutations = {"Gold", "Diamond", "Neon", "Frozen", "UpsideDown", "Rainbow", "Galactic", "Magma", "Underworld"},
    Mutations = {},
    MutationOrder =
    {
        Gold = 1,
        Diamond = 2,
        Neon  = 3,
        Frozen = 4,
        UpsideDown = 5,
        Rainbow = 6,
        Galactic = 7,
        Magma = 8,
        Underworld = 9,
    },

    FuseCombinations = {},

    AllSeeds = {"All"},
    AllGears = {"All"},
    SeedRarities = {},
    GearRarities = {},
}


local seedpath = game:GetService("Players").LocalPlayer.PlayerGui.Main.Seeds.Frame.ScrollingFrame
for i,v in pairs(seedpath:GetChildren()) do
    if (not v:IsA("Frame") or not v:FindFirstChild("Title")) then continue end
    local seedName = v:FindFirstChild("Title").ContentText
    table.insert(Globals.AllSeeds, seedName)
    --warn("Found seed: " .. seedName)
end

local gearpath = game:GetService("Players").LocalPlayer.PlayerGui.Main.Gears.Frame.ScrollingFrame
for i,v in pairs(gearpath:GetChildren()) do
    if (not v:IsA("Frame") or not v:FindFirstChild("Title")) then continue end
    local gearName = v:FindFirstChild("Title").ContentText
    table.insert(Globals.AllGears, gearName)
    --warn("Found gear: " .. gearName)
end


local ModuleCache = {}
local LoadedModules = {}
local ModuleManager = 
{
    LoadModule = function(self, Base, Path)
        local CacheKey = tostring(Base) .. Path
        if (ModuleCache[CacheKey]) then
            return ModuleCache[CacheKey]
        end

        local Components = Path:split(".")
        for _, Component in Components do
            Base = Base:FindFirstChild(Component)
            if (not Base) then
                return {}
            end
        end
        
        local success, result = pcall(require, Base)
        if (success) then
            ModuleCache[CacheKey] = result
            return result
        else
            ModuleCache[CacheKey] = {}
            return {}
        end
    end,

    GetModule = function(self, moduleName)
        if (LoadedModules[moduleName]) then
            return LoadedModules[moduleName]
        end
        
        local moduleConfigs = {
            PlayerData = 
            {
                base = game.ReplicatedStorage,
                path = "PlayerData"
            },

            -- game:GetService("ReplicatedStorage").Modules.Library.BrainrotMutations
            BrainrotMutations =
            {
                base = game.ReplicatedStorage.Modules.Library,
                path = "BrainrotMutations"
            },

            FuseCombinations =
            {
                base = game.ReplicatedStorage.Modules.Library,
                path = "FuseCombinations"
            },

            Chances =
            {
                base = game.ReplicatedStorage.Modules.Library,
                path = "Chances"
            },

            Utils =
            {
                base = game.ReplicatedStorage.Modules.Utility,
                path = "Util"
            },

            PackObj = 
            {
                base = game.Players.LocalPlayer.PlayerScripts.Client.Modules['CardPack [Client]'],
                path = "PackObject"
            },

        }
        
        local config = moduleConfigs[moduleName]
        if (not config) then
            warn("Unknown module:", moduleName)
            LoadedModules[moduleName] = {}
            return {}
        end
        
        local module = self:LoadModule(config.base, config.path)
        LoadedModules[moduleName] = module
        task.wait(0.01)
        
        return module
    end,
}

Globals.MutationOrder = {}
Globals.RarityOrder = {}
for i,v in pairs(ModuleManager:GetModule("BrainrotMutations").Colors) do
    table.insert(Globals.Mutations, i)
    table.insert(Globals.MutationOrder, i)
    Globals.MutationOrder[i] = v.Boost
    --warn("name: " .. i .. " | boost: " .. v.Boost)
end

--PlantRegistry
for i,v in pairs(ModuleManager:GetModule("Chances")) do
    for i2, v2 in pairs(v) do
        if (not Globals.Rarities or not Helpers:Contains(Globals.Rarities, i)) then
            table.insert(Globals.Rarities, i)
            table.insert(Globals.RarityOrder, i)
            Globals.RarityOrder[i] = v.Chance
            --warn("name: " .. i .. " | boost: " .. v.Chance)
        end
    end
end

for i,v in pairs(ModuleManager:GetModule("FuseCombinations")) do
    local plant, brainrot, result = i, v.Brainrot, v.Result
    table.insert(Globals.FuseCombinations, {Plant = plant, Brainrot = brainrot, Result = result})
    --warn("plant: " .. plant .. " | brainrot: " .. brainrot .. " | result: " .. result)
end


local lcl = game.Players.LocalPlayer
local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
local combatevent = game:GetService("ReplicatedStorage").Remotes.AttacksServer.WeaponAttack
local favoriteevent = game:GetService("ReplicatedStorage").Remotes.FavoriteItem
local sellevent = game:GetService("ReplicatedStorage").Remotes.ItemSell
local equipbest = game:GetService("ReplicatedStorage").Remotes.EquipBest
local buygearevent = game:GetService("ReplicatedStorage").Remotes.BuyGear
local buyitem = game:GetService("ReplicatedStorage").Remotes.BuyItem
local pickupevent = game:GetService("ReplicatedStorage").Remotes.RemoveItem
local placeevent = game:GetService("ReplicatedStorage").Remotes.PlaceItem
local useitemevent = game:GetService("ReplicatedStorage").Remotes.UseItem
local packevent = game:GetService("ReplicatedStorage").Remotes.OpenHeldPack
local equipitem = game:GetService("ReplicatedStorage").Remotes.EquipItem
local eggremote = game:GetService("ReplicatedStorage").Remotes.OpenEgg
local mergeevent = game:GetService("ReplicatedStorage").Remotes.MergeCards

local DesyncLibrary = 
{
    DesyncPosition = CFrame.new(0, 0, 0),
    ShouldDesync = false,
    RealPosition = CFrame.new(0, 0, 0),

    HeartBeat = function(self)
        if not game:GetService('Players').LocalPlayer.Character then
            return
        end

        local hrp = game:GetService('Players').LocalPlayer.Character
            :FindFirstChild('HumanoidRootPart')
        local humanoid = game:GetService('Players').LocalPlayer.Character
            :FindFirstChild('Humanoid')

        if self.ShouldDesync and hrp and humanoid and humanoid.Health > 0 then
            self.RealPosition = hrp.CFrame
            hrp.CFrame = self.DesyncPosition
        end
    end,
}

local oldIndex
oldIndex = hookmetamethod(game, '__index', function(self, key)
    if not checkcaller() and key == 'CFrame' and DesyncLibrary.ShouldDesync then
        if
            game:GetService('Players').LocalPlayer.Character
            and game:GetService('Players').LocalPlayer.Character
                :FindFirstChild('HumanoidRootPart')
        then
            if
                game:GetService('Players').LocalPlayer.Character
                    :FindFirstChild('Humanoid')
                and game:GetService('Players').LocalPlayer.Character.Humanoid.Health
                    > 0
            then
                if
                    self
                    == game:GetService('Players').LocalPlayer.Character.HumanoidRootPart
                then
                    return DesyncLibrary.RealPosition
                end
            end
        end
    end
    return oldIndex(self, key)
end)

game:GetService('RunService').RenderStepped:Connect(function()
    if DesyncLibrary.ShouldDesync then
        if game:GetService('Players').LocalPlayer.Character then
            local hrp = game:GetService('Players').LocalPlayer.Character
                :FindFirstChild('HumanoidRootPart')
            if hrp then
                hrp.CFrame = DesyncLibrary.RealPosition
            end
        end
    end
end)

game:GetService('RunService').Heartbeat:Connect(function()
    DesyncLibrary:HeartBeat()
end)

local Dependencies =
{
    VerifyAssets = function(self)
        local assets = loadstring(game:HttpGet("https://raw.githubusercontent.com/quadshoota/Lunor/refs/heads/main/Available.lua"))()

        for i,v in pairs(assets) do
            if (not isfile("Lunor/Icons/" .. v .. ".png")) then
                local success, errorMessage = pcall(function()
                    writefile("Lunor/Icons/" .. v .. ".png", game:HttpGet("https://github.com/quadshoota/Lunor/blob/main/Icons/" .. v .. ".png?raw=true"))
                end)

                if (not success) then
                    warn("Failed to download asset: " .. v .. " - " .. errorMessage)
                else
                    Storage.Icons[v] = "rbxasset://Lunor/Icons/" .. v
                    warn("Downloaded asset: " .. v)
                end
            end

            if (isfile("Lunor/Icons/" .. v .. ".png")) then
                Storage.Icons[v] = "rbxasset://Lunor/Icons/" .. v
            end
        end
    end,

    Cleanname = function(self, name)
        return name:gsub("[^%a]", ""):lower()
    end,

    CreateDirectories = function(self)
        local gamename = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
        gamename = self:Cleanname(gamename)
        
        local dokipath = "Lunor"
        if (not isfolder(dokipath)) then
            makefolder(dokipath)
        end

        local iconspath = dokipath .. "/Icons"
        if (not isfolder(iconspath)) then
            makefolder(iconspath)
        end

        local path = "Lunor/" .. gamename .. "/"
        if (not isfolder(path)) then
            makefolder(path)
        end

        local configspath = path .. "Configs"
        if (not isfolder(configspath)) then
            makefolder(configspath)
        end

        Storage.ConfigsPath = configspath
        self:VerifyAssets()
    end,

    CustomAsset = function(self, assetName) 
        if (not (Storage.Icons[assetName])) then
            warn("Asset not found: " .. assetName)
            return "rbxassetid://0"
        end

        local path = "Lunor/Icons/" .. assetName .. ".png"
        if (not isfile(path)) then
            warn("Asset file not found: " .. path)
            return "rbxassetid://0"
        end

        local toasset = getcustomasset(path)
        if (not toasset) then
            warn("Failed to get custom asset: " .. path)
            return "rbxassetid://0"
        end

        return toasset
    end,
}

Dependencies:CreateDirectories()
Library:Window({
    Name = "LUNOR",
    Key = "LunacyWindowsDetectionBoss7261",
    Logo = Dependencies:CustomAsset("LunorPNG"),
})

Library:MobileButton(Dependencies:CustomAsset("LunorPNG"))


local VisualEffects = 
{
    CreateHitTracer = function(self, StartPosition, EndPosition)
        local tracer = Instance.new('Part')
        tracer.Anchored = true
        tracer.CanCollide = false
        tracer.Shape = Enum.PartType.Cylinder
        tracer.Material = Enum.Material.SmoothPlastic
        tracer.Color = Color3.fromRGB(128, 128, 128)
        tracer.Transparency = 0.5

        local distance = (EndPosition - StartPosition).Magnitude
        tracer.Size = Vector3.new(distance, 0.1, 0.1)

        local midpoint = (StartPosition + EndPosition) / 2
        tracer.CFrame = CFrame.lookAt(midpoint, EndPosition)
            * CFrame.Angles(0, math.pi / 2, 0)

        tracer.Parent = workspace
        game:GetService('Debris'):AddItem(tracer, 0.5)

        return tracer
    end,

    CreateHitEffect = function(self, targetModel, damageText)
        -- game:GetService("Players").LocalPlayer.PlayerScripts.Client.Modules["Weapons [Client]"].Bat.LegacyBats.HitEffect
        -- game:GetService("Players").LocalPlayer.PlayerScripts.Client.Modules["Weapons [Client]"].Bat.HitEffect
        local attachment = game:GetService('Players').LocalPlayer.PlayerScripts.Client.Modules["Weapons [Client]"].Bat.HitEffect.Attachment:Clone()
        attachment.Parent = targetModel.PrimaryPart
        
        for _, emitter in pairs(attachment:GetChildren()) do
            emitter:Emit(emitter:GetAttribute('EmitCount') or 10)
        end
        
        local highlight = Instance.new('Highlight')
        highlight.FillTransparency = 0.3
        highlight.OutlineTransparency = 1
        highlight.DepthMode = Enum.HighlightDepthMode.Occluded
        highlight.Parent = targetModel
        
        local damageMarkerModule = require(game:GetService('ReplicatedStorage').Modules.Effect.DamageMarker)
        damageMarkerModule(targetModel.PrimaryPart.Position, tostring(damageText))
        
        local springModule = require(game:GetService('ReplicatedStorage').Modules.Utility.Tweener.Spring)
        springModule.target(highlight, 0.9, 3, {
            ['FillTransparency'] = 1,
        })

        Services.Debris:AddItem(highlight, 0.3)
        Services.Debris:AddItem(attachment, 2)
    end,

    CreateCustomDamageMarker = function(self, targetPosition, damageText, color, darkerColor)
        local replicatedStorage = game:GetService('ReplicatedStorage')
        local springModule = require(replicatedStorage.Modules.Utility.Tweener.Spring)
        
        local attachment = Instance.new('Attachment')
        attachment.Parent = workspace.Terrain
        attachment.WorldPosition = targetPosition
        
        local billboardGui = replicatedStorage.Modules.Effect.DamageMarker.BillboardGui:Clone()
        billboardGui.Frame.DamageShadow.TextColor3 = darkerColor
        billboardGui.Frame.DamageShadow.Damage.TextColor3 = color
        billboardGui.Frame.DamageShadow.Damage.TextStrokeColor3 = darkerColor
        billboardGui.Parent = attachment
        billboardGui.Frame.DamageShadow.Text = damageText or 'Lunor Error'
        billboardGui.Frame.DamageShadow.Damage.Text = damageText or 'Lunor Error'
        
        springModule.target(billboardGui.Frame.UIScale, 0.9, 3, {
            ['Scale'] = 0.2 + math.random(-10, 50) / 100,
        })
        
        local randomX = math.random(-5, 5)
        local randomY = math.random(-3, 3)
        local offsetConfig = {}
        offsetConfig.StudsOffset = vector.create(randomX, randomY, 0)
        
        springModule.target(billboardGui, 1.5, 2, offsetConfig)
        
        task.delay(0.65, function()
            springModule.target(billboardGui.Frame.DamageShadow, 0.9, 2.5, {
                ['TextTransparency'] = 1,
                ['TextStrokeTransparency'] = 1,
            })
            springModule.target(billboardGui.Frame.DamageShadow.Damage, 0.9, 2.5, {
                ['TextTransparency'] = 1,
                ['TextStrokeTransparency'] = 1,
            })
        end)
    end,

    CreateHitEffectColored = function(self, targetModel, damageText, color, darkerColor)
        local attachment = game:GetService('Players').LocalPlayer.PlayerScripts.Client.Modules["Weapons [Client]"].Bat.HitEffect.Attachment:Clone()
        attachment.Parent = targetModel.PrimaryPart
        
        for _, emitter in pairs(attachment:GetChildren()) do
            emitter:Emit(emitter:GetAttribute('EmitCount') or 10)
        end
        
        local highlight = Instance.new('Highlight')
        highlight.FillColor = color
        highlight.FillTransparency = 0.3
        highlight.OutlineTransparency = 1
        highlight.DepthMode = Enum.HighlightDepthMode.Occluded
        highlight.Parent = targetModel
        
        self:CreateCustomDamageMarker(targetModel.PrimaryPart.Position, tostring(damageText), color, darkerColor)
        
        local springModule = require(game:GetService('ReplicatedStorage').Modules.Utility.Tweener.Spring)
        springModule.target(highlight, 0.9, 3, {
            ['FillTransparency'] = 1,
        })
        
        Services.Debris:AddItem(highlight, 0.3)
        Services.Debris:AddItem(attachment, 2)
    end,

    crosshairdata =
    {
        alpha = 0,
        increasing = true,
        angle = 0,
        animX = 0,
        animY = 0,
        lines = {},
        texts = {},
    },

    clearcrosshair = function(self)
        local data = self.crosshairdata
        for _, line in pairs(data.lines) do
            line:Remove()
        end
        for _, text in pairs(data.texts) do
            text:Remove()
        end
        data.lines = {}
        data.texts = {}
    end,

    drawcrosshair = function(self)
        local dt = 1 / 60
        local alphaSpeed = 0.3
        local data = self.crosshairdata
        
        if (data.increasing) then
            data.alpha = data.alpha + alphaSpeed * dt
            if (data.alpha >= 1) then
                data.alpha = 1
                data.increasing = false
            end
        else
            data.alpha = data.alpha - alphaSpeed * dt
            if (data.alpha <= 0) then
                data.alpha = 0
                data.increasing = true
            end
        end
        
        data.angle = data.angle + 1.2 * dt
        if (data.angle > math.pi * 2) then
            data.angle = data.angle - math.pi * 2
        end
        
        local mouse = game:GetService('UserInputService'):GetMouseLocation()
        local cursorX = mouse.X
        local cursorY = mouse.Y
        
        if (data.animX == 0) then
            data.animX = cursorX
        end
        if (data.animY == 0) then
            data.animY = cursorY
        end
        
        local smoothing = 8
        local lerpFactor = 1 - math.exp(-smoothing * dt)
        
        data.animX = data.animX + (cursorX - data.animX) * lerpFactor
        data.animY = data.animY + (cursorY - data.animY) * lerpFactor
        
        for _, line in pairs(data.lines) do
            line:Remove()
        end
        for _, text in pairs(data.texts) do
            text:Remove()
        end
        data.lines = {}
        data.texts = {}
        
        local size = 10
        local thickness = 1.5
        local gap = 5
        
        local linePositions = {
            { { data.animX - size - gap, data.animY }, { data.animX - gap, data.animY } },
            { { data.animX + gap, data.animY }, { data.animX + size + gap, data.animY } },
            { { data.animX, data.animY - size - gap }, { data.animX, data.animY - gap } },
            { { data.animX, data.animY + gap }, { data.animX, data.animY + size + gap } },
        }
        
        local s = math.sin(data.angle)
        local c = math.cos(data.angle)
        
        for i = 1, 4 do
            local p1 = linePositions[i][1]
            local p2 = linePositions[i][2]
            
            local p1x = p1[1] - data.animX
            local p1y = p1[2] - data.animY
            local p2x = p2[1] - data.animX
            local p2y = p2[2] - data.animY
            
            local rp1x = p1x * c - p1y * s + data.animX
            local rp1y = p1x * s + p1y * c + data.animY
            local rp2x = p2x * c - p2y * s + data.animX
            local rp2y = p2x * s + p2y * c + data.animY
            
            local outlineOffsets = {
                { -1, 0 },
                { 1, 0 },
                { 0, -1 },
                { 0, 1 },
            }
            
            for _, offset in pairs(outlineOffsets) do
                local outline = Drawing.new('Line')
                outline.From = Vector2.new(rp1x + offset[1], rp1y + offset[2])
                outline.To = Vector2.new(rp2x + offset[1], rp2y + offset[2])
                outline.Color = Color3.new(0, 0, 0)
                outline.Thickness = 1
                outline.Visible = true
                table.insert(data.lines, outline)
            end
            
            local mainLine = Drawing.new('Line')
            mainLine.From = Vector2.new(rp1x, rp1y)
            mainLine.To = Vector2.new(rp2x, rp2y)
            mainLine.Color = Color3.new(1, 1, 1)
            mainLine.Thickness = thickness
            mainLine.Visible = true
            table.insert(data.lines, mainLine)
        end
        
        local text1 = Drawing.new('Text')
        text1.Text = 'Lunor.'
        text1.Position = Vector2.new(data.animX - 35, data.animY + size + gap + 2)
        text1.Color = Color3.new(1, 1, 1)
        text1.Size = 18
        text1.Center = false
        text1.Outline = true
        text1.Visible = true
        table.insert(data.texts, text1)
        
        local text2 = Drawing.new('Text')
        text2.Text = 'rocks'
        text2.Position = Vector2.new(data.animX + 10, data.animY + size + gap + 2)
        text2.Color = Color3.new(0.5, 0.8, 1)
        text2.Transparency = data.alpha
        text2.Size = 18
        text2.Center = false
        text2.Outline = true
        text2.Visible = true
        table.insert(data.texts, text2)
    end,
}

local Utils =
{
    CachedPlot = nil,
    CachedTool = nil,


    ReturnMaxInventory = function(self)
        local max = ModuleManager:GetModule("Utils"):GetMaxInventorySpace(game.Players.LocalPlayer)
        return max or 0
    end,

    CardStorage =
    {
        Intro = ModuleManager:GetModule("PackObj").Intro,
        ListenForInput = ModuleManager:GetModule("PackObj").ListenForInput,
        Open = ModuleManager:GetModule("PackObj").Open,
        ShowcaseCards = ModuleManager:GetModule("PackObj").ShowcaseCards,
        Destroy = ModuleManager:GetModule("PackObj").Destroy,
    },

    InstantOpenCards = function(self, boolean)
        local packobject = ModuleManager:GetModule("PackObj")
        
        if (boolean) then
            hookfunction(packobject.Intro, function(p)
            end)
            
            hookfunction(packobject.ListenForInput, function(p)
                task.defer(function()
                    p:Open()
                end)
            end)
            
            hookfunction(packobject.Open, function(p)
                p.rarityMod = nil
                if (p.PackModel) then
                    p.PackModel:Destroy()
                end
                task.defer(function()
                    p:ShowcaseCards()
                    task.wait()
                    p:Destroy()
                end)
            end)
            
            hookfunction(packobject.ShowcaseCards, function(p)
            end)
            
            hookfunction(packobject.Destroy, function(p)
                if (p.PackGui) then
                    pcall(function() p.PackGui:Destroy() end)
                end
                if (p.rarityMod and typeof(p.rarityMod) == "function") then
                    pcall(function() p.rarityMod() end)
                    p.rarityMod = nil
                end
                if (p.HitAttachment) then
                    pcall(function() p.HitAttachment:Destroy() end)
                    p.HitAttachment = nil
                end
                local camera = workspace.CurrentCamera
                local blur = game.Lighting:FindFirstChild("UIBlur")
                local playerGui = game.Players.LocalPlayer.PlayerGui
                if (camera) then
                    camera.FieldOfView = 70
                end
                if (blur) then
                    blur.Size = 0
                end
                if (playerGui:FindFirstChild("BackpackGui")) then
                    playerGui.BackpackGui.Enabled = true
                end
                if (playerGui:FindFirstChild("Main")) then
                    playerGui.Main.Enabled = true
                end
                game.Players.LocalPlayer:SetAttribute("OpeningPacks", nil)
                setmetatable(p, nil)
            end)
        end
    end,

    IsMaxInventory = function(self)
        local max = self:ReturnMaxInventory()
        local current = #game.Players.LocalPlayer.Backpack:GetChildren()
        if (current >= max) then
            return true
        end

        return false
    end,

    ReturnAllSeedsStock = function(self)
        local storage = {}
        for _, seedName in pairs(Globals.AllSeeds) do
            if (seedName == "All") then continue end
            storage[seedName] = Helpers:ReturnSeedStock(seedName)
            --warn("Seed: " .. tostring(seedName) .. " | Stock: " .. tostring(storage[seedName]))
        end
        
        return storage
    end,

    ReturnAllGearsStock = function(self)
        local storage = {}
        for _, gearName in pairs(Globals.AllGears) do
            if (gearName == "All") then continue end
            storage[gearName] = Helpers:ReturnGearStock(gearName)
            --warn("Gear: " .. tostring(gearName) .. " | Stock: " .. tostring(storage[gearName]))
        end
        
        return storage
    end,

    ReturnTool = function(self) 
        local tool = nil
        for i,v in pairs(lcl.Backpack:GetChildren()) do
            if (v:IsA("Tool") and string.find(v.Name, "Bat")) then
                tool = v
                break
            end
        end

        if (tool) then
            return tool
        end

        return nil
    end,

    EquipTool = function(self, boolean, force)
        local tool = self:ReturnTool()
        if (not tool and not force) then return end

        -- game.Players.LocalPlayer:FindFirstChild("Basic Bat")
        if (boolean == false and lcl.Character:FindFirstChildOfClass("Tool") or boolean == true and lcl.Character:FindFirstChildOfClass("Tool") and lcl.Character:FindFirstChildOfClass("Tool") ~= tool) then
            humanoid:UnequipTools()
            return
        elseif (boolean == true) then
            humanoid:EquipTool(tool)
            return
        end
    end,

    Contains = function(self, tbl, val)
        for i,v in pairs(tbl) do
            if (v == val) then
                return true
            end
        end

        return false
    end,

    IsFavorite = function(self, id)
        local gotdata = ModuleManager:GetModule("PlayerData"):GetData().Data
        for i,v in pairs(gotdata.Favorites) do
            if (i == tostring(id)) then
                --warn("Is favorite: " .. tostring(id))
                return true
            end
        end

        return false
    end,

    Favorite = function(self, iteminst, boolean)
        local itemid = iteminst:GetAttribute("ID")
        if (not itemid) then return end

        if (self:IsFavorite(itemid) == boolean) then return end
        --warn("Item is: " .. tostring(self:IsFavorite(itemid)) .. " | Boolean: " .. tostring(boolean))

        favoriteevent:FireServer(itemid)
    end,

    GetAllFavorites = function(self)
        local gotdata = ModuleManager:GetModule("PlayerData"):GetData().Data
        return gotdata.Favorites
    end,

    GetFavoriteData = function(self, id)
        for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
            local toolid = v:GetAttribute("ID") or nil
            if (toolid == nil) then continue end
            if (v:IsA("Tool") and toolid == id) then

                local itemdata = {}
                local size, worth, itemname = v:GetAttribute("Size"), v:GetAttribute("Worth"), v:GetAttribute("ItemName")
                if (not size or not worth or not itemname) then
                    return nil
                end

                itemdata.Size = size
                itemdata.Worth = worth
                itemdata.ItemName = itemname
                return itemdata
            end
        end
    end,

    GetPlot = function(self)
        if (self.CachedPlot) then return self.CachedPlot end
        for i,v in pairs(workspace.Plots:GetChildren()) do
            if (v:GetAttribute("Owner") == lcl.Name) then
                self.CachedPlot = v
                return v
            end
        end
    end,

    IsWithinPlot  = function(self, entity)
        local plot = self:GetPlot()
        local plotname = plot.Name
        --warn("lcl plot: " .. tostring(plotname) .. " | ent plot: " .. tostring(entity:GetAttribute("Plot")) .. " | match? " .. tostring(entity:GetAttribute("Plot") == plotname))
        local entityplot = entity:GetAttribute("Plot")

        entityplot = tonumber(entityplot)
        plotname = tonumber(plotname)

        if (entityplot == plotname) then
            return true
        end

        return false
    end,


    GetClosestChild = function(self, folder)
        if (hrp == nil) then return nil end
        local closestentity = nil
        local closestdist = math.huge
        for i,v in pairs(folder:GetChildren()) do
            if (self:IsWithinPlot(v) == false) then continue end
            local dist = (v:GetPivot().Position - hrp.Position).Magnitude
            if (dist < closestdist) then
                closestdist = dist
                closestentity = v
            end
        end

        --workspace.ScriptedMap.Brainrots["9f0dbadf-25f4-4"].RootPart")
        return closestentity
    end,

    GetHighestHealthChild = function(self, folder)
        if (hrp == nil) then return nil end
        local highestentity = nil
        local highesthealth = -math.huge
        for i,v in pairs(folder:GetChildren()) do
            if (self:IsWithinPlot(v) == false) then continue end
            local health = tonumber(v:GetAttribute("MaxHealth")) or 0
            if (health > highesthealth) then
                highesthealth = health
                highestentity = v
            end
        end

        return highestentity
    end,

    GetProjectileChild = function(self, folder)
        if (hrp == nil) then return nil end
        local highestentity = nil
        local highesthealth = -math.huge
        for i,v in pairs(folder:GetChildren()) do
            if (self:IsWithinPlot(v) == false or v:GetAttribute("Progress") ~= nil and v:GetAttribute("Progress") <= 0.58) then continue end
            local health = tonumber(v:GetAttribute("MaxHealth")) or 0
            if (health > highesthealth) then
                highesthealth = health
                highestentity = v
            end
        end

        return highestentity
    end,

    GetLowestHealthChild = function(self, folder)
        if (hrp == nil) then return nil end
        local lowestentity = nil
        local lowesthealth = math.huge
        for i,v in pairs(folder:GetChildren()) do
            if (self:IsWithinPlot(v) == false) then continue end
            local health = tonumber(v:GetAttribute("Health")) or 0
            if (health < lowesthealth) then
                lowesthealth = health
                lowestentity = v
            end
        end

        return lowestentity
    end,

    GetHighestRarityChild = function(self, folder)
        if (hrp == nil) then return nil end
        local highestentity = nil
        local highestrarity = -math.huge
        for i,v in pairs(folder:GetChildren()) do
            if (self:IsWithinPlot(v) == false) then continue end
            local rarity = v:GetAttribute("Rarity") or "Common"
            local rarityvalue = Globals.RarityOrder[rarity] or 0
            if (rarityvalue > highestrarity) then
                highestrarity = rarityvalue
                highestentity = v
            end
        end

        return highestentity
    end,

    GetHighestMutationChild = function(self, folder)
        if (hrp == nil) then return nil end

        local highestentity = nil
        local highestmutation = -math.huge
        for i,v in pairs(folder:GetChildren()) do
            if (self:IsWithinPlot(v) == false) then continue end
            --workspace.ScriptedMap.Brainrots["09adbfdd-db63-4"].Stats.Mutation
            local mutationgui = v:FindFirstChild("Stats").Mutation
            local mutation = mutationgui.Text
            if (mutationgui.Visible == false) then
                continue
            end
            
            local mutationvalue = Globals.MutationOrder[mutation] or 0
            if (mutationvalue and mutationvalue > highestmutation) then
                highestmutation = mutationvalue
                highestentity = v
            end
        end

        if (highestmutation == 0 or highestentity == nil) then
            return self:GetHighestHealthChild(folder)
        end

        return highestentity
    end,

}

local Tabs =
{
    Farm = Library:Tab({
        Title = "Farm",
        Icon = Dependencies:CustomAsset("browsers"),
        Vertical = false,
    }),

    Items = Library:Tab({
        Title = "Backpack",
        Icon = Dependencies:CustomAsset("version"),
        Vertical = false,
    }),

    Shop = Library:Tab({
        Title = "Shop",
        Icon = Dependencies:CustomAsset("archive"),
        Vertical = false,
    }),

    Settings = Library:Tab({
        Title = "Settings",
        Icon = Dependencies:CustomAsset("gear"),
        Vertical = false,
    }),

    Configs = Library:Tab({
        Title = "Configs",
        Icon = Dependencies:CustomAsset("cloudfile"),
        Vertical = false,
    }),

    Developer = Library:Tab({
        Title = "Developer",
        Icon = Dependencies:CustomAsset("gear"),
        Vertical = false,
    }),
}


local Sections = 
{
    -- Farm
    Farm = Tabs.Farm:Section({
        Title = "Farm",
        Side = "Left",
        ShowTitle = false,
    }),

    -- Favorites
    Favorites = Tabs.Farm:Section({
        Title = "Favorites",
        Side = "Right",
        ShowTitle = false,
    }),

    -- Sell
    Sell = Tabs.Shop:Section({
        Title = "Sell",
        Side = "Right",
        ShowTitle = false,
    }),

    -- Shop
    Shop = Tabs.Shop:Section({
        Title = "Shop",
        Side = "Left",
        ShowTitle = false,
    }),

    -- Settings
    Settings = Tabs.Settings:Section({
        Title = "Settings",
        Side = "Left",
        ShowTitle = false,
    }),

    -- Developer
    Developer = Tabs.Developer:Section({
        Title = "Developer",
        Side = "Left",
        ShowTitle = false,
    }),

    -- Configs
    Configs = Tabs.Configs:Section({
        Title = "Configs",
        Side = "Left",
        ShowTitle = false,
    }),

    -- Share Configs
    ShareConfigs = Tabs.Configs:Section({
        Title = "Share Configs",
        Side = "Right",
        ShowTitle = false,
    }),

    -- Items
    Items = Tabs.Items:Section({
        Title = "Items",
        Side = "Left",
        ShowTitle = false,
    }),

    Items2 = Tabs.Items:Section({
        Title = "Items",
        Side = "Right",
        ShowTitle = false,
    }),

    -- Fuses
    --[[
        Fuses = Tabs.Items:Section({
        Title = "Fuses - NOT ADDED",
        Side = "Right",
        ShowTitle = false,
    }),
    ]]
}

local Subsections = 
{
    -- Farm
    Combat = Sections.Farm:Subsection({
        Name = "Attack",
        Side = "Left",
    }),

    -- Collect & Equip Best
    Collect = Sections.Farm:Subsection({
        Name = "Collect",
        Side = "Right",
    }),

    -- Seeds
    Seeds = Sections.Shop:Subsection({
        Name = "Seeds",
        Side = "Left",
    }),

    -- Gears
    Gears = Sections.Shop:Subsection({
        Name = "Gears",
        Side = "Right",
    }),


    -- Sell
    Sell = Sections.Sell:Subsection({
        Name = "Sell",
        Side = "Left",
    }),

    Favorites = Sections.Favorites:Subsection({
        Name = "Favorites",
        Side = "Right",
    }),

    -- Settings
    Settings = Sections.Settings:Subsection({
        Name = "Settings",
        Side = "Left",
    }),

    -- Interface
    Interface = Sections.Settings:Subsection({
        Name = "Interface",
        Side = "Left",
    }),

    -- Items/Projectiles
    Projectiles = Sections.Items:Subsection({
        Name = "Gears",
        Side = "Left",
    }),

    -- Items/Cards
    Cards = Sections.Items2:Subsection({
        Name = "Cards",
        Side = "Right",
    }),

    -- Eggs
    Eggs = Sections.Items2:Subsection({
        Name = "Eggs",
        Side = "Right",
    }),

}



local Config =
{
    Connections =
    {
        AutoCombat = nil,
        AutoMove = nil,
        AutoSellBrainrot = nil,
        AutoSellPlantConnection = nil,
        CrosshairConnection = nil,
        AutoCollectAndEquipConnection = nil,
        AutoClaimEvent = nil,
        AutoPurchaseSeedsConnection = nil,
        AutoPurchaseGearsConnection = nil,
        AutoOpenCardsConnection = nil,
        AutoCombatConnection = nil,
    },

    Cooldowns =
    {
        LastAttacked = 0,
        AttackCooldown = 0.15,
        AutoMoveCooldown = 3,
        LastAutoMove = 0,
        LastSoldBrainrot = 0,
        SellBrainrotEvery = 12,
        SellPlantsEvery = 15,
        CollectAndEquipEvery = 35,
        LastCollectedAndEquipped = 0,
        LastCollectedAward = 0,
        CollectAwardEvery = 10,
        PurchaseSeedsEvery = 10,
        PurchaseGearsEvery = 10,
        LastPurchasedSeeds = 0,
        LastPurchasedGears = 0,
        LastAutoFavorite = 0,
        AutoFavoriteEvery = 6,
        LastThrownProjectile = 0,
        ThrowProjectileEvery = 2,
        LastOpenedCard = 0,
        OpenCardEvery = 1.5,
        LastOpenedEgg = 0,
        OpenEggsEvery = 8,
    },

    Farm =
    {
        AutoCombat = false,
        AutoMove = false,
        AutoMovePriority = {"Max Health", "Rarity"},
        SelectedAutoMovePriority = "Max Health",
        AutoMoveOptions = {"Equip Best", "Set Maximum"},
        SelectedAutoMoveOptions = {},
        UseAmount = 5,
        OriginalUse = 5,

        Priority = {"Max Health", "Rarity", "Mutation", "Low Health", "Distance"},
        SelectedPriority = "Low Health",
    },

    Collect =
    {
        AutoCollectAndEquip = false,
        AutoClaimEvent = false,
    },

    Sell =
    {
        SellBrainrot = false,
        SellBrainrotOptions = {"Max Inventory"},
        SelectedSellBrainrotOptions = {},
        SellPlants = false,
        SellPlantRarities = Globals.Rarities,
        SelectedSellPlantRarities = {},
    },

    Favorites =
    {
        AutoFavorite = false,
        FavoriteOptions = {"Rarity", "Value", "Weight"},
        SelectedFavoriteOptions = {"Rarity"},
        FavoritePriority = {"Value", "Weight", "Rarity"},
        SelectedFavoritePriority = "Value",
        FavoriteRarities = Globals.Rarities,
        SelectedFavoriteRarities = {},
        WeightThreshold = 0,
        ValueThreshold = 0,
    },

    Shop =
    {
        AutoPurchaseSeeds = false,
        PurchasableSeeds = Globals.AllSeeds,
        SelectedPurchasableSeeds = {},
        SeedPurchaseAmount = 0,

        AutoPurchaseGears = false,
        PurchasableGears = Globals.AllGears,
        SelectedPurchasableGears = {},
        GearPurchaseAmount = 0,
    },

    UserInterface =
    {
        ShowCrosshair = false,
        ShowEffects = false,
        PlayHitsound = false,
    },

    Settings =
    {
        Lowgraphics = false,

        Notifications = true,
    },

    Items =
    {
        AutoProjectiles = false,
        Projectiles = {"Frost Grenade", "Banana Gun", "Carrot Launcher"},
        SelectedProjectiles = {},
        ProjectileOptions = {"Health"},
        SelectedProjectileOptions = {},
        ProjectileHealth = 150,

        InstantOpenCards = false,
        AutoOpenCards = false,
        AutoOpenEggs = false,

        FuseList = {},
        SelectedFuses = "Unknown",
        AutoFuse = false,
    }
}

for i,v in pairs(Globals.FuseCombinations) do
    table.insert(Config.Items.FuseList, v.Result)
end


local Features =
{
    Farm =
    {
        GetEntityByPriority = function(self)
            local priority = Config.Farm.SelectedPriority
            if (priority == "Distance") then
                return Utils:GetClosestChild(workspace.ScriptedMap.Brainrots)
            elseif (priority == "Rarity") then
                return Utils:GetHighestRarityChild(workspace.ScriptedMap.Brainrots)
            elseif (priority == "Max Health") then
                return Utils:GetHighestHealthChild(workspace.ScriptedMap.Brainrots)
            elseif (priority == "Mutation") then
                return Utils:GetHighestMutationChild(workspace.ScriptedMap.Brainrots)
            elseif (priority == "Low Health") then
                return Utils:GetLowestHealthChild(workspace.ScriptedMap.Brainrots)
            end

            return Utils:GetClosestChild(workspace.ScriptedMap.Brainrots)
        end,

        TeleportEntity = function(self)
            if (not Config.Connections.AutoCombatConnection) then return end
            local target = self:GetEntityByPriority()
            if (target == nil) then return end

            DesyncLibrary.ShouldDesync = true
            local htbox = target:FindFirstChild("BrainrotHitbox") or target:FindFirstChild("Hitbox")
            DesyncLibrary.DesyncPosition = htbox.CFrame
            --hrp.CFrame = target:FindFirstChild("BrainrotHitbox").CFrame
        end,

        AttackEntity = function(self)
            local target = self:GetEntityByPriority()
            if target == nil then
                return
            end

            Utils:EquipTool(true, false)

            combatevent:FireServer({
                target.Name,
            })
        end,

        PlantsCache =
        {
            PickedUpIDs = {},
        },

        PickupPlants = function(self, row)
            local plot = Utils:GetPlot()
            if (not plot) then return end

            local onrowactive = 0
            local count = 0
            for i,v in pairs(plot.Plants:GetChildren()) do
                if (v:GetAttribute("Offline") or v:GetAttribute("Enabled") or v:GetAttribute("Rebirth")) then continue end

                local placedrow = v:GetAttribute("Row")
                if (not placedrow) then continue end
                
                if (placedrow and placedrow == row) then 
                    onrowactive = onrowactive + 1
                    continue 
                end

                if (Utils:Contains(Config.Farm.SelectedAutoMoveOptions, "Set Maximum") and count < Config.Farm.UseAmount) then
                    count = count + 1
                elseif (Utils:Contains(Config.Farm.SelectedAutoMoveOptions, "Set Maximum") and count >= Config.Farm.UseAmount) then
                    break
                end
                
                pickupevent:FireServer(v:GetAttribute("ID"))
            end

            return onrowactive
        end,

        GetDPSFromPlant = function(self, damage, cooldown)
            return (damage / cooldown)
        end,

        GetDPSFromPlantsTable = function(self, plantstbl)
            local totaldps = 0
            for i,v in pairs(plantstbl) do
                totaldps = totaldps + self:GetDPSFromPlant(v.Damage, v.Cooldown)
            end
            return totaldps
        end,

        dpsdata =
        {
            basetime = 31,
            basespeed = 2.5,
            baseprogress = 60,
        },

        CalculateNeededDPS = function(self, speed, progress, health)
            progress = progress * 100
            progress = math.round(progress)
            
            local remainingProgress = 100 - progress
            
            if (remainingProgress <= 0) then
                return 0
            end
            
            local baseProgressRange = 100 - self.dpsdata.baseprogress
            local timeRemaining = (remainingProgress / baseProgressRange) * self.dpsdata.basetime * (self.dpsdata.basespeed / speed)
            local neededDPS = health / timeRemaining
            
            return neededDPS
        end,

        PlacePlants = function(self, row, dpsneeded)
            local plot = Utils:GetPlot()
            if (not plot) then return end
            local planted = self:PickupPlants(row)

            local tomove = 35
            if (Utils:Contains(Config.Farm.SelectedAutoMoveOptions, "Set Maximum")) then
                tomove = Config.Farm.UseAmount
            end

            if (planted >= tomove) then return end
            

            Config.Cooldowns.AutoMoveCooldown = 25
            if (Utils:Contains(Config.Farm.SelectedAutoMoveOptions, "Equip Best")) then
                for i, v in pairs(lcl.Backpack:GetChildren()) do
                    if (not v:IsA("Tool") or not v:GetAttribute("IsPlant")) then continue end
                    local id = v:GetAttribute("ID") or nil
                    local damage = v:GetAttribute("Damage") or nil
                    local cooldown = v:GetAttribute("Cooldown") or 1
                    if (not id or not damage) then continue end
                    table.insert(self.PlantsCache.PickedUpIDs, {ID = id, Name = v.Name, Damage = damage, Cooldown = cooldown})
                end
            end

            self.PlantsCache.PickedUpIDs = Helpers:GetHighestDamageTable(self.PlantsCache.PickedUpIDs, tomove)

            local cframetoplace = nil
            for i, v in pairs(plot.Rows[row].Grass:GetChildren()) do
                if (v.Position.Z > 658 and v.Position.Z < 660) then
                    cframetoplace = v.CFrame
                    break
                end
            end
            
            local dps = 0
            for index, plantData in pairs(self.PlantsCache.PickedUpIDs) do
                local dmgpersec = self:GetDPSFromPlant(tonumber(plantData.Damage), tonumber(plantData.Cooldown))
                local foundtool = false

                for i, v in pairs(lcl:FindFirstChild("Backpack"):GetChildren()) do
                    local itemid = v:GetAttribute("ID") or nil
                    if (not itemid) then continue end
                    
                    if (v:IsA("Tool") and plantData.ID == itemid) then
                        v.Parent = lcl.Character
                        foundtool = true
                        break
                    end
                end

                if (not foundtool) then
                    continue
                end

                if (Utils:Contains(Config.Farm.SelectedAutoMoveOptions, "DPS Based Amount") and dps > dpsneeded) then break end
                repeat task.wait(0.25) placeevent:FireServer({ID = plantData.ID, CFrame = cframetoplace, Item = toolname, Floor = plot.Rows[row].Grass:FindFirstChild("1")}) until (not lcl.Character:FindFirstChildOfClass("Tool")) or (Config.Farm.AutoMove == false)
                if (Utils:Contains(Config.Farm.SelectedAutoMoveOptions, "DPS Based Amount") and dps + dmgpersec >= dpsneeded) then
                    dps = dps + self:GetDPSFromPlant(tonumber(plantData.Damage), tonumber(plantData.Cooldown))
                    break
                end

                dps = dps + self:GetDPSFromPlant(tonumber(plantData.Damage), tonumber(plantData.Cooldown))
            end

            self.PlantsCache.PickedUpIDs = {}
            Config.Cooldowns.AutoMoveCooldown = 3
        end,

        AutoMovePlants = function(self)
            local brainpath = workspace.ScriptedMap.Brainrots
            local highestrarity = 0
            local highesthealth = 0
            local ent = nil
            local row = nil

            for i,v in pairs(brainpath:GetChildren()) do
                local rarity = v:GetAttribute("Rarity") or 0
                local maxhealth = tonumber(v:GetAttribute("MaxHealth")) or 0
                local ownerid = v:GetAttribute("AssociatedPlayer") or nil
                local onrow = v:GetAttribute("Row") or nil
                local lclid = game.Players.LocalPlayer.UserId
                if (ownerid ~= lclid or not onrow or not rarity) then continue end

                local rarityvalue = Globals.RarityOrder[rarity] or 0
                if (Config.Farm.SelectedAutoMovePriority == "Rarity" and rarityvalue > highestrarity) then
                    highestrarity = rarityvalue
                    ent = v
                    row = onrow
                end

                if (Config.Farm.SelectedAutoMovePriority == "Max Health" and maxhealth > highesthealth) then
                    highesthealth = maxhealth
                    ent = v
                    row = onrow
                end
            end
            
            if (not row or not ent) then
                return
            end

            local dpsneeded = self:CalculateNeededDPS(ent:GetAttribute("Speed"), ent:GetAttribute("Progress"), ent:GetAttribute("Health"))
            dpsneeded = tonumber(dpsneeded)
            self:PlacePlants(row, dpsneeded)
        end,

    },

    Sell =
    {
        AutoFavorite = function(self)
            for i,v in pairs(lcl.Backpack:GetChildren()) do
                if (not v:IsA("Tool")) then continue end
                local model = v:FindFirstChildOfClass("Model") or nil
                if (not model) then continue end
                local rarity = model:GetAttribute("Rarity") or nil
                if (not rarity) then continue end
                local itemid = v:GetAttribute("ID") or nil
                if (not itemid) then continue end
                local shouldFavorite = false

                if (Utils:Contains(Config.Favorites.SelectedFavoriteOptions, "Rarity")) then
                    if (Utils:Contains(Config.Favorites.SelectedFavoriteRarities, rarity)) then
                        Utils:Favorite(v, true)
                        continue -- this item, is done next one now.
                    end
                end

                if (Utils:Contains(Config.Favorites.SelectedFavoriteOptions, "Value") or Utils:Contains(Config.Favorites.SelectedFavoriteOptions, "Weight")) then
                    local data = Utils:GetFavoriteData(itemid)
                    if (data) then
                        if (Utils:Contains(Config.Favorites.SelectedFavoriteOptions, "Value") and Config.Favorites.ValueThreshold > 0) then
                            --warn("Data worth: " .. tostring(data.Worth) .. " | Threshold: " .. tostring(tonumber(Config.Favorites.ValueThreshold)))
                            if (data.Worth >= tonumber(Config.Favorites.ValueThreshold)) then
                                Utils:Favorite(v, true)
                                continue
                            end
                        end
                        if (Utils:Contains(Config.Favorites.SelectedFavoriteOptions, "Weight") and Config.Favorites.WeightThreshold > 0) then
                            --warn("Data size: " .. tostring(data.Size) .. " | Threshold: " .. tostring(tonumber(Config.Favorites.WeightThreshold)))
                            if (data.Size >= tonumber(Config.Favorites.WeightThreshold)) then
                                Utils:Favorite(v, true)
                                continue
                            end
                        end
                    end
                end
            end
        end,
        
        Cache =
        {
            AutoSellBrainrotsActive = false,
            AutoSellPlantsActive = false,
            LastNotifiedSell = 0,
        },

        AutoSellBrainrot = function(self)
            self:AutoFavorite()

            if (self.Cache.LastNotifiedSell == nil or tick() - self.Cache.LastNotifiedSell >= 5) then
                self.Cache.LastNotifiedSell = tick()
                if (Config.Favorites.AutoFavorite and Config.Favorites.Notifications) then
                    Library:Notification("LUNOR » Favorited items..", 3, "success")
                end
            end

            task.wait()
            sellevent:FireServer(nil, nil, true)
        end,

        AutoSellPlants = function(self)
            if (not Config.Sell.SellPlants or #Config.Sell.SelectedSellPlantRarities <= 0) then return end
            if (self.Cache.AutoSellPlantsActive) then return end
            self.Cache.AutoSellPlantsActive = true

            for i,v in pairs(lcl.Backpack:GetChildren()) do
                if (not v:IsA("Tool")) then continue end
                if (not v:GetAttribute("IsPlant")) then continue end
                local model = v:FindFirstChildOfClass("Model") or nil
                if (not model) then continue end
                local rarity = model:GetAttribute("Rarity") or nil
                if (not rarity) then continue end
                if (Utils:Contains(Config.Sell.SelectedSellPlantRarities, rarity)) then
                    Utils:Favorite(v, false)
                else
                    Utils:Favorite(v, true)
                end
            end

            task.wait()
            sellevent:FireServer(nil, nil, true)
            self.Cache.AutoSellPlantsActive = false
        end
    },

    Collect =
    {
        Cache =
        {
            --AutoCollectAndEquipActive = false,
        },

        AutoCollectAndEquip = function(self)
            equipbest:Fire()
            if (Config.Settings.Notifications) then
                Library:Notification("LUNOR » Equipped & Collected", 3, "success")
            end
        end,

        AutoClaimEvent = function(self, force)
            local path = workspace.ScriptedMap.Event.TomadeFloor.GuiAttachment.Billboard:FindFirstChild("Checkmark") or nil
            if (not force) then
                if (not path or path and path.Visible == false) then return end
            end
            local proxim = workspace.ScriptedMap.Event.EventRewards.TalkPart:FindFirstChild("ProximityPrompt")
            if (not proxim) then return end

            if (Config.Farm.AutoCombat) then Restores:RestoreCombatConn(false) end

            DesyncLibrary.ShouldDesync = true
            DesyncLibrary.DesyncPosition = proxim.Parent.CFrame
            task.wait(0.15)
            fireproximityprompt(proxim)
            DesyncLibrary.DesyncPosition = DesyncLibrary.RealPosition
            DesyncLibrary.ShouldDesync = false

            if (Config.Settings.Notifications) then
                Library:Notification("LUNOR » Claimed Event Reward's", 3, "success")
            end

            if (Config.Farm.AutoCombat) then Restores:RestoreCombatConn(true) end
        end,
    },

    Shop =
    {
        Cache =
        {
            AutoPurchaseSeedsActive = false,
            AutoPurchaseGearsActive = false,
            LastSeedsNotification = 0,
            LastGearsNotification = 0,
        },

        AutoPurchaseSeeds = function(self)
            if (not Config.Shop.AutoPurchaseSeeds) then return end
            if (#Config.Shop.SelectedPurchasableSeeds == 0 or Config.Shop.SeedPurchaseAmount == 0) then return end

            local topurchase = {}
            if (Utils:Contains(Config.Shop.SelectedPurchasableSeeds, "All")) then
                topurchase = Globals.AllSeeds
            else
                topurchase = Config.Shop.SelectedPurchasableSeeds
            end

            local seedstock = Utils:ReturnAllSeedsStock()
            local cannotify = false
            local purchaseAmount = Config.Shop.SeedPurchaseAmount
            for i,v in pairs(topurchase) do
                if (v == "All") then continue end
                if (seedstock[v] and seedstock[v] > 0) then
                    local amountToBuy = math.min(purchaseAmount, seedstock[v])
                    for j = 1, amountToBuy do
                        --warn("Seed: " .. v .. " | Purchase Amount: " .. tostring(amountToBuy) .. " | Stock: " .. tostring(seedstock[v]))
                        buyitem:FireServer(v, true)
                        task.wait(0.15)
                        cannotify = true
                    end
                end
            end

            if (not cannotify) then return end
            if (self.Cache.LastSeedsNotification == nil or tick() - self.Cache.LastSeedsNotification >= 5) then
                self.Cache.LastSeedsNotification = tick()

                if (Config.Settings.Notifications) then
                    Library:Notification("LUNOR » Purchased Seeds", 3, "success")
                end
            end
        end,

        AutoPurchaseGears = function(self)
            if (not Config.Shop.AutoPurchaseGears) then return end
            if (#Config.Shop.SelectedPurchasableGears == 0 or Config.Shop.GearPurchaseAmount == 0) then return end

            local topurchase = {}
            if (Utils:Contains(Config.Shop.SelectedPurchasableGears, "All")) then
                topurchase = Globals.AllGears
            else
                topurchase = Config.Shop.SelectedPurchasableGears
            end

            local cannotify = false
            local gearstock = Utils:ReturnAllGearsStock()
            local purchaseAmount = Config.Shop.GearPurchaseAmount
            for i,v in pairs(topurchase) do
                if (v == "All") then continue end

                if (gearstock[v] and gearstock[v] > 0) then
                    local amountToBuy = math.min(purchaseAmount, gearstock[v])
                    for j = 1, amountToBuy do
                        --warn("Seed: " .. v .. " | Purchase Amount: " .. tostring(amountToBuy) .. " | Stock: " .. tostring(gearstock[v]))
                        buygearevent:FireServer(v, true)
                        task.wait(0.15) 
                        cannotify = true
                    end
                end
            end


            if (not cannotify) then return end
            if (self.Cache.LastGearsNotification == nil or tick() - self.Cache.LastGearsNotification >= 5) then
                self.Cache.LastGearsNotification = tick()

                if (Config.Settings.Notifications) then
                    Library:Notification("LUNOR » Purchased Gears", 3, "success")
                end
            end
        end,
    },

    Items =
    {

        ThrowProjectile = function(self)
            if (not Config.Items.AutoProjectiles) then return end
            if (#Config.Items.SelectedProjectileOptions == 0) then return end
            if (not Config.Items.ProjectileHealth or Config.Items.ProjectileHealth == nil or Config.Items.ProjectileHealth ~= nil and Config.Items.ProjectileHealth <= 0) then return end
            
            local target = Utils:GetProjectileChild(workspace.ScriptedMap.Brainrots)
            if (not target) then return end
            if (not target:GetAttribute("Health") or target:GetAttribute("Health") == nil or target:GetAttribute("Health") == 0) then return end
            if (target:GetAttribute("MaxHealth") < Config.Items.ProjectileHealth) then return end
            if (not target:GetAttribute("Progress") or target:GetAttribute("Progress") == nil or target:GetAttribute("Progress") and target:GetAttribute("Progress") ~= nil and target:GetAttribute("Progress") < 0.58) then return end
            
            repeat task.wait() until target:GetAttribute("Speed") > 0 or (not Config.Items.AutoProjectiles)
            local backpack = game.Players.LocalPlayer:FindFirstChild("Backpack")
            local usedTools = {}

            local rayOrigin = target:FindFirstChild("BrainrotHitbox") or target:FindFirstChild("Hitbox")
            if (not rayOrigin) then return end
            DesyncLibrary.ShouldDesync = true
            DesyncLibrary.DesyncPosition = rayOrigin.CFrame

            for i, v in pairs(backpack:GetChildren()) do
                if (not v:GetAttribute("Name")) then continue end
                if (v:IsA("Tool") and Utils:Contains(Config.Items.SelectedProjectiles, v:GetAttribute("Name"))) then
                    Restores:RestoreCombatConn(false)
                    Utils:EquipTool(false, true)
                    task.wait(0.2)
                    v.Parent = game.Players.LocalPlayer.Character
                    table.insert(usedTools, v:GetAttribute("Name"))
                    task.wait(0.1)
                    DesyncLibrary.DesyncPosition = rayOrigin.CFrame

                    useitemevent:FireServer({
                        Toggle = true,
                        Tool = game.Players.LocalPlayer.Character:FindFirstChild(v.Name),
                        Time = 0,
                        Pos = rayOrigin.Position,
                    })
                end
                task.wait()
            end

            Restores:RestoreCombatConn(true)
            task.wait(0.1)
            if (#usedTools <= 0) then return end

            Utils:EquipTool(false, true)
            Library:Notification("GEARS » " .. table.concat(usedTools, " | "), 3, "warning")
            DesyncLibrary.ShouldDesync = false
        end,


        OpenPacks = function(self)
            -- packevent
            local backpack = game.Players.LocalPlayer:FindFirstChild("Backpack")
            for i,v in pairs(backpack:GetChildren()) do
                local loweredname = string.lower(v.Name)
                if (v:IsA("Tool") and string.find(loweredname, "pack")) then
                    v.Parent = game.Players.LocalPlayer.Character
                    break
                end
            end

            packevent:FireServer()
        end,

        EggFunc = nil,
        SkipEggs = function(self)
            if (self.EggFunc) then return end
            local gc_objects = getgc(true)
            for i,v in pairs(gc_objects) do
                if (type(v) == "function" and islclosure(v)) then
                    local consts = getconstants(v)
                    for idx, val in pairs(consts) do
                        if (type(val) == "string" and string.find(val, "EggOpening")) then
                            local info = getinfo(v)
                            if (info.source and string.find(info.source, "Shop")) then
                                self.EggFunc = v
                                hookfunction(v, newcclosure(function(p54)
                                    return
                                end))
                                break
                            end
                        end
                    end
                end
            end
        end,

        AutoEggOpening = function(self)
            local backpack = game.Players.LocalPlayer:FindFirstChild("Backpack")
            local equipped = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
            local exit = false

            if (equipped and not string.find(equipped.Name, "Egg") or equipped and string.find(equipped.Name, "Eggplant")) then
                equipped = nil
            end

            if (equipped and equipped:GetAttribute("ItemName")) then
                local itemname = equipped:GetAttribute("ItemName") or nil
                if (itemname and string.find(itemname, "Egg") and not string.find(itemname, "Eggplant")) then
                    eggremote:FireServer()
                    task.wait(0.1)
                    Utils:EquipTool(false, true)
                    if (Config.Settings.Notifications) then
                        Library:Notification("EGGS » Opening " .. tostring(itemname or "Unknown"), 3, "success")
                    end
                    exit = true
                    return true
                end
            end

            if (exit) then return end

            if (not equipped or equipped == nil) then
                for i,v in pairs(backpack:GetChildren()) do
                    if (not v or v and not v:GetAttribute("ItemName")) then continue end
                    if (v and v:GetAttribute("ItemName") and string.find(v:GetAttribute("ItemName"), "Egg") and not string.find(v:GetAttribute("ItemName"), "Eggplant")) then
                        if (Config.Cooldowns.OpenEggsEvery == 15 or self.EggFunc == nil) then
                            self:SkipEggs()
                            Config.Cooldowns.OpenEggsEvery = 8
                        end

                        Restores:RestoreCombatConn(false)
                        Utils:EquipTool(false, true)
                        task.wait(0.2)
                        v.Parent = game.Players.LocalPlayer.Character
                        task.wait(0.2)
                        eggremote:FireServer()
                        task.wait(0.2)
                        Utils:EquipTool(false, true)
                        if (Config.Settings.Notifications) then
                            Library:Notification("EGGS » Opening " .. tostring(v:GetAttribute("ItemName") or "Unknown"), 3, "success")
                        end

                        exit = true
                        Restores:RestoreCombatConn(true)
                        break
                    end
                end
            end

            if (exit) then return true end
            if (equipped) then return end

            -- couldnt find any eggs, set cooldown upto 15 + restore.
            if (Config.Settings.Notifications) then
                Library:Notification("EGGS » No more eggs found, disabling..", 3, "warning")
            end

            if (self.EggFunc) then
                restorefunction(self.EggFunc)
                self.EggFunc = nil
                Config.Cooldowns.OpenEggsEvery = 15
                return false
            end
        end,
    },
}

Subsections.Combat:Toggle({
    Name = "Auto Attack",
    Flag = "AutoCombat",
    Default = Config.Farm.AutoCombat,
    Callback = function(value)
        Config.Farm.AutoCombat = value
        if (value) then
            if (not Config.Connections.AutoCombatConnection) then
                Config.Connections.AutoCombatConnection = Services.RunService.Heartbeat:Connect(function()
                    local currentTime = tick()
                    if (Config.Cooldowns.LastAttacked == nil or currentTime - Config.Cooldowns.LastAttacked >= Config.Cooldowns.AttackCooldown) then
                        Config.Cooldowns.AttackCooldown = math.random(0.15, 0.23)
                        Config.Cooldowns.LastAttacked = currentTime
                        Features.Farm:AttackEntity()
                        Features.Farm:TeleportEntity()
                    end
                end)
            end
        else
            if (Config.Connections.AutoCombatConnection) then
                Config.Connections.AutoCombatConnection:Disconnect()
                Config.Connections.AutoCombatConnection = nil
                DesyncLibrary.DesyncPosition = DesyncLibrary.RealPosition
                task.wait()
                DesyncLibrary.ShouldDesync = false
                Utils:EquipTool(false)
            end
        end
    end,
})

Subsections.Combat:Dropdown({
    Name = "Target Mode",
    Flag = "CombatPriority",
    Options = Config.Farm.Priority, 
    Default = Config.Farm.SelectedPriority,
    Callback = function(value)
        Config.Farm.SelectedPriority = value
    end,
})

Subsections.Combat:Separator()

Subsections.Combat:Toggle({
    Name = "Move Plants",
    Flag = "AutoMovePlants",
    Default = Config.Farm.AutoMove,
    Callback = function(value)
        Config.Farm.AutoMove = value
        if (value) then
            if (not Config.Connections.AutoMove) then
                Config.Connections.AutoMove = Services.RunService.Heartbeat:Connect(function()
                    local currentTime = tick()
                    if (currentTime - Config.Cooldowns.LastAutoMove < Config.Cooldowns.AutoMoveCooldown) then
                        return
                    end

                    Config.Cooldowns.LastAutoMove = currentTime
                    Features.Farm:AutoMovePlants()
                end)
            end
        else
            if (Config.Connections.AutoMove) then
                Config.Connections.AutoMove:Disconnect()
                Config.Connections.AutoMove = nil
            end
        end
    end,
})

Subsections.Combat:Dropdown({
    Name = "Move Method",
    Flag = "MovePriority",
    Options = Config.Farm.AutoMovePriority, 
    Default = Config.Farm.SelectedAutoMovePriority,
    Callback = function(value)
        Config.Farm.SelectedAutoMovePriority = value
    end,
})

Subsections.Combat:Dropdown({
    Name = "Move Settings",
    Flag = "AutoMoveOptions",
    Max = 99,
    Options = Config.Farm.AutoMoveOptions, 
    Default = Config.Farm.SelectedAutoMoveOptions,
    Callback = function(value)
        Config.Farm.SelectedAutoMoveOptions = value
    end,
})

Subsections.Combat:Textbox({
    Name = "Use Amount",
    Flag = "UseAmount",
    PlaceholderText = "Enter amount..",
    Default = Config.Farm.UseAmount,
    Numeric = true,
    Depends = 
    {
        ["AutoMoveOptions"] = 
        {
            contains = {"Use Amount"},
        },
        ["AutoMovePlants"] = true,
    },
    Callback = function(value)
        Config.Farm.UseAmount = tonumber(value)
        Config.Farm.OriginalUse = tonumber(value)
    end,
})

-- Collect & Equip Best
Subsections.Collect:Toggle({
    Name = "Auto Collect & Equip",
    Flag = "collectequipbrainrots",
    Default = Config.Collect.AutoCollectAndEquip,
    Callback = function(value)
        Config.Collect.AutoCollectAndEquip = value
        if (value) then
            if (not Config.Connections.AutoCollectAndEquipConnection) then
                Config.Connections.AutoCollectAndEquipConnection = Services.RunService.Heartbeat:Connect(function()
                    local currentTime = tick()
                    if (currentTime - Config.Cooldowns.LastCollectedAndEquipped < Config.Cooldowns.CollectAndEquipEvery) then
                        return
                    end

                    if (Utils:Contains(Config.Sell.SelectedSellBrainrotOptions, "Max Inventory") and Utils:IsMaxInventory() == false) then
                        Config.Cooldowns.LastCollectedAndEquipped = currentTime
                        Features.Collect:AutoCollectAndEquip()
                        return
                    end

                    if (not Config.Sell.SellBrainrot or Config.Sell.SellBrainrot and currentTime - Config.Cooldowns.LastSoldBrainrot < Config.Cooldowns.SellBrainrotEvery) then
                        Config.Cooldowns.LastCollectedAndEquipped = currentTime
                        Features.Collect:AutoCollectAndEquip()
                    end
                end)
            end
        else
            if (Config.Connections.AutoCollectAndEquipConnection) then
                Config.Connections.AutoCollectAndEquipConnection:Disconnect()
                Config.Connections.AutoCollectAndEquipConnection = nil
            end
        end
    end,
})


Subsections.Collect:Toggle({
    Name = "Auto-Collect Rewards",
    Flag = "autoclaimrewards",
    Default = Config.Collect.AutoClaimEvent,
    Callback = function(value)
        Config.Collect.AutoClaimEvent = value
        if (value) then
            if (not Config.Connections.AutoClaimEvent) then
                Config.Connections.AutoClaimEvent = Services.RunService.Heartbeat:Connect(function()
                    local currentTime = tick()
                    if (currentTime - Config.Cooldowns.LastCollectedAward < Config.Cooldowns.CollectAwardEvery) then
                        return
                    end

                    Config.Cooldowns.LastCollectedAward = currentTime
                    Features.Collect:AutoClaimEvent()
                end)
            end
        else
            if (Config.Connections.AutoClaimEvent) then
                Config.Connections.AutoClaimEvent:Disconnect()
                Config.Connections.AutoClaimEvent = nil
            end
        end
    end,
})

Subsections.Collect:Separator()

local rewardsparagraph = Subsections.Collect:Paragraph({
    Title = "Statistics",
    Description = {
        {
            Text = "Target » None",
        },
        {
            Text = "Progress » None",
        },
        {
            Text = "Boss » None",
        },
        {
            Text = "Boost » None",
        },
    },
    Position = "Center",
})

-- Sell Brainrot
Subsections.Sell:Toggle({
    Name = "Sell Brainrots",
    Flag = "SellBrainrotToggle",
    Default = Config.Sell.SellBrainrot,
    Callback = function(value)
        Config.Sell.SellBrainrot = value
        if (value) then
            if (not Config.Connections.AutoSellBrainrot) then
                Config.Connections.AutoSellBrainrot = Services.RunService.Heartbeat:Connect(function()
                    local currentTime = tick()
                    if (Utils:Contains(Config.Sell.SelectedSellBrainrotOptions, "Max Inventory") and Utils:IsMaxInventory() == true) then
                        Config.Cooldowns.LastSoldBrainrot = currentTime
                        Features.Sell:AutoSellBrainrot()
                        return
                    end

                    if (currentTime - Config.Cooldowns.LastSoldBrainrot < Config.Cooldowns.SellBrainrotEvery or Utils:Contains(Config.Sell.SelectedSellBrainrotOptions, "Max Inventory")) then
                        return
                    end

                    Config.Cooldowns.LastSoldBrainrot = currentTime
                    Features.Sell:AutoSellBrainrot()
                end)
            end
        else
            if (Config.Connections.AutoSellBrainrot) then
                Config.Connections.AutoSellBrainrot:Disconnect()
                Config.Connections.AutoSellBrainrot = nil
            end
        end
    end,
})

Subsections.Sell:Dropdown({
    Name = "Settings",
    Flag = "SellBrainrotOptions",
    Max = 99,
    Options = Config.Sell.SellBrainrotOptions, 
    Default = Config.Sell.SelectedSellBrainrotOptions,
    Callback = function(value)
        Config.Sell.SelectedSellBrainrotOptions = value
    end,
})

-- Sell Plants
Subsections.Sell:Separator()

Subsections.Sell:Toggle({
    Name = "Sell Plants",
    Flag = "SellPlantsToggle",
    Default = Config.Sell.SellPlants,
    Callback = function(value)
        Config.Sell.SellPlants = value
        if (value) then
            if (not Config.Connections.AutoSellPlantConnection) then
                Config.Connections.AutoSellPlantConnection = Services.RunService.Heartbeat:Connect(function()
                    local currentTime = tick()
                    if (Config.Cooldowns.LastSoldPlants == nil or currentTime - Config.Cooldowns.LastSoldPlants >= Config.Cooldowns.SellPlantsEvery) then
                        Config.Cooldowns.LastSoldPlants = currentTime
                        Features.Sell:AutoSellPlants()
                    end
                end)
            end
        else
            if (Config.Connections.AutoSellPlantConnection) then
                Config.Connections.AutoSellPlantConnection:Disconnect()
                Config.Connections.AutoSellPlantConnection = nil
            end
        end
    end,
})

Subsections.Sell:Dropdown({
    Name = "Keep Rarities",
    Flag = "SellPlantRarities",
    Max = 99,
    Options = Config.Sell.SellPlantRarities, 
    Default = Config.Sell.SelectedSellPlantRarities,
    Callback = function(value)
        Config.Sell.SelectedSellPlantRarities = value
    end,
})

-- Favorities
Sections.Favorites:Toggle({
    Name = "Auto Favorite",
    Flag = "AutoFavorite",
    Default = Config.Favorites.AutoFavorite,
    Callback = function(value)
        Config.Favorites.AutoFavorite = value
        if (value) then
            if (not Config.Connections.AutoFavoriteConnection) then
                Config.Connections.AutoFavoriteConnection = Services.RunService.Heartbeat:Connect(function()
                    local currentTime = tick()
                    if (currentTime - Config.Cooldowns.LastAutoFavorite < Config.Cooldowns.AutoFavoriteEvery) then
                        return
                    end

                    Config.Cooldowns.LastAutoFavorite = currentTime
                    Features.Sell:AutoFavorite()
                end)
            end
        else
            if (Config.Connections.AutoFavoriteConnection) then
                Config.Connections.AutoFavoriteConnection:Disconnect()
                Config.Connections.AutoFavoriteConnection = nil
            end
        end
    end,
})

Sections.Favorites:Dropdown({
    Name = "Select Filters",
    Flag = "FavoriteOptions",
    Max = 99,
    Options = Config.Favorites.FavoriteOptions, 
    Default = Config.Favorites.SelectedFavoriteOptions,
    Callback = function(value)
        Config.Favorites.SelectedFavoriteOptions = value
    end,
})

Sections.Favorites:Dropdown({
    Name = "Select Rarities",
    Flag = "FavoriteRarities",
    Max = 99,
    Options = Config.Favorites.FavoriteRarities, 
    Default = Config.Favorites.SelectedFavoriteRarities,
    Depends = 
    {
        ["FavoriteOptions"] = 
        {
            contains = {"Rarity"},
        },
    },
    Callback = function(value)
        Config.Favorites.SelectedFavoriteRarities = value
    end,
})


Sections.Favorites:Slider({
    Name = "Weight's Above        ",
    Min = 0,
    Max = 1000,
    Default = Config.Favorites.WeightThreshold,
    Flag = "FavoriteWeightThreshold",
    Suffix = "KG",
    Depends = 
    {
        ["FavoriteOptions"] = 
        {
            contains = {"Weight"},
        },
    },
    Callback = function(value)
        Config.Favorites.WeightThreshold = tonumber(value) or 0
    end,
})

Sections.Favorites:Slider({
    Name = "Value's Above        ",
    Min = 0,
    Max = 1000000,
    Default = Config.Favorites.ValueThreshold,
    Flag = "FavoriteValueThreshold",
    Suffix = "$",
    Depends = 
    {
        ["FavoriteOptions"] = 
        {
            contains = {"Value"},
        },
    },
    Callback = function(value)
        Config.Favorites.ValueThreshold = tonumber(value) or 0
    end,
})


-- seperator
Sections.Favorites:Separator()

-- tooltip paragraph
Sections.Favorites:Paragraph({
    Title = "Double-Click",
    Description = {
        {
            Text = "» Type your desired value, simply",
        },
        {
            Text = "» Double-Click the slider above me!",
        },
    },
    Position = "Center",
})


-- Shop Seeds
Subsections.Seeds:Toggle({
    Name = "Purchase Seeds",
    Flag = "AutoPurchaseSeeds",
    Default = Config.Shop.AutoPurchaseSeeds,
    Callback = function(value)
        Config.Shop.AutoPurchaseSeeds = value
        Config.Cooldowns.LastPurchasedSeeds = 0

        if (value) then
            if (not Config.Connections.AutoPurchaseSeedsConnection) then
                Config.Connections.AutoPurchaseSeedsConnection = Services.RunService.Heartbeat:Connect(function()
                    if (workspace:GetAttribute("NextSeedRestock") <= 1 or workspace:GetAttribute("NextSeedRestock") >= 299) then
                        Config.Cooldowns.LastPurchasedSeeds = tick()
                        Features.Shop:AutoPurchaseSeeds()
                        return
                    end

                    local currentTime = tick()
                    if (currentTime - Config.Cooldowns.LastPurchasedSeeds < Config.Cooldowns.PurchaseSeedsEvery) then
                        return
                    end

                    Config.Cooldowns.LastPurchasedSeeds = currentTime
                    Features.Shop:AutoPurchaseSeeds()
                end)
            end
        else
            if (Config.Connections.AutoPurchaseSeedsConnection) then
                Config.Connections.AutoPurchaseSeedsConnection:Disconnect()
                Config.Connections.AutoPurchaseSeedsConnection = nil
            end
        end
    end,
})

Subsections.Seeds:Separator()

Subsections.Seeds:Dropdown({
    Name = "Select Seeds",
    Flag = "PurchasableSeeds",
    Max = 99,
    Options = Config.Shop.PurchasableSeeds, 
    Default = Config.Shop.SelectedPurchasableSeeds,
    Callback = function(value)
        Config.Shop.SelectedPurchasableSeeds = value
        Config.Cooldowns.LastPurchasedSeeds = 0
    end,
})

Subsections.Seeds:Textbox({
    Name = "Quantity",
    Flag = "SeedPurchaseAmount",
    PlaceholderText = "None..",
    Callback = function(value)
        value = Helpers:ConvertToNumbers(value) or 0
        if (value and value >= 0) then
            Config.Shop.SeedPurchaseAmount = value
            Config.Cooldowns.LastPurchasedSeeds = 0
            --warn("Set seed purchase amount to: " .. tostring(Config.Shop.SeedPurchaseAmount))
        end
    end,
})

-- Shop Gears

Subsections.Gears:Toggle({
    Name = "Purchase Gears",
    Flag = "AutoPurchaseGears",
    Default = Config.Shop.AutoPurchaseGears,
    Callback = function(value)
        Config.Shop.AutoPurchaseGears = value
        Config.Cooldowns.LastPurchasedGears = 0

        if (value) then
            if (not Config.Connections.AutoPurchaseGearsConnection) then
                Config.Connections.AutoPurchaseGearsConnection = Services.RunService.Heartbeat:Connect(function()
                    if (workspace:GetAttribute("NextGearRestock") <= 1 or workspace:GetAttribute("NextGearRestock") >= 299) then
                        Config.Cooldowns.LastPurchasedGears = tick()
                        Features.Shop:AutoPurchaseGears()
                        return
                    end

                    local currentTime = tick()
                    if (currentTime - Config.Cooldowns.LastPurchasedGears < Config.Cooldowns.PurchaseGearsEvery) then
                        return
                    end

                    Config.Cooldowns.LastPurchasedGears = currentTime
                    Features.Shop:AutoPurchaseGears()
                end)
            end
        else
            if (Config.Connections.AutoPurchaseGearsConnection) then
                Config.Connections.AutoPurchaseGearsConnection:Disconnect()
                Config.Connections.AutoPurchaseGearsConnection = nil
            end
        end
    end,
})

Subsections.Gears:Separator()

Subsections.Gears:Dropdown({
    Name = "Select Gears",
    Flag = "PurchasableGears",
    Max = 99,
    Options = Config.Shop.PurchasableGears, 
    Default = Config.Shop.SelectedPurchasableGears,
    Callback = function(value)
        Config.Shop.SelectedPurchasableGears = value
        Config.Cooldowns.LastPurchasedGears = 0
    end,
})

Subsections.Gears:Textbox({
    Name = "Quantity",
    Flag = "GearPurchaseAmount",
    PlaceholderText = "None..",
    Callback = function(value)
        value = Helpers:ConvertToNumbers(value) or 0
        if (value and value >= 0) then
            Config.Shop.GearPurchaseAmount = value
            Config.Cooldowns.LastPurchasedGears = 0
            --warn("Set gear purchase amount to: " .. tostring(Config.Shop.GearPurchaseAmount))
        end
    end,
})

Subsections.Settings:Toggle({
    Name = "Max Performance",
    Flag = "Lowgraphics",
    Default = Config.Settings.Lowgraphics,
    Callback = function(value)
        Config.Settings.Lowgraphics = value
        if (value) then
            Helpers:BoostFrames()
        else
            Helpers:RestoreBoost()
        end
    end,
})


-- Interface
local UIKeybind = Subsections.Interface:Keybind({
    Name = "Interface Key",
    Key = Library.UIKey,
    Mode = "Hold",
    Callback = function(value)
        if (Library.UIKey == value) then return end
        Restores:UpdateKeybind()
    end,
})

Subsections.Interface:Toggle({
    Name = "Notifications",
    Flag = "Notifications",
    Default = Config.Settings.Notifications,
    Callback = function(value)
        Config.Settings.Notifications = value
    end,
})

-- Items
Subsections.Projectiles:Toggle({
    Name = "Auto Gears",
    Flag = "AutoProjectiles",
    Default = Config.Items.AutoProjectiles,
    Callback = function(value)
        Config.Items.AutoProjectiles = value
        if (value) then
            if (not Config.Connections.ProjectileConnection) then
                Config.Connections.ProjectileConnection = Services.RunService.Heartbeat:Connect(function()
                    local currentTime = tick()
                    if (Config.Cooldowns.LastThrownProjectile == nil or currentTime - Config.Cooldowns.LastThrownProjectile >= Config.Cooldowns.ThrowProjectileEvery) then
                        Config.Cooldowns.LastThrownProjectile = currentTime
                        Features.Items:ThrowProjectile()
                    end
                end)
            end
        else
            if (Config.Connections.ProjectileConnection) then
                Config.Connections.ProjectileConnection:Disconnect()
                Config.Connections.ProjectileConnection = nil
            end
        end
    end,
})

Subsections.Projectiles:Separator()

Subsections.Projectiles:Dropdown({
    Name = "Select Gears",
    Flag = "Projectiles",
    Max = 99,
    Options = Config.Items.Projectiles,
    Default = Config.Items.SelectedProjectiles,
    Callback = function(value)
        Config.Items.SelectedProjectiles = value
    end,
})

Subsections.Projectiles:Dropdown({
    Name = "Target Mode",
    Flag = "ProjectileOptions",
    Max = 99,
    Options = Config.Items.ProjectileOptions, 
    Default = Config.Items.SelectedProjectileOptions,
    Callback = function(value)
        Config.Items.SelectedProjectileOptions = value
    end,
})

Subsections.Projectiles:Slider({
    Name = "Health Above           ",
    Min = 0,
    Max = 850000,
    Flag = "ProjectileHealth",
    Default = Config.Items.ProjectileHealth,
    Suffix = "hp",
    Depends = 
    {
        ["ProjectileOptions"] =
        {
            contains = {"Health"},
        },
    },
    Callback = function(value)
        if (not value or value == nil) then 
            value = 0 
        end

        value = tonumber(value) or 0
        Config.Items.ProjectileHealth = value
    end,
})

-- Cards
Subsections.Cards:Toggle({
    Name = "Disable Animation",
    Flag = "InstantOpenCards",
    Default = Config.Items.InstantOpenCards,
    Callback = function(value)
        Config.Items.InstantOpenCards = value
        Utils:InstantOpenCards(value)
    end,
})

-- AutoOpenCards
Subsections.Cards:Toggle({
    Name = "Auto-Open Cards",
    Flag = "AutoOpenCards",
    Default = Config.Items.AutoOpenCards,
    Callback = function(value)
        Config.Items.AutoOpenCards = value
        if (value) then
            if (not Config.Connections.AutoOpenCardsConnection) then
                Config.Connections.AutoOpenCardsConnection = Services.RunService.Heartbeat:Connect(function()
                    local currentTime = tick()
                    if (Config.Cooldowns.LastOpenedCard == nil or currentTime - Config.Cooldowns.LastOpenedCard >= Config.Cooldowns.OpenCardEvery) then
                        Config.Cooldowns.LastOpenedCard = currentTime
                        Features.Items:OpenPacks()
                    end
                end)
            end
        else
            if (Config.Connections.AutoOpenCardsConnection) then
                Config.Connections.AutoOpenCardsConnection:Disconnect()
                Config.Connections.AutoOpenCardsConnection = nil
            end
        end
    end,
})


-- autoopeneggs
Subsections.Eggs:Toggle({
    Name = "Auto-Open Eggs",
    Flag = "AutoOpenEggs",
    Default = Config.Items.AutoOpenEggs,
    Callback = function(value)
        Config.Items.AutoOpenEggs = value
        Config.Cooldowns.LastOpenedEgg = nil
        if (value) then
            if (not Config.Connections.AutoOpenEggsConnection) then
                Features.Items:SkipEggs()
                Config.Connections.AutoOpenEggsConnection = Services.RunService.Heartbeat:Connect(function()
                    local currentTime = tick()
                    if (Config.Cooldowns.LastOpenedEgg == nil or currentTime - Config.Cooldowns.LastOpenedEgg >= Config.Cooldowns.OpenEggsEvery) then
                        Config.Cooldowns.LastOpenedEgg = currentTime
                        Features.Items:AutoEggOpening()
                    end
                end)
            end
        else
            if (Config.Connections.AutoOpenEggsConnection) then
                Config.Connections.AutoOpenEggsConnection:Disconnect()
                Config.Connections.AutoOpenEggsConnection = nil
                if (Features.Items.EggFunc ~= nil) then
                    restorefunction(Features.Items.EggFunc)
                    Features.Items.EggFunc = nil
                end
            end
        end
    end,
})


-- fuses

--[[
local fusepara = Sections.Fuses:List({
    Name = "Fusing - NOT ADDED YET",
    Flag = "FuseData",
    Options = {"Brainrot » None", "Plant » None", "Result » None"},
    MinHeight = 45,
    Callback = function(value)
        
    end,
})

Sections.Fuses:Dropdown({
    Name = "Select Fuse",
    Flag = "SelectFuses",
    Options = Config.Items.FuseList,
    Default = Config.Items.SelectedFuses,
    Callback = function(value)
        Config.Items.SelectedFuses = value
        if (not Config.Items.SelectedFuses or Config.Items.SelectedFuses == nil or #Config.Items.SelectedFuses <= 0) then
            fusepara:Refresh({"Brainrot » None", "Plant » None", "Result » None"})
            return
        end

        for i,v in pairs(Globals.FuseCombinations) do
            if (Utils:Contains(v, Config.Items.SelectedFuses)) then
                v.Brainrot = tostring(v.Brainrot) or nil
                v.Plant = tostring(v.Plant) or nil
                v.Result = tostring(v.Result) or nil
                fusepara:Refresh({"Brainrot » " .. tostring(v.Brainrot or "None"), "Plant » " .. tostring(v.Plant or "None"), "Result » " .. tostring(v.Result or "None")})
                return
            end
        end
    end,
})

Sections.Fuses:Separator()

Sections.Fuses:Toggle({
    Name = "Auto Fuse",
    Flag = "AutoFuse",
    Default = Config.Items.AutoFuse,
    Callback = function(value)
        Config.Items.AutoFuse = value
    end,
})
]]

Sections.Developer:Button({
    Name = "Pickup Plants",
    Callback = function()
        Features.Farm:PickupPlants()
    end,
})

-- rejoin
Sections.Developer:Button({
    Name = "Rejoin Server",
    Callback = function()
        local ts = game:GetService('TeleportService')
        local p = game:GetService('Players').LocalPlayer
        ts:Teleport(game.PlaceId, p)
    end,
})

-- AutoClaimEvent(true)
Sections.Developer:Button({
    Name = "AutoClaimEvent",
    Callback = function()
        Features.Collect:AutoClaimEvent(true)
    end,
})

-- Configs

local ConfigsModule = 
{
    Cache = 
    {
        Configs = {"Default"},
        SelectedAction = "Load",
        SelectedConfig = nil,
        TextboxInput = "",
        ConfigKey = "",
    },

    GetConfigurations = function(self)
        self.Cache.Configs = {}
        for _, file in pairs(listfiles(Storage.ConfigsPath)) do
            if (file:match("%.json$")) then
                local configName = file:match("([^/\\]+)%.json$")
                if (configName) then
                    table.insert(self.Cache.Configs, configName)
                end
            end
        end

        if (#self.Cache.Configs == 0) then
            table.insert(self.Cache.Configs, "Default")
        end
    end,

    ValidateConfigName = function(self, name)
        if (not name or name == "") then
            return false, "Config name cannot be empty"
        end
        
        local cleanName = name:gsub("[^%w_]", ""):gsub("%s+", "")
        
        if (cleanName == "") then
            return false, "Config name must contain valid characters"
        end
        
        if (#cleanName > 50) then
            return false, "Config name too long (max 50 characters)"
        end
        
        return true, cleanName
    end,

    ConfigExists = function(self, configName)
        local filePath = Storage.ConfigsPath .. "/" .. configName .. ".json"
        return isfile(filePath)
    end,

    SaveConfiguration = function(self, configName)
        local isValid, result = self:ValidateConfigName(configName)
        if (not isValid) then
            return false, result
        end
        
        local cleanName = result
        local content = Library:GetConfig()
        local filePath = Storage.ConfigsPath .. "/" .. cleanName .. ".json"
        
        local message = ""
        if (self:ConfigExists(cleanName)) then
            message = "Config '" .. cleanName .. "' overwritten successfully"
        else
            message = "Config '" .. cleanName .. "' saved successfully"
        end
        
        writefile(filePath, content)
        self:GetConfigurations()
        return true, message
    end,

    LoadConfiguration = function(self, configName)
        if (not configName or configName == "") then
            return false, "No config selected"
        end
        
        local filePath = Storage.ConfigsPath .. "/" .. configName .. ".json"
        if (isfile(filePath)) then
            local content = readfile(filePath)
            if (content) then
                Library:LoadConfig(content)
                return true, "Config '" .. configName .. "' loaded successfully"
            end
        end
        return false, "Failed to load config '" .. configName .. "'"
    end,

    DeleteConfiguration = function(self, configName)
        if (not configName or configName == "") then
            return false, "No config selected"
        end
        
        if (configName == "Default") then
            return false, "Cannot delete Default config"
        end
        
        local filePath = Storage.ConfigsPath .. "/" .. configName .. ".json"
        if (isfile(filePath)) then
            delfile(filePath)
            self:GetConfigurations()
            return true, "Config '" .. configName .. "' deleted successfully"
        end
        return false, "Config '" .. configName .. "' not found"
    end,

    ExecuteAction = function(self)
        local success, message = false, ""
        
        if (self.Cache.SelectedAction == "Save") then
            local configName
            
            if (self.Cache.SelectedConfig and self.Cache.SelectedConfig ~= "") then
                configName = self.Cache.SelectedConfig
                success, message = self:SaveConfiguration(configName)
            else
                configName = self.Cache.TextboxInput
                if (not configName or configName == "") then
                    message = "Please select a config to override or enter a new config name"
                else
                    success, message = self:SaveConfiguration(configName)
                end
            end
        elseif (self.Cache.SelectedAction == "Create") then
            local configName = self.Cache.TextboxInput
            if (not configName or configName == "") then
                message = "Please enter a new config name"
            else
                success, message = self:SaveConfiguration(configName)
            end
        elseif (self.Cache.SelectedAction == "Load") then
            if (not self.Cache.SelectedConfig) then
                message = "Please select a config to load"
            else
                success, message = self:LoadConfiguration(self.Cache.SelectedConfig)
            end
        elseif (self.Cache.SelectedAction == "Delete") then
            if (not self.Cache.SelectedConfig) then
                message = "Please select a config to delete"
            else
                success, message = self:DeleteConfiguration(self.Cache.SelectedConfig)
            end
        end
        
        --print(message)
        if (Config.Settings.Notifications) then
            Library:Notification("LUNOR » " .. message, 3, success and "success" or "error")
        end
        return success, message
    end,
}

ConfigsModule:GetConfigurations()
Sections.Configs:Textbox({
    Name = "Name",
    Flag = "ConfigsName",
    PlaceholderText = "Enter name..",
    Callback = function(value)
        ConfigsModule.Cache.TextboxInput = value
    end,
})

local configlist = Sections.Configs:List({
    Name = "Configurations:",
    Flag = "ConfigsList",
    Options = ConfigsModule.Cache.Configs,
    MinHeight = 80,
    Callback = function(value)
        ConfigsModule.Cache.SelectedConfig = value
    end,
})

Sections.Configs:Dropdown({
    Name = "Actions",
    Flag = "ConfigsActions",
    Options = {"Save", "Load", "Delete", "Create"},
    Searchable = true,
    Default = "Load",
    Callback = function(value)
        ConfigsModule.Cache.SelectedAction = value
    end,
})


Sections.Configs:Button({
    Name = "Confirm",
    Callback = function()
        ConfigsModule:ExecuteAction()
        configlist:Refresh(ConfigsModule.Cache.Configs)
    end,
})


Sections.ShareConfigs:Paragraph({
    Title = "Share Configs",
    Description = {
        {
            Text = "» To share, press the share button",
        },
        {
            Text = "» To load, first enter the config-key",
        },
        {
            Text = "» After setting key, press load button",
        },
    },
    Position = "Center",
})

-- seperator
Sections.ShareConfigs:Separator()

-- textbox to enter configkey
Sections.ShareConfigs:Textbox({
    Name = "Enter Key",
    Flag = "ConfigKey",
    PlaceholderText = "None..",
    Callback = function(value)
        ConfigsModule.Cache.ConfigKey = value
    end,
})

-- load from configkey
Sections.ShareConfigs:Button({
    Name = "Load",
    Callback = function()
        local content = ConfigsModule.Cache.ConfigKey
        if (not content or content == "" or content == "None") then
            if (Config.Settings.Notifications) then
                Library:Notification("LUNOR » Please enter a valid config-key", 3, "error")
            end
            return
        end

        local success, decoded = pcall(function()
            return base64.decode(content)
        end)

        if (not success or not decoded) then
            if (Config.Settings.Notifications) then
                Library:Notification("LUNOR » Invalid config-key", 3, "error")
            end
            return
        end

        success, message = pcall(function()
            Library:LoadConfig(decoded)
        end)

        if (not success) then
            if (Config.Settings.Notifications) then
                Library:Notification("LUNOR » Failed to load config-key", 3, "error")
            end
            return
        end

        if (Config.Settings.Notifications) then
            Library:Notification("LUNOR » Config loaded from key successfully", 3, "success")
        end
    end,
})

-- export
Sections.ShareConfigs:Button({
    Name = "Share",
    Callback = function()
        local content = Library:GetConfig()
        content = base64.encode(content)
        setclipboard(content)
        if (Config.Settings.Notifications) then
            Library:Notification("LUNOR » Config copied to clipboard", 3, "success")
        end
    end,
})


local runtime =
{
    cache =
    {
        lasttarget = nil,
        lastlevel = nil,
        lastuntillboss = nil,
        lastboost = nil,
    },

    cooldowns =
    {
        lastupdate = 0,
        updateevery = 7,
    },

    handle = function(self)
        local target = workspace.ScriptedMap.Event.HitListVisualizer.Hitbox.GuiAttachment.Billboard.Display.Text or "None"
        local level = ModuleManager:GetModule("PlayerData"):GetData().Data.ClaimedRewards.CardUpdateEvent or "None"
        local untillboss = ModuleManager:GetModule("PlayerData"):GetData().Data.BrainrotsForBoss or "None"
        local boost = ModuleManager:GetModule("PlayerData"):GetData().Data.Boost or "None"

        if (self.cache.lasttarget == target and self.cache.lastlevel == level and self.cwache.lastuntillboss == untillboss and self.cache.lastboost == boost) then return end

        self.cache.lasttarget = target
        self.cache.lastlevel = level
        self.cache.lastuntillboss = untillboss
        self.cache.lastboost = boost
        local bosspercentage = (untillboss / 500) * 100
        bosspercentage = math.clamp(bosspercentage, 0, 100)
        bosspercentage = math.floor(bosspercentage)

        if (level and level == 20) then
            local Event = game:GetService("ReplicatedStorage").Remotes.CardUpdateEvent
            Event:FireServer(
                "purchaseReplay"
            )

            task.wait(0.25)

            Features.Collect:AutoClaimEvent(true)
        end

        rewardsparagraph:SetDescription(
        {
            {
                Text = "Target » " .. (target or "None"),
            },
            {
                Text = "Current Level » " .. (level or "None"),
            },
            {
                Text = "Boss Status » " .. (bosspercentage or "None") .. "%",
            },
            {
                Text = "Currency Boost » " .. (boost or "None") .. "x",
            },
        })
    end,
}

Services.RunService.Heartbeat:Connect(function()
    local currentTime = tick()
    if (currentTime - runtime.cooldowns.lastupdate < runtime.cooldowns.updateevery) then
        return
    end

    runtime.cooldowns.lastupdate = currentTime
    runtime:handle()
end)

Library:Notification("LUNOR » Loaded Successfully", 3, "success")

Restores =
{
    RestoreCombatConn = function(self, boolean)
        if (not boolean and Config.Connections.AutoCombatConnection) then
            Config.Connections.AutoCombatConnection:Disconnect()
            Config.Connections.AutoCombatConnection = nil
            DesyncLibrary.DesyncPosition = DesyncLibrary.RealPosition
            task.wait()
            DesyncLibrary.ShouldDesync = false
            return
        elseif (boolean and not Config.Connections.AutoCombatConnection and Config.Farm.AutoCombat) then
            Config.Connections.AutoCombatConnection = Services.RunService.Heartbeat:Connect(function()
                local currentTime = tick()
                if (Config.Cooldowns.LastAttacked == nil or currentTime - Config.Cooldowns.LastAttacked >= Config.Cooldowns.AttackCooldown) then
                    Config.Cooldowns.AttackCooldown = math.random(0.15, 0.23)
                    Config.Cooldowns.LastAttacked = currentTime
                    Features.Farm:AttackEntity()
                    Features.Farm:TeleportEntity()
                end
            end)
            return
        end
    end,

    UpdateKeybind = function(self)
        local key = UIKeybind:GetKey()
        Library.UIKey = key
    end,
}

