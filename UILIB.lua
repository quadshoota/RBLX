-- Nova UI Library
-- A lightweight, reliable UI library for Roblox scripts

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local NovaLibrary = {}
local NovaUI = {}
NovaUI.__index = NovaUI

-- Constants
local TWEEN_SPEED = 0.25
local FONT_SIZE = 14
local DEFAULT_FONT = Font.new("rbxasset://fonts/families/GothamSSm.json")

-- Themes
NovaLibrary.Themes = {
    Dark = {
        Background = Color3.fromRGB(30, 30, 35),
        Container = Color3.fromRGB(40, 40, 45),
        Button = Color3.fromRGB(45, 45, 50),
        ButtonHover = Color3.fromRGB(55, 55, 60),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(180, 180, 180),
        Accent = Color3.fromRGB(100, 120, 255),
        Border = Color3.fromRGB(60, 60, 65),
        Slider = Color3.fromRGB(70, 70, 75),
        Toggle = Color3.fromRGB(50, 50, 55),
        ToggleAccent = Color3.fromRGB(100, 120, 255),
        Dropdown = Color3.fromRGB(45, 45, 50),
        DropdownOption = Color3.fromRGB(50, 50, 55),
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 245),
        Container = Color3.fromRGB(230, 230, 235),
        Button = Color3.fromRGB(220, 220, 225),
        ButtonHover = Color3.fromRGB(210, 210, 215),
        Text = Color3.fromRGB(30, 30, 35),
        SubText = Color3.fromRGB(80, 80, 85),
        Accent = Color3.fromRGB(80, 100, 230),
        Border = Color3.fromRGB(200, 200, 205),
        Slider = Color3.fromRGB(200, 200, 205),
        Toggle = Color3.fromRGB(220, 220, 225),
        ToggleAccent = Color3.fromRGB(80, 100, 230),
        Dropdown = Color3.fromRGB(220, 220, 225),
        DropdownOption = Color3.fromRGB(210, 210, 215),
    },
    Ocean = {
        Background = Color3.fromRGB(20, 30, 40),
        Container = Color3.fromRGB(30, 40, 55),
        Button = Color3.fromRGB(35, 45, 60),
        ButtonHover = Color3.fromRGB(45, 55, 70),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(180, 190, 200),
        Accent = Color3.fromRGB(65, 145, 225),
        Border = Color3.fromRGB(45, 55, 70),
        Slider = Color3.fromRGB(50, 60, 75),
        Toggle = Color3.fromRGB(40, 50, 65),
        ToggleAccent = Color3.fromRGB(65, 145, 225),
        Dropdown = Color3.fromRGB(35, 45, 60),
        DropdownOption = Color3.fromRGB(40, 50, 65),
    },
    Crimson = {
        Background = Color3.fromRGB(40, 25, 30),
        Container = Color3.fromRGB(50, 30, 35),
        Button = Color3.fromRGB(60, 35, 40),
        ButtonHover = Color3.fromRGB(70, 40, 45),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(200, 180, 180),
        Accent = Color3.fromRGB(225, 65, 85),
        Border = Color3.fromRGB(70, 45, 50),
        Slider = Color3.fromRGB(75, 50, 55),
        Toggle = Color3.fromRGB(65, 40, 45),
        ToggleAccent = Color3.fromRGB(225, 65, 85),
        Dropdown = Color3.fromRGB(60, 35, 40),
        DropdownOption = Color3.fromRGB(65, 40, 45),
    }
}

-- Utility Functions
local function Create(instanceType)
    return function(properties, children)
        local instance = Instance.new(instanceType)
        
        for property, value in pairs(properties or {}) do
            instance[property] = value
        end
        
        for _, child in ipairs(children or {}) do
            child.Parent = instance
        end
        
        return instance
    end
end

local function ApplyTheme(instance, themeColor, theme)
    if theme and NovaLibrary.Themes[theme] and NovaLibrary.Themes[theme][themeColor] then
        return NovaLibrary.Themes[theme][themeColor]
    end
    return instance
end

local function Tween(instance, properties, duration)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or TWEEN_SPEED, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

local function GetTextSize(text, fontSize, font)
    return TextService:GetTextSize(text, fontSize or FONT_SIZE, font or DEFAULT_FONT, Vector2.new(1000, 1000))
end

