-- Configuration Manager for ASCII Roguelike
-- Handles loading and saving configuration files to appdata
local ConfigManager = {}

-- Configuration definitions
local configs = {
    PLAYER = {
        csvName = "player",
        luaName = "game.config.player",
        isArray = false
    },
    ENEMY = {
        csvName = "enemy", 
        luaName = "game.config.enemy",
        isArray = true,
        idField = "id"  -- The field that serves as the key for array configs
    },
    WEAPONS = {
        csvName = "weapons",
        luaName = "game.config.weapons",
        isArray = true,
        idField = "id"  -- The field that serves as the key for array configs
    }
}

-- Default configurations (fallback values)
local defaultConfigs = {}
for configKey, configDef in pairs(configs) do
    defaultConfigs[configKey] = require(configDef.luaName)
end

-- Current loaded configurations
for configKey, _ in pairs(configs) do
    ConfigManager[configKey] = {}
end

-- Configuration file paths
local CONFIG_DIR = "config/"
local function getConfigFilePath(csvName)
    local fileName = csvName
    if not fileName:match("%.csv$") then
        fileName = fileName .. ".csv"
    end
    return CONFIG_DIR .. fileName
end

-- Helper function to convert table to CSV format
local function tableToCSV(data, isArray, idField)
    local lines = {}
    
    if isArray then
        -- Handle array config (multiple objects with same structure)
        local firstKey = next(data)
        if not firstKey then return "" end
        
        local firstItem = data[firstKey]
        
        -- Generate header from the first item's fields, with idField first
        local headers = {}
        table.insert(headers, idField)
        for key, _ in pairs(firstItem) do
            if key ~= idField then
                table.insert(headers, key)
            end
        end
        table.insert(lines, table.concat(headers, ","))
        
        -- Generate data rows
        for id, item in pairs(data) do
            local values = {}
            table.insert(values, tostring(id))  -- ID field first
            for i = 2, #headers do
                local key = headers[i]
                table.insert(values, tostring(item[key] or ""))
            end
            table.insert(lines, table.concat(values, ","))
        end
    else
        -- Handle simple config (single object with fields)
        table.insert(lines, "property,value")
        for key, value in pairs(data) do
            table.insert(lines, string.format("%s,%s", key, tostring(value)))
        end
    end
    
    return table.concat(lines, "\n")
end

-- Helper function to parse CSV format to table
local function csvToTable(csvContent, isArray, idField)
    local lines = {}
    for line in csvContent:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    
    if #lines < 2 then
        return nil -- Invalid CSV
    end
    
    local result = {}
    
    if isArray then
        -- Parse array config (multiple objects)
        local headers = {}
        for header in lines[1]:gmatch("([^,]+)") do
            table.insert(headers, header)
        end
        
        if #headers < 1 then
            return nil
        end
        
        -- Parse data rows
        for i = 2, #lines do
            local parts = {}
            for part in lines[i]:gmatch("([^,]+)") do
                table.insert(parts, part)
            end
            
            if #parts >= #headers then
                local id = parts[1]  -- First column is always the ID
                local item = { id = id }
                
                -- Map remaining columns to their headers
                for j = 2, #headers do
                    local key = headers[j]
                    local value = parts[j]
                    
                    -- Try to convert to number if it looks like a number
                    local numValue = tonumber(value)
                    if numValue then
                        item[key] = numValue
                    else
                        item[key] = value
                    end
                end
                
                result[id] = item
            else
                Log.log("[error]missing field in: " .. json.stringify(parts, true) .. "[/error]")
            end
        end
    else
        -- Parse simple config (single object)
        for i = 2, #lines do
            local parts = {}
            for part in lines[i]:gmatch("([^,]+)") do
                table.insert(parts, part)
            end
            
            if #parts >= 2 then
                local key = parts[1]
                local value = parts[2]
                
                -- Try to convert to number if it looks like a number
                local numValue = tonumber(value)
                if numValue then
                    result[key] = numValue
                else
                    result[key] = value
                end
            end
        end
    end
    
    return result
