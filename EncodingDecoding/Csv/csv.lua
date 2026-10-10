local csv = {}


--------------------- Local Functions ---------------------

--- Splits a CSV line into its fields.
--- Supports quoted fields, escaped quotes and commas inside quotes.
--- @param line string   String representing the line to be splitted.
--- @return table
local function splitCsv(line)
    local result = {}
    local i = 1
    local len = #line

    while i <= len do
        while i <= len and line:sub(i, i) == " " do
            i = i + 1
        end

        if line:sub(i, i) == '"' then
            i = i + 1
            local start = i
            local field = ""

            while i <= len do
                local c = line:sub(i, i)
                if c == '"' then
                    if line:sub(i + 1, i + 1) == '"' then
                        field = field .. line:sub(start, i - 1) .. '"'
                        i = i + 2
                        start = i
                    else
                        field = field .. line:sub(start, i - 1)
                        i = i + 1
                        break
                    end
                else
                    i = i + 1
                end
            end

            while i <= len and line:sub(i, i) ~= "," do
                i = i + 1
            end

            table.insert(result, field)
        else
            local start = i
            while i <= len and line:sub(i, i) ~= "," do
                i = i + 1
            end
            table.insert(result, line:sub(start, i - 1))
        end
        if i <= len and line:sub(i, i) == "," then
            i = i + 1

            if i > len then
                table.insert(result, "")
            end
        else
            break
        end
    end
    return result
end

--- Local function that escape csv values, like ',','"' and '\n'
--- @param v string   String representing the line to be escaped.
--- @return string
local function escapeCsvField(v)
    v = tostring(v)
    if v:find('[,"\n]') then
        v = '"' .. v:gsub('"', '""') .. '"'
    end
    return v
end

-----------------------------------------------------------



------------------------ DataTable ------------------------

--- Represents tabular data with named columns.
--- Allow modification like dt[1]["age"] = 30 and access like dt["age"]
--- @class DataTable
--- @field headers  table<string>       Array containing the column names
--- @field data     table<table<any>>   Array containing rows keyed by column names
local DataTable = {}
DataTable.__index = function(self, key)
    local value = rawget(DataTable, key)
    if value ~= nil then
        return value
    end

    value = rawget(self, key)
    if value ~= nil then
        return value
    end

    if type(key) == "number" then
        return self.data[key]
    end

    if type(key) == "string" and self:hasColumn(key) then
        return self:getColumn(key)
    end

    return nil
end

csv.DataTable = DataTable


------------------ DataTable Constructor ------------------

--- Creates a new DataTable.
--- Rows are copied into the new table; individual row tables are not copied.
--- @param headers  table<string>?  Array of column names
--- @param data     table<any>?     Array of rows keyed by column names
--- @return DataTable
function DataTable.new(headers, data)
    headers = headers or {}
    data = data or {}
    local self = setmetatable({}, DataTable)

    self.headers = headers
    self.data = {}

    local seen = {}

    for _, header in ipairs(self.headers) do
        assert(type(header) == "string" and header ~= "",
            "Headers must be non-empty strings")
        assert(not seen[header], "Duplicate header: " .. header)
        seen[header] = true
    end

    for _, row in ipairs(data) do
        self:addRow(row)
    end

    return self
end

-----------------------------------------------------------



-------------------- DataTable Getters --------------------

--- Returns the number of rows.
--- @return integer
function DataTable:rowCount()
    return #self.data
end

--- Returns the number of columns.
--- @return integer
function DataTable:columnCount()
    return #self.headers
end

--- Returns a column as an array of values.
--- @param column string    Column name
--- @return table
function DataTable:getColumn(column)
    assert(self:hasColumn(column), "DataTable does not have column " .. column)
    local header = column
    local result = {}

    for i, row in ipairs(self.data) do
        result[i] = row[header]
    end

    return result
end

--- Returns a row by its index.
--- @param index integer  Row index
--- @return table
function DataTable:getRow(index)
    assert(type(index) == "number" and self.data[index] ~= nil, "Invalid row index: " .. index)

    return self.data[index]
