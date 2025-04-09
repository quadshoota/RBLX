local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Catto-YFCN/BetterOrion/refs/heads/main/OrionLib"))() 
local FlagsManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Catto-YFCN/BetterOrion/refs/heads/main/OrionLibPlus"))()

if (not LPH_OBFUSCATED) then
    LPH_JIT_MAX = function(...) return(...) end;
    LPH_NO_VIRTUALIZE = function(...) return(...) end;
    LPH_CRASH = function(...) while task.wait() do game:GetService("ScriptContext"):SetTimeout(math.huge);while true do while true do while true do while true do while true do while true do while true do while true do print("noob") end end end end end end end end end end;
    LRM_UserNote = "Owner" 
    LRM_ScriptVersion = "v002" 
    ClonedPrint = print
end

if (LPH_OBFUSCATED) then
    ClonedPrint = print
    print = function(...)end
    warn = function(...)end
end

local teleportCooldown = {
    lastTeleportAttempt = 0,
    cooldownPeriod = 10
}

if (not isfile('Lunor_Trans.png')) then
    writefile("Lunor_Trans.png", game:HttpGet('https://github.com/Catto-YFCN/Lunor_Dependencies/blob/main/Lunor_Trans.png?raw=true'))
end

if getgenv().sessionInitialized == nil then
    getgenv().sessionInitialized = true
end

