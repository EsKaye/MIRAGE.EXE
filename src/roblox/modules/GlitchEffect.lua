-- GlitchEffect Module
local GlitchEffect = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Constants
local GLITCH_TYPES = {
    POSITION = "position",
    COLOR = "color",
    TEXTURE = "texture",
    AUDIO = "audio"
}

-- Glitch configurations
local GLITCH_CONFIGS = {
    position = {
        intensity = 0.1,
        frequency = 0.5,
        duration = 0.2
    },
    color = {
        intensity = 0.3,
        frequency = 0.3,
        duration = 0.3
    },
    texture = {
        intensity = 0.5,
        frequency = 0.4,
        duration = 0.4
    },
    audio = {
        intensity = 0.2,
        frequency = 0.6,
        duration = 0.1
    }
}

-- Active glitches
local activeGlitches = {}

-- Helper functions
local function createGlitchObject(parent, glitchType)
    local glitch = Instance.new("Frame")
    glitch.Name = "Glitch_" .. glitchType
    glitch.Size = UDim2.new(1, 0, 1, 0)
    glitch.BackgroundTransparency = 1
    glitch.Parent = parent

    if glitchType == GLITCH_TYPES.POSITION then
        local positionEffect = Instance.new("Frame")
        positionEffect.Name = "PositionEffect"
        positionEffect.Size = UDim2.new(1, 0, 1, 0)
        positionEffect.BackgroundTransparency = 1
        positionEffect.Parent = glitch
    elseif glitchType == GLITCH_TYPES.COLOR then
        local colorEffect = Instance.new("ColorCorrectionEffect")
        colorEffect.Name = "ColorEffect"
        colorEffect.Parent = glitch
    elseif glitchType == GLITCH_TYPES.TEXTURE then
        local textureEffect = Instance.new("Frame")
        textureEffect.Name = "TextureEffect"
        textureEffect.Size = UDim2.new(1, 0, 1, 0)
        textureEffect.BackgroundTransparency = 1
        textureEffect.Parent = glitch
    elseif glitchType == GLITCH_TYPES.AUDIO then
        local audioEffect = Instance.new("Sound")
        audioEffect.Name = "AudioEffect"
        audioEffect.Parent = glitch
    end

    return glitch
end

-- Apply glitch
function GlitchEffect.applyGlitch(parent, glitchType, intensity, frequency)
    if not GLITCH_TYPES[glitchType] then
        return nil, "Invalid glitch type"
    end

    local config = GLITCH_CONFIGS[glitchType]
    intensity = intensity or config.intensity
    frequency = frequency or config.frequency

    local glitch = createGlitchObject(parent, glitchType)
    activeGlitches[glitch.Name] = {
        object = glitch,
        type = glitchType,
        intensity = intensity,
        frequency = frequency,
        startTime = os.time()
    }

    -- Start glitch effect
    if glitchType == GLITCH_TYPES.POSITION then
        RunService:BindToRenderStep(glitch.Name, 1, function()
            local effect = glitch:FindFirstChild("PositionEffect")
            if effect then
                effect.Position = UDim2.new(
                    math.random(-intensity, intensity),
                    0,
                    math.random(-intensity, intensity),
                    0
                )
            end
        end)
    elseif glitchType == GLITCH_TYPES.COLOR then
        RunService:BindToRenderStep(glitch.Name, 1, function()
            local effect = glitch:FindFirstChild("ColorEffect")
            if effect then
                effect.TintColor = Color3.new(
                    math.random(),
                    math.random(),
                    math.random()
                )
            end
        end)
    elseif glitchType == GLITCH_TYPES.TEXTURE then
        RunService:BindToRenderStep(glitch.Name, 1, function()
            local effect = glitch:FindFirstChild("TextureEffect")
            if effect then
                effect.BackgroundTransparency = math.random()
            end
        end)
    elseif glitchType == GLITCH_TYPES.AUDIO then
        local effect = glitch:FindFirstChild("AudioEffect")
        if effect then
            effect.Volume = intensity
            effect.PlaybackSpeed = 1 + (math.random() * 2 - 1) * intensity
            effect:Play()
        end
    end

    return glitch
end

-- Remove glitch
function GlitchEffect.removeGlitch(glitchName)
    local glitch = activeGlitches[glitchName]
    if not glitch then
        return false, "Glitch not found"
    end

    RunService:UnbindFromRenderStep(glitchName)
    glitch.object:Destroy()
    activeGlitches[glitchName] = nil
    return true, "Glitch removed"
end

-- Update glitch
function GlitchEffect.updateGlitch(glitchName, properties)
    local glitch = activeGlitches[glitchName]
    if not glitch then
        return false, "Glitch not found"
    end

    for property, value in pairs(properties) do
        glitch[property] = value
    end

    return true, "Glitch updated"
end

-- Get glitch
function GlitchEffect.getGlitch(glitchName)
    return activeGlitches[glitchName]
end

-- Get all glitches
function GlitchEffect.getAllGlitches()
    return activeGlitches
end

-- Get glitch types
function GlitchEffect.getGlitchTypes()
    return GLITCH_TYPES
end

-- Get glitch configs
function GlitchEffect.getGlitchConfigs()
    return GLITCH_CONFIGS
end

-- Apply random glitch
function GlitchEffect.applyRandomGlitch(parent, intensity)
    local glitchType = GLITCH_TYPES[math.random(1, #GLITCH_TYPES)]
    return GlitchEffect.applyGlitch(parent, glitchType, intensity)
end

-- Apply multiple glitches
function GlitchEffect.applyMultipleGlitches(parent, glitchTypes, intensity)
    local glitches = {}
    for _, glitchType in ipairs(glitchTypes) do
        local glitch = GlitchEffect.applyGlitch(parent, glitchType, intensity)
        if glitch then
            table.insert(glitches, glitch)
        end
    end
    return glitches
end

-- Cleanup
function GlitchEffect.cleanup()
    for glitchName, glitch in pairs(activeGlitches) do
        RunService:UnbindFromRenderStep(glitchName)
        glitch.object:Destroy()
    end
    activeGlitches = {}
end

return GlitchEffect 