-- [ts]: Panels.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Color = ____Dora.Color -- 1
local Content = ____Dora.Content -- 1
local Keyboard = ____Dora.Keyboard -- 1
local Mouse = ____Dora.Mouse -- 1
local Path = ____Dora.Path -- 1
local Vec2 = ____Dora.Vec2 -- 1
local emit = ____Dora.emit -- 1
local json = ____Dora.json -- 1
local ImGui = require("ImGui") -- 2
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 5
local inputTextFlags = ____Theme.inputTextFlags -- 5
local mainWindowFlags = ____Theme.mainWindowFlags -- 5
local noScrollFlags = ____Theme.noScrollFlags -- 5
local okColor = ____Theme.okColor -- 5
local panelBg = ____Theme.panelBg -- 5
local scriptPanelBg = ____Theme.scriptPanelBg -- 5
local themeColor = ____Theme.themeColor -- 5
local transparent = ____Theme.transparent -- 5
local warnColor = ____Theme.warnColor -- 5
local ____Model = require("Script.Tools.SceneEditor.Model") -- 6
local addAssetPath = ____Model.addAssetPath -- 6
local addChildNode = ____Model.addChildNode -- 6
local deleteNode = ____Model.deleteNode -- 6
local iconFor = ____Model.iconFor -- 6
local importFileDialog = ____Model.importFileDialog -- 6
local importFolderDialog = ____Model.importFolderDialog -- 6
local isFolderAsset = ____Model.isFolderAsset -- 6
local isScriptAsset = ____Model.isScriptAsset -- 6
local isTextureAsset = ____Model.isTextureAsset -- 6
local lowerExt = ____Model.lowerExt -- 6
local pushConsole = ____Model.pushConsole -- 6
local zh = ____Model.zh -- 6
local ____Runtime = require("Script.Tools.SceneEditor.Runtime") -- 7
local updatePreviewRuntime = ____Runtime.updatePreviewRuntime -- 7
local ____Player = require("Script.Tools.SceneEditor.Player") -- 8
local drawGamePreviewWindow = ____Player.drawGamePreviewWindow -- 8
local startPlay = ____Player.startPlay -- 8
local stopPlay = ____Player.stopPlay -- 8
local sceneSaveFile = Path(Content.writablePath, ".dora", "imgui-editor.scene.json") -- 12
local function drawNodeRow(state, id, depth) -- 14
	local node = state.nodes[id] -- 15
	if node == nil then -- 15
		return -- 16
	end -- 16
	local indent = string.rep("  ", depth) -- 17
	local label = ((((indent .. iconFor(node.kind)) .. "  ") .. node.name) .. "##tree_") .. id -- 18
	if ImGui.Selectable(label, state.selectedId == id) then -- 18
		state.selectedId = id -- 20
		state.previewDirty = true -- 21
	end -- 21
	for ____, childId in ipairs(node.children) do -- 23
		drawNodeRow(state, childId, depth + 1) -- 24
	end -- 24
end -- 14
local function drawAddNodePopup(state) -- 28
	ImGui.BeginPopup( -- 29
		"AddNodePopup", -- 29
		function() -- 29
			ImGui.TextColored(themeColor, zh and "添加节点" or "Add Node") -- 30
			ImGui.Separator() -- 31
			if ImGui.Selectable("○  Node", false) then -- 31
				addChildNode(state, "Node") -- 32
				ImGui.CloseCurrentPopup() -- 32
			end -- 32
			if ImGui.Selectable("▣  Sprite", false) then -- 32
				addChildNode(state, "Sprite") -- 33
				ImGui.CloseCurrentPopup() -- 33
			end -- 33
			if ImGui.Selectable("T  Label", false) then -- 33
				addChildNode(state, "Label") -- 34
				ImGui.CloseCurrentPopup() -- 34
			end -- 34
			if ImGui.Selectable("◉  Camera", false) then -- 34
				addChildNode(state, "Camera") -- 35
				ImGui.CloseCurrentPopup() -- 35
			end -- 35
		end -- 29
	) -- 29
end -- 28
local function saveScene(state) -- 39
	Content:mkdir(Path(Content.writablePath, ".dora")) -- 40
	local data = {version = 1, nodes = {}} -- 41
	for ____, id in ipairs(state.order) do -- 42
		local node = state.nodes[id] -- 43
		if node ~= nil then -- 43
			local ____data_nodes_0 = data.nodes -- 43
			____data_nodes_0[#____data_nodes_0 + 1] = { -- 45
				id = node.id, -- 46
				kind = node.kind, -- 47
				name = node.name, -- 48
				parentId = node.parentId, -- 49
				x = node.x, -- 50
				y = node.y, -- 51
				scaleX = node.scaleX, -- 52
				scaleY = node.scaleY, -- 53
				rotation = node.rotation, -- 54
				visible = node.visible, -- 55
				texture = node.texture, -- 56
				text = node.text, -- 57
				script = node.script -- 58
			} -- 58
		end -- 58
	end -- 58
	local text = json.encode(data) -- 62
	if text ~= nil and Content:save(sceneSaveFile, text) then -- 62
		state.status = (zh and "已保存：" or "Saved: ") .. sceneSaveFile -- 64
	else -- 64
		state.status = zh and "保存失败" or "Save failed" -- 66
	end -- 66
	pushConsole(state, state.status) -- 68
