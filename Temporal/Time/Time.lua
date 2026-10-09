--- @class Time
--- An immutable Time with hour, minute and seconds.
--- The components can be read through `hour`, `min` and `sec`, but cannot be changed.
--- @field hour integer              The hour of the time. Goes from 0 to 23
--- @field min  integer              The minute of the time. Goes from 0 to 59
--- @field sec  integer              The second of the time. Goes from 0 to 59
local Time = {}
Time.__index = function(self, key)
  if key == "hour" then
    return rawget(self, "_hour")
  elseif key == "min" then
    return rawget(self, "_min")
  elseif key == "sec" then
    return rawget(self, "_sec")
  end
  return Time[key]
end
Time.__newindex = function(self, key, value)
  error("Time is immutable. Please create a new instance.")
end


-------------------- Time Constructors --------------------

--- Return a time with the given values.
--- @param hour    integer   The value of the hour
--- @param minute  integer   The value of the minute
--- @param second  integer   The value of the second
--- @return Time
function Time.of(hour, minute, second)
  assert(math.type(hour) == "integer" and hour >= 0 and hour < 24, "invalid hour")
  assert(math.type(minute) == "integer" and minute >= 0 and minute < 60, "invalid minute")
  assert(math.type(second) == "integer" and second >= 0 and second < 60, "invalid second")

  return setmetatable({
    _hour = hour,
    _min = minute,
    _sec = second
  }, Time)
end

--- Return current time, based on POSIX Epoch.
--- @return Time
function Time.now()
  local t = os.date("*t")

  return Time.of(t.hour, t.min, t.sec)
end

--- Parse a Time from the given String
--- @param timeString  string  The string to be converted into a time
--- @param format      string? Optional parameter that tells how the string should be parsed. The char 'h' is used to represent the hour (2 characters), 'm' the minute (2 characters) and 's' the second (2 characters) . For exemple, a format 'h:m:s' expects a string of the type '06:21:12'. It uses this format as default.
--- @return Time
function Time.parse(timeString, format)
  format = (type(format) == "string" and format) or "h:m:s"
  assert(type(timeString) == "string", "Invalid input for parse")
  local i = 1

  local hour
  local minute
  local second
  for c in format:gmatch('.') do
    if c == 'h' then
      hour = tonumber(timeString:sub(i, i + 1))
      i = i + 2
    elseif c == 'm' then
      minute = tonumber(timeString:sub(i, i + 1))
      i = i + 2
    elseif c == 's' then
      second = tonumber(timeString:sub(i, i + 1))
      i = i + 2
    else
      if timeString:byte(i) ~= c:byte(1) then
        error("Wrong input for format")
      end
      i = i + 1
    end
  end

  --- @cast hour integer
  --- @cast minute integer
  --- @cast second integer
  return Time.of(hour, minute, second)
end

-----------------------------------------------------------



------------------- Operations Overload -------------------

--- Add "seconds" amount of seconds to the Time.
--- @param seconds integer  The amount of seconds to be added to time
--- @return Time
function Time:__add(seconds)
  assert(math.type(seconds) == "integer", "invalid seconds")

  local sec = (self.sec + seconds) % 60
  local min = (self.min + (self.sec + seconds) // 60) % 60
  local hour = (self.hour + (self.min + (self.sec + seconds) // 60) // 60) % 24

  return Time.of(hour, min, sec)
end

--- Subtract "seconds" amount of seconds to the Time.
--- @param seconds integer  The amount of seconds to be subbed from time
--- @return Time
function Time:__sub(seconds)
  assert(math.type(seconds) == "integer", "invalid seconds")

  local sec = (self.sec - seconds) % 60
  local min = (self.min + (self.sec - seconds) // 60) % 60
  local hour = (self.hour + (self.min + (self.sec - seconds) // 60) // 60) % 24

  return Time.of(hour, min, sec)
end

--- Compare two times for equality using == operator
--- @param time Time  The time to be compared
--- @return boolean
function Time:__eq(time)
  return self.hour == time.hour and self.min == time.min and self.sec == time.sec
end

--- Compare two time using < operator
--- @param time Time  The time to be compared
--- @return boolean
function Time:__lt(time)
  for _, field in ipairs({ "hour", "min", "sec" }) do
    if self[field] ~= time[field] then
      return self[field] < time[field]
    end
  end

  return false
end

--- Compare two time using <= operator
--- @param time Time  The time to be compared
--- @return boolean
function Time:__le(time)
  for _, field in ipairs({ "hour", "min", "sec" }) do
    if self[field] ~= time[field] then
      return self[field] <= time[field]
    end
  end

  return false
end

--- Convert a time to string using ISO Formatting. Intended use is debugging
--- @return string
function Time:__tostring()
  return self:format();
end

-----------------------------------------------------------



-------------------------- Utils --------------------------


--- Return the time according to the given format
--- @param format string?  Optional parameter that tells how the string should be formatted. The char 'h' is used to represent the hour (2 characters), 'm' the minute (2 characters) and 's' the second (2 characters). For exemple, a format 'h:m:s' generates a string of the type '20:30:13'. It uses this format as default.
--- @return string
function Time:format(format)
  local values = {
    h = string.format("%02d", self.hour),
    m = string.format("%02d", self.min),
    s = string.format("%02d", self.sec),
  }
  local str = (format or "h:m:s"):gsub("[hms]", values)
  return str
end

-----------------------------------------------------------


------------------------ Duration -------------------------

--- Return the duration between the two times in the given metric
--- @param time   Time            The Time to be compared with
--- @param metric "s"|"m"|"h"?    The metric to return the duration. "h" for hours, "m" for minutes and "s" for seconds
--- @return number
function Time:between(time, metric)
  metric = ((metric == "s" or metric == "m" or metric == "h") and metric) or
      "s";

  if metric == "s" then
    return (time.hour - self.hour) * 60 * 60 + (time.min - self.min) * 60 + (time.sec - self.sec)
  elseif metric == "m" then
    return (time.hour - self.hour) * 60 + (time.min - self.min)
  elseif metric == "h" then
    return time.hour - self.hour
  end
  error("Unsupported metric")
end

-----------------------------------------------------------


return Time
