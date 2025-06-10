-- FileViewer Module
local FileViewer = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Load modules
local FileSystem = require(ReplicatedStorage.Modules.FileSystem)
local GlitchEffect = require(ReplicatedStorage.Modules.GlitchEffect)

-- Constants
local WINDOW_DEFAULTS = {
    Size = UDim2.new(0.5, 0, 0.6, 0),
    Position = UDim2.new(0.25, 0, 0.2, 0),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    BorderSizePixel = 1,
    BorderColor3 = Color3.fromRGB(100, 100, 100)
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

local function createContentArea(parent, fileType)
    local contentArea = Instance.new("ScrollingFrame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -20, 1, -TITLE_BAR_HEIGHT - 20)
    contentArea.Position = UDim2.new(0, 10, 0, TITLE_BAR_HEIGHT + 10)
    contentArea.BackgroundTransparency = 1
    contentArea.BorderSizePixel = 0
    contentArea.ScrollBarThickness = 6
    contentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentArea.Parent = parent

    if fileType == "txt" then
        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "TextContent"
        textLabel.Size = UDim2.new(1, 0, 0, 0)
        textLabel.Position = UDim2.new(0, 0, 0, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = ""
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextSize = 14
        textLabel.Font = Enum.Font.Code
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextYAlignment = Enum.TextYAlignment.Top
        textLabel.TextWrapped = true
        textLabel.AutomaticSize = Enum.AutomaticSize.Y
        textLabel.Parent = contentArea

        return contentArea, textLabel
    elseif fileType == "png" then
        local imageLabel = Instance.new("ImageLabel")
        imageLabel.Name = "ImageContent"
        imageLabel.Size = UDim2.new(1, 0, 1, 0)
        imageLabel.Position = UDim2.new(0, 0, 0, 0)
        imageLabel.BackgroundTransparency = 1
        imageLabel.Parent = contentArea

        return contentArea, imageLabel
    elseif fileType == "mp3" then
        local soundLabel = Instance.new("TextLabel")
        soundLabel.Name = "SoundContent"
        soundLabel.Size = UDim2.new(1, 0, 0, 30)
        soundLabel.Position = UDim2.new(0, 0, 0, 0)
        soundLabel.BackgroundTransparency = 1
        soundLabel.Text = "Audio file"
        soundLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        soundLabel.TextSize = 14
        soundLabel.Font = Enum.Font.Code
        soundLabel.TextXAlignment = Enum.TextXAlignment.Center
        soundLabel.Parent = contentArea

        local playButton = Instance.new("TextButton")
        playButton.Name = "PlayButton"
        playButton.Size = UDim2.new(0, 100, 0, 30)
        playButton.Position = UDim2.new(0.5, -50, 0, 40)
        playButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        playButton.BorderSizePixel = 0
        playButton.Text = "Play"
        playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        playButton.TextSize = 14
        playButton.Font = Enum.Font.Code
        playButton.Parent = contentArea

        return contentArea, {soundLabel, playButton}
    elseif fileType == "exe" then
        local exeLabel = Instance.new("TextLabel")
        exeLabel.Name = "ExeContent"
        exeLabel.Size = UDim2.new(1, 0, 0, 30)
        exeLabel.Position = UDim2.new(0, 0, 0, 0)
        exeLabel.BackgroundTransparency = 1
        exeLabel.Text = "Executable file"
        exeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        exeLabel.TextSize = 14
        exeLabel.Font = Enum.Font.Code
        exeLabel.TextXAlignment = Enum.TextXAlignment.Center
        exeLabel.Parent = contentArea

        local runButton = Instance.new("TextButton")
        runButton.Name = "RunButton"
        runButton.Size = UDim2.new(0, 100, 0, 30)
        runButton.Position = UDim2.new(0.5, -50, 0, 40)
        runButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        runButton.BorderSizePixel = 0
        runButton.Text = "Run"
        runButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        runButton.TextSize = 14
        runButton.Font = Enum.Font.Code
        runButton.Parent = contentArea

        return contentArea, {exeLabel, runButton}
    else
        local unknownLabel = Instance.new("TextLabel")
        unknownLabel.Name = "UnknownContent"
        unknownLabel.Size = UDim2.new(1, 0, 0, 30)
        unknownLabel.Position = UDim2.new(0, 0, 0, 0)
        unknownLabel.BackgroundTransparency = 1
        unknownLabel.Text = "Unknown file type"
        unknownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        unknownLabel.TextSize = 14
        unknownLabel.Font = Enum.Font.Code
        unknownLabel.TextXAlignment = Enum.TextXAlignment.Center
        unknownLabel.Parent = contentArea

        return contentArea, unknownLabel
    end
end

-- Create file viewer window
function FileViewer.createWindow(parent, filePath)
    -- Get file info
    local fileInfo = FileSystem.getFileInfo(filePath)
    if not fileInfo then
        return nil, "File not found"
    end

    -- Create main window
    local window = Instance.new("Frame")
    window.Name = "FileViewer"
    for property, value in pairs(WINDOW_DEFAULTS) do
        window[property] = value
    end
    window.Parent = parent

    -- Create title bar
    local titleBar = createTitleBar(window, fileInfo.name)
    local closeButton = createCloseButton(titleBar)

    -- Create content area
    local contentArea, contentElement = createContentArea(window, fileInfo.type)

    -- Load file content
    if fileInfo.type == "txt" then
        local content = FileSystem.readFile(filePath)
        if content then
            contentElement.Text = content
        end
    elseif fileInfo.type == "png" then
        -- TODO: Load image content
        contentElement.Image = "rbxassetid://1234567890" -- Replace with actual image ID
    elseif fileInfo.type == "mp3" then
        local playButton = contentElement[2]
        playButton.MouseButton1Click:Connect(function()
            -- TODO: Play audio content
        end)
    elseif fileInfo.type == "exe" then
        local runButton = contentElement[2]
        runButton.MouseButton1Click:Connect(function()
            -- TODO: Handle executable
        end)
    end

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

    -- Handle close button
    closeButton.MouseButton1Click:Connect(function()
        window:Destroy()
    end)

    -- Add corruption effects
    local glitchCleanup = GlitchEffect.applyToScreen(window, 0.1)

    return {
        window = window,
        cleanup = function()
            glitchCleanup()
        end
    }
end

return FileViewer 