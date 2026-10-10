--- @class Stack
--- A container class that represents a Stack, a LIFO (last-in, first-out) data structure
--- @field private data table
Stack = {}
Stack.__index = function(self, key)
    if key == "data" then
        return rawget(self, "_data")
    end
    return Stack[key]
end
Stack.__newindex = function(self, key, value)
    error("Stack can't be modified. Please use the apropriate push, pop and top.")
end


-------------------- Stack Constructor --------------------

--- Create a new Stack object
--- @return Stack
function Stack.new()
    return setmetatable({
        _data = {},
    }, Stack);
end

-----------------------------------------------------------



-------------------------- Utils --------------------------

--- Returns the size of the Stack. To be used by # operator
--- @return number
function Stack:__len()
    return #self.data
end

--- Returns `true` if the Stack is empty. `false` otherwise
--- @return boolean
function Stack:empty()
    return #self == 0
end

--- Push an element on top of Stack
--- @param element any
function Stack:push(element)
    table.insert(self.data, element)
end

--- Pop an element from top of Stack
--- @return any  element element from the top of Stack
function Stack:pop()
    return table.remove(self.data)
end

--- Return the element on top of Stack
--- @return any  element element from the top of Stack
function Stack:top()
    return self.data[#self]
end

-----------------------------------------------------------


return Stack