end

-- Generic function to load any configuration
local function loadConfig(configKey)
    local configDef = configs[configKey]
    local defaultConfig = defaultConfigs[configKey]
    local configFile = getConfigFilePath(configDef.csvName)
    
    local info = love.filesystem.getInfo(configFile)
    local fileExists = info ~= nil
    
    if fileExists then
        -- File exists, load it
        local content = love.filesystem.read(configFile)
        if content then
            local config = csvToTable(content, configDef.isArray, configDef.idField)
            if config then
                -- Validate the loaded config
                local validationResult = defaultConfig.validate(config)
                if validationResult == true then
                    ConfigManager[configKey] = config
                    return true
                else
                    -- Validation failed, log error and use default but DON'T overwrite file
                    Log.log("[error]" .. configKey:lower() .. " config validation failed for " .. configFile .. ": " .. validationResult .. "[/error]")
                    Log.log("[warning]Using default " .. configKey:lower() .. " config. Fix the file to use custom settings.[/warning]")
                end
            else
                -- Failed to parse CSV, use default but DON'T overwrite file
                Log.log("[error]Failed to parse " .. configFile .. " as valid CSV[/error]")
                Log.log("[warning]Using default " .. configKey:lower() .. " config. Fix the file to use custom settings.[/warning]")
            end
        else
            -- Failed to read file content, use default but DON'T overwrite file
            Log.log("[error]Failed to read " .. configFile .. "[/error]")
            Log.log("[warning]Using default " .. configKey:lower() .. " config. Fix the file to use custom settings.[/warning]")
        end
    end
    
    -- File doesn't exist OR validation/parsing failed - use default
    ConfigManager[configKey] = {}
    for key, value in pairs(defaultConfig) do
        if type(value) ~= "function" then -- Skip any functions (like validate)
            if configDef.isArray and type(value) == "table" then
                ConfigManager[configKey][key] = {}
                for subKey, subValue in pairs(value) do
                    if type(subValue) ~= "function" then
                        ConfigManager[configKey][key][subKey] = subValue
                    end
                end
            else
                ConfigManager[configKey][key] = value
            end
        end
    end
    
    -- Only create/save the default config file if it doesn't exist
    if not fileExists then
        -- Create the config directory if it doesn't exist
        LocalFileUtil.createPathDirectoryIfNotExists(configFile)
        
        -- Save default config
        local csvContent = tableToCSV(ConfigManager[configKey], configDef.isArray, configDef.idField)
        LocalFileUtil.writeFile(configFile, csvContent)
    end
    
    return fileExists -- Return true if file existed (even if validation failed), false if created new
end

-- Initialize/reinitialize configuration loading
function ConfigManager.load()
    local allLoaded = true
    local createdFiles = false
    
    for configKey, _ in pairs(configs) do
        local loaded = loadConfig(configKey)
        if loaded then
            -- File existed (regardless of validation success)
            -- allLoaded remains true only if validation succeeded
        else
            -- File didn't exist, created default
            allLoaded = false
            createdFiles = true
        end
    end
    
    if allLoaded then
        Log.log("[info]All configs loaded successfully from files[/info]")
    elseif createdFiles then
        Log.log("[info]Some config files created with defaults[/info]")
    else
        Log.log("[warning]Some configs using defaults due to validation errors[/warning]")
    end
end

-- Save current configurations to files
function ConfigManager.save()
    for configKey, configDef in pairs(configs) do
        local configFile = getConfigFilePath(configDef.csvName)
        local csvContent = tableToCSV(ConfigManager[configKey], configDef.isArray, configDef.idField)
        LocalFileUtil.writeFile(configFile, csvContent)
    end
    
    Log.log("[info]Configurations saved to " .. CONFIG_DIR .. "[/info]")
end

-- Get configuration file paths (for debugging)
function ConfigManager.getConfigPaths()
    local paths = {}
    for configKey, configDef in pairs(configs) do
        paths[configKey:lower()] = getConfigFilePath(configDef.csvName)
    end
    return paths
end

return ConfigManager
