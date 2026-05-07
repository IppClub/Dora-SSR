-- [ts]: Model.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local ____exports = {} -- 1
local workspaceRoot, workspacePath, hasAsset, rememberAsset, sortAssets, normalizeSlash, stripFolderPrefix, refreshAssetSearchPath, notifyWebIDEFileAdded, copyFileToImported, sceneNodeKind, stringValue, numberValue, booleanValue, updateNextIdFromNodeId, importedAssetRoot, importedAssetRootEntry -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Buffer = ____Dora.Buffer -- 1
local Content = ____Dora.Content -- 1
local Path = ____Dora.Path -- 1
local emit = ____Dora.emit -- 1
local json = ____Dora.json -- 1
function workspaceRoot() -- 10
	return Content.writablePath -- 11
end -- 11
function workspacePath(path) -- 14
	return Path( -- 15
		workspaceRoot(), -- 15
		path -- 15
	) -- 15
end -- 15
function ____exports.pushConsole(state, message) -- 65
	local ____state_console_0 = state.console -- 65
	____state_console_0[#____state_console_0 + 1] = message -- 66
	if #state.console > 7 then -- 66
		table.remove(state.console, 1) -- 68
	end -- 68
end -- 65
function ____exports.isFolderAsset(path) -- 94
	return path ~= "" and string.sub( -- 95
		path, -- 95
		string.len(path), -- 95
		string.len(path) -- 95
	) == "/" -- 95
end -- 94
function hasAsset(state, asset) -- 98
	for ____, item in ipairs(state.assets) do -- 99
		if item == asset then -- 99
			return true -- 100
		end -- 100
	end -- 100
	return false -- 102
end -- 102
function rememberAsset(state, asset) -- 105
	if asset == "" then -- 105
		return -- 106
	end -- 106
	if not hasAsset(state, asset) then -- 106
		local ____state_assets_1 = state.assets -- 106
		____state_assets_1[#____state_assets_1 + 1] = asset -- 107
	end -- 107
end -- 107
function sortAssets(state) -- 110
	table.sort( -- 111
		state.assets, -- 111
		function(a, b) -- 111
			local aFolder = ____exports.isFolderAsset(a) -- 112
			local bFolder = ____exports.isFolderAsset(b) -- 113
			if aFolder == bFolder then -- 113
				return a < b -- 114
			end -- 114
			return aFolder -- 115
		end -- 111
	) -- 111
end -- 111
function normalizeSlash(path) -- 119
	local result = string.gsub(path, "\\", "/") -- 120
	local found = string.find(result, "//") -- 121
	while found ~= nil do -- 121
		result = string.gsub(result, "//", "/") -- 123
		found = string.find(result, "//") -- 124
	end -- 124
	return result -- 126
end -- 126
function stripFolderPrefix(folder, path) -- 129
	local cleanFolder = normalizeSlash(folder) -- 130
	local cleanPath = normalizeSlash(path) -- 131
	if string.sub( -- 131
		cleanPath, -- 132
		1, -- 132
		string.len(cleanFolder) -- 132
	) == cleanFolder then -- 132
		local rest = string.sub( -- 133
			cleanPath, -- 133
			string.len(cleanFolder) + 1 -- 133
		) -- 133
		if string.sub(rest, 1, 1) == "/" then -- 133
			rest = string.sub(rest, 2) -- 134
		end -- 134
		return rest -- 135
	end -- 135
	return Path:getFilename(path) -- 137
end -- 137
function refreshAssetSearchPath(importedPath) -- 140
	Content:addSearchPath(workspaceRoot()) -- 141
	Content:addSearchPath(workspacePath(importedAssetRoot)) -- 142
	if importedPath ~= nil and importedPath ~= "" then -- 142
		local importedFolder = Path:getPath(importedPath) -- 144
		if importedFolder ~= "" then -- 144
			Content:addSearchPath(workspacePath(importedFolder)) -- 145
		end -- 145
	end -- 145
	Content:clearPathCache() -- 147
end -- 147
function ____exports.refreshImportedAssets(state) -- 150
	local importedAbsolutePath = workspacePath(importedAssetRoot) -- 151
	Content:mkdir(importedAbsolutePath) -- 152
	refreshAssetSearchPath(importedAssetRoot) -- 153
	rememberAsset(state, importedAssetRootEntry) -- 154
	for ____, file in ipairs(Content:getAllFiles(importedAbsolutePath)) do -- 155
		local asset = normalizeSlash(Path(importedAssetRoot, file)) -- 156
		rememberAsset(state, asset) -- 157
	end -- 157
	sortAssets(state) -- 159
end -- 150
function notifyWebIDEFileAdded(workspaceRelativePath) -- 162
	local fullPath = workspacePath(workspaceRelativePath) -- 163
	local payload = json.encode({name = "UpdateFile", file = fullPath, exists = true, content = ""}) -- 164
	if payload ~= nil then -- 164
		emit("AppWS", "Send", payload) -- 171
	end -- 171
end -- 171
function copyFileToImported(srcPath, importedPath) -- 175
	local target = workspacePath(importedPath) -- 176
	Content:mkdir(Path:getPath(target)) -- 177
	if srcPath == target or Content:copy(srcPath, target) then -- 177
		refreshAssetSearchPath(importedPath) -- 179
		notifyWebIDEFileAdded(importedPath) -- 180
		return importedPath -- 181
	end -- 181
	Content:clearPathCache() -- 183
	return nil -- 184
end -- 184
function ____exports.addAssetFolder(state, folderPath) -- 207
	if folderPath == "" then -- 207
		return nil -- 208
	end -- 208
	local folderName = Path:getName(folderPath) or "Folder" -- 209
	local rootAsset = Path(importedAssetRoot, folderName) .. "/" -- 210
	rememberAsset(state, importedAssetRootEntry) -- 211
	rememberAsset(state, rootAsset) -- 212
	local added = 0 -- 213
	for ____, file in ipairs(Content:getAllFiles(folderPath)) do -- 214
		local absoluteFile = Content:exist(file) and file or Path(folderPath, file) -- 215
		local relativeFile = stripFolderPrefix(folderPath, absoluteFile) -- 216
		local importedFile = Path(importedAssetRoot, folderName, relativeFile) -- 217
		local asset = copyFileToImported(absoluteFile, importedFile) -- 218
		if asset ~= nil then -- 218
			rememberAsset(state, asset) -- 220
			added = added + 1 -- 221
		end -- 221
	end -- 221
	____exports.refreshImportedAssets(state) -- 224
	state.selectedAsset = rootAsset -- 225
	state.status = ((((____exports.zh and "已加入文件夹：" or "Folder imported: ") .. folderName) .. " (") .. tostring(added)) .. ")" -- 226
	____exports.pushConsole(state, state.status) -- 227
	return rootAsset -- 228
end -- 207
local localeMatch = string.match(App.locale, "^zh") -- 4
____exports.zh = localeMatch ~= nil -- 5
importedAssetRoot = "Imported" -- 7
importedAssetRootEntry = importedAssetRoot .. "/" -- 8
function ____exports.makeBuffer(text, size) -- 18
	local buffer = Buffer(size) -- 19
	buffer.text = text -- 20
	return buffer -- 21
end -- 18
function ____exports.createEditorState() -- 24
	Content:addSearchPath(workspaceRoot()) -- 25
	Content:mkdir(workspacePath(importedAssetRoot)) -- 26
	local state = { -- 27
		nextId = 0, -- 28
		selectedId = "root", -- 29
		mode = "2D", -- 30
		zoom = 100, -- 31
		showGrid = true, -- 32
		snapEnabled = false, -- 33
		viewportTool = "Select", -- 34
		leftWidth = 280, -- 35
		rightWidth = 340, -- 36
		bottomHeight = 132, -- 37
		status = ____exports.zh and "Dora Visual Editor 已加载" or "Dora Visual Editor loaded", -- 38
		console = {____exports.zh and "真实 Dora Viewport 已启用。" or "Real Dora viewport enabled."}, -- 39
		nodes = {}, -- 40
		order = {}, -- 41
		preview = {x = 0, y = 0, width = 640, height = 360}, -- 42
		previewDirty = true, -- 43
		runtimeNodes = {}, -- 44
		runtimeLabels = {}, -- 45
		isPlaying = false, -- 46
		gameWindowOpen = false, -- 47
		playViewport = {x = 0, y = 0, width = 960, height = 540}, -- 48
		playDirty = true, -- 49
		playRuntimeNodes = {}, -- 50
		playRuntimeLabels = {}, -- 51
		assetImportBuffer = ____exports.makeBuffer(importedAssetRoot .. "/new.png", 256), -- 52
		scriptPathBuffer = ____exports.makeBuffer("", 256), -- 53
		scriptContentBuffer = ____exports.makeBuffer("", 8192), -- 54
		selectedAsset = "", -- 55
		assets = {}, -- 56
		viewportPanX = 0, -- 57
		viewportPanY = 0, -- 58
		draggingViewport = false -- 59
	} -- 59
	____exports.refreshImportedAssets(state) -- 61
	return state -- 62
end -- 24
function ____exports.iconFor(kind) -- 72
	if kind == "Sprite" then -- 72
		return "▣" -- 73
	end -- 73
	if kind == "Label" then -- 73
		return "T" -- 74
	end -- 74
	if kind == "Camera" then -- 74
		return "◉" -- 75
	end -- 75
	return "○" -- 76
end -- 72
function ____exports.lowerExt(path) -- 79
	local ext = Path:getExt(path or "") or "" -- 80
	return string.lower(ext) -- 81
end -- 79
function ____exports.isTextureAsset(path) -- 84
	local ext = ____exports.lowerExt(path) -- 85
	return ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "bmp" or ext == "gif" or ext == "webp" or ext == "ktx" or ext == "pvr" or ext == "clip" -- 86
end -- 84
function ____exports.isScriptAsset(path) -- 89
	local ext = ____exports.lowerExt(path) -- 90
	return ext == "lua" or ext == "ts" or ext == "tsx" or ext == "yue" or ext == "js" or ext == "json" -- 91
end -- 89
function ____exports.addAssetPath(state, path, importedPath) -- 187
	if path == nil or path == "" then -- 187
		return nil -- 188
	end -- 188
	if Content:isdir(path) then -- 188
		return ____exports.addAssetFolder(state, path) -- 190
	end -- 190
	local asset = copyFileToImported( -- 192
		path, -- 192
		importedPath or Path( -- 192
			importedAssetRoot, -- 192
			Path:getFilename(path) -- 192
		) -- 192
	) -- 192
	if asset == nil then -- 192
		state.status = (____exports.zh and "导入失败：" or "Import failed: ") .. path -- 194
		____exports.pushConsole(state, state.status) -- 195
		return nil -- 196
	end -- 196
	rememberAsset(state, asset) -- 198
	rememberAsset(state, importedAssetRootEntry) -- 199
	____exports.refreshImportedAssets(state) -- 200
	state.selectedAsset = asset -- 201
	state.status = (____exports.zh and "已加入资源：" or "Asset added: ") .. asset -- 202
	____exports.pushConsole(state, state.status) -- 203
	return asset -- 204
end -- 187
function ____exports.importFileDialog(state) -- 231
	App:openFileDialog( -- 232
		false, -- 232
		function(path) return ____exports.addAssetPath(state, path) end -- 232
	) -- 232
end -- 231
function ____exports.importFolderDialog(state) -- 235
	App:openFileDialog( -- 236
		true, -- 236
		function(path) return ____exports.addAssetFolder(state, path) end -- 236
	) -- 236
end -- 235
local function newNodeId(state, kind) -- 239
	state.nextId = state.nextId + 1 -- 240
	return (string.lower(kind) .. "-") .. tostring(state.nextId) -- 241
end -- 239
function ____exports.addNode(state, kind, name, parentId) -- 244
	local resolvedParentId = parentId or "root" -- 245
	local id = kind == "Root" and "root" or newNodeId(state, kind) -- 246
	local index = state.nextId -- 247
	local node = { -- 248
		id = id, -- 249
		kind = kind, -- 250
		name = name, -- 251
		parentId = resolvedParentId, -- 252
		children = {}, -- 253
		x = (kind == "Root" or kind == "Camera") and 0 or (index % 5 - 2) * 70, -- 254
		y = (kind == "Root" or kind == "Camera") and 0 or math.floor(index / 5) % 4 * 55, -- 255
		scaleX = 1, -- 256
		scaleY = 1, -- 257
		rotation = 0, -- 258
		visible = true, -- 259
		texture = "", -- 260
		text = kind == "Label" and "Label" or "", -- 261
		script = "", -- 262
		nameBuffer = ____exports.makeBuffer(name, 128), -- 263
		textureBuffer = ____exports.makeBuffer("", 256), -- 264
		textBuffer = ____exports.makeBuffer(kind == "Label" and "Label" or "", 256), -- 265
		scriptBuffer = ____exports.makeBuffer("", 256) -- 266
	} -- 266
	state.nodes[id] = node -- 268
	local ____state_order_2 = state.order -- 268
	____state_order_2[#____state_order_2 + 1] = id -- 269
	local parent = state.nodes[resolvedParentId] -- 270
	if id ~= "root" and parent ~= nil then -- 270
		local ____parent_children_3 = parent.children -- 270
		____parent_children_3[#____parent_children_3 + 1] = id -- 272
	end -- 272
	return node -- 274
end -- 244
function sceneNodeKind(value)
	if value == "Root" or value == "Node" or value == "Sprite" or value == "Label" or value == "Camera" then
		return value
	end
	return "Node"
end
function stringValue(value, fallback)
	return type(value) == "string" and value or fallback
end
function numberValue(value, fallback)
	local parsed = tonumber(value)
	return parsed ~= nil and parsed or fallback
end
function booleanValue(value, fallback)
	return type(value) == "boolean" and value or fallback
end
function updateNextIdFromNodeId(state, id)
	local digits = string.match(id, "%-(%d+)$")
	if digits ~= nil then
		local value = tonumber(digits)
		if value ~= nil and value > state.nextId then
			state.nextId = value
		end
	end
end
function ____exports.loadSceneFromFile(state, file)
	if not Content:exist(file) then
		return false
	end
	local data = json.decode(Content:load(file))
	if data == nil then
		return false
	end
	local rawNodes = data.nodes
	if rawNodes == nil then
		return false
	end
	state.nodes = {}
	state.order = {}
	state.runtimeNodes = {}
	state.runtimeLabels = {}
	state.playRuntimeNodes = {}
	state.playRuntimeLabels = {}
	state.nextId = 0
	for ____, raw in ipairs(rawNodes) do
		local kind = sceneNodeKind(raw.kind)
		local id = stringValue(raw.id, kind == "Root" and "root" or (string.lower(kind) .. "-") .. tostring(state.nextId + 1))
		local name = stringValue(raw.name, kind == "Root" and "MainScene" or kind)
		local texture = stringValue(raw.texture, "")
		local text = stringValue(raw.text, kind == "Label" and "Label" or "")
		local script = stringValue(raw.script, "")
		local parentId = id == "root" and nil or stringValue(raw.parentId, "root")
		local node = {
			id = id,
			kind = kind,
			name = name,
			parentId = parentId,
			children = {},
			x = numberValue(raw.x, 0),
			y = numberValue(raw.y, 0),
			scaleX = numberValue(raw.scaleX, 1),
			scaleY = numberValue(raw.scaleY, 1),
			rotation = numberValue(raw.rotation, 0),
			visible = booleanValue(raw.visible, true),
			texture = texture,
			text = text,
			script = script,
			nameBuffer = ____exports.makeBuffer(name, 128),
			textureBuffer = ____exports.makeBuffer(texture, 256),
			textBuffer = ____exports.makeBuffer(text, 256),
			scriptBuffer = ____exports.makeBuffer(script, 256)
		}
		state.nodes[id] = node
		state.order[#state.order + 1] = id
		updateNextIdFromNodeId(state, id)
	end
	if state.nodes.root == nil then
		____exports.addNode(state, "Root", "MainScene")
	end
	for ____, id in ipairs(state.order) do
		if id ~= "root" then
			local node = state.nodes[id]
			if node ~= nil then
				if node.parentId == nil or state.nodes[node.parentId] == nil then
					node.parentId = "root"
				end
				state.nodes[node.parentId].children[#state.nodes[node.parentId].children + 1] = id
			end
		end
	end
	state.selectedId = state.nodes.root ~= nil and "root" or (state.order[1] or "root")
	state.previewDirty = true
	state.playDirty = true
	state.status = ____exports.zh and "已加载场景" or "Scene loaded"
	____exports.pushConsole(state, state.status)
	return true
end
local function removeFromOrder(state, id) -- 277
	do -- 277
		local i = #state.order -- 278
		while i >= 1 do -- 278
			if state.order[i] == id then -- 278
				table.remove(state.order, i) -- 280
			end -- 280
			i = i - 1 -- 278
		end -- 278
	end -- 278
end -- 277
function ____exports.deleteNode(state, id) -- 285
	if id == "root" then -- 285
		state.status = ____exports.zh and "根节点不能删除" or "Root cannot be deleted" -- 287
		return -- 288
	end -- 288
	local node = state.nodes[id] -- 290
	if node == nil then -- 290
		return -- 291
	end -- 291
	do -- 291
		local i = #node.children -- 292
		while i >= 1 do -- 292
			____exports.deleteNode(state, node.children[i]) -- 293
			i = i - 1 -- 292
		end -- 292
	end -- 292
	local parent = node.parentId ~= nil and state.nodes[node.parentId] or nil -- 295
	if parent ~= nil then -- 295
		do -- 295
			local i = #parent.children -- 297
			while i >= 1 do -- 297
				if parent.children[i] == id then -- 297
					table.remove(parent.children, i) -- 298
				end -- 298
				i = i - 1 -- 297
			end -- 297
		end -- 297
	end -- 297
	__TS__Delete(state.nodes, id) -- 301
	removeFromOrder(state, id) -- 302
	state.selectedId = "root" -- 303
	state.draggingNodeId = nil -- 304
	state.previewDirty = true -- 305
	state.status = ____exports.zh and "已删除节点" or "Node deleted" -- 306
	____exports.pushConsole(state, state.status) -- 307
end -- 285
function ____exports.addChildNode(state, kind) -- 310
	local parentId = state.selectedId or "root" -- 311
	if state.nodes[parentId] == nil then -- 311
		parentId = "root" -- 312
	end -- 312
	local node = ____exports.addNode( -- 313
		state, -- 313
		kind, -- 313
		kind .. tostring(state.nextId + 1), -- 313
		parentId -- 313
	) -- 313
	state.selectedId = node.id -- 314
	state.previewDirty = true -- 315
	state.status = (____exports.zh and "已添加 " or "Added ") .. node.name -- 316
	____exports.pushConsole(state, state.status) -- 317
end -- 310
return ____exports -- 310
