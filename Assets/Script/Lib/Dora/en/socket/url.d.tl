-- URL parsing, composition, escaping and relative resolution helpers.
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
	-- Percent-encodes bytes outside LuaSocket's unreserved set.
	escape: function(value: string): string
	-- Decodes percent-escaped bytes.
	unescape: function(value: string): string
	-- Splits a URL into named components, optionally seeded with defaults.
	parse: function(value: string, defaults?: URLParts): URLParts | nil, string | nil
	-- Rebuilds a URL from parsed components.
	build: function(parts: URLParts): string
	-- Resolves a relative URL against a base URL.
	absolute: function(base: string | URLParts, relative: string): string
	-- Splits and decodes a URL path into segments.
	parse_path: function(path: string): {string}
	-- Joins path segments and escapes them unless unsafe is true.
	build_path: function(path: {string}, unsafe?: boolean): string
end

return url