local utils =
{
    RoleChecker = function(self)
        if (string.find(LRM_UserNote, "Ad Reward")) then
            return "Free Version"
        elseif (string.find(LRM_UserNote, "Premium")) then
            return "Premium Version"
        elseif (string.find(LRM_UserNote, "Owner")) then
            return "Dev Version"
        elseif (string.find(LRM_UserNote, "nylt")) then
            return "nylts stupidity" 
        else
            return "No Role Assigned"
        end
    end,

    getLunorIcon = function(self)
        local asset
        local success, product = pcall(function()
            return getcustomasset(readfile('Lunor_Trans.png'))
        end)
    
        if (not success or identifyexecutor():find("Cryptic")) then
            asset = "http://www.roblox.com/asset/?id=139977906854557"
        else
            asset = product
        end
        return asset
    end,

    formatVersion = function(self, version)
        local formattedVersion = "v" .. version:sub(2):gsub(".", "%0.") 
        return formattedVersion:sub(1, #formattedVersion - 1) 
    end,
    
    calculate_distance = function(self, a, b)
        if (a and b) then
            return math.sqrt((a.X - b.X) * (a.X - b.X) + (a.Y - b.Y) * (a.Y - b.Y))
        end
        return 0
    end,
}

utilscolor = 
{
    interpolate_color = function(self, color1, color2, t)
        local r = math.floor((1 - t) * color1[1] + t * color2[1])
        local g = math.floor((1 - t) * color1[2] + t * color2[2])
        local b = math.floor((1 - t) * color1[3] + t * color2[3])
        return string.format("#%02x%02x%02x", r, g, b)
    end,

    hex_to_rgb = function(self, hex)
        return {
            tonumber(hex:sub(1, 2), 16),
            tonumber(hex:sub(3, 4), 16),
            tonumber(hex:sub(5, 6), 16)
        }
    end,

    gradient = function(self, word)
        if (not word or #word == 0) then
            return "Error"
        end
    
        if (getgenv().GradientColor == nil) then
            start_color = self:hex_to_rgb("be7dfa") 
            end_color = self:hex_to_rgb("877dfa") 
        else
            start_color = self:hex_to_rgb(getgenv().GradientColor.startingColor)
            end_color = self:hex_to_rgb(getgenv().GradientColor.endingColor)
        end
    
        local gradient_word = ""
        local word_len = #word
        local step = 1.0 / math.max(word_len - 1, 1)
    
        for i = 1, word_len do
            local t = step * (i - 1)
            local color = self:interpolate_color(start_color, end_color, t)
            gradient_word = gradient_word .. string.format('<font color="%s">%s</font>', color, word:sub(i, i))
        end
    
        return gradient_word
    end,
}

if (not isfolder("Lunor/Hunters")) then
    makefolder("Lunor/Hunters")
end

if (not isfile("Lunor/Hunters/saved_configs.json")) then
    writefile("Lunor/Hunters/saved_configs.json", "{}")
end

local Config =
{
    InitializeTime = os.time(),
    InitializeCFrame = nil,
    Fighting =
    {
        AutoHit = false,
        AutoPosition = false,
		AutoStartDungeon = false,
        InstantKill = false,
        SkipBoss = false,
        SoftLockLimit = 35,
    },

    Premium =
    {
        AutomaticEverything = false,
    },

    Items =
    {
        AutoRoll = false,
        AutoReawaken = false,

        -- stats
        AutoStats = false,
        Priority = nil,
        Strength = 0,
        Agility = 0,
        Perception = 0,
        Vitality = 0,
        Intellect = 0,
    },

    Dungeon =
    {
        AutoDungeon = false,
        SelectDungeonFromLevel = false,
        SelectDifficultyFromLevel = false,
        Dungeons = {"Singularity", "Goblin Caves", "Spider Cavern"},
        Difficulty = "Normal",
        SelectedDungeon = "Singularity",
    },
}

local main = lib:Load({
    Title = 'Hunters '.. utils:formatVersion(LRM_ScriptVersion)..' | ' .. utilscolor:gradient("discord.gg/lunor").. " | ".. utils:RoleChecker(),
    KeyAuth = "Gato_Was_Here_Lol",
    ToggleButton = utils.getLunorIcon()
})

local tabs = {
    Main = main:AddTab("Main"),
    Fighting = main:AddTab("Combat"),
    Valuables = main:AddTab("Items"),
    Dungeons = main:AddTab("Dungeons"),
    Config = main:AddTab("Configs"),
}

main:SelectTab()

local sections = {
    Updates = tabs.Main:AddSection({Title = utilscolor:gradient("Updates"), Description = "", Defualt = true , Locked = false}),
    Items = tabs.Valuables:AddSection({Title = utilscolor:gradient("Rolls"), Description = "", Defualt = true , Locked = false}),
    Character = tabs.Valuables:AddSection({Title = utilscolor:gradient("Character"), Description = "", Defualt = true , Locked = false}),
    Stats = tabs.Valuables:AddSection({Title = utilscolor:gradient("Stats"), Description = "", Defualt = true , Locked = false}), 
    Killaura = tabs.Fighting:AddSection({Title = utilscolor:gradient("Auto-Farm"), Description = "", Defualt = true , Locked = false}),
    Exploits = tabs.Fighting:AddSection({Title = utilscolor:gradient("Exploits"), Description = "", Defualt = true , Locked = false}),
    PremiumFeatures = tabs.Fighting:AddSection({Title = utilscolor:gradient("Premium Features"), Description = "", Defualt = true , Locked = false}),
    FarmDungeon = tabs.Dungeons:AddSection({Title = utilscolor:gradient("Auto Dungeon"), Description = "", Defualt = true , Locked = false}),
    FarmSettings = tabs.Dungeons:AddSection({Title = utilscolor:gradient("Dungeon Settings"), Description = "", Defualt = false , Locked = false}),
    Gradient = tabs.Config:AddSection({Title = utilscolor:gradient("Gradient"), Description = "", Defualt = false , Locked = false}),
}

-- update log
sections.Updates:AddParagraph({Title = "Changelog", Description = "[-] Added Automatic Stats.\n[-] Added Priority selection for stats.\n[-] Added custom delay before, rejoin dungeon to avoid softlock\n[-] Minor bugfixes."})

sections.Items:AddToggle("AutoRoll", {
    Title = "Auto Roll",
    Description = "Automatically rolls for items.",
    Default = false,
    Callback = function(Value)
        Config.Items.AutoRoll = Value
    end,
})

sections.Killaura:AddToggle("AutoHit", {
    Title = "Auto Hit",
    Description = "Automatically hits enemies.",
    Default = false,
    Callback = function(Value)
        Config.Fighting.AutoHit = Value
    end,
})

sections.Killaura:AddToggle("AutoPosition", {
    Title = "Auto Position",
    Description = "Automatically positions to hit enemies.",
    Default = false,
    Callback = function(Value)
        Config.Fighting.AutoPosition = Value
    end,
})

sections.Exploits:AddToggle("InstantKill", {
    Title = "Instant Kill",
    Description = "Instantly kills enemies, doesnt work on nightmare mode.",
    Default = false,
    Callback = function(Value)
        Config.Fighting.InstantKill = Value
    end,
})

sections.Exploits:AddToggle("SkipBoss", {
    Title = "Skip Boss",
    Description = "Skips boss fights, boss fights take longer to instant kill.",
    Default = false,
    Callback = function(Value)
        Config.Fighting.SkipBoss = Value
    end,
})

sections.Killaura:AddToggle("AutoStartDungeon", {
	Title = "Auto Start Dungeon",
	Description = "Automatically starts the dungeon.",
	Default = false,
	Callback = function(Value)
		Config.Fighting.AutoStartDungeon = Value
	end,
})

sections.FarmDungeon:AddToggle("AutoDungeonToggle", {
    Title = "Auto Dungeon",
    Description = "Automatically enters dungeons.",
    Default = false,
    Callback = function(Value)
        Config.Dungeon.AutoDungeon = Value
    end,
})

sections.FarmSettings:AddToggle("SelectDungeonFromLevel", {
    Title = "Select Dungeon From Level",
    Description = "Automatically selects dungeon based on level.",
    Default = false,
    Callback = function(Value)
        Config.Dungeon.SelectDungeonFromLevel = Value
    end,
})

sections.FarmSettings:AddToggle("SelectDifficultyFromLevel", {
    Title = "Select Difficulty From Level",
    Description = "Automatically selects difficulty based on level.",
    Default = false,
    Callback = function(Value)
        Config.Dungeon.SelectDifficultyFromLevel = Value
    end,
})

sections.FarmSettings:AddParagraph({Title = "Usage", Description = "This won't select nightmare, so it works with instant kill."})

sections.FarmDungeon:AddDropdown("DungeonSelector", {
    Title = "Auto Dungeon",
    Description = "",
    Options = Config.Dungeon.Dungeons,
    Default = Config.Dungeon.SelectedDungeon,
    PlaceHolder = "Select Dungeon",
    Multiple = false,
    Callback = function(Value)
        Config.Dungeon.SelectedDungeon = Value
    end,
})

sections.FarmDungeon:AddDropdown("DungeonDifficulty", {
    Title = "Dungeon Difficulty",
    Description = "",
    Options = {"Normal", "Hard", "Nightmare"},
    Default = Config.Dungeon.Difficulty,
    PlaceHolder = "Select Difficulty",
    Multiple = false,
    Callback = function(Value)
        Config.Dungeon.Difficulty = Value
    end,
})

sections.Character:AddToggle("AutoReawaken", {
    Title = "Auto Reawaken",
    Description = "Automatically reawakens.",
    Default = false,
    Callback = function(Value)
        Config.Items.AutoReawaken = Value
    end,
})

sections.PremiumFeatures:AddToggle("AutomaticEverything", {
    Title = "Automatic Leveling",
    Description = "Automatically does everything, should be used with config/autoload.\nDisable, auto position, auto hit, auto re-awaken, autostart dungeon, auto level/difficulty\nThis feature does it all for you automatically.",
    Default = false,
    Callback = function(Value)
        Config.Premium.AutomaticEverything = Value
    end,
})

-- stats
sections.Stats:AddToggle("AutoStats", {
    Title = "Auto Stats",
    Description = "Automatically assigns stats.",
    Default = false,
    Callback = function(Value)
        Config.Items.AutoStats = Value
    end,
})

sections.Stats:AddDropdown("Priority", {
    Title = "Priority",
    Description = "Select the stat to prioritize.",
    Options = {"Strength", "Agility", "Perception", "Vitality", "Intellect"},
    Default = Config.Items.Priority,
    PlaceHolder = "Select Stat",
    Multiple = false,
    Callback = function(Value)
        Config.Items.Priority = Value
    end,
})

sections.Stats:AddSlider("Strength", {
    Title = "Strength",
    Description = "",
    Default = Config.Items.Strength,
    Min = 0,
    Max = 750,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        Config.Items.Strength = Value
    end,
})

sections.Stats:AddSlider("Agility", {
    Title = "Agility",
    Description = "",
    Default = Config.Items.Agility,
    Min = 0,
    Max = 750,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        Config.Items.Agility = Value
    end,
})

sections.Stats:AddSlider("Perception", {
    Title = "Perception",
    Description = "",
    Default = Config.Items.Perception,
    Min = 0,
    Max = 750,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        Config.Items.Perception = Value
    end,
})

sections.Stats:AddSlider("Vitality", {
    Title = "Vitality",
    Description = "",
    Default = Config.Items.Vitality,
    Min = 0,
    Max = 750,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        Config.Items.Vitality = Value
    end,
})

sections.Stats:AddSlider("Intellect", {
    Title = "Intellect",
    Description = "",
    Default = Config.Items.Intellect,
    Min = 0,
    Max = 750,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        Config.Items.Intellect = Value
    end,
})


-- anti softlock
sections.Exploits:AddSlider("SoftLockLimit", {
    Title = "Time before leaving",
    Description = "The amount of time before the script makes a new dungeon, to prevent softlock.",
    Default = Config.Fighting.SoftLockLimit,
    Min = 0,
    Max = 200,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        Config.Fighting.SoftLockLimit = Value
    end,
})

local globals =
{
    IsInLobby = function(self)
        local success, result = pcall(function()
            return workspace:FindFirstChild("Map") and 
                   workspace.Map:FindFirstChild("Lobby") and
                   workspace.Map.Lobby:FindFirstChild("Invisible Barrier Floor Lobby")
        end)
        
        if (success and result) then
            return true
        end
        
        local finishedSuccess, finishedResult = pcall(function()
            local player = game:GetService("Players").LocalPlayer
            if not player or not player.PlayerGui then return false end
            
            for _, gui in pairs(player.PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") then
                    local dungeonEnd = gui:FindFirstChild("DungeonEnd")
                    if dungeonEnd then
                        local status = dungeonEnd:FindFirstChild("Status")
                        if status then
                            local victory = status:FindFirstChild("Victory")
                            if victory and victory.Visible then
                                return true
                            end
                        end
                    end
                end
            end
            return false
        end)
        
        if (finishedSuccess and finishedResult) then
            return true
        end
        
        return false
    end,
}

local FeatureUtils = {
    MobCache = {
        ActiveMob = nil,
    },
    
    RetrieveTargets = function(self)
        local success, result = pcall(function()
            local mobContainer = workspace:FindFirstChild("Mobs")
            if not (mobContainer) then
                return {}
            end
           
            local mobs = mobContainer:GetChildren()
            local validMobs = {}
           
            for i, mob in ipairs(mobs) do
                if mob and mob:IsA("Model") then
                    local hrp = mob:FindFirstChild("HumanoidRootPart")
                    if (hrp) then
                        table.insert(validMobs, {Model = mob, HRP = hrp, Index = i})
                    end
                end
            end
           
            return validMobs
        end)
        
        if not success then
            return {}
        end
        
        return result or {}
    end,
    
    IsValidMob = function(self, mob)
        if not (mob) then
            return false
        end
        
        if not (mob.Parent) then
            return false
        end
        
        if not (mob:FindFirstChild("HumanoidRootPart")) then
            return false
        end
        
        return true
    end,

    isboss = function(self)
        local targets = self:RetrieveTargets()
        if (#targets == 0) then return false end

        for i, v in ipairs(targets) do
            local humanoid = v.Model:FindFirstChild("Humanoid")
            if (humanoid) then
                if (humanoid.DisplayName == "Monolith") then
                    return true
                elseif (humanoid.DisplayName == "Gorruk") then
                    return true
                elseif (humanoid.DisplayName == "Zyreth") then
                    return true
                end
            end
        end

        return false
    end,

    bosscache =
    {
        lastkilltimestamp = nil,
        forcenewdungeon = false,
    }, 

    instantkill = function(self)
        local success, result = pcall(function()
            self.isRunning = true
            
            local targets = self:RetrieveTargets()
            
            local lcl = game:GetService("Players").LocalPlayer
            if not (lcl) then return end
            
            if not (lcl.Character) then return end
            
            local humanoid = lcl.Character:FindFirstChildOfClass("Humanoid")
            if not (humanoid) then return end
            
            local lclplatform = humanoid.PlatformStand
    
            if not (Config.Fighting.InstantKill) then
                lclplatform = false
                return
            end
    
            local hrp = lcl.Character:FindFirstChild("HumanoidRootPart")
            if not (hrp) then return end
    
            if (Config.InitializeCFrame == nil) then
                Config.InitializeCFrame = hrp.CFrame
            end
    
            if (not globals:IsInLobby()) then
                lclplatform = true
                hrp.Velocity = Vector3.zero
                hrp.CFrame = Config.InitializeCFrame + Vector3.new(0, 25, 0)
            end
    
            if (#targets == 0) then
                return
            end
    
            if (self.bosscache.lastkilltimestamp) then
                local timeDiff = os.time() - self.bosscache.lastkilltimestamp
                if (timeDiff >= Config.Fighting.SoftLockLimit) then
                    self.bosscache.forcenewdungeon = true
                end
            end
    
            for i, v in ipairs(targets) do
                if v and v.Model then
                    local mobHumanoid = v.Model:FindFirstChild("Humanoid")
                    if (mobHumanoid) then
                        local isBoss = false
                        pcall(function() isBoss = self:isboss() end)
                        
                        if (Config.Fighting.SkipBoss and isBoss) then
                            self.bosscache.forcenewdungeon = true
                            return
                        end
    
                        if (mobHumanoid.Health > 0) then
                            self.bosscache.lastkilltimestamp = os.time()
                            mobHumanoid.Health = 0
                        end
                    end
                end
            end
        end)
        
        self.isRunning = false
    end,
    
    AttackMob = function(self)
        local validMobs = self:RetrieveTargets()

        if (Config.Fighting.InstantKill and not self:isboss()) then
            return
        end
       
        local character = game:GetService("Players").LocalPlayer.Character
        local humanoid = character:FindFirstChildOfClass("Humanoid")

        if (#validMobs == 0) then
            self.MobCache.ActiveMob = nil
            humanoid.PlatformStand = true
            return
        end
        
        if (self.MobCache.ActiveMob and not self:IsValidMob(self.MobCache.ActiveMob)) then
            self.MobCache.ActiveMob = nil
        end
       
        local targetMob = validMobs[1]
        
        self.MobCache.ActiveMob = targetMob.Model
       
        local player = game:GetService("Players").LocalPlayer
        if not (player) then return end
       
        local character = player.Character
        if not (character) then return end
       
        local root = character:FindFirstChild("HumanoidRootPart")
        if not (root) then return end
       
        local targetHRP = targetMob.HRP
        local targetPosition = targetHRP.Position
       
        local teleportPosition = Vector3.new(targetPosition.X, targetPosition.Y + 10, targetPosition.Z)
        if (humanoid) then
            humanoid.PlatformStand = true
        end
        root.Velocity = Vector3.zero
        root.CFrame = CFrame.new(teleportPosition, targetPosition)

    end,
}

local Features =
{
    Fighting =
    {
        AutoHit = function(self)
            if (Config.Fighting.InstantKill and not FeatureUtils:isboss()) then
                return
            end

            task.wait(1)
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Combat"):FireServer()
        end,

        AutoStartDungeon = function(self)
            local success, path = pcall(function()
                local player = game:GetService("Players").LocalPlayer
                if not player or not player.PlayerGui then return nil end
                
                for _, gui in pairs(player.PlayerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") then
                        local startDungeon = gui:FindFirstChild("StartDungeon")
                        if startDungeon then
                            local innerStartDungeon = startDungeon:FindFirstChild("StartDungeon")
                            if innerStartDungeon then
                                return innerStartDungeon:FindFirstChild("ImageLabel")
                            end
                        end
                    end
                end
                return nil
            end)
            
            if not success or not path or not path.Visible then return end
            
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DungeonStart"):FireServer()
        end,

        AutoCache = {
            Enabled = false,
            PreviousState = false,

            LoggedStates = {
                Instantkill = nil,
                AutoStartDungeon = nil,
                AutoDungeon = nil,
                SelectDungeonFromLevel = nil,
                SelectDifficultyFromLevel = nil,
                AutoReawaken = nil,
                Restored = false,
            },

        },

        AutoEverything = function(self)
            -- premium check
            --if not (LRM_ScriptName == "Lunor-Hunters-Premium") then return end

            if (Config.Premium.AutomaticEverything) then
                Config.Fighting.InstantKill = true
                Config.Fighting.AutoStartDungeon = true
                Config.Dungeon.AutoDungeon = true
                Config.Dungeon.SelectDungeonFromLevel = true
                Config.Dungeon.SelectDifficultyFromLevel = true
                Config.Items.AutoReawaken = true
                self.AutoCache.LoggedStates.Restored = true
            end
        end,
    },

    Dungeons =
    {
        CreateDungeon = function(self)
            if not (FeatureUtils.bosscache.forcenewdungeon) then
                if (not globals:IsInLobby()) then
                    return
                end
            end

            local selecteddungeon = Config.Dungeon.SelectedDungeon
            local passed_arg = nil
            if (selecteddungeon == "Singularity") then
                passed_arg = "DoubleDungeonD"
            elseif (selecteddungeon == "Goblin Caves") then
                passed_arg = "GoblinCave"
            elseif (selecteddungeon == "Spider Cavern") then
                passed_arg = "SpiderCavern"
            else
                return
            end
            if (Config.Dungeon.SelectDungeonFromLevel) then
                local level = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.ButtomAlign.Level.Text
                level = string.gsub(level, "LEVEL ", "")
                level = tonumber(level)
               
                if (level >= 1 and level <= 19) then
                    passed_arg = "DoubleDungeonD"
                elseif (level >= 20 and level <= 39) then
                    passed_arg = "GoblinCave"
                elseif (level >= 40 and level <= 1000) then
                    passed_arg = "SpiderCavern"
                else
                    return
                end
            end
            local args = {
                [1] = passed_arg
            }
               
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("createLobby"):InvokeServer(unpack(args))            
            local difficulty = Config.Dungeon.Difficulty
            if (Config.Dungeon.SelectDifficultyFromLevel) then
                local level = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.ButtomAlign.Level.Text
                level = string.gsub(level, "LEVEL ", "")
                level = tonumber(level)
               
                if (passed_arg == "DoubleDungeonD") then
                    if (level >= 1 and level <= 5) then
                        difficulty = "Normal"
                    elseif (level >= 6 and level <= 14) then
                        difficulty = "Hard"
                    elseif (level >= 15) then
                        if (Config.Fighting.InstantKill) then
                            difficulty = "Hard"
                        else
                            difficulty = "Nightmare"
                        end
                    end
                end  

                if (passed_arg == "GoblinCave") then
                    if (level >= 20 and level <= 24) then
                        difficulty = "Normal"
                    elseif (level >= 25 and level <= 34) then
                        difficulty = "Hard"
                    elseif (level >= 35) then
                        if (Config.Fighting.InstantKill) then
                            difficulty = "Hard"
                        else
                            difficulty = "Nightmare"
                        end
                    end
                end
            end

            if (Config.Dungeon.SelectDifficultyFromLevel) then
                local level = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.ButtomAlign.Level.Text
                level = string.gsub(level, "LEVEL ", "")
                level = tonumber(level)
               
                if (passed_arg == "SpiderCavern") then
                    if (level >= 40 and level <= 44) then
                        difficulty = "Normal"
                    elseif (level >= 45 and level <= 54) then
                        difficulty = "Hard"
                    elseif (level >= 55) then
                        if (Config.Fighting.InstantKill) then
                            difficulty = "Hard"
                        else
                            difficulty = "Nightmare"
                        end
                    end
                end
            end

            local args = {
                [1] = difficulty
            }
           
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("LobbyDifficulty"):FireServer(unpack(args))
        end,

        StartDungeon = function(self)
            local currentTime = os.time()
            if currentTime - teleportCooldown.lastTeleportAttempt < teleportCooldown.cooldownPeriod then
                return
            end
            
            teleportCooldown.lastTeleportAttempt = currentTime
            
            self:CreateDungeon()
            game:GetService("ReplicatedStorage").Remotes.LobbyStart:FireServer()
            
            if (getgenv().AllowQueueOnTeleport ~= false) then
                local queue = queue_on_teleport or queueonteleport
                if (queue) then
                    local key = script_key or ""
                    local queueCode = [[
                        if getgenv().sessionInitialized == nil then
                            getgenv().sessionInitialized = true
                            print("TEST: New session initialized")
                        end
                        
                        if not game:IsLoaded() then
                            game.Loaded:Wait()
                        end
                        
                        getgenv().dungeon = true
                        script_key = "]] .. key .. [["
                    ]]
                    
                 --   if LRM_ScriptName == "Lunor-Hunters-Premium" then
                 --       queue(queueCode .. game:HttpGet("https://raw.githubusercontent.com/Catto-YFCN/Lunor_Dependencies/refs/heads/main/Premium-Loader"))
                 --   else
                  --      queue(queueCode .. "loadstring(game:HttpGet('https://raw.githubusercontent.com/Catto-YFCN/Lunor_Dependencies/refs/heads/main/Games'))()")

                        
                        queue(loadstring(game:HttpGet("https://raw.githubusercontent.com/quadshoota/RBLX/refs/heads/main/UILIB.lua"))())
                    --end
                end
            end
        end,
    },

    Items =
    {
        AutomaticRoll = function(self)
            task.wait(1.5)
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Roll"):InvokeServer()
        end,

        AutoReawaken = function(self)
            -- @todo, check if we can, re-awaken, currently just fire remote every 10 seconds.
            task.wait(10)
            local success, result = pcall(function()
                return game:GetService("ReplicatedStorage").Remotes.Reawaken:InvokeServer()
            end)

            if (not success) then return end
        end,

        AutoStats = function(self)
            if (not Config.Items.AutoStats) then
                return
            end
            
            local statsGui
            local success, result = pcall(function()
                for _, gui in pairs(game:GetService("Players").LocalPlayer.PlayerGui:GetChildren()) do
                    if (gui:FindFirstChild("EzUISpringsSurfaceGui")) then
                        local centerAlign = gui.EzUISpringsSurfaceGui:FindFirstChild("CenterAlign")
                        if (centerAlign and centerAlign:FindFirstChild("Stats")) then
                            local imageLabel = centerAlign.Stats:FindFirstChild("ImageLabel")
                            if (imageLabel and imageLabel:FindFirstChild("StatsFrame")) then
                                local statsFrame = imageLabel.StatsFrame
                                if (statsFrame:FindFirstChild("STR") and statsFrame:FindFirstChild("Points")) then
                                    return statsFrame
                                end
                            end
                        end
                    end
                end
                return nil
            end)
            
            if (not success or not result) then
                return
            end
            
            statsGui = result
            
            local availablePoints = tonumber(statsGui.Points.ContentText) or 0
            
            if (availablePoints <= 0) then
                return
            end
            
            local currentStats = {
                Strength = tonumber(statsGui.STR.ContentText) or 0,
                Agility = tonumber(statsGui.AGI.ContentText) or 0,
                Perception = tonumber(statsGui.PER.ContentText) or 0,
                Vitality = tonumber(statsGui.VIT.ContentText) or 0,
                Intellect = tonumber(statsGui.INT.ContentText) or 0
            }
            
            local targetStats = {
                Strength = Config.Items.Strength,
                Agility = Config.Items.Agility,
                Perception = Config.Items.Perception,
                Vitality = Config.Items.Vitality,
                Intellect = Config.Items.Intellect
            }
            
            local statOrder = {"Strength", "Agility", "Perception", "Vitality", "Intellect"}
            
            if (Config.Items.Priority) then
                local priorityIndex = table.find(statOrder, Config.Items.Priority)
                if (priorityIndex) then
                    table.insert(statOrder, 1, table.remove(statOrder, priorityIndex))
                end
            end
            
            for _, stat in ipairs(statOrder) do
                if (currentStats[stat] < targetStats[stat]) then
                    local args = {
                        [1] = stat
                    }
                    
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("PointTo"):InvokeServer(unpack(args))
                    return
                end
            end
        end,
    },
}

game:GetService("RunService").RenderStepped:Connect(function()
    if (Config.Items.AutoReawaken) then
        Features.Items:AutoReawaken()
    end
    
    if (Config.Items.AutoRoll) then
        Features.Items:AutomaticRoll()
    end

    if (Config.Fighting.AutoHit) then
        Features.Fighting:AutoHit()
    end

    if (Config.Fighting.AutoPosition) then
        FeatureUtils:AttackMob()
    end

	if (Config.Fighting.AutoStartDungeon) then
		Features.Fighting:AutoStartDungeon()
	end

    if (Config.Dungeon.AutoDungeon) then
        Features.Dungeons:StartDungeon()
    end

    if (Config.Items.AutoStats) then
        Features.Items:AutoStats()
    end

    FeatureUtils:instantkill() -- checks in the function, vital for instant kill.
    Features.Fighting:AutoEverything()  -- checks in the function.
end)


-- Add config system
FlagsManager:SetLibrary(lib)
FlagsManager:SetIgnoreIndexes({})
FlagsManager:SetFolder("Lunor/Hunters")
FlagsManager:InitSaveSystem(tabs.Config)

local themes = tabs.Config:AddSection({Title = "Themes", Description = "if you want to create your own theme u can submit it to the official discord server", Defualt = true, Locked = true})
local CustomThemes = {}
local StoredThemes = loadstring(game:HttpGet("https://raw.githubusercontent.com/Just3itx/ESPFixed/refs/heads/main/themes"))()

for v,_ in pairs(StoredThemes) do
    table.insert(CustomThemes, v)
end

themes:AddDropdown("Themes", {
    Title = "Choose Theme",
    Description = "",
    Options = CustomThemes,
    Default = "default",
    PlaceHolder = "Select Theme",
    Multiple = false,
    Callback = function(Theme)
        lib:SetTheme(Theme)
    end,
})

function colorToHex(color)
    local r = math.floor(color.R * 255)
    local g = math.floor(color.G * 255)
    local b = math.floor(color.B * 255)
    return string.format("%02X%02X%02X", r, g, b)
end

sections.Gradient:AddColorpicker("GradientStart", {
    Title = "Gradient Starting Color",
    Default = Color3.new(1.000000, 0.854902, 0.019608),
    Callback = function(selectedColor)
        startingGradient = colorToHex(selectedColor)
    end,
})

sections.Gradient:AddColorpicker("GradientEnd", {
    Title = "Gradient Ending Color",
    Default = Color3.new(0.968627, 1.000000, 0.019608),
    Callback = function(selectedColor)
        endingGradient = colorToHex(selectedColor)
    end,
})

sections.Gradient:AddButton({
    Title = "Copy Gradient Config",
    Variant = "Outline",
    Callback = function()
        setclipboard('getgenv().GradientColor = {\n    startingColor = "' .. startingGradient .. '",\n    endingColor = "' .. endingGradient .. '"\n}\nscript_key="Insert Lunor Key Here";\nloadstring(game:HttpGet("https://raw.githubusercontent.com/Just3itx/Lunor-Loadstrings/refs/heads/main/Loader"))()')
        lib:Notification("Gradient", "Successfully copied gradient config to clipboard.", 5)
    end,
})

-- Load autoload config
FlagsManager:LoadAutoloadConfig()

local LocalPlayer = game.Players.LocalPlayer
for _, v in pairs(getconnections(LocalPlayer.Idled)) do
    v:Disable()
end
