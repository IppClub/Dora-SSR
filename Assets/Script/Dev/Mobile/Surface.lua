-- [ts]: Surface.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayPush = ____lualib.__TS__ArrayPush -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Color = ____Dora.Color -- 1
local Vec2 = ____Dora.Vec2 -- 1
function ____exports.surfaceColor(bottom, top, fraction) -- 11
	local t = math.max( -- 12
		0, -- 12
		math.min(1, fraction) -- 12
	) -- 12
	local result = 0 -- 13
	for ____, divisor in ipairs({16777216, 65536, 256, 1}) do -- 14
		local a = math.floor(bottom / divisor) % 256 -- 15
		local b = math.floor(top / divisor) % 256 -- 16
		result = result + math.floor(a + (b - a) * t + 0.5) * divisor -- 17
	end -- 17
	return result -- 19
end -- 11
function ____exports.roundedSurfaceVertices(width, height, radius) -- 22
	local verts = {} -- 23
	local r = math.max( -- 24
		0, -- 24
		math.min(radius, width / 2, height / 2) -- 24
	) -- 24
	for ____, corner in ipairs({{x = width - r, y = r, a = -math.pi / 2}, {x = width - r, y = height - r, a = 0}, {x = r, y = height - r, a = math.pi / 2}, {x = r, y = r, a = math.pi}}) do -- 25
		do -- 25
			local i = 0 -- 26
			while i <= 8 do -- 26
				local a = corner.a + i * math.pi / 16 -- 27
				verts[#verts + 1] = Vec2( -- 28
					corner.x + math.cos(a) * r, -- 28
					corner.y + math.sin(a) * r -- 28
				) -- 28
				i = i + 1 -- 26
			end -- 26
		end -- 26
	end -- 26
	return verts -- 31
end -- 22
function ____exports.paintSurface(draw, width, height, radius, style) -- 37
	local outline = ____exports.roundedSurfaceVertices(width, height, radius) -- 38
	if style.shadow then -- 38
		draw:drawPolygon( -- 40
			__TS__ArrayMap( -- 40
				outline, -- 40
				function(____, v) return Vec2(v.x + 2, v.y - 3) end -- 40
			), -- 40
			Color(1375731712) -- 40
		) -- 40
	end -- 40
	local bottom = style.bottomColor or style.topColor -- 42
	local function colorAt(y) -- 43
		return Color(____exports.surfaceColor(bottom, style.topColor, height > 0 and y / height or 0)) -- 43
	end -- 43
	local center = Vec2(width / 2, height / 2) -- 44
	local centerColor = colorAt(center.y) -- 45
	local verts = {} -- 46
	do -- 46
		local i = 0 -- 47
		while i < #outline do -- 47
			local a = outline[i + 1] -- 48
			local b = outline[(i + 1) % #outline + 1] -- 48
			__TS__ArrayPush( -- 49
				verts, -- 49
				{center, centerColor}, -- 49
				{ -- 49
					a, -- 49
					colorAt(a.y) -- 49
				}, -- 49
				{ -- 49
					b, -- 49
					colorAt(b.y) -- 49
				} -- 49
			) -- 49
			i = i + 1 -- 47
		end -- 47
	end -- 47
	draw:drawVertices(verts) -- 51
	if style.borderColor ~= nil then -- 51
		draw:drawPolygon( -- 52
			outline, -- 52
			Color(0), -- 52
			style.borderWidth or 1, -- 52
			Color(style.borderColor) -- 52
		) -- 52
	end -- 52
end -- 37
return ____exports -- 37