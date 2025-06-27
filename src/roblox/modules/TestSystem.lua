-- TestSystem Module
local TestSystem = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local PersonalityState = require(script.Parent.PersonalityState)
local PersonalityResponses = require(script.Parent.PersonalityResponses)
local PersonalityEffects = require(script.Parent.PersonalityEffects)
local GlitchEffect = require(script.Parent.GlitchEffect)
local FileSystem = require(script.Parent.FileSystem)
local CommandSystem = require(script.Parent.CommandSystem)
local TerminalInterface = require(script.Parent.TerminalInterface)
local GameInterface = require(script.Parent.GameInterface)

-- Test results
local testResults = {
    passed = 0,
    failed = 0,
    total = 0
}

-- Helper functions
local function assertEqual(expected, actual, message)
    testResults.total = testResults.total + 1
    if expected == actual then
        testResults.passed = testResults.passed + 1
        print("✅ PASSED:", message)
        return true
    else
        testResults.failed = testResults.failed + 1
        print("❌ FAILED:", message)
        print("  Expected:", expected)
        print("  Actual:", actual)
        return false
    end
end

local function assertNotEqual(expected, actual, message)
    testResults.total = testResults.total + 1
    if expected ~= actual then
        testResults.passed = testResults.passed + 1
        print("✅ PASSED:", message)
        return true
    else
        testResults.failed = testResults.failed + 1
        print("❌ FAILED:", message)
        print("  Expected: not", expected)
        print("  Actual:", actual)
        return false
    end
end

local function assertTrue(condition, message)
    testResults.total = testResults.total + 1
    if condition then
        testResults.passed = testResults.passed + 1
        print("✅ PASSED:", message)
        return true
    else
        testResults.failed = testResults.failed + 1
        print("❌ FAILED:", message)
        print("  Expected: true")
        print("  Actual: false")
        return false
    end
end

local function assertFalse(condition, message)
    testResults.total = testResults.total + 1
    if not condition then
        testResults.passed = testResults.passed + 1
        print("✅ PASSED:", message)
        return true
    else
        testResults.failed = testResults.failed + 1
        print("❌ FAILED:", message)
        print("  Expected: false")
        print("  Actual: true")
        return false
    end
end

-- Test personality state
local function testPersonalityState()
    print("\n=== Testing PersonalityState ===")
    
    -- Test initialization
    assertTrue(PersonalityState.initialize(), "PersonalityState initialization")
    
    -- Test personality switching
    assertTrue(PersonalityState.setPersonality("SABLE"), "Set personality to SABLE")
    assertEqual("SABLE", PersonalityState.getCurrentPersonality(), "Get current personality")
    
    -- Test trust level
    assertTrue(PersonalityState.setTrustLevel(50), "Set trust level")
    assertEqual(50, PersonalityState.getTrustLevel(), "Get trust level")
    
    -- Test corruption level
    assertTrue(PersonalityState.setCorruptionLevel(25), "Set corruption level")
    assertEqual(25, PersonalityState.getCorruptionLevel(), "Get corruption level")
    
    -- Test memory management
    assertTrue(PersonalityState.addMemory("test_memory", "Test memory content"), "Add memory")
    assertEqual("Test memory content", PersonalityState.getMemory("test_memory"), "Get memory")
end

-- Test personality responses
local function testPersonalityResponses()
    print("\n=== Testing PersonalityResponses ===")
    
    -- Test response generation
    local response = PersonalityResponses.getResponse("SABLE", "GREETING")
    assertNotEqual(nil, response, "Get SABLE greeting response")
    
    -- Test response formatting
    local formatted = PersonalityResponses.formatResponse("Hello, {name}!", {name = "User"})
    assertEqual("Hello, User!", formatted, "Format response with variables")
    
    -- Test response types
    local types = PersonalityResponses.getResponseTypes()
    assertTrue(#types > 0, "Get response types")
end

-- Test file system
local function testFileSystem()
    print("\n=== Testing FileSystem ===")
    
    -- Test directory operations
    assertTrue(FileSystem.createDirectory("/test_dir"), "Create directory")
    assertTrue(FileSystem.changeDirectory("/test_dir"), "Change directory")
    
    -- Test file operations
    assertTrue(FileSystem.writeFile("/test_dir/test.txt", "Test content"), "Write file")
    assertEqual("Test content", FileSystem.readFile("/test_dir/test.txt"), "Read file")
    
    -- Test file info
    local info = FileSystem.getFileInfo("/test_dir/test.txt")
    assertNotEqual(nil, info, "Get file info")
    assertEqual("test.txt", info.name, "File name")
    
    -- Test directory listing
    local items = FileSystem.listDirectory("/test_dir")
    assertNotEqual(nil, items, "List directory")
    assertTrue(#items > 0, "Directory not empty")
end

-- Test command system
local function testCommandSystem()
    print("\n=== Testing CommandSystem ===")
    
    -- Test basic commands
    local success, result = CommandSystem.executeCommand("help")
    assertTrue(success, "Execute help command")
    
    -- Test file commands
    success, result = CommandSystem.executeCommand("cd /test_dir")
    assertTrue(success, "Execute cd command")
    
    -- Test personality commands
    success, result = CommandSystem.executeCommand("personality set SABLE")
    assertTrue(success, "Execute personality command")
    
    -- Test invalid command
    success, result = CommandSystem.executeCommand("invalid_command")
    assertFalse(success, "Handle invalid command")
end

-- Test effects
local function testEffects()
    print("\n=== Testing Effects ===")
    
    -- Test personality effects
    local success = PersonalityEffects.applyEffect("test_target", "VISUAL")
    assertTrue(success, "Apply personality effect")
    
    -- Test glitch effects
    success = GlitchEffect.applyGlitch("test_target", "POSITION")
    assertTrue(success, "Apply glitch effect")
    
    -- Test effect removal
    success = PersonalityEffects.removeEffect("test_target")
    assertTrue(success, "Remove personality effect")
    
    success = GlitchEffect.removeGlitch("test_target")
    assertTrue(success, "Remove glitch effect")
end

-- Run all tests
function TestSystem.runTests()
    print("\n=== Starting MIRAGE.EXE Tests ===")
    
    -- Reset test results
    testResults = {
        passed = 0,
        failed = 0,
        total = 0
    }
    
    -- Run test suites
    testPersonalityState()
    testPersonalityResponses()
    testFileSystem()
    testCommandSystem()
    testEffects()
    
    -- Print summary
    print("\n=== Test Summary ===")
    print("Total Tests:", testResults.total)
    print("Passed:", testResults.passed)
    print("Failed:", testResults.failed)
    print("Success Rate:", string.format("%.1f%%", (testResults.passed / testResults.total) * 100))
    
    return testResults
end

return TestSystem 