end -- 39
local function drawHeader(state) -- 71
	ImGui.TextColored(themeColor, "✦ Dora Visual Editor") -- 72
	ImGui.SameLine() -- 73
	if ImGui.Button("2D") then -- 73
		state.mode = "2D" -- 74
	end -- 74
	ImGui.SameLine() -- 75
	if ImGui.Button("Script") then -- 75
		state.mode = "Script" -- 76
	end -- 76
	ImGui.SameLine() -- 77
	ImGui.TextDisabled(zh and "Native ImGui / Godot-like" or "Native ImGui / Godot-like") -- 78
	ImGui.Separator() -- 79
	if state.isPlaying then -- 79
		if ImGui.Button("■ Stop") then -- 79
			stopPlay(state) -- 81
		end -- 81
	elseif ImGui.Button("▶ Run") then -- 81
		startPlay(state) -- 83
	end -- 83
	ImGui.SameLine() -- 85
	if ImGui.Button("▣ Save") then -- 85
		saveScene(state) -- 86
	end -- 86
	ImGui.SameLine() -- 87
	if ImGui.Button("◇ Build") then -- 87
		state.status = zh and "Build 会在代码生成稳定后接入" or "Build will be wired after codegen is stable" -- 89
		pushConsole(state, state.status) -- 90
	end -- 90
	ImGui.SameLine() -- 92
	ImGui.TextDisabled("|") -- 93
	ImGui.SameLine() -- 94
	if ImGui.Button("＋ Add") then -- 94
		ImGui.OpenPopup("AddNodePopup") -- 95
	end -- 95
	drawAddNodePopup(state) -- 96
	ImGui.SameLine() -- 97
	if ImGui.Button("Delete") then -- 97
		deleteNode(state, state.selectedId) -- 98
	end -- 98
	ImGui.Separator() -- 99
end -- 71
local function drawScenePanel(state) -- 102
	ImGui.TextColored(themeColor, "Scene Tree") -- 103
	ImGui.SameLine() -- 104
	if ImGui.SmallButton("＋##scene_add") then -- 104
		ImGui.OpenPopup("AddNodePopup") -- 105
	end -- 105
	drawAddNodePopup(state) -- 106
	ImGui.Separator() -- 107
	drawNodeRow(state, "root", 0) -- 108
	ImGui.Separator() -- 109
	ImGui.TextDisabled(zh and "＋ 添加到当前选中节点下" or "+ adds under selected node") -- 110
end -- 102
local function bindTextureToSprite(state, node, texture) -- 113
	node.texture = texture -- 114
	node.textureBuffer.text = texture -- 115
	state.selectedAsset = texture -- 116
	state.previewDirty = true -- 117
	state.status = (zh and "已绑定贴图：" or "Texture assigned: ") .. texture -- 118
	pushConsole(state, state.status) -- 119
end -- 113
local function createSpriteFromTexture(state, texture) -- 122
	addChildNode(state, "Sprite") -- 123
	local node = state.nodes[state.selectedId] -- 124
	if node ~= nil and node.kind == "Sprite" then -- 124
		bindTextureToSprite(state, node, texture) -- 126
	end -- 126
end -- 122
local function assetIcon(asset) -- 130
	if isFolderAsset(asset) then -- 130
		return "📁" -- 131
	end -- 131
	if isTextureAsset(asset) then -- 131
		return "🖼" -- 132
	end -- 132
	if isScriptAsset(asset) then -- 132
		return "◇" -- 133
	end -- 133
	local ext = lowerExt(asset) -- 134
	if ext == "wav" or ext == "mp3" or ext == "ogg" or ext == "flac" then -- 134
		return "♪" -- 135
	end -- 135
	if ext == "ttf" or ext == "otf" or ext == "fnt" then -- 135
		return "F" -- 136
	end -- 136
	if ext == "json" or ext == "xml" or ext == "yaml" or ext == "yml" then -- 136
		return "{}" -- 137
	end -- 137
	if ext == "atlas" or ext == "model" or ext == "skel" or ext == "anim" then -- 137
		return "◆" -- 138
	end -- 138
	return "·" -- 139
end -- 130
local function startsWith(text, prefix) -- 142
	return string.sub( -- 143
		text, -- 143
		1, -- 143
		string.len(prefix) -- 143
	) == prefix -- 143
end -- 142
local function drawAssetRow(state, asset) -- 146
	if isFolderAsset(asset) then -- 146
		ImGui.TreeNode( -- 148
			(assetIcon(asset) .. "  ") .. asset, -- 148
			function() -- 148
				for ____, child in ipairs(state.assets) do -- 149
					if child ~= asset and not isFolderAsset(child) and startsWith(child, asset) then -- 149
						drawAssetRow(state, child) -- 151
					end -- 151
				end -- 151
			end -- 148
		) -- 148
		return -- 155
	end -- 155
	if ImGui.Selectable( -- 155
		(assetIcon(asset) .. "  ") .. asset, -- 157
		state.selectedAsset == asset -- 157
	) then -- 157
		state.selectedAsset = asset -- 158
		local node = state.nodes[state.selectedId] -- 159
		if node ~= nil and node.kind == "Sprite" and isTextureAsset(asset) then -- 159
			bindTextureToSprite(state, node, asset) -- 161
			return -- 162
		elseif node ~= nil and isScriptAsset(asset) then -- 162
			node.script = asset -- 164
			node.scriptBuffer.text = asset -- 165
			state.status = (zh and "已绑定脚本：" or "Script assigned: ") .. asset -- 166
		else -- 166
			state.status = zh and "已选择资源；选中 Sprite 可绑定图片，选中节点可绑定脚本" or "Asset selected; select a Sprite for images, or a node for scripts" -- 168
		end -- 168
		pushConsole(state, state.status) -- 170
	end -- 170
