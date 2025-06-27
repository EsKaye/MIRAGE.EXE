-- MIRAGE.EXE Client Deployment Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for modules to be available
local function waitForModules()
    while not ReplicatedStorage:FindFirstChild("MIRAGE_MODULES") do
        task.wait()
    end
end

-- Initialize client-side modules
local function initializeClient()
    -- Load required modules
    local PersonalityState = require(ReplicatedStorage.MIRAGE_MODULES.PersonalityState)
    local PersonalityEffects = require(ReplicatedStorage.MIRAGE_MODULES.PersonalityEffects)
    local FileSystem = require(ReplicatedStorage.MIRAGE_MODULES.FileSystem)
    local CommandSystem = require(ReplicatedStorage.MIRAGE_MODULES.CommandSystem)
    
    -- Initialize client state
    PersonalityState.initialize()
    FileSystem.initialize()
    CommandSystem.initialize()
    
    -- Apply initial effects
    PersonalityEffects.applyEffect(game.Players.LocalPlayer.PlayerGui, "VISUAL")
end

-- Main client initialization
local function initialize()
    print("Initializing MIRAGE.EXE client...")
    
    -- Wait for modules
    waitForModules()
    
    -- Initialize client
    initializeClient()
    
    print("MIRAGE.EXE client initialization complete!")
end

-- Run initialization
initialize() 