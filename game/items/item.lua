Weapon = require("game.items.weapon")
Consumable = require("game.items.consumable")
Armor = require("game.items.armor")

local Item = {}
Item.__index = Item

Item.TYPE = {
    weapon = "weapon",
    consumable = "consumable",
    armor = "armor"
}

Item.configs = {
    weapon = Weapon,
    consumable = Consumable,
    armor = Armor
}

-- Constructor for creating a new item
function Item.new(config)
    if not config then error("Item config is required") end
    
    local item = setmetatable({
        id = config.id,
        name = config.name,
        char = config.char,
        color = config.color,
    }, Item)
    
    -- Optional properties
    item.type = config.type or "item"  -- Default type
    item.description = config.description
    
    return item
end

-- Validation function for item configuration
function Item.validate(config)
    if not config then
        return "Config is nil"
    end
    
    if type(config) ~= "table" then
        return "Config must be a table"
    end
    
    -- Validate id
    if not config.id or type(config.id) ~= "string" or config.id == "" then
        return "Item must have a valid id (non-empty string)"
    end
    
    -- Validate name
    if not config.name or type(config.name) ~= "string" or config.name == "" then
        return "Item must have a valid name (non-empty string)"
    end
    
    -- Validate char
    if not config.char or type(config.char) ~= "string" or config.char == "" then
        return "Item must have a valid char (non-empty string)"
    end
    
    -- Validate color
    if not config.color or type(config.color) ~= "string" or config.color == "" then
        return "Item must have a valid color (non-empty string)"
    end
    
    -- Validate optional type
    if config.type == nil or type(config.type) ~= "string" or Item.TYPE[config.type] == nil then
        return "Item type must be a valid type: " .. table.concat(Item.TYPE, ", ")
    end
    
    return Item.configs[config.type].validate(config)
end

function Item:getUIInfo()
    return {
        "Name: " .. self.name,
    }
end

return Item
