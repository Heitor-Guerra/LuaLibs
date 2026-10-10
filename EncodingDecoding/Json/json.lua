local json = {}


--------------------- Local Functions ---------------------



-----------------------------------------------------------



---------------------- Lib Functions ----------------------

--- Function that reads data from a json file. Returns a table representing the object
--- @param filename string  String that represents the filename of json. Must end with .json
--- @return table
function json.read(filename)
    assert(filename:lower():match("%.json$"), "Filename is not a json file")
    local file = assert(io.open(filename, "r"), "Could not open file")

    local data = {}



    file:close()
    return data
end

--- Function that parse a json string to an object. Returns a table representing the object
--- @param json string  String that represents the json.
--- @return table
function json.parse(json)
    local data = {}


    return data
end

--- Function that writes a table as a .json file.
--- @param data     table   Table containing the data to be saved
--- @param filename string  String that represents the filename of json. Must end with .json
function json.write(data, filename)
end

--- Function that converts a table to a json style string.
--- @param data     table   Table containing the data to be saved
--- @return string
function json.string(data)
    local result = ""

    return result
end

-----------------------------------------------------------


return json
