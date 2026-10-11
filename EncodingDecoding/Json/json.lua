local json = {}

---------------------- Lib Functions ----------------------

------------------------ Encoding -------------------------

local encodeTable = {}

--------------------- Local Functions ---------------------

local function encodeNumberBoolean(data)
    return tostring(data)
end

local function encodeString(data)
    if data == "null" then
        return "null"
    end

    data = data:gsub('[%z\1-\31\\"]', function(c)
        local escapes = {
            ['"'] = '\\"',
            ['\\'] = '\\\\',
            ['\b'] = '\\b',
            ['\f'] = '\\f',
            ['\n'] = '\\n',
            ['\r'] = '\\r',
            ['\t'] = '\\t'
        }

        return escapes[c] or string.format('\\u%04x', string.byte(c))
    end)

    return '"' .. data .. '"'
end

local function encodeArray(data)
    local result = {}

    for _, value in ipairs(data) do
        --- @type string
        local typeStr = type(value)

        if typeStr == "table" and #value ~= 0 then
            typeStr = "array"
        end

        local encoder = encodeTable[typeStr]

        if encoder then
            result[#result + 1] = encoder(value)
        end
    end

    return "[" .. table.concat(result, ",\n") .. "]"
end

local function encodeObject(data)
    local result = {}

    for key, value in pairs(data) do
        --- @type string
        local typeStr = type(value)

        if typeStr == "table" and #value ~= 0 then
            typeStr = "array"
        end

        local encoder = encodeTable[typeStr]

        if encoder then
            result[#result + 1] =
                encodeString(tostring(key))
                .. ": "
                .. encoder(value)
        end
    end

    return "{" .. table.concat(result, ",\n") .. "}"
end

encodeTable.number = encodeNumberBoolean
encodeTable.boolean = encodeNumberBoolean
encodeTable.string = encodeString
encodeTable.array = encodeArray
encodeTable.table = encodeObject

-----------------------------------------------------------

--- Function that converts a table to a json style string.
--- @param data     table   Table containing the data to be saved
--- @return string
function json.format(data)
    return encodeObject(data)
end

--- Function that writes a table as a .json file.
--- @param data     table   Table containing the data to be saved
--- @param filename string  String that represents the filename of json. Must end with .json
function json.write(data, filename)
    assert(filename:lower():match("%.json$"), "Filename is not a json file")
    local file = assert(io.open(filename, "w"), "Could not open file " .. filename)
    file:write(json.format(data))
    file:flush()
    file:close()
end

-----------------------------------------------------------




------------------------ Decoding -------------------------

local decodeValue

--------------------- Local Functions ---------------------

local function skipWhitespace(str, pos)
    while pos <= #str and str:sub(pos, pos):match("%s") do
        pos = pos + 1
    end

    return pos
end

local function decodeString(str, pos)
    pos = pos + 1

    local result = {}

    while pos <= #str do
        local char = str:sub(pos, pos)

        if char == '"' then
            return table.concat(result), pos + 1
        end

        if char == "\\" then
            pos = pos + 1

            local escaped = str:sub(pos, pos)

            local escapes = {
                ['"'] = '"',
                ['\\'] = '\\',
                ['/'] = '/',
                ['b'] = '\b',
                ['f'] = '\f',
                ['n'] = '\n',
                ['r'] = '\r',
                ['t'] = '\t'
            }

            if not escapes[escaped] then
                error("Invalid escape character: " .. escaped)
            end
            table.insert(result, escapes[escaped])
        else
            table.insert(result, char)
        end

        pos = pos + 1
    end

    error("Unterminated JSON string")
end

local function decodeNumber(str, pos)
    local remaining = str:sub(pos)
    local number = remaining:match("^-?%d+%.?%d*[eE]?[+-]?%d*")

    if not number or number == "" then
        error("Invalid number at position " .. pos)
    end

    local value = tonumber(number)

    if not value then
        error("Invalid number at position " .. pos)
    end

    return value, pos + #number
end

local function decodeArray(str, pos)
    local result = {}
    pos = skipWhitespace(str, pos + 1)
    if str:sub(pos, pos) == "]" then
        return result, pos + 1
    end

    while true do
        local value
        value, pos = decodeValue(str, pos)
        pos = skipWhitespace(str, pos)

        table.insert(result, value)
        local char = str:sub(pos, pos)

        if char == "]" then
            return result, pos + 1
        elseif char == "," then
            pos = skipWhitespace(str, pos + 1)
        else
            error("Expected ',' or ']' at position " .. pos)
        end
    end
end

local function decodeObject(str, pos)
    local result = {}
    pos = skipWhitespace(str, pos + 1)

    if str:sub(pos, pos) == "}" then
        return result, pos + 1
    end

    while true do
        local key
        key, pos = decodeValue(str, pos)
        if type(key) ~= "string" then
            error("Expected key at position " .. pos)
        end

        pos = skipWhitespace(str, pos)
        local char = str:sub(pos, pos)
        if char ~= ":" then
            error("Expected ':' at position " .. pos)
        end

        local value
        value, pos = decodeValue(str, pos + 1)

        result[key] = value

        pos = skipWhitespace(str, pos)
        char = str:sub(pos, pos)

        if char == "}" then
            return result, pos + 1
        elseif char == "," then
            pos = skipWhitespace(str, pos + 1)
        else
            error("Expected ',' or '}' at position " .. pos)
        end
    end
end


decodeValue = function(str, pos)
    pos = skipWhitespace(str, pos)
    local char = str:sub(pos, pos)

    if char == '"' then
        return decodeString(str, pos)
    elseif char == "{" then
        return decodeObject(str, pos)
    elseif char == "[" then
        return decodeArray(str, pos)
    elseif str:sub(pos, pos + 3) == "true" then
        return true, pos + 4
    elseif str:sub(pos, pos + 4) == "false" then
        return false, pos + 5
    elseif str:sub(pos, pos + 3) == "null" then
        return nil, pos + 4
    elseif char == "-" or char:match("%d") then
        return decodeNumber(str, pos)
    end

    error("Unexpected JSON value at position " .. pos)
end

-----------------------------------------------------------

--- Function that parse a json string to an object. Can return any type of data
--- @param str string  String that represents the json.
--- @return string|boolean|number|table|nil
function json.parse(str)
    assert(type(str) == "string", "Expected a JSON string")

    local result, pos = decodeValue(str, 1)
    pos = skipWhitespace(str, pos)

    if pos <= #str then
        error("Unexpected trailing data at position " .. pos)
    end

    return result
end

--- Function that reads data from a json file.  Can return any type of data
--- @param filename string  String that represents the filename of json. Must end with .json
--- @return string|boolean|number|table|nil
function json.read(filename)
    assert(filename:lower():match("%.json$"), "Filename is not a json file")
    local file = assert(io.open(filename, "r"), "Could not open file " .. filename)
    local txt = file:read("a")
    file:close()

    return json.parse(txt)
end

-----------------------------------------------------------

-----------------------------------------------------------

return json
