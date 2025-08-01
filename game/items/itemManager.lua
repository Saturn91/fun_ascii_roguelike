Item = require("game.items.item")

local ItemManager = {}

local itemDefinitions = nil

function ItemManager.init()
    itemDefinitions = {}

    for key, weapon in pairs(ConfigManager.WEAPONS) do
        itemDefinitions[key] = Weapon.new(weapon)
    end
end

function ItemManager.new(key)
    if itemDefinitions[key] == nil then Log.error("item: " .. key .. " is not defined") end
    return CloneUtil.clone(itemDefinitions[key])
end

return ItemManager