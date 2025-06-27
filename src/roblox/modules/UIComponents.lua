-- UIComponents Module
local UIComponents = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Constants
local WINDOW_DEFAULTS = {
    width = 400,
    height = 300,
    titleHeight = 30,
    padding = 10,
    cornerRadius = 8,
    backgroundColor = Color3.fromRGB(40, 40, 40),
    titleColor = Color3.fromRGB(60, 60, 60),
    textColor = Color3.fromRGB(255, 255, 255)
}

-- Helper functions
local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

local function createStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.Parent = parent
    return stroke
end

-- Create window
function UIComponents.createWindow(parent, options)
    options = options or {}
    local window = Instance.new("Frame")
    window.Name = options.name or "Window"
    window.Size = UDim2.new(0, options.width or WINDOW_DEFAULTS.width, 0, options.height or WINDOW_DEFAULTS.height)
    window.Position = UDim2.new(0.5, 0, 0.5, 0)
    window.AnchorPoint = Vector2.new(0.5, 0.5)
    window.BackgroundColor3 = options.backgroundColor or WINDOW_DEFAULTS.backgroundColor
    window.Parent = parent

    -- Add corner radius
    createCorner(window, options.cornerRadius or WINDOW_DEFAULTS.cornerRadius)

    -- Add title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, options.titleHeight or WINDOW_DEFAULTS.titleHeight)
    titleBar.BackgroundColor3 = options.titleColor or WINDOW_DEFAULTS.titleColor
    titleBar.Parent = window

    -- Add corner radius to title bar
    createCorner(titleBar, options.cornerRadius or WINDOW_DEFAULTS.cornerRadius)

    -- Add title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -60, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = options.title or "Window"
    titleText.TextColor3 = options.textColor or WINDOW_DEFAULTS.textColor
    titleText.TextSize = 14
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    -- Add close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 1, 0)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = options.textColor or WINDOW_DEFAULTS.textColor
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar

    -- Add content frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, -20, 1, -(options.titleHeight or WINDOW_DEFAULTS.titleHeight) - 20)
    contentFrame.Position = UDim2.new(0, 10, 0, (options.titleHeight or WINDOW_DEFAULTS.titleHeight) + 10)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = window

    -- Make window draggable
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function updateDrag(input)
        local delta = input.Position - dragStart
        window.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)

    -- Add close functionality
    closeButton.MouseButton1Click:Connect(function()
        window:Destroy()
    end)

    return window
end

-- Create button
function UIComponents.createButton(parent, options)
    options = options or {}
    local button = Instance.new("TextButton")
    button.Name = options.name or "Button"
    button.Size = UDim2.new(0, options.width or 100, 0, options.height or 30)
    button.Position = options.position or UDim2.new(0, 0, 0, 0)
    button.BackgroundColor3 = options.backgroundColor or Color3.fromRGB(60, 60, 60)
    button.Text = options.text or "Button"
    button.TextColor3 = options.textColor or WINDOW_DEFAULTS.textColor
    button.TextSize = options.textSize or 14
    button.Font = options.font or Enum.Font.Gotham
    button.Parent = parent

    -- Add corner radius
    createCorner(button, options.cornerRadius or WINDOW_DEFAULTS.cornerRadius)

    -- Add hover effect
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = options.hoverColor or Color3.fromRGB(80, 80, 80)
        }):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = options.backgroundColor or Color3.fromRGB(60, 60, 60)
        }):Play()
    end)

    return button
end

-- Create text input
function UIComponents.createTextInput(parent, options)
    options = options or {}
    local input = Instance.new("TextBox")
    input.Name = options.name or "TextInput"
    input.Size = UDim2.new(0, options.width or 200, 0, options.height or 30)
    input.Position = options.position or UDim2.new(0, 0, 0, 0)
    input.BackgroundColor3 = options.backgroundColor or Color3.fromRGB(50, 50, 50)
    input.Text = options.text or ""
    input.PlaceholderText = options.placeholder or ""
    input.TextColor3 = options.textColor or WINDOW_DEFAULTS.textColor
    input.PlaceholderColor3 = options.placeholderColor or Color3.fromRGB(150, 150, 150)
    input.TextSize = options.textSize or 14
    input.Font = options.font or Enum.Font.Gotham
    input.Parent = parent

    -- Add corner radius
    createCorner(input, options.cornerRadius or WINDOW_DEFAULTS.cornerRadius)

    -- Add stroke
    createStroke(input, options.strokeColor or Color3.fromRGB(100, 100, 100), options.strokeThickness or 1)

    return input
