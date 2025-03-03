-- Create a fresh version of the Celestial library with proper AddTab implementation
local Celestial = {}

-- Services
local LightingService = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local PlayersService = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local WorkspaceCamera = game:GetService("Workspace").CurrentCamera
local LocalPlayer = PlayersService.LocalPlayer
local PlayerMouse = LocalPlayer:GetMouse()

-- Core Properties
Celestial = {
    Version = "1.0.0",
    OpenFrames = {},
    Options = {},
    Themes = {"Dark", "Darker", "Light", "Aqua", "Amethyst", "Rose"},
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
    GUI = nil
}

-- Initialize UI container
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "CelestialUI"
MainGui.ResetOnSpawn = false
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MainGui.Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui")

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
ProtectGui(MainGui)

Celestial.GUI = MainGui

-- Callback handling with error handling
function Celestial.SafeCallback(_, callback, ...)
    if not callback then 
        return 
    end
    
    local success, errorMsg = pcall(callback, ...)
    if not success then
        local _, endPos = errorMsg:find(":%d+: ")
        if not endPos then 
            return Celestial:Notify({
                Title = "Error",
                Content = "Callback error",
                SubContent = errorMsg,
                Duration = 5
            })
        end
        
        return Celestial:Notify({
            Title = "Error",
            Content = "Callback error",
            SubContent = errorMsg:sub(endPos + 1),
            Duration = 5
        })
    end
end

