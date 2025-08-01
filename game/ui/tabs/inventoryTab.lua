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
        "  Empty"
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

return InventoryTab
