-- Weapon Configuration Array
local weaponConfig = {
    sword = {
        id = "sword",
        char = "/",
        color = "silver",
        damage = "2d2",
        range = 1,
        name = "Sword"
    },
    bow = {
        id = "bow",
        char = "}",
        color = "brown",
        damage = "1d6",
        range = 5,
        name = "Bow"
    },
    staff = {
        id = "staff",
        char = "|",
        color = "white",
        damage = "1d1",
        range = 1,
        name = "Staff"
    }
}

-- Validation function for weapon configuration
function weaponConfig.validate(config)
    if not config then
        return "Config is nil"
    end
    
    if type(config) ~= "table" then
        return "Config must be a table"
    end

    -- Check if there's at least one weapon type
    local hasWeapons = false
    for weaponType, weapon in pairs(config) do
        if type(weapon) == "table" then
            hasWeapons = true

            -- Validate individual weapon
            local result = weaponConfig.validateWeapon(weaponType, weapon)
            if result ~= true then
                return result
            end
        end
    end

    if not hasWeapons then
        return "Config must contain at least one weapon type"
    end
    
    return true
end

function weaponConfig.validateWeapon(weaponType, weapon)

    if not weapon or type(weapon) ~= "table" then
        return string.format("Weapon '%s' must be a table", weaponType)
    end

    -- Validate id
    if not weapon.id or type(weapon.id) ~= "string" or weapon.id == "" then
        return string.format("Weapon '%s' must have a valid id", weaponType)
    end

    -- Validate char
    if not weapon.char or type(weapon.char) ~= "string" or weapon.char == "" then
        return string.format("Weapon '%s' must have a valid char", weaponType)
    end

    -- Validate color
    if weapon.color and type(weapon.color) ~= "string" then
        return string.format("Weapon '%s' color must be a string", weaponType)
    end

    -- Validate damage
    if not weapon.damage or not Dice.validateFormula(weapon.damage) then
        return string.format("Weapon '%s' damage invalid dice formula (e.g. 1d2)", weaponType)
    end

    -- Validate range
    if weapon.range and (type(weapon.range) ~= "number" or weapon.range < 1) then
        return string.format("Weapon '%s' range must be a positive number", weaponType)
    end

    -- Validate name
    if weapon.name and type(weapon.name) ~= "string" then
        return string.format("Weapon '%s' name must be a string", weaponType)
    end

    return true
end

return weaponConfig
