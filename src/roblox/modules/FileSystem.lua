-- FileSystem Module
local FileSystem = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Constants
local FILE_TYPES = {
    TEXT = "txt",
    IMAGE = "png",
    AUDIO = "mp3",
    EXECUTABLE = "exe",
    CORRUPTED = "corrupted"
}

local FILE_ICONS = {
    [FILE_TYPES.TEXT] = "📄",
    [FILE_TYPES.IMAGE] = "🖼️",
    [FILE_TYPES.AUDIO] = "🎵",
    [FILE_TYPES.EXECUTABLE] = "⚙️",
    [FILE_TYPES.CORRUPTED] = "⚠️"
}

-- File system structure
local fileSystem = {
    root = {
        name = "C:",
        type = "directory",
        children = {
            ["System"] = {
                name = "System",
                type = "directory",
                children = {
                    ["config.sys"] = {
                        name = "config.sys",
                        type = FILE_TYPES.TEXT,
                        content = "System configuration file",
                        size = 1024,
                        created = os.time(),
                        modified = os.time()
                    }
                }
            },
            ["Users"] = {
                name = "Users",
                type = "directory",
                children = {
                    ["Default"] = {
                        name = "Default",
                        type = "directory",
                        children = {
                            ["Documents"] = {
                                name = "Documents",
                                type = "directory",
                                children = {}
                            },
                            ["Downloads"] = {
                                name = "Downloads",
                                type = "directory",
                                children = {}
                            }
                        }
                    }
                }
            },
            ["Program Files"] = {
                name = "Program Files",
                type = "directory",
                children = {
                    ["MIRAGE"] = {
                        name = "MIRAGE",
                        type = "directory",
                        children = {
                            ["MIRAGE.exe"] = {
                                name = "MIRAGE.exe",
                                type = FILE_TYPES.EXECUTABLE,
                                content = "MIRAGE.exe - Haunted Operating System",
                                size = 2048,
                                created = os.time(),
                                modified = os.time()
                            }
                        }
                    }
                }
            }
        }
    }
}

-- Helper functions
local function getPathParts(path)
    local parts = {}
    for part in string.gmatch(path, "[^/\\]+") do
        table.insert(parts, part)
    end
    return parts
end

local function getNodeByPath(path)
    local parts = getPathParts(path)
    local current = fileSystem.root

    for _, part in ipairs(parts) do
        if not current.children then
            return nil
        end
        current = current.children[part]
        if not current then
            return nil
        end
    end

    return current
end

-- File operations
function FileSystem.createFile(path, name, type, content)
    local parent = getNodeByPath(path)
    if not parent or parent.type ~= "directory" then
        return false, "Invalid path or not a directory"
    end

    if parent.children[name] then
        return false, "File already exists"
    end

    parent.children[name] = {
        name = name,
        type = type,
        content = content,
        size = content and #content or 0,
        created = os.time(),
        modified = os.time()
    }

    return true
end

function FileSystem.createDirectory(path, name)
    local parent = getNodeByPath(path)
    if not parent or parent.type ~= "directory" then
        return false, "Invalid path or not a directory"
    end

    if parent.children[name] then
        return false, "Directory already exists"
    end

    parent.children[name] = {
        name = name,
        type = "directory",
        children = {}
    }

    return true
end

function FileSystem.delete(path)
    local parts = getPathParts(path)
    local fileName = table.remove(parts)
    local parent = getNodeByPath(table.concat(parts, "/"))

    if not parent or not parent.children[fileName] then
        return false, "File or directory not found"
    end

    parent.children[fileName] = nil
    return true
end

function FileSystem.readFile(path)
    local node = getNodeByPath(path)
    if not node or node.type == "directory" then
        return nil, "File not found or is a directory"
    end

    return node.content
end

function FileSystem.writeFile(path, content)
    local node = getNodeByPath(path)
    if not node or node.type == "directory" then
        return false, "File not found or is a directory"
    end

    node.content = content
    node.size = #content
    node.modified = os.time()
    return true
end

function FileSystem.listDirectory(path)
    local node = getNodeByPath(path)
    if not node or node.type ~= "directory" then
        return nil, "Directory not found"
    end

    local items = {}
    for name, item in pairs(node.children) do
        table.insert(items, {
            name = item.name,
            type = item.type,
            size = item.size or 0,
            created = item.created,
            modified = item.modified,
            icon = FILE_ICONS[item.type] or "📁"
        })
    end

    return items
end

function FileSystem.getFileInfo(path)
    local node = getNodeByPath(path)
    if not node then
        return nil, "File not found"
    end

    return {
        name = node.name,
        type = node.type,
        size = node.size or 0,
        created = node.created,
        modified = node.modified,
        icon = FILE_ICONS[node.type] or "📁"
    }
end

-- Corruption effects
function FileSystem.corruptFile(path, intensity)
    local node = getNodeByPath(path)
    if not node or node.type == "directory" then
        return false, "File not found or is a directory"
    end

    -- Corrupt file content
    if node.content then
        local corrupted = ""
        for i = 1, #node.content do
            if math.random() < intensity then
                corrupted = corrupted .. string.char(math.random(33, 126))
            else
                corrupted = corrupted .. string.sub(node.content, i, i)
            end
        end
        node.content = corrupted
    end

    -- Change file type
    if math.random() < intensity then
        node.type = FILE_TYPES.CORRUPTED
    end

    node.modified = os.time()
    return true
end

return FileSystem 