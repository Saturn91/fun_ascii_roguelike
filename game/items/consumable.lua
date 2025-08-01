local Consumable = {}

Consumable.__index = Consumable
setmetatable(Consumable, {__index = Item})

-- Constructor for creating a new consumable
function Consumable.new(config)
    if not config then error("Consumable config is required") end
    local consumable = setmetatable(Item.new(config), Consumable)

    -- Add consumable-specific properties here in the future
    -- consumable.effect = config.effect
    -- consumable.duration = config.duration
    -- consumable.stackSize = config.stackSize
    
    return consumable
end

function Consumable.validate(config)
    return true
end

return Consumable
