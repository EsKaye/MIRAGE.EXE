-- GlitchEffect Module
local GlitchEffect = {}

-- Constants
local GLITCH_COLORS = {
    Color3.fromRGB(255, 0, 255),   -- Magenta
    Color3.fromRGB(0, 255, 255),   -- Cyan
    Color3.fromRGB(255, 255, 0)    -- Yellow
}

-- Helper functions
local function randomColor()
    return GLITCH_COLORS[math.random(1, #GLITCH_COLORS)]
end

local function randomOffset()
    return math.random(-5, 5)
end

-- Apply glitch effect to text
function GlitchEffect.applyToText(textLabel, intensity)
    if not textLabel:IsA("TextLabel") and not textLabel:IsA("TextButton") then
        return
    end

    local originalText = textLabel.Text
    local originalColor = textLabel.TextColor3
    local originalPosition = textLabel.Position

    -- Create glitch copies
    local copies = {}
    for i = 1, 3 do
        local copy = textLabel:Clone()
        copy.Parent = textLabel.Parent
        copy.TextColor3 = randomColor()
        copy.Position = UDim2.new(
            originalPosition.X.Scale,
            originalPosition.X.Offset + randomOffset(),
            originalPosition.Y.Scale,
            originalPosition.Y.Offset + randomOffset()
        )
        copy.TextTransparency = 0.5
        table.insert(copies, copy)
    end

    -- Animate glitch
    spawn(function()
        while true do
            wait(0.1 * (1 - intensity))
            
            -- Randomly modify original text
            if math.random() < intensity then
                textLabel.Text = string.gsub(originalText, ".", function()
                    return math.random() < 0.1 and string.char(math.random(33, 126)) or ""
                end)
            else
                textLabel.Text = originalText
            end

            -- Update copies
            for _, copy in ipairs(copies) do
                copy.TextColor3 = randomColor()
                copy.Position = UDim2.new(
                    originalPosition.X.Scale,
                    originalPosition.X.Offset + randomOffset(),
                    originalPosition.Y.Scale,
                    originalPosition.Y.Offset + randomOffset()
                )
            end
        end
    end)

    -- Cleanup function
    return function()
        for _, copy in ipairs(copies) do
            copy:Destroy()
        end
        textLabel.Text = originalText
        textLabel.TextColor3 = originalColor
        textLabel.Position = originalPosition
    end
end

-- Apply glitch effect to frame
function GlitchEffect.applyToFrame(frame, intensity)
    if not frame:IsA("Frame") and not frame:IsA("ImageLabel") then
        return
    end

    local originalColor = frame.BackgroundColor3
    local originalPosition = frame.Position
    local originalSize = frame.Size

    -- Create glitch copies
    local copies = {}
    for i = 1, 2 do
        local copy = frame:Clone()
        copy.Parent = frame.Parent
        copy.BackgroundColor3 = randomColor()
        copy.BackgroundTransparency = 0.7
        copy.Position = UDim2.new(
            originalPosition.X.Scale,
            originalPosition.X.Offset + randomOffset(),
            originalPosition.Y.Scale,
            originalPosition.Y.Offset + randomOffset()
        )
        table.insert(copies, copy)
    end

    -- Animate glitch
    spawn(function()
        while true do
            wait(0.2 * (1 - intensity))
            
            -- Randomly modify original frame
            if math.random() < intensity then
                frame.BackgroundColor3 = randomColor()
                frame.Position = UDim2.new(
                    originalPosition.X.Scale,
                    originalPosition.X.Offset + randomOffset(),
                    originalPosition.Y.Scale,
                    originalPosition.Y.Offset + randomOffset()
                )
            else
                frame.BackgroundColor3 = originalColor
                frame.Position = originalPosition
            end

            -- Update copies
            for _, copy in ipairs(copies) do
                copy.BackgroundColor3 = randomColor()
                copy.Position = UDim2.new(
                    originalPosition.X.Scale,
                    originalPosition.X.Offset + randomOffset(),
                    originalPosition.Y.Scale,
                    originalPosition.Y.Offset + randomOffset()
                )
            end
        end
    end)

    -- Cleanup function
    return function()
        for _, copy in ipairs(copies) do
            copy:Destroy()
        end
        frame.BackgroundColor3 = originalColor
        frame.Position = originalPosition
        frame.Size = originalSize
    end
end

-- Apply screen glitch effect
function GlitchEffect.applyToScreen(screenGui, intensity)
    local glitchFrame = Instance.new("Frame")
    glitchFrame.Name = "GlitchOverlay"
    glitchFrame.Size = UDim2.new(1, 0, 1, 0)
    glitchFrame.BackgroundTransparency = 1
    glitchFrame.Parent = screenGui

    -- Create scan lines
    for i = 1, 20 do
        local line = Instance.new("Frame")
        line.Name = "ScanLine" .. i
        line.Size = UDim2.new(1, 0, 0, 1)
        line.Position = UDim2.new(0, 0, 0, (i - 1) * 0.05)
        line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        line.BackgroundTransparency = 0.9
        line.Parent = glitchFrame
    end

    -- Animate glitch
    spawn(function()
        while true do
            wait(0.1 * (1 - intensity))
            
            if math.random() < intensity then
                -- Random scan line glitch
                for _, line in ipairs(glitchFrame:GetChildren()) do
                    if math.random() < 0.3 then
                        line.BackgroundTransparency = math.random() * 0.5
                        line.BackgroundColor3 = randomColor()
                    end
                end

                -- Screen shake
                if math.random() < 0.2 then
                    local originalPosition = screenGui.Position
                    screenGui.Position = UDim2.new(
                        originalPosition.X.Scale,
                        originalPosition.X.Offset + randomOffset(),
                        originalPosition.Y.Scale,
                        originalPosition.Y.Offset + randomOffset()
                    )
                    wait(0.05)
                    screenGui.Position = originalPosition
                end
            end
        end
    end)

    -- Cleanup function
    return function()
        glitchFrame:Destroy()
    end
end

return GlitchEffect 