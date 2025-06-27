-- PersonalityEffects Module
local PersonalityEffects = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Constants
local EFFECT_TYPES = {
    VISUAL = "visual",
    AUDIO = "audio",
    PARTICLE = "particle",
    GLITCH = "glitch"
}

-- Effect definitions
local EFFECTS = {
    SABLE = {
        visual = {
            color = Color3.fromRGB(0, 0, 0),
            transparency = 0.5,
            blur = 0.2
        },
        audio = {
            ambient = "rbxassetid://1234567890", -- Replace with actual sound ID
            volume = 0.5,
            pitch = 1.0
        },
        particle = {
            color = Color3.fromRGB(0, 0, 0),
            size = 0.1,
            speed = 5
        },
        glitch = {
            intensity = 0.1,
            frequency = 0.5
        }
    },
    NULL = {
        visual = {
            color = Color3.fromRGB(255, 0, 0),
            transparency = 0.3,
            blur = 0.5
        },
        audio = {
            ambient = "rbxassetid://0987654321", -- Replace with actual sound ID
            volume = 0.7,
            pitch = 0.8
        },
        particle = {
            color = Color3.fromRGB(255, 0, 0),
            size = 0.2,
            speed = 10
        },
        glitch = {
            intensity = 0.5,
            frequency = 1.0
        }
    },
    HONEY = {
        visual = {
            color = Color3.fromRGB(255, 215, 0),
            transparency = 0.7,
            blur = 0.1
        },
        audio = {
            ambient = "rbxassetid://5678901234", -- Replace with actual sound ID
            volume = 0.3,
            pitch = 1.2
        },
        particle = {
            color = Color3.fromRGB(255, 215, 0),
            size = 0.05,
            speed = 3
        },
        glitch = {
            intensity = 0.05,
            frequency = 0.2
        }
    }
}

-- Active effects
local activeEffects = {}

-- Helper functions
local function createEffectObject(parent, effectType, personality)
    local effect = Instance.new("Frame")
    effect.Name = personality .. "_" .. effectType
    effect.Size = UDim2.new(1, 0, 1, 0)
    effect.BackgroundTransparency = 1
    effect.Parent = parent

    if effectType == EFFECT_TYPES.VISUAL then
        local blur = Instance.new("BlurEffect")
        blur.Size = EFFECTS[personality].visual.blur
        blur.Parent = effect

        local colorCorrection = Instance.new("ColorCorrectionEffect")
        colorCorrection.TintColor = EFFECTS[personality].visual.color
        colorCorrection.Parent = effect
    elseif effectType == EFFECT_TYPES.AUDIO then
        local sound = Instance.new("Sound")
        sound.SoundId = EFFECTS[personality].audio.ambient
        sound.Volume = EFFECTS[personality].audio.volume
        sound.Pitch = EFFECTS[personality].audio.pitch
        sound.Looped = true
        sound.Parent = effect
    elseif effectType == EFFECT_TYPES.PARTICLE then
        local particleEmitter = Instance.new("ParticleEmitter")
        particleEmitter.Color = ColorSequence.new(EFFECTS[personality].particle.color)
        particleEmitter.Size = NumberSequence.new(EFFECTS[personality].particle.size)
        particleEmitter.Speed = NumberRange.new(EFFECTS[personality].particle.speed)
        particleEmitter.Parent = effect
    elseif effectType == EFFECT_TYPES.GLITCH then
        local glitchEffect = Instance.new("Frame")
        glitchEffect.Name = "GlitchEffect"
        glitchEffect.Size = UDim2.new(1, 0, 1, 0)
        glitchEffect.BackgroundTransparency = 1
        glitchEffect.Parent = effect
    end

    return effect
end

-- Apply effect
function PersonalityEffects.applyEffect(parent, personality, effectType)
    if not EFFECTS[personality] then
        return nil, "Invalid personality"
    end

    if not EFFECT_TYPES[effectType] then
        return nil, "Invalid effect type"
    end

    local effect = createEffectObject(parent, effectType, personality)
    activeEffects[effect.Name] = effect

    if effectType == EFFECT_TYPES.AUDIO then
        local sound = effect:FindFirstChild("Sound")
        if sound then
            sound:Play()
        end
    end

    return effect
end

-- Remove effect
function PersonalityEffects.removeEffect(effectName)
    local effect = activeEffects[effectName]
    if not effect then
        return false, "Effect not found"
    end

    if effect:FindFirstChild("Sound") then
        effect.Sound:Stop()
    end

    effect:Destroy()
    activeEffects[effectName] = nil
    return true, "Effect removed"
end

-- Update effect
function PersonalityEffects.updateEffect(effectName, properties)
    local effect = activeEffects[effectName]
    if not effect then
        return false, "Effect not found"
    end

    for property, value in pairs(properties) do
        if effect:FindFirstChild(property) then
            effect[property].Value = value
        end
    end

    return true, "Effect updated"
end

-- Get effect
function PersonalityEffects.getEffect(effectName)
    return activeEffects[effectName]
end

-- Get all effects
function PersonalityEffects.getAllEffects()
    return activeEffects
end

-- Get effect types
function PersonalityEffects.getEffectTypes()
    return EFFECT_TYPES
end

-- Get personality effects
function PersonalityEffects.getPersonalityEffects(personality)
    return EFFECTS[personality]
end

-- Update glitch effect
function PersonalityEffects.updateGlitchEffect(effectName, intensity, frequency)
    local effect = activeEffects[effectName]
    if not effect then
        return false, "Effect not found"
    end

    local glitchEffect = effect:FindFirstChild("GlitchEffect")
    if not glitchEffect then
        return false, "Glitch effect not found"
    end

    -- Update glitch properties
    local tweenInfo = TweenInfo.new(
        1/frequency,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut
    )

    local tween = TweenService:Create(glitchEffect, tweenInfo, {
        Position = UDim2.new(
            math.random(-intensity, intensity),
            0,
            math.random(-intensity, intensity),
            0
        )
    })

    tween:Play()
    return true, "Glitch effect updated"
end

-- Cleanup
function PersonalityEffects.cleanup()
    for _, effect in pairs(activeEffects) do
        effect:Destroy()
    end
    activeEffects = {}
end

return PersonalityEffects 