local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local CelestialLibrary = {
    Name = "Celestial UI",
    Version = "1.0.0",
    Tabs = {},
    Elements = {},
    Themes = {
        Dark = {
            Primary = Color3.fromRGB(25, 25, 30),
            Secondary = Color3.fromRGB(35, 35, 40),
            Accent = Color3.fromRGB(120, 120, 255),
            Text = Color3.fromRGB(240, 240, 240),
            SubText = Color3.fromRGB(170, 170, 170),
            Border = Color3.fromRGB(60, 60, 65),
            Divider = Color3.fromRGB(50, 50, 55),
            DropdownOption = Color3.fromRGB(30, 30, 35),
            DropdownBorder = Color3.fromRGB(50, 50, 55),
            DropdownFrame = Color3.fromRGB(35, 35, 40),
            DropdownHolder = Color3.fromRGB(30, 30, 35),
            SliderRail = Color3.fromRGB(40, 40, 45),
            ToggleSlider = Color3.fromRGB(150, 150, 150),
            ToggleToggled = Color3.fromRGB(255, 255, 255),
            InputBackground = Color3.fromRGB(40, 40, 45),
            InputBorder = Color3.fromRGB(65, 65, 70),
            InElementBorder = Color3.fromRGB(80, 80, 85),
            NotificationBackground = Color3.fromRGB(30, 30, 35),
            NotificationBorder = Color3.fromRGB(50, 50, 55),
            DialogInput = Color3.fromRGB(45, 45, 50),
        },
        Light = {
            Primary = Color3.fromRGB(240, 240, 245),
            Secondary = Color3.fromRGB(230, 230, 235),
            Accent = Color3.fromRGB(80, 80, 255),
            Text = Color3.fromRGB(40, 40, 40),
            SubText = Color3.fromRGB(90, 90, 90),
            Border = Color3.fromRGB(200, 200, 205),
            Divider = Color3.fromRGB(210, 210, 215),
            DropdownOption = Color3.fromRGB(225, 225, 230),
            DropdownBorder = Color3.fromRGB(200, 200, 205),
            DropdownFrame = Color3.fromRGB(220, 220, 225),
            DropdownHolder = Color3.fromRGB(235, 235, 240),
            SliderRail = Color3.fromRGB(220, 220, 225),
            ToggleSlider = Color3.fromRGB(150, 150, 150),
            ToggleToggled = Color3.fromRGB(50, 50, 50),
            InputBackground = Color3.fromRGB(225, 225, 230),
            InputBorder = Color3.fromRGB(200, 200, 205),
            InElementBorder = Color3.fromRGB(180, 180, 185),
            NotificationBackground = Color3.fromRGB(235, 235, 240),
            NotificationBorder = Color3.fromRGB(200, 200, 205),
            DialogInput = Color3.fromRGB(215, 215, 220),
        },
        Ocean = {
            Primary = Color3.fromRGB(20, 25, 40),
            Secondary = Color3.fromRGB(30, 35, 50),
            Accent = Color3.fromRGB(50, 150, 255),
            Text = Color3.fromRGB(240, 240, 240),
            SubText = Color3.fromRGB(170, 170, 180),
            Border = Color3.fromRGB(45, 50, 70),
            Divider = Color3.fromRGB(40, 45, 60),
            DropdownOption = Color3.fromRGB(25, 30, 45),
            DropdownBorder = Color3.fromRGB(45, 50, 70),
            DropdownFrame = Color3.fromRGB(30, 35, 50),
            DropdownHolder = Color3.fromRGB(25, 30, 45),
            SliderRail = Color3.fromRGB(35, 40, 55),
            ToggleSlider = Color3.fromRGB(140, 150, 170),
            ToggleToggled = Color3.fromRGB(255, 255, 255),
            InputBackground = Color3.fromRGB(35, 40, 55),
            InputBorder = Color3.fromRGB(60, 65, 80),
            InElementBorder = Color3.fromRGB(75, 80, 95),
            NotificationBackground = Color3.fromRGB(25, 30, 45),
            NotificationBorder = Color3.fromRGB(45, 50, 70),
            DialogInput = Color3.fromRGB(40, 45, 60),
        },
        Midnight = {
            Primary = Color3.fromRGB(15, 15, 20),
            Secondary = Color3.fromRGB(25, 25, 30),
            Accent = Color3.fromRGB(120, 60, 255),
            Text = Color3.fromRGB(240, 240, 240),
            SubText = Color3.fromRGB(170, 170, 170),
            Border = Color3.fromRGB(40, 40, 45),
            Divider = Color3.fromRGB(35, 35, 40),
            DropdownOption = Color3.fromRGB(20, 20, 25),
            DropdownBorder = Color3.fromRGB(40, 40, 45),
            DropdownFrame = Color3.fromRGB(25, 25, 30),
            DropdownHolder = Color3.fromRGB(20, 20, 25),
            SliderRail = Color3.fromRGB(30, 30, 35),
            ToggleSlider = Color3.fromRGB(140, 140, 150),
            ToggleToggled = Color3.fromRGB(240, 240, 240),
            InputBackground = Color3.fromRGB(30, 30, 35),
            InputBorder = Color3.fromRGB(50, 50, 55),
            InElementBorder = Color3.fromRGB(70, 70, 75),
            NotificationBackground = Color3.fromRGB(20, 20, 25),
            NotificationBorder = Color3.fromRGB(40, 40, 45),
            DialogInput = Color3.fromRGB(35, 35, 40),
        },
        Crimson = {
            Primary = Color3.fromRGB(30, 20, 25),
            Secondary = Color3.fromRGB(40, 25, 30),
            Accent = Color3.fromRGB(255, 80, 100),
            Text = Color3.fromRGB(240, 240, 240),
            SubText = Color3.fromRGB(180, 170, 170),
            Border = Color3.fromRGB(60, 45, 50),
            Divider = Color3.fromRGB(50, 40, 45),
            DropdownOption = Color3.fromRGB(35, 25, 30),
            DropdownBorder = Color3.fromRGB(60, 45, 50),
            DropdownFrame = Color3.fromRGB(40, 30, 35),
            DropdownHolder = Color3.fromRGB(35, 25, 30),
            SliderRail = Color3.fromRGB(45, 35, 40),
            ToggleSlider = Color3.fromRGB(160, 140, 150),
            ToggleToggled = Color3.fromRGB(255, 255, 255),
            InputBackground = Color3.fromRGB(45, 35, 40),
            InputBorder = Color3.fromRGB(65, 55, 60),
            InElementBorder = Color3.fromRGB(80, 70, 75),
            NotificationBackground = Color3.fromRGB(35, 25, 30),
            NotificationBorder = Color3.fromRGB(60, 45, 50),
            DialogInput = Color3.fromRGB(50, 40, 45),
        },
    },
    CurrentTheme = "Dark",
    Transparency = false,
    UseAcrylic = false,
    Options = {},
    Flags = {},
    OpenFrames = {},
    Notifications = {},
    NotificationSize = 24,
    ThemeObjects = {},
    ToggleKey = Enum.KeyCode.RightShift,
    MinimizeKey = Enum.KeyCode.RightControl,
}

local KeyNames = {
    [Enum.KeyCode.LeftControl] = "LCtrl",
    [Enum.KeyCode.RightControl] = "RCtrl",
    [Enum.KeyCode.LeftShift] = "LShift",
    [Enum.KeyCode.RightShift] = "RShift",
    [Enum.KeyCode.LeftAlt] = "LAlt",
    [Enum.KeyCode.RightAlt] = "RAlt",
    [Enum.UserInputType.MouseButton1] = "MB1",
    [Enum.UserInputType.MouseButton2] = "MB2",
    [Enum.UserInputType.MouseButton3] = "MB3",
}

-- Creator utility
local Creator = {}

function Creator.New(Class, Properties, Children)
    local Object = Instance.new(Class)
    
    for Index, Value in next, Properties or {} do
        if Index == "ThemeTag" then
            CelestialLibrary:AddThemeObject(Object, Value)
        else
            Object[Index] = Value
        end
    end
    
    for _, Child in next, Children or {} do
        Child.Parent = Object
    end
    
    return Object
end

function Creator.AddSignal(Signal, Function)
    local Connection = Signal:Connect(Function)
    return Connection
end

function Creator.Round(Number, Divider)
    Divider = Divider or 1
    return math.floor(Number / Divider + 0.5) * Divider
end

function Creator.GetTextSize(Text, Font, Size, Resolution)
    local Resolution = Resolution or Vector2.new(1000, 1000)
    return TextService:GetTextSize(Text, Size, Font, Resolution)
end

function Creator.GetMouseLocation()
    return UserInputService:GetMouseLocation()
end

