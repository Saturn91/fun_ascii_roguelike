local Creature = {}
local HealthManager = require("game.creatures.HealthManager")

Creature.__index = Creature

function Creature.new(config)
    local instance = setmetatable({
        x = config.x or 0,
        y = config.y or 0,
        char = config.char,
        color = config.color,
        walkable = config.walkable or false,
        baseAttackDamage = config.baseAttackDamage,
        inventory = InventoryController.new(),
    }, Creature)

    instance.healthManager = HealthManager.new(config.health, self)

    return instance
end

return Creature