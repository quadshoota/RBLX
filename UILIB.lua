--[[
    Celestial Interface Suite - Enhanced
    A beautiful, fluent UI library for Roblox experiences.
    
    Author: YourName
    License: MIT
    GitHub: https://github.com/yourusername/Celestial
--]]

-- LOCAL MODULE DEFINITIONS
local Celestial = {}
local Acrylic = {}
local Creator = {}
local Components = {}
local Elements = {}
local Themes = {Names = {"Dark", "Midnight", "Light", "Nebula", "Aurora", "Sunset"}}
local Flipper = {} -- Animation Engine

-- SERVICES
local LightingService = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local PlayersService = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local WorkspaceCamera = game:GetService("Workspace").CurrentCamera
local LocalPlayer = PlayersService.LocalPlayer
local PlayerMouse = LocalPlayer:GetMouse()

--//////////////////////////////////////////////////////////////////////////////////--
--                                   FLIPPER ENGINE                                 --
--//////////////////////////////////////////////////////////////////////////////////--

-- Animation Engine based on Flipper
do
    -- Signal implementation
    local Signal = {}
    Signal.__index = Signal

    function Signal.new()
        return setmetatable({_connections = {}, _threads = {}}, Signal)
    end

    function Signal:fire(...)
        for _, connection in pairs(self._connections) do
            connection._handler(...)
        end
        
        for _, thread in pairs(self._threads) do
            coroutine.resume(thread, ...)
        end
        
        self._threads = {}
    end

    function Signal:connect(callback)
        local connection = {
            signal = self, 
            connected = true, 
            _handler = callback
        }
        
        table.insert(self._connections, connection)
        
        function connection:disconnect()
            if self.connected then
                self.connected = false
                for i, conn in pairs(self.signal._connections) do
                    if conn == self then
                        table.remove(self.signal._connections, i)
                        return
                    end
                end
            end
        end
        
        return connection
    end

    function Signal:wait()
        table.insert(self._threads, coroutine.running())
        return coroutine.yield()
    end
    
    -- Base Motor class
    local BaseMotor = {}
    BaseMotor.__index = BaseMotor

    function BaseMotor.new()
        return setmetatable({
            _onStep = Signal.new(),
            _onStart = Signal.new(),
            _onComplete = Signal.new()
        }, BaseMotor)
    end

    function BaseMotor:onStep(callback)
        return self._onStep:connect(callback)
    end

    function BaseMotor:onStart(callback)
        return self._onStart:connect(callback)
    end

    function BaseMotor:onComplete(callback)
        return self._onComplete:connect(callback)
    end

    function BaseMotor:start()
        if not self._connection then
            self._connection = RunService.RenderStepped:Connect(function(deltaTime)
                self:step(deltaTime)
            end)
        end
    end

    function BaseMotor:stop()
        if self._connection then
            self._connection:Disconnect()
            self._connection = nil
        end
    end

    BaseMotor.destroy = BaseMotor.stop
    BaseMotor.step = function() end
    BaseMotor.getValue = function() end
    BaseMotor.setGoal = function() end

    function BaseMotor:__tostring()
        return "Motor"
    end

    -- Single Motor (animates a single value)
    local SingleMotor = setmetatable({}, BaseMotor)
    SingleMotor.__index = SingleMotor

    function SingleMotor.new(initialValue, useImplicitConnections)
        assert(initialValue, "Missing argument #1: initialValue")
        assert(typeof(initialValue) == "number", "initialValue must be a number!")
        
        local self = setmetatable(BaseMotor.new(), SingleMotor)
        
        self._useImplicitConnections = useImplicitConnections ~= nil and useImplicitConnections or true
        self._goal = nil
        self._state = {complete = true, value = initialValue}
        
        return self
    end

    function SingleMotor:step(deltaTime)
        if self._state.complete then
            return true
        end
        
        local newState = self._goal:step(self._state, deltaTime)
        self._state = newState
        self._onStep:fire(newState.value)
        
        if newState.complete then
            if self._useImplicitConnections then
                self:stop()
            end
            self._onComplete:fire()
        end
        
        return newState.complete
    end

    function SingleMotor:getValue()
        return self._state.value
    end

    function SingleMotor:setGoal(goal)
        self._state.complete = false
        self._goal = goal
        self._onStart:fire()
        
        if self._useImplicitConnections then
            self:start()
        end
    end

    function SingleMotor:__tostring()
        return "Motor(Single)"
    end

    -- Group Motor (animates multiple values)
    local GroupMotor = setmetatable({}, BaseMotor)
    GroupMotor.__index = GroupMotor
    
    -- Motor detection helper
    local isMotor = function(obj)
        local objType = tostring(obj):match("^Motor%((.+)%)$")
        if objType then
            return true, objType
        else
            return false
        end
    end
    
    -- Motor conversion helper
    local function createMotor(value)
        if isMotor(value) then
            return value
        end
        
        local valueType = typeof(value)
        if valueType == "number" then
            return SingleMotor.new(value, false)
        elseif valueType == "table" then
            return GroupMotor.new(value, false)
        end
        
        error(("Unable to convert %q to motor; type %s is unsupported"):format(value, valueType), 2)
    end

    function GroupMotor.new(initialValues, useImplicitConnections)
        assert(initialValues, "Missing argument #1: initialValues")
        assert(typeof(initialValues) == "table", "initialValues must be a table!")
        assert(not initialValues.step, [[initialValues contains disallowed property "step". Did you mean to put a table of values here?]])
        
        local self = setmetatable(BaseMotor.new(), GroupMotor)
        
        if useImplicitConnections ~= nil then
            self._useImplicitConnections = useImplicitConnections
        else
            self._useImplicitConnections = true
        end
        
        self._complete = true
        self._motors = {}
        
        for key, value in pairs(initialValues) do
            self._motors[key] = createMotor(value)
        end
        
        return self
    end

    function GroupMotor:step(deltaTime)
        if self._complete then
            return true
        end
        
        local allComplete = true
        for _, motor in pairs(self._motors) do
            local complete = motor:step(deltaTime)
            if not complete then
                allComplete = false
            end
        end
        
        self._onStep:fire(self:getValue())
        
        if allComplete then
            if self._useImplicitConnections then
                self:stop()
            end
            self._complete = true
            self._onComplete:fire()
        end
        
        return allComplete
    end

    function GroupMotor:setGoal(goals)
        assert(not goals.step, [[goals contains disallowed property "step". Did you mean to put a table of goals here?]])
        
        self._complete = false
        self._onStart:fire()
        
        for key, goal in pairs(goals) do
            local motor = assert(self._motors[key], ("Unknown motor for key %s"):format(key))
            motor:setGoal(goal)
        end
        
        if self._useImplicitConnections then
            self:start()
        end
    end

    function GroupMotor:getValue()
        local values = {}
        for key, motor in pairs(self._motors) do
            values[key] = motor:getValue()
        end
        return values
    end

    function GroupMotor:__tostring()
        return "Motor(Group)"
    end

    -- Spring goal
    local Spring = {}
    Spring.__index = Spring

    function Spring.new(targetValue, options)
        assert(targetValue, "Missing argument #1: targetValue")
        options = options or {}
        
        return setmetatable({
            _targetValue = targetValue,
            _frequency = options.frequency or 4,
            _dampingRatio = options.dampingRatio or 1
        }, Spring)
    end

    function Spring:step(state, deltaTime)
        -- Adapted spring physics implementation
        local d = self._dampingRatio
        local f = self._frequency * 2 * math.pi
        local g = self._targetValue
        local p = state.value
        local v = state.velocity or 0
        
        local offset = p - g
        local decay = math.exp(-d * f * deltaTime)
        
        local position, velocity
        
        if d == 1 then -- Critically damped
            position = (offset * (1 + f * deltaTime) + v * deltaTime) * decay + g
            velocity = (v * (1 - f * deltaTime) - offset * (f * f * deltaTime)) * decay
        elseif d < 1 then -- Underdamped
            local c = math.sqrt(1 - d * d)
            
            local i = math.cos(f * c * deltaTime)
            local j = math.sin(f * c * deltaTime)
            
            if c > 0.0001 then
                j = j / c
            else
                j = deltaTime * f
            end
            
            position = (offset * i + v * j) * decay + g
            velocity = (v * i - offset * j * f) * decay
        else -- Overdamped
            local c = math.sqrt(d * d - 1)
            
            local r1 = -f * (d - c)
            local r2 = -f * (d + c)
            
            local co2 = (v - offset * r1) / (2 * f * c)
            local co1 = offset - co2
            
            local e1 = co1 * math.exp(r1 * deltaTime)
            local e2 = co2 * math.exp(r2 * deltaTime)
            
            position = e1 + e2 + g
            velocity = e1 * r1 + e2 * r2
        end
        
        local complete = math.abs(velocity) < 0.001 and math.abs(position - g) < 0.001
        
        return {
            complete = complete,
            value = complete and g or position,
            velocity = velocity
        }
    end

    -- Instant goal (jumps to target immediately)
    local Instant = {}
    Instant.__index = Instant

    function Instant.new(targetValue)
        return setmetatable({_targetValue = targetValue}, Instant)
    end

    function Instant:step()
        return {
            complete = true,
            value = self._targetValue
        }
    end

    -- Linear goal (moves at constant velocity)
    local Linear = {}
    Linear.__index = Linear

    function Linear.new(targetValue, options)
        assert(targetValue, "Missing argument #1: targetValue")
        options = options or {}
        
        return setmetatable({
            _targetValue = targetValue,
            _velocity = options.velocity or 1
        }, Linear)
    end

    function Linear:step(state, deltaTime)
        local currentValue = state.value
        local velocity = self._velocity
        local deltaValue = deltaTime * velocity
        local targetValue = self._targetValue
        
        local reachedTarget = deltaValue >= math.abs(targetValue - currentValue)
        
        currentValue = currentValue + deltaValue * (targetValue > currentValue and 1 or -1)
        
        if reachedTarget then
            currentValue = self._targetValue
            velocity = 0
        end
        
        return {
            complete = reachedTarget,
            value = currentValue,
            velocity = velocity
        }
    end

    -- Export the Flipper library
    Flipper = {
        SingleMotor = SingleMotor,
        GroupMotor = GroupMotor,
        Spring = Spring,
        Instant = Instant,
        Linear = Linear,
        isMotor = isMotor
    }
