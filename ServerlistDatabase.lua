
Library = {
	Open = true,
	Tabs = {},
	Accent = Color3.fromRGB(250, 250, 250),
	Sections = {},
	Flags = {},
    Callbacks = {},
    Elements = {},
	UnNamedFlags = 0,
	Blurframe = nil,
	mainframe = nil,
    CurrentOpenDropdown = nil,
	DropdownActive = false,
	Dependencies = {},

	ThemeObjects = {},
	Holder = nil,
	Keys = {
		[Enum.KeyCode.LeftShift] = "LShift",
		[Enum.KeyCode.RightShift] = "RShift",
		[Enum.KeyCode.LeftControl] = "LCtrl",
		[Enum.KeyCode.RightControl] = "RCtrl",
		[Enum.KeyCode.LeftAlt] = "LAlt",
		[Enum.KeyCode.RightAlt] = "RAlt",
		[Enum.KeyCode.CapsLock] = "Caps",
		[Enum.KeyCode.One] = "1",
		[Enum.KeyCode.Two] = "2",
		[Enum.KeyCode.Three] = "3",
		[Enum.KeyCode.Four] = "4",
		[Enum.KeyCode.Five] = "5",
		[Enum.KeyCode.Six] = "6",
		[Enum.KeyCode.Seven] = "7",
		[Enum.KeyCode.Eight] = "8",
		[Enum.KeyCode.Nine] = "9",
		[Enum.KeyCode.Zero] = "0",
		[Enum.KeyCode.KeypadOne] = "Num1",
		[Enum.KeyCode.KeypadTwo] = "Num2",
		[Enum.KeyCode.KeypadThree] = "Num3",
		[Enum.KeyCode.KeypadFour] = "Num4",
		[Enum.KeyCode.KeypadFive] = "Num5",
		[Enum.KeyCode.KeypadSix] = "Num6",
		[Enum.KeyCode.KeypadSeven] = "Num7",
		[Enum.KeyCode.KeypadEight] = "Num8",
		[Enum.KeyCode.KeypadNine] = "Num9",
		[Enum.KeyCode.KeypadZero] = "Num0",
		[Enum.KeyCode.Minus] = "-",
		[Enum.KeyCode.Equals] = "=",
		[Enum.KeyCode.Tilde] = "~",
		[Enum.KeyCode.LeftBracket] = "[",
		[Enum.KeyCode.RightBracket] = "]",
		[Enum.KeyCode.RightParenthesis] = ")",
		[Enum.KeyCode.LeftParenthesis] = "(",
		[Enum.KeyCode.Semicolon] = ",",
		[Enum.KeyCode.Quote] = "'",
		[Enum.KeyCode.BackSlash] = "\\",
		[Enum.KeyCode.Comma] = ",",
		[Enum.KeyCode.Period] = ".",
		[Enum.KeyCode.Slash] = "/",
		[Enum.KeyCode.Asterisk] = "*",
		[Enum.KeyCode.Plus] = "+",
		[Enum.KeyCode.Period] = ".",
		[Enum.KeyCode.Backquote] = "`",
		[Enum.UserInputType.MouseButton1] = "MB1",
		[Enum.UserInputType.MouseButton2] = "MB2",
		[Enum.UserInputType.MouseButton3] = "MB3",
	},

	Connections = {},
	connections = {},
	UIKey = Enum.KeyCode.End,
	ScreenGUI = nil,
	Fontsize = 12,
}

local Path = game:GetService("RunService"):IsStudio() and game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") or game:GetService("CoreGui")

function Library.Disconnect(self, Connection)
	if (Connection) then
		Connection:Disconnect()
	end
end

Library.Subtabs = {}
setmetatable(Library.Subtabs, { __index = Library.Tabs })

Library.__index = Library
Library.Tabs.__index = Library.Tabs
Library.Sections.__index = Library.Sections
local LocalPlayer = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Mouse = LocalPlayer:GetMouse()

function Library:ChangeAccent(Color)
    self.Accent = Color

    for obj in pairs(self.ThemeObjects) do
        if not obj or not obj.Parent then return end

        if obj:IsA("Frame") or obj:IsA("TextButton") and obj.BackgroundTransparency < 1 then
            obj.BackgroundColor3 = Color
        elseif obj:IsA("TextLabel") then
            obj.TextColor3 = Color
        elseif obj:IsA("TextButton") and obj.BackgroundTransparency == 1 then
            obj.TextColor3 = Color
        elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            obj.ImageColor3 = Color
        elseif obj:IsA("UIStroke") then
            obj.Color = self:GetStrokeColor()
        end
    end

    local accentHex = Color:ToHex()
    local strokeHex = self:GetStrokeColor():ToHex()

    local function track(obj)
        if not obj or not obj:IsA("Instance") then return end

        if obj:IsA("UIStroke") and obj.Color:ToHex() == strokeHex then
            self.ThemeObjects[obj] = obj
        elseif (obj:IsA("Frame") or obj:IsA("TextButton")) and obj.BackgroundTransparency < 1 and obj.BackgroundColor3:ToHex() == accentHex then
            self.ThemeObjects[obj] = obj
        elseif (obj:IsA("TextLabel") or obj:IsA("TextButton")) and obj.TextColor3:ToHex() == accentHex then
            self.ThemeObjects[obj] = obj
        elseif (obj:IsA("ImageLabel") or obj:IsA("ImageButton")) and obj.ImageColor3:ToHex() == accentHex then
            self.ThemeObjects[obj] = obj
        end
    end

    for _, tab in pairs(self.Tabs) do
        if type(tab) == "table" and tab.Elements then
            for _, el in pairs(tab.Elements) do
                if type(el) == "table" and el.Holder and typeof(el.Holder) == "Instance" then
                    for _, obj in ipairs(el.Holder:GetDescendants()) do
                        track(obj)
                    end
                end
            end
        end
    end

    for _, tab in pairs(self.Subtabs) do
        if type(tab) == "table" and tab.Elements then
            for _, el in pairs(tab.Elements) do
                if type(el) == "table" and el.Holder and typeof(el.Holder) == "Instance" then
                    for _, obj in ipairs(el.Holder:GetDescendants()) do
                        track(obj)
                    end
                end
            end
        end
    end
end


function Library.Round(self, Number, Float)
	return Float * math.floor(Number / Float)
end

function Library.NextFlag()
	Library.UnNamedFlags = Library.UnNamedFlags + 1
	return string.format("%.14g", Library.UnNamedFlags)
end

function Library.CheckDependencies(element)
	if not element or not element.Depends then
		return true
	end
	
	for flag, requiredValue in pairs(element.Depends) do
		local currentValue = Library.Flags[flag]
		
		-- Handle different types of dependency checks
		if type(requiredValue) == "table" then
			-- Handle table-based requirements
			if requiredValue.contains then
				-- Check if currentValue (table) contains any of the required values
				if type(currentValue) ~= "table" then
					return false
				end
				
				local hasRequired = false
				for _, reqVal in ipairs(requiredValue.contains) do
					for _, curVal in ipairs(currentValue) do
						if curVal == reqVal then
							hasRequired = true
							break
						end
					end
					if hasRequired then break end
				end
				
				if not hasRequired then
					return false
				end
			elseif requiredValue.excludes then
				-- Check if currentValue does NOT contain any of the excluded values
				-- Handle single string values first
				if type(currentValue) == "string" then
					for _, excludeVal in ipairs(requiredValue.excludes) do
						if currentValue == excludeVal then
							return false -- Found an excluded value, fail the check
						end
					end
					-- Continue checking other dependencies - don't return true here
				elseif type(currentValue) == "table" then
					-- Handle table values
					for _, excludeVal in ipairs(requiredValue.excludes) do
						for _, curVal in ipairs(currentValue) do
							if curVal == excludeVal then
								return false -- Found an excluded value, fail the check
							end
						end
					end
					-- Continue checking other dependencies - don't return true here
				end
				-- If currentValue is neither string nor table, continue checking other dependencies
			elseif requiredValue.containsAll then
				-- Check if currentValue (table) contains all of the required values
				if type(currentValue) ~= "table" then
					return false
				end
				
				for _, reqVal in ipairs(requiredValue.containsAll) do
					local found = false
					for _, curVal in ipairs(currentValue) do
						if curVal == reqVal then
							found = true
							break
						end
					end
					if not found then
						return false
					end
				end
			else
				-- Direct table comparison
				if currentValue ~= requiredValue then
					return false
				end
			end
		elseif type(requiredValue) == "function" then
			-- Handle function-based requirements for custom logic
			if not requiredValue(currentValue) then
				return false
			end
		else
			-- Handle simple value comparison
			if currentValue ~= requiredValue then
				return false
			end
		end
	end
	
	return true
end

function Library.UpdateElementVisibility(element)
	if not element then return end
	
	local shouldShow = Library.CheckDependencies(element)
	if element.SetVisible then
		element:SetVisible(shouldShow)
	end
end

function Library.UpdateAllDependencies()
	for flag, element in pairs(Library.Elements) do
		if element.Depends then
			Library.UpdateElementVisibility(element)
		end
	end
end

function Library.SetFlag(flag, value)
	Library.Flags[flag] = value
	
	-- Update dependencies when a flag changes
	Library.UpdateAllDependencies()
	
	-- Call the callback if it exists
	if Library.Callbacks[flag] then
		Library.Callbacks[flag](value)
	end
end

function Library.InitializeAllDependencies()
	-- Wait a moment for all elements to be created, then update all dependencies
	task.spawn(function()
		task.wait(0.2)
		Library.UpdateAllDependencies()
	end)
end

