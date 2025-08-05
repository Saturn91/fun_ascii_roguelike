-- Grid Adapter Module
-- Provides compatibility layer between old AsciiGrid API and new AsciiEngine
local GridAdapter = {}

GridAdapter.__index = GridAdapter

function GridAdapter:new(asciiGrid, engine)
    local instance = setmetatable({}, self)
    instance.grid = asciiGrid
    instance.engine = engine
    instance.gameAreaWidth = 80  -- Default, will be set by UI.init
    instance.gameAreaHeight = 25 -- Default, will be set by UI.init
    return instance
end

-- Legacy compatibility functions that many modules expect
function GridAdapter:setCell(x, y, char, color, walkable)
    if char then
        self.grid:setCell(x, y, char, color)
    end
    -- Store walkable info in a separate table if needed
    if not self.walkableData then
        self.walkableData = {}
    end
    if not self.walkableData[y] then
        self.walkableData[y] = {}
    end
    self.walkableData[y][x] = walkable ~= false
end

function GridAdapter:getCell(x, y)
    local cell = self.grid:getCell(x, y)
    if cell then
        local walkable = true
        if self.walkableData and self.walkableData[y] and self.walkableData[y][x] ~= nil then
            walkable = self.walkableData[y][x]
        end
        return {
            char = cell.glyph,
            color = cell.color,
            walkable = walkable
        }
    end
    return nil
end

function GridAdapter:isInBounds(x, y)
    local cols, rows = self.engine:getGridSize()
    return x >= 1 and x <= cols and y >= 1 and y <= rows
end

function GridAdapter:isWalkable(x, y)
    if self.walkableData and self.walkableData[y] and self.walkableData[y][x] ~= nil then
        return self.walkableData[y][x]
    end
    return true -- Default to walkable
end

function GridAdapter:clear(char, color, walkable)
    self.grid:clear(char, color)
    self.walkableData = {}
end

function GridAdapter:writeText(x, y, text, color, backgroundColor)
    self.grid:writeText(x, y, text, color, backgroundColor)
end

function GridAdapter:fillRect(x1, y1, x2, y2, glyph, color, backgroundColor)
    self.grid:fillRect(x1, y1, x2, y2, glyph, color, backgroundColor)
end

function GridAdapter:drawBorder(glyph, color)
    self.grid:drawBorder(glyph, color)
end

function GridAdapter:getDimensions()
    return self.engine:getGridSize()
end

function GridAdapter:getCharDimensions()
    return self.engine:getCharSize()
end

-- Additional compatibility methods
function GridAdapter:clearArea(startX, startY, endX, endY, char, color, walkable)
    char = char or " "
    color = color or {0, 0, 0}
    walkable = walkable ~= false
    
    for y = startY, endY do
        for x = startX, endX do
            self:setCell(x, y, char, color, walkable)
        end
    end
end

function GridAdapter:fill(char, color, walkable)
    char = char or " "
    color = color or {0, 0, 0}
    walkable = walkable ~= false
    
    local cols, rows = self.engine:getGridSize()
    for y = 1, rows do
        for x = 1, cols do
            self:setCell(x, y, char, color, walkable)
        end
    end
end

-- Make it compatible with array-style access grid[y][x]
function GridAdapter:__index(key)
    if type(key) == "number" then
        -- Return a row proxy
        return setmetatable({
            _adapter = self,
            _row = key
        }, {
            __index = function(t, col)
                if type(col) == "number" then
                    return t._adapter:getCell(col, t._row)
                end
                return nil
            end,
            __newindex = function(t, col, value)
                if type(col) == "number" and type(value) == "table" then
                    -- Handle the case where UI code sets grid[y][x] = {char="X", color={1,1,1}, walkable=true}
                    t._adapter:setCell(col, t._row, value.char, value.color, value.walkable)
                end
            end,
            __len = function(t)
                local cols, _ = t._adapter.engine:getGridSize()
                return cols
            end
        })
    else
        -- Return the method from the class
        return rawget(GridAdapter, key) or rawget(getmetatable(self), key)
    end
end

function GridAdapter:__len()
    local _, rows = self.engine:getGridSize()
    return rows
end

-- Set game area dimensions (called by UI.init)
function GridAdapter:setGameAreaDimensions(width, height)
    self.gameAreaWidth = width
    self.gameAreaHeight = height
end

return GridAdapter