end

--//////////////////////////////////////////////////////////////////////////////////--
--                                   CREATOR MODULE                                 --
--//////////////////////////////////////////////////////////////////////////////////--

do
    -- Registry for themed objects
    Creator.Registry = {}
    
    -- Signal connections for cleanup
    Creator.Signals = {}
    
    -- Motors for transparency animations
    Creator.TransparencyMotors = {}
    
    -- Default properties for common Instance types
    Creator.DefaultProperties = {
        ScreenGui = {
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        },
        Frame = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0
        },
        ScrollingFrame = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            ScrollBarImageColor3 = Color3.new(0, 0, 0)
        },
        TextLabel = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            Font = Enum.Font.GothamSemibold,
            Text = "",
            TextColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1,
            TextSize = 14
        },
        TextButton = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            AutoButtonColor = false,
            Font = Enum.Font.GothamSemibold,
            Text = "",
            TextColor3 = Color3.new(0, 0, 0),
            TextSize = 14
        },
        TextBox = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            ClearTextOnFocus = false,
            Font = Enum.Font.GothamSemibold,
            Text = "",
            TextColor3 = Color3.new(0, 0, 0),
            TextSize = 14
        },
        ImageLabel = {
            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0
        },
        ImageButton = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            AutoButtonColor = false
        },
        CanvasGroup = {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0
        }
    }

    -- Apply theme properties to an object
    local function applyThemeProperties(object, properties)
        if properties.ThemeTag then
            Creator.AddThemeObject(object, properties.ThemeTag)
        end
    end

    -- Add a signal connection to the registry for cleanup
    function Creator.AddSignal(signal, callback)
        table.insert(Creator.Signals, signal:Connect(callback))
    end

    -- Disconnect all registered signals
    function Creator.Disconnect()
        for i = #Creator.Signals, 1, -1 do
            local signal = table.remove(Creator.Signals, i)
            signal:Disconnect()
        end
    end

    -- Get a theme property value
    function Creator.GetThemeProperty(property)
        if Themes[Celestial.Theme][property] then
            return Themes[Celestial.Theme][property]
        end
        return Themes.Dark[property]
    end

    -- Update all themed objects
    function Creator.UpdateTheme()
        for object, data in next, Creator.Registry do
            for property, value in next, data.Properties do
                object[property] = Creator.GetThemeProperty(value)
            end
        end
        
        for _, motor in next, Creator.TransparencyMotors do
            motor:setGoal(Flipper.Instant.new(Creator.GetThemeProperty("ElementTransparency")))
        end
    end

    -- Register an object to be themed
    function Creator.AddThemeObject(object, properties)
        local index = #Creator.Registry + 1
        local data = {
            Object = object,
            Properties = properties,
            Idx = index
        }
        
        Creator.Registry[object] = data
        Creator.UpdateTheme()
        return object
    end

    -- Override theme properties on an object
    function Creator.OverrideTag(object, properties)
        Creator.Registry[object].Properties = properties
        Creator.UpdateTheme()
    end

    -- Create a new Instance with properties and children
    function Creator.New(className, properties, children)
        local instance = Instance.new(className)
        
        -- Apply default properties for the class
        for property, value in next, Creator.DefaultProperties[className] or {} do
            instance[property] = value
        end
        
        -- Apply custom properties
        for property, value in next, properties or {} do
            if property ~= "ThemeTag" then
                instance[property] = value
            end
        end
        
        -- Add children
        for _, child in next, children or {} do
            child.Parent = instance
        end
        
        applyThemeProperties(instance, properties or {})
        return instance
    end

    -- Create a spring-driven animation motor for properties
    function Creator.SpringMotor(initialValue, object, property, skipThemeUpdates, isTransparency)
        skipThemeUpdates = skipThemeUpdates or false
        isTransparency = isTransparency or false
        
        local motor = Flipper.SingleMotor.new(initialValue)
        
        motor:onStep(function(value)
            object[property] = value
        end)
        
        if isTransparency then
            table.insert(Creator.TransparencyMotors, motor)
        end
        
        local setGoal = function(goal, ignoreCheck)
            ignoreCheck = ignoreCheck or false
            
            if not skipThemeUpdates then
                if not ignoreCheck then
                    if property == "BackgroundTransparency" and Celestial.DialogOpen then
                        return
                    end
                end
            end
            
            motor:setGoal(Flipper.Spring.new(goal, {frequency = 8}))
        end
        
        return motor, setGoal
    end
end

--//////////////////////////////////////////////////////////////////////////////////--
--                                  ACRYLIC MODULE                                  --
--//////////////////////////////////////////////////////////////////////////////////--

