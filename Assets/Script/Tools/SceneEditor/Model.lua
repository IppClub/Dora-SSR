-- [ts]: Model.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local ____exports = {} -- 1
local hasAsset, rememberAsset, normalizeSlash, stripFolderPrefix, refreshAssetSearchPath, copyFileToImported, importedAssetRoot -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Buffer = ____Dora.Buffer -- 1
local Content = ____Dora.Content -- 1
local Path = ____Dora.Path -- 1
function ____exports.pushConsole(state, message) -- 53
	local ____state_console_0 = state.console -- 53
	____state_console_0[#____state_console_0 + 1] = message -- 54
	if #state.console > 7 then -- 54
		table.remove(state.console, 1) -- 56
	end -- 56
end -- 53
function hasAsset(state, asset) -- 86
	for ____, item in ipairs(state.assets) do -- 87
		if item == asset then -- 87
			return true -- 88
		end -- 88
	end -- 88
	return false -- 90
end -- 90
function rememberAsset(state, asset) -- 93
	if asset == "" then -- 93
		return -- 94
	end -- 94
	if not hasAsset(state, asset) then -- 94
		local ____state_assets_1 = state.assets -- 94
		____state_assets_1[#____state_assets_1 + 1] = asset -- 95
	end -- 95
end -- 95
function normalizeSlash(path) -- 98
	local result = string.gsub(path, "\\", "/") -- 99
	local found = string.find(result, "//") -- 100
	while found ~= nil do -- 100
		result = string.gsub(result, "//", "/") -- 102
		found = string.find(result, "//") -- 103
	end -- 103
	return result -- 105
end -- 105
function stripFolderPrefix(folder, path) -- 108
	local cleanFolder = normalizeSlash(folder) -- 109
	local cleanPath = normalizeSlash(path) -- 110
	if string.sub( -- 110
		cleanPath, -- 111
		1, -- 111
		string.len(cleanFolder) -- 111
	) == cleanFolder then -- 111
		local rest = string.sub( -- 112
			cleanPath, -- 112
			string.len(cleanFolder) + 1 -- 112
		) -- 112
		if string.sub(rest, 1, 1) == "/" then -- 112
			rest = string.sub(rest, 2) -- 113
		end -- 113
		return rest -- 114
	end -- 114
	return Path:getName(path) -- 116
end -- 116
function refreshAssetSearchPath(importedPath) -- 119
	Content:addSearchPath(Content.writablePath) -- 120
	if importedPath ~= nil and importedPath ~= "" then -- 120
		local importedFolder = Path:getPath(importedPath) -- 122
		if importedFolder ~= "" then -- 122
			Content:addSearchPath(Path(Content.writablePath, importedFolder)) -- 123
		end -- 123
	end -- 123
	Content:clearPathCache() -- 125
end -- 125
function copyFileToImported(srcPath, importedPath) -- 128
	local target = Path(Content.writablePath, importedPath) -- 129
	Content:mkdir(Path:getPath(target)) -- 130
	if Content:exist(srcPath) and srcPath ~= target then -- 130
		if Content:copy(srcPath, target) then -- 130
			refreshAssetSearchPath(importedPath) -- 133
			return importedPath -- 134
		end -- 134
		local parentPath = Path:getPath(srcPath) -- 136
		if parentPath ~= "" then -- 136
			Content:addSearchPath(parentPath) -- 137
		end -- 137
		Content:clearPathCache() -- 138
		return srcPath -- 139
	end -- 139
	refreshAssetSearchPath(importedPath) -- 141
	return importedPath -- 142
end -- 142
function ____exports.addAssetFolder(state, folderPath) -- 158
	if folderPath == "" then -- 158
		return nil -- 159
	end -- 159
	local folderName = Path:getName(folderPath) or "Folder" -- 160
	local rootAsset = Path(importedAssetRoot, folderName) .. "/" -- 161
	rememberAsset(state, rootAsset) -- 162
	local added = 0 -- 163
	for ____, file in ipairs(Content:getAllFiles(folderPath)) do -- 164
		local absoluteFile = Content:exist(file) and file or Path(folderPath, file) -- 165
		local relativeFile = stripFolderPrefix(folderPath, absoluteFile) -- 166
		local importedFile = Path(importedAssetRoot, folderName, relativeFile) -- 167
		local asset = copyFileToImported(absoluteFile, importedFile) -- 168
		rememberAsset(state, asset) -- 169
		added = added + 1 -- 170
	end -- 170
	state.selectedAsset = rootAsset -- 172
	state.status = ((((____exports.zh and "已加入文件夹：" or "Folder imported: ") .. folderName) .. " (") .. tostring(added)) .. ")" -- 173
	____exports.pushConsole(state, state.status) -- 174
	return rootAsset -- 175
end -- 158
local localeMatch = string.match(App.locale, "^zh") -- 4
____exports.zh = localeMatch ~= nil -- 5
importedAssetRoot = "Imported" -- 7
function ____exports.makeBuffer(text, size) -- 9
	local buffer = Buffer(size) -- 10
	buffer.text = text -- 11
	return buffer -- 12
end -- 9
function ____exports.createEditorState() -- 15
	Content:addSearchPath(Content.writablePath) -- 16
	return { -- 17
		nextId = 0, -- 18
		selectedId = "root", -- 19
		mode = "2D", -- 20
		zoom = 100, -- 21
		showGrid = true, -- 22
		snapEnabled = false, -- 23
		viewportTool = "Select", -- 24
		leftWidth = 280, -- 25
		rightWidth = 340, -- 26
		bottomHeight = 132, -- 27
		status = ____exports.zh and "Dora Visual Editor 已加载" or "Dora Visual Editor loaded", -- 28
		console = {____exports.zh and "真实 Dora Viewport 已启用。" or "Real Dora viewport enabled."}, -- 29
		nodes = {}, -- 30
		order = {}, -- 31
		preview = {x = 0, y = 0, width = 640, height = 360}, -- 32
		previewDirty = true, -- 33
		runtimeNodes = {}, -- 34
		runtimeLabels = {}, -- 35
		isPlaying = false, -- 36
		gameWindowOpen = false, -- 37
		playViewport = {x = 0, y = 0, width = 960, height = 540}, -- 38
		playDirty = true, -- 39
		playRuntimeNodes = {}, -- 40
		playRuntimeLabels = {}, -- 41
		assetImportBuffer = ____exports.makeBuffer(importedAssetRoot .. "/new.png", 256), -- 42
		scriptPathBuffer = ____exports.makeBuffer("", 256), -- 43
		scriptContentBuffer = ____exports.makeBuffer("", 8192), -- 44
		selectedAsset = "", -- 45
		assets = {"Imported/dora_sample_sprite.png"}, -- 46
		viewportPanX = 0, -- 47
		viewportPanY = 0, -- 48
		draggingViewport = false -- 49
	} -- 49
end -- 15
function ____exports.iconFor(kind) -- 60
	if kind == "Sprite" then -- 60
		return "▣" -- 61
	end -- 61
	if kind == "Label" then -- 61
		return "T" -- 62
	end -- 62
	if kind == "Camera" then -- 62
		return "◉" -- 63
	end -- 63
	return "○" -- 64
end -- 60
function ____exports.lowerExt(path) -- 67
	local ext = Path:getExt(path or "") or "" -- 68
	return string.lower(ext) -- 69
end -- 67
function ____exports.isTextureAsset(path) -- 72
	local ext = ____exports.lowerExt(path) -- 73
	return ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "bmp" or ext == "gif" or ext == "webp" or ext == "ktx" or ext == "pvr" or ext == "clip" -- 74
end -- 72
function ____exports.isScriptAsset(path) -- 77
	local ext = ____exports.lowerExt(path) -- 78
	return ext == "lua" or ext == "ts" or ext == "tsx" or ext == "yue" or ext == "js" or ext == "json" -- 79
end -- 77
function ____exports.isFolderAsset(path) -- 82
	return path ~= "" and string.sub( -- 83
		path, -- 83
		string.len(path), -- 83
		string.len(path) -- 83
	) == "/" -- 83
end -- 82
function ____exports.addAssetPath(state, path, importedPath) -- 145
	if path == "" then -- 145
		return nil -- 146
	end -- 146
	if Content:isdir(path) then -- 146
		return ____exports.addAssetFolder(state, path) -- 148
	end -- 148
	local asset = copyFileToImported( -- 150
		path, -- 150
		importedPath or Path( -- 150
			importedAssetRoot, -- 150
			Path:getName(path) -- 150
		) -- 150
	) -- 150
	rememberAsset(state, asset) -- 151
	state.selectedAsset = asset -- 152
	state.status = (____exports.zh and "已加入资源：" or "Asset added: ") .. asset -- 153
	____exports.pushConsole(state, state.status) -- 154
	return asset -- 155
end -- 145
function ____exports.importFileDialog(state) -- 178
	App:openFileDialog( -- 179
		false, -- 179
		function(____, path) return ____exports.addAssetPath(state, path) end -- 179
	) -- 179
end -- 178
function ____exports.importFolderDialog(state) -- 182
	App:openFileDialog( -- 183
		true, -- 183
		function(____, path) return ____exports.addAssetFolder(state, path) end -- 183
	) -- 183
end -- 182
local function newNodeId(state, kind) -- 186
	state.nextId = state.nextId + 1 -- 187
	return (string.lower(kind) .. "-") .. tostring(state.nextId) -- 188
end -- 186
function ____exports.addNode(state, kind, name, parentId) -- 191
	local resolvedParentId = parentId or "root" -- 192
	local id = kind == "Root" and "root" or newNodeId(state, kind) -- 193
	local index = state.nextId -- 194
	local node = { -- 195
		id = id, -- 196
		kind = kind, -- 197
		name = name, -- 198
		parentId = resolvedParentId, -- 199
		children = {}, -- 200
		x = (kind == "Root" or kind == "Camera") and 0 or (index % 5 - 2) * 70, -- 201
		y = (kind == "Root" or kind == "Camera") and 0 or math.floor(index / 5) % 4 * 55, -- 202
		scaleX = 1, -- 203
		scaleY = 1, -- 204
		rotation = 0, -- 205
		visible = true, -- 206
		texture = "", -- 207
		text = kind == "Label" and "Label" or "", -- 208
		script = "", -- 209
		nameBuffer = ____exports.makeBuffer(name, 128), -- 210
		textureBuffer = ____exports.makeBuffer("", 256), -- 211
		textBuffer = ____exports.makeBuffer(kind == "Label" and "Label" or "", 256), -- 212
		scriptBuffer = ____exports.makeBuffer("", 256) -- 213
	} -- 213
	state.nodes[id] = node -- 215
	local ____state_order_2 = state.order -- 215
	____state_order_2[#____state_order_2 + 1] = id -- 216
	local parent = state.nodes[resolvedParentId] -- 217
	if id ~= "root" and parent ~= nil then -- 217
		local ____parent_children_3 = parent.children -- 217
		____parent_children_3[#____parent_children_3 + 1] = id -- 219
	end -- 219
	return node -- 221
end -- 191
local function removeFromOrder(state, id) -- 224
	do -- 224
		local i = #state.order -- 225
		while i >= 1 do -- 225
			if state.order[i] == id then -- 225
				table.remove(state.order, i) -- 227
			end -- 227
			i = i - 1 -- 225
		end -- 225
	end -- 225
end -- 224
function ____exports.deleteNode(state, id) -- 232
	if id == "root" then -- 232
		state.status = ____exports.zh and "根节点不能删除" or "Root cannot be deleted" -- 234
		return -- 235
	end -- 235
	local node = state.nodes[id] -- 237
	if node == nil then -- 237
		return -- 238
	end -- 238
	do -- 238
		local i = #node.children -- 239
		while i >= 1 do -- 239
			____exports.deleteNode(state, node.children[i]) -- 240
			i = i - 1 -- 239
		end -- 239
	end -- 239
	local parent = node.parentId ~= nil and state.nodes[node.parentId] or nil -- 242
	if parent ~= nil then -- 242
		do -- 242
			local i = #parent.children -- 244
			while i >= 1 do -- 244
				if parent.children[i] == id then -- 244
					table.remove(parent.children, i) -- 245
				end -- 245
				i = i - 1 -- 244
			end -- 244
		end -- 244
	end -- 244
	__TS__Delete(state.nodes, id) -- 248
	removeFromOrder(state, id) -- 249
	state.selectedId = "root" -- 250
	state.draggingNodeId = nil -- 251
	state.previewDirty = true -- 252
	state.status = ____exports.zh and "已删除节点" or "Node deleted" -- 253
	____exports.pushConsole(state, state.status) -- 254
end -- 232
function ____exports.addChildNode(state, kind) -- 257
	local parentId = state.selectedId or "root" -- 258
	if state.nodes[parentId] == nil then -- 258
		parentId = "root" -- 259
	end -- 259
	local node = ____exports.addNode( -- 260
		state, -- 260
		kind, -- 260
		kind .. tostring(state.nextId + 1), -- 260
		parentId -- 260
	) -- 260
	state.selectedId = node.id -- 261
	state.previewDirty = true -- 262
	state.status = (____exports.zh and "已添加 " or "Added ") .. node.name -- 263
	____exports.pushConsole(state, state.status) -- 264
end -- 257
return ____exports -- 257