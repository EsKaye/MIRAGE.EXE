-- Settings Module
local Settings = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Modules
local UIComponents = require(script.Parent.UIComponents)
local PersonalityState = require(script.Parent.PersonalityState)
local PersonalityEffects = require(script.Parent.PersonalityEffects)

-- Constants
local SETTINGS_DEFAULTS = {
    width = 600,
    height = 400,
    titleHeight = 30,
    padding = 10,
    cornerRadius = 8,
    backgroundColor = Color3.fromRGB(20, 20, 20),
    titleColor = Color3.fromRGB(30, 30, 30),
    textColor = Color3.fromRGB(0, 255, 0),
    hoverColor = Color3.fromRGB(40, 40, 40),
    selectedColor = Color3.fromRGB(60, 60, 60),
    sectionHeight = 40,
    optionHeight = 30
}

-- Default settings
local defaultSettings = {
    visual = {
        theme = "dark",
        glitchIntensity = 0.5,
        particleEffects = true,
        screenEffects = true
    },
    audio = {
        masterVolume = 1,
        musicVolume = 0.7,
        effectsVolume = 0.8,
        ambientVolume = 0.5
    },
    personality = {
        defaultPersonality = "SABLE",
        trustThreshold = 50,
        corruptionThreshold = 25
    },
    system = {
        autoSave = true,
        saveInterval = 300, -- 5 minutes
        maxHistory = 100,
        showHiddenFiles = false
    }
}

-- Current settings
local currentSettings = table.clone(defaultSettings)

-- Helper functions
local function createSection(parent, title, yOffset)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, SETTINGS_DEFAULTS.sectionHeight)
    section.Position = UDim2.new(0, 0, 0, yOffset)
    section.BackgroundColor3 = SETTINGS_DEFAULTS.titleColor
    section.BorderSizePixel = 0
    section.Parent = parent
    
    -- Add corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, SETTINGS_DEFAULTS.cornerRadius)
    corner.Parent = section
    
    -- Add title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -SETTINGS_DEFAULTS.padding * 2, 1, 0)
    titleLabel.Position = UDim2.new(0, SETTINGS_DEFAULTS.padding, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = SETTINGS_DEFAULTS.textColor
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.Font = Enum.Font.Code
    titleLabel.TextSize = 16
    titleLabel.Parent = section
    
    return section
end

local function createToggle(parent, label, value, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, SETTINGS_DEFAULTS.optionHeight)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    -- Add label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = label
    label.TextColor3 = SETTINGS_DEFAULTS.textColor
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Font = Enum.Font.Code
    label.TextSize = 14
    label.Parent = frame
    
    -- Add toggle
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -50, 0.5, -10)
    toggle.BackgroundColor3 = value and SETTINGS_DEFAULTS.selectedColor or SETTINGS_DEFAULTS.backgroundColor
    toggle.BorderSizePixel = 0
    toggle.Parent = frame
    
    -- Add corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = toggle
    
    -- Add knob
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 2, 0, 2)
    knob.BackgroundColor3 = SETTINGS_DEFAULTS.textColor
    knob.BorderSizePixel = 0
    knob.Parent = toggle
    
    -- Add corner
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(0, 8)
    knobCorner.Parent = knob
    
    -- Add click handler
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            value = not value
            toggle.BackgroundColor3 = value and SETTINGS_DEFAULTS.selectedColor or SETTINGS_DEFAULTS.backgroundColor
            TweenService:Create(knob, TweenInfo.new(0.2), {
                Position = value and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2)
            }):Play()
            if callback then
                callback(value)
            end
        end
    end)
    
    return frame
end

