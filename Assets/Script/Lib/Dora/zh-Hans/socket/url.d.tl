-- URL 解析、拼装、转义和相对地址解析工具。
local record URLParts
	scheme: string
	authority: string
	userinfo: string
	user: string
	password: string
	host: string
	port: string | integer
	path: string
	params: string
	query: string
	fragment: string
end

local record url
	type Parts = URLParts
	const _VERSION: string
	-- 对 LuaSocket 非保留字符集合之外的字节执行百分号编码。
	escape: function(value: string): string
	-- 解码百分号转义的字节。
	unescape: function(value: string): string
	-- 将 URL 拆分为命名字段，并可用默认值表预填。
	parse: function(value: string, defaults?: URLParts): URLParts | nil, string | nil
	-- 从 URL 字段表重新生成 URL。
	build: function(parts: URLParts): string
	-- 以基础 URL 为基准解析相对 URL。
	absolute: function(base: string | URLParts, relative: string): string
	-- 将路径拆成若干段并解码。
	parse_path: function(path: string): {string}
	-- 拼接路径段；除非 unsafe 为真，否则会自动转义。
	build_path: function(path: {string}, unsafe?: boolean): string
end

return url
