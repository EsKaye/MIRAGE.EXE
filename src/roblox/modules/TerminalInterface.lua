-- TerminalInterface Module
local TerminalInterface = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Modules
local CommandSystem = require(script.Parent.CommandSystem)
local PersonalityState = require(script.Parent.PersonalityState)
local PersonalityResponses = require(script.Parent.PersonalityResponses)
local PersonalityEffects = require(script.Parent.PersonalityEffects)
local GlitchEffect = require(script.Parent.GlitchEffect)

-- Constants
local TERMINAL_DEFAULTS = {
    width = 800,
    height = 600,
    titleHeight = 30,
    padding = 10,
    cornerRadius = 8,
    backgroundColor = Color3.fromRGB(0, 0, 0),
    titleColor = Color3.fromRGB(40, 40, 40),
    textColor = Color3.fromRGB(0, 255, 0),
    prompt = "> ",
    maxHistory = 100
}

-- Terminal state
local terminalState = {
    history = {},
    historyIndex = 0,
    currentInput = "",
    isProcessing = false
}

-- Helper functions
local function createCorner(radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    return corner
end

local function createStroke(thickness, color)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness
    stroke.Color = color
    return stroke
end

-- Create terminal window
function TerminalInterface.createWindow(parent)
    -- Create main frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, TERMINAL_DEFAULTS.width, 0, TERMINAL_DEFAULTS.height)
    frame.Position = UDim2.new(0.5, -TERMINAL_DEFAULTS.width/2, 0.5, -TERMINAL_DEFAULTS.height/2)
    frame.BackgroundColor3 = TERMINAL_DEFAULTS.backgroundColor
    frame.Parent = parent

    -- Add corner radius
    createCorner(TERMINAL_DEFAULTS.cornerRadius).Parent = frame

    -- Create title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, TERMINAL_DEFAULTS.titleHeight)
    titleBar.BackgroundColor3 = TERMINAL_DEFAULTS.titleColor
    titleBar.Parent = frame

    -- Add corner radius to title bar
    createCorner(TERMINAL_DEFAULTS.cornerRadius).Parent = titleBar

    -- Create title text
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -20, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "MIRAGE.EXE Terminal"
    titleText.TextColor3 = TERMINAL_DEFAULTS.textColor
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Font = Enum.Font.Code
    titleText.TextSize = 14
    titleText.Parent = titleBar

    -- Create close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 5)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "X"
    closeButton.TextColor3 = TERMINAL_DEFAULTS.textColor
    closeButton.Font = Enum.Font.Code
    closeButton.TextSize = 14
    closeButton.Parent = titleBar

    -- Create output area
    local outputArea = Instance.new("ScrollingFrame")
    outputArea.Size = UDim2.new(1, -TERMINAL_DEFAULTS.padding * 2, 1, -TERMINAL_DEFAULTS.titleHeight - TERMINAL_DEFAULTS.padding * 3)
    outputArea.Position = UDim2.new(0, TERMINAL_DEFAULTS.padding, 0, TERMINAL_DEFAULTS.titleHeight + TERMINAL_DEFAULTS.padding)
    outputArea.BackgroundTransparency = 1
    outputArea.BorderSizePixel = 0
    outputArea.ScrollBarThickness = 6
    outputArea.ScrollingDirection = Enum.ScrollingDirection.Y
    outputArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    outputArea.Parent = frame

    -- Create output list
    local outputList = Instance.new("UIListLayout")
    outputList.Padding = UDim.new(0, 5)
    outputList.Parent = outputArea

    -- Create input area
    local inputArea = Instance.new("Frame")
    inputArea.Size = UDim2.new(1, -TERMINAL_DEFAULTS.padding * 2, 0, 30)
    inputArea.Position = UDim2.new(0, TERMINAL_DEFAULTS.padding, 1, -TERMINAL_DEFAULTS.padding - 30)
    inputArea.BackgroundTransparency = 1
    inputArea.Parent = frame

    -- Create prompt
    local prompt = Instance.new("TextLabel")
    prompt.Size = UDim2.new(0, 20, 1, 0)
    prompt.Position = UDim2.new(0, 0, 0, 0)
    prompt.BackgroundTransparency = 1
    prompt.Text = TERMINAL_DEFAULTS.prompt
    prompt.TextColor3 = TERMINAL_DEFAULTS.textColor
    prompt.TextXAlignment = Enum.TextXAlignment.Left
    prompt.Font = Enum.Font.Code
    prompt.TextSize = 14
    prompt.Parent = inputArea

    -- Create input field
    local inputField = Instance.new("TextBox")
    inputField.Size = UDim2.new(1, -30, 1, 0)
    inputField.Position = UDim2.new(0, 25, 0, 0)
    inputField.BackgroundTransparency = 1
    inputField.Text = ""
    inputField.TextColor3 = TERMINAL_DEFAULTS.textColor
    inputField.TextXAlignment = Enum.TextXAlignment.Left
    inputField.Font = Enum.Font.Code
    inputField.TextSize = 14
    inputField.Parent = inputArea

    -- Add output line
    local function addOutputLine(text, color)
        local line = Instance.new("TextLabel")
        line.Size = UDim2.new(1, 0, 0, 20)
        line.BackgroundTransparency = 1
        line.Text = text
        line.TextColor3 = color or TERMINAL_DEFAULTS.textColor
        line.TextXAlignment = Enum.TextXAlignment.Left
        line.TextYAlignment = Enum.TextYAlignment.Top
        line.Font = Enum.Font.Code
        line.TextSize = 14
        line.TextWrapped = true
        line.Parent = outputArea

        -- Update canvas size
        outputArea.CanvasSize = UDim2.new(0, 0, 0, outputList.AbsoluteContentSize.Y)
        outputArea.CanvasPosition = Vector2.new(0, outputArea.CanvasSize.Y.Offset)
    end

    -- Process command
    local function processCommand(input)
        if terminalState.isProcessing then
            return
        end

        terminalState.isProcessing = true
        addOutputLine(TERMINAL_DEFAULTS.prompt .. input)

        -- Add to history
        table.insert(terminalState.history, input)
        if #terminalState.history > TERMINAL_DEFAULTS.maxHistory then
            table.remove(terminalState.history, 1)
        end
        terminalState.historyIndex = #terminalState.history + 1

        -- Execute command
        local success, result = CommandSystem.executeCommand(input)
        if not success then
            addOutputLine(result, Color3.fromRGB(255, 0, 0))
        else
            if type(result) == "table" then
                for _, item in ipairs(result) do
                    addOutputLine(tostring(item))
                end
            else
                addOutputLine(tostring(result))
            end
        end

        terminalState.isProcessing = false
        inputField.Text = ""
    end

    -- Handle input
    inputField.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local input = inputField.Text
            if input ~= "" then
                processCommand(input)
            end
        end
    end)

    -- Handle history navigation
    inputField.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Up then
            if terminalState.historyIndex > 1 then
                terminalState.historyIndex = terminalState.historyIndex - 1
                inputField.Text = terminalState.history[terminalState.historyIndex]
                inputField.CursorPosition = #inputField.Text + 1
            end
        elseif input.KeyCode == Enum.KeyCode.Down then
            if terminalState.historyIndex < #terminalState.history then
                terminalState.historyIndex = terminalState.historyIndex + 1
                inputField.Text = terminalState.history[terminalState.historyIndex]
                inputField.CursorPosition = #inputField.Text + 1
            else
                terminalState.historyIndex = #terminalState.history + 1
                inputField.Text = ""
            end
        end
    end)

    -- Handle window dragging
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function updateDrag(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
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

    -- Handle close button
    closeButton.MouseButton1Click:Connect(function()
        frame:Destroy()
    end)

    -- Display welcome message
    addOutputLine("Welcome to MIRAGE.EXE Terminal")
    addOutputLine("Type 'help' for available commands")

    return frame
end

-- Clear terminal
function TerminalInterface.clear()
    terminalState.history = {}
    terminalState.historyIndex = 0
    terminalState.currentInput = ""
    terminalState.isProcessing = false
end

-- Get terminal state
function TerminalInterface.getState()
    return terminalState
end

-- Set terminal state
function TerminalInterface.setState(state)
    terminalState = state
end

return TerminalInterface 