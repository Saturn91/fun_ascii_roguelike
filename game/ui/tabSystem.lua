-- Tab System for UI
-- Handles tabbed interface in the info area
local TabSystem = {}

-- Import tab modules
local PlayerTab = require("game.ui.tabs.playerTab")
local InventoryTab = require("game.ui.tabs.inventoryTab")
local StatsTab = require("game.ui.tabs.statsTab")

-- Tab definitions
local TABS = {
    {id = "player", name = "Player", key = "p", number = "1", module = PlayerTab},
    {id = "inventory", name = "Inventory", key = "i", number = "2", module = InventoryTab},
    {id = "stats", name = "Stats", key = "s", number = "3", module = StatsTab}
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
    
    -- Use the tab's module to draw content
    if tab.module then
        tab.module.draw(gameGrid, area, player)
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
