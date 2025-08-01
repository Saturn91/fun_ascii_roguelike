Item = require("game.items.item")

local ItemManager = {}

local itemDefinitions = nil

function ItemManager.init()
    itemDefinitions = {}

    for key, weapon in pairs(ConfigManager.WEAPONS) do
        itemDefinitions[key] = Item.new(weapon)
    end
end

function ItemManager.getItem(key)
    if itemDefinitions[key] == nil then Log.error("item: " .. key .. " is not defined") end
    return itemDefinitions[key]
end

return ItemManager