local testScript = require("tests/unitTestLib/testlib")
local test

Log = {}

Log.errors = {}

Log.log = function(message) end
Log.error = error
Log.warn = Log.log

local testLib = nil

local totalTime = 0

function testScript.run(_testLib)
    testLib = _testLib
    testLib.totalTime = 0

    local testFilesDirectory = "tests/unittests/tests/"

    -- Get all test files from the directory
    local testFiles = getFilesInDirectory(testFilesDirectory)

    if testLib.specificTest then
        for i, file in ipairs(testFiles) do
            if file:sub(- #testLib.specificTest) == testLib.specificTest then
                print("Running specific test: " .. testLib.specificTest)
                testFiles = { file }
            end
        end
    end

    for _, file in ipairs(testFiles) do
        testScript.runTestFile(file)
    end
end

function testScript.runTestFile(path)
    local startTime = os.clock()
    testLib.newSection(path)
    require(path)(testLib)
    testLib.totalTime = testLib.totalTime + os.clock() - startTime
end

function getFilesInDirectory(directory)
    local files = {}
    local command
    if package.config:sub(1, 1) == '\\' then
        -- Windows
        command = 'dir "' .. directory .. '" /b'
    else
        -- Unix-like (Linux, macOS)
        command = 'ls "' .. directory .. '"'
    end
    local p = io.popen(command)
    for file in p:lines() do
        if file:match("%.lua$") then
            local name = file:sub(1, -5)
            table.insert(files, directory .. name)
        end
    end
    p:close()
    return files
end

return testScript
