

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local virtualUser = game:GetService("VirtualUser")
local IdledConnection = LocalPlayer.Idled:Connect(function()
    virtualUser:CaptureController()
    virtualUser:ClickButton2(Vector2.new())
end)

local lcl = game.Players.LocalPlayer
local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")

local Services = 
{
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    VirtualUser = game:GetService("VirtualUser"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Debris = game:GetService("Debris"),
    UserInputService = game:GetService("UserInputService"),
}

repeat task.wait(1) until Services.ReplicatedStorage.Remotes:FindFirstChild("FavoriteItem")
local combatevent = Services.ReplicatedStorage.Remotes.AttacksServer.WeaponAttack
local favoriteevent = Services.ReplicatedStorage.Remotes.FavoriteItem
local sellevent = Services.ReplicatedStorage.Remotes.ItemSell
local equipbest = Services.ReplicatedStorage.Remotes.EquipBest
local buygearevent = Services.ReplicatedStorage.Remotes.BuyGear
local buyitem = Services.ReplicatedStorage.Remotes.BuyItem
local pickupevent = Services.ReplicatedStorage.Remotes.RemoveItem
local placeevent = Services.ReplicatedStorage.Remotes.PlaceItem
local useitemevent = Services.ReplicatedStorage.Remotes.UseItem
local packevent = Services.ReplicatedStorage.Remotes.OpenHeldPack
local equipitem = Services.ReplicatedStorage.Remotes.EquipItem
local eggremote = Services.ReplicatedStorage.Remotes.OpenEgg
local mergevent = Services.ReplicatedStorage.Remotes.MergeCards
local cardupdateevent = Services.ReplicatedStorage.Remotes.CardUpdateEvent

--local libfile = readfile("lib.lua")
--local Library = loadstring(libfile)()

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/quadshoota/RBLX/refs/heads/main/ServerlistDatabase.lua"))()
local Storage =
{
    Icons = {},
    ConfigsPath = nil,
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
    Version = "Developer",
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
    GearNames = {},
    AllPotions = {},
    AllEvents = {},
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

            GearRegistry =
            {
                base = game.ReplicatedStorage.Modules.Registries,
                path = "GearRegistry"
            },

            EventRegistry =
            {
                base = game.ReplicatedStorage.Modules.Registries,
                path = "EventRegistry"
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

local ignoredgears = {"Frost Blower", "Water Bucket", "Premium Water", "Handcuffs"}
for i,v in pairs(ModuleManager:GetModule("GearRegistry")) do

    if (string.find(i, "Gun") or string.find(i, "Grenade") or string.find(i, "Launcher")) then
        table.insert(Globals.GearNames, i)
    elseif (string.find(i, "Potion")) then
        table.insert(Globals.AllPotions, i)
    end
end

for i,v in pairs(ModuleManager:GetModule("EventRegistry")) do
    table.insert(Globals.AllEvents, i)
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


local Utils =
{
    CachedPlot = nil,
    CachedTool = nil,

    FormatPrice = function(self, price)
        local str = tostring(price)
        local formatted = str:reverse():gsub("(%d%d%d)", "%1."):reverse()
        if (formatted:sub(1, 1) == ".") then
            formatted = formatted:sub(2)
        end
        return formatted
    end,

    ConvertToEnumkey = function(self, text)
        local enumMap = {
            RShift = Enum.KeyCode.RightShift,
            RCtrl = Enum.KeyCode.RightControl,
            LAlt = Enum.KeyCode.LeftAlt,
            RAlt = Enum.KeyCode.RightAlt,
            Caps = Enum.KeyCode.CapsLock,
            Insert = Enum.KeyCode.Insert
        }
        
        return enumMap[text]
    end,

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

    Tool = function(self, boolean, inst)
        local equipped = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool") or nil

        if (boolean == false) then
            humanoid:UnequipTools()
        elseif (boolean == true and inst and inst ~= nil and inst:IsA("Tool") and inst.Parent == game.Players.LocalPlayer.Backpack) then
            if (equipped and equipped ~= inst) then
                humanoid:UnequipTools()
            end

            task.wait()
            humanoid:EquipTool(inst)
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

    -- Info
    Info = Tabs.Farm:Section({
        Title = "Info",
        Side = "Left",
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

    -- Items/Potions
    Potions = Sections.Items:Subsection({
        Name = "Potions",
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

        -- propertychanged
        AutoResetConnection = nil,
        RewardClaimConnection = nil,
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
        CollectAwardEvery = 25,
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
        LastUsedPotion = 0,
        UsePotionEvery = 2,
        LastEventReset = 0,
        EventResetEvery = 35,
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
        FarmEvents = Globals.AllEvents,
        SelectedFarmEvents = {},
    },

    Collect =
    {
        AutoCollectAndEquip = false,
        AutoClaimEvent = false,
        AutoPurchaseRestart = false,
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
        SelectedFavoriteOptions = {},
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
        DeleteOthersBrainrots = false,
        DeleteOthersPlants = false,
        SetMaxFps = "Disabled",
        

        Notifications = true,
        -- RShift RCtrl LAlt RAlt Caps Insert only these.
        KeyList = {"RShift", "RCtrl", "LAlt", "RAlt", "Caps", "Insert"},
        SelectedKey = "RCtrl",
    },

    Items =
    {
        AutoProjectiles = false,
        AutoPotions = false,
        Projectiles = Globals.GearNames,
        SelectedProjectiles = {},
        ProjectileOptions = {"Health"},
        PotionOptions = Globals.AllPotions,
        SelectedPotions = {},
        SelectedProjectileOptions = {},
        ProjectileHealth = 150,

        InstantOpenCards = false,
        AutoOpenCards = false,

        DisableEggAnimations = false,
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
            if (#Config.Farm.SelectedFarmEvents > 0) then
                local events = workspace:GetAttribute("ActiveEvents") or {}
                if (Utils:Contains(Config.Farm.SelectedFarmEvents, events) == false) then
                    return
                end
            end

            local target = self:GetEntityByPriority()
            if (target == nil) then return end
            local htbox = target:FindFirstChild("BrainrotHitbox") or target:FindFirstChild("Hitbox")
            Restores:UpdatePosition(htbox.CFrame)
        end,

        AttackEntity = function(self)
            if (#Config.Farm.SelectedFarmEvents > 0) then
                local events = workspace:GetAttribute("ActiveEvents") or {}
                if (Utils:Contains(Config.Farm.SelectedFarmEvents, events) == false) then
                    Restores:UpdateDesync("TeleportEntity", false)
                    return
                end
            end

            local target = self:GetEntityByPriority()
            if target == nil then
                Restores:UpdateDesync("TeleportEntity", false)
                return
            end

            Restores:UpdateDesync("TeleportEntity", true)
            self:TeleportEntity()
            Utils:Tool(true, Utils:ReturnTool())

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
                        Utils:Tool(true, v)
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
            for i,v in pairs(lcl.Backpack:GetChildren()) do
                if (not v:IsA("Tool") or not v:GetAttribute("IsPlant")) then continue end
                local model = v:FindFirstChildOfClass("Model") or nil
                if (not model) then continue end
                local rarity = model:GetAttribute("Rarity") or nil
                if (not rarity) then continue end

                if (not Utils:Contains(Config.Sell.SelectedSellPlantRarities, rarity)) then
                    Utils:Favorite(v, true)
                end
            end

            task.wait(1)
            sellevent:FireServer(nil, true, true)
        end
    },

    Collect =
    {
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
            Restores:UpdateDesync("ClaimEvent", true)
            Restores:UpdatePosition(proxim.Parent.CFrame)

            task.wait(0.25)
            fireproximityprompt(proxim)

            if (Config.Settings.Notifications) then
                Library:Notification("LUNOR » Claimed Event Reward's", 3, "success")
            end

            Restores:UpdateDesync("ClaimEvent", false)

            if (Config.Farm.AutoCombat) then Restores:RestoreCombatConn(true) end
        end,

        AutoResetEvent = function(self)
            local path = game.Players.LocalPlayer.PlayerGui.SurfaceGui.ReplayFrame
            if (not path or path and path.Visible == false) then return end

            
            local money = ModuleManager:GetModule("PlayerData"):GetData().Data.Money
            local canreset = (money >= 500000) and true or false

            if (path and path.Visible == true and canreset) then
                cardupdateevent:FireServer(
                    "purchaseReplay"
                )

                task.wait(0.25)
                self:AutoClaimEvent(true)

                if (Config.Settings.Notifications) then
                    Library:Notification("LUNOR » Event finished, purchasing reset", 3, "success")
                end
            end

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
        UsePotions = function(self)
            if (Config.Items.AutoPotions == false) then return end
            if (#Config.Items.SelectedPotions == 0) then return end
            local backpack = game.Players.LocalPlayer:FindFirstChild("Backpack")
            --warn("Using Potions..")

            for i,v in pairs(backpack:GetChildren()) do
                local itemname = v:GetAttribute("ItemName") or nil
                if (not itemname) then continue end
                --warn(tostring(itemname))

                if (v:IsA("Tool") and Utils:Contains(Config.Items.SelectedPotions, itemname)) then
                    --warn("found")
                    Restores:RestoreCombatConn(false)
                    Utils:Tool(true, v)
                    task.wait(0.1)
                    useitemevent:FireServer({
                        Toggle = true,
                        Tool = game.Players.LocalPlayer.Character:FindFirstChild(v.Name),
                    })
                    task.wait(0.2)
                    Utils:Tool(false)
                    Restores:RestoreCombatConn(true)

                    if (Config.Settings.Notifications) then
                        Library:Notification("POTIONS » " .. v:GetAttribute("ItemName"), 3, "warning")
                    end

                    break
                end
            end

            return true
        end,

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
            

            for i, v in pairs(backpack:GetChildren()) do
                if (not v:GetAttribute("Name")) then continue end
                if (v:IsA("Tool") and Utils:Contains(Config.Items.SelectedProjectiles, v:GetAttribute("Name"))) then
                    Restores:RestoreCombatConn(false)
                    Utils:Tool(true, v)
                    Restores:UpdateDesync("ThrowProjectile", true)
                    Restores:UpdatePosition(rayOrigin.CFrame)
                    table.insert(usedTools, v:GetAttribute("Name"))
                    task.wait(0.3)
                    
                    Restores:UpdatePosition(rayOrigin.CFrame)
                    useitemevent:FireServer({
                        Toggle = true,
                        Tool = game.Players.LocalPlayer.Character:FindFirstChild(v.Name),
                        Time = 0,
                        Pos = rayOrigin.Position,
                    })

                    task.wait(0.1)

                    break
                end
            end

            Restores:UpdateDesync("ThrowProjectile", false)
            Restores:RestoreCombatConn(true)
            if (#usedTools <= 0) then return end

            Utils:Tool(false)
            if (Config.Settings.Notifications) then
                Library:Notification("PROJECTILES » Threw " .. table.concat(usedTools, " | "), 3, "warning")
            end
        end,


        OpenPacks = function(self)
            -- packevent
            local backpack = game.Players.LocalPlayer:FindFirstChild("Backpack")
            local equipped = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")

            if (equipped and string.find(string.lower(equipped.Name), "pack")) then
                packevent:FireServer()
                if (Config.Settings.Notifications) then
                    Library:Notification("CARDS » Opening " .. tostring(equipped.Name), 3, "success")
                end
                return true
            end

            for i,v in pairs(backpack:GetChildren()) do
                local loweredname = string.lower(v.Name)
                if (v:IsA("Tool") and string.find(loweredname, "pack")) then
                    Restores:RestoreCombatConn(false)
                    Utils:Tool(true, v)
                    task.wait(0.1)
                    equipped = v
                    break
                end
            end

            if (not equipped or not string.find(string.lower(equipped.Name), "pack")) then return end

            packevent:FireServer()
            task.wait(0.1)
            Utils:Tool(false)
            Restores:RestoreCombatConn(true)

            if (Config.Settings.Notifications) then
                Library:Notification("CARDS » Opening " .. tostring(equipped.Name), 3, "success")
            end
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
                        if (Config.Cooldowns.OpenEggsEvery == 15 or self.EggFunc == nil and Config.Items.DisableEggAnimations) then
                            Config.Cooldowns.OpenEggsEvery = 8
                        end

                        Restores:RestoreCombatConn(false)
                        Utils:Tool(true, v)
                        task.wait(0.2)
                        eggremote:FireServer()
                        task.wait(0.2)

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
            Config.Cooldowns.OpenEggsEvery = 15
            return false
        end,
    },

    Settings =
    {
        Storage =
        {
            DeleteConn = nil,
            PlantConn = nil
        },

        DeleteOthersBrainrots = function(self)
            if (Config.Settings.DeleteOthersBrainrots == true) then
                local path = workspace.ScriptedMap.Brainrots
                DeleteConn = path.ChildAdded:Connect(function(child)
                    if (child:GetAttribute("AssociatedPlayer") ~= lcl.UserId) then
                        child:Destroy()
                    end
                end)
            else
                if (DeleteConn) then
                    DeleteConn:Disconnect()
                    DeleteConn = nil
                end
            end
        end,

        DeleteOthersPlants = function(self)
            if (Config.Settings.DeleteOthersPlants == true) then
                for i,v in pairs(workspace.Plots:GetChildren()) do
                    if (v:GetAttribute("Owner") ~= lcl.Name) then
                        local path = v.Plants
                        for i,v in pairs(path:GetChildren()) do
                            v:Destroy()
                        end

                        PlantConn = path.ChildAdded:Connect(function(child)
                            child:Destroy()
                        end)
                    end
                end
            else
                if (PlantConn) then
                    PlantConn:Disconnect()
                    PlantConn = nil
                end
            end
        end,
    }
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
                    end
                end)
            end
        else
            if (Config.Connections.AutoCombatConnection) then
                Config.Connections.AutoCombatConnection:Disconnect()
                Config.Connections.AutoCombatConnection = nil
                Restores:UpdateDesync("TeleportEntity", false)
                Utils:Tool(false)
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

-- events
Subsections.Combat:Dropdown({
    Name = "Only On Events",
    Flag = "EventPriority",
    Options = Config.Farm.FarmEvents, 
    Default = Config.Farm.SelectedFarmEvents,
    Max = 99,
    Callback = function(value)
        Config.Farm.SelectedFarmEvents = value
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
            if (not Config.Connections.RewardClaimConnection) then
                local path = workspace.ScriptedMap.Event.TomadeFloor.GuiAttachment.Billboard:FindFirstChild("Checkmark")
                if (not path) then return end
                Config.Connections.RewardClaimConnection = path:GetPropertyChangedSignal("Visible"):Connect(function()
                    if (path.Visible == true) then
                        Config.Cooldowns.LastCollectedAward = tick()
                        Features.Collect:AutoClaimEvent()
                    end
                end)
            end

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
                Restores:UpdateDesync("ClaimEvent", false)
            end

            if (Config.Connections.RewardClaimConnection) then
                Config.Connections.RewardClaimConnection:Disconnect()
                Config.Connections.RewardClaimConnection = nil
            end
        end
    end,
})

-- AutoPurchaseRestart event toggle
Subsections.Collect:Toggle({
    Name = "Auto-Restart Event",
    Flag = "AutoPurchaseRestart",
    Default = Config.Collect.AutoPurchaseRestart,
    Callback = function(value)
        Config.Collect.AutoPurchaseRestart = value
        if (value) then

            -- Property Changed Visible, and true send it forward.
            if (not Config.Connections.AutoResetConnection) then
                local path = game.Players.LocalPlayer.PlayerGui.SurfaceGui.ReplayFrame
                Config.Connections.AutoResetConnection = path:GetPropertyChangedSignal("Visible"):Connect(function()
                    if (path.Visible == true) then
                        Features.Collect:AutoResetEvent()
                        Config.Cooldowns.LastEventReset = tick()
                    end
                end)
            end

            if (not Config.Connections.AutoResetEvent) then
                Config.Connections.AutoResetEvent = Services.RunService.Heartbeat:Connect(function()
                    local currentTime = tick()
                    if (currentTime - Config.Cooldowns.LastEventReset < Config.Cooldowns.EventResetEvery) then
                        return
                    end

                    Config.Cooldowns.LastEventReset = currentTime
                    Features.Collect:AutoResetEvent()
                end)
            end
        else
            if (Config.Connections.AutoResetEvent) then
                Config.Connections.AutoResetEvent:Disconnect()
                Config.Connections.AutoResetEvent = nil
            end

            if (Config.Connections.AutoResetConnection) then
                Config.Connections.AutoResetConnection:Disconnect()
                Config.Connections.AutoResetConnection = nil
            end
        end
    end,
})


local rewardsparagraph = Sections.Info:Paragraph({
    Title = "Event Details",
    Description = {
        {
            Text = "Target » None",
        },
        {
            Text = "Event Level » None",
        },
        {
            Text = "Boss Status » None",
        },
        {
            Text = "Server Version » " .. tostring(game.PlaceVersion),
        },
    },
    Position = "Center",
})


-- seperator
Sections.Info:Separator()

-- copy join link button
Sections.Info:Button({
    Name = "Copy Server Code",
    Callback = function()
        local script = 'local TeleportService = game:GetService("TeleportService")\nlocal player = game:GetService("Players").LocalPlayer\nTeleportService:TeleportToPlaceInstance(' .. tostring(game.PlaceId) .. ', "' .. tostring(game.JobId) .. '", player)'
        setclipboard(script)
        Library:Notification("LUNOR » Copied Join Link", 3, "success")
    end,
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
            Config.Cooldowns.LastSoldPlants = nil
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
    Name = "Sell Rarities",
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

-- seperator
Sections.Favorites:Separator()

Sections.Favorites:Dropdown({
    Name = "Select Rarities",
    Flag = "FavoriteRarities",
    Max = 99,
    Options = Config.Favorites.FavoriteRarities, 
    Default = Config.Favorites.SelectedFavoriteRarities,
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
    Name = "Seed Quantity",
    Flag = "SeedPurchaseAmount",
    PlaceholderText = "None..",
    Default = Config.Shop.SeedPurchaseAmount,
    Callback = function(value)
        value = Helpers:ConvertToNumbers(value) or 0
        Config.Shop.SeedPurchaseAmount = value
        Config.Cooldowns.LastPurchasedSeeds = 0
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
    Name = "Gear Quantity",
    Flag = "GearPurchaseAmount",
    Default = Config.Shop.GearPurchaseAmount,
    PlaceholderText = "None..",
    Callback = function(value)
        value = Helpers:ConvertToNumbers(value) or 0
        Config.Shop.GearPurchaseAmount = value
        Config.Cooldowns.LastPurchasedGears = 0
        --warn("Set gear purchase amount to: " .. tostring(Config.Shop.GearPurchaseAmount))
    end,
})

-- Options
Subsections.Settings:Toggle({
    Name = "Low Graphics",
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

-- DeleteOthersBrainrots
Subsections.Settings:Toggle({
    Name = "Delete Others Brainrots",
    Flag = "DeleteOthersBrainrots",
    Default = Config.Settings.DeleteOthersBrainrots,
    Callback = function(value)
        Config.Settings.DeleteOthersBrainrots = value
        Features.Settings:DeleteOthersBrainrots()
    end,
})

-- DeleteOthersPlants
Subsections.Settings:Toggle({
    Name = "Delete Others Plants",
    Flag = "DeleteOthersPlants",
    Default = Config.Settings.DeleteOthersPlants,
    Callback = function(value)
        Config.Settings.DeleteOthersPlants = value
        Features.Settings:DeleteOthersPlants()
    end,
})

-- MAX FPS DROPDOWN
Subsections.Settings:Dropdown({
    Name = "Limit FPS         ",
    Flag = "MaxFPS",
    Options = {"Disabled", "30", "60", "144", "240", "Unlimited"},
    Default = Config.Settings.SetMaxFps,
    Callback = function(value)
        Config.Settings.SetMaxFps = value
        if (value ~= "Disabled") then
            if (value == "Unlimited") then
                setfpscap(0)
                return
            end

            value = tonumber(value)
            setfpscap(value)
            return
        end
    end,
})


-- Interface
Subsections.Interface:Dropdown({
    Name = "Interface Key",
    Flag = "interfacekeybind",
    Options = Config.Settings.KeyList, 
    Default = Config.Settings.SelectedKey,
    Callback = function(value)
        Config.Settings.InterfaceKey = value
        local enumKey = Utils:ConvertToEnumkey(value)
        Library.UIKey = enumKey
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
                Restores:UpdateDesync("ThrowProjectile", false)
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


-- autopoints
Subsections.Potions:Toggle({
    Name = "Auto Potions",
    Flag = "AutoPotions",
    Default = Config.Items.AutoPotions,
    Callback = function(value)
        Config.Items.AutoPotions = value
        Config.Cooldowns.LastUsedPotion = nil
        if (value) then
            if (not Config.Connections.AutoPotionConnection) then
                Config.Connections.AutoPotionConnection = Services.RunService.Heartbeat:Connect(function()
                    local currentTime = tick()
                    if (Config.Cooldowns.LastUsedPotion == nil or currentTime - Config.Cooldowns.LastUsedPotion >= Config.Cooldowns.UsePotionEvery) then
                        Config.Cooldowns.LastUsedPotion = currentTime
                        Features.Items:UsePotions()
                    end
                end)
            end
        else
            if (Config.Connections.AutoPotionConnection) then
                Config.Connections.AutoPotionConnection:Disconnect()
                Config.Connections.AutoPotionConnection = nil

            end
        end
    end,
})

-- seperator
Subsections.Potions:Separator()

-- PotionOptions
Subsections.Potions:Dropdown({
    Name = "Select Potions",
    Flag = "PotionOptions",
    Max = 99,
    Options = Config.Items.PotionOptions,
    Default = Config.Items.SelectedPotions,
    Callback = function(value)
        Config.Items.SelectedPotions = value
        Config.Cooldowns.LastUsedPotion = nil
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


-- DisableEggAnimations
Subsections.Eggs:Toggle({
    Name = "Disable Animation",
    Flag = "InstantOpenEggs",
    Default = Config.Items.DisableEggAnimations,
    Callback = function(value)
        Config.Items.DisableEggAnimations = value
        if (value and Features.Items.EggFunc == nil) then
            Features.Items:SkipEggs()
        elseif (not value and Features.Items.EggFunc ~= nil) then
            restorefunction(Features.Items.EggFunc)
            Features.Items.EggFunc = nil
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

-- seperator
Sections.Developer:Separator()

-- LogAllRequests
Sections.Developer:Button({
    Name = "Log All Requests",
    Callback = function()
        Restores:LogAllRequests()
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

    GetAutoloadConfigName = function(self)
        local filePath = Storage.ConfigsPath .. "/autoload.lnr"
        if (isfile(filePath)) then
            local content = readfile(filePath)
            return content or nil
        end
        return nil
    end,

    GetConfigurations = function(self)
        self.Cache.Configs = {}
        local autoloadname = self:GetAutoloadConfigName()
        for _, file in pairs(listfiles(Storage.ConfigsPath)) do
            if (file:match("%.lnr$")) then
                local configName = file:match("([^/\\]+)%.lnr$")

                if (configName and configName == autoloadname) then
                    configName = configName .. " [autoload]"
                end

                if (configName and configName ~= "autoload") then
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
        local filePath = Storage.ConfigsPath .. "/" .. configName .. ".lnr"
        return isfile(filePath)
    end,

    SaveConfiguration = function(self, configName)
        local isValid, result = self:ValidateConfigName(configName)
        if (not isValid) then
            return false, result
        end

        local cleanName = result

        local content = Library:GetConfig()
        local filePath = Storage.ConfigsPath .. "/" .. cleanName .. ".lnr"
        
        local message = ""
        if (self:ConfigExists(cleanName)) then
            message = "Config '" .. cleanName .. "' overwritten successfully"
        else
            message = "Config '" .. cleanName .. "' saved successfully"
        end
        
        content = base64.encode(content)
        writefile(filePath, content)
        self:GetConfigurations()
        return true, message
    end,

    LoadConfiguration = function(self, configName)
        if (not configName or configName == "") then
            return false, "No config selected"
        end

        local autoloadname = self:GetAutoloadConfigName()
        if (configName == autoloadname .. " [autoload]") then
            configName = autoloadname
        end
        
        local filePath = Storage.ConfigsPath .. "/" .. configName .. ".lnr"
        if (isfile(filePath)) then
            local content = readfile(filePath)
            if (content) then
                content = base64.decode(content)
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

        local autoloadname = self:GetAutoloadConfigName()
        if (configName == autoloadname .. " [autoload]") then
            configName = autoloadname
        end
        
        if (configName == "Default") then
            return false, "Cannot delete Default config"
        end
        
        local filePath = Storage.ConfigsPath .. "/" .. configName .. ".lnr"
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
                local autoloadname = self:GetAutoloadConfigName()
                if (configName == autoloadname .. " [autoload]") then
                    configName = autoloadname
                end

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
        elseif (self.Cache.SelectedAction == "Auto-Load") then
            if (not self.Cache.SelectedConfig) then
                message = "Please select a config to autoload"
            else
                self:SetAutoload(self.Cache.SelectedConfig)
                success = true
                message = false
            end
        end
        
        --print(message)

        if (message and message ~= false) then
            Library:Notification("LUNOR » " .. message, 3, success and "success" or "error")
        end
        
        return success, message
    end,

    SetAutoload = function(self, configname)
        local filePath = Storage.ConfigsPath .. "/" .. "autoload" .. ".lnr"
        local content = readfile(filePath)
        
        local autoloadname = self:GetAutoloadConfigName()
        if (configname == autoloadname .. " [autoload]") then
            configname = autoloadname
        end

        if (content == configname) then
            writefile(filePath, "")
            self:GetConfigurations()
            Library:Notification("LUNOR » Auto-Load disabled.", 3, "success")
            return
        end

        writefile(filePath, configname)
        self:GetConfigurations()
        Library:Notification("LUNOR » Auto-Load set to '" .. configname .. "'", 3, "success")
    end,

    DoAutoload = function(self)
        local filePath = Storage.ConfigsPath .. "/" .. "autoload" .. ".lnr"
        if (not isfile(filePath)) then
            writefile(filePath, "")
            return
        end

        local configname = readfile(filePath)
        if (not isfile(Storage.ConfigsPath .. "/" .. configname .. ".lnr")) then
            writefile(filePath, "")
            return
        end

        if (configname and configname ~= "" and configname ~= "nil" and configname ~= "null") then
            self:LoadConfiguration(configname)
            Library:Notification("LUNOR » Auto-Load config '" .. configname .. "' loaded successfully", 3, "success")
        end
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

-- seperator
Sections.Configs:Separator()

Sections.Configs:Dropdown({
    Name = "Actions",
    Flag = "ConfigsActions",
    Options = {"Save", "Load", "Delete", "Create", "Auto-Load"},
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
    Name = "Load from Key",
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
    Name = "Copy Config-Key",
    Callback = function()
        local content = Library:GetConfig()
        content = base64.encode(content)
        setclipboard(content)
        if (Config.Settings.Notifications) then
            Library:Notification("LUNOR » Config copied to clipboard", 3, "success")
        end
    end,
})

-- Tutorial button
Sections.ShareConfigs:Button({
    Name = "Tutorial",
    Callback = function()
        -- will add link opening
    end,
})



local runtime =
{
    cache =
    {
        lasttarget = nil,
        lastlevel = nil,
        lastmoney = nil,
    },

    cooldowns =
    {
        lastupdate = 0,
        updateevery = 7,
    },

    handle = function(self)
        local target = workspace.ScriptedMap.Event.HitListVisualizer.Hitbox.GuiAttachment.Billboard.Display.Text or "None"
        local level = ModuleManager:GetModule("PlayerData"):GetData().Data.ClaimedRewards.CardUpdateEvent or "None"
        local money = ModuleManager:GetModule("PlayerData"):GetData().Data.Money
        if (money > 50000 and Config.Collect.AutoPurchaseRestart == true) then money = true else money = false end
        if (self.cache.lasttarget == target and self.cache.lastlevel == level and self.cache.lastmoney == money) then
            return
        end

        self.cache.lasttarget = target
        self.cache.lastlevel = level
        self.cache.lastmoney = money
        rewardsparagraph:SetDescription(
        {
            {
                Text = "Target » " .. (target or "None"),
            },
            {
                Text = "Progression » " .. (level or "None") .. "/20",
            },
            {
                Text = "Auto Restart » " .. tostring(money),
            },
            {
                Text = "Server Ver » " .. tostring(game.PlaceVersion),
            }
        })
    end,
}

Services.RunService.Heartbeat:Connect(function()
    local currentTime = tick()
    if (currentTime - runtime.cooldowns.lastupdate < runtime.cooldowns.updateevery) then
        return
    else
        runtime.cooldowns.lastupdate = currentTime
        runtime:handle()
    end
end)


Restores =
{
    RestoreCombatConn = function(self, boolean)
        if (not boolean and Config.Connections.AutoCombatConnection) then
            Config.Connections.AutoCombatConnection:Disconnect()
            Config.Connections.AutoCombatConnection = nil
            Restores:UpdateDesync("TeleportEntity", false)
            Utils:Tool(false)
            return
        elseif (boolean and not Config.Connections.AutoCombatConnection and Config.Farm.AutoCombat) then
            Config.Connections.AutoCombatConnection = Services.RunService.Heartbeat:Connect(function()
                local currentTime = tick()
                if (Config.Cooldowns.LastAttacked == nil or currentTime - Config.Cooldowns.LastAttacked >= Config.Cooldowns.AttackCooldown) then
                    Config.Cooldowns.AttackCooldown = math.random(0.15, 0.23)
                    Config.Cooldowns.LastAttacked = currentTime
                    Features.Farm:AttackEntity()
                    Restores:UpdateDesync("TeleportEntity", true)
                end
            end)
            return
        end
    end,

    DesyncCache =
    {
        Requests = {},
        LastSendData = 0,
        SendDataEvery = 5,
    },

    LogAllRequests = function(self)
        warn("[ REQUESTS DATA ]")
        
        for i,v in pairs(self.DesyncCache.Requests) do
            warn(i .. " » " .. tostring(v))
        end

        warn(" [ DESYNC DATA]")
        warn("Desync Status » " .. tostring(DesyncLibrary.ShouldDesync))

    end,


    UpdatePosition = function(self, position)
        if (not position or position == nil) then
            return
        end

        DesyncLibrary.DesyncPosition = position
    end,

    UpdateDesync = function(self, identifier, boolean)
        if (self.DesyncCache.Requests[identifier] == nil or self.DesyncCache.Requests[identifier] ~= boolean) then
            self.DesyncCache.Requests[identifier] = boolean
        end

        if (Utils:Contains(self.DesyncCache.Requests, true)) then
            DesyncLibrary.ShouldDesync = true
            return true
        else
            DesyncLibrary.DesyncPosition = DesyncLibrary.RealPosition
            task.wait()
            DesyncLibrary.ShouldDesync = false
            return false
        end
    end,
}


repeat task.wait(1) until Storage.ConfigsPath ~= nil
ConfigsModule:DoAutoload()
Library:Notification("LUNOR » Loaded Successfully", 3, "success")
