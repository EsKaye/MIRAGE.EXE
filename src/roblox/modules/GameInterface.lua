-- GameInterface Module
local GameInterface = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Modules
local UIComponents = require(script.Parent.UIComponents)
local TerminalInterface = require(script.Parent.TerminalInterface)
local FileExplorer = require(script.Parent.FileExplorer)
local Settings = require(script.Parent.Settings)
local HelpSystem = require(script.Parent.HelpSystem)
local PersonalityState = require(script.Parent.PersonalityState)
local PersonalityEffects = require(script.Parent.PersonalityEffects)

-- Constants
local WINDOW_DEFAULTS = {
    width = 1200,
    height = 800,
    titleHeight = 30,
    padding = 10,
    cornerRadius = 8,
    backgroundColor = Color3.fromRGB(20, 20, 20),
    titleColor = Color3.fromRGB(30, 30, 30),
    textColor = Color3.fromRGB(0, 255, 0),
    hoverColor = Color3.fromRGB(40, 40, 40),
    selectedColor = Color3.fromRGB(60, 60, 60),
    taskbarHeight = 40,
    startMenuWidth = 200,
    startMenuHeight = 300
}

-- State
local windows = {}
local activeWindow = nil
local dragging = false
local dragStart
local startPos

-- Helper functions
local function createTaskbar(parent)
    local taskbar = Instance.new("Frame")
    taskbar.Size = UDim2.new(1, 0, 0, WINDOW_DEFAULTS.taskbarHeight)
    taskbar.Position = UDim2.new(0, 0, 1, -WINDOW_DEFAULTS.taskbarHeight)
    taskbar.BackgroundColor3 = WINDOW_DEFAULTS.titleColor
    taskbar.BorderSizePixel = 0
    taskbar.Parent = parent
    
    -- Add start button
    local startButton = UIComponents.createButton({
        text = "Start",
        size = UDim2.new(0, 100, 1, 0),
        position = UDim2.new(0, 0, 0, 0),
        parent = taskbar
    })
    
    -- Add start menu
    local startMenu = Instance.new("Frame")
    startMenu.Size = UDim2.new(0, WINDOW_DEFAULTS.startMenuWidth, 0, WINDOW_DEFAULTS.startMenuHeight)
    startMenu.Position = UDim2.new(0, 0, 1, 0)
    startMenu.BackgroundColor3 = WINDOW_DEFAULTS.backgroundColor
    startMenu.BorderSizePixel = 0
    startMenu.Visible = false
    startMenu.Parent = taskbar
    
    -- Add corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, WINDOW_DEFAULTS.cornerRadius)
    corner.Parent = startMenu
    
    -- Add menu items
    local menuItems = {
        {
            text = "Terminal",
            action = function()
                local window = TerminalInterface.createWindow()
                window.Parent = parent
                table.insert(windows, window)
                startMenu.Visible = false
            end
        },
        {
            text = "File Explorer",
            action = function()
                local window = FileExplorer.createWindow()
                window.Parent = parent
                table.insert(windows, window)
                startMenu.Visible = false
            end
        },
        {
            text = "Settings",
            action = function()
                local window = Settings.createWindow()
                window.Parent = parent
                table.insert(windows, window)
                startMenu.Visible = false
            end
        },
        {
            text = "Help",
            action = function()
                local window = HelpSystem.createWindow()
                window.Parent = parent
                table.insert(windows, window)
                startMenu.Visible = false
            end
        }
    }
    
    local yOffset = 0
    for _, item in ipairs(menuItems) do
        local button = UIComponents.createButton({
            text = item.text,
            size = UDim2.new(1, 0, 0, 40),
            position = UDim2.new(0, 0, 0, yOffset),
            parent = startMenu
        })
        
        button.MouseButton1Click:Connect(function()
            item.action()
        end)
        
        yOffset = yOffset + 40
    end
    
    -- Toggle start menu
    startButton.MouseButton1Click:Connect(function()
        startMenu.Visible = not startMenu.Visible
    end)
    
    -- Close start menu when clicking outside
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if not startMenu:IsDescendantOf(input.Target) and not startButton:IsDescendantOf(input.Target) then
                startMenu.Visible = false
            end
        end
    end)
    
    return taskbar
end

local function createWindow(parent, title, content)
    local window = Instance.new("Frame")
    window.Size = UDim2.new(0, 800, 0, 600)
    window.Position = UDim2.new(0.5, -400, 0.5, -300)
    window.BackgroundColor3 = WINDOW_DEFAULTS.backgroundColor
    window.BorderSizePixel = 0
    window.Parent = parent
    
    -- Add corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, WINDOW_DEFAULTS.cornerRadius)
    corner.Parent = window
    
    -- Add title bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, WINDOW_DEFAULTS.titleHeight)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = WINDOW_DEFAULTS.titleColor
    titleBar.BorderSizePixel = 0
    titleBar.Parent = window
    
    -- Add corner
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, WINDOW_DEFAULTS.cornerRadius)
    titleCorner.Parent = titleBar
    
    -- Add title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = WINDOW_DEFAULTS.textColor
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.Font = Enum.Font.Code
    titleLabel.TextSize = 14
    titleLabel.Parent = titleBar
    
    -- Add close button
    local closeButton = UIComponents.createButton({
        text = "×",
        size = UDim2.new(0, 30, 1, 0),
        position = UDim2.new(1, -30, 0, 0),
        parent = titleBar
    })
    
    -- Add content
    if content then
        content.Parent = window
        content.Position = UDim2.new(0, 0, 0, WINDOW_DEFAULTS.titleHeight)
        content.Size = UDim2.new(1, 0, 1, -WINDOW_DEFAULTS.titleHeight)
    end
    
    -- Make window draggable
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
            
            -- Set as active window
            if activeWindow then
                activeWindow.ZIndex = 1
            end
            window.ZIndex = 2
            activeWindow = window
            
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
    
    -- Handle close button
    closeButton.MouseButton1Click:Connect(function()
        window:Destroy()
        for i, w in ipairs(windows) do
            if w == window then
                table.remove(windows, i)
                break
            end
        end
        if activeWindow == window then
            activeWindow = nil
        end
    end)
    
    -- Add to windows list
    table.insert(windows, window)
    
    return window
end

-- Main function to create the game interface
function GameInterface.createWindow()
    -- Create main frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = WINDOW_DEFAULTS.backgroundColor
    frame.BorderSizePixel = 0
    
    -- Create taskbar
    local taskbar = createTaskbar(frame)
    
    -- Create initial windows
    local terminal = TerminalInterface.createWindow()
    terminal.Parent = frame
    table.insert(windows, terminal)
    
    local explorer = FileExplorer.createWindow()
    explorer.Parent = frame
    table.insert(windows, explorer)
    
    -- Add personality effects
    PersonalityEffects.applyEffect(frame, "VISUAL")
    
    return frame
end

return GameInterface 