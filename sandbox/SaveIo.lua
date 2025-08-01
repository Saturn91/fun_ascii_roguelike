SaveIo = {}

local _io = nil

function SaveIo.setup()
    _io = CloneUtil.clone(_G["io"])
    _G.oi = nil
    io = {
        popen = function() Log.warn("oi.popen can not be used in mods...") end,
        open = function() Log.warn("oi.open can not be used in mods...") end,
    }
end

function SaveIo.open(file)
    return _io.open(file, "rb")
end

function SaveIo.lines(file)
    return _io.lines(file)
end

function SaveIo.fetchLocalizedText(url, options)
    local currentLocale = Local.getCurrentLocale()

    result = nil

    local response = nil

    options = options or {}
    options.loc = currentLocale

    if options.extension == nil then
        options.extension = ".txt"
    end

    if currentLocale ~= "en" then
        --try to get localized version
        response = SaveIo.fetch(url, options)
    end

    if not response then
        options.loc = nil

        --try to get default version
        response = SaveIo.fetch(url, options)
    end

    if response then
        if response == "" then
            Log.log(url .. " file is empty...")
            return
        end

        result = response
    end

    return result
end

function SaveIo.fetch(url, options)
    local options = options or {}

    -- Build the final URL with localization and extension options
    local finalUrl = url

    if options.loc == "en" then
        finalUrl = finalUrl .. (options.extension and options.extension or "")
    elseif options.loc ~= nil then
        finalUrl = finalUrl .. "-" .. options.loc .. (options.extension and options.extension or "")
    else
        finalUrl = finalUrl .. (options.extension and options.extension or "")
    end

    local command = "curl -s -H 'Pragma: no-cache' " .. finalUrl
    local handle = _io.popen(command)
    local content = handle:read("*a")
    handle:close()

    if not string.match(content, "^[45]%d%d") then
        return content
    end

    Log.warn("not able to fetch! " .. finalUrl .. " error: " .. content)
    return nil
end
