--- @class Queue
--- A container class that represents a Queue, a FIFO (first-in, first-out) data structure
--- @field private data table
Queue = {}
Queue.__index = function(self, key)
    if key == "data" then
        return rawget(self, "_data")
    end
    return Queue[key]
end
Queue.__newindex = function(self, key, value)
    error("Queue can't be modified. Please use the apropriate push, pop and front.")
end


-------------------- Queue Constructor --------------------

--- Create a new Queue object
--- @return Queue
function Queue.new()
    return setmetatable({
        _data = {},
    }, Queue);
end

-----------------------------------------------------------



-------------------------- Utils --------------------------

--- Returns the size of the Queue. To be used by # operator
--- @return number
function Queue:__len()
    return #self.data
end

--- Returns `true` if the Queue is empty. `false` otherwise
--- @return boolean
function Queue:empty()
    return #self == 0
end

--- Push an element on back of Queue
--- @param element any
function Queue:push(element)
    table.insert(self.data, element)
end

--- Pop an element from front of Queue
--- @return any  element element from the front of Queue
function Queue:pop()
    return table.remove(self.data, 1)
end

--- Return the element on front of Queue
--- @return any  element element from the front of Queue
function Queue:front()
    return self.data[1]
end

--- Return the element on back of Queue
--- @return any  element element from the back of Queue
function Queue:back()
    return self.data[#self]
end

-----------------------------------------------------------


return Queue
