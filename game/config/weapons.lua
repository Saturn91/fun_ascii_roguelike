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
    for _, weapon in pairs(config) do
        if type(weapon) == "table" then
            hasWeapons = true

            -- Validate individual weapon
            local result = weaponConfig.validateWeapon(weapon)
            if result ~= true then return result end
        end
    end

    if not hasWeapons then
        return "Config must contain at least one weapon type"
    end
    
    return true
end

function weaponConfig.validateWeapon(weapon)
    return Weapon.validate(weapon)
end

return weaponConfig
