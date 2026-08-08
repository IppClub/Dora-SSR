local socket = require("socket")
local type TCP = socket.TCP
local type Source = socket.Source
local type Sink = socket.Sink

local record Request
	-- 绝对 HTTP URL。
	url: string
	-- HTTP 方法；省略时会根据请求内容推断为 GET 或 POST。
	method: string
	headers: {string: string | number}
	source: Source
	sink: Sink
	proxy: string
	redirect: boolean
	maxredirects: integer
	create: function(): TCP
	-- HTTPS 超时时间，单位为秒。
	timeout: number
	-- HTTPS 对端证书验证模式。
	verify: string | boolean
end

-- 阻塞式 HTTP/1.1 客户端；HTTPS 由 Dora 的 XRT 客户端提供。
local record http
	type Request = Request
	-- 以秒为单位的连接超时时间。
	TIMEOUT: number
	-- 默认 User-Agent 请求头。
	USERAGENT: string
	-- 可选的代理 URL。
	PROXY: string
	-- 执行简单 URL 形式的请求，返回正文、状态码、响应头和状态行。
	request: function(url: string, body?: string): string | nil, integer | string, {string: string} | nil, string | nil
	-- 执行请求表形式的请求，可通过 LTN12 流式传输数据。
	request: function(request: Request): integer | nil, integer | string, {string: string} | nil, string | nil
end

return http
