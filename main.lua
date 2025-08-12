require("mainImports")

GAMESTATE = {}

local currentMapType = ""

function love.load()
    love.window.setMode(800, 600, {resizable = true})

    initializeEngine()

    GAMESTATE.engine:getLayerById("creatures"):setCell(1, 1, "@")
    GAMESTATE.engine:getLayerById("ui"):writeText(40, 1, "Map type: " .. currentMapType, {0, 1, 0})
end

function love.draw()
    love.graphics.clear(0, 0.0, 0)
    GAMESTATE.engine:draw()
    CRT.apply()
end

function love.resize(w, h)
    GAMESTATE.engine:resize()
end

function love.keyreleased(key)
    if key == "space" then
        regenerateMap()
        GAMESTATE.engine:getLayerById("ui"):clear()
        GAMESTATE.engine:getLayerById("ui"):writeText(40, 1, "Map type: " .. currentMapType, {0, 1, 0})
    end
end

function regenerateMap()
    local gridCols, gridRows = GAMESTATE.engine:getGridSize()
    
    if love.math.random() < 0.5 then
        local generatedMap = RoomsAndCorridors.generate(gridCols, gridRows)
        GAMESTATE.mapAdapter:updateMap(generatedMap, GAMESTATE.engine)
        currentMapType = "RoomsAndCorridors"
    else
        local generatedMap = CaveSystem.generate(gridCols, gridRows)
        GAMESTATE.mapAdapter:updateMap(generatedMap, GAMESTATE.engine)
        currentMapType = "CaveSystem"
    end
end

function initializeEngine()
    GAMESTATE.engine = AsciiEngine:new({
        gridCols = 120,
        gridRows = 66,
        font = Fonts["ibm-mono"]
    })

    currentMapType = "CaveSystem"
    
    local gridCols, gridRows = GAMESTATE.engine:getGridSize()
    local generatedMap = CaveSystem.generate(gridCols, gridRows)
    GAMESTATE.mapAdapter = MapAdapter.new(generatedMap, "map", 0, 0)
    GAMESTATE.engine:addLayer(GAMESTATE.mapAdapter.layer)
    GAMESTATE.mapAdapter:populate(GAMESTATE.engine)

    GAMESTATE.engine:addLayer(AsciiGrid:new("creatures")) -- used for the map

    GAMESTATE.engine:addLayer(AsciiGrid:new("ui")) -- used for popups and overlays
    GAMESTATE.engine:calculateScaling()
end