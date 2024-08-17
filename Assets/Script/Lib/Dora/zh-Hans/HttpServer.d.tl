-- 代表一个HTTP请求对象。
local record Request

	-- 包含请求头信息的表。
	headers: {string: string}

	-- 请求的内容体。
	body: table | string
end

-- 代表一个HTTP服务器，可以处理请求和传输文件。
local record HttpServer

	-- 服务器的本地IP地址。
	const localIP: string

	-- WebSocket连接的数量。
	const wsConnectionCount: integer

	-- 服务器的根静态文件目录的路径。
	wwwPath: string

	-- 在指定端口上启动HTTP服务器。
	-- @param port (integer) 要启动服务器的端口号。
	-- @return (boolean) 一个布尔值，表示服务器是否成功启动。
	start: function(self: HttpServer, port: integer): boolean

	-- 在指定端口上启动WebSocket服务器。
	-- @param port (integer) 要启动服务器的端口号。
	-- @return (boolean) 一个布尔值，表示服务器是否成功启动。
	startWS: function(self: HttpServer, port: integer): boolean

	-- 注册一个处理函数，用于处理POST请求。
	-- @param pattern (string) 匹配请求的URL的模式。
	-- @param handler (function) 匹配模式时要调用的处理函数。函数应返回一个包含可以序列化为JSON的响应数据的Lua表。
	post: function(
		self: HttpServer,
		pattern: string,
		handler: function(Request): table
	)

	-- 注册一个处理函数，用于在协程中处理POST请求。
	-- @param pattern (string) 要匹配的URL模式。
	-- @param handler (function) 匹配模式时要调用的处理函数。函数应返回一个包含可以序列化为JSON的响应数据的字典。并且函数将在协程中运行。
	postSchedule: function(
		self: HttpServer,
		pattern: string,
		handler: function(Request): table
	)

	-- 注册一个处理函数，用于处理文件上传的多部分POST请求。
	-- @param pattern (string) 要匹配的URL模式。
	-- @param acceptHandler (function) 匹配模式时要调用的处理函数。函数应返回要将文件保存为的文件名，或者返回 `null` 来拒绝文件。
	-- @param doneHandler (function) 匹配模式时要调用的处理函数。函数应返回 `true` 来接受文件，或者返回 `false` 来拒绝文件。
	upload: function(
		self: HttpServer,
		pattern: string,
		acceptHandler: function(req: Request, filename: string): (string | nil),
		doneHandler: function(req: Request, filename: string): boolean
	)

	-- 停止服务器，包括已启动的HTTP服务器和WebSocket服务器。
	stop: function(self: HttpServer)
end

local httpServer: HttpServer
return httpServer
