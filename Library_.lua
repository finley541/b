local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

local Library = {}
Library.__index = Library

local Theme = {
	Accent = Color3.fromRGB(35, 220, 190),
	AccentAlt = Color3.fromRGB(120, 82, 255),
	AccentDark = Color3.fromRGB(20, 125, 118),

	Background = Color3.fromRGB(17, 22, 31),
	Surface = Color3.fromRGB(24, 31, 43),
	SurfaceSoft = Color3.fromRGB(30, 39, 54),
	Sidebar = Color3.fromRGB(18, 42, 43),
	Element = Color3.fromRGB(34, 44, 60),
	ElementHover = Color3.fromRGB(42, 54, 74),

	Text = Color3.fromRGB(244, 248, 252),
	Muted = Color3.fromRGB(150, 163, 177),
	Stroke = Color3.fromRGB(84, 107, 126),
	Danger = Color3.fromRGB(242, 90, 112),
}

local DEFAULT_TWEEN = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function create(className, props, children)
	local object = Instance.new(className)

	for property, value in pairs(props or {}) do
		object[property] = value
	end

	for _, child in ipairs(children or {}) do
		child.Parent = object
	end

	return object
end

local function tween(object, props, info)
	TweenService:Create(object, info or DEFAULT_TWEEN, props):Play()
end

local function corner(radius)
	return create("UICorner", {
		CornerRadius = UDim.new(0, radius or 8),
	})
end

local function stroke(color, transparency, thickness)
	return create("UIStroke", {
		Color = color or Theme.Stroke,
		Transparency = transparency or 0.62,
		Thickness = thickness or 1,
	})
end

local function padding(x, y)
	return create("UIPadding", {
		PaddingTop = UDim.new(0, y or x or 10),
		PaddingBottom = UDim.new(0, y or x or 10),
		PaddingLeft = UDim.new(0, x or 10),
		PaddingRight = UDim.new(0, x or 10),
	})
end

local function gradient(colorA, colorB, rotation)
	return create("UIGradient", {
		Color = ColorSequence.new(colorA, colorB),
		Rotation = rotation or 0,
	})
end

local function label(text, size, color, bold)
	return create("TextLabel", {
		BackgroundTransparency = 1,
		Text = tostring(text or ""),
		TextColor3 = color or Theme.Text,
		TextSize = size or 14,
		Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	})
end

local function safeCallback(callback, ...)
	if typeof(callback) == "function" then
		task.spawn(callback, ...)
	end
end

local function makeDraggable(frame, handle)
	local dragging = false
	local dragStart
	local startPosition

	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end

		dragging = true
		dragStart = input.Position
		startPosition = frame.Position
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end

		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end)
end

local function getParent(config)
	if config and config.Parent then
		return config.Parent
	end

	return CoreGui
end

local function normalizeToastPosition(position)
	local normalized = string.lower(tostring(position or "BottomRight")):gsub("[%s_-]", "")

	if normalized == "topleft" then
		return "TopLeft"
	elseif normalized == "topright" then
		return "TopRight"
	elseif normalized == "bottomleft" then
		return "BottomLeft"
	end

	return "BottomRight"
end

local function makeElementHolder(parent, height)
	return create("Frame", {
		Size = UDim2.new(1, 0, 0, height or 44),
		BackgroundColor3 = Theme.Element,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = parent,
	}, {
		corner(8),
		stroke(Theme.Stroke, 0.78),
	})
end

