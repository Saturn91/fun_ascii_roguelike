-- Configuration Manager for ASCII Roguelike
-- Handles loading and saving configuration files to appdata
local ConfigManager = {}

-- Default configurations (fallback values)
local defaultPlayerConfig = require("game.config.player")
local defaultEnemyConfig = require("game.config.enemy")

-- Current loaded configurations
ConfigManager.PLAYER = {}
ConfigManager.ENEMY = {}

-- Configuration file paths
local CONFIG_DIR = "config/"
local PLAYER_CONFIG_FILE = CONFIG_DIR .. "player.csv"
local ENEMY_CONFIG_FILE = CONFIG_DIR .. "enemy.csv"

-- Helper function to convert table to CSV format
local function tableToCSV(data, isArray)
    local lines = {}
    
    if isArray then
        -- Handle enemy-style array config
        table.insert(lines, "type,char,color,health,damage,name,moveChance,aggroRange")
        for enemyType, enemy in pairs(data) do
            local line = string.format("%s,%s,%s,%d,%d,%s,%.2f,%d",
                enemyType,
                enemy.char,
                enemy.color,
                enemy.health,
                enemy.damage,
                enemy.name,
                enemy.moveChance,
                enemy.aggroRange
            )
            table.insert(lines, line)
        end
    else
        -- Handle player-style simple config
        table.insert(lines, "property,value")
        for key, value in pairs(data) do
            table.insert(lines, string.format("%s,%s", key, tostring(value)))
        end
    end
    
    return table.concat(lines, "\n")
end

-- Helper function to parse CSV format to table
local function csvToTable(csvContent, isArray)
    local lines = {}
    for line in csvContent:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    
    if #lines < 2 then
        return nil -- Invalid CSV
    end
    
    local result = {}
    
    if isArray then
        -- Parse enemy config
        for i = 2, #lines do -- Skip header
            local parts = {}
            for part in lines[i]:gmatch("([^,]+)") do
                table.insert(parts, part)
            end
            
            if #parts >= 8 then
                local enemyType = parts[1]
                result[enemyType] = {
                    char = parts[2],
                    color = parts[3],
                    health = tonumber(parts[4]) or 1,
                    damage = tonumber(parts[5]) or 1,
                    name = parts[6],
                    moveChance = tonumber(parts[7]) or 0.3,
                    aggroRange = tonumber(parts[8]) or 3
                }
            end
        end
    else
        -- Parse player config
        for i = 2, #lines do -- Skip header
            local parts = {}
            for part in lines[i]:gmatch("([^,]+)") do
                table.insert(parts, part)
            end
            
            if #parts >= 2 then
                local key = parts[1]
                local value = parts[2]
                
                -- Convert numeric values
                if key == "health" or key == "baseAttackDamage" then
                    result[key] = tonumber(value) or 0
                else
                    result[key] = value
                end
            end
        end
    end
    
    return result
end

-- Load player configuration
local function loadPlayerConfig()
    local info = love.filesystem.getInfo(PLAYER_CONFIG_FILE)
    
    if info then
        -- File exists, load it
        local content = love.filesystem.read(PLAYER_CONFIG_FILE)
        if content then
            local config = csvToTable(content, false)
            if config then
                -- Validate the loaded config
                local validationResult = defaultPlayerConfig.validate(config)
                if validationResult == true then
                    ConfigManager.PLAYER = config
                    return true
                else
                    -- Validation failed, log error and use default
                    Log.log("[error]Player config validation failed for " .. PLAYER_CONFIG_FILE .. ": " .. validationResult .. "[/error]")
                end
            end
        end
    end
    
    -- File doesn't exist, failed to load, or validation failed - use default
    ConfigManager.PLAYER = {}
    for key, value in pairs(defaultPlayerConfig) do
        if key ~= "validate" then -- Skip the validation function
            ConfigManager.PLAYER[key] = value
        end
    end
    
    -- Create the config directory if it doesn't exist
    LocalFileUtil.createPathDirectoryIfNotExists(PLAYER_CONFIG_FILE)
    
    -- Save default config
    local csvContent = tableToCSV(ConfigManager.PLAYER, false)
    LocalFileUtil.writeFile(PLAYER_CONFIG_FILE, csvContent)
    
    return false
end

-- Load enemy configuration
local function loadEnemyConfig()
    local info = love.filesystem.getInfo(ENEMY_CONFIG_FILE)
    
    if info then
        -- File exists, load it
        local content = love.filesystem.read(ENEMY_CONFIG_FILE)
        if content then
            local config = csvToTable(content, true)
            if config then
                -- Validate the loaded config
                local validationResult = defaultEnemyConfig.validate(config)
                if validationResult == true then
                    ConfigManager.ENEMY = config
                    return true
                else
                    -- Validation failed, log error and use default
                    Log.log("[error]Enemy config validation failed for " .. ENEMY_CONFIG_FILE .. ": " .. validationResult .. "[/error]")
                end
            end
        end
    end
    
    -- File doesn't exist, failed to load, or validation failed - use default
    ConfigManager.ENEMY = {}
    for key, value in pairs(defaultEnemyConfig) do
        if key ~= "validate" and key ~= "validateEnemy" then -- Skip the validation functions
            ConfigManager.ENEMY[key] = {}
            for subKey, subValue in pairs(value) do
                ConfigManager.ENEMY[key][subKey] = subValue
            end
        end
    end
    
    -- Create the config directory if it doesn't exist
    LocalFileUtil.createPathDirectoryIfNotExists(ENEMY_CONFIG_FILE)
    
    -- Save default config
    local csvContent = tableToCSV(ConfigManager.ENEMY, true)
    LocalFileUtil.writeFile(ENEMY_CONFIG_FILE, csvContent)
    
    return false
end

-- Initialize/reinitialize configuration loading
function ConfigManager.load()
    local playerLoaded = loadPlayerConfig()
    local enemyLoaded = loadEnemyConfig()
    
    if playerLoaded and enemyLoaded then
        Log.log("[info]Configs read from files[/info]")
    else
        Log.log("[info]Created files[/info]")
    end
end

-- Save current configurations to files
function ConfigManager.save()
    -- Save player config
    local playerCsv = tableToCSV(ConfigManager.PLAYER, false)
    LocalFileUtil.writeFile(PLAYER_CONFIG_FILE, playerCsv)
    
    -- Save enemy config
    local enemyCsv = tableToCSV(ConfigManager.ENEMY, true)
    LocalFileUtil.writeFile(ENEMY_CONFIG_FILE, enemyCsv)
    
    Log.log("[info]Configurations saved to " .. CONFIG_DIR .. "[/info]")
end

-- Get configuration file paths (for debugging)
function ConfigManager.getConfigPaths()
    return {
        player = PLAYER_CONFIG_FILE,
        enemy = ENEMY_CONFIG_FILE
    }
end

return ConfigManager