function Creator.SpringMotor(Initial, Object, Property)
    local Spring = {}
    
    local Target = Initial
    local Position = Target
    local Velocity = 0
    
    local Damping = 1
    local Stiffness = 100
    local TimeTick = 0.01
    local LastUpdate = tick()
    
    local Connection
    
    local function UpdateSpring()
        local Now = tick()
        local DeltaTime = math.min(Now - LastUpdate, 0.1)
        LastUpdate = Now
        
        local Acceleration = Stiffness * (Target - Position) - Damping * Velocity
        Velocity = Velocity + Acceleration * DeltaTime
        Position = Position + Velocity * DeltaTime
        
        Object[Property] = Position
        
        if math.abs(Target - Position) < 0.001 and math.abs(Velocity) < 0.001 then
            Object[Property] = Target
            Connection:Disconnect()
            Connection = nil
        end
    end
    
    function Spring.SetValue(Value)
        Target = Value
        
        if not Connection then
            Connection = RunService.Heartbeat:Connect(UpdateSpring)
        end
    end
    
    function Spring.GetValue()
        return Target
    end
    
    return Spring, Spring.SetValue
end

function Creator.OverrideTag(Object, Tag)
    if not Object or not Tag then return end
    
    for Property, Value in next, Tag do
        if not CelestialLibrary.ThemeObjects[Object] then
            CelestialLibrary.ThemeObjects[Object] = {}
        end
        
        CelestialLibrary.ThemeObjects[Object][Property] = Value
    end
    
    CelestialLibrary:UpdateTheme()
end

-- Utility Functions
function CelestialLibrary:Round(Number, Divider)
    return Creator.Round(Number, Divider)
end

function CelestialLibrary:AddThemeObject(Object, Tag)
    if not Object or not Tag then return end
    
    for Property, Value in next, Tag do
        if not self.ThemeObjects[Object] then
            self.ThemeObjects[Object] = {}
        end
        
        self.ThemeObjects[Object][Property] = Value
    end
end

function CelestialLibrary:UpdateTheme()
    for Object, Properties in next, self.ThemeObjects do
        if not Object or typeof(Object) ~= "Instance" or not Object:IsDescendantOf(game) then
            self.ThemeObjects[Object] = nil
            continue
        end
        
        for Property, Value in next, Properties do
            if Value and self.Themes[self.CurrentTheme][Value] then
                Object[Property] = self.Themes[self.CurrentTheme][Value]
            end
        end
    end
end

function CelestialLibrary:SetTheme(Theme)
    if self.Themes[Theme] then
        self.CurrentTheme = Theme
        self:UpdateTheme()
    end
end

function CelestialLibrary:ToggleAcrylic(Value)
    self.UseAcrylic = Value
    self.MainBlur.Enabled = Value
end

function CelestialLibrary:ToggleTransparency(Value)
    self.Transparency = Value
    self:UpdateTheme()
end

function CelestialLibrary:SafeCallback(Callback, ...)
    local Success, Error = pcall(Callback, ...)
    
    if not Success then
        warn("Celestial UI | Error in callback:", Error)
    end
end

function CelestialLibrary:GetFontFromName(Name)
    if Name == "Default" or Name == "Gotham" then
        return Font.new("rbxasset://fonts/families/GothamSSm.json")
    elseif Name == "Ubuntu" then
        return Font.new("rbxasset://fonts/families/Ubuntu.json")
    elseif Name == "SourceSans" then
        return Font.new("rbxasset://fonts/families/SourceSansPro.json")
    elseif Name == "Poppins" then
        return Font.new("rbxasset://fonts/families/Poppins.json")
    elseif Name == "RobotoCondensed" then
        return Font.new("rbxasset://fonts/families/RobotoCondensed.json")
    elseif Name == "Inter" then
        return Font.new("rbxasset://fonts/families/Inter.json")
    end
    
    return Font.new("rbxasset://fonts/families/GothamSSm.json")
end

-- Base element component
local function CreateElement(Title, Description, Container)
    local ElementFrame = Creator.New("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = Container
    })
    
    local ElementTitle = Creator.New("TextLabel", {
        FontFace = CelestialLibrary.Font,
        Text = Title or "Element",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = ElementFrame,
        ThemeTag = {
            TextColor3 = "Text"
        }
    })
    
    local ElementDescription
    
    if Description then
        ElementDescription = Creator.New("TextLabel", {
            FontFace = CelestialLibrary.Font,
            Text = Description,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 0, 20),
            Parent = ElementFrame,
            ThemeTag = {
                TextColor3 = "SubText"
            }
        })
        ElementFrame.Size = UDim2.new(1, 0, 0, 50)
    end
    
    return {
        Frame = ElementFrame,
        Title = ElementTitle,
        Description = ElementDescription,
        SetTitle = function(_, NewTitle)
            ElementTitle.Text = NewTitle
        end,
        SetDesc = function(_, NewDesc)
            if ElementDescription then
                ElementDescription.Text = NewDesc
            else
                ElementDescription = Creator.New("TextLabel", {
                    FontFace = CelestialLibrary.Font,
                    Text = NewDesc,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 20),
                    Parent = ElementFrame,
                    ThemeTag = {
                        TextColor3 = "SubText"
                    }
                })
                ElementFrame.Size = UDim2.new(1, 0, 0, 50)
            end
        end
    }
end

-- Create a textbox (shared component)
local function CreateTextbox(Parent, HasIcon)
    local TextboxFrame = Creator.New("Frame", {
        Size = UDim2.fromOffset(160, 30),
        BackgroundTransparency = 0,
        Parent = Parent,
        ThemeTag = {
            BackgroundColor3 = "InputBackground"
        }
    }, {
        Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 4)
        }),
        Creator.New("UIStroke", {
            Thickness = 1,
            Transparency = 0.5,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeTag = {
                Color = "InputBorder"
            }
        })
    })
    
    local TextBox = Creator.New("TextBox", {
        FontFace = CelestialLibrary.Font,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, HasIcon and -26 or -10, 1, 0),
        Position = UDim2.fromOffset(HasIcon and 26 or 10, 0),
        Parent = TextboxFrame,
        ClipsDescendants = true,
        ThemeTag = {
            TextColor3 = "Text",
            PlaceholderColor3 = "SubText"
        }
    })
    
    if HasIcon then
        local SearchIcon = Creator.New("ImageLabel", {
            Image = "rbxassetid://10709790573",
            Size = UDim2.fromOffset(16, 16),
            Position = UDim2.new(0, 6, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Parent = TextboxFrame,
            ThemeTag = {
                ImageColor3 = "SubText"
            }
        })
    end
    
    return {
        Frame = TextboxFrame,
        Input = TextBox
    }
end

-- Dialog component
local Dialog = {}

function Dialog:Create()
    if self.DialogFrame then
        self.DialogFrame:Destroy()
    end
    
    local DialogFrame = Creator.New("Frame", {
        Size = UDim2.fromOffset(400, 300),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 0,
        Visible = false,
        Parent = CelestialLibrary.GUI,
        ThemeTag = {
            BackgroundColor3 = "Secondary"
        }
    }, {
        Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 8)
        }),
        Creator.New("UIStroke", {
            Thickness = 1,
            Transparency = 0.5,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeTag = {
                Color = "Border"
            }
        })
    })
    
    local DialogTitle = Creator.New("TextLabel", {
        FontFace = CelestialLibrary.Font,
        Text = "Dialog",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.fromOffset(10, 0),
        Parent = DialogFrame,
        ThemeTag = {
            TextColor3 = "Text"
        }
    })
    
    local DialogButtons = Creator.New("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 1, -50),
        BackgroundTransparency = 1,
        Parent = DialogFrame
    }, {
        Creator.New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        }),
        Creator.New("UIPadding", {
            PaddingRight = UDim.new(0, 10)
        })
    })
    
    local ButtonCount = 0
    local Dialog = {
        Root = DialogFrame,
        Title = DialogTitle,
        ButtonsFrame = DialogButtons,
        Buttons = {},
        SelectedButton = nil
    }
    
    function Dialog:Button(Text, Callback)
        ButtonCount = ButtonCount + 1
        
        local Button = Creator.New("TextButton", {
            FontFace = CelestialLibrary.Font,
            Text = Text,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            BackgroundTransparency = 0,
            Size = UDim2.new(0, 100, 0, 30),
            Parent = DialogButtons,
            LayoutOrder = -ButtonCount, -- Reverse order
            ThemeTag = {
                BackgroundColor3 = "Secondary",
                TextColor3 = "Text"
            }
        }, {
            Creator.New("UICorner", {
                CornerRadius = UDim.new(0, 4)
            }),
            Creator.New("UIStroke", {
                Thickness = 1,
                Transparency = 0.5,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                ThemeTag = {
                    Color = "Border"
                }
            })
        })
        
        -- Add hover effects
        Creator.AddSignal(Button.MouseEnter, function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.8}):Play()
        end)
        
        Creator.AddSignal(Button.MouseLeave, function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        end)
        
        Creator.AddSignal(Button.MouseButton1Down, function()
            TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundTransparency = 0.6}):Play()
        end)
        
        Creator.AddSignal(Button.MouseButton1Up, function()
            TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundTransparency = 0.8}):Play()
        end)
        
        Creator.AddSignal(Button.MouseButton1Click, function()
            self:Close()
            if Callback then
                Callback()
            end
        end)
        
        table.insert(self.Buttons, {Button = Button, Callback = Callback})
        return self
    end
    
    -- Open/close functions
    local Overlay = Creator.New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = CelestialLibrary.GUI
    })
    
    function Dialog:Open()
        Dialog.Root.Visible = true
        Dialog.Root.Size = UDim2.fromOffset(400, 300)
        Overlay.Visible = true
        
        -- Animations
        Dialog.Root.BackgroundTransparency = 1
        Dialog.Root.Position = UDim2.new(0.5, 0, 0.5, -20)
        
        for _, Obj in pairs(Dialog.Root:GetDescendants()) do
            if Obj:IsA("TextLabel") or Obj:IsA("TextButton") or Obj:IsA("ImageLabel") then
                Obj.BackgroundTransparency = 1
                Obj.TextTransparency = 1
                Obj.ImageTransparency = 1
            end
            
            if Obj:IsA("UIStroke") then
                Obj.Transparency = 1
            end
        end
        
        TweenService:Create(Overlay, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
        TweenService:Create(Dialog.Root, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0,
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        
        -- Animate all children
        for _, Obj in pairs(Dialog.Root:GetDescendants()) do
            if Obj:IsA("TextLabel") or Obj:IsA("TextButton") then
                TweenService:Create(Obj, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    TextTransparency = 0,
                    BackgroundTransparency = Obj.BackgroundTransparency == 0 and 0 or 1
                }):Play()
            end
            
            if Obj:IsA("ImageLabel") or Obj:IsA("ImageButton") then
                TweenService:Create(Obj, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    ImageTransparency = 0,
                    BackgroundTransparency = 1
                }):Play()
            end
            
            if Obj:IsA("UIStroke") then
                TweenService:Create(Obj, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Transparency = 0.5
                }):Play()
            end
        end
    end
    
    function Dialog:Close()
        -- Animate out
        TweenService:Create(Overlay, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        TweenService:Create(Dialog.Root, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.5, -20)
        }):Play()
        
        -- Animate all children
        for _, Obj in pairs(Dialog.Root:GetDescendants()) do
            if Obj:IsA("TextLabel") or Obj:IsA("TextButton") then
                TweenService:Create(Obj, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    TextTransparency = 1,
                    BackgroundTransparency = 1
                }):Play()
            end
            
            if Obj:IsA("ImageLabel") or Obj:IsA("ImageButton") then
                TweenService:Create(Obj, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    ImageTransparency = 1,
                    BackgroundTransparency = 1
                }):Play()
            end
            
            if Obj:IsA("UIStroke") then
                TweenService:Create(Obj, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Transparency = 1
                }):Play()
            end
        end
        
        task.delay(0.3, function()
            Dialog.Root.Visible = false
            Overlay.Visible = false
        end)
    end
    
    self.DialogFrame = DialogFrame
    self.Overlay = Overlay
    return Dialog
