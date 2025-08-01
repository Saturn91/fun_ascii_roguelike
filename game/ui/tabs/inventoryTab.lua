-- Inventory Tab for Tab System
-- Displays weapons and items
local InventoryTab = {}

-- Track selected item for detail display
local selectedSlot = nil
local selectedType = nil  -- "equipment" or "backpack"

-- Mock inventory data for demonstration
local mockInventory = {
    equipment = {
        r = nil,  -- right hand
        l = nil,  -- left hand
        h = nil,  -- head
        b = nil,  -- body
        f = nil   -- legs
    },
    backpack = {
        [1] = {char = "S", name = "Iron Sword", damage = "2d6+1", type = "weapon"},
        [2] = {char = "P", name = "Health Potion", effect = "Heal 10 HP", type = "consumable"},
        [3] = nil,
        [4] = nil,
        [5] = nil,
        [6] = nil,
        [7] = nil,
        [8] = nil,
        [9] = nil,
        [10] = nil  -- slot 0 maps to index 10
    }
}

-- Draw Inventory tab content
function InventoryTab.draw(gameGrid, area, player)
    -- Build inventory display with item characters
    local lines = {
        "INVENTORY",
        "",
        "Equipment:",
        string.format("[r] right hand: %s", InventoryTab.getItemChar("equipment", "r")),
        string.format("[l] left hand: %s", InventoryTab.getItemChar("equipment", "l")), 
        string.format("[h] head: %s", InventoryTab.getItemChar("equipment", "h")),
        string.format("[b] body: %s", InventoryTab.getItemChar("equipment", "b")),
        string.format("[f] legs: %s", InventoryTab.getItemChar("equipment", "f")),
        "",
        "Backpack:",
        string.format("[1]%s [2]%s [3]%s [4]%s [5]%s", 
            InventoryTab.getItemChar("backpack", 1),
            InventoryTab.getItemChar("backpack", 2),
            InventoryTab.getItemChar("backpack", 3),
            InventoryTab.getItemChar("backpack", 4),
            InventoryTab.getItemChar("backpack", 5)
        ),
        string.format("[6]%s [7]%s [8]%s [9]%s [0]%s", 
            InventoryTab.getItemChar("backpack", 6),
            InventoryTab.getItemChar("backpack", 7),
            InventoryTab.getItemChar("backpack", 8),
            InventoryTab.getItemChar("backpack", 9),
            InventoryTab.getItemChar("backpack", 10)
        )
    }
    
    -- Add item details if something is selected
    if selectedSlot and selectedType then
        local item = InventoryTab.getSelectedItem()
        if item then
            table.insert(lines, "")
            table.insert(lines, "SELECTED ITEM:")
            table.insert(lines, string.format("Name: %s", item.name))
            if item.damage then
                table.insert(lines, string.format("Damage: %s", item.damage))
            end
            if item.effect then
                table.insert(lines, string.format("Effect: %s", item.effect))
            end
            table.insert(lines, string.format("Type: %s", item.type))
            table.insert(lines, "")
            table.insert(lines, "Actions: [E]quip [D]rop [U]se")
        else
            table.insert(lines, "")
            table.insert(lines, "Empty slot selected")
        end
    else
        table.insert(lines, "")
        table.insert(lines, "Select an item to see details")
        table.insert(lines, "Press slot keys (1-9,0,r,l,h,b,f)")
    end
    
    InventoryTab.drawLines(gameGrid, area, lines, {0.8, 1, 0.8})
end

-- Get item character for display (or - if empty)
function InventoryTab.getItemChar(inventoryType, slot)
    if inventoryType == "equipment" then
        local item = mockInventory.equipment[slot]
        return item and item.char or "-"
    elseif inventoryType == "backpack" then
        local index = slot == 0 and 10 or slot
        local item = mockInventory.backpack[index]
        return item and item.char or "-"
    end
    return "-"
end

-- Get currently selected item
function InventoryTab.getSelectedItem()
    if not selectedSlot or not selectedType then
        return nil
    end
    
    if selectedType == "equipment" then
        return mockInventory.equipment[selectedSlot]
    elseif selectedType == "backpack" then
        local index = selectedSlot == 0 and 10 or selectedSlot
        return mockInventory.backpack[index]
    end
    
    return nil