-- Create the main window of the UI
function Celestial:CreateWindow(config)
    assert(config.Title, "Window - Missing Title")
    
    if self.Window then
        print("You cannot create more than one window.")
        return
    end
    
    self.MinimizeKey = config.MinimizeKey
    self.UseAcrylic = config.Acrylic or false
    
    -- Create the main window container
    local windowContainer = Instance.new("Frame")
    windowContainer.Name = "WindowContainer"
    windowContainer.Size = config.Size or UDim2.fromOffset(600, 400)
    windowContainer.Position = UDim2.fromScale(0.5, 0.5)
    windowContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    windowContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    windowContainer.BackgroundTransparency = 0.1
    windowContainer.BorderSizePixel = 0
    windowContainer.Parent = self.GUI
    
    -- Add rounded corners
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = windowContainer
    
    -- Create title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    titleBar.BackgroundTransparency = 0.2
    titleBar.BorderSizePixel = 0
    titleBar.Parent = windowContainer
    
    -- Add rounded corners to title bar (top only)
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    -- Title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -80, 1, 0)
    titleText.Position = UDim2.fromOffset(10, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = config.Title
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 18
    titleText.Font = Enum.Font.GothamSemibold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Subtitle text
    if config.SubTitle then
        local subtitleText = Instance.new("TextLabel")
        subtitleText.Name = "SubTitle"
        subtitleText.Size = UDim2.new(0, 100, 1, 0)
        subtitleText.Position = UDim2.new(0, titleText.AbsoluteSize.X + 15, 0, 0)
        subtitleText.BackgroundTransparency = 1
        subtitleText.Text = config.SubTitle
        subtitleText.TextColor3 = Color3.fromRGB(180, 180, 180)
        subtitleText.TextSize = 14
        subtitleText.Font = Enum.Font.Gotham
        subtitleText.TextXAlignment = Enum.TextXAlignment.Left
        subtitleText.Parent = titleBar
    end
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.fromOffset(30, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeButton.BackgroundTransparency = 0.8
    closeButton.Text = ""
    closeButton.AutoButtonColor = false
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Create tab container
    local tabWidth = config.TabWidth or 160
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, tabWidth, 1, -50)
    tabContainer.Position = UDim2.fromOffset(10, 45)
    tabContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    tabContainer.BackgroundTransparency = 0.3
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = windowContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tabContainer
    
    -- Create tab holder ScrollingFrame
    local tabHolder = Instance.new("ScrollingFrame")
    tabHolder.Name = "TabHolder"
    tabHolder.Size = UDim2.fromScale(1, 1)
    tabHolder.BackgroundTransparency = 1
    tabHolder.BorderSizePixel = 0
    tabHolder.ScrollBarThickness = 0
    tabHolder.ScrollBarImageTransparency = 1
    tabHolder.Parent = tabContainer
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.Parent = tabHolder
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingTop = UDim.new(0, 5)
    tabPadding.Parent = tabHolder
    
    -- Create content container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -(tabWidth + 25), 1, -50)
    contentContainer.Position = UDim2.new(0, tabWidth + 15, 0, 45)
    contentContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    contentContainer.BackgroundTransparency = 0.3
    contentContainer.BorderSizePixel = 0
    contentContainer.ClipsDescendants = true
    contentContainer.Parent = windowContainer
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 8)
    contentCorner.Parent = contentContainer
    
    -- Window properties
    local window = {
        Root = windowContainer,
        TabHolder = tabHolder,
        ContainerHolder = contentContainer,
        Title = config.Title,
        SubTitle = config.SubTitle,
        Tabs = {},
        TabCount = 0,
        SelectedTab = nil
    }
    
    -- Store in main Celestial object
    self.Window = window
    
    -- Allow dragging the window
    local isDragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = windowContainer.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and isDragging then
            local delta = input.Position - dragStart
            windowContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Tab system
    function window:AddTab(config)
        self.TabCount = self.TabCount + 1
        local tabIndex = self.TabCount
        
        -- Create tab button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = "Tab_" .. config.Title
        tabButton.Size = UDim2.new(0.9, 0, 0, 32)
        tabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        tabButton.BackgroundTransparency = 0.7
        tabButton.Text = config.Title
        tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabButton.TextSize = 14
        tabButton.Font = Enum.Font.GothamSemibold
        tabButton.AutoButtonColor = false
        tabButton.Parent = self.TabHolder
        
        local tabButtonCorner = Instance.new("UICorner")
        tabButtonCorner.CornerRadius = UDim.new(0, 4)
        tabButtonCorner.Parent = tabButton
        
        -- Add icon if specified
        if config.Icon then
            -- You would implement icon handling here
            -- For simplicity, we're skipping this for now
        end
        
        -- Create tab content container
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = "TabContent_" .. config.Title
        tabContent.Size = UDim2.fromScale(1, 1)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 2
        tabContent.ScrollingDirection = Enum.ScrollingDirection.Y
        tabContent.CanvasSize = UDim2.fromScale(0, 0)
        tabContent.Visible = false
        tabContent.Parent = self.ContainerHolder
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 6)
        contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        contentLayout.Parent = tabContent
        
        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingTop = UDim.new(0, 8)
        contentPadding.PaddingBottom = UDim.new(0, 8)
        contentPadding.Parent = tabContent
        
        -- Update canvas size when content changes
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 16)
        end)
        
        -- Tab object
        local tab = {
            Button = tabButton,
            Container = tabContent,
            Title = config.Title,
            Icon = config.Icon,
            Sections = {},
            Index = tabIndex
        }
        
        -- Add section function
        function tab:AddSection(name)
            local sectionContainer = Instance.new("Frame")
            sectionContainer.Name = "Section_" .. name
            sectionContainer.Size = UDim2.new(1, -20, 0, 36)
            sectionContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            sectionContainer.BackgroundTransparency = 0.4
            sectionContainer.BorderSizePixel = 0
            sectionContainer.ClipsDescendants = true
            sectionContainer.AutomaticSize = Enum.AutomaticSize.Y
            sectionContainer.Parent = self.Container
            
            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = UDim.new(0, 6)
            sectionCorner.Parent = sectionContainer
            
            -- Section title
            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Name = "Title"
            sectionTitle.Size = UDim2.new(1, -16, 0, 26)
            sectionTitle.Position = UDim2.fromOffset(8, 4)
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Text = name
            sectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            sectionTitle.TextSize = 14
            sectionTitle.Font = Enum.Font.GothamSemibold
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            sectionTitle.Parent = sectionContainer
            
            -- Elements container
            local elementsContainer = Instance.new("Frame")
            elementsContainer.Name = "Elements"
            elementsContainer.Size = UDim2.new(1, -16, 0, 0)
            elementsContainer.Position = UDim2.fromOffset(8, 30)
            elementsContainer.BackgroundTransparency = 1
            elementsContainer.BorderSizePixel = 0
            elementsContainer.AutomaticSize = Enum.AutomaticSize.Y
            elementsContainer.Parent = sectionContainer
            
            local elementsLayout = Instance.new("UIListLayout")
            elementsLayout.Padding = UDim.new(0, 6)
            elementsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            elementsLayout.Parent = elementsContainer
            
            -- Update section container size based on elements
            elementsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                elementsContainer.Size = UDim2.new(1, -16, 0, elementsLayout.AbsoluteContentSize.Y)
                sectionContainer.Size = UDim2.new(1, -20, 0, elementsContainer.Size.Y.Offset + 36)
            end)
            
            -- Section object
            local section = {
                Container = elementsContainer,
                Title = name,
                Elements = {},
                Window = window
            }
            
            -- UI Element functions
            -- Button element
            function section:AddButton(config)
                assert(config.Title, "Button missing Title")
                
                local buttonFrame = Instance.new("Frame")
                buttonFrame.Name = "Button_" .. config.Title
                buttonFrame.Size = UDim2.new(1, 0, 0, 32)
                buttonFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                buttonFrame.BackgroundTransparency = 0.6
                buttonFrame.BorderSizePixel = 0
                buttonFrame.Parent = self.Container
                
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 4)
                buttonCorner.Parent = buttonFrame
                
                local buttonText = Instance.new("TextLabel")
                buttonText.Name = "Title"
                buttonText.Size = UDim2.new(1, -16, 1, 0)
                buttonText.Position = UDim2.fromOffset(8, 0)
                buttonText.BackgroundTransparency = 1
                buttonText.Text = config.Title
                buttonText.TextColor3 = Color3.fromRGB(255, 255, 255)
                buttonText.TextSize = 14
                buttonText.Font = Enum.Font.Gotham
                buttonText.TextXAlignment = Enum.TextXAlignment.Left
                buttonText.Parent = buttonFrame
                
                -- Add description
                if config.Description then
                    buttonText.Size = UDim2.new(1, -16, 0, 18)
                    buttonText.Position = UDim2.fromOffset(8, 4)
                    
                    local buttonDesc = Instance.new("TextLabel")
                    buttonDesc.Name = "Description"
                    buttonDesc.Size = UDim2.new(1, -16, 0, 14)
                    buttonDesc.Position = UDim2.fromOffset(8, 20)
                    buttonDesc.BackgroundTransparency = 1
                    buttonDesc.Text = config.Description
                    buttonDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
                    buttonDesc.TextSize = 12
                    buttonDesc.Font = Enum.Font.Gotham
                    buttonDesc.TextXAlignment = Enum.TextXAlignment.Left
                    buttonDesc.Parent = buttonFrame
                end
                
                -- Clickable button
                local clickButton = Instance.new("TextButton")
                clickButton.Name = "ClickButton"
                clickButton.Size = UDim2.fromScale(1, 1)
                clickButton.BackgroundTransparency = 1
                clickButton.Text = ""
                clickButton.Parent = buttonFrame
                
                -- Connect click callback
                clickButton.MouseButton1Click:Connect(function()
                    Celestial:SafeCallback(config.Callback)
                end)
                
                -- Hover effect
                clickButton.MouseEnter:Connect(function()
                    buttonFrame.BackgroundTransparency = 0.4
                end)
                
                clickButton.MouseLeave:Connect(function()
                    buttonFrame.BackgroundTransparency = 0.6
                end)
                
                return {
                    SetTitle = function(_, text)
                        buttonText.Text = text
                    end,
                    SetDesc = function(_, text)
                        if buttonFrame:FindFirstChild("Description") then
                            buttonFrame.Description.Text = text
                        end
                    end
                }
            end
            
            -- Toggle element
            function section:AddToggle(config)
                assert(config.Title, "Toggle missing Title")
                
                local toggleFrame = Instance.new("Frame")
                toggleFrame.Name = "Toggle_" .. config.Title
                toggleFrame.Size = UDim2.new(1, 0, 0, 32)
                toggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                toggleFrame.BackgroundTransparency = 0.6
                toggleFrame.BorderSizePixel = 0
                toggleFrame.Parent = self.Container
                
                local toggleCorner = Instance.new("UICorner")
                toggleCorner.CornerRadius = UDim.new(0, 4)
                toggleCorner.Parent = toggleFrame
                
                local toggleText = Instance.new("TextLabel")
                toggleText.Name = "Title"
                toggleText.Size = UDim2.new(1, -56, 1, 0)
                toggleText.Position = UDim2.fromOffset(8, 0)
                toggleText.BackgroundTransparency = 1
                toggleText.Text = config.Title
                toggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
                toggleText.TextSize = 14
                toggleText.Font = Enum.Font.Gotham
                toggleText.TextXAlignment = Enum.TextXAlignment.Left
                toggleText.Parent = toggleFrame
                
                -- Add description
                if config.Description then
                    toggleText.Size = UDim2.new(1, -56, 0, 18)
                    toggleText.Position = UDim2.fromOffset(8, 4)
                    
                    local toggleDesc = Instance.new("TextLabel")
                    toggleDesc.Name = "Description"
                    toggleDesc.Size = UDim2.new(1, -56, 0, 14)
                    toggleDesc.Position = UDim2.fromOffset(8, 20)
                    toggleDesc.BackgroundTransparency = 1
                    toggleDesc.Text = config.Description
                    toggleDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
                    toggleDesc.TextSize = 12
                    toggleDesc.Font = Enum.Font.Gotham
                    toggleDesc.TextXAlignment = Enum.TextXAlignment.Left
                    toggleDesc.Parent = toggleFrame
                end
                
                -- Toggle indicator
                local toggleIndicator = Instance.new("Frame")
                toggleIndicator.Name = "Indicator"
                toggleIndicator.Size = UDim2.fromOffset(40, 20)
                toggleIndicator.Position = UDim2.new(1, -48, 0.5, 0)
                toggleIndicator.AnchorPoint = Vector2.new(0, 0.5)
                toggleIndicator.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                toggleIndicator.BorderSizePixel = 0
                toggleIndicator.Parent = toggleFrame
                
                local indicatorCorner = Instance.new("UICorner")
                indicatorCorner.CornerRadius = UDim.new(1, 0)
                indicatorCorner.Parent = toggleIndicator
                
                local toggle = Instance.new("Frame")
                toggle.Name = "Toggle"
                toggle.Size = UDim2.fromOffset(16, 16)
                toggle.Position = UDim2.fromOffset(2, 2)
                toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggle.BorderSizePixel = 0
                toggle.Parent = toggleIndicator
                
                local toggleCorner = Instance.new("UICorner")
                toggleCorner.CornerRadius = UDim.new(1, 0)
                toggleCorner.Parent = toggle
                
                -- Toggle state
                local toggleState = config.Default or false
                local toggled = toggleState
                
                -- Update the toggle appearance
                local function updateToggle()
                    if toggled then
                        TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 170, 255)}):Play()
                        TweenService:Create(toggle, TweenInfo.new(0.2), {Position = UDim2.fromOffset(22, 2)}):Play()
                    else
                        TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
                        TweenService:Create(toggle, TweenInfo.new(0.2), {Position = UDim2.fromOffset(2, 2)}):Play()
                    end
                end
                
                -- Initial state
                updateToggle()
                
                -- Clickable button
                local clickButton = Instance.new("TextButton")
                clickButton.Name = "ClickButton"
                clickButton.Size = UDim2.fromScale(1, 1)
                clickButton.BackgroundTransparency = 1
                clickButton.Text = ""
                clickButton.Parent = toggleFrame
                
                -- Toggle interface
                local toggleInterface = {
                    Value = toggled,
                    
                    SetValue = function(self, value)
                        toggled = value
                        self.Value = value
                        updateToggle()
                        Celestial:SafeCallback(config.Callback, toggled)
                    end,
                    
                    OnChanged = function(self, callback)
                        self.Changed = callback
                        callback(self.Value)
                    end,
                    
                    SetTitle = function(_, text)
                        toggleText.Text = text
                    end,
                    
                    SetDesc = function(_, text)
                        if toggleFrame:FindFirstChild("Description") then
                            toggleFrame.Description.Text = text
                        end
                    end
                }
                
                -- Connect click callback
                clickButton.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    toggleInterface:SetValue(toggled)
                end)
                
                -- Hover effect
                clickButton.MouseEnter:Connect(function()
                    toggleFrame.BackgroundTransparency = 0.4
                end)
                
                clickButton.MouseLeave:Connect(function()
                    toggleFrame.BackgroundTransparency = 0.6
                end)
                
                return toggleInterface
            end
            
            -- Add more UI elements here (Slider, Dropdown, etc.)
            
            -- Paragraph element
            function section:AddParagraph(config)
                assert(config.Title, "Paragraph missing Title")
                
                local paragraphFrame = Instance.new("Frame")
                paragraphFrame.Name = "Paragraph_" .. config.Title
                paragraphFrame.Size = UDim2.new(1, 0, 0, 60) -- Dynamic sizing
                paragraphFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                paragraphFrame.BackgroundTransparency = 0.6
                paragraphFrame.BorderSizePixel = 0
                paragraphFrame.AutomaticSize = Enum.AutomaticSize.Y
                paragraphFrame.Parent = self.Container
                
                local paragraphCorner = Instance.new("UICorner")
                paragraphCorner.CornerRadius = UDim.new(0, 4)
                paragraphCorner.Parent = paragraphFrame
                
                local paragraphTitle = Instance.new("TextLabel")
                paragraphTitle.Name = "Title"
                paragraphTitle.Size = UDim2.new(1, -16, 0, 20)
                paragraphTitle.Position = UDim2.fromOffset(8, 8)
                paragraphTitle.BackgroundTransparency = 1
                paragraphTitle.Text = config.Title
                paragraphTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
                paragraphTitle.TextSize = 16
                paragraphTitle.Font = Enum.Font.GothamSemibold
                paragraphTitle.TextXAlignment = Enum.TextXAlignment.Left
                paragraphTitle.Parent = paragraphFrame
                
                local paragraphContent = Instance.new("TextLabel")
                paragraphContent.Name = "Content"
                paragraphContent.Size = UDim2.new(1, -16, 0, 0)
                paragraphContent.Position = UDim2.fromOffset(8, 32)
                paragraphContent.BackgroundTransparency = 1
                paragraphContent.Text = config.Content or ""
                paragraphContent.TextColor3 = Color3.fromRGB(200, 200, 200)
                paragraphContent.TextSize = 14
                paragraphContent.Font = Enum.Font.Gotham
                paragraphContent.TextXAlignment = Enum.TextXAlignment.Left
                paragraphContent.TextYAlignment = Enum.TextYAlignment.Top
                paragraphContent.TextWrapped = true
                paragraphContent.AutomaticSize = Enum.AutomaticSize.Y
                paragraphContent.Parent = paragraphFrame
                
                -- Add padding at the bottom
                local padding = Instance.new("Frame")
                padding.Name = "Padding"
                padding.Size = UDim2.new(1, 0, 0, 8)
                padding.Position = UDim2.new(0, 0, 1, 0)
                padding.AnchorPoint = Vector2.new(0, 1)
                padding.BackgroundTransparency = 1
                padding.Parent = paragraphFrame
                
                -- Update frame size based on content
                paragraphContent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    paragraphFrame.Size = UDim2.new(1, 0, 0, paragraphContent.AbsoluteSize.Y + 40)
                end)
                
                return {
                    SetTitle = function(_, text)
                        paragraphTitle.Text = text
                    end,
                    
                    SetContent = function(_, text)
                        paragraphContent.Text = text
                    end
                }
            end
            
            -- Add more UI elements as needed...
            
            table.insert(self.Sections, section)
            return section
        end
        
        -- Connect tab click
        tabButton.MouseButton1Click:Connect(function()
            window:SelectTab(tabIndex)
        end)
        
        self.Tabs[tabIndex] = tab
        
        -- Select this tab if it's the first one
        if tabIndex == 1 then
            window:SelectTab(1)
        end
        
        return tab
    end
    
    -- Select a tab
    function window:SelectTab(index)
        -- Hide all tab contents
        for _, tab in pairs(self.Tabs) do
            tab.Container.Visible = false
            tab.Button.BackgroundTransparency = 0.7
            tab.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        
        -- Show the selected tab
        local selectedTab = self.Tabs[index]
        if selectedTab then
            selectedTab.Container.Visible = true
            selectedTab.Button.BackgroundTransparency = 0.5
            selectedTab.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            self.SelectedTab = index
        end
    end
    
    -- Minimize the window
    function window:Minimize()
        self.Minimized = not self.Minimized
        self.Root.Visible = not self.Minimized
    end
    
    -- Simple dialog implementation
    function window:Dialog(config)
        -- Create dialog background
        local dialogBg = Instance.new("Frame")
        dialogBg.Name = "DialogBackground"
        dialogBg.Size = UDim2.fromScale(1, 1)
        dialogBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        dialogBg.BackgroundTransparency = 0.5
        dialogBg.BorderSizePixel = 0
        dialogBg.Parent = self.Root
        
        -- Create dialog
        local dialog = Instance.new("Frame")
        dialog.Name = "Dialog"
        dialog.Size = UDim2.fromOffset(300, 150)
        dialog.Position = UDim2.fromScale(0.5, 0.5)
        dialog.AnchorPoint = Vector2.new(0.5, 0.5)
        dialog.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        dialog.BorderSizePixel = 0
        dialog.Parent = dialogBg
        
        local dialogCorner = Instance.new("UICorner")
        dialogCorner.CornerRadius = UDim.new(0, 8)
        dialogCorner.Parent = dialog
        
        -- Dialog title
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, -20, 0, 30)
        title.Position = UDim2.fromOffset(10, 10)
        title.BackgroundTransparency = 1
        title.Text = config.Title or "Dialog"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 18
        title.Font = Enum.Font.GothamSemibold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = dialog
        
        -- Dialog content
        local content = Instance.new("TextLabel")
        content.Name = "Content"
        content.Size = UDim2.new(1, -20, 0, 0)
        content.Position = UDim2.fromOffset(10, 40)
        content.BackgroundTransparency = 1
        content.Text = config.Content or ""
        content.TextColor3 = Color3.fromRGB(230, 230, 230)
        content.TextSize = 14
        content.Font = Enum.Font.Gotham
        content.TextXAlignment = Enum.TextXAlignment.Left
        content.TextYAlignment = Enum.TextYAlignment.Top
        content.TextWrapped = true
        content.AutomaticSize = Enum.AutomaticSize.Y
        content.Parent = dialog
        
        -- Buttons container
        local buttonsContainer = Instance.new("Frame")
        buttonsContainer.Name = "ButtonsContainer"
        buttonsContainer.Size = UDim2.new(1, -20, 0, 35)
        buttonsContainer.Position = UDim2.new(0, 10, 1, -45)
        buttonsContainer.BackgroundTransparency = 1
        buttonsContainer.Parent = dialog
        
        local buttonsLayout = Instance.new("UIListLayout")
        buttonsLayout.Padding = UDim.new(0, 10)
        buttonsLayout.FillDirection = Enum.FillDirection.Horizontal
        buttonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        buttonsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        buttonsLayout.Parent = buttonsContainer
        
        -- Add buttons
        if config.Buttons and #config.Buttons > 0 then
            for i, buttonConfig in ipairs(config.Buttons) do
                local button = Instance.new("TextButton")
                button.Name = "Button_" .. (buttonConfig.Title or "Button")
                button.Size = UDim2.new(0, 100, 0, 30)
                button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                button.BorderSizePixel = 0
                button.Text = buttonConfig.Title or "Button"
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
                button.TextSize = 14
                button.Font = Enum.Font.GothamSemibold
                button.Parent = buttonsContainer
                
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 4)
                buttonCorner.Parent = button
                
                -- Connect callback
                button.MouseButton1Click:Connect(function()
                    dialogBg:Destroy()
                    if buttonConfig.Callback then
                        buttonConfig.Callback()
                    end
                end)
                
                -- Hover effect
                button.MouseEnter:Connect(function()
                    button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                end)
                
                button.MouseLeave:Connect(function()
                    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                end)
            end
        else
            -- Default close button
            local closeButton = Instance.new("TextButton")
            closeButton.Name = "CloseButton"
            closeButton.Size = UDim2.new(0, 100, 0, 30)
            closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            closeButton.BorderSizePixel = 0
            closeButton.Text = "Close"
            closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            closeButton.TextSize = 14
            closeButton.Font = Enum.Font.GothamSemibold
            closeButton.Parent = buttonsContainer
            
            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 4)
            buttonCorner.Parent = closeButton
            
            closeButton.MouseButton1Click:Connect(function()
                dialogBg:Destroy()
            end)
            
            closeButton.MouseEnter:Connect(function()
                closeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            end)
            
            closeButton.MouseLeave:Connect(function()
                closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end)
        end
        
        -- Resize dialog based on content
        content:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            local requiredHeight = content.AbsoluteSize.Y + 100
            dialog.Size = UDim2.fromOffset(300, math.max(150, requiredHeight))
        end)
        
        return dialog
    end
    
    return window