end

-- Element Implementations
local Elements = {}

-- Button implementation
Elements.Button = {}
function Elements.Button:New(Config, Container)
    assert(Config.Title, "Button - Missing Title")
    Config.Callback = Config.Callback or function() end
    
    local ButtonElement = CreateElement(Config.Title, Config.Description, Container)
    
    local ButtonFrame = Creator.New("TextButton", {
        FontFace = CelestialLibrary.Font,
        Text = Config.Text or "Button",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        BackgroundTransparency = 0,
        Size = UDim2.new(0, 120, 0, 30),
        Position = UDim2.new(1, -10, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        Parent = ButtonElement.Frame,
        ThemeTag = {
            BackgroundColor3 = "Secondary",
            TextColor3 = "Text"
        }
    }, {
        Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 4)
        }),
        Creator.New("UIStroke", {
            Thickness = 1,
            Transparency = 0.5,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeTag = {
                Color = "Border"
            }
        })
    })
    
    -- Add hover and click effects
    Creator.AddSignal(ButtonFrame.MouseEnter, function()
        TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.8}):Play()
    end)
    
    Creator.AddSignal(ButtonFrame.MouseLeave, function()
        TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end)
    
    Creator.AddSignal(ButtonFrame.MouseButton1Down, function()
        TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundTransparency = 0.6}):Play()
    end)
    
    Creator.AddSignal(ButtonFrame.MouseButton1Up, function()
        TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundTransparency = 0.8}):Play()
    end)
    
    Creator.AddSignal(ButtonFrame.MouseButton1Click, function()
        CelestialLibrary:SafeCallback(Config.Callback)
    end)
    
    local Button = {
        Element = ButtonElement,
        Button = ButtonFrame
    }
    
    function Button:SetText(Text)
        ButtonFrame.Text = Text
    end
    
    return Button
end

-- Toggle implementation
Elements.Toggle = {}
function Elements.Toggle:New(Idx, Config, Container)
    assert(Config.Title, "Toggle - Missing Title")
    
    local Toggle = {
        Value = Config.Default or false,
        Callback = Config.Callback or function(Value) end,
        Type = "Toggle",
    }
    
    local ToggleElement = CreateElement(Config.Title, Config.Description, Container)
    
    Toggle.SetTitle = ToggleElement.SetTitle
    Toggle.SetDesc = ToggleElement.SetDesc
    
    local ToggleCircle = Creator.New("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(0, 2, 0.5, 0),
        Image = "http://www.roblox.com/asset/?id=12266946128",
        ImageTransparency = 0.5,
        ThemeTag = {
            ImageColor3 = "ToggleSlider",
        },
    })
    
    local ToggleBorder = Creator.New("UIStroke", {
        Transparency = 0.5,
        ThemeTag = {
            Color = "ToggleSlider",
        },
    })
    
    local ToggleSlider = Creator.New("Frame", {
        Size = UDim2.fromOffset(36, 18),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Parent = ToggleElement.Frame,
        BackgroundTransparency = 1,
        ThemeTag = {
            BackgroundColor3 = "Accent",
        },
    }, {
        Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 9),
        }),
        ToggleBorder,
        ToggleCircle,
    })
    
    function Toggle:OnChanged(Func)
        Toggle.Changed = Func
        Func(Toggle.Value)
    end
    
    function Toggle:SetValue(Value)
        Value = not not Value
        Toggle.Value = Value
        
        Creator.OverrideTag(ToggleBorder, { Color = Toggle.Value and "Accent" or "ToggleSlider" })
        Creator.OverrideTag(ToggleCircle, { ImageColor3 = Toggle.Value and "ToggleToggled" or "ToggleSlider" })
        TweenService:Create(
            ToggleCircle,
            TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { Position = UDim2.new(0, Toggle.Value and 19 or 2, 0.5, 0) }
        ):Play()
        TweenService:Create(
            ToggleSlider,
            TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { BackgroundTransparency = Toggle.Value and 0 or 1 }
        ):Play()
        ToggleCircle.ImageTransparency = Toggle.Value and 0 or 0.5
        
        CelestialLibrary:SafeCallback(Toggle.Callback, Toggle.Value)
        CelestialLibrary:SafeCallback(Toggle.Changed, Toggle.Value)
    end
    
    function Toggle:Destroy()
        ToggleElement.Frame:Destroy()
        CelestialLibrary.Options[Idx] = nil
    end
    
    Creator.AddSignal(ToggleElement.Frame.MouseButton1Click, function()
        Toggle:SetValue(not Toggle.Value)
    end)
    
    Toggle:SetValue(Toggle.Value)
    
    CelestialLibrary.Options[Idx] = Toggle
    return Toggle
end

