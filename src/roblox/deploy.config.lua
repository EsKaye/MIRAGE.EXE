-- MIRAGE.EXE Deployment Configuration
return {
    -- Module Configuration
    modules = {
        enabled = {
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
        },
        loadOrder = {
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
    },
    
    -- UI Configuration
    ui = {
        defaultTheme = {
            backgroundColor = Color3.fromRGB(20, 20, 20),
            textColor = Color3.fromRGB(0, 255, 0),
            accentColor = Color3.fromRGB(0, 200, 0),
            titleColor = Color3.fromRGB(30, 30, 30),
            hoverColor = Color3.fromRGB(40, 40, 40),
            selectedColor = Color3.fromRGB(60, 60, 60)
        },
        windowDefaults = {
            width = 1200,
            height = 800,
            titleHeight = 30,
            padding = 10,
            cornerRadius = 8,
            taskbarHeight = 40,
            startMenuWidth = 200,
            startMenuHeight = 300
        }
    },
    
    -- File System Configuration
    fileSystem = {
        rootPath = "MIRAGE_DATA",
        defaultDirectories = {
            "system",
            "users",
            "documents",
            "downloads",
            "pictures",
            "music",
            "videos"
        },
        defaultFiles = {
            ["system/README.txt"] = "Welcome to MIRAGE.EXE\n\nThis is a simulated operating system with AI personalities.\nType 'help' in the terminal for available commands.",
            ["system/CHANGELOG.txt"] = "MIRAGE.EXE v1.0.0\n- Initial release\n- Basic file system\n- Terminal interface\n- AI personalities\n- Visual effects"
        }
    },
    
    -- Personality Configuration
    personalities = {
        default = "NEUTRAL",
        available = {
            "NEUTRAL",
            "FRIENDLY",
            "HOSTILE",
            "CORRUPTED"
        },
        trustLevels = {
            min = 0,
            max = 100,
            default = 50
        },
        corruptionLevels = {
            min = 0,
            max = 100,
            default = 0
        }
    },
    
    -- Effect Configuration
    effects = {
        enabled = {
            "VISUAL",
            "AUDIO",
            "GLITCH"
        },
        intensity = {
            min = 0,
            max = 100,
            default = 50
        }
    },
    
    -- Security Configuration
    security = {
        maxFileSize = 1024 * 1024, -- 1MB
        allowedFileTypes = {
            "txt",
            "lua",
            "json",
            "md"
        },
        restrictedPaths = {
            "system/core",
            "system/config"
        }
    }
} 