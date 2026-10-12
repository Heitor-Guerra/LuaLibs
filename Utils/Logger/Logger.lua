--- @class Logger
--- A class that represents a Logger, used to maintain information on how the system is working.
--- @field logPath  string   Used to represent where the log should be written. Value can be overriden. Defaults to "./logs.log"
--- @field minLevel LogLevel Used to represent the minumum level to capture. Levels lower than this will be ignored. Value can be overriden. Defaults to Logger.Level.DEBUG
local Logger = {}
Logger.__index = function(self, key)
    if key == "logPath" then
        return rawget(self, "_logPath")
    else
        return rawget(Logger, key)
    end
end

--- Logger levels by priority (higher number = more severe)
--- @enum LogLevel
Logger.Level = {
    DEBUG = 1,
    INFO  = 2,
    WARN  = 3,
    ERROR = 4
}

-------------------- Logger Constructor --------------------

--- Creates a new Logger instance.
--- @param logPath?  string        Path to the log file. Defaults to "./logs.log" if not provided.
--- @param minLevel? LogLevel      Minimum log level to capture. Defaults to DEBUG.
--- @return table
function Logger.new(logPath, minLevel)
    logPath = logPath or "./logs.log"
    minLevel = minLevel or Logger.Level.DEBUG

    return setmetatable({
        _logPath = logPath,
        _minLevel = minLevel
    }, Logger)
end

------------------------------------------------------------



---------------------- Logger Methods ----------------------

--- Writes a log message to file and console output. Returns `true` if successful, `false` otherwise.
--- @param msg   string    The message content to log.
--- @param at    string    Location/context identifier where the log occurred.
--- @param level LogLevel  Log level (DEBUG, INFO, WARN, ERROR).
--- @param out   file*     Output stream (io.stdout or io.stderr).
--- @return boolean
function Logger:log(msg, at, level, out)
    if self.minLevel and level < self.minLevel then
        return true
    end

    local timestamp = os.date("%Y-%m-%dT%H:%M:%S")

    local levelStr = type(level) == "number" and ({ "DEBUG", "INFO", "WARN", "ERROR" })[level] or tostring(level)

    local str = string.format(
        "[%s] %s --- {%s}\t\t\t: %s\n",
        levelStr, timestamp, at, msg
    )

    local ok, err = pcall(function()
        local file = assert(io.open(self.logPath, "a+"), "Could not open file: " .. self.logPath)
        file:write(str)
        file:flush()
        file:close()
    end)

    if not ok then
        io.stderr:write("[LOGGER ERROR] File write failed: " .. tostring(err) .. "\n")
    end

    io.write(out, str)
    return ok;
end

------------------------------------------------------------


----------------------- Wrap Methods -----------------------

--- Logs a warning message with WARN level.
--- Writes to file and stdout.
--- @param msg   string  The warning message content.
--- @param at    string  Location/context identifier.
function Logger:logWarn(msg, at)
    self:log(msg, at, self.Level.WARN, io.stdout)
end

--- Logs an informational message with INFO level.
--- Writes to file and stdout.
--- @param msg   string  The warning message content.
--- @param at    string  Location/context identifier.
function Logger:logInfo(msg, at)
    self:log(msg, at, self.Level.INFO, io.stdout)
end

--- Logs an error message with ERROR level.
--- Writes to file and stdout.
--- @param msg   string  The warning message content.
--- @param at    string  Location/context identifier.
function Logger:logError(msg, at)
    self:log(msg, at, self.Level.ERROR, io.stderr)
end

--- Logs a debug message with DEBUG level.
--- Writes to file and stdout.
--- @param msg   string  The warning message content.
--- @param at    string  Location/context identifier.
function Logger:logDebug(msg, at)
    self:log(msg, at, self.Level.DEBUG, io.stdout)
end

------------------------------------------------------------


return Logger
