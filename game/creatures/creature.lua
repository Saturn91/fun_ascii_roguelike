local Creature = {}
local HealthManager = require("game.creatures.HealthManager")
local Colors = require("Colors")

-- Import InventoryController from global (defined in __index.lua)
-- This avoids circular dependency issues

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

    instance.healthManager = HealthManager.new(config.health, instance)

    return instance
end

-- Move creature to new position if valid
function Creature:moveTo(newX, newY, gameGrid, gridWidth, gridHeight)
    -- Check bounds
    if newX < 1 or newX > gridWidth or newY < 1 or newY > gridHeight then
        return false
    end
    
    local targetCell = gameGrid[newY][newX]
    -- Basic walkability check - can be overridden by subclasses for specific logic
    if targetCell and targetCell.walkable then
        -- Clear old position (restore the floor)
        gameGrid[self.y][self.x] = {char = ".", color = {0.5, 0.5, 0.5}, walkable = true}
        
        -- Update creature position
        self.x = newX
        self.y = newY
        
        -- Place creature at new position
        self:placeOnGrid(gameGrid)
        
        return true
    end
    
    return false
end

-- Place creature on the game grid at their current position
function Creature:placeOnGrid(gameGrid)
    gameGrid[self.y][self.x] = {
        char = self.char,
        color = Colors.get(self.color),
        walkable = self.walkable
    }
end

return Creature