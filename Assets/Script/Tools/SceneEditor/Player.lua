-- [ts]: Player.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local ClipNode = ____Dora.ClipNode -- 1
local Color = ____Dora.Color -- 1
local Content = ____Dora.Content -- 1
local Director = ____Dora.Director -- 1
local DrawNode = ____Dora.DrawNode -- 1
local Label = ____Dora.Label -- 1
local Node = ____Dora.Node -- 1
local Path = ____Dora.Path -- 1
local Sprite = ____Dora.Sprite -- 1
local Vec2 = ____Dora.Vec2 -- 1
local ImGui = require("ImGui") -- 2
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 5
local okColor = ____Theme.okColor -- 5
local viewportBgColor = ____Theme.viewportBgColor -- 5
local viewportFrameColor = ____Theme.viewportFrameColor -- 5
local warnColor = ____Theme.warnColor -- 5
local ____Model = require("Script.Tools.SceneEditor.Model") -- 6
local pushConsole = ____Model.pushConsole -- 6
local zh = ____Model.zh -- 6
local function worldPointFromScreen(screenX, screenY) -- 12
	local size = App.visualSize -- 13
	return {screenX - size.width / 2, size.height / 2 - screenY} -- 14
end -- 12
local function makeClipStencil(width, height) -- 17
	local hw = width / 2 -- 18
	local hh = height / 2 -- 19
	local stencil = DrawNode() -- 20
	stencil:drawPolygon( -- 21
		{ -- 21
			Vec2(-hw, -hh), -- 22
			Vec2(hw, -hh), -- 23
			Vec2(hw, hh), -- 24
			Vec2(-hw, hh) -- 25
		}, -- 25
		Color(4294967295), -- 26
		0, -- 26
		Color() -- 26
	) -- 26
	return stencil -- 27
end -- 17
local function makeGameBackground(width, height) -- 30
	local hw = width / 2 -- 31
	local hh = height / 2 -- 32
	local bg = DrawNode() -- 33
	bg:drawPolygon( -- 34
		{ -- 34
			Vec2(-hw, -hh), -- 35
			Vec2(hw, -hh), -- 36
			Vec2(hw, hh), -- 37
			Vec2(-hw, hh) -- 38
		}, -- 38
		viewportBgColor, -- 39
		1, -- 39
		viewportFrameColor -- 39
	) -- 39
	return bg -- 40
end -- 30
local function makeFallbackRect(width, height, color) -- 43
	local hw = width / 2 -- 44
	local hh = height / 2 -- 45
	local rect = DrawNode() -- 46
	rect:drawSegment( -- 47
		Vec2(-hw, -hh), -- 47
		Vec2(hw, -hh), -- 47
		1, -- 47
		color -- 47
	) -- 47
	rect:drawSegment( -- 48
		Vec2(hw, -hh), -- 48
		Vec2(hw, hh), -- 48
		1, -- 48
		color -- 48
	) -- 48
	rect:drawSegment( -- 49
		Vec2(hw, hh), -- 49
		Vec2(-hw, hh), -- 49
		1, -- 49
		color -- 49
	) -- 49
	rect:drawSegment( -- 50
		Vec2(-hw, hh), -- 50
		Vec2(-hw, -hh), -- 50
		1, -- 50
		color -- 50
	) -- 50
	return rect -- 51
end -- 43
local function createPlayVisual(item) -- 54
	if item.kind == "Sprite" then -- 54
		if item.texture ~= "" then -- 54
			local sprite = Sprite(item.texture) -- 57
			if sprite ~= nil then -- 57
				return sprite -- 58
			end -- 58
		end -- 58
		return makeFallbackRect( -- 60
			128, -- 60
			96, -- 60
			Color(2859640520) -- 60
		) -- 60
	end -- 60
	if item.kind == "Label" then -- 60
		local label = Label("sarasa-mono-sc-regular", 32) -- 63
		if label ~= nil then -- 63
			label.text = item.text or "Label" -- 65
			return label -- 66
		end -- 66
		return makeFallbackRect( -- 68
			180, -- 68
			56, -- 68
			Color(2866196799) -- 68
		) -- 68
	end -- 68
	return Node() -- 70
end -- 54
local function applyTransform(target, item) -- 73
	target.x = item.x -- 74
	target.y = item.y -- 75
	target.scaleX = item.scaleX -- 76
	target.scaleY = item.scaleY -- 77
	target.angle = item.rotation -- 78
	target.visible = item.visible -- 79
	target.tag = item.name -- 80