end -- 146
local function drawAssetsPanel(state) -- 174
	ImGui.TextColored(themeColor, "FileSystem") -- 175
	ImGui.SameLine() -- 176
	if ImGui.SmallButton("＋ File") then -- 176
		importFileDialog(state) -- 177
	end -- 177
	ImGui.SameLine() -- 178
	if ImGui.SmallButton("＋ Folder") then -- 178
		importFolderDialog(state) -- 179
	end -- 179
	ImGui.Separator() -- 180
	ImGui.TextDisabled(zh and "支持 png/jpg/webp/lua/ts/json/音频/字体/模型等；文件夹会递归导入。" or "Supports images, scripts, json, audio, fonts, models; folders import recursively.") -- 181
	ImGui.Separator() -- 182
	if #state.assets == 0 then -- 182
		ImGui.TextDisabled(zh and "点击 + File 或 + Folder 导入资源。" or "Click + File or + Folder to import assets.") -- 184
		return -- 185
	end -- 185
	for ____, asset in ipairs(state.assets) do -- 187
		if isFolderAsset(asset) then -- 187
			drawAssetRow(state, asset) -- 189
		end -- 189
	end -- 189
	for ____, asset in ipairs(state.assets) do -- 192
		local insideFolder = false -- 193
		for ____, folder in ipairs(state.assets) do -- 194
			if isFolderAsset(folder) and startsWith(asset, folder) then -- 194
				insideFolder = true -- 195
			end -- 195
		end -- 195
		if not insideFolder and not isFolderAsset(asset) then -- 195
			drawAssetRow(state, asset) -- 197
		end -- 197
	end -- 197
	if state.selectedAsset ~= "" and isTextureAsset(state.selectedAsset) then -- 197
		ImGui.Separator() -- 200
		ImGui.TextColored(themeColor, "Texture Preview") -- 201
		local ok = pcall(function() return ImGui.Image( -- 202
			state.selectedAsset, -- 202
			Vec2(160, 120) -- 202
		) end) -- 202
		if not ok then -- 202
			ImGui.TextDisabled(zh and "无法预览该贴图；但仍可尝试绑定到 Sprite。" or "Unable to preview; still can bind to Sprite.") -- 203
		end -- 203
		local selectedNode = state.nodes[state.selectedId] -- 204
		if selectedNode ~= nil and selectedNode.kind == "Sprite" then -- 204
			if ImGui.Button(zh and "绑定到当前 Sprite" or "Bind To Sprite") then -- 204
				bindTextureToSprite(state, selectedNode, state.selectedAsset) -- 206
			end -- 206
			ImGui.SameLine() -- 207
		end -- 207
		if ImGui.Button(zh and "用此贴图创建 Sprite" or "Create Sprite") then -- 207
			createSpriteFromTexture(state, state.selectedAsset) -- 209
		end -- 209
	end -- 209
end -- 174
local function scriptTemplate(node) -- 213
	local name = node ~= nil and node.name or "Script" -- 214
	return (((((("-- " .. name) .. " behavior\n") .. "return function(node, scene, nodes)\n") .. "\tif node == nil then\n") .. "\t\tprint(\"[SceneScript] " .. name .. ": node is nil; run the scene/game preview instead of this behavior script directly.\")\n") .. "\t\treturn\n\tend\n") .. "\t-- write behavior here\nend\n"
end -- 213
local function loadScriptIntoEditor(state, node, scriptPath) -- 218
	if node ~= nil then -- 218
		node.script = scriptPath -- 220
		node.scriptBuffer.text = scriptPath -- 221
		state.activeScriptNodeId = node.id -- 222
	else -- 222
		state.activeScriptNodeId = nil -- 224
	end -- 224
	state.scriptPathBuffer.text = scriptPath -- 226
	local scriptFile = Path(Content.writablePath, scriptPath) -- 227
	if Content:exist(scriptFile) then -- 227
		state.scriptContentBuffer.text = Content:load(scriptFile) or "" -- 229
	elseif Content:exist(scriptPath) then -- 229
		state.scriptContentBuffer.text = Content:load(scriptPath) or "" -- 231
	else -- 231
		state.scriptContentBuffer.text = scriptTemplate(node) -- 233
	end -- 233
	state.mode = "Script" -- 235
end -- 218
local function openScriptForNode(state, node) -- 238
	local path = node.script ~= "" and node.script or ("Script/" .. node.name) .. ".lua" -- 239
	loadScriptIntoEditor(state, node, path) -- 240
