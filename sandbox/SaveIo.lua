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

local whiteListedUrls = {
    NEWS = "https://raw.githubusercontent.com/Saturn91/ArkovsTowerNewsRepo/master/News",
    ROADMAP = "https://raw.githubusercontent.com/Saturn91/ArkovsTowerNewsRepo/master/Roadmap",
    FLAGS = "https://raw.githubusercontent.com/Saturn91/ArkovsTowerNewsRepo/master/flags",
    END_GAME_MESSAGE =
    "https://raw.githubusercontent.com/Saturn91/ArkovsTowerNewsRepo/master/game-finished-message/message",
}

function SaveIo.fetchLocalizedText(urlId, options)
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
        response = SaveIo.fetch(urlId, options)
    end

    if not response then
        options.loc = nil

        --try to get default version
        response = SaveIo.fetch(urlId, options)
    end

    if response then
        if response == "" then
            Log.log(urlId .. " file is empty...")
            return
        end

        result = response
    end

    return result
end

function SaveIo.fetch(urlId, options)
    local options = options or {}

    if whiteListedUrls[urlId] == nil then return nil end

    local url = whiteListedUrls[urlId]

    if options.loc == "en" then
        url = url .. (options.extension and options.extension or "")
    elseif options.loc ~= nil then
        url = url .. "-" .. options.loc .. (options.extension and options.extension or "")
    else
        url = url .. (options.extension and options.extension or "")
    end

    if options.test then
        return url
    end

    local command = "curl -s -H 'Pragma: no-cache' " .. url
    local handle = _io.popen(command)
    local content = handle:read("*a")
    handle:close()

    if not string.match(content, "^[45]%d%d") then
        return content
    end

    Log.warn("not able to fetch! " .. url .. " error: " .. content)
    return nil
end