-- Slider implementation
Elements.Slider = {}
function Elements.Slider:New(Idx, Config, Container)
    assert(Config.Title, "Slider - Missing Title.")
    assert(Config.Default, "Slider - Missing default value.")
    assert(Config.Min, "Slider - Missing minimum value.")
    assert(Config.Max, "Slider - Missing maximum value.")
    assert(Config.Rounding, "Slider - Missing rounding value.")

    local Slider = {
        Value = nil,
        Min = Config.Min,
        Max = Config.Max,
        Rounding = Config.Rounding,
        Callback = Config.Callback or function(Value) end,
        Type = "Slider",
    }

    local Dragging = false

    local SliderElement = CreateElement(Config.Title, Config.Description, Container)
    SliderElement.Description.Size = UDim2.new(1, -170, 0, 14)

    Slider.SetTitle = SliderElement.SetTitle
    Slider.SetDesc = SliderElement.SetDesc

    local SliderDot = Creator.New("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, -7, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        Image = "http://www.roblox.com/asset/?id=12266946128",
        ThemeTag = {
            ImageColor3 = "Accent",
        },
    })

    local SliderRail = Creator.New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(7, 0),
        Size = UDim2.new(1, -14, 1, 0),
    }, {
        SliderDot,
    })

    local SliderFill = Creator.New("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        ThemeTag = {
            BackgroundColor3 = "Accent",
        },
    }, {
        Creator.New("UICorner", {
            CornerRadius = UDim.new(1, 0),
        }),
    })

    local SliderDisplay = Creator.New("TextLabel", {
        FontFace = CelestialLibrary.Font,
        Text = "Value",
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Right,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 100, 0, 14),
        Position = UDim2.new(0, -4, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        ThemeTag = {
            TextColor3 = "SubText",
        },
    })

    local SliderInner = Creator.New("Frame", {
        Size = UDim2.new(1, 0, 0, 4),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        BackgroundTransparency = 0.4,
        Parent = SliderElement.Frame,
        ThemeTag = {
            BackgroundColor3 = "SliderRail",
        },
    }, {
        Creator.New("UICorner", {
            CornerRadius = UDim.new(1, 0),
        }),
        Creator.New("UISizeConstraint", {
            MaxSize = Vector2.new(150, math.huge),
        }),
        SliderDisplay,
        SliderFill,
        SliderRail,
    })

    Creator.AddSignal(SliderDot.InputBegan, function(Input)
        if
            Input.UserInputType == Enum.UserInputType.MouseButton1
            or Input.UserInputType == Enum.UserInputType.Touch
        then
            Dragging = true
        end
    end)

    Creator.AddSignal(SliderDot.InputEnded, function(Input)
        if
            Input.UserInputType == Enum.UserInputType.MouseButton1
            or Input.UserInputType == Enum.UserInputType.Touch
        then
            Dragging = false
        end
    end)

    Creator.AddSignal(UserInputService.InputChanged, function(Input)
        if
            Dragging
            and (
                Input.UserInputType == Enum.UserInputType.MouseMovement
                or Input.UserInputType == Enum.UserInputType.Touch
            )
        then
            local SizeScale =
                math.clamp((Input.Position.X - SliderRail.AbsolutePosition.X) / SliderRail.AbsoluteSize.X, 0, 1)
            Slider:SetValue(Slider.Min + ((Slider.Max - Slider.Min) * SizeScale))
        end
    end)

    function Slider:OnChanged(Func)
        Slider.Changed = Func
        Func(Slider.Value)
    end

    function Slider:SetValue(Value)
        self.Value = CelestialLibrary:Round(math.clamp(Value, Slider.Min, Slider.Max), Slider.Rounding)
        SliderDot.Position = UDim2.new((self.Value - Slider.Min) / (Slider.Max - Slider.Min), -7, 0.5, 0)
        SliderFill.Size = UDim2.fromScale((self.Value - Slider.Min) / (Slider.Max - Slider.Min), 1)
        SliderDisplay.Text = tostring(self.Value)

        CelestialLibrary:SafeCallback(Slider.Callback, self.Value)
        CelestialLibrary:SafeCallback(Slider.Changed, self.Value)
    end

    function Slider:Destroy()
        SliderElement.Frame:Destroy()
        CelestialLibrary.Options[Idx] = nil
    end

    Slider:SetValue(Config.Default)

    CelestialLibrary.Options[Idx] = Slider
    return Slider
end

