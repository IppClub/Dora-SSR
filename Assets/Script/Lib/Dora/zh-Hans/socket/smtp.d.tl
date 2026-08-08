local socket = require("socket")
local type Source = socket.Source
local type Sink = socket.Sink
local type TCP = socket.TCP

local record Message
	headers: {string: string}
	body: string | Source | {Message}
	preamble: string
	epilogue: string
	zone: string
end

local record Mail
	from: string
	rcpt: string | {string}
	source: Source
	server: string
	port: integer
	domain: string
	user: string
	password: string
	step: function(source: Source, sink: Sink): integer | nil, string | nil
	create: function(): TCP
end

-- 阻塞式 SMTP 客户端和 RFC 2045 邮件数据源生成器。
local record smtp
	type Message = Message
	type Mail = Mail
	TIMEOUT: number
	SERVER: string
	PORT: integer
	DOMAIN: string
	ZONE: string
	-- 将邮件描述（包括多段正文）转换为 LTN12 source。
	message: function(message: Message): Source
	-- 通过配置的 SMTP 服务器发送一封邮件。
	send: function(mail: Mail): integer | nil, string | nil
end

return smtp
