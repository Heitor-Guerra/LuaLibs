--- @class Heap
--- A container class that represents a Heap, a balanced binary-tree-like container whose root is the max value.
--- The user might create the heap with a compare function, in which case it can decide how it works. If none is given,
--- it will order the elements by the usage of >
--- @field private data table
--- @field private _cmp? fun(a: any, b: any): boolean
Heap = {}
Heap.__index = function(self, key)
    if key == "data" then
        return rawget(self, "_data")
    end
    return Heap[key]
end
Heap.__newindex = function(self, key, value)
    error("Heap can't be modified directly. Please use the apropriate push, pop and front.")
end


-------------------- Heap Constructor ---------------------

--- Create a new Heap object
--- @param cmp? fun(a: any, b: any): boolean The function that compares two heap members. By default, it uses the operator >
--- @return Heap
function Heap.new(cmp)
    return setmetatable({
        _data = {},
        _cmp = cmp,
    }, Heap);
end

-----------------------------------------------------------



-------------------------- Utils --------------------------

--- Returns the size of the Heap. To be used by # operator
--- @return number
function Heap:__len()
    return #self.data
end

--- Compares two heap elements and returns `true` if the element in pos1 should be higher than the element in pos2
--- @return boolean
function Heap:compare(pos1, pos2)
    if self._cmp then
        return self._cmp(self.data[pos1], self.data[pos2])
    else
        return self.data[pos1] > self.data[pos2]
    end
end

--- Push an element on Heap
--- @param element any
function Heap:push(element)
    --- Propagate the element up in to the list
    --- @param i integer current position
    local function heapifyUp(i)
        if i == 1 then
            return
        end
        local parent = i // 2
        if self:compare(i, parent) then
            self.data[i], self.data[parent] = self.data[parent], self.data[i]
            heapifyUp(parent)
        end
    end

    table.insert(self.data, element)
    heapifyUp(#self)
end

--- Pop the max element from Heap
--- @return any  element max element from Heap
function Heap:pop()
    --- Propagate the element down the list
    --- @param i integer current position
    local function heapifyDown(i)
        local childLeft = i * 2
        local childRight = i * 2 + 1

        local max = i
        if self.data[childLeft] and self:compare(childLeft, max) then
            max = childLeft
        end

        if self.data[childRight] and self:compare(childRight, max) then
            max = childRight
        end

        if max ~= i then
            self.data[i], self.data[max] = self.data[max], self.data[i]
            heapifyDown(max)
        end
    end

    self.data[#self], self.data[1] = self.data[1], self.data[#self]
    local element = table.remove(self.data)
    heapifyDown(1)

    return element
end

--- Return the element on root of Heap
--- @return any  element element from the root of Heap
function Heap:root()
    return self.data[1]
end

--- Returns `true` if the Heap is empty. `false` otherwise
--- @return boolean
function Heap:empty()
    return #self == 0
end

-----------------------------------------------------------


return Heap
