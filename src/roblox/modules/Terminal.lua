-- Terminal Module
local Terminal = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Load modules
local FileSystem = require(ReplicatedStorage.Modules.FileSystem)
local GlitchEffect = require(ReplicatedStorage.Modules.GlitchEffect)
local PersonalityResponses = require(ReplicatedStorage.Modules.PersonalityResponses)

-- Constants
local WINDOW_DEFAULTS = {
    Size = UDim2.new(0.6, 0, 0.4, 0),
    Position = UDim2.new(0.2, 0, 0.3, 0),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BorderSizePixel = 1,
    BorderColor3 = Color3.fromRGB(100, 100, 100)
}

local TITLE_BAR_HEIGHT = 30
local TITLE_BAR_COLOR = Color3.fromRGB(40, 40, 40)
local TITLE_TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local PROMPT_COLOR = Color3.fromRGB(0, 255, 0)
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local ERROR_COLOR = Color3.fromRGB(255, 0, 0)

-- Command history
local commandHistory = {}
local historyIndex = 0

-- Current directory
local currentDirectory = "/"

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

local function createOutputArea(parent)
    local outputArea = Instance.new("ScrollingFrame")
    outputArea.Name = "OutputArea"
    outputArea.Size = UDim2.new(1, -20, 1, -TITLE_BAR_HEIGHT - 60)
    outputArea.Position = UDim2.new(0, 10, 0, TITLE_BAR_HEIGHT + 10)
    outputArea.BackgroundTransparency = 1
    outputArea.BorderSizePixel = 0
    outputArea.ScrollBarThickness = 6
    outputArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    outputArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
    outputArea.Parent = parent

    local outputList = Instance.new("UIListLayout")
    outputList.Padding = UDim.new(0, 5)
    outputList.Parent = outputArea

    return outputArea
end

local function createInputArea(parent)
    local inputArea = Instance.new("Frame")
    inputArea.Name = "InputArea"
    inputArea.Size = UDim2.new(1, -20, 0, 30)
    inputArea.Position = UDim2.new(0, 10, 1, -40)
    inputArea.BackgroundTransparency = 1
    inputArea.Parent = parent

    local prompt = Instance.new("TextLabel")
    prompt.Name = "Prompt"
    prompt.Size = UDim2.new(0, 20, 1, 0)
    prompt.Position = UDim2.new(0, 0, 0, 0)
    prompt.BackgroundTransparency = 1
    prompt.Text = ">"
    prompt.TextColor3 = PROMPT_COLOR
    prompt.TextSize = 14
    prompt.Font = Enum.Font.Code
    prompt.TextXAlignment = Enum.TextXAlignment.Left
    prompt.Parent = inputArea

    local input = Instance.new("TextBox")
    input.Name = "Input"
    input.Size = UDim2.new(1, -30, 1, 0)
    input.Position = UDim2.new(0, 25, 0, 0)
    input.BackgroundTransparency = 1
    input.Text = ""
    input.TextColor3 = TEXT_COLOR
    input.TextSize = 14
    input.Font = Enum.Font.Code
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.Parent = inputArea

    return inputArea, input
end

local function addOutput(outputArea, text, color)
    local output = Instance.new("TextLabel")
    output.Size = UDim2.new(1, 0, 0, 0)
    output.BackgroundTransparency = 1
    output.Text = text
    output.TextColor3 = color or TEXT_COLOR
    output.TextSize = 14
    output.Font = Enum.Font.Code
    output.TextXAlignment = Enum.TextXAlignment.Left
    output.TextYAlignment = Enum.TextYAlignment.Top
    output.TextWrapped = true
    output.AutomaticSize = Enum.AutomaticSize.Y
    output.Parent = outputArea

    outputArea.CanvasPosition = Vector2.new(0, outputArea.CanvasSize.Y.Offset)
end

