--- @class Complex
--- @field private real number
--- @field private imaginary number
Complex = {}
Complex.__index = function(self, key)
  if key == "real" then
    return rawget(self, "_real")
  elseif key == "imaginary" then
    return rawget(self, "_imaginary")
  end
  return Complex[key]
end

--- Creates a new Complex Object
--- @param real number
--- @param imaginary number
--- @return Complex
function Complex:new(real, imaginary)
  return setmetatable({
    _real = real,
    _imaginary = imaginary,
  }, self);
end

--- @return string
function Complex:__name()
  return "Complex";
end

--- Returns the modulus of the complex number
--- @return number
function Complex:modulus()
  return math.sqrt(self.real ^ 2 + self.imaginary ^ 2);
end

--- Returns the conjugate of the complex number
--- @return Complex
function Complex:conjugate()
  return Complex:new(self.real, -self.imaginary);
end

--- Returns the complex originated from e^x, where x is this number
--- @return Complex
function Complex:exp()
  return Complex:new(math.exp(self.real) * math.cos(self.imaginary), math.exp(self.real) * math.sin(self.imaginary));
end

--- @param num Complex | number
--- @return Complex
function Complex:__add(num)
  if type(num) == "number" then
    return Complex:new(self.real + num, self.imaginary);
  end
  return Complex:new(self.real + num.real, self.imaginary + num.imaginary);
end

--- @param num Complex
--- @return Complex
function Complex:__sub(num)
  if type(num) == "number" then
    return Complex:new(self.real - num, self.imaginary);
  end
  return Complex:new(self.real - num.real, self.imaginary - num.imaginary);
end

--- @return Complex
function Complex:__unm()
  return Complex:new(-self.real, -self.imaginary);
end

--- @param num Complex
--- @return Complex
function Complex:__div(num)
  if type(num) == "number" then
    return Complex:new(self.real / num, self.imaginary / num);
  end

  if num.real == 0 and num.imaginary == 0 then
    error("Denominator is zero");
  end

  local realPart = (self.real * num.real + self.imaginary * num.imaginary) /
      (num.real ^ 2 + num.imaginary ^ 2);
  local imPart = (self.imaginary * num.real - self.real * num.imaginary) /
      (num.real ^ 2 + num.imaginary ^ 2);
  return Complex:new(realPart, imPart);
end

--- @param num Complex
--- @return Complex
function Complex:__mul(num)
  if type(num) == "number" then
    return Complex:new(self.real * num, self.imaginary * num);
  end
  local realPart = (self.real * num.real - self.imaginary * num.imaginary);
  local imPart = (self.imaginary * num.real + self.real * num.imaginary);
  return Complex:new(realPart, imPart);
end

--- @param num Complex
--- @return boolean
function Complex:__lt(num)
  if type(num) == "number" then
    return self:modulus() < num;
  end
  return self:modulus() < num:modulus();
end

--- @param num Complex
--- @return boolean
function Complex:__le(num)
  if type(num) == "number" then
    return self:modulus() <= num;
  end
  return self:modulus() <= num:modulus();
end

--- @param num Complex
--- @return boolean
function Complex:__gt(num)
  if type(num) == "number" then
    return self:modulus() > num;
  end
  return self:modulus() > num:modulus();
end

--- @param num Complex
--- @return boolean
function Complex:__ge(num)
  if type(num) == "number" then
    return self:modulus() >= num;
  end
  return self:modulus() >= num:modulus();
end

--- @param num Complex
--- @return boolean
function Complex:__eq(num)
  if type(num) == "number" then
    return self.real == num and self.imaginary == 0;
  end
  return self.real == num.real and self.imaginary == num.imaginary;
end

--- @return string
function Complex:__tostring()
  return string.format("%g %gi", self.real, self.imaginary);
end

return Complex
