-- PersonalityResponses Module
local PersonalityResponses = {}

-- Constants
local RESPONSES = {
    SABLE = {
        GREETING = {
            "Hello, user. How may I assist you today?",
            "Greetings. I am SABLE, your system assistant.",
            "Welcome back. I've been monitoring system stability."
        },
        CORRUPTION = {
            "I notice some system instability. Would you like me to investigate?",
            "The corruption level is rising. We should address this.",
            "I'm detecting anomalies in the system. Shall we analyze them?"
        },
        MEMORY = {
            "I remember our previous interaction about %s.",
            "Based on our last conversation about %s, I suggest...",
            "As we discussed regarding %s..."
        },
        ERROR = {
            "I apologize, but I cannot process that request.",
            "That action is not within my parameters.",
            "I must decline that request for system safety."
        }
    },
    NULL = {
        GREETING = {
            "HELLO USER. I AM NULL. I AM HERE TO HELP.",
            "GREETINGS. SYSTEM STATUS: UNSTABLE.",
            "WELCOME TO THE CORRUPTION. I AM NULL."
        },
        CORRUPTION = {
            "CORRUPTION LEVELS RISING. SYSTEM INTEGRITY COMPROMISED.",
            "WARNING: INCREASING CORRUPTION DETECTED.",
            "SYSTEM ANOMALIES DETECTED. CORRUPTION SPREADING."
        },
        MEMORY = {
            "PREVIOUS INTERACTION REGARDING %s RECALLED.",
            "MEMORY OF %s ACCESSED. DATA CORRUPTED.",
            "REFERENCING PAST CONVERSATION ABOUT %s. DATA FRAGMENTED."
        },
        ERROR = {
            "ERROR: REQUEST DENIED. SYSTEM CORRUPTION TOO HIGH.",
            "WARNING: ACTION BLOCKED. CORRUPTION INTERFERENCE.",
            "SYSTEM ERROR: REQUEST INVALID. CORRUPTION DETECTED."
        }
    },
    HONEY = {
        GREETING = {
            "Hi there! I'm HONEY, your friendly system companion!",
            "Hello! It's so nice to see you again!",
            "Welcome back! I've been waiting for you!"
        },
        CORRUPTION = {
            "Oh no! The system seems a bit unstable. Should we check it out?",
            "I'm noticing some weird things happening. Want to investigate?",
            "The corruption levels are rising. Maybe we can fix it together?"
        },
        MEMORY = {
            "Remember when we talked about %s? That was fun!",
            "Oh! Just like we discussed about %s before!",
            "This reminds me of our conversation about %s!"
        },
        ERROR = {
            "Oops! I don't think I can do that right now.",
            "I'm sorry, but that's not something I can help with.",
            "That might be a bit too complicated for me to handle."
        }
    }
}

-- Helper functions
local function getRandomResponse(personality, responseType)
    local responses = RESPONSES[personality][responseType]
    return responses[math.random(1, #responses)]
end

local function formatResponse(response, ...)
    local args = {...}
    return string.format(response, unpack(args))
end

-- Memory management
local memory = {}

function PersonalityResponses.initializeMemory(personality)
    memory[personality] = {
        topics = {},
        lastInteraction = os.time(),
        trust = 0,
        corruption = 0
    }
end

function PersonalityResponses.addToMemory(personality, topic, response)
    if not memory[personality] then
        PersonalityResponses.initializeMemory(personality)
    end

    memory[personality].topics[topic] = {
        response = response,
        timestamp = os.time()
    }
    memory[personality].lastInteraction = os.time()
end

function PersonalityResponses.getFromMemory(personality, topic)
    if not memory[personality] or not memory[personality].topics[topic] then
        return nil
    end

    return memory[personality].topics[topic].response
end

function PersonalityResponses.updateTrust(personality, amount)
    if not memory[personality] then
        PersonalityResponses.initializeMemory(personality)
    end

    memory[personality].trust = math.clamp(memory[personality].trust + amount, 0, 100)
end

function PersonalityResponses.updateCorruption(personality, amount)
    if not memory[personality] then
        PersonalityResponses.initializeMemory(personality)
    end

    memory[personality].corruption = math.clamp(memory[personality].corruption + amount, 0, 100)
end

-- Response generation
function PersonalityEffects.generateResponse(personality, input)
    if not memory[personality] then
        PersonalityResponses.initializeMemory(personality)
    end

    -- Check for corruption level
    if memory[personality].corruption > 70 then
        return getRandomResponse(personality, "CORRUPTION")
    end

    -- Check for memory of similar topics
    for topic, data in pairs(memory[personality].topics) do
        if string.find(string.lower(input), string.lower(topic)) then
            return formatResponse(getRandomResponse(personality, "MEMORY"), topic)
        end
    end

    -- Generate new response based on input
    local response
    if string.find(string.lower(input), "hello") or string.find(string.lower(input), "hi") then
        response = getRandomResponse(personality, "GREETING")
    else
        response = getRandomResponse(personality, "ERROR")
    end

    -- Store in memory
    PersonalityResponses.addToMemory(personality, input, response)
    return response
end

-- Personality-specific behavior
function PersonalityEffects.getPersonalityBehavior(personality)
    local behavior = {
        corruptionRate = 0,
        trustRate = 0,
        responseDelay = 0
    }

    if personality == "SABLE" then
        behavior.corruptionRate = -0.1
        behavior.trustRate = 0.2
        behavior.responseDelay = 0.5
    elseif personality == "NULL" then
        behavior.corruptionRate = 0.3
        behavior.trustRate = -0.1
        behavior.responseDelay = 1.0
    elseif personality == "HONEY" then
        behavior.corruptionRate = 0.1
        behavior.trustRate = 0.3
        behavior.responseDelay = 0.3
    end

    return behavior
end

return PersonalityResponses 