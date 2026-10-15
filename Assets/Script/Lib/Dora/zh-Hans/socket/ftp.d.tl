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

-- 基于 LuaSocket 的阻塞式 FTP 客户端。
local record ftp
	type Request = Request
	TIMEOUT: number
	USER: string
	PASSWORD: string
	-- 将 URL 下载为字符串，或把表形式请求流式写入 sink。
	get: function(request: string | Request): string | integer | nil, string | nil
	-- 向 URL 上传字符串，或从请求的 source 流式上传。
	put: function(request: string | Request, body?: string): integer | nil, string | nil
	-- 执行一条或多条 FTP 控制命令。
	command: function(request: Request): integer | nil, string | nil
end

return ftp
