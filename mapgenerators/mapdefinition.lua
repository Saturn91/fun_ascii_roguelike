local MapDefinition = {}

MapDefinition.__index = MapDefinition

function MapDefinition:new(parameters, options)
    local valid = MapDefinition.validate(parameters)
    if type(valid) == "string" then error(valid) end

    options = options or {}
    local instance = setmetatable(parameters, self)
    instance.options = {}
    instance.options.rooms = options.rooms
    instance.tileDefinitions = options.tileDefinitions or {Char:new("."), Char:new("█")}
    instance.tileIds = options.tileIds or {"floor", "wall"}
    instance.tileMap = options.tileMap or AsciiRoomGeneratorUtil.generateRoom(parameters.width, parameters.height)

    local tileMapValidation = MapDefinition.validateTileMap(instance)
    if type(tileMapValidation) == "string" then error(tileMapValidation) end

    return instance
end

function MapDefinition.validate(parameters)
    if not parameters.width or not parameters.height then
        return "MapDefinition requires width and height parameters."
    end

    if not parameters.walkable then 
        return "MapDefinition requires a walkable map parameter."
    end

    if not #parameters.walkable == parameters.height or not #parameters.walkable[1] == parameters.width then
        return "Walkable map dimensions do not match specified width and height."
    end

    return true
end

function MapDefinition.validateTileMap(mapDefinition)
    if not mapDefinition.tileMap or #mapDefinition.tileMap ~= mapDefinition.height then
        print("yop")
        print(json.stringify({ map = mapDefinition.tileMap}))
        return "Tile map is missing or does not match the height of the map definition."
    end

    for y = 1, #mapDefinition.tileMap do
        if #mapDefinition.tileMap[y] ~= mapDefinition.width then
            return "Tile map row " .. y .. " does not match the width of the map definition."
        end
    end

    local usedChars = {}
    for y = 1, #mapDefinition.tileMap do
        for x = 1, #mapDefinition.tileMap[y] do
            local charID = mapDefinition.tileMap[y][x]
            if not charID or type(charID) ~= "number" then
                return "Tile map contains invalid character at (" .. x .. ", " .. y .. "). <" .. tostring(charID) .. "> - can only contain numbers."
            end
            if not usedChars[charID] then
                usedChars[charID] = true
            end
        end
    end

    for index in pairs(usedChars) do
        if not mapDefinition.tileDefinitions[index] then
            return "Tile map uses character '" .. index .. "' that is not defined in tileDefinitions."
        end

        if not mapDefinition.tileDefinitions[index].glyph or not mapDefinition.tileDefinitions[index].color then
            return "Tile definition for character '" .. index .. "' is missing glyph or color."
        end
    end

    if #mapDefinition.tileDefinitions ~= #mapDefinition.tileIds then
        return "tileDefinitions and tileIds must have the same length"
    end

    return true
end

return MapDefinition