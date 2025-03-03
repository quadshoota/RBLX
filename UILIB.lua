NewNotification:Close()
            end)
        end
        return NewNotification
    end

    return Notification
end

Component.Section = function(Title, Parent)
    local Section = {}

    Section.Layout = Creator.New("UIListLayout", {
        Padding = UDim.new(0, 5),
    })

    Section.Container = Creator.New("Frame", {
        Size = UDim2.new(1, 0, 0, 26),
        Position = UDim2.fromOffset(0, 24),
        BackgroundTransparency = 1,
    }, {
        Section.Layout,
    })

    Section.Root = Creator.New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 26),
        LayoutOrder = 7,
        Parent = Parent,
    }, {
        Creator.New("TextLabel", {
            RichText = true,
            Text = Title,
            TextTransparency = 0,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            TextSize = 18,
            TextXAlignment = "Left",
            TextYAlignment = "Center",
            Size = UDim2.new(1, -16, 0, 18),
            Position = UDim2.fromOffset(0, 2),
            ThemeTag = {
                TextColor3 = "Text",
            },
        }),
        Section.Container,
    })

    Creator.AddSignal(Section.Layout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        Section.Container.Size = UDim2.new(1, 0, 0, Section.Layout.AbsoluteContentSize.Y)
        Section.Root.Size = UDim2.new(1, 0, 0, Section.Layout.AbsoluteContentSize.Y + 25)
    end)
    return Section
end

Component.Tab = function(Window)
    local Tab = {
        Window = Window,
        Tabs = {},
        Containers = {},
        SelectedTab = 0,
        TabCount = 0,
    }

    function Tab:GetCurrentTabPos()
        local TabHolderPos = Tab.Window.TabHolder.AbsolutePosition.Y
        local TabPos = Tab.Tabs[Tab.SelectedTab].Frame.AbsolutePosition.Y

        return TabPos - TabHolderPos
    end

    function Tab:New(Title, Icon, Parent)
        Tab.TabCount = Tab.TabCount + 1
        local TabIndex = Tab.TabCount

        local NewTab = {
            Selected = false,
            Name = Title,
            Type = "Tab",
        }

        if Icon and Icon ~= "" then
            if Fluent:GetIcon(Icon) then
                Icon = Fluent:GetIcon(Icon)
            end
        else
            Icon = nil
        end

        NewTab.Frame = Creator.New("TextButton", {
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundTransparency = 1,
            Parent = Parent,
            ThemeTag = {
                BackgroundColor3 = "Tab",
            },
        }, {
            Creator.New("UICorner", {
                CornerRadius = UDim.new(0, 6),
            }),
            Creator.New("TextLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = Icon and UDim2.new(0, 30, 0.5, 0) or UDim2.new(0, 12, 0.5, 0),
                Text = Title,
                RichText = true,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextTransparency = 0,
                FontFace = Font.new(
                    "rbxasset://fonts/families/GothamSSm.json",
                    Enum.FontWeight.Regular,
                    Enum.FontStyle.Normal
                ),
                TextSize = 12,
                TextXAlignment = "Left",
                TextYAlignment = "Center",
                Size = UDim2.new(1, -12, 1, 0),
                BackgroundTransparency = 1,
                ThemeTag = {
                    TextColor3 = "Text",
                },
            }),
            Creator.New("ImageLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.fromOffset(16, 16),
                Position = UDim2.new(0, 8, 0.5, 0),
                BackgroundTransparency = 1,
                Image = Icon and Icon or nil,
                ThemeTag = {
                    ImageColor3 = "Text",
                },
            }),
        })

        local ContainerLayout = Creator.New("UIListLayout", {
            Padding = UDim.new(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder,
        })

        NewTab.ContainerFrame = Creator.New("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Parent = Window.ContainerHolder,
            Visible = false,
            BottomImage = "rbxassetid://6889812791",
            MidImage = "rbxassetid://6889812721",
            TopImage = "rbxassetid://6276641225",
            ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
            ScrollBarImageTransparency = 0.95,
            ScrollBarThickness = 3,
            BorderSizePixel = 0,
            CanvasSize = UDim2.fromScale(0, 0),
            ScrollingDirection = Enum.ScrollingDirection.Y,
        }, {
            ContainerLayout,
            Creator.New("UIPadding", {
                PaddingRight = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 1),
                PaddingTop = UDim.new(0, 1),
                PaddingBottom = UDim.new(0, 1),
            }),
        })

        Creator.AddSignal(ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            NewTab.ContainerFrame.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 2)
        end)

        NewTab.Motor, NewTab.SetTransparency = Creator.SpringMotor(1, NewTab.Frame, "BackgroundTransparency")

        Creator.AddSignal(NewTab.Frame.MouseEnter, function()
            NewTab.SetTransparency(NewTab.Selected and 0.85 or 0.89)
        end)
        Creator.AddSignal(NewTab.Frame.MouseLeave, function()
            NewTab.SetTransparency(NewTab.Selected and 0.89 or 1)
        end)
        Creator.AddSignal(NewTab.Frame.MouseButton1Down, function()
            NewTab.SetTransparency(0.92)
        end)
        Creator.AddSignal(NewTab.Frame.MouseButton1Up, function()
            NewTab.SetTransparency(NewTab.Selected and 0.85 or 0.89)
        end)
        Creator.AddSignal(NewTab.Frame.MouseButton1Click, function()
            Tab:SelectTab(TabIndex)
        end)

        Tab.Containers[TabIndex] = NewTab.ContainerFrame
        Tab.Tabs[TabIndex] = NewTab

        NewTab.Container = NewTab.ContainerFrame
        NewTab.ScrollFrame = NewTab.Container

        function NewTab:AddSection(SectionTitle)
            local Section = { Type = "Section" }

            local SectionFrame = Component.Section(SectionTitle, NewTab.Container)
            Section.Container = SectionFrame.Container
            Section.ScrollFrame = NewTab.Container

            setmetatable(Section, Fluent.Elements)
            return Section
        end

        setmetatable(NewTab, Fluent.Elements)
        return NewTab
    end

    function Tab:SelectTab(TabIdx)
        local Window = Tab.Window

        Tab.SelectedTab = TabIdx

        for _, TabObject in next, Tab.Tabs do
            TabObject.SetTransparency(1)
            TabObject.Selected = false
        end
        Tab.Tabs[TabIdx].SetTransparency(0.89)
        Tab.Tabs[TabIdx].Selected = true

        Window.TabDisplay.Text = Tab.Tabs[TabIdx].Name
        Window.SelectorPosMotor:setGoal(Flipper.Spring.new(Tab:GetCurrentTabPos(), { frequency = 6 }))

        task.spawn(function()
            Window.ContainerHolder.Parent = Window.ContainerAnim
            
            Window.ContainerPosMotor:setGoal(Flipper.Spring.new(15, { frequency = 10 }))
            Window.ContainerBackMotor:setGoal(Flipper.Spring.new(1, { frequency = 10 }))
            task.wait(0.12)
            for _, Container in next, Tab.Containers do
                Container.Visible = false
            end
            Tab.Containers[TabIdx].Visible = true
            Window.ContainerPosMotor:setGoal(Flipper.Spring.new(0, { frequency = 5 }))
            Window.ContainerBackMotor:setGoal(Flipper.Spring.new(0, { frequency = 8 }))
            task.wait(0.12)
            Window.ContainerHolder.Parent = Window.ContainerCanvas
        end)
    end

    return Tab
