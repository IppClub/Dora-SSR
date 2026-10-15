-- LuaSocket 3.1.0 的 TCP、UDP、DNS、超时、数据源和数据接收器接口。
local type Source = function(): string | nil, string | nil
local type Sink = function(chunk?: string, err?: string): integer | nil, string | nil
local type Filter = function(chunk?: string): string | nil

local record Selectable
	-- 返回 socket.select 使用的原生描述符。
	getfd: function(self: Selectable): number
	-- 返回未读缓冲数据是否使套接字处于立即可读状态。
	dirty: function(self: Selectable): boolean
end

local record TCP
	-- 接受一个等待中的客户端连接。
	accept: function(self: TCP): TCP | nil, string | nil
	-- 将套接字绑定到本地地址和端口。
	bind: function(self: TCP, address: string, port: integer): integer | nil, string | nil
	-- 关闭套接字。
	close: function(self: TCP): integer
	-- 将套接字连接到远程端点。
	connect: function(self: TCP, address: string, port: integer): integer | nil, string | nil
	dirty: function(self: TCP): boolean
	getfamily: function(self: TCP): string
	getfd: function(self: TCP): number
	getoption: function(self: TCP, name: string): any
	getpeername: function(self: TCP): string | nil, integer | string | nil, string | nil
	getsockname: function(self: TCP): string | nil, integer | string | nil, string | nil
	getstats: function(self: TCP): number, number, number
	gettimeout: function(self: TCP): number, number
	listen: function(self: TCP, backlog?: integer): integer | nil, string | nil
	-- 接收一行、全部剩余数据或指定字节数的数据。
	receive: function(self: TCP, pattern?: string | integer, prefix?: string): string | nil, string | nil, string | nil
	-- 发送字符串或字符串中指定范围的字节。
	send: function(self: TCP, data: string, start?: integer, finish?: integer): integer | nil, string | nil, integer | nil
	setoption: function(self: TCP, name: string, value: any): integer | nil, string | nil
	setstats: function(self: TCP, received?: number, sent?: number, age?: number): integer
	settimeout: function(self: TCP, value: number, mode?: string): integer
	shutdown: function(self: TCP, mode?: string): integer
end

local record UDP
	close: function(self: UDP): integer
	dirty: function(self: UDP): boolean
	getfamily: function(self: UDP): string
	getfd: function(self: UDP): number
	getoption: function(self: UDP, name: string): any
	getpeername: function(self: UDP): string | nil, integer | nil
	getsockname: function(self: UDP): string | nil, integer | nil, string | nil
	gettimeout: function(self: UDP): number, number
	receive: function(self: UDP, size?: integer): string | nil, string | nil
	receivefrom: function(self: UDP, size?: integer): string | nil, string | nil, integer | nil
	send: function(self: UDP, data: string): integer | nil, string | nil
	sendto: function(self: UDP, data: string, address: string, port: integer): integer | nil, string | nil
	setoption: function(self: UDP, name: string, value: any): integer | nil, string | nil
	setpeername: function(self: UDP, address?: string, port?: integer): integer | nil, string | nil
	setsockname: function(self: UDP, address: string, port: integer): integer | nil, string | nil
	settimeout: function(self: UDP, value: number, mode?: string): integer
end

local record DNSAddress
	family: string
	addr: string
end

local record DNS
	getaddrinfo: function(host: string): {DNSAddress} | nil, string | nil
	gethostname: function(): string
	getnameinfo: function(address: string): string | nil, string | nil
	tohostname: function(address: string): string | nil, string | nil
	toip: function(address: string): string | nil, string | nil
end

local record socket
	type TCP = TCP
	type UDP = UDP
	type Selectable = Selectable
	type Source = Source
	type Sink = Sink
	type Filter = Filter
	const _VERSION: string
	const BLOCKSIZE: integer
	const dns: DNS

	-- 创建、绑定并监听一个 TCP 套接字。
	bind: function(host: string, port: integer, backlog?: integer): TCP | nil, string | nil
	-- 创建并连接一个 TCP 套接字。
	connect: function(address: string, port: integer, localAddress?: string, localPort?: integer, family?: string): TCP | nil, string | nil
	connect4: function(address: string, port: integer, localAddress?: string, localPort?: integer): TCP | nil, string | nil
	connect6: function(address: string, port: integer, localAddress?: string, localPort?: integer): TCP | nil, string | nil
	-- 返回以秒表示且带小数精度的墙上时钟时间。
	gettime: function(): number
	newtry: function(finalizer?: function()): function(...: any): any
	protect: function(fn: function(...: any): any): function(...: any): any
	-- 等待套接字变为可读或可写，或者等待超时。
	select: function(readable: {Selectable}, writable?: {Selectable}, timeout?: number): {Selectable}, {Selectable}, string | nil
	sink: function(mode: string, sock: TCP): Sink
	skip: function(count: integer, ...: any): any
	-- 阻塞当前线程指定的秒数。
	sleep: function(seconds: number)
	source: function(mode: string, sock: TCP, length?: integer): Source
	tcp: function(): TCP | nil, string | nil
	tcp4: function(): TCP | nil, string | nil
	tcp6: function(): TCP | nil, string | nil
	try: function(...: any): any
	udp: function(): UDP | nil, string | nil
	udp4: function(): UDP | nil, string | nil
	udp6: function(): UDP | nil, string | nil
end

return socket
