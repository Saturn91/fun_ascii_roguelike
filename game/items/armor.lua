local Armor = {}

Armor.__index = Armor
setmetatable(Armor, {__index = Item})

-- Constructor for creating a new armor
function Armor.new(config)
    if not config then error("Armor config is required") end
    local armor = setmetatable(Item.new(config), Armor)

    -- Add armor-specific properties here in the future
    -- armor.defense = config.defense
    -- armor.slot = config.slot (helmet, chest, legs, etc.)
    -- armor.durability = config.durability
    
    return armor
end

function Armor.validate(config)
    return true
end

return Armor
