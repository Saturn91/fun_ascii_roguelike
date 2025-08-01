-- Tab System for UI
-- Handles tabbed interface in the info area
local TabSystem = {}

-- Tab definitions
local TABS = {
    {id = "player", name = "Player", key = "p", number = "1"},
    {id = "inventory", name = "Inventory", key = "i", number = "2"},
    {id = "stats", name = "Stats", key = "s", number = "3"}
}

-- Current active tab (default to player)
local currentTab = 1

-- Initialize the tab system
function TabSystem.init()
    currentTab = 1
end

-- Switch to a specific tab by ID
function TabSystem.switchToTab(tabId)
    for i, tab in ipairs(TABS) do
        if tab.id == tabId then
            currentTab = i
            if Log then
                Log.log(string.format("[info]Switched to %s tab[/info]", tab.name))
            end
            return true
        end
    end
    return false
end

-- Switch tab by key input
function TabSystem.handleInput(key)
    for i, tab in ipairs(TABS) do
        if key == tab.key or key == tab.number then
            currentTab = i
            if Log then
                Log.log(string.format("[info]Switched to %s tab[/info]", tab.name))
            end
            return true
        end
    end
    return false
end

-- Get current tab info
function TabSystem.getCurrentTab()
    return TABS[currentTab]
end

-- Draw the tab system
function TabSystem.draw(gameGrid, area, player)
    -- Draw tab headers
    TabSystem.drawTabHeaders(gameGrid, area)
    
    -- Draw content for current tab
    TabSystem.drawTabContent(gameGrid, area, player)
end

-- Draw tab headers
function TabSystem.drawTabHeaders(gameGrid, area)
    local headerY = area.y - 1
    local startX = area.x
    
    for i, tab in ipairs(TABS) do
        local isActive = (i == currentTab)
        local tabText = string.format("[%s]", tab.name)
        
        -- Draw tab text
        for j = 1, #tabText do
            local x = startX + j - 1
            if headerY <= #gameGrid and x <= #gameGrid[headerY] and x < area.x + area.width then
                local color = isActive and {1, 1, 0} or {0.6, 0.6, 0.6}  -- Yellow for active, gray for inactive
                gameGrid[headerY][x] = {
                    char = tabText:sub(j, j),
                    color = color,
                    walkable = false
                }
            end
        end
        
        startX = startX + #tabText + 1  -- Space between tabs
    end
end

-- Draw content for the current tab
function TabSystem.drawTabContent(gameGrid, area, player)
    local tab = TABS[currentTab]
    
    if tab.id == "player" then
        TabSystem.drawPlayerTab(gameGrid, area, player)
    elseif tab.id == "inventory" then
        TabSystem.drawInventoryTab(gameGrid, area, player)
    elseif tab.id == "stats" then
        TabSystem.drawStatsTab(gameGrid, area, player)
    end
end

-- Draw Player tab content
function TabSystem.drawPlayerTab(gameGrid, area, player)
    local lines = {
        string.format("Player: %s", player.char or "@"),
        string.format("Pos: (%d,%d)", player.x or 0, player.y or 0),
        string.format("HP: %d/%d", player.health or 0, player.maxHealth or 0),
        string.format("Damage: %d", player.baseAttackDamage or 0),
        "",
        "Weapon: None",  -- TODO: Add weapon info when implemented
        "Status: Alive"
    }
    
    TabSystem.drawLines(gameGrid, area, lines, {0.8, 0.8, 1})
end

-- Draw Inventory tab content
function TabSystem.drawInventoryTab(gameGrid, area, player)
    local lines = {
        "INVENTORY",
        "",
        "Weapons:",
        "  None equipped",
        "",
        "Items:",
        "  Empty"
    }
    
    TabSystem.drawLines(gameGrid, area, lines, {0.8, 1, 0.8})
end

-- Draw Stats tab content
function TabSystem.drawStatsTab(gameGrid, area, player)
    local lines = {
        "STATISTICS",
        "",
        string.format("Enemies: %d", player.enemiesKilled or 0),
        string.format("Rooms: %d", player.roomsVisited or 1),
        string.format("Steps: %d", player.stepsTaken or 0),
        "",
        "Time: 00:00"  -- TODO: Add game time tracking
    }
    
    TabSystem.drawLines(gameGrid, area, lines, {1, 0.8, 0.8})
end

-- Helper function to draw lines of text
function TabSystem.drawLines(gameGrid, area, lines, color)
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

-- Get list of available tabs for help/controls
function TabSystem.getTabControls()
    local controls = {}
    for _, tab in ipairs(TABS) do
        table.insert(controls, string.format("%s/%s: %s", tab.number, string.upper(tab.key), tab.name))
    end
    return controls
end

return TabSystem
