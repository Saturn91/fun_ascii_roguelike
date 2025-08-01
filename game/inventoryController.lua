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
function InventoryController:equip(slot)
    -- Get item from backpack slot
    local item = self.backpack[slot]
    if not item then
        return false -- No item in slot
    end
    
    local targetSlot = nil
    if item.type == Item.TYPE.weapon then targetSlot = "r" end

    if targetSlot == nil then Log.error("not able to equip: " .. item.type) end

    if self.equipment[targetSlot] then
        self:unequip(targetSlot)
    end
    
    -- Move item from backpack to equipment
    self.equipment[targetSlot] = item
    self.backpack[slot] = nil
    
    return true
end

function InventoryController:unequip(equipmentType)
    -- Get equipped item
    local item = self.equipment[equipmentType]
    if not item then
        return false -- No item equipped
    end
    
    -- Find first empty backpack slot
    local emptySlot = self:getEmptySlot()
    if not emptySlot then
        return false -- Backpack is full
    end
    
    -- Move item from equipment to backpack
    self.backpack[emptySlot] = item
    self.equipment[equipmentType] = nil
    
    return true
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
    local item = self.backpack[slot]
    if item then
        self.backpack[slot] = nil
        return item
    end
    return nil
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
    local item = self:removeItem(slot)
    if item then
        -- For now, just remove the item (later could add to world)
        return item
    end
    return nil
end

-- Utility Methods
function InventoryController:isEmpty(slot)
    --TODO: Check if specified backpack slot is empty
end

function InventoryController:isFull()
    --TODO: Check if all backpack slots are occupied
end

function InventoryController:getEmptySlot()
    for i = 1, 10 do
        if self.backpack[i] == nil then
            return i
        end
    end
    return nil -- No empty slots
end

function InventoryController:getAllItems()
    return {
        equipment = self.equipment,
        backpack = self.backpack
    }
end

return InventoryController
