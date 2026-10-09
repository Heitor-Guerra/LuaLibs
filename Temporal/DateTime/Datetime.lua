--- @class DateTime
--- @field year  integer              The year of the date. Can be any Gregorian year
--- @field month integer              The month of the date. Goes from 1 to 12
--- @field day   integer              The day of the date. Goes from 1 to 31
--- @field hour  integer              The hour of the date. Goes from 0 to 23
--- @field min   integer              The minute of the date. Goes from 0 to 59
--- @field sec   integer              The second of the date. Goes from 0 to 59
local DateTime = {}
DateTime.__index = function(self, key)
  if key == "day" then
    return rawget(self, "_day")
  elseif key == "month" then
    return rawget(self, "_month")
  elseif key == "year" then
    return rawget(self, "_year")
  elseif key == "hour" then
    return rawget(self, "_hour")
  elseif key == "min" then
    return rawget(self, "_min")
  elseif key == "sec" then
    return rawget(self, "_sec")
  end
  return DateTime[key]
end
DateTime.__newindex = function(self, key, value)
  error("DateTime is immutable. Please create a new instance.")
end


local monthLength = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
local monthNames = { "January", "February", "March", "April", "May", "June",
  "July", "August", "September", "October", "November", "December" }
local dayOfWeek = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }


local function isLeap(year)
  return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
end

local function daysOnMonth(year, month)
  return (isLeap(year) and month == 2) and monthLength[month] + 1 or monthLength[month]
end

local function toOsDateParam(date)
  return {
    year = date.year,
    month = date.month,
    day = date.day,
    hour = date.hour,
    min = date.min,
    sec = date.sec
  }
end


-------------------- DateTime Constructors --------------------

--- Return a date with the given values. The tiome parameters are optional
--- @param year   integer   The value of the year
--- @param month  integer   The value of the month
--- @param day    integer   The value of the day
--- @param hour   integer?  The optional value of the hour. Default is 0
--- @param minute integer?  The optional value of the minute. Default is 0
--- @param second integer?  The optional value of the second. Default is 0
--- @return DateTime
function DateTime.of(year, month, day, hour, minute, second)
  hour = hour or 0
  minute = minute or 0
  second = second or 0
  assert(math.type(year) == "integer" and year >= 1, "invalid year")
  assert(math.type(month) == "integer" and month >= 1 and month <= 12, "invalid month")
  assert(math.type(day) == "integer" and day >= 1 and day <= daysOnMonth(year, month), "invalid day")
  assert(math.type(hour) == "integer" and hour >= 0 and hour < 24, "invalid hour")
  assert(math.type(minute) == "integer" and minute >= 0 and minute < 60, "invalid minute")
  assert(math.type(second) == "integer" and second >= 0 and second < 60, "invalid second")

  return setmetatable({
    _year = year,
    _month = month,
    _day = day,
    _hour = hour,
    _min = minute,
    _sec = second
  }, DateTime)
end

--- Return today's date and time, based on POSIX Epoch.
--- @return DateTime
function DateTime.now()
  local t = os.date("*t")

  return DateTime.of(t.year, t.month, t.day, t.hour, t.min, t.sec)
end

--- Parse a DateTime from the given String
--- @param dateString  string  The string to be converted into a date
--- @param format      string? Optional parameter that tells how the string should be parsed. The char 'D' is used to represent the day (2 characters), 'M' the month (2 characters), 'Y' the year (4 characters), 'h' the hour (2 characters), 'm' the minute (2 characters) and 's' the second (2 characters) . For exemple, a format 'y-m-dTh:m:s' expects a string of the type '2026-05-20T06:21:12'. It uses this format as default.
--- @return DateTime
function DateTime.parse(dateString, format)
  format = (type(format) == "string" and format) or "Y-M-DTh:m:s"
  assert(type(dateString) == "string", "Invalid input for parse")


  local i = 1

  local year
  local month
  local day
  local hour
  local minute
  local second
  for c in format:gmatch('.') do
    if c == 'D' then
      day = tonumber(dateString:sub(i, i + 1))
      i = i + 2
    elseif c == 'M' then
      month = tonumber(dateString:sub(i, i + 1))
      i = i + 2
    elseif c == 'Y' then
      year = tonumber(dateString:sub(i, i + 3))
      i = i + 4
    elseif c == 'h' then
      hour = tonumber(dateString:sub(i, i + 1))
      i = i + 2
    elseif c == 'm' then
      minute = tonumber(dateString:sub(i, i + 1))
      i = i + 2
    elseif c == 's' then
      second = tonumber(dateString:sub(i, i + 1))
      i = i + 2
    else
      if dateString:byte(i) ~= c:byte(1) then
        error("Wrong input for format")
      end
      i = i + 1
    end
  end
  --- @cast year integer
  --- @cast month integer
  --- @cast day integer
  --- @cast hour integer
  --- @cast minute integer
  --- @cast second integer
  return DateTime.of(year, month, day, hour, minute, second)
end

-----------------------------------------------------------



------------------- Operations Overload -------------------

--- Add "days" amount of days to the DateTime.
--- @param days integer  The amount of days to be added to date
--- @return DateTime
function DateTime:__add(days)
  assert(math.type(days) == "integer", "invalid day")

  local day = self.day + days
  local month = self.month
  local year = self.year

  while day > daysOnMonth(year, month) do
    day = day - daysOnMonth(year, month)
    month = month + 1
    if month > 12 then
      month = month - 12
      year = year + 1
    end
  end

  return DateTime(year, month, day)
