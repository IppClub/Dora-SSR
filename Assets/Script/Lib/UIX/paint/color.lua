-- [ts]: color.ts
local ____exports = {} -- 1
function ____exports.withAlpha(color, alpha) -- 1
	local a = math.floor(math.max( -- 2
		0, -- 2
		math.min(1, alpha) -- 2
	) * 255) -- 2
	return color & 16777215 | a << 24 -- 3
end -- 1
function ____exports.mixColor(a, b, t) -- 6
	local ratio = math.max( -- 7
		0, -- 7
		math.min(1, t) -- 7
	) -- 7
	local aa = (a & 4294967295) >> 24 & 255 -- 8
	local ar = (a & 4294967295) >> 16 & 255 -- 9
	local ag = (a & 4294967295) >> 8 & 255 -- 10
	local ab = a & 255 -- 11
	local ba = (b & 4294967295) >> 24 & 255 -- 12
	local br = (b & 4294967295) >> 16 & 255 -- 13
	local bg = (b & 4294967295) >> 8 & 255 -- 14
	local bb = b & 255 -- 15
	local rr = math.floor(ar + (br - ar) * ratio) -- 16
	local rg = math.floor(ag + (bg - ag) * ratio) -- 17
	local rb = math.floor(ab + (bb - ab) * ratio) -- 18
	local ra = math.floor(aa + (ba - aa) * ratio) -- 19
	return ra << 24 | rr << 16 | rg << 8 | rb -- 20
end -- 6
return ____exports -- 6