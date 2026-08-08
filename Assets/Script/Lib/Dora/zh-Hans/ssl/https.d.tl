local socket = require("socket")
local type Source = socket.Source
local type Sink = socket.Sink

local record Request
	-- 绝对 HTTPS URL。
	url: string
	-- HTTP 方法；省略时会根据请求内容推断为 GET 或 POST。
	method: string
	headers: {string: string | number}
	source: Source
	sink: Sink
	-- 以秒为单位的请求超时时间。
	timeout: number
	-- 对端证书验证模式；为兼容 LuaSec，默认不验证，设为 "peer" 或 true 时启用。
	verify: string | boolean
end

-- 由 Dora XRT HTTP 客户端实现的阻塞式 HTTPS 请求兼容模块。
local record https
	type Request = Request
	TIMEOUT: number
	const PORT: integer
	-- 返回响应正文、状态码、响应头和状态行。
	request: function(url: string, body?: string): string | nil, integer | string, {string: string} | nil, string | nil
	-- 执行请求表形式的请求；提供 sink 时会把完整响应写入该 sink。
	request: function(request: Request): integer | nil, integer | string, {string: string} | nil, string | nil
end

return https
