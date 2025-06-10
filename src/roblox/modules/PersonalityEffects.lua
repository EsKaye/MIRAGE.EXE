-- PersonalityEffects Module
local PersonalityEffects = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Constants
local PERSONALITY_COLORS = {
    SABLE = Color3.fromRGB(0, 0, 0),      -- Black
    NULL = Color3.fromRGB(255, 0, 0),     -- Red
    HONEY = Color3.fromRGB(255, 215, 0)   -- Gold
}

local PERSONALITY_SOUNDS = {
    SABLE = "rbxassetid://1234567890",    -- Replace with actual sound IDs
    NULL = "rbxassetid://1234567891",
    HONEY = "rbxassetid://1234567892"
}

-- Helper functions
local function createSound(parent, soundId)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Parent = parent
    return sound
end

local function createParticleEmitter(parent, color)
    local emitter = Instance.new("ParticleEmitter")
    emitter.Color = ColorSequence.new(color)
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 0)
    })
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    emitter.Rate = 50
    emitter.Speed = NumberRange.new(5, 10)
    emitter.Lifetime = NumberRange.new(0.5, 1)
    emitter.SpreadAngle = Vector2.new(45, 45)
    emitter.Parent = parent
    return emitter
end

-- SABLE effects
function PersonalityEffects.applySableEffects(window)
    -- Dark theme
    window.BackgroundColor3 = PERSONALITY_COLORS.SABLE
    window.BackgroundTransparency = 0.1

    -- Add subtle particle effect
    local emitter = createParticleEmitter(window, PERSONALITY_COLORS.SABLE)
    emitter.Enabled = true

    -- Add ambient sound
    local sound = createSound(window, PERSONALITY_SOUNDS.SABLE)
    sound.Volume = 0.3
    sound.Looped = true
    sound:Play()

    -- Add typing sound
    local typingSound = createSound(window, PERSONALITY_SOUNDS.SABLE)
    typingSound.Volume = 0.2

    return {
        cleanup = function()
            emitter:Destroy()
            sound:Destroy()
            typingSound:Destroy()
        end,
        playTypingSound = function()
            typingSound:Play()
        end
    }
end

-- NULL effects
function PersonalityEffects.applyNullEffects(window)
    -- Red theme with corruption
    window.BackgroundColor3 = PERSONALITY_COLORS.NULL
    window.BackgroundTransparency = 0.2

    -- Add aggressive particle effect
    local emitter = createParticleEmitter(window, PERSONALITY_COLORS.NULL)
    emitter.Enabled = true
    emitter.Rate = 100
    emitter.Speed = NumberRange.new(10, 20)

    -- Add corrupted sound
    local sound = createSound(window, PERSONALITY_SOUNDS.NULL)
    sound.Volume = 0.4
    sound.Looped = true
    sound:Play()

    -- Add glitch sound
    local glitchSound = createSound(window, PERSONALITY_SOUNDS.NULL)
    glitchSound.Volume = 0.3

    return {
        cleanup = function()
            emitter:Destroy()
            sound:Destroy()
            glitchSound:Destroy()
        end,
        playGlitchSound = function()
            glitchSound:Play()
        end
    }
end

-- HONEY effects
function PersonalityEffects.applyHoneyEffects(window)
    -- Gold theme
    window.BackgroundColor3 = PERSONALITY_COLORS.HONEY
    window.BackgroundTransparency = 0.15

    -- Add sparkle particle effect
    local emitter = createParticleEmitter(window, PERSONALITY_COLORS.HONEY)
    emitter.Enabled = true
    emitter.Rate = 30
    emitter.Speed = NumberRange.new(2, 5)
    emitter.Lifetime = NumberRange.new(0.3, 0.6)

    -- Add ambient sound
    local sound = createSound(window, PERSONALITY_SOUNDS.HONEY)
    sound.Volume = 0.3
    sound.Looped = true
    sound:Play()

    -- Add notification sound
    local notificationSound = createSound(window, PERSONALITY_SOUNDS.HONEY)
    notificationSound.Volume = 0.2

    return {
        cleanup = function()
            emitter:Destroy()
            sound:Destroy()
            notificationSound:Destroy()
        end,
        playNotificationSound = function()
            notificationSound:Play()
        end
    }
end

-- Apply personality-specific effects to text
function PersonalityEffects.applyToText(textLabel, personality)
    local color = PERSONALITY_COLORS[personality]
    if not color then return end

    -- Apply personality-specific text styling
    textLabel.TextColor3 = color
    textLabel.Font = Enum.Font.Code
    textLabel.TextSize = 14

    -- Add subtle animation
    local originalSize = textLabel.TextSize
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local function animateText()
        local tween = TweenService:Create(textLabel, tweenInfo, {
            TextSize = originalSize + 2
        })
        tween:Play()
        tween.Completed:Connect(function()
            TweenService:Create(textLabel, tweenInfo, {
                TextSize = originalSize
            }):Play()
        end)
    end

    return {
        animate = animateText
    }
end

return PersonalityEffects 