end -- 73
local function firstCamera(state) -- 83
	for ____, id in ipairs(state.order) do -- 84
		local item = state.nodes[id] -- 85
		if item ~= nil and item.kind == "Camera" and item.visible then -- 85
			return item -- 86
		end -- 86
	end -- 86
	return nil -- 88
end -- 83
local function loadNodeScript(item) -- 91
	if item.script == "" then -- 91
		return "" -- 92
	end -- 92
	local writablePath = Path(Content.writablePath, item.script) -- 93
	if Content:exist(writablePath) then -- 93
		return Content:load(writablePath) or "" -- 94
	end -- 94
	if Content:exist(item.script) then -- 94
		return Content:load(item.script) or "" -- 95
	end -- 95
	return "" -- 96
end -- 91
local function runNodeScript(state, item, runtimeNode) -- 99
	local scriptText = loadNodeScript(item) -- 100
	if scriptText == "" then -- 100
		return -- 101
	end -- 101
	local chunk, loadError = load(scriptText, item.script) -- 102
	if chunk == nil then -- 102
		pushConsole( -- 104
			state, -- 104
			(((zh and "脚本加载失败：" or "Script load failed: ") .. item.script) .. " ") .. tostring(loadError or "") -- 104
		) -- 104
		return -- 105
	end -- 105
	local ok, result = pcall(chunk) -- 107
	if not ok then -- 107
		pushConsole( -- 109
			state, -- 109
			(((zh and "脚本执行失败：" or "Script failed: ") .. item.script) .. " ") .. tostring(result) -- 109
		) -- 109
		return -- 110
	end -- 110
	if type(result) == "function" then -- 110
		local behavior = result -- 113
		local behaviorOk, behaviorError = pcall(function() return behavior(runtimeNode, state.playContent or runtimeNode, state.playRuntimeNodes) end) -- 114
		if not behaviorOk then -- 114
			pushConsole( -- 115
				state, -- 115
				(((zh and "脚本绑定失败：" or "Script attach failed: ") .. item.script) .. " ") .. tostring(behaviorError) -- 115
			) -- 115
		end -- 115
	end -- 115
end -- 99
local function clearPlayRuntime(state) -- 119
	if state.playRoot ~= nil then -- 119
		state.playRoot:removeFromParent(true) -- 121
		state.playRoot = nil -- 122
	end -- 122
	state.playWorld = nil -- 124
	state.playContent = nil -- 125
	state.playRuntimeNodes = {} -- 126
	state.playRuntimeLabels = {} -- 127
	state.isPlaying = false -- 128
	state.playDirty = true -- 129
end -- 119
function ____exports.stopPlay(state) -- 132
	clearPlayRuntime(state) -- 133
	state.status = zh and "游戏预览已停止" or "Game preview stopped" -- 134
	pushConsole(state, state.status) -- 135
end -- 132
function ____exports.startPlay(state) -- 138
	clearPlayRuntime(state) -- 139
	state.isPlaying = true -- 140
	state.gameWindowOpen = true -- 141
	state.playDirty = true -- 142
	state.status = zh and "游戏预览运行中" or "Game preview running" -- 143
	pushConsole(state, state.status) -- 144
