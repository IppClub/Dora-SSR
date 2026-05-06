-- [ts]: Model.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Buffer = ____Dora.Buffer -- 1
local Content = ____Dora.Content -- 1
local Path = ____Dora.Path -- 1
local localeMatch = string.match(App.locale, "^zh") -- 4
____exports.zh = localeMatch ~= nil -- 5
function ____exports.makeBuffer(text, size) -- 7
	local buffer = Buffer(size) -- 8
	buffer.text = text -- 9
	return buffer -- 10
end -- 7
function ____exports.createEditorState() -- 13
	return { -- 14
		nextId = 0, -- 15
		selectedId = "root", -- 16
		mode = "2D", -- 17
		zoom = 100, -- 18
		showGrid = true, -- 19
		leftWidth = 280, -- 20
		rightWidth = 340, -- 21
		bottomHeight = 132, -- 22
		status = ____exports.zh and "Dora Visual Editor 已加载" or "Dora Visual Editor loaded", -- 23
		console = {____exports.zh and "真实 Dora Viewport 已启用。" or "Real Dora viewport enabled."}, -- 24
		nodes = {}, -- 25
		order = {}, -- 26
		preview = {x = 0, y = 0, width = 640, height = 360}, -- 27
		previewDirty = true, -- 28
		runtimeNodes = {}, -- 29
		runtimeLabels = {}, -- 30
		assetImportBuffer = ____exports.makeBuffer("Image/new.png", 256), -- 31
		scriptPathBuffer = ____exports.makeBuffer("", 256), -- 32
		scriptContentBuffer = ____exports.makeBuffer("", 8192), -- 33
		selectedAsset = "", -- 34
		assets = {"Image/player.png", "Image/enemy.png", "Audio/bgm.ogg", "Script/player.lua"} -- 35
	} -- 35