-- Dropdown implementation
Elements.Dropdown = {}
function Elements.Dropdown:New(Idx, Config, Container)
    assert(Config.Title, "Dropdown - Missing Title")
    assert(Config.Values, "Dropdown - Missing Values")

    local Dropdown = {
        Values = Config.Values,
        Value = Config.Default,
        Multi = Config.Multi or false,
        Buttons = {},
        Opened = false,
        Type = "Dropdown",
        Callback = Config.Callback or function() end,
    }

    local DropdownElement = CreateElement(Config.Title, Config.Description, Container)
    DropdownElement.Description.Size = UDim2.new(1, -170, 0, 14)

    Dropdown.SetTitle = DropdownElement.SetTitle
    Dropdown.SetDesc = DropdownElement.SetDesc

    local DropdownDisplay = Creator.New("TextLabel", {
        FontFace = CelestialLibrary.Font,
        Text = "Value",
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -30, 0, 14),
        Position = UDim2.new(0, 8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ThemeTag = {
            TextColor3 = "Text",
        },
    })

    local DropdownIco = Creator.New("ImageLabel", {
        Image = "rbxassetid://10709790948",
        Size = UDim2.fromOffset(16, 16),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        BackgroundTransparency = 1,
        ThemeTag = {
            ImageColor3 = "SubText",
        },
    })

    local DropdownInner = Creator.New("TextButton", {
        Size = UDim2.fromOffset(160, 30),
        Position = UDim2.new(1, -10, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 0.9,
        Parent = DropdownElement.Frame,
        ThemeTag = {
            BackgroundColor3 = "DropdownFrame",
        },
    }, {
        Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 5),
        }),
        Creator.New("UIStroke", {
            Transparency = 0.5,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeTag = {
                Color = "InElementBorder",
            },
        }),
        DropdownIco,
        DropdownDisplay,
    })

    local DropdownListLayout = Creator.New("UIListLayout", {
        Padding = UDim.new(0, 3),
    })

    local DropdownScrollFrame = Creator.New("ScrollingFrame", {
        Size = UDim2.new(1, -5, 1, -10),
        Position = UDim2.fromOffset(5, 5),
        BackgroundTransparency = 1,
        BottomImage = "rbxassetid://6889812791",
        MidImage = "rbxassetid://6889812721",
        TopImage = "rbxassetid://6276641225",
        ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
        ScrollBarImageTransparency = 0.95,
        ScrollBarThickness = 4,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromScale(0, 0),
    }, {
        DropdownListLayout,
    })

    local DropdownHolderFrame = Creator.New("Frame", {
        Size = UDim2.fromScale(1, 0.6),
        ThemeTag = {
            BackgroundColor3 = "DropdownHolder",
        },
    }, {
        DropdownScrollFrame,
        Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 7),
        }),
        Creator.New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeTag = {
                Color = "DropdownBorder",
            },
        }),
        Creator.New("ImageLabel", {
            BackgroundTransparency = 1,
            Image = "http://www.roblox.com/asset/?id=5554236805",
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(23, 23, 277, 277),
            Size = UDim2.fromScale(1, 1) + UDim2.fromOffset(30, 30),
            Position = UDim2.fromOffset(-15, -15),
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = 0.1,
        }),
    })

    local DropdownHolderCanvas = Creator.New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(170, 300),
        Parent = CelestialLibrary.GUI,
        Visible = false,
    }, {
        DropdownHolderFrame,
        Creator.New("UISizeConstraint", {
            MinSize = Vector2.new(170, 0),
        }),
    })
    table.insert(CelestialLibrary.OpenFrames, DropdownHolderCanvas)

    local function RecalculateListPosition()
        local Camera = workspace.CurrentCamera
        local Add = 0
        if Camera.ViewportSize.Y - DropdownInner.AbsolutePosition.Y < DropdownHolderCanvas.AbsoluteSize.Y - 5 then
            Add = DropdownHolderCanvas.AbsoluteSize.Y
                - 5
                - (Camera.ViewportSize.Y - DropdownInner.AbsolutePosition.Y)
                + 40
        end
        DropdownHolderCanvas.Position =
            UDim2.fromOffset(DropdownInner.AbsolutePosition.X - 1, DropdownInner.AbsolutePosition.Y - 5 - Add)
    end

    local ListSizeX = 0
    local function RecalculateListSize()
        if #Dropdown.Values > 10 then
            DropdownHolderCanvas.Size = UDim2.fromOffset(ListSizeX, 392)
        else
            DropdownHolderCanvas.Size = UDim2.fromOffset(ListSizeX, DropdownListLayout.AbsoluteContentSize.Y + 10)
        end
    end

    local function RecalculateCanvasSize()
        DropdownScrollFrame.CanvasSize = UDim2.fromOffset(0, DropdownListLayout.AbsoluteContentSize.Y)
    end

    RecalculateListPosition()
    RecalculateListSize()

    Creator.AddSignal(DropdownInner:GetPropertyChangedSignal("AbsolutePosition"), RecalculateListPosition)

    Creator.AddSignal(DropdownInner.MouseButton1Click, function()
        Dropdown:Open()
    end)

    Creator.AddSignal(UserInputService.InputBegan, function(Input)
        if
            Input.UserInputType == Enum.UserInputType.MouseButton1
            or Input.UserInputType == Enum.UserInputType.Touch
        then
            local AbsPos, AbsSize = DropdownHolderFrame.AbsolutePosition, DropdownHolderFrame.AbsoluteSize
            if
                Mouse.X < AbsPos.X
                or Mouse.X > AbsPos.X + AbsSize.X
                or Mouse.Y < (AbsPos.Y - 20 - 1)
                or Mouse.Y > AbsPos.Y + AbsSize.Y
            then
                Dropdown:Close()
            end
        end
    end)

    function Dropdown:Open()
        Dropdown.Opened = true
        DropdownHolderCanvas.Visible = true
        RecalculateListPosition()
        TweenService:Create(
            DropdownHolderFrame,
            TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { Size = UDim2.fromScale(1, 1) }
        ):Play()
    end

    function Dropdown:Close()
        Dropdown.Opened = false
        DropdownHolderFrame.Size = UDim2.fromScale(1, 0.6)
        DropdownHolderCanvas.Visible = false
    end

    function Dropdown:Display()
        local Values = Dropdown.Values
        local Str = ""

        if Config.Multi then
            for Idx, Value in next, Values do
                if Dropdown.Value[Value] then
                    Str = Str .. Value .. ", "
                end
            end
            Str = Str:sub(1, #Str - 2)
        else
            Str = Dropdown.Value or ""
        end

        DropdownDisplay.Text = (Str == "" and "--" or Str)
    end

    function Dropdown:GetActiveValues()
        if Config.Multi then
            local T = {}

            for Value, Bool in next, Dropdown.Value do
                table.insert(T, Value)
            end

            return T
        else
            return Dropdown.Value and 1 or 0
        end
    end

    function Dropdown:BuildDropdownList()
        local Values = Dropdown.Values
        local Buttons = {}

        for _, Element in next, DropdownScrollFrame:GetChildren() do
            if not Element:IsA("UIListLayout") then
                Element:Destroy()
            end
        end

        local Count = 0

        for Idx, Value in next, Values do
            local Table = {}

            Count = Count + 1

            local ButtonSelector = Creator.New("Frame", {
                Size = UDim2.fromOffset(4, 14),
                BackgroundColor3 = Color3.fromRGB(76, 194, 255),
                Position = UDim2.fromOffset(-1, 16),
                AnchorPoint = Vector2.new(0, 0.5),
                ThemeTag = {
                    BackgroundColor3 = "Accent",
                },
            }, {
                Creator.New("UICorner", {
                    CornerRadius = UDim.new(0, 2),
                }),
            })

            local ButtonLabel = Creator.New("TextLabel", {
                FontFace = CelestialLibrary.Font,
                Text = Value,
                TextColor3 = Color3.fromRGB(200, 200, 200),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Position = UDim2.fromOffset(10, 0),
                Name = "ButtonLabel",
                ThemeTag = {
                    TextColor3 = "Text",
                },
            })

            local Button = Creator.New("TextButton", {
                Size = UDim2.new(1, -5, 0, 32),
                BackgroundTransparency = 1,
                ZIndex = 23,
                Text = "",
                Parent = DropdownScrollFrame,
                ThemeTag = {
                    BackgroundColor3 = "DropdownOption",
                },
            }, {
                ButtonSelector,
                ButtonLabel,
                Creator.New("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                }),
            })

            local Selected

            if Config.Multi then
                Selected = Dropdown.Value[Value]
            else
                Selected = Dropdown.Value == Value
            end

            local BackMotor, SetBackTransparency = Creator.SpringMotor(1, Button, "BackgroundTransparency")
            local SelMotor, SetSelTransparency = Creator.SpringMotor(1, ButtonSelector, "BackgroundTransparency")

            Creator.AddSignal(Button.MouseEnter, function()
                SetBackTransparency(Selected and 0.85 or 0.89)
            end)
            Creator.AddSignal(Button.MouseLeave, function()
                SetBackTransparency(Selected and 0.89 or 1)
            end)
            Creator.AddSignal(Button.MouseButton1Down, function()
                SetBackTransparency(0.92)
            end)
            Creator.AddSignal(Button.MouseButton1Up, function()
                SetBackTransparency(Selected and 0.85 or 0.89)
            end)

            function Table:UpdateButton()
                if Config.Multi then
                    Selected = Dropdown.Value[Value]
                    if Selected then
                        SetBackTransparency(0.89)
                    end
                else
                    Selected = Dropdown.Value == Value
                    SetBackTransparency(Selected and 0.89 or 1)
                end

                TweenService:Create(
                    ButtonSelector,
                    TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                    { Size = UDim2.new(0, 4, 0, Selected and 14 or 6) }
                ):Play()
                SetSelTransparency(Selected and 0 or 1)
            end

            Creator.AddSignal(ButtonLabel.InputBegan, function(Input)
                if
                    Input.UserInputType == Enum.UserInputType.MouseButton1
                    or Input.UserInputType == Enum.UserInputType.Touch
                then
                    local Try = not Selected

                    if Dropdown:GetActiveValues() == 1 and not Try and not Config.AllowNull then
                    else
                        if Config.Multi then
                            Selected = Try
                            Dropdown.Value[Value] = Selected and true or nil
                        else
                            Selected = Try
                            Dropdown.Value = Selected and Value or nil

                            for _, OtherButton in next, Buttons do
                                OtherButton:UpdateButton()
                            end
                        end

                        Table:UpdateButton()
                        Dropdown:Display()

                        CelestialLibrary:SafeCallback(Dropdown.Callback, Dropdown.Value)
                        CelestialLibrary:SafeCallback(Dropdown.Changed, Dropdown.Value)
                    end
                end
            end)

            Table:UpdateButton()
            Dropdown:Display()

            Buttons[Button] = Table
        end

        ListSizeX = 0
        for Button, Table in next, Buttons do
            if Button.ButtonLabel then
                if Button.ButtonLabel.TextBounds.X > ListSizeX then
                    ListSizeX = Button.ButtonLabel.TextBounds.X
                end
            end
        end
        ListSizeX = ListSizeX + 30

        RecalculateCanvasSize()
        RecalculateListSize()
    end

    function Dropdown:SetValues(NewValues)
        if NewValues then
            Dropdown.Values = NewValues
        end

        Dropdown:BuildDropdownList()
    end

    function Dropdown:OnChanged(Func)
        Dropdown.Changed = Func
        Func(Dropdown.Value)
    end

    function Dropdown:SetValue(Val)
        if Dropdown.Multi then
            local nTable = {}

            for Value, Bool in next, Val do
                if table.find(Dropdown.Values, Value) then
                    nTable[Value] = true
                end
            end

            Dropdown.Value = nTable
        else
            if not Val then
                Dropdown.Value = nil
            elseif table.find(Dropdown.Values, Val) then
                Dropdown.Value = Val
            end
        end

        Dropdown:BuildDropdownList()

        CelestialLibrary:SafeCallback(Dropdown.Callback, Dropdown.Value)
        CelestialLibrary:SafeCallback(Dropdown.Changed, Dropdown.Value)
    end

    function Dropdown:Destroy()
        DropdownElement.Frame:Destroy()
        CelestialLibrary.Options[Idx] = nil
    end

    Dropdown:BuildDropdownList()
    Dropdown:Display()

    local Defaults = {}

    if type(Config.Default) == "string" then
        local Idx = table.find(Dropdown.Values, Config.Default)
        if Idx then
            table.insert(Defaults, Idx)
        end
    elseif type(Config.Default) == "table" then
        for _, Value in next, Config.Default do
            local Idx = table.find(Dropdown.Values, Value)
            if Idx then
                table.insert(Defaults, Idx)
            end
        end
    elseif type(Config.Default) == "number" and Dropdown.Values[Config.Default] ~= nil then
        table.insert(Defaults, Config.Default)
    end

    if next(Defaults) then
        for i = 1, #Defaults do
            local Index = Defaults[i]
            if Config.Multi then
                Dropdown.Value[Dropdown.Values[Index]] = true
            else
                Dropdown.Value = Dropdown.Values[Index]
            end

            if not Config.Multi then
                break
            end
        end

        Dropdown:BuildDropdownList()
        Dropdown:Display()
    end

    CelestialLibrary.Options[Idx] = Dropdown
    return Dropdown
end

-- Input implementation
Elements.Input = {}
function Elements.Input:New(Idx, Config, Container)
    assert(Config.Title, "Input - Missing Title")
    Config.Callback = Config.Callback or function() end

    local Input = {
        Value = Config.Default or "",
        Numeric = Config.Numeric or false,
        Finished = Config.Finished or false,
        Callback = Config.Callback or function(Value) end,
        Type = "Input",
    }

    local InputElement = CreateElement(Config.Title, Config.Description, Container)

    Input.SetTitle = InputElement.SetTitle
    Input.SetDesc = InputElement.SetDesc

    local Textbox = CreateTextbox(InputElement.Frame, true)
    Textbox.Frame.Position = UDim2.new(1, -10, 0.5, 0)
    Textbox.Frame.AnchorPoint = Vector2.new(1, 0.5)
    Textbox.Frame.Size = UDim2.fromOffset(160, 30)
    Textbox.Input.Text = Config.Default or ""
    Textbox.Input.PlaceholderText = Config.Placeholder or ""

    local Box = Textbox.Input

    function Input:SetValue(Text)
        if Config.MaxLength and #Text > Config.MaxLength then
            Text = Text:sub(1, Config.MaxLength)
        end

        if Input.Numeric then
            if (not tonumber(Text)) and Text:len() > 0 then
                Text = Input.Value
            end
        end

        Input.Value = Text
        Box.Text = Text

        CelestialLibrary:SafeCallback(Input.Callback, Input.Value)
        CelestialLibrary:SafeCallback(Input.Changed, Input.Value)
    end

    if Input.Finished then
        Creator.AddSignal(Box.FocusLost, function(enter)
            if not enter then
                return
            end
            Input:SetValue(Box.Text)
        end)
    else
        Creator.AddSignal(Box:GetPropertyChangedSignal("Text"), function()
            Input:SetValue(Box.Text)
        end)
    end

    function Input:OnChanged(Func)
        Input.Changed = Func
        Func(Input.Value)
    end

    function Input:Destroy()
        InputElement.Frame:Destroy()
        CelestialLibrary.Options[Idx] = nil
    end

    CelestialLibrary.Options[Idx] = Input
    return Input
end

-- Colorpicker implementation
Elements.Colorpicker = {}
function Elements.Colorpicker:New(Idx, Config, Container)
    assert(Config.Title, "Colorpicker - Missing Title")
    assert(Config.Default, "AddColorPicker: Missing default value.")

    local Colorpicker = {
        Value = Config.Default,
        Transparency = Config.Transparency or 0,
        Type = "Colorpicker",
        Title = type(Config.Title) == "string" and Config.Title or "Colorpicker",
        Callback = Config.Callback or function(Color) end,
    }

    function Colorpicker:SetHSVFromRGB(Color)
        local H, S, V = Color3.toHSV(Color)
        Colorpicker.Hue = H
        Colorpicker.Sat = S
        Colorpicker.Vib = V
    end

    Colorpicker:SetHSVFromRGB(Colorpicker.Value)

    local ColorpickerElement = CreateElement(Config.Title, Config.Description, Container)

    Colorpicker.SetTitle = ColorpickerElement.SetTitle
    Colorpicker.SetDesc = ColorpickerElement.SetDesc

    local DisplayFrameColor = Creator.New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Colorpicker.Value,
        Parent = ColorpickerElement.Frame,
    }, {
        Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 4),
        }),
    })

    local DisplayFrame = Creator.New("ImageLabel", {
        Size = UDim2.fromOffset(26, 26),
        Position = UDim2.new(1, -10, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        Parent = ColorpickerElement.Frame,
        Image = "http://www.roblox.com/asset/?id=14204231522",
        ImageTransparency = 0.45,
        ScaleType = Enum.ScaleType.Tile,
        TileSize = UDim2.fromOffset(40, 40),
    }, {
        Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 4),
        }),
        DisplayFrameColor,
    })

    local function CreateColorDialog()
        local Dialog = Dialog:Create()
        Dialog.Title.Text = Colorpicker.Title
        Dialog.Root.Size = UDim2.fromOffset(430, 330)

        local Hue, Sat, Vib = Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib
        local Transparency = Colorpicker.Transparency

        local function CreateInput()
            local Box = CreateTextbox(Dialog.Root, false)
            Box.Frame.Size = UDim2.new(0, 90, 0, 32)

            return Box
        end

        local function CreateInputLabel(Text, Pos)
            return Creator.New("TextLabel", {
                FontFace = CelestialLibrary.Font,
                Text = Text,
                TextColor3 = Color3.fromRGB(240, 240, 240),
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(1, 0, 0, 32),
                Position = Pos,
                BackgroundTransparency = 1,
                Parent = Dialog.Root,
                ThemeTag = {
                    TextColor3 = "Text",
                },
            })
        end

        local function GetRGB()
            local Value = Color3.fromHSV(Hue, Sat, Vib)
            return { R = math.floor(Value.r * 255), G = math.floor(Value.g * 255), B = math.floor(Value.b * 255) }
        end

        local SatCursor = Creator.New("ImageLabel", {
            Size = UDim2.new(0, 18, 0, 18),
            ScaleType = Enum.ScaleType.Fit,
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Image = "http://www.roblox.com/asset/?id=4805639000",
        })

        local SatVibMap = Creator.New("ImageLabel", {
            Size = UDim2.fromOffset(180, 160),
            Position = UDim2.fromOffset(20, 55),
            Image = "rbxassetid://4155801252",
            BackgroundColor3 = Colorpicker.Value,
            BackgroundTransparency = 0,
            Parent = Dialog.Root,
        }, {
            Creator.New("UICorner", {
                CornerRadius = UDim.new(0, 4),
            }),
            SatCursor,
        })

        local OldColorFrame = Creator.New("Frame", {
            BackgroundColor3 = Colorpicker.Value,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = Colorpicker.Transparency,
        }, {
            Creator.New("UICorner", {
                CornerRadius = UDim.new(0, 4),
            }),
        })

        local OldColorFrameChecker = Creator.New("ImageLabel", {
            Image = "http://www.roblox.com/asset/?id=14204231522",
            ImageTransparency = 0.45,
            ScaleType = Enum.ScaleType.Tile,
            TileSize = UDim2.fromOffset(40, 40),
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(112, 220),
            Size = UDim2.fromOffset(88, 24),
            Parent = Dialog.Root,
        }, {
            Creator.New("UICorner", {
                CornerRadius = UDim.new(0, 4),
            }),
            Creator.New("UIStroke", {
                Thickness = 2,
                Transparency = 0.75,
            }),
            OldColorFrame,
        })

        local DialogDisplayFrame = Creator.New("Frame", {
            BackgroundColor3 = Colorpicker.Value,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 0,
        }, {
            Creator.New("UICorner", {
                CornerRadius = UDim.new(0, 4),
            }),
        })

        local DialogDisplayFrameChecker = Creator.New("ImageLabel", {
            Image = "http://www.roblox.com/asset/?id=14204231522",
            ImageTransparency = 0.45,
            ScaleType = Enum.ScaleType.Tile,
            TileSize = UDim2.fromOffset(40, 40),
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(20, 220),
            Size = UDim2.fromOffset(88, 24),
            Parent = Dialog.Root,
        }, {
            Creator.New("UICorner", {
                CornerRadius = UDim.new(0, 4),
            }),
            Creator.New("UIStroke", {
                Thickness = 2,
                Transparency = 0.75,
            }),
            DialogDisplayFrame,
        })

        local SequenceTable = {}

        for Color = 0, 1, 0.1 do
            table.insert(SequenceTable, ColorSequenceKeypoint.new(Color, Color3.fromHSV(Color, 1, 1)))
        end

        local HueSliderGradient = Creator.New("UIGradient", {
            Color = ColorSequence.new(SequenceTable),
            Rotation = 90,
        })

        local HueDragHolder = Creator.New("Frame", {
            Size = UDim2.new(1, 0, 1, -10),
            Position = UDim2.fromOffset(0, 5),
            BackgroundTransparency = 1,
        })

        local HueDrag = Creator.New("ImageLabel", {
            Size = UDim2.fromOffset(14, 14),
            Image = "http://www.roblox.com/asset/?id=12266946128",
            Parent = HueDragHolder,
            ThemeTag = {
                ImageColor3 = "DialogInput",
            },
        })

        local HueSlider = Creator.New("Frame", {
            Size = UDim2.fromOffset(12, 190),
            Position = UDim2.fromOffset(210, 55),
            Parent = Dialog.Root,
        }, {
            Creator.New("UICorner", {
                CornerRadius = UDim.new(1, 0),
            }),
            HueSliderGradient,
            HueDragHolder,
        })

        local HexInput = CreateInput()
        HexInput.Frame.Position = UDim2.fromOffset(Config.Transparency and 260 or 240, 55)
        CreateInputLabel("Hex", UDim2.fromOffset(Config.Transparency and 360 or 340, 55))

        local RedInput = CreateInput()
        RedInput.Frame.Position = UDim2.fromOffset(Config.Transparency and 260 or 240, 95)
        CreateInputLabel("Red", UDim2.fromOffset(Config.Transparency and 360 or 340, 95))

        local GreenInput = CreateInput()
        GreenInput.Frame.Position = UDim2.fromOffset(Config.Transparency and 260 or 240, 135)
        CreateInputLabel("Green", UDim2.fromOffset(Config.Transparency and 360 or 340, 135))

        local BlueInput = CreateInput()
        BlueInput.Frame.Position = UDim2.fromOffset(Config.Transparency and 260 or 240, 175)
        CreateInputLabel("Blue", UDim2.fromOffset(Config.Transparency and 360 or 340, 175))

        local AlphaInput
        if Config.Transparency then
            AlphaInput = CreateInput()
            AlphaInput.Frame.Position = UDim2.fromOffset(260, 215)
            CreateInputLabel("Alpha", UDim2.fromOffset(360, 215))
        end

        local TransparencySlider, TransparencyDrag, TransparencyColor
        if Config.Transparency then
            local TransparencyDragHolder = Creator.New("Frame", {
                Size = UDim2.new(1, 0, 1, -10),
                Position = UDim2.fromOffset(0, 5),
                BackgroundTransparency = 1,
            })

            TransparencyDrag = Creator.New("ImageLabel", {
                Size = UDim2.fromOffset(14, 14),
                Image = "http://www.roblox.com/asset/?id=12266946128",
                Parent = TransparencyDragHolder,
                ThemeTag = {
                    ImageColor3 = "DialogInput",
                },
            })

            TransparencyColor = Creator.New("Frame", {
                Size = UDim2.fromScale(1, 1),
            }, {
                Creator.New("UIGradient", {
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1),
                    }),
                    Rotation = 270,
                }),
                Creator.New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                }),
            })

            TransparencySlider = Creator.New("Frame", {
                Size = UDim2.fromOffset(12, 190),
                Position = UDim2.fromOffset(230, 55),
                Parent = Dialog.Root,
                BackgroundTransparency = 1,
            }, {
                Creator.New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                }),
                Creator.New("ImageLabel", {
                    Image = "http://www.roblox.com/asset/?id=14204231522",
                    ImageTransparency = 0.45,
                    ScaleType = Enum.ScaleType.Tile,
                    TileSize = UDim2.fromOffset(40, 40),
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),
                    Parent = Dialog.Root,
                }, {
                    Creator.New("UICorner", {
                        CornerRadius = UDim.new(1, 0),
                    }),
                }),
                TransparencyColor,
                TransparencyDragHolder,
            })
        end

        local function Display()
            SatVibMap.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
            HueDrag.Position = UDim2.new(0, -1, Hue, -6)
            SatCursor.Position = UDim2.new(Sat, 0, 1 - Vib, 0)
            DialogDisplayFrame.BackgroundColor3 = Color3.fromHSV(Hue, Sat, Vib)

            HexInput.Input.Text = "#" .. Color3.fromHSV(Hue, Sat, Vib):ToHex()
            RedInput.Input.Text = GetRGB()["R"]
            GreenInput.Input.Text = GetRGB()["G"]
            BlueInput.Input.Text = GetRGB()["B"]

            if Config.Transparency then
                TransparencyColor.BackgroundColor3 = Color3.fromHSV(Hue, Sat, Vib)
                DialogDisplayFrame.BackgroundTransparency = Transparency
                TransparencyDrag.Position = UDim2.new(0, -1, 1 - Transparency, -6)
                AlphaInput.Input.Text = Creator.Round((1 - Transparency) * 100, 0) .. "%"
            end
        end

        Creator.AddSignal(HexInput.Input.FocusLost, function(Enter)
            if Enter then
                local Success, Result = pcall(Color3.fromHex, HexInput.Input.Text)
                if Success and typeof(Result) == "Color3" then
                    Hue, Sat, Vib = Color3.toHSV(Result)
                end
            end
            Display()
        end)

        Creator.AddSignal(RedInput.Input.FocusLost, function(Enter)
            if Enter then
                local CurrentColor = GetRGB()
                local Success, Result = pcall(Color3.fromRGB, RedInput.Input.Text, CurrentColor["G"], CurrentColor["B"])
                if Success and typeof(Result) == "Color3" then
                    if tonumber(RedInput.Input.Text) <= 255 then
                        Hue, Sat, Vib = Color3.toHSV(Result)
                    end
                end
            end
            Display()
        end)

        Creator.AddSignal(GreenInput.Input.FocusLost, function(Enter)
            if Enter then
                local CurrentColor = GetRGB()
                local Success, Result =
                    pcall(Color3.fromRGB, CurrentColor["R"], GreenInput.Input.Text, CurrentColor["B"])
                if Success and typeof(Result) == "Color3" then
                    if tonumber(GreenInput.Input.Text) <= 255 then
                        Hue, Sat, Vib = Color3.toHSV(Result)
                    end
                end
            end
            Display()
        end)

        Creator.AddSignal(BlueInput.Input.FocusLost, function(Enter)
            if Enter then
                local CurrentColor = GetRGB()
                local Success, Result =
                    pcall(Color3.fromRGB, CurrentColor["R"], CurrentColor["G"], BlueInput.Input.Text)
                if Success and typeof(Result) == "Color3" then
                    if tonumber(BlueInput.Input.Text) <= 255 then
                        Hue, Sat, Vib = Color3.toHSV(Result)
                    end
                end
            end
            Display()
        end)

        if Config.Transparency then
            Creator.AddSignal(AlphaInput.Input.FocusLost, function(Enter)
                if Enter then
                    pcall(function()
                        local Value = tonumber(AlphaInput.Input.Text)
                        if Value >= 0 and Value <= 100 then
                            Transparency = 1 - Value * 0.01
                        end
                    end)
                end
                Display()
            end)
        end

        Creator.AddSignal(SatVibMap.InputBegan, function(Input)
            if
                Input.UserInputType == Enum.UserInputType.MouseButton1
                or Input.UserInputType == Enum.UserInputType.Touch
            then
                while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    local MinX = SatVibMap.AbsolutePosition.X
                    local MaxX = MinX + SatVibMap.AbsoluteSize.X
                    local MouseX = math.clamp(Mouse.X, MinX, MaxX)

                    local MinY = SatVibMap.AbsolutePosition.Y
                    local MaxY = MinY + SatVibMap.AbsoluteSize.Y
                    local MouseY = math.clamp(Mouse.Y, MinY, MaxY)

                    Sat = (MouseX - MinX) / (MaxX - MinX)
                    Vib = 1 - ((MouseY - MinY) / (MaxY - MinY))
                    Display()

                    RunService.RenderStepped:Wait()
                end
            end
        end)

        Creator.AddSignal(HueSlider.InputBegan, function(Input)
            if
                Input.UserInputType == Enum.UserInputType.MouseButton1
                or Input.UserInputType == Enum.UserInputType.Touch
            then
                while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    local MinY = HueSlider.AbsolutePosition.Y
                    local MaxY = MinY + HueSlider.AbsoluteSize.Y
                    local MouseY = math.clamp(Mouse.Y, MinY, MaxY)

                    Hue = ((MouseY - MinY) / (MaxY - MinY))
                    Display()

                    RunService.RenderStepped:Wait()
                end
            end
        end)

        if Config.Transparency then
            Creator.AddSignal(TransparencySlider.InputBegan, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                        local MinY = TransparencySlider.AbsolutePosition.Y
                        local MaxY = MinY + TransparencySlider.AbsoluteSize.Y
                        local MouseY = math.clamp(Mouse.Y, MinY, MaxY)

                        Transparency = 1 - ((MouseY - MinY) / (MaxY - MinY))
                        Display()

                        RunService.RenderStepped:Wait()
                    end
                end
            end)
        end

        Display()

        Dialog:Button("Done", function()
            Colorpicker:SetValue({ Hue, Sat, Vib }, Transparency)
        end)
        Dialog:Button("Cancel")
        Dialog:Open()
    end

    function Colorpicker:Display()
        Colorpicker.Value = Color3.fromHSV(Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib)

        DisplayFrameColor.BackgroundColor3 = Colorpicker.Value
        DisplayFrameColor.BackgroundTransparency = Colorpicker.Transparency

        CelestialLibrary:SafeCallback(Colorpicker.Callback, Colorpicker.Value)
        CelestialLibrary:SafeCallback(Colorpicker.Changed, Colorpicker.Value)
    end

    function Colorpicker:SetValue(HSV, Transparency)
        local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3])

        Colorpicker.Transparency = Transparency or 0
        Colorpicker:SetHSVFromRGB(Color)
        Colorpicker:Display()
    end

    function Colorpicker:SetValueRGB(Color, Transparency)
        Colorpicker.Transparency = Transparency or 0
        Colorpicker:SetHSVFromRGB(Color)
        Colorpicker:Display()
    end

    function Colorpicker:OnChanged(Func)
        Colorpicker.Changed = Func
        Func(Colorpicker.Value)
    end

    function Colorpicker:Destroy()
        ColorpickerElement.Frame:Destroy()
        CelestialLibrary.Options[Idx] = nil
    end

    Creator.AddSignal(ColorpickerElement.Frame.MouseButton1Click, function()
        CreateColorDialog()
    end)

    Colorpicker:Display()

    CelestialLibrary.Options[Idx] = Colorpicker
    return Colorpicker
