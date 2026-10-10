local calculus = {}

---------------------- Lib Functions ----------------------

--- Approximate the first derivative of a function at a point.
--- @param func fun(x:number):number  A function that accepts and returns a number.
--- @param x number                   The point at which to estimate the derivative.
--- @param h number?                  Optional step size. Defaults to 10e-6.
--- @return  number
function calculus.derivative(func, x, h)
    h = h or 10e-6
    assert(type(h) == "number" and h > 0, "h must be a positive number")
    return (func(x + h) - func(x - h)) / (2 * h)
end

--- Approximately integrate a function over an interval.
--- @param func fun(x:number):number  A function that accepts and returns a number.
--- @param a    number                The lower bound of integration.
--- @param b    number                The upper bound of integration.
--- @param n    number?               Number of subintervals. Must be a positive even integer. defaults to 1000.
--- @return     number
function calculus.integral(func, a, b, n)
    assert(type(n) == "number" and n >= 2, "n must be a positive even integer")
    local area = 0
    n = n or 1000
    local h = (b - a) / n

    for i = a, b - h, h do
        area = area + (func(i + h / 2) * h)
    end
    return area
end

-----------------------------------------------------------


return calculus