end

-- Add a notification system
function Celestial:Notify(options)
    options = options or {}
    options.Title = options.Title or "Notification"
    options.Content = options.Content or ""
    options.Duration = options.Duration or 5
    
    -- Create notification container if it doesn't exist
    if not self.NotificationContainer then
        self.NotificationContainer = Instance.new("Frame")
        self.NotificationContainer.Name = "NotificationContainer"
        self.NotificationContainer.Size = UDim2.new(0, 300, 1, 0)
        self.NotificationContainer.Position = UDim2.new(1, -310, 0, 0)
        self.NotificationContainer.BackgroundTransparency = 1
        self.NotificationContainer.Parent = self.GUI
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 10)
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        listLayout.Parent = self.NotificationContainer
        
        local padding = Instance.new("UIPadding")
        padding.PaddingBottom = UDim.new(0, 10)
        padding.Parent = self.NotificationContainer
    end
    
    -- Create notification
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(1, -20, 0, 0)
    notification.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    notification.BorderSizePixel = 0
    notification.AutomaticSize = Enum.AutomaticSize.Y
    notification.Parent = self.NotificationContainer
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notification
    
    -- Notification title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -20, 0, 24)
    title.Position = UDim2.fromOffset(10, 10)
    title.BackgroundTransparency = 1
    title.Text = options.Title
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = notification
    
    -- Notification content
    local content = Instance.new("TextLabel")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 0, 0)
    content.Position = UDim2.fromOffset(10, 34)
    content.BackgroundTransparency = 1
    content.Text = options.Content
    content.TextColor3 = Color3.fromRGB(220, 220, 220)
    content.TextSize = 14
    content.Font = Enum.Font.Gotham
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Top
    content.TextWrapped = true
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Parent = notification
    
    -- Add sub-content if provided
    if options.SubContent and options.SubContent ~= "" then
        local subContent = Instance.new("TextLabel")
        subContent.Name = "SubContent"
        subContent.Size = UDim2.new(1, -20, 0, 0)
        subContent.Position = UDim2.new(0, 10, 0, content.AbsolutePosition.Y + content.AbsoluteSize.Y + 5)
        subContent.BackgroundTransparency = 1
        subContent.Text = options.SubContent
        subContent.TextColor3 = Color3.fromRGB(180, 180, 180)
        subContent.TextSize = 12
        subContent.Font = Enum.Font.Gotham
        subContent.TextXAlignment = Enum.TextXAlignment.Left
        subContent.TextYAlignment = Enum.TextYAlignment.Top
        subContent.TextWrapped = true
        subContent.AutomaticSize = Enum.AutomaticSize.Y
        subContent.Parent = notification
        
        -- Connect size change
        content:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            subContent.Position = UDim2.new(0, 10, 0, 34 + content.AbsoluteSize.Y + 5)
        end)
    end
    
    -- Add bottom padding
    local padding = Instance.new("Frame")
    padding.Name = "BottomPadding"
    padding.Size = UDim2.new(1, 0, 0, 10)
    padding.BackgroundTransparency = 1
    padding.Position = UDim2.new(0, 0, 1, 0)
    padding.AnchorPoint = Vector2.new(0, 0)
    padding.Parent = notification
    
    -- Auto-close
    if options.Duration then
        task.delay(options.Duration, function()
            -- Fade out animation
            for i = 0, 10 do
                notification.BackgroundTransparency = i/10
                for _, child in ipairs(notification:GetChildren()) do
                    if child:IsA("TextLabel") then
                        child.TextTransparency = i/10
                    end
                end
                task.wait(0.02)
            end
            notification:Destroy()
        end)
    end
    
    -- Initial slide-in animation
    notification.Position = UDim2.new(1, 0, 0, 0)
    for i = 10, 0, -1 do
        notification.Position = UDim2.new(i/10, 0, 0, 0)
        task.wait(0.02)
    end
    
    return notification