end

-- Keybind implementation
Elements.Keybind = {}
function Elements.Keybind:New(Idx, Config, Container)
    assert(Config.Title, "Keybind - Missing Title")
    
    local Keybind = {
        Value = Config.Default,
        Mode = Config.Mode or "Toggle",
        Type = "Keybind",
        Callback = Config.Callback or function(Value) end,
        ChangedCallback = Config.ChangedCallback or function(Value) end,
    }
    
    local Modes = {
        Always = "Always",
        Toggle = "Toggle",
        Hold = "Hold"
    }
    
    local KeybindElement = CreateElement(Config.Title, Config.Description, Container)
    
    Keybind.SetTitle = KeybindElement.SetTitle
    Keybind.SetDesc = KeybindElement.SetDesc
    
    local KeybindDisplay = Creator.New("TextLabel", {
        FontFace = CelestialLibrary.Font,
        Text = "None",
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Center,
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        ThemeTag = {
            TextColor3 = "Text",
        },
    })
    
    local KeybindButton = Creator.New("TextButton", {
        Size = UDim2.new(0, 120, 0, 30),
        Position = UDim2.new(1, -10, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 0.9,
        Text = "",
        Parent = KeybindElement.Frame,
        ThemeTag = {
            BackgroundColor3 = "InputBackground",
        },
    }, {
        Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 5),
        }),
        Creator.New("UIStroke", {
            Transparency = 0.5,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeTag = {
                Color = "InputBorder",
            },
        }),
        KeybindDisplay,
    })
    
    local ModeSelectValue = Config.Mode or "Toggle"
    
    local ModeSelectDropdown
    if Config.AllowModeChange then
        ModeSelectDropdown = Elements.Dropdown:New("KeybindMode_" .. Idx, {
            Title = "Mode",
            Values = {"Toggle", "Hold", "Always"},
            Default = ModeSelectValue,
            Multi = false,
            AllowNull = false,
            Callback = function(Value)
                ModeSelectValue = Value
                Keybind.Mode = Value
            end
        }, Container)
        ModeSelectDropdown.SetValue(ModeSelectValue)
    end
    
    function Keybind:SetValue(Key, Mode)
        if Key == nil then
            Key = Enum.KeyCode.Unknown
        end
        
        if Key.Name == "Unknown" then
            Keybind.Value = nil
            KeybindDisplay.Text = "None"
        else
            local Name = (Key.Name ~= "Unknown" and Key.Name) or "None"
            KeybindDisplay.Text = KeyNames[Key] or Name
            Keybind.Value = Key
        end
        
        if Mode then
            ModeSelectValue = Mode
            Keybind.Mode = Mode
            if ModeSelectDropdown then
                ModeSelectDropdown.SetValue(Mode)
            end
        end
        
        CelestialLibrary:SafeCallback(Keybind.ChangedCallback, Keybind.Value)
    end
    
    function Keybind:OnClick(Callback)
        Keybind.Clicked = Callback
    end
    
    function Keybind:DoClick()
        CelestialLibrary:SafeCallback(Keybind.Callback, Keybind.Value)
        CelestialLibrary:SafeCallback(Keybind.Clicked, Keybind.Value)
    end
    
    local Listening = false
    
    Creator.AddSignal(UserInputService.InputBegan, function(Input, Processed)
        if Processed then return end
        
        if Keybind.Value and Input.KeyCode == Keybind.Value then
            if ModeSelectValue == Modes.Toggle then
                Keybind:DoClick()
            elseif ModeSelectValue == Modes.Always then
                Keybind:DoClick()
            end
        end
    end)
    
    Creator.AddSignal(UserInputService.InputEnded, function(Input)
        if Keybind.Value and Input.KeyCode == Keybind.Value then
            if ModeSelectValue == Modes.Hold then
                Keybind:DoClick()
            end
        end
    end)
    
    Creator.AddSignal(KeybindButton.MouseButton1Click, function()
        if Listening then return end
        
        Listening = true
        KeybindDisplay.Text = "..."
        
        local Connection 
        Connection = UserInputService.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.Keyboard then
                Keybind:SetValue(Input.KeyCode)
                Listening = false
                
                if Connection then 
                    Connection:Disconnect()
                end
            end
        end)
    end)
    
    Creator.AddSignal(KeybindButton.MouseButton2Click, function()
        if Listening then return end
        
        Keybind:SetValue(nil)
    end)
    
    Creator.AddSignal(KeybindButton.MouseEnter, function()
        TweenService:Create(KeybindButton, TweenInfo.new(0.1), {BackgroundTransparency = 0.8}):Play()
    end)
    
    Creator.AddSignal(KeybindButton.MouseLeave, function()
        TweenService:Create(KeybindButton, TweenInfo.new(0.1), {BackgroundTransparency = 0.9}):Play()
    end)
    
    if Config.Default then
        Keybind:SetValue(Config.Default, ModeSelectValue)
    end
    
    Keybind.Frame = KeybindElement.Frame
    CelestialLibrary.Options[Idx] = Keybind
    
    return Keybind