end

--- Subtract "days" amount of days from DateTime.
--- @param days integer  The amount of days to be subbed to date
--- @return DateTime
function DateTime:__sub(days)
  assert(math.type(days) == "integer", "invalid day")

  local day = self.day - days
  local month = self.month
  local year = self.year

  while day < 1 do
    month = month - 1
    if month < 1 then
      month = month + 12
      year = year - 1
    end

    day = day + daysOnMonth(year, month)
  end

  return DateTime(year, month, day)
end

--- Compare two dateTimes for equality using == operator
--- @param date DateTime  The date to be compared
--- @return boolean
function DateTime:__eq(date)
  return self.day == date.day and self.month == date.month and self.year == date.year and self.hour == date.hour and
      self.min == date.min and self.sec == date.sec
end

--- Compare two dateTimes using < operator
--- @param date DateTime  The date to be compared
--- @return boolean
function DateTime:__lt(date)
  for _, field in ipairs({ "year", "month", "day", "hour", "min", "sec" }) do
    if self[field] ~= date[field] then
      return self[field] < date[field]
    end
  end

  return false
end

--- Compare two dateTimes using <= operator
--- @param date DateTime  The date to be compared
--- @return boolean
function DateTime:__le(date)
  for _, field in ipairs({ "year", "month", "day", "hour", "min", "sec" }) do
    if self[field] ~= date[field] then
      return self[field] <= date[field]
    end
  end

  return false
end

-----------------------------------------------------------



------------------------- Getters -------------------------

--- Return the day of the year on DateTime
--- @return integer
function DateTime:getDayOfYear()
  local total = 0
  for i = 1, self.month - 1 do
    total = total + daysOnMonth(self.year, i)
  end
  return total + self.day
end

--- Return the day of the week on DateTime. Day of week is represented as an integer from 1 to 7, where 1 is Sunday and 7 is Saturday
--- @return integer
function DateTime:getDayOfWeek()
  local q = self.day
  local m = self.month
  local y = self.year

  if m < 3 then
    m = m + 12
    y = y - 1
  end

  local h = (q
    + math.floor(13 * (m + 1) / 5)
    + y
    + math.floor(y / 4)
    - math.floor(y / 100)
    + math.floor(y / 400)) % 7

  return ((h + 6) % 7) + 1
end

--- Return the name of day of the week on DateTime. For exemple, it returns "Sunday", if the method getDayOfWeek returns 1.
--- @return string
function DateTime:getDayOfWeekName()
  return dayOfWeek[self:getDayOfWeek()]
end

--- Return the name of month on DateTime. For exemple, it returns "February", if the month is 2.
--- @return string
function DateTime:getMonthName()
  return monthNames[self.month]
end

--- Return the length of the year on DateTime
--- @return integer
function DateTime:lengthOfYear()
  return (self:isLeap() and 366) or 365
end

--- Return the length of a month on DateTime
--- @return integer
function DateTime:lengthOfMonth()
  return daysOnMonth(self.year, self.month)
end

-----------------------------------------------------------



-------------------------- Utils --------------------------


--- Return true if the date is leap. Otherwise, returns false.
--- @return boolean
function DateTime:isLeap()
  return isLeap(self.year)
end

--- Return the date according to the given format
--- @param format string?  Optional parameter that tells how the string should be formatted. The char 'D' is used to represent the day (2 characters), 'M' the month (2 characters), 'Y' the year (4 characters), 'h' the hour (2 characters), 'm' the minute (2 characters) and 's' the second (2 characters). For exemple, a format 'Y-M-DTh:m:s' generates a string of the type '2026-05-20T20:30:13'. It uses this format as default.
--- @return string
function DateTime:format(format)
  local values = {
    D = string.format("%02d", self.day),
    M = string.format("%02d", self.month),
    Y = string.format("%04d", self.year),
    h = string.format("%02d", self.hour),
    m = string.format("%02d", self.min),
    s = string.format("%02d", self.sec),
  }
  local str = (format or "Y-M-DTh:m:s"):gsub("[DMYhms]", values)
  return str
end

-----------------------------------------------------------


------------------------ Duration -------------------------

--- Return the duration between the two dates in the given metric
--- @param date   DateTime                 The DateTime to be compared with
--- @param metric "s"|"m"|"h"|"D"|"M"|"Y"? The metric to return the duration. "Y" for year, "M" for months, "D" for days, "h" for hours, "m" for minutes and "s" for seconds
--- @return number
function DateTime:between(date, metric)
  metric = ((metric == "s" or metric == "m" or metric == "h" or metric == "D" or metric == "M" or metric == "Y") and metric) or
      "s";
  local time1 = os.time(toOsDateParam(self))
  local time2 = os.time(toOsDateParam(date))
  local diff = time2 - time1

  if metric == "s" then
    return diff
  elseif metric == "m" then
    return diff // 60
  elseif metric == "h" then
    return diff // (60 * 60)
  elseif metric == "D" then
    return diff // (60 * 60 * 24)
  elseif metric == "M" then
    return 12 * (date.year - self.year) + (date.month - self.month)
  elseif metric == "Y" then
    return date.year - self.year
  end
  error("Unsupported metric")
end

-----------------------------------------------------------


return DateTime
