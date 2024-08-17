-- The HTTP request object.
local record Request

	-- A table containing the request headers.
	headers: {string: string}

	-- The body of the request.
	body: table | string
end

-- Represents an HTTP server that can handle requests and serve files.
local record HttpServer

	-- The local IP address of the server.
	const localIP: string

	-- The number of WebSocket connections.
	const wsConnectionCount: integer

	-- The path to the root static file directory of the server.
	wwwPath: string

	-- Starts the HTTP server on the specified port.
	-- @param port (integer) The port number on which to start the server.
	-- @return (boolean) A boolean value indicating whether the server started successfully.
	start: function(self: HttpServer, port: integer): boolean

	-- Starts the WebSocket server on the specified port.
	-- @param port (integer) The port number on which to start the server.
	-- @return (boolean) A boolean value indicating whether the server started successfully.
	startWS: function(self: HttpServer, port: integer): boolean

	-- Registers a handler function for handling POST requests.
	-- @param pattern (string) The pattern to match the URL of the request.
	-- @param handler (function) The handler function to call when the pattern is matched. The function should return a Lua table containing response data that can be serialized to JSON.
	post: function(
		self: HttpServer,
		pattern: string,
		handler: function(Request): table
	)

	-- Registers a handler function for handling POST requests in a coroutine.
	-- @param pattern (string) The URL pattern to match.
	-- @param handler (function) The handler function to call when the pattern is matched. The function should return a dictionary containing response data that can be serialized to JSON, and the function will run in a coroutine.
	postSchedule: function(
		self: HttpServer,
		pattern: string,
		handler: function(Request): table
	)

	-- Registers a handler function for handling multipart POST requests for file uploads.
	-- @param pattern (string) The URL pattern to match.
	-- @param acceptHandler (function) The handler function to call when the pattern is matched. The function should return the filename to save the file as, or return `null` to reject the file.
	-- @param doneHandler (function) The handler function to call when the pattern is matched. The function should return `true` to accept the file, or `false` to reject the file.
	upload: function(
		self: HttpServer,
		pattern: string,
		acceptHandler: function(req: Request, filename: string): (string | nil),
		doneHandler: function(req: Request, filename: string): boolean
	)

	-- Stops the servers, including HTTP and WebSocket servers.
	stop: function(self: HttpServer)
end

local httpServer: HttpServer
return httpServer