-- Main UI Creation
function NovaLibrary.new(config)
    config = config or {}
    
    local Nova = setmetatable({
        Name = config.Name or "Nova UI",
        Theme = config.Theme or "Dark",
        Font = config.Font or DEFAULT_FONT,
        ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift,
        Tabs = {},
        Elements = {},
        Connections = {},
        Flags = {},
    }, NovaUI)
    
    -- Create GUI
    local screenGui = Create "ScreenGui" {
        Name = Nova.Name,
        DisplayOrder = 100,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
    }
    
    -- Set parent based on environment
    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
        screenGui.Parent = CoreGui
    elseif gethui then
        screenGui.Parent = gethui()
    else
        screenGui.Parent = CoreGui
    end
    
    Nova.ScreenGui = screenGui
    
    -- Create Main Frame
    local mainFrame = Create "Frame" {
        Name = "MainFrame",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = ApplyTheme("Background", Nova.Theme),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(config.Width or 600, config.Height or 400),
    }
    
    -- Add corner and stroke
    local corner = Create "UICorner" {
        CornerRadius = UDim.new(0, 6),
        Parent = mainFrame
    }
    
    local stroke = Create "UIStroke" {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = ApplyTheme("Border", Nova.Theme),
        Thickness = 1,
        Parent = mainFrame
    }
    
    Nova.MainFrame = mainFrame
    mainFrame.Parent = screenGui
    
    -- Create Header
    local header = Create "Frame" {
        Name = "Header",
        BackgroundColor3 = ApplyTheme("Container", Nova.Theme),
        Size = UDim2.new(1, 0, 0, 40),
        Parent = mainFrame
    }
    
    Create "UICorner" {
        CornerRadius = UDim.new(0, 6),
        Parent = header
    }
    
    -- Fix corner radius at bottom of header
    Create "Frame" {
        BackgroundColor3 = ApplyTheme("Container", Nova.Theme),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -6),
        Size = UDim2.new(1, 0, 0, 6),
        Parent = header
    }
    
    -- Header Title
    local title = Create "TextLabel" {
        BackgroundTransparency = 1,
        Font = Nova.Font,
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Text = Nova.Name,
        TextColor3 = ApplyTheme("Text", Nova.Theme),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    }
    
    -- Header Buttons
    local buttonHolder = Create "Frame" {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -70, 0, 0),
        Size = UDim2.new(0, 70, 1, 0),
        Parent = header
    }
    
    Create "UIListLayout" {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 5),
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Parent = buttonHolder
    }
    
    -- Minimize Button
    local minimizeButton = Create "ImageButton" {
        BackgroundTransparency = 1,
        Image = "rbxassetid://7072718362", -- General minimize icon
        Size = UDim2.fromOffset(24, 24),
        ImageColor3 = ApplyTheme("SubText", Nova.Theme),
        Parent = buttonHolder
    }
    
    -- Close Button
    local closeButton = Create "ImageButton" {
        BackgroundTransparency = 1,
        Image = "rbxassetid://7072725342", -- General close icon
        Size = UDim2.fromOffset(24, 24),
        ImageColor3 = ApplyTheme("SubText", Nova.Theme),
        Parent = buttonHolder
    }
    
    -- Make header draggable
    local isDragging = false
    local dragStart = nil
    local startPos = nil
    
    Nova:AddConnection(header.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    Nova:AddConnection(UserInputService.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and isDragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    Nova:AddConnection(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
    
    -- Content Frame
    local contentFrame = Create "Frame" {
        BackgroundColor3 = ApplyTheme("Background", Nova.Theme),
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 1, -40),
        Parent = mainFrame
    }
    
    -- Tab Container
    local tabContainer = Create "Frame" {
        BackgroundColor3 = ApplyTheme("Container", Nova.Theme),
        Size = UDim2.new(1, 0, 0, 36),
        Parent = contentFrame
    }
    
    Create "UICorner" {
        CornerRadius = UDim.new(0, 6),
        Parent = tabContainer
    }
    
    local tabButtonHolder = Create "ScrollingFrame" {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(8, 0),
        Size = UDim2.new(1, -16, 1, 0),
        CanvasSize = UDim2.fromScale(0, 1),
        ScrollBarThickness = 0,
        Parent = tabContainer
    }
    
    -- Tab button layout
    Create "UIListLayout" {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Parent = tabButtonHolder
    }
    
    -- Tab Content Container
    local tabContentContainer = Create "Frame" {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 44),
        Size = UDim2.new(1, 0, 1, -44),
        Parent = contentFrame
    }
    
    Nova.Header = header
    Nova.Title = title
    Nova.MinimizeButton = minimizeButton
    Nova.CloseButton = closeButton
    Nova.ContentFrame = contentFrame
    Nova.TabContainer = tabContainer
    Nova.TabButtonHolder = tabButtonHolder
    Nova.TabContentContainer = tabContentContainer
    
    -- Handle minimize button
    Nova:AddConnection(minimizeButton.MouseButton1Click, function()
        Nova:Minimize()
    end)
    
    -- Handle close button
    Nova:AddConnection(closeButton.MouseButton1Click, function()
        Nova:Toggle()
    end)
    
    -- Handle toggle key
    Nova:AddConnection(UserInputService.InputBegan, function(input)
        if input.KeyCode == Nova.ToggleKey then
            Nova:Toggle()
        end
    end)
    
    return Nova
end

-- Add connection management
function NovaUI:AddConnection(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(self.Connections, connection)
    return connection
end

-- UI Behaviors
function NovaUI:Toggle()
    self.MainFrame.Visible = not self.MainFrame.Visible
end

function NovaUI:Minimize()
    if self.Minimized then
        Tween(self.MainFrame, {Size = self.OriginalSize}, 0.3)
    else
        self.OriginalSize = self.MainFrame.Size
        Tween(self.MainFrame, {Size = UDim2.new(self.MainFrame.Size.X.Scale, self.MainFrame.Size.X.Offset, 0, 40)}, 0.3)
    end
    
    self.Minimized = not self.Minimized
    
    -- Hide content
    self.ContentFrame.Visible = not self.Minimized
end

-- Add a notification
function NovaUI:Notify(options)
    options = options or {}
    local title = options.Title or "Notification"
    local content = options.Content or ""
    local duration = options.Duration or 5
    
    -- Create notification container if needed
    if not self.NotificationHolder then
        self.NotificationHolder = Create "Frame" {
            AnchorPoint = Vector2.new(1, 1),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -20, 1, -20),
            Size = UDim2.new(0, 280, 1, -40),
            Parent = self.ScreenGui
        }
        
        Create "UIListLayout" {
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            Padding = UDim.new(0, 10),
            Parent = self.NotificationHolder
        }
    end
    
    -- Create notification
    local notifHeight = content ~= "" and 80 or 50
    
    local notification = Create "Frame" {
        BackgroundColor3 = ApplyTheme("Container", self.Theme),
        Size = UDim2.new(0, 0, 0, notifHeight),
        BackgroundTransparency = 0,
        Parent = self.NotificationHolder
    }
    
    Create "UICorner" {
        CornerRadius = UDim.new(0, 6),
        Parent = notification
    }
    
    Create "UIStroke" {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = ApplyTheme("Border", self.Theme),
        Thickness = 1,
        Parent = notification
    }
    
    local titleLabel = Create "TextLabel" {
        BackgroundTransparency = 1,
        Font = self.Font,
        Position = UDim2.fromOffset(10, 8),
        Size = UDim2.new(1, -20, 0, 20),
        Text = title,
        TextColor3 = ApplyTheme("Text", self.Theme),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notification
    }
    
    if content ~= "" then
        local contentLabel = Create "TextLabel" {
            BackgroundTransparency = 1,
            Font = self.Font,
            Position = UDim2.fromOffset(10, 30),
            Size = UDim2.new(1, -20, 0, 40),
            Text = content,
            TextColor3 = ApplyTheme("SubText", self.Theme),
            TextSize = 14,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Parent = notification
        }
    end
    
    -- Animate in
    Tween(notification, {Size = UDim2.new(1, 0, 0, notifHeight)}, 0.3)
    
    -- Animate out after duration
    task.delay(duration, function()
        Tween(notification, {Size = UDim2.new(0, 0, 0, notifHeight)}, 0.3).Completed:Connect(function()
            notification:Destroy()
        end)
    end)
    
    return notification
end

-- Tab Creation
function NovaUI:AddTab(name, icon)
    -- Create tab button
    local tabButton = Create "TextButton" {
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Font = self.Font,
        LayoutOrder = #self.Tabs + 1,
        Size = UDim2.new(0, 120, 1, -10),
        Text = name,
        TextColor3 = ApplyTheme("SubText", self.Theme),
        TextSize = 14,
        Parent = self.TabButtonHolder
    }
    
    if icon then
        local iconImage = Create "ImageLabel" {
            BackgroundTransparency = 1,
            Image = icon,
            Position = UDim2.fromOffset(5, 0),
            Size = UDim2.fromOffset(16, 16),
            AnchorPoint = Vector2.new(0, 0.5),
            ImageColor3 = ApplyTheme("SubText", self.Theme),
            Parent = tabButton
        }
        
        tabButton.Text = "   " .. tabButton.Text
    end
    
    -- Create tab content
    local tabContent = Create "ScrollingFrame" {
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.fromScale(0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = ApplyTheme("SubText", self.Theme),
        ScrollBarImageTransparency = 0.5,
        Visible = false,
        Parent = self.TabContentContainer
    }
    
    -- Setup padding and layout for sections
    Create "UIPadding" {
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        Parent = tabContent
    }
    
    local listLayout = Create "UIListLayout" {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabContent
    }
    
    -- Update canvas size when elements change
    self:AddConnection(listLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        tabContent.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Create tab object
    local tab = {
        Name = name,
        Button = tabButton,
        Container = tabContent,
        Sections = {},
    }
    
    -- Select this tab if it's the first
    if #self.Tabs == 0 then
        tabContent.Visible = true
        tabButton.TextColor3 = ApplyTheme("Accent", self.Theme)
        self.SelectedTab = tab
    end
    
    -- Tab selection behavior
    self:AddConnection(tabButton.MouseButton1Click, function()
        self:SelectTab(tab)
    end)
    
    -- Add tab functions
    function tab:AddSection(title)
        return self.UI:AddSection(self, title)
    end
    
    tab.UI = self
    table.insert(self.Tabs, tab)
    
    return tab
end

function NovaUI:SelectTab(tab)
    if self.SelectedTab == tab then return end
    
    -- Hide all tab contents
    for _, t in ipairs(self.Tabs) do
        t.Container.Visible = false
        t.Button.TextColor3 = ApplyTheme("SubText", self.Theme)
        
        -- Also update icon if present
        for _, child in ipairs(t.Button:GetChildren()) do
            if child:IsA("ImageLabel") then
                child.ImageColor3 = ApplyTheme("SubText", self.Theme)
            end
        end
    end
    
    -- Show selected tab
    tab.Container.Visible = true
    tab.Button.TextColor3 = ApplyTheme("Accent", self.Theme)
    
    -- Update icon if present
    for _, child in ipairs(tab.Button:GetChildren()) do
        if child:IsA("ImageLabel") then
            child.ImageColor3 = ApplyTheme("Accent", self.Theme)
        end
    end
    
    self.SelectedTab = tab
end

-- Section Creation
function NovaUI:AddSection(tab, title)
    -- Create section container
    local section = Create "Frame" {
        BackgroundColor3 = ApplyTheme("Container", self.Theme),
        Size = UDim2.new(1, 0, 0, 36), -- Will be updated as elements are added
        Parent = tab.Container
    }
    
    Create "UICorner" {
        CornerRadius = UDim.new(0, 6),
        Parent = section
    }
    
    Create "UIStroke" {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = ApplyTheme("Border", self.Theme),
        Thickness = 1,
        Parent = section
    }
    
    -- Section title
    local sectionTitle = Create "TextLabel" {
        BackgroundTransparency = 1,
        Font = self.Font,
        Position = UDim2.fromOffset(10, 8),
        Size = UDim2.new(1, -20, 0, 20),
        Text = title,
        TextColor3 = ApplyTheme("Text", self.Theme),
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section
    }
    
    -- Container for elements
    local elementContainer = Create "Frame" {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(10, 36),
        Size = UDim2.new(1, -20, 0, 0), -- Will be updated as elements are added
        Parent = section
    }
    
    local listLayout = Create "UIListLayout" {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = elementContainer
    }
    
    -- Update section size when elements change
    self:AddConnection(listLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        elementContainer.Size = UDim2.new(1, -20, 0, listLayout.AbsoluteContentSize.Y)
        section.Size = UDim2.new(1, 0, 0, elementContainer.Size.Y.Offset + 46)
    end)
    
    -- Create section object
    local sectionObj = {
        Title = title,
        Container = elementContainer,
        Frame = section,
        Elements = {}
    }
    
    -- Add section functions
    function sectionObj:AddButton(options)
        return self.UI:AddButton(self, options)
    end
    
    function sectionObj:AddToggle(id, options)
        return self.UI:AddToggle(self, id, options)
    end
    
    function sectionObj:AddSlider(id, options)
        return self.UI:AddSlider(self, id, options)
    end
    
    function sectionObj:AddDropdown(id, options)
        return self.UI:AddDropdown(self, id, options)
    end
    
    function sectionObj:AddLabel(text)
        return self.UI:AddLabel(self, text)
    end
    
    function sectionObj:AddInput(id, options)
        return self.UI:AddInput(self, id, options)
    end
    
    function sectionObj:AddColorPicker(id, options)
        return self.UI:AddColorPicker(self, id, options)
    end
    
    function sectionObj:AddKeybind(id, options)
        return self.UI:AddKeybind(self, id, options)
    end
    
    sectionObj.UI = self
    table.insert(tab.Sections, sectionObj)
    
    return sectionObj
end

-- Element Creation
function NovaUI:AddButton(section, options)
    options = options or {}
    
    -- Create button container
    local container = Create "Frame" {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 32),
        Parent = section.Container
    }
    
    -- Create title
    local title = Create "TextLabel" {
        BackgroundTransparency = 1,
        Font = self.Font,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Text = options.Title or "Button",
        TextColor3 = ApplyTheme("Text", self.Theme),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    }
    
    -- Create button
    local button = Create "TextButton" {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = ApplyTheme("Button", self.Theme),
        Font = self.Font,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 120, 0, 26),
        Text = options.Text or "Click",
        TextColor3 = ApplyTheme("Text", self.Theme),
        TextSize = 14,
        AutoButtonColor = false,
        Parent = container
    }
    
    Create "UICorner" {
        CornerRadius = UDim.new(0, 4),
        Parent = button
    }
    
    Create "UIStroke" {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = ApplyTheme("Border", self.Theme),
        Thickness = 1,
        Parent = button
    }
    
    -- Button hover and click effects
    local buttonColor = ApplyTheme("Button", self.Theme)
    local hoverColor = ApplyTheme("ButtonHover", self.Theme)
    
    self:AddConnection(button.MouseEnter, function()
        Tween(button, {BackgroundColor3 = hoverColor})
    end)
    
    self:AddConnection(button.MouseLeave, function()
        Tween(button, {BackgroundColor3 = buttonColor})
    end)
    
    self:AddConnection(button.MouseButton1Down, function()
        Tween(button, {BackgroundColor3 = buttonColor})
    end)
    
    self:AddConnection(button.MouseButton1Up, function()
        Tween(button, {BackgroundColor3 = hoverColor})
    end)
    
    -- Click callback
    self:AddConnection(button.MouseButton1Click, function()
        if options.Callback then
            options.Callback()
        end
    end)
    
    -- Create button object
    local buttonObj = {
        Type = "Button",
        Title = title,
        Button = button,
        SetTitle = function(_, text)
            title.Text = text
        end,
        SetText = function(_, text)
            button.Text = text
        end
    }
    
    return buttonObj
end

function NovaUI:AddToggle(section, id, options)
    options = options or {}
    local default = options.Default == true
    
    -- Create toggle container
    local container = Create "Frame" {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 32),
        Parent = section.Container
    }
    
    -- Title
    local title = Create "TextLabel" {
        BackgroundTransparency = 1,
        Font = self.Font,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Text = options.Title or "Toggle",
        TextColor3 = ApplyTheme("Text", self.Theme),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    }
    
    -- Description
    if options.Description then
        container.Size = UDim2.new(1, 0, 0, 42)
        
        local description = Create "TextLabel" {
            BackgroundTransparency = 1,
            Font = self.Font,
            Position = UDim2.fromOffset(0, 22),
            Size = UDim2.new(0.7, 0, 0, 14),
            Text = options.Description,
            TextColor3 = ApplyTheme("SubText", self.Theme),
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        }
    end
    
    -- Toggle background
    local toggleBackground = Create "Frame" {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = ApplyTheme("Toggle", self.Theme),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 40, 0, 20),
        Parent = container
    }
    
    Create "UICorner" {
        CornerRadius = UDim.new(1, 0),
        Parent = toggleBackground
    }
    
    Create "UIStroke" {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = ApplyTheme("Border", self.Theme),
        Thickness = 1,
        Parent = toggleBackground
    }
    
    -- Toggle circle
    local toggleCircle = Create "Frame" {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Position = UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.new(0, 16, 0, 16),
        Parent = toggleBackground
    }
    
    Create "UICorner" {
        CornerRadius = UDim.new(1, 0),
        Parent = toggleCircle
    }
    
    -- Create toggle object
    local toggle = {
        Type = "Toggle",
        Title = title,
        Background = toggleBackground,
        Circle = toggleCircle,
        Container = container,
        Value = default,
        Callback = options.Callback,
        SetValue = function(self, value)
            self.Value = value
            
            Tween(self.Circle, {
                Position = UDim2.new(0, value and 22 or 2, 0.5, 0)
            })
            
            Tween(self.Background, {
                BackgroundColor3 = value and ApplyTheme("ToggleAccent", self.UI.Theme) or ApplyTheme("Toggle", self.UI.Theme)
            })
            
            if self.Callback then
                self.Callback(value)
            end
            
            self.UI.Flags[id] = value
        end,
        Toggle = function(self)
            self:SetValue(not self.Value)
        end,
        SetTitle = function(self, text)
            self.Title.Text = text
        end
    }
    
    -- Toggle behavior
    self:AddConnection(toggleBackground.MouseButton1Click, function()
        toggle:Toggle()
    end)
    
    -- Initialize
    toggle.UI = self
    self.Flags[id] = default
    toggle:SetValue(default)
    
    return toggle