end -- 238
local function saveScriptFile(state, node) -- 243
	local path = state.scriptPathBuffer.text ~= "" and state.scriptPathBuffer.text or "Script/NewScript.lua" -- 244
	state.scriptPathBuffer.text = path -- 245
	if node ~= nil then -- 245
		node.script = path -- 247
		node.scriptBuffer.text = path -- 248
	end -- 248
	local scriptFile = Path(Content.writablePath, path) -- 250
	Content:mkdir(Path:getPath(scriptFile)) -- 251
	if Content:save(scriptFile, state.scriptContentBuffer.text) then -- 251
		state.status = (zh and "脚本已保存：" or "Script saved: ") .. path -- 253
		if state.selectedAsset ~= path then -- 253
			state.selectedAsset = path -- 254
		end -- 254
		local exists = false -- 255
		for ____, asset in ipairs(state.assets) do -- 256
			if asset == path then -- 256
				exists = true -- 256
			end -- 256
		end -- 256
		if not exists then -- 256
			local ____state_assets_1 = state.assets -- 256
			____state_assets_1[#____state_assets_1 + 1] = path -- 257
		end -- 257
	else -- 257
		state.status = zh and "脚本保存失败" or "Failed to save script" -- 259
	end -- 259
	pushConsole(state, state.status) -- 261
end -- 243
local function currentScriptPath(state, node) -- 264
	if state.scriptPathBuffer.text ~= "" then -- 264
		return state.scriptPathBuffer.text -- 265
	end -- 265
	if node ~= nil and node.script ~= "" then -- 265
		return node.script -- 266
	end -- 266
	if node ~= nil then -- 266
		return ("Script/" .. node.name) .. ".lua" -- 267
	end -- 267
	return "Script/NewScript.lua" -- 268
end -- 264
local function sendWebIDEMessage(payload) -- 271
	local text = json.encode(payload) -- 272
	if text ~= nil then -- 272
		emit("AppWS", "Send", text) -- 273
	end -- 273
end -- 271
local function openScriptInWebIDE(state, node) -- 271
	local scriptPath = currentScriptPath(state, node) -- 272
	state.scriptPathBuffer.text = scriptPath -- 273
	if state.scriptContentBuffer.text == "" then -- 273
		state.scriptContentBuffer.text = scriptTemplate(node) -- 275
	end -- 275
	saveScriptFile(state, node) -- 277
	local title = Path:getFilename(scriptPath) or scriptPath -- 278
	local fullScriptPath = Path(Content.writablePath, scriptPath) -- 279
	sendWebIDEMessage({ -- 280
		name = "UpdateFile", -- 281
		file = fullScriptPath, -- 282
		exists = true, -- 283
		content = state.scriptContentBuffer.text -- 284
	}) -- 284
	sendWebIDEMessage({ -- 286
		name = "OpenFile", -- 287
		file = fullScriptPath, -- 288
		title = title, -- 289
		folder = false, -- 290
		position = {lineNumber = 1, column = 1} -- 291
	}) -- 291
	local editingInfo = {index = 0, files = {{key = scriptPath, title = title, folder = false, position = {lineNumber = 1, column = 1}}}} -- 293
	local editingText = json.encode(editingInfo) -- 302
	if editingText ~= nil then -- 288
		Content:mkdir(Path(Content.writablePath, ".dora")) -- 290
		Content:save( -- 291
			Path(Content.writablePath, ".dora", "open-script.editing.json"), -- 291
			editingText -- 291
		) -- 291
	end -- 291
	App:openURL("http://127.0.0.1:8866/?file=" .. scriptPath) -- 293
	state.status = (zh and "已打开 Web IDE：" or "Opened Web IDE: ") .. scriptPath -- 294
	pushConsole(state, state.status) -- 295
end -- 271
local function drawScriptAssetList(state, node) -- 298
	ImGui.TextColored(themeColor, zh and "脚本资源" or "Script Assets") -- 299
	for ____, asset in ipairs(state.assets) do -- 300
		if isScriptAsset(asset) and not isFolderAsset(asset) then -- 300
			if ImGui.Selectable("◇  " .. asset, state.selectedAsset == asset) then -- 300
				state.selectedAsset = asset -- 303
				loadScriptIntoEditor(state, node, asset) -- 304
			end -- 304
		end -- 304
	end -- 304
end -- 298
local function drawScriptPanel(state) -- 310
	local activeId = state.activeScriptNodeId or state.selectedId -- 311
	local node = state.nodes[activeId] -- 312
	ImGui.TextColored(themeColor, "Script Workspace") -- 313
	ImGui.SameLine() -- 314
	ImGui.TextDisabled(node ~= nil and node.name or (zh and "独立文件模式" or "File mode")) -- 315
	ImGui.Separator() -- 316
	ImGui.BeginChild( -- 317
		"ScriptSidebar", -- 317
		Vec2(220, 0), -- 317
		{}, -- 317
		noScrollFlags, -- 317
		function() -- 317
			drawScriptAssetList(state, node) -- 318
			ImGui.Separator() -- 319
			if ImGui.Button(zh and "新建脚本" or "New Script") then -- 319
				local scriptName = node ~= nil and node.name or "NewScript" -- 321
				local path = ("Script/" .. scriptName) .. ".lua" -- 322
				state.scriptPathBuffer.text = path -- 323
				state.scriptContentBuffer.text = scriptTemplate(node) -- 324
				if node ~= nil then -- 324
					node.script = path -- 326
					node.scriptBuffer.text = path -- 327
					state.activeScriptNodeId = node.id -- 328
				end -- 328
			end -- 328
			if ImGui.Button(zh and "导入脚本文件" or "Import Script") then -- 328
				importFileDialog(state) -- 331
			end -- 331
			if node ~= nil and ImGui.Button(zh and "绑定选中资源" or "Attach Selected") then -- 331
				if state.selectedAsset ~= "" and isScriptAsset(state.selectedAsset) then -- 331
					loadScriptIntoEditor(state, node, state.selectedAsset) -- 334
				end -- 334
			end -- 334
			if ImGui.Button(zh and "重新加载" or "Reload") then -- 334
				loadScriptIntoEditor(state, node, state.scriptPathBuffer.text) -- 338
			end -- 338
		end -- 317
	) -- 317
	ImGui.SameLine() -- 341
	ImGui.PushStyleColor( -- 342
		"ChildBg", -- 342
		scriptPanelBg, -- 342
		function() -- 342
			ImGui.BeginChild( -- 343
				"ScriptEditorPane", -- 343
				Vec2(0, 0), -- 343
				{}, -- 343
				noScrollFlags, -- 343
				function() -- 343
					ImGui.TextDisabled(zh and "脚本路径" or "Script Path") -- 344
					ImGui.InputText("##ScriptPath", state.scriptPathBuffer, inputTextFlags) -- 345
					ImGui.SameLine() -- 346
					if ImGui.Button(zh and "保存" or "Save") then -- 346
						saveScriptFile(state, node) -- 347
					end -- 347
					ImGui.SameLine() -- 348
					if ImGui.Button(zh and "Web IDE 打开" or "Open in Web IDE") then -- 348
						openScriptInWebIDE(state, node) -- 349
					end -- 349
					if node ~= nil then -- 349
						ImGui.SameLine() -- 351
						if ImGui.Button(zh and "绑定到节点" or "Attach Node") then -- 351
							node.script = state.scriptPathBuffer.text -- 353
							node.scriptBuffer.text = node.script -- 354
							state.status = (zh and "脚本已绑定到节点：" or "Script attached to node: ") .. node.name -- 355
							pushConsole(state, state.status) -- 356
						end -- 356
					end -- 356
					ImGui.Separator() -- 359
					ImGui.InputTextMultiline( -- 360
						"##ScriptEditor", -- 360
						state.scriptContentBuffer, -- 360
						Vec2(0, -4), -- 360
						{} -- 360
					) -- 360
				end -- 343
			) -- 343
		end -- 342
	) -- 342
end -- 310
local function viewportScale(state) -- 365
	return math.max(0.25, state.zoom / 100) -- 366
end -- 365
local function clampZoom(value) -- 369
	return math.max( -- 370
		25, -- 370
		math.min(400, value) -- 370
	) -- 370
end -- 369
local function zoomViewportAt(state, delta, screenX, screenY) -- 373
	if delta == 0 then -- 373
		return -- 374
	end -- 374
	local before = state.zoom -- 375
	local beforeScale = viewportScale(state) -- 376
	local p = state.preview -- 377
	local centerX = p.x + p.width / 2 -- 378
	local centerY = p.y + p.height / 2 -- 379
	local sceneX = (screenX - centerX - state.viewportPanX) / beforeScale -- 380
	local sceneY = (centerY - screenY - state.viewportPanY) / beforeScale -- 381
	state.zoom = clampZoom(state.zoom + delta) -- 382
	if state.zoom ~= before then -- 382
		local afterScale = viewportScale(state) -- 384
		state.viewportPanX = screenX - centerX - sceneX * afterScale -- 385
		state.viewportPanY = centerY - screenY - sceneY * afterScale -- 386
		state.previewDirty = true -- 387
	end -- 387
end -- 373
local function zoomViewportFromCenter(state, delta) -- 391
	local p = state.preview -- 392
	zoomViewportAt(state, delta, p.x + p.width / 2, p.y + p.height / 2) -- 393
end -- 391
local function screenToScene(state, screenX, screenY) -- 396
	local p = state.preview -- 397
	local scale = viewportScale(state) -- 398
	local localX = screenX - (p.x + p.width / 2) - state.viewportPanX -- 399
	local localY = p.y + p.height / 2 - screenY - state.viewportPanY -- 400
	return {localX / scale, localY / scale} -- 401
end -- 396
local function pickNodeAt(state, screenX, screenY) -- 404
	local sceneX, sceneY = table.unpack( -- 405
		screenToScene(state, screenX, screenY), -- 405
		1, -- 405
		2 -- 405
	) -- 405
	do -- 405
		local i = #state.order -- 406
		while i >= 1 do -- 406
			local id = state.order[i] -- 407
			local node = state.nodes[id] -- 408
			if node ~= nil and id ~= "root" and node.visible then -- 408
				local dx = sceneX - node.x -- 410
				local dy = sceneY - node.y -- 411
				local radius = node.kind == "Camera" and 185 or (node.kind == "Sprite" and 82 or 54) -- 412
				if dx * dx + dy * dy <= radius * radius then -- 412
					return id -- 413
				end -- 413
			end -- 413
			i = i - 1 -- 406
		end -- 406
	end -- 406
	return nil -- 416
end -- 404
local function handleViewportMouse(state, hovered) -- 419
	if not hovered then -- 419
		return -- 420
	end -- 420
	local spacePressed = Keyboard:isKeyPressed("Space") -- 421
	local wheel = Mouse.wheel -- 422
	local wheelDelta = math.abs(wheel.y) >= math.abs(wheel.x) and wheel.y or wheel.x -- 423
	if wheelDelta ~= 0 then -- 423
		local mouse = ImGui.GetMousePos() -- 425
		zoomViewportAt(state, wheelDelta > 0 and 6 or -6, mouse.x, mouse.y) -- 426
	end -- 426
	if ImGui.IsMouseClicked(2) then -- 426
		state.draggingNodeId = nil -- 429
		state.draggingViewport = true -- 430
		ImGui.ResetMouseDragDelta(2) -- 431
	end -- 431
	if ImGui.IsMouseClicked(0) then -- 431
		if spacePressed then -- 431
			state.draggingNodeId = nil -- 435
			state.draggingViewport = true -- 436
		else -- 436
			local mouse = ImGui.GetMousePos() -- 438
			local picked = pickNodeAt(state, mouse.x, mouse.y) -- 439
			if picked ~= nil then -- 439
				state.selectedId = picked -- 441
				state.previewDirty = true -- 442
				state.draggingNodeId = picked -- 443
				state.draggingViewport = false -- 444
			else -- 444
				state.draggingNodeId = nil -- 446
				state.draggingViewport = true -- 447
			end -- 447
		end -- 447
		ImGui.ResetMouseDragDelta(0) -- 450
	end -- 450
	if ImGui.IsMouseReleased(0) or ImGui.IsMouseReleased(2) then -- 450
		state.draggingNodeId = nil -- 453
		state.draggingViewport = false -- 454
	end -- 454
	if ImGui.IsMouseDragging(0) or ImGui.IsMouseDragging(2) then -- 454
		local panButton = ImGui.IsMouseDragging(2) and 2 or 0 -- 457
		local delta = ImGui.GetMouseDragDelta(panButton) -- 458
		if delta.x ~= 0 or delta.y ~= 0 then -- 458
			if state.draggingNodeId ~= nil and panButton == 0 then -- 458
				local node = state.nodes[state.draggingNodeId] -- 461
				if node ~= nil then -- 461
					local scale = viewportScale(state) -- 463
					node.x = node.x + delta.x / scale -- 464
					node.y = node.y - delta.y / scale -- 465
					if state.snapEnabled then -- 465
						local step = 16 -- 467
						node.x = math.floor(node.x / step + 0.5) * step -- 468
						node.y = math.floor(node.y / step + 0.5) * step -- 469
					end -- 469
				end -- 469
			elseif state.draggingViewport then -- 469
				state.viewportPanX = state.viewportPanX + delta.x -- 473
				state.viewportPanY = state.viewportPanY - delta.y -- 474
			end -- 474
			ImGui.ResetMouseDragDelta(panButton) -- 476
		end -- 476
	end -- 476
end -- 419
local function drawViewportToolButton(state, tool, label) -- 481
	local active = state.viewportTool == tool -- 482
	if active then -- 482
		ImGui.PushStyleColor( -- 484
			"Button", -- 484
			Color(4281349698), -- 484
			function() -- 484
				ImGui.PushStyleColor( -- 485
					"Text", -- 485
					themeColor, -- 485
					function() -- 485
						if ImGui.Button(label) then -- 485
							state.viewportTool = tool -- 486
						end -- 486
					end -- 485
				) -- 485
			end -- 484
		) -- 484
	elseif ImGui.Button(label) then -- 484
		state.viewportTool = tool -- 490
	end -- 490
end -- 481
local function drawViewport(state) -- 494
	ImGui.TextColored(themeColor, "2D") -- 495
	ImGui.SameLine() -- 496
	drawViewportToolButton(state, "Select", "Select") -- 497
	ImGui.SameLine() -- 498
	drawViewportToolButton(state, "Move", "Move") -- 499
	ImGui.SameLine() -- 500
	drawViewportToolButton(state, "Rotate", "Rotate") -- 501
	ImGui.SameLine() -- 502
	drawViewportToolButton(state, "Scale", "Scale") -- 503
	ImGui.SameLine() -- 504
	ImGui.TextDisabled("|") -- 505
	ImGui.SameLine() -- 506
	local snapChanged, snap = ImGui.Checkbox("Snap", state.snapEnabled) -- 507
	if snapChanged then -- 507
		state.snapEnabled = snap -- 508
	end -- 508
	ImGui.SameLine() -- 509
	local gridChanged, grid = ImGui.Checkbox("Grid", state.showGrid) -- 510
	if gridChanged then -- 510
		state.showGrid = grid -- 511
		state.previewDirty = true -- 511
	end -- 511
	ImGui.SameLine() -- 512
	if ImGui.Button("Center") then -- 512
		state.viewportPanX = 0 -- 514
		state.viewportPanY = 0 -- 515
		state.zoom = 100 -- 516
		state.previewDirty = true -- 517
	end -- 517
	ImGui.SameLine() -- 519
	ImGui.TextDisabled("Main.scene") -- 520
	ImGui.Separator() -- 521
	local cursor = ImGui.GetCursorScreenPos() -- 522
	local avail = ImGui.GetContentRegionAvail() -- 523
	local viewportWidth = math.max(360, avail.x - 8) -- 524
	local viewportHeight = math.max(300, avail.y - 38) -- 525
	if math.abs(state.preview.width - viewportWidth) > 1 or math.abs(state.preview.height - viewportHeight) > 1 then -- 525
		state.previewDirty = true -- 527
	end -- 527
	state.preview.x = cursor.x -- 529
	state.preview.y = cursor.y -- 530
	state.preview.width = viewportWidth -- 531
	state.preview.height = viewportHeight -- 532
	updatePreviewRuntime(state) -- 533
	ImGui.Dummy(Vec2(viewportWidth, viewportHeight)) -- 534
	local hovered = ImGui.IsItemHovered() -- 535
	handleViewportMouse(state, hovered) -- 536
	ImGui.SetCursorScreenPos(Vec2(cursor.x + viewportWidth - 142, cursor.y + 8)) -- 537
	if ImGui.SmallButton("-##viewport_zoom_out") then -- 537
		zoomViewportFromCenter(state, -10) -- 538
	end -- 538
	ImGui.SameLine() -- 539
	ImGui.PushStyleColor( -- 540
		"Text", -- 540
		themeColor, -- 540
		function() -- 540
			if ImGui.SmallButton(tostring(math.floor(state.zoom)) .. "%") then -- 540
				state.zoom = 100 -- 542
				state.viewportPanX = 0 -- 543
				state.viewportPanY = 0 -- 544
				state.previewDirty = true -- 545
			end -- 545
		end -- 540
	) -- 540
	ImGui.SameLine() -- 548
	if ImGui.SmallButton("+##viewport_zoom_in") then -- 548
		zoomViewportFromCenter(state, 10) -- 549
	end -- 549
	ImGui.SetCursorScreenPos(Vec2(cursor.x, cursor.y + viewportHeight + 4)) -- 550
	ImGui.Separator() -- 551
	ImGui.TextColored(okColor, "Dora 2D Viewport") -- 552
	ImGui.SameLine() -- 553
	ImGui.TextDisabled(zh and "滚轮缩放；中键/Space+拖动平移；触控板双指滚动等价滚轮。" or "Wheel zoom; MMB or Space+drag pans; trackpad two-finger scroll is wheel.") -- 554
end -- 494
local function drawInspector(state) -- 557
	ImGui.TextColored(themeColor, "Inspector") -- 558
	ImGui.Separator() -- 559
	local node = state.nodes[state.selectedId] -- 560
	if node == nil then -- 560
		ImGui.TextDisabled(zh and "没有选中节点" or "No node selected") -- 562
		return -- 563
	end -- 563
	ImGui.Text((iconFor(node.kind) .. "  ") .. node.kind) -- 565
	if ImGui.InputText("Name", node.nameBuffer, inputTextFlags) then -- 565
		node.name = node.nameBuffer.text -- 566
	end -- 566
	local changed, x, y = ImGui.DragFloat2( -- 567
		"Position", -- 567
		node.x, -- 567
		node.y, -- 567
		1, -- 567
		-10000, -- 567
		10000, -- 567
		"%.1f" -- 567
	) -- 567
	if changed then -- 567
		node.x = x -- 568
		node.y = y -- 568
	end -- 568
	changed, x, y = ImGui.DragFloat2( -- 569
		"Scale", -- 569
		node.scaleX, -- 569
		node.scaleY, -- 569
		0.01, -- 569
		-100, -- 569
		100, -- 569
		"%.2f" -- 569
	) -- 569
	if changed then -- 569
		node.scaleX = x -- 570
		node.scaleY = y -- 570
	end -- 570
	local angleChanged, angle = ImGui.DragFloat( -- 571
		"Rotation", -- 571
		node.rotation, -- 571
		1, -- 571
		-360, -- 571
		360, -- 571
		"%.1f" -- 571
	) -- 571
	if angleChanged then -- 571
		node.rotation = angle -- 572
	end -- 572
	local visibleChanged, visible = ImGui.Checkbox("Visible", node.visible) -- 573
	if visibleChanged then -- 573
		node.visible = visible -- 574
	end -- 574
	ImGui.Separator() -- 575
	if ImGui.InputText("Script", node.scriptBuffer, inputTextFlags) then -- 575
		node.script = node.scriptBuffer.text -- 576
	end -- 576
	if ImGui.Button(zh and "打开脚本" or "Open Script") then -- 576
		openScriptForNode(state, node) -- 577
	end -- 577
	if node.kind == "Sprite" then -- 577
		ImGui.Separator() -- 579
		if ImGui.InputText("Texture", node.textureBuffer, inputTextFlags) then -- 579
			node.texture = node.textureBuffer.text -- 581
			state.previewDirty = true -- 582
		end -- 582
		if ImGui.Button(zh and "导入并绑定贴图" or "Import Texture") then -- 582
			App:openFileDialog( -- 585
				false, -- 585
				function(path) -- 585
					local asset = addAssetPath(state, path) -- 586
					if asset ~= nil and isTextureAsset(asset) then -- 586
						bindTextureToSprite(state, node, asset) -- 587
					end -- 587
				end -- 585
			) -- 585
		end -- 585
		ImGui.SameLine() -- 590
		if ImGui.Button(zh and "绑定选中贴图" or "Use Selected") then -- 590
			if state.selectedAsset ~= "" and isTextureAsset(state.selectedAsset) then -- 590
				bindTextureToSprite(state, node, state.selectedAsset) -- 592
			end -- 592
		end -- 592
	elseif node.kind == "Label" then -- 592
		ImGui.Separator() -- 595
		if ImGui.InputText("Text", node.textBuffer, inputTextFlags) then -- 595
			node.text = node.textBuffer.text -- 596
		end -- 596
	elseif node.kind == "Camera" then -- 596
		ImGui.Separator() -- 598
		ImGui.TextDisabled(zh and "Camera 显示真实取景框。" or "Camera shows a real frame in viewport.") -- 599
	end -- 599
end -- 557
local function drawConsole(state) -- 603
	ImGui.TextColored(themeColor, "Console") -- 604
	ImGui.SameLine() -- 605
	ImGui.TextColored(okColor, state.status) -- 606
	ImGui.Separator() -- 607
	for ____, line in ipairs(state.console) do -- 608
		ImGui.TextDisabled(line) -- 608
	end -- 608
end -- 603
local function drawVerticalSplitter(id, height, onDrag) -- 611
	ImGui.PushStyleColor( -- 612
		"Button", -- 612
		Color(4281612868), -- 612
		function() -- 612
			ImGui.PushStyleColor( -- 613
				"ButtonHovered", -- 613
				Color(4283259240), -- 613
				function() -- 613
					ImGui.PushStyleColor( -- 614
						"ButtonActive", -- 614
						Color(4294954035), -- 614
						function() -- 614
							ImGui.Button( -- 615
								"##" .. id, -- 615
								Vec2(12, height) -- 615
							) -- 615
						end -- 614
					) -- 614
				end -- 613
			) -- 613
		end -- 612
	) -- 612
	if ImGui.IsItemHovered() then -- 612
		ImGui.BeginTooltip(function() return ImGui.Text(zh and "拖动调整面板宽度" or "Drag to resize panel") end) -- 620
	end -- 620
	if ImGui.IsItemActive() and ImGui.IsMouseDragging(0) then -- 620
		local delta = ImGui.GetMouseDragDelta(0) -- 623
		if delta.x ~= 0 then -- 623
			onDrag(delta.x) -- 625
			ImGui.ResetMouseDragDelta(0) -- 626
		end -- 626
	end -- 626
end -- 611
function ____exports.drawEditor(state) -- 631
	local size = App.visualSize -- 632
	local margin = 10 -- 633
	local nativeFooterSafeArea = 60 -- keep Dora native footer/settings layer outside the editor window
	local windowWidth = math.max(360, size.width - margin * 2) -- 634
	local windowHeight = math.max(260, size.height - margin * 2 - nativeFooterSafeArea) -- 635
	ImGui.SetNextWindowPos( -- 636
		Vec2(margin, margin), -- 636
		"Always" -- 636
	) -- 636
	ImGui.SetNextWindowSize( -- 637
		Vec2(windowWidth, windowHeight), -- 637
		"Always" -- 637
	) -- 637
	ImGui.SetNextWindowBgAlpha(state.mode == "Script" and 0.96 or 0.1) -- 638
	ImGui.Begin( -- 639
		"Dora Visual Editor", -- 639
		mainWindowFlags, -- 639
		function() -- 639
			drawHeader(state) -- 640
			local avail = ImGui.GetContentRegionAvail() -- 641
			local bottomHeight = math.max(72, math.min(state.bottomHeight, math.floor(avail.y * 0.28))) -- 642
			if state.mode == "Script" then -- 642
				local scriptHeight = math.max(180, avail.y - bottomHeight - 8) -- 644
				ImGui.PushStyleColor( -- 645
					"ChildBg", -- 645
					panelBg, -- 645
					function() -- 645
						ImGui.BeginChild( -- 646
							"ScriptWorkspaceRoot", -- 646
							Vec2(0, scriptHeight), -- 646
							{}, -- 646
							noScrollFlags, -- 646
							function() return drawScriptPanel(state) end -- 646
						) -- 646
					end -- 645
				) -- 645
				ImGui.BeginChild( -- 648
					"ScriptConsoleDock", -- 648
					Vec2(0, bottomHeight), -- 648
					{}, -- 648
					noScrollFlags, -- 648
					function() return drawConsole(state) end -- 648
				) -- 648
				return -- 649
			end -- 649
			local mainHeight = math.max(160, avail.y - bottomHeight - 10) -- 651
			local availableWidth = math.max(520, avail.x - 4) -- 652
			state.leftWidth = math.max( -- 653
				190, -- 653
				math.min(state.leftWidth, availableWidth - state.rightWidth - 320) -- 653
			) -- 653
			state.rightWidth = math.max( -- 654
				250, -- 654
				math.min(state.rightWidth, availableWidth - state.leftWidth - 320) -- 654
			) -- 654
			local centerWidth = math.max(220, availableWidth - state.leftWidth - state.rightWidth - 24) -- 655
			local leftTopHeight = math.floor(mainHeight * 0.58) -- 656
			local leftBottomHeight = mainHeight - leftTopHeight - 8 -- 657
			ImGui.BeginChild( -- 659
				"LeftDock", -- 659
				Vec2(state.leftWidth, mainHeight), -- 659
				{}, -- 659
				noScrollFlags, -- 659
				function() -- 659
					ImGui.BeginChild( -- 660
						"SceneDock", -- 660
						Vec2(0, leftTopHeight), -- 660
						{}, -- 660
						noScrollFlags, -- 660
						function() return drawScenePanel(state) end -- 660
					) -- 660
					ImGui.BeginChild( -- 661
						"AssetDock", -- 661
						Vec2(0, leftBottomHeight), -- 661
						{}, -- 661
						noScrollFlags, -- 661
						function() return drawAssetsPanel(state) end -- 661
					) -- 661
				end -- 659
			) -- 659
			ImGui.SameLine() -- 663
			drawVerticalSplitter( -- 664
				"LeftSplitter", -- 664
				mainHeight, -- 664
				function(deltaX) -- 664
					state.leftWidth = math.max( -- 665
						190, -- 665
						math.min(state.leftWidth + deltaX, availableWidth - state.rightWidth - 320) -- 665
					) -- 665
				end -- 664
			) -- 664
			ImGui.SameLine() -- 667
			ImGui.PushStyleColor( -- 668
				"ChildBg", -- 668
				transparent, -- 668
				function() -- 668
					ImGui.BeginChild( -- 669
						"CenterDock", -- 669
						Vec2(centerWidth, mainHeight), -- 669
						{}, -- 669
						noScrollFlags, -- 669
						function() -- 669
							if state.mode == "Script" then -- 669
								drawScriptPanel(state) -- 670
							else -- 670
								drawViewport(state) -- 670
							end -- 670
						end -- 669
					) -- 669
				end -- 668
			) -- 668
			ImGui.SameLine() -- 673
			drawVerticalSplitter( -- 674
				"RightSplitter", -- 674
				mainHeight, -- 674
				function(deltaX) -- 674
					state.rightWidth = math.max( -- 675
						250, -- 675
						math.min(state.rightWidth - deltaX, availableWidth - state.leftWidth - 320) -- 675
					) -- 675
				end -- 674
			) -- 674
			ImGui.SameLine() -- 677
			ImGui.BeginChild( -- 678
				"RightDock", -- 678
				Vec2(state.rightWidth, mainHeight), -- 678
				{}, -- 678
				noScrollFlags, -- 678
				function() return drawInspector(state) end -- 678
			) -- 678
			ImGui.BeginChild( -- 679
				"BottomConsoleDock", -- 679
				Vec2(0, bottomHeight), -- 679
				{}, -- 679
				noScrollFlags, -- 679
				function() return drawConsole(state) end -- 679
			) -- 679
		end -- 639
	) -- 639
	drawGamePreviewWindow(state) -- 681
end -- 631
function ____exports.drawRuntimeError(message) -- 684
	local size = App.visualSize -- 685
	ImGui.SetNextWindowPos( -- 686
		Vec2(10, 10), -- 686
		"Always" -- 686
	) -- 686
	ImGui.SetNextWindowSize( -- 687
		Vec2( -- 687
			math.max(320, size.width - 20), -- 687
			math.max(220, size.height - 20) -- 687
		), -- 687
		"Always" -- 687
	) -- 687
	ImGui.Begin( -- 688
		"Dora Visual Editor Error", -- 688
		mainWindowFlags, -- 688
		function() -- 688
			ImGui.TextColored(warnColor, "SceneImGuiEditor runtime error") -- 689
			ImGui.Separator() -- 690
			ImGui.TextWrapped(message or "unknown error") -- 691
		end -- 688
	) -- 688
end -- 684
return ____exports -- 684
