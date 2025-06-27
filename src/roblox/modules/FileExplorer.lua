-- FileExplorer Module
local FileExplorer = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Modules
local FileSystem = require(script.Parent.FileSystem)
local UIComponents = require(script.Parent.UIComponents)
local PersonalityEffects = require(script.Parent.PersonalityEffects)

-- Constants
local EXPLORER_DEFAULTS = {
    width = 800,
    height = 600,
    titleHeight = 30,
    padding = 10,
    cornerRadius = 8,
    backgroundColor = Color3.fromRGB(20, 20, 20),
    titleColor = Color3.fromRGB(30, 30, 30),
    textColor = Color3.fromRGB(0, 255, 0),
    hoverColor = Color3.fromRGB(40, 40, 40),
    selectedColor = Color3.fromRGB(60, 60, 60),
    iconSize = 32,
    itemHeight = 40,
    maxPathLength = 50
}

-- State
local currentPath = "/"
local selectedItems = {}
local sortOrder = "name"
local viewMode = "list" -- list or grid
local searchQuery = ""

-- Helper functions
local function createIcon(iconType)
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, EXPLORER_DEFAULTS.iconSize, 0, EXPLORER_DEFAULTS.iconSize)
    icon.BackgroundTransparency = 1
    icon.Image = FileSystem.getFileIcon(iconType)
    return icon
end

local function createItemFrame(name, type, isDirectory)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, EXPLORER_DEFAULTS.itemHeight)
    frame.BackgroundColor3 = EXPLORER_DEFAULTS.backgroundColor
    frame.BorderSizePixel = 0
    
    -- Add corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, EXPLORER_DEFAULTS.cornerRadius)
    corner.Parent = frame
    
    -- Add icon
    local icon = createIcon(type)
    icon.Position = UDim2.new(0, EXPLORER_DEFAULTS.padding, 0.5, -EXPLORER_DEFAULTS.iconSize/2)
    icon.Parent = frame
    
    -- Add name label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -EXPLORER_DEFAULTS.iconSize - EXPLORER_DEFAULTS.padding * 3, 1, 0)
    label.Position = UDim2.new(0, EXPLORER_DEFAULTS.iconSize + EXPLORER_DEFAULTS.padding * 2, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = EXPLORER_DEFAULTS.textColor
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Font = Enum.Font.Code
    label.TextSize = 14
    label.Parent = frame
    
    -- Add hover effect
    local function onHover()
        if not selectedItems[name] then
            TweenService:Create(frame, TweenInfo.new(0.2), {
                BackgroundColor3 = EXPLORER_DEFAULTS.hoverColor
            }):Play()
        end
    end
    
    local function onUnhover()
        if not selectedItems[name] then
            TweenService:Create(frame, TweenInfo.new(0.2), {
                BackgroundColor3 = EXPLORER_DEFAULTS.backgroundColor
            }):Play()
        end
    end
    
    frame.MouseEnter:Connect(onHover)
    frame.MouseLeave:Connect(onUnhover)
    
    -- Add click handler
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                -- Toggle selection
                selectedItems[name] = not selectedItems[name]
                frame.BackgroundColor3 = selectedItems[name] and EXPLORER_DEFAULTS.selectedColor or EXPLORER_DEFAULTS.backgroundColor
            else
                -- Clear other selections and select this
                for itemName, _ in pairs(selectedItems) do
                    selectedItems[itemName] = false
                end
                selectedItems[name] = true
                frame.BackgroundColor3 = EXPLORER_DEFAULTS.selectedColor
                
                -- If directory, navigate to it
                if isDirectory then
                    navigateTo(currentPath .. name .. "/")
                end
            end
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            -- Show context menu
            showContextMenu(frame, name, type, isDirectory)
        end
    end)
    
    return frame
end

local function showContextMenu(parent, name, type, isDirectory)
    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0, 200, 0, 0)
    menu.Position = UDim2.new(0, parent.AbsolutePosition.X, 0, parent.AbsolutePosition.Y)
    menu.BackgroundColor3 = EXPLORER_DEFAULTS.backgroundColor
    menu.BorderSizePixel = 0
    
    -- Add corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, EXPLORER_DEFAULTS.cornerRadius)
    corner.Parent = menu
    
    -- Add menu items
    local items = {
        {text = "Open", action = function()
            if isDirectory then
                navigateTo(currentPath .. name .. "/")
            else
                openFile(currentPath .. name)
            end
        end},
        {text = "Copy", action = function()
            -- TODO: Implement copy
        end},
        {text = "Cut", action = function()
            -- TODO: Implement cut
        end},
        {text = "Delete", action = function()
            -- TODO: Implement delete
        end},
        {text = "Rename", action = function()
            -- TODO: Implement rename
        end}
    }
    
    local yOffset = 0
    for _, item in ipairs(items) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 30)
        button.Position = UDim2.new(0, 0, 0, yOffset)
        button.BackgroundColor3 = EXPLORER_DEFAULTS.backgroundColor
        button.BorderSizePixel = 0
        button.Text = item.text
        button.TextColor3 = EXPLORER_DEFAULTS.textColor
        button.Font = Enum.Font.Code
        button.TextSize = 14
        button.Parent = menu
        
        -- Add hover effect
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = EXPLORER_DEFAULTS.hoverColor
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = EXPLORER_DEFAULTS.backgroundColor
            }):Play()
        end)
        
        -- Add click handler
        button.MouseButton1Click:Connect(function()
            item.action()
            menu:Destroy()
        end)
        
        yOffset = yOffset + 30
    end
    
    menu.Size = UDim2.new(0, 200, 0, yOffset)
    menu.Parent = parent.Parent