end

function NovaUI:AddSlider(section, id, options)
    options = options or {}
    
    local min = options.Min or 0
    local max = options.Max or 100
    local default = math.clamp(options.Default or min, min, max)
    local rounding = options.Rounding or 1
    
    -- Create slider container
    local container = Create "Frame" {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = section.Container
    }
    
    -- Title and value
    local titleValue = Create "TextLabel" {
        BackgroundTransparency = 1,
        Font = self.Font,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 20),
        Text = options.Title .. ": " .. default,
        TextColor3 = ApplyTheme("Text", self.Theme),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    }
    
    -- Description
    if options.Description then
        container.Size = UDim2.new(1, 0, 0, 54)
        
        local description = Create "TextLabel" {
            BackgroundTransparency = 1,
            Font = self.Font,
            Position = UDim2.fromOffset(0, 22),
            Size = UDim2.new(1, 0, 0, 14),
            Text = options.Description,
            TextColor3 = ApplyTheme("SubText", self.Theme),
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        }
        
        titleValue.Position = UDim2.fromOffset(0, 0)
    else
        titleValue.Position = UDim2.fromOffset(0, 0)
    end
    
    -- Slider background
    local sliderBackground = Create "Frame" {
        BackgroundColor3 = ApplyTheme("Slider", self.Theme),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -10),
        Size = UDim2.new(1, 0, 0, 6),
        Parent = container
    }
    
    Create "UICorner" {
        CornerRadius = UDim.new(1, 0),
        Parent = sliderBackground
    }
    
    -- Slider fill
    local sliderFill = Create "Frame" {
        BackgroundColor3 = ApplyTheme("Accent", self.Theme),
        BorderSizePixel = 0,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        Parent = sliderBackground
    }
    
    Create "UICorner" {
        CornerRadius = UDim.new(1, 0),
        Parent = sliderFill
    }
    
    -- Slider circle
    local sliderCircle = Create "Frame" {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        ZIndex = 2,
        Parent = sliderBackground
    }
    
    Create "UICorner" {
        CornerRadius = UDim.new(1, 0),
        Parent = sliderCircle
    }
    
    Create "UIStroke" {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = ApplyTheme("Border", self.Theme),
        Thickness = 1,
        Parent = sliderCircle
    }
    
    -- Create slider object
    local slider = {
        Type = "Slider",
        Title = titleValue,
        Background = sliderBackground,
        Fill = sliderFill,
        Circle = sliderCircle,
        Container = container,
        Min = min,
        Max = max,
        Value = default,
        Rounding = rounding,
        Callback = options.Callback,
        SetValue = function(self, value)
            value = math.clamp(value, self.Min, self.Max)
            
            if self.Rounding then
                value = math.floor(value / self.Rounding + 0.5) * self.Rounding
            end
            
            self.Value = value
            
            -- Update UI
            local percent = (value - self.Min) / (self.Max - self.Min)
            
            self.Fill.Size = UDim2.new(percent, 0, 1, 0)
            self.Circle.Position = UDim2.new(percent, 0, 0.5, 0)
            self.Title.Text = options.Title .. ": " .. value
            
            if self.Callback then
                self.Callback(value)
            end
            
            self.UI.Flags[id] = value
        end
    }
    
    -- Slider behavior
    local isDragging = false
    
    self:AddConnection(sliderBackground.MouseButton1Down, function()
        isDragging = true
    end)
    
    self:AddConnection(sliderCircle.MouseButton1Down, function()
        isDragging = true
    end)
    
    self:AddConnection(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    self:AddConnection(UserInputService.InputChanged, function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position.X
            local framePos = sliderBackground.AbsolutePosition.X
            local frameSize = sliderBackground.AbsoluteSize.X
            
            local relativePos = (mousePos - framePos) / frameSize
            local value = min + ((max - min) * relativePos)
            
            slider:SetValue(value)
        end
    end)
    
    -- Initialize
    slider.UI = self
    self.Flags[id] = default
    slider:SetValue(default)
    
    return slider
end

function NovaUI:AddDropdown(section, id, options)
    options = options or {}
    
    local values = options.Values or {}
    local default = options.Default
    local multiSelect = options.Multi == true
    
    -- Create dropdown container
    local container = Create "Frame" {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = section.Container
    }
    
    -- Title
    local title = Create "TextLabel" {
        BackgroundTransparency = 1,
        Font = self.Font,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 20),
        Text = options.Title or "Dropdown",
        TextColor3 = ApplyTheme("Text", self.Theme),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    }
    
    -- Description
    if options.Description then
        container.Size = UDim2.new(1, 0, 0, 50)
        
        local description = Create "TextLabel" {
            BackgroundTransparency = 1,
            Font = self.Font,
            Position = UDim2.fromOffset(0, 22),
            Size = UDim2.new(1, -140, 0, 14),
            Text = options.Description,
            TextColor3 = ApplyTheme("SubText", self.Theme),
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        }
    end
    
    -- Create dropdown button
    local dropdownButton = Create "TextButton" {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = ApplyTheme("Dropdown", self.Theme),
        Font = self.Font,
        Position = UDim2.new(1, 0, 1, 0),
        Size = UDim2.new(0, 140, 0, 30),
        Text = "Select...",
        TextColor3 = ApplyTheme("Text", self.Theme),
        TextSize = 14,
        AutoButtonColor = false,
        ClipsDescendants = true,
        Parent = container
    }
    
    Create "UICorner" {
        CornerRadius = UDim.new(0, 4),
        Parent = dropdownButton
    }
    
    Create "UIStroke" {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = ApplyTheme("Border", self.Theme),
        Thickness = 1,
        Parent = dropdownButton
    }
    
    -- Dropdown arrow
    local dropdownArrow = Create "ImageLabel" {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://7072706796", -- Down arrow
        Position = UDim2.new(1, -5, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        ImageColor3 = ApplyTheme("SubText", self.Theme),
        Parent = dropdownButton
    }
    
    -- Create dropdown list
    local dropdownList = Create "Frame" {
        BackgroundColor3 = ApplyTheme("Dropdown", self.Theme),
        Position = UDim2.fromOffset(dropdownButton.AbsolutePosition.X, dropdownButton.AbsolutePosition.Y + 30),
        Size = UDim2.new(0, 140, 0, 0),
        Visible = false,
        ZIndex = 10,
        Parent = self.ScreenGui
    }
    
    Create "UICorner" {
        CornerRadius = UDim.new(0, 4),
        Parent = dropdownList
    }
    
    Create "UIStroke" {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = ApplyTheme("Border", self.Theme),
        Thickness = 1,
        Parent = dropdownList
    }
    
    local dropdownScroll = Create "ScrollingFrame" {
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(5, 5),
        Size = UDim2.new(1, -10, 1, -10),
        CanvasSize = UDim2.fromScale(0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = ApplyTheme("SubText", self.Theme),
        ScrollBarImageTransparency = 0.5,
        ZIndex = 10,
        Parent = dropdownList
    }
    
    local listLayout = Create "UIListLayout" {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = dropdownScroll
    }
    
    -- Create dropdown object
    local dropdown = {
        Type = "Dropdown",
        Title = title,
        Button = dropdownButton,
        List = dropdownList,
        Scroll = dropdownScroll,
        Container = container,
        Values = values,
        Selected = multiSelect and {} or default,
        Multi = multiSelect,
        AllowNull = options.AllowNull == true,
        Callback = options.Callback,
        Open = false,
        
        SetValues = function(self, newValues)
            self.Values = newValues
            self:Refresh()
        end,
        
        SetValue = function(self, value)
            if self.Multi then
                -- For multi-select
                self.Selected = value or {}
            else
                -- For single select
                self.Selected = value
            end
            
            self:UpdateText()
            
            if self.Callback then
                self.Callback(self.Selected)
            end
            
            self.UI.Flags[id] = self.Selected
        end,
        
        UpdateText = function(self)
            local selected = self.Selected
            
            if self.Multi then
                local count = 0
                for _ in pairs(selected) do count = count + 1 end
                
                if count == 0 then
                    self.Button.Text = "Select..."
                elseif count == 1 then
                    for value, _ in pairs(selected) do
                        self.Button.Text = value
                        break
                    end
                else
                    self.Button.Text = count .. " selected"
                end
            else
                self.Button.Text = selected or "Select..."
            end
        end,
        
        Refresh = function(self)
            -- Clear existing options
            for _, child in ipairs(self.Scroll:GetChildren()) do
                if not child:IsA("UIListLayout") then
                    child:Destroy()
                end
            end
            
            -- Add options
            for _, value in ipairs(self.Values) do
                local option = Create "TextButton" {
                    BackgroundColor3 = ApplyTheme("DropdownOption", self.UI.Theme),
                    Font = self.UI.Font,
                    Size = UDim2.new(1, 0, 0, 24),
                    Text = value,
                    TextColor3 = ApplyTheme("Text", self.UI.Theme),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    ZIndex = 10,
                    Parent = self.Scroll
                }
                
                Create "UIPadding" {
                    PaddingLeft = UDim.new(0, 8),
                    Parent = option
                }
                
                -- Selection indicator
                local selected = false
                
                if self.Multi then
                    selected = self.Selected[value] == true
                else
                    selected = self.Selected == value
                end
                
                -- Selection visual
                local indicator = Create "Frame" {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = ApplyTheme("Accent", self.UI.Theme),
                    BackgroundTransparency = selected and 0 or 1,
                    Position = UDim2.new(1, -8, 0.5, 0),
                    Size = UDim2.fromOffset(4, 14),
                    ZIndex = 10,
                    Parent = option
                }
                
                Create "UICorner" {
                    CornerRadius = UDim.new(1, 0),
                    Parent = indicator
                }
                
                -- Option hover effect
                self.UI:AddConnection(option.MouseEnter, function()
                    Tween(option, {BackgroundColor3 = ApplyTheme("ButtonHover", self.UI.Theme)})
                end)
                
                self.UI:AddConnection(option.MouseLeave, function()
                    Tween(option, {BackgroundColor3 = ApplyTheme("DropdownOption", self.UI.Theme)})
                end)
                
                -- Option selection
                self.UI:AddConnection(option.MouseButton1Click, function()
                    if self.Multi then
                        -- For multi-select
                        self.Selected[value] = not self.Selected[value] or nil
                        indicator.BackgroundTransparency = self.Selected[value] and 0 or 1
                    else
                        -- For single select
                        if self.Selected == value and self.AllowNull then
                            self.Selected = nil
                        else
                            self.Selected = value
                        end
                        
                        self:Close()
                    end
                    
                    self:UpdateText()
                    
                    if self.Callback then
                        self.Callback(self.Selected)
                    end
                    
                    self.UI.Flags[id] = self.Selected
                end)
            end
            
            -- Update canvas size
            self.Scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
            
            -- Calculate dropdown list height (max 200)
            local height = math.min(listLayout.AbsoluteContentSize.Y + 10, 200)
            self.List.Size = UDim2.new(0, 140, 0, height)
        end,
        
        Toggle = function(self)
            self.Open = not self.Open
            
            if self.Open then
                self:Open()
            else
                self:Close()
            end
        end,
        
        Open = function(self)
            self.Open = true
            
            -- Position dropdown properly
            local buttonPos = self.Button.AbsolutePosition
            local buttonSize = self.Button.AbsoluteSize
            
            self.List.Position = UDim2.fromOffset(buttonPos.X, buttonPos.Y + buttonSize.Y)
            self.List.Visible = true
            
            -- Update the list options
            self:Refresh()
            
            -- Close when clicking outside
            self._connection = self.UI:AddConnection(UserInputService.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local position = UserInputService:GetMouseLocation()
                    local inlist = position.X > self.List.AbsolutePosition.X and
                                   position.X < self.List.AbsolutePosition.X + self.List.AbsoluteSize.X and
                                   position.Y > self.List.AbsolutePosition.Y and
                                   position.Y < self.List.AbsolutePosition.Y + self.List.AbsoluteSize.Y
                                   
                    local inbutton = position.X > self.Button.AbsolutePosition.X and
                                     position.X < self.Button.AbsolutePosition.X + self.Button.AbsoluteSize.X and
                                     position.Y > self.Button.AbsolutePosition.Y and
                                     position.Y < self.Button.AbsolutePosition.Y + self.Button.AbsoluteSize.Y
                    
                    if not inlist and not inbutton then
                        self:Close()
                    end
                end
            end)
        end,
        
        Close = function(self)
            self.Open = false
            self.List.Visible = false
            
            if self._connection then
                self._connection:Disconnect()
                self._connection = nil
            end
        end
    }
    
    -- Button behavior
    self:AddConnection(dropdownButton.MouseButton1Click, function()
        dropdown:Toggle()
    end)
    
    -- Initialize
    dropdown.UI = self
    
    -- Set default value
    if multiSelect then
        local selected = {}
        
        if type(default) == "table" then
            for _, value in ipairs(default) do
                selected[value] = true
            end
        end
        
        dropdown.Selected = selected
        self.Flags[id] = selected
    else
        dropdown.Selected = default
        self.Flags[id] = default
    end
    
    dropdown:UpdateText()
    
    return dropdown
end

function NovaUI:AddLabel(section, text)
    -- Create label container
    local container = Create "Frame" {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Parent = section.Container
    }
    
    -- Create label
    local label = Create "TextLabel" {
        BackgroundTransparency = 1,
        Font = self.Font,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromScale(1, 1),
        Text = text or "",
        TextColor3 = ApplyTheme("SubText", self.Theme),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    }
    
    -- Create label object
    local labelObj = {
        Type = "Label",
        Label = label,
        Container = container,
        SetText = function(self, newText)
            self.Label.Text = newText
        end
    }
    
    return labelObj
end

function NovaUI:AddInput(section, id, options)
    options = options or {}
    
    -- Create input container
    local container = Create "Frame" {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = section.Container
    }
    
    -- Title
    local title = Create "TextLabel" {
        BackgroundTransparency = 1,
        Font = self.Font,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 20),
        Text = options.Title or "Input",
        TextColor3 = ApplyTheme("Text", self.Theme),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    }
    
    -- Description
    if options.Description then
        container.Size = UDim2.new(1, 0, 0, 50)
        
        local description = Create "TextLabel" {
            BackgroundTransparency = 1,
            Font = self.Font,
            Position = UDim2.fromOffset(0, 22),
            Size = UDim2.new(1, -140, 0, 14),
            Text = options.Description,
            TextColor3 = ApplyTheme("SubText", self.Theme),
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        }
    end
    
    -- Create input box
    local inputBox = Create "Frame" {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = ApplyTheme("Button", self.Theme),
        Position = UDim2.new(1, 0, 1, 0),
        Size = UDim2.new(0, 140, 0, 30),
        Parent = container
    }
    
    Create "UICorner" {
        CornerRadius = UDim.new(0, 4),
        Parent = inputBox
    }
    
    Create "UIStroke" {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = ApplyTheme("Border", self.Theme),
        Thickness = 1,
        Parent = inputBox
    }
    
    local textBox = Create "TextBox" {
        BackgroundTransparency = 1,
        Font = self.Font,
        PlaceholderColor3 = ApplyTheme("SubText", self.Theme),
        PlaceholderText = options.Placeholder or "Enter text...",
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Text = options.Default or "",
        TextColor3 = ApplyTheme("Text", self.Theme),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = options.ClearTextOnFocus ~= false,
        Parent = inputBox
    }
    
    -- Create input object
    local input = {
        Type = "Input",
        Title = title,
        Box = textBox,
        Container = container,
        Value = options.Default or "",
        Callback = options.Callback,
        Finished = options.Finished == true,
        Numeric = options.Numeric == true,
        
        SetValue = function(self, value)
            if self.Numeric and type(value) == "string" then
                if value ~= "" and not tonumber(value) then
                    return
                end
            end
            
            self.Value = value
            self.Box.Text = value
            
            if self.Callback then
                self.Callback(value)
            end
            
            self.UI.Flags[id] = value
        end
    }
    
    -- Input behavior
    if options.Finished then
        self:AddConnection(textBox.FocusLost, function(enterPressed)
            if enterPressed then
                input:SetValue(textBox.Text)
            end
        end)
    else
        self:AddConnection(textBox:GetPropertyChangedSignal("Text"), function()
            input:SetValue(textBox.Text)
        end)
    end
    
    -- Initialize
    input.UI = self
    self.Flags[id] = options.Default or ""
    
    return input
end

function NovaUI:AddKeybind(section, id, options)
    options = options or {}
    
    -- Create keybind container
    local container = Create "Frame" {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = section.Container
    }
    
    -- Title
    local title = Create "TextLabel" {
        BackgroundTransparency = 1,
        Font = self.Font,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 20),
        Text = options.Title or "Keybind",
        TextColor3 = ApplyTheme("Text", self.Theme),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = container
    }
    
    -- Description
    if options.Description then
        container.Size = UDim2.new(1, 0, 0, 50)
        
        local description = Create "TextLabel" {
            BackgroundTransparency = 1,
            Font = self.Font,
            Position = UDim2.fromOffset(0, 22),
            Size = UDim2.new(1, -140, 0, 14),
            Text = options.Description,
            TextColor3 = ApplyTheme("SubText", self.Theme),
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = container
        }
    end
    
    -- Create keybind button
    local keybindButton = Create "TextButton" {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = ApplyTheme("Button", self.Theme),
        Font = self.Font,
        Position = UDim2.new(1, 0, 1, 0),
        Size = UDim2.new(0, 100, 0, 30),
        Text = "None",
        TextColor3 = ApplyTheme("Text", self.Theme),
        TextSize = 14,
        AutoButtonColor = false,
        Parent = container
    }
    
    Create "UICorner" {
        CornerRadius = UDim.new(0, 4),
        Parent = keybindButton
    }
    
    Create "UIStroke" {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = ApplyTheme("Border", self.Theme),
        Thickness = 1,
        Parent = keybindButton
    }
    
    -- Key name conversion
    local function GetKeyName(input)
        if input == nil then
            return "None"
        end
        
        -- Mouse button names
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            return "MB1"
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            return "MB2"
        elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
            return "MB3"
        end
        
        -- Special key names
        local keyNameMap = {
            [Enum.KeyCode.Unknown] = "None",
            [Enum.KeyCode.LeftControl] = "LCtrl",
            [Enum.KeyCode.RightControl] = "RCtrl",
            [Enum.KeyCode.LeftShift] = "LShift",
            [Enum.KeyCode.RightShift] = "RShift",
            [Enum.KeyCode.LeftAlt] = "LAlt",
            [Enum.KeyCode.RightAlt] = "RAlt",
        }
        
        if input.KeyCode and keyNameMap[input.KeyCode] then
            return keyNameMap[input.KeyCode]
        end
        
        -- Default key name
        return input.KeyCode and input.KeyCode.Name or "None"
    end
    
    -- Create keybind object
    local keybind = {
        Type = "Keybind",
        Title = title,
        Button = keybindButton,
        Container = container,
        Value = options.Default,
        Mode = options.Mode or "Toggle", -- Toggle, Hold, Always
        Listening = false,
        Callback = options.Callback,
        
        SetValue = function(self, value)
            self.Value = value
            self.Button.Text = GetKeyName({KeyCode = value})
            
            if self.Callback then
                self.Callback(value)
            end
            
            self.UI.Flags[id] = value
        end,
        
        StartListening = function(self)
            self.Listening = true
            self.Button.Text = "..."
            
            local inputConnection
            inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                
                if input.UserInputType == Enum.UserInputType.Keyboard or
                   input.UserInputType == Enum.UserInputType.MouseButton1 or
                   input.UserInputType == Enum.UserInputType.MouseButton2 or
                   input.UserInputType == Enum.UserInputType.MouseButton3 then
                    
                    local keyCode = input.UserInputType.Name:find("MouseButton") and input.UserInputType or input.KeyCode
                    self:SetValue(keyCode)
                    
                    self.Listening = false
                    inputConnection:Disconnect()
                end
            end)
        end
    }
    
    -- Button behavior
    self:AddConnection(keybindButton.MouseButton1Click, function()
        if not keybind.Listening then
            keybind:StartListening()
        end
    end)
    
    -- Right-click to clear
    self:AddConnection(keybindButton.MouseButton2Click, function()
        keybind:SetValue(nil)
    end)
    
    -- Keybind detection
    self:AddConnection(UserInputService.InputBegan, function(input, gameProcessed)
        if gameProcessed or keybind.Listening or not keybind.Value then return end
        
        local inputType = input.UserInputType
        local keyCode = input.KeyCode
        
        local isMatch = false
        
        if (inputType == Enum.UserInputType.Keyboard and keyCode == keybind.Value) or
           (inputType.Name:find("MouseButton") and inputType == keybind.Value) then
            isMatch = true
        end
        
        if isMatch then
            if keybind.Mode == "Toggle" or keybind.Mode == "Always" then
                if keybind.Callback then
                    keybind.Callback(keybind.Value)
                end
            end
        end
    end)
    
    self:AddConnection(UserInputService.InputEnded, function(input, gameProcessed)
        if gameProcessed or keybind.Listening or not keybind.Value then return end
        
        local inputType = input.UserInputType
        local keyCode = input.KeyCode
        
        local isMatch = false
        
        if (inputType == Enum.UserInputType.Keyboard and keyCode == keybind.Value) or
           (inputType.Name:find("MouseButton") and inputType == keybind.Value) then
            isMatch = true
        end
        
        if isMatch and keybind.Mode == "Hold" then
            if keybind.Callback then
                keybind.Callback(keybind.Value)
            end
        end
    end)
    
    -- Initialize
    keybind.UI = self
    self.Flags[id] = options.Default
    
    if options.Default then
        keybind:SetValue(options.Default)
    end
    
    return keybind
