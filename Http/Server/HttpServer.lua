--- @class HttpServer
--- A class that represents a Server, for listening to requests made through http protocol.
--- Register routes before calling listen().
--- @field host         string        Interface address to bind to.
--- @field port         integer       TCP port to listen on.
--- @field isListening  boolean       Represents the current status
--- @field routes       table<string> Represents the routes to be listened
local HttpServer = {}
HttpServer.__index = function(self, key)
    if key == "host" then
        return rawget(self, "_host")
    elseif key == "port" then
        return rawget(self, "_port")
    elseif key == "isListening" then
        return rawget(self, "_isListening")
    elseif key == "routes" then
        return rawget(self, "_routes")
    end
    return HttpServer[key]
end
HttpServer.__newindex = function(self, key, value)
    error("HttpServer is immutable and there shouldn't be a reason to change it.")
end

--- Http Status from response
--- @enum HttpServer.Status
HttpServer.Status = {
    --- Informational
    CONTINUE_100 = 100,
    SWITCHING_PROTOCOLS_101 = 101,
    PROCESSING_102 = 102,
    EARLY_HINTS_103 = 103,

    --- Successful
    OK_200 = 200,
    CREATED_201 = 201,
    ACCEPTED_202 = 202,
    NON_AUTHORITATIVE_INFORMATION_203 = 203,
    NO_CONTENT_204 = 204,
    RESET_CONTENT_205 = 205,
    PARTIAL_CONTENT_206 = 206,
    MULTI_STATUS_207 = 207,
    ALREADY_REPORTED_208 = 208,
    IM_USED_226 = 226,

    --- Redirection
    MULTIPLE_CHOICES_300 = 300,
    MOVED_PERMANENTLY_301 = 301,
    FOUND_302 = 302,
    SEE_OTHER_303 = 303,
    NOT_MODIFIED_304 = 304,
    TEMPORARY_REDIRECT_307 = 307,
    PERMANENT_REDIRECT_308 = 308,

    --- Client error
    BAD_REQUEST_400 = 400,
    UNAUTHORIZED_401 = 401,
    PAYMENT_REQUIRED_402 = 402,
    FORBIDDEN_403 = 403,
    NOT_FOUND_404 = 404,
    METHOD_NOT_ALLOWED_405 = 405,
    NOT_ACCEPTABLE_406 = 406,
    PROXY_AUTHENTICATION_REQUIRED_407 = 407,
    REQUEST_TIMEOUT_408 = 408,
    CONFLICT_409 = 409,
    GONE_410 = 410,
    LENGTH_REQUIRED_411 = 411,
    PRECONDITION_FAILED_412 = 412,
    CONTENT_TOO_LARGE_413 = 413,
    URI_TOO_LONG_414 = 414,
    UNSUPPORTED_MEDIA_TYPE_415 = 415,
    RANGE_NOT_SATISFIABLE_416 = 416,
    EXPECTATION_FAILED_417 = 417,
    IM_A_TEAPOT_418 = 418,
    MISDIRECTED_REQUEST_421 = 421,
    UNPROCESSABLE_CONTENT_422 = 422,
    LOCKED_423 = 423,
    FAILED_DEPENDENCY_424 = 424,
    TOO_EARLY_425 = 425,
    UPGRADE_REQUIRED_426 = 426,
    PRECONDITION_REQUIRED_428 = 428,
    TOO_MANY_REQUESTS_429 = 429,
    REQUEST_HEADER_FIELDS_TOO_LARGE_431 = 431,
    UNAVAILABLE_FOR_LEGAL_REASONS_451 = 451,

    --- Server error
    INTERNAL_SERVER_ERROR_500 = 500,
    NOT_IMPLEMENTED_501 = 501,
    BAD_GATEWAY_502 = 502,
    SERVICE_UNAVAILABLE_503 = 503,
    GATEWAY_TIMEOUT_504 = 504,
    HTTP_VERSION_NOT_SUPPORTED_505 = 505,
    VARIANT_ALSO_NEGOTIATES_506 = 506,
    INSUFFICIENT_STORAGE_507 = 507,
    LOOP_DETECTED_508 = 508,
    NOT_EXTENDED_510 = 510,
    NETWORK_AUTHENTICATION_REQUIRED_511 = 511,
}

--- Http Method
---@enum HttpServer.Method
HttpServer.Methods = {
    GET = "GET",
    POST = "POST",
    PATCH = "PATCH",
    DELETE = "DELETE",
    PUT = "PUT",
    QUERY = "QUERY",
    HEAD = "HEAD",
    OPTIONS = "OPTIONS",
    TRACE = "TRACE",
    CONNECT = "CONNECT",
}

--------------------- Local Functions ---------------------


-----------------------------------------------------------



------------------- Server Constructors -------------------

---Creates an HTTP server.
---@param host? string   Address to bind to. Defaults to "127.0.0.1".
---@param port? integer  TCP port to listen on. Defaults to 8888.
---@return HttpServer server
function HttpServer:new(host, port)
    host = host or "127.0.0.1"
    port = port or 8888
    return setmetatable({
        _host = host,
        _port = port,
        _isListening = false,
        _routes = {}
    }, self)
end

-----------------------------------------------------------



--------------------- Routing Methods ---------------------

--- Registers a handler for a method and path pattern.
--- @param method  HttpServer.Method                                          HTTP method to match.
--- @param path    string                                                         Route path or pattern.
--- @param handler fun(request: HttpServer.HttpRequest): HttpServer.HttpResponse  Function called for matching requests.
function HttpServer:route(method, path, handler) end

