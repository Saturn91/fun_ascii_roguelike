-- MapAdapter module test
-- Testing map definition to AsciiGrid layer conversion

DefaultMapDefinition = require("mapgenerators.DefaultMapDefinition")
AsciiGrid = require("asciiEngine.asciiGrid")
MapAdapter = require("mapgenerators.MapAdapter")

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
        tileDefinitions = {[1] = ".", [2] = "█"}
    }
    
    local mapLayer, populateLayer = MapAdapter.createLayerFromMapDefinition(mockMap, "testLayer", 0, 0)
    
    test.assert_equal("testLayer", mapLayer.id, "Layer should have correct id")
    test.assert_equal("function", type(populateLayer), "Should return a populate function")
    
    -- Test with offset
    local mapLayerWithOffset, populateLayerWithOffset = MapAdapter.createLayerFromMapDefinition(mockMap, "offsetLayer", 5, 3)
    test.assert_equal("offsetLayer", mapLayerWithOffset.id, "Layer with offset should have correct id")
    test.assert_equal("function", type(populateLayerWithOffset), "Layer with offset should return a populate function")
    
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
    test.assert_equal(".", map.tileDefinitions[1], "Floor tile should be correct")
    test.assert_equal("█", map.tileDefinitions[2], "Wall tile should be correct")
    test.assert_equal("floor", map.tileIds[1], "Floor tile ID should be correct")
    test.assert_equal("wall", map.tileIds[2], "Wall tile ID should be correct")
    
    -- Test integration: DefaultMapDefinition with MapAdapter
    test.newSection("MapAdapter Integration Tests")
    
    local integrationMap = DefaultMapDefinition.createSimpleRoom(5, 4)
    local integrationLayer, integrationPopulate = MapAdapter.createLayerFromMapDefinition(integrationMap, "integrationLayer", 1, 1)
    
    test.assert_equal("integrationLayer", integrationLayer.id, "Integration layer should have correct id")
    test.assert_equal("function", type(integrationPopulate), "Integration should return populate function")
    
end

return run
