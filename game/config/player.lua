-- Player Configuration
local playerConfig = {
    char = "@",
    color = "", --if nil or empty use default color [player]
    health = 10,
    weapon = "sword", -- optional
    baseAttackDamage = 2,
}

-- Validation function for player configuration
function playerConfig.validate(config)
    if not config then
        return "Config is nil"
    end
    
    -- Validate char
    if config.char and (type(config.char) ~= "string" or config.char == "") then
        return "char must be a non-empty string"
    end
    
    -- Validate color (can be empty string or valid string)
    if config.color and type(config.color) ~= "string" then
        return "color must be a string"
    end
    
    -- Validate health
    if not config.health or type(config.health) ~= "number" or config.health <= 0 then
        return "health must be a positive number"
    end
    
    if config.health > 999 then
        return "health cannot exceed 999"
    end
    
    -- Validate baseAttackDamage
    if not config.baseAttackDamage or type(config.baseAttackDamage) ~= "number" or config.baseAttackDamage <= 0 then
        return "baseAttackDamage must be a positive number"
    end
    
    if config.baseAttackDamage > 100 then
        return "baseAttackDamage cannot exceed 100"
    end
    
    return true
end

return playerConfig
