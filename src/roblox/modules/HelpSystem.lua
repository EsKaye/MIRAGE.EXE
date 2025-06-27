-- HelpSystem Module
local HelpSystem = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Modules
local UIComponents = require(script.Parent.UIComponents)
local CommandSystem = require(script.Parent.CommandSystem)
local PersonalityState = require(script.Parent.PersonalityState)

-- Constants
local HELP_DEFAULTS = {
    width = 800,
    height = 600,
    titleHeight = 30,
    padding = 10,
    cornerRadius = 8,
    backgroundColor = Color3.fromRGB(20, 20, 20),
    titleColor = Color3.fromRGB(30, 30, 30),
    textColor = Color3.fromRGB(0, 255, 0),
    hoverColor = Color3.fromRGB(40, 40, 40),
    selectedColor = Color3.fromRGB(60, 60, 60),
    sectionHeight = 40,
    contentPadding = 20
}

-- Help content
local helpContent = {
    commands = {
        title = "Commands",
        content = {
            {
                title = "File Commands",
                items = {
                    {name = "cd", description = "Change directory", usage = "cd <path>"},
                    {name = "ls", description = "List directory contents", usage = "ls [path]"},
                    {name = "cat", description = "Display file contents", usage = "cat <file>"},
                    {name = "mkdir", description = "Create directory", usage = "mkdir <name>"},
                    {name = "rm", description = "Remove file or directory", usage = "rm <path>"},
                    {name = "mv", description = "Move file or directory", usage = "mv <source> <destination>"},
                    {name = "cp", description = "Copy file or directory", usage = "cp <source> <destination>"}
                }
            },
            {
                title = "System Commands",
                items = {
                    {name = "clear", description = "Clear terminal", usage = "clear"},
                    {name = "help", description = "Show help", usage = "help [command]"},
                    {name = "pwd", description = "Print working directory", usage = "pwd"}
                }
            },
            {
                title = "Personality Commands",
                items = {
                    {name = "personality", description = "Manage personalities", usage = "personality <set|get|list> [name]"},
                    {name = "trust", description = "Manage trust level", usage = "trust <get|set> [value]"},
                    {name = "corruption", description = "Manage corruption level", usage = "corruption <get|set> [value]"}
                }
            },
            {
                title = "Effect Commands",
                items = {
                    {name = "effect", description = "Apply personality effect", usage = "effect <type> [target]"},
                    {name = "glitch", description = "Apply glitch effect", usage = "glitch <type> [target]"}
                }
            }
        }
    },
    tutorials = {
        title = "Tutorials",
        content = {
            {
                title = "Getting Started",
                steps = {
                    "Welcome to MIRAGE.EXE! This is a simulated operating system with AI personalities.",
                    "Use the terminal to interact with the system. Type 'help' to see available commands.",
                    "Navigate the file system using 'cd' and 'ls' commands.",
                    "Interact with AI personalities using the 'personality' command.",
                    "Manage trust and corruption levels to influence AI behavior."
                }
            },
            {
                title = "File System",
                steps = {
                    "The file system is organized in a hierarchical structure.",
                    "Use 'cd' to change directories and 'ls' to list contents.",
                    "Create directories with 'mkdir' and remove them with 'rm'.",
                    "Move files with 'mv' and copy them with 'cp'.",
                    "View file contents with 'cat'."
                }
            },
            {
                title = "AI Personalities",
                steps = {
                    "There are three AI personalities: SABLE, NULL, and HONEY.",
                    "Each personality has unique traits and behaviors.",
                    "Use 'personality set' to switch between personalities.",
                    "Build trust with 'trust set' to unlock new features.",
                    "Manage corruption with 'corruption set' to influence behavior."
                }
            },
            {
                title = "Visual Effects",
                steps = {
                    "Apply personality effects with the 'effect' command.",
                    "Create glitch effects with the 'glitch' command.",
                    "Effects can be applied to files, directories, or the entire system.",
                    "Some effects require specific trust or corruption levels.",
                    "Combine effects for unique visual experiences."
                }
            }
        }
    },
    faq = {
        title = "FAQ",
        content = {
            {
                question = "What is MIRAGE.EXE?",
                answer = "MIRAGE.EXE is a simulated operating system with AI personalities. It combines file system management, command-line interaction, and AI personality simulation."
            },
            {
                question = "How do I interact with AI personalities?",
                answer = "Use the 'personality' command to switch between personalities. Build trust and manage corruption to influence their behavior."
            },
            {
                question = "What are the different personalities?",
                answer = "SABLE is the default personality, NULL is aggressive and corruptive, and HONEY is friendly and helpful. Each has unique traits and behaviors."
            },
            {
                question = "How do I manage files?",
                answer = "Use commands like 'cd', 'ls', 'mkdir', 'rm', 'mv', and 'cp' to navigate and manage the file system."
            },
            {
                question = "What are visual effects?",
                answer = "Visual effects are personality-specific and glitch effects that can be applied to the system. Use 'effect' and 'glitch' commands to apply them."
            }
        }
    }
}

