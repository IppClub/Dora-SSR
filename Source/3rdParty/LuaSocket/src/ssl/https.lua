-----------------------------------------------------------------------------
-- LuaSec-compatible HTTPS request subset backed by Dora's XRT HTTP client.
-----------------------------------------------------------------------------

local socket = require("socket")
local ltn12 = require("ltn12")
local core = require("dora.https")
local table = require("table")
local type = type

local _M = {
    TIMEOUT = 60,
    PORT = 443,
}

local function collect(source)
    if not source then return nil end
    local chunks = {}
    while true do
        local chunk, err = source()
        if chunk then
            chunks[#chunks + 1] = chunk
        elseif err then
            return nil, err
        else
            return table.concat(chunks)
        end
    end
end

local function execute(reqt, returnBody)
    if reqt.proxy then return nil, "proxy not supported" end
    if reqt.create then return nil, "create function not permitted" end
    local body, err = collect(reqt.source)
    if err then return nil, err end
    local method = reqt.method
    if not method or method == "" then
        method = body ~= nil and "POST" or "GET"
    end
    local response, code, headers, status = core.request {
        url = reqt.url,
        method = method,
        headers = reqt.headers,
        body = body,
        timeout = reqt.timeout or _M.TIMEOUT,
        verify = reqt.verify,
    }
    if response == nil then return nil, code end
    if reqt.sink then
        local ok, sinkerr = reqt.sink(response)
        if ok == nil then return nil, sinkerr end
        ok, sinkerr = reqt.sink(nil)
        if ok == nil then return nil, sinkerr end
        return 1, code, headers, status
    end
    if returnBody then return response, code, headers, status end
    return 1, code, headers, status
end

_M.request = socket.protect(function(reqt, body)
    if type(reqt) == "string" then
        local request = {url = reqt}
        if body ~= nil then
            request.method = "POST"
            request.source = ltn12.source.string(body)
            request.headers = {
                ["content-length"] = #body,
                ["content-type"] = "application/x-www-form-urlencoded",
            }
        end
        return execute(request, true)
    end
    return execute(reqt, false)
end)

return _M
