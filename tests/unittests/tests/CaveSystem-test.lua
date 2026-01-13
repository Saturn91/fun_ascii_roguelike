-- CaveSystem module test
-- Testing cave system generation

-- Mock love.math.random for consistent testing
love = love or {}
love.math = love.math or {}

-- Use real random for cave generation to allow natural variation
function love.math.random(min, max)
    if min and max then
        return math.random(min, max)
    elseif min then
        return math.random(min)
    else
        return math.random()
    end
end

-- Import required modules and dependencies
require("util._index")
MapDefinition = require("mapgenerators.mapdefinition")
local CaveSystem = require("mapgenerators.generators.CaveSystem")

function run(test)
    
    test.newSection("CaveSystem Generation Tests")
    
    local map = CaveSystem.generate(50, 30)
    
    test.assert_equal(50, map.width, "Map width should be 50")
    test.assert_equal(30, map.height, "Map height should be 30")
    test.assert_equal(false, map.walkable == nil, "Walkable map should not be nil")
    test.assert_equal(false, map.tileMap == nil, "Tile map should not be nil")
    test.assert_equal(false, map.options.rooms == nil, "Caves should not be nil")
    
    local walkableCount = 0
    for y = 1, map.height do
        for x = 1, map.width do
            if map.walkable[y][x] then
                walkableCount = walkableCount + 1
            end
        end
    end
    
    test.assert_equal(true, walkableCount > 0, "Should have at least some walkable tiles")
    test.assert_equal(true, #map.options.rooms > 0, "Should have at least one cave")
    
    test.newSection("CaveSystem Room Properties Tests")
    
    local caves = map.options.rooms
    
    for i, cave in ipairs(caves) do
        test.assert_equal(false, cave.centerX == nil, "Cave " .. i .. " should have centerX")
        test.assert_equal(false, cave.centerY == nil, "Cave " .. i .. " should have centerY")
        test.assert_equal(false, cave.radius == nil, "Cave " .. i .. " should have radius")
        test.assert_equal(true, cave.centerX > 0, "Cave " .. i .. " centerX should be positive")
        test.assert_equal(true, cave.centerY > 0, "Cave " .. i .. " centerY should be positive")
        test.assert_equal(true, cave.radius > 0, "Cave " .. i .. " radius should be positive")
    end
    
    test.newSection("CaveSystem Different Sizes Tests")
    
    local smallMap = CaveSystem.generate(30, 20)
    local largeMap = CaveSystem.generate(120, 80)
    
    test.assert_equal(30, smallMap.width, "Small map width should be 30")
    test.assert_equal(20, smallMap.height, "Small map height should be 20")
    test.assert_equal(120, largeMap.width, "Large map width should be 120")
    test.assert_equal(80, largeMap.height, "Large map height should be 80")
    
    test.newSection("CaveSystem Tile Definitions Tests")
    
    test.assert_equal(false, map.tileDefinitions[1] == nil, "Floor tile definition should exist")
    test.assert_equal(false, map.tileDefinitions[2] == nil, "Wall tile definition should exist")
    test.assert_equal(false, map.tileDefinitions[3] == nil, "Empty tile definition should exist")
    test.assert_equal(false, map.tileDefinitions[4] == nil, "Extension tile definition should exist")
    
    test.assert_equal(".", map.tileDefinitions[1].glyph, "Floor glyph should be '.'")
    test.assert_equal("█", map.tileDefinitions[2].glyph, "Wall glyph should be '█'")
    test.assert_equal(" ", map.tileDefinitions[3].glyph, "Empty glyph should be ' '")
    test.assert_equal(".", map.tileDefinitions[4].glyph, "Extension glyph should be '.'")
    
    -- Check that extension has blue color
    test.assert_equal(true, map.tileDefinitions[4].color[3] > 0.8, "Extension should have blue component")
    
    test.newSection("CaveSystem Walkable Map Integrity Tests")
    
    -- Check that walkable map has correct dimensions
    test.assert_equal(map.height, #map.walkable, "Walkable map height should match map height")
    for y = 1, #map.walkable do
        test.assert_equal(map.width, #map.walkable[y], "Walkable map width should match map width at row " .. y)
    end
    
    -- Check that tile map has correct dimensions
    test.assert_equal(map.height, #map.tileMap, "Tile map height should match map height")
    for y = 1, #map.tileMap do
        test.assert_equal(map.width, #map.tileMap[y], "Tile map width should match map width at row " .. y)
    end
    
    -- Check that walkable and tile map correspond correctly
    for y = 1, map.height do
        for x = 1, map.width do
            if map.walkable[y][x] then
                test.assert_equal(true, map.tileMap[y][x] == 1 or map.tileMap[y][x] == 4, "Walkable tiles should be floor (1) or extension (4)")
            else
                test.assert_equal(true, map.tileMap[y][x] == 2 or map.tileMap[y][x] == 3, 
                    "Non-walkable tiles should be wall (2) or empty (3)")
            end
        end
    end
end

return run
