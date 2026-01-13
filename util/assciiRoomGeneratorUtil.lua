AsciiRoomGeneratorUtil = {}

function AsciiRoomGeneratorUtil.generateRoom(width, height, floorChar, wallChar)
    local room = {}
    for y = 1, height do
        room[y] = {}
        for x = 1, width do
            if x == 1 or x == width or y == 1 or y == height then
                room[y][x] = wallChar or "█"
            else
                room[y][x] = floorChar or "."
            end
        end
    end
end

return AsciiRoomGeneratorUtil