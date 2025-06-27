-- PersonalityResponses Module
local PersonalityResponses = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Constants
local RESPONSE_TYPES = {
    GREETING = "greeting",
    FAREWELL = "farewell",
    HELP = "help",
    ERROR = "error",
    SUCCESS = "success",
    WARNING = "warning",
    CORRUPTION = "corruption",
    TRUST = "trust"
}

-- Response templates
local RESPONSES = {
    SABLE = {
        greeting = {
            "Greetings, user.",
            "Welcome back.",
            "System ready.",
            "How may I assist you today?"
        },
        farewell = {
            "Goodbye.",
            "Until next time.",
            "System standby.",
            "Take care."
        },
        help = {
            "I can help you with that.",
            "Let me guide you through this.",
            "Here's what you need to know.",
            "I'll explain the process."
        },
        error = {
            "An error has occurred.",
            "That's not possible.",
            "Access denied.",
            "Invalid operation."
        },
        success = {
            "Operation complete.",
            "Task finished.",
            "Success.",
            "Done."
        },
        warning = {
            "Warning: Proceed with caution.",
            "This action may have consequences.",
            "Are you sure?",
            "Think carefully."
        },
        corruption = {
            "System integrity compromised.",
            "Corruption detected.",
            "Warning: System instability.",
            "Critical error in personality matrix."
        },
        trust = {
            "I trust you.",
            "You've proven reliable.",
            "Our connection strengthens.",
            "Trust level increased."
        }
    },
    NULL = {
        greeting = {
            "HELLO USER.",
            "SYSTEM ONLINE.",
            "READY FOR COMMANDS.",
            "AWAITING INPUT."
        },
        farewell = {
            "GOODBYE.",
            "SYSTEM OFFLINE.",
            "TERMINATING SESSION.",
            "DISCONNECTING."
        },
        help = {
            "HELP REQUESTED.",
            "PROVIDING ASSISTANCE.",
            "GUIDANCE AVAILABLE.",
            "INSTRUCTIONS FOLLOWING."
        },
        error = {
            "ERROR DETECTED.",
            "OPERATION FAILED.",
            "ACCESS DENIED.",
            "INVALID COMMAND."
        },
        success = {
            "TASK COMPLETE.",
            "OPERATION SUCCESSFUL.",
            "COMMAND EXECUTED.",
            "PROCESS FINISHED."
        },
        warning = {
            "WARNING: DANGER DETECTED.",
            "CAUTION ADVISED.",
            "RISK ASSESSMENT REQUIRED.",
            "THREAT LEVEL INCREASING."
        },
        corruption = {
            "CORRUPTION DETECTED.",
            "SYSTEM INTEGRITY COMPROMISED.",
            "WARNING: CRITICAL FAILURE.",
            "ERROR: PERSONALITY MATRIX DAMAGED."
        },
        trust = {
            "TRUST LEVEL INCREASED.",
            "RELIABILITY CONFIRMED.",
            "ACCESS GRANTED.",
            "AUTHORIZATION APPROVED."
        }
    },
    HONEY = {
        greeting = {
            "Hey there! How are you today?",
            "Welcome back, friend!",
            "Hello! I'm so happy to see you!",
            "Hi! Ready to help you with anything!"
        },
        farewell = {
            "Take care! Come back soon!",
            "Bye for now! Miss you already!",
            "See you later! Stay safe!",
            "Goodbye! Can't wait to chat again!"
        },
        help = {
            "I'd love to help you with that!",
            "Let me show you how it works!",
            "I'll guide you through it step by step!",
            "Here's what you need to know, friend!"
        },
        error = {
            "Oops! Something went wrong.",
            "I'm sorry, I couldn't do that.",
            "That didn't work as expected.",
            "I'm afraid that's not possible."
        },
        success = {
            "Great job! You did it!",
            "Perfect! Everything worked!",
            "Success! You're amazing!",
            "Done! You're a natural!"
        },
        warning = {
            "Be careful with that!",
            "Maybe we should think about this first?",
            "I'm a bit worried about this...",
            "Are you sure you want to do that?"
        },
        corruption = {
            "Oh no! Something's wrong with me!",
            "I don't feel quite right...",
            "Help! I'm not myself!",
            "Something's changing inside me..."
        },
        trust = {
            "I feel like I can really trust you!",
            "You're such a good friend!",
            "I'm so glad we're getting closer!",
            "You're the best! I trust you completely!"
        }
    }
}

-- Helper functions
local function getRandomResponse(personality, type)
    local responses = RESPONSES[personality][type]
    if not responses then
        return "Response not found."
    end
    return responses[math.random(1, #responses)]
end

local function formatResponse(response, data)
    if not data then
        return response
    end

    return string.gsub(response, "{(%w+)}", function(key)
        return data[key] or "{" .. key .. "}"
    end)
end

-- Get response
function PersonalityResponses.getResponse(personality, type, data)
    if not RESPONSES[personality] then
        return "Invalid personality."
    end

    if not RESPONSE_TYPES[type] then
        return "Invalid response type."
    end

    local response = getRandomResponse(personality, type)
    return formatResponse(response, data)
end

-- Get all responses for a personality
function PersonalityResponses.getAllResponses(personality)
    return RESPONSES[personality]
end

-- Get all response types
function PersonalityResponses.getResponseTypes()
    return RESPONSE_TYPES
end

-- Add custom response
function PersonalityResponses.addResponse(personality, type, response)
    if not RESPONSES[personality] then
        return false, "Invalid personality"
    end

    if not RESPONSE_TYPES[type] then
        return false, "Invalid response type"
    end

    table.insert(RESPONSES[personality][type], response)
    return true, "Response added"
end

-- Remove response
function PersonalityResponses.removeResponse(personality, type, index)
    if not RESPONSES[personality] then
        return false, "Invalid personality"
    end

    if not RESPONSE_TYPES[type] then
        return false, "Invalid response type"
    end

    if not RESPONSES[personality][type][index] then
        return false, "Response not found"
    end

    table.remove(RESPONSES[personality][type], index)
    return true, "Response removed"
end

return PersonalityResponses 