end

-- Destroy the UI library
function Celestial:Destroy()
    if self.GUI then
        self.GUI:Destroy()
        self.Unloaded = true
    end
end

-- Set the UI theme (simplified for this example)
function Celestial:SetTheme(themeName)
    if table.find(self.Themes, themeName) then
        self.Theme = themeName
        -- You would implement theme color changes here
    end
end

-- Toggle acrylic effect (simplified)
function Celestial:ToggleAcrylic(enabled)
    self.Acrylic = enabled
    -- Would implement actual acrylic effect
end

-- Toggle transparency
function Celestial:ToggleTransparency(enabled)
    self.Transparency = enabled
    -- Would implement transparency changes
end

-- Make the library accessible globally
if getgenv then
    getgenv().CelestialUI = Celestial
end

-- Example usage
local window = Celestial:CreateWindow({
    Title = "Celestial Demo",
    SubTitle = "v1.0.0",
    Size = UDim2.fromOffset(600, 400)
})

-- Create tabs with our working AddTab method
local homeTab = window:AddTab({
    Title = "Home"
})

local settingsTab = window:AddTab({
    Title = "Settings"
})

-- Add sections and elements
local mainSection = homeTab:AddSection("Main")

mainSection:AddButton({
    Title = "Click Me",
    Description = "This is a button",
    Callback = function()
        Celestial:Notify({
            Title = "Button Clicked",
            Content = "You clicked the button!",
            Duration = 3
        })
    end
})

mainSection:AddToggle({
    Title = "Toggle Feature",
    Description = "This is a toggle",
    Default = false,
    Callback = function(value)
        print("Toggle value:", value)
    end
})

mainSection:AddParagraph({
    Title = "Information",
    Content = "This is a paragraph with some information about the Celestial UI Library."
})

-- Add to settings tab
local settingsSection = settingsTab:AddSection("Settings")

settingsSection:AddButton({
    Title = "Destroy UI",
    Description = "Completely removes the UI",
    Callback = function()
        Celestial:Destroy()
    end
})

-- Show a welcome notification
Celestial:Notify({
    Title = "Celestial UI",
    Content = "Welcome to the Celestial UI Library",
    SubContent = "UI has been successfully initialized",
    Duration = 5
})

return Celestial
