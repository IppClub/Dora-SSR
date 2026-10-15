-- [tsx]: Visual.tsx
local ____exports = {} -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local ____Dora = require("Dora") -- 2
local Color = ____Dora.Color -- 2
local Node = ____Dora.Node -- 2
local Size = ____Dora.Size -- 2
local Vec2 = ____Dora.Vec2 -- 2
local nvg = require("nvg") -- 3
--- NanoVG surface following Dora-Example/UIX's PaintNode + roundedPanel pattern.
function ____exports.RoundedSurface(props) -- 22
	local function onCreate() -- 23
		local node = Node() -- 24
		node.anchor = Vec2.zero -- 25
		node.size = Size(props.width, props.height) -- 26
		node:onRender(function() -- 27
			nvg.Save() -- 28
			nvg.ApplyTransform(node) -- 29
			local radius = math.max( -- 30
				0, -- 30
				math.min(props.radius, props.width / 2, props.height / 2) -- 30
			) -- 30
			if props.shadow then -- 30
				nvg.BeginPath() -- 32
				nvg.RoundedRect( -- 33
					2, -- 33
					-3, -- 33
					props.width, -- 33
					props.height, -- 33
					radius -- 33
				) -- 33
				nvg.FillColor(Color(1375731712)) -- 34
				nvg.Fill() -- 35
			end -- 35
			nvg.BeginPath() -- 37
			nvg.RoundedRect( -- 38
				0, -- 38
				0, -- 38
				props.width, -- 38
				props.height, -- 38
				radius -- 38
			) -- 38
			if props.topColor ~= nil and props.bottomColor ~= nil then -- 38
				nvg.FillPaint(nvg.LinearGradient( -- 40
					0, -- 40
					props.height, -- 40
					0, -- 40
					0, -- 40
					Color(props.topColor), -- 40
					Color(props.bottomColor) -- 40
				)) -- 40
			else -- 40
				nvg.FillColor(Color(props.fillColor or 4294967295)) -- 42
			end -- 42
			nvg.Fill() -- 44
			local borderWidth = props.borderWidth or 0 -- 45
			if borderWidth > 0 then -- 45
				nvg.BeginPath() -- 47
				nvg.RoundedRect( -- 48
					borderWidth / 2, -- 48
					borderWidth / 2, -- 48
					props.width - borderWidth, -- 48
					props.height - borderWidth, -- 48
					math.max(0, radius - borderWidth / 2) -- 48
				) -- 48
				nvg.StrokeWidth(borderWidth) -- 49
				nvg.StrokeColor(Color(props.borderColor or 4294967295)) -- 50
				nvg.Stroke() -- 51
			end -- 51
			nvg.Restore() -- 53
			return false -- 54
		end) -- 27
		return node -- 56
	end -- 23
	return React.createElement("custom-node", { -- 58
		x = props.x or 0, -- 58
		y = props.y or 0, -- 58
		width = props.width, -- 58
		height = props.height, -- 58
		opacity = props.opacity or 1, -- 58
		renderOrder = props.renderOrder, -- 58
		onCreate = onCreate -- 58
	}) -- 58
end -- 22
function ____exports.VerticalGradient(props) -- 61
	local function onCreate() -- 62
		local node = Node() -- 63
		node.anchor = Vec2.zero -- 64
		node.size = Size(props.width, props.height) -- 65
		node:onRender(function() -- 66
			nvg.Save() -- 67
			nvg.ApplyTransform(node) -- 68
			nvg.BeginPath() -- 69
			nvg.Rect(0, 0, props.width, props.height) -- 70
			nvg.FillPaint(nvg.LinearGradient( -- 71
				0, -- 71
				props.height, -- 71
				0, -- 71
				0, -- 71
				Color(props.topColor), -- 71
				Color(props.bottomColor) -- 71
			)) -- 71
			nvg.Fill() -- 72
			nvg.Restore() -- 73
			return false -- 74
		end) -- 66
		return node -- 76
	end -- 62
	return React.createElement("custom-node", { -- 78
		x = props.x or 0, -- 78
		y = props.y or 0, -- 78
		width = props.width, -- 78
		height = props.height, -- 78
		onCreate = onCreate -- 78
	}) -- 78
end -- 61
function ____exports.roundedRectVerts(width, height, radius) -- 81
	local r = math.max( -- 82
		0, -- 82
		math.min(radius, width / 2, height / 2) -- 82
	) -- 82
	local verts = {} -- 83
	local corners = {{x = width - r, y = r, start = -math.pi / 2}, {x = width - r, y = height - r, start = 0}, {x = r, y = height - r, start = math.pi / 2}, {x = r, y = r, start = math.pi}} -- 84
	for ____, corner in ipairs(corners) do -- 90
		do -- 90
			local step = 0 -- 91
			while step <= 6 do -- 91
				local angle = corner.start + step * math.pi / 12 -- 92
				verts[#verts + 1] = Vec2( -- 93
					corner.x + math.cos(angle) * r, -- 93
					corner.y + math.sin(angle) * r -- 93
				) -- 93
				step = step + 1 -- 91
			end -- 91
		end -- 91
	end -- 91
	return verts -- 96
end -- 81
--- Stencil-only rounded path for clipping sprites and other scene nodes.
function ____exports.RoundedStencil(props) -- 100
	return React.createElement( -- 101
		"draw-node", -- 101
		nil, -- 101
		React.createElement( -- 101
			"polygon-shape", -- 101
			{ -- 101
				verts = ____exports.roundedRectVerts(props.width, props.height, props.radius), -- 101
				fillColor = 4294967295 -- 101
			} -- 101
		) -- 101
	) -- 101
end -- 100
return ____exports -- 100