local function createSlider(parent, label, min, max, value, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, SETTINGS_DEFAULTS.optionHeight)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    -- Add label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -100, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = label
    label.TextColor3 = SETTINGS_DEFAULTS.textColor
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Font = Enum.Font.Code
    label.TextSize = 14
    label.Parent = frame
    
    -- Add slider
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0, 80, 0, 4)
    slider.Position = UDim2.new(1, -90, 0.5, -2)
    slider.BackgroundColor3 = SETTINGS_DEFAULTS.backgroundColor
    slider.BorderSizePixel = 0
    slider.Parent = frame
    
    -- Add corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 2)
    corner.Parent = slider
    
    -- Add fill
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(value, 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = SETTINGS_DEFAULTS.selectedColor
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    -- Add corner
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = fill
    
    -- Add knob
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new(value, -6, 0.5, -6)
    knob.BackgroundColor3 = SETTINGS_DEFAULTS.textColor
    knob.BorderSizePixel = 0
    knob.Parent = slider
    
    -- Add corner
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(0, 6)
    knobCorner.Parent = knob
    
    -- Add value label
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 40, 1, 0)
    valueLabel.Position = UDim2.new(1, -40, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = string.format("%.0f%%", value * 100)
    valueLabel.TextColor3 = SETTINGS_DEFAULTS.textColor
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.TextYAlignment = Enum.TextYAlignment.Center
    valueLabel.Font = Enum.Font.Code
    valueLabel.TextSize = 14
    valueLabel.Parent = frame
    
    -- Add drag handler
    local dragging = false
    local dragStart
    local startValue
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position.X
            startValue = value
        end
    end)
    
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragging then
                local delta = (input.Position.X - dragStart) / slider.AbsoluteSize.X
                value = math.clamp(startValue + delta, 0, 1)
                fill.Size = UDim2.new(value, 0, 1, 0)
                knob.Position = UDim2.new(value, -6, 0.5, -6)
                valueLabel.Text = string.format("%.0f%%", value * 100)
                if callback then
                    callback(value)
                end
            end
        end
    end)
    
    return frame
end

local function createDropdown(parent, label, options, value, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, SETTINGS_DEFAULTS.optionHeight)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    -- Add label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -120, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = label
    label.TextColor3 = SETTINGS_DEFAULTS.textColor
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Font = Enum.Font.Code
    label.TextSize = 14
    label.Parent = frame
    
    -- Add dropdown
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(0, 100, 0, 30)
    dropdown.Position = UDim2.new(1, -110, 0.5, -15)
    dropdown.BackgroundColor3 = SETTINGS_DEFAULTS.backgroundColor
    dropdown.BorderSizePixel = 0
    dropdown.Parent = frame
    
    -- Add corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, SETTINGS_DEFAULTS.cornerRadius)
    corner.Parent = dropdown
    
    -- Add selected value
    local selected = Instance.new("TextLabel")
    selected.Size = UDim2.new(1, -30, 1, 0)
    selected.Position = UDim2.new(0, 10, 0, 0)
    selected.BackgroundTransparency = 1
    selected.Text = value
    selected.TextColor3 = SETTINGS_DEFAULTS.textColor
    selected.TextXAlignment = Enum.TextXAlignment.Left
    selected.TextYAlignment = Enum.TextYAlignment.Center
    selected.Font = Enum.Font.Code
    selected.TextSize = 14
    selected.Parent = dropdown
    
    -- Add arrow
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -20, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = SETTINGS_DEFAULTS.textColor
    arrow.TextXAlignment = Enum.TextXAlignment.Center
    arrow.TextYAlignment = Enum.TextYAlignment.Center
    arrow.Font = Enum.Font.Code
    arrow.TextSize = 12
    arrow.Parent = dropdown
    
    -- Add dropdown menu
    local menu = Instance.new("Frame")
    menu.Size = UDim2.new(0, 100, 0, 0)
    menu.Position = UDim2.new(1, -110, 1, 5)
    menu.BackgroundColor3 = SETTINGS_DEFAULTS.backgroundColor
    menu.BorderSizePixel = 0
    menu.Visible = false
    menu.Parent = frame
    
    -- Add corner
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, SETTINGS_DEFAULTS.cornerRadius)
    menuCorner.Parent = menu
    
    -- Add options
    local yOffset = 0
    for _, option in ipairs(options) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 30)
        button.Position = UDim2.new(0, 0, 0, yOffset)
        button.BackgroundColor3 = SETTINGS_DEFAULTS.backgroundColor
        button.BorderSizePixel = 0
        button.Text = option
        button.TextColor3 = SETTINGS_DEFAULTS.textColor
        button.Font = Enum.Font.Code
        button.TextSize = 14
        button.Parent = menu
        
        -- Add hover effect
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = SETTINGS_DEFAULTS.hoverColor
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = SETTINGS_DEFAULTS.backgroundColor
            }):Play()
        end)
        
        -- Add click handler
        button.MouseButton1Click:Connect(function()
            value = option
            selected.Text = value
            menu.Visible = false
            if callback then
                callback(value)
            end
        end)
        
        yOffset = yOffset + 30
    end
    
    menu.Size = UDim2.new(0, 100, 0, yOffset)
    
    -- Add click handler
    dropdown.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            menu.Visible = not menu.Visible
            arrow.Text = menu.Visible and "▲" or "▼"
        end
    end)
    
    return frame