end -- 138
local function rebuildPlayRuntime(state) -- 147
	if state.playRoot == nil then -- 147
		state.playRoot = Node() -- 149
		state.playRoot.tag = "__DoraImGuiGamePreview__" -- 150
		Director.entry:addChild(state.playRoot) -- 151
	end -- 151
	state.playRoot:removeAllChildren(true) -- 153
	state.playRuntimeNodes = {} -- 154
	state.playRuntimeLabels = {} -- 155
	local renderScale = App.devicePixelRatio or 1 -- 157
	local width = math.max(160, state.playViewport.width * renderScale) -- 158
	local height = math.max(120, state.playViewport.height * renderScale) -- 159
	local clip = ClipNode(makeClipStencil(width, height)) -- 160
	clip.alphaThreshold = 0.01 -- 161
	state.playRoot:addChild(clip) -- 162
	clip:addChild(makeGameBackground(width, height)) -- 163
	local world = Node() -- 165
	state.playWorld = world -- 166
	clip:addChild(world) -- 167
	local content = Node() -- 168
	state.playContent = content -- 169
	world:addChild(content) -- 170
	state.playRuntimeNodes.root = content -- 171
	local camera = firstCamera(state) -- 173
	if camera ~= nil then -- 173
		world.x = -camera.x -- 175
		world.y = -camera.y -- 176
		world.angle = -camera.rotation -- 177
	end -- 177
	for ____, id in ipairs(state.order) do -- 180
		local item = state.nodes[id] -- 181
		if item ~= nil and id ~= "root" and item.kind ~= "Camera" then -- 181
			local runtime = createPlayVisual(item) -- 183
			applyTransform(runtime, item) -- 184
			state.playRuntimeNodes[id] = runtime -- 185
			if item.kind == "Label" then -- 185
				state.playRuntimeLabels[id] = runtime -- 186
			end -- 186
			local parent = state.playRuntimeNodes[item.parentId or "root"] or content -- 187
			parent:addChild(runtime) -- 188
		end -- 188
	end -- 188
	for ____, id in ipairs(state.order) do -- 191
		local item = state.nodes[id] -- 192
		local runtime = state.playRuntimeNodes[id] -- 193
		if item ~= nil and runtime ~= nil then -- 193
			runNodeScript(state, item, runtime) -- 195
		end -- 195
	end -- 195
	state.playDirty = false -- 198
end -- 147
local function updatePlayRuntime(state) -- 201
	if not state.isPlaying then -- 201
		return -- 202
	end -- 202
	if state.playDirty or state.playRoot == nil then -- 202
		rebuildPlayRuntime(state) -- 203
	end -- 203
	local p = state.playViewport -- 204
	local cx, cy = table.unpack( -- 205
		worldPointFromScreen(p.x + p.width / 2, p.y + p.height / 2), -- 205
		1, -- 205
		2 -- 205
	) -- 205
	if state.playRoot ~= nil then -- 205
		state.playRoot.x = cx -- 207
		state.playRoot.y = cy -- 208
	end -- 208
end -- 201
function ____exports.drawGamePreviewWindow(state) -- 212
	if not state.gameWindowOpen then -- 212
		return -- 213
	end -- 213
	local appSize = App.visualSize -- 214
	ImGui.SetNextWindowSize( -- 215
		Vec2( -- 215
			math.min(960, appSize.width - 80), -- 215
			math.min(620, appSize.height - 80) -- 215
		), -- 215
		"FirstUseEver" -- 215
	) -- 215
	ImGui.SetNextWindowBgAlpha(0.16) -- 216
	ImGui.Begin( -- 217
		"Game Preview", -- 217
		{"NoSavedSettings"}, -- 217
		function() -- 217
			if state.isPlaying then -- 217
				ImGui.TextColored(okColor, zh and "运行中" or "Running") -- 219
				ImGui.SameLine() -- 220
				if ImGui.Button("■ Stop") then -- 220
					____exports.stopPlay(state) -- 221
				end -- 221
				ImGui.SameLine() -- 222
				if ImGui.Button("↻ Restart") then -- 222
					____exports.startPlay(state) -- 223
				end -- 223
			else -- 223
				ImGui.TextColored(warnColor, zh and "已停止" or "Stopped") -- 225
				ImGui.SameLine() -- 226
				if ImGui.Button("▶ Run") then -- 226
					____exports.startPlay(state) -- 227
				end -- 227
			end -- 227
			ImGui.SameLine() -- 229
			ImGui.TextDisabled(zh and "这是独立 Game 预览，不是编辑视口。" or "Independent game preview, not the editor viewport.") -- 230
			ImGui.Separator() -- 231
			local cursor = ImGui.GetCursorScreenPos() -- 232
			local avail = ImGui.GetContentRegionAvail() -- 233
			local width = math.max(320, avail.x - 8) -- 234
			local height = math.max(240, avail.y - 8) -- 235
			if math.abs(state.playViewport.width - width) > 1 or math.abs(state.playViewport.height - height) > 1 then -- 235
				state.playDirty = true -- 237
			end -- 237
			state.playViewport.x = cursor.x -- 239
			state.playViewport.y = cursor.y -- 240
			state.playViewport.width = width -- 241
			state.playViewport.height = height -- 242
			updatePlayRuntime(state) -- 243
			ImGui.Dummy(Vec2(width, height)) -- 244
		end -- 217
	) -- 217
end -- 212
return ____exports -- 212