-- CommandSystem Module
local CommandSystem = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local FileSystem = require(script.Parent.FileSystem)
local PersonalityState = require(script.Parent.PersonalityState)
local PersonalityResponses = require(script.Parent.PersonalityResponses)
local PersonalityEffects = require(script.Parent.PersonalityEffects)
local GlitchEffect = require(script.Parent.GlitchEffect)

-- Constants
local COMMAND_TYPES = {
    FILE = "file",
    SYSTEM = "system",
    PERSONALITY = "personality",
    EFFECT = "effect"
}

-- Command definitions
local commands = {
    -- File commands
    ["cd"] = {
        type = COMMAND_TYPES.FILE,
        description = "Change directory",
        usage = "cd [path]",
        execute = function(args)
            local path = args[1] or "."
            return FileSystem.changeDirectory(path)
        end
    },
    ["ls"] = {
        type = COMMAND_TYPES.FILE,
        description = "List directory contents",
        usage = "ls [path]",
        execute = function(args)
            local path = args[1]
            return FileSystem.listDirectory(path)
        end
    },
    ["cat"] = {
        type = COMMAND_TYPES.FILE,
        description = "Display file contents",
        usage = "cat <file>",
        execute = function(args)
            if not args[1] then
                return nil, "No file specified"
            end
            return FileSystem.readFile(args[1])
        end
    },
    ["mkdir"] = {
        type = COMMAND_TYPES.FILE,
        description = "Create directory",
        usage = "mkdir <path>",
        execute = function(args)
            if not args[1] then
                return nil, "No path specified"
            end
            return FileSystem.createDirectory(args[1])
        end
    },
    ["rm"] = {
        type = COMMAND_TYPES.FILE,
        description = "Remove file or directory",
        usage = "rm <path>",
        execute = function(args)
            if not args[1] then
                return nil, "No path specified"
            end
            return FileSystem.delete(args[1])
        end
    },
    ["mv"] = {
        type = COMMAND_TYPES.FILE,
        description = "Move file or directory",
        usage = "mv <source> <destination>",
        execute = function(args)
            if not args[1] or not args[2] then
                return nil, "Source and destination required"
            end
            return FileSystem.move(args[1], args[2])
        end
    },
    ["cp"] = {
        type = COMMAND_TYPES.FILE,
        description = "Copy file or directory",
        usage = "cp <source> <destination>",
        execute = function(args)
            if not args[1] or not args[2] then
                return nil, "Source and destination required"
            end
            return FileSystem.copy(args[1], args[2])
        end
    },

    -- System commands
    ["clear"] = {
        type = COMMAND_TYPES.SYSTEM,
        description = "Clear terminal screen",
        usage = "clear",
        execute = function()
            return true
        end
    },
    ["help"] = {
        type = COMMAND_TYPES.SYSTEM,
        description = "Display help information",
        usage = "help [command]",
        execute = function(args)
            if args[1] then
                local command = commands[args[1]]
                if not command then
                    return nil, "Command not found"
                end
                return string.format("%s - %s\nUsage: %s", args[1], command.description, command.usage)
            end

            local helpText = "Available commands:\n"
            for name, cmd in pairs(commands) do
                helpText = helpText .. string.format("%s - %s\n", name, cmd.description)
            end
            return helpText
        end
    },
    ["pwd"] = {
        type = COMMAND_TYPES.SYSTEM,
        description = "Print working directory",
        usage = "pwd",
        execute = function()
            local currentDir = FileSystem.getCurrentDirectory()
            return currentDir.name
        end
    },

    -- Personality commands
    ["personality"] = {
        type = COMMAND_TYPES.PERSONALITY,
        description = "Manage AI personalities",
        usage = "personality [list|set|info] [name]",
        execute = function(args)
            local action = args[1]
            if not action then
                return nil, "No action specified"
            end

            if action == "list" then
                return PersonalityState.getAvailablePersonalities()
            elseif action == "set" then
                local name = args[2]
                if not name then
                    return nil, "No personality specified"
                end
                return PersonalityState.setPersonality(name)
            elseif action == "info" then
                return PersonalityState.getCurrentPersonality()
            end

            return nil, "Invalid action"
        end
    },
    ["trust"] = {
        type = COMMAND_TYPES.PERSONALITY,
        description = "Manage trust level",
        usage = "trust [get|set] [value]",
        execute = function(args)
            local action = args[1]
            if not action then
                return nil, "No action specified"
            end

            if action == "get" then
                return PersonalityState.getTrustLevel()
            elseif action == "set" then
                local value = tonumber(args[2])
                if not value then
                    return nil, "Invalid value"
                end
                return PersonalityState.setTrustLevel(value)
            end

            return nil, "Invalid action"
        end
    },
    ["corruption"] = {
        type = COMMAND_TYPES.PERSONALITY,
        description = "Manage corruption level",
        usage = "corruption [get|set] [value]",
        execute = function(args)
            local action = args[1]
            if not action then
                return nil, "No action specified"
            end

            if action == "get" then
                return PersonalityState.getCorruptionLevel()
            elseif action == "set" then
                local value = tonumber(args[2])
                if not value then
                    return nil, "Invalid value"
                end
                return PersonalityState.setCorruptionLevel(value)
            end

            return nil, "Invalid action"
        end
    },

    -- Effect commands
    ["effect"] = {
        type = COMMAND_TYPES.EFFECT,
        description = "Manage visual effects",
        usage = "effect [list|apply|remove] [type] [target]",
        execute = function(args)
            local action = args[1]
            if not action then
                return nil, "No action specified"
            end

            if action == "list" then
                return PersonalityEffects.getEffectTypes()
            elseif action == "apply" then
                local effectType = args[2]
                local target = args[3]
                if not effectType then
                    return nil, "No effect type specified"
                end
                return PersonalityEffects.applyEffect(target, effectType)
            elseif action == "remove" then
                local effectType = args[2]
                if not effectType then
                    return nil, "No effect type specified"
                end
                return PersonalityEffects.removeEffect(effectType)
            end

            return nil, "Invalid action"
        end
    },
    ["glitch"] = {
        type = COMMAND_TYPES.EFFECT,
        description = "Manage glitch effects",
        usage = "glitch [list|apply|remove] [type] [target]",
        execute = function(args)
            local action = args[1]
            if not action then
                return nil, "No action specified"
            end

            if action == "list" then
                return GlitchEffect.getGlitchTypes()
            elseif action == "apply" then
                local glitchType = args[2]
                local target = args[3]
                if not glitchType then
                    return nil, "No glitch type specified"
                end
                return GlitchEffect.applyGlitch(target, glitchType)
            elseif action == "remove" then
                local glitchType = args[2]
                if not glitchType then
                    return nil, "No glitch type specified"
                end
                return GlitchEffect.removeGlitch(glitchType)
            end

            return nil, "Invalid action"
        end
    }
}

