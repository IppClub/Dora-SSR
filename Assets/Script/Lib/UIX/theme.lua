-- [ts]: theme.ts
local ____exports = {} -- 1
____exports.doraPrismTheme = { -- 93
	name = "Dora Prism", -- 94
	colors = { -- 95
		surface = {base = 4279309853, raised = 4028310576, sunken = 3423079184, overlay = 3422881546}, -- 96
		line = {subtle = 2854892866, normal = 3426766946, strong = 3719940056}, -- 102
		accent = {primary = 4281716991, secondary = 4283268351, warm = 4294951258}, -- 107
		state = { -- 112
			danger = 4294922078, -- 113
			mana = 4283268351, -- 114
			shield = 4285587711, -- 115
			success = 4283881098, -- 116
			warning = 4294941757 -- 117
		}, -- 117
		text = {primary = 4294244607, secondary = 4288588989, disabled = 2858643584, inverse = 4278652951}, -- 119
		focus = {ring = 4281716991, glow = 1714802943} -- 125
	}, -- 125
	space = { -- 130
		xxs = 2, -- 130
		xs = 4, -- 130
		sm = 8, -- 130
		md = 12, -- 130
		lg = 16, -- 130
		xl = 24, -- 130
		xxl = 32 -- 130
	}, -- 130
	radius = { -- 131
		xs = 3, -- 131
		sm = 4, -- 131
		md = 8, -- 131
		lg = 12, -- 131
		xl = 16 -- 131
	}, -- 131
	stroke = {hairline = 1, normal = 2, strong = 3, focus = 3}, -- 132
	font = {name = "sarasa-mono-sc-regular", sdf = true, size = { -- 133
		xs = 11, -- 136
		sm = 13, -- 136
		md = 16, -- 136
		lg = 20, -- 136
		xl = 26 -- 136
	}}, -- 136
	size = {control = {sm = 32, md = 44, lg = 56}, icon = {sm = 16, md = 22, lg = 30}}, -- 138
	motion = {fast = 0.08, normal = 0.14, slow = 0.22}, -- 142
	painter = {shadowAlpha = 0.28, bevelAlpha = 0.32, disabledAlpha = 0.42} -- 143
} -- 143
function ____exports.mergeTheme(base, override) -- 150
	if override == nil then -- 150
		return base -- 151
	end -- 151
	return { -- 152
		name = override.name or base.name, -- 153
		colors = override.colors or base.colors, -- 154
		space = override.space or base.space, -- 155
		radius = override.radius or base.radius, -- 156
		stroke = override.stroke or base.stroke, -- 157
		font = override.font or base.font, -- 158
		size = override.size or base.size, -- 159
		motion = override.motion or base.motion, -- 160
		painter = override.painter or base.painter -- 161
	} -- 161
end -- 150
return ____exports -- 150