end

-- Helper function to draw lines of text
function InventoryTab.drawLines(gameGrid, area, lines, color)
    for i, line in ipairs(lines) do
        local y = area.y + i - 1
        if y <= area.y + area.height - 1 and y <= #gameGrid then
            for j = 1, math.min(#line, area.width) do
                local x = area.x + j - 1
                if x <= #gameGrid[y] then
                    -- Use different colors for different sections
                    local lineColor = color
                    if line:match("^Equipment:") or line:match("^Backpack:") then
                        lineColor = {1, 1, 0.6}  -- Yellow for section headers
                    elseif line:match("^SELECTED ITEM:") then
                        lineColor = {1, 0.8, 0.8}  -- Light red for selected item header
                    elseif line:match("^Name:") or line:match("^Damage:") or line:match("^Effect:") or line:match("^Type:") then
                        lineColor = {0.8, 1, 0.9}  -- Light green for item details
                    elseif line:match("^Actions:") then
                        lineColor = {1, 1, 0.8}  -- Light yellow for actions
                    elseif line:match("^Controls:") then
                        lineColor = {0.7, 0.7, 0.7}  -- Gray for controls
                    elseif line:match("^%[") then
                        lineColor = {0.9, 0.9, 1}  -- Light blue for slot lines
                    end
                    
                    gameGrid[y][x] = {
                        char = line:sub(j, j),
                        color = lineColor,
                        walkable = false
                    }
                end
            end
        end
    end
end

function InventoryTab.updateOnKeypressed(key, player, gameGrid)
    -- Equipment slot controls: r, l, h, b, f
    local equipmentKeys = {
        r = "right hand",
        l = "left hand", 
        h = "head",
        b = "body",
        f = "legs"
    }
    
    -- Check if key is for equipment slot
    if equipmentKeys[key] then
        InventoryTab.selectEquipmentSlot(key, equipmentKeys[key], player)
        return true
    end
    
    -- Backpack slot controls: 1-9, 0
    local backpackKeys = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"}
    
    -- Check if the pressed key is for backpack slots
    for index, backpackKey in ipairs(backpackKeys) do
        if key == backpackKey then
            local slotNumber = (backpackKey == "0") and 10 or tonumber(backpackKey)
            InventoryTab.selectBackpackSlot(slotNumber, key, player)
            return true
        end
    end
    
    -- Action keys when item is selected
    if selectedSlot and selectedType then
        if key == "e" then
            InventoryTab.equipItem()
            return true
        elseif key == "d" then
            InventoryTab.dropItem()
            return true
        elseif key == "u" then
            InventoryTab.useItem()
            return true
        end
    end
    
    return false  -- Key not handled by inventory tab
end

-- Handle equipment slot selection
function InventoryTab.selectEquipmentSlot(key, slotName, player)
    selectedSlot = key
    selectedType = "equipment"
    
    if Log then
        Log.log(string.format("[info]Selected equipment slot: %s (key: %s)[/info]", slotName, key))
    end
end

-- Handle backpack slot selection
function InventoryTab.selectBackpackSlot(slotNumber, key, player)
    selectedSlot = slotNumber
    selectedType = "backpack"
    
    if Log then
        Log.log(string.format("[info]Selected backpack slot %d (key: %s)[/info]", slotNumber, key))
    end
end

-- Handle item actions
function InventoryTab.equipItem()
    local item = InventoryTab.getSelectedItem()
    if item then
        if Log then
            Log.log(string.format("[info]Equipping %s[/info]", item.name))
        end
        -- TODO: Implement equip logic
    end
end

function InventoryTab.dropItem()
    local item = InventoryTab.getSelectedItem()
    if item then
        if Log then
            Log.log(string.format("[info]Dropping %s[/info]", item.name))
        end
        -- TODO: Implement drop logic
    end
end

function InventoryTab.useItem()
    local item = InventoryTab.getSelectedItem()
    if item then
        if Log then
            Log.log(string.format("[info]Using %s[/info]", item.name))
        end
        -- TODO: Implement use logic
    end
end

return InventoryTab