do
    -- Utility functions
    local function mapRange(value, min1, max1, min2, max2)
        return (value - min1) * (max2 - min2) / (max1 - min1) + min2
    end

    local function screenToWorldPoint(screenPoint, depth)
        local ray = WorkspaceCamera:ScreenPointToRay(screenPoint.X, screenPoint.Y)
        return ray.Origin + ray.Direction * depth
    end

    local function getEffectPadding()
        local screenHeight = WorkspaceCamera.ViewportSize.Y
        return mapRange(screenHeight, 0, 2560, 10, 60)
    end

    local Utils = {
        screenToWorldPoint = screenToWorldPoint,
        getEffectPadding = getEffectPadding
    }

    -- CreateAcrylic - Create a physical part for acrylic effect
    local CreateAcrylic = function()
        local part = Creator.New("Part", {
            Name = "Body",
            Color = Color3.new(0, 0, 0),
            Material = Enum.Material.Glass,
            Size = Vector3.new(1, 1, 0),
            Anchored = true,
            CanCollide = false,
            Locked = true,
            CastShadow = false,
            Transparency = 0.96
        }, {
            Creator.New("SpecialMesh", {
                MeshType = Enum.MeshType.Brick,
                Offset = Vector3.new(0, 0, -1E-6)
            })
        })
        
        return part
    end

    -- AcrylicBlur - Create blur effect for acrylic surfaces
    local AcrylicBlur = function(offset)
        local interface = {}
        offset = offset or 0.001
        
        local vectors = {
            topLeft = Vector2.new(),
            topRight = Vector2.new(), 
            bottomRight = Vector2.new()
        }
        
        local model = CreateAcrylic()
        model.Parent = workspace
        
        -- Update position vectors for the acrylic surface
        local function updatePositionVectors(size, position)
            vectors.topLeft = position
            vectors.topRight = position + Vector2.new(size.X, 0)
            vectors.bottomRight = position + size
        end
        
        -- Update the model based on current camera and vectors
        local function updateModel()
            local camera = WorkspaceCamera
            local cameraTransform = camera and camera.CFrame or CFrame.new()
            
            local v1, v2, v3 = Utils.screenToWorldPoint(vectors.topLeft, offset),
                              Utils.screenToWorldPoint(vectors.topRight, offset),
                              Utils.screenToWorldPoint(vectors.bottomRight, offset)
                              
            local width, height = (v2 - v1).Magnitude, (v2 - v3).Magnitude
            
            model.CFrame = CFrame.fromMatrix((v1 + v3)/2, cameraTransform.XVector, cameraTransform.YVector, cameraTransform.ZVector)
            model.Mesh.Scale = Vector3.new(width, height, 0)
        end
        
        -- Setup update triggers based on UI element
        local function setupForElement(element)
            local padding = Utils.getEffectPadding()
            local size, pos = element.AbsoluteSize - Vector2.new(padding, padding), 
                             element.AbsolutePosition + Vector2.new(padding/2, padding/2)
            
            updatePositionVectors(size, pos)
            task.spawn(updateModel)
        end
        
        -- Connect camera property changes to update the effect
        local connections = {}
        local function connectCamera()
            local camera = WorkspaceCamera
            if not camera then return end
            
            table.insert(connections, camera:GetPropertyChangedSignal("CFrame"):Connect(updateModel))
            table.insert(connections, camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateModel))
            table.insert(connections, camera:GetPropertyChangedSignal("FieldOfView"):Connect(updateModel))
            
            task.spawn(updateModel)
        end
        
        -- Clean up connections when model is destroyed
        model.Destroying:Connect(function()
            for _, connection in connections do
                pcall(function() connection:Disconnect() end)
            end
        end)
        
        connectCamera()
        
        return setupForElement, model
    end

    -- AcrylicPaint - Create the visual frame for acrylic effects
    local AcrylicPaint = function()
        local interface = {}
        
        -- Create the visual frame for the acrylic paint effect
        interface.Frame = Creator.New("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 0.9,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0
        }, {
            -- Noise texture
            Creator.New("ImageLabel", {
                Image = "rbxassetid://8992230677",
                ScaleType = "Slice",
                SliceCenter = Rect.new(Vector2.new(99, 99), Vector2.new(99, 99)),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(1, 120, 1, 116),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundTransparency = 1,
                ImageColor3 = Color3.fromRGB(0, 0, 0),
                ImageTransparency = 0.7
            }),
            
            -- Corner rounding
            Creator.New("UICorner", {
                CornerRadius = UDim.new(0, 12)
            }),
            
            -- Background layer
            Creator.New("Frame", {
                BackgroundTransparency = 0.35,
                Size = UDim2.fromScale(1, 1),
                Name = "Background",
                ThemeTag = {BackgroundColor3 = "AcrylicMain"}
            }, {
                Creator.New("UICorner", {
                    CornerRadius = UDim.new(0, 12)
                })
            }),
            
            -- Gradient overlay
            Creator.New("Frame", {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0.4,
                Size = UDim2.fromScale(1, 1)
            }, {
                Creator.New("UICorner", {
                    CornerRadius = UDim.new(0, 12)
                }),
                Creator.New("UIGradient", {
                    Rotation = 90,
                    ThemeTag = {Color = "AcrylicGradient"}
                })
            }),
            
            -- Noise texture layers
            Creator.New("ImageLabel", {
                Image = "rbxassetid://9968344105",
                ImageTransparency = 0.96,
                ScaleType = Enum.ScaleType.Tile,
                TileSize = UDim2.new(0, 128, 0, 128),
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1
            }, {
                Creator.New("UICorner", {
                    CornerRadius = UDim.new(0, 12)
                })
            }),
            
            Creator.New("ImageLabel", {
                Image = "rbxassetid://9968344227",
                ImageTransparency = 0.88,
                ScaleType = Enum.ScaleType.Tile,
                TileSize = UDim2.new(0, 128, 0, 128),
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                ThemeTag = {ImageTransparency = "AcrylicNoise"}
            }, {
                Creator.New("UICorner", {
                    CornerRadius = UDim.new(0, 12)
                })
            }),
            
            -- Subtle inner shadow
            Creator.New("ImageLabel", {
                Image = "rbxassetid://9969931088", -- Inner shadow image
                ImageTransparency = 0.75,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(Vector2.new(512, 512), Vector2.new(512, 512)),
                SliceScale = 0.05,
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1
            }, {
                Creator.New("UICorner", {
                    CornerRadius = UDim.new(0, 12)
                })
            }),
            
            -- Border with gloss effect
            Creator.New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 2
            }, {
                Creator.New("UICorner", {
                    CornerRadius = UDim.new(0, 12)
                }),
                Creator.New("UIStroke", {
                    Transparency = 0.45,
                    Thickness = 1.5,
                    ThemeTag = {Color = "AcrylicBorder"}
                })
            }),
            
            -- Subtle highlight at the top
            Creator.New("Frame", {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0.85,
                Size = UDim2.new(1, -4, 0, 1),
                Position = UDim2.new(0, 2, 0, 1),
                ZIndex = 3
            })
        })
        
        -- Add blur effect if acrylic is enabled
        local effectInstance
        if Celestial.UseAcrylic then
            local setupBlur, model = AcrylicBlur()
            effectInstance = {
                Frame = Creator.New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1)
                }),
                Model = model
            }
            
            -- Connect position and size changes to update blur
            Creator.AddSignal(effectInstance.Frame:GetPropertyChangedSignal("AbsolutePosition"), function()
                setupBlur(effectInstance.Frame)
            end)
            
            Creator.AddSignal(effectInstance.Frame:GetPropertyChangedSignal("AbsoluteSize"), function()
                setupBlur(effectInstance.Frame)
            end)
            
            -- Add parent element to update visibility based on parent
            effectInstance.AddParent = function(parent)
                Creator.AddSignal(parent:GetPropertyChangedSignal("Visible"), function()
                    effectInstance.SetVisibility(parent.Visible)
                end)
            end
            
            -- Set visibility of the acrylic effect
            effectInstance.SetVisibility = function(visible)
                model.Transparency = visible and 0.96 or 1
            end
            
            effectInstance.Frame.Parent = interface.Frame
            interface.Model = effectInstance.Model
            interface.AddParent = effectInstance.AddParent
            interface.SetVisibility = effectInstance.SetVisibility
        end
        
        return interface
    end

    -- Initialize acrylic effects
    function Acrylic.init()
        local depthEffect = Instance.new("DepthOfFieldEffect")
        depthEffect.FarIntensity = 0
        depthEffect.InFocusRadius = 0.1
        depthEffect.NearIntensity = 1
        
        local blurEffect = Instance.new("BlurEffect")
        blurEffect.Size = 3
        
        local bloomEffect = Instance.new("BloomEffect")
        bloomEffect.Intensity = 0.3
        bloomEffect.Size = 12
        bloomEffect.Threshold = 0.8
        
        local savedEffects = {}
        
        -- Enable acrylic effect by disabling other depth effects
        function Acrylic.Enable()
            for _, effect in pairs(savedEffects) do
                effect.Enabled = false
            end
            depthEffect.Parent = LightingService
            blurEffect.Parent = LightingService
            bloomEffect.Parent = LightingService
        end
        
        -- Disable acrylic effect and restore original depth effects
        function Acrylic.Disable()
            for _, effect in pairs(savedEffects) do
                effect.Enabled = effect.enabled
            end
            depthEffect.Parent = nil
            blurEffect.Parent = nil
            bloomEffect.Parent = nil
        end
        
        -- Save state of existing depth effects
        local function saveExistingEffects()
            local function checkEffect(effect)
                if effect:IsA("DepthOfFieldEffect") or effect:IsA("BlurEffect") or effect:IsA("BloomEffect") then
                    savedEffects[effect] = {enabled = effect.Enabled}
                end
            end
            
            for _, child in pairs(LightingService:GetChildren()) do
                checkEffect(child)
            end
            
            if WorkspaceCamera then
                for _, child in pairs(WorkspaceCamera:GetChildren()) do
                    checkEffect(child)
                end
            end
        end
        
        saveExistingEffects()
        Acrylic.Enable()
    end

    -- Export Acrylic components
    Acrylic.AcrylicBlur = AcrylicBlur
    Acrylic.CreateAcrylic = CreateAcrylic
    Acrylic.AcrylicPaint = AcrylicPaint
end

--//////////////////////////////////////////////////////////////////////////////////--
--                                 THEMES DEFINITIONS                               --
--//////////////////////////////////////////////////////////////////////////////////--