end

function CelestialLibrary:Create(Config)
    Config = Config or {}
    
    Config.Name = Config.Name or "Celestial UI"
    Config.Size = Config.Size or UDim2.fromOffset(600, 400)
    Config.Theme = Config.Theme or "Dark"
    Config.Acrylic = Config.Acrylic or false
    Config.Transparency = Config.Transparency or false
    Config.Font = Config.Font or "Default"
    Config.FillScreen = Config.FillScreen or false
    Config.ToggleKey = Config.ToggleKey or Enum.KeyCode.RightShift
    
    -- Set the font
    self.Font = self:GetFontFromName(Config.Font)
    self.ToggleKey = Config.ToggleKey
    
    -- Apply settings
    self:SetTheme(Config.Theme)
    self.UseAcrylic = Config.Acrylic
    self.Transparency = Config.Transparency
    
    -- Create the GUI
    local ScreenGui = Creator.New("ScreenGui", {
        Name = Config.Name,
        DisplayOrder = 100,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
    })
    
    -- Set parent
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = CoreGui
    end
    
    self.Minimized = false
    self.Toggled = true
    self.GUI = ScreenGui
    
    -- Create MainBlur
    self.MainBlur = Creator.New("BlurEffect", {
        Size = 12,
        Enabled = Config.Acrylic,
        Parent = game:GetService("Lighting"),
    })
    
    -- Create Notifications Container
    self.NotificationsFrame = Creator.New("Frame", {
        Position = UDim2.new(1, -20, 1, -20),
        Size = UDim2.new(0, 300, 1, -40),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Parent = ScreenGui,
    }, {
        Creator.New("UIListLayout", {
            Padding = UDim.new(0, 10),
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            SortOrder = Enum.SortOrder.LayoutOrder,
        })
    })
    
    -- Create Main Container
    local MainFrameSize = Config.FillScreen and UDim2.fromScale(1, 1) or Config.Size
    
    self.MainFrame = Creator.New("Frame", {
        Size = MainFrameSize,
        Position = Config.FillScreen and UDim2.fromScale(0.5, 0.5) or UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = self.Transparency and 0.2 or 0,
        Visible = self.Toggled,
        Parent = ScreenGui,
        ThemeTag = {
            BackgroundColor3 = "Primary"
        }
    }, {
        Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 8)
        }),
        Creator.New("UIStroke", {
            Thickness = 1,
            Transparency = 0.5,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeTag = {
                Color = "Border"
            }
        })
    })
    
    -- Create Header
    self.HeaderFrame = Creator.New("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        ClipsDescendants = true,
        BackgroundTransparency = 0,
        ThemeTag = {
            BackgroundColor3 = "Secondary"
        },
        Parent = self.MainFrame
    }, {
        Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 8)
        }),
        Creator.New("Frame", {
            Size = UDim2.new(1, 0, 0, 10),
            Position = UDim2.new(0, 0, 1, -5),
            ZIndex = 0,
            ThemeTag = {
                BackgroundColor3 = "Secondary"
            }
        })
    })
    
    -- Create title & subtitle
    self.TitleLabel = Creator.New("TextLabel", {
        FontFace = self.Font,
        Text = Config.Name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        ThemeTag = {
            TextColor3 = "Text"
        },
        Parent = self.HeaderFrame
    })
    
    -- Create buttons
    local ButtonHolder = Creator.New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -10, 0, 0),
        Size = UDim2.new(0, 120, 1, 0),
        AnchorPoint = Vector2.new(1, 0),
        Parent = self.HeaderFrame
    }, {
        Creator.New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8)
        })
    })
    
    -- Create minimize button
    self.MinimizeButton = Creator.New("ImageButton", {
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Image = "rbxassetid://10709790907",
        Size = UDim2.fromOffset(16, 16),
        ThemeTag = {
            ImageColor3 = "SubText"
        },
        Parent = ButtonHolder
    })
    
    -- Create close button
    self.CloseButton = Creator.New("ImageButton", {
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Image = "rbxassetid://10709790763",
        Size = UDim2.fromOffset(16, 16),
        ThemeTag = {
            ImageColor3 = "SubText"
        },
        Parent = ButtonHolder
    })
    
    -- Create TabContainer
    self.TabContainer = Creator.New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(1, 0, 1, -50),
        ZIndex = 2,
        Parent = self.MainFrame
    })
    
    -- Handle buttons events
    Creator.AddSignal(self.MinimizeButton.MouseButton1Click, function()
        self:Minimize()
    end)
    
    Creator.AddSignal(self.CloseButton.MouseButton1Click, function()
        self:Toggle()
    end)
    
    -- Make Header draggable
    local Dragging = false
    local DragStart = nil
    local StartPosition = nil
    
    Creator.AddSignal(self.HeaderFrame.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = Input.Position
            StartPosition = self.MainFrame.Position
        end
    end)
    
    Creator.AddSignal(UserInputService.InputChanged, function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            local Delta = Input.Position - DragStart
            self.MainFrame.Position = UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale,
                StartPosition.Y.Offset + Delta.Y
            )
        end
    end)
    
    Creator.AddSignal(UserInputService.InputEnded, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end)
    
    -- Handle toggling
    Creator.AddSignal(UserInputService.InputBegan, function(Input)
        if Input.KeyCode == self.ToggleKey then
            self:Toggle()
        end
        
        if Input.KeyCode == self.MinimizeKey then
            self:Minimize()
        end
    end)
    
    -- Create Tablist
    self.TabList = Creator.New("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 0,
        Parent = self.TabContainer,
        ThemeTag = {
            BackgroundColor3 = "Secondary"
        }
    }, {
        Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 6)
        }),
        Creator.New("UIStroke", {
            Thickness = 1,
            Transparency = 0.5,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeTag = {
                Color = "Border"
            }
        }),
        Creator.New("ScrollingFrame", {
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            Active = true,
            BackgroundTransparency = 1,
            ScrollBarImageTransparency = 1,
            ScrollBarThickness = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        }, {
            Creator.New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4)
            })
        })
    })
    
    -- Create TabDisplay
    self.TabDisplay = Creator.New("Frame", {
        Size = UDim2.new(1, 0, 1, -36),
        Position = UDim2.new(0, 0, 0, 36),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = self.TabContainer
    })
    
    return self
end
