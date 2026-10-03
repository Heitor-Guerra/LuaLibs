--- @class (exact) Date
--- @field private year integer  The year of the date. Can be any positive number
--- @field private month integer The month of the date. Goes from 1 to 12
--- @field private day integer   The day of the date. Goes from 1 to 31
Date = {}
function Date:__index(key)
  if key == "year" or key == "month" or key == "day" then
    return rawget(self, "_" .. key)
  else
    error("Field " .. key .. " does not exist on Date.")
  end
end

--- Return a date with the given values.
--- @param year integer
--- @param month integer
--- @param day integer
--- @return Date
function Date:__call(year, month, day)
  return setmetatable({
    year = year,
    month = month,
    day = day,
  }, self)
end

--- Return today's date, based on POSIX Epoch.
--- @return Date
function Date:now()
  local time = os.time()

  return setmetatable({
    year = 1970 + time // (60 * 60 * 24 * 365.25),
    month = 1 + (time // (60 * 60 * 24 * 30.437)) % 12,
    day = 1 + (time // (60 * 60 * 24)) % 30,
  }, self)
end

function Date:isLeap()
  return self.year % 4 == 0 and (self.year % 100 ~= 0 or self.year % 400 == 0)
end
