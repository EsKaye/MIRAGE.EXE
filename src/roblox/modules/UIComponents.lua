-- UIComponents Module
local UIComponents = {}

-- Services
local TweenService = game:GetService("TweenService")

-- Constants
local WINDOW_DEFAULTS = {
    Size = UDim2.new(0.3, 0, 0.4, 0),
    Position = UDim2.new(0.35, 0, 0.3, 0),
    BackgroundTransparency = 0.1,
    BorderSizePixel = 1,
    BorderColor3 = Color3.fromRGB(255, 255, 255),
    ClipsDescendants = true
}

local TITLE_BAR_HEIGHT = 30
local TITLE_BAR_COLOR = Color3.fromRGB(40, 40, 40)
local TITLE_TEXT_COLOR = Color3.fromRGB(255, 255, 255)

-- Helper functions
local function createTitleBar(parent, title)
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, TITLE_BAR_HEIGHT)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = TITLE_BAR_COLOR
    titleBar.BorderSizePixel = 0
    titleBar.Parent = parent

    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -20, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = title
    titleText.TextColor3 = TITLE_TEXT_COLOR
    titleText.TextSize = 14
    titleText.Font = Enum.Font.Code
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    return titleBar
end

local function createCloseButton(parent)
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 12
    closeButton.Font = Enum.Font.Code
    closeButton.Parent = parent

    return closeButton
end

local function createChatBox(parent)
    local chatBox = Instance.new("ScrollingFrame")
    chatBox.Name = "ChatBox"
    chatBox.Size = UDim2.new(1, -20, 1, -TITLE_BAR_HEIGHT - 60)
    chatBox.Position = UDim2.new(0, 10, 0, TITLE_BAR_HEIGHT + 10)
    chatBox.BackgroundTransparency = 1
    chatBox.BorderSizePixel = 0
    chatBox.ScrollBarThickness = 6
    chatBox.CanvasSize = UDim2.new(0, 0, 0, 0)
    chatBox.AutomaticCanvasSize = Enum.AutomaticSize.Y
    chatBox.Parent = parent

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 5)
    uiListLayout.Parent = chatBox

    return chatBox
end

local function createInputBox(parent)
    local inputBox = Instance.new("Frame")
    inputBox.Name = "InputBox"
    inputBox.Size = UDim2.new(1, -20, 0, 40)
    inputBox.Position = UDim2.new(0, 10, 1, -50)
    inputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    inputBox.BorderSizePixel = 1
    inputBox.BorderColor3 = Color3.fromRGB(100, 100, 100)
    inputBox.Parent = parent

    local textBox = Instance.new("TextBox")
    textBox.Name = "Input"
    textBox.Size = UDim2.new(1, -20, 1, -10)
    textBox.Position = UDim2.new(0, 10, 0, 5)
    textBox.BackgroundTransparency = 1
    textBox.Text = ""
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 14
    textBox.Font = Enum.Font.Code
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.TextYAlignment = Enum.TextYAlignment.Center
    textBox.PlaceholderText = "Type your message..."
    textBox.Parent = inputBox

    return inputBox
end

-- Create a personality window
function UIComponents.createPersonalityWindow(parent, title, personality)
    -- Create main window
    local window = Instance.new("Frame")
    window.Name = title .. "Window"
    for property, value in pairs(WINDOW_DEFAULTS) do
        window[property] = value
    end
    window.Parent = parent

    -- Create title bar
    local titleBar = createTitleBar(window, title)
    local closeButton = createCloseButton(titleBar)

    -- Create chat box
    local chatBox = createChatBox(window)

    -- Create input box
    local inputBox = createInputBox(window)

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

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)

    -- Add message to chat
    function window:AddMessage(message, isUser)
        local messageFrame = Instance.new("Frame")
        messageFrame.Size = UDim2.new(1, 0, 0, 20)
        messageFrame.BackgroundTransparency = 1

        local messageText = Instance.new("TextLabel")
        messageText.Size = UDim2.new(1, 0, 1, 0)
        messageText.BackgroundTransparency = 1
        messageText.Text = message
        messageText.TextColor3 = isUser and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(255, 255, 255)
        messageText.TextSize = 14
        messageText.Font = Enum.Font.Code
        messageText.TextXAlignment = isUser and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
        messageText.Parent = messageFrame

        messageFrame.Parent = chatBox
    end

    -- Handle close button
    closeButton.MouseButton1Click:Connect(function()
        window.Visible = false
    end)

    return window
end

-- Create a notification
function UIComponents.createNotification(parent, message, duration)
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 200, 0, 40)
    notification.Position = UDim2.new(1, 10, 0, 10)
    notification.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    notification.BorderSizePixel = 1
    notification.BorderColor3 = Color3.fromRGB(100, 100, 100)
    notification.Parent = parent

    local messageText = Instance.new("TextLabel")
    messageText.Size = UDim2.new(1, -20, 1, 0)
    messageText.Position = UDim2.new(0, 10, 0, 0)
    messageText.BackgroundTransparency = 1
    messageText.Text = message
    messageText.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageText.TextSize = 14
    messageText.Font = Enum.Font.Code
    messageText.TextXAlignment = Enum.TextXAlignment.Left
    messageText.TextYAlignment = Enum.TextYAlignment.Center
    messageText.Parent = notification

    -- Animate in
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(notification, tweenInfo, {
        Position = UDim2.new(1, -210, 0, 10)
    })
    tween:Play()

    -- Animate out after duration
    delay(duration, function()
        local tweenOut = TweenService:Create(notification, tweenInfo, {
            Position = UDim2.new(1, 10, 0, 10)
        })
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            notification:Destroy()
        end)
    end)

    return notification
end

return UIComponents 