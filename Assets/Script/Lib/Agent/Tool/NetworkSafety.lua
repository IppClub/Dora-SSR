-- [ts]: NetworkSafety.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringCharAt = ____lualib.__TS__StringCharAt -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__ArrayEvery = ____lualib.__TS__ArrayEvery -- 1
local ____exports = {} -- 1
local ____socket = require("socket") -- 2
local dns = ____socket.dns -- 2
function ____exports.isHttpUrl(url) -- 4
	local normalized = string.lower(__TS__StringTrim(url)) -- 5
	return __TS__StringStartsWith(normalized, "http://") or __TS__StringStartsWith(normalized, "https://") -- 6
end -- 4
function ____exports.getHttpUrlHost(url) -- 9
	local schemeEnd = (string.find(url, "://", nil, true) or 0) - 1 -- 10
	if schemeEnd < 0 then -- 10
		return nil -- 11
	end -- 11
	local authority = __TS__StringSlice(url, schemeEnd + 3) -- 12
	for ____, separator in ipairs({"/", "?", "#"}) do -- 13
		local index = (string.find(authority, separator, nil, true) or 0) - 1 -- 14
		if index >= 0 then -- 14
			authority = __TS__StringSlice(authority, 0, index) -- 15
		end -- 15
	end -- 15
	local at = -1 -- 17
	do -- 17
		local i = 0 -- 18
		while i < #authority do -- 18
			if __TS__StringCharAt(authority, i) == "@" then -- 18
				at = i -- 19
			end -- 19
			i = i + 1 -- 18
		end -- 18
	end -- 18
	if at >= 0 then -- 18
		authority = __TS__StringSlice(authority, at + 1) -- 21
	end -- 21
	if __TS__StringStartsWith(authority, "[") then -- 21
		local ____end = (string.find(authority, "]", nil, true) or 0) - 1 -- 23
		return ____end > 1 and string.lower(__TS__StringSlice(authority, 1, ____end)) or nil -- 24
	end -- 24
	local colon = -1 -- 26
	do -- 26
		local i = 0 -- 27
		while i < #authority do -- 27
			if __TS__StringCharAt(authority, i) == ":" then -- 27
				colon = i -- 28
			end -- 28
			i = i + 1 -- 27
		end -- 27
	end -- 27
	if colon >= 0 then -- 27
		authority = __TS__StringSlice(authority, 0, colon) -- 30
	end -- 30
	return authority ~= "" and string.lower(authority) or nil -- 31
end -- 9
function ____exports.isPrivateNetworkAddress(address) -- 34
	local normalized = string.lower(address) -- 35
	if __TS__StringIncludes(normalized, ":") then -- 35
		if normalized == "::" or normalized == "::1" then -- 35
			return true -- 37
		end -- 37
		if __TS__StringStartsWith(normalized, "fc") or __TS__StringStartsWith(normalized, "fd") then -- 37
			return true -- 38
		end -- 38
		if __TS__StringStartsWith(normalized, "fe8") or __TS__StringStartsWith(normalized, "fe9") or __TS__StringStartsWith(normalized, "fea") or __TS__StringStartsWith(normalized, "feb") then -- 38
			return true -- 39
		end -- 39
		local mappedPrefix = "::ffff:" -- 40
		if __TS__StringStartsWith(normalized, mappedPrefix) then -- 40
			return ____exports.isPrivateNetworkAddress(__TS__StringSlice(normalized, #mappedPrefix)) -- 41
		end -- 41
		return false -- 42
	end -- 42
	local parts = __TS__StringSplit(normalized, ".") -- 44
	if #parts ~= 4 then -- 44
		return true -- 45
	end -- 45
	local octets = {} -- 46
	for ____, part in ipairs(parts) do -- 47
		local value = __TS__Number(part) -- 48
		if part == "" or value < 0 or value > 255 or math.floor(value) ~= value then -- 48
			return true -- 49
		end -- 49
		octets[#octets + 1] = value -- 50
	end -- 50
	local first = octets[1] -- 52
	local second = octets[2] -- 53
	if first == 0 or first == 10 or first == 127 then -- 53
		return true -- 54
	end -- 54
	if first == 100 and second >= 64 and second <= 127 then -- 54
		return true -- 55
	end -- 55
	if first == 169 and second == 254 then -- 55
		return true -- 56
	end -- 56
	if first == 172 and second >= 16 and second <= 31 then -- 56
		return true -- 57
	end -- 57
	if first == 192 and (second == 0 or second == 168) then -- 57
		return true -- 58
	end -- 58
	if first == 198 and (second == 18 or second == 19) then -- 58
		return true -- 59
	end -- 59
	if first >= 224 then -- 59
		return true -- 60
	end -- 60
	return false -- 61
end -- 34
function ____exports.isSafePublicHttpUrl(url) -- 64
	if not ____exports.isHttpUrl(url) then -- 64
		return false -- 65
	end -- 65
	local host = ____exports.getHttpUrlHost(url) -- 66
	if not host then -- 66
		return false -- 67
	end -- 67
	if host == "localhost" or __TS__StringEndsWith(host, ".localhost") or __TS__StringEndsWith(host, ".local") then -- 67
		return false -- 68
	end -- 68
	if host == "metadata.google.internal" or __TS__StringEndsWith(host, ".internal") then -- 68
		return false -- 69
	end -- 69
	if __TS__StringIncludes(host, ":") then -- 69
		return false -- 70
	end -- 70
	local numericHost = string.match(host, "^[%d%.]+$") -- 71
	if numericHost ~= nil then -- 71
		return false -- 72
	end -- 72
	local ipv4 = __TS__StringSplit(host, ".") -- 73
	if #ipv4 == 4 and __TS__ArrayEvery( -- 73
		ipv4, -- 74
		function(____, part) return part ~= "" and __TS__Number(part) >= 0 and __TS__Number(part) <= 255 end -- 74
	) then -- 74
		return false -- 75
	end -- 75
	local addresses = dns.getaddrinfo(host) -- 77
	if not addresses or #addresses == 0 then -- 77
		return false -- 78
	end -- 78
	for ____, address in ipairs(addresses) do -- 79
		if ____exports.isPrivateNetworkAddress(address.addr) then -- 79
			return false -- 80
		end -- 80
	end -- 80
	return true -- 82
end -- 64
return ____exports -- 64