end

Component.Textbox = function(Parent, Acrylic)
    Acrylic = Acrylic or false
    local Textbox = {}

    Textbox.Input = Creator.New("TextBox", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromOffset(10, 0),
        ThemeTag = {
            TextColor3 = "Text",
            PlaceholderColor3 = "SubText",
        },
    })

    Textbox.Container = Creator.New("Frame", {
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Position = UDim2.new(0, 6, 0, 0),
        Size = UDim2.new(1, -12, 1, 0),
    }, {
        Textbox.Input,
    })

    Textbox.Indicator = Creator.New("Frame", {
        Size = UDim2.new(1, -4, 0, 1),
        Position = UDim2.new(0, 2, 1, 0),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundTransparency = Acrylic and 0.5 or 0,
        ThemeTag = {
            BackgroundColor3 = Acrylic and "InputIndicator" or "DialogInputLine",
        },
    })

    Textbox.Frame = Creator.New("Frame", {
        Size = UDim2.new(0, 0, 0, 30),
        BackgroundTransparency = Acrylic and 0.9 or 0,
        Parent = Parent,
        ThemeTag = {
            BackgroundColor3 = Acrylic and "Input" or "DialogInput",
        },
    }, {
        Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 4),
        }),
        Creator.New("UIStroke", {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Transparency = Acrylic and 0.5 or 0.65,
            ThemeTag = {
                Color = Acrylic and "InElementBorder" or "DialogButtonBorder",
            },
        }),
        Textbox.Indicator,
        Textbox.Container,
    })

    local function Update()
        local PADDING = 2
        local Reveal = Textbox.Container.AbsoluteSize.X

        if not Textbox.Input:IsFocused() or Textbox.Input.TextBounds.X <= Reveal - 2 * PADDING then
            Textbox.Input.Position = UDim2.new(0, PADDING, 0, 0)
        else
            local Cursor = Textbox.Input.CursorPosition
            if Cursor ~= -1 then
                local subtext = string.sub(Textbox.Input.Text, 1, Cursor - 1)
                local width = game:GetService("TextService"):GetTextSize(
                    subtext,
                    Textbox.Input.TextSize,
                    Textbox.Input.Font,
                    Vector2.new(math.huge, math.huge)
                ).X

                local CurrentCursorPos = Textbox.Input.Position.X.Offset + width
                if CurrentCursorPos < PADDING then
                    Textbox.Input.Position = UDim2.fromOffset(PADDING - width, 0)
                elseif CurrentCursorPos > Reveal - PADDING - 1 then
                    Textbox.Input.Position = UDim2.fromOffset(Reveal - width - PADDING - 1, 0)
                end
            end
        end
    end

    task.spawn(Update)

    Creator.AddSignal(Textbox.Input:GetPropertyChangedSignal("Text"), Update)
    Creator.AddSignal(Textbox.Input:GetPropertyChangedSignal("CursorPosition"), Update)

    Creator.AddSignal(Textbox.Input.Focused, function()
        Update()
        Textbox.Indicator.Size = UDim2.new(1, -2, 0, 2)
        Textbox.Indicator.Position = UDim2.new(0, 1, 1, 0)
        Textbox.Indicator.BackgroundTransparency = 0
        Creator.OverrideTag(Textbox.Frame, { BackgroundColor3 = Acrylic and "InputFocused" or "DialogHolder" })
        Creator.OverrideTag(Textbox.Indicator, { BackgroundColor3 = "Accent" })
    end)

    Creator.AddSignal(Textbox.Input.FocusLost, function()
        Update()
        Textbox.Indicator.Size = UDim2.new(1, -4, 0, 1)
        Textbox.Indicator.Position = UDim2.new(0, 2, 1, 0)
        Textbox.Indicator.BackgroundTransparency = 0.5
        Creator.OverrideTag(Textbox.Frame, { BackgroundColor3 = Acrylic and "Input" or "DialogInput" })
        Creator.OverrideTag(Textbox.Indicator, { BackgroundColor3 = Acrylic and "InputIndicator" or "DialogInputLine" })
    end)

    return Textbox
end

