TextUtil = {}

function TextUtil.printCenterOff(text, pos, col, width, font)
    if col ~= nil then Colors.SetDefaultColor(col) end
    local textWidthPx = FontRenderer.getTextLength(text, font)
    FontRenderer.print(text, { x = pos.x + (width - textWidthPx) / 2, y = pos.y }, { color = col, font = font })
    Colors.ResetColor()
end

function TextUtil.printCenterOffScreen(text, y, col, font)
    TextUtil.printCenterOff(text, { x = 0, y = y }, col, Screen.resolution.x, font)
end

function TextUtil.shortNumberString(number)
    if number < 1000 then return "" .. number end
    return (math.floor(number / 100) / 10) .. "k"
end

function TextUtil.wordWrap(str, charNum)
    local lines = {}
    local line = ""
    for word in str:gmatch("%S+") do
        if #line + #TextUtil.toUtf8CharArray(word) + 1 > charNum then
            table.insert(lines, line)
            line = word
        else
            line = line == "" and word or (line .. " " .. word)
        end
    end
    if line ~= "" then
        table.insert(lines, line)
    end
    return lines
end

function TextUtil.replaceFirst(str, find, replace)
    local startPos, endPos = string.find(str, find)
    if startPos then
        return string.sub(str, 1, startPos - 1) .. replace .. string.sub(str, endPos + 1)
    end
    return str
end

function TextUtil.cutFromTheRightAfter(str, delimiter)
    local lastDelimiterPos = string.find(str, delimiter .. "[^" .. delimiter .. "]*$") or 0
    if lastDelimiterPos > 0 then
        return string.sub(str, 1, lastDelimiterPos - 1)
    end
    return str
end

function TextUtil.printFloat(float, numOfDigits)
    -- Format the number with the specified number of digits
    local formatString = string.format("%%.%df", numOfDigits or 1)
    local formattedFloat = string.format(formatString, float)

    -- Print the result
    return "" .. formattedFloat
end

function TextUtil.replaceVariables(template, replacements)
    local result = template
    local variables = TextUtil.extractKeysFromString(template)

    for i, variableName in ipairs(variables) do
        if replacements[variableName] ~= nil then
            local replacementString = replacements[variableName]
            if type(replacementString) == "table" then
                result = {
                    id = replacementString.id,
                    variables = replacementString.variables
                }
            else
                result = result:gsub("%%{" .. variableName .. "}", replacementString)
            end
        end
    end

    return result
end

function TextUtil.extractKeysFromString(inputString)
    local keys = {}
    for key in inputString:gmatch("%%{(.-)}") do
        table.insert(keys, key)
    end
    return keys
end

function TextUtil.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function TextUtil.toUtf8CharArray(string)
    local charArray = {}
    for p, c in utf8.codes(string) do
        table.insert(charArray, utf8.char(c))
    end

    return charArray
end

function TextUtil.utf8CharArrayToString(charArray)
    local string = ""
    for i, char in ipairs(charArray) do
        string = string .. char
    end

    return string
end

function TextUtil.join(array, arg1, arg2)
    local result = ""
    local arg1 = arg1 or ","

    if type(arg1) == "string" then
        for i = 1, #array do
            result = result .. array[i]
            if i < #array then
                result = result .. arg1
            end
        end

        return result
    end

    if type(arg1) == "function" then
        for i = 1, #array do
            result = result .. arg1(array[i], i)
            if i < #array then
                result = result .. (arg2 or ",")
            end
        end

        return result
    end

    --else
    for i = 1, #array do
        result = result .. array[i]
        if i < #array then
            result = result .. arg1
        end
    end
end

function TextUtil.elipseText(text, ammountOfChars)
    if #text <= ammountOfChars then
        return text
    end

    return string.sub(text, 1, ammountOfChars - 3) .. "..."
end