function Library:CreateWindow(config)
	config = config or {}

	local gui = create("ScreenGui", {
		Name = config.Name or "Lunex",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		DisplayOrder = config.DisplayOrder or 999999,
		Parent = getParent(config),
	})

	local root = create("Frame", {
		Name = "Root",
		Size = config.Size or UDim2.fromOffset(720, 430),
		Position = config.Position or UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.Background,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = gui,
	}, {
		corner(10),
		stroke(Color3.fromRGB(120, 148, 170), 0.58),
		gradient(Color3.fromRGB(21, 47, 51), Color3.fromRGB(27, 28, 63), 28),
	})

	local glow = create("Frame", {
		Name = "Glow",
		Size = UDim2.fromOffset(170, 170),
		Position = UDim2.new(1, -120, 0, -72),
		BackgroundColor3 = Theme.AccentAlt,
		BackgroundTransparency = 0.74,
		BorderSizePixel = 0,
		Parent = root,
	}, {
		corner(99),
		gradient(Theme.AccentAlt, Theme.Accent, 45),
	})

	local topbar = create("Frame", {
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = Color3.fromRGB(20, 27, 38),
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Parent = root,
	})

	local appTitle = label(config.Title or "Lunex", 13, Theme.Text, true)
	appTitle.Position = UDim2.fromOffset(16, 8)
	appTitle.Size = UDim2.new(1, -150, 0, 17)
	appTitle.Parent = topbar

	local appSub = label(config.Subtitle or "by " .. Player.Name, 11, Theme.Muted, false)
	appSub.Position = UDim2.fromOffset(16, 23)
	appSub.Size = UDim2.new(1, -150, 0, 14)
	appSub.Parent = topbar

	local minimize = create("TextButton", {
		Name = "Minimize",
		Size = UDim2.fromOffset(30, 26),
		Position = UDim2.new(1, -72, 0, 8),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "-",
		TextColor3 = Theme.Muted,
		TextSize = 18,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		Parent = topbar,
	})

	local close = create("TextButton", {
		Name = "Close",
		Size = UDim2.fromOffset(30, 26),
		Position = UDim2.new(1, -38, 0, 8),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "x",
		TextColor3 = Theme.Muted,
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false,
		Parent = topbar,
	})

	local sidebar = create("Frame", {
		Name = "Sidebar",
		Position = UDim2.fromOffset(0, 42),
		Size = UDim2.new(0, 148, 1, -42),
		BackgroundColor3 = Theme.Sidebar,
		BackgroundTransparency = 0.18,
		BorderSizePixel = 0,
		Parent = root,
	}, {
		gradient(Color3.fromRGB(19, 62, 58), Color3.fromRGB(21, 32, 46), 90),
	})

	local rail = create("Frame", {
		Name = "Rail",
		Position = UDim2.fromOffset(10, 12),
		Size = UDim2.new(1, -20, 1, -24),
		BackgroundTransparency = 1,
		Parent = sidebar,
	})

	local navLayout = create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = rail,
	})

	local content = create("Frame", {
		Name = "Content",
		Position = UDim2.fromOffset(148, 42),
		Size = UDim2.new(1, -148, 1, -42),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.16,
		BorderSizePixel = 0,
		Parent = root,
	})

	local header = create("Frame", {
		Name = "Header",
		Size = UDim2.new(1, 0, 0, 66),
		BackgroundTransparency = 1,
		Parent = content,
	})

	local pageTitle = label("Main", 22, Theme.Text, true)
	pageTitle.Position = UDim2.fromOffset(24, 13)
	pageTitle.Size = UDim2.new(1, -48, 0, 28)
	pageTitle.Parent = header

	local pageSubtitle = label("", 12, Theme.Muted, false)
	pageSubtitle.Position = UDim2.fromOffset(25, 39)
	pageSubtitle.Size = UDim2.new(1, -50, 0, 18)
	pageSubtitle.Parent = header

	local pages = create("Frame", {
		Name = "Pages",
		Position = UDim2.fromOffset(20, 66),
		Size = UDim2.new(1, -40, 1, -84),
		BackgroundTransparency = 1,
		Parent = content,
	})

	local toastLayer = create("Frame", {
		Name = "Toasts",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = gui,
	})

	local toastContainers = {}
	local toastCornerConfig = {
		TopLeft = {
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.fromOffset(16, 16),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
		},
		TopRight = {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -16, 0, 16),
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Top,
		},
		BottomLeft = {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 16, 1, -16),
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
		},
		BottomRight = {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -16, 1, -16),
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
		},
	}

	for positionName, positionConfig in pairs(toastCornerConfig) do
		local container = create("Frame", {
			Name = positionName,
			AnchorPoint = positionConfig.AnchorPoint,
			Position = positionConfig.Position,
			Size = UDim2.fromOffset(280, 420),
			BackgroundTransparency = 1,
			Parent = toastLayer,
		})

		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = positionConfig.HorizontalAlignment,
			VerticalAlignment = positionConfig.VerticalAlignment,
			Parent = container,
		})

		toastContainers[positionName] = container
	end

	makeDraggable(root, topbar)

	local window = {
		Gui = gui,
		Root = root,
		Topbar = topbar,
		Sidebar = sidebar,
		Pages = pages,
		Title = pageTitle,
		Subtitle = pageSubtitle,
		ToastPosition = normalizeToastPosition(config.ToastPosition),
		Tabs = {},
		SelectedTab = nil,
		Visible = true,
	}

	local function selectTab(tab)
		for _, other in ipairs(window.Tabs) do
			other.Page.Visible = false
			tween(other.Button, {
				BackgroundColor3 = Color3.fromRGB(24, 35, 45),
				BackgroundTransparency = 0.42,
			})
			tween(other.Label, {
				TextColor3 = Theme.Muted,
			})
			tween(other.Indicator, {
				Size = UDim2.fromOffset(4, 0),
				BackgroundTransparency = 1,
			})
		end

		tab.Page.Visible = true
		pageTitle.Text = tab.Name
		pageSubtitle.Text = tab.Description or ""
		window.SelectedTab = tab

		tween(tab.Button, {
			BackgroundColor3 = Color3.fromRGB(32, 66, 70),
			BackgroundTransparency = 0.12,
		})
		tween(tab.Label, {
			TextColor3 = Theme.Text,
		})
		tween(tab.Indicator, {
			Size = UDim2.fromOffset(4, 24),
			BackgroundTransparency = 0,
		})
	end

	local function createPage(name)
		local page = create("ScrollingFrame", {
			Name = name,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Theme.Accent,
			CanvasSize = UDim2.new(),
			Visible = false,
			Parent = pages,
		})

		padding(2, 2).Parent = page

		local layout = create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = page,
		})

		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			page.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 10)
		end)

		return page
	end

	local function createNavButton(tab)
		local button = create("TextButton", {
			Name = tab.Name .. "Button",
			Size = UDim2.new(1, 0, 0, 38),
			BackgroundColor3 = Color3.fromRGB(24, 35, 45),
			BackgroundTransparency = 0.42,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			Parent = rail,
		}, {
			corner(7),
		})

		local indicator = create("Frame", {
			Name = "Indicator",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 8, 0.5, 0),
			Size = UDim2.fromOffset(4, 0),
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = button,
		}, {
			corner(99),
		})

		local buttonLabel = label(tab.Icon and (tab.Icon .. "  " .. tab.Name) or tab.Name, 13, Theme.Muted, true)
		buttonLabel.Name = "Label"
		buttonLabel.Position = UDim2.fromOffset(22, 0)
		buttonLabel.Size = UDim2.new(1, -32, 1, 0)
		buttonLabel.Parent = button

		button.MouseEnter:Connect(function()
			if window.SelectedTab ~= tab then
				tween(button, {
					BackgroundTransparency = 0.25,
				})
				tween(buttonLabel, {
					TextColor3 = Theme.Text,
				})
			end
		end)

		button.MouseLeave:Connect(function()
			if window.SelectedTab ~= tab then
				tween(button, {
					BackgroundTransparency = 0.42,
				})
				tween(buttonLabel, {
					TextColor3 = Theme.Muted,
				})
			end
		end)

		button.MouseButton1Click:Connect(function()
			selectTab(tab)
		end)

		return button, indicator, buttonLabel
	end

	local function createCard(parent, options)
		options = options or {}

		local raw = options.Raw == true
		local contentY = options.ContentY or (raw and 0 or 62)
		local minHeight = options.MinHeight or 104
		local maxHeight = options.MaxHeight or 900
		local manualHeight = options.Height
		local bottomPadding = raw and 0 or 14
		local cardChildren = {}

		if not raw then
			table.insert(cardChildren, corner(9))
			table.insert(cardChildren, stroke(Theme.Stroke, 0.72))
		end

		local card = create("Frame", {
			Name = options.Title or "Card",
			Size = UDim2.new(1, 0, 0, manualHeight or minHeight),
			BackgroundColor3 = Theme.SurfaceSoft,
			BackgroundTransparency = raw and 1 or 0.08,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Parent = parent,
		}, cardChildren)

		local accentLine
		local cardTitle
		local description

		if not raw then
			accentLine = create("Frame", {
				Size = UDim2.new(1, -24, 0, 1),
				Position = UDim2.fromOffset(12, 0),
				BackgroundColor3 = Theme.Accent,
				BackgroundTransparency = 0.12,
				BorderSizePixel = 0,
				Parent = card,
			}, {
				gradient(Theme.Accent, Theme.AccentAlt, 0),
			})

			cardTitle = label(options.Title or "Card", 15, Theme.Text, true)
			cardTitle.Position = UDim2.fromOffset(16, 10)
			cardTitle.Size = UDim2.new(1, -32, 0, 22)
			cardTitle.Parent = card

			description = label(options.Description or "", 12, Theme.Muted, false)
			description.Position = UDim2.fromOffset(16, 32)
			description.Size = UDim2.new(1, -32, 0, 24)
			description.TextWrapped = true
			description.TextYAlignment = Enum.TextYAlignment.Top
			description.Parent = card
		end

		local container = create("ScrollingFrame", {
			Name = "Container",
			Position = raw and UDim2.fromOffset(0, contentY) or UDim2.fromOffset(14, contentY),
			Size = raw and UDim2.new(1, 0, 1, -contentY - bottomPadding) or UDim2.new(1, -28, 1, -contentY - bottomPadding),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Theme.Accent,
			CanvasSize = UDim2.new(),
			ClipsDescendants = true,
			Parent = card,
		})

		local containerLayout = create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = container,
		})

		local function updateCardHeight()
			local contentHeight = containerLayout.AbsoluteContentSize.Y
			local wantedHeight = contentY + contentHeight + bottomPadding
			local height = manualHeight or math.clamp(wantedHeight, minHeight, maxHeight)

			card.Size = UDim2.new(1, 0, 0, height)
			container.CanvasSize = UDim2.fromOffset(0, contentHeight)

			task.defer(function()
				container.ScrollBarThickness = contentHeight > container.AbsoluteSize.Y and 3 or 0
			end)
		end

		containerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCardHeight)
		task.defer(updateCardHeight)

		local cardObject = {
			Instance = card,
			Container = container,
			AccentLine = accentLine,
		}

		function cardObject:SetTitle(text)
			if cardTitle then
				cardTitle.Text = tostring(text or "")
			end
		end

		function cardObject:SetDescription(text)
			if description then
				description.Text = tostring(text or "")
			end
		end

		function cardObject:SetHeight(height)
			manualHeight = height
			updateCardHeight()
		end

		function cardObject:CreateParagraph(options)
			options = options or {}

			local holder = makeElementHolder(container, options.Height or 54)

			local title = label(options.Title or "Paragraph", 13, Theme.Text, true)
			title.Position = UDim2.fromOffset(12, 7)
			title.Size = UDim2.new(1, -24, 0, 18)
			title.Parent = holder

			local body = label(options.Text or "", 12, Theme.Muted, false)
			body.Position = UDim2.fromOffset(12, 25)
			body.Size = UDim2.new(1, -24, 0, (options.Height or 54) - 30)
			body.TextWrapped = true
			body.TextYAlignment = Enum.TextYAlignment.Top
			body.Parent = holder

			return holder
		end

		function cardObject:CreateButton(options)
			options = options or {}

			local button = create("TextButton", {
				Size = UDim2.new(1, 0, 0, options.Height or 38),
				BackgroundColor3 = Theme.Element,
				BackgroundTransparency = 0.04,
				BorderSizePixel = 0,
				Text = options.Name or "Button",
				TextColor3 = Theme.Text,
				TextSize = 13,
				Font = Enum.Font.GothamBold,
				AutoButtonColor = false,
				Parent = container,
			}, {
				corner(8),
				stroke(Theme.Stroke, 0.76),
			})

			button.MouseEnter:Connect(function()
				tween(button, { BackgroundColor3 = Theme.ElementHover })
			end)

			button.MouseLeave:Connect(function()
				tween(button, { BackgroundColor3 = Theme.Element })
			end)

			button.MouseButton1Click:Connect(function()
				safeCallback(options.Callback)
			end)

			return button
		end

		function cardObject:CreateToggle(options)
			options = options or {}

			local holder = makeElementHolder(container, 42)

			local text = label(options.Name or "Toggle", 13, Theme.Text, true)
			text.Position = UDim2.fromOffset(12, 0)
			text.Size = UDim2.new(1, -86, 1, 0)
			text.Parent = holder

			local switch = create("TextButton", {
				Size = UDim2.fromOffset(44, 22),
				Position = UDim2.new(1, -56, 0.5, -11),
				BackgroundColor3 = Color3.fromRGB(61, 70, 84),
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = false,
				Parent = holder,
			}, {
				corner(99),
				stroke(Theme.Stroke, 0.78),
			})

			local knob = create("Frame", {
				Size = UDim2.fromOffset(16, 16),
				Position = UDim2.fromOffset(3, 3),
				BackgroundColor3 = Theme.Text,
				BorderSizePixel = 0,
				Parent = switch,
			}, {
				corner(99),
			})

			local element = {
				Instance = holder,
				CurrentValue = options.CurrentValue and true or false,
			}

			local function render()
				tween(switch, {
					BackgroundColor3 = element.CurrentValue and Theme.AccentDark or Color3.fromRGB(61, 70, 84),
				})
				tween(knob, {
					Position = element.CurrentValue and UDim2.fromOffset(25, 3) or UDim2.fromOffset(3, 3),
					BackgroundColor3 = element.CurrentValue and Color3.fromRGB(235, 255, 250) or Theme.Text,
				})
			end

			function element:Set(value)
				self.CurrentValue = value and true or false
				render()
				safeCallback(options.Callback, self.CurrentValue)
			end

			switch.MouseButton1Click:Connect(function()
				element:Set(not element.CurrentValue)
			end)

			holder.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					element:Set(not element.CurrentValue)
				end
			end)

			render()
			return element
		end

		function cardObject:CreateSlider(options)
			options = options or {}

			local min = options.Range and options.Range[1] or 0
			local max = options.Range and options.Range[2] or 100
			local increment = options.Increment or 1

			local holder = makeElementHolder(container, 68)

			local text = label(options.Name or "Slider", 13, Theme.Text, true)
			text.Position = UDim2.fromOffset(12, 4)
			text.Size = UDim2.new(1, -140, 0, 26)
			text.Parent = holder

			local valueText = label("", 12, Theme.Muted, false)
			valueText.Position = UDim2.new(1, -130, 0, 4)
			valueText.Size = UDim2.fromOffset(118, 26)
			valueText.TextXAlignment = Enum.TextXAlignment.Right
			valueText.Parent = holder

			local bar = create("Frame", {
				Size = UDim2.new(1, -24, 0, 6),
				Position = UDim2.fromOffset(12, 46),
				BackgroundColor3 = Color3.fromRGB(62, 71, 86),
				BorderSizePixel = 0,
				Parent = holder,
			}, {
				corner(99),
			})

			local fill = create("Frame", {
				Size = UDim2.new(),
				BackgroundColor3 = Theme.Accent,
				BorderSizePixel = 0,
				Parent = bar,
			}, {
				corner(99),
				gradient(Theme.Accent, Theme.AccentAlt, 0),
			})

			local knob = create("Frame", {
				Size = UDim2.fromOffset(14, 14),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				BackgroundColor3 = Theme.Text,
				BorderSizePixel = 0,
				Parent = bar,
			}, {
				corner(99),
				stroke(Theme.Accent, 0.18),
			})

			local dragging = false
			local element = {
				Instance = holder,
				CurrentValue = options.CurrentValue or min,
			}

			local function snap(value)
				return math.clamp(math.floor((value / increment) + 0.5) * increment, min, max)
			end

			local function render()
				local alpha = 0
				if max ~= min then
					alpha = (element.CurrentValue - min) / (max - min)
				end

				fill.Size = UDim2.new(alpha, 0, 1, 0)
				knob.Position = UDim2.fromScale(alpha, 0.5)
				valueText.Text = tostring(element.CurrentValue) .. (options.Suffix and (" " .. options.Suffix) or "")
			end

			local function updateFromX(x)
				local alpha = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
				element:Set(snap(min + ((max - min) * alpha)))
			end

			function element:Set(value)
				self.CurrentValue = snap(tonumber(value) or min)
				render()
				safeCallback(options.Callback, self.CurrentValue)
			end

			bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					updateFromX(input.Position.X)
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					updateFromX(input.Position.X)
				end
			end)

			element:Set(element.CurrentValue)
			return element
		end

		function cardObject:CreateInput(options)
			options = options or {}

			local holder = makeElementHolder(container, 66)

			local text = label(options.Name or "Input", 13, Theme.Text, true)
			text.Position = UDim2.fromOffset(12, 4)
			text.Size = UDim2.new(1, -24, 0, 24)
			text.Parent = holder

			local box = create("TextBox", {
				Size = UDim2.new(1, -24, 0, 28),
				Position = UDim2.fromOffset(12, 31),
				BackgroundColor3 = Color3.fromRGB(18, 24, 34),
				BackgroundTransparency = 0.08,
				BorderSizePixel = 0,
				ClearTextOnFocus = false,
				Text = tostring(options.CurrentValue or ""),
				PlaceholderText = options.PlaceholderText or "Type here...",
				TextColor3 = Theme.Text,
				PlaceholderColor3 = Theme.Muted,
				TextSize = 12,
				Font = Enum.Font.Gotham,
				Parent = holder,
			}, {
				corner(7),
				stroke(Theme.Stroke, 0.8),
			})

			local element = {
				Instance = holder,
				CurrentValue = tostring(options.CurrentValue or ""),
			}

			function element:Set(value)
				self.CurrentValue = tostring(value or "")
				box.Text = self.CurrentValue
				safeCallback(options.Callback, self.CurrentValue)
			end

			box.Focused:Connect(function()
				tween(box, { BackgroundColor3 = Color3.fromRGB(24, 32, 45) })
			end)

			box.FocusLost:Connect(function()
				tween(box, { BackgroundColor3 = Color3.fromRGB(18, 24, 34) })
				element.CurrentValue = box.Text
				safeCallback(options.Callback, element.CurrentValue)

				if options.RemoveTextAfterFocusLost then
					box.Text = ""
				end
			end)

			return element
		end

		function cardObject:CreateDropdown(options)
			options = options or {}

			local optionList = options.Options or {}
			local multiple = options.MultipleOptions or false

			local holder = makeElementHolder(container, 44)
			holder.ClipsDescendants = true

			local top = create("TextButton", {
				Size = UDim2.new(1, 0, 0, 44),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				Parent = holder,
			})

			local text = label(options.Name or "Dropdown", 13, Theme.Text, true)
			text.Position = UDim2.fromOffset(12, 0)
			text.Size = UDim2.new(1, -190, 1, 0)
			text.Parent = top

			local selected = label("", 12, Theme.Muted, false)
			selected.Position = UDim2.new(1, -172, 0, 0)
			selected.Size = UDim2.fromOffset(136, 44)
			selected.TextXAlignment = Enum.TextXAlignment.Right
			selected.TextTruncate = Enum.TextTruncate.AtEnd
			selected.Parent = top

			local caret = label("v", 12, Theme.Muted, true)
			caret.Position = UDim2.new(1, -28, 0, 0)
			caret.Size = UDim2.fromOffset(18, 44)
			caret.TextXAlignment = Enum.TextXAlignment.Center
			caret.Parent = top

			local list = create("Frame", {
				Position = UDim2.fromOffset(10, 44),
				Size = UDim2.new(1, -20, 0, 0),
				BackgroundTransparency = 1,
				Parent = holder,
			})

			create("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = list,
			})

			local open = false
			local element = {
				Instance = holder,
				CurrentOption = options.CurrentOption or {},
			}

			if typeof(element.CurrentOption) ~= "table" then
				element.CurrentOption = { element.CurrentOption }
			end

			local function contains(value)
				for _, selectedOption in ipairs(element.CurrentOption) do
					if selectedOption == value then
						return true
					end
				end

				return false
			end

			local function remove(value)
				for index, selectedOption in ipairs(element.CurrentOption) do
					if selectedOption == value then
						table.remove(element.CurrentOption, index)
						return
					end
				end
			end

			local function renderText()
				selected.Text = #element.CurrentOption > 0 and table.concat(element.CurrentOption, ", ") or "None"
			end

			local function resize()
				tween(holder, {
					Size = UDim2.new(1, 0, 0, open and (50 + (#optionList * 32)) or 44),
				})
				caret.Text = open and "^" or "v"
			end

			local optionButtons = {}

			local function renderOptions()
				for _, optionButton in ipairs(optionButtons) do
					local active = contains(optionButton.Option)
					tween(optionButton.Button, {
						BackgroundColor3 = active and Theme.AccentDark or Color3.fromRGB(27, 35, 48),
						TextColor3 = active and Theme.Text or Theme.Muted,
					})
				end

				renderText()
			end

			function element:Set(value)
				if typeof(value) == "table" then
					self.CurrentOption = value
				else
					self.CurrentOption = { value }
				end

				renderOptions()
				safeCallback(options.Callback, self.CurrentOption)
			end

			for _, option in ipairs(optionList) do
				local optionButton = create("TextButton", {
					Size = UDim2.new(1, 0, 0, 26),
					BackgroundColor3 = Color3.fromRGB(27, 35, 48),
					BorderSizePixel = 0,
					Text = tostring(option),
					TextColor3 = Theme.Muted,
					TextSize = 12,
					Font = Enum.Font.GothamBold,
					AutoButtonColor = false,
					Parent = list,
				}, {
					corner(7),
				})

				local record = {
					Button = optionButton,
					Option = option,
				}

				table.insert(optionButtons, record)

				optionButton.MouseButton1Click:Connect(function()
					if multiple then
						if contains(option) then
							remove(option)
						else
							table.insert(element.CurrentOption, option)
						end
					else
						element.CurrentOption = { option }
						open = false
						resize()
					end

					renderOptions()
					safeCallback(options.Callback, element.CurrentOption)
				end)
			end

			top.MouseButton1Click:Connect(function()
				open = not open
				resize()
			end)

			renderOptions()
			resize()
			return element
		end

		function cardObject:CreateColorPicker(options)
			options = options or {}

			local holder = makeElementHolder(container, options.Height or 150)

			local text = label(options.Name or "Color Picker", 13, Theme.Text, true)
			text.Position = UDim2.fromOffset(12, 4)
			text.Size = UDim2.new(1, -76, 0, 28)
			text.Parent = holder

			local preview = create("Frame", {
				Size = UDim2.fromOffset(38, 24),
				Position = UDim2.new(1, -50, 0, 8),
				BackgroundColor3 = options.Color or options.CurrentValue or Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Parent = holder,
			}, {
				corner(8),
				stroke(Theme.Stroke, 0.78),
			})

			local element = {
				Instance = holder,
				CurrentValue = options.Color or options.CurrentValue or Color3.fromRGB(255, 255, 255),
			}

			local fills = {}
			local values = {}

			local function makeChannel(name, y, channel)
				local channelLabel = label(name, 12, Theme.Muted, true)
				channelLabel.Position = UDim2.fromOffset(12, y)
				channelLabel.Size = UDim2.fromOffset(22, 24)
				channelLabel.Parent = holder

				local bar = create("Frame", {
					Size = UDim2.new(1, -118, 0, 8),
					Position = UDim2.fromOffset(40, y + 8),
					BackgroundColor3 = Color3.fromRGB(62, 71, 86),
					BorderSizePixel = 0,
					Parent = holder,
				}, {
					corner(99),
				})

				local channelColor =
					channel == "R" and Color3.fromRGB(255, 82, 96)
					or channel == "G" and Color3.fromRGB(64, 224, 142)
					or Color3.fromRGB(84, 154, 255)

				local fill = create("Frame", {
					Size = UDim2.new(),
					BackgroundColor3 = channelColor,
					BorderSizePixel = 0,
					Parent = bar,
				}, {
					corner(99),
				})

				local valueText = label("0", 12, Theme.Muted, false)
				valueText.Position = UDim2.new(1, -68, 0, y)
				valueText.Size = UDim2.fromOffset(56, 24)
				valueText.TextXAlignment = Enum.TextXAlignment.Right
				valueText.Parent = holder

				local dragging = false

				local function updateFromX(x)
					local alpha = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
					local r = math.floor((element.CurrentValue.R * 255) + 0.5)
					local g = math.floor((element.CurrentValue.G * 255) + 0.5)
					local b = math.floor((element.CurrentValue.B * 255) + 0.5)

					if channel == "R" then
						r = math.floor((alpha * 255) + 0.5)
					elseif channel == "G" then
						g = math.floor((alpha * 255) + 0.5)
					else
						b = math.floor((alpha * 255) + 0.5)
					end

					element:Set(Color3.fromRGB(r, g, b))
				end

				bar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						updateFromX(input.Position.X)
					end
				end)

				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)

				UserInputService.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						updateFromX(input.Position.X)
					end
				end)

				fills[channel] = fill
				values[channel] = valueText
			end

			function element:Set(color)
				if typeof(color) ~= "Color3" then
					color = Color3.fromRGB(255, 255, 255)
				end

				self.CurrentValue = color
				preview.BackgroundColor3 = color

				local r = math.floor((color.R * 255) + 0.5)
				local g = math.floor((color.G * 255) + 0.5)
				local b = math.floor((color.B * 255) + 0.5)

				fills.R.Size = UDim2.new(color.R, 0, 1, 0)
				fills.G.Size = UDim2.new(color.G, 0, 1, 0)
				fills.B.Size = UDim2.new(color.B, 0, 1, 0)

				values.R.Text = tostring(r)
				values.G.Text = tostring(g)
				values.B.Text = tostring(b)

				safeCallback(options.Callback, color)
			end

			makeChannel("R", 42, "R")
			makeChannel("G", 78, "G")
			makeChannel("B", 114, "B")

			element:Set(element.CurrentValue)
			return element
		end

		return cardObject
	end

	function window:CreateTab(options)
		options = options or {}

		local tab = {
			Name = options.Name or "Tab",
			Description = options.Description,
			Icon = options.Icon,
			Page = createPage(options.Name or "Tab"),
		}

		tab.Button, tab.Indicator, tab.Label = createNavButton(tab)

		function tab:CreateCard(cardOptions)
			return createCard(self.Page, cardOptions)
		end

		function tab:CreateRaw(options)
			local rawOptions = {}

			for key, value in pairs(options or {}) do
				rawOptions[key] = value
			end

			rawOptions.Raw = true
			return createCard(self.Page, rawOptions)
		end

		function tab:CreateParagraph(options)
			local raw = self:CreateRaw({
				Title = options and options.Title or "Paragraph",
				MinHeight = options and options.Height or 54,
			})

			return raw:CreateParagraph(options)
		end

		function tab:CreateButton(options)
			local raw = self:CreateRaw({
				Title = options and options.Name or "Button",
				MinHeight = options and options.Height or 38,
			})

			return raw:CreateButton(options)
		end

		function tab:CreateToggle(options)
			local raw = self:CreateRaw({
				Title = options and options.Name or "Toggle",
				MinHeight = 42,
			})

			return raw:CreateToggle(options)
		end

		function tab:CreateSlider(options)
			local raw = self:CreateRaw({
				Title = options and options.Name or "Slider",
				MinHeight = 68,
			})

			return raw:CreateSlider(options)
		end

		function tab:CreateInput(options)
			local raw = self:CreateRaw({
				Title = options and options.Name or "Input",
				MinHeight = 66,
			})

			return raw:CreateInput(options)
		end

		function tab:CreateDropdown(options)
			local raw = self:CreateRaw({
				Title = options and options.Name or "Dropdown",
				MinHeight = 44,
				MaxHeight = 260,
			})

			return raw:CreateDropdown(options)
		end

		function tab:CreateColorPicker(options)
			local raw = self:CreateRaw({
				Title = options and options.Name or "Color Picker",
				MinHeight = options and options.Height or 150,
			})

			return raw:CreateColorPicker(options)
		end

		table.insert(window.Tabs, tab)

		if not window.SelectedTab then
			selectTab(tab)
		end

		return tab
	end

	function window:SelectTab(name)
		for _, tab in ipairs(self.Tabs) do
			if tab.Name == name then
				selectTab(tab)
				return tab
			end
		end
	end

	function window:Toggle()
		self.Visible = not self.Visible

		tween(root, {
			Position = self.Visible and (config.Position or UDim2.fromScale(0.5, 0.5)) or UDim2.fromScale(0.5, 1.35),
		}, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out))
	end

	function window:Notify(options)
		options = options or {}

		local position = normalizeToastPosition(options.Position or self.ToastPosition)
		local container = toastContainers[position] or toastContainers.BottomRight
		local duration = tonumber(options.Duration) or 4

		local toast = create("Frame", {
			Name = "Toast",
			Size = UDim2.new(1, 0, 0, options.Height or 72),
			BackgroundColor3 = Theme.SurfaceSoft,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Parent = container,
		}, {
			corner(8),
			stroke(Theme.Stroke, 1),
		})

		local toastTitle = label(options.Title or "Notification", 13, Theme.Text, true)
		toastTitle.Position = UDim2.fromOffset(14, 10)
		toastTitle.Size = UDim2.new(1, -28, 0, 20)
		toastTitle.TextTransparency = 1
		toastTitle.Parent = toast

		local toastText = label(options.Text or options.Description or "", 12, Theme.Muted, false)
		toastText.Position = UDim2.fromOffset(14, 31)
		toastText.Size = UDim2.new(1, -28, 0, 30)
		toastText.TextWrapped = true
		toastText.TextYAlignment = Enum.TextYAlignment.Top
		toastText.TextTransparency = 1
		toastText.Parent = toast

		local toastStroke = toast:FindFirstChildOfClass("UIStroke")

		tween(toast, { BackgroundTransparency = 0.08 })
		tween(toastTitle, { TextTransparency = 0 })
		tween(toastText, { TextTransparency = 0 })
		if toastStroke then
			tween(toastStroke, { Transparency = 0.72 })
		end

		task.delay(duration, function()
			if not toast.Parent then
				return
			end

			tween(toast, { BackgroundTransparency = 1 })
			tween(toastTitle, { TextTransparency = 1 })
			tween(toastText, { TextTransparency = 1 })
			if toastStroke then
				tween(toastStroke, { Transparency = 1 })
			end

			task.wait(0.2)
			if toast.Parent then
				toast:Destroy()
			end
		end)

		return toast
	end

	function window:Toast(options)
		return self:Notify(options)
	end

	function window:Destroy()
		gui:Destroy()
	end

	minimize.MouseEnter:Connect(function()
		tween(minimize, { TextColor3 = Theme.Text })
	end)

	minimize.MouseLeave:Connect(function()
		tween(minimize, { TextColor3 = Theme.Muted })
	end)

	minimize.MouseButton1Click:Connect(function()
		window:Toggle()
	end)

	close.MouseEnter:Connect(function()
		tween(close, { TextColor3 = Theme.Danger })
	end)

	close.MouseLeave:Connect(function()
		tween(close, { TextColor3 = Theme.Muted })
	end)

	close.MouseButton1Click:Connect(function()
		window:Destroy()
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.KeyCode == (config.ToggleKey or Enum.KeyCode.RightShift) then
			window:Toggle()
		end
	end)

	navLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		rail.Size = UDim2.new(1, -20, 1, -24)
	end)

	task.spawn(function()
		while gui.Parent do
			tween(glow, {
				Position = UDim2.new(1, -138, 0, -60),
				BackgroundTransparency = 0.68,
			}, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut))
			task.wait(1.8)

			if not gui.Parent then
				break
			end

			tween(glow, {
				Position = UDim2.new(1, -110, 0, -78),
				BackgroundTransparency = 0.78,
			}, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut))
			task.wait(1.8)
		end
	end)

	return window
end

return Library
