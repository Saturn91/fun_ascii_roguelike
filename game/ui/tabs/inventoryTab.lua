-- Inventory Tab for Tab System
-- Displays weapons and items
local InventoryTab = {}

-- Draw Inventory tab content
function InventoryTab.draw(gameGrid, area, player)
    local lines = {
        "INVENTORY",
        "",
        "Weapons:",
        "  None equipped",
        "",
        "Items:",
        "  Empty",
        "",
        "Controls:",
        "  1-9,0 - Select slots 1-10"
    }
    
    InventoryTab.drawLines(gameGrid, area, lines, {0.8, 1, 0.8})
end

-- Helper function to draw lines of text
function InventoryTab.drawLines(gameGrid, area, lines, color)
    for i, line in ipairs(lines) do
        local y = area.y + i - 1
        if y <= area.y + area.height - 1 then
            for j = 1, math.min(#line, area.width) do
                local x = area.x + j - 1
                if y <= #gameGrid and x <= #gameGrid[y] then
                    gameGrid[y][x] = {
                        char = line:sub(j, j),
                        color = color,
                        walkable = false
                    }
                end
            end
        end
    end
end

function InventoryTab.updateOnKeypressed(key, player, gameGrid)
    -- Inventory-specific controls: 0-9 for inventory slots
    local inventoryKeys = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"}
    
    -- Check if the pressed key is one of our inventory keys
    for index, inventoryKey in ipairs(inventoryKeys) do
        if key == inventoryKey then
            -- Handle inventory slot selection
            InventoryTab.selectInventorySlot(index, key, player)
            return true  -- Key was handled
        end
    end
    
    return false  -- Key not handled by inventory tab
end

-- Handle inventory slot selection
function InventoryTab.selectInventorySlot(slotNumber, key, player)
    if Log then
        Log.log(string.format("[info]Selected inventory slot %d (key: %s)[/info]", slotNumber, key))
    end
    
    -- TODO: Implement inventory slot selection logic
    -- This is where you would:
    -- 1. Access the player's inventory
    -- 2. Select/equip the item in slot slotNumber
    -- 3. Update player stats accordingly
end

return InventoryTab
