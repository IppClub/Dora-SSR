local socket = require("socket")
local type TCP = socket.TCP
local type Source = socket.Source
local type Sink = socket.Sink

local record Request
	-- Absolute HTTP URL.
	url: string
	-- HTTP method, inferred as GET or POST when omitted.
	method: string
	headers: {string: string | number}
	source: Source
	sink: Sink
	proxy: string
	redirect: boolean
	maxredirects: integer
	create: function(): TCP
	-- HTTPS timeout in seconds.
	timeout: number
	-- HTTPS peer verification mode.
	verify: string | boolean
end

-- Blocking HTTP/1.1 client. HTTPS is backed by Dora's XRT client.
local record http
	type Request = Request
	-- Connection timeout in seconds.
	TIMEOUT: number
	-- Default User-Agent header.
	USERAGENT: string
	-- Optional proxy URL.
	PROXY: string
	-- Performs the simple URL form and returns body, status code, headers and status line.
	request: function(url: string, body?: string): string | nil, integer | string, {string: string} | nil, string | nil
	-- Performs a table-form request suitable for streaming through LTN12.
	request: function(request: Request): integer | nil, integer | string, {string: string} | nil, string | nil
end

return http
