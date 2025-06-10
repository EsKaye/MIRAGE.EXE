-- MIRAGE.exe - Roblox Server Initialization
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")

-- Load modules
local PersonalityResponses = require(ReplicatedStorage.Modules.PersonalityResponses)

-- Create necessary folders
local MIRAGE = Instance.new("Folder")
MIRAGE.Name = "MIRAGE"
MIRAGE.Parent = ReplicatedStorage

local Config = Instance.new("Folder")
Config.Name = "Config"
Config.Parent = MIRAGE

local States = Instance.new("Folder")
States.Name = "States"
States.Parent = MIRAGE

-- Initialize personality states
local personalities = {"SABLE", "NULL", "HONEY"}

for _, personality in ipairs(personalities) do
    -- Create state value
    local state = Instance.new("StringValue")
    state.Name = personality
    state.Parent = States

    -- Initialize state data
    local stateData = {
        corruption = 0,
        trust = 0,
        lastInteraction = os.time(),
        memory = {}
    }

    -- Set initial state
    state.Value = HttpService:JSONEncode(stateData)

    -- Initialize personality memory
    PersonalityResponses.initializeMemory(personality)
end

-- Corruption timer
spawn(function()
    while true do
        wait(10) -- Check every 10 seconds

        for _, personality in ipairs(personalities) do
            local state = States:FindFirstChild(personality)
            if state then
                local stateData = HttpService:JSONDecode(state.Value)
                local behavior = PersonalityResponses.getPersonalityBehavior(personality)

                -- Update corruption
                stateData.corruption = math.clamp(
                    stateData.corruption + behavior.corruptionRate,
                    0,
                    100
                )

                -- Update trust
                stateData.trust = math.clamp(
                    stateData.trust + behavior.trustRate,
                    0,
                    100
                )

                -- Save state
                state.Value = HttpService:JSONEncode(stateData)
            end
        end
    end
end)

print("MIRAGE.exe server initialized successfully") 