do
    -- Dark Theme - Enhanced with deeper colors and better contrast
    Themes.Dark = {
        Name = "Dark",
        Accent = Color3.fromRGB(86, 180, 255),
        AcrylicMain = Color3.fromRGB(30, 32, 36),
        AcrylicBorder = Color3.fromRGB(80, 85, 90),
        AcrylicGradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 45, 50)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 22, 24))
        }),
        AcrylicNoise = 0.92,
        TitleBarLine = Color3.fromRGB(65, 70, 75),
        Tab = Color3.fromRGB(110, 115, 120),
        Element = Color3.fromRGB(50, 55, 60),
        ElementBorder = Color3.fromRGB(35, 40, 45),
        InElementBorder = Color3.fromRGB(70, 75, 80),
        ElementTransparency = 0.83,
        ToggleSlider = Color3.fromRGB(110, 115, 120),
        ToggleToggled = Color3.fromRGB(0, 0, 0),
        SliderRail = Color3.fromRGB(110, 115, 120),
        DropdownFrame = Color3.fromRGB(160, 165, 170),
        DropdownHolder = Color3.fromRGB(40, 45, 50),
        DropdownBorder = Color3.fromRGB(35, 40, 45),
        DropdownOption = Color3.fromRGB(110, 115, 120),
        Keybind = Color3.fromRGB(110, 115, 120),
        Input = Color3.fromRGB(160, 165, 170),
        InputFocused = Color3.fromRGB(10, 12, 14),
        InputIndicator = Color3.fromRGB(130, 135, 140),
        Dialog = Color3.fromRGB(35, 40, 45),
        DialogHolder = Color3.fromRGB(25, 30, 35),
        DialogHolderLine = Color3.fromRGB(20, 25, 30),
        DialogButton = Color3.fromRGB(35, 40, 45),
        DialogButtonBorder = Color3.fromRGB(70, 75, 80),
        DialogBorder = Color3.fromRGB(60, 65, 70),
        DialogInput = Color3.fromRGB(45, 50, 55),
        DialogInputLine = Color3.fromRGB(150, 155, 160),
        Text = Color3.fromRGB(235, 235, 235),
        SubText = Color3.fromRGB(170, 170, 170),
        Hover = Color3.fromRGB(50, 55, 60),
        HoverChange = 0.08
    }

    -- Midnight Theme - Darker with blue accents
    Themes.Midnight = {
        Name = "Midnight",
        Accent = Color3.fromRGB(72, 138, 182),
        AcrylicMain = Color3.fromRGB(15, 18, 24),
        AcrylicBorder = Color3.fromRGB(60, 70, 80),
        AcrylicGradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 30, 40)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 12, 18))
        }),
        AcrylicNoise = 0.94,
        TitleBarLine = Color3.fromRGB(50, 60, 70),
        Tab = Color3.fromRGB(90, 100, 110),
        Element = Color3.fromRGB(35, 40, 50),
        ElementBorder = Color3.fromRGB(20, 25, 30),
        InElementBorder = Color3.fromRGB(50, 55, 65),
        ElementTransparency = 0.80,
        DropdownFrame = Color3.fromRGB(100, 110, 120),
        DropdownHolder = Color3.fromRGB(25, 30, 40),
        DropdownBorder = Color3.fromRGB(20, 25, 35),
        Dialog = Color3.fromRGB(25, 30, 40),
        DialogHolder = Color3.fromRGB(15, 20, 25),
        DialogHolderLine = Color3.fromRGB(10, 15, 20),
        DialogButton = Color3.fromRGB(25, 30, 40),
        DialogButtonBorder = Color3.fromRGB(45, 50, 60),
        DialogBorder = Color3.fromRGB(40, 45, 55),
        DialogInput = Color3.fromRGB(35, 40, 50),
        DialogInputLine = Color3.fromRGB(100, 110, 120),
        Text = Color3.fromRGB(235, 240, 245),
        SubText = Color3.fromRGB(160, 170, 180),
        Hover = Color3.fromRGB(40, 45, 55),
        HoverChange = 0.07
    }

    -- Light Theme - Clean, modern with soft shadows
    Themes.Light = {
        Name = "Light",
        Accent = Color3.fromRGB(0, 120, 215),
        AcrylicMain = Color3.fromRGB(245, 245, 245),
        AcrylicBorder = Color3.fromRGB(200, 200, 200),
        AcrylicGradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(245, 245, 245))
        }),
        AcrylicNoise = 0.97,
        TitleBarLine = Color3.fromRGB(210, 210, 210),
        Tab = Color3.fromRGB(90, 90, 90),
        Element = Color3.fromRGB(255, 255, 255),
        ElementBorder = Color3.fromRGB(200, 200, 200),
        InElementBorder = Color3.fromRGB(180, 180, 180),
        ElementTransparency = 0.60,
        ToggleSlider = Color3.fromRGB(60, 60, 60),
        ToggleToggled = Color3.fromRGB(255, 255, 255),
        SliderRail = Color3.fromRGB(60, 60, 60),
        DropdownFrame = Color3.fromRGB(230, 230, 230),
        DropdownHolder = Color3.fromRGB(255, 255, 255),
        DropdownBorder = Color3.fromRGB(210, 210, 210),
        DropdownOption = Color3.fromRGB(150, 150, 150),
        Keybind = Color3.fromRGB(150, 150, 150),
        Input = Color3.fromRGB(230, 230, 230),
        InputFocused = Color3.fromRGB(180, 180, 180),
        InputIndicator = Color3.fromRGB(80, 80, 80),
        Dialog = Color3.fromRGB(255, 255, 255),
        DialogHolder = Color3.fromRGB(245, 245, 245),
        DialogHolderLine = Color3.fromRGB(235, 235, 235),
        DialogButton = Color3.fromRGB(255, 255, 255),
        DialogButtonBorder = Color3.fromRGB(220, 220, 220),
        DialogBorder = Color3.fromRGB(190, 190, 190),
        DialogInput = Color3.fromRGB(250, 250, 250),
        DialogInputLine = Color3.fromRGB(180, 180, 180),
        Text = Color3.fromRGB(20, 20, 20),
        SubText = Color3.fromRGB(80, 80, 80),
        Hover = Color3.fromRGB(70, 70, 70),
        HoverChange = 0.16
    }

    -- Nebula Theme - Cosmic purple and blues
    Themes.Nebula = {
        Name = "Nebula",
        Accent = Color3.fromRGB(123, 82, 231),
        AcrylicMain = Color3.fromRGB(20, 18, 30),
        AcrylicBorder = Color3.fromRGB(90, 70, 120),
        AcrylicGradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 45, 100)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 30, 70)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 15, 40))
        }),
        AcrylicNoise = 0.92,
        TitleBarLine = Color3.fromRGB(70, 55, 95),
        Tab = Color3.fromRGB(140, 120, 180),
        Element = Color3.fromRGB(60, 45, 90),
        ElementBorder = Color3.fromRGB(40, 30, 60),
        InElementBorder = Color3.fromRGB(80, 65, 105),
        ElementTransparency = 0.82,
        ToggleSlider = Color3.fromRGB(140, 120, 180),
        ToggleToggled = Color3.fromRGB(15, 10, 25),
        SliderRail = Color3.fromRGB(140, 120, 180),
        DropdownFrame = Color3.fromRGB(160, 140, 200),
        DropdownHolder = Color3.fromRGB(50, 40, 70),
        DropdownBorder = Color3.fromRGB(40, 30, 60),
        DropdownOption = Color3.fromRGB(140, 120, 180),
        Keybind = Color3.fromRGB(140, 120, 180),
        Input = Color3.fromRGB(140, 120, 180),
        InputFocused = Color3.fromRGB(20, 15, 35),
        InputIndicator = Color3.fromRGB(160, 140, 200),
        Dialog = Color3.fromRGB(50, 40, 70),
        DialogHolder = Color3.fromRGB(40, 30, 60),
        DialogHolderLine = Color3.fromRGB(35, 25, 55),
        DialogButton = Color3.fromRGB(50, 40, 70),
        DialogButtonBorder = Color3.fromRGB(80, 65, 105),
        DialogBorder = Color3.fromRGB(70, 55, 95),
        DialogInput = Color3.fromRGB(55, 45, 75),
        DialogInputLine = Color3.fromRGB(160, 140, 200),
        Text = Color3.fromRGB(235, 230, 255),
        SubText = Color3.fromRGB(170, 160, 190),
        Hover = Color3.fromRGB(70, 55, 100),
        HoverChange = 0.07
    }

    -- Aurora Theme - Northern lights-inspired blues and greens
    Themes.Aurora = {
        Name = "Aurora",
        Accent = Color3.fromRGB(30, 215, 150),
        AcrylicMain = Color3.fromRGB(20, 25, 35),
        AcrylicBorder = Color3.fromRGB(70, 100, 110),
        AcrylicGradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 80, 100)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 60, 80)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 40, 60))
        }),
        AcrylicNoise = 0.92,
        TitleBarLine = Color3.fromRGB(60, 90, 100),
        Tab = Color3.fromRGB(120, 170, 180),
        Element = Color3.fromRGB(45, 75, 90),
        ElementBorder = Color3.fromRGB(35, 55, 70),
        InElementBorder = Color3.fromRGB(70, 100, 110),
        ElementTransparency = 0.84,
        ToggleSlider = Color3.fromRGB(120, 170, 180),
        ToggleToggled = Color3.fromRGB(15, 20, 25),
        SliderRail = Color3.fromRGB(120, 170, 180),
        DropdownFrame = Color3.fromRGB(140, 190, 200),
        DropdownHolder = Color3.fromRGB(40, 65, 80),
        DropdownBorder = Color3.fromRGB(35, 55, 70),
        DropdownOption = Color3.fromRGB(120, 170, 180),
        Keybind = Color3.fromRGB(120, 170, 180),
        Input = Color3.fromRGB(120, 170, 180),
        InputFocused = Color3.fromRGB(20, 30, 40),
        InputIndicator = Color3.fromRGB(140, 190, 200),
        Dialog = Color3.fromRGB(40, 65, 80),
        DialogHolder = Color3.fromRGB(30, 55, 70),
        DialogHolderLine = Color3.fromRGB(25, 45, 60),
        DialogButton = Color3.fromRGB(40, 65, 80),
        DialogButtonBorder = Color3.fromRGB(70, 100, 110),
        DialogBorder = Color3.fromRGB(60, 90, 100),
        DialogInput = Color3.fromRGB(45, 70, 85),
        DialogInputLine = Color3.fromRGB(140, 190, 200),
        Text = Color3.fromRGB(235, 245, 255),
        SubText = Color3.fromRGB(170, 190, 210),
        Hover = Color3.fromRGB(55, 85, 100),
        HoverChange = 0.07
    }

    -- Sunset Theme - Warm oranges and reds
    Themes.Sunset = {
        Name = "Sunset",
        Accent = Color3.fromRGB(255, 120, 50),
        AcrylicMain = Color3.fromRGB(35, 25, 30),
        AcrylicBorder = Color3.fromRGB(120, 80, 70),
        AcrylicGradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 60, 50)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 40, 40)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 30, 30))
        }),
        AcrylicNoise = 0.92,
        TitleBarLine = Color3.fromRGB(100, 70, 60),
        Tab = Color3.fromRGB(180, 130, 110),
        Element = Color3.fromRGB(90, 60, 55),
        ElementBorder = Color3.fromRGB(70, 45, 40),
        InElementBorder = Color3.fromRGB(110, 75, 65),
        ElementTransparency = 0.84,
        ToggleSlider = Color3.fromRGB(180, 130, 110),
        ToggleToggled = Color3.fromRGB(20, 15, 15),
        SliderRail = Color3.fromRGB(180, 130, 110),
        DropdownFrame = Color3.fromRGB(200, 150, 130),
        DropdownHolder = Color3.fromRGB(80, 55, 50),
        DropdownBorder = Color3.fromRGB(70, 45, 40),
        DropdownOption = Color3.fromRGB(180, 130, 110),
        Keybind = Color3.fromRGB(180, 130, 110),
        Input = Color3.fromRGB(180, 130, 110),
        InputFocused = Color3.fromRGB(40, 25, 25),
        InputIndicator = Color3.fromRGB(200, 150, 130),
        Dialog = Color3.fromRGB(80, 55, 50),
        DialogHolder = Color3.fromRGB(70, 45, 40),
        DialogHolderLine = Color3.fromRGB(60, 40, 35),
        DialogButton = Color3.fromRGB(80, 55, 50),
        DialogButtonBorder = Color3.fromRGB(110, 75, 65),
        DialogBorder = Color3.fromRGB(100, 70, 60),
        DialogInput = Color3.fromRGB(85, 60, 55),
        DialogInputLine = Color3.fromRGB(200, 150, 130),
        Text = Color3.fromRGB(255, 240, 230),
        SubText = Color3.fromRGB(210, 180, 170),
        Hover = Color3.fromRGB(100, 70, 65),
        HoverChange = 0.07
    }
