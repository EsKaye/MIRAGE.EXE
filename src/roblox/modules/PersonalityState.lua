-- PersonalityState Module
local PersonalityState = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Constants
local PERSONALITIES = {
    SABLE = {
        name = "SABLE",
        color = Color3.fromRGB(0, 0, 0),
        corruptionRate = 0.1,
        trustRate = 0.05,
        memoryCapacity = 100,
        responseDelay = 0.5
    },
    NULL = {
        name = "NULL",
        color = Color3.fromRGB(255, 0, 0),
        corruptionRate = 0.3,
        trustRate = -0.1,
        memoryCapacity = 50,
        responseDelay = 0.2
    },
    HONEY = {
        name = "HONEY",
        color = Color3.fromRGB(255, 215, 0),
        corruptionRate = -0.05,
        trustRate = 0.2,
        memoryCapacity = 200,
        responseDelay = 0.8
    }
}

-- State management
local states = {}

-- Helper functions
local function generateId()
    return HttpService:GenerateGUID(false)
end

local function clamp(value, min, max)
    return math.min(math.max(value, min), max)
end

-- Initialize personality state
function PersonalityState.initialize(personality)
    if not PERSONALITIES[personality] then
        return nil, "Invalid personality"
    end

    local state = {
        id = generateId(),
        personality = personality,
        corruption = 0,
        trust = 50,
        lastInteraction = os.time(),
        memory = {},
        activeEffects = {},
        isCorrupted = false
    }

    states[state.id] = state
    return state
end

-- Update personality state
function PersonalityState.update(id, deltaTime)
    local state = states[id]
    if not state then
        return nil, "State not found"
    end

    local personality = PERSONALITIES[state.personality]
    
    -- Update corruption
    state.corruption = clamp(
        state.corruption + (personality.corruptionRate * deltaTime),
        0,
        100
    )

    -- Update trust
    state.trust = clamp(
        state.trust + (personality.trustRate * deltaTime),
        0,
        100
    )

    -- Check corruption threshold
    if state.corruption >= 75 and not state.isCorrupted then
        state.isCorrupted = true
        return true, "Personality corrupted"
    end

    return false, "State updated"
end

-- Add memory entry
function PersonalityState.addMemory(id, memory)
    local state = states[id]
    if not state then
        return nil, "State not found"
    end

    local personality = PERSONALITIES[state.personality]
    
    -- Add new memory
    table.insert(state.memory, {
        content = memory,
        timestamp = os.time(),
        importance = 1
    })

    -- Trim memory if exceeding capacity
    while #state.memory > personality.memoryCapacity do
        table.remove(state.memory, 1)
    end

    return true, "Memory added"
end

-- Get memory entries
function PersonalityState.getMemories(id, count)
    local state = states[id]
    if not state then
        return nil, "State not found"
    end

    count = count or #state.memory
    local memories = {}
    
    for i = #state.memory, math.max(1, #state.memory - count + 1), -1 do
        table.insert(memories, state.memory[i])
    end

    return memories
end

-- Add effect
function PersonalityState.addEffect(id, effect)
    local state = states[id]
    if not state then
        return nil, "State not found"
    end

    table.insert(state.activeEffects, {
        type = effect.type,
        intensity = effect.intensity,
        duration = effect.duration,
        startTime = os.time()
    })

    return true, "Effect added"
end

-- Update effects
function PersonalityState.updateEffects(id)
    local state = states[id]
    if not state then
        return nil, "State not found"
    end

    local currentTime = os.time()
    local expiredEffects = {}

    for i, effect in ipairs(state.activeEffects) do
        if currentTime - effect.startTime >= effect.duration then
            table.insert(expiredEffects, i)
        end
    end

    -- Remove expired effects
    for i = #expiredEffects, 1, -1 do
        table.remove(state.activeEffects, expiredEffects[i])
    end

    return true, "Effects updated"
end

-- Get active effects
function PersonalityState.getEffects(id)
    local state = states[id]
    if not state then
        return nil, "State not found"
    end

    return state.activeEffects
end

-- Get personality info
function PersonalityState.getPersonalityInfo(personality)
    return PERSONALITIES[personality]
end

-- Get state
function PersonalityState.getState(id)
    return states[id]
end

-- Reset state
function PersonalityState.reset(id)
    local state = states[id]
    if not state then
        return nil, "State not found"
    end

    state.corruption = 0
    state.trust = 50
    state.lastInteraction = os.time()
    state.memory = {}
    state.activeEffects = {}
    state.isCorrupted = false

    return true, "State reset"
end

return PersonalityState 