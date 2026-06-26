-- [ts]: primitives.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Color = ____Dora.Color -- 1
local nvg = require("nvg") -- 2
local ____types = require("UIX.types") -- 5
local clamp = ____types.clamp -- 5
local ____color = require("UIX.paint.color") -- 6
local withAlpha = ____color.withAlpha -- 6
function ____exports.rect(width, height) -- 8
	return {x = 0, y = 0, width = width, height = height} -- 9
end -- 8
function ____exports.roundedPanel(ctx, r, options) -- 12
	local theme = ctx.theme -- 17
	local radius = options and options.radius or theme.radius.md -- 18
	local elevated = (options and options.elevated) ~= false -- 19
	if elevated then -- 19
		nvg.BeginPath() -- 21
		nvg.RoundedRect( -- 22
			r.x + 2, -- 22
			r.y + 3, -- 22
			r.width, -- 22
			r.height, -- 22
			radius -- 22
		) -- 22
		nvg.FillColor(Color(withAlpha(4278190080, theme.painter.shadowAlpha * ctx.opacity))) -- 23
		nvg.Fill() -- 24
	end -- 24
	local fill = (options and options.variant) == "solid" and theme.colors.surface.base or theme.colors.surface.raised -- 26
	nvg.BeginPath() -- 27
	nvg.RoundedRect( -- 28
		r.x, -- 28
		r.y, -- 28
		r.width, -- 28
		r.height, -- 28
		radius -- 28
	) -- 28
	nvg.FillColor(Color(withAlpha(fill, ctx.opacity))) -- 29
	nvg.Fill() -- 30
	nvg.BeginPath() -- 31
	nvg.RoundedRect( -- 32
		r.x + 0.5, -- 32
		r.y + 0.5, -- 32
		r.width - 1, -- 32
		r.height - 1, -- 32
		radius -- 32
	) -- 32
	nvg.StrokeWidth(theme.stroke.hairline) -- 33
	nvg.StrokeColor(Color(withAlpha(theme.colors.line.normal, ctx.opacity))) -- 34
	nvg.Stroke() -- 35
end -- 12
function ____exports.buttonSurface(ctx, r, options) -- 38
	local theme = ctx.theme -- 42
	local state = ctx.state -- 43
	local variant = options and options.variant or "primary" -- 44
	local radius = options and options.radius or theme.radius.md -- 45
	local fill = theme.colors.surface.raised -- 46
	local stroke = theme.colors.line.normal -- 47
	if variant == "primary" then -- 47
		stroke = theme.colors.accent.primary -- 48
	end -- 48
	if variant == "secondary" then -- 48
		stroke = theme.colors.accent.secondary -- 49
	end -- 49
	if variant == "danger" then -- 49
		stroke = theme.colors.state.danger -- 50
	end -- 50
	if variant == "glass" then -- 50
		fill = withAlpha(theme.colors.surface.raised, 0.78) -- 51
	end -- 51
	if variant == "ghost" then -- 51
		fill = withAlpha(theme.colors.surface.raised, (state.hovered or state.pressed) and 0.45 or 0.08) -- 52
	end -- 52
	if state.selected then -- 52
		fill = withAlpha(theme.colors.accent.primary, 0.35) -- 53
	end -- 53
	if state.pressed then -- 53
		fill = theme.colors.surface.sunken -- 54
	end -- 54
	if state.disabled then -- 54
		fill = withAlpha(theme.colors.surface.sunken, theme.painter.disabledAlpha) -- 56
		stroke = theme.colors.line.subtle -- 57
	end -- 57
	nvg.BeginPath() -- 59
	nvg.RoundedRect( -- 60
		r.x, -- 60
		r.y, -- 60
		r.width, -- 60
		r.height, -- 60
		radius -- 60
	) -- 60
	nvg.FillColor(Color(withAlpha(fill, ctx.opacity))) -- 61
	nvg.Fill() -- 62
	if not state.disabled and (state.hovered or state.selected) then -- 62
		nvg.BeginPath() -- 64
		nvg.RoundedRect( -- 65
			r.x + 1, -- 65
			r.y + 1, -- 65
			r.width - 2, -- 65
			r.height - 2, -- 65
			radius -- 65
		) -- 65
		nvg.FillColor(Color(withAlpha(theme.colors.accent.primary, 0.12 * ctx.opacity))) -- 66
		nvg.Fill() -- 67
	end -- 67
	nvg.BeginPath() -- 69
	nvg.RoundedRect( -- 70
		r.x + 0.5, -- 70
		r.y + 0.5, -- 70
		r.width - 1, -- 70
		r.height - 1, -- 70
		radius -- 70
	) -- 70
	nvg.StrokeWidth(state.focused and theme.stroke.normal or theme.stroke.hairline) -- 71
	nvg.StrokeColor(Color(withAlpha(stroke, state.disabled and 0.45 or ctx.opacity))) -- 72
	nvg.Stroke() -- 73
end -- 38
function ____exports.progressTrack(ctx, r) -- 76
	local theme = ctx.theme -- 77
	nvg.BeginPath() -- 78
	nvg.RoundedRect( -- 79
		r.x, -- 79
		r.y, -- 79
		r.width, -- 79
		r.height, -- 79
		math.min(theme.radius.sm, r.height / 2) -- 79
	) -- 79
	nvg.FillColor(Color(withAlpha(theme.colors.surface.sunken, ctx.opacity))) -- 80
	nvg.Fill() -- 81
	nvg.StrokeWidth(theme.stroke.hairline) -- 82
	nvg.StrokeColor(Color(withAlpha(theme.colors.line.subtle, ctx.opacity))) -- 83
	nvg.Stroke() -- 84