end

--//////////////////////////////////////////////////////////////////////////////////--
--                                   COMPONENTS                                     --
--//////////////////////////////////////////////////////////////////////////////////--

do
    -- Element Component (Base for UI elements)
    Components.Element = function(title, description, container, isInteractable)
        local interface = {}
        
        -- Title label
        interface.TitleLabel = Creator.New("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            Text = title,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 0, 14),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            ThemeTag = {TextColor3 = "Text"}
        })
        
        -- Description label
        interface.DescLabel = Creator.New("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
            Text = description,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 13,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            ThemeTag = {TextColor3 = "SubText"}
        })
        
        -- Label container
        interface.LabelHolder = Creator.New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(12, 0),
            Size = UDim2.new(1, -30, 0, 0)
        }, {
            Creator.New("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center
            }),
            Creator.New("UIPadding", {
                PaddingBottom = UDim.new(0, 14),
                PaddingTop = UDim.new(0, 14)
            }),
            interface.TitleLabel,
            interface.DescLabel
        })
        
        -- Subtle shadow
        interface.Shadow = Creator.New("ImageLabel", {
            Image = "rbxassetid://9969931050", -- Shadow image
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = 0.6,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(Vector2.new(512, 512), Vector2.new(512, 512)),
            SliceScale = 0.04,
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(1, 8, 1, 8)
        })
        
        -- Border
        interface.Border = Creator.New("UIStroke", {
            Transparency = 0.5,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = Color3.fromRGB(0, 0, 0),
            ThemeTag = {Color = "ElementBorder"}
        })
        
        -- Main element frame
        interface.Frame = Creator.New("TextButton", {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 0.89,
            BackgroundColor3 = Color3.fromRGB(130, 130, 130),
            Parent = container,
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            LayoutOrder = 7,
            ThemeTag = {
                BackgroundColor3 = "Element",
                BackgroundTransparency = "ElementTransparency"
            }
        }, {
            interface.Shadow,
            Creator.New("UICorner", {
                CornerRadius = UDim.new(0, 8)
            }),
            interface.Border,
            interface.LabelHolder
        })
        
        -- Set title text
        function interface.SetTitle(_, text)
            interface.TitleLabel.Text = text
        end
        
        -- Set description text
        function interface.SetDesc(_, text)
            if text == nil then
                text = ""
            end
            
            if text == "" then
                interface.DescLabel.Visible = false
            else
                interface.DescLabel.Visible = true
            end
            
            interface.DescLabel.Text = text
        end
        
        -- Destroy element
        function interface.Destroy(_)
            interface.Frame:Destroy()
        end
        
        -- Initialize with provided title and description
        interface:SetTitle(title)
        interface:SetDesc(description)
        
        -- Add hover effects for interactive elements
        if isInteractable then
            local _, setTransparency = Creator.SpringMotor(
                Creator.GetThemeProperty("ElementTransparency"),
                interface.Frame,
                "BackgroundTransparency",
                false,
                true
            )
            
            local hoverMotor = Flipper.SingleMotor.new(0)
            local hoverSpring = function(goal) hoverMotor:setGoal(Flipper.Spring.new(goal, {frequency = 10})) end
            
            hoverMotor:onStep(function(value)
                interface.Shadow.ImageTransparency = 0.6 - (value * 0.2)
                interface.Shadow.Size = UDim2.new(1, 8 + (value * 4), 1, 8 + (value * 4))
            end)
            
            Creator.AddSignal(interface.Frame.MouseEnter, function()
                setTransparency(Creator.GetThemeProperty("ElementTransparency") - Creator.GetThemeProperty("HoverChange"))
                hoverSpring(1)
            end)
            
            Creator.AddSignal(interface.Frame.MouseLeave, function()
                setTransparency(Creator.GetThemeProperty("ElementTransparency"))
                hoverSpring(0)
            end)
            
            Creator.AddSignal(interface.Frame.MouseButton1Down, function()
                setTransparency(Creator.GetThemeProperty("ElementTransparency") + Creator.GetThemeProperty("HoverChange"))
                hoverSpring(0.8)
            end)
            
            Creator.AddSignal(interface.Frame.MouseButton1Up, function()
                setTransparency(Creator.GetThemeProperty("ElementTransparency") - Creator.GetThemeProperty("HoverChange"))
                hoverSpring(1)
            end)
        end
        
        return interface
    end

    -- Button Component
    Components.Button = function(title, container, isCompact)
        isCompact = isCompact or false
        
        local interface = {}
        
        -- Button title label
        interface.Title = Creator.New("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 14,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            ThemeTag = {TextColor3 = "Text"}
        })
        
        -- Hover effect frame
        interface.HoverFrame = Creator.New("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            ThemeTag = {BackgroundColor3 = "Hover"}
        }, {
            Creator.New("UICorner", {
                CornerRadius = UDim.new(0, 6)
            })
        })
        
        -- Button shadow
        interface.Shadow = Creator.New("ImageLabel", {
            Image = "rbxassetid://9969931050", -- Shadow image
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = 0.7,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(Vector2.new(512, 512), Vector2.new(512, 512)),
            SliceScale = 0.03,
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(1, 6, 1, 6)
        })
        
        -- Inner highlight (subtle reflection)
        interface.Highlight = Creator.New("Frame", {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.9,
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.fromOffset(0, 1),
            BorderSizePixel = 0
        }, {
            Creator.New("UICorner", {
                CornerRadius = UDim.new(0, 6)
            })
        })
        
        -- Main button frame
        interface.Frame = Creator.New("TextButton", {
            Size = UDim2.new(0, 0, 0, 34),
            Parent = container,
            ThemeTag = {BackgroundColor3 = "DialogButton"}
        }, {
            interface.Shadow,
            Creator.New("UICorner", {
                CornerRadius = UDim.new(0, 6)
            }),
            Creator.New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Transparency = 0.55,
                ThemeTag = {Color = "DialogButtonBorder"}
            }),
            interface.Highlight,
            interface.HoverFrame,
            interface.Title
        })
        
        -- Set up hover animations for smoother interaction
        local hoverMotor = Flipper.SingleMotor.new(0)
        local clickMotor = Flipper.SingleMotor.new(0)
        
        local hoverSpring = function(goal) hoverMotor:setGoal(Flipper.Spring.new(goal, {frequency = 10})) end
        local clickSpring = function(goal) clickMotor:setGoal(Flipper.Spring.new(goal, {frequency = 8})) end
        
        hoverMotor:onStep(function(value)
            interface.HoverFrame.BackgroundTransparency = 1 - (value * 0.04)
            interface.Shadow.ImageTransparency = 0.7 - (value * 0.1)
            interface.Shadow.Size = UDim2.new(1, 6 + (value * 2), 1, 6 + (value * 2))
            interface.Highlight.BackgroundTransparency = 0.9 - (value * 0.08)
        end)
        
        clickMotor:onStep(function(value)
            interface.Frame.Position = UDim2.fromOffset(0, value * 2)
        end)
        
        Creator.AddSignal(interface.Frame.MouseEnter, function()
            hoverSpring(1)
        end)
        
        Creator.AddSignal(interface.Frame.MouseLeave, function()
            hoverSpring(0)
        end)
        
        Creator.AddSignal(interface.Frame.MouseButton1Down, function()
            clickSpring(1)
            interface.Shadow.ImageTransparency = 0.9
        end)
        
        Creator.AddSignal(interface.Frame.MouseButton1Up, function()
            clickSpring(0)
            if interface.Frame:IsHovered() then
                interface.Shadow.ImageTransparency = 0.6
            else
                interface.Shadow.ImageTransparency = 0.7
            end
        end)
        
        return interface
    end

    -- Notification Component
    Components.Notification = {
        Holder = nil
    }

    function Components.Notification.Init(self, parent)
        self.Holder = Creator.New("Frame", {
            Position = UDim2.new(1, -30, 1, -30),
            Size = UDim2.new(0, 310, 1, -30),
            AnchorPoint = Vector2.new(1, 1),
            BackgroundTransparency = 1,
            Parent = parent
        }, {
            Creator.New("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                Padding = UDim.new(0, 20)
            })
        })
    end

    function Components.Notification.New(self, options)
        options.Title = options.Title or "Title"
        options.Content = options.Content or "Content"
        options.SubContent = options.SubContent or ""
        options.Duration = options.Duration or nil
        options.Buttons = options.Buttons or {}
        
        local interface = {Closed = false}
        
        -- Create acrylic background
        interface.AcrylicPaint = Acrylic.AcrylicPaint()
        
        -- Shadow for notification
        interface.Shadow = Creator.New("ImageLabel", {
            Image = "rbxassetid://9969931050", -- Shadow image
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = 0.5,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(Vector2.new(512, 512), Vector2.new(512, 512)),
            SliceScale = 0.04,
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(1, 15, 1, 15)
        })
        
        -- Create title with icon
        interface.TitleHolder = Creator.New("Frame", {
            Position = UDim2.new(0, 14, 0, 17),
            Size = UDim2.new(1, -28, 0, 16),
            BackgroundTransparency = 1,
        }, {
            Creator.New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 8)
            }),
            
            -- Notification icon
            Creator.New("ImageLabel", {
                Image = "rbxassetid://9968344492", -- Info/notification icon
                Size = UDim2.fromOffset(16, 16),
                BackgroundTransparency = 1,
                ImageColor3 = Color3.fromRGB(255, 255, 255),
                ThemeTag = {ImageColor3 = "Accent"}
            }),
            
            -- Title text
            Creator.New("TextLabel", {
                Text = options.Title,
                RichText = true,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextTransparency = 0,
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextSize = 14,
                TextXAlignment = "Left",
                TextYAlignment = "Center",
                Size = UDim2.new(1, -24, 1, 0),
                TextWrapped = true,
                BackgroundTransparency = 1,
                ThemeTag = {TextColor3 = "Text"}
            })
        })
        
        -- Create content labels
        interface.ContentLabel = Creator.New("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            Text = options.Content,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, 0, 0, 14),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            TextWrapped = true,
            ThemeTag = {TextColor3 = "Text"}
        })
        
        interface.SubContentLabel = Creator.New("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
            Text = options.SubContent,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutomaticSize = Enum.AutomaticSize.Y,
            Size = UDim2.new(1, 0, 0, 14),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            TextWrapped = true,
            ThemeTag = {TextColor3 = "SubText"}
        })
        
        -- Create label container
        interface.LabelHolder = Creator.New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(14, 40),
            Size = UDim2.new(1, -28, 0, 0)
        }, {
            Creator.New("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 4)
            }),
            interface.ContentLabel,
            interface.SubContentLabel
        })
        
        -- Create close button
        interface.CloseButton = Creator.New("TextButton", {
            Text = "",
            Position = UDim2.new(1, -14, 0, 13),
            Size = UDim2.fromOffset(20, 20),
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1
        }, {
            Creator.New("ImageLabel", {
                Image = "rbxassetid://9886659671", -- Close icon
                Size = UDim2.fromOffset(16, 16),
                Position = UDim2.fromScale(0.5, 0.5),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                ImageTransparency = 0.1,
                ThemeTag = {ImageColor3 = "Text"}
            })
        })
        
        -- Progress bar for timed notifications
        interface.ProgressBar = Creator.New("Frame", {
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            ThemeTag = {BackgroundColor3 = "Accent"}
        }, {
            Creator.New("UICorner", {
                CornerRadius = UDim.new(0, 2)
            })
        })
        
        -- Main notification frame
        interface.Root = Creator.New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.fromScale(1, 0)
        }, {
            interface.Shadow,
            interface.AcrylicPaint.Frame,
            interface.TitleHolder,
            interface.CloseButton,
            interface.LabelHolder,
            interface.ProgressBar
        })
        
        -- Handle empty content
        if options.Content == "" then
            interface.ContentLabel.Visible = false
        end
        
        if options.SubContent == "" then
            interface.SubContentLabel.Visible = false
        end
        
        -- Create holder frame
        interface.Holder = Creator.New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 200),
            Parent = self.Holder
        }, {
            interface.Root
        })
        
        -- Set up slide animation
        local slideMotor = Flipper.GroupMotor.new({
            Scale = 1,
            Offset = 60
        })
        
        slideMotor:onStep(function(values)
            interface.Root.Position = UDim2.new(values.Scale, values.Offset, 0, 0)
        end)
        
        -- Set up progress bar animation for timed notifications
        if options.Duration then
            local progressMotor = Flipper.SingleMotor.new(0)
            progressMotor:onStep(function(value)
                interface.ProgressBar.Size = UDim2.new(1 - value, 0, 0, 2)
            end)
            
            interface.ProgressBar.Visible = true
            
            task.spawn(function()
                task.wait(0.5) -- Short delay before starting countdown
                progressMotor:setGoal(Flipper.Linear.new(1, {velocity = 1/options.Duration}))
            end)
        else
            interface.ProgressBar.Visible = false
        end
        
        -- Connect close button
        Creator.AddSignal(interface.CloseButton.MouseButton1Click, function()
            interface:Close()
        end)
        
        -- Open animation
        function interface.Open(_)
            local labelHeight = interface.LabelHolder.AbsoluteSize.Y
            interface.Holder.Size = UDim2.new(1, 0, 0, 58 + labelHeight)
            
            slideMotor:setGoal({
                Scale = Flipper.Spring.new(0, {frequency = 5}),
                Offset = Flipper.Spring.new(0, {frequency = 5})
            })
        end
        
        -- Close animation
        function interface.Close(_)
            if not interface.Closed then
                interface.Closed = true
                
                task.spawn(function()
                    slideMotor:setGoal({
                        Scale = Flipper.Spring.new(1, {frequency = 5}),
                        Offset = Flipper.Spring.new(60, {frequency = 5})
                    })
                    
                    task.wait(0.4)
                    if Celestial.UseAcrylic then
                        interface.AcrylicPaint.Model:Destroy()
                    end
                    interface.Holder:Destroy()
                end)
            end
        end
        
        -- Open the notification
        interface:Open()
        
        -- Auto-close after duration
        if options.Duration then
            task.delay(options.Duration, function()
                interface:Close()
            end)
        end
        
        return interface
    end

    -- Dialog Component
    Components.Dialog = {Window = nil}

    function Components.Dialog.Init(self, window)
        self.Window = window
        return self
    end

    function Components.Dialog.Create(_)
        local interface = {Buttons = 0}
        
        -- Create the dialog background tint
        interface.TintFrame = Creator.New("TextButton", {
            Text = "",
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            Parent = Components.Dialog.Window.Root
        }, {
            Creator.New("UICorner", {
                CornerRadius = UDim.new(0, 8)
            })
        })
        
        -- Set up animations
        local _, setTintTransparency = Creator.SpringMotor(1, interface.TintFrame, "BackgroundTransparency", true)
        
        -- Button container
        interface.ButtonHolder = Creator.New("Frame", {
            Size = UDim2.new(1, -40, 1, -40),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            BackgroundTransparency = 1
        }, {
            Creator.New("UIListLayout", {
                Padding = UDim.new(0, 10),
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder
            })
        })
        
        -- Button container frame with divider
        interface.ButtonHolderFrame = Creator.New("Frame", {
            Size = UDim2.new(1, 0, 0, 70),
            Position = UDim2.new(0, 0, 1, -70),
            ThemeTag = {BackgroundColor3 = "DialogHolder"}
        }, {
            Creator.New("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                ThemeTag = {BackgroundColor3 = "DialogHolderLine"}
            }),
            interface.ButtonHolder
        })
        
        -- Dialog shadow
        interface.Shadow = Creator.New("ImageLabel", {
            Image = "rbxassetid://9969931050", -- Shadow image
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = 0.4,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(Vector2.new(512, 512), Vector2.new(512, 512)),
            SliceScale = 0.05,
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(1, 40, 1, 40)
        })
        
        -- Dialog title
        interface.Title = Creator.New("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Text = "Dialog",
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextSize = 22,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, 0, 0, 22),
            Position = UDim2.fromOffset(20, 25),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            ThemeTag = {TextColor3 = "Text"}
        })
        
        -- Scale animation
        interface.Scale = Creator.New("UIScale", {Scale = 1})
        local _, setScale = Creator.SpringMotor(1.1, interface.Scale, "Scale")
        
        -- Main dialog container
        interface.Root = Creator.New("CanvasGroup", {
            Size = UDim2.fromOffset(320, 180),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            GroupTransparency = 1,
            Parent = interface.TintFrame,
            ThemeTag = {BackgroundColor3 = "Dialog"}
        }, {
            interface.Shadow,
            Creator.New("UICorner", {
                CornerRadius = UDim.new(0, 10)
            }),
            Creator.New("UIStroke", {
                Transparency = 0.4,
                Thickness = 1.5,
                ThemeTag = {Color = "DialogBorder"}
            }),
            interface.Scale,
            interface.Title,
            interface.ButtonHolderFrame
        })
        
        -- Dialog open/close animations
        local _, setTransparency = Creator.SpringMotor(1, interface.Root, "GroupTransparency")
        
        function interface.Open(_)
            Celestial.DialogOpen = true
            interface.Scale.Scale = 1.1
            setTintTransparency(0.6)
            setTransparency(0)
            setScale(1)
        end
        
        function interface.Close(_)
            Celestial.DialogOpen = false
            setTintTransparency(1)
            setTransparency(1)
            setScale(1.1)
            interface.Root.UIStroke:Destroy()
            task.wait(0.15)
            interface.TintFrame:Destroy()
        end
        
        -- Add a button to the dialog
        function interface.Button(_, text, callback)
            interface.Buttons = interface.Buttons + 1
            text = text or "Button"
            callback = callback or function() end
            
            local buttonComponent = Components.Button(text, interface.ButtonHolder, true)
            buttonComponent.Title.Text = text
            
            -- Resize buttons to fit evenly
            for _, child in next, interface.ButtonHolder:GetChildren() do
                if child:IsA("TextButton") then
                    child.Size = UDim2.new(1/interface.Buttons, -(((interface.Buttons-1)*10)/interface.Buttons), 0, 36)
                end
            end
            
            -- Connect button callback
            Creator.AddSignal(buttonComponent.Frame.MouseButton1Click, function()
                Celestial:SafeCallback(callback)
                pcall(function() interface:Close() end)
            end)
            
            return buttonComponent
        end
        
        return interface
    end

    -- More component definitions would go here
    -- Section, Tab, Window, TitleBar, etc.
