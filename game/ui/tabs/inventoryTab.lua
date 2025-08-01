-- Inventory Tab for Tab System
-- Displays weapons and items
local InventoryTab = {}

-- Track selected item for detail display
local selectedSlot = nil
local selectedType = nil  -- "equipment" or "backpack"

-- Draw Inventory tab content
function InventoryTab.draw(gameGrid, area, player)
    -- Build inventory display with item characters
    local lines = {
        "INVENTORY",
        "",
        "Equipment:",
        string.format("[r] right hand: %s", InventoryTab.getItemDisplay("equipment", "r", player)),
        string.format("[l] left hand: %s", InventoryTab.getItemDisplay("equipment", "l", player)), 
        string.format("[h] head: %s", InventoryTab.getItemDisplay("equipment", "h", player)),
        string.format("[b] body: %s", InventoryTab.getItemDisplay("equipment", "b", player)),
        string.format("[f] legs: %s", InventoryTab.getItemDisplay("equipment", "f", player)),
        "",
        "Backpack:",
        string.format("[1] %s", InventoryTab.getItemDisplay("backpack", 1, player)),
        string.format("[2] %s", InventoryTab.getItemDisplay("backpack", 2, player)),
        string.format("[3] %s", InventoryTab.getItemDisplay("backpack", 3, player)),
        string.format("[4] %s", InventoryTab.getItemDisplay("backpack", 4, player)),
        string.format("[5] %s", InventoryTab.getItemDisplay("backpack", 5, player)),
        string.format("[6] %s", InventoryTab.getItemDisplay("backpack", 6, player)),
        string.format("[7] %s", InventoryTab.getItemDisplay("backpack", 7, player)),
        string.format("[8] %s", InventoryTab.getItemDisplay("backpack", 8, player)),
        string.format("[9] %s", InventoryTab.getItemDisplay("backpack", 9, player)),
        string.format("[0] %s", InventoryTab.getItemDisplay("backpack", 10, player))
    }
    
    -- Add item details if something is selected
    if selectedSlot and selectedType then
        local item = InventoryTab.getSelectedItem(player)
        if item then
            table.insert(lines, "")
            table.insert(lines, "SELECTED ITEM:")
            table.insert(lines, string.format("Char: %s", item.char))
            table.insert(lines, string.format("Name: %s", item.name))
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
function InventoryTab.getItemChar(inventoryType, slot, player)
    if inventoryType == "equipment" then
        local item = player.inventory.equipment[slot]
        return item and item.char or "-"
    elseif inventoryType == "backpack" then
        local index = slot == 0 and 10 or slot
        local item = player.inventory.backpack[index]
        return item and item.char or "-"
    end
    return "-"
end

-- Get item display string (character + name or just - if empty)
function InventoryTab.getItemDisplay(inventoryType, slot, player)
    if inventoryType == "equipment" then
        local item = player.inventory.equipment[slot]
        return item and string.format("%s %s", item.char, item.name) or "-"
    elseif inventoryType == "backpack" then
        local index = slot == 0 and 10 or slot
        local item = player.inventory.backpack[index]
        return item and string.format("%s %s", item.char, item.name) or "-"
    end
    return "-"
end

-- Get currently selected item
function InventoryTab.getSelectedItem(player)
    if not selectedSlot or not selectedType then
        return nil
    end
    
    if selectedType == "equipment" then
        return player.inventory.equipment[selectedSlot]
    elseif selectedType == "backpack" then
        local index = selectedSlot == 0 and 10 or selectedSlot
        return player.inventory.backpack[index]
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
                        -- Check if this is the currently selected slot
                        local isSelected = false
                        if selectedSlot and selectedType then
                            if selectedType == "equipment" then
                                isSelected = line:match("^%[" .. selectedSlot .. "%]")
                            elseif selectedType == "backpack" then
                                local keyToMatch = (selectedSlot == 10) and "0" or tostring(selectedSlot)
                                isSelected = line:match("^%[" .. keyToMatch .. "%]")
                            end
                        end
                        
                        if isSelected then
                            lineColor = {1, 1, 0}  -- Bright yellow for selected slot
                        else
                            lineColor = {0.9, 0.9, 1}  -- Light blue for regular slot lines
                        end
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
            InventoryTab.equipItem(player)
            return true
        elseif key == "d" then
            InventoryTab.dropItem(player)
            return true
        elseif key == "u" then
            InventoryTab.useItem(player)
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
function InventoryTab.equipItem(player)
    local item = InventoryTab.getSelectedItem(player)
    if item then
        if Log then
            Log.log(string.format("[info]Equipping %s[/info]", item.name))
        end
        -- TODO: Implement equip logic
    end
end

function InventoryTab.dropItem(player)
    local item = InventoryTab.getSelectedItem(player)
    if item then
        if Log then
            Log.log(string.format("[info]Dropping %s[/info]", item.name))
        end
        -- TODO: Implement drop logic
    end
end

function InventoryTab.useItem(player)
    local item = InventoryTab.getSelectedItem(player)
    if item then
        if Log then
            Log.log(string.format("[info]Using %s[/info]", item.name))
        end
        -- TODO: Implement use logic
    end
end

return InventoryTab
