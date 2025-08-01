-- InventoryController Class
-- Handles inventory logic and actions for players, enemies, NPCs, etc.
local InventoryController = {}
InventoryController.__index = InventoryController

-- Constructor for creating a new inventory
function InventoryController.new()
    local inventory = setmetatable({}, InventoryController)
    
    -- Equipment slots (r, l, h, b, f)
    inventory.equipment = {
        r = nil, -- right hand
        l = nil, -- left hand  
        h = nil, -- head
        b = nil, -- body
        f = nil  -- feet
    }
    
    -- Backpack slots (1-10, mapped as 1-9, 0)
    inventory.backpack = {}
    for i = 1, 10 do
        inventory.backpack[i] = nil
    end
    
    return inventory
end

-- Equipment Management
function InventoryController:equip(slot, equipmentType)
    --TODO: Move item from backpack slot to equipment slot
end

function InventoryController:unequip(equipmentType)
    --TODO: Move item from equipment slot to first available backpack slot
end

function InventoryController:getEquipped(equipmentType)
    --TODO: Return item equipped in specified equipment slot
end

function InventoryController:canEquip(item, equipmentType)
    --TODO: Check if item type matches equipment slot and slot is valid
end

-- Item Management
function InventoryController:addItem(item)
    local _item = item
    if type(item) == "string" then _item = itemManager.new(item) end

    for i = 1, 10 do
        if self.backpack[i] == nil then
            self.backpack[i] = _item
            return i
        end
    end

    return false
end

function InventoryController:removeItem(slot)
    --TODO: Remove and return item from specified backpack slot
end

function InventoryController:getItem(slot)
    --TODO: Return item from specified backpack slot (without removing)
end

function InventoryController:moveItem(fromSlot, toSlot)
    --TODO: Move item from one backpack slot to another
end

function InventoryController:use(slot)
    --TODO: Use item in specified slot (consumables, etc.)
end

function InventoryController:drop(slot)
    --TODO: Drop item from inventory (remove without adding to world yet)
end

-- Utility Methods
function InventoryController:isEmpty(slot)
    --TODO: Check if specified backpack slot is empty
end

function InventoryController:isFull()
    --TODO: Check if all backpack slots are occupied
end

function InventoryController:getEmptySlot()
    --TODO: Return first empty backpack slot number, or nil if full
end

function InventoryController:getAllItems()
    return {
        equipment = self.equipment,
        backpack = self.backpack
    }
end

return InventoryController
