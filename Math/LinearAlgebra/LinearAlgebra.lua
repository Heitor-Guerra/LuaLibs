local LinearAlgebra = {}

------------------------- Matrix --------------------------

--- @class Matrix
--- A class that represents a two-dimensional matrix of numbers.
--- @field private data table<table<number>>  The matrix entries, indexed by row and column.
--- @field rows number                        The number of rows in the matrix.
--- @field cols number                        The number of columns in the matrix.
local Matrix = {}
Matrix.__index = function(self, key)
    if key == "cols" then
        return rawget(self, "_cols")
    elseif key == "rows" then
        return rawget(self, "_rows")
    elseif key == "data" then
        return rawget(self, "_data")
    elseif type(key) == "number" then
        return rawget(self.data, key)
    else
        return rawget(Matrix, key)
    end
end
--- @type Matrix
LinearAlgebra.Matrix = Matrix


--------------------- Local Functions ---------------------

--- Assert that two matrices have identical dimensions.
--- @param a Matrix The first matrix.
--- @param b Matrix The second matrix.
local function checkSameShape(a, b)
    assert(a.rows == b.rows and a.cols == b.cols, "Matrices must have the same dimensions")
end

-----------------------------------------------------------



------------------- Matrix Constructors -------------------

--- Create a matrix from a rectangular, non-empty two-dimensional array.
--- The input data is copied.
--- @param data table<table<number>> A non-empty array of equally sized rows containing numbers.
--- @return Matrix
function Matrix.new(data)
    assert(type(data) == "table" and #data > 0, "Matrix data must be a non-empty array of rows")

    local rows = #data
    local cols = #data[1]

    local copy = {}

    for i = 1, rows do
        copy[i] = {}
        for j = 1, cols do
            assert(type(data[i][j]) == "number", "Matrix entries must be numbers")
            copy[i][j] = data[i][j]
        end
    end

    return setmetatable({
        _rows = rows,
        _cols = cols,
        _data = copy,
    }, Matrix)
end

--- Create an identity matrix of the specified size.
--- @param size number  The number of rows and columns. Must be positive.
--- @return Matrix
function Matrix.identity(size)
    local data = {}
    for i = 1, size do
        data[i] = {}
        for j = 1, size do
            data[i][j] = (i == j) and 1 or 0
        end
    end

    return Matrix.new(data)
end

--- Create an identity matrix with the same dimensions as a square matrix.
--- @param mat Matrix   The reference matrix. Must be square.
--- @return Matrix
function Matrix.identityLike(mat)
    assert(mat.cols == mat.rows, "Reference matrix must be square")
    return Matrix.identity(mat.rows)
end

--- Create a matrix filled with zeros.
--- @param rows number  The number of rows.
--- @param cols number  The number of columns.
--- @return Matrix
function Matrix.zeros(rows, cols)
    local data = {}
    for i = 1, rows do
        data[i] = {}
        for j = 1, cols do
            data[i][j] = 0
        end
    end

    return Matrix.new(data)
end

--- Create a zero matrix with the same dimensions as another matrix.
--- @param mat Matrix   The reference matrix.
--- @return Matrix
function Matrix.zerosLike(mat)
    return Matrix.zeros(mat.rows, mat.cols)
end

--- Create a matrix filled with ones.
--- @param rows number The number of rows.
--- @param cols number The number of columns.
--- @return Matrix
function Matrix.ones(rows, cols)
    local data = {}
    for i = 1, rows do
        data[i] = {}
        for j = 1, cols do
            data[i][j] = 1
        end
    end

    return Matrix.new(data)
end

--- Create a matrix of ones with the same dimensions as another matrix.
--- @param mat Matrix   The reference matrix.
--- @return Matrix
function Matrix.onesLike(mat)
    return Matrix.ones(mat.rows, mat.cols)
end

-----------------------------------------------------------



------------------- Operations Overload -------------------

--- Add a number or another matrix to this matrix.
--- When b is a number, it is added to every entry.
--- When b is a matrix, corresponding entries are added element-wise.
--- @param b Matrix | number     The scalar or matrix to add.
--- @return Matrix
function Matrix:__add(b)
    if type(b) == "number" then
        local data = {}
        for i = 1, self.rows do
            data[i] = {}
            for j = 1, self.cols do
                data[i][j] = self.data[i][j] + b
            end
        end
        return Matrix.new(data)
    end

    checkSameShape(self, b)
    local data = {}
    for i = 1, self.rows do
        data[i] = {}
        for j = 1, self.cols do
            data[i][j] = self.data[i][j] + b.data[i][j]
        end
    end
    return Matrix.new(data)
end

--- Subtract a number or another matrix from this matrix.
--- When b is a number, it is subtracted from every entry.
--- When b is a matrix, corresponding entries are subtracted element-wise.
--- @param b Matrix | number    The scalar or matrix to subtract.
--- @return Matrix
function Matrix:__sub(b)
    if type(b) == "number" then
        local data = {}
        for i = 1, self.rows do
            data[i] = {}
            for j = 1, self.cols do
                data[i][j] = self.data[i][j] - b
            end
        end
        return Matrix.new(data)
    end

    checkSameShape(self, b)
    local data = {}
    for i = 1, self.rows do
        data[i] = {}
        for j = 1, self.cols do
            data[i][j] = self.data[i][j] - b.data[i][j]
        end
    end
    return Matrix.new(data)
end

--- Negate every entry in this matrix.
--- @return Matrix
function Matrix:__unm()
    return self * -1
end

--- Multiply this matrix by a number or another matrix.
--- Scalar multiplication multiplies every entry by b.
--- Matrix multiplication uses the standard row-by-column product.
--- @param b Matrix | number  The scalar or right-hand matrix.
--- @return Matrix
function Matrix:__mul(b)
    if type(b) == "number" then
        local data = {}
        for i = 1, self.rows do
            data[i] = {}
            for j = 1, self.cols do
                data[i][j] = self.data[i][j] * b
            end
        end
        return Matrix.new(data)
    end

    assert(self.cols == b.rows, "Left matrix columns must match right matrix rows")

    local data = {}
    for i = 1, self.rows do
        data[i] = {}
        for j = 1, b.cols do
            local sum = 0
            for k = 1, self.cols do
                sum = sum + self.data[i][k] * b.data[k][j]
            end
            data[i][j] = sum
        end
    end
    return Matrix.new(data)
end

--- Divide every entry in this matrix by a scalar.
--- @param b number   The divisor. Must not be zero.
--- @return Matrix
function Matrix:__div(b)
    assert(type(b) == "number", "A matrix can only be divided by a number")
    assert(b ~= 0, "A matrix can't be divided by 0")

    local data = {}
    for i = 1, self.rows do
        data[i] = {}
        for j = 1, self.cols do
            data[i][j] = self.data[i][j] / b
        end
    end
    return Matrix.new(data)
end

-----------------------------------------------------------



-------------------- Other Operations ---------------------

--- Transpose this matrix by exchanging its rows and columns.
--- @return Matrix
function Matrix:transpose()
    local data = {}
    for i = 1, self.cols do
        data[i] = {}
        for j = 1, self.rows do
            data[i][j] = self.data[j][i]
        end
    end
    return Matrix.new(data)
end

--- Calculate the determinant of this square matrix.
--- The determinant is computed using Gaussian elimination. The original matrix is not modified.
--- @return number
function Matrix:determinant()
    assert(self.rows == self.cols, "Determinant requires a square matrix")

    local n = self.rows
    local a = {}
    local tolerance = 2e-15 * n

    for i = 1, n do
        a[i] = {}
        for j = 1, n do
            a[i][j] = self.data[i][j]
        end
    end

    local det = 1

    for col = 1, n do
        local pivotRow = col
        local largest = math.abs(a[col][col])

        for i = col + 1, n do
            local value = math.abs(a[i][col])
            if value > largest then
                largest = value
                pivotRow = i
            end
        end

        if largest <= tolerance then
            return 0
        end

        if pivotRow ~= col then
            a[col], a[pivotRow] = a[pivotRow], a[col]
            det = -det
        end

        local pivot = a[col][col]
        det = det * pivot

        for i = col + 1, n do
            local factor = a[i][col] / pivot
            for j = col + 1, n do
                a[i][j] = a[i][j] - factor * a[col][j]
            end
        end
    end

    return det
end

--- Calculate the inverse of this square matrix.
--- @return Matrix
function Matrix:inverse()
    assert(self.rows == self.cols, "Inverse requires a square matrix")

    local n = self.rows
    local a = {}
    local tolerance = 2e-15 * n

    for i = 1, n do
        a[i] = {}
        for j = 1, n do
            a[i][j] = self.data[i][j]
            a[i][n + j] = (i == j) and 1 or 0
        end
    end

    for col = 1, n do
        local pivotRow = col
        local largest = math.abs(a[col][col])

        for i = col + 1, n do
            local value = math.abs(a[i][col])
            if value > largest then
                largest = value
                pivotRow = i
            end
        end

        if largest <= tolerance then
            error("Matrix is singular or numerically singular")
        end

        if pivotRow ~= col then
            a[col], a[pivotRow] = a[pivotRow], a[col]
        end

        local pivot = a[col][col]
        for j = 1, 2 * n do
            a[col][j] = a[col][j] / pivot
        end

        for i = 1, n do
            if i ~= col then
                local factor = a[i][col]
                for j = 1, 2 * n do
                    a[i][j] = a[i][j] - factor * a[col][j]
                end
            end
        end
    end

    local inverseData = {}
    for i = 1, n do
        inverseData[i] = {}
        for j = 1, n do
            inverseData[i][j] = a[i][n + j]
        end
    end

    return Matrix.new(inverseData)
end

-----------------------------------------------------------

-----------------------------------------------------------





------------------------- Vector --------------------------

--- @class Vector
--- A class that represents a one-dimensional vector of numbers.
--- @field data table<number> The vector components, indexed by position.
local Vector = {}
Vector.__index = function(self, key)
    if key == "data" then
        return rawget(self, "_data")
    elseif type(key) == "number" then
        return rawget(self.data, key)
    else
        return rawget(Vector, key)
    end
end
--- @type Vector
LinearAlgebra.Vector = Vector


--------------------- Local Functions ---------------------

--- Assert that two vectors have the same number of components.
--- @param a Vector The first vector.
--- @param b Vector The second vector.
local function checkSameLength(a, b)
    assert(#a.data == #b.data, "Vectors must have the same length")
end

-----------------------------------------------------------



------------------- Vector Constructors -------------------

--- Create a vector from a non-empty array of numbers.
--- The input array is copied.
--- @param values table<number>   A non-empty array containing numeric components.
--- @return Vector
function Vector.new(values)
    assert(type(values) == "table" and #values > 0, "Vector data must be a non-empty array")

    local copy = {}
    for i = 1, #values do
        assert(type(values[i]) == "number", "Vector entries must be numbers")
        copy[i] = values[i]
    end

    return setmetatable({ _data = copy }, Vector)
end

--- Create a unit vector along a specified axis.
--- The vector has value of 1 at the specified axis and 0 at every other position.
--- @param n number     The dimension of the vector. Must be a positive integer.
--- @param axis number  The axis along which the unit vector points, between 1 and n.
--- @return Vector
function Vector.unitAxis(n, axis)
    assert(axis > 0 and axis <= n, "Axis must be between 1 and the dimension")

    local copy = {}
    for i = 1, n do
        copy[i] = (i == axis and 1) or 0
    end

    return Vector.new(copy)
end

-----------------------------------------------------------



------------------- Operations Overload -------------------

--- Get the number of components in this vector, it's dimension.
--- @return number
function Vector:__len()
    return #self.data
end

--- Add a number or another vector to this vector.
--- When b is a number, it is added to every component.
--- When b is a vector, corresponding entries are added element-wise.
--- @param b Vector | number    The scalar or vector to add.
--- @return Vector
function Vector:__add(b)
    if type(b) == "number" then
        local result = {}
        for i = 1, #self do
            result[i] = self.data[i] + b
        end
        return Vector.new(result)
    end

    checkSameLength(self, b)
    local result = {}
    for i = 1, #self do
        result[i] = self.data[i] + b.data[i]
    end
    return Vector.new(result)
end

--- Subtract a number or another vector from this vector.
--- When b is a number, it is subtracted to every component.
--- When b is a vector, corresponding entries are subtracted element-wise.
--- @param b Vector | number     The scalar or vector to subtract.
--- @return Vector
function Vector:__sub(b)
    if type(b) == "number" then
        local result = {}
        for i = 1, #self do
            result[i] = self.data[i] - b
        end
        return Vector.new(result)
    end

    checkSameLength(self, b)
    local result = {}
    for i = 1, #self do
        result[i] = self.data[i] - b.data[i]
    end
    return Vector.new(result)
end

--- Negate every component of this vector.
--- @return Vector
function Vector:__unm()
    return self * -1
end

--- Multiply this vector by a number or another vector.
--- When b is a number, it is multiplied to every component.
--- When b is a vector, returns their cross product.
--- @param b Vector | number     The scalar or vector to multiply by.
--- @return Vector
function Vector:__mul(b)
    if type(b) == "number" then
        local result = {}
        for i = 1, #self do
            result[i] = self.data[i] * b
        end
        return Vector.new(result)
    end

    checkSameLength(self, b)
    local result = {}
    for i = 1, #self do
        result[i] = self.data[i] * b.data[i]
    end
    return Vector.new(result)
end

--- Divide every component of this vector by a scalar.
--- @param b number   The divisor. Must not be zero.
--- @return Vector
function Vector:__div(b)
    assert(type(b) == "number", "A vector can only be divided by a number")
    assert(b ~= 0, "A vector can't be divided by 0")

    local result = {}
    for i = 1, #self do
        result[i] = self.data[i] / b
    end
    return Vector.new(result)
end

-----------------------------------------------------------



-------------------- Other Operations ---------------------

--- Calculate the dot product of this vector and another vector.
--- @param b Vector   The other vector. Must have the same length.
--- @return number
function Vector:dot(b)
    checkSameLength(self, b)

    local sum = 0
    for i = 1, #self do
        sum = sum + self.data[i] * b.data[i]
    end
    return sum
end

--- Project this vector onto another vector.
--- @param b Vector     The vector onto which this vector is projected.
--- @return Vector
function Vector:project(b)
    return b:unit() * self:dot(b) / b:magnitude()
end

--- Calculate the cross product of this vector and another vector.
--- Both vectors must have exactly three components.
--- @param b Vector    The other three-dimensional vector.
--- @return Vector
function Vector:cross(b)
    assert(#self == 3 and #b == 3, "Cross product requires two 3D vectors")

    local a, c = self.data, b.data
    return Vector.new({
        a[2] * c[3] - a[3] * c[2],
        a[3] * c[1] - a[1] * c[3],
        a[1] * c[2] - a[2] * c[1],
    })
end

--- Normalize this vector to unit length.
--- @return Vector
function Vector:unit()
    local mag = self:magnitude();
    local data = {}
    for i = 1, #self do
        data[i] = self.data[i] / mag
    end
    return Vector.new(data)
end

--- Calculate the Euclidean magnitude of this vector.
--- @return number
function Vector:magnitude()
    local sum = 0
    for i = 1, #self do
        sum = sum + self.data[i] ^ 2
    end
    return math.sqrt(sum)
end

-----------------------------------------------------------


return LinearAlgebra