-- Helper functions
local function createSection(parent, title, yOffset)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, HELP_DEFAULTS.sectionHeight)
    section.Position = UDim2.new(0, 0, 0, yOffset)
    section.BackgroundColor3 = HELP_DEFAULTS.titleColor
    section.BorderSizePixel = 0
    section.Parent = parent
    
    -- Add corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, HELP_DEFAULTS.cornerRadius)
    corner.Parent = section
    
    -- Add title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -HELP_DEFAULTS.padding * 2, 1, 0)
    titleLabel.Position = UDim2.new(0, HELP_DEFAULTS.padding, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = HELP_DEFAULTS.textColor
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.Font = Enum.Font.Code
    titleLabel.TextSize = 16
    titleLabel.Parent = section
    
    return section
end

local function createCommandItem(parent, command)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    -- Add name
    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(0, 100, 0, 20)
    name.Position = UDim2.new(0, 0, 0, 0)
    name.BackgroundTransparency = 1
    name.Text = command.name
    name.TextColor3 = HELP_DEFAULTS.textColor
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.TextYAlignment = Enum.TextYAlignment.Center
    name.Font = Enum.Font.Code
    name.TextSize = 14
    name.Parent = frame
    
    -- Add description
    local description = Instance.new("TextLabel")
    description.Size = UDim2.new(1, -110, 0, 20)
    description.Position = UDim2.new(0, 110, 0, 0)
    description.BackgroundTransparency = 1
    description.Text = command.description
    description.TextColor3 = HELP_DEFAULTS.textColor
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.TextYAlignment = Enum.TextYAlignment.Center
    description.Font = Enum.Font.Code
    description.TextSize = 14
    description.Parent = frame
    
    -- Add usage
    local usage = Instance.new("TextLabel")
    usage.Size = UDim2.new(1, -110, 0, 20)
    usage.Position = UDim2.new(0, 110, 0, 20)
    usage.BackgroundTransparency = 1
    usage.Text = "Usage: " .. command.usage
    usage.TextColor3 = HELP_DEFAULTS.textColor
    usage.TextXAlignment = Enum.TextXAlignment.Left
    usage.TextYAlignment = Enum.TextYAlignment.Center
    usage.Font = Enum.Font.Code
    usage.TextSize = 12
    usage.Parent = frame
    
    return frame
end

local function createTutorialStep(parent, step, index)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    -- Add step number
    local number = Instance.new("TextLabel")
    number.Size = UDim2.new(0, 30, 1, 0)
    number.Position = UDim2.new(0, 0, 0, 0)
    number.BackgroundTransparency = 1
    number.Text = tostring(index) .. "."
    number.TextColor3 = HELP_DEFAULTS.textColor
    number.TextXAlignment = Enum.TextXAlignment.Left
    number.TextYAlignment = Enum.TextYAlignment.Center
    number.Font = Enum.Font.Code
    number.TextSize = 14
    number.Parent = frame
    
    -- Add step text
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -40, 1, 0)
    text.Position = UDim2.new(0, 40, 0, 0)
    text.BackgroundTransparency = 1
    text.Text = step
    text.TextColor3 = HELP_DEFAULTS.textColor
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextYAlignment = Enum.TextYAlignment.Center
    text.Font = Enum.Font.Code
    text.TextSize = 14
    text.TextWrapped = true
    text.Parent = frame
    
    return frame
end

local function createFAQItem(parent, item)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 80)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    -- Add question
    local question = Instance.new("TextLabel")
    question.Size = UDim2.new(1, 0, 0, 20)
    question.Position = UDim2.new(0, 0, 0, 0)
    question.BackgroundTransparency = 1
    question.Text = "Q: " .. item.question
    question.TextColor3 = HELP_DEFAULTS.textColor
    question.TextXAlignment = Enum.TextXAlignment.Left
    question.TextYAlignment = Enum.TextYAlignment.Center
    question.Font = Enum.Font.Code
    question.TextSize = 14
    question.TextWrapped = true
    question.Parent = frame
    
    -- Add answer
    local answer = Instance.new("TextLabel")
    answer.Size = UDim2.new(1, 0, 0, 60)
    answer.Position = UDim2.new(0, 0, 0, 20)
    answer.BackgroundTransparency = 1
    answer.Text = "A: " .. item.answer
    answer.TextColor3 = HELP_DEFAULTS.textColor
    answer.TextXAlignment = Enum.TextXAlignment.Left
    answer.TextYAlignment = Enum.TextYAlignment.Top
    answer.Font = Enum.Font.Code
    answer.TextSize = 14
    answer.TextWrapped = true
    answer.Parent = frame
    
    return frame
end

