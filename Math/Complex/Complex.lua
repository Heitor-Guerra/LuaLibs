--- @class Complex
--- An immutable complex number with real and imaginary components.
--- The components can be read through `real` and `imaginary`, but cannot be changed.
--- @field real number
--- @field imaginary number
Complex = {}
Complex.__index = function(self, key)
  if key == "real" then
    return rawget(self, "_real")
  elseif key == "imaginary" then
    return rawget(self, "_imaginary")
  end
  return Complex[key]
end
Complex.__newindex = function(self, key, value)
  error("Complex is immutable. Please create a new instance.")
end


------------------- Complex Constructor -------------------

--- Create a new Complex object
--- @param real number      The real component
--- @param imaginary number The imaginary component
--- @return Complex
function Complex:new(real, imaginary)
  return setmetatable({
    _real = real,
    _imaginary = imaginary,
  }, self);
end

-----------------------------------------------------------


------------------- Operations Overload -------------------

--- Add a number or another complex number to this complex number
--- @param num Complex | number   The value to add
--- @return Complex
function Complex:__add(num)
  if type(num) == "number" then
    return Complex:new(self.real + num, self.imaginary);
  end
  return Complex:new(self.real + num.real, self.imaginary + num.imaginary);
end

--- Subtract a number or another complex number from this complex number
--- @param num Complex | number  The value to subtract
--- @return Complex
function Complex:__sub(num)
  if type(num) == "number" then
    return Complex:new(self.real - num, self.imaginary);
  end
  return Complex:new(self.real - num.real, self.imaginary - num.imaginary);
end

--- Negate this complex number
--- @return Complex
function Complex:__unm()
  return Complex:new(-self.real, -self.imaginary);
end

--- Divide this complex number by a number or another complex number
--- @param num Complex|number  The divisor
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

--- Multiply this complex number by a number or another complex number
--- @param num Complex|number  The value to multiply by
--- @return Complex
function Complex:__mul(num)
  if type(num) == "number" then
    return Complex:new(self.real * num, self.imaginary * num);
  end
  local realPart = (self.real * num.real - self.imaginary * num.imaginary);
  local imPart = (self.imaginary * num.real + self.real * num.imaginary);
  return Complex:new(realPart, imPart);
end

--- Compare this complex number's modulus with a number or another complex number's modulus
--- @param num Complex|number  The value to compare with
--- @return boolean
function Complex:__lt(num)
  if type(num) == "number" then
    return self:modulus() < num;
  end
  return self:modulus() < num:modulus();
end

--- Compare whether this complex number's modulus is less than or equal to a value
--- @param num Complex|number  The value to compare with
--- @return boolean
function Complex:__le(num)
  if type(num) == "number" then
    return self:modulus() <= num;
  end
  return self:modulus() <= num:modulus();
end

--- Test whether this complex number equals a number or another complex number
--- @param num Complex|number  The value to compare with
--- @return boolean
function Complex:__eq(num)
  if type(num) == "number" then
    return self.real == num and self.imaginary == 0;
  end
  return self.real == num.real and self.imaginary == num.imaginary;
end

-----------------------------------------------------------


-------------------------- Utils --------------------------

--- Return the modulus (magnitude) of the complex number
--- @return number
function Complex:modulus()
  return math.sqrt(self.real ^ 2 + self.imaginary ^ 2);
end

--- Return the phase of the complex number
--- @return number
function Complex:phase()
  if self.real == 0 then
    return math.pi / 2
  end
  return math.atan(self.imaginary / self.real);
end

--- Return the complex conjugate, with the imaginary component negated
--- @return Complex
function Complex:conjugate()
  return Complex:new(self.real, -self.imaginary);
end

--- Return the complex exponential, e^z, where z is this complex number
--- @return Complex
function Complex:exp()
  return Complex:new(math.exp(self.real) * math.cos(self.imaginary), math.exp(self.real) * math.sin(self.imaginary));
end

--- @return string
function Complex:__tostring()
  return string.format("%g + %gi", self.real, self.imaginary);
end

-----------------------------------------------------------


return Complex
