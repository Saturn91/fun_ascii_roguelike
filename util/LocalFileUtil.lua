LocalFileUtil = {}

function LocalFileUtil.saveImage(path, image)
    -- Save the current transformation state
    love.graphics.push()

    -- Reset the transformation state to disable scaling
    love.graphics.origin()

    --put Sprite into a canvas
    local canvas = love.graphics.newCanvas(image:getWidth(), image:getHeight())
    love.graphics.setCanvas(canvas)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(image)
    love.graphics.setCanvas() -- The canvas must not be active when we call canvas:newImageData().

    local imagedata = canvas:newImageData()

    --actually write file
    imagedata:encode("png",path)

    -- Restore the previous transformation state
    love.graphics.pop()
end

function LocalFileUtil.loadImage(path)
    return love.graphics.newImage(LocalFileUtil.readFileRaw(path))
end

function LocalFileUtil.readFileRaw(path)
    local data = love.filesystem.newFileData(path)
    return data
end

function LocalFileUtil.writeFile(path, string)
    love.filesystem.write(path,string)
end

function LocalFileUtil.recursiveGetAllFilesInDirectory(directory)
    local files = {}
    local directoriesToCheck = {directory}
    local directories = {}

    while #directoriesToCheck > 0 do
        local currentDirectory = table.remove(directoriesToCheck,1)
        local allFilesInFolder = love.filesystem.getDirectoryItems(currentDirectory)
        ArrayUtil.ForEach(allFilesInFolder, function(fileName)
            local currentFile = currentDirectory.."/"..fileName
            if love.filesystem.getInfo(currentFile).type == "directory" then
                table.insert(directoriesToCheck,currentFile)
                table.insert(directories,currentFile)
            else
                table.insert(files,currentFile)
            end
        end)
    end
    
    return {
        files=files,
        directories=directories
    }
end

function LocalFileUtil.recursiveCopyAllFilesInDirectory(from, to)
    local files = LocalFileUtil.recursiveGetAllFilesInDirectory(from).files
    local newPaths = ArrayUtil.map(files, function(filePath)
        return TextUtil.replaceFirst(filePath,from,to)
    end)

    for i,fileName in ipairs(files) do
        LocalFileUtil.createPathDirectoryIfNotExists(newPaths[i])
        love.filesystem.write(newPaths[i],love.filesystem.read(fileName))
    end    
end

function LocalFileUtil.createPathDirectoryIfNotExists(path)
    local directory = TextUtil.cutFromTheRightAfter(path, "/")
    if love.filesystem.getInfo(directory) == nil then
        love.filesystem.createDirectory(directory)
    end
end

function LocalFileUtil.recursiveDeleteAllFilesAndDirectoriesWithinDirectory(directory)
    local content = LocalFileUtil.recursiveGetAllFilesInDirectory(directory)

    local directories = ArrayUtil.Reverse(content.directories)

    ArrayUtil.ForEach(content.files,function(file)
        love.filesystem.remove(file)
    end)

    ArrayUtil.ForEach(directories, function(dir)
        love.filesystem.remove(dir)
    end)
end

function LocalFileUtil.addLineToFile(path, line, options)
    local options = options or {}

    -- Read the existing content of the file, if it exists
    local content = love.filesystem.read(path) or ""

    local addLine = true
    if options.noDuplicatedLines then
        -- Check if the line already exists in the content
        if content:find(line, 1, true) then
            addLine = false
        end
    end

    -- Append the new line and a newline character if needed
    if addLine then
        content = content .. line .. "\n"
    end

    -- Write the updated content back to the file
    love.filesystem.write(path, content)
end

function LocalFileUtil.getAllDirectoriesWithinFolder(folder)
    local allFiles = love.filesystem.getDirectoryItems(folder)
    local directories = ArrayUtil.Filter(allFiles, function(file) return love.filesystem.getInfo(folder.."/"..file).type == "directory" end)
    return directories
end