end

local function updatePathDisplay(pathDisplay)
    local displayText = currentPath
    if #displayText > EXPLORER_DEFAULTS.maxPathLength then
        displayText = "..." .. displayText:sub(-EXPLORER_DEFAULTS.maxPathLength + 3)
    end
    pathDisplay.Text = displayText
end

local function updateFileList(fileList)
    -- Clear existing items
    for _, child in ipairs(fileList:GetChildren()) do
        child:Destroy()
    end
    
    -- Get directory contents
    local items = FileSystem.listDirectory(currentPath)
    if not items then return end
    
    -- Sort items
    table.sort(items, function(a, b)
        if a.isDirectory ~= b.isDirectory then
            return a.isDirectory
        end
        if sortOrder == "name" then
            return a.name:lower() < b.name:lower()
        elseif sortOrder == "type" then
            return a.type < b.type
        elseif sortOrder == "date" then
            return a.modified > b.modified
        end
    end)
    
    -- Filter by search query
    if searchQuery ~= "" then
        local filtered = {}
        for _, item in ipairs(items) do
            if item.name:lower():find(searchQuery:lower()) then
                table.insert(filtered, item)
            end
        end
        items = filtered
    end
    
    -- Create item frames
    local yOffset = 0
    for _, item in ipairs(items) do
        local frame = createItemFrame(item.name, item.type, item.isDirectory)
        frame.Position = UDim2.new(0, 0, 0, yOffset)
        frame.Parent = fileList
        yOffset = yOffset + EXPLORER_DEFAULTS.itemHeight
    end
    
    -- Update fileList size
    fileList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

local function navigateTo(path)
    if FileSystem.changeDirectory(path) then
        currentPath = path
        -- Update UI
        -- TODO: Implement UI updates
    end
end

local function openFile(path)
    local info = FileSystem.getFileInfo(path)
    if not info then return end
    
    -- TODO: Implement file opening based on type
    print("Opening file:", path)
end

-- Main function to create the explorer window
function FileExplorer.createWindow()
    -- Create main frame
    local frame = UIComponents.createWindow({
        title = "File Explorer",
        width = EXPLORER_DEFAULTS.width,
        height = EXPLORER_DEFAULTS.height,
        titleHeight = EXPLORER_DEFAULTS.titleHeight,
        padding = EXPLORER_DEFAULTS.padding,
        cornerRadius = EXPLORER_DEFAULTS.cornerRadius,
        backgroundColor = EXPLORER_DEFAULTS.backgroundColor,
        titleColor = EXPLORER_DEFAULTS.titleColor,
        textColor = EXPLORER_DEFAULTS.textColor
    })
    
    -- Create toolbar
    local toolbar = Instance.new("Frame")
    toolbar.Size = UDim2.new(1, 0, 0, 40)
    toolbar.Position = UDim2.new(0, 0, 0, EXPLORER_DEFAULTS.titleHeight)
    toolbar.BackgroundColor3 = EXPLORER_DEFAULTS.titleColor
    toolbar.BorderSizePixel = 0
    toolbar.Parent = frame
    
    -- Add back button
    local backButton = UIComponents.createButton({
        text = "←",
        size = UDim2.new(0, 40, 1, 0),
        position = UDim2.new(0, EXPLORER_DEFAULTS.padding, 0, 0),
        parent = toolbar
    })
    
    -- Add path display
    local pathDisplay = Instance.new("TextLabel")
    pathDisplay.Size = UDim2.new(1, -100, 1, 0)
    pathDisplay.Position = UDim2.new(0, 50, 0, 0)
    pathDisplay.BackgroundTransparency = 1
    pathDisplay.Text = currentPath
    pathDisplay.TextColor3 = EXPLORER_DEFAULTS.textColor
    pathDisplay.TextXAlignment = Enum.TextXAlignment.Left
    pathDisplay.TextYAlignment = Enum.TextYAlignment.Center
    pathDisplay.Font = Enum.Font.Code
    pathDisplay.TextSize = 14
    pathDisplay.Parent = toolbar
    
    -- Add search box
    local searchBox = UIComponents.createTextInput({
        placeholder = "Search...",
        size = UDim2.new(0, 200, 0, 30),
        position = UDim2.new(1, -210, 0.5, -15),
        parent = toolbar
    })
    
    -- Create file list
    local fileList = Instance.new("ScrollingFrame")
    fileList.Size = UDim2.new(1, 0, 1, -EXPLORER_DEFAULTS.titleHeight - 40)
    fileList.Position = UDim2.new(0, 0, 0, EXPLORER_DEFAULTS.titleHeight + 40)
    fileList.BackgroundTransparency = 1
    fileList.BorderSizePixel = 0
    fileList.ScrollBarThickness = 6
    fileList.ScrollingDirection = Enum.ScrollingDirection.Y
    fileList.CanvasSize = UDim2.new(0, 0, 0, 0)
    fileList.Parent = frame
    
    -- Add list layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 2)
    listLayout.Parent = fileList
    
    -- Connect events
    backButton.MouseButton1Click:Connect(function()
        local parentPath = currentPath:match("(.*/)[^/]*/$")
        if parentPath then
            navigateTo(parentPath)
        end
    end)
    
    searchBox.FocusLost:Connect(function()
        searchQuery = searchBox.Text
        updateFileList(fileList)
    end)
    
    -- Initial update
    updatePathDisplay(pathDisplay)
    updateFileList(fileList)
    
    return frame
end

return FileExplorer 