-- Helper functions
local function parseCommand(input)
    local parts = {}
    for part in string.gmatch(input, "%S+") do
        table.insert(parts, part)
    end

    if #parts == 0 then
        return nil, nil
    end

    local command = parts[1]
    table.remove(parts, 1)
    return command, parts
end

-- Execute command
function CommandSystem.executeCommand(input)
    local command, args = parseCommand(input)
    if not command then
        return nil, "No command specified"
    end

    local cmd = commands[command]
    if not cmd then
        return nil, "Command not found"
    end

    local success, result = cmd.execute(args)
    if not success then
        return nil, result
    end

    return result
end

-- Get command types
function CommandSystem.getCommandTypes()
    return COMMAND_TYPES
end

-- Get all commands
function CommandSystem.getAllCommands()
    return commands
end

-- Get commands by type
function CommandSystem.getCommandsByType(type)
    local filtered = {}
    for name, cmd in pairs(commands) do
        if cmd.type == type then
            filtered[name] = cmd
        end
    end
    return filtered
end

-- Add custom command
function CommandSystem.addCommand(name, definition)
    if commands[name] then
        return false, "Command already exists"
    end

    if not definition.type or not definition.description or not definition.usage or not definition.execute then
        return false, "Invalid command definition"
    end

    commands[name] = definition
    return true
end

-- Remove command
function CommandSystem.removeCommand(name)
    if not commands[name] then
        return false, "Command not found"
    end

    commands[name] = nil
    return true
end

return CommandSystem 