end

-- Create label
function UIComponents.createLabel(parent, options)
    options = options or {}
    local label = Instance.new("TextLabel")
    label.Name = options.name or "Label"
    label.Size = UDim2.new(0, options.width or 200, 0, options.height or 30)
    label.Position = options.position or UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = options.text or ""
    label.TextColor3 = options.textColor or WINDOW_DEFAULTS.textColor
    label.TextSize = options.textSize or 14
    label.Font = options.font or Enum.Font.Gotham
    label.TextXAlignment = options.xAlignment or Enum.TextXAlignment.Left
    label.TextYAlignment = options.yAlignment or Enum.TextYAlignment.Center
    label.Parent = parent

    return label
end

-- Create scroll frame
function UIComponents.createScrollFrame(parent, options)
    options = options or {}
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = options.name or "ScrollFrame"
    scrollFrame.Size = UDim2.new(0, options.width or 200, 0, options.height or 200)
    scrollFrame.Position = options.position or UDim2.new(0, 0, 0, 0)
    scrollFrame.BackgroundColor3 = options.backgroundColor or Color3.fromRGB(40, 40, 40)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = options.scrollBarThickness or 6
    scrollFrame.ScrollingDirection = options.scrollingDirection or Enum.ScrollingDirection.Y
    scrollFrame.CanvasSize = options.canvasSize or UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = parent

    -- Add corner radius
    createCorner(scrollFrame, options.cornerRadius or WINDOW_DEFAULTS.cornerRadius)

    -- Add list layout
    if options.useListLayout then
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, options.padding or WINDOW_DEFAULTS.padding)
        listLayout.Parent = scrollFrame
    end

    return scrollFrame
end

-- Create toggle
function UIComponents.createToggle(parent, options)
    options = options or {}
    local toggle = Instance.new("Frame")
    toggle.Name = options.name or "Toggle"
    toggle.Size = UDim2.new(0, options.width or 50, 0, options.height or 25)
    toggle.Position = options.position or UDim2.new(0, 0, 0, 0)
    toggle.BackgroundColor3 = options.backgroundColor or Color3.fromRGB(60, 60, 60)
    toggle.Parent = parent

    -- Add corner radius
    createCorner(toggle, options.cornerRadius or WINDOW_DEFAULTS.cornerRadius)

    -- Add toggle button
    local button = Instance.new("Frame")
    button.Name = "Button"
    button.Size = UDim2.new(0, options.buttonSize or 20, 1, 0)
    button.Position = UDim2.new(0, 2, 0, 0)
    button.BackgroundColor3 = options.buttonColor or Color3.fromRGB(255, 255, 255)
    button.Parent = toggle

    -- Add corner radius to button
    createCorner(button, options.buttonCornerRadius or (options.buttonSize or 20) / 2)

    -- Add label
    if options.text then
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -60, 1, 0)
        label.Position = UDim2.new(0, 60, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = options.text
        label.TextColor3 = options.textColor or WINDOW_DEFAULTS.textColor
        label.TextSize = options.textSize or 14
        label.Font = options.font or Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggle
    end

    -- Add toggle functionality
    local isToggled = false
    local function updateToggle()
        isToggled = not isToggled
        local tweenInfo = TweenInfo.new(0.2)
        local tween = TweenService:Create(button, tweenInfo, {
            Position = UDim2.new(isToggled and 1 or 0, isToggled and -22 or 2, 0, 0),
            BackgroundColor3 = isToggled and (options.toggledColor or Color3.fromRGB(0, 255, 0)) or (options.buttonColor or Color3.fromRGB(255, 255, 255))
        })
        tween:Play()
        if options.onToggle then
            options.onToggle(isToggled)
        end
    end

    toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateToggle()
        end
    end)

    return toggle
end

return UIComponents 