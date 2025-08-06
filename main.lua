require("mainImports")

GAMESTATE = {}

function love.load()
    love.window.setMode(800, 600, {resizable = true})

    initializeEngine()

    local defaultMap = DefaultMapDefinition.createSimpleRoom(146, 54)
    local mapLayer, populateLayer = MapAdapter.createLayerFromMapDefinition(defaultMap, "mapLayer", 0, 0)
    GAMESTATE.engine:addLayer(mapLayer)
    populateLayer(GAMESTATE.engine)

    GAMESTATE.engine:getLayerById("layer2"):writeText(40, 10, "Welcome to the ASCII Roguelike!", {1, 1, 1})
end

function love.draw()
    love.graphics.clear(0, 0, 0)
    GAMESTATE.engine:draw()
end

function love.resize(w, h)
    GAMESTATE.engine:resize()
end

function initializeEngine()
    GAMESTATE.engine = AsciiEngine:new({
        gridCols = 146,
        gridRows = 54,
        font = Fonts["ibm-mono"]
    })
    
    GAMESTATE.engine:addLayer(AsciiGrid:new("main"))
    GAMESTATE.engine:addLayer(AsciiGrid:new("layer2")) -- used for popups and overlays
    GAMESTATE.engine:calculateScaling()
end