end

-- Save configuration
function NovaUI:SaveConfig(name)
    local config = {
        flags = self.Flags
    }
    
    if writefile then
        local success, err = pcall(function()
            local folder = "NovaUI"
            local subfolder = folder .. "/configs"
            
            if not isfolder(folder) then
                makefolder(folder)
            end
            
            if not isfolder(subfolder) then
                makefolder(subfolder)
            end
            
            writefile(subfolder .. "/" .. name .. ".json", HttpService:JSONEncode(config))
        end)
        
        return success
    end
    
    return false
end

-- Load configuration
function NovaUI:LoadConfig(name)
    if readfile then
        local success, result = pcall(function()
            local content = readfile("NovaUI/configs/" .. name .. ".json")
            return HttpService:JSONDecode(content)
        end)
        
        if success and result and result.flags then
            for id, value in pairs(result.flags) do
                if self.Flags[id] ~= nil then
                    self.Flags[id] = value
                    
                    -- Find and update elements with this id
                    for _, tab in ipairs(self.Tabs) do
                        for _, section in ipairs(tab.Sections) do
                            for _, element in ipairs(section.Elements) do
                                if element.ID == id and element.SetValue then
                                    element:SetValue(value)
                                end
                            end
                        end
                    end
                end
            end
            
            return true
        end
    end
    
    return false