Component.TitleBar = function(Config)
    local TitleBar = {}

    local function BarButton(Icon, Pos, Parent, Callback)
        local Button = {
            Callback = Callback or function() end,
        }

        Button.Frame = Creator.New("TextButton", {
            Size = UDim2.new(0, 34, 1, -8),
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Parent = Parent,
            Position = Pos,
            Text = "",
            ThemeTag = {
                BackgroundColor3 = "Text",
            },
        }, {
            Creator.New("UICorner", {
                CornerRadius = UDim.new(0, 7),
            }),
            Creator.New("ImageLabel", {
                Image = Icon,
                Size = UDim2.fromOffset(16, 16),
                Position = UDim2.fromScale(0.5, 0.5),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Name = "Icon",
                ThemeTag = {
                    ImageColor3 = "Text",
                },
            }),
        })

        local Motor, SetTransparency = Creator.SpringMotor(1, Button.Frame, "BackgroundTransparency")

        Creator.AddSignal(Button.Frame.MouseEnter, function()
            SetTransparency(0.94)
        end)
        Creator.AddSignal(Button.Frame.MouseLeave, function()
            SetTransparency(1, true)
        end)
        Creator.AddSignal(Button.Frame.MouseButton1Down, function()
            SetTransparency(0.96)
        end)
        Creator.AddSignal(Button.Frame.MouseButton1Up, function()
            SetTransparency(0.94)
        end)
        Creator.AddSignal(Button.Frame.MouseButton1Click, Button.Callback)

        Button.SetCallback = function(Func)
            Button.Callback = Func
        end

        return Button
    end

    TitleBar.Frame = Creator.New("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        Parent = Config.Parent,
    }, {
        Creator.New("Frame", {
            Size = UDim2.new(1, -16, 1, 0),
            Position = UDim2.new(0, 16, 0, 0),
            BackgroundTransparency = 1,
        }, {
            Creator.New("UIListLayout", {
                Padding = UDim.new(0, 5),
                FillDirection = Enum.FillDirection.Horizontal,
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
            Creator.New("TextLabel", {
                RichText = true,
                Text = Config.Title,
                FontFace = Font.new(
                    "rbxasset://fonts/families/GothamSSm.json",
                    Enum.FontWeight.Regular,
                    Enum.FontStyle.Normal
                ),
                TextSize = 12,
                TextXAlignment = "Left",
                TextYAlignment = "Center",
                Size = UDim2.fromScale(0, 1),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                ThemeTag = {
                    TextColor3 = "Text",
                },
            }),
            Creator.New("TextLabel", {
                RichText = true,
                Text = Config.SubTitle,
                TextTransparency = 0.4,
                FontFace = Font.new(
                    "rbxasset://fonts/families/GothamSSm.json",
                    Enum.FontWeight.Regular,
                    Enum.FontStyle.Normal
                ),
                TextSize = 12,
                TextXAlignment = "Left",
                TextYAlignment = "Center",
                Size = UDim2.fromScale(0, 1),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                ThemeTag = {
                    TextColor3 = "Text",
                },
            }),
        }),
        Creator.New("Frame", {
            BackgroundTransparency = 0.5,
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, 0),
            ThemeTag = {
                BackgroundColor3 = "TitleBarLine",
            },
        }),
    })

    TitleBar.CloseButton = BarButton(Icons.Close, UDim2.new(1, -4, 0, 4), TitleBar.Frame, function()
        Fluent:Dialog({
            Title = "Close",
            Content = "Are you sure you want to unload the interface?",
            Buttons = {
                {
                    Title = "Yes",
                    Callback = function()
                        Fluent:Destroy()
                    end,
                },
                {
                    Title = "No",
                },
            },
        })
    end)
    TitleBar.MaxButton = BarButton(Icons.Max, UDim2.new(1, -40, 0, 4), TitleBar.Frame, function()
        Config.Window.Maximize(not Config.Window.Maximized)
    end)
    TitleBar.MinButton = BarButton(Icons.Min, UDim2.new(1, -80, 0, 4), TitleBar.Frame, function()
        Fluent.Window:Minimize()
    end)

    return TitleBar
end

