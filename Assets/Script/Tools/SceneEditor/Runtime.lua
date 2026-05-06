-- [ts]: Runtime.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Color = ____Dora.Color -- 1
local Director = ____Dora.Director -- 1
local DrawNode = ____Dora.DrawNode -- 1
local Label = ____Dora.Label -- 1
local Line = ____Dora.Line -- 1
local Node = ____Dora.Node -- 1
local Sprite = ____Dora.Sprite -- 1
local Vec2 = ____Dora.Vec2 -- 1
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 3
local greenAxisColor = ____Theme.greenAxisColor -- 3
local gridMajorColor = ____Theme.gridMajorColor -- 3
local gridMinorColor = ____Theme.gridMinorColor -- 3
local redAxisColor = ____Theme.redAxisColor -- 3
local function worldPointFromScreen(screenX, screenY) -- 5
	local size = App.visualSize -- 6
	return {screenX - size.width / 2, size.height / 2 - screenY} -- 7
end -- 5
local function makeLine(points, color) -- 10
	return Line(points, color) -- 11
end -- 10
local function makeThickLine(a, b, color, horizontal) -- 14
	local node = Node() -- 15
	do -- 15
		local offset = -2 -- 16
		while offset <= 2 do -- 16
			if horizontal then -- 16
				node:addChild(makeLine( -- 18
					{ -- 18
						Vec2(a.x, a.y + offset), -- 18
						Vec2(b.x, b.y + offset) -- 18
					}, -- 18
					color -- 18
				)) -- 18
			else -- 18
				node:addChild(makeLine( -- 20
					{ -- 20
						Vec2(a.x + offset, a.y), -- 20
						Vec2(b.x + offset, b.y) -- 20
					}, -- 20
					color -- 20
				)) -- 20
			end -- 20
			offset = offset + 1 -- 16
		end -- 16
	end -- 16
	return node -- 23
end -- 14
local function makeRectLine(width, height, color) -- 26
	local hw = width / 2 -- 27
	local hh = height / 2 -- 28
	return makeLine( -- 29
		{ -- 29
			Vec2(-hw, -hh), -- 30
			Vec2(hw, -hh), -- 31
			Vec2(hw, hh), -- 32
			Vec2(-hw, hh), -- 33
			Vec2(-hw, -hh) -- 34
		}, -- 34
		color -- 35
	) -- 35
end -- 26
local function makeCanvasBackground(width, height) -- 38
	local hw = width / 2 -- 39
	local hh = height / 2 -- 40
	local bg = DrawNode() -- 41
	bg:drawPolygon( -- 42
		{ -- 42
			Vec2(-hw, -hh), -- 43
			Vec2(hw, -hh), -- 44
			Vec2(hw, hh), -- 45
			Vec2(-hw, hh) -- 46
		}, -- 46
		Color(4278915352), -- 47
		6, -- 47
		Color(4294954035) -- 47
	) -- 47
	return bg -- 48
end -- 38
local function makeGridLine(width, height) -- 51
	local grid = Node() -- 52
	local hw = width / 2 -- 53
	local hh = height / 2 -- 54
	local step = 32 -- 55
	local minor = DrawNode() -- 56
	local major = DrawNode() -- 57
	local i = 0 -- 58
	local x = -math.floor(hw / step) * step -- 59
	while x <= hw do -- 59
		if i % 5 == 0 then -- 59
			major:drawSegment( -- 62
				Vec2(x, -hh), -- 62
				Vec2(x, hh), -- 62
				1.2, -- 62
				gridMajorColor -- 62
			) -- 62
		else -- 62
			minor:drawSegment( -- 64
				Vec2(x, -hh), -- 64
				Vec2(x, hh), -- 64
				0.55, -- 64
				gridMinorColor -- 64
			) -- 64
		end -- 64
		x = x + step -- 66
		i = i + 1 -- 67
	end -- 67
	i = 0 -- 69
	local y = -math.floor(hh / step) * step -- 70
	while y <= hh do -- 70
		if i % 5 == 0 then -- 70
			major:drawSegment( -- 73
				Vec2(-hw, y), -- 73
				Vec2(hw, y), -- 73
				1.2, -- 73
				gridMajorColor -- 73
			) -- 73
		else -- 73
			minor:drawSegment( -- 75
				Vec2(-hw, y), -- 75
				Vec2(hw, y), -- 75
				0.55, -- 75
				gridMinorColor -- 75
			) -- 75
		end -- 75
		y = y + step -- 77
		i = i + 1 -- 78
	end -- 78
	grid:addChild(minor) -- 80
	grid:addChild(major) -- 81
	return grid -- 82