function Library.GetConfig(self)
	local Config = ""
    for Index, Value in pairs(self.Flags) do
        local element = Library.Elements[Index]
        local isButton = element and (element.IsButton or element.Name == "Button" or Index:find("Button"))
        if (Index ~= "ConfigConfig_List" and Index ~= "ConfigConfig_Load" and Index ~= "ConfigConfig_Save" and Index ~= "ConfigName" and Index ~= "ConfigList" and not isButton and typeof(Value) ~= "function") then
			local Value2 = Value
			local Final = ""

			if (typeof(Value2) == "Color3") then
				local hue, sat, val = Value2:ToHSV()
				Final = ("rgb(%s,%s,%s,%s)"):format(tostring(hue), tostring(sat), tostring(val), tostring(1))
			elseif (typeof(Value2) == "table" and Value2.Color and Value2.Transparency) then
				local hue, sat, val = Value2.Color:ToHSV()
				Final = ("rgb(%s,%s,%s,%s)"):format(tostring(hue), tostring(sat), tostring(val), tostring(Value2.Transparency))
			elseif (typeof(Value2) == "table" and Value.Mode) then
				local Values = Value.current
				Final = ("key(%s,%s,%s)"):format(Values[1] or "nil", Values[2] or "nil", Value.Mode)
			elseif (Value2 ~= nil) then
				if (typeof(Value2) == "boolean") then
					Value2 = ("bool(%s)"):format(tostring(Value2))
				elseif (typeof(Value2) == "table") then
					local New = "table("
					for Index2, Value3 in pairs(Value2) do
						New = New .. Value3 .. ","
					end
					if (New:sub(#New) == ",") then
						New = New:sub(0, #New - 1)
					end
					Value2 = New .. ")"
				elseif (typeof(Value2) == "string") then
					Value2 = ("string(%s)"):format(Value2)
				elseif (typeof(Value2) == "number") then
					Value2 = ("number(%s)"):format(tostring(Value2))
				end
				Final = Value2
			end
			Config = Config .. Index .. ": " .. tostring(Final) .. "\n"
		end
	end
	return Config
end

function Library.LoadConfig(self, Config)
	if not (Config and type(Config) == "string" and Config:len() > 0) then
		return
	end
	
	local Table = string.split(Config, "\n")

	for Index, Value in pairs(Table) do
		local Table3 = string.split(Value, ":")

		if (#Table3 >= 2) then
			local flagName = Table3[1]
			local flagValue = Table3[2]:sub(2) 

			local element = Library.Elements[flagName]
			local isButton = element and (element.IsButton or element.Name == "Button" or flagName:find("Button"))
			local isFunction = typeof(Library.Flags[flagName]) == "function"
			
			if (flagName == "ConfigConfig_List" or flagName == "ConfigConfig_Load" or flagName == "ConfigConfig_Save" or flagName == "ConfigName" or flagName == "ConfigList" or isButton or isFunction) then
				return
			end

			if (flagValue:sub(1, 3) == "rgb") then
				local values = string.split(flagValue:sub(5, #flagValue - 1), ",")
				if (#values >= 3) then
					local h, s, v, a = tonumber(values[1]), tonumber(values[2]), tonumber(values[3]), tonumber(values[4])
					if (h and s and v) then
						flagValue = Color3.fromHSV(h, s, v)
					end
				end
			elseif (flagValue:sub(1, 3) == "key") then
				local values = string.split(flagValue:sub(5, #flagValue - 1), ",")
				if (values[1] == "nil") then
					values[1] = nil
				end
				if (values[2] == "nil") then
					values[2] = nil
				end
				flagValue = values
			elseif (flagValue:sub(1, 4) == "bool") then
				flagValue = flagValue:sub(6, #flagValue - 1) == "true"
			elseif (flagValue:sub(1, 5) == "table") then
				local tableStr = flagValue:sub(7, #flagValue - 1)
				if (tableStr == "") then
					flagValue = {}
				else
					flagValue = string.split(tableStr, ",")
				end
			elseif (flagValue:sub(1, 6) == "string") then
				flagValue = flagValue:sub(8, #flagValue - 1)
			elseif (flagValue:sub(1, 6) == "number") then
				flagValue = tonumber(flagValue:sub(8, #flagValue - 1))
			elseif (flagValue:sub(1, 4) == "enum") then
				local enumStr = flagValue:sub(6, #flagValue - 1)
				for keyName, keyCode in pairs(Library.Keys) do
					if (tostring(keyName) == enumStr) then
						flagValue = keyName
						break
					end
				end
			end

            Library.Flags[flagName] = flagValue
            if (element and element.Set and not isButton) then
                element:Set(flagValue)
            end
        end
	end
end

function Library.IsMouseOverFrame(self, Frame)
	local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize

	if (Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y) then
		return true
	end

	return false
end

function Library.Coonnection(self, Signal, Callback)
	local Con = Signal:Connect(Callback)
	return Con
end

function Library.connection(self, signal, callback)
	local connection = signal:Connect(callback)
	table.insert(Library.connections, connection)
	return connection
end

function Library.GetStrokeColor(self, brightFactor)
	brightFactor = brightFactor or 1.15

	return Color3.new(
		math.min(Library.Accent.R * brightFactor, 1),
		math.min(Library.Accent.G * brightFactor, 1),
		math.min(Library.Accent.B * brightFactor, 1)
	)
end

local Tabs = Library.Tabs
local Sections = Library.Sections

function Library.MakeDraggable(self, topbarobject, object)
    local Dragging = false
    local DragInput
    local DragStart
    local StartPosition
    
    local function Update(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
        object.Position = pos
    end
    
    topbarobject.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
            
            input.Changed:Connect(function()
                if (input.UserInputState == Enum.UserInputState.End) then
                    Dragging = false
                end
            end)
        end
    end)
    
    topbarobject.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            DragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if (input == DragInput and Dragging) then
            Update(input)
        end
    end)
end

function Library.Window(self, Options)
	local Window = {
		Tabs = {},
		Name = Options.Name or "lunacy.solutions",
        Key = Options.Key,
        Logo = Options.Logo,
		Sections = {},
		Elements = {},
		Dragging = { false, UDim2.new(0, 0, 0, 0) },
	}

    if (Window.Key and Window.Key ~= "LunacyWindowsDetectionBoss7261") then 
		return 
	end

	local newgabrieluibyraphael = Instance.new("ScreenGui", Path)
	newgabrieluibyraphael.Name = "a ui by raphael"
	newgabrieluibyraphael.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	Library:connection(UserInputService.InputBegan, function(Input)
		if (Input.KeyCode == Library.UIKey) then
			Library:SetOpen(not Library.Open)
		end
	end)
	
    local mainframe = Instance.new("Frame", newgabrieluibyraphael)
    mainframe.Name = "mainframe"
    mainframe.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    mainframe.BackgroundTransparency = 0.07
    mainframe.BorderColor3 = Color3.fromRGB(0, 0, 0)
    mainframe.BorderSizePixel = 0

	function Library.GetScaledTextSize(originalSize, customScale)
		if (not Library.mainframe) then
			return originalSize
		end
		
		local currentSize = Library.mainframe.AbsoluteSize
		local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
		
		local baseSize
		if (isMobile) then
			baseSize = Vector2.new(375, 400)
		else
			baseSize = Vector2.new(665, 467)
		end
		
		local scaleX = currentSize.X / baseSize.X
		local scaleY = currentSize.Y / baseSize.Y
		local scaleFactor = math.min(scaleX, scaleY)
		
		if (customScale) then
			scaleFactor = scaleFactor * customScale
		end
		
		if (isMobile) then
			scaleFactor = scaleFactor * 0.9
		end
		
		local finalSize = originalSize * scaleFactor
		
		local minSize, maxSize
		if (isMobile) then
			minSize = math.max(8, originalSize * 0.85)
			maxSize = math.min(24, originalSize * 1.1)
		else
			minSize = originalSize * 0.96
			maxSize = originalSize * 1.0
		end
		
		return math.clamp(math.floor(finalSize + 0.5), minSize, maxSize)
	end

	function Library.GetSizeScaled(originalUDim2, customScale)
		local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
		local scaleFactor = 1
		
		if (customScale) then
			scaleFactor = customScale
		elseif (isMobile) then
			scaleFactor = 0.85
		end
		
		return UDim2.new(
			originalUDim2.X.Scale,
			math.floor(originalUDim2.X.Offset * scaleFactor),
			originalUDim2.Y.Scale,
			math.floor(originalUDim2.Y.Offset * scaleFactor)
		)
	end

	function Library.SizeFromOffset(x, y, customScale)
		return Library.GetSizeScaled(UDim2.fromOffset(x, y), customScale)
	end

	function Library.SizeNew(xScale, xOffset, yScale, yOffset, customScale)
		return Library.GetSizeScaled(UDim2.new(xScale, xOffset, yScale, yOffset), customScale)
	end

	function Library.PosFromOffset(x, y)
		return UDim2.fromOffset(x, y)
	end

	function Library.PosNew(xScale, xOffset, yScale, yOffset)
		return UDim2.new(xScale, xOffset, yScale, yOffset)
	end

	function Library.UDim2(xScale, xOffset, yScale, yOffset, noScale)
		if (noScale) then
			return UDim2.new(xScale, xOffset, yScale, yOffset)
		end
		return Library.GetSizeScaled(UDim2.new(xScale, xOffset, yScale, yOffset))
	end

	function Library.UpdateTextScaling(self)
		if (not self.mainframe) then
			return
		end
		
		for _, descendant in pairs(self.mainframe:GetDescendants()) do
			if (descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox")) then
				if (not descendant:GetAttribute("OriginalTextSize")) then
					descendant:SetAttribute("OriginalTextSize", descendant.TextSize)
				end
				
				local originalSize = descendant:GetAttribute("OriginalTextSize")
				descendant.TextSize = Library.GetScaledTextSize(originalSize)
			end
		end
	end

	local function calculatenewpos()
		local viewportSize = workspace.CurrentCamera.ViewportSize
		local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

		local width, height
		if (isMobile) then
			width = math.max(math.min(viewportSize.X * 0.9, 500), 250)
			height = math.max(math.min(viewportSize.Y * 0.8, 400), 350)
		else
			width = 665
			height = 467
		end
		
		mainframe.Size = Library.UDim2(0, width, 0, height)
		
		local x = (viewportSize.X - width) / 2
		local y = (viewportSize.Y - height) / 2
		
		if (isMobile) then
			y = math.max(y, 20)
		end
		
		mainframe.Position = UDim2.new(0, x, 0, y)
		Library:UpdateTextScaling()
	end

	calculatenewpos()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(calculatenewpos)

	Library.ScreenGUI = newgabrieluibyraphael
	Library.mainframe = mainframe

	function Library.Resize(self, object)
		local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
		
		local Frame = Instance.new("Frame")
		Frame.Position = UDim2.new(1, isMobile and -80 or -25, 1, isMobile and -80 or -25)
		Frame.Size = UDim2.new(0, isMobile and 80 or 25, 0, isMobile and 80 or 25)
		Frame.BackgroundTransparency = 1
		Frame.BorderSizePixel = 0
		Frame.ZIndex = 100
		Frame.Parent = object
		
		local resizing = false
		local startPos = nil
		local startSize = nil
		
		local function updateSize(inputPos, finishResize)
			if (not startPos or not startSize) then 
				return 
			end
			
			local deltaX = inputPos.X - startPos.X
			local deltaY = inputPos.Y - startPos.Y
			
			local viewport = workspace.CurrentCamera.ViewportSize
			local minWidth = 350
			local minHeight = 250
			local maxWidth = viewport.X * 0.98 or viewport.X * 0.9
			local maxHeight = viewport.Y * 0.95 or viewport.Y * 0.9
			
			local newWidth = math.clamp(startSize.X.Offset + deltaX, minWidth, maxWidth)
			local newHeight = math.clamp(startSize.Y.Offset + deltaY, minHeight, maxHeight)
			
			object.Size = UDim2.new(startSize.X.Scale, newWidth, startSize.Y.Scale, newHeight)
			
			-- Only call expensive operations when finishing resize
			if (finishResize) then
				Library:UpdateTextScaling()
			end
		end
		
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if (gameProcessed) then 
				return 
			end
			
			local inputPos = input.Position
			local framePos = Frame.AbsolutePosition
			local frameSize = Frame.AbsoluteSize
			
			local inBounds = inputPos.X >= framePos.X and inputPos.X <= framePos.X + frameSize.X and inputPos.Y >= framePos.Y and inputPos.Y <= framePos.Y + frameSize.Y
			
			if (inBounds and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)) then
				resizing = true
				startPos = input.Position
				startSize = object.Size
			end
		end)
		
		UserInputService.InputChanged:Connect(function(input, gameProcessed)
			if (resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)) then
				updateSize(input.Position, false)
			end
		end)
		
		UserInputService.InputEnded:Connect(function(input, gameProcessed)
			if ((input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and resizing) then
				-- Call updateSize one final time with finishResize = true to apply expensive operations
				updateSize(input.Position, true)
				resizing = false
				startPos = nil
				startSize = nil
			end
		end)
	end

	Library:Resize(mainframe)

	local uIStroke = Instance.new("UIStroke")	
	uIStroke.Name = "UIStroke"
	uIStroke.Color = Color3.fromRGB(45, 45, 45)
	uIStroke.Thickness = 2.4
	uIStroke.Transparency = 1
	uIStroke.Parent = mainframe

	local uICorner = Instance.new("UICorner")	
	uICorner.Name = "UICorner"
	uICorner.CornerRadius = UDim.new(0, 12)
	uICorner.Parent = mainframe

	local acrylicthing = Instance.new("ImageLabel")	
	acrylicthing.Name = "acrylicthing"
	acrylicthing.Image = "rbxassetid://9968344105"
	acrylicthing.ImageTransparency = 0.98
	acrylicthing.ScaleType = Enum.ScaleType.Tile
	acrylicthing.TileSize = UDim2.fromOffset(128, 128)
	acrylicthing.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	acrylicthing.BackgroundTransparency = 1
	acrylicthing.BorderColor3 = Color3.fromRGB(0, 0, 0)
	acrylicthing.BorderSizePixel = 0
	acrylicthing.Size = UDim2.fromScale(1, 1)

	local uICorner1 = Instance.new("UICorner")	
	uICorner1.Name = "UICorner"
	uICorner1.Parent = acrylicthing

	acrylicthing.Parent = mainframe

	local acrylicthing1 = Instance.new("ImageLabel")	
	acrylicthing1.Name = "acrylicthing"
	acrylicthing1.Image = "rbxassetid://9968344227"
	acrylicthing1.ImageTransparency = 0.95
	acrylicthing1.ScaleType = Enum.ScaleType.Tile
	acrylicthing1.TileSize = UDim2.fromOffset(128, 128)
	acrylicthing1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	acrylicthing1.BackgroundTransparency = 1
	acrylicthing1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	acrylicthing1.BorderSizePixel = 0
	acrylicthing1.Size = UDim2.fromScale(1, 1)

	local uICorner2 = Instance.new("UICorner")	
	uICorner2.Name = "UICorner"
	uICorner2.Parent = acrylicthing1

	acrylicthing1.Parent = mainframe

	local theholderdwbbg = Instance.new("Frame")	
	theholderdwbbg.Name = "theholderdwbbg"
	theholderdwbbg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	theholderdwbbg.BackgroundTransparency = 1
	theholderdwbbg.BorderColor3 = Color3.fromRGB(0, 0, 0)
	theholderdwbbg.BorderSizePixel = 0
	theholderdwbbg.Size = UDim2.fromScale(1, 1)

	local uIListLayout = Instance.new("UIListLayout")	
	uIListLayout.Name = "UIListLayout"
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Parent = theholderdwbbg

	local sidebarHolder = Instance.new("Frame")	
	sidebarHolder.Name = "SidebarHolder"
	sidebarHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sidebarHolder.BackgroundTransparency = 1
	sidebarHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
	sidebarHolder.BorderSizePixel = 0
	sidebarHolder.Size = Library.UDim2(0, 150, 1, 0)

	local anothersidebarholder = Instance.new("Frame")	
	anothersidebarholder.Name = "anothersidebarholder"
	anothersidebarholder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	anothersidebarholder.BackgroundTransparency = 1
	anothersidebarholder.BorderColor3 = Color3.fromRGB(0, 0, 0)
	anothersidebarholder.BorderSizePixel = 0
	anothersidebarholder.Size = UDim2.fromScale(1, 1)

	local uIListLayout1 = Instance.new("UIListLayout")	
	uIListLayout1.Name = "UIListLayout"
	uIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout1.Parent = anothersidebarholder

	local buttonsholder = Instance.new("Frame")	
	buttonsholder.Name = "Buttonsholder"
	buttonsholder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	buttonsholder.BackgroundTransparency = 1
	buttonsholder.BorderColor3 = Color3.fromRGB(0, 0, 0)
	buttonsholder.BorderSizePixel = 0
	buttonsholder.LayoutOrder = 1
	buttonsholder.Size = Library.UDim2(1, 0, 0, 45)

	Library:MakeDraggable(buttonsholder, mainframe)

	local buttons = Instance.new("Frame")	
	buttons.Name = "Buttons"
	buttons.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	buttons.BackgroundTransparency = 1
	buttons.BorderColor3 = Color3.fromRGB(0, 0, 0)
	buttons.BorderSizePixel = 0
	buttons.Size = UDim2.fromScale(1, 1)

	local uIListLayout2 = Instance.new("UIListLayout")	
	uIListLayout2.Name = "UIListLayout"
	uIListLayout2.Padding = UDim.new(0, 6)
	uIListLayout2.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout2.VerticalAlignment = Enum.VerticalAlignment.Center
	uIListLayout2.Parent = buttons

	-- Create title container
	local titleContainer = Instance.new("Frame")
	titleContainer.Name = "TitleContainer"
	titleContainer.BackgroundTransparency = 1
	titleContainer.Size = Library.UDim2(0, 140, 1, 0)
	titleContainer.Position = UDim2.fromScale(0.35, -3.18E-2)
	
	-- Create logo if provided
	if Window.Logo then
		local logoImage = Instance.new("ImageLabel")
		logoImage.Name = "Logo"
		logoImage.Image = Window.Logo
		logoImage.BackgroundTransparency = 1
		logoImage.ImageTransparency = 0.3 -- 70% visible
		logoImage.Size = Library.UDim2(0, 25, 0, 25)
		logoImage.Position = UDim2.fromScale(0.15, 0.5)
		logoImage.AnchorPoint = Vector2.new(0, 0.5)
		logoImage.Parent = titleContainer
		
		-- Add corner radius to logo
		local logoCorner = Instance.new("UICorner")
		logoCorner.CornerRadius = UDim.new(0, 4)
		logoCorner.Parent = logoImage
	end
	
	-- Create text label
	local textLabel = Instance.new("TextLabel")	
    textLabel.Name = "TitleText"
	textLabel.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	textLabel.Text = Window.Name
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextSize = Library.GetScaledTextSize(15)
	textLabel.TextWrapped = true
	textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.BackgroundTransparency = 1
	textLabel.BorderColor3 = Color3.fromRGB(27, 42, 53)
	textLabel.BorderSizePixel = 0
	textLabel.Size = Library.UDim2(0, 100, 1, 0)
	textLabel.Position = UDim2.fromScale(0.25, 0.5)
	textLabel.AnchorPoint = Vector2.new(0, 0.5)
	textLabel.Parent = titleContainer
	
	titleContainer.Parent = buttons

	buttons.Parent = buttonsholder
	buttonsholder.Parent = anothersidebarholder

	local BlurTemplate = Instance.new("Frame")	
	BlurTemplate.Size = Library.UDim2(0.95, 0, 0.95, 0)
	BlurTemplate.Position = UDim2.new(0.5, 0, 0.5, 0)
	BlurTemplate.AnchorPoint = Vector2.new(0.5, 0.5)
	BlurTemplate.BackgroundTransparency = 1
	Library.BlurTemplate = BlurTemplate

	local troot = Instance.new("Folder", workspace.CurrentCamera)
	troot.Name = "BlurSnox"

	local gTokenMH = 99999999
	local gToken = math.random(1, gTokenMH)

	local DepthOfField = Instance.new("DepthOfFieldEffect", game:GetService("Lighting"))
	DepthOfField.FarIntensity = 0
	Library.Blurframe = DepthOfField
	DepthOfField.FocusDistance = 51.6
	DepthOfField.InFocusRadius = 50
	DepthOfField.NearIntensity = 1
	DepthOfField.Name = "DPT_" .. gToken

	local blurframe = Library.BlurTemplate:Clone()
	blurframe.Parent = mainframe

	local GenUid
	do
		local id = 0
		function GenUid()
			id = id + 1
			return "neon::" .. tostring(id)
		end
	end

	local function IsNotNaN(x)
		return x == x
	end

	local dothat = IsNotNaN(workspace.CurrentCamera:ScreenPointToRay(0, 0).Origin.x)
	while (not dothat) do
		RunService.RenderStepped:wait()
		dothat = IsNotNaN(workspace.CurrentCamera:ScreenPointToRay(0, 0).Origin.x)
	end

	local DrawQuad
	local acos, max, pi, sqrt = math.acos, math.max, math.pi, math.sqrt
	local sz = 0.2

	function DrawTriangle(v1, v2, v3, p0, p1)
		local s1 = (v1 - v2).magnitude
		local s2 = (v2 - v3).magnitude
		local s3 = (v3 - v1).magnitude
		local smax = max(s1, s2, s3)
		local A, B, C
		if (s1 == smax) then
			A, B, C = v1, v2, v3
		elseif (s2 == smax) then
			A, B, C = v2, v3, v1
		elseif (s3 == smax) then
			A, B, C = v3, v1, v2
		end

		local para = ((B - A).x * (C - A).x + (B - A).y * (C - A).y + (B - A).z * (C - A).z) / (A - B).magnitude
		local perp = sqrt((C - A).magnitude ^ 2 - para * para)
		local dif_para = (A - B).magnitude - para

		local st = CFrame.new(B, A)
		local za = CFrame.Angles(pi / 2, 0, 0)

		local cf0 = st

		local Top_Look = (cf0 * za).lookVector
		local Mid_Point = A + CFrame.new(A, B).LookVector * para
		local Needed_Look = CFrame.new(Mid_Point, C).LookVector
		local dot = Top_Look.x * Needed_Look.x + Top_Look.y * Needed_Look.y + Top_Look.z * Needed_Look.z

		local ac = CFrame.Angles(0, 0, acos(dot))

		cf0 = cf0 * ac
		if (((cf0 * za).lookVector - Needed_Look).magnitude > 0.01) then
			cf0 = cf0 * CFrame.Angles(0, 0, -2* acos(dot))
		end
		cf0 = cf0 * CFrame.new(0, perp / 2, -(dif_para + para / 2))

		local cf1 = st * ac * CFrame.Angles(0, pi, 0)
		if (((cf1 * za).lookVector - Needed_Look).magnitude > 0.01) then
			cf1 = cf1 * CFrame.Angles(0, 0, 2 * acos(dot))
		end
		cf1 = cf1 * CFrame.new(0, perp / 2, dif_para / 2)

		if (not p0) then
			p0 = Instance.new("Part")			
			p0.FormFactor = "Custom"
			p0.TopSurface = 0
			p0.BottomSurface = 0
			p0.Anchored = true
			p0.CanCollide = false
			p0.CastShadow = false
			p0.Material = "Glass"
			p0.Size = Vector3.new(sz, sz, sz)
			local mesh = Instance.new("SpecialMesh", p0)
			mesh.MeshType = 2
			mesh.Name = "WedgeMesh"
		end
		p0.WedgeMesh.Scale = Vector3.new(0, perp / sz, para / sz)
		p0.CFrame = cf0

		if (not p1) then
			p1 = p0:clone()
		end
		p1.WedgeMesh.Scale = Vector3.new(0, perp / sz, dif_para / sz)
		p1.CFrame = cf1

		return p0, p1
	end

	function DrawQuad(v1, v2, v3, v4, parts)
		parts[1], parts[2] = DrawTriangle(v1, v2, v3, parts[1], parts[2])
		parts[3], parts[4] = DrawTriangle(v3, v2, v4, parts[3], parts[4])
	end

	local binds = {}

	--warn("SetOpen")
	function Library.SetOpen(self, bool)
		if (typeof(bool) == "boolean") then
			Library.Open = bool
			Library.Blurframe.Enabled = bool
			Library.mainframe.Visible = bool

			if (bool) then
				blurframe = Library.BlurTemplate:Clone()
				blurframe.Parent = mainframe

				local parents = {}
				local function add(child)
					if (child:IsA("GuiObject")) then
						parents[#parents + 1] = child
						add(child.Parent)
					end
				end

				table.clear(parents)
				add(blurframe)

				local uid = GenUid()
				local parts = {}
				local f = Instance.new("Folder", root)
				f.Name = blurframe.Name

				binds[uid] = {
					parts = parts,
					frame = blurframe,
				}

				local function UpdateOrientation(fetchProps)
					local properties = {
						Transparency = 0.98,
						BrickColor = BrickColor.new("Institutional white"),
					}
					local zIndex = 1 - 0.05 * blurframe.ZIndex

					local tl, br = blurframe.AbsolutePosition, blurframe.AbsolutePosition + blurframe.AbsoluteSize
					local tr, bl = Vector2.new(br.x, tl.y), Vector2.new(tl.x, br.y)
					
					local rot = 0
					for _, v in ipairs(parents) do
						rot = rot + v.Rotation
					end
					if (rot ~= 0 and rot % 180 ~= 0) then
						local mid = tl:lerp(br, 0.5)
						local s, c = math.sin(math.rad(rot)), math.cos(math.rad(rot))

						tl = Vector2.new(c * (tl.x - mid.x) - s * (tl.y - mid.y), s * (tl.x - mid.x) + c * (tl.y - mid.y)) + mid
						tr = Vector2.new(c * (tr.x - mid.x) - s * (tr.y - mid.y), s * (tr.x - mid.x) + c * (tr.y - mid.y)) + mid
						bl = Vector2.new(c * (bl.x - mid.x) - s * (bl.y - mid.y), s * (bl.x - mid.x) + c * (bl.y - mid.y)) + mid
						br = Vector2.new(c * (br.x - mid.x) - s * (br.y - mid.y), s * (br.x - mid.x) + c * (br.y - mid.y)) + mid
					end
					
					DrawQuad(
						workspace.CurrentCamera:ScreenPointToRay(tl.x, tl.y, zIndex).Origin,
						workspace.CurrentCamera:ScreenPointToRay(tr.x, tr.y, zIndex).Origin,
						workspace.CurrentCamera:ScreenPointToRay(bl.x, bl.y, zIndex).Origin,
						workspace.CurrentCamera:ScreenPointToRay(br.x, br.y, zIndex).Origin,
						parts
					)
					if (fetchProps) then
						for _, pt in pairs(parts) do
							pt.Parent = f
						end
						for propName, propValue in pairs(properties) do
							for _, pt in pairs(parts) do
								pt[propName] = propValue
							end
						end
					end
				end

				UpdateOrientation(true)

				-- Use Heartbeat connection instead of BindToRenderStep for Luarmor compatibility
				local connection = RunService.Heartbeat:Connect(function()
					if (Library.Open) then
						UpdateOrientation()
					else
						connection:Disconnect()
					end
				end)
				
				-- Store connection for cleanup
				binds[uid].connection = connection
			else
				for uid, bind in pairs(binds) do
					-- Disconnect the Heartbeat connection instead of UnbindFromRenderStep
					if (bind.connection) then
						bind.connection:Disconnect()
					end

					for _, part in pairs(bind.parts) do
						part.Transparency = 1
					end

					if (root) then
						for _, folder in ipairs(root:GetChildren()) do
							if (folder:IsA("Folder")) then
								for _, part in ipairs(folder:GetChildren()) do
									if (part:IsA("BasePart")) then
										part.Transparency = 1
									end
								end
							end
						end
					end

					binds[uid] = nil
				end

				if (blurframe) then
					blurframe:Destroy()
					blurframe = nil
				end
			end
		end
	end

	--warn("Library")

	Library:SetOpen(true)

	local tabHolder = Instance.new("ScrollingFrame")	
	tabHolder.Name = "TabHolder"
	tabHolder.ScrollBarThickness = 0
	tabHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	tabHolder.BackgroundTransparency = 1
	tabHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
	tabHolder.BorderSizePixel = 0
	tabHolder.LayoutOrder = 3
	tabHolder.Position = UDim2.fromScale(0, 0.225)
	tabHolder.Selectable = false
	tabHolder.Size = Library.UDim2(1, 0, 1, -120)

	local uIListLayout3 = Instance.new("UIListLayout")	
	uIListLayout3.Name = "UIListLayout"
	uIListLayout3.Padding = UDim.new(0, 6)
	uIListLayout3.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout3.Parent = tabHolder

	local uIPadding = Instance.new("UIPadding")	
	uIPadding.Name = "UIPadding"
	uIPadding.PaddingLeft = UDim.new(0, 15)
	uIPadding.PaddingTop = UDim.new(0, 10)
	uIPadding.Parent = tabHolder
	tabHolder.Parent = anothersidebarholder

	local search = Instance.new("Frame")	
	search.Name = "Search"
	search.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	search.BackgroundTransparency = 1
	search.BorderColor3 = Color3.fromRGB(0, 0, 0)
	search.BorderSizePixel = 0
	search.LayoutOrder = 2
	search.Size = Library.UDim2(1, 0, 0, 40)

	local line = Instance.new("Frame")	
	line.Name = "line"
	line.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	line.BackgroundTransparency = 0.5
	line.BorderColor3 = Color3.fromRGB(0, 0, 0)
	line.BorderSizePixel = 0
	line.Size = Library.UDim2(1, 0, 0, 1)
	line.Parent = search

	local line1 = Instance.new("Frame")	
	line1.Name = "line"
	line1.AnchorPoint = Vector2.new(0, 1)
	line1.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	line1.BackgroundTransparency = 0.5
	line1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	line1.BorderSizePixel = 0
	line1.Position = UDim2.fromScale(0, 1)
	line1.Size = Library.UDim2(1, 0, 0, 1)
	line1.Parent = search

	local searchzone = Instance.new("Frame")	
	searchzone.Name = "searchzone"
	searchzone.AnchorPoint = Vector2.new(0.5, 0.5)
	searchzone.BackgroundColor3 = Color3.fromRGB(35, 35, 33)
	searchzone.BackgroundTransparency = 0.7
	searchzone.BorderColor3 = Color3.fromRGB(0, 0, 0)
	searchzone.BorderSizePixel = 0
	searchzone.Position = UDim2.fromScale(0.5, 0.5)
	searchzone.Size = Library.UDim2(1, -30, 0, 25)

	local uICorner4 = Instance.new("UICorner")	
	uICorner4.Name = "UICorner"
	uICorner4.CornerRadius = UDim.new(0, 4)
	uICorner4.Parent = searchzone

	local keyicon = Instance.new("ImageLabel")	
	keyicon.Name = "Keyicon"
	keyicon.Image = "rbxassetid://139032822388177"
	keyicon.ImageColor3 = Color3.fromRGB(80, 80, 75)
	keyicon.AnchorPoint = Vector2.new(0, 0.5)
	keyicon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	keyicon.BackgroundTransparency = 1
	keyicon.BorderColor3 = Color3.fromRGB(0, 0, 0)
	keyicon.BorderSizePixel = 0
	keyicon.Position = UDim2.new(1, -25, 0.5, 0)
	keyicon.Size = UDim2.fromOffset(14, 14)
	keyicon.Parent = searchzone

	local searchipnut = Instance.new("TextBox")	
	searchipnut.Name = "TextBox"
	searchipnut.FontFace = Font.new("rbxassetid://12187365364")	
	searchipnut.PlaceholderText = "Search..."
	searchipnut.Text = ""
	searchipnut.TextColor3 = Color3.fromRGB(255, 255, 255)
	searchipnut.TextSize = Library.GetScaledTextSize(12)
	searchipnut.TextXAlignment = Enum.TextXAlignment.Left
	searchipnut.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	searchipnut.BackgroundTransparency = 1
	searchipnut.BorderColor3 = Color3.fromRGB(0, 0, 0)
	searchipnut.BorderSizePixel = 0
	searchipnut.Position = UDim2.fromOffset(9, 0)
	searchipnut.Size = Library.UDim2(1, -42, 1, 0)
	searchipnut.Parent = searchzone

	local uIStroke2 = Instance.new("UIStroke")	
	uIStroke2.Name = "UIStroke"
	uIStroke2.Color = Color3.fromRGB(45, 45, 45)
	uIStroke2.Transparency = 0.6
	uIStroke2.Parent = searchzone

	searchzone.Parent = search
	search.Parent = anothersidebarholder

	anothersidebarholder.Parent = sidebarHolder
	searchipnut.Changed:Connect(function(property)
		if (property == "Text") then
			local searchText = searchipnut.Text:lower()

			if (searchText == "") then
				for _, tab in pairs(Window.Tabs) do
					tab.Elements.TabButton.Visible = true
				end
			else
				local visibleTabs = {}

				for _, tab in pairs(Window.Tabs) do
					local tabName = tab.Name:lower()
					local shouldShow = tabName:find(searchText, 1, true) ~= nil
					tab.Elements.TabButton.Visible = shouldShow

					if (shouldShow) then
						table.insert(visibleTabs, tab)
					end
				end

				if (#visibleTabs == 1) then
					for _, tab in pairs(Window.Tabs) do
						if (tab.Open) then
							tab:Turn(false)
						end
					end
					visibleTabs[1]:Turn(true)
				elseif (#visibleTabs > 1) then
					for _, tab in pairs(Window.Tabs) do
						if (tab.Open and not tab.Elements.TabButton.Visible) then
							tab:Turn(false)
						end
					end
				end
			end
		end
	end)

	searchipnut.FocusLost:Connect(function()
		if (searchipnut.Text == "") then
			for _, tab in pairs(Window.Tabs) do
				tab.Elements.TabButton.Visible = true
			end
		end
	end)

	local line2 = Instance.new("Frame")	
	line2.Name = "Line"
	line2.AnchorPoint = Vector2.new(1, 0)
	line2.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	line2.BackgroundTransparency = 0.5
	line2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	line2.BorderSizePixel = 0
	line2.Position = UDim2.fromScale(1, 0)
	line2.Size = Library.UDim2(0, 1, 1, 0)
	line2.Parent = sidebarHolder

	sidebarHolder.Parent = theholderdwbbg

	--warn("Window")

	local content = Instance.new("Frame")	
	content.Name = "content"
	content.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	content.BackgroundTransparency = 1
	content.BorderColor3 = Color3.fromRGB(0, 0, 0)
	content.BorderSizePixel = 0
	content.ClipsDescendants = true
	content.LayoutOrder = 1
	content.Size = Library.UDim2(1, -150, 1, 0)
	content.Parent = theholderdwbbg

	theholderdwbbg.Parent = mainframe

	function Window.UpdateTabs(self)
		for Index, Tab in pairs(Window.Tabs) do
			Tab:Turn(Tab.Open)
		end
	end

	function Library.Tab(self, Properties)
		if (not Properties) then
			Properties = {}
		end

		local Tab = {
			Name = Properties.Title or "Tab",
			Icon = Properties.Icon,
			Window = Window,
			Open = false,
			Sections = {},
			Tabs = {},
			Elements = {},
			Vertical = Properties.Vertical or false,
		}

		local atab = Instance.new("TextButton", tabHolder)
		atab.Name = "atab"
		atab.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")		
		atab.Text = ""
		atab.TextColor3 = Color3.fromRGB(0, 0, 0)
		atab.TextSize = Library.GetScaledTextSize(14)
		atab.AutoButtonColor = false
		atab.BackgroundColor3 = Color3.fromRGB(39, 39, 42)
		atab.BackgroundTransparency = 1
		atab.BorderColor3 = Color3.fromRGB(0, 0, 0)
		atab.BorderSizePixel = 0
		atab.Size = Library.UDim2(1, -20, 0, 29)

		local uICorner = Instance.new("UICorner")		
		uICorner.Name = "UICorner"
		uICorner.CornerRadius = UDim.new(0, 6)
		uICorner.Parent = atab

		local uIStroke = Instance.new("UIStroke")		
		uIStroke.Name = "UIStroke"
		uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uIStroke.Color = Color3.fromRGB(31, 31, 34)
		uIStroke.Enabled = false
		uIStroke.Parent = atab

		local uIListLayout = Instance.new("UIListLayout")		
		uIListLayout.Name = "UIListLayout"
		uIListLayout.Padding = UDim.new(0, 10)
		uIListLayout.FillDirection = Enum.FillDirection.Horizontal
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uIListLayout.Parent = atab

		local uIPadding = Instance.new("UIPadding")		
		uIPadding.Name = "UIPadding"
		uIPadding.PaddingLeft = UDim.new(0, 8)
		uIPadding.Parent = atab

		local tabbdcon
        if (Tab.Icon) then
            tabbdcon = Instance.new("ImageLabel", atab)
            tabbdcon.Name = "tabbdcon"
            tabbdcon.Image = Tab.Icon
            tabbdcon.ImageColor3 = Color3.fromRGB(115, 115, 115)
            tabbdcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            tabbdcon.BackgroundTransparency = 1
            tabbdcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
            tabbdcon.BorderSizePixel = 0
            tabbdcon.Size = UDim2.fromOffset(12, 12)
        end

        local tabnme = Instance.new("TextLabel")
        tabnme.Name = "TextLabel"
        tabnme.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        tabnme.Text = Tab.Name
        tabnme.TextColor3 = Color3.fromRGB(115, 115, 115)
        tabnme.TextSize = Library.GetScaledTextSize(12)
        tabnme.AutomaticSize = Enum.AutomaticSize.X
        tabnme.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tabnme.BackgroundTransparency = 1
        tabnme.BorderColor3 = Color3.fromRGB(0, 0, 0)
        tabnme.BorderSizePixel = 0
        tabnme.Size = UDim2.fromScale(0, 1)
        tabnme.Parent = atab

		local tabs4 = Instance.new("ScrollingFrame", content)
		tabs4.Name = "tabs_" .. Tab.Name
		tabs4.AutomaticCanvasSize = Enum.AutomaticSize.Y
		tabs4.ScrollBarThickness = 0
		tabs4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		tabs4.BackgroundTransparency = 1
		tabs4.BorderColor3 = Color3.fromRGB(0, 0, 0)
		tabs4.BorderSizePixel = 0
		tabs4.ClipsDescendants = false
		tabs4.Position = UDim2.fromOffset(10, 1)
		tabs4.Selectable = false
		tabs4.Size = Library.UDim2(1, -20, 1.02, -10)
		tabs4.Visible = false

		local uno = Instance.new("Frame")		
		uno.Name = "uno"
		uno.AutomaticSize = Enum.AutomaticSize.Y
		uno.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		uno.BackgroundTransparency = 1
		uno.BorderColor3 = Color3.fromRGB(0, 0, 0)
		uno.BorderSizePixel = 0
		uno.Size = UDim2.fromOffset(654, 390)
		uno.Parent = tabs4

		local dos = Instance.new("Frame")		
		dos.Name = "dos"
		dos.AutomaticSize = Enum.AutomaticSize.Y
		dos.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		dos.BackgroundTransparency = 1
		dos.BorderColor3 = Color3.fromRGB(0, 0, 0)
		dos.BorderSizePixel = 0
		dos.Size = UDim2.fromScale(1, 0)
		dos.Parent = uno

		local dosLayout = Instance.new("UIListLayout")		
		dosLayout.Name = "_"
		dosLayout.HorizontalFlex = Enum.UIFlexAlignment.Fill
		dosLayout.Padding = UDim.new(0, 13)
		dosLayout.FillDirection = Tab.Vertical and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
		dosLayout.SortOrder = Enum.SortOrder.LayoutOrder
		dosLayout.Parent = dos

		local left = Instance.new("Frame", dos)
		left.Name = "Left"
		left.AutomaticSize = Enum.AutomaticSize.Y
		left.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		left.BackgroundTransparency = 1
		left.BorderColor3 = Color3.fromRGB(0, 0, 0)
		left.BorderSizePixel = 0

		local leftLayout = Instance.new("UIListLayout")		
		leftLayout.Name = "_"
		leftLayout.HorizontalFlex = Enum.UIFlexAlignment.Fill
		leftLayout.Padding = UDim.new(0, 12)
		leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
		leftLayout.Parent = left

		local right = Instance.new("Frame", dos)
		right.Name = "Right"
		right.AutomaticSize = Enum.AutomaticSize.Y
		right.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		right.BackgroundTransparency = 1
		right.BorderColor3 = Color3.fromRGB(0, 0, 0)
		right.BorderSizePixel = 0
		right.LayoutOrder = 2

		local rightLayout = Instance.new("UIListLayout")		
		rightLayout.Name = "_"
		rightLayout.HorizontalFlex = Enum.UIFlexAlignment.Fill
		rightLayout.Padding = UDim.new(0, 12)
		rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
		rightLayout.Parent = right

		local tabsLayout = Instance.new("UIListLayout")		
		tabsLayout.Name = "_"
		tabsLayout.HorizontalFlex = Enum.UIFlexAlignment.Fill
		tabsLayout.Padding = UDim.new(0, 16)
		tabsLayout.FillDirection = Enum.FillDirection.Horizontal
		tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tabsLayout.Parent = tabs4

		local tabsPadding = Instance.new("UIPadding")		
		tabsPadding.Name = "UIPadding"
		tabsPadding.PaddingTop = UDim.new(0, 12)
		tabsPadding.Parent = tabs4

		function Tab.Turn(self, bool)
			Tab.Open = bool

			local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

			if (bool) then
				TweenService:Create(atab, tweenInfo, {
					BackgroundTransparency = 0.7,
				}):Play()

				uIStroke.Enabled = true

				if (tabbdcon) then
					TweenService:Create(tabbdcon, tweenInfo, {
						ImageColor3 = Color3.fromRGB(255, 255, 255),
					}):Play()
				end

				TweenService:Create(tabnme, tweenInfo, {
					TextColor3 = Color3.fromRGB(235, 235, 235),
				}):Play()

				tabs4.Visible = true
			else
				TweenService:Create(atab, tweenInfo, {
					BackgroundTransparency = 1,
				}):Play()

				uIStroke.Enabled = false

				if (tabbdcon) then
					TweenService:Create(tabbdcon, tweenInfo, {
						ImageColor3 = Color3.fromRGB(115, 115, 115),
					}):Play()
				end

				TweenService:Create(tabnme, tweenInfo, {
					TextColor3 = Color3.fromRGB(115, 115, 115),
				}):Play()

				tabs4.Visible = false
			end
		end

		atab.MouseButton1Click:Connect(function()
			if (not Tab.Open) then
				for _, otherTab in pairs(Window.Tabs) do
					if (otherTab.Open and otherTab ~= Tab) then
						otherTab:Turn(false)
					end
				end

				Tab:Turn(true)
			end
		end)

		atab.MouseEnter:Connect(function()
			if (Library.DropdownActive) then 
				return 
			end 
			if (not Tab.Open) then
				TweenService:Create(atab, TweenInfo.new(0.15), {
					BackgroundTransparency = 0.85,
				}):Play()
			end
		end)

		atab.MouseLeave:Connect(function()
			if (not Tab.Open) then
				TweenService:Create(atab, TweenInfo.new(0.15), {
					BackgroundTransparency = 1,
				}):Play()
			end
		end)

		Tab.Elements = {
			Left = left,
			Right = right,
			TabButton = atab,
			Content = tabs4,
		}

		if (#Window.Tabs == 0) then
			Tab:Turn(true)
		end

		Window.Tabs[#Window.Tabs + 1] = Tab
		return setmetatable(Tab, Library.Tabs)
	end

	--warn("Section")

	function Tabs.Section(self, Properties)
		if (not Properties) then
			Properties = {}
		end
		self.SectionCount = (self.SectionCount or 0) + 1

		local Section = {
			Name = Properties.Name or "Section",
			Tab = self,
			Side = (Properties.side or Properties.Side or "Left"),
			Zindex = Properties.Zindex or (1000 - self.SectionCount),
			Elements = {},
			HasSubsection = Properties.HasSubsection or Properties.Subsection or false,
			Content = {},
			ShowTitle = Properties.ShowTitle ~= false,
			IsMinimized = false,
		}

		local section = Instance.new("Frame", Section.Tab.Elements[Section.Side])
		section.Name = "section"
		section.AutomaticSize = Enum.AutomaticSize.Y
		section.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
		section.BackgroundTransparency = 0.4
		section.BorderColor3 = Color3.fromRGB(0, 0, 0)
		section.BorderSizePixel = 0
		section.ZIndex = Section.Zindex
		section.Position = UDim2.fromScale(-4.0200000000000005E-3, 0)
		section.Size = Library.UDim2(1, 0, 3.02, 12)

		local uICorner = Instance.new("UICorner")		
		uICorner.Name = "UICorner"
		uICorner.CornerRadius = UDim.new(0, 6)
		uICorner.Parent = section

		local uIStroke = Instance.new("UIStroke")		
		uIStroke.Name = "UIStroke"
		uIStroke.Color = Color3.fromRGB(45, 45, 45)
		uIStroke.Transparency = 0.4
		uIStroke.Parent = section

		local uIListLayout = Instance.new("UIListLayout")		
		uIListLayout.Name = "UIListLayout"
		uIListLayout.Padding = UDim.new(0, 8)
		uIListLayout.FillDirection = Enum.FillDirection.Vertical
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.Parent = section

		local uIPadding = Instance.new("UIPadding")		
		uIPadding.Name = "UIPadding"
		uIPadding.PaddingBottom = UDim.new(0, 12)
		uIPadding.PaddingTop = UDim.new(0, 5)
		uIPadding.Parent = section

		-- Minimize button
		local minimizeButton = Instance.new("TextButton")
		minimizeButton.Name = "MinimizeButton"
		minimizeButton.Text = ""
		minimizeButton.AutoButtonColor = false
		minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		minimizeButton.BackgroundTransparency = 1
		minimizeButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
		minimizeButton.BorderSizePixel = 0
		minimizeButton.Position = UDim2.fromOffset(6, 6)
		minimizeButton.Size = UDim2.fromOffset(20, 20)
		minimizeButton.ZIndex = Section.Zindex + 10
		minimizeButton.Parent = section

		local minimizeIcon = Instance.new("ImageLabel")
		minimizeIcon.Name = "MinimizeIcon"
        -- mobile icon for minim
        -- http://www.roblox.com/asset/?id=5273114855 // 115894980866040
		minimizeIcon.Image = "http://www.roblox.com/asset/?id=115894980866040"
		minimizeIcon.ImageColor3 = Color3.fromRGB(115, 115, 115)
		minimizeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		minimizeIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		minimizeIcon.BackgroundTransparency = 1
		minimizeIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
		minimizeIcon.BorderSizePixel = 0
		minimizeIcon.Position = UDim2.fromScale(0.5, 0.5)
		minimizeIcon.Size = UDim2.fromOffset(16, 16)
		minimizeIcon.ZIndex = Section.Zindex + 11
		minimizeIcon.Parent = minimizeButton

		-- Store references
		Section.Elements.MinimizeButton = minimizeButton
		Section.Elements.MinimizeIcon = minimizeIcon

		local aholder = Instance.new("Frame", section)
		aholder.Name = "aholder"
		aholder.AutomaticSize = Enum.AutomaticSize.Y
		aholder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		aholder.BackgroundTransparency = 1
		aholder.BorderColor3 = Color3.fromRGB(0, 0, 0)
		aholder.BorderSizePixel = 0
		aholder.LayoutOrder = 1
		aholder.Size = UDim2.fromScale(1, 0)

		if (not Section.HasSubsection) then
			aholder.Visible = true
		else
			aholder.Visible = false
		end

		local uIListLayoutA = Instance.new("UIListLayout")		
		uIListLayoutA.Name = "UIListLayout"
		uIListLayoutA.Padding = UDim.new(0, 8)
		uIListLayoutA.HorizontalFlex = Enum.UIFlexAlignment.Fill
		uIListLayoutA.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayoutA.Parent = aholder

		local uIPadding = Instance.new("UIPadding", aholder)
		uIPadding.Name = "UIPadding"
		uIPadding.PaddingBottom = UDim.new(0, 3)
		uIPadding.PaddingLeft = UDim.new(0, 3)
		uIPadding.PaddingRight = UDim.new(0, 3)
		uIPadding.PaddingTop = UDim.new(0, 3)

		Section.Elements.SectionContent = aholder

		if (not Section.HasSubsection and Section.ShowTitle) then
			local sectiontitle = Instance.new("Frame", aholder)
			sectiontitle.Name = "sectiontitle"
			sectiontitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			sectiontitle.BackgroundTransparency = 1
			sectiontitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
			sectiontitle.BorderSizePixel = 0
			sectiontitle.Size = UDim2.fromOffset(0, 22)

			local title = Instance.new("TextLabel")			
			title.Name = "title"
			title.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
			title.Text = Section.Name
			title.TextColor3 = Color3.fromRGB(221, 221, 221)
			title.TextSize = Library.GetScaledTextSize(14)
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			title.BackgroundTransparency = 1
			title.BorderColor3 = Color3.fromRGB(0, 0, 0)
			title.BorderSizePixel = 0
			title.Position = UDim2.fromOffset(8, 0)
			title.Size = UDim2.fromOffset(0, 25)
			title.Parent = sectiontitle
		end

		-- Minimize functionality
		function Section.ToggleMinimize(self)
			-- Add null check for minimize icon
			if not self.Elements.MinimizeIcon or not self.Elements.MinimizeIcon.Parent then
				return
			end
			
			self.IsMinimized = not self.IsMinimized
			
			local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			
			-- Rotate the minimize icon
			TweenService:Create(self.Elements.MinimizeIcon, tweenInfo, {
				Rotation = self.IsMinimized and 180 or 0
			}):Play()
			
			-- Check if section actually has subsections
			local hasSubsections = self._Subsections and #self._Subsections > 0
			
					-- Toggle visibility of all content
		if self.IsMinimized then
			-- Minimize: hide content but keep small space
			if hasSubsections then
				-- For sections with subsections, hide all subsection content holders
				for _, subsection in ipairs(self._Subsections) do
					if subsection.Holder then
						subsection.Holder.Visible = false
					end
					
					-- Hide subsection button elements
					if subsection.Buttone then
						subsection.Buttone.Visible = false
					end
					
					-- Hide subsection name label
					if subsection.NameLabel then
						subsection.NameLabel.Visible = false
					end
					
					-- Hide subsection inner frame
					if subsection.Inner then
						subsection.Inner.Visible = false
					end
				end
				
				-- Hide the subsection container (but keep it in the tree)
				local subSection = section:FindFirstChild("Sub-section")
				if subSection then
					subSection.Visible = false
				end
			else
				-- For regular sections, just hide the content
				if self.Elements.SectionContent then
					self.Elements.SectionContent.Visible = false
				end
			end
			
			-- Disable automatic sizing and set section to minimal height
			section.AutomaticSize = Enum.AutomaticSize.None
			section.Size = UDim2.new(1, 0, 0, 32) -- Small height for minimize button
		else
			-- Restore: show content and restore size
			if hasSubsections then
				-- Show the subsection container first
				local subSection = section:FindFirstChild("Sub-section")
				if subSection then
					subSection.Visible = true
				end
				
				-- Restore subsection visibility based on active state
				for _, subsection in ipairs(self._Subsections) do
					if subsection.Holder then
						subsection.Holder.Visible = subsection.IsActive
					end
					
					-- Restore subsection button elements
					if subsection.Buttone then
						subsection.Buttone.Visible = true
					end
					
					-- Restore subsection name label
					if subsection.NameLabel then
						subsection.NameLabel.Visible = true
					end
					
					-- Restore subsection inner frame
					if subsection.Inner then
						subsection.Inner.Visible = true
					end
				end
			else
				-- For regular sections, show the content
				if self.Elements.SectionContent then
					self.Elements.SectionContent.Visible = true
				end
			end
			
			-- Re-enable automatic sizing and restore original size
			section.AutomaticSize = Enum.AutomaticSize.Y
			TweenService:Create(section, tweenInfo, {
				Size = UDim2.new(1, 0, 3.02, 12) -- Original size
			}):Play()
		end
		end

		-- Connect minimize button click
		minimizeButton.MouseButton1Click:Connect(function()
			Section:ToggleMinimize()
		end)


		-- Hover effects for minimize button
		minimizeButton.MouseEnter:Connect(function()
			if Section.Elements.MinimizeIcon then
				local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				TweenService:Create(Section.Elements.MinimizeIcon, hoverTween, {
					ImageColor3 = Color3.fromRGB(221, 221, 221)
				}):Play()
			end
		end)

		minimizeButton.MouseLeave:Connect(function()
			if Section.Elements.MinimizeIcon then
				local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				TweenService:Create(Section.Elements.MinimizeIcon, hoverTween, {
					ImageColor3 = Color3.fromRGB(115, 115, 115)
				}):Play()
			end
		end)

		function Section.Disable(self, disabled)
			if disabled == nil then disabled = true end
			
			-- Store the disabled state
			self.Disabled = disabled
			
			-- Section remains visible, just darkened
			if disabled then
				-- Darken the section background
				local disabledTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				TweenService:Create(section, disabledTween, {
					BackgroundTransparency = 0.7,
				}):Play()
			else
				-- Restore normal appearance
				local enabledTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				TweenService:Create(section, enabledTween, {
					BackgroundTransparency = 0.4,
				}):Play()
			end
			
			-- If section has subsections, disable all subsection buttons
			if self._Subsections then
				for _, subsection in ipairs(self._Subsections) do
					if subsection.Buttone then
						subsection.Buttone.Active = not disabled
						-- Visual indication when disabled
						if disabled then
							local disabledTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
							TweenService:Create(subsection.NameLabel, disabledTween, {
								TextColor3 = Color3.fromRGB(60, 60, 60),
							}):Play()
						else
							-- Restore original color based on active state
							local enabledTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
							local targetColor = subsection.IsActive and Color3.fromRGB(221, 221, 221) or Color3.fromRGB(115, 115, 115)
							TweenService:Create(subsection.NameLabel, enabledTween, {
								TextColor3 = targetColor,
							}):Play()
						end
					end
					-- Store disabled state for subsections too
					subsection.Disabled = disabled
				end
			end
			
			-- Disable all elements within the section (make them non-interactive and darkened)
			for _, element in pairs(Library.Elements) do
				if element.Section == self then
					-- Store the original disabled state if not already stored
					if element.OriginalDisabled == nil then
						element.OriginalDisabled = element.Disabled or false
					end
					
					-- Set the disabled state
					element.Disabled = disabled
					
					-- Apply visual darkening effect to element
					if element.Elements then
						for _, guiElement in pairs(element.Elements) do
							if guiElement and guiElement:IsA("GuiObject") then
								if disabled then
									-- Darken and make non-interactive
									if guiElement:IsA("TextButton") or guiElement:IsA("ImageButton") then
										guiElement.Active = false
									end
									local disabledTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
									TweenService:Create(guiElement, disabledTween, {
										BackgroundTransparency = math.min(guiElement.BackgroundTransparency + 0.4, 1),
									}):Play()
									-- Darken text elements
									for _, child in pairs(guiElement:GetDescendants()) do
										if child:IsA("TextLabel") or child:IsA("TextButton") then
											TweenService:Create(child, disabledTween, {
												TextColor3 = Color3.fromRGB(60, 60, 60),
											}):Play()
										end
									end
								else
									-- Restore normal appearance and functionality
									if guiElement:IsA("TextButton") or guiElement:IsA("ImageButton") then
										guiElement.Active = true
									end
									local enabledTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
									TweenService:Create(guiElement, enabledTween, {
										BackgroundTransparency = math.max(guiElement.BackgroundTransparency - 0.4, 0),
									}):Play()
									-- Restore text colors (you may need to adjust these colors based on your theme)
									for _, child in pairs(guiElement:GetDescendants()) do
										if child:IsA("TextLabel") or child:IsA("TextButton") then
											TweenService:Create(child, enabledTween, {
												TextColor3 = Color3.fromRGB(221, 221, 221),
											}):Play()
										end
									end
								end
							end
						end
					end
				end
			end
		end

		Section.Tab.Sections[#Section.Tab.Sections + 1] = Section
		return setmetatable(Section, Library.Sections)
	end

	--warn("Subsection")
	function Sections.Subsection(self, Properties)
		Properties = Properties or {}
		self._Subsections = self._Subsections or {}
		local sectionRoot = self.Elements.SectionContent.Parent

		local subSection = sectionRoot:FindFirstChild("Sub-section")

		if (not subSection) then
			subSection = Instance.new("Frame")
			subSection.Name = "Sub-section"
			subSection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			subSection.BackgroundTransparency = 1
			subSection.BorderColor3 = Color3.fromRGB(0, 0, 0)
			subSection.BorderSizePixel = 0
			subSection.Size = Library.UDim2(1, 0, 0, 35)
			subSection.Parent = sectionRoot
		end

		local thesubsectonholder = subSection:FindFirstChild("thesubsectonholder")
		if (not thesubsectonholder) then
			thesubsectonholder = Instance.new("Frame")
			thesubsectonholder.Name = "thesubsectonholder"
			thesubsectonholder.AnchorPoint = Vector2.new(0.5, 0)
			thesubsectonholder.BackgroundColor3 = Color3.fromRGB(39, 39, 42)
			thesubsectonholder.BackgroundTransparency = 1
			thesubsectonholder.BorderColor3 = Color3.fromRGB(0, 0, 0)
			thesubsectonholder.BorderSizePixel = 0
			thesubsectonholder.Position = UDim2.fromScale(0.5, 0)
			thesubsectonholder.Size = Library.UDim2(1, -14, 1, 0)
			thesubsectonholder.Parent = subSection

			local uICorner = Instance.new("UICorner")
			uICorner.Name = "UICorner"
			uICorner.Parent = thesubsectonholder

			local uIStroke = Instance.new("UIStroke")
			uIStroke.Name = "UIStroke"
			uIStroke.Color = Color3.fromRGB(45, 45, 45)
			uIStroke.Transparency = 0.6
			uIStroke.Parent = thesubsectonholder

			local uIListLayout = Instance.new("UIListLayout")
			uIListLayout.Name = "UIListLayout"
			uIListLayout.Padding = UDim.new(0, 2)
			uIListLayout.FillDirection = Enum.FillDirection.Horizontal
			uIListLayout.HorizontalFlex = Enum.UIFlexAlignment.Fill
			uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
			uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			uIListLayout.Parent = thesubsectonholder

			local uIPadding = Instance.new("UIPadding")
			uIPadding.Name = "UIPadding"
			uIPadding.PaddingBottom = UDim.new(0, 3)
			uIPadding.PaddingLeft = UDim.new(0, 3)
			uIPadding.PaddingRight = UDim.new(0, 3)
			uIPadding.PaddingTop = UDim.new(0, 3)
			uIPadding.Parent = thesubsectonholder
		end

		local subsectionbutton = Instance.new("TextButton")
		subsectionbutton.Name = "subsectionbutton"
		subsectionbutton.Text = ""
		subsectionbutton.AutoButtonColor = false
		subsectionbutton.Active = true
		subsectionbutton.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
		subsectionbutton.BackgroundTransparency = 1
		subsectionbutton.BorderColor3 = Color3.fromRGB(0, 0, 0)
		subsectionbutton.BorderSizePixel = 0
		subsectionbutton.Selectable = false
		subsectionbutton.Size = UDim2.fromOffset(100, 28)

		local uICorner2 = Instance.new("UICorner")
		uICorner2.Name = "UICorner"
		uICorner2.CornerRadius = UDim.new(0, 6)
		uICorner2.Parent = subsectionbutton

		local inner = Instance.new("Frame")
		inner.Name = "inner"
		inner.AnchorPoint = Vector2.new(0.5, 0.5)
		inner.BackgroundColor3 = Color3.fromRGB(9, 9, 11)
		inner.BorderColor3 = Color3.fromRGB(0, 0, 0)
		inner.BorderSizePixel = 0
		inner.BackgroundTransparency = 1
		inner.Position = UDim2.fromScale(0.5, 0.5)
		inner.Size = Library.UDim2(1, -2, 1, -2)
		inner.Parent = subsectionbutton

		local uICorner1 = Instance.new("UICorner")
		uICorner1.Name = "UICorner"
		uICorner1.CornerRadius = UDim.new(0, 6)
		uICorner1.Parent = inner

		local subsectionname = Instance.new("TextLabel")
		subsectionname.Name = "subsectionname"
		subsectionname.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
		subsectionname.Text = Properties.Name or "Group"
		subsectionname.TextColor3 = Color3.fromRGB(115, 115, 115)
		subsectionname.TextSize = Library.GetScaledTextSize(14)
		subsectionname.AutomaticSize = Enum.AutomaticSize.X
		subsectionname.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		subsectionname.BackgroundTransparency = 1
		subsectionname.BorderColor3 = Color3.fromRGB(0, 0, 0)
		subsectionname.BorderSizePixel = 0
		subsectionname.LayoutOrder = 3
		subsectionname.Size = Library.UDim2(1, -14, 1, 0)
		subsectionname.Parent = inner



		subsectionbutton.Parent = thesubsectonholder

		local aholder = Instance.new("Frame", sectionRoot)
		aholder.Name = "aholder"
		aholder.AutomaticSize = Enum.AutomaticSize.Y
		aholder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		aholder.BackgroundTransparency = 1
		aholder.BorderColor3 = Color3.fromRGB(0, 0, 0)
		aholder.BorderSizePixel = 0
		aholder.LayoutOrder = 10
		aholder.Size = UDim2.fromScale(1, 0)
		aholder.Visible = false

		local uIListLayoutA = Instance.new("UIListLayout")
		uIListLayoutA.Name = "UIListLayout"
		uIListLayoutA.Padding = UDim.new(0, 4)
		uIListLayoutA.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayoutA.Parent = aholder

		local subsectionObj = {
			Elements = { SectionContent = aholder },
			Holder = aholder,
			ParentSection = self,
			Name = Properties.Name or "Group",
			Inner = inner,
			NameLabel = subsectionname,
			IsActive = false,
		}
		table.insert(self._Subsections, subsectionObj)

		subsectionbutton.MouseEnter:Connect(function()
			if (not subsectionObj.IsActive) then
				local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				TweenService:Create(subsectionname, hoverTween, {
					TextColor3 = Color3.fromRGB(221, 221, 221),
				}):Play()
			end
		end)

		subsectionbutton.MouseLeave:Connect(function()
			if (not subsectionObj.IsActive) then
				local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				TweenService:Create(subsectionname, hoverTween, {
					TextColor3 = Color3.fromRGB(115, 115, 115),
				}):Play()
			end
		end)

		subsectionbutton.MouseButton1Click:Connect(function()
			-- Check if the section is disabled
			if self.Disabled then
				return
			end
			for _, sub in ipairs(self._Subsections) do
				local isActive = (sub == subsectionObj)
				sub.Holder.Visible = isActive
				sub.Buttone.Active = not isActive
				sub.IsActive = isActive
				local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

				if (isActive) then
					TweenService:Create(sub.Buttone, tweenInfo, {
						BackgroundTransparency = 0,
					}):Play()
					TweenService:Create(sub.Inner, tweenInfo, {
						BackgroundTransparency = 0,
					}):Play()
					TweenService:Create(sub.NameLabel, tweenInfo, {
						TextColor3 = Color3.fromRGB(221, 221, 221),
					}):Play()

					sub.Buttone.BackgroundColor3 = Color3.fromRGB(35, 35, 33)
					sub.Inner.BackgroundColor3 = Color3.fromRGB(35, 35, 33)
				else
					TweenService:Create(sub.Buttone, tweenInfo, {
						BackgroundTransparency = 1,
					}):Play()
					TweenService:Create(sub.Inner, tweenInfo, {
						BackgroundTransparency = 1,
					}):Play()
					TweenService:Create(sub.NameLabel, tweenInfo, {
						TextColor3 = Color3.fromRGB(115, 115, 115),
					}):Play()

					sub.Buttone.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
					sub.Inner.BackgroundColor3 = Color3.fromRGB(9, 9, 11)
				end
			end

			-- Preserve minimize button references while updating content
			self.Elements.SectionContent = subsectionObj.Elements.SectionContent
		end)



		subsectionObj.Buttone = subsectionbutton

		if (#self._Subsections == 1) then
			aholder.Visible = true
			subsectionbutton.BackgroundTransparency = 0
			subsectionbutton.BackgroundColor3 = Color3.fromRGB(35, 35, 33)
			inner.BackgroundTransparency = 0
			inner.BackgroundColor3 = Color3.fromRGB(35, 35, 33)
			subsectionname.TextColor3 = Color3.fromRGB(221, 221, 221)
			subsectionbutton.Active = false
			subsectionObj.IsActive = true

			-- Preserve minimize button references while updating content
			self.Elements.SectionContent = subsectionObj.Elements.SectionContent
		end

		function subsectionObj.Disable(self, disabled)
			if disabled == nil then disabled = true end
			
			-- Store the disabled state
			self.Disabled = disabled
			
			-- Disable/enable the subsection button but keep it visible
			if self.Buttone then
				self.Buttone.Active = not disabled
				-- Visual indication when disabled
				if disabled then
					local disabledTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					TweenService:Create(self.NameLabel, disabledTween, {
						TextColor3 = Color3.fromRGB(60, 60, 60),
					}):Play()
					-- Darken the button itself
					TweenService:Create(self.Buttone, disabledTween, {
						BackgroundTransparency = 0.7,
					}):Play()
					TweenService:Create(self.Inner, disabledTween, {
						BackgroundTransparency = 0.7,
					}):Play()
				else
					-- Restore original color based on active state
					local enabledTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					local targetColor = self.IsActive and Color3.fromRGB(221, 221, 221) or Color3.fromRGB(115, 115, 115)
					TweenService:Create(self.NameLabel, enabledTween, {
						TextColor3 = targetColor,
					}):Play()
					-- Restore button transparency based on active state
					local targetTransparency = self.IsActive and 0 or 1
					TweenService:Create(self.Buttone, enabledTween, {
						BackgroundTransparency = targetTransparency,
					}):Play()
					TweenService:Create(self.Inner, enabledTween, {
						BackgroundTransparency = targetTransparency,
					}):Play()
				end
			end
			
			-- Keep subsection content visible but darken it
			if self.Holder then
				if disabled then
					-- Darken the content area
					local disabledTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					for _, child in pairs(self.Holder:GetChildren()) do
						if child:IsA("GuiObject") then
							TweenService:Create(child, disabledTween, {
								BackgroundTransparency = math.min(child.BackgroundTransparency + 0.4, 1),
							}):Play()
						end
					end
				else
					-- Restore normal appearance
					local enabledTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					for _, child in pairs(self.Holder:GetChildren()) do
						if child:IsA("GuiObject") then
							TweenService:Create(child, enabledTween, {
								BackgroundTransparency = math.max(child.BackgroundTransparency - 0.4, 0),
							}):Play()
						end
					end
				end
			end
			
			-- Disable all elements within the subsection by checking their GUI parent
			for _, element in pairs(Library.Elements) do
				if element.Elements then
					-- Check each element's GUI components to see if they belong to this subsection
					local belongsToSubsection = false
					for _, guiElement in pairs(element.Elements) do
						if guiElement and guiElement.Parent == self.Elements.SectionContent then
							belongsToSubsection = true
							break
						end
					end
					
					if belongsToSubsection then
						-- Store the original disabled state if not already stored
						if element.OriginalDisabled == nil then
							element.OriginalDisabled = element.Disabled or false
						end
						
						-- Set the disabled state
						element.Disabled = disabled
						
						-- Apply visual darkening effect to element
						for _, guiElement in pairs(element.Elements) do
							if guiElement and guiElement:IsA("GuiObject") then
								if disabled then
									-- Darken and make non-interactive
									if guiElement:IsA("TextButton") or guiElement:IsA("ImageButton") then
										guiElement.Active = false
									end
									local disabledTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
									TweenService:Create(guiElement, disabledTween, {
										BackgroundTransparency = math.min(guiElement.BackgroundTransparency + 0.4, 1),
									}):Play()
									-- Darken text elements
									for _, child in pairs(guiElement:GetDescendants()) do
										if child:IsA("TextLabel") or child:IsA("TextButton") then
											TweenService:Create(child, disabledTween, {
												TextColor3 = Color3.fromRGB(60, 60, 60),
											}):Play()
										end
									end
								else
									-- Restore normal appearance and functionality
									if guiElement:IsA("TextButton") or guiElement:IsA("ImageButton") then
										guiElement.Active = true
									end
									local enabledTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
									TweenService:Create(guiElement, enabledTween, {
										BackgroundTransparency = math.max(guiElement.BackgroundTransparency - 0.4, 0),
									}):Play()
									-- Restore text colors
									for _, child in pairs(guiElement:GetDescendants()) do
										if child:IsA("TextLabel") or child:IsA("TextButton") then
											TweenService:Create(child, enabledTween, {
												TextColor3 = Color3.fromRGB(221, 221, 221),
											}):Play()
										end
									end
								end
							end
						end
					end
				end
			end
		end

		return setmetatable(subsectionObj, getmetatable(self))
	end

	function Sections.Toggle(self, Properties)
		if (not Properties) then
			Properties = {}
		end

		local Toggle = {
			Window = self.Window,
			Section = self,
			Name = Properties.Name or "Toggle",
			State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or false),
			Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
			Flag = (Properties.flag or Properties.Flag or Properties.pointer or Properties.Pointer or Library.NextFlag()),
			Value = false,
			HasKeybind = false,
			Depends = Properties.Depends,
		}
		Toggle.Value = Toggle.State

		local toggleElement = Instance.new("TextButton", Toggle.Section.Elements.SectionContent)
		Toggle.Elements = { ToggleElement = toggleElement }
		toggleElement.Name = "ToggleElement"
		toggleElement.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")		
		toggleElement.Text = ""
		toggleElement.TextColor3 = Color3.fromRGB(0, 0, 0)
		toggleElement.TextSize = Library.GetScaledTextSize(14)
		toggleElement.AutoButtonColor = false
		toggleElement.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		toggleElement.BackgroundTransparency = 1
		toggleElement.BorderColor3 = Color3.fromRGB(0, 0, 0)
		toggleElement.BorderSizePixel = 0
		toggleElement.Size = Library.UDim2(1, 0, 0, 25)

		local box = Instance.new("Frame")		
		box.Name = "Box"
		box.AnchorPoint = Vector2.new(1, 0.5)
		box.BackgroundColor3 = Color3.fromRGB(35, 35, 33)
		box.BackgroundTransparency = 1
		box.BorderColor3 = Color3.fromRGB(0, 0, 0)
		box.BorderSizePixel = 0
		box.Position = UDim2.new(1, -7, 0.5, 0)
		box.Size = UDim2.fromOffset(22, 21)
		box.Parent = toggleElement

		local uICorner = Instance.new("UICorner")		
		uICorner.Name = "UICorner"
		uICorner.CornerRadius = UDim.new(0, 4)
		uICorner.Parent = box

		local uIStroke = Instance.new("UIStroke")		
		uIStroke.Name = "UIStroke"
		uIStroke.Color = Color3.fromRGB(45, 45, 45)
		uIStroke.Transparency = 0.6
		uIStroke.Parent = box

		local icon = Instance.new("ImageLabel")		
		icon.Name = "Icon"
		icon.Image = "http://www.roblox.com/asset/?id=5273114855"
		icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		icon.ScaleType = Enum.ScaleType.Slice
		icon.SliceScale = 4
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		icon.BackgroundTransparency = 1
		icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
		icon.BorderSizePixel = 0
		icon.Position = UDim2.fromScale(0.5, 0.5)
		icon.Size = UDim2.fromOffset(14, 14)
		icon.Visible = false
		icon.Parent = box

		local iconScale = Instance.new("UIScale")		
		iconScale.Name = "IconScale"
		iconScale.Scale = 0
		iconScale.Parent = icon

		local toggleName = Instance.new("TextLabel")		
		toggleName.Name = "ToggleName"
		toggleName.FontFace = Font.new("rbxassetid://12187365364")		
		toggleName.Text = Toggle.Name
		toggleName.TextColor3 = Color3.fromRGB(115, 115, 115)
		toggleName.TextSize = Library.GetScaledTextSize(12)
		toggleName.TextWrapped = true
		toggleName.TextXAlignment = Enum.TextXAlignment.Left
		toggleName.AnchorPoint = Vector2.new(0, 0.5)
		toggleName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		toggleName.BackgroundTransparency = 1
		toggleName.BorderColor3 = Color3.fromRGB(0, 0, 0)
		toggleName.BorderSizePixel = 0
		toggleName.Position = UDim2.new(0, 8, 0.5, 0)
		toggleName.Size = Library.UDim2(1, -52, 1, 0)
		toggleName.Parent = toggleElement

		function Toggle.Set(self, newState)
			self.State = newState
			self.Value = newState

			local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local quickTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

			if (self.State) then
				TweenService:Create(box, tweenInfo, {
					BackgroundColor3 = Color3.fromRGB(35, 35, 33),
					BackgroundTransparency = 0,
				}):Play()

				TweenService:Create(uIStroke, tweenInfo, {
					Color = Color3.fromRGB(38, 38, 36),
					Transparency = 0,
				}):Play()

				TweenService:Create(toggleName, tweenInfo, {
					TextColor3 = Color3.fromRGB(221, 221, 221),
				}):Play()

				icon.Visible = true
				TweenService:Create(iconScale, quickTweenInfo, {
					Scale = 1,
				}):Play()
			else
				TweenService:Create(box, tweenInfo, {
					BackgroundColor3 = Color3.fromRGB(35, 35, 33),
					BackgroundTransparency = 1,
				}):Play()

				TweenService:Create(uIStroke, tweenInfo, {
					Color = Color3.fromRGB(45, 45, 45),
					Transparency = 0.6,
				}):Play()

				TweenService:Create(toggleName, tweenInfo, {
					TextColor3 = Color3.fromRGB(115, 115, 115),
				}):Play()

				TweenService:Create(iconScale, quickTweenInfo, {
					Scale = 0,
				}):Play()

				task.delay(0.2, function()
					if (not self.State) then
						icon.Visible = false
					end
				end)
			end

			Library.Flags[self.Flag] = self.State
			Library.SetFlag(self.Flag, self.State)
		end

		function Toggle.SetVisible(self, visible)
			toggleElement.Visible = visible
		end

		toggleElement.MouseButton1Click:Connect(function()
			-- Check if the section or element is disabled
			if Toggle.Section.Disabled or Toggle.Disabled then
				return
			end
			Toggle:Set(not Toggle.State)
		end)

		function Toggle.Keybind(self, KeybindProperties)
			if (Toggle.HasKeybind) then
				return
			end

			Toggle.HasKeybind = true
			KeybindProperties = KeybindProperties or {}

			local Keybind = {
				Key = KeybindProperties.Key or KeybindProperties.Default or Enum.KeyCode.E,
				Mode = KeybindProperties.Mode or "Toggle",
				Flag = KeybindProperties.Flag or (Toggle.Flag .. "_KB"),
				Callback = KeybindProperties.Callback,
				Binding = false,
				State = false,
			}
			toggleName.Size = Library.UDim2(1, -85, 1, 0)

			local keybindcurrentframe = Instance.new("TextButton")			
			keybindcurrentframe.Name = "Keybindcurrentframe"
			keybindcurrentframe.Text = ""
			keybindcurrentframe.AutoButtonColor = false
			keybindcurrentframe.AnchorPoint = Vector2.new(1, 0.5)
			keybindcurrentframe.AutomaticSize = Enum.AutomaticSize.X
			keybindcurrentframe.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			keybindcurrentframe.BackgroundTransparency = 1
			keybindcurrentframe.BorderColor3 = Color3.fromRGB(0, 0, 0)
			keybindcurrentframe.BorderSizePixel = 0
			keybindcurrentframe.Position = UDim2.new(1, -35, 0.5, 0)
			keybindcurrentframe.Size = UDim2.fromOffset(0, 21)
			keybindcurrentframe.Parent = toggleElement

			local uICorner = Instance.new("UICorner")			
			uICorner.Name = "UICorner"
			uICorner.CornerRadius = UDim.new(0, 4)
			uICorner.Parent = keybindcurrentframe

			local uIStroke = Instance.new("UIStroke")			
			uIStroke.Name = "UIStroke"
			uIStroke.Color = Color3.fromRGB(45, 45, 45)
			uIStroke.Transparency = 0.6
			uIStroke.Parent = keybindcurrentframe

			local frame = Instance.new("Frame")			
			frame.Name = "Frame"
			frame.AutomaticSize = Enum.AutomaticSize.X
			frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			frame.BackgroundTransparency = 1
			frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
			frame.BorderSizePixel = 0
			frame.Size = UDim2.fromScale(0, 1)
			frame.Parent = keybindcurrentframe

			local uIListLayout = Instance.new("UIListLayout")			
			uIListLayout.Name = "UIListLayout"
			uIListLayout.Padding =UDim.new(0, 3)
			uIListLayout.FillDirection = Enum.FillDirection.Horizontal
			uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			uIListLayout.Parent = frame

			local uIPadding = Instance.new("UIPadding")			
			uIPadding.Name = "UIPadding"
			uIPadding.PaddingLeft = UDim.new(0, 5)
			uIPadding.PaddingRight = UDim.new(0, 5)
			uIPadding.PaddingTop = UDim.new(0, 1)
			uIPadding.Parent = frame

			local left = Instance.new("Frame")			
			left.Name = "Left"
			left.AutomaticSize = Enum.AutomaticSize.X
			left.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			left.BackgroundTransparency = 1
			left.BorderColor3 = Color3.fromRGB(0, 0, 0)
			left.BorderSizePixel = 0
			left.LayoutOrder = 1
			left.Size = UDim2.fromScale(0, 1)
			left.Parent = frame

			local keybindtexrt = Instance.new("TextLabel")			
			keybindtexrt.Name = "keybindtexrt"
			keybindtexrt.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
			keybindtexrt.Text = Library.Keys[Keybind.Key] or Keybind.Key.Name or "..."
			keybindtexrt.TextColor3 = Color3.fromRGB(115, 115, 115)
			keybindtexrt.TextSize = Library.GetScaledTextSize(12)
			keybindtexrt.TextWrapped = true
			keybindtexrt.Active = true
			keybindtexrt.AutomaticSize = Enum.AutomaticSize.X
			keybindtexrt.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			keybindtexrt.BackgroundTransparency = 1
			keybindtexrt.BorderColor3 = Color3.fromRGB(0, 0, 0)
			keybindtexrt.Selectable = true
			keybindtexrt.Size = UDim2.fromScale(1, 1)
			keybindtexrt.Parent = left

			local holdConnection

			local function SetKeybind(newKey)
				if (newKey == Enum.KeyCode.Backspace) then
					Keybind.Key = nil
					keybindtexrt.Text = "..."
				else
					Keybind.Key = newKey
					keybindtexrt.Text = Library.Keys[newKey] or (newKey and newKey.Name) or "..."
				end
				Library.Flags[Keybind.Flag] = Keybind.Key
			end

			local function StartBinding()
				if (Keybind.Binding) then
					return
				end

				Keybind.Binding = true
				keybindtexrt.Text = "..."

				local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				TweenService:Create(keybindtexrt, tweenInfo, {
					TextColor3 = Color3.fromRGB(255, 255, 255),
				}):Play()
				TweenService:Create(uIStroke, tweenInfo, {
					Color = Color3.fromRGB(38, 38, 36),
					Transparency = 0,
				}):Play()

				local connection
				connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
					if (gameProcessed) then
						return
					end

					local inputKey = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType
					SetKeybind(inputKey)

					TweenService:Create(keybindtexrt, tweenInfo, {
						TextColor3 = Color3.fromRGB(115, 115, 115),
					}):Play()
					TweenService:Create(uIStroke, tweenInfo, {
						Color = Color3.fromRGB(45, 45, 45),
						Transparency = 0.6,
					}):Play()

					connection:Disconnect()
					Keybind.Binding = false
				end)
			end

			keybindcurrentframe.MouseButton1Click:Connect(StartBinding)

			UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if (gameProcessed or Keybind.Binding or not Keybind.Key) then
					return
				end

				if (input.KeyCode == Keybind.Key or input.UserInputType == Keybind.Key) then
					if (Keybind.Mode == "Toggle") then
						Toggle:Set(not Toggle.State)
					elseif (Keybind.Mode == "Button") then
						Toggle:Set(true)
						if (Keybind.Callback) then
							Keybind.Callback(true)
						end
					elseif (Keybind.Mode == "Hold") then
						Keybind.State = true
						Toggle:Set(true)

						if (holdConnection) then
							holdConnection:Disconnect()
						end
						holdConnection = RunService.Heartbeat:Connect(function()
							if (Keybind.Callback) then
								Keybind.Callback(true)
							end
						end)
					end
				end
			end)

			UserInputService.InputEnded:Connect(function(input, gameProcessed)
				if (gameProcessed or Keybind.Mode ~= "Hold" or not Keybind.Key) then
					return
				end

				if (input.KeyCode == Keybind.Key or input.UserInputType == Keybind.Key) then
					Keybind.State = false
					Toggle:Set(false)

					if (holdConnection) then
						holdConnection:Disconnect()
						holdConnection = nil
					end

					if (Keybind.Callback) then
						Keybind.Callback(false)
					end
				end
			end)

			function Keybind.Set(self, newKey)
				SetKeybind(newKey)
			end

			function Keybind.GetKey(self)
				return Keybind.Key
			end

			function Keybind.GetState(self)
				return Keybind.State
			end

			Library.Flags[Keybind.Flag] = Keybind.Key
			Library.Flags[Keybind.Flag .. "_STATE"] = Keybind.State

			return Keybind
		end

		toggleElement.MouseEnter:Connect(function()
			if (Library.DropdownActive) then 
				return 
			end 
			local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

			if (not Toggle.State) then
				TweenService:Create(box, hoverTween, {
					BackgroundTransparency = 0.8,
				}):Play()

				TweenService:Create(toggleName, hoverTween, {
					TextColor3 = Color3.fromRGB(221, 221, 221),
				}):Play()
			end
		end)

		toggleElement.MouseLeave:Connect(function()
			local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

			if (not Toggle.State) then
				TweenService:Create(box, hoverTween, {
					BackgroundTransparency = 1,
				}):Play()

				TweenService:Create(toggleName, hoverTween, {
					TextColor3 = Color3.fromRGB(115, 115, 115),
				}):Play()
			end
		end)

        Toggle:Set(Toggle.Value)
		Library.SetFlag(Toggle.Flag, Toggle.Value)
		Library.Elements[Toggle.Flag] = Toggle
		Library.Callbacks[Toggle.Flag] = Toggle.Callback
		
		-- Check dependencies on creation
		if Toggle.Depends then
			Library.UpdateElementVisibility(Toggle)
		end

		return Toggle
	end

	function Sections.Slider(self, Properties)
		if (not Properties) then
			Properties = {}
		end

		local Slider = {
			Window = self.Window,
			Section = self,
			Name = Properties.Name or "Slider",
			Min = Properties.Min or 0,
			Max = Properties.Max or 100,
			Default = Properties.Default or Properties.Min,
			Decimals = Properties.Decimals or 0,
			Suffix = Properties.Suffix or "",
			Flag = Properties.Flag or Library.NextFlag(),
			Callback = Properties.Callback or function() end,
			Value = Properties.Default or Properties.Min,
			Depends = Properties.Depends,
		}
		Slider.Value = Slider.Default

		local sliderframe = Instance.new("Frame", Slider.Section.Elements.SectionContent)
		Slider.Elements = { SliderFrame = sliderframe }
		sliderframe.Name = "Sliderframe"
		sliderframe.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		sliderframe.BackgroundTransparency = 1
		sliderframe.BorderColor3 = Color3.fromRGB(0, 0, 0)
		sliderframe.BorderSizePixel = 0
		sliderframe.Size = Library.UDim2(1, 0, 0, 20)

		local textHolder = Instance.new("Frame")		
		textHolder.Name = "TextHolder"
		textHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		textHolder.BackgroundTransparency = 1
		textHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
		textHolder.BorderSizePixel = 0
		textHolder.Size = Library.UDim2(1, -52, 1, 0)
		textHolder.Parent = sliderframe

		local slidername = Instance.new("TextLabel")		
		slidername.Name = "Slidername"
		slidername.FontFace = Font.new("rbxassetid://12187365364")		
		slidername.Text = Slider.Name
		slidername.TextColor3 = Color3.fromRGB(115, 115, 115)
		slidername.TextSize = Library.GetScaledTextSize(12)
		slidername.TextWrapped = true
		slidername.TextXAlignment = Enum.TextXAlignment.Left
		slidername.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		slidername.BackgroundTransparency = 1
		slidername.BorderColor3 = Color3.fromRGB(0, 0, 0)
		slidername.BorderSizePixel = 0
		slidername.Position = UDim2.fromOffset(8, 0)
		slidername.Size = Library.UDim2(1, -52, 1, 0)
		slidername.Parent = textHolder

		local thebgofsliderbar = Instance.new("Frame")		
		thebgofsliderbar.Name = "Thebgofsliderbar"
		thebgofsliderbar.AnchorPoint = Vector2.new(1, 0.5)
		thebgofsliderbar.BackgroundColor3 = Color3.fromRGB(33, 32, 43)
		thebgofsliderbar.BackgroundTransparency = 1
		thebgofsliderbar.BorderColor3 = Color3.fromRGB(0, 0, 0)
		thebgofsliderbar.BorderSizePixel = 0
		thebgofsliderbar.Position = UDim2.new(1, -7, 0.5, 0)
		thebgofsliderbar.Size = Library.UDim2(1, -120, 0, 8)
		thebgofsliderbar.Parent = sliderframe

		local uICorner1 = Instance.new("UICorner")		
		uICorner1.Name = "UICorner"
		uICorner1.CornerRadius = UDim.new(0, 1)
		uICorner1.Parent = thebgofsliderbar

		local uIStroke1 = Instance.new("UIStroke")		
		uIStroke1.Name = "UIStroke"
		uIStroke1.Color = Color3.fromRGB(45, 45, 45)
		uIStroke1.Transparency = 0.6
		uIStroke1.Parent = thebgofsliderbar

		local thesliderbar = Instance.new("Frame")		
		thesliderbar.Name = "Thesliderbar"
		thesliderbar.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
		thesliderbar.BorderColor3 = Color3.fromRGB(0, 0, 0)
		thesliderbar.BorderSizePixel = 0
		thesliderbar.Size = Library.UDim2(0, 0, 1, 0)
		thesliderbar.Parent = thebgofsliderbar

		local uIStroke = Instance.new("UIStroke")		
		uIStroke.Name = "UIStroke"
		uIStroke.Color = Color3.fromRGB(38, 38, 36)
		uIStroke.Parent = thesliderbar

		local uICorner = Instance.new("UICorner")		
		uICorner.Name = "UICorner"
		uICorner.CornerRadius = UDim.new(0, 1)
		uICorner.Parent = thesliderbar

		local slidertextbox = Instance.new("TextBox", thebgofsliderbar)
		slidertextbox.Name = "Slidertextbox"
		slidertextbox.CursorPosition = -1		
		slidertextbox.FontFace = Font.new("rbxassetid://12187365364")		
		slidertextbox.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
		slidertextbox.Text = "50"
		slidertextbox.TextColor3 = Color3.fromRGB(67, 67, 68)
		slidertextbox.TextSize = Library.GetScaledTextSize(12)
		slidertextbox.TextXAlignment = Enum.TextXAlignment.Center
		slidertextbox.Active = false
		slidertextbox.AnchorPoint = Vector2.new(1, 0.5)
		slidertextbox.AutomaticSize = Enum.AutomaticSize.X
		slidertextbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		slidertextbox.BackgroundTransparency = 1
		slidertextbox.BorderColor3 = Color3.fromRGB(0, 0, 0)
		slidertextbox.BorderSizePixel = 0
		slidertextbox.Position = UDim2.new(0.66, 0, 0.5, 0)
		slidertextbox.Selectable = false
		slidertextbox.Size = Library.UDim2(0, 0, 1, 4)

		local Sliding = false
		local format = "%." .. Slider.Decimals .. "f"

		local function SetValue(value, fromInput)
			fromInput = fromInput or false
			local power = 10 ^ Slider.Decimals
			value = math.floor((value * power) + 0.5) / power
			value = math.clamp(value, Slider.Min, Slider.Max)

			Slider.Value = value
			local percent = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
			if ((Slider.Max - Slider.Min) == 0) then
				percent = 0
			end

			local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(thesliderbar, tweenInfo, {
				Size = UDim2.new(percent, 0, 1, 0),
			}):Play()

			if (not fromInput or slidertextbox.Text ~= (string.format(format, Slider.Value) .. Slider.Suffix)) then
				slidertextbox.Text = string.format(format, Slider.Value) .. Slider.Suffix
			end

            Library.SetFlag(Slider.Flag, Slider.Value)
			Library.Callbacks[Slider.Flag] = Slider.Callback
            Library.Elements[Slider.Flag] = Slider
		end

		local function HandleSlide(input)
			local barStartX = thebgofsliderbar.AbsolutePosition.X
			local barSizeX = thebgofsliderbar.AbsoluteSize.X
			if (barSizeX <= 0) then
				return
			end

			local percentage = math.clamp((input.Position.X - barStartX) / barSizeX, 0, 1)
			local value = Slider.Min + (Slider.Max - Slider.Min) * percentage
			SetValue(value)
		end

		thebgofsliderbar.InputBegan:Connect(function(input)
			-- Check if the section or element is disabled
			if Slider.Section.Disabled or Slider.Disabled then
				return
			end
			if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
				Sliding = true
				HandleSlide(input)
				if (slidertextbox:IsFocused()) then
					slidertextbox:ReleaseFocus()
				end
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
				Sliding = false
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if (Sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)) then
				HandleSlide(input)
			end
		end)

		slidertextbox.FocusLost:Connect(function(enterPressed)
			-- Check if the section or element is disabled
			if Slider.Section.Disabled or Slider.Disabled then
				return
			end
			if (enterPressed) then
				local textContent = slidertextbox.Text
				local numericString = textContent

				if (Slider.Suffix and Slider.Suffix ~= "") then
					local escapedSuffixPattern = Slider.Suffix:gsub("([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
					numericString = textContent:gsub(escapedSuffixPattern, "")
				end

				local numValue = tonumber(numericString)

				if (numValue) then
					SetValue(numValue, true)
				else
					slidertextbox.Text = string.format(format, Slider.Value) .. Slider.Suffix
				end
			else
				slidertextbox.Text = string.format(format, Slider.Value) .. Slider.Suffix
			end
		end)

		sliderframe.MouseEnter:Connect(function()
			if (Library.DropdownActive) then 
				return 
			end 
			local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

			TweenService:Create(slidername, hoverTween, {
				TextColor3 = Color3.fromRGB(255, 255, 255),
			}):Play()

            TweenService:Create(slidertextbox, hoverTween, {
                TextColor3 = Color3.fromRGB(255, 255, 255),
            }):Play()
		end)

		sliderframe.MouseLeave:Connect(function()
			local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

			TweenService:Create(slidername, hoverTween, {
				TextColor3 = Color3.fromRGB(115, 115, 115),
			}):Play()

            TweenService:Create(slidertextbox, hoverTween, {
                TextColor3 = Color3.fromRGB(67, 67, 68),
            }):Play()
		end)

		SetValue(Slider.Default)

		function Slider.Set(self, value)
			SetValue(value)
		end

		function Slider.GetValue(self)
			return Slider.Value
		end
		
		function Slider.SetVisible(self, visible)
			sliderframe.Visible = visible
		end
		
		-- Check dependencies on creation
		if Slider.Depends then
			Library.UpdateElementVisibility(Slider)
		end

		return Slider
	end

	function Sections.Dropdown(self, Properties)
		if (not Properties) then
			Properties = {}
		end

		self.DropdownCount = (self.DropdownCount or 0) + 1

		local Dropdown = {
			Window = self.Window,
			Section = self,
			Name = Properties.Name or "Dropdown",
			Options = Properties.Options or {},
			Default = Properties.Default,
			Max = Properties.Max,
			Flag = Properties.Flag or Library.NextFlag(),
			Callback = Properties.Callback or function() end,
			ZIndex = Properties.zIndex or Properties.Zindex or (1000 - self.DropdownCount),
			ScrollMaxHeight = Properties.ScrollMaxHeight or 200,
			AutoSize = Properties.AutoSize ~= false, 
			ManualSize = Properties.ManualSize or UDim2.new(1, 0, 0, 105),
			Searchable = Properties.Searchable ~= false, -- Enable search by default
			OptionInsts = {},
			FilteredOptions = {},
			SearchQuery = "",
			isOpen = false,
			Depends = Properties.Depends,
		}

		local dropdown = Instance.new("Frame", Dropdown.Section.Elements.SectionContent)
        Dropdown.Elements = { DropdownFrame = dropdown }
		dropdown.Name = "Dropdown"
		dropdown.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		dropdown.BackgroundTransparency = 1
		dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
		dropdown.BorderSizePixel = 0
		dropdown.ZIndex = Dropdown.ZIndex
		dropdown.Size = Library.UDim2(1, 0, 0, 25)

		local dropdownname = Instance.new("TextLabel")		
		dropdownname.Name = "Dropdownname"
		dropdownname.FontFace = Font.new("rbxassetid://12187365364")		
		dropdownname.Text = Dropdown.Name
		dropdownname.TextColor3 = Color3.fromRGB(115, 115, 115)
		dropdownname.TextSize = Library.GetScaledTextSize(12)
		dropdownname.TextXAlignment = Enum.TextXAlignment.Left
		dropdownname.AnchorPoint = Vector2.new(0, 0.5)
		dropdownname.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		dropdownname.BackgroundTransparency = 1
		dropdownname.BorderColor3 = Color3.fromRGB(0, 0, 0)
		dropdownname.BorderSizePixel = 0
		dropdownname.Position = UDim2.new(0, 8, 0.5, 0)
		dropdownname.Size = Library.UDim2(1, -12, 0, 15)
		dropdownname.Parent = dropdown

		local dropdowncurrentframe = Instance.new("TextButton")		
		dropdowncurrentframe.Name = "Dropdowncurrentframe"
		dropdowncurrentframe.Text = ""
		dropdowncurrentframe.AutoButtonColor = false
		dropdowncurrentframe.AnchorPoint = Vector2.new(1, 0.5)
		dropdowncurrentframe.AutomaticSize = Dropdown.AutoSize and Enum.AutomaticSize.X or Enum.AutomaticSize.None
		dropdowncurrentframe.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		dropdowncurrentframe.BackgroundTransparency = 1
		dropdowncurrentframe.BorderColor3 = Color3.fromRGB(0, 0, 0)
		dropdowncurrentframe.BorderSizePixel = 0
		dropdowncurrentframe.Position = UDim2.new(1, -7, 0.5, 0)
		dropdowncurrentframe.Size = Dropdown.AutoSize and UDim2.fromOffset(0, 21) or UDim2.fromOffset(80, 21)
		dropdowncurrentframe.Parent = dropdown

		local uIStroke = Instance.new("UIStroke")		
		uIStroke.Name = "UIStroke"
		uIStroke.Color = Color3.fromRGB(45, 45, 45)
		uIStroke.Transparency = 0.6
		uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uIStroke.Parent = dropdowncurrentframe

		local uICorner = Instance.new("UICorner")		
		uICorner.Name = "UICorner"
		uICorner.CornerRadius = UDim.new(0, 4)
		uICorner.Parent = dropdowncurrentframe

		local frame = Instance.new("Frame")		
		frame.Name = "Frame"
		frame.AutomaticSize = Dropdown.AutoSize and Enum.AutomaticSize.X or Enum.AutomaticSize.None
		frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		frame.BackgroundTransparency = 1
		frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		frame.BorderSizePixel = 0
		frame.Size = Dropdown.AutoSize and UDim2.fromScale(0, 1) or UDim2.fromScale(1, 1)
		frame.Parent = dropdowncurrentframe

		local uIListLayout = Instance.new("UIListLayout")		
		uIListLayout.Name = "UIListLayout"
		uIListLayout.Padding = UDim.new(0, 3)
		uIListLayout.FillDirection = Enum.FillDirection.Horizontal
		uIListLayout.HorizontalFlex = Dropdown.AutoSize and Enum.UIFlexAlignment.None or Enum.UIFlexAlignment.Fill
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.Parent = frame

		local uIPadding = Instance.new("UIPadding")		
		uIPadding.Name = "UIPadding"
		uIPadding.PaddingLeft = UDim.new(0, 8)
		uIPadding.PaddingRight = UDim.new(0, 8)
		uIPadding.PaddingTop = UDim.new(0, 4)
		uIPadding.PaddingBottom = UDim.new(0, 4)
		uIPadding.Parent = frame

		local left = Instance.new("Frame")		
		left.Name = "Left"
		left.AutomaticSize = Dropdown.AutoSize and Enum.AutomaticSize.X or Enum.AutomaticSize.None
		left.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		left.BackgroundTransparency = 1
		left.BorderColor3 = Color3.fromRGB(0, 0, 0)
		left.BorderSizePixel = 0
		left.Size = Dropdown.AutoSize and UDim2.fromScale(0, 1) or UDim2.new(1, -40, 1, 0)
		left.Parent = frame

        local dropdownCurrenttext = Instance.new("TextLabel")		
        dropdownCurrenttext.Name = "DropdownCurrenttext"
        dropdownCurrenttext.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        dropdownCurrenttext.Text = "..."
        dropdownCurrenttext.TextColor3 = Color3.fromRGB(115, 115, 115)
        dropdownCurrenttext.TextSize = Library.GetScaledTextSize(12)
        dropdownCurrenttext.TextWrapped = false
        dropdownCurrenttext.TextTruncate = Enum.TextTruncate.AtEnd
        dropdownCurrenttext.TextXAlignment = Enum.TextXAlignment.Left
        dropdownCurrenttext.Active = true
        dropdownCurrenttext.AutomaticSize = Dropdown.AutoSize and Enum.AutomaticSize.X or Enum.AutomaticSize.None
        dropdownCurrenttext.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dropdownCurrenttext.BackgroundTransparency = 1
        dropdownCurrenttext.BorderColor3 = Color3.fromRGB(0, 0, 0)
        dropdownCurrenttext.Selectable = true
        dropdownCurrenttext.Size = UDim2.new(1, -4, 1, -2)
        dropdownCurrenttext.Position = UDim2.new(0, 2, 0, 1)
		dropdownCurrenttext.Parent = left

		local right = Instance.new("Frame")		
		right.Name = "Right"
		right.AnchorPoint = Vector2.new(1, 0.5)
		right.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		right.BackgroundTransparency = 1
		right.BorderColor3 = Color3.fromRGB(0, 0, 0)
		right.BorderSizePixel = 0
		right.LayoutOrder = 1
		right.Position = UDim2.new(1, -5, 0.5, 0)
		right.Size = Library.UDim2(0, 15, 1, 0)
		right.Parent = frame

		local dropdownIcon = Instance.new("ImageLabel")		
		dropdownIcon.Name = "DropdownIcon"
		dropdownIcon.Image = "rbxassetid://115894980866040"
		dropdownIcon.ImageColor3 = Color3.fromRGB(44, 44, 41)
		dropdownIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		dropdownIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		dropdownIcon.BackgroundTransparency = 1
		dropdownIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
		dropdownIcon.BorderSizePixel = 0
		dropdownIcon.Position = UDim2.fromScale(0.5, 0.5)
		dropdownIcon.Size = UDim2.fromOffset(14, 14)
		dropdownIcon.ZIndex = 4
		dropdownIcon.Parent = right
        
        Dropdown.dropdownIcon = dropdownIcon

        local dropdownList = Instance.new("Frame")		
        dropdownList.Name = "DropdownList"
        dropdownList.AnchorPoint = Vector2.new(1, 0)
        dropdownList.AutomaticSize = Dropdown.AutoSize and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
        dropdownList.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
        dropdownList.BackgroundTransparency = 0.3
        dropdownList.BorderColor3 = Color3.fromRGB(0, 0, 0)
        dropdownList.BorderSizePixel = 0
        dropdownList.Position = UDim2.fromScale(1, 1.02)
        dropdownList.Size = Dropdown.AutoSize and UDim2.new(0, math.max(120, dropdowncurrentframe.AbsoluteSize.X), 0, 0) or UDim2.fromScale(1.5, 6)
        dropdownList.Visible = false
        dropdownList.ZIndex = Dropdown.ZIndex
        dropdownList.ClipsDescendants = true
        dropdownList.Parent = dropdowncurrentframe

        if (Dropdown.AutoSize) then
            local sizeConstraint = Instance.new("UISizeConstraint")
            sizeConstraint.MaxSize = Vector2.new(300, Dropdown.ScrollMaxHeight or 105)
            sizeConstraint.MinSize = Vector2.new(120, 0)
            sizeConstraint.Parent = dropdownList
        end

        Dropdown.dropdownList = dropdownList

		local uICorner2 = Instance.new("UICorner")		
		uICorner2.Name = "UICorner"
		uICorner2.CornerRadius = UDim.new(0, 6)
		uICorner2.Parent = dropdownList

		local uIStroke1 = Instance.new("UIStroke")		
		uIStroke1.Name = "UIStroke"
		uIStroke1.Color = Color3.fromRGB(38, 38, 36)
		uIStroke1.Parent = dropdownList

        -- Search input (only if searchable)
        local searchInput = nil
        if (Dropdown.Searchable) then
            searchInput = Instance.new("TextBox")
            searchInput.Name = "SearchInput"
            searchInput.FontFace = Font.new("rbxassetid://12187365364")
            searchInput.PlaceholderText = "Search..."
            searchInput.PlaceholderColor3 = Color3.fromRGB(115, 115, 115)
            searchInput.Text = ""
            searchInput.TextColor3 = Color3.fromRGB(255, 255, 255)
            searchInput.TextSize = Library.GetScaledTextSize(11)
            searchInput.TextXAlignment = Enum.TextXAlignment.Left
            searchInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            searchInput.BackgroundTransparency = 0.2
            searchInput.BorderSizePixel = 0
            searchInput.Size = Library.UDim2(1, -8, 0, 20)
            searchInput.Position = UDim2.new(0, 4, 0, 4)
            searchInput.ZIndex = Dropdown.ZIndex + 5
            searchInput.Parent = dropdownList

            local searchCorner = Instance.new("UICorner")
            searchCorner.CornerRadius = UDim.new(0, 3)
            searchCorner.Parent = searchInput

            local searchStroke = Instance.new("UIStroke")
            searchStroke.Color = Color3.fromRGB(45, 45, 45)
            searchStroke.Transparency = 0.6
            searchStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            searchStroke.Parent = searchInput

            -- Search icon
            local searchIcon = Instance.new("ImageLabel")
            searchIcon.Name = "SearchIcon"
            searchIcon.Image = "rbxassetid://139032822388177"
            searchIcon.ImageColor3 = Color3.fromRGB(80, 80, 75)
            searchIcon.AnchorPoint = Vector2.new(1, 0.5)
            searchIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            searchIcon.BackgroundTransparency = 1
            searchIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
            searchIcon.BorderSizePixel = 0
            searchIcon.Position = UDim2.new(1, 6, 0.5, 0)
            searchIcon.Size = UDim2.fromOffset(14, 14)
            searchIcon.ZIndex = Dropdown.ZIndex + 6
            searchIcon.Parent = searchInput

            -- Add padding to prevent text overlap with icon
            local searchPadding = Instance.new("UIPadding")
            searchPadding.PaddingLeft = UDim.new(0, 6)
            searchPadding.PaddingRight = UDim.new(0, 16)
            searchPadding.Parent = searchInput
            
            -- Store references for ZIndex manipulation
            Dropdown.searchInput = searchInput
            Dropdown.searchIcon = searchIcon
        end

        local optionHolder = Instance.new("ScrollingFrame")		
        optionHolder.Name = "OptionHolder"
        optionHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
        optionHolder.ScrollBarThickness = 0
		optionHolder.AutomaticSize = Dropdown.AutoSize and Enum.AutomaticSize.X or Enum.AutomaticSize.None
		optionHolder.BackgroundColor3 = Color3.fromRGB(28, 29, 32)
		optionHolder.BackgroundTransparency = 1
		optionHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
		optionHolder.BorderSizePixel = 0
        optionHolder.Selectable = true
		optionHolder.Active = true
        optionHolder.Size = UDim2.fromScale(1, 1)
        optionHolder.Position = Dropdown.Searchable and UDim2.new(0, 0, 0, 28) or UDim2.new(0, 0, 0, 0)
        optionHolder.ZIndex = Dropdown.ZIndex + 2
        optionHolder.ClipsDescendants = true
        optionHolder.Parent = dropdownList

        if (Dropdown.AutoSize) then
            optionHolder.Size = Library.UDim2(1, 0, 0, math.min(Dropdown.ScrollMaxHeight or 105, 200))
            optionHolder.ScrollBarThickness = 0
            optionHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
            optionHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
        else
            optionHolder.Size = Library.UDim2(1, 0, 1, Dropdown.Searchable and -28 or 0)
        end

        Dropdown.optionHolder = optionHolder

		local uICorner1 = Instance.new("UICorner")		
		uICorner1.Name = "UICorner"
		uICorner1.CornerRadius = UDim.new(0, 4)
		uICorner1.Parent = optionHolder

		local uIListLayout1 = Instance.new("UIListLayout")		
		uIListLayout1.Name = "UIListLayout"
		uIListLayout1.Padding = UDim.new(0, 2)
		uIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout1.Parent = optionHolder

		local uIPadding1 = Instance.new("UIPadding")		
		uIPadding1.Name = "UIPadding"
		uIPadding1.PaddingBottom = UDim.new(0, 0)
		uIPadding1.PaddingTop = UDim.new(0, 2)
		uIPadding1.Parent = optionHolder

		local chosenValue = Dropdown.Max and {} or (Dropdown.Default or "...")

        -- Initialize filtered options
        Dropdown.FilteredOptions = {}
        for _, option in ipairs(Dropdown.Options) do
            table.insert(Dropdown.FilteredOptions, option)
        end

        local function filterOptions(query)
            Dropdown.SearchQuery = query:lower()
            table.clear(Dropdown.FilteredOptions)
            
            if (Dropdown.SearchQuery == "") then
                for _, option in ipairs(Dropdown.Options) do
                    table.insert(Dropdown.FilteredOptions, option)
                end
            else
                for _, option in ipairs(Dropdown.Options) do
                    if (option:lower():find(Dropdown.SearchQuery, 1, true)) then
                        table.insert(Dropdown.FilteredOptions, option)
                    end
                end
            end
            
            -- Hide/show options based on filter
            for optionName, optionData in pairs(Dropdown.OptionInsts) do
                local shouldShow = table.find(Dropdown.FilteredOptions, optionName) ~= nil
                optionData.frame.Visible = shouldShow
            end
        end

        -- Search functionality
        if (Dropdown.Searchable and searchInput) then
            searchInput.Changed:Connect(function(property)
                if (property == "Text") then
                    filterOptions(searchInput.Text)
                end
            end)

            searchInput.FocusLost:Connect(function()
                -- Keep focus when dropdown is open
                if (Dropdown.isOpen) then
                    task.wait(0.1)
                    if (Dropdown.isOpen) then
                        searchInput:CaptureFocus()
                    end
                end
            end)
        end

        local function updateCurrentText()
            if (Dropdown.Max) then
                if (#chosenValue == 0) then
                    dropdownCurrenttext.Text = "..."
                else
                    local fullText = table.concat(chosenValue, ", ")
                    if (#fullText > 15) then
                        dropdownCurrenttext.Text = string.sub(fullText, 1, 12) .. "..."
                    else
                        dropdownCurrenttext.Text = fullText
                    end
                end
            else
                local displayText = tostring(chosenValue)
                if (#displayText > 15) then
                    dropdownCurrenttext.Text = string.sub(displayText, 1, 12) .. "..."
                else
                    dropdownCurrenttext.Text = displayText
                end
            end
        end

		local function setOptionSelectedLook(optionInst, isSelected)
			if (not optionInst) then
				return
			end
			local label = optionInst.label
			local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(label, tweenInfo, {
				TextColor3 = isSelected and Color3.fromRGB(221, 221, 221) or Color3.fromRGB(115, 115, 115),
			}):Play()
		end

		local function createOptionElement(optionName)
            local option = Instance.new("TextLabel")			
            option.Name = optionName
            option.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
            option.Text = optionName
            option.TextColor3 = Color3.fromRGB(115, 115, 115)
            option.TextSize = Library.GetScaledTextSize(12)
            option.TextWrapped = true
            option.TextXAlignment = Enum.TextXAlignment.Left
            option.AutomaticSize = Enum.AutomaticSize.None
            option.BackgroundColor3 = Color3.fromRGB(29, 30, 42)
            option.BackgroundTransparency = 1
            option.BorderSizePixel = 0
            option.ClipsDescendants = true
            option.Size = Library.UDim2(1, 0, 0, 20)
            option.Parent = optionHolder

			local textButton = Instance.new("TextButton")			
			textButton.Name = "TextButton"
			textButton.Text = ""
			textButton.BackgroundTransparency = 1
			textButton.Size = UDim2.fromScale(1, 1)
			textButton.ZIndex = Dropdown.ZIndex + 10
			textButton.AutoButtonColor = false
			textButton.Parent = option

			local uIPadding2 = Instance.new("UIPadding")			
			uIPadding2.Name = "UIPadding"
			uIPadding2.PaddingLeft = UDim.new(0, 3)
			uIPadding2.Parent = option

			Dropdown.OptionInsts[optionName] = {
				frame = option,
				label = option,
				button = textButton,
			}

			textButton.MouseEnter:Connect(function()
				if (Library.DropdownActive) then 
					return 
				end 
				if (not table.find(Dropdown.Max and chosenValue or { chosenValue }, optionName)) then
					local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					TweenService:Create(option, hoverTween, {
						TextColor3 = Color3.fromRGB(255, 255, 255),
					}):Play()
				end
			end)

			textButton.MouseLeave:Connect(function()
				if (not table.find(Dropdown.Max and chosenValue or { chosenValue }, optionName)) then
					local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					TweenService:Create(option, hoverTween, {
						TextColor3 = Color3.fromRGB(115, 115, 115),
					}):Play()
				end
			end)

			textButton.MouseButton1Click:Connect(function()
				-- Check if the section or element is disabled
				if Dropdown.Section.Disabled or Dropdown.Disabled then
					return
				end
				if (Dropdown.Max) then
					local currentIndex = table.find(chosenValue, optionName)
					if (Dropdown.Max == 1) then
						if (not currentIndex) then
							if (#chosenValue > 0) then
								local oldSelection = chosenValue[1]
								if (Dropdown.OptionInsts[oldSelection]) then
									setOptionSelectedLook(Dropdown.OptionInsts[oldSelection], false)
								end
							end
							table.clear(chosenValue)
							table.insert(chosenValue, optionName)
							setOptionSelectedLook(Dropdown.OptionInsts[optionName], true)
						end
						Dropdown.isOpen = false
						Library.DropdownActive = false
					else
						if (currentIndex) then
							table.remove(chosenValue, currentIndex)
							setOptionSelectedLook(Dropdown.OptionInsts[optionName], false)
						elseif (#chosenValue < Dropdown.Max) then
							table.insert(chosenValue, optionName)
							setOptionSelectedLook(Dropdown.OptionInsts[optionName], true)
						end
					end
				else
					if (chosenValue ~= optionName) then
						if (Dropdown.OptionInsts[chosenValue]) then
							setOptionSelectedLook(Dropdown.OptionInsts[chosenValue], false)
						end
						chosenValue = optionName
						setOptionSelectedLook(Dropdown.OptionInsts[optionName], true)
					end
					Dropdown.isOpen = false
					Library.DropdownActive = false
				end

				updateCurrentText()
				Library.SetFlag(Dropdown.Flag, chosenValue)

                if (not Dropdown.isOpen) then
                    dropdownList.Visible = false
                    TweenService:Create(dropdownIcon, TweenInfo.new(0.2), { Rotation = 0 }):Play()
                    Library.CurrentOpenDropdown = nil
                end
			end)

			return option
		end

        local function toggleDropdownList()
            if (Library.CurrentOpenDropdown and Library.CurrentOpenDropdown ~= Dropdown) then
                Library.CurrentOpenDropdown.isOpen = false
				Library.DropdownActive = false
                if (Library.CurrentOpenDropdown.dropdownList) then
                    Library.CurrentOpenDropdown.dropdownList.Visible = false
                    -- Restore original ZIndex for the previously open dropdown
                    Library.CurrentOpenDropdown.dropdownList.ZIndex = Library.CurrentOpenDropdown.ZIndex
                    if (Library.CurrentOpenDropdown.optionHolder) then
                        Library.CurrentOpenDropdown.optionHolder.ZIndex = Library.CurrentOpenDropdown.ZIndex + 2
                    end
                    if (Library.CurrentOpenDropdown.searchInput) then
                        Library.CurrentOpenDropdown.searchInput.ZIndex = Library.CurrentOpenDropdown.ZIndex + 5
                    end
                    if (Library.CurrentOpenDropdown.searchIcon) then
                        Library.CurrentOpenDropdown.searchIcon.ZIndex = Library.CurrentOpenDropdown.ZIndex + 6
                    end
                    
                    -- Restore original ZIndex values for previously open dropdown option buttons
                    for _, optionData in pairs(Library.CurrentOpenDropdown.OptionInsts) do
                        if optionData.button then
                            optionData.button.ZIndex = Library.CurrentOpenDropdown.ZIndex + 10
                        end
                        if optionData.frame then
                            optionData.frame.ZIndex = Library.CurrentOpenDropdown.ZIndex
                        end
                    end
                end

                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                TweenService:Create(Library.CurrentOpenDropdown.dropdownIcon, tweenInfo, { Rotation = 0 }):Play()
            end
            
            Dropdown.isOpen = not Dropdown.isOpen
			Library.DropdownActive = Dropdown.isOpen
            dropdownList.Visible = Dropdown.isOpen
            
            if (Dropdown.isOpen) then
                Library.CurrentOpenDropdown = Dropdown
                -- Increase ZIndex to render above all other elements including lists
                dropdownList.ZIndex = 50000
                optionHolder.ZIndex = 50002
                if (Dropdown.searchInput) then
                    Dropdown.searchInput.ZIndex = 50005
                end
                if (Dropdown.searchIcon) then
                    Dropdown.searchIcon.ZIndex = 50006
                end
                
                -- Update all option button ZIndex values to ensure they render on top
                for _, optionData in pairs(Dropdown.OptionInsts) do
                    if optionData.button then
                        optionData.button.ZIndex = 50010
                    end
                    if optionData.frame then
                        optionData.frame.ZIndex = 50003
                    end
                end
                -- Focus search input when opening
                if (Dropdown.Searchable and Dropdown.searchInput) then
                    task.wait(0.1)
                    Dropdown.searchInput:CaptureFocus()
                end
            else
                Library.CurrentOpenDropdown = nil
                -- Restore original ZIndex when closing
                dropdownList.ZIndex = Dropdown.ZIndex
                optionHolder.ZIndex = Dropdown.ZIndex + 2
                if (Dropdown.searchInput) then
                    Dropdown.searchInput.ZIndex = Dropdown.ZIndex + 5
                end
                if (Dropdown.searchIcon) then
                    Dropdown.searchIcon.ZIndex = Dropdown.ZIndex + 6
                end
                
                -- Restore original ZIndex values for option buttons
                for _, optionData in pairs(Dropdown.OptionInsts) do
                    if optionData.button then
                        optionData.button.ZIndex = Dropdown.ZIndex + 10
                    end
                    if optionData.frame then
                        optionData.frame.ZIndex = Dropdown.ZIndex
                    end
                end
                -- Clear search when closing
                if (Dropdown.Searchable and Dropdown.searchInput) then
                    Dropdown.searchInput.Text = ""
                    filterOptions("")
                end
            end
            
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(dropdownIcon, tweenInfo, { Rotation = Dropdown.isOpen and 180 or 0 }):Play()
        end

		dropdowncurrentframe.MouseButton1Click:Connect(toggleDropdownList)

		dropdown.MouseEnter:Connect(function()
			local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

			if (Library.CurrentOpenDropdown == nil or Library.CurrentOpenDropdown == Dropdown) then
				TweenService:Create(dropdownname, hoverTween, {
					TextColor3 = Color3.fromRGB(255, 255, 255),
				}):Play()
			end
		end)

		dropdown.MouseLeave:Connect(function()
			local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

			TweenService:Create(dropdownname, hoverTween, {
				TextColor3 = Color3.fromRGB(115, 115, 115),
			}):Play()
		end)

		function Dropdown.Refresh(self, newOptions)
			for _, instData in pairs(Dropdown.OptionInsts) do
				instData.frame:Destroy()
			end
			table.clear(Dropdown.OptionInsts)
			Dropdown.Options = newOptions or {}

            -- Update filtered options
            table.clear(Dropdown.FilteredOptions)
            for _, option in ipairs(Dropdown.Options) do
                table.insert(Dropdown.FilteredOptions, option)
            end

			if (Dropdown.Max) then
				chosenValue = {}
			else
				chosenValue = "..."
			end

			for _, optionName in ipairs(Dropdown.Options) do
				createOptionElement(optionName)
			end

            -- Apply current search filter
            if (Dropdown.Searchable and searchInput) then
                filterOptions(searchInput.Text)
            end

			if (Dropdown.Default) then
				if (Dropdown.Max) then
					chosenValue = {}
					local defaultsToApply = type(Dropdown.Default) == "table" and Dropdown.Default or { Dropdown.Default }
					for _, defOpt in ipairs(defaultsToApply) do
						if (table.find(Dropdown.Options, defOpt) and #chosenValue < Dropdown.Max) then
							table.insert(chosenValue, defOpt)
							if (Dropdown.OptionInsts[defOpt]) then
								setOptionSelectedLook(Dropdown.OptionInsts[defOpt], true)
							end
						end
					end
				else
					if (table.find(Dropdown.Options, Dropdown.Default)) then
						chosenValue = Dropdown.Default
						if (Dropdown.OptionInsts[chosenValue]) then
							setOptionSelectedLook(Dropdown.OptionInsts[chosenValue], true)
						end
					else
						chosenValue = #Dropdown.Options > 0 and Dropdown.Options[1] or "..."
						if (Dropdown.OptionInsts[chosenValue]) then
							setOptionSelectedLook(Dropdown.OptionInsts[chosenValue], true)
						end
					end
				end
			elseif (#Dropdown.Options > 0 and not Dropdown.Max) then
				chosenValue = Dropdown.Options[1]
				if (Dropdown.OptionInsts[chosenValue]) then
					setOptionSelectedLook(Dropdown.OptionInsts[chosenValue], true)
				end
			end

			updateCurrentText()
			Library.SetFlag(Dropdown.Flag, chosenValue)
		end

		function Dropdown.Set(self, value)
			local validValue = false
			if (Dropdown.Max) then
				local tempChosen = {}
				local valuesToSet = type(value) == "table" and value or { value }
				for _, valOpt in ipairs(valuesToSet) do
					if (Dropdown.OptionInsts[valOpt] and #tempChosen < Dropdown.Max) then
						table.insert(tempChosen, valOpt)
					end
				end
				if (#tempChosen > 0) then
					for _, optName in ipairs(chosenValue) do
						if (Dropdown.OptionInsts[optName]) then
							setOptionSelectedLook(Dropdown.OptionInsts[optName], false)
						end
					end
					chosenValue = tempChosen

					for _, optName in ipairs(chosenValue) do
						if (Dropdown.OptionInsts[optName]) then
							setOptionSelectedLook(Dropdown.OptionInsts[optName], true)
						end
					end
					validValue = true
				end
			else
				if (Dropdown.OptionInsts[value]) then
					if (Dropdown.OptionInsts[chosenValue]) then
						setOptionSelectedLook(Dropdown.OptionInsts[chosenValue], false)
					end
					chosenValue = value
					setOptionSelectedLook(Dropdown.OptionInsts[chosenValue], true)
					validValue = true
				end
			end

			if (validValue) then
				updateCurrentText()
				Library.SetFlag(Dropdown.Flag, chosenValue)
			end
		end

		function Dropdown.GetValue(self)
			return chosenValue
		end

        function Dropdown.SetAutoSize(self, autoSize, manualSize)
            self.AutoSize = autoSize
            if (manualSize) then
                self.ManualSize = manualSize
            end
            
            dropdowncurrentframe.AutomaticSize = autoSize and Enum.AutomaticSize.X or Enum.AutomaticSize.None
            left.Size = autoSize and UDim2.fromScale(0, 1) or UDim2.new(1, -30, 1, 0)
            dropdownCurrenttext.AutomaticSize = autoSize and Enum.AutomaticSize.X or Enum.AutomaticSize.None
            dropdownList.AutomaticSize = autoSize and Enum.AutomaticSize.Y or Enum.AutomaticSize.None
            
            if (autoSize) then
                local optionCount = 0
                for _ in pairs(Dropdown.OptionInsts) do
                    optionCount = optionCount + 1
                end
                
                local optionHeight = 10
                local padding = 6
                local topPadding = 5
                local bottomPadding = 5
                local calculatedHeight = (optionCount * optionHeight) + ((optionCount - 1) * padding) + topPadding + bottomPadding
                local maxHeight = Dropdown.ScrollMaxHeight or 200
                local finalHeight = math.min(calculatedHeight, maxHeight)
                
                dropdownList.Size = Library.UDim2(0, math.max(120, dropdowncurrentframe.AbsoluteSize.X), 0, finalHeight)
                dropdownList.Position = UDim2.new(1, 0, 0, 23)
                
                if (calculatedHeight > maxHeight) then
                    optionHolder.ScrollBarThickness = 0
                    optionHolder.AutomaticSize = Enum.AutomaticSize.None
                    optionHolder.Size = UDim2.fromScale(1, 1)
                    optionHolder.CanvasSize = Library.UDim2(0, 0, 0, calculatedHeight)
                else
                    optionHolder.ScrollBarThickness = 0
                    optionHolder.AutomaticSize = Enum.AutomaticSize.Y
                    optionHolder.Size = Library.UDim2(1, 0, 0, finalHeight)
                    optionHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
                end
            else
                dropdownList.Size = self.ManualSize
                dropdownList.Position = UDim2.new(1, 0, 0, 23)
                optionHolder.ScrollBarThickness = 0
                optionHolder.AutomaticSize = Enum.AutomaticSize.None
                optionHolder.Size = UDim2.fromScale(1, 1)
            end
            
            dropdownList.ClipsDescendants = true
            optionHolder.ClipsDescendants = true
            
            for _, optionData in pairs(Dropdown.OptionInsts) do
                if (optionData.frame) then
                    optionData.frame.AutomaticSize = Enum.AutomaticSize.None
                    optionData.frame.Size = Library.UDim2(1, 0, 0, 20)
                end
            end
        end
        
		Dropdown:Refresh(Dropdown.Options)
		Library.Elements[Dropdown.Flag] = Dropdown
		Library.Callbacks[Dropdown.Flag] = Dropdown.Callback

        if (Dropdown.AutoSize) then
            Dropdown:SetAutoSize(true)
        end
		
		Library:connection(UserInputService.InputBegan, function(input, gameProcessedEvent)
			if (gameProcessedEvent) then
				return
			end
			
			if (input.UserInputType == Enum.UserInputType.MouseButton1) then
				if (Library.CurrentOpenDropdown and Library.CurrentOpenDropdown == Dropdown) then
					local mouse = LocalPlayer:GetMouse()
					local mousePos = Vector2.new(mouse.X, mouse.Y)
					
					local overDropdownFrame = Library:IsMouseOverFrame(dropdown)
					local overDropdownList = Library:IsMouseOverFrame(dropdownList)
					
					if (not overDropdownFrame and not overDropdownList) then
						Dropdown.isOpen = false
						Library.DropdownActive = false
						dropdownList.Visible = false
						TweenService:Create(dropdownIcon, TweenInfo.new(0.2), { Rotation = 0 }):Play()
						Library.CurrentOpenDropdown = nil
					end
				end
			end
		end)
		
		function Dropdown.SetVisible(self, visible)
			dropdown.Visible = visible
		end
		
		-- Check dependencies on creation
		if Dropdown.Depends then
			Library.UpdateElementVisibility(Dropdown)
		end

		return Dropdown
	end

	function Sections.List(self, Properties)
		if (not Properties) then
			Properties = {}
		end

		self.ListCount = (self.ListCount or 0) + 1

		local List = {
			Window = self.Window,
			Section = self,
			Name = Properties.Name or "List",
			Options = Properties.Options or {},
			Default = Properties.Default,
			Max = Properties.Max,
			Flag = Properties.Flag or Library.NextFlag(),
			Callback = Properties.Callback or function() end,
			ZIndex = Properties.zIndex or Properties.Zindex or (1000 - self.ListCount),
			MaxHeight = Properties.MaxHeight or 150,
			MinHeight = Properties.MinHeight or 50, -- Minimum height for the list
			OptionInsts = {},
			Depends = Properties.Depends,
		}

		local listFrame = Instance.new("Frame", List.Section.Elements.SectionContent)
        List.Elements = { ListFrame = listFrame }
		listFrame.Name = "List"
		listFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		listFrame.BackgroundTransparency = 1
		listFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		listFrame.BorderSizePixel = 0
		listFrame.ZIndex = List.ZIndex
		listFrame.Size = Library.UDim2(1, 0, 0, math.max(List.MinHeight + 25, math.min(25 + (#List.Options * 22) + 10, List.MaxHeight + 25)))

		local listName = Instance.new("TextLabel")		
		listName.Name = "ListName"
		listName.FontFace = Font.new("rbxassetid://12187365364")		
		listName.Text = List.Name
		listName.TextColor3 = Color3.fromRGB(115, 115, 115)
		listName.TextSize = Library.GetScaledTextSize(12)
		listName.TextXAlignment = Enum.TextXAlignment.Left
		listName.AnchorPoint = Vector2.new(0, 0)
		listName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		listName.BackgroundTransparency = 1
		listName.BorderColor3 = Color3.fromRGB(0, 0, 0)
		listName.BorderSizePixel = 0
		listName.Position = UDim2.new(0, 8, 0, 0)
		listName.Size = Library.UDim2(1, -16, 0, 20)
		listName.Parent = listFrame

		local listContainer = Instance.new("Frame")		
		listContainer.Name = "ListContainer"
		listContainer.AnchorPoint = Vector2.new(0.5, 0)
		listContainer.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
		listContainer.BackgroundTransparency = 0.3
		listContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
		listContainer.BorderSizePixel = 0
		listContainer.Position = UDim2.new(0.5, 0, 0, 22)
		listContainer.Size = Library.UDim2(1, -14, 0, math.max(List.MinHeight, math.min(#List.Options * 22 + 4, List.MaxHeight)))
		listContainer.ZIndex = List.ZIndex
		listContainer.ClipsDescendants = true
		listContainer.Parent = listFrame

		local uICorner2 = Instance.new("UICorner")		
		uICorner2.Name = "UICorner"
		uICorner2.CornerRadius = UDim.new(0, 6)
		uICorner2.Parent = listContainer

		local uIStroke1 = Instance.new("UIStroke")		
		uIStroke1.Name = "UIStroke"
		uIStroke1.Color = Color3.fromRGB(38, 38, 36)
		uIStroke1.Parent = listContainer

        local optionHolder = Instance.new("ScrollingFrame")		
        optionHolder.Name = "OptionHolder"
        optionHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
        optionHolder.ScrollBarThickness = 0
		optionHolder.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
		optionHolder.BackgroundTransparency = 1
		optionHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
		optionHolder.BorderSizePixel = 0
        optionHolder.Selectable = true
		optionHolder.Active = true
        optionHolder.Size = UDim2.fromScale(1, 1)
        optionHolder.ZIndex = List.ZIndex
        optionHolder.ClipsDescendants = true
        optionHolder.Parent = listContainer

		local uICorner1 = Instance.new("UICorner")		
		uICorner1.Name = "UICorner"
		uICorner1.CornerRadius = UDim.new(0, 4)
		uICorner1.Parent = optionHolder

		local uIListLayout1 = Instance.new("UIListLayout")		
		uIListLayout1.Name = "UIListLayout"
		uIListLayout1.Padding = UDim.new(0, 2)
		uIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout1.Parent = optionHolder

		local uIPadding1 = Instance.new("UIPadding")		
		uIPadding1.Name = "UIPadding"
		uIPadding1.PaddingBottom = UDim.new(0, 2)
		uIPadding1.PaddingTop = UDim.new(0, 2)
		uIPadding1.Parent = optionHolder

		local chosenValue = List.Max and {} or (List.Default or nil)

		local function setOptionSelectedLook(optionInst, isSelected)
			if (not optionInst) then
				return
			end
			local label = optionInst.label
			local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(label, tweenInfo, {
				TextColor3 = isSelected and Color3.fromRGB(221, 221, 221) or Color3.fromRGB(115, 115, 115),
			}):Play()
		end

		local function createOptionElement(optionName)
            local option = Instance.new("TextLabel")			
            option.Name = optionName
            option.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
            option.Text = optionName
            option.TextColor3 = Color3.fromRGB(115, 115, 115)
            option.TextSize = Library.GetScaledTextSize(12)
            option.TextWrapped = true
            option.TextXAlignment = Enum.TextXAlignment.Left
            option.AutomaticSize = Enum.AutomaticSize.None
            option.BackgroundColor3 = Color3.fromRGB(29, 30, 42)
            option.BackgroundTransparency = 1
            option.BorderSizePixel = 0
            option.ClipsDescendants = true
            option.Size = Library.UDim2(1, 0, 0, 20)
            option.Parent = optionHolder

			local textButton = Instance.new("TextButton")			
			textButton.Name = "TextButton"
			textButton.Text = ""
			textButton.BackgroundTransparency = 1
			textButton.Size = UDim2.fromScale(1, 1)
			textButton.ZIndex = 15
			textButton.AutoButtonColor = false
			textButton.Parent = option

			local uIPadding2 = Instance.new("UIPadding")			
			uIPadding2.Name = "UIPadding"
			uIPadding2.PaddingLeft = UDim.new(0, 8)
			uIPadding2.Parent = option

			List.OptionInsts[optionName] = {
				frame = option,
				label = option,
				button = textButton,
			}

			textButton.MouseEnter:Connect(function()
				if (not table.find(List.Max and chosenValue or (chosenValue and { chosenValue } or {}), optionName)) then
					local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					TweenService:Create(option, hoverTween, {
						TextColor3 = Color3.fromRGB(255, 255, 255),
					}):Play()
				end
			end)

			textButton.MouseLeave:Connect(function()
				if (not table.find(List.Max and chosenValue or (chosenValue and { chosenValue } or {}), optionName)) then
					local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					TweenService:Create(option, hoverTween, {
						TextColor3 = Color3.fromRGB(115, 115, 115),
					}):Play()
				end
			end)

			textButton.MouseButton1Click:Connect(function()
				-- Check if the section or element is disabled
				if List.Section.Disabled or List.Disabled then
					return
				end
				if (List.Max) then
					local currentIndex = table.find(chosenValue, optionName)
					if (List.Max == 1) then
						if (not currentIndex) then
							if (#chosenValue > 0) then
								local oldSelection = chosenValue[1]
								if (List.OptionInsts[oldSelection]) then
									setOptionSelectedLook(List.OptionInsts[oldSelection], false)
								end
							end
							table.clear(chosenValue)
							table.insert(chosenValue, optionName)
							setOptionSelectedLook(List.OptionInsts[optionName], true)
						end
					else
						if (currentIndex) then
							table.remove(chosenValue, currentIndex)
							setOptionSelectedLook(List.OptionInsts[optionName], false)
						elseif (#chosenValue < List.Max) then
							table.insert(chosenValue, optionName)
							setOptionSelectedLook(List.OptionInsts[optionName], true)
						end
					end
				else
					if (chosenValue ~= optionName) then
						if (chosenValue and List.OptionInsts[chosenValue]) then
							setOptionSelectedLook(List.OptionInsts[chosenValue], false)
						end
						chosenValue = optionName
						setOptionSelectedLook(List.OptionInsts[optionName], true)
					end
				end

				Library.SetFlag(List.Flag, chosenValue)
			end)

			return option
		end

		listFrame.MouseEnter:Connect(function()
			local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(listName, hoverTween, {
				TextColor3 = Color3.fromRGB(255, 255, 255),
			}):Play()
		end)

		listFrame.MouseLeave:Connect(function()
			local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(listName, hoverTween, {
				TextColor3 = Color3.fromRGB(115, 115, 115),
			}):Play()
		end)

		function List.Refresh(self, newOptions)
			-- Store previous selections before clearing
			local previousSelections = {}
			if (List.Max) then
				-- Multi-selection: copy the array
				if (chosenValue and type(chosenValue) == "table") then
					for _, value in ipairs(chosenValue) do
						table.insert(previousSelections, value)
					end
				end
			else
				-- Single selection: store the value
				if (chosenValue) then
					table.insert(previousSelections, chosenValue)
				end
			end

			for _, instData in pairs(List.OptionInsts) do
				instData.frame:Destroy()
			end
			table.clear(List.OptionInsts)
			List.Options = newOptions or {}

			if (List.Max) then
				chosenValue = {}
			else
				chosenValue = nil
			end

			for _, optionName in ipairs(List.Options) do
				createOptionElement(optionName)
			end

			-- Update container size
			local optionCount = #List.Options
			local newHeight = math.max(List.MinHeight, math.min(optionCount * 22 + 4, List.MaxHeight))
			listContainer.Size = Library.UDim2(1, -14, 0, newHeight)
			listFrame.Size = Library.UDim2(1, 0, 0, math.max(List.MinHeight + 25, newHeight + 25))

			-- Restore previous selections that are still available
			local hasValidPreviousSelection = false
			if (#previousSelections > 0) then
				if (List.Max) then
					chosenValue = {}
					for _, prevSelection in ipairs(previousSelections) do
						if (table.find(List.Options, prevSelection) and #chosenValue < List.Max) then
							table.insert(chosenValue, prevSelection)
							if (List.OptionInsts[prevSelection]) then
								setOptionSelectedLook(List.OptionInsts[prevSelection], true)
							end
							hasValidPreviousSelection = true
						end
					end
				else
					-- Single selection: use the first valid previous selection
					for _, prevSelection in ipairs(previousSelections) do
						if (table.find(List.Options, prevSelection)) then
							chosenValue = prevSelection
							if (List.OptionInsts[chosenValue]) then
								setOptionSelectedLook(List.OptionInsts[chosenValue], true)
							end
							hasValidPreviousSelection = true
							break
						end
					end
				end
			end

			-- Only apply defaults if no previous selections were restored
			if (not hasValidPreviousSelection) then
				if (List.Default) then
					if (List.Max) then
						chosenValue = {}
						local defaultsToApply = type(List.Default) == "table" and List.Default or { List.Default }
						for _, defOpt in ipairs(defaultsToApply) do
							if (table.find(List.Options, defOpt) and #chosenValue < List.Max) then
								table.insert(chosenValue, defOpt)
								if (List.OptionInsts[defOpt]) then
									setOptionSelectedLook(List.OptionInsts[defOpt], true)
								end
							end
						end
					else
						if (table.find(List.Options, List.Default)) then
							chosenValue = List.Default
							if (List.OptionInsts[chosenValue]) then
								setOptionSelectedLook(List.OptionInsts[chosenValue], true)
							end
						else
							chosenValue = #List.Options > 0 and List.Options[1] or nil
							if (chosenValue and List.OptionInsts[chosenValue]) then
								setOptionSelectedLook(List.OptionInsts[chosenValue], true)
							end
						end
					end
				elseif (#List.Options > 0 and not List.Max) then
					chosenValue = List.Options[1]
					if (List.OptionInsts[chosenValue]) then
						setOptionSelectedLook(List.OptionInsts[chosenValue], true)
					end
				end
			end

			Library.SetFlag(List.Flag, chosenValue)
		end

		function List.Set(self, value)
			local validValue = false
			if (List.Max) then
				local tempChosen = {}
				local valuesToSet = type(value) == "table" and value or { value }
				for _, valOpt in ipairs(valuesToSet) do
					if (List.OptionInsts[valOpt] and #tempChosen < List.Max) then
						table.insert(tempChosen, valOpt)
					end
				end
				if (#tempChosen > 0) then
					for _, optName in ipairs(chosenValue) do
						if (List.OptionInsts[optName]) then
							setOptionSelectedLook(List.OptionInsts[optName], false)
						end
					end
					chosenValue = tempChosen

					for _, optName in ipairs(chosenValue) do
						if (List.OptionInsts[optName]) then
							setOptionSelectedLook(List.OptionInsts[optName], true)
						end
					end
					validValue = true
				end
			else
				if (List.OptionInsts[value]) then
					if (chosenValue and List.OptionInsts[chosenValue]) then
						setOptionSelectedLook(List.OptionInsts[chosenValue], false)
					end
					chosenValue = value
					setOptionSelectedLook(List.OptionInsts[chosenValue], true)
					validValue = true
				end
			end

			if (validValue) then
				Library.SetFlag(List.Flag, chosenValue)
			end
		end

		function List.GetValue(self)
			return chosenValue
		end
		
		function List.SetVisible(self, visible)
			listFrame.Visible = visible
		end
        
		List:Refresh(List.Options)
		Library.Elements[List.Flag] = List
		Library.Callbacks[List.Flag] = List.Callback
		
		-- Check dependencies on creation
		if List.Depends then
			Library.UpdateElementVisibility(List)
		end

		return List
	end

	function Sections.Button(self, Properties)
        if (not Properties) then
            Properties = {}
        end

        local Button = {
            Window = self.Window,
            Section = self,
            Name = Properties.Name or "Button",
            Callback = Properties.Callback or function() end,
            Flag = Properties.Flag or Library.NextFlag(),
            IsButton = true,
            Depends = Properties.Depends,
        }

        local tabButton = Instance.new("TextButton", Button.Section.Elements.SectionContent)
        Button.Elements = { ButtonFrame = tabButton }
        tabButton.Name = "tab button"
        tabButton.FontFace = Font.new("rbxassetid://12187361378")		
		tabButton.Text = ""
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.TextSize = Library.GetScaledTextSize(22)
        tabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        tabButton.BackgroundTransparency = 1
        tabButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        tabButton.BorderSizePixel = 0
        tabButton.Size = Library.UDim2(1, 0, 0, 21)

        local thebuttonwow = Instance.new("TextButton")		
		thebuttonwow.Name = "thebuttonwow"
        thebuttonwow.FontFace = Font.new("rbxassetid://12187365364")		
		thebuttonwow.Text = Button.Name
        thebuttonwow.TextColor3 = Color3.fromRGB(115, 115, 115)
        thebuttonwow.TextSize = Library.GetScaledTextSize(12)
        thebuttonwow.Active = false
        thebuttonwow.AnchorPoint = Vector2.new(0.5, 0)
        thebuttonwow.BackgroundColor3 = Color3.fromRGB(35, 35, 33)
        thebuttonwow.BackgroundTransparency = 1
        thebuttonwow.BorderColor3 = Color3.fromRGB(0, 0, 0)
        thebuttonwow.BorderSizePixel = 0
        thebuttonwow.Position = UDim2.fromScale(0.5, 0)
        thebuttonwow.Selectable = false
        thebuttonwow.Size = Library.UDim2(1, -14, 1, 0)
        thebuttonwow.Parent = tabButton

        local cHILD = Instance.new("UICorner")		
		cHILD.Name = "_CHILD"
        cHILD.CornerRadius = UDim.new(0, 6)
        cHILD.Parent = thebuttonwow

        local uIStroke = Instance.new("UIStroke")		
		uIStroke.Name = "UIStroke"
        uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        uIStroke.Color = Color3.fromRGB(45, 45, 45)
        uIStroke.Transparency = 0.6
        uIStroke.Parent = thebuttonwow

        function Button.Click(self)
            self.Callback()
        end

        thebuttonwow.MouseEnter:Connect(function()
            local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			if (not Library.DropdownActive) then
				TweenService:Create(thebuttonwow, hoverTween, {
					TextColor3 = Color3.fromRGB(255, 255, 255),
				}):Play()
			end
        end)

        thebuttonwow.MouseLeave:Connect(function()
            local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(thebuttonwow, hoverTween, {
                TextColor3 = Color3.fromRGB(115, 115, 115),
            }):Play()
        end)

        thebuttonwow.MouseButton1Click:Connect(function()
            -- Check if the section or element is disabled
            if Button.Section.Disabled or Button.Disabled then
                return
            end
            local clickTween = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(thebuttonwow, clickTween, {
                BackgroundTransparency = 0,
            }):Play()

            task.wait(0.15)

            local returnTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            TweenService:Create(thebuttonwow, returnTween, {
                BackgroundTransparency = 1,
            }):Play()

            Button:Click()
        end)
        
        function Button.SetVisible(self, visible)
            tabButton.Visible = visible
        end

        Library.Elements[Button.Flag] = Button
        
        -- Check dependencies on creation
        if Button.Depends then
            Library.UpdateElementVisibility(Button)
        end
        
        return Button
    end

	function Sections.Textbox(self, Properties)
		if (not Properties) then
			Properties = {}
		end

		local Textbox = {
			Window = self.Window,
			Section = self,
			Name = Properties.Name or "Textbox",
			Default = Properties.Default or "",
			PlaceholderText = Properties.PlaceholderText or Properties.Placeholder or "",
			Flag = Properties.Flag or Library.NextFlag(),
			Callback = Properties.Callback or function() end,
			Value = "",
			Depends = Properties.Depends,
		}
		Textbox.Value = Textbox.Default

		local textox = Instance.new("Frame", Textbox.Section.Elements.SectionContent)
		Textbox.Elements = { TextboxFrame = textox }
		textox.Name = "Textox"
		textox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		textox.BackgroundTransparency = 1
		textox.BorderColor3 = Color3.fromRGB(0, 0, 0)
		textox.BorderSizePixel = 0
		textox.Size = Library.UDim2(1, 0, 0, 25)

		local textboxname = Instance.new("TextLabel")		
		textboxname.Name = "Textboxname"
		textboxname.FontFace = Font.new("rbxassetid://12187365364")		
		textboxname.Text = Textbox.Name
		textboxname.TextColor3 = Color3.fromRGB(115, 115, 115)
		textboxname.TextSize = Library.GetScaledTextSize(12)
		textboxname.TextXAlignment = Enum.TextXAlignment.Left
		textboxname.AnchorPoint = Vector2.new(0, 0.5)
		textboxname.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		textboxname.BackgroundTransparency = 1
		textboxname.BorderColor3 = Color3.fromRGB(0, 0, 0)
		textboxname.BorderSizePixel = 0
		textboxname.Position = UDim2.new(0, 8, 0.5, 0)
		textboxname.Size = Library.UDim2(1, -12, 0, 15)
		textboxname.Parent = textox

		local textboxcurrentframe = Instance.new("Frame")		
		textboxcurrentframe.Name = "Textboxcurrentframe"
		textboxcurrentframe.AnchorPoint = Vector2.new(1, 0.5)
		textboxcurrentframe.AutomaticSize = Enum.AutomaticSize.X
		textboxcurrentframe.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		textboxcurrentframe.BackgroundTransparency = 1
		textboxcurrentframe.BorderColor3 = Color3.fromRGB(0, 0, 0)
		textboxcurrentframe.BorderSizePixel = 0
		textboxcurrentframe.Position = UDim2.new(1, -7, 0.5, 0)
		textboxcurrentframe.Size = UDim2.fromOffset(0, 21)
		textboxcurrentframe.Parent = textox

		local uICorner = Instance.new("UICorner")		
		uICorner.Name = "UICorner"
		uICorner.CornerRadius = UDim.new(0, 4)
		uICorner.Parent = textboxcurrentframe

		local uIStroke = Instance.new("UIStroke")		
		uIStroke.Name = "UIStroke"
		uIStroke.Color = Color3.fromRGB(45, 45, 45)
		uIStroke.Transparency = 0.6
		uIStroke.Parent = textboxcurrentframe

		local frame = Instance.new("Frame")		
		frame.Name = "Frame"
		frame.AutomaticSize = Enum.AutomaticSize.X
		frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		frame.BackgroundTransparency = 1
		frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		frame.BorderSizePixel = 0
		frame.Size = UDim2.fromScale(0, 1)
		frame.Parent = textboxcurrentframe

		local uIListLayout = Instance.new("UIListLayout")		
		uIListLayout.Name = "UIListLayout"
		uIListLayout.Padding = UDim.new(0, 8)
		uIListLayout.FillDirection = Enum.FillDirection.Horizontal
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.Parent = frame

		local uIPadding = Instance.new("UIPadding")		
		uIPadding.Name = "UIPadding"
		uIPadding.PaddingLeft = UDim.new(0, 5)
		uIPadding.PaddingRight = UDim.new(0, 5)
		uIPadding.PaddingTop = UDim.new(0, 1)
		uIPadding.Parent = frame

		local left = Instance.new("Frame")		
        left.Name = "Left"
		left.AutomaticSize = Enum.AutomaticSize.X
		left.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		left.BackgroundTransparency = 1
		left.BorderColor3 = Color3.fromRGB(0, 0, 0)
		left.BorderSizePixel = 0
		left.Size = UDim2.fromScale(0, 1)
		left.Parent = frame

		local textboxValue = Instance.new("TextBox")		
		textboxValue.Name = "TextboxValue"
		textboxValue.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
		textboxValue.PlaceholderColor3 = Color3.fromRGB(115, 115, 115)
		textboxValue.PlaceholderText = Textbox.PlaceholderText
		textboxValue.Text = Textbox.Default
		textboxValue.TextColor3 = Color3.fromRGB(115, 115, 115)
		textboxValue.TextSize = Library.GetScaledTextSize(12)
		textboxValue.TextWrapped = true
		textboxValue.AutomaticSize = Enum.AutomaticSize.X
		textboxValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		textboxValue.BackgroundTransparency = 1
		textboxValue.BorderColor3 = Color3.fromRGB(0, 0, 0)
		textboxValue.BorderSizePixel = 0
		textboxValue.Size = UDim2.fromScale(1, 1)
		textboxValue.Parent = left

		local right = Instance.new("Frame")		
		right.Name = "Right"
		right.AnchorPoint = Vector2.new(1, 0.5)
		right.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		right.BackgroundTransparency = 1
		right.BorderColor3 = Color3.fromRGB(0, 0, 0)
		right.BorderSizePixel = 0
		right.LayoutOrder = 1
		right.Position = UDim2.new(1, -5, 0.5, 0)
		right.Size = Library.UDim2(0, 20, 1, 0)
		right.Parent = frame

		local textboxicon = Instance.new("ImageLabel")		
		textboxicon.Name = "Textboxicon"
		textboxicon.Image = "rbxassetid://81955492858183"
		textboxicon.ImageColor3 = Color3.fromRGB(44, 44, 41)
		textboxicon.AnchorPoint = Vector2.new(0.5, 0.5)
		textboxicon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		textboxicon.BackgroundTransparency = 1
		textboxicon.BorderColor3 = Color3.fromRGB(0, 0, 0)
		textboxicon.BorderSizePixel = 0
		textboxicon.Position = UDim2.fromScale(0.5, 0.5)
		textboxicon.Size = UDim2.fromOffset(12, 12)
		textboxicon.ZIndex = 4
		textboxicon.Parent = right

		function Textbox.Set(self, value)
			self.Value = tostring(value)
			textboxValue.Text = self.Value
			Library.SetFlag(self.Flag, self.Value)
		end

		function Textbox.GetValue(self)
			return Textbox.Value
		end

		textboxValue.Focused:Connect(function()
			-- Check if the section or element is disabled
			if Textbox.Section.Disabled or Textbox.Disabled then
				textboxValue:ReleaseFocus()
				return
			end
			local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(uIStroke, tweenInfo, {
				Color = Color3.fromRGB(38, 38, 36),
				Transparency = 0,
			}):Play()
			TweenService:Create(textboxValue, tweenInfo, {
				TextColor3 = Color3.fromRGB(221, 221, 221),
			}):Play()
		end)

		textboxValue.FocusLost:Connect(function(enterPressed)
			-- Check if the section or element is disabled
			if Textbox.Section.Disabled or Textbox.Disabled then
				return
			end
			local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(uIStroke, tweenInfo, {
				Color = Color3.fromRGB(45, 45, 45),
				Transparency = 0.6,
			}):Play()
			TweenService:Create(textboxValue, tweenInfo, {
				TextColor3 = Color3.fromRGB(115, 115, 115),
			}):Play()

			Textbox.Value = textboxValue.Text
			Library.SetFlag(Textbox.Flag, Textbox.Value)
		end)

		textox.MouseEnter:Connect(function()
			local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			if (not Library.DropdownActive) then 
				TweenService:Create(textboxname, hoverTween, {
					TextColor3 = Color3.fromRGB(255, 255, 255),
				}):Play()
			end
		end)

		textox.MouseLeave:Connect(function()
			local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(textboxname, hoverTween, {
				TextColor3 = Color3.fromRGB(115, 115, 115),
			}):Play()
		end)

        Library.SetFlag(Textbox.Flag, Textbox.Value)
		Library.Callbacks[Textbox.Flag] = Textbox.Callback
		Library.Elements[Textbox.Flag] = Textbox
		
		function Textbox.SetVisible(self, visible)
			textox.Visible = visible
		end
		
		-- Check dependencies on creation
		if Textbox.Depends then
			Library.UpdateElementVisibility(Textbox)
		end

		return Textbox
	end

	function Sections.Separator(self, Properties)
		if (not Properties) then
			Properties = {}
		end

		local Separator = {
			Window = self.Window,
			Section = self,
			Name = Properties.Name or "",
			Margin = Properties.Margin or 8,
			Depends = Properties.Depends,
		}

		local separatorFrame = Instance.new("Frame", Separator.Section.Elements.SectionContent)
		separatorFrame.Name = "Separator"
		separatorFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		separatorFrame.BackgroundTransparency = 1
		separatorFrame.BorderSizePixel = 0
		separatorFrame.Size = Library.UDim2(1, 0, 0, 1 + (Separator.Margin * 2))

		local separatorLine = Instance.new("Frame")
		separatorLine.Name = "SeparatorLine"
		separatorLine.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		separatorLine.BackgroundTransparency = 0.5
		separatorLine.BorderColor3 = Color3.fromRGB(0, 0, 0)
		separatorLine.BorderSizePixel = 0
		separatorLine.AnchorPoint = Vector2.new(0.5, 0.5)
		separatorLine.Position = UDim2.fromScale(0.5, 0.5)
		separatorLine.Size = Library.UDim2(1, -(Separator.Margin * 3), 0, 1)
		separatorLine.ZIndex = 1000
		separatorLine.Parent = separatorFrame

		-- Optional label for named separators
		if (Separator.Name and Separator.Name ~= "") then
			separatorFrame.Size = Library.UDim2(1, 0, 0, 20 + (Separator.Margin * 2))
			
			local separatorLabel = Instance.new("TextLabel")
			separatorLabel.Name = "SeparatorLabel"
			separatorLabel.FontFace = Font.new("rbxassetid://12187365364")
			separatorLabel.Text = Separator.Name
			separatorLabel.TextColor3 = Color3.fromRGB(115, 115, 115)
			separatorLabel.TextSize = Library.GetScaledTextSize(11)
			separatorLabel.TextXAlignment = Enum.TextXAlignment.Center
			separatorLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			separatorLabel.BackgroundTransparency = 1
			separatorLabel.BorderSizePixel = 0
			separatorLabel.Position = UDim2.new(0, Separator.Margin, 0, Separator.Margin)
			separatorLabel.Size = Library.UDim2(1, -(Separator.Margin * 2), 0, 12)
			separatorLabel.Parent = separatorFrame

			-- Adjust line position to be below text
			separatorLine.Position = UDim2.new(0.5, 0, 0, Separator.Margin + 14)
			separatorLine.AnchorPoint = Vector2.new(0.5, 0)
		end

		-- Add SetVisible method for dependency handling
		function Separator:SetVisible(visible)
			separatorFrame.Visible = visible
		end

		-- Register for dependency updates if dependencies exist
		if Separator.Depends then
			Library.Elements[Library.NextFlag()] = Separator
			Library.UpdateElementVisibility(Separator)
		end

		return Separator
	end

	function Sections.Keybind(self, Properties)
		if (not Properties) then
			Properties = {}
		end

		local Keybind = {
			Window = self.Window,
			Section = self,
			Name = Properties.Name or "Keybind",
			Key = Properties.Key or Properties.Default or Enum.KeyCode.E,
			Mode = Properties.Mode or "Toggle",
			Flag = Properties.Flag or Library.NextFlag(),
			Callback = Properties.Callback or function() end,
			Binding = false,
			State = false,
			Depends = Properties.Depends,
		}

		local keybindframE = Instance.new("TextButton", Keybind.Section.Elements.SectionContent)
		keybindframE.Name = "keybindfram e"
		keybindframE.Text = ""
		keybindframE.Active = false
		keybindframE.AutoButtonColor = false
		keybindframE.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		keybindframE.BackgroundTransparency = 1
		keybindframE.BorderColor3 = Color3.fromRGB(0, 0, 0)
		keybindframE.BorderSizePixel = 0
		keybindframE.Selectable = false
		keybindframE.Size = Library.UDim2(1, 0, 0, 25)

		local textboxname = Instance.new("TextLabel")		
		textboxname.Name = "Textboxname"
		textboxname.FontFace = Font.new("rbxassetid://12187365364")		
		textboxname.Text = Keybind.Name
		textboxname.TextColor3 = Color3.fromRGB(115, 115, 115)
		textboxname.TextSize = Library.GetScaledTextSize(12)
		textboxname.TextXAlignment = Enum.TextXAlignment.Left
		textboxname.AnchorPoint = Vector2.new(0, 0.5)
		textboxname.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		textboxname.BackgroundTransparency = 1
		textboxname.BorderColor3 = Color3.fromRGB(0, 0, 0)
		textboxname.BorderSizePixel = 0
		textboxname.Position = UDim2.new(0, 8, 0.5, 0)
		textboxname.Size = Library.UDim2(1, -12, 0, 15)
		textboxname.Parent = keybindframE

		local keybindcurrentframe = Instance.new("Frame")		
		keybindcurrentframe.Name = "Keybindcurrentframe"
		keybindcurrentframe.AnchorPoint = Vector2.new(1, 0.5)
		keybindcurrentframe.AutomaticSize = Enum.AutomaticSize.X
		keybindcurrentframe.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		keybindcurrentframe.BackgroundTransparency = 1
		keybindcurrentframe.BorderColor3 = Color3.fromRGB(0, 0, 0)
		keybindcurrentframe.BorderSizePixel = 0
		keybindcurrentframe.Position = UDim2.new(1, -7, 0.5, 0)
		keybindcurrentframe.Size = UDim2.fromOffset(0, 21)
		keybindcurrentframe.Parent = keybindframE

		local uICorner = Instance.new("UICorner")		
		uICorner.Name = "UICorner"
		uICorner.CornerRadius = UDim.new(0, 4)
		uICorner.Parent = keybindcurrentframe

		local uIStroke = Instance.new("UIStroke")		
		uIStroke.Name = "UIStroke"
		uIStroke.Color = Color3.fromRGB(45, 45, 45)
		uIStroke.Transparency = 0.6
		uIStroke.Parent = keybindcurrentframe

		local frame = Instance.new("Frame")		
		frame.Name = "Frame"
		frame.AutomaticSize = Enum.AutomaticSize.X
		frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		frame.BackgroundTransparency = 1
		frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		frame.BorderSizePixel = 0
		frame.Size = UDim2.fromScale(0, 1)
		frame.Parent = keybindcurrentframe

		local uIListLayout = Instance.new("UIListLayout")		
		uIListLayout.Name = "UIListLayout"
		uIListLayout.Padding = UDim.new(0, 3)
		uIListLayout.FillDirection = Enum.FillDirection.Horizontal
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.Parent = frame

		local uIPadding = Instance.new("UIPadding")		
		uIPadding.Name = "UIPadding"
		uIPadding.PaddingLeft = UDim.new(0, 5)
		uIPadding.PaddingRight = UDim.new(0, 8)
		uIPadding.PaddingTop = UDim.new(0, 1)
		uIPadding.Parent = frame

		local left = Instance.new("Frame")		
		left.Name = "Left"
		left.AutomaticSize = Enum.AutomaticSize.X
		left.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		left.BackgroundTransparency = 1
		left.BorderColor3 = Color3.fromRGB(0, 0, 0)
		left.BorderSizePixel = 0
		left.LayoutOrder = 1
		left.Size = UDim2.fromScale(0, 1)
		left.Parent = frame

		local keybindtexrt = Instance.new("TextLabel")		
		keybindtexrt.Name = "keybindtexrt"
		keybindtexrt.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
		keybindtexrt.Text = Library.Keys[Keybind.Key] or Keybind.Key.Name or "..."
		keybindtexrt.TextColor3 = Color3.fromRGB(115, 115, 115)
		keybindtexrt.TextSize = Library.GetScaledTextSize(12)
		keybindtexrt.TextWrapped = true
		keybindtexrt.Active = true
		keybindtexrt.AutomaticSize = Enum.AutomaticSize.X
		keybindtexrt.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		keybindtexrt.BackgroundTransparency = 1
		keybindtexrt.BorderColor3 = Color3.fromRGB(0, 0, 0)
		keybindtexrt.Selectable = true
		keybindtexrt.Size = UDim2.fromScale(1, 1)
		keybindtexrt.Parent = left

		local right = Instance.new("Frame")		
		right.Name = "Right"
		right.AnchorPoint = Vector2.new(1, 0.5)
		right.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		right.BackgroundTransparency = 1
		right.BorderColor3 = Color3.fromRGB(0, 0, 0)
		right.BorderSizePixel = 0
		right.Position = UDim2.new(1, -5, 0.5, 0)
		right.Size = Library.UDim2(0, 15, 1, 0)
		right.Parent = frame

		local keybindicon = Instance.new("ImageLabel")		
		keybindicon.Name = "keybindicon"
		keybindicon.Image = "rbxassetid://130326046703412"
		keybindicon.ImageColor3 = Color3.fromRGB(35, 35, 33)
		keybindicon.AnchorPoint = Vector2.new(0.5, 0.5)
		keybindicon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		keybindicon.BackgroundTransparency = 1
		keybindicon.BorderColor3 = Color3.fromRGB(0, 0, 0)
		keybindicon.BorderSizePixel = 0
		keybindicon.Position = UDim2.fromScale(0.5, 0.5)
		keybindicon.Size = UDim2.fromOffset(12, 12)
		keybindicon.ZIndex = 4
		keybindicon.Parent = right

		local holdConnection

		local function Set(newKey)
			if (newKey == Enum.KeyCode.Backspace or newKey == Enum.KeyCode.Escape) then
				Keybind.Key = nil
				keybindtexrt.Text = "..."
			else
				Keybind.Key = newKey
				keybindtexrt.Text = Library.Keys[newKey] or (newKey and newKey.Name) or "..."
			end
			Library.Flags[Keybind.Flag] = Keybind.Key
		end

		local function StartBinding()
			if (Keybind.Binding) then
				return
			end

			Keybind.Binding = true
			keybindtexrt.Text = "..."

			local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(textboxname, tweenInfo, {
				TextColor3 = Color3.fromRGB(255, 255, 255),
			}):Play()
			TweenService:Create(keybindtexrt, tweenInfo, {
				TextColor3 = Color3.fromRGB(255, 255, 255),
			}):Play()
			TweenService:Create(uIStroke, tweenInfo, {
				Color = Color3.fromRGB(38, 38, 36),
				Transparency = 0,
			}):Play()

			local connection
			connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if (gameProcessed) then
					return
				end

				local inputKey = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType
				Set(inputKey)

				TweenService:Create(textboxname, tweenInfo, {
					TextColor3 = Color3.fromRGB(115, 115, 115),
				}):Play()
				TweenService:Create(keybindtexrt, tweenInfo, {
					TextColor3 = Color3.fromRGB(115, 115, 115),
				}):Play()
				TweenService:Create(uIStroke, tweenInfo, {
					Color = Color3.fromRGB(45, 45, 45),
					Transparency = 0.6,
				}):Play()

				connection:Disconnect()
				Keybind.Binding = false
			end)
		end

		keybindframE.MouseButton1Click:Connect(StartBinding)

		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if (gameProcessed or Keybind.Binding or not Keybind.Key) then
				return
			end

			if (input.KeyCode == Keybind.Key or input.UserInputType == Keybind.Key) then
				if (Keybind.Mode == "Toggle") then
					Keybind.State = not Keybind.State
					Library.Flags[Keybind.Flag .. "_STATE"] = Keybind.State
					Keybind.Callback(Keybind.State)
				elseif (Keybind.Mode == "Button") then
					Library.Flags[Keybind.Flag .. "_STATE"] = true
					Keybind.Callback(true)
				elseif (Keybind.Mode == "Hold") then
					Keybind.State = true
					Library.Flags[Keybind.Flag .. "_STATE"] = true

					if (holdConnection) then
						holdConnection:Disconnect()
					end
					holdConnection = RunService.Heartbeat:Connect(function()
						Keybind.Callback(true)
					end)
				end
			end
		end)

		UserInputService.InputEnded:Connect(function(input, gameProcessed)
			if (gameProcessed or Keybind.Mode ~= "Hold" or not Keybind.Key) then
				return
			end

			if (input.KeyCode == Keybind.Key or input.UserInputType == Keybind.Key) then
				Keybind.State = false
				Library.Flags[Keybind.Flag .. "_STATE"] = false

				if (holdConnection) then
					holdConnection:Disconnect()
					holdConnection = nil
				end

				Keybind.Callback(false)
			end
		end)

		keybindframE.MouseEnter:Connect(function()
			if (not Keybind.Binding) then
				if (Library.DropdownActive) then 
					return 
				end 
				local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				TweenService:Create(textboxname, hoverTween, {
					TextColor3 = Color3.fromRGB(255, 255, 255),
				}):Play()
			end
		end)

		keybindframE.MouseLeave:Connect(function()
			if (not Keybind.Binding) then
				local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				TweenService:Create(textboxname, hoverTween, {
					TextColor3 = Color3.fromRGB(115, 115, 115),
				}):Play()
			end
		end)

		function Keybind.Set(self, newKey)
			Set(newKey)
		end

		function Keybind.GetKey(self)
			return Keybind.Key
		end

		function Keybind.GetState(self)
			return Keybind.State
		end

		Library.Flags[Keybind.Flag] = Keybind.Key
		Library.Flags[Keybind.Flag .. "_STATE"] = Keybind.State

		-- Add SetVisible method for dependency handling
		function Keybind:SetVisible(visible)
			keybindframE.Visible = visible
		end

		-- Register for dependency updates if dependencies exist
		if Keybind.Depends then
			Library.Elements[Keybind.Flag] = Keybind
			Library.UpdateElementVisibility(Keybind)
		end

		return Keybind
	end

	function Sections.ColorPicker(self, Properties)
		if (not Properties) then
			Properties = {}
		end

        local ColorPicker = {
            Window = self.Window,
            Section = self,
            Name = Properties.Name or "Color Picker",
            Default = Properties.Default or Color3.fromRGB(255, 0, 0),
            Flag = Properties.Flag or Library.NextFlag(),
            Zindex = Properties.ZIndex or 50,
            Callback = Properties.Callback or function() end,
            Value = Properties.Default or Color3.fromRGB(255, 0, 0),
            IsOpen = false,
            Depends = Properties.Depends,
        }

		ColorPicker.Value = ColorPicker.Default
		local colorpickerframe = Instance.new("TextButton", ColorPicker.Section.Elements.SectionContent)
		colorpickerframe.Name = "ColorPickerFrame"
		colorpickerframe.Text = ""
		colorpickerframe.Active = false
		colorpickerframe.AutoButtonColor = false
		colorpickerframe.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		colorpickerframe.BackgroundTransparency = 1
		colorpickerframe.BorderColor3 = Color3.fromRGB(0, 0, 0)
		colorpickerframe.BorderSizePixel = 0
		colorpickerframe.Selectable = false
		colorpickerframe.ZIndex = ColorPicker.Zindex
		colorpickerframe.Size = Library.UDim2(1, 0, 0, 25)

		local colorpickername = Instance.new("TextLabel")		
		colorpickername.Name = "ColorPickerName"
		colorpickername.FontFace = Font.new("rbxassetid://12187365364")		
		colorpickername.Text = ColorPicker.Name
		colorpickername.TextColor3 = Color3.fromRGB(115, 115, 115)
		colorpickername.TextSize = Library.GetScaledTextSize(12)
		colorpickername.TextXAlignment = Enum.TextXAlignment.Left
		colorpickername.AnchorPoint = Vector2.new(0, 0.5)
		colorpickername.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		colorpickername.BackgroundTransparency = 1
		colorpickername.BorderColor3 = Color3.fromRGB(0, 0, 0)
		colorpickername.BorderSizePixel = 0
		colorpickername.Position = UDim2.new(0, 8, 0.5, 0)
		colorpickername.Size = Library.UDim2(1, -12, 0, 15)
		colorpickername.Parent = colorpickerframe

		local box = Instance.new("TextButton")		
		box.Name = "Box"
		box.Text = ""
		box.AutoButtonColor = false
		box.AnchorPoint = Vector2.new(1, 0.5)
		box.BackgroundColor3 = ColorPicker.Default
		box.BorderColor3 = Color3.fromRGB(0, 0, 0)
		box.BorderSizePixel = 0
		box.Position = UDim2.new(1, -7, 0.5, 0)
		box.Size = UDim2.fromOffset(22, 21)
		box.Parent = colorpickerframe

		local uICorner = Instance.new("UICorner")		
		uICorner.Name = "UICorner"
		uICorner.CornerRadius = UDim.new(0, 4)
		uICorner.Parent = box

		local uIStroke = Instance.new("UIStroke")		
		uIStroke.Name = "UIStroke"
		uIStroke.Color = Color3.fromRGB(45, 45, 45)
		uIStroke.Transparency = 0.6
		uIStroke.Parent = box

		local theholderclolpirkcer = Instance.new("Frame")		
		theholderclolpirkcer.Name = "ColorPickerHolder"
		theholderclolpirkcer.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
		theholderclolpirkcer.BorderColor3 = Color3.fromRGB(0, 0, 0)
		theholderclolpirkcer.BorderSizePixel = 0
		theholderclolpirkcer.Position = UDim2.new(1, -185, 0, 30)
		theholderclolpirkcer.Size = UDim2.fromOffset(178, 125)
		theholderclolpirkcer.ZIndex = 50
		theholderclolpirkcer.Visible = false
		theholderclolpirkcer.Parent = colorpickerframe

		local holderUICorner = Instance.new("UICorner")		
		holderUICorner.Name = "UICorner"
		holderUICorner.CornerRadius = UDim.new(0, 6)
		holderUICorner.Parent = theholderclolpirkcer

		local holderUIStroke = Instance.new("UIStroke")		
		holderUIStroke.Name = "UIStroke"
		holderUIStroke.Color = Color3.fromRGB(45, 45, 45)
		holderUIStroke.Transparency = 0.4
		holderUIStroke.Parent = theholderclolpirkcer

		local uIListLayout = Instance.new("UIListLayout")		
		uIListLayout.Name = "UIListLayout"
		uIListLayout.Padding = UDim.new(0, 6)
		uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uIListLayout.Parent = theholderclolpirkcer

		local actualpalette = Instance.new("ImageButton")		
		actualpalette.Name = "Actualpalette"
		actualpalette.Image = "rbxassetid://4155801252"
		actualpalette.Active = true
		actualpalette.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		actualpalette.BorderColor3 = Color3.fromRGB(0, 0, 0)
		actualpalette.BorderSizePixel = 0
		actualpalette.Position = UDim2.fromOffset(10, 8)
		actualpalette.Selectable = true
		actualpalette.Size = UDim2.fromOffset(158, 95)
		actualpalette.Parent = theholderclolpirkcer

		local paletteUICorner = Instance.new("UICorner")		
		paletteUICorner.Name = "UICorner"
		paletteUICorner.CornerRadius = UDim.new(0, 4)
		paletteUICorner.Parent = actualpalette

		local select = Instance.new("ImageLabel")		
		select.Name = "Select"
		select.Image = "http://www.roblox.com/asset/?id=4805639000"
		select.ScaleType = Enum.ScaleType.Fit
		select.AnchorPoint = Vector2.new(0.5, 0.5)
		select.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		select.BackgroundTransparency = 1
		select.BorderColor3 = Color3.fromRGB(0, 0, 0)
		select.BorderSizePixel = 0
		select.Position = UDim2.new(1, -25, 0, 25)
		select.Size = UDim2.fromOffset(18, 18)
		select.Parent = actualpalette

		local colorSlider = Instance.new("ImageButton")		
		colorSlider.Name = "ColorSlider"
		colorSlider.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
		colorSlider.AnchorPoint = Vector2.new(1, 0)
		colorSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		colorSlider.BorderColor3 = Color3.fromRGB(27, 42, 53)
		colorSlider.ClipsDescendants = true
		colorSlider.Position = UDim2.fromOffset(168, 110)
		colorSlider.Size = UDim2.fromOffset(158, 7)
		colorSlider.Parent = theholderclolpirkcer

		local sliderUICorner = Instance.new("UICorner")		
		sliderUICorner.Name = "UICorner"
		sliderUICorner.CornerRadius = UDim.new(0, 6)
		sliderUICorner.Parent = colorSlider

		local uIGradient = Instance.new("UIGradient")		
		uIGradient.Name = "UIGradient"
		uIGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.0557, Color3.fromRGB(255, 85, 0)),
			ColorSequenceKeypoint.new(0.111, Color3.fromRGB(255, 170, 0)),
			ColorSequenceKeypoint.new(0.167, Color3.fromRGB(254, 255, 0)),
			ColorSequenceKeypoint.new(0.223, Color3.fromRGB(169, 255, 0)),
			ColorSequenceKeypoint.new(0.279, Color3.fromRGB(84, 255, 0)),
			ColorSequenceKeypoint.new(0.334, Color3.fromRGB(0, 255, 1)),
			ColorSequenceKeypoint.new(0.39, Color3.fromRGB(0, 255, 87)),
			ColorSequenceKeypoint.new(0.446, Color3.fromRGB(0, 255, 172)),
			ColorSequenceKeypoint.new(0.501, Color3.fromRGB(0, 253, 255)),
			ColorSequenceKeypoint.new(0.557, Color3.fromRGB(0, 168, 255)),
			ColorSequenceKeypoint.new(0.613, Color3.fromRGB(0, 82, 255)),
			ColorSequenceKeypoint.new(0.669, Color3.fromRGB(3, 0, 255)),
			ColorSequenceKeypoint.new(0.724, Color3.fromRGB(88, 0, 255)),
			ColorSequenceKeypoint.new(0.78, Color3.fromRGB(173, 0, 255)),
			ColorSequenceKeypoint.new(0.836, Color3.fromRGB(255, 0, 251)),
			ColorSequenceKeypoint.new(0.891, Color3.fromRGB(255, 0, 166)),
			ColorSequenceKeypoint.new(0.947, Color3.fromRGB(255, 0, 81)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
}
uIGradient.Parent = colorSlider
local sliderPoint = Instance.new("ImageButton")		
	sliderPoint.Name = "SliderPoint"
	sliderPoint.Image = "http://www.roblox.com/asset/?id=3259050989"
	sliderPoint.ImageColor3 = Color3.fromRGB(255, 255, 255)
	sliderPoint.AnchorPoint = Vector2.new(0.5, 0.5)
	sliderPoint.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sliderPoint.BackgroundTransparency = 1
	sliderPoint.BorderColor3 = Color3.fromRGB(27, 42, 53)
	sliderPoint.Position = UDim2.fromScale(0, 0.5)
	sliderPoint.Size = UDim2.fromOffset(12, 12)
	sliderPoint.Parent = colorSlider

	local currentHue = 0
	local currentSat = 1
	local currentVal = 1
	local draggingPalette = false
	local draggingSlider = false

	local function HSVtoRGB(h, s, v)
		local r, g, b
		local i = math.floor(h * 6)
		local f = h * 6 - i
		local p = v * (1 - s)
		local q = v * (1 - f * s)
		local t = v * (1 - (1 - f) * s)

		i = i % 6

		if (i == 0) then
			r, g, b = v, t, p
		elseif (i == 1) then
			r, g, b = q, v, p
		elseif (i == 2) then
			r, g, b = p, v, t
		elseif (i == 3) then
			r, g, b = p, q, v
		elseif (i == 4) then
			r, g, b = t, p, v
		elseif (i == 5) then
			r, g, b = v, p, q
		end

		return Color3.fromRGB(r * 255, g * 255, b * 255)
	end

	local function RGBtoHSV(color)
		local r, g, b = color.R, color.G, color.B
		local max = math.max(r, g, b)
		local min = math.min(r, g, b)
		local delta = max - min

		local h = 0
		if (delta > 0) then
			if (max == r) then
				h = (g - b) / delta
			elseif (max == g) then
				h = 2 + (b - r) / delta
			else
				h = 4 + (r - g) / delta
			end
			h = h / 6
			if (h < 0) then
				h = h + 1
			end
		end

		local s = max == 0 and 0 or delta / max
		local v = max

		return h, s, v
	end

	local function updateColor()
		local newColor = HSVtoRGB(currentHue, currentSat, currentVal)
		ColorPicker.Value = newColor
		box.BackgroundColor3 = newColor
		Library.Flags[ColorPicker.Flag] = newColor
		ColorPicker.Callback(newColor)
	end

	local function updatePalette()
		local hueColor = HSVtoRGB(currentHue, 1, 1)
		actualpalette.BackgroundColor3 = hueColor
	end

	actualpalette.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1) then
			draggingPalette = true
			local function updatePalettePosition(inputPos)
				local relativeX = math.clamp((inputPos.X - actualpalette.AbsolutePosition.X) / actualpalette.AbsoluteSize.X, 0, 1)
				local relativeY = math.clamp((inputPos.Y - actualpalette.AbsolutePosition.Y) / actualpalette.AbsoluteSize.Y, 0, 1)

				currentSat = relativeX
				currentVal = 1 - relativeY

				select.Position = UDim2.fromScale(relativeX, relativeY)
				updateColor()
			end

			updatePalettePosition(input.Position)
		end
	end)

	colorSlider.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1) then
			draggingSlider = true
			local function updateSliderPosition(inputPos)
				local relativeX = math.clamp((inputPos.X - colorSlider.AbsolutePosition.X) / colorSlider.AbsoluteSize.X, 0, 1)
				currentHue = relativeX

				sliderPoint.Position = UDim2.fromScale(relativeX, 0.5)
				updatePalette()
				updateColor()
			end

			updateSliderPosition(input.Position)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseMovement) then
			if (draggingPalette) then
				local relativeX = math.clamp((input.Position.X - actualpalette.AbsolutePosition.X) / actualpalette.AbsoluteSize.X, 0, 1)
				local relativeY = math.clamp((input.Position.Y - actualpalette.AbsolutePosition.Y) / actualpalette.AbsoluteSize.Y, 0, 1)

				currentSat = relativeX
				currentVal = 1 - relativeY

				select.Position = UDim2.fromScale(relativeX, relativeY)
				updateColor()
			elseif (draggingSlider) then
				local relativeX = math.clamp((input.Position.X - colorSlider.AbsolutePosition.X) / colorSlider.AbsoluteSize.X, 0, 1)
				currentHue = relativeX

				sliderPoint.Position = UDim2.fromScale(relativeX, 0.5)
				updatePalette()
				updateColor()
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1) then
			draggingPalette = false
			draggingSlider = false
		end
	end)

	local function toggleColorPicker()
		ColorPicker.IsOpen = not ColorPicker.IsOpen
		theholderclolpirkcer.Visible = ColorPicker.IsOpen

		local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		if (ColorPicker.IsOpen) then
			TweenService:Create(uIStroke, tweenInfo, {
				Color = Color3.fromRGB(38, 38, 36),
				Transparency = 0,
			}):Play()
		else
			TweenService:Create(uIStroke, tweenInfo, {
				Color = Color3.fromRGB(45, 45, 45),
				Transparency = 0.6,
			}):Play()
		end
	end

	box.MouseButton1Click:Connect(toggleColorPicker)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if (gameProcessed) then
			return
		end

		if (ColorPicker.IsOpen and input.UserInputType == Enum.UserInputType.MouseButton1) then
			if (not Library:IsMouseOverFrame(theholderclolpirkcer) and not Library:IsMouseOverFrame(box)) then
				toggleColorPicker()
			end
		end
	end)

	colorpickerframe.MouseEnter:Connect(function()
		if (Library.DropdownActive) then 
			return 
		end 
		local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(colorpickername, hoverTween, {
			TextColor3 = Color3.fromRGB(255, 255, 255),
		}):Play()
	end)

	colorpickerframe.MouseLeave:Connect(function()
		local hoverTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(colorpickername, hoverTween, {
			TextColor3 = Color3.fromRGB(115, 115, 115),
		}):Play()
	end)

    function ColorPicker.Set(self, color)
        self.Value = color
        box.BackgroundColor3 = color

        currentHue, currentSat, currentVal = RGBtoHSV(color)

        select.Position = UDim2.fromScale(currentSat, 1 - currentVal)
        sliderPoint.Position = UDim2.fromScale(currentHue, 0.5)

        updatePalette()
        updateColor()

        Library.Flags[self.Flag] = color
        self.Callback(color)
    end

    function ColorPicker.GetValue(self)
        return self.Value
    end

	-- Add SetVisible method for dependency handling
	function ColorPicker:SetVisible(visible)
		ColorPicker.Elements.colorpickerFrame.Visible = visible
	end

	-- Register for dependency updates if dependencies exist
	if ColorPicker.Depends then
		Library.Elements[ColorPicker.Flag] = ColorPicker
		Library.UpdateElementVisibility(ColorPicker)
	end

	ColorPicker.Set(ColorPicker, ColorPicker.Default)
	return ColorPicker
end

function Sections.Paragraph(self, Properties)
	if (not Properties) then
		Properties = {}
	end

	local Paragraph = {
		Window = self.Window,
		Section = self,
		Title = Properties.Title ~= nil and Properties.Title or (Properties.Name or ""),
		Description = Properties.Description or Properties.Content or "Description text goes here.",
		Position = Properties.Position or "Left", 
		Depends = Properties.Depends,
	}

	local paragraphFrame = Instance.new("Frame", Paragraph.Section.Elements.SectionContent)
	Paragraph.Elements = { ParagraphFrame = paragraphFrame }
	paragraphFrame.Name = "ParagraphFrame"
	paragraphFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	paragraphFrame.BackgroundTransparency = 1
	paragraphFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	paragraphFrame.BorderSizePixel = 0
	paragraphFrame.AutomaticSize = Enum.AutomaticSize.Y
	paragraphFrame.Size = Library.UDim2(1, 0, 0, 0)

	local contentHolder = Instance.new("Frame")		
	contentHolder.Name = "ContentHolder"
	contentHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	contentHolder.BackgroundTransparency = 1
	contentHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
	contentHolder.BorderSizePixel = 0
	contentHolder.AutomaticSize = Enum.AutomaticSize.Y
	contentHolder.Size = Library.UDim2(1, 0, 0, 0)
	contentHolder.Parent = paragraphFrame

	if (Paragraph.Position == "Right") then
		contentHolder.Position = UDim2.new(0, 0, 0, 0)
		contentHolder.Size = Library.UDim2(1, -7, 0, 0)
	elseif (Paragraph.Position == "Center") then
		contentHolder.AnchorPoint = Vector2.new(0.5, 0)
		contentHolder.Position = UDim2.new(0.5, 0, 0, 0)
		contentHolder.Size = Library.UDim2(1, -14, 0, 0)
	else 
		contentHolder.Position = UDim2.new(0, 8, 0, 0)
		contentHolder.Size = Library.UDim2(1, -16, 0, 0)
	end

	local uIListLayout = Instance.new("UIListLayout")		
	uIListLayout.Name = "UIListLayout"
	uIListLayout.Padding = UDim.new(0, Paragraph.Title ~= false and 4 or 0)
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Parent = contentHolder

	if (Paragraph.Position == "Center") then
		uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	elseif (Paragraph.Position == "Right") then
		uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	else
		uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	end

	-- Create title label only if title is not false
	local titleLabel = nil
	if Paragraph.Title ~= false then
		titleLabel = Instance.new("TextLabel")		
		titleLabel.Name = "TitleLabel"
		titleLabel.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
		titleLabel.Text = Paragraph.Title
		titleLabel.TextColor3 = Color3.fromRGB(221, 221, 221)
		titleLabel.TextSize = Library.GetScaledTextSize(14)
		titleLabel.TextWrapped = true
		titleLabel.AutomaticSize = Enum.AutomaticSize.Y
		titleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		titleLabel.BackgroundTransparency = 1
		titleLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		titleLabel.BorderSizePixel = 0
		titleLabel.Size = Library.UDim2(1, 0, 0, 0)
		titleLabel.LayoutOrder = 1
		titleLabel.Parent = contentHolder
	end

	-- Handle both old string format and new structured format
	local descriptionElements = {}
	
	if type(Paragraph.Description) == "table" then
		-- New structured format with icons
		local layoutOrder = Paragraph.Title ~= false and 2 or 1
		for key, item in pairs(Paragraph.Description) do
			if type(item) == "table" and item.Text then
				local itemFrame = Instance.new("Frame")
				itemFrame.Name = "ItemFrame_" .. key
				itemFrame.BackgroundTransparency = 1
				itemFrame.AutomaticSize = Enum.AutomaticSize.Y
				itemFrame.Size = Library.UDim2(1, -8, 0, 0)
				itemFrame.LayoutOrder = layoutOrder
				itemFrame.Parent = contentHolder
				
				-- Create icon if provided (positioned absolutely to not affect text layout)
				local iconLabel = nil
				if item.Icon then
					iconLabel = Instance.new("ImageLabel")
					iconLabel.Name = "Icon"
					iconLabel.Image = item.Icon
					iconLabel.ImageColor3 = Color3.fromRGB(115, 115, 115)
					iconLabel.ImageTransparency = 0.2
					iconLabel.BackgroundTransparency = 1
					iconLabel.Size = UDim2.fromOffset(10, 10)
					iconLabel.Position = UDim2.fromOffset(0, 0)
					iconLabel.AnchorPoint = Vector2.new(0, 0.5)
					iconLabel.Parent = itemFrame
				end
				
				-- Create text label (uses full width for proper alignment)
				local textLabel = Instance.new("TextLabel")
				textLabel.Name = "TextLabel"
				textLabel.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
				textLabel.Text = item.Text or ""
				textLabel.TextColor3 = Color3.fromRGB(115, 115, 115)
				textLabel.TextSize = Library.GetScaledTextSize(12)
				textLabel.TextWrapped = true
				textLabel.AutomaticSize = Enum.AutomaticSize.Y
				textLabel.BackgroundTransparency = 1
				textLabel.Size = Library.UDim2(1, item.Icon and -16 or 0, 0, 0)
				textLabel.Position = UDim2.fromOffset(item.Icon and 16 or 0, 0)
				textLabel.Parent = itemFrame
				
				-- Set text alignment based on position
				if (Paragraph.Position == "Center") then
					textLabel.TextXAlignment = Enum.TextXAlignment.Center
					if iconLabel then
						iconLabel.Position = UDim2.new(0.5, -8 - (textLabel.TextBounds.X / 2), 0.5, 0)
					end
				elseif (Paragraph.Position == "Right") then
					textLabel.TextXAlignment = Enum.TextXAlignment.Right
					if iconLabel then
						iconLabel.Position = UDim2.new(1, -textLabel.TextBounds.X - 16, 0.5, 0)
					end
				else
					textLabel.TextXAlignment = Enum.TextXAlignment.Left
					if iconLabel then
						iconLabel.Position = UDim2.fromOffset(0, 0)
						iconLabel.AnchorPoint = Vector2.new(0, 0.5)
					end
				end
				
				descriptionElements[key] = {
					frame = itemFrame,
					icon = iconLabel,
					text = textLabel,
					data = item
				}
				
				layoutOrder = layoutOrder + 1
			end
		end
	else
		-- Old string format
		local descriptionLabel = Instance.new("TextLabel")		
		descriptionLabel.Name = "DescriptionLabel"
		descriptionLabel.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		descriptionLabel.Text = Paragraph.Description
		descriptionLabel.TextColor3 = Color3.fromRGB(115, 115, 115)
		descriptionLabel.TextSize = Library.GetScaledTextSize(12)
		descriptionLabel.TextWrapped = true
		descriptionLabel.AutomaticSize = Enum.AutomaticSize.Y
		descriptionLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		descriptionLabel.BackgroundTransparency = 1
		descriptionLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		descriptionLabel.BorderSizePixel = 0
		descriptionLabel.Size = Library.UDim2(1, 0, 0, 0)
		descriptionLabel.LayoutOrder = Paragraph.Title ~= false and 2 or 1
		descriptionLabel.Parent = contentHolder
		
		-- Set text alignment based on position
		if (Paragraph.Position == "Center") then
			descriptionLabel.TextXAlignment = Enum.TextXAlignment.Center
		elseif (Paragraph.Position == "Right") then
			descriptionLabel.TextXAlignment = Enum.TextXAlignment.Right
		else 
			descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
		end
		
		descriptionElements.descriptionLabel = descriptionLabel
	end

	function Paragraph.SetTitle(self, newTitle)
		self.Title = newTitle
		if titleLabel then
			if newTitle == false then
				titleLabel.Visible = false
			else
				titleLabel.Visible = true
				titleLabel.Text = newTitle
			end
		end
		
		-- Update UIListLayout padding based on title visibility
		if uIListLayout then
			uIListLayout.Padding = UDim.new(0, newTitle ~= false and 4 or 0)
		end
	end

	function Paragraph.SetDescription(self, newDescription)
		self.Description = newDescription
		
		-- Clear existing description elements
		for key, element in pairs(descriptionElements) do
			if element.frame then
				element.frame:Destroy()
			elseif element.Destroy then
				element:Destroy()
			end
		end
		table.clear(descriptionElements)
		
		-- Recreate description based on new format
		if type(newDescription) == "table" then
			-- New structured format with icons
			local layoutOrder = self.Title ~= false and 2 or 1
			for key, item in pairs(newDescription) do
				if type(item) == "table" and item.Text then
					local itemFrame = Instance.new("Frame")
					itemFrame.Name = "ItemFrame_" .. key
					itemFrame.BackgroundTransparency = 1
					itemFrame.AutomaticSize = Enum.AutomaticSize.Y
					itemFrame.Size = Library.UDim2(1, -8, 0, 0)
					itemFrame.LayoutOrder = layoutOrder
					itemFrame.Parent = contentHolder
					
					-- Create icon if provided (positioned absolutely to not affect text layout)
					local iconLabel = nil
					if item.Icon then
						iconLabel = Instance.new("ImageLabel")
						iconLabel.Name = "Icon"
						iconLabel.Image = item.Icon
						iconLabel.ImageColor3 = Color3.fromRGB(115, 115, 115)
						iconLabel.ImageTransparency = 0.2
						iconLabel.BackgroundTransparency = 1
						iconLabel.Size = UDim2.fromOffset(10, 10)
						iconLabel.Position = UDim2.fromOffset(0, 0)
						iconLabel.AnchorPoint = Vector2.new(0, 0.5)
						iconLabel.Parent = itemFrame
					end
					
					-- Create text label (uses full width for proper alignment)
					local textLabel = Instance.new("TextLabel")
					textLabel.Name = "TextLabel"
					textLabel.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
					textLabel.Text = item.Text or ""
					textLabel.TextColor3 = Color3.fromRGB(115, 115, 115)
					textLabel.TextSize = Library.GetScaledTextSize(12)
					textLabel.TextWrapped = true
					textLabel.AutomaticSize = Enum.AutomaticSize.Y
					textLabel.BackgroundTransparency = 1
					textLabel.Size = Library.UDim2(1, item.Icon and -16 or 0, 0, 0)
					textLabel.Position = UDim2.fromOffset(item.Icon and 16 or 0, 0)
					textLabel.Parent = itemFrame
					
					-- Set text alignment based on position
					if (Paragraph.Position == "Center") then
						textLabel.TextXAlignment = Enum.TextXAlignment.Center
						if iconLabel then
							iconLabel.Position = UDim2.new(0.5, -8 - (textLabel.TextBounds.X / 2), 0.5, 0)
						end
					elseif (Paragraph.Position == "Right") then
						textLabel.TextXAlignment = Enum.TextXAlignment.Right
						if iconLabel then
							iconLabel.Position = UDim2.new(1, -textLabel.TextBounds.X - 16, 0.5, 0)
						end
					else
						textLabel.TextXAlignment = Enum.TextXAlignment.Left
						if iconLabel then
							iconLabel.Position = UDim2.fromOffset(0, 0)
							iconLabel.AnchorPoint = Vector2.new(0, 0.5)
						end
					end
					
					descriptionElements[key] = {
						frame = itemFrame,
						icon = iconLabel,
						text = textLabel,
						data = item
					}
					
					layoutOrder = layoutOrder + 1
				end
			end
		else
			-- Old string format
			local descriptionLabel = Instance.new("TextLabel")		
			descriptionLabel.Name = "DescriptionLabel"
			descriptionLabel.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
			descriptionLabel.Text = newDescription
			descriptionLabel.TextColor3 = Color3.fromRGB(115, 115, 115)
			descriptionLabel.TextSize = Library.GetScaledTextSize(12)
			descriptionLabel.TextWrapped = true
			descriptionLabel.AutomaticSize = Enum.AutomaticSize.Y
			descriptionLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			descriptionLabel.BackgroundTransparency = 1
			descriptionLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
			descriptionLabel.BorderSizePixel = 0
			descriptionLabel.Size = Library.UDim2(1, 0, 0, 0)
			descriptionLabel.LayoutOrder = self.Title ~= false and 2 or 1
			descriptionLabel.Parent = contentHolder
			
			-- Set text alignment based on position
			if (Paragraph.Position == "Center") then
				descriptionLabel.TextXAlignment = Enum.TextXAlignment.Center
			elseif (Paragraph.Position == "Right") then
				descriptionLabel.TextXAlignment = Enum.TextXAlignment.Right
			else 
				descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
			end
			
			descriptionElements.descriptionLabel = descriptionLabel
		end
	end

	function Paragraph.SetPosition(self, newPosition)
		self.Position = newPosition

		if (newPosition == "Right") then
			contentHolder.AnchorPoint = Vector2.new(0, 0)
			contentHolder.Position = UDim2.new(0, 0, 0, 0)
			contentHolder.Size = Library.UDim2(1, -7, 0, 0)
			uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
			if titleLabel then
				titleLabel.TextXAlignment = Enum.TextXAlignment.Right
			end
		elseif (newPosition == "Center") then
			contentHolder.AnchorPoint = Vector2.new(0.5, 0)
			contentHolder.Position = UDim2.new(0.5, 0, 0, 0)
			contentHolder.Size = Library.UDim2(1, -14, 0, 0)
			uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			if titleLabel then
				titleLabel.TextXAlignment = Enum.TextXAlignment.Center
			end
		else 
			contentHolder.AnchorPoint = Vector2.new(0, 0)
			contentHolder.Position = UDim2.new(0, 8, 0, 0)
			contentHolder.Size = Library.UDim2(1, -16, 0, 0)
			uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
			if titleLabel then
				titleLabel.TextXAlignment = Enum.TextXAlignment.Left
			end
		end
		
		-- Update description alignment based on format
		if type(self.Description) == "table" then
			-- Structured format - update each item's alignment
			for key, element in pairs(descriptionElements) do
				if element.frame and element.text then
					if (newPosition == "Center") then
						element.text.TextXAlignment = Enum.TextXAlignment.Center
						if element.icon then
							element.icon.Position = UDim2.new(0.5, -8 - (element.text.TextBounds.X / 2), 0.5, 0)
						end
					elseif (newPosition == "Right") then
						element.text.TextXAlignment = Enum.TextXAlignment.Right
						if element.icon then
							element.icon.Position = UDim2.new(1, -element.text.TextBounds.X - 16, 0.5, 0)
						end
					else
						element.text.TextXAlignment = Enum.TextXAlignment.Left
						if element.icon then
							element.icon.Position = UDim2.fromOffset(0, 0)
							element.icon.AnchorPoint = Vector2.new(0, 0.5)
						end
					end
				end
			end
		else
			-- Old string format - update single description label
			local descriptionLabel = descriptionElements.descriptionLabel
			if descriptionLabel then
				if (newPosition == "Center") then
					descriptionLabel.TextXAlignment = Enum.TextXAlignment.Center
				elseif (newPosition == "Right") then
					descriptionLabel.TextXAlignment = Enum.TextXAlignment.Right
				else 
					descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
				end
			end
		end
	end
	
	function Paragraph.SetVisible(self, visible)
		paragraphFrame.Visible = visible
	end
	
	-- Check dependencies on creation
	if Paragraph.Depends then
		Library.UpdateElementVisibility(Paragraph)
	end

	return Paragraph
end

function Sections.Image(self, Properties)
	if (not Properties) then
		Properties = {}
	end

	local Image = {
		Window = self.Window,
		Section = self,
		Name = Properties.Name or "Image",
		Image = Properties.Image and tostring(Properties.Image) or "rbxassetid://0",
		Width = Properties.Width or 100,
		Height = Properties.Height or 100,
		ImageColor3 = Properties.ImageColor3 or Color3.fromRGB(255, 255, 255),
		ImageTransparency = Properties.ImageTransparency or 0,
		BackgroundTransparency = Properties.BackgroundTransparency or 1,
		BackgroundColor3 = Properties.BackgroundColor3 or Color3.fromRGB(35, 35, 33),
		Position = Properties.Position or "Center", -- Left, Center, Right
		ScaleType = Properties.ScaleType or Enum.ScaleType.Stretch,
		Flag = Properties.Flag or Library.NextFlag(),
		Depends = Properties.Depends,
	}

	local imageFrame = Instance.new("Frame", Image.Section.Elements.SectionContent)
	Image.Elements = { ImageFrame = imageFrame }
	imageFrame.Name = "ImageFrame"
	imageFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	imageFrame.BackgroundTransparency = 1
	imageFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	imageFrame.BorderSizePixel = 0
	imageFrame.Size = Library.UDim2(1, 0, 0, Image.Height + 8)

	local contentHolder = Instance.new("Frame")
	contentHolder.Name = "ContentHolder"
	contentHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	contentHolder.BackgroundTransparency = 1
	contentHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
	contentHolder.BorderSizePixel = 0
	contentHolder.Size = Library.UDim2(1, 0, 1, 0)
	contentHolder.Parent = imageFrame

	-- Position content holder based on alignment
	if (Image.Position == "Left") then
		contentHolder.Position = UDim2.new(0, 8, 0, 4)
		contentHolder.Size = Library.UDim2(1, -16, 1, -8)
	elseif (Image.Position == "Right") then
		contentHolder.Position = UDim2.new(0, 0, 0, 4)
		contentHolder.Size = Library.UDim2(1, -8, 1, -8)
	else -- Center
		contentHolder.Position = UDim2.new(0, 0, 0, 4)
		contentHolder.Size = Library.UDim2(1, 0, 1, -8)
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "ImageLabel"
	imageLabel.Image = Image.Image
	imageLabel.ImageColor3 = Image.ImageColor3
	imageLabel.ImageTransparency = Image.ImageTransparency
	imageLabel.BackgroundColor3 = Image.BackgroundColor3
	imageLabel.BackgroundTransparency = Image.BackgroundTransparency
	imageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	imageLabel.BorderSizePixel = 0
	imageLabel.ScaleType = Image.ScaleType
	imageLabel.Size = UDim2.fromOffset(Image.Width, Image.Height)
	imageLabel.Parent = contentHolder

	-- Position image based on alignment
	if (Image.Position == "Left") then
		imageLabel.Position = UDim2.new(0, 0, 0, 0)
		imageLabel.AnchorPoint = Vector2.new(0, 0)
	elseif (Image.Position == "Right") then
		imageLabel.Position = UDim2.new(1, 0, 0, 0)
		imageLabel.AnchorPoint = Vector2.new(1, 0)
	else -- Center
		imageLabel.Position = UDim2.new(0.5, 0, 0, 0)
		imageLabel.AnchorPoint = Vector2.new(0.5, 0)
	end

	-- Add corner radius if background is visible
	if Image.BackgroundTransparency < 1 then
		local uICorner = Instance.new("UICorner")
		uICorner.Name = "UICorner"
		uICorner.CornerRadius = UDim.new(0, 6)
		uICorner.Parent = imageLabel
	end

	function Image.SetImage(self, newImage)
		self.Image = newImage and tostring(newImage) or "rbxassetid://0"
		imageLabel.Image = self.Image
	end

	function Image.SetSize(self, width, height)
		self.Width = width or self.Width
		self.Height = height or self.Height
		imageLabel.Size = UDim2.fromOffset(self.Width, self.Height)
		imageFrame.Size = Library.UDim2(1, 0, 0, self.Height + 8)
	end

	function Image.SetWidth(self, width)
		self:SetSize(width, nil)
	end

	function Image.SetHeight(self, height)
		self:SetSize(nil, height)
	end

	function Image.SetImageColor3(self, color)
		self.ImageColor3 = color
		imageLabel.ImageColor3 = color
	end

	function Image.SetImageTransparency(self, transparency)
		self.ImageTransparency = transparency
		imageLabel.ImageTransparency = transparency
	end

	function Image.SetBackgroundColor3(self, color)
		self.BackgroundColor3 = color
		imageLabel.BackgroundColor3 = color
	end

	function Image.SetBackgroundTransparency(self, transparency)
		self.BackgroundTransparency = transparency
		imageLabel.BackgroundTransparency = transparency
		
		-- Add or remove corner radius based on transparency
		local existingCorner = imageLabel:FindFirstChild("UICorner")
		if transparency < 1 and not existingCorner then
			local uICorner = Instance.new("UICorner")
			uICorner.Name = "UICorner"
			uICorner.CornerRadius = UDim.new(0, 6)
			uICorner.Parent = imageLabel
		elseif transparency >= 1 and existingCorner then
			existingCorner:Destroy()
		end
	end

	function Image.SetPosition(self, position)
		self.Position = position
		
		-- Update content holder positioning
		if (position == "Left") then
			contentHolder.Position = UDim2.new(0, 8, 0, 4)
			contentHolder.Size = Library.UDim2(1, -16, 1, -8)
			imageLabel.Position = UDim2.new(0, 0, 0, 0)
			imageLabel.AnchorPoint = Vector2.new(0, 0)
		elseif (position == "Right") then
			contentHolder.Position = UDim2.new(0, 0, 0, 4)
			contentHolder.Size = Library.UDim2(1, -8, 1, -8)
			imageLabel.Position = UDim2.new(1, 0, 0, 0)
			imageLabel.AnchorPoint = Vector2.new(1, 0)
		else -- Center
			contentHolder.Position = UDim2.new(0, 0, 0, 4)
			contentHolder.Size = Library.UDim2(1, 0, 1, -8)
			imageLabel.Position = UDim2.new(0.5, 0, 0, 0)
			imageLabel.AnchorPoint = Vector2.new(0.5, 0)
		end
	end

	function Image.SetScaleType(self, scaleType)
		self.ScaleType = scaleType
		imageLabel.ScaleType = scaleType
	end

	function Image.SetVisible(self, visible)
		imageFrame.Visible = visible
	end

	Library.Elements[Image.Flag] = Image
	
	-- Check dependencies on creation
	if Image.Depends then
		Library.UpdateElementVisibility(Image)
	end

	return Image
end

function Library.MobileButton(self)
	local menu = Instance.new("TextButton")		
	menu.Name = "Menu"
	menu.Text = ""
	menu.Active = false
	menu.AnchorPoint = Vector2.new(0.5, 0)
	menu.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
	menu.BackgroundTransparency = 0.07
	menu.BorderColor3 = Color3.fromRGB(0, 0, 0)
	menu.BorderSizePixel = 0
	menu.Position = UDim2.new(0.5, 0, 0, 20)
	menu.Selectable = false
	menu.Size = UDim2.fromOffset(40, 40)
	menu.Parent = Library.ScreenGUI

	local uICorner = Instance.new("UICorner")		
	uICorner.Name = "UICorner"
	uICorner.Parent = menu

	local uIStroke = Instance.new("UIStroke")		
	uIStroke.Name = "UIStroke"
	uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uIStroke.Color = Color3.fromRGB(45, 45, 45)
	uIStroke.Parent = menu

	local acrylicthing = Instance.new("ImageLabel")		
	acrylicthing.Name = "acrylicthing"
	acrylicthing.Image = "rbxassetid://9968344105"
	acrylicthing.ImageTransparency = 0.98
	acrylicthing.ScaleType = Enum.ScaleType.Tile
	acrylicthing.TileSize = UDim2.fromOffset(128, 128)
	acrylicthing.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	acrylicthing.BackgroundTransparency = 1
	acrylicthing.BorderColor3 = Color3.fromRGB(0, 0, 0)
	acrylicthing.BorderSizePixel = 0
	acrylicthing.Size = UDim2.fromScale(1, 1)

	local uICorner1 = Instance.new("UICorner")		
	uICorner1.Name = "UICorner"
	uICorner1.Parent = acrylicthing

	acrylicthing.Parent = menu

	local acrylicthing1 = Instance.new("ImageLabel")		
	acrylicthing1.Name = "acrylicthing"
	acrylicthing1.Image = "rbxassetid://9968344227"
	acrylicthing1.ImageTransparency = 0.95
	acrylicthing1.ScaleType = Enum.ScaleType.Tile
	acrylicthing1.TileSize = UDim2.fromOffset(128, 128)
	acrylicthing1.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	acrylicthing1.BackgroundTransparency = 1
	acrylicthing1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	acrylicthing1.BorderSizePixel = 0
	acrylicthing1.Size = UDim2.fromScale(1, 1)

	local uICorner2 = Instance.new("UICorner")		
	uICorner2.Name = "UICorner"
	uICorner2.Parent = acrylicthing1

	acrylicthing1.Parent = menu

	local uIPadding = Instance.new("UIPadding")		
	uIPadding.Name = "UIPadding"
	uIPadding.PaddingLeft = UDim.new(0, 12)
	uIPadding.PaddingRight = UDim.new(0, 12)
	uIPadding.Parent = menu

    local logo = Instance.new("ImageLabel")		
	logo.Name = "logo"
	logo.Image = "http://www.roblox.com/asset/?id=111169752816426"
	logo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	logo.BackgroundTransparency = 1
	logo.BorderColor3 = Color3.fromRGB(0, 0, 0)
	logo.BorderSizePixel = 0
	--logo.Position = UDim2.fromScale(0.5, 0.5)
	logo.Size = UDim2.fromScale(1, 1)
	logo.Parent = menu

	menu.MouseButton1Click:Connect(function()
		Library:SetOpen(not Library.Open)
	end)

	Library:MakeDraggable(menu, menu)

	return menu
end

return Window
end

	function Library.Notification(self, message, time, type)
		time = time or 3
		type = type or "info"
		local notifications = Library.ScreenGUI:FindFirstChild("NotificationHolder")
	if (not notifications) then
		notifications = Instance.new("Frame")
		notifications.Name = "NotificationHolder"
		notifications.BackgroundTransparency = 1
		notifications.AnchorPoint = Vector2.new(1, 0)
		notifications.Position = UDim2.new(1, -15, 0, 15)
		notifications.Size = Library.UDim2(0, 320, 1, -30)
		notifications.ZIndex = 100
		notifications.Parent = Library.ScreenGUI
		
		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 10)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		layout.VerticalAlignment = Enum.VerticalAlignment.Top
		layout.Parent = notifications
	end

	local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	local notifWidth = isMobile and math.min(320, workspace.CurrentCamera.ViewportSize.X * 0.9) or 320

	local notification = Instance.new("Frame")
	notification.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
	notification.BackgroundTransparency = 1
	notification.BorderSizePixel = 0
	notification.Size = Library.UDim2(0, notifWidth * 0.9, 0, 0)
	notification.AutomaticSize = Enum.AutomaticSize.Y
	notification.Position = UDim2.new(1, 100, 0, 0)
	notification.ZIndex = 101
	notification.LayoutOrder = tick()
	notification.Parent = notifications

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = notification

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(55, 55, 55)
	stroke.Transparency = 1
	stroke.Thickness = 1.5
	stroke.Parent = notification

	local shadow = Instance.new("Frame")
	shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shadow.BackgroundTransparency = 1
	shadow.BorderSizePixel = 0
	shadow.Position = UDim2.new(0, 2, 0, 2)
	shadow.Size = Library.UDim2(1, 0, 1, 0)
	shadow.ZIndex = 100
	shadow.Parent = notification

	local shadowCorner = Instance.new("UICorner")
	shadowCorner.CornerRadius = UDim.new(0, 12)
	shadowCorner.Parent = shadow

	local acrylic1 = Instance.new("ImageLabel")
	acrylic1.Image = "rbxassetid://9968344105"
	acrylic1.ImageTransparency = 1
	acrylic1.ScaleType = Enum.ScaleType.Tile
	acrylic1.TileSize = UDim2.fromOffset(128, 128)
	acrylic1.BackgroundTransparency = 1
	acrylic1.Size = UDim2.fromScale(1, 1)
	acrylic1.ZIndex = 102
	acrylic1.Parent = notification

	local acrylic1Corner = Instance.new("UICorner")
	acrylic1Corner.CornerRadius = UDim.new(0, 12)
	acrylic1Corner.Parent = acrylic1

	local acrylic2 = Instance.new("ImageLabel")
	acrylic2.Image = "rbxassetid://9968344227"
	acrylic2.ImageTransparency = 1
	acrylic2.ScaleType = Enum.ScaleType.Tile
	acrylic2.TileSize = UDim2.fromOffset(128, 128)
	acrylic2.BackgroundTransparency = 1
	acrylic2.Size = UDim2.fromScale(1, 1)
	acrylic2.ZIndex = 102
	acrylic2.Parent = notification

	local acrylic2Corner = Instance.new("UICorner")
	acrylic2Corner.CornerRadius = UDim.new(0, 12)
	acrylic2Corner.Parent = acrylic2

	local contentFrame = Instance.new("Frame")
	contentFrame.BackgroundTransparency = 1
	contentFrame.Size = Library.UDim2(1, 0, 0, 0)
	contentFrame.AutomaticSize = Enum.AutomaticSize.Y
	contentFrame.ZIndex = 103
	contentFrame.Parent = notification

	local contentLayout = Instance.new("UIListLayout")
	contentLayout.Padding = UDim.new(0, 8)
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	contentLayout.Parent = contentFrame

	local contentPadding = Instance.new("UIPadding")
	contentPadding.PaddingTop = UDim.new(0, 16)
	contentPadding.PaddingBottom = UDim.new(0, 16)
	contentPadding.PaddingLeft = UDim.new(0, 18)
	contentPadding.PaddingRight = UDim.new(0, 18)
	contentPadding.Parent = contentFrame

	local topRow = Instance.new("Frame")
	topRow.BackgroundTransparency = 1
	topRow.Size = Library.UDim2(1, 0, 0, 18)
	topRow.LayoutOrder = 1
	topRow.Parent = contentFrame

	local iconColors = {
		success = Color3.fromRGB(34, 197, 94),
		error = Color3.fromRGB(239, 68, 68),
		warning = Color3.fromRGB(245, 158, 11),
		info = Color3.fromRGB(59, 130, 246)
	}

	local typeColor = iconColors[type] or iconColors.info

	local statusDot = Instance.new("Frame")
	statusDot.BackgroundColor3 = typeColor
	statusDot.BackgroundTransparency = 1
	statusDot.BorderSizePixel = 0
	statusDot.Size = Library.UDim2(0, 8, 0, 8)
	statusDot.Position = UDim2.new(0, 0, 0.5, -4)
	statusDot.Parent = topRow

	local dotCorner = Instance.new("UICorner")
	dotCorner.CornerRadius = UDim.new(1, 0)
	dotCorner.Parent = statusDot

	local typeLabel = Instance.new("TextLabel")
	typeLabel.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	typeLabel.Text = string.upper(type)
	typeLabel.TextColor3 = typeColor
	typeLabel.TextSize = Library.GetScaledTextSize(10)
	typeLabel.TextXAlignment = Enum.TextXAlignment.Left
	typeLabel.BackgroundTransparency = 1
	typeLabel.TextTransparency = 1
	typeLabel.Position = UDim2.new(0, 16, 0, 0)
	typeLabel.Size = Library.UDim2(1, -40, 1, 0)
	typeLabel.Parent = topRow

	local timeLabel = Instance.new("TextLabel")
	timeLabel.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	timeLabel.Text = os.date("%H:%M")
	timeLabel.TextColor3 = Color3.fromRGB(115, 115, 115)
	timeLabel.TextSize = Library.GetScaledTextSize(9)
	timeLabel.TextXAlignment = Enum.TextXAlignment.Right
	timeLabel.BackgroundTransparency = 1
	timeLabel.TextTransparency = 1
	timeLabel.AnchorPoint = Vector2.new(1, 0)
	timeLabel.Position = UDim2.new(1, 0, 0, 0)
	timeLabel.Size = Library.UDim2(0, 40, 1, 0)
	timeLabel.Parent = topRow

	local messageLabel = Instance.new("TextLabel")
	messageLabel.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	messageLabel.Text = message
	messageLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
	messageLabel.TextSize = Library.GetScaledTextSize(12)
	messageLabel.TextWrapped = true
	messageLabel.TextXAlignment = Enum.TextXAlignment.Left
	messageLabel.TextYAlignment = Enum.TextYAlignment.Top
	messageLabel.BackgroundTransparency = 1
	messageLabel.TextTransparency = 1
	messageLabel.Size = Library.UDim2(1, 0, 0, 0)
	messageLabel.AutomaticSize = Enum.AutomaticSize.Y
	messageLabel.LayoutOrder = 2
	messageLabel.Parent = contentFrame
	spawn(function()
		local slideIn = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(0, notifWidth, 0, 0),
			BackgroundTransparency = 0.1
		})
		
		local fadeInStroke = TweenService:Create(stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 0.3
		})
		
		local fadeInShadow = TweenService:Create(shadow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.7
		})
		
		local fadeInAcrylic1 = TweenService:Create(acrylic1, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			ImageTransparency = 0.97
		})
		
		local fadeInAcrylic2 = TweenService:Create(acrylic2, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			ImageTransparency = 0.94
		})
		
		local fadeInDot = TweenService:Create(statusDot, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0
		})
		
		local fadeInType = TweenService:Create(typeLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 0
		})
		
		local fadeInTime = TweenService:Create(timeLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 0
		})
		
		local fadeInMessage = TweenService:Create(messageLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 0
		})
		
		slideIn:Play()
		fadeInStroke:Play()
		fadeInShadow:Play()
		fadeInAcrylic1:Play()
		fadeInAcrylic2:Play()
		fadeInDot:Play()
		fadeInType:Play()
		fadeInTime:Play()
		fadeInMessage:Play()
		
		task.wait(time - 0.5)
		
		local slideOut = TweenService:Create(notification, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(1, 50, 0, 0),
			BackgroundTransparency = 1
		})
		
		local fadeOut = TweenService:Create(stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Transparency = 1
		})
		
		slideOut:Play()
		fadeOut:Play()
		
		slideOut.Completed:Connect(function()
			notification:Destroy()
		end)
	end)
end

return Library