Component.Window = function(Config)
    local Window = {
        Minimized = false,
        Maximized = false,
        Size = Config.Size,
        CurrentPos = 0,
        TabWidth = 0,
        Position = UDim2.fromOffset(
            Camera.ViewportSize.X / 2 - Config.Size.X.Offset / 2,
            Camera.ViewportSize.Y / 2 - Config.Size.Y.Offset / 2
        ),
    }

    local Dragging, DragInput, MousePos, StartPos = false
    local Resizing, ResizePos = false
    local MinimizeNotif = false

    Window.AcrylicPaint = Acrylic.AcrylicPaint()
    Window.TabWidth = Config.TabWidth or 150

    local Selector = Creator.New("Frame", {
        Size = UDim2.fromOffset(4, 0),
        BackgroundColor3 = Color3.fromRGB(76, 194, 255),
        Position = UDim2.fromOffset(0, 17),
        AnchorPoint = Vector2.new(0, 0.5),
        ThemeTag = {
            BackgroundColor3 = "Accent",
        },
    }, {
        Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 2),
        }),
    })

    local ResizeStartFrame = Creator.New("Frame", {
        Size = UDim2.fromOffset(20, 20),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 1, -20),
    })

    Window.TabHolder = Creator.New("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ScrollBarImageTransparency = 1,
        ScrollBarThickness = 0,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromScale(0, 0),
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, {
        Creator.New("UIListLayout", {
            Padding = UDim.new(0, 4),
        }),
    })

    local TabFrame = Creator.New("Frame", {
        Size = UDim2.new(0, Window.TabWidth, 1, -66),
        Position = UDim2.new(0, 12, 0, 54),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
    }, {
        Window.TabHolder,
        Selector,
    })

    Window.TabDisplay = Creator.New("TextLabel", {
        RichText = true,
        Text = "Tab",
        TextTransparency = 0,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        TextSize = 28,
        TextXAlignment = "Left",
        TextYAlignment = "Center",
        Size = UDim2.new(1, -16, 0, 28),
        Position = UDim2.fromOffset(Window.TabWidth + 26, 56),
        BackgroundTransparency = 1,
        ThemeTag = {
            TextColor3 = "Text",
        },
    })

    Window.ContainerHolder = Creator.New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
    })

    Window.ContainerAnim = Creator.New("CanvasGroup", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
    })

    Window.ContainerCanvas = Creator.New("Frame", {
        Size = UDim2.new(1, -Window.TabWidth - 32, 1, -102),
        Position = UDim2.fromOffset(Window.TabWidth + 26, 90),
        BackgroundTransparency = 1,
    }, {
        Window.ContainerAnim,
        Window.ContainerHolder
    })

    Window.Root = Creator.New("Frame", {
        BackgroundTransparency = 1,
        Size = Window.Size,
        Position = Window.Position,
        Parent = Config.Parent,
    }, {
        Window.AcrylicPaint.Frame,
        Window.TabDisplay,
        Window.ContainerCanvas,
        TabFrame,
        ResizeStartFrame,
    })

    Window.TitleBar = Component.TitleBar({
        Title = Config.Title,
        SubTitle = Config.SubTitle,
        Parent = Window.Root,
        Window = Window,
    })

    if Fluent.UseAcrylic then
        Window.AcrylicPaint.AddParent(Window.Root)
    end

    local SizeMotor = Flipper.SingleMotor.new(Window.Size.X.Offset)
    local SizeMotorY = Flipper.SingleMotor.new(Window.Size.Y.Offset)

    local PosMotor = Flipper.SingleMotor.new(Window.Position.X.Offset)
    local PosMotorY = Flipper.SingleMotor.new(Window.Position.Y.Offset)

    Window.SelectorPosMotor = Flipper.SingleMotor.new(17)
    Window.SelectorSizeMotor = Flipper.SingleMotor.new(0)
    Window.ContainerBackMotor = Flipper.SingleMotor.new(0)
    Window.ContainerPosMotor = Flipper.SingleMotor.new(94)

    SizeMotor:onStep(function(value)
        Window.Root.Size = UDim2.new(0, value, 0, SizeMotorY:getValue())
    end)

    SizeMotorY:onStep(function(value)
        Window.Root.Size = UDim2.new(0, SizeMotor:getValue(), 0, value)
    end)

    PosMotor:onStep(function(value)
        Window.Root.Position = UDim2.new(0, value, 0, PosMotorY:getValue())
    end)

    PosMotorY:onStep(function(value)
        Window.Root.Position = UDim2.new(0, PosMotor:getValue(), 0, value)
    end)

    local LastValue = 0
    local LastTime = 0
    Window.SelectorPosMotor:onStep(function(Value)
        Selector.Position = UDim2.new(0, 0, 0, Value + 17)
        local Now = tick()
        local DeltaTime = Now - LastTime

        if LastValue ~= nil then
            Window.SelectorSizeMotor:setGoal(Flipper.Spring.new((math.abs(Value - LastValue) / (DeltaTime * 60)) + 16))
            LastValue = Value
        end
        LastTime = Now
    end)

    Window.SelectorSizeMotor:onStep(function(Value)
        Selector.Size = UDim2.new(0, 4, 0, Value)
    end)

    Window.ContainerBackMotor:onStep(function(Value)
        Window.ContainerAnim.GroupTransparency = Value
    end)

    Window.ContainerPosMotor:onStep(function(Value)
        Window.ContainerAnim.Position = UDim2.fromOffset(0, Value)
    end)

    local OldSizeX
    local OldSizeY
    Window.Maximize = function(Value, NoPos, Instant)
        Window.Maximized = Value
        Window.TitleBar.MaxButton.Frame.Icon.Image = Value and Icons.Restore or Icons.Max

        if Value then
            OldSizeX = Window.Size.X.Offset
            OldSizeY = Window.Size.Y.Offset
        end
        local SizeX = Value and Camera.ViewportSize.X or OldSizeX
        local SizeY = Value and Camera.ViewportSize.Y or OldSizeY
        
        SizeMotor:setGoal(Flipper[Instant and "Instant" or "Spring"].new(SizeX, { frequency = 6 }))
        SizeMotorY:setGoal(Flipper[Instant and "Instant" or "Spring"].new(SizeY, { frequency = 6 }))
        
        Window.Size = UDim2.fromOffset(SizeX, SizeY)

        if not NoPos then
            PosMotor:setGoal(Flipper.Spring.new(Value and 0 or Window.Position.X.Offset, { frequency = 6 }))
            PosMotorY:setGoal(Flipper.Spring.new(Value and 0 or Window.Position.Y.Offset, { frequency = 6 }))
        end
    end

    Creator.AddSignal(Window.TitleBar.Frame.InputBegan, function(Input)
        if
            Input.UserInputType == Enum.UserInputType.MouseButton1
            or Input.UserInputType == Enum.UserInputType.Touch
        then
            Dragging = true
            MousePos = Input.Position
            StartPos = Window.Root.Position

            if Window.Maximized then
                StartPos = UDim2.fromOffset(
                    Mouse.X - (Mouse.X * ((OldSizeX - 100) / Window.Root.AbsoluteSize.X)),
                    Mouse.Y - (Mouse.Y * (OldSizeY / Window.Root.AbsoluteSize.Y))
                )
            end

            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    Creator.AddSignal(Window.TitleBar.Frame.InputChanged, function(Input)
        if
            Input.UserInputType == Enum.UserInputType.MouseMovement
            or Input.UserInputType == Enum.UserInputType.Touch
        then
            DragInput = Input
        end
    end)

    Creator.AddSignal(ResizeStartFrame.InputBegan, function(Input)
        if
            Input.UserInputType == Enum.UserInputType.MouseButton1
            or Input.UserInputType == Enum.UserInputType.Touch
        then
            Resizing = true
            ResizePos = Input.Position
        end
    end)

    Creator.AddSignal(UserInputService.InputChanged, function(Input)
        if Input == DragInput and Dragging then
            local Delta = Input.Position - MousePos
            Window.Position = UDim2.fromOffset(StartPos.X.Offset + Delta.X, StartPos.Y.Offset + Delta.Y)
            PosMotor:setGoal(Flipper.Instant.new(Window.Position.X.Offset))
            PosMotorY:setGoal(Flipper.Instant.new(Window.Position.Y.Offset))

            if Window.Maximized then
                Window.Maximize(false, true, true)
            end
        end

        if
            (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
            and Resizing
        then
            local Delta = Input.Position - ResizePos
            local StartSize = Window.Size

            local TargetSize = Vector3.new(StartSize.X.Offset, StartSize.Y.Offset, 0) + Vector3.new(1, 1, 0) * Delta
            local TargetSizeClamped = Vector2.new(math.clamp(TargetSize.X, 470, 2048), math.clamp(TargetSize.Y, 380, 2048))

            SizeMotor:setGoal(Flipper.Instant.new(TargetSizeClamped.X))
            SizeMotorY:setGoal(Flipper.Instant.new(TargetSizeClamped.Y))
        end
    end)

    Creator.AddSignal(UserInputService.InputEnded, function(Input)
        if Resizing == true or Input.UserInputType == Enum.UserInputType.Touch then
            Resizing = false
            Window.Size = UDim2.fromOffset(SizeMotor:getValue(), SizeMotorY:getValue())
        end
    end)

    Creator.AddSignal(Window.TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        Window.TabHolder.CanvasSize = UDim2.new(0, 0, 0, Window.TabHolder.UIListLayout.AbsoluteContentSize.Y)
    end)

    Creator.AddSignal(UserInputService.InputBegan, function(Input)
        if
            type(Fluent.MinimizeKeybind) == "table"
            and Fluent.MinimizeKeybind.Type == "Keybind"
            and not UserInputService:GetFocusedTextBox()
        then
            if Input.KeyCode.Name == Fluent.MinimizeKeybind.Value then
                Window:Minimize()
            end
        elseif Input.KeyCode == Fluent.MinimizeKey and not UserInputService:GetFocusedTextBox() then
            Window:Minimize()
        end
    end)

    function Window:Minimize()
        Window.Minimized = not Window.Minimized
        Window.Root.Visible = not Window.Minimized
        if not MinimizeNotif then
            MinimizeNotif = true
            local Key = Fluent.MinimizeKeybind and Fluent.MinimizeKeybind.Value or Fluent.MinimizeKey.Name
            Fluent:Notify({
                Title = "Interface",
                Content = "Press " .. Key .. " to toggle the interface.",
                Duration = 6
            })
        end
    end

    function Window:Destroy()
        if Fluent.UseAcrylic then
            Window.AcrylicPaint.Model:Destroy()
        end
        Window.Root:Destroy()
    end

    local DialogModule = Component.Dialog(Window)
    function Window:Dialog(Config)
        local Dialog = DialogModule:Create()
        Dialog.Title.Text = Config.Title

        local Content = Creator.New("TextLabel", {
            FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
            Text = Config.Content,
            TextColor3 = Color3.fromRGB(240, 240, 240),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.fromOffset(20, 60),
            BackgroundTransparency = 1,
            Parent = Dialog.Root,
            ClipsDescendants = false,
            ThemeTag = {
                TextColor3 = "Text",
            },
        })

        Creator.New("UISizeConstraint", {
            MinSize = Vector2.new(300, 165),
            MaxSize = Vector2.new(620, math.huge),
            Parent = Dialog.Root,
        })

        Dialog.Root.Size = UDim2.fromOffset(Content.TextBounds.X + 40, 165)
        if Content.TextBounds.X + 40 > Window.Size.X.Offset - 120 then
            Dialog.Root.Size = UDim2.fromOffset(Window.Size.X.Offset - 120, 165)
            Content.TextWrapped = true
            Dialog.Root.Size = UDim2.fromOffset(Window.Size.X.Offset - 120, Content.TextBounds.Y + 150)
        end

        for _, Button in next, Config.Buttons do
            Dialog:Button(Button.Title, Button.Callback)
        end

        Dialog:Open()
    end

    local TabModule = Component.Tab(Window)
    function Window:AddTab(TabConfig)
        return TabModule:New(TabConfig.Title, TabConfig.Icon, Window.TabHolder)
    end

    function Window:SelectTab(Tab)
        TabModule:SelectTab(1)
    end

    Creator.AddSignal(Window.TabHolder:GetPropertyChangedSignal("CanvasPosition"), function()
        LastValue = TabModule:GetCurrentTabPos() + 16
        LastTime = 0
        Window.SelectorPosMotor:setGoal(Flipper.Instant.new(TabModule:GetCurrentTabPos()))
    end)

    return Window
end

-- UI Elements
local Elements = {}
Elements.__index = Elements
Elements.__namecall = function(Table, Key, ...)
    return Elements[Key](...)
end

function Elements:AddSection(Config)
    assert(Config.Title, "Section - Missing Title")
    
    local Section = require(Components.Section)(Config.Title, self.Container)
    return Section
end

function Elements:AddButton(Config)
    assert(Config.Title, "Button - Missing Title")
    Config.Callback = Config.Callback or function() end

    local ButtonFrame = Component.Element(Config.Title, Config.Description, self.Container, true)

    local ButtonIco = Creator.New("ImageLabel", {
        Image = "rbxassetid://10709791437",
        Size = UDim2.fromOffset(16, 16),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        BackgroundTransparency = 1,
        Parent = ButtonFrame.Frame,
        ThemeTag = {
            ImageColor3 = "Text",
        },
    })

    Creator.AddSignal(ButtonFrame.Frame.MouseButton1Click, function()
        Fluent:SafeCallback(Config.Callback)
    end)

    return ButtonFrame
end

function Elements:AddToggle(Config)
    assert(Config.Title, "Toggle - Missing Title")

    local Toggle = {
        Value = Config.Default or false,
        Callback = Config.Callback or function(Value) end,
        Type = "Toggle",
    }

    local ToggleFrame = Component.Element(Config.Title, Config.Description, self.Container, true)
    ToggleFrame.DescLabel.Size = UDim2.new(1, -54, 0, 14)

    Toggle.SetTitle = ToggleFrame.SetTitle
    Toggle.SetDesc = ToggleFrame.SetDesc

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
        Parent = ToggleFrame.Frame,
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

        Fluent:SafeCallback(Toggle.Callback, Toggle.Value)
        Fluent:SafeCallback(Toggle.Changed, Toggle.Value)
    end

    Creator.AddSignal(ToggleFrame.Frame.MouseButton1Click, function()
        Toggle:SetValue(not Toggle.Value)
    end)

    Toggle:SetValue(Toggle.Value)

    local ElementIdx = #Fluent.Options + 1
    Fluent.Options[ElementIdx] = Toggle
    return Toggle
end

function Elements:AddSlider(Config)
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

    local SliderFrame = Component.Element(Config.Title, Config.Description, self.Container, false)
    SliderFrame.DescLabel.Size = UDim2.new(1, -170, 0, 14)

    Slider.SetTitle = SliderFrame.SetTitle
    Slider.SetDesc = SliderFrame.SetDesc

    local SliderDot = Creator.New("ImageLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(0, -7, 0.5, 0),
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
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
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
        Parent = SliderFrame.Frame,
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
        self.Value = Fluent:Round(math.clamp(Value, Slider.Min, Slider.Max), Slider.Rounding)
        SliderDot.Position = UDim2.new((self.Value - Slider.Min) / (Slider.Max - Slider.Min), -7, 0.5, 0)
        SliderFill.Size = UDim2.fromScale((self.Value - Slider.Min) / (Slider.Max - Slider.Min), 1)
        SliderDisplay.Text = tostring(self.Value)

        Fluent:SafeCallback(Slider.Callback, self.Value)
        Fluent:SafeCallback(Slider.Changed, self.Value)
    end

    Slider:SetValue(Config.Default)

    local ElementIdx = #Fluent.Options + 1
    Fluent.Options[ElementIdx] = Slider
    return Slider
end

function Elements:AddDropdown(Config)
    assert(Config.Title, "Dropdown - Missing Title")
    assert(Config.Default, "AddDropdown: Missing default value.")

    local Dropdown = {
        Values = Config.Values,
        Value = Config.Default,
        Multi = Config.Multi,
        Buttons = {},
        Opened = false,
        Type = "Dropdown",
        Callback = Config.Callback or function(Value) end,
    }

    local DropdownFrame = Component.Element(Config.Title, Config.Description, self.Container, false)
    DropdownFrame.DescLabel.Size = UDim2.new(1, -170, 0, 14)

    Dropdown.SetTitle = DropdownFrame.SetTitle
    Dropdown.SetDesc = DropdownFrame.SetDesc

    local DropdownDisplay = Creator.New("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
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
        Parent = DropdownFrame.Frame,
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
        Parent = Fluent.GUI,
        Visible = false,
    }, {
        DropdownHolderFrame,
        Creator.New("UISizeConstraint", {
            MinSize = Vector2.new(170, 0),
        }),
    })
    table.insert(Fluent.OpenFrames, DropdownHolderCanvas)

    local function RecalculateListPosition()
        local Add = 0
        if Camera.ViewportSize.Y - DropdownInner.AbsolutePosition.Y < DropdownHolderCanvas.AbsoluteSize.Y - 5 then
            Add = DropdownHolderCanvas.AbsoluteSize.Y
                - 5
                - (Camera.ViewportSize.Y - DropdownInner.AbsolutePosition.Y)
                + 40
        end
        DropdownHolderCanvas.Position = UDim2.fromOffset(DropdownInner.AbsolutePosition.X - 1, DropdownInner.AbsolutePosition.Y - 5 - Add)
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

    local ScrollFrame = self.ScrollFrame
    function Dropdown:Open()
        Dropdown.Opened = true
        ScrollFrame.ScrollingEnabled = false
        DropdownHolderCanvas.Visible = true
        TweenService:Create(
            DropdownHolderFrame,
            TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { Size = UDim2.fromScale(1, 1) }
        ):Play()
    end

    function Dropdown:Close()
        Dropdown.Opened = false
        ScrollFrame.ScrollingEnabled = true
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
                FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
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
            local SelectorSizeMotor = Flipper.SingleMotor.new(6)

            SelectorSizeMotor:onStep(function(value)
                ButtonSelector.Size = UDim2.new(0, 4, 0, value)
            end)

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

                SelectorSizeMotor:setGoal(Flipper.Spring.new(Selected and 14 or 6, { frequency = 6 }))
                SetSelTransparency(Selected and 0 or 1)
            end

            ButtonLabel.InputBegan:Connect(function(Input)
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

                        Fluent:SafeCallback(Dropdown.Callback, Dropdown.Value)
                        Fluent:SafeCallback(Dropdown.Changed, Dropdown.Value)
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

        Fluent:SafeCallback(Dropdown.Callback, Dropdown.Value)
        Fluent:SafeCallback(Dropdown.Changed, Dropdown.Value)
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

    local ElementIdx = #Fluent.Options + 1
    Fluent.Options[ElementIdx] = Dropdown
    return Dropdown
end

function Elements:AddInput(Config)
    assert(Config.Title, "Input - Missing Title")
    Config.Callback = Config.Callback or function() end

    local Input = {
        Value = Config.Default or "",
        Numeric = Config.Numeric or false,
        Finished = Config.Finished or false,
        Callback = Config.Callback or function(Value) end,
        Type = "Input",
    }

    local InputFrame = Component.Element(Config.Title, Config.Description, self.Container, false)

    Input.SetTitle = InputFrame.SetTitle
    Input.SetDesc = InputFrame.SetDesc

    local Textbox = Component.Textbox(InputFrame.Frame, true)
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

        Fluent:SafeCallback(Input.Callback, Input.Value)
        Fluent:SafeCallback(Input.Changed, Input.Value)
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

    local ElementIdx = #Fluent.Options + 1
    Fluent.Options[ElementIdx] = Input
    return Input
end

function Elements:AddKeybind(Config)
    assert(Config.Title, "KeyBind - Missing Title")
    assert(Config.Default, "KeyBind - Missing default value.")

    local Keybind = {
        Value = Config.Default,
        Toggled = false,
        Mode = Config.Mode or "Toggle",
        Type = "Keybind",
        Callback = Config.Callback or function(Value) end,
        ChangedCallback = Config.ChangedCallback or function(New) end,
    }

    local Picking = false

    local KeybindFrame = Component.Element(Config.Title, Config.Description, self.Container, true)

    Keybind.SetTitle = KeybindFrame.SetTitle
    Keybind.SetDesc = KeybindFrame.SetDesc

    local KeybindDisplayLabel = Creator.New("TextLabel", {
        FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        Text = Config.Default,
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Center,
        Size = UDim2.new(0, 0, 0, 14),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        ThemeTag = {
            TextColor3 = "Text",
        },
    })

    local KeybindDisplayFrame = Creator.New("TextButton", {
        Size = UDim2.fromOffset(0, 30),
        Position = UDim2.new(1, -10, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 0.9,
        Parent = KeybindFrame.Frame,
        AutomaticSize = Enum.AutomaticSize.X,
        ThemeTag = {
            BackgroundColor3 = "Keybind",
        },
    }, {
        Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 5),
        }),
        Creator.New("UIPadding", {
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
        }),
        Creator.New("UIStroke", {
            Transparency = 0.5,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            ThemeTag = {
                Color = "InElementBorder",
            },
        }),
        KeybindDisplayLabel,
    })

    function Keybind:GetState()
        if UserInputService:GetFocusedTextBox() and Keybind.Mode ~= "Always" then
            return false
        end

        if Keybind.Mode == "Always" then
            return true
        elseif Keybind.Mode == "Hold" then
            if Keybind.Value == "None" then
                return false
            end

            local Key = Keybind.Value

            if Key == "MouseLeft" or Key == "MouseRight" then
                return Key == "MouseLeft" and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                    or Key == "MouseRight"
                        and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
            else
                return UserInputService:IsKeyDown(Enum.KeyCode[Keybind.Value])
            end
        else
            return Keybind.Toggled
        end
    end

    function Keybind:SetValue(Key, Mode)
        Key = Key or Keybind.Key
        Mode = Mode or Keybind.Mode

        KeybindDisplayLabel.Text = Key
        Keybind.Value = Key
        Keybind.Mode = Mode
    end

    function Keybind:OnClick(Callback)
        Keybind.Clicked = Callback
    end

    function Keybind:OnChanged(Callback)
        Keybind.Changed = Callback
        Callback(Keybind.Value)
    end

    function Keybind:DoClick()
        Fluent:SafeCallback(Keybind.Callback, Keybind.Toggled)
        Fluent:SafeCallback(Keybind.Clicked, Keybind.Toggled)
    end

    Creator.AddSignal(KeybindDisplayFrame.InputBegan, function(Input)
        if
            Input.UserInputType == Enum.UserInputType.MouseButton1
            or Input.UserInputType == Enum.UserInputType.Touch
        then
            Picking = true
            KeybindDisplayLabel.Text = "..."

            task.wait(0.2)

            local Event
            Event = UserInputService.InputBegan:Connect(function(Input)
                local Key

                if Input.UserInputType == Enum.UserInputType.Keyboard then
                    Key = Input.KeyCode.Name
                elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Key = "MouseLeft"
                elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
                    Key = "MouseRight"
                end

                local EndedEvent
                EndedEvent = UserInputService.InputEnded:Connect(function(Input)
                    if
                        Input.KeyCode.Name == Key
                        or Key == "MouseLeft" and Input.UserInputType == Enum.UserInputType.MouseButton1
                        or Key == "MouseRight" and Input.UserInputType == Enum.UserInputType.MouseButton2
                    then
                        Picking = false

                        KeybindDisplayLabel.Text = Key
                        Keybind.Value = Key

                        Fluent:SafeCallback(Keybind.ChangedCallback, Input.KeyCode or Input.UserInputType)
                        Fluent:SafeCallback(Keybind.Changed, Input.KeyCode or Input.UserInputType)

                        Event:Disconnect()
                        EndedEvent:Disconnect()
                    end
                end)
            end)
        end
    end)

    Creator.AddSignal(UserInputService.InputBegan, function(Input)
        if not Picking and not UserInputService:GetFocusedTextBox() then
            if Keybind.Mode == "Toggle" then
                local Key = Keybind.Value

                if Key == "MouseLeft" or Key == "MouseRight" then
                    if
                        Key == "MouseLeft" and Input.UserInputType == Enum.UserInputType.MouseButton1
                        or Key == "MouseRight" and Input.UserInputType == Enum.UserInputType.MouseButton2
                    then
                        Keybind.Toggled = not Keybind.Toggled
                        Keybind:DoClick()
                    end
                elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                    if Input.KeyCode.Name == Key then
                        Keybind.Toggled = not Keybind.Toggled
                        Keybind:DoClick()
                    end
                end
            end
        end
    end)

    local ElementIdx = #Fluent.Options + 1
    Fluent.Options[ElementIdx] = Keybind
    return Keybind
end

function Elements:AddColorpicker(Config)
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

    local ColorpickerFrame = Component.Element(Config.Title, Config.Description, self.Container, true)

    Colorpicker.SetTitle = ColorpickerFrame.SetTitle
    Colorpicker.SetDesc = ColorpickerFrame.SetDesc

    local DisplayFrameColor = Creator.New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Colorpicker.Value,
        Parent = ColorpickerFrame.Frame,
    }, {
        Creator.New("UICorner", {
            CornerRadius = UDim.new(0, 4),
        }),
    })

    local DisplayFrame = Creator.New("ImageLabel", {
        Size = UDim2.fromOffset(26, 26),
        Position = UDim2.new(1, -10, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        Parent = ColorpickerFrame.Frame,
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
    
    local function createColorDialog()
        local Dialog = Component.Dialog(Fluent.Window):Create()
        Dialog.Title.Text = Colorpicker.Title
        Dialog.Root.Size = UDim2.fromOffset(430, 330)

        local Hue, Sat, Vib = Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib
        local Transparency = Colorpicker.Transparency

        local function createInput()
            local Box = Component.Textbox()
            Box.Frame.Parent = Dialog.Root
            Box.Frame.Size = UDim2.new(0, 90, 0, 32)

            return Box
        end

        local function createInputLabel(Text, Pos)
            return Creator.New("TextLabel", {
                FontFace = Font.new(
                    "rbxasset://fonts/families/GothamSSm.json",
                    Enum.FontWeight.Medium,
                    Enum.FontStyle.Normal
                ),
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

        local function getRGB()
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

        local HexInput = createInput()
        HexInput.Frame.Position = UDim2.fromOffset(Config.Transparency and 260 or 240, 55)
        createInputLabel("Hex", UDim2.fromOffset(Config.Transparency and 360 or 340, 55))

        local RedInput = createInput()
        RedInput.Frame.Position = UDim2.fromOffset(Config.Transparency and 260 or 240, 95)
        createInputLabel("Red", UDim2.fromOffset(Config.Transparency and 360 or 340, 95))

        local GreenInput = createInput()
        GreenInput.Frame.Position = UDim2.fromOffset(Config.Transparency and 260 or 240, 135)
        createInputLabel("Green", UDim2.fromOffset(Config.Transparency and 360 or 340, 135))

        local BlueInput = createInput()
        BlueInput.Frame.Position = UDim2.fromOffset(Config.Transparency and 260 or 240, 175)
        createInputLabel("Blue", UDim2.fromOffset(Config.Transparency and 360 or 340, 175))

        local AlphaInput
        if Config.Transparency then
            AlphaInput = createInput()
            AlphaInput.Frame.Position = UDim2.fromOffset(260, 215)
            createInputLabel("Alpha", UDim2.fromOffset(360, 215))
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
            RedInput.Input.Text = getRGB()["R"]
            GreenInput.Input.Text = getRGB()["G"]
            BlueInput.Input.Text = getRGB()["B"]

            if Config.Transparency then
                TransparencyColor.BackgroundColor3 = Color3.fromHSV(Hue, Sat, Vib)
                DialogDisplayFrame.BackgroundTransparency = Transparency
                TransparencyDrag.Position = UDim2.new(0, -1, 1 - Transparency, -6)
                AlphaInput.Input.Text = Fluent:Round((1 - Transparency) * 100, 0) .. "%"
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
                local CurrentColor = getRGB()
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
                local CurrentColor = getRGB()
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
                local CurrentColor = getRGB()
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

        Fluent:SafeCallback(Colorpicker.Callback, Colorpicker.Value)
        Fluent:SafeCallback(Colorpicker.Changed, Colorpicker.Value)
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

    Creator.AddSignal(ColorpickerFrame.Frame.MouseButton1Click, function()
        createColorDialog()
    end)

    Colorpicker:Display()

    local ElementIdx = #Fluent.Options + 1
    Fluent.Options[ElementIdx] = Colorpicker
    return Colorpicker
end

function Elements:AddParagraph(Config)
    assert(Config.Title, "Paragraph - Missing Title")
    Config.Content = Config.Content or ""

    local Paragraph = Component.Element(Config.Title, Config.Content, self.Container, false)
    Paragraph.Frame.BackgroundTransparency = 0.92
    Paragraph.Border.Transparency = 0.6

    return Paragraph
end

Fluent.Elements = Elements

-- GUI Setup
local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
local MainGUI = Creator.New("ScreenGui", {
    Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui"),
})
ProtectGui(MainGUI)

local NotificationModule = Component.Notification()
NotificationModule:Init(MainGUI)

-- Utility functions
function Fluent:SafeCallback(Callback, ...)
    if not Callback then
        return
    end

    local Success, Event = pcall(Callback, ...)
    if not Success then
        local _, i = Event:find(":%d+: ")

        if not i then
            return self:Notify({
                Title = "Interface",
                Content = "Callback error",
                SubContent = Event,
                Duration = 5,
            })
        end

        return self:Notify({
            Title = "Interface",
            Content = "Callback error",
            SubContent = Event:sub(i + 1),
            Duration = 5,
        })
    end
end

function Fluent:Round(Number, Factor)
    if Factor == 0 then
        return math.floor(Number)
    end
    Number = tostring(Number)
    return Number:find("%.") and tonumber(Number:sub(1, Number:find("%.") + Factor)) or Number
end

function Fluent:GetIcon(Name)
    if Name ~= nil and Name ~= "" then
        -- Simplified icon lookup logic - you'd implement your own icon system
        return "rbxassetid://" .. tostring(Name)
    end
    return nil
end

-- Window functions
function Fluent:CreateWindow(Config)
    assert(Config.Title, "Window - Missing Title")

    if Fluent.Window then
        print("You cannot create more than one window.")
        return
    end

    Fluent.MinimizeKey = Config.MinimizeKey or Enum.KeyCode.LeftControl
    Fluent.UseAcrylic = Config.Acrylic or false
    Fluent.Acrylic = Config.Acrylic or false
    Fluent.Theme = Config.Theme or "Dark"
    if Config.Acrylic then
        Acrylic.init()
    end

    local Window = Component.Window({
        Parent = MainGUI,
        Size = Config.Size or UDim2.fromOffset(600, 400),
        Title = Config.Title,
        SubTitle = Config.SubTitle or "",
        TabWidth = Config.TabWidth or 150,
    })

    Fluent.Window = Window
    Fluent:SetTheme(Config.Theme)

    return Window
end

function Fluent:SetTheme(Value)
    if Fluent.Window and table.find(Fluent.Themes, Value) then
        Fluent.Theme = Value
        Creator.UpdateTheme()
    end
end

function Fluent:Destroy()
    if Fluent.Window then
        Fluent.Unloaded = true
        if Fluent.UseAcrylic then
            Fluent.Window.AcrylicPaint.Model:Destroy()
        end
        Creator.Disconnect()
        MainGUI:Destroy()
    end
end

function Fluent:ToggleAcrylic(Value)
    if Fluent.Window then
        if Fluent.UseAcrylic then
            Fluent.Acrylic = Value
            Fluent.Window.AcrylicPaint.Model.Transparency = Value and 0.98 or 1
            if Value then
                Acrylic.Enable()
            else
                Acrylic.Disable()
            end
        end
    end
end

function Fluent:ToggleTransparency(Value)
    if Fluent.Window then
        Fluent.Window.AcrylicPaint.Frame.Background.BackgroundTransparency = Value and 0.35 or 0
    end
end

function Fluent:Notify(Config)
    return NotificationModule:New(Config)
end

function Fluent:Dialog(Config)
    if Fluent.Window then
        return Fluent.Window:Dialog(Config)
    end
end

-- Make the library available globally if in a supported environment
if getgenv then
    getgenv().Fluent = Fluent
end

return Fluent
