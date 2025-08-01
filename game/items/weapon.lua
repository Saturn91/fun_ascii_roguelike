local Weapon = {}

Weapon.__index = Weapon
setmetatable(Weapon, {__index = Item})

-- Constructor for creating a new weapon
function Weapon.new(config)
    if not config then error("Weapon config is required") end
    local weapon = setmetatable(Item.new(config), Weapon)

    -- Add weapon-specific properties here in the future
    -- weapon.damage = config.damage
    -- weapon.attackSpeed = config.attackSpeed
    -- weapon.range = config.range
    
    return weapon
end

function Weapon.validate(weapon)
    if not weapon or type(weapon) ~= "table" then
        return string.format("Weapon '%s' must be a table", json.stringify(weapon, true))
    end

    -- Validate id
    if not weapon.id or type(weapon.id) ~= "string" or #weapon.id == 0 then
        return string.format("Weapon '%s' must have a valid id", json.stringify(weapon, true))
    end

    -- Validate char
    if not weapon.char or type(weapon.char) ~= "string" or #weapon.char == 0 then
        return string.format("Weapon '%s' must have a valid char", weapon.id)
    end

    -- Validate color
    if weapon.color and type(weapon.color) ~= "string" then
        return string.format("Weapon '%s' color must be a string", weapon.id)
    end

    -- Validate damage
    if not weapon.damage or not Dice.validateFormula(weapon.damage) then
        return string.format("Weapon '%s' damage invalid dice formula (e.g. 1d2)", weapon.id)
    end

    -- Validate range
    if weapon.range and (type(weapon.range) ~= "number" or weapon.range < 1) then
        return string.format("Weapon '%s' range must be a positive number", weapon.id)
    end

    -- Validate name
    if weapon.name and type(weapon.name) ~= "string" then
        return string.format("Weapon '%s' name must be a string", weapon.id)
    end

    return true
end

return Weapon