-- Command handlers
local commands = {
    cd = function(args)
        if #args == 0 then
            return currentDirectory
        end

        local newPath = args[1]
        if newPath == ".." then
            -- Move up one directory
            local parts = string.split(currentDirectory, "/")
            table.remove(parts)
            currentDirectory = table.concat(parts, "/")
            if currentDirectory == "" then
                currentDirectory = "/"
            end
        else
            -- Move to specified directory
            if newPath:sub(1, 1) == "/" then
                currentDirectory = newPath
            else
                currentDirectory = currentDirectory .. "/" .. newPath
            end
        end

        return "Changed directory to: " .. currentDirectory
    end,

    ls = function(args)
        local path = args[1] or currentDirectory
        local items = FileSystem.listDirectory(path)
        if not items then
            return "Error: Directory not found", ERROR_COLOR
        end

        local output = {}
        for _, item in ipairs(items) do
            table.insert(output, item.name)
        end

        return table.concat(output, "\n")
    end,

    cat = function(args)
        if #args == 0 then
            return "Error: No file specified", ERROR_COLOR
        end

        local path = args[1]
        if path:sub(1, 1) ~= "/" then
            path = currentDirectory .. "/" .. path
        end

        local content = FileSystem.readFile(path)
        if not content then
            return "Error: File not found", ERROR_COLOR
        end

        return content
    end,

    help = function(args)
        return [[Available commands:
cd [path] - Change directory
ls [path] - List directory contents
cat [file] - Display file contents
help - Show this help message
clear - Clear terminal
exit - Close terminal]]
    end,

    clear = function(args)
        for _, child in ipairs(outputArea:GetChildren()) do
            if child:IsA("TextLabel") then
                child:Destroy()
            end
        end
        return nil
    end
}

-- Create terminal window
function Terminal.createWindow(parent)
    -- Create main window
    local window = Instance.new("Frame")
    window.Name = "Terminal"
    for property, value in pairs(WINDOW_DEFAULTS) do
        window[property] = value
    end
    window.Parent = parent

    -- Create title bar
    local titleBar = createTitleBar(window, "Terminal")
    local closeButton = createCloseButton(titleBar)

    -- Create output area
    local outputArea = createOutputArea(window)

    -- Create input area
    local inputArea, input = createInputArea(window)

    -- Handle input
    input.FocusLost:Connect(function(enterPressed)
        if not enterPressed then
            return
        end

        local command = input.Text
        input.Text = ""

        -- Add command to history
        table.insert(commandHistory, command)
        historyIndex = #commandHistory + 1

        -- Display command
        addOutput(outputArea, "> " .. command)

        -- Parse and execute command
        local args = {}
        for arg in string.gmatch(command, "%S+") do
            table.insert(args, arg)
        end

        if #args == 0 then
            return
        end

        local commandName = args[1]
        table.remove(args, 1)

        local handler = commands[commandName]
        if handler then
            local result, color = handler(args)
            if result then
                addOutput(outputArea, result, color)
            end
        else
            addOutput(outputArea, "Error: Unknown command '" .. commandName .. "'", ERROR_COLOR)
        end
    end)

    -- Handle command history
    input.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Up then
            if historyIndex > 1 then
                historyIndex = historyIndex - 1
                input.Text = commandHistory[historyIndex]
                input.CursorPosition = string.len(input.Text) + 1
            end
        elseif input.KeyCode == Enum.KeyCode.Down then
            if historyIndex < #commandHistory then
                historyIndex = historyIndex + 1
                input.Text = commandHistory[historyIndex]
                input.CursorPosition = string.len(input.Text) + 1
            else
                historyIndex = #commandHistory + 1
                input.Text = ""
            end
        end
    end)

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

    -- Add welcome message
    addOutput(outputArea, "Welcome to MIRAGE.exe Terminal")
    addOutput(outputArea, "Type 'help' for available commands")

    return {
        window = window,
        cleanup = function()
            glitchCleanup()
        end
    }
end

return Terminal 