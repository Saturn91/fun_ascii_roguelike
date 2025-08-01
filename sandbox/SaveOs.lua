SaveOs = {}

local _os = nil

local whiteListedCmds = {
    "explorer",
    "xdg-open",
    "open"
}

function SaveOs.setup()
    _os = CloneUtil.clone(_G["os"])
    _G.os = nil
    os = {
        execute = function() Log.warn("os.execute can not be used in mods...") end,
        copy = function() Log.warn("os.copy can not be used in mods...") end
    }
end

function SaveOs.cleanPath(path)
    return string.gsub(path, "/", "\\")
end

function SaveOs.getOSSpecificLovePath()
    local saveDirectory = love.filesystem.getSaveDirectory()

    if love.system.getOS() == "Windows" then
        saveDirectory = string.gsub(saveDirectory, "/", "\\")
    elseif love.system.getOS() == "OS X" then
        saveDirectory = string.gsub(saveDirectory, " ", "\\ ")
    end

    return saveDirectory
end

function SaveOs.execute(command, parameter, overrideOS)
    local os = overrideOS or _os

    -- List of whitelisted commands with their allowed parameter patterns
    local whitelist = {
        explorer = "^[A-Za-z0-9_\\/:. -]*$",
        ["xdg-open"] = "^[A-Za-z0-9_\\/:. -]*$",
        open = "^[A-Za-z0-9_\\/:. -]*$"
    }

    if not ArrayUtil.hasValue(whiteListedCmds, command) then
        Log.log("Command not whitelisted: " .. command)
        return false
    end

    if command and parameter and whitelist[command] and parameter:match(whitelist[command]) then
        local saveDirectory = SaveOs.getOSSpecificLovePath()

        if string.sub(parameter, 1, #saveDirectory) ~= saveDirectory then
            Log.log("Invalid parameter for '" .. command .. "' parameter: " .. parameter)
            return false
        end

        os.execute(command .. " " .. parameter)
        return true
    else
        Log.log("Command or parameter not valid: " .. command .. " " .. parameter)
        return false
    end
end

function SaveOs.copy(source, destination, overrideOS)
    local os = overrideOS or _os

    --if destination starts with the love save directory, then it is allowed
    local saveDirectory = love.filesystem.getSaveDirectory()

    if string.sub(destination, 1, #saveDirectory) ~= saveDirectory then
        Log.log("Invalid destination: " .. destination .. " -> " .. saveDirectory)
        return false
    end

    local cmd

    if love.system.getOS() == "Windows" then
        -- Use powershell on Windows, with * to copy all contents of the source directory
        -- delete destination and all files within if it exists
        os.execute('rmdir /s /q "' .. destination .. '"')

        cmd = 'powershell -Command "' ..
            'if (-not (Test-Path -Path \'' ..
            destination .. '\')) { New-Item -ItemType Directory -Path \'' .. destination .. '\' } ; ' ..
            'Get-ChildItem -Path \'' .. source .. '\' -Recurse | ForEach-Object { ' ..
            '$destinationPath = Join-Path -Path \'' ..
            destination .. '\' -ChildPath $_.FullName.Substring(\'' .. source .. '\'.Length + 1); ' ..
            'if ($_.PSIsContainer) { ' ..
            'if (-not (Test-Path -Path $destinationPath)) { New-Item -ItemType Directory -Path $destinationPath } ' ..
            '} else { ' ..
            'Copy-Item -Path $_.FullName -Destination $destinationPath -Force ' ..
            '} ' ..
            '}"'
    else
        -- Use cp on Linux and macOS, with / to copy the contents of the source directory
        -- delete destination and all files within if it exists
        os.execute('rm -rf "' .. destination .. '"')
        cmd = 'rsync -av "' .. source .. '/" "' .. destination .. '"'
        -- The dot-slash (/. or "./") ensures all contents including hidden files are copied.
    end

    os.execute(cmd)

    return true
end

function SaveOs.date(param1, param2, param3)
    local os = _os
    return os.date(param1, param2, param3)
end

function SaveOs.rename(old, new, overrideOS)
    --if both paths are with the lovedirectory/mods then it is allowed
    local saveDirectory = love.filesystem.getSaveDirectory()

    if saveDirectory == old then
        Log.log("can not rename systemfolder folder")
        return false
    end

    if string.sub(old, 1, #saveDirectory) ~= saveDirectory or string.sub(new, 1, #saveDirectory) ~= saveDirectory then
        Log.log("Invalid renaming: " .. old .. " -> " .. new)
        return false
    end

    local os = overrideOS or _os
    os.rename(old, new)

    return true
end