--- Registers a GET route.
--- @param path    string                                                         Route path or pattern.
--- @param handler fun(request: HttpServer.HttpRequest): HttpServer.HttpResponse  Function called for matching requests.
function HttpServer:get(path, handler)
    self:route(self.Methods.GET, path, handler)
end

--- Registers a POST route.
--- @param path    string                                                         Route path or pattern.
--- @param handler fun(request: HttpServer.HttpRequest): HttpServer.HttpResponse  Function called for matching requests.
function HttpServer:post(path, handler)
    self:route(self.Methods.POST, path, handler)
end

--- Registers a PUT route.
--- @param path    string                                                         Route path or pattern.
--- @param handler fun(request: HttpServer.HttpRequest): HttpServer.HttpResponse  Function called for matching requests.
function HttpServer:put(path, handler)
    self:route(self.Methods.PUT, path, handler)
end

--- Registers a PATCH route.
--- @param path    string                                                         Route path or pattern.
--- @param handler fun(request: HttpServer.HttpRequest): HttpServer.HttpResponse  Function called for matching requests.
function HttpServer:patch(path, handler)
    self:route(self.Methods.PATCH, path, handler)
end

--- Registers a DELETE route.
--- @param path    string                                                         Route path or pattern.
--- @param handler fun(request: HttpServer.HttpRequest): HttpServer.HttpResponse  Function called for matching requests.
function HttpServer:delete(path, handler)
    self:route(self.Methods.DELETE, path, handler)
end

--- Registers a HEAD route.
--- @param path    string                                                         Route path or pattern.
--- @param handler fun(request: HttpServer.HttpRequest): HttpServer.HttpResponse  Function called for matching requests.
function HttpServer:head(path, handler)
    self:route(self.Methods.HEAD, path, handler)
end

--- Registers an OPTIONS route.
--- @param path    string                                                         Route path or pattern.
--- @param handler fun(request: HttpServer.HttpRequest): HttpServer.HttpResponse  Function called for matching requests.
function HttpServer:options(path, handler)
    self:route(self.Methods.OPTIONS, path, handler)
end

--- Registers a TRACE route.
--- @param path    string                                                         Route path or pattern.
--- @param handler fun(request: HttpServer.HttpRequest): HttpServer.HttpResponse  Function called for matching requests.
function HttpServer:trace(path, handler)
    self:route(self.Methods.TRACE, path, handler)
end

--- Registers a CONNECT route.
--- @param path    string                                                         Route path or pattern.
--- @param handler fun(request: HttpServer.HttpRequest): HttpServer.HttpResponse  Function called for matching requests.
function HttpServer:connect(path, handler)
    self:route(self.Methods.CONNECT, path, handler)
end

-----------------------------------------------------------



--------------------- Running Methods ---------------------

--- Starts listening for requests.
--- @return boolean success  `true` if the server started/listened successfully.
--- @return string? error    Error description on failure.
function HttpServer:listen()
    rawset(self, "_isListening", true)
    return true, ""
end

--- Stops the server if it is running.
--- @return boolean
function HttpServer:stop()
    rawset(self, "_isListening", false)
    return true
end

-----------------------------------------------------------



------------------------ Responses ------------------------

--- @class HttpServer.HttpResponse
--- @field status  HttpServer.Status      HTTP status code.
--- @field headers table<string, string>  Response headers.
--- @field body    string                 Response body represented as a string. May be empty. User decide wheter to parse it or not.
HttpServer.HttpResponse = {}
HttpServer.HttpResponse.__index = function(self, key)
    if key == "status" then
        return rawget(self, "_status")
    elseif key == "headers" then
        return rawget(self, "_headers")
    elseif key == "body" then
        return rawget(self, "_body")
    end
    return HttpServer.HttpResponse[key]
end

------------------ Response Constructors ------------------

--- Structures an HTTP Response.
--- @param status  HttpServer.Status     HTTP status code.
--- @param headers table<string, string> Response headers.
--- @param body    string                Response body represented as a string. May be empty. User decide wheter to parse it or not
--- @return HttpServer.HttpResponse
function HttpServer.HttpResponse.new(status, headers, body)
    return setmetatable({
        _status = status,
        _headers = headers,
        _body = body
    }, HttpServer.HttpResponse)
end

-----------------------------------------------------------

-----------------------------------------------------------



------------------------- Request -------------------------

--- @class HttpServer.HttpRequest
--- @field method  HttpServer.Method     HTTP method, such as "GET" or "POST".
--- @field headers table<string, string> Request headers.
--- @field body    string                Request body; may be empty.
HttpServer.HttpRequest = {}
HttpServer.HttpRequest.__index = function(self, key)
    if key == "method" then
        return rawget(self, "_method")
    elseif key == "headers" then
        return rawget(self, "_headers")
    elseif key == "body" then
        return rawget(self, "_body")
    end
    return HttpServer.HttpRequest[key]
end

------------------ Requests Constructors ------------------

--- Structures an HTTP Request.
--- @param method  HttpServer.Method     HTTP method.
--- @param headers table<string, string> Request headers.
--- @param body    string                Request body; may be empty.
--- @return HttpServer.HttpRequest
function HttpServer.HttpRequest.new(method, headers, body)
    return setmetatable({
        _method = method,
        _headers = headers,
        _body = body
    }, HttpServer.HttpRequest)
end

-----------------------------------------------------------

-----------------------------------------------------------


return HttpServer