end

--//////////////////////////////////////////////////////////////////////////////////--
--                               UI ELEMENT MODULES                                 --
--//////////////////////////////////////////////////////////////////////////////////--

-- Button Element
do
    local Button = {}
    Button.__index = Button
    Button.__type = "Button"

    function Button.New(container, config)
        assert(config.Title, "Button - Missing Title")
        config.Callback = config.Callback or function() end
        
        local element = Components.Element(config.Title, config.Description, container.Container, true)
        
        -- Add button icon with pulse animation
        local icon = Creator.New("ImageLabel", {
            Image = "rbxassetid://10709791437",
            Size = UDim2.fromOffset(18, 18),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -12, 0.5, 0),
            BackgroundTransparency = 1,
            Parent = element.Frame,
            ThemeTag = {ImageColor3 = "Accent"}
        })
        
        -- Create pulse effect
        local pulse = Creator.New("Frame", {
            Size = UDim2.fromOffset(0, 0),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Parent = icon
        }, {
            Creator.New("UICorner", {
                CornerRadius = UDim.new(1, 0)
            })
        })
        
        -- Connect click callback
        Creator.AddSignal(element.Frame.MouseButton1Click, function()
            -- Pulse animation
            pulse.Size = UDim2.fromOffset(0, 0)
            pulse.BackgroundTransparency = 0.5
            
            TweenService:Create(
                pulse, 
                TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), 
                {Size = UDim2.fromOffset(40, 40), BackgroundTransparency = 1}
            ):Play()
            
            -- Call the callback
            container.Library:SafeCallback(config.Callback)
        end)
        
        return element
    end

    Elements.Button = Button
