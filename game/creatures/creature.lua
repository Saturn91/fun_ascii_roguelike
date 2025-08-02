local Creature = {}

Creature.__index = Creature

function Creature.new(config)
    local instance = setmetatable({
        x = config.x or 0,
        y = config.y or 0,
        char = config.char,
        color = config.color,
        health = config.health,
        maxHealth = config.health,
        walkable = config.walkable or false,
        baseAttackDamage = config.baseAttackDamage,
        inventory = InventoryController.new()
    }, Creature)
    return instance
end

return Creature