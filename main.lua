require("mainImports")

GAMESTATE = {}

function love.load()
    love.window.setMode(800, 600, {resizable = true, fullscreen = true})

    initializeEngine()

    GAMESTATE.engine:getLayerById("layer2"):writeText(40, 10, "Welcome to the ASCII Roguelike!", {0, 1, 0})
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
    end
end

function regenerateMap()
    local gridCols, gridRows = GAMESTATE.engine:getGridSize()
    local generatedMap = RoomsAndCorridors.generate(gridCols, gridRows)
    GAMESTATE.mapAdapter:updateMap(generatedMap, GAMESTATE.engine)
end

function initializeEngine()
    GAMESTATE.engine = AsciiEngine:new({
        gridCols = 120,
        gridRows = 66,
        font = Fonts["ibm-mono"]
    })
    
    local gridCols, gridRows = GAMESTATE.engine:getGridSize()
    local generatedMap = RoomsAndCorridors.generate(gridCols, gridRows)
    GAMESTATE.mapAdapter = MapAdapter.new(generatedMap, "main", 0, 0)
    GAMESTATE.engine:addLayer(GAMESTATE.mapAdapter.layer)
    GAMESTATE.mapAdapter:populate(GAMESTATE.engine)

    GAMESTATE.engine:addLayer(AsciiGrid:new("layer2")) -- used for popups and overlays
    GAMESTATE.engine:calculateScaling()
end