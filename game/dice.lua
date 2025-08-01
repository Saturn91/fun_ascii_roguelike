local Dice = {}

-- Parse dice formula and return dice size, dice amount, and constant modifier
-- Returns: diceSize, diceAmount, constant
function Dice.getDicesFromFormula(diceFormula)
    if not diceFormula then
        return nil, nil, nil
    end
    
    -- Remove spaces from the formula
    diceFormula = string.gsub(diceFormula, "%s", "")
    
    -- Handle modifier (+ or - at the end)
    local modifier = 0
    local modifierPattern = "([%+%-])(%d+)$"
    local modifierMatch = string.match(diceFormula, modifierPattern)
    if modifierMatch then
        local sign, value = string.match(diceFormula, modifierPattern)
        modifier = tonumber(value) or 0
        if sign == "-" then
            modifier = -modifier
        end
        -- Remove modifier from formula
        diceFormula = string.gsub(diceFormula, modifierPattern, "")
    end
    
    -- Parse dice formula (XdY format)
    local numDice, diceSize
    
    -- Check for "dX" format (single die)
    if string.match(diceFormula, "^d%d+$") then
        numDice = 1
        diceSize = tonumber(string.match(diceFormula, "d(%d+)"))
    -- Check for "XdY" format
    elseif string.match(diceFormula, "^%d+d%d+$") then
        numDice, diceSize = string.match(diceFormula, "(%d+)d(%d+)")
        numDice = tonumber(numDice)
        diceSize = tonumber(diceSize)
    else
        -- Invalid format
        return nil, nil, nil
    end
    
    -- Validate parsed values
    if not numDice or not diceSize or numDice <= 0 or diceSize <= 0 then
        return nil, nil, nil
    end
    
    return diceSize, numDice, modifier
end

-- dice formula can be "2d6" "d6" "2d6+3"
function Dice.roll(diceFormula, diceCount, default)
    -- If no formula provided, use diceCount and default as fallback
    if not diceFormula then
        if diceCount and default then
            return love.math.random(diceCount, diceCount * default)
        end
        return 1
    end
    
    -- Parse the dice formula
    local diceSize, numDice, modifier = Dice.getDicesFromFormula(diceFormula)
    
    -- If parsing failed, return default or 1
    if not diceSize or not numDice then
        Log.log("Invalid dice formula: " .. (diceFormula or "nil"))
        return default or 1
    end
    
    -- Roll the dice
    local total = 0
    for i = 1, numDice do
        total = total + love.math.random(1, diceSize)
    end
    
    -- Apply modifier
    total = total + modifier
    
    -- Ensure minimum result is 1
    return math.max(1, total)
end

function Dice.validateFormula(diceFormula)
    val1, val2 = Dice.getDicesFromFormula(diceFormula)
    return val1 ~= nil and val2 ~= nil
end

return Dice