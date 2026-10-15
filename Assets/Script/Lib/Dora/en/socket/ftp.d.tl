local socket = require("socket")
local type Source = socket.Source
local type Sink = socket.Sink
local type TCP = socket.TCP

local record Request
	url: string
	host: string
	port: integer
	user: string
	password: string
	path: string
	type: string
	command: string | {string}
	argument: string | {string}
	check: string | integer | {string | integer}
	source: Source
	sink: Sink
	step: function(source: Source, sink: Sink): integer | nil, string | nil
	create: function(): TCP
end

-- Blocking FTP client built on LuaSocket.
local record ftp
	type Request = Request
	TIMEOUT: number
	USER: string
	PASSWORD: string
	-- Downloads a URL to a string, or streams a table-form request into its sink.
	get: function(request: string | Request): string | integer | nil, string | nil
	-- Uploads a string to a URL, or streams a request from its source.
	put: function(request: string | Request, body?: string): integer | nil, string | nil
	-- Executes one or more FTP control commands.
	command: function(request: Request): integer | nil, string | nil
end

return ftp
