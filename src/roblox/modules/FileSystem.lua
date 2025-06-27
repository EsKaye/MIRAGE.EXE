-- FileSystem Module
local FileSystem = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Constants
local FILE_TYPES = {
    TEXT = "text",
    IMAGE = "image",
    AUDIO = "audio",
    EXECUTABLE = "executable",
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
        name = "root",
        type = "directory",
        children = {
            ["home"] = {
                name = "home",
                type = "directory",
                children = {
                    ["documents"] = {
                        name = "documents",
                        type = "directory",
                        children = {
                            ["readme.txt"] = {
                                name = "readme.txt",
                                type = FILE_TYPES.TEXT,
                                content = "Welcome to MIRAGE.exe\n\nThis is a simulated operating system with multiple AI personalities.\n\nType 'help' in the terminal for available commands.",
                                size = 150,
                                created = os.time(),
                                modified = os.time()
                            }
                        }
                    },
                    ["downloads"] = {
                        name = "downloads",
                        type = "directory",
                        children = {}
                    },
                    ["pictures"] = {
                        name = "pictures",
                        type = "directory",
                        children = {}
                    },
                    ["music"] = {
                        name = "music",
                        type = "directory",
                        children = {}
                    }
                }
            },
            ["system"] = {
                name = "system",
                type = "directory",
                children = {
                    ["config.json"] = {
                        name = "config.json",
                        type = FILE_TYPES.TEXT,
                        content = "{\n  \"version\": \"1.0.0\",\n  \"personalities\": [\"SABLE\", \"NULL\", \"HONEY\"],\n  \"defaultPersonality\": \"SABLE\"\n}",
                        size = 100,
                        created = os.time(),
                        modified = os.time()
                    }
                }
            },
            ["bin"] = {
                name = "bin",
                type = "directory",
                children = {
                    ["terminal.exe"] = {
                        name = "terminal.exe",
                        type = FILE_TYPES.EXECUTABLE,
                        content = "TERMINAL_PROGRAM",
                        size = 500,
                        created = os.time(),
                        modified = os.time()
                    }
                }
            }
        }
    }
}

-- Current directory
local currentDirectory = fileSystem.root

-- Helper functions
local function splitPath(path)
    local parts = {}
    for part in string.gmatch(path, "[^/]+") do
        table.insert(parts, part)
    end
    return parts
end

local function getNode(path)
    if path == "/" then
        return fileSystem.root
    end

    local parts = splitPath(path)
    local node = fileSystem.root

    for _, part in ipairs(parts) do
        if not node.children or not node.children[part] then
            return nil
        end
        node = node.children[part]
    end

    return node
end

local function getParentNode(path)
    if path == "/" then
        return nil
    end

    local parts = splitPath(path)
    table.remove(parts)
    return getNode("/" .. table.concat(parts, "/"))
end

local function getFileName(path)
    local parts = splitPath(path)
    return parts[#parts]
end

-- Change directory
function FileSystem.changeDirectory(path)
    if path == ".." then
        if currentDirectory == fileSystem.root then
            return false, "Already at root directory"
        end
        currentDirectory = getParentNode(currentDirectory.path)
        return true
    end

    local node = getNode(path)
    if not node then
        return false, "Directory not found"
    end

    if node.type ~= "directory" then
        return false, "Not a directory"
    end

    currentDirectory = node
    return true
end

-- List directory
function FileSystem.listDirectory(path)
    local node = path and getNode(path) or currentDirectory
    if not node then
        return nil
    end

    if node.type ~= "directory" then
        return nil
    end

    local items = {}
    for _, child in pairs(node.children) do
        table.insert(items, {
            name = child.name,
            type = child.type,
            size = child.size,
            created = child.created,
            modified = child.modified,
            icon = FILE_ICONS[child.type] or "📁"
        })
    end

    return items
end

-- Read file
function FileSystem.readFile(path)
    local node = getNode(path)
    if not node then
        return nil
    end

    if node.type == "directory" then
        return nil
    end

    return node.content
end

-- Write file
function FileSystem.writeFile(path, content)
    local parent = getParentNode(path)
    if not parent then
        return false, "Parent directory not found"
    end

    local fileName = getFileName(path)
    if parent.children[fileName] then
        return false, "File already exists"
    end

    parent.children[fileName] = {
        name = fileName,
        type = FILE_TYPES.TEXT,
        content = content,
        size = #content,
        created = os.time(),
        modified = os.time()
    }

    return true
end

-- Create directory
function FileSystem.createDirectory(path)
    local parent = getParentNode(path)
    if not parent then
        return false, "Parent directory not found"
    end

    local dirName = getFileName(path)
    if parent.children[dirName] then
        return false, "Directory already exists"
    end

    parent.children[dirName] = {
        name = dirName,
        type = "directory",
        children = {},
        created = os.time(),
        modified = os.time()
    }

    return true
end

-- Delete file or directory
function FileSystem.delete(path)
    local parent = getParentNode(path)
    if not parent then
        return false, "Parent directory not found"
    end

    local name = getFileName(path)
    if not parent.children[name] then
        return false, "File or directory not found"
    end

    parent.children[name] = nil
    return true
end

-- Move file or directory
function FileSystem.move(source, destination)
    local sourceNode = getNode(source)
    if not sourceNode then
        return false, "Source not found"
    end

    local destParent = getParentNode(destination)
    if not destParent then
        return false, "Destination directory not found"
    end

    local destName = getFileName(destination)
    if destParent.children[destName] then
        return false, "Destination already exists"
    end

    local sourceParent = getParentNode(source)
    sourceParent.children[sourceNode.name] = nil
    destParent.children[destName] = sourceNode
    sourceNode.name = destName

    return true
end

-- Copy file or directory
function FileSystem.copy(source, destination)
    local sourceNode = getNode(source)
    if not sourceNode then
        return false, "Source not found"
    end

    local destParent = getParentNode(destination)
    if not destParent then
        return false, "Destination directory not found"
    end

    local destName = getFileName(destination)
    if destParent.children[destName] then
        return false, "Destination already exists"
    end

    local function deepCopy(node)
        local copy = {
            name = node.name,
            type = node.type,
            created = os.time(),
            modified = os.time()
        }

        if node.type == "directory" then
            copy.children = {}
            for name, child in pairs(node.children) do
                copy.children[name] = deepCopy(child)
            end
        else
            copy.content = node.content
            copy.size = node.size
        end

        return copy
    end

    destParent.children[destName] = deepCopy(sourceNode)
    return true
end

-- Get current directory
function FileSystem.getCurrentDirectory()
    return currentDirectory
end

-- Get file type
function FileSystem.getFileType(path)
    local node = getNode(path)
    if not node then
        return nil
    end

    return node.type
end

-- Get file info
function FileSystem.getFileInfo(path)
    local node = getNode(path)
    if not node then
        return nil
    end

    return {
        name = node.name,
        type = node.type,
        size = node.size,
        created = node.created,
        modified = node.modified,
        icon = FILE_ICONS[node.type] or "📁"
    }
end

-- Get file types
function FileSystem.getFileTypes()
    return FILE_TYPES
end

-- Get file icons
function FileSystem.getFileIcons()
    return FILE_ICONS
end

return FileSystem 