end

-- Toggle Element
do
    local Toggle = {}
    Toggle.__index = Toggle
    Toggle.__type = "Toggle"

    function Toggle.New(container, title, options)
        local library = container.Library
        
        assert(options.Title, "Toggle - Missing Title")
        
        local toggle = {
            Value = options.Default or false,
            Callback = options.Callback or function() end,
            Type = "Toggle"
        }
        
        -- Create element
        local element = Components.Element(options.Title, options.Description, container.Container, true)
        element.DescLabel.Size = UDim2.new(1, -54, 0, 14)
        
        toggle.SetTitle = element.SetTitle
        toggle.SetDesc = element.SetDesc
        
        -- Create toggle indicator
        local indicatorIcon = Creator.New("ImageLabel", {
            AnchorPoint = Vector2.new(0, 0.5),
            Size = UDim2.fromOffset(16, 16),
            Position = UDim2.new(0, 2, 0.5, 0),
            Image = "rbxassetid://12266946128",
            ImageTransparency = 0.5,
            ThemeTag = {ImageColor3 = "ToggleSlider"}
        })
        
        local strokeEffect = Creator.New("UIStroke", {
            Transparency = 0.5,
            Thickness = 1.5,
            ThemeTag = {Color = "ToggleSlider"}
        })
        
        -- Create ripple effect for toggle
        local ripple = Creator.New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(1, 1)
        }, {
            Creator.New("UICorner", {
                CornerRadius = UDim.new(0, 9)
            }),
            Creator.New("UIStroke", {
                Transparency = 1,
                Thickness = 5,
                ThemeTag = {Color = "Accent"}
            })
        })
        
        -- Create toggle background
        local toggleBackground = Creator.New("Frame", {
            Size = UDim2.fromOffset(40, 20),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -10, 0.5, 0),
            Parent = element.Frame,
            BackgroundTransparency = 1,
            ThemeTag = {BackgroundColor3 = "Accent"}
        }, {
            Creator.New("UICorner", {
                CornerRadius = UDim.new(0, 10)
            }),
            strokeEffect,
            indicatorIcon,
            ripple
        })
        
        -- Handle value changes
        function toggle.OnChanged(self, callback)
            toggle.Changed = callback
            callback(toggle.Value)
        end
        
        -- Set toggle value
        function toggle.SetValue(self, value)
            value = not not value -- Convert to boolean
            toggle.Value = value
            
            -- Update the toggle appearance
            Creator.OverrideTag(strokeEffect, {Color = toggle.Value and "Accent" or "ToggleSlider"})
            Creator.OverrideTag(indicatorIcon, {ImageColor3 = toggle.Value and "ToggleToggled" or "ToggleSlider"})
            
            -- Animate the indicator
            TweenService:Create(
                indicatorIcon, 
                TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), 
                {Position = UDim2.new(0, toggle.Value and 22 or 2, 0.5, 0)}
            ):Play()
            
            -- Animate the background
            TweenService:Create(
                toggleBackground, 
                TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), 
                {BackgroundTransparency = toggle.Value and 0 or 1}
            ):Play()
            
            -- Animate the ripple effect
            if toggle.Value then
                ripple.UIStroke.Transparency = 0.6
                
                TweenService:Create(
                    ripple, 
                    TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), 
                    {Size = UDim2.fromScale(1.8, 1.8)}
                ):Play()
                
                TweenService:Create(
                    ripple.UIStroke, 
                    TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), 
                    {Transparency = 1}
                ):Play()
            end
            
            -- Update the icon transparency
            indicatorIcon.ImageTransparency = toggle.Value and 0 or 0.5
            
            -- Call callbacks
            library:SafeCallback(toggle.Callback, toggle.Value)
            library:SafeCallback(toggle.Changed, toggle.Value)
        end
        
        -- Cleanup
        function toggle.Destroy(self)
            element:Destroy()
            library.Options[title] = nil
        end
        
        -- Toggle on click
        Creator.AddSignal(element.Frame.MouseButton1Click, function()
            toggle:SetValue(not toggle.Value)
        end)
        
        -- Initialize with default value
        toggle:SetValue(toggle.Value)
        
        -- Register with library
        library.Options[title] = toggle
        
        return toggle
    end

    Elements.Toggle = Toggle
