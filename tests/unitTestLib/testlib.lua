require("tests/unitTestLib/JsonUtil")

local testlib = {}

local tests = 0
local failed = 0
local passed = 0
local totalTests = 0

local currentSection = "main"

function log(info)
    print("[info]: " .. info)
end

function log_error(errorMsg)
    print("--> [error]: " .. errorMsg)
end

function testlib.init()
    tests = 0
    failed = 0
    passed = 0
end

function testlib.title(text)
    print("test: " .. text)
    return body
end

function isArray(any)
    if type(any) == "number" then return false end
    if type(any) == "boolean" then return false end
    return #any ~= nil and any[1] ~= nil
end

function convertAnyToString(any)
    if any == nil then return "/nil" end
    if any == true then return "bool/true" end
    if any == false then return "bool/false" end

    if isArray(any) then
        local str = ""
        for i = 1, #any do
            str = str .. any[i] .. ","
        end
        return str
    end
    return json.stringify(any, true)
end

function convertFloatToString(float, numOfDigits)
    -- Format the number with the specified number of digits
    local formatString = string.format("%%.%df", numOfDigits or 1)
    local formattedFloat = string.format(formatString, float)

    -- Print the result
    return "" .. formattedFloat
end

function float_equals(a, b)
    return convertFloatToString(a, 4) == convertFloatToString(b, 4)
end

function deep_equals(a, b)
    return json.stringify(a, true) == json.stringify(b, true)
end

function testlib.assert_equal(a, b, description)
    if description == nil then description = "unset description" end
    tests = tests + 1
    totalTests = totalTests + 1

    local test_failed = false

    if type(a) == "number" or type(b) == "number" or type(a) == "string" or type(b) == "string" or type(a) == "boolean" or type(b) == "boolean" or a == nil or b == nil then
        if type(a) == "number" and type(b) == "number" then
            local isFloat = math.floor(a) ~= a
            if isFloat then
                if math.floor(b) ~= b then
                    test_failed = not float_equals(a, b)
                else
                    test_failed = true
                end
            else
                test_failed = a ~= b
            end
        else
            test_failed = a ~= b
        end
    else
        test_failed = not deep_equals(a, b)
    end

    if test_failed then
        failed = failed + 1
        log_error(description .. " failed -> " .. convertAnyToString({ actual = a or "nil", expected = b or "nil" }))
    else
        passed = passed + 1
    end
end

function testlib.assert_error(func, message)
    local success, err = pcall(func)
    testlib.assert_equal(success, false, "Expected to throw: " .. message)
end

local lastStart = 0
local lastDuration = 0
function testlib.newSection(section)
    lastDuration = os.clock() - lastStart
    lastStart = os.clock()
    if tests > 0 then
        testlib.result(true)
        tests = 0
        failed = 0
        passed = 0
    end
    currentSection = section
end

function getMsString(timeS)
    return string.format("%.2f", timeS * 1000)
end

function testlib.result(noReturn, totalTime, maxTime)
    if failed > 0 then
        error(currentSection .. " -> " .. failed .. "/" .. passed .. " tests failed!")
        os.exit(1)
    else
        if not testlib.silent then
            log(currentSection ..
                " -> test succeded: " .. passed .. "/" .. tests .. " passed (" .. getMsString(lastDuration) .. ")ms")
        end

        if not noReturn then
            if totalTime > maxTime then
                log_error("Test took too long: " .. getMsString(totalTime) .. "ms")
                os.exit(1)
            end

            log("All " .. totalTests .. " tests passed (" .. getMsString(totalTime) .. "ms/" ..
                getMsString(maxTime) .. "ms)")
            os.exit(0)
        end
    end
end

function testlib.fail(msg)
    log_error(msg)
    failed = failed + 1
end

return testlib
