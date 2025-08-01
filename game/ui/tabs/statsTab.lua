-- Stats Tab for Tab System
-- Displays game statistics and progress
local StatsTab = {}

-- Draw Stats tab content
function StatsTab.draw(gameGrid, area, player)
    local lines = {
        "STATISTICS",
        "",
        string.format("Enemies: %d", player.enemiesKilled or 0),
        string.format("Rooms: %d", player.roomsVisited or 1),
        string.format("Steps: %d", player.stepsTaken or 0),
        "",
        "Time: 00:00"  -- TODO: Add game time tracking
    }
    
    StatsTab.drawLines(gameGrid, area, lines, {1, 0.8, 0.8})
end

-- Helper function to draw lines of text
function StatsTab.drawLines(gameGrid, area, lines, color)
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

return StatsTab
