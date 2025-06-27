-- Terminal Module
local Terminal = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Load modules
local FileSystem = require(ReplicatedStorage.Modules.FileSystem)
local GlitchEffect = require(ReplicatedStorage.Modules.GlitchEffect)
local PersonalityResponses = require(ReplicatedStorage.Modules.PersonalityResponses)

-- Constants
local TERMINAL_DEFAULTS = {
    width = 600,
    height = 400,
    titleHeight = 30,
    padding = 10,
    cornerRadius = 8,
    backgroundColor = Color3.fromRGB(0, 0, 0),
    textColor = Color3.fromRGB(0, 255, 0),
    prompt = "> ",
    maxHistory = 100
}

-- Command handlers
local commands = {
    cd = function(args, terminal)
        if #args < 1 then
            return "Usage: cd <directory>"
        end
        local success, error = terminal.fileSystem:changeDirectory(args[1])
        if not success then
            return "Error: " .. error
        end
        return nil
    end,
    ls = function(args, terminal)
        local files = terminal.fileSystem:listDirectory()
        if not files then
            return "Error: Could not list directory"
        end
        local output = ""
        for _, file in ipairs(files) do
            output = output .. file.name .. "\n"
        end
        return output
    end,
    cat = function(args, terminal)
        if #args < 1 then
            return "Usage: cat <file>"
        end
        local content = terminal.fileSystem:readFile(args[1])
        if not content then
            return "Error: Could not read file"
        end
        return content
    end,
    help = function(args, terminal)
        local output = "Available commands:\n"
        for cmd, _ in pairs(commands) do
            output = output .. cmd .. "\n"
        end
        return output
    end,
    clear = function(args, terminal)
        terminal.outputArea.Text = ""
        return nil
    end,
    exit = function(args, terminal)
        terminal.window:Destroy()
        return nil
    end
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

-- Create terminal window
function Terminal.createWindow(parent, fileSystem)
    local window = Instance.new("Frame")
    window.Name = "Terminal"
    window.Size = UDim2.new(0, TERMINAL_DEFAULTS.width, 0, TERMINAL_DEFAULTS.height)
    window.Position = UDim2.new(0.5, 0, 0.5, 0)
    window.AnchorPoint = Vector2.new(0.5, 0.5)
    window.BackgroundColor3 = TERMINAL_DEFAULTS.backgroundColor
    window.Parent = parent

    -- Add corner radius
    createCorner(window, TERMINAL_DEFAULTS.cornerRadius)

    -- Add title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, TERMINAL_DEFAULTS.titleHeight)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    titleBar.Parent = window

    -- Add corner radius to title bar
    createCorner(titleBar, TERMINAL_DEFAULTS.cornerRadius)

    -- Add title text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -60, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "Terminal"
    titleText.TextColor3 = TERMINAL_DEFAULTS.textColor
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
    closeButton.TextColor3 = TERMINAL_DEFAULTS.textColor
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar

    -- Add output area
    local outputArea = Instance.new("ScrollingFrame")
    outputArea.Name = "OutputArea"
    outputArea.Size = UDim2.new(1, -20, 1, -TERMINAL_DEFAULTS.titleHeight - 40)
    outputArea.Position = UDim2.new(0, 10, 0, TERMINAL_DEFAULTS.titleHeight + 10)
    outputArea.BackgroundTransparency = 1
    outputArea.BorderSizePixel = 0
    outputArea.ScrollBarThickness = 6
    outputArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    outputArea.Parent = window

    -- Add output text
    local outputText = Instance.new("TextLabel")
    outputText.Name = "OutputText"
    outputText.Size = UDim2.new(1, 0, 0, 0)
    outputText.Position = UDim2.new(0, 0, 0, 0)
    outputText.BackgroundTransparency = 1
    outputText.Text = ""
    outputText.TextColor3 = TERMINAL_DEFAULTS.textColor
    outputText.TextSize = 14
    outputText.Font = Enum.Font.Gotham
    outputText.TextXAlignment = Enum.TextXAlignment.Left
    outputText.TextYAlignment = Enum.TextYAlignment.Top
    outputText.TextWrapped = true
    outputText.Parent = outputArea

    -- Add input area
    local inputArea = Instance.new("Frame")
    inputArea.Name = "InputArea"
    inputArea.Size = UDim2.new(1, -20, 0, 30)
    inputArea.Position = UDim2.new(0, 10, 1, -40)
    inputArea.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    inputArea.Parent = window

    -- Add corner radius to input area
    createCorner(inputArea, TERMINAL_DEFAULTS.cornerRadius)

    -- Add input text
    local inputText = Instance.new("TextBox")
    inputText.Name = "InputText"
    inputText.Size = UDim2.new(1, -20, 1, 0)
    inputText.Position = UDim2.new(0, 10, 0, 0)
    inputText.BackgroundTransparency = 1
    inputText.Text = TERMINAL_DEFAULTS.prompt
    inputText.TextColor3 = TERMINAL_DEFAULTS.textColor
    inputText.TextSize = 14
    inputText.Font = Enum.Font.Gotham
    inputText.TextXAlignment = Enum.TextXAlignment.Left
    inputText.TextYAlignment = Enum.TextYAlignment.Center
    inputText.Parent = inputArea

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

    -- Command history
    local history = {}
    local historyIndex = 0

    -- Process command
    local function processCommand(command)
        -- Add command to history
        table.insert(history, command)
        if #history > TERMINAL_DEFAULTS.maxHistory then
            table.remove(history, 1)
        end
        historyIndex = #history + 1

        -- Split command into parts
        local parts = {}
        for part in string.gmatch(command, "%S+") do
            table.insert(parts, part)
        end

        if #parts == 0 then
            return
        end

        -- Get command handler
        local cmd = parts[1]
        table.remove(parts, 1)

        -- Execute command
        local handler = commands[cmd]
        if handler then
            local result = handler(parts, {
                window = window,
                fileSystem = fileSystem,
                outputArea = outputArea,
                outputText = outputText
            })
            if result then
                outputText.Text = outputText.Text .. "\n" .. result
            end
        else
            outputText.Text = outputText.Text .. "\nCommand not found: " .. cmd
        end

        -- Update output area
        outputText.Text = outputText.Text .. "\n" .. TERMINAL_DEFAULTS.prompt
        outputArea.CanvasPosition = Vector2.new(0, outputText.TextBounds.Y)
    end

    -- Handle input
    inputText.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local command = string.sub(inputText.Text, #TERMINAL_DEFAULTS.prompt + 1)
            processCommand(command)
            inputText.Text = TERMINAL_DEFAULTS.prompt
        end
    end)

    -- Handle history navigation
    inputText.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Up then
            if historyIndex > 1 then
                historyIndex = historyIndex - 1
                inputText.Text = TERMINAL_DEFAULTS.prompt .. history[historyIndex]
            end
        elseif input.KeyCode == Enum.KeyCode.Down then
            if historyIndex < #history then
                historyIndex = historyIndex + 1
                inputText.Text = TERMINAL_DEFAULTS.prompt .. history[historyIndex]
            else
                historyIndex = #history + 1
                inputText.Text = TERMINAL_DEFAULTS.prompt
            end
        end
    end)

    return window
end

-- Add command
function Terminal.addCommand(name, handler)
    commands[name] = handler
end

-- Remove command
function Terminal.removeCommand(name)
    commands[name] = nil
end

-- Get commands
function Terminal.getCommands()
    return commands
end

return Terminal 