end

--- Returns whether a column exists.
--- @param column string  Column name
--- @return boolean
function DataTable:hasColumn(column)
    for _, header in ipairs(self.headers) do
        if header == column then
            return true
        end
    end

    return false
end

-----------------------------------------------------------



------------------- DataTable Modifiers -------------------

--- Removes all rows while preserving the headers.
function DataTable:clear()
    self.data = {}
end

--- Adds a row to DataTable.
--- Every declared column must be present in the row.
--- @param row table  Row to be added to DataTable
function DataTable:addRow(row)
    assert(type(row) == "table", "Row must be a table")

    local newRow = {}

    for _, header in ipairs(self.headers) do
        assert(row[header] ~= nil, "Row does not have header " .. header)
        newRow[header] = row[header]
    end

    table.insert(self.data, newRow)
end

--- Removes and returns a row.
--- @param index integer  Index of the row to be removed
--- @return table
function DataTable:removeRow(index)
    assert(type(index) == "number" and self.data[index] ~= nil, "Invalid row index")

    return table.remove(self.data, index)
end

--- Adds a column with specified default value.
--- @param header string  Column name
--- @param defaultValue? any
function DataTable:addColumn(header, defaultValue)
    assert(type(header) == "string" and header ~= "", "Header must be a non-empty string")
    assert(not self:hasColumn(header), "Column already exists: " .. header)

    table.insert(self.headers, header)

    for _, row in ipairs(self.data) do
        row[header] = defaultValue
    end
end

--- Removes a column and returns its values.
--- @param column string  Column name
--- @return table
function DataTable:removeColumn(column)
    assert(self:hasColumn(column), "DataTable does not have column " .. column)
    local header = column
    local values = self:getColumn(header)

    for i, name in ipairs(self.headers) do
        if name == header then
            table.remove(self.headers, i)
            break
        end
    end

    for _, row in ipairs(self.data) do
        row[header] = nil
    end

    return values
end

-----------------------------------------------------------



--------------------- DataTable Saves ---------------------

--- Function that writes data to a csv file.
--- @param filename  string      String that represents the filename of the csv to be saved. Must end with .csv
function DataTable:toCsv(filename)
    assert(filename:lower():match("%.csv$"), "Filename is not a csv file")
    local file = assert(io.open(filename, "w"), "Could not open file")

    local data = self.data
    local headers = self.headers

    local headersLine = ""
    for _, value in ipairs(headers) do
        headersLine = headersLine .. escapeCsvField(value) .. ","
    end
    headersLine = headersLine:sub(1, -2)
    file:write(headersLine .. '\n')

    for i, line in ipairs(data) do
        local lineStr = ""
        for _, header in ipairs(headers) do
            assert(line[header] ~= nil, "Line " .. i .. " does not have header " .. header)
            lineStr = lineStr .. escapeCsvField(line[header]) .. ","
        end
        lineStr = lineStr:sub(1, -2)
        file:write(lineStr .. '\n')
    end

    file:flush()
    file:close()
end

-----------------------------------------------------------



-----------------------------------------------------------




---------------------- Lib Functions ----------------------

--- Function that reads data from a csv file. Returns an DataTable representing the csv
--- @param filename string  String that represents the filename of csv. Must end with .csv
--- @return DataTable
function csv.read(filename)
    assert(filename:lower():match("%.csv$"), "Filename is not a csv file")
    local file = assert(io.open(filename, "r"), "Could not open file")

    local data = {}

    --- @type string
    local headersStr = file:read("l");

    --- @type table
    local headers = splitCsv(headersStr)

    for line in file:lines() do
        local vals = splitCsv(line)
        local row = {}
        for i, header in ipairs(headers) do
            row[header] = vals[i]
        end
        table.insert(data, row)
    end
    file:close()

    return DataTable.new(headers, data)
end

-----------------------------------------------------------


return csv