end -- 13
function ____exports.pushConsole(state, message) -- 39
	local ____state_console_0 = state.console -- 39
	____state_console_0[#____state_console_0 + 1] = message -- 40
	if #state.console > 7 then -- 40
		table.remove(state.console, 1) -- 42
	end -- 42
end -- 39
function ____exports.iconFor(kind) -- 46
	if kind == "Sprite" then -- 46
		return "▣" -- 47
	end -- 47
	if kind == "Label" then -- 47
		return "T" -- 48
	end -- 48
	if kind == "Camera" then -- 48
		return "◉" -- 49
	end -- 49
	return "○" -- 50
end -- 46
function ____exports.lowerExt(path) -- 53
	local ext = Path:getExt(path or "") or "" -- 54
	return string.lower(ext) -- 55
end -- 53
function ____exports.assetFolderForExt(ext) -- 58
	if ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "ktx" or ext == "pvr" or ext == "clip" then -- 58
		return "Image" -- 59
	end -- 59
	if ext == "lua" or ext == "ts" or ext == "tsx" or ext == "yue" then -- 59
		return "Script" -- 60
	end -- 60
	if ext == "wav" or ext == "mp3" or ext == "ogg" then -- 60
		return "Audio" -- 61
	end -- 61
	if ext == "anim" or ext == "model" or ext == "skel" then -- 61
		return "Animation" -- 62
	end -- 62
	return "Resource" -- 63
end -- 58
function ____exports.isTextureAsset(path) -- 66
	local ext = ____exports.lowerExt(path) -- 67
	return ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "ktx" or ext == "pvr" or ext == "clip" -- 68
end -- 66
function ____exports.isScriptAsset(path) -- 71
	local ext = ____exports.lowerExt(path) -- 72
	return ext == "lua" or ext == "ts" or ext == "tsx" or ext == "yue" -- 73
end -- 71
local function hasAsset(state, asset) -- 76
	for ____, item in ipairs(state.assets) do -- 77
		if item == asset then -- 77
			return true -- 78
		end -- 78
	end -- 78
	return false -- 80
end -- 76
function ____exports.addAssetPath(state, path) -- 83
	if path == "" then -- 83
		return -- 84
	end -- 84
	local ext = ____exports.lowerExt(path) -- 85
	local folder = ____exports.assetFolderForExt(ext) -- 86
	local name = Path:getName(path) -- 87
	local asset = Path(folder, name) -- 88
	local target = Path(Content.writablePath, asset) -- 89
	Content:mkdir(Path(Content.writablePath, folder)) -- 90
	if Content:exist(path) and path ~= target then -- 90
		if not Content:copy(path, target) then -- 90
			asset = path -- 93
		end -- 93
	end -- 93
	if not hasAsset(state, asset) then -- 93
		local ____state_assets_1 = state.assets -- 93
		____state_assets_1[#____state_assets_1 + 1] = asset -- 97
	end -- 97
	state.selectedAsset = asset -- 99
	state.status = (____exports.zh and "已加入资源：" or "Asset added: ") .. asset -- 100
	____exports.pushConsole(state, state.status) -- 101
end -- 83
function ____exports.importFileDialog(state) -- 104
	App:openFileDialog( -- 105
		false, -- 105
		function(____, path) return ____exports.addAssetPath(state, path) end -- 105
	) -- 105
end -- 104
function ____exports.importFolderDialog(state) -- 108
	App:openFileDialog( -- 109
		true, -- 109
		function(____, path) -- 109
			if path == "" then -- 109
				return -- 110
			end -- 110
			for ____, file in ipairs(Content:getFiles(path)) do -- 111
				____exports.addAssetPath( -- 112
					state, -- 112
					Path(path, file) -- 112
				) -- 112
			end -- 112
		end -- 109
	) -- 109
end -- 108
local function newNodeId(state, kind) -- 117
	state.nextId = state.nextId + 1 -- 118
	return (string.lower(kind) .. "-") .. tostring(state.nextId) -- 119
end -- 117
function ____exports.addNode(state, kind, name, parentId) -- 122
	local resolvedParentId = parentId or "root" -- 123
	local id = kind == "Root" and "root" or newNodeId(state, kind) -- 124
	local index = state.nextId -- 125
	local node = { -- 126
		id = id, -- 127
		kind = kind, -- 128
		name = name, -- 129
		parentId = resolvedParentId, -- 130
		children = {}, -- 131
		x = (kind == "Root" or kind == "Camera") and 0 or (index % 5 - 2) * 70, -- 132
		y = (kind == "Root" or kind == "Camera") and 0 or math.floor(index / 5) % 4 * 55, -- 133
		scaleX = 1, -- 134
		scaleY = 1, -- 135
		rotation = 0, -- 136
		visible = true, -- 137
		texture = "", -- 138
		text = kind == "Label" and "Label" or "", -- 139
		script = "", -- 140
		nameBuffer = ____exports.makeBuffer(name, 128), -- 141
		textureBuffer = ____exports.makeBuffer("", 256), -- 142
		textBuffer = ____exports.makeBuffer(kind == "Label" and "Label" or "", 256), -- 143
		scriptBuffer = ____exports.makeBuffer("", 256) -- 144
	} -- 144
	state.nodes[id] = node -- 146
	local ____state_order_2 = state.order -- 146
	____state_order_2[#____state_order_2 + 1] = id -- 147
	local parent = state.nodes[resolvedParentId] -- 148
	if id ~= "root" and parent ~= nil then -- 148
		local ____parent_children_3 = parent.children -- 148
		____parent_children_3[#____parent_children_3 + 1] = id -- 150
	end -- 150
	return node -- 152
end -- 122
local function removeFromOrder(state, id) -- 155
	do -- 155
		local i = #state.order -- 156
		while i >= 1 do -- 156
			if state.order[i] == id then -- 156
				table.remove(state.order, i) -- 158
			end -- 158
			i = i - 1 -- 156
		end -- 156
	end -- 156
end -- 155
function ____exports.deleteNode(state, id) -- 163
	if id == "root" then -- 163
		state.status = ____exports.zh and "根节点不能删除" or "Root cannot be deleted" -- 165
		return -- 166
	end -- 166
	local node = state.nodes[id] -- 168
	if node == nil then -- 168
		return -- 169
	end -- 169
	do -- 169
		local i = #node.children -- 170
		while i >= 1 do -- 170
			____exports.deleteNode(state, node.children[i]) -- 171
			i = i - 1 -- 170
		end -- 170
	end -- 170
	local parent = node.parentId ~= nil and state.nodes[node.parentId] or nil -- 173
	if parent ~= nil then -- 173
		do -- 173
			local i = #parent.children -- 175
			while i >= 1 do -- 175
				if parent.children[i] == id then -- 175
					table.remove(parent.children, i) -- 176
				end -- 176
				i = i - 1 -- 175
			end -- 175
		end -- 175
	end -- 175
	__TS__Delete(state.nodes, id) -- 179
	removeFromOrder(state, id) -- 180
	state.selectedId = "root" -- 181
	state.previewDirty = true -- 182
	state.status = ____exports.zh and "已删除节点" or "Node deleted" -- 183
	____exports.pushConsole(state, state.status) -- 184
end -- 163
function ____exports.addChildNode(state, kind) -- 187
	local parentId = state.selectedId or "root" -- 188
	if state.nodes[parentId] == nil then -- 188
		parentId = "root" -- 189
	end -- 189
	local node = ____exports.addNode( -- 190
		state, -- 190
		kind, -- 190
		kind .. tostring(state.nextId + 1), -- 190
		parentId -- 190
	) -- 190
	state.selectedId = node.id -- 191
	state.previewDirty = true -- 192
	state.status = (____exports.zh and "已添加 " or "Added ") .. node.name -- 193
	____exports.pushConsole(state, state.status) -- 194
end -- 187
return ____exports -- 187