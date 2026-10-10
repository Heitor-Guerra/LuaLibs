--- @class Deque
--- A container class that represents a Deque, a double-ended queue data structure
--- @field private data table<any>
Deque = {}
Deque.__index = function(self, key)
    if type(key) == "number" then
        return rawget(self, "_data")[key]
    elseif key == "data" then
        return rawget(self, "_data")
    end
    return Deque[key]
end
Deque.__newindex = function(self, key, value)
    if type(key) == "number" then
        self.data[key] = value
    else
        error("Deque can't be modified. Please use the apropriate push, pop and front.")
    end
end


-------------------- Deque Constructor --------------------

--- Create a new Deque object
--- @return Deque
function Deque.new()
    return setmetatable({
        _data = {},
    }, Deque);
end

-----------------------------------------------------------



-------------------------- Utils --------------------------

--- Returns the size of the Deque. To be used by # operator
--- @return number
function Deque:__len()
    return #self.data
end

--- Returns `true` if the Deque is empty. `false` otherwise
--- @return boolean
function Deque:empty()
    return #self == 0
end

--- Push an element on back of Deque
--- @param element any
function Deque:push_back(element)
    table.insert(self.data, element)
end

--- Pop an element from back of Deque
--- @return any  element element from the back of Deque
function Deque:pop_back()
    return table.remove(self.data)
end

--- Push an element on front of Deque
--- @param element any
function Deque:push_front(element)
    table.insert(self.data, 1, element)
end

--- Pop an element from front of Deque
--- @return any  element element from the top of Deque
function Deque:pop_front()
    return table.remove(self.data, 1)
end

--- Return the element on front of Deque
--- @return any  element element from the front of Deque
function Deque:front()
    return self.data[1]
end

--- Return the element on back of Deque
--- @return any  element element from the back of Deque
function Deque:back()
    return self.data[#self]
end

--- Remove all elements from Deque
function Deque:clear()
    self.data = {}
end

-----------------------------------------------------------


return Deque