end -- 51
local function makeAxisLine(width, height) -- 85
	local hw = width / 2 -- 86
	local hh = height / 2 -- 87
	local axis = Node() -- 88
	local xAxis = DrawNode() -- 89
	xAxis:drawSegment( -- 90
		Vec2(-hw, 0), -- 90
		Vec2(hw, 0), -- 90
		3.5, -- 90
		redAxisColor -- 90
	) -- 90
	local yAxis = DrawNode() -- 91
	yAxis:drawSegment( -- 92
		Vec2(0, -hh), -- 92
		Vec2(0, hh), -- 92
		3.5, -- 92
		greenAxisColor -- 92
	) -- 92
	axis:addChild(xAxis) -- 93
	axis:addChild(yAxis) -- 94
	return axis -- 95
end -- 85
local function makeSpritePlaceholder() -- 98
	local node = Node() -- 99
	local frame = makeRectLine( -- 100
		96, -- 100
		64, -- 100
		Color(4283409407) -- 100
	) -- 100
	frame:addChild(makeLine( -- 101
		{ -- 101
			Vec2(-48, -32), -- 101
			Vec2(48, 32), -- 101
			Vec2(-48, 32), -- 101
			Vec2(48, -32) -- 101
		}, -- 101
		Color(4283409407) -- 101
	)) -- 101
	node:addChild(frame) -- 102
	return node -- 103
end -- 98
local function makeCameraShape() -- 106
	local node = Node() -- 107
	node:addChild(makeRectLine( -- 108
		180, -- 108
		100, -- 108
		Color(4294954035) -- 108
	)) -- 108
	node:addChild(makeLine( -- 109
		{ -- 109
			Vec2(-90, 0), -- 109
			Vec2(90, 0), -- 109
			Vec2(0, -50), -- 109
			Vec2(0, 50) -- 109
		}, -- 109
		Color(4294954035) -- 109
	)) -- 109
	return node -- 110
end -- 106
local function createRuntimeVisual(state, item) -- 113
	local wrapper = Node() -- 114
	if item.kind == "Sprite" then -- 114
		local visual = nil -- 116
		if item.texture ~= "" then -- 116
			visual = Sprite(item.texture) -- 118
		end -- 118
		wrapper:addChild(visual ~= nil and visual or makeSpritePlaceholder()) -- 120
	elseif item.kind == "Label" then -- 120
		local label = Label("sarasa-mono-sc-regular", 32) -- 122
		if label ~= nil then -- 122
			label.text = item.text or "Label" -- 124
			state.runtimeLabels[item.id] = label -- 125
			wrapper:addChild(label) -- 126
		else -- 126
			wrapper:addChild(makeRectLine( -- 128
				120, -- 128
				38, -- 128
				Color(4292664540) -- 128
			)) -- 128
		end -- 128
	elseif item.kind == "Camera" then -- 128
		wrapper:addChild(makeCameraShape()) -- 131
	else -- 131
		wrapper:addChild(makeThickLine( -- 133
			Vec2(-14, 0), -- 133
			Vec2(14, 0), -- 133
			Color(4294967295), -- 133
			true -- 133
		)) -- 133
		wrapper:addChild(makeThickLine( -- 134
			Vec2(0, -14), -- 134
			Vec2(0, 14), -- 134
			Color(4294967295), -- 134
			false -- 134
		)) -- 134
	end -- 134
	return wrapper -- 136
