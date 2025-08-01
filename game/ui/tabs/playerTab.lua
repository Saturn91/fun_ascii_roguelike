-- Player Tab for Tab System
-- Displays player information and stats
local PlayerTab = {}

-- Draw Player tab content
function PlayerTab.draw(gameGrid, area, player)
    local lines = {
        string.format("Player: %s", player.char or "@"),
        string.format("Pos: (%d,%d)", player.x or 0, player.y or 0),
        string.format("HP: %d/%d", player.health or 0, player.maxHealth or 0),
        string.format("Damage: %d", player.baseAttackDamage or 0),
        "",
        "Weapon: None",  -- TODO: Add weapon info when implemented
        "Status: Alive"
    }
    
    PlayerTab.drawLines(gameGrid, area, lines, {0.8, 0.8, 1})
end

-- Helper function to draw lines of text
function PlayerTab.drawLines(gameGrid, area, lines, color)
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

return PlayerTab
