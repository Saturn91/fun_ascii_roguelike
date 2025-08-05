require("mainImports")

GAMESTATE = {}

function love.load()
    love.window.setMode(800, 600, {resizable = true})

    initializeEngine()

    -- test grid
    GAMESTATE.engine:getLayerById("main"):drawBorder("█", {0.8, 0.8, 0.8})
    local text = "Welcome to the ASCII Roguelike!"
    for i = 1, #text + 2 do
        GAMESTATE.engine:getLayerById("main"):setCell(10 + i - 2, 10, "█", {1, 0, 0}, {0, 0, 0})
    end
    GAMESTATE.engine:getLayerById("main"):setCell(10, 10, "█", {1, 0, 0}, {0, 0, 0})
    GAMESTATE.engine:getLayerById("layer2"):writeText(10, 10, text, {1, 1, 1})
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