end

-- Add the rest of your UI elements (Colorpicker, Dropdown, Slider, etc.) here

--//////////////////////////////////////////////////////////////////////////////////--
--                               MAIN CELESTIAL MODULE                              --
--//////////////////////////////////////////////////////////////////////////////////--

-- Initialize UI container
local MainGui = Creator.New("ScreenGui", {
    Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui")
})

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
ProtectGui(MainGui)

Components.Notification:Init(MainGui)

-- Library setup
Celestial = {
    Version = "1.0.0",
    OpenFrames = {},
    Options = {},
    Themes = Themes.Names,
    Window = nil,
    WindowFrame = nil,
    Unloaded = false,
    Theme = "Dark",
    DialogOpen = false,
    UseAcrylic = false,
    Acrylic = false,
    Transparency = true,
    MinimizeKeybind = nil,
    MinimizeKey = Enum.KeyCode.LeftControl,
    GUI = MainGui
}

-- Safely execute callbacks with error handling
function Celestial.SafeCallback(_, callback, ...)
    if not callback then 
        return 
    end
    
    local success, errorMsg = pcall(callback, ...)
    if not success then
        local _, endPos = errorMsg:find(":%d+: ")
        if not endPos then 
            return Celestial:Notify({
                Title = "Celestial",
                Content = "Callback error",
                SubContent = errorMsg,
                Duration = 5
            })
        end
        
        return Celestial:Notify({
            Title = "Celestial",
            Content = "Callback error",
            SubContent = errorMsg:sub(endPos + 1),
            Duration = 5
        })
    end
end

-- Precision rounding utility
function Celestial.Round(_, value, decimalPlaces)
    if decimalPlaces == 0 then 
        return math.floor(value)
    end
    
    value = tostring(value)
    return value:find("%.") and tonumber(value:sub(1, value:find("%.")+decimalPlaces)) or value
end

-- Icon system
local Icons = {
    assets = {
        ['lucide-close'] = 'rbxassetid://9886659671',
        ['lucide-min'] = 'rbxassetid://9886659276',
        ['lucide-max'] = 'rbxassetid://9886659406',
        ['lucide-restore'] = 'rbxassetid://9886659001',
        ['lucide-settings'] = 'rbxassetid://9968344947',
        ['lucide-info'] = 'rbxassetid://9968344492',
        ['lucide-alert'] = 'rbxassetid://9968344309',
        ['lucide-check'] = 'rbxassetid://9968344577'
        -- Add more icons as needed
    }
}

function Celestial.GetIcon(_, name, specificIcon)
    if specificIcon ~= nil and Icons.assets["lucide-"..specificIcon] then
        return Icons.assets["lucide-"..specificIcon]
    end
    return nil
end

-- Element interface for UI components
local ElementInterface = {}
ElementInterface.__index = ElementInterface
ElementInterface.__namecall = function(self, method, ...)
    return ElementInterface[method](...)
end

-- Register all UI elements
for _, Element in pairs(Elements) do
    ElementInterface["Add"..Element.__type] = function(container, props, options)
        Element.Container = container.Container
        Element.Type = container.Type
        Element.ScrollFrame = container.ScrollFrame
        Element.Library = Celestial
        return Element.New(container, props, options)
    end
end

Celestial.Elements = ElementInterface

-- Create the main window of the UI
function Celestial.CreateWindow(_, config)
    assert(config.Title, "Window - Missing Title")
    
    if Celestial.Window then
        print("You cannot create more than one window.")
        return
    end
    
    Celestial.MinimizeKey = config.MinimizeKey
    Celestial.UseAcrylic = config.Acrylic
    
    if config.Acrylic then
        Acrylic.init()
    end
    
    -- Create the window (simplified - in real implementation, this would call Window.lua)
    local windowInstance = {
        Parent = MainGui,
        Size = config.Size,
        Title = config.Title,
        SubTitle = config.SubTitle,
        TabWidth = config.TabWidth
    }
    
    Celestial.Window = windowInstance
    Celestial:SetTheme(config.Theme)
    
    return windowInstance
end

-- Set the UI theme
function Celestial.SetTheme(_, themeName)
    if Celestial.Window and table.find(Celestial.Themes, themeName) then
        Celestial.Theme = themeName
        Creator.UpdateTheme()
    end
end

-- Cleanup and destroy the UI
function Celestial.Destroy(_)
    if Celestial.Window then
        Celestial.Unloaded = true
        
        if Celestial.UseAcrylic then
            Celestial.Window.AcrylicPaint.Model:Destroy()
        end
        
        Creator.Disconnect()
        Celestial.GUI:Destroy()
    end
end

-- Toggle acrylic effect
function Celestial.ToggleAcrylic(_, enabled)
    if Celestial.Window then
        if Celestial.UseAcrylic then
            Celestial.Acrylic = enabled
            Celestial.Window.AcrylicPaint.Model.Transparency = enabled and 0.96 or 1
            
            if enabled then
                Acrylic.Enable()
            else
                Acrylic.Disable()
            end
        end
    end
end

-- Toggle transparency effects
function Celestial.ToggleTransparency(_, enabled)
    if Celestial.Window then
        Celestial.Window.AcrylicPaint.Frame.Background.BackgroundTransparency = enabled and 0.35 or 0
    end
end

-- Display a notification
function Celestial.Notify(_, options)
    return Components.Notification:New(options)
end

-- Make the library accessible globally if in a supported environment
if getgenv then
    getgenv().Celestial = Celestial
end

return Celestial
