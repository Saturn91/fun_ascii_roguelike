--get first script param
if arg[1] == nil then
    extensive = false
elseif arg[1] == '-l' then
    extensive = true
elseif #arg[1] > 2 then
    extensive = true
    specificTest = arg[1]
else
    extensive = false
end
local extensive = arg[1] == "-l"

test = require("tests/unitTestLib/testlib")
test.silent = not extensive
test.specificTest = specificTest

local t = require("tests/unittests/test")

test.init()
t.run(test)
test.result(false, t.totalTime, 0.2) --max 0.2s for all tests
