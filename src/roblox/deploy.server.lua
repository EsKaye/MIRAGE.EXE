-- MIRAGE.EXE Deployment Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Create necessary folders
local function createFolders()
    -- Create MIRAGE_MODULES folder in ReplicatedStorage if it doesn't exist
    if not ReplicatedStorage:FindFirstChild("MIRAGE_MODULES") then
        local modulesFolder = Instance.new("Folder")
        modulesFolder.Name = "MIRAGE_MODULES"
        modulesFolder.Parent = ReplicatedStorage
    end
    
    -- Create MIRAGE_DATA folder in ServerStorage if it doesn't exist
    if not game:GetService("ServerStorage"):FindFirstChild("MIRAGE_DATA") then
        local dataFolder = Instance.new("Folder")
        dataFolder.Name = "MIRAGE_DATA"
        dataFolder.Parent = game:GetService("ServerStorage")
    end
end

-- Load and initialize modules
local function initializeModules()
    local modules = {
        "PersonalityState",
        "PersonalityResponses",
        "PersonalityEffects",
        "GlitchEffect",
        "FileSystem",
        "CommandSystem",
        "TerminalInterface",
        "FileExplorer",
        "Settings",
        "HelpSystem",
        "GameInterface"
    }
    
    for _, moduleName in ipairs(modules) do
        local module = require(script.Parent.modules[moduleName])
        if module.initialize then
            module.initialize()
        end
    end
end

-- Set up player handling
local function setupPlayerHandling()
    -- Handle player joining
    game.Players.PlayerAdded:Connect(function(player)
        -- Create player GUI
        local playerGui = Instance.new("PlayerGui")
        playerGui.Name = "MIRAGE.EXE"
        playerGui.Parent = player
        
        -- Create screen GUI
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "MIRAGE.EXE"
        screenGui.Parent = playerGui
        
        -- Create main window
        local GameInterface = require(ReplicatedStorage.MIRAGE_MODULES.GameInterface)
        local mainWindow = GameInterface.createWindow()
        mainWindow.Parent = screenGui
    end)
    
    -- Handle player leaving
    game.Players.PlayerRemoving:Connect(function(player)
        -- Clean up player GUI
        local playerGui = player:FindFirstChild("MIRAGE.EXE")
        if playerGui then
            playerGui:Destroy()
        end
    end)
end

-- Main deployment function
local function deploy()
    print("Deploying MIRAGE.EXE...")
    
    -- Create necessary folders
    createFolders()
    
    -- Initialize modules
    initializeModules()
    
    -- Set up player handling
    setupPlayerHandling()
    
    print("MIRAGE.EXE deployment complete!")
end

-- Run deployment
deploy() 