local record Request
	headers: {string: string}
	body: table | string
end
local record HttpServer
	wwwPath: string
	start: function(self: HttpServer, port: integer): boolean
	post: function(self: HttpServer, pattern: string, handler: function(Request):table)
	stop: function(self: HttpServer)
end
local httpServer: HttpServer
return httpServer