end -- 76
function ____exports.progressFill(ctx, r, progress, variant) -- 87
	local theme = ctx.theme -- 88
	local p = clamp(progress, 0, 1) -- 89
	if p <= 0 then -- 89
		return -- 90
	end -- 90
	local color = theme.colors.accent.primary -- 91
	if variant == "health" then -- 91
		color = theme.colors.state.danger -- 92
	end -- 92
	if variant == "mana" then -- 92
		color = theme.colors.state.mana -- 93
	end -- 93
	if variant == "shield" then -- 93
		color = theme.colors.state.shield -- 94
	end -- 94
	if variant == "warm" then -- 94
		color = theme.colors.accent.warm -- 95
	end -- 95
	local width = math.max(1, r.width * p) -- 96
	nvg.BeginPath() -- 97
	nvg.RoundedRect( -- 98
		r.x, -- 98
		r.y, -- 98
		width, -- 98
		r.height, -- 98
		math.min(theme.radius.sm, r.height / 2) -- 98
	) -- 98
	nvg.FillColor(Color(withAlpha(color, ctx.opacity))) -- 99
	nvg.Fill() -- 100
end -- 87
function ____exports.focusRing(ctx, r, options) -- 103
	if not ctx.state.focused or ctx.state.disabled then -- 103
		return -- 108
	end -- 108
	local theme = ctx.theme -- 109
	local inset = options and options.inset or -2 -- 110
	local radius = options and options.radius or theme.radius.md + 2 -- 111
	nvg.BeginPath() -- 112
	nvg.RoundedRect( -- 113
		r.x + inset, -- 113
		r.y + inset, -- 113
		r.width - inset * 2, -- 113
		r.height - inset * 2, -- 113
		radius -- 113
	) -- 113
	nvg.StrokeWidth(theme.stroke.focus) -- 114
	nvg.StrokeColor(Color(withAlpha(options and options.color or theme.colors.focus.ring, ctx.opacity))) -- 115
	nvg.Stroke() -- 116
end -- 103
function ____exports.cooldownMask(ctx, r, progress) -- 119
	local p = clamp(progress, 0, 1) -- 120
	if p <= 0 then -- 120
		return -- 121
	end -- 121
	local height = r.height * p -- 122
	nvg.BeginPath() -- 123
	nvg.RoundedRect( -- 124
		r.x, -- 124
		r.y, -- 124
		r.width, -- 124
		height, -- 124
		ctx.theme.radius.md -- 124
	) -- 124
	nvg.FillColor(Color(withAlpha(ctx.theme.colors.accent.primary, 0.34 * ctx.opacity))) -- 125
	nvg.Fill() -- 126
end -- 119
local function itemQualityColor(ctx, quality) -- 129
	if quality == "rare" then -- 129
		return ctx.theme.colors.accent.secondary -- 130
	end -- 130
	if quality == "epic" then -- 130
		return 4290272511 -- 131
	end -- 131
	if quality == "legendary" then -- 131
		return ctx.theme.colors.accent.warm -- 132
	end -- 132
	if quality == "common" then -- 132
		return ctx.theme.colors.line.strong -- 133
	end -- 133
	return ctx.theme.colors.line.subtle -- 134
end -- 129
function ____exports.itemSlotSurface(ctx, r, quality, selected) -- 137
	local theme = ctx.theme -- 138
	local radius = theme.radius.md -- 139
	local state = ctx.state -- 140
	local fill = state.disabled and withAlpha(theme.colors.surface.sunken, theme.painter.disabledAlpha) or theme.colors.surface.sunken -- 141
	local stroke = itemQualityColor(ctx, quality) -- 142
	if state.pressed then -- 142
		stroke = theme.colors.text.primary -- 143
	end -- 143
	if selected == true or state.selected then -- 143
		stroke = theme.colors.accent.primary -- 144
	end -- 144
	nvg.BeginPath() -- 145
	nvg.RoundedRect( -- 146
		r.x, -- 146
		r.y, -- 146
		r.width, -- 146
		r.height, -- 146
		radius -- 146
	) -- 146
	nvg.FillColor(Color(withAlpha(fill, ctx.opacity))) -- 147
	nvg.Fill() -- 148
	if quality ~= "empty" and not state.disabled then -- 148
		nvg.BeginPath() -- 150
		nvg.RoundedRect( -- 151
			r.x + 3, -- 151
			r.y + 3, -- 151
			r.width - 6, -- 151
			r.height - 6, -- 151
			math.max(1, radius - 2) -- 151
		) -- 151
		nvg.FillColor(Color(withAlpha(stroke, (selected == true or state.selected) and 0.24 or 0.12))) -- 152
		nvg.Fill() -- 153
	end -- 153
	nvg.BeginPath() -- 155
	nvg.RoundedRect( -- 156
		r.x + 0.5, -- 156
		r.y + 0.5, -- 156
		r.width - 1, -- 156
		r.height - 1, -- 156
		radius -- 156
	) -- 156
	nvg.StrokeWidth((selected == true or state.selected) and theme.stroke.normal or theme.stroke.hairline) -- 157
	nvg.StrokeColor(Color(withAlpha(stroke, state.disabled and 0.38 or ctx.opacity))) -- 158
	nvg.Stroke() -- 159
end -- 137
return ____exports -- 137