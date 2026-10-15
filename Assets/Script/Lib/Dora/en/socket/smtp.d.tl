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

-- Blocking SMTP client and RFC 2045 message-source builder.
local record smtp
	type Message = Message
	type Mail = Mail
	TIMEOUT: number
	SERVER: string
	PORT: integer
	DOMAIN: string
	ZONE: string
	-- Converts a message description, including multipart bodies, into an LTN12 source.
	message: function(message: Message): Source
	-- Sends one message through the configured SMTP server.
	send: function(mail: Mail): integer | nil, string | nil
end

return smtp
