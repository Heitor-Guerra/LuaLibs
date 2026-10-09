--- @class Date
--- An immutable Date with year, month and day.
--- The components can be read through `year`, `month` and `day`, but cannot be changed.
--- @field year integer         The year of the date. Can be any Gregorian year
--- @field month integer        The month of the date. Goes from 1 to 12
--- @field day integer          The day of the date. Goes from 1 to 31
local Date = {}
Date.__index = function(self, key)
  if key == "day" then
    return rawget(self, "_day")
  elseif key == "month" then
    return rawget(self, "_month")
  elseif key == "year" then
    return rawget(self, "_year")
  end
  return Date[key]
end
Date.__newindex = function(self, key, value)
  error("Date is immutable. Please create a new instance.")
end


local monthLength = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

local monthNames = { "January", "February", "March", "April", "May", "June", "July",
  "August", "September", "October", "November", "December" }

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
    day = date.day
  }
end

-------------------- Date Constructors --------------------

--- Return a date with the given values.
--- @param year   integer   The value of the year
--- @param month  integer   The value of the month
--- @param day    integer   The value of the day
--- @return Date
function Date.of(year, month, day)
  assert(math.type(year) == "integer" and year >= 1, "invalid year")
  assert(math.type(month) == "integer" and month >= 1 and month <= 12, "invalid month")
  assert(math.type(day) == "integer" and day >= 1 and day <= daysOnMonth(year, month), "invalid day")

  return setmetatable({
    _year = year,
    _month = month,
    _day = day,
  }, Date)
end

--- Return today's date, based on POSIX Epoch.
--- @return Date
function Date.now()
  local t = os.date("*t")

  return Date.of(t.year, t.month, t.day)
end

--- Parse a Date from the given String
--- @param dateString  string  The string to be converted into a date
--- @param format      string? Optional parameter that tells how the string should be parsed. The char 'D' is used to represent the day (2 characters), 'M' the month (2 characters) and 'Y' the year (4 characters). For exemple, a format 'Y-M-D' expects a string of the type '2026-05-20'. It uses this format as default.
--- @return Date
function Date.parse(dateString, format)
  format = (type(format) == "string" and format) or "Y-M-D"
  assert(type(dateString) == "string", "Invalid input for parse")
  local i = 1

  local year
  local month
  local day
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
  return Date.of(year, month, day)
end

-----------------------------------------------------------



------------------- Operations Overload -------------------

--- Add "days" amount of days to the Date.
--- @param days integer  The amount of days to be added to date
--- @return Date
function Date:__add(days)
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

  return Date.of(year, month, day)
end

--- Subtract "days" amount of days from Date.
--- @param days integer  The amount of days to be subbed to date
--- @return Date
function Date:__sub(days)
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

  return Date.of(year, month, day)
end

--- Compare two date for equality using == operator
--- @param date Date  The date to be compared
--- @return boolean
function Date:__eq(date)
  return self.day == date.day and self.month == date.month and self.year == date.year
end

--- Compare two date using < operator
--- @param date Date  The date to be compared
--- @return boolean
function Date:__lt(date)
  for _, field in ipairs({ "year", "month", "day" }) do
    if self[field] ~= date[field] then
      return self[field] < date[field]
    end
  end

  return false
end

--- Compare two date using <= operator
--- @param date Date  The date to be compared
--- @return boolean
function Date:__le(date)
  for _, field in ipairs({ "year", "month", "day" }) do
    if self[field] ~= date[field] then
      return self[field] <= date[field]
    end
  end

  return false
end

--- Convert a date to string using ISO Formatting. Intended use is debugging
--- @return string
function Date:__tostring()
  return self:format();
end

-----------------------------------------------------------



------------------------- Getters -------------------------

--- Return the day of the year on Date
--- @return integer
function Date:getDayOfYear()
  local total = 0
  for i = 1, self.month - 1 do
    total = total + daysOnMonth(self.year, i)
  end
  return total + self.day
end

--- Return the day of the week on Date. Day of week is represented as an integer from 1 to 7, where 1 is Sunday and 7 is Saturday
--- @return integer
function Date:getDayOfWeek()
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

--- Return the name of day of the week on Date. For exemple, it returns "Sunday", if the method getDayOfWeek returns 1.
--- @return string
function Date:getDayOfWeekName()
  return dayOfWeek[self:getDayOfWeek()]
end

--- Return the name of month on Date. For exemple, it returns "February", if the month is 2.
--- @return string
function Date:getMonthName()
  return monthNames[self.month]
end

--- Return the length of the year on Date
--- @return integer
function Date:lengthOfYear()
  return (self:isLeap() and 366) or 365
end

--- Return the length of a month on Date
--- @return integer
function Date:lengthOfMonth()
  return daysOnMonth(self.year, self.month)
end

-----------------------------------------------------------



-------------------------- Utils --------------------------

--- Return true if the date is leap. Otherwise, returns false.
--- @return boolean
function Date:isLeap()
  return isLeap(self.year)
end

--- Return the date according to the given format
--- @param format string?  Optional parameter that tells how the string should be formatted. The char 'D' is used to represent the day (2 characters), 'M' the month (2 characters) and 'Y' the year (4 characters). For exemple, a format 'Y-M-D' generates a string of the type '2026-05-20'. It uses this format as default.
--- @return string
function Date:format(format)
  local values = {
    D = string.format("%02d", self.day),
    M = string.format("%02d", self.month),
    Y = string.format("%04d", self.year),
  }
  local str = (format or "Y-M-D"):gsub("[DMY]", values)
  return str
end

-----------------------------------------------------------


------------------------ Duration -------------------------

--- Return the duration between the two dates in the given metric
--- @param date   Date                     The Date to be compared with
--- @param metric "s"|"m"|"h"|"D"|"M"|"Y"? The metric to return the duration. "Y" for year, "M" for months, "D" for days, "h" for hours, "m" for minutes and "s" for seconds
--- @return number
function Date:between(date, metric)
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


return Date
