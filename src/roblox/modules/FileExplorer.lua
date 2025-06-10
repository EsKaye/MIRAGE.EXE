-- FileExplorer Module
local FileExplorer = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Load modules
local FileSystem = require(ReplicatedStorage.Modules.FileSystem)
local GlitchEffect = require(ReplicatedStorage.Modules.GlitchEffect)

-- Constants
local ITEM_HEIGHT = 30
local ITEM_PADDING = 5
local ICON_SIZE = 20

-- Helper functions
local function createItemFrame(parent, item)
    local frame = Instance.new("Frame")
    frame.Name = item.name
    frame.Size = UDim2.new(1, 0, 0, ITEM_HEIGHT)
    frame.BackgroundTransparency = 1

    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, ICON_SIZE, 1, 0)
    icon.Position = UDim2.new(0, ITEM_PADDING, 0, 0)
    icon.BackgroundTransparency = 1
    icon.Text = item.icon
    icon.TextSize = 16
    icon.Font = Enum.Font.Code
    icon.TextXAlignment = Enum.TextXAlignment.Left
    icon.Parent = frame

    local name = Instance.new("TextLabel")
    name.Name = "Name"
    name.Size = UDim2.new(1, -ICON_SIZE - ITEM_PADDING * 3, 1, 0)
    name.Position = UDim2.new(0, ICON_SIZE + ITEM_PADDING * 2, 0, 0)
    name.BackgroundTransparency = 1
    name.Text = item.name
    name.TextSize = 14
    name.Font = Enum.Font.Code
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.TextYAlignment = Enum.TextYAlignment.Center
    name.Parent = frame

    local size = Instance.new("TextLabel")
    size.Name = "Size"
    size.Size = UDim2.new(0, 100, 1, 0)
    size.Position = UDim2.new(1, -100, 0, 0)
    size.BackgroundTransparency = 1
    size.Text = item.type == "directory" and "" or string.format("%d bytes", item.size)
    size.TextSize = 12
    size.Font = Enum.Font.Code
    size.TextXAlignment = Enum.TextXAlignment.Right
    size.TextYAlignment = Enum.TextYAlignment.Center
    size.Parent = frame

    frame.Parent = parent
    return frame
end

-- Create file explorer window
function FileExplorer.createWindow(parent, title)
    -- Create main window
    local window = Instance.new("Frame")
    window.Name = "FileExplorer"
    window.Size = UDim2.new(0.4, 0, 0.6, 0)
    window.Position = UDim2.new(0.3, 0, 0.2, 0)
    window.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    window.BorderSizePixel = 1
    window.BorderColor3 = Color3.fromRGB(100, 100, 100)
    window.Parent = parent

    -- Create title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = window

    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -20, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = title
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 14
    titleText.Font = Enum.Font.Code
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    -- Create path bar
    local pathBar = Instance.new("Frame")
    pathBar.Name = "PathBar"
    pathBar.Size = UDim2.new(1, 0, 0, 30)
    pathBar.Position = UDim2.new(0, 0, 0, 30)
    pathBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    pathBar.BorderSizePixel = 0
    pathBar.Parent = window

    local pathText = Instance.new("TextLabel")
    pathText.Name = "Path"
    pathText.Size = UDim2.new(1, -20, 1, 0)
    pathText.Position = UDim2.new(0, 10, 0, 0)
    pathText.BackgroundTransparency = 1
    pathText.Text = "C:"
    pathText.TextColor3 = Color3.fromRGB(200, 200, 200)
    pathText.TextSize = 12
    pathText.Font = Enum.Font.Code
    pathText.TextXAlignment = Enum.TextXAlignment.Left
    pathText.Parent = pathBar

    -- Create content area
    local contentArea = Instance.new("ScrollingFrame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, 0, 1, -60)
    contentArea.Position = UDim2.new(0, 0, 0, 60)
    contentArea.BackgroundTransparency = 1
    contentArea.BorderSizePixel = 0
    contentArea.ScrollBarThickness = 6
    contentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentArea.Parent = window

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, ITEM_PADDING)
    uiListLayout.Parent = contentArea

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

    -- Navigation functions
    local currentPath = "C:"

    local function updatePath(path)
        currentPath = path
        pathText.Text = path

        -- Clear content area
        for _, child in ipairs(contentArea:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end

        -- Load directory contents
        local items = FileSystem.listDirectory(path)
        if items then
            for _, item in ipairs(items) do
                local itemFrame = createItemFrame(contentArea, item)
                
                -- Handle item click
                itemFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if item.type == "directory" then
                            updatePath(currentPath .. "/" .. item.name)
                        else
                            -- Handle file click
                            local content = FileSystem.readFile(currentPath .. "/" .. item.name)
                            if content then
                                -- TODO: Open file viewer
                            end
                        end
                    end
                end)
            end
        end
    end

    -- Initialize with root directory
    updatePath(currentPath)

    -- Add navigation buttons
    local backButton = Instance.new("TextButton")
    backButton.Name = "BackButton"
    backButton.Size = UDim2.new(0, 60, 0, 20)
    backButton.Position = UDim2.new(0, 10, 0, 5)
    backButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    backButton.BorderSizePixel = 0
    backButton.Text = "Back"
    backButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    backButton.TextSize = 12
    backButton.Font = Enum.Font.Code
    backButton.Parent = pathBar

    backButton.MouseButton1Click:Connect(function()
        local parentPath = currentPath:match("(.*)/[^/]*$")
        if parentPath then
            updatePath(parentPath)
        end
    end)

    -- Add corruption effects
    local glitchCleanup = GlitchEffect.applyToScreen(window, 0.1)

    return {
        window = window,
        updatePath = updatePath,
        cleanup = function()
            glitchCleanup()
        end
    }
end

return FileExplorer 