end -- 113
function ____exports.rebuildPreviewRuntime(state) -- 139
	if state.previewRoot == nil then -- 139
		state.previewRoot = Node() -- 141
		state.previewRoot.tag = "__DoraImGuiEditorViewport__" -- 142
		Director.entry:addChild(state.previewRoot) -- 143
	end -- 143
	state.previewRoot:removeAllChildren(true) -- 145
	state.runtimeNodes = {} -- 146
	state.runtimeLabels = {} -- 147
	local renderScale = App.devicePixelRatio or 1 -- 149
	local width = math.max(160, state.preview.width * renderScale) -- 150
	local height = math.max(120, state.preview.height * renderScale) -- 151
	state.previewRoot:addChild(makeCanvasBackground(width, height)) -- 152
	if state.showGrid then -- 152
		state.previewRoot:addChild(makeGridLine(width, height)) -- 154
	end -- 154
	state.previewRoot:addChild(makeAxisLine(width, height)) -- 156
	do -- 156
		local offset = 0 -- 157
		while offset <= 8 do -- 157
			state.previewRoot:addChild(makeRectLine( -- 158
				width + offset, -- 158
				height + offset, -- 158
				Color(4294954035) -- 158
			)) -- 158
			offset = offset + 2 -- 157
		end -- 157
	end -- 157
	local content = Node() -- 161
	local scale = math.max(0.25, state.zoom / 100) -- 162
	content.scaleX = scale -- 163
	content.scaleY = scale -- 164
	state.previewContent = content -- 165
	state.previewRoot:addChild(content) -- 166
	state.runtimeNodes.root = content -- 167
	for ____, id in ipairs(state.order) do -- 169
		local item = state.nodes[id] -- 170
		if item ~= nil and id ~= "root" then -- 170
			local runtime = createRuntimeVisual(state, item) -- 172
			state.runtimeNodes[id] = runtime -- 173
			local parent = state.runtimeNodes[item.parentId or "root"] or content -- 174
			parent:addChild(runtime) -- 175
		end -- 175
	end -- 175
	state.previewDirty = false -- 178
end -- 139
function ____exports.updatePreviewRuntime(state) -- 181
	if state.previewDirty or state.previewRoot == nil then -- 181
		____exports.rebuildPreviewRuntime(state) -- 183
	end -- 183
	local p = state.preview -- 185
	local cx, cy = table.unpack( -- 186
		worldPointFromScreen(p.x + p.width / 2, p.y + p.height / 2), -- 186
		1, -- 186
		2 -- 186
	) -- 186
	local previewRoot = state.previewRoot -- 187
	if previewRoot == nil then -- 187
		return -- 188
	end -- 188
	previewRoot.x = cx -- 189
	previewRoot.y = cy -- 190
	if state.previewContent ~= nil then -- 190
		local scale = math.max(0.25, state.zoom / 100) -- 192
		state.previewContent.scaleX = scale -- 193
		state.previewContent.scaleY = scale -- 194
	end -- 194
	for ____, id in ipairs(state.order) do -- 196
		local item = state.nodes[id] -- 197
		local runtime = state.runtimeNodes[id] -- 198
		if item ~= nil and runtime ~= nil then -- 198
			runtime.x = item.x -- 200
			runtime.y = item.y -- 201
			runtime.scaleX = item.scaleX -- 202
			runtime.scaleY = item.scaleY -- 203
			runtime.angle = item.rotation -- 204
			runtime.visible = item.visible -- 205
			local label = state.runtimeLabels[id] -- 206
			if label ~= nil then -- 206
				label.text = item.text or "Label" -- 207
			end -- 207
		end -- 207
	end -- 207
end -- 181
return ____exports -- 181