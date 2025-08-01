--source: https://raw.githubusercontent.com/tedajax/json-lua/master/json.lua

--[[
The MIT License (MIT)
Copyright (c) 2014 Ted Dobyns
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local _json = require "tests/unitTestLib/jsonDecode"
json = {
    parse = _json.decode
}

local tokens = {}

tokens.quote = '\"'
tokens.comma = ','
tokens.colon = ':'
tokens.leftBracket = '['
tokens.rightBracket = ']'
tokens.leftBrace = '{'
tokens.rightBrace = '}'

local types = {
    none = 0,
    syntax = 1,
    number = 2,
    string = 3,
    boolean = 4
}

local table_types = {
    array = 0,
    object = 1
}

local function count_table_items(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

local function encode_spaces(output, count, minify)
    if minify then return output end

    for i = 1, count do
        output = output .. ' '
    end

    return output
end

local function encode_return(output, minify, tabIndex)
    if minify then return output end

    output = output .. '\n'
    output = encode_spaces(output, tabIndex * 4, minify)

    return output
end

local function encode_number(output, number, minify, tabIndex)
    output = output .. tostring(number)
    return output
end

local function encode_boolean(output, boolean, minify, tabIndex)
    output = output .. tostring(boolean)
    return output
end

local function encode_string(output, string, minify, tabIndex)
    output = output .. '\"' .. string .. '\"'
    return output
end

local function encode_keyvalue(output, key, value, minify, tabIndex)
    output = encode_string(output, key, minify, tabIndex)

    output = encode_spaces(output, 1, minify)

    output = output .. ':'

    output = encode_spaces(output, 1, minify)

    output = encode_value(output, value, minify, tabIndex)

    return output
end

local function encode_object(output, object, minify, tabIndex)
    output = output .. '{'

    tabIndex = tabIndex + 1
    output = encode_return(output, minify, tabIndex)

    local keys = {}
    for k, _ in pairs(object) do
        table.insert(keys, k)
    end
    table.sort(keys)

    local count = #keys
    local encoded = 0

    for _, k in ipairs(keys) do
        output = encode_keyvalue(output, k, object[k], minify, tabIndex)

        encoded = encoded + 1

        if encoded < count then
            output = output .. ','
        else
            tabIndex = tabIndex - 1
        end

        output = encode_return(output, minify, tabIndex)
    end

    output = output .. '}'

    return output
end


local function encode_array(output, array, minify, tabIndex)
    output = output .. '['

    tabIndex = tabIndex + 1
    output = encode_return(output, minify, tabIndex)

    for i, value in ipairs(array) do
        output = encode_value(output, value, minify, tabIndex)

        if i < #array then
            output = output .. ','
        else
            tabIndex = tabIndex - 1
        end

        output = encode_return(output, minify, tabIndex)
    end

    output = output .. ']'

    return output
end

local function table_type(table)
    if #table > 0 then
        return table_types.array
    else
        return table_types.object
    end
end

local function encode_table(output, table, minify, tabIndex)
    if table_type(table) == table_types.array then
        output = encode_array(output, table, minify, tabIndex)
    else
        output = encode_object(output, table, minify, tabIndex)
    end

    return output
end

function encode_value(output, value, minify, tabIndex)
    local t = type(value)
    if t == "table" then
        output = encode_table(output, value, minify, tabIndex)
    elseif t == "number" then
        output = encode_number(output, value, minify, tabIndex)
    elseif t == "string" then
        output = encode_string(output, value, minify, tabIndex)
    elseif t == "boolean" then
        output = encode_boolean(output, value, minify, tabIndex)
    end

    return output
end

local function encode(table, minify)
    assert(type(table) == "table", "JSON encoding requires a table.")

    local output = ""

    output = encode_table(output, table, minify, 0)

    return output
end

json.stringify = encode