end

-- Main function to create the settings window
function Settings.createWindow()
    -- Create main frame
    local frame = UIComponents.createWindow({
        title = "Settings",
        width = SETTINGS_DEFAULTS.width,
        height = SETTINGS_DEFAULTS.height,
        titleHeight = SETTINGS_DEFAULTS.titleHeight,
        padding = SETTINGS_DEFAULTS.padding,
        cornerRadius = SETTINGS_DEFAULTS.cornerRadius,
        backgroundColor = SETTINGS_DEFAULTS.backgroundColor,
        titleColor = SETTINGS_DEFAULTS.titleColor,
        textColor = SETTINGS_DEFAULTS.textColor
    })
    
    -- Create content area
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, 0, 1, -SETTINGS_DEFAULTS.titleHeight)
    content.Position = UDim2.new(0, 0, 0, SETTINGS_DEFAULTS.titleHeight)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 6
    content.ScrollingDirection = Enum.ScrollingDirection.Y
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.Parent = frame
    
    -- Create sections
    local yOffset = SETTINGS_DEFAULTS.padding
    
    -- Visual settings
    local visualSection = createSection(content, "Visual Settings", yOffset)
    yOffset = yOffset + SETTINGS_DEFAULTS.sectionHeight + SETTINGS_DEFAULTS.padding
    
    createDropdown(visualSection, "Theme", {"dark", "light", "custom"}, currentSettings.visual.theme, function(value)
        currentSettings.visual.theme = value
    end)
    
    createSlider(visualSection, "Glitch Intensity", 0, 1, currentSettings.visual.glitchIntensity, function(value)
        currentSettings.visual.glitchIntensity = value
        PersonalityEffects.updateGlitchIntensity(value)
    end)
    
    createToggle(visualSection, "Particle Effects", currentSettings.visual.particleEffects, function(value)
        currentSettings.visual.particleEffects = value
    end)
    
    createToggle(visualSection, "Screen Effects", currentSettings.visual.screenEffects, function(value)
        currentSettings.visual.screenEffects = value
    end)
    
    -- Audio settings
    yOffset = yOffset + visualSection.Size.Y.Offset + SETTINGS_DEFAULTS.padding
    local audioSection = createSection(content, "Audio Settings", yOffset)
    yOffset = yOffset + SETTINGS_DEFAULTS.sectionHeight + SETTINGS_DEFAULTS.padding
    
    createSlider(audioSection, "Master Volume", 0, 1, currentSettings.audio.masterVolume, function(value)
        currentSettings.audio.masterVolume = value
    end)
    
    createSlider(audioSection, "Music Volume", 0, 1, currentSettings.audio.musicVolume, function(value)
        currentSettings.audio.musicVolume = value
    end)
    
    createSlider(audioSection, "Effects Volume", 0, 1, currentSettings.audio.effectsVolume, function(value)
        currentSettings.audio.effectsVolume = value
    end)
    
    createSlider(audioSection, "Ambient Volume", 0, 1, currentSettings.audio.ambientVolume, function(value)
        currentSettings.audio.ambientVolume = value
    end)
    
    -- Personality settings
    yOffset = yOffset + audioSection.Size.Y.Offset + SETTINGS_DEFAULTS.padding
    local personalitySection = createSection(content, "Personality Settings", yOffset)
    yOffset = yOffset + SETTINGS_DEFAULTS.sectionHeight + SETTINGS_DEFAULTS.padding
    
    createDropdown(personalitySection, "Default Personality", {"SABLE", "NULL", "HONEY"}, currentSettings.personality.defaultPersonality, function(value)
        currentSettings.personality.defaultPersonality = value
    end)
    
    createSlider(personalitySection, "Trust Threshold", 0, 100, currentSettings.personality.trustThreshold / 100, function(value)
        currentSettings.personality.trustThreshold = value * 100
    end)
    
    createSlider(personalitySection, "Corruption Threshold", 0, 100, currentSettings.personality.corruptionThreshold / 100, function(value)
        currentSettings.personality.corruptionThreshold = value * 100
    end)
    
    -- System settings
    yOffset = yOffset + personalitySection.Size.Y.Offset + SETTINGS_DEFAULTS.padding
    local systemSection = createSection(content, "System Settings", yOffset)
    yOffset = yOffset + SETTINGS_DEFAULTS.sectionHeight + SETTINGS_DEFAULTS.padding
    
    createToggle(systemSection, "Auto Save", currentSettings.system.autoSave, function(value)
        currentSettings.system.autoSave = value
    end)
    
    createSlider(systemSection, "Save Interval", 1, 10, currentSettings.system.saveInterval / 600, function(value)
        currentSettings.system.saveInterval = value * 600
    end)
    
    createSlider(systemSection, "Max History", 10, 1000, currentSettings.system.maxHistory / 1000, function(value)
        currentSettings.system.maxHistory = value * 1000
    end)
    
    createToggle(systemSection, "Show Hidden Files", currentSettings.system.showHiddenFiles, function(value)
        currentSettings.system.showHiddenFiles = value
    end)
    
    -- Add buttons
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0, 40)
    buttonFrame.Position = UDim2.new(0, 0, 1, -40)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = frame
    
    local saveButton = UIComponents.createButton({
        text = "Save",
        size = UDim2.new(0, 100, 0, 30),
        position = UDim2.new(1, -220, 0.5, -15),
        parent = buttonFrame
    })
    
    local resetButton = UIComponents.createButton({
        text = "Reset",
        size = UDim2.new(0, 100, 0, 30),
        position = UDim2.new(1, -110, 0.5, -15),
        parent = buttonFrame
    })
    
    local closeButton = UIComponents.createButton({
        text = "Close",
        size = UDim2.new(0, 100, 0, 30),
        position = UDim2.new(1, 0, 0.5, -15),
        parent = buttonFrame
    })
    
    -- Connect button events
    saveButton.MouseButton1Click:Connect(function()
        -- TODO: Save settings
        frame:Destroy()
    end)
    
    resetButton.MouseButton1Click:Connect(function()
        currentSettings = table.clone(defaultSettings)
        -- TODO: Reset UI
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        frame:Destroy()
    end)
    
    return frame
end

-- Get current settings
function Settings.getSettings()
    return currentSettings
end

-- Reset settings to default
function Settings.resetSettings()
    currentSettings = table.clone(defaultSettings)
end

-- Save settings
function Settings.saveSettings()
    -- TODO: Implement settings persistence
end

-- Load settings
function Settings.loadSettings()
    -- TODO: Implement settings loading
end

return Settings 