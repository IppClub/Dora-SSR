local socket = require("socket")
local type Filter = socket.Filter

-- MIME Base64、Quoted-Printable、换行规范化和自动换行过滤器。
local record mime
	const _VERSION: string
	-- 创建 Base64 或 Quoted-Printable 编码过滤器。
	encode: function(name?: string, mode?: string): Filter
	-- 创建 Base64 或 Quoted-Printable 解码过滤器。
	decode: function(name?: string): Filter
	-- 创建文本、Base64 或 Quoted-Printable 自动换行过滤器。
	wrap: function(name?: string, length?: integer): Filter
	-- 创建换行符规范化过滤器。
	normalize: function(marker?: string): Filter
	-- 创建 SMTP 点填充过滤器。
	stuff: function(): Filter
	-- 底层增量 Base64 编码和解码函数。
	b64: function(context?: string, chunk?: string): string | nil, string | nil
	unb64: function(context?: string, chunk?: string): string | nil, string | nil
	-- 底层增量 Quoted-Printable 编码和解码函数。
	qp: function(context?: string, chunk?: string, marker?: string): string | nil, string | nil
	unqp: function(context?: string, chunk?: string): string | nil, string | nil
	wrp: function(remaining: integer, chunk?: string, length?: integer): string | nil, integer
	qpwrp: function(remaining: integer, chunk?: string, length?: integer): string | nil, integer
	eol: function(context: integer, chunk?: string, marker?: string): string | nil, integer
	dot: function(context: integer, chunk?: string): string | nil, integer
end

return mime
