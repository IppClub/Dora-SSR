local socket = require("socket")
local type Source = socket.Source
local type Sink = socket.Sink

local record Request
	-- Absolute HTTPS URL.
	url: string
	-- HTTP method, inferred as GET or POST when omitted.
	method: string
	headers: {string: string | number}
	source: Source
	sink: Sink
	-- Request timeout in seconds.
	timeout: number
	-- Peer verification mode. It defaults to none for LuaSec compatibility; use "peer" or true to enable it.
	verify: string | boolean
end

-- Blocking HTTPS request compatibility backed by Dora's XRT HTTP client.
local record https
	type Request = Request
	TIMEOUT: number
	const PORT: integer
	-- Returns response body, status code, response headers and status line.
	request: function(url: string, body?: string): string | nil, integer | string, {string: string} | nil, string | nil
	-- Sends a table-form request and writes the completed response through its sink when provided.
	request: function(request: Request): integer | nil, integer | string, {string: string} | nil, string | nil
end

return https
