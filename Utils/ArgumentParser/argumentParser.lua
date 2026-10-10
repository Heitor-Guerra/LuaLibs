local argumentParse = {}

--------------------- Local Functions ---------------------

--- Local function that prints the help message on stdout
--- @param expectedArgs table<string>   Table containing the expected arguments, as the index, and their description on value.
local function printHelp(expectedArgs)
    print("usage: " .. arg[0] .. " [options]")
    print("Available options are:")

    for arg, desc in pairs(expectedArgs) do
        print(arg .. "\t\t" .. desc)
    end
end

-----------------------------------------------------------



---------------------- Lib Functions ----------------------


--- Simple cli Argument Parser that takes the expected arguments and returns their values. Generate, automatically, help and error messages
--- @param expectedArgs table<string>  Table containing the expected arguments, as the index, and their description on value. In instance, a table like the following is the expected format: `local expected = {["--temp1"] = "Do something 1", ["--temp2"] = "Do something 2`. It is recommended to build it like this, since Lua use -- as comment
--- @return table<string> arguments    Table containing the parsed arguments
function argumentParse.parse(expectedArgs)
    local returnTable = {}
    local j = 1

    while j <= #arg do
        if arg[j] == "--help" or arg[j] == "-h" then
            printHelp(expectedArgs)
            os.exit()
        end

        if expectedArgs[arg[j]] then
            returnTable[arg[j]] = arg[j + 1]
            j = j + 1
        else
            print(arg[0] .. ": unrecognized option '" .. arg[j] .. "'")
            printHelp(expectedArgs)
            os.exit()
        end
        j = j + 1
    end

    return returnTable
end

-----------------------------------------------------------

return argumentParse
