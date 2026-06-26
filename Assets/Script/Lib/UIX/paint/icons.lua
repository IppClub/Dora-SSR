-- [ts]: icons.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Color = ____Dora.Color -- 1
local nvg = require("nvg") -- 2
local function lineIcon(points, rect, color, width) -- 8
	nvg.BeginPath() -- 9
	for i = 1, #points / 2 do -- 9
		local x = rect.x + points[(i - 1) * 2 + 1] * rect.width -- 11
		local y = rect.y + points[(i - 1) * 2 + 1 + 1] * rect.height -- 12
		if i == 1 then -- 12
			nvg.MoveTo(x, y) -- 13
		else -- 13
			nvg.LineTo(x, y) -- 14
		end -- 14
	end -- 14
	nvg.StrokeWidth(width) -- 16
	nvg.StrokeColor(Color(color)) -- 17
	nvg.Stroke() -- 18
end -- 8
____exports.iconPainters = { -- 21
	play = function(_ctx, r, color) -- 22
		nvg.BeginPath() -- 23
		nvg.MoveTo(r.x + r.width * 0.32, r.y + r.height * 0.22) -- 24
		nvg.LineTo(r.x + r.width * 0.32, r.y + r.height * 0.78) -- 25
		nvg.LineTo(r.x + r.width * 0.78, r.y + r.height * 0.5) -- 26
		nvg.ClosePath() -- 27
		nvg.FillColor(Color(color)) -- 28
		nvg.Fill() -- 29
	end, -- 22
	close = function(_ctx, r, color) -- 31
		lineIcon({0.25, 0.25, 0.75, 0.75}, r, color, 2) -- 32
		lineIcon({0.75, 0.25, 0.25, 0.75}, r, color, 2) -- 33
	end, -- 31
	gear = function(_ctx, r, color) -- 35
		nvg.BeginPath() -- 36
		nvg.Circle( -- 37
			r.x + r.width / 2, -- 37
			r.y + r.height / 2, -- 37
			math.min(r.width, r.height) * 0.32 -- 37
		) -- 37
		nvg.StrokeWidth(2) -- 38
		nvg.StrokeColor(Color(color)) -- 39
		nvg.Stroke() -- 40
		nvg.BeginPath() -- 41
		nvg.Circle( -- 42
			r.x + r.width / 2, -- 42
			r.y + r.height / 2, -- 42
			math.min(r.width, r.height) * 0.11 -- 42
		) -- 42
		nvg.FillColor(Color(color)) -- 43
		nvg.Fill() -- 44
	end, -- 35
	coin = function(_ctx, r, color) -- 46
		nvg.BeginPath() -- 47
		nvg.Circle( -- 48
			r.x + r.width / 2, -- 48
			r.y + r.height / 2, -- 48
			math.min(r.width, r.height) * 0.38 -- 48
		) -- 48
		nvg.FillColor(Color(color)) -- 49
		nvg.Fill() -- 50
		nvg.BeginPath() -- 51
		nvg.Circle( -- 52
			r.x + r.width / 2, -- 52
			r.y + r.height / 2, -- 52
			math.min(r.width, r.height) * 0.24 -- 52
		) -- 52
		nvg.StrokeWidth(2) -- 53
		nvg.StrokeColor(Color(1426063360)) -- 54
		nvg.Stroke() -- 55
	end, -- 46
	heart = function(_ctx, r, color) -- 57
		nvg.BeginPath() -- 58
		nvg.MoveTo(r.x + r.width * 0.5, r.y + r.height * 0.78) -- 59
		nvg.BezierTo( -- 60
			r.x + r.width * 0.18, -- 60
			r.y + r.height * 0.55, -- 60
			r.x + r.width * 0.15, -- 60
			r.y + r.height * 0.25, -- 60
			r.x + r.width * 0.36, -- 60
			r.y + r.height * 0.25 -- 60
		) -- 60
		nvg.BezierTo( -- 61
			r.x + r.width * 0.46, -- 61
			r.y + r.height * 0.25, -- 61
			r.x + r.width * 0.5, -- 61
			r.y + r.height * 0.36, -- 61
			r.x + r.width * 0.5, -- 61
			r.y + r.height * 0.36 -- 61
		) -- 61
		nvg.BezierTo( -- 62
			r.x + r.width * 0.5, -- 62
			r.y + r.height * 0.36, -- 62
			r.x + r.width * 0.54, -- 62
			r.y + r.height * 0.25, -- 62
			r.x + r.width * 0.64, -- 62
			r.y + r.height * 0.25 -- 62
		) -- 62
		nvg.BezierTo( -- 63
			r.x + r.width * 0.85, -- 63
			r.y + r.height * 0.25, -- 63
			r.x + r.width * 0.82, -- 63
			r.y + r.height * 0.55, -- 63
			r.x + r.width * 0.5, -- 63
			r.y + r.height * 0.78 -- 63
		) -- 63
		nvg.FillColor(Color(color)) -- 64
		nvg.Fill() -- 65
	end, -- 57
	mana = function(_ctx, r, color) -- 67
		nvg.BeginPath() -- 68
		nvg.MoveTo(r.x + r.width * 0.5, r.y + r.height * 0.12) -- 69
		nvg.BezierTo( -- 70
			r.x + r.width * 0.28, -- 70
			r.y + r.height * 0.42, -- 70
			r.x + r.width * 0.2, -- 70
			r.y + r.height * 0.58, -- 70
			r.x + r.width * 0.5, -- 70
			r.y + r.height * 0.86 -- 70
		) -- 70
		nvg.BezierTo( -- 71
			r.x + r.width * 0.8, -- 71
			r.y + r.height * 0.58, -- 71
			r.x + r.width * 0.72, -- 71
			r.y + r.height * 0.42, -- 71
			r.x + r.width * 0.5, -- 71
			r.y + r.height * 0.12 -- 71
		) -- 71
		nvg.FillColor(Color(color)) -- 72
		nvg.Fill() -- 73
	end, -- 67
	lock = function(_ctx, r, color) -- 75
		nvg.BeginPath() -- 76
		nvg.RoundedRect( -- 77
			r.x + r.width * 0.25, -- 77
			r.y + r.height * 0.44, -- 77
			r.width * 0.5, -- 77
			r.height * 0.38, -- 77
			3 -- 77
		) -- 77
		nvg.FillColor(Color(color)) -- 78
		nvg.Fill() -- 79
		nvg.BeginPath() -- 80
		nvg.Arc( -- 81
			r.x + r.width * 0.5, -- 81
			r.y + r.height * 0.45, -- 81
			r.width * 0.22, -- 81
			math.pi, -- 81
			math.pi * 2, -- 81
			"CW" -- 81
		) -- 81
		nvg.StrokeWidth(2) -- 82
		nvg.StrokeColor(Color(color)) -- 83
		nvg.Stroke() -- 84
	end, -- 75
	check = function(_ctx, r, color) -- 86
		lineIcon({ -- 87
			0.22, -- 87
			0.52, -- 87
			0.42, -- 87
			0.72, -- 87
			0.78, -- 87
			0.28 -- 87
		}, r, color, 3) -- 87
	end, -- 86
	warning = function(_ctx, r, color) -- 89
		nvg.BeginPath() -- 90
		nvg.MoveTo(r.x + r.width * 0.5, r.y + r.height * 0.16) -- 91
		nvg.LineTo(r.x + r.width * 0.86, r.y + r.height * 0.82) -- 92
		nvg.LineTo(r.x + r.width * 0.14, r.y + r.height * 0.82) -- 93
		nvg.ClosePath() -- 94
		nvg.StrokeWidth(2) -- 95
		nvg.StrokeColor(Color(color)) -- 96
		nvg.Stroke() -- 97
	end, -- 89
	arrow = function(_ctx, r, color) -- 99
		lineIcon({ -- 100
			0.25, -- 100
			0.5, -- 100
			0.75, -- 100
			0.5, -- 100
			0.55, -- 100
			0.3, -- 100
			0.75, -- 100
			0.5, -- 100
			0.55, -- 100
			0.7 -- 100
		}, r, color, 2) -- 100
	end -- 99
} -- 99
function ____exports.drawIcon(name, ctx, rect, color) -- 104
	nvg.Save() -- 105
	nvg.Translate(rect.x, rect.y + rect.height) -- 106
	nvg.Scale(1, -1) -- 107
	local drawRect = {x = 0, y = 0, width = rect.width, height = rect.height} -- 108
	local painter = ____exports.iconPainters[name] -- 109
	if painter ~= nil then -- 109
		painter(ctx, drawRect, color) -- 111
		nvg.Restore() -- 112
		return -- 113
	end -- 113
	nvg.BeginPath() -- 115
	nvg.RoundedRect( -- 116
		2, -- 116
		2, -- 116
		rect.width - 4, -- 116
		rect.height - 4, -- 116
		3 -- 116
	) -- 116
	nvg.StrokeWidth(2) -- 117
	nvg.StrokeColor(Color(color)) -- 118
	nvg.Stroke() -- 119
	nvg.Restore() -- 120
end -- 104
return ____exports -- 104