-- Main function to create the help window
function HelpSystem.createWindow()
    -- Create main frame
    local frame = UIComponents.createWindow({
        title = "Help",
        width = HELP_DEFAULTS.width,
        height = HELP_DEFAULTS.height,
        titleHeight = HELP_DEFAULTS.titleHeight,
        padding = HELP_DEFAULTS.padding,
        cornerRadius = HELP_DEFAULTS.cornerRadius,
        backgroundColor = HELP_DEFAULTS.backgroundColor,
        titleColor = HELP_DEFAULTS.titleColor,
        textColor = HELP_DEFAULTS.textColor
    })
    
    -- Create content area
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, 0, 1, -HELP_DEFAULTS.titleHeight)
    content.Position = UDim2.new(0, 0, 0, HELP_DEFAULTS.titleHeight)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 6
    content.ScrollingDirection = Enum.ScrollingDirection.Y
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.Parent = frame
    
    -- Create sections
    local yOffset = HELP_DEFAULTS.padding
    
    -- Commands section
    local commandsSection = createSection(content, helpContent.commands.title, yOffset)
    yOffset = yOffset + HELP_DEFAULTS.sectionHeight + HELP_DEFAULTS.padding
    
    for _, category in ipairs(helpContent.commands.content) do
        local categoryTitle = Instance.new("TextLabel")
        categoryTitle.Size = UDim2.new(1, 0, 0, 30)
        categoryTitle.Position = UDim2.new(0, 0, 0, yOffset)
        categoryTitle.BackgroundTransparency = 1
        categoryTitle.Text = category.title
        categoryTitle.TextColor3 = HELP_DEFAULTS.textColor
        categoryTitle.TextXAlignment = Enum.TextXAlignment.Left
        categoryTitle.TextYAlignment = Enum.TextYAlignment.Center
        categoryTitle.Font = Enum.Font.Code
        categoryTitle.TextSize = 16
        categoryTitle.Parent = content
        
        yOffset = yOffset + 30
        
        for _, command in ipairs(category.items) do
            local item = createCommandItem(content, command)
            item.Position = UDim2.new(0, 0, 0, yOffset)
            yOffset = yOffset + 60
        end
        
        yOffset = yOffset + HELP_DEFAULTS.padding
    end
    
    -- Tutorials section
    local tutorialsSection = createSection(content, helpContent.tutorials.title, yOffset)
    yOffset = yOffset + HELP_DEFAULTS.sectionHeight + HELP_DEFAULTS.padding
    
    for _, tutorial in ipairs(helpContent.tutorials.content) do
        local tutorialTitle = Instance.new("TextLabel")
        tutorialTitle.Size = UDim2.new(1, 0, 0, 30)
        tutorialTitle.Position = UDim2.new(0, 0, 0, yOffset)
        tutorialTitle.BackgroundTransparency = 1
        tutorialTitle.Text = tutorial.title
        tutorialTitle.TextColor3 = HELP_DEFAULTS.textColor
        tutorialTitle.TextXAlignment = Enum.TextXAlignment.Left
        tutorialTitle.TextYAlignment = Enum.TextYAlignment.Center
        tutorialTitle.Font = Enum.Font.Code
        tutorialTitle.TextSize = 16
        tutorialTitle.Parent = content
        
        yOffset = yOffset + 30
        
        for i, step in ipairs(tutorial.steps) do
            local item = createTutorialStep(content, step, i)
            item.Position = UDim2.new(0, 0, 0, yOffset)
            yOffset = yOffset + 40
        end
        
        yOffset = yOffset + HELP_DEFAULTS.padding
    end
    
    -- FAQ section
    local faqSection = createSection(content, helpContent.faq.title, yOffset)
    yOffset = yOffset + HELP_DEFAULTS.sectionHeight + HELP_DEFAULTS.padding
    
    for _, item in ipairs(helpContent.faq.content) do
        local faqItem = createFAQItem(content, item)
        faqItem.Position = UDim2.new(0, 0, 0, yOffset)
        yOffset = yOffset + 80
    end
    
    -- Update canvas size
    content.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    
    -- Add close button
    local closeButton = UIComponents.createButton({
        text = "Close",
        size = UDim2.new(0, 100, 0, 30),
        position = UDim2.new(1, -110, 1, -40),
        parent = frame
    })
    
    closeButton.MouseButton1Click:Connect(function()
        frame:Destroy()
    end)
    
    return frame
end

-- Get help content
function HelpSystem.getContent()
    return helpContent
end

-- Get command help
function HelpSystem.getCommandHelp(command)
    for _, category in ipairs(helpContent.commands.content) do
        for _, cmd in ipairs(category.items) do
            if cmd.name == command then
                return cmd
            end
        end
    end
    return nil
end

-- Get tutorial
function HelpSystem.getTutorial(title)
    for _, tutorial in ipairs(helpContent.tutorials.content) do
        if tutorial.title == title then
            return tutorial
        end
    end
    return nil
end

-- Get FAQ
function HelpSystem.getFAQ(question)
    for _, item in ipairs(helpContent.faq.content) do
        if item.question == question then
            return item
        end
    end
    return nil
end

return HelpSystem 