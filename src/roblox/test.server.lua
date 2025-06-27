-- Test Runner Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create module folder if it doesn't exist
local moduleFolder = ReplicatedStorage:FindFirstChild("MIRAGE_MODULES")
if not moduleFolder then
    moduleFolder = Instance.new("Folder")
    moduleFolder.Name = "MIRAGE_MODULES"
    moduleFolder.Parent = ReplicatedStorage
end

-- Load test system
local TestSystem = require(script.Parent.modules.TestSystem)

-- Run tests
print("\n=== MIRAGE.EXE Test Runner ===")
local results = TestSystem.runTests()

-- Output final status
if results.failed == 0 then
    print("\n✨ All tests passed successfully!")
else
    print("\n⚠️ Some tests failed. Please check the output above for details.")
end 