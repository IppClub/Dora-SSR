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
function ____exports.pushConsole(state, message) -- 47
	local ____state_console_0 = state.console -- 47
	____state_console_0[#____state_console_0 + 1] = message -- 48
	if #state.console > 7 then -- 48
		table.remove(state.console, 1) -- 50
	end -- 50
end -- 47
function hasAsset(state, asset) -- 80
	for ____, item in ipairs(state.assets) do -- 81
		if item == asset then -- 81
			return true -- 82
		end -- 82
	end -- 82
	return false -- 84
end -- 84
function rememberAsset(state, asset) -- 87
	if asset == "" then -- 87
		return -- 88
	end -- 88
	if not hasAsset(state, asset) then -- 88
		local ____state_assets_1 = state.assets -- 88
		____state_assets_1[#____state_assets_1 + 1] = asset -- 89
	end -- 89
end -- 89
function normalizeSlash(path) -- 92
	local result = string.gsub(path, "\\", "/") -- 93
	local found = string.find(result, "//") -- 94
	while found ~= nil do -- 94
		result = string.gsub(result, "//", "/") -- 96
		found = string.find(result, "//") -- 97
	end -- 97
	return result -- 99
end -- 99
function stripFolderPrefix(folder, path) -- 102
	local cleanFolder = normalizeSlash(folder) -- 103
	local cleanPath = normalizeSlash(path) -- 104
	if string.sub( -- 104
		cleanPath, -- 105
		1, -- 105
		string.len(cleanFolder) -- 105
	) == cleanFolder then -- 105
		local rest = string.sub( -- 106
			cleanPath, -- 106
			string.len(cleanFolder) + 1 -- 106
		) -- 106
		if string.sub(rest, 1, 1) == "/" then -- 106
			rest = string.sub(rest, 2) -- 107
		end -- 107
		return rest -- 108
	end -- 108
	return Path:getName(path) -- 110
end -- 110
function refreshAssetSearchPath(importedPath) -- 113
	Content:addSearchPath(Content.writablePath) -- 114
	if importedPath ~= nil and importedPath ~= "" then -- 114
		local importedFolder = Path:getPath(importedPath) -- 116
		if importedFolder ~= "" then -- 116
			Content:addSearchPath(Path(Content.writablePath, importedFolder)) -- 117
		end -- 117
	end -- 117
	Content:clearPathCache() -- 119
end -- 119
function copyFileToImported(srcPath, importedPath) -- 122
	local target = Path(Content.writablePath, importedPath) -- 123
	Content:mkdir(Path:getPath(target)) -- 124
	if Content:exist(srcPath) and srcPath ~= target then -- 124
		if Content:copy(srcPath, target) then -- 124
			refreshAssetSearchPath(importedPath) -- 127
			return importedPath -- 128
		end -- 128
		local parentPath = Path:getPath(srcPath) -- 130
		if parentPath ~= "" then -- 130
			Content:addSearchPath(parentPath) -- 131
		end -- 131
		Content:clearPathCache() -- 132
		return srcPath -- 133
	end -- 133
	refreshAssetSearchPath(importedPath) -- 135
	return importedPath -- 136
end -- 136
function ____exports.addAssetFolder(state, folderPath) -- 152
	if folderPath == "" then -- 152
		return nil -- 153
	end -- 153
	local folderName = Path:getName(folderPath) or "Folder" -- 154
	local rootAsset = Path(importedAssetRoot, folderName) .. "/" -- 155
	rememberAsset(state, rootAsset) -- 156
	local added = 0 -- 157
	for ____, file in ipairs(Content:getAllFiles(folderPath)) do -- 158
		local absoluteFile = Content:exist(file) and file or Path(folderPath, file) -- 159
		local relativeFile = stripFolderPrefix(folderPath, absoluteFile) -- 160
		local importedFile = Path(importedAssetRoot, folderName, relativeFile) -- 161
		local asset = copyFileToImported(absoluteFile, importedFile) -- 162
		rememberAsset(state, asset) -- 163
		added = added + 1 -- 164
	end -- 164
	state.selectedAsset = rootAsset -- 166
	state.status = ((((____exports.zh and "已加入文件夹：" or "Folder imported: ") .. folderName) .. " (") .. tostring(added)) .. ")" -- 167
	____exports.pushConsole(state, state.status) -- 168
	return rootAsset -- 169
end -- 152
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
		assetImportBuffer = ____exports.makeBuffer(importedAssetRoot .. "/new.png", 256), -- 36
		scriptPathBuffer = ____exports.makeBuffer("", 256), -- 37
		scriptContentBuffer = ____exports.makeBuffer("", 8192), -- 38
		selectedAsset = "", -- 39
		assets = {"Imported/dora_sample_sprite.png"}, -- 40
		viewportPanX = 0, -- 41
		viewportPanY = 0, -- 42
		draggingViewport = false -- 43
	} -- 43
end -- 15
function ____exports.iconFor(kind) -- 54
	if kind == "Sprite" then -- 54
		return "▣" -- 55
	end -- 55
	if kind == "Label" then -- 55
		return "T" -- 56
	end -- 56
	if kind == "Camera" then -- 56
		return "◉" -- 57
	end -- 57
	return "○" -- 58
end -- 54
function ____exports.lowerExt(path) -- 61
	local ext = Path:getExt(path or "") or "" -- 62
	return string.lower(ext) -- 63
end -- 61
function ____exports.isTextureAsset(path) -- 66
	local ext = ____exports.lowerExt(path) -- 67
	return ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "bmp" or ext == "gif" or ext == "webp" or ext == "ktx" or ext == "pvr" or ext == "clip" -- 68
end -- 66
function ____exports.isScriptAsset(path) -- 71
	local ext = ____exports.lowerExt(path) -- 72
	return ext == "lua" or ext == "ts" or ext == "tsx" or ext == "yue" or ext == "js" or ext == "json" -- 73
end -- 71
function ____exports.isFolderAsset(path) -- 76
	return path ~= "" and string.sub( -- 77
		path, -- 77
		string.len(path), -- 77
		string.len(path) -- 77
	) == "/" -- 77
end -- 76
function ____exports.addAssetPath(state, path, importedPath) -- 139
	if path == "" then -- 139
		return nil -- 140
	end -- 140
	if Content:isdir(path) then -- 140
		return ____exports.addAssetFolder(state, path) -- 142
	end -- 142
	local asset = copyFileToImported( -- 144
		path, -- 144
		importedPath or Path( -- 144
			importedAssetRoot, -- 144
			Path:getName(path) -- 144
		) -- 144
	) -- 144
	rememberAsset(state, asset) -- 145
	state.selectedAsset = asset -- 146
	state.status = (____exports.zh and "已加入资源：" or "Asset added: ") .. asset -- 147
	____exports.pushConsole(state, state.status) -- 148
	return asset -- 149
end -- 139
function ____exports.importFileDialog(state) -- 172
	App:openFileDialog( -- 173
		false, -- 173
		function(____, path) return ____exports.addAssetPath(state, path) end -- 173
	) -- 173
end -- 172
function ____exports.importFolderDialog(state) -- 176
	App:openFileDialog( -- 177
		true, -- 177
		function(____, path) return ____exports.addAssetFolder(state, path) end -- 177
	) -- 177
end -- 176
local function newNodeId(state, kind) -- 180
	state.nextId = state.nextId + 1 -- 181
	return (string.lower(kind) .. "-") .. tostring(state.nextId) -- 182
end -- 180
function ____exports.addNode(state, kind, name, parentId) -- 185
	local resolvedParentId = parentId or "root" -- 186
	local id = kind == "Root" and "root" or newNodeId(state, kind) -- 187
	local index = state.nextId -- 188
	local node = { -- 189
		id = id, -- 190
		kind = kind, -- 191
		name = name, -- 192
		parentId = resolvedParentId, -- 193
		children = {}, -- 194
		x = (kind == "Root" or kind == "Camera") and 0 or (index % 5 - 2) * 70, -- 195
		y = (kind == "Root" or kind == "Camera") and 0 or math.floor(index / 5) % 4 * 55, -- 196
		scaleX = 1, -- 197
		scaleY = 1, -- 198
		rotation = 0, -- 199
		visible = true, -- 200
		texture = "", -- 201
		text = kind == "Label" and "Label" or "", -- 202
		script = "", -- 203
		nameBuffer = ____exports.makeBuffer(name, 128), -- 204
		textureBuffer = ____exports.makeBuffer("", 256), -- 205
		textBuffer = ____exports.makeBuffer(kind == "Label" and "Label" or "", 256), -- 206
		scriptBuffer = ____exports.makeBuffer("", 256) -- 207
	} -- 207
	state.nodes[id] = node -- 209
	local ____state_order_2 = state.order -- 209
	____state_order_2[#____state_order_2 + 1] = id -- 210
	local parent = state.nodes[resolvedParentId] -- 211
	if id ~= "root" and parent ~= nil then -- 211
		local ____parent_children_3 = parent.children -- 211
		____parent_children_3[#____parent_children_3 + 1] = id -- 213
	end -- 213
	return node -- 215
end -- 185
local function removeFromOrder(state, id) -- 218
	do -- 218
		local i = #state.order -- 219
		while i >= 1 do -- 219
			if state.order[i] == id then -- 219
				table.remove(state.order, i) -- 221
			end -- 221
			i = i - 1 -- 219
		end -- 219
	end -- 219
end -- 218
function ____exports.deleteNode(state, id) -- 226
	if id == "root" then -- 226
		state.status = ____exports.zh and "根节点不能删除" or "Root cannot be deleted" -- 228
		return -- 229
	end -- 229
	local node = state.nodes[id] -- 231
	if node == nil then -- 231
		return -- 232
	end -- 232
	do -- 232
		local i = #node.children -- 233
		while i >= 1 do -- 233
			____exports.deleteNode(state, node.children[i]) -- 234
			i = i - 1 -- 233
		end -- 233
	end -- 233
	local parent = node.parentId ~= nil and state.nodes[node.parentId] or nil -- 236
	if parent ~= nil then -- 236
		do -- 236
			local i = #parent.children -- 238
			while i >= 1 do -- 238
				if parent.children[i] == id then -- 238
					table.remove(parent.children, i) -- 239
				end -- 239
				i = i - 1 -- 238
			end -- 238
		end -- 238
	end -- 238
	__TS__Delete(state.nodes, id) -- 242
	removeFromOrder(state, id) -- 243
	state.selectedId = "root" -- 244
	state.draggingNodeId = nil -- 245
	state.previewDirty = true -- 246
	state.status = ____exports.zh and "已删除节点" or "Node deleted" -- 247
	____exports.pushConsole(state, state.status) -- 248
end -- 226
function ____exports.addChildNode(state, kind) -- 251
	local parentId = state.selectedId or "root" -- 252
	if state.nodes[parentId] == nil then -- 252
		parentId = "root" -- 253
	end -- 253
	local node = ____exports.addNode( -- 254
		state, -- 254
		kind, -- 254
		kind .. tostring(state.nextId + 1), -- 254
		parentId -- 254
	) -- 254
	state.selectedId = node.id -- 255
	state.previewDirty = true -- 256
	state.status = (____exports.zh and "已添加 " or "Added ") .. node.name -- 257
	____exports.pushConsole(state, state.status) -- 258
end -- 251
return ____exports -- 251