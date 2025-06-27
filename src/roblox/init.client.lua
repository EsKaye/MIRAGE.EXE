-- Main Client Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Wait for modules
local modules = ReplicatedStorage:WaitForChild("Modules")
local PersonalityState = require(modules:WaitForChild("PersonalityState"))
local PersonalityResponses = require(modules:WaitForChild("PersonalityResponses"))
local PersonalityEffects = require(modules:WaitForChild("PersonalityEffects"))
local GlitchEffect = require(modules:WaitForChild("GlitchEffect"))
local FileSystem = require(modules:WaitForChild("FileSystem"))
local CommandSystem = require(modules:WaitForChild("CommandSystem"))
local TerminalInterface = require(modules:WaitForChild("TerminalInterface"))
local GameInterface = require(modules:WaitForChild("GameInterface"))

-- Initialize client
local function initializeClient()
    -- Set up personality state
    PersonalityState.initializeClient()

    -- Set up file system
    FileSystem.initializeClient()

    -- Set up command system
    CommandSystem.initializeClient()

    -- Set up effects
    PersonalityEffects.initializeClient()
    GlitchEffect.initializeClient()

    -- Create screen GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MIRAGE.EXE"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Create main window
    local mainWindow = GameInterface.createMainWindow(screenGui)

    -- Create terminal window
    GameInterface.createTerminalWindow(mainWindow:WaitForChild("Desktop"))
end

-- Handle cleanup
game:BindToClose(function()
    -- Clean up client state
    PersonalityState.cleanupClient()
    FileSystem.cleanupClient()
    CommandSystem.cleanupClient()
    PersonalityEffects.cleanupClient()
    GlitchEffect.cleanupClient()
end)

-- Initialize client
initializeClient() 