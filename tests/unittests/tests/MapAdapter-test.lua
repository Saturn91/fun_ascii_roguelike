-- MapAdapter module test
-- Testing map definition to AsciiGrid layer conversion

DefaultMapDefinition = require("mapgenerators.DefaultMapDefinition")
AsciiGrid = require("asciiEngine.asciiGrid")
GridChar = require("asciiEngine.GridChar")
MapAdapter = require("mapgenerators.MapAdapter")
MapDefinition = require("mapgenerators.mapdefinition")

function run(test)
    
    -- Test MapAdapter basic functionality
    test.newSection("MapAdapter Basic Tests")
    
    -- Create a simple mock MapDefinition manually without validation
    local mockMap = {
        width = 3,
        height = 3,
        tileMap = {
            {2, 2, 2},
            {2, 1, 2},
            {2, 2, 2}
        },
        tileDefinitions = {[1] = {
            glyph = ".",
            color = {0, 1, 0, 1}
        }, [2] = {
            glyph = "█",
            color = {0.5, 0.5, 0.5, 1}
        }},
    }
    
    -- Test new object-oriented approach
    local mapAdapter = MapAdapter.new(mockMap, "testLayer", 0, 0)
    
    test.assert_equal("testLayer", mapAdapter.layer.id, "MapAdapter layer should have correct id")
    test.assert_equal("testLayer", mapAdapter.layerId, "MapAdapter layerId field should be correct")
    test.assert_equal(0, mapAdapter.offsetX, "MapAdapter offsetX should be correct")
    test.assert_equal(0, mapAdapter.offsetY, "MapAdapter offsetY should be correct")
    test.assert_equal(mockMap, mapAdapter.mapDefinition, "MapAdapter should store mapDefinition")
    
    -- Test with offset
    local mapAdapterWithOffset = MapAdapter.new(mockMap, "offsetLayer", 5, 3)
    test.assert_equal("offsetLayer", mapAdapterWithOffset.layer.id, "MapAdapter with offset should have correct layer id")
    test.assert_equal(5, mapAdapterWithOffset.offsetX, "MapAdapter offsetX should be correct")
    test.assert_equal(3, mapAdapterWithOffset.offsetY, "MapAdapter offsetY should be correct")
    
    -- Test updateMap method
    local newMockMap = {
        width = 2,
        height = 2,
        tileMap = {
            {1, 1},
            {1, 1}
        },
        tileDefinitions = {[1] = {
            glyph = "o",
            color = {1, 0, 0, 1}
        }},
    }
    
    -- Create a mock engine for testing updateMap
    local mockEngine = {
        getGridSize = function() return 10, 10 end
    }
    
    -- Initialize the layer first
    mapAdapter.layer:initialize(mockEngine)
    mapAdapter:updateMap(newMockMap, mockEngine)
    test.assert_equal(newMockMap, mapAdapter.mapDefinition, "MapAdapter should update mapDefinition")
    test.assert_equal(2, mapAdapter.mapDefinition.width, "Updated map should have new width")
    test.assert_equal(2, mapAdapter.mapDefinition.height, "Updated map should have new height")
    
    -- Test DefaultMapDefinition functionality
    test.newSection("DefaultMapDefinition Tests")
    
    local map = DefaultMapDefinition.createSimpleRoom(3, 3)
    
    test.assert_equal(2, map.tileMap[1][1], "Corner should be wall")
    test.assert_equal(1, map.tileMap[2][2], "Center should be floor")
    test.assert_equal(false, map.walkable[1][1], "Corner should not be walkable")
    test.assert_equal(true, map.walkable[2][2], "Center should be walkable")
    test.assert_equal(3, map.width, "Map width should be correct")
    test.assert_equal(3, map.height, "Map height should be correct")
    
    -- Test default size parameters
    local defaultSizeMap = DefaultMapDefinition.createSimpleRoom()
    test.assert_equal(20, defaultSizeMap.width, "Default width should be 20")
    test.assert_equal(15, defaultSizeMap.height, "Default height should be 15")
    
    -- Test tile definitions
    test.assert_equal(map.tileDefinitions[1].glyph, ",", "Floor tile should be correct")
    test.assert_equal(map.tileDefinitions[2].glyph, "█", "Wall tile should be correct")
    test.assert_equal("floor", map.tileIds[1], "Floor tile ID should be correct")
    test.assert_equal("wall", map.tileIds[2], "Wall tile ID should be correct")
    
    -- Test integration: DefaultMapDefinition with MapAdapter
    test.newSection("MapAdapter Integration Tests")
    
    local integrationMap = DefaultMapDefinition.createSimpleRoom(5, 4)
    local integrationMapAdapter = MapAdapter.new(integrationMap, "integrationLayer", 1, 1)
    
    test.assert_equal("integrationLayer", integrationMapAdapter.layer.id, "Integration layer should have correct id")
    test.assert_equal(integrationMap, integrationMapAdapter.mapDefinition, "Integration should store mapDefinition")
    test.assert_equal(1, integrationMapAdapter.offsetX, "Integration offsetX should be correct")
    test.assert_equal(1, integrationMapAdapter.offsetY, "Integration offsetY should be correct")
    
end

return run