end

-- Get all configurations
function NovaUI:GetConfigs()
    local configs = {}
    
    if listfiles then
        local success, result = pcall(function()
            return listfiles("NovaUI/configs")
        end)
        
        if success and result then
            for _, file in ipairs(result) do
                -- Extract filename without extension
                local filename = file:match("([^/\\]+)%.json$")
                if filename then
                    table.insert(configs, filename)
                end
            end
        end
    end
    
    return configs
end

-- Set autoload configuration
function NovaUI:SetAutoloadConfig(name)
    if writefile then
        pcall(function()
            local folder = "NovaUI"
            
            if not isfolder(folder) then
                makefolder(folder)
            end
            
            writefile(folder .. "/autoload.txt", name)
        end)
    end
end

-- Load autoload configuration
function NovaUI:LoadAutoloadConfig()
    if readfile and isfile("NovaUI/autoload.txt") then
        local success, name = pcall(function()
            return readfile("NovaUI/autoload.txt")
        end)
        
        if success and name and name ~= "" then
            self:LoadConfig(name)
            return true
        end
    end
    
    return false
end

-- Cleanup resources
function NovaUI:Destroy()
    -- Disconnect all connections
    for _, connection in ipairs(self.Connections) do
        connection:Disconnect()
    end
    
    -- Remove GUI
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
    
    -- Remove blur
    if self.Blur then
        self.Blur:Destroy()
    end
end

return NovaLibrary
