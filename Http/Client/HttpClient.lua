--- @class HttpClient
--- A class that represents a Client, for making requests through http protocol.
--- @field connectionTimeout  number  Maximum time in seconds to establish a connection.
local HttpClient = {}
HttpClient.__index = function(self, key)
    if key == "connectionTimeout" then
        return rawget(self, "_connectionTimeout")
    end
    return HttpClient[key]
end
HttpClient.__newindex = function(self, key, value)
    if key == "connectionTimeout" then
        return rawset(self, "_connectionTimeout", value)
    end
    return HttpClient[key]
end

--- Http Status from response
--- @enum HttpClient.Status
HttpClient.Status = {
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
--- @enum HttpClient.Method
HttpClient.Methods = {
    GET = "GET",
    POST = "POST",
    PATCH = "PATCH",
    DELETE = "DELETE",
    PUT = "PUT",
    QUERY = "QUERY",
    HEAD = "HEAD",
    OPTIONS = "OPTIONS",
    TRACE = "TRACE",
    CONNECT = "CONNECT"
}

--------------------- Local Functions ---------------------

--- Parses a raw HTTP response string into status, headers, and body.
--- @param rawResponse string The raw response string
--- @return number     status
--- @return table      headers
--- @return string     body
local function parse(rawResponse)
    local response = rawResponse:gsub("\r\n", "\n")

    local headerEnd, bodyStart = response:find("\n\n")
    local headerPart, body = "", ""

    if headerEnd then
        headerPart = response:sub(1, headerEnd - 1)
        body = response:sub(bodyStart + 1)
    else
        headerPart = response
    end

    local lines = {}
    for line in headerPart:gmatch("[^\n]+") do
        table.insert(lines, line)
    end

    --- @type number?
    local status = 200
    local headers = {}

    if #lines > 0 then
        local statusStr = lines[1]:match("HTTP/%d+%.%d+%s+(%d+)")
        if statusStr then
            status = tonumber(statusStr)
        end

        for i = 2, #lines do
            local k, v = lines[i]:match("^([^:]+):%s*(.*)$")
            if k and v then
                headers[k:lower()] = v
            end
        end
    end

    assert(status, "Error on completing the request.")
    return status, headers, body
end

-----------------------------------------------------------



------------------- Client Constructors -------------------

--- Creates an HTTP client.
--- @param connectionTimeout? number Maximum seconds to wait for a connection. Defaults to 30.
--- @return HttpClient
function HttpClient:new(connectionTimeout)
    connectionTimeout = connectionTimeout or 30
    return setmetatable({
        _connectionTimeout = connectionTimeout,
    }, HttpClient)
end

-----------------------------------------------------------



--------------------- Request Methods ---------------------

--- Sends an HTTP request with the mode specified.
--- @param url      string                  Absolute request URL.
--- @param request  HttpClient.HttpRequest  Object that contains information about the request
--- @return HttpClient.HttpResponse
function HttpClient:send(url, request)
    local cmd = { "curl", "-s", "-i", "-X", request.method }

    if request.headers then
        for key, value in pairs(request.headers) do
            table.insert(cmd, "-H")
            table.insert(cmd, string.format("%s: %s", key, value))
        end
    end

    if request.body then
        table.insert(cmd, "-d")
        table.insert(cmd, request.body)
    end

    table.insert(cmd, url)

    local handle = io.popen(table.concat(cmd, " ") .. " 2>&1")
    if not handle then
        return HttpClient.HttpResponse.new(HttpClient.Status.INTERNAL_SERVER_ERROR_500, {}, "Failed to execute request")
    end

    local result = handle:read("*a")
    handle:close()

    local status, parsedHeaders, parsedBody = parse(result)

    return HttpClient.HttpResponse.new(status, parsedHeaders, parsedBody)
end

--- Sends an HTTP GET request. Requests a representation of the specified resource.
--- @param url      string                Absolute request URL.
--- @param headers? table<string, string> Optional request headers.
--- @return HttpClient.HttpResponse
function HttpClient:get(url, headers)
    return self:send(url, HttpClient.HttpRequest.new(HttpClient.Methods.GET, headers, nil))
end

--- Sends an HTTP POST request. Submits an entity to the specified resource.
--- @param url      string                Absolute request URL.
--- @param headers? table<string, string> Optional request headers.
--- @param body?    string                Optional request body.
--- @return HttpClient.HttpResponse
function HttpClient:post(url, headers, body)
    return self:send(url, HttpClient.HttpRequest.new(HttpClient.Methods.POST, headers, body))
end

--- Sends an HTTP PATCH request. Applies partial modifications to a resource.
--- @param url      string                Absolute request URL.
--- @param headers? table<string, string> Optional request headers.
--- @param body?    string                Optional request body.
--- @return HttpClient.HttpResponse
function HttpClient:patch(url, headers, body)
    return self:send(url, HttpClient.HttpRequest.new(HttpClient.Methods.PATCH, headers, body))
end

--- Sends an HTTP DELETE request. Deletes the specified resource.
--- @param url      string                Absolute request URL.
--- @param headers? table<string, string> Optional request headers.
--- @return HttpClient.HttpResponse
function HttpClient:delete(url, headers)
    return self:send(url, HttpClient.HttpRequest.new(HttpClient.Methods.DELETE, headers, nil))
end

--- Sends an HTTP PUT request. Replaces all current representations of the target resource with the request content.
--- @param url      string                Absolute request URL.
--- @param headers? table<string, string> Optional request headers.
--- @param body?    string                Optional request body.
--- @return HttpClient.HttpResponse
function HttpClient:put(url, headers, body)
    return self:send(url, HttpClient.HttpRequest.new(HttpClient.Methods.PUT, headers, body))
end

--- Sends an HTTP QUERY request. It requests that the target resource process the request content in a safe and idempotent manner,
--- returning the result in the response.
--- It is similar to GET, but allows request content with defined semantics.
--- @param url      string                Absolute request URL.
--- @param headers? table<string, string> Optional request headers.
--- @param body?    string                Optional request body.
--- @return HttpClient.HttpResponse
function HttpClient:query(url, headers, body)
    return self:send(url, HttpClient.HttpRequest.new(HttpClient.Methods.QUERY, headers, body))
end

--- Sends an HTTP HEAD request. For metadata, response body is empty
--- @param url      string                Absolute request URL.
--- @param headers? table<string, string> Optional request headers.
--- @return HttpClient.HttpResponse
function HttpClient:head(url, headers)
    return self:send(url, HttpClient.HttpRequest.new(HttpClient.Methods.HEAD, headers, nil))
end

--- Sends an HTTP OPTIONS request. Describes the communication options for the target resource.
--- @param url      string                Absolute request URL.
--- @param headers? table<string, string> Optional request headers.
--- @return HttpClient.HttpResponse
function HttpClient:options(url, headers)
    return self:send(url, HttpClient.HttpRequest.new(HttpClient.Methods.OPTIONS, headers, nil))
end

--- Sends an HTTP TRACE request. Performs a message loop-back test.
--- @param url      string                Absolute request URL.
--- @param headers? table<string, string> Optional request headers.
--- @return HttpClient.HttpResponse
function HttpClient:trace(url, headers)
    return self:send(url, HttpClient.HttpRequest.new(HttpClient.Methods.TRACE, headers, nil))
end

--- Establishes a tunnel to the server through HTTP CONNECT.
--- @param url      string                Absolute request URL.
--- @param headers? table<string, string> Optional request headers.
--- @return HttpClient.HttpResponse
function HttpClient:connect(url, headers)
    return self:send(url, HttpClient.HttpRequest.new(HttpClient.Methods.CONNECT, headers, nil))
end

-----------------------------------------------------------


---------------------- Http Response ----------------------

--- @class HttpClient.HttpResponse
--- @field status  HttpClient.Status      HTTP status code.
--- @field headers table<string, string>  Response headers.
--- @field body    string                 Response body represented as a string. May be empty. User decide wheter to parse it or not.
HttpClient.HttpResponse = {}
HttpClient.HttpResponse.__index = function(self, key)
    if key == "status" then
        return rawget(self, "_status")
    elseif key == "headers" then
        return rawget(self, "_headers")
    elseif key == "body" then
        return rawget(self, "_body")
    end
    return HttpClient.HttpResponse[key]
end
HttpClient.HttpResponse.__newindex = function(self, key, value)
    error("Http Response is immutable. Please make a copy to change it")
end


------------------ Response Constructors ------------------

--- @private
--- Structures an HTTP Response. Should not be used outside the client.
--- @param status  HttpClient.Status     HTTP status code.
--- @param headers table<string, string> Response headers.
--- @param body    string                Response body represented as a string. May be empty. User decide wheter to parse it or not
--- @return HttpClient.HttpResponse
function HttpClient.HttpResponse.new(status, headers, body)
    return setmetatable({
        _status = status,
        _headers = headers,
        _body = body
    }, HttpClient.HttpResponse)
end

-----------------------------------------------------------

-----------------------------------------------------------



------------------------- Request -------------------------

--- @class HttpClient.HttpRequest
--- @field method  HttpClient.Method     HTTP method, such as "GET" or "POST".
--- @field headers table<string, string> Request headers.
--- @field body    string                Request body; may be empty.
HttpClient.HttpRequest = {}
HttpClient.HttpRequest.__index = function(self, key)
    if key == "method" then
        return rawget(self, "_method")
    elseif key == "headers" then
        return rawget(self, "_headers")
    elseif key == "body" then
        return rawget(self, "_body")
    end
    return HttpClient.HttpRequest[key]
end

------------------ Requests Constructors ------------------

--- Structures an HTTP Request.
--- @param method   HttpClient.Method     HTTP method.
--- @param headers? table<string, string> Request headers.
--- @param body?    string                Request body; may be empty.
--- @return HttpClient.HttpRequest
function HttpClient.HttpRequest.new(method, headers, body)
    return setmetatable({
        _method = method,
        _headers = headers,
        _body = body
    }, HttpClient.HttpRequest)
end

-----------------------------------------------------------

-----------------------------------------------------------


return HttpClient
