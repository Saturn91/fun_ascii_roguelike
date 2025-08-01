-- Dice module test
-- Testing dice formula parsing and rolling

-- Mock love.math.random for consistent testing
love = love or {}
love.math = love.math or {}

-- Mock random function that returns predictable values for testing
local mock_random_values = {}
local mock_random_index = 1

function love.math.random(min, max)
    if #mock_random_values > 0 then
        local value = mock_random_values[mock_random_index]
        mock_random_index = mock_random_index + 1
        if mock_random_index > #mock_random_values then
            mock_random_index = 1
        end
        return value
    else
        -- Use Lua's built-in random if no mock values are set
        if min and max then
            return math.random(min, max)
        elseif min then
            return math.random(min)
        else
            return math.random()
        end
    end
end

-- Helper function to set mock random values
local function setMockRandomValues(values)
    mock_random_values = values
    mock_random_index = 1
end

-- Helper function to clear mock random values (use real random)
local function clearMockRandomValues()
    mock_random_values = {}
    mock_random_index = 1
end

-- Import the Dice module
local Dice = require("game/dice")

function run(test)
    
    -- Test getDicesFromFormula function
    test.newSection("getDicesFromFormula Tests")
    
    -- Test basic d6
    local diceSize, diceAmount, constant = Dice.getDicesFromFormula("d6")
    test.assert_equal(6, diceSize, "d6 should have dice size 6")
    test.assert_equal(1, diceAmount, "d6 should have dice amount 1")
    test.assert_equal(0, constant, "d6 should have constant 0")
    
    -- Test 2d6
    diceSize, diceAmount, constant = Dice.getDicesFromFormula("2d6")
    test.assert_equal(6, diceSize, "2d6 should have dice size 6")
    test.assert_equal(2, diceAmount, "2d6 should have dice amount 2")
    test.assert_equal(0, constant, "2d6 should have constant 0")
    
    -- Test 2d6+3
    diceSize, diceAmount, constant = Dice.getDicesFromFormula("2d6+3")
    test.assert_equal(6, diceSize, "2d6+3 should have dice size 6")
    test.assert_equal(2, diceAmount, "2d6+3 should have dice amount 2")
    test.assert_equal(3, constant, "2d6+3 should have constant 3")
    
    -- Test d20-2
    diceSize, diceAmount, constant = Dice.getDicesFromFormula("d20-2")
    test.assert_equal(20, diceSize, "d20-2 should have dice size 20")
    test.assert_equal(1, diceAmount, "d20-2 should have dice amount 1")
    test.assert_equal(-2, constant, "d20-2 should have constant -2")
    
    -- Test 3d8+5
    diceSize, diceAmount, constant = Dice.getDicesFromFormula("3d8+5")
    test.assert_equal(8, diceSize, "3d8+5 should have dice size 8")
    test.assert_equal(3, diceAmount, "3d8+5 should have dice amount 3")
    test.assert_equal(5, constant, "3d8+5 should have constant 5")
    
    -- Test with spaces
    diceSize, diceAmount, constant = Dice.getDicesFromFormula(" 2d6 + 3 ")
    test.assert_equal(6, diceSize, "Spaces should be ignored")
    test.assert_equal(2, diceAmount, "Spaces should be ignored")
    test.assert_equal(3, constant, "Spaces should be ignored")
    
    -- Test invalid formulas
    diceSize, diceAmount, constant = Dice.getDicesFromFormula("invalid")
    test.assert_equal(nil, diceSize, "Invalid formula should return nil")
    test.assert_equal(nil, diceAmount, "Invalid formula should return nil")
    test.assert_equal(nil, constant, "Invalid formula should return nil")
    
    diceSize, diceAmount, constant = Dice.getDicesFromFormula("")
    test.assert_equal(nil, diceSize, "Empty formula should return nil")
    test.assert_equal(nil, diceAmount, "Empty formula should return nil")
    test.assert_equal(nil, constant, "Empty formula should return nil")
    
    diceSize, diceAmount, constant = Dice.getDicesFromFormula(nil)
    test.assert_equal(nil, diceSize, "Nil formula should return nil")
    test.assert_equal(nil, diceAmount, "Nil formula should return nil")
    test.assert_equal(nil, constant, "Nil formula should return nil")
    
    -- Test roll function with controlled random values
    test.newSection("Dice Roll Tests - Controlled")
    
    -- Test d6 with controlled random (always returns 3)
    setMockRandomValues({3})
    local result = Dice.roll("d6")
    test.assert_equal(3, result, "d6 with mock random 3 should return 3")
    
    -- Test 2d6 with controlled random (always returns 3)
    setMockRandomValues({3, 3})
    result = Dice.roll("2d6")
    test.assert_equal(6, result, "2d6 with mock random 3,3 should return 6")
    
    -- Test 2d6+3 with controlled random (always returns 3)
    setMockRandomValues({3, 3})
    result = Dice.roll("2d6+3")
    test.assert_equal(9, result, "2d6+3 with mock random 3,3 should return 9")
    
    -- Test d20-2 with controlled random (always returns 10)
    setMockRandomValues({10})
    result = Dice.roll("d20-2")
    test.assert_equal(8, result, "d20-2 with mock random 10 should return 8")
    
    -- Test minimum value enforcement
    setMockRandomValues({1})
    result = Dice.roll("d6-10")
    test.assert_equal(1, result, "Result should never be less than 1")
    
    -- Test range validation with real random
    test.newSection("Dice Roll Range Tests - Random")
    clearMockRandomValues()
    
    -- Test d6 range (30 rolls)
    for i = 1, 30 do
        result = Dice.roll("d6")
        test.assert_equal(true, result >= 1 and result <= 6, "d6 roll " .. i .. " should be between 1-6, got " .. result)
    end
    
    -- Test 2d6 range (30 rolls)
    for i = 1, 30 do
        result = Dice.roll("2d6")
        test.assert_equal(true, result >= 2 and result <= 12, "2d6 roll " .. i .. " should be between 2-12, got " .. result)
    end
    
    -- Test 2d6+3 range (30 rolls)
    for i = 1, 30 do
        result = Dice.roll("2d6+3")
        test.assert_equal(true, result >= 5 and result <= 15, "2d6+3 roll " .. i .. " should be between 5-15, got " .. result)
    end
    
    -- Test d20-2 range (30 rolls)
    for i = 1, 30 do
        result = Dice.roll("d20-2")
        test.assert_equal(true, result >= 1 and result <= 18, "d20-2 roll " .. i .. " should be between 1-18, got " .. result)
    end
    
    -- Test 3d8+5 range (30 rolls)
    for i = 1, 30 do
        result = Dice.roll("3d8+5")
        test.assert_equal(true, result >= 8 and result <= 29, "3d8+5 roll " .. i .. " should be between 8-29, got " .. result)
    end
    
    -- Test edge cases
    test.newSection("Edge Case Tests")
    
    -- Test invalid formula returns default
    result = Dice.roll("invalid", nil, 42)
    test.assert_equal(42, result, "Invalid formula should return default value")
    
    -- Test invalid formula without default
    result = Dice.roll("invalid")
    test.assert_equal(1, result, "Invalid formula without default should return 1")
    
    -- Test nil formula with fallback parameters
    result = Dice.roll(nil, 3, 6)
    test.assert_equal(true, result >= 3 and result <= 18, "Nil formula with fallback should use fallback logic")
    
    -- Test nil formula without fallback
    result = Dice.roll(nil)
    test.assert_equal(1, result, "Nil formula without fallback should return 1")
    
    -- Test multiple dice with large numbers
    for i = 1, 10 do
        result = Dice.roll("10d10")
        test.assert_equal(true, result >= 10 and result <= 100, "10d10 roll " .. i .. " should be between 10-100, got " .. result)
    end

    --Test Dice.validateFormula
    local testCases = {
        { formula ="d6", valid = true },
        { formula = "2d6", valid = true},
        { formula = "2d6+3", valid = true},
        { formula = "d20-2", valid = true},
        { formula = "3d8+5", valid = true},
        { formula = "invalid", valid = false},
        { formula = "", valid = false},
        { formula = "nil", valid = false},
    }

    for _, case in ipairs(testCases) do
        test.assert_equal(case.valid, Dice.validateFormula(case.formula), case.formula)
    end
end

return run
