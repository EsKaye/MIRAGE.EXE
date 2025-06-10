-- MIRAGE.exe - Client Initialization
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Load modules
local GlitchEffect = require(ReplicatedStorage.Modules.GlitchEffect)
local PersonalityEffects = require(ReplicatedStorage.Modules.PersonalityEffects)
local PersonalityResponses = require(ReplicatedStorage.Modules.PersonalityResponses)
local UIComponents = require(ReplicatedStorage.Modules.UIComponents)

local MIRAGE = ReplicatedStorage:WaitForChild("MIRAGE")
local States = MIRAGE:WaitForChild("States")

-- Initialize UI
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MIRAGE_UI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Create main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(1, 0, 1, 0)
mainFrame.BackgroundTransparency = 1
mainFrame.Parent = screenGui

-- Initialize personality windows
local personalityWindows = {}

local function initializePersonalityWindow(personality)
    local window = UIComponents.createPersonalityWindow(mainFrame, personality, personality)
    local effects = PersonalityEffects["apply" .. personality .. "Effects"](window)
    local glitchCleanup = GlitchEffect.applyToScreen(screenGui, 0.1)

    -- Handle input
    local inputBox = window:FindFirstChild("InputBox")
    local textBox = inputBox:FindFirstChild("Input")

    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and textBox.Text ~= "" then
            -- Add user message
            window:AddMessage(textBox.Text, true)

            -- Generate and add response
            local response = PersonalityResponses.generateResponse(personality, textBox.Text)
            window:AddMessage(response, false)

            -- Update effects based on response
            if personality == "SABLE" then
                effects.playTypingSound()
            elseif personality == "NULL" then
                effects.playGlitchSound()
            elseif personality == "HONEY" then
                effects.playNotificationSound()
            end

            -- Clear input
            textBox.Text = ""
        end
    end)

    personalityWindows[personality] = {
        window = window,
        effects = effects,
        glitchCleanup = glitchCleanup
    }
end

-- Initialize all personalities
initializePersonalityWindow("SABLE")
initializePersonalityWindow("NULL")
initializePersonalityWindow("HONEY")

-- Handle cleanup
game:BindToClose(function()
    for _, data in pairs(personalityWindows) do
        data.effects.cleanup()
        data.glitchCleanup()
    end
end)

-- Add initial messages
for personality, data in pairs(personalityWindows) do
    data.window:AddMessage(PersonalityResponses.generateResponse(personality, "hello"), false)
end

print("MIRAGE.exe client initialized successfully") 