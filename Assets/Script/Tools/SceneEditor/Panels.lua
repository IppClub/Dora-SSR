-- [ts]: Panels.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Color = ____Dora.Color -- 1
local Content = ____Dora.Content -- 1
local Keyboard = ____Dora.Keyboard -- 1
local Path = ____Dora.Path -- 1
local Vec2 = ____Dora.Vec2 -- 1
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
local sceneSaveFile = Path(Content.writablePath, ".dora", "imgui-editor.scene.json") -- 11
local function drawNodeRow(state, id, depth) -- 13
	local node = state.nodes[id] -- 14
	if node == nil then -- 14
		return -- 15
	end -- 15
	local indent = string.rep("  ", depth) -- 16
	local label = ((((indent .. iconFor(node.kind)) .. "  ") .. node.name) .. "##tree_") .. id -- 17
	if ImGui.Selectable(label, state.selectedId == id) then -- 17
		state.selectedId = id -- 19
		state.previewDirty = true -- 20
	end -- 20
	for ____, childId in ipairs(node.children) do -- 22
		drawNodeRow(state, childId, depth + 1) -- 23
	end -- 23
end -- 13
local function drawAddNodePopup(state) -- 27
	ImGui.BeginPopup( -- 28
		"AddNodePopup", -- 28
		function() -- 28
			ImGui.TextColored(themeColor, zh and "添加节点" or "Add Node") -- 29
			ImGui.Separator() -- 30
			if ImGui.Selectable("○  Node", false) then -- 30
				addChildNode(state, "Node") -- 31
				ImGui.CloseCurrentPopup() -- 31
			end -- 31
			if ImGui.Selectable("▣  Sprite", false) then -- 31
				addChildNode(state, "Sprite") -- 32
				ImGui.CloseCurrentPopup() -- 32
			end -- 32
			if ImGui.Selectable("T  Label", false) then -- 32
				addChildNode(state, "Label") -- 33
				ImGui.CloseCurrentPopup() -- 33
			end -- 33
			if ImGui.Selectable("◉  Camera", false) then -- 33
				addChildNode(state, "Camera") -- 34
				ImGui.CloseCurrentPopup() -- 34
			end -- 34
		end -- 28
	) -- 28
end -- 27
local function saveScene(state) -- 38
	Content:mkdir(Path(Content.writablePath, ".dora")) -- 39
	local data = {version = 1, nodes = {}} -- 40
	for ____, id in ipairs(state.order) do -- 41
		local node = state.nodes[id] -- 42
		if node ~= nil then -- 42
			local ____data_nodes_0 = data.nodes -- 42
			____data_nodes_0[#____data_nodes_0 + 1] = { -- 44
				id = node.id, -- 45
				kind = node.kind, -- 46
				name = node.name, -- 47
				parentId = node.parentId, -- 48
				x = node.x, -- 49
				y = node.y, -- 50
				scaleX = node.scaleX, -- 51
				scaleY = node.scaleY, -- 52
				rotation = node.rotation, -- 53
				visible = node.visible, -- 54
				texture = node.texture, -- 55
				text = node.text, -- 56
				script = node.script -- 57
			} -- 57
		end -- 57
	end -- 57
	local text = json.encode(data) -- 61
	if text ~= nil and Content:save(sceneSaveFile, text) then -- 61
		state.status = (zh and "已保存：" or "Saved: ") .. sceneSaveFile -- 63
	else -- 63
		state.status = zh and "保存失败" or "Save failed" -- 65
	end -- 65
	pushConsole(state, state.status) -- 67
end -- 38
local function drawHeader(state) -- 70
	ImGui.TextColored(themeColor, "✦ Dora Visual Editor") -- 71
	ImGui.SameLine() -- 72
	if ImGui.Button("2D") then -- 72
		state.mode = "2D" -- 73
	end -- 73
	ImGui.SameLine() -- 74
	if ImGui.Button("Script") then -- 74
		state.mode = "Script" -- 75
	end -- 75
	ImGui.SameLine() -- 76
	ImGui.TextDisabled(zh and "Native ImGui / Godot-like" or "Native ImGui / Godot-like") -- 77
	ImGui.Separator() -- 78
	if ImGui.Button("▶ Run") then -- 78
		state.status = zh and "Run 会在下一步接入场景运行" or "Run will be wired in the next step" -- 80
		pushConsole(state, state.status) -- 81
	end -- 81
	ImGui.SameLine() -- 83
	if ImGui.Button("▣ Save") then -- 83
		saveScene(state) -- 84
	end -- 84
	ImGui.SameLine() -- 85
	if ImGui.Button("◇ Build") then -- 85
		state.status = zh and "Build 会在代码生成稳定后接入" or "Build will be wired after codegen is stable" -- 87
		pushConsole(state, state.status) -- 88
	end -- 88
	ImGui.SameLine() -- 90
	ImGui.TextDisabled("|") -- 91
	ImGui.SameLine() -- 92
	if ImGui.Button("＋ Add") then -- 92
		ImGui.OpenPopup("AddNodePopup") -- 93
	end -- 93
	drawAddNodePopup(state) -- 94
	ImGui.SameLine() -- 95
	if ImGui.Button("Delete") then -- 95
		deleteNode(state, state.selectedId) -- 96
	end -- 96
	ImGui.Separator() -- 97
end -- 70
local function drawScenePanel(state) -- 100
	ImGui.TextColored(themeColor, "Scene Tree") -- 101
	ImGui.SameLine() -- 102
	if ImGui.SmallButton("＋##scene_add") then -- 102
		ImGui.OpenPopup("AddNodePopup") -- 103
	end -- 103
	drawAddNodePopup(state) -- 104
	ImGui.Separator() -- 105
	drawNodeRow(state, "root", 0) -- 106
	ImGui.Separator() -- 107
	ImGui.TextDisabled(zh and "＋ 添加到当前选中节点下" or "+ adds under selected node") -- 108
end -- 100
local function bindTextureToSprite(state, node, texture) -- 111
	node.texture = texture -- 112
	node.textureBuffer.text = texture -- 113
	state.selectedAsset = texture -- 114
	state.previewDirty = true -- 115
	state.status = (zh and "已绑定贴图：" or "Texture assigned: ") .. texture -- 116
	pushConsole(state, state.status) -- 117
end -- 111
local function createSpriteFromTexture(state, texture) -- 120
	addChildNode(state, "Sprite") -- 121
	local node = state.nodes[state.selectedId] -- 122
	if node ~= nil and node.kind == "Sprite" then -- 122
		bindTextureToSprite(state, node, texture) -- 124
	end -- 124
end -- 120
local function assetIcon(asset) -- 128
	if isFolderAsset(asset) then -- 128
		return "📁" -- 129
	end -- 129
	if isTextureAsset(asset) then -- 129
		return "🖼" -- 130
	end -- 130
	if isScriptAsset(asset) then -- 130
		return "◇" -- 131
	end -- 131
	local ext = lowerExt(asset) -- 132
	if ext == "wav" or ext == "mp3" or ext == "ogg" or ext == "flac" then -- 132
		return "♪" -- 133
	end -- 133
	if ext == "ttf" or ext == "otf" or ext == "fnt" then -- 133
		return "F" -- 134
	end -- 134
	if ext == "json" or ext == "xml" or ext == "yaml" or ext == "yml" then -- 134
		return "{}" -- 135
	end -- 135
	if ext == "atlas" or ext == "model" or ext == "skel" or ext == "anim" then -- 135
		return "◆" -- 136
	end -- 136
	return "·" -- 137
end -- 128
local function startsWith(text, prefix) -- 140
	return string.sub( -- 141
		text, -- 141
		1, -- 141
		string.len(prefix) -- 141
	) == prefix -- 141
end -- 140
local function drawAssetRow(state, asset) -- 144
	if isFolderAsset(asset) then -- 144
		ImGui.TreeNode( -- 146
			(assetIcon(asset) .. "  ") .. asset, -- 146
			function() -- 146
				for ____, child in ipairs(state.assets) do -- 147
					if child ~= asset and not isFolderAsset(child) and startsWith(child, asset) then -- 147
						drawAssetRow(state, child) -- 149
					end -- 149
				end -- 149
			end -- 146
		) -- 146
		return -- 153
	end -- 153
	if ImGui.Selectable( -- 153
		(assetIcon(asset) .. "  ") .. asset, -- 155
		state.selectedAsset == asset -- 155
	) then -- 155
		state.selectedAsset = asset -- 156
		local node = state.nodes[state.selectedId] -- 157
		if node ~= nil and node.kind == "Sprite" and isTextureAsset(asset) then -- 157
			bindTextureToSprite(state, node, asset) -- 159
			return -- 160
		elseif node ~= nil and isScriptAsset(asset) then -- 160
			node.script = asset -- 162
			node.scriptBuffer.text = asset -- 163
			state.status = (zh and "已绑定脚本：" or "Script assigned: ") .. asset -- 164
		else -- 164
			state.status = zh and "已选择资源；选中 Sprite 可绑定图片，选中节点可绑定脚本" or "Asset selected; select a Sprite for images, or a node for scripts" -- 166
		end -- 166
		pushConsole(state, state.status) -- 168
	end -- 168
end -- 144
local function drawAssetsPanel(state) -- 172
	ImGui.TextColored(themeColor, "FileSystem") -- 173
	ImGui.SameLine() -- 174
	if ImGui.SmallButton("＋ File") then -- 174
		importFileDialog(state) -- 175
	end -- 175
	ImGui.SameLine() -- 176
	if ImGui.SmallButton("＋ Folder") then -- 176
		importFolderDialog(state) -- 177
	end -- 177
	ImGui.Separator() -- 178
	ImGui.TextDisabled(zh and "支持 png/jpg/webp/lua/ts/json/音频/字体/模型等；文件夹会递归导入。" or "Supports images, scripts, json, audio, fonts, models; folders import recursively.") -- 179
	ImGui.Separator() -- 180
	if #state.assets == 0 then -- 180
		ImGui.TextDisabled(zh and "点击 + File 或 + Folder 导入资源。" or "Click + File or + Folder to import assets.") -- 182
		return -- 183
	end -- 183
	for ____, asset in ipairs(state.assets) do -- 185
		if isFolderAsset(asset) then -- 185
			drawAssetRow(state, asset) -- 187
		end -- 187
	end -- 187
	for ____, asset in ipairs(state.assets) do -- 190
		local insideFolder = false -- 191
		for ____, folder in ipairs(state.assets) do -- 192
			if isFolderAsset(folder) and startsWith(asset, folder) then -- 192
				insideFolder = true -- 193
			end -- 193
		end -- 193
		if not insideFolder and not isFolderAsset(asset) then -- 193
			drawAssetRow(state, asset) -- 195
		end -- 195
	end -- 195
	if state.selectedAsset ~= "" and isTextureAsset(state.selectedAsset) then -- 195
		ImGui.Separator() -- 198
		ImGui.TextColored(themeColor, "Texture Preview") -- 199
		local ok = pcall(function() return ImGui.Image( -- 200
			state.selectedAsset, -- 200
			Vec2(160, 120) -- 200
		) end) -- 200
		if not ok then -- 200
			ImGui.TextDisabled(zh and "无法预览该贴图；但仍可尝试绑定到 Sprite。" or "Unable to preview; still can bind to Sprite.") -- 201
		end -- 201
		local selectedNode = state.nodes[state.selectedId] -- 202
		if selectedNode ~= nil and selectedNode.kind == "Sprite" then -- 202
			if ImGui.Button(zh and "绑定到当前 Sprite" or "Bind To Sprite") then -- 202
				bindTextureToSprite(state, selectedNode, state.selectedAsset) -- 204
			end -- 204
			ImGui.SameLine() -- 205
		end -- 205
		if ImGui.Button(zh and "用此贴图创建 Sprite" or "Create Sprite") then -- 205
			createSpriteFromTexture(state, state.selectedAsset) -- 207
		end -- 207
	end -- 207
end -- 172
local function scriptTemplate(node) -- 211
	local name = node ~= nil and node.name or "Script" -- 212
	return ("-- " .. name) .. " behavior\nreturn function(node, scene)\n\t-- write behavior here\nend\n"
end -- 211
local function loadScriptIntoEditor(state, node, scriptPath) -- 216
	if node ~= nil then -- 216
		node.script = scriptPath -- 218
		node.scriptBuffer.text = scriptPath -- 219
		state.activeScriptNodeId = node.id -- 220
	else -- 220
		state.activeScriptNodeId = nil -- 222
	end -- 222
	state.scriptPathBuffer.text = scriptPath -- 224
	local scriptFile = Path(Content.writablePath, scriptPath) -- 225
	if Content:exist(scriptFile) then -- 225
		state.scriptContentBuffer.text = Content:load(scriptFile) or "" -- 227
	elseif Content:exist(scriptPath) then -- 227
		state.scriptContentBuffer.text = Content:load(scriptPath) or "" -- 229
	else -- 229
		state.scriptContentBuffer.text = scriptTemplate(node) -- 231
	end -- 231
	state.mode = "Script" -- 233
end -- 216
local function openScriptForNode(state, node) -- 236
	local path = node.script ~= "" and node.script or ("Script/" .. node.name) .. ".lua" -- 237
	loadScriptIntoEditor(state, node, path) -- 238
end -- 236
local function saveScriptFile(state, node) -- 241
	local path = state.scriptPathBuffer.text ~= "" and state.scriptPathBuffer.text or "Script/NewScript.lua" -- 242
	state.scriptPathBuffer.text = path -- 243
	if node ~= nil then -- 243
		node.script = path -- 245
		node.scriptBuffer.text = path -- 246
	end -- 246
	local scriptFile = Path(Content.writablePath, path) -- 248
	Content:mkdir(Path:getPath(scriptFile)) -- 249
	if Content:save(scriptFile, state.scriptContentBuffer.text) then -- 249
		state.status = (zh and "脚本已保存：" or "Script saved: ") .. path -- 251
		if state.selectedAsset ~= path then -- 251
			state.selectedAsset = path -- 252
		end -- 252
		local exists = false -- 253
		for ____, asset in ipairs(state.assets) do -- 254
			if asset == path then -- 254
				exists = true -- 254
			end -- 254
		end -- 254
		if not exists then -- 254
			local ____state_assets_1 = state.assets -- 254
			____state_assets_1[#____state_assets_1 + 1] = path -- 255
		end -- 255
	else -- 255
		state.status = zh and "脚本保存失败" or "Failed to save script" -- 257
	end -- 257
	pushConsole(state, state.status) -- 259
end -- 241
local function drawScriptAssetList(state, node) -- 262
	ImGui.TextColored(themeColor, zh and "脚本资源" or "Script Assets") -- 263
	for ____, asset in ipairs(state.assets) do -- 264
		if isScriptAsset(asset) and not isFolderAsset(asset) then -- 264
			if ImGui.Selectable("◇  " .. asset, state.selectedAsset == asset) then -- 264
				state.selectedAsset = asset -- 267
				loadScriptIntoEditor(state, node, asset) -- 268
			end -- 268
		end -- 268
	end -- 268
end -- 262
local function drawScriptPanel(state) -- 274
	local activeId = state.activeScriptNodeId or state.selectedId -- 275
	local node = state.nodes[activeId] -- 276
	ImGui.TextColored(themeColor, "Script Workspace") -- 277
	ImGui.SameLine() -- 278
	ImGui.TextDisabled(node ~= nil and node.name or (zh and "独立文件模式" or "File mode")) -- 279
	ImGui.Separator() -- 280
	ImGui.BeginChild( -- 281
		"ScriptSidebar", -- 281
		Vec2(220, 0), -- 281
		{}, -- 281
		noScrollFlags, -- 281
		function() -- 281
			drawScriptAssetList(state, node) -- 282
			ImGui.Separator() -- 283
			if ImGui.Button(zh and "新建脚本" or "New Script") then -- 283
				local scriptName = node ~= nil and node.name or "NewScript" -- 285
				local path = ("Script/" .. scriptName) .. ".lua" -- 286
				state.scriptPathBuffer.text = path -- 287
				state.scriptContentBuffer.text = scriptTemplate(node) -- 288
				if node ~= nil then -- 288
					node.script = path -- 290
					node.scriptBuffer.text = path -- 291
					state.activeScriptNodeId = node.id -- 292
				end -- 292
			end -- 292
			if ImGui.Button(zh and "导入脚本文件" or "Import Script") then -- 292
				importFileDialog(state) -- 295
			end -- 295
			if node ~= nil and ImGui.Button(zh and "绑定选中资源" or "Attach Selected") then -- 295
				if state.selectedAsset ~= "" and isScriptAsset(state.selectedAsset) then -- 295
					loadScriptIntoEditor(state, node, state.selectedAsset) -- 298
				end -- 298
			end -- 298
			if ImGui.Button(zh and "重新加载" or "Reload") then -- 298
				loadScriptIntoEditor(state, node, state.scriptPathBuffer.text) -- 302
			end -- 302
		end -- 281
	) -- 281
	ImGui.SameLine() -- 305
	ImGui.PushStyleColor( -- 306
		"ChildBg", -- 306
		scriptPanelBg, -- 306
		function() -- 306
			ImGui.BeginChild( -- 307
				"ScriptEditorPane", -- 307
				Vec2(0, 0), -- 307
				{}, -- 307
				noScrollFlags, -- 307
				function() -- 307
					ImGui.TextDisabled(zh and "脚本路径" or "Script Path") -- 308
					ImGui.InputText("##ScriptPath", state.scriptPathBuffer, inputTextFlags) -- 309
					ImGui.SameLine() -- 310
					if ImGui.Button(zh and "保存" or "Save") then -- 310
						saveScriptFile(state, node) -- 311
					end -- 311
					if node ~= nil then -- 311
						ImGui.SameLine() -- 313
						if ImGui.Button(zh and "绑定到节点" or "Attach Node") then -- 313
							node.script = state.scriptPathBuffer.text -- 315
							node.scriptBuffer.text = node.script -- 316
							state.status = (zh and "脚本已绑定到节点：" or "Script attached to node: ") .. node.name -- 317
							pushConsole(state, state.status) -- 318
						end -- 318
					end -- 318
					ImGui.Separator() -- 321
					ImGui.InputTextMultiline( -- 322
						"##ScriptEditor", -- 322
						state.scriptContentBuffer, -- 322
						Vec2(0, -4), -- 322
						{} -- 322
					) -- 322
				end -- 307
			) -- 307
		end -- 306
	) -- 306
end -- 274
local function viewportScale(state) -- 327
	return math.max(0.25, state.zoom / 100) -- 328
end -- 327
local function screenToScene(state, screenX, screenY) -- 331
	local p = state.preview -- 332
	local scale = viewportScale(state) -- 333
	local localX = screenX - (p.x + p.width / 2) - state.viewportPanX -- 334
	local localY = p.y + p.height / 2 - screenY - state.viewportPanY -- 335
	return {localX / scale, localY / scale} -- 336
end -- 331
local function pickNodeAt(state, screenX, screenY) -- 339
	local sceneX, sceneY = table.unpack( -- 340
		screenToScene(state, screenX, screenY), -- 340
		1, -- 340
		2 -- 340
	) -- 340
	do -- 340
		local i = #state.order -- 341
		while i >= 1 do -- 341
			local id = state.order[i] -- 342
			local node = state.nodes[id] -- 343
			if node ~= nil and id ~= "root" and node.visible then -- 343
				local dx = sceneX - node.x -- 345
				local dy = sceneY - node.y -- 346
				local radius = node.kind == "Camera" and 185 or (node.kind == "Sprite" and 82 or 54) -- 347
				if dx * dx + dy * dy <= radius * radius then -- 347
					return id -- 348
				end -- 348
			end -- 348
			i = i - 1 -- 341
		end -- 341
	end -- 341
	return nil -- 351
end -- 339
local function handleViewportMouse(state, hovered) -- 354
	if not hovered then -- 354
		return -- 355
	end -- 355
	local spacePressed = Keyboard:isKeyPressed("Space") -- 356
	if ImGui.IsMouseClicked(2) then -- 356
		state.draggingNodeId = nil -- 358
		state.draggingViewport = true -- 359
		ImGui.ResetMouseDragDelta(2) -- 360
	end -- 360
	if ImGui.IsMouseClicked(0) then -- 360
		if spacePressed then -- 360
			state.draggingNodeId = nil -- 364
			state.draggingViewport = true -- 365
		else -- 365
			local mouse = ImGui.GetMousePos() -- 367
			local picked = pickNodeAt(state, mouse.x, mouse.y) -- 368
			if picked ~= nil then -- 368
				state.selectedId = picked -- 370
				state.previewDirty = true -- 371
				state.draggingNodeId = picked -- 372
				state.draggingViewport = false -- 373
			else -- 373
				state.draggingNodeId = nil -- 375
				state.draggingViewport = true -- 376
			end -- 376
		end -- 376
		ImGui.ResetMouseDragDelta(0) -- 379
	end -- 379
	if ImGui.IsMouseReleased(0) or ImGui.IsMouseReleased(2) then -- 379
		state.draggingNodeId = nil -- 382
		state.draggingViewport = false -- 383
	end -- 383
	if ImGui.IsMouseDragging(0) or ImGui.IsMouseDragging(2) then -- 383
		local panButton = ImGui.IsMouseDragging(2) and 2 or 0 -- 386
		local delta = ImGui.GetMouseDragDelta(panButton) -- 387
		if delta.x ~= 0 or delta.y ~= 0 then -- 387
			if state.draggingNodeId ~= nil and panButton == 0 then -- 387
				local node = state.nodes[state.draggingNodeId] -- 390
				if node ~= nil then -- 390
					local scale = viewportScale(state) -- 392
					node.x = node.x + delta.x / scale -- 393
					node.y = node.y - delta.y / scale -- 394
					if state.snapEnabled then -- 394
						local step = 16 -- 396
						node.x = math.floor(node.x / step + 0.5) * step -- 397
						node.y = math.floor(node.y / step + 0.5) * step -- 398
					end -- 398
				end -- 398
			elseif state.draggingViewport then -- 398
				state.viewportPanX = state.viewportPanX + delta.x -- 402
				state.viewportPanY = state.viewportPanY - delta.y -- 403
			end -- 403
			ImGui.ResetMouseDragDelta(panButton) -- 405
		end -- 405
	end -- 405
end -- 354
local function drawViewportToolButton(state, tool, label) -- 410
	local active = state.viewportTool == tool -- 411
	if active then -- 411
		ImGui.PushStyleColor( -- 413
			"Button", -- 413
			Color(4281349698), -- 413
			function() -- 413
				ImGui.PushStyleColor( -- 414
					"Text", -- 414
					themeColor, -- 414
					function() -- 414
						if ImGui.Button(label) then -- 414
							state.viewportTool = tool -- 415
						end -- 415
					end -- 414
				) -- 414
			end -- 413
		) -- 413
	elseif ImGui.Button(label) then -- 413
		state.viewportTool = tool -- 419
	end -- 419
end -- 410
local function drawViewport(state) -- 423
	ImGui.TextColored(themeColor, "2D") -- 424
	ImGui.SameLine() -- 425
	drawViewportToolButton(state, "Select", "Select") -- 426
	ImGui.SameLine() -- 427
	drawViewportToolButton(state, "Move", "Move") -- 428
	ImGui.SameLine() -- 429
	drawViewportToolButton(state, "Rotate", "Rotate") -- 430
	ImGui.SameLine() -- 431
	drawViewportToolButton(state, "Scale", "Scale") -- 432
	ImGui.SameLine() -- 433
	ImGui.TextDisabled("|") -- 434
	ImGui.SameLine() -- 435
	local snapChanged, snap = ImGui.Checkbox("Snap", state.snapEnabled) -- 436
	if snapChanged then -- 436
		state.snapEnabled = snap -- 437
	end -- 437
	ImGui.SameLine() -- 438
	local gridChanged, grid = ImGui.Checkbox("Grid", state.showGrid) -- 439
	if gridChanged then -- 439
		state.showGrid = grid -- 440
		state.previewDirty = true -- 440
	end -- 440
	ImGui.SameLine() -- 441
	if ImGui.Button("Center") then -- 441
		state.viewportPanX = 0 -- 443
		state.viewportPanY = 0 -- 444
		state.zoom = 100 -- 445
		state.previewDirty = true -- 446
	end -- 446
	ImGui.SameLine() -- 448
	ImGui.TextDisabled("Main.scene") -- 449
	ImGui.Separator() -- 450
	local cursor = ImGui.GetCursorScreenPos() -- 451
	local avail = ImGui.GetContentRegionAvail() -- 452
	local viewportWidth = math.max(360, avail.x - 8) -- 453
	local viewportHeight = math.max(300, avail.y - 38) -- 454
	if math.abs(state.preview.width - viewportWidth) > 1 or math.abs(state.preview.height - viewportHeight) > 1 then -- 454
		state.previewDirty = true -- 456
	end -- 456
	state.preview.x = cursor.x -- 458
	state.preview.y = cursor.y -- 459
	state.preview.width = viewportWidth -- 460
	state.preview.height = viewportHeight -- 461
	updatePreviewRuntime(state) -- 462
	ImGui.Dummy(Vec2(viewportWidth, viewportHeight)) -- 463
	local hovered = ImGui.IsItemHovered() -- 464
	handleViewportMouse(state, hovered) -- 465
	ImGui.SetCursorScreenPos(Vec2(cursor.x + viewportWidth - 92, cursor.y + 8)) -- 466
	ImGui.PushStyleColor( -- 467
		"Text", -- 467
		themeColor, -- 467
		function() -- 467
			ImGui.Text(tostring(math.floor(state.zoom)) .. "%") -- 468
		end -- 467
	) -- 467
	ImGui.SetCursorScreenPos(Vec2(cursor.x, cursor.y + viewportHeight + 4)) -- 470
	ImGui.Separator() -- 471
	ImGui.TextColored(okColor, "Dora 2D Viewport") -- 472
	ImGui.SameLine() -- 473
	ImGui.TextDisabled(zh and "滚轮缩放；中键/Space+拖动平移；触控板双指滚动等价滚轮。" or "Wheel zoom; MMB or Space+drag pans; trackpad two-finger scroll is wheel.") -- 474
end -- 423
local function drawInspector(state) -- 477
	ImGui.TextColored(themeColor, "Inspector") -- 478
	ImGui.Separator() -- 479
	local node = state.nodes[state.selectedId] -- 480
	if node == nil then -- 480
		ImGui.TextDisabled(zh and "没有选中节点" or "No node selected") -- 482
		return -- 483
	end -- 483
	ImGui.Text((iconFor(node.kind) .. "  ") .. node.kind) -- 485
	if ImGui.InputText("Name", node.nameBuffer, inputTextFlags) then -- 485
		node.name = node.nameBuffer.text -- 486
	end -- 486
	local changed, x, y = ImGui.DragFloat2( -- 487
		"Position", -- 487
		node.x, -- 487
		node.y, -- 487
		1, -- 487
		-10000, -- 487
		10000, -- 487
		"%.1f" -- 487
	) -- 487
	if changed then -- 487
		node.x = x -- 488
		node.y = y -- 488
	end -- 488
	changed, x, y = ImGui.DragFloat2( -- 489
		"Scale", -- 489
		node.scaleX, -- 489
		node.scaleY, -- 489
		0.01, -- 489
		-100, -- 489
		100, -- 489
		"%.2f" -- 489
	) -- 489
	if changed then -- 489
		node.scaleX = x -- 490
		node.scaleY = y -- 490
	end -- 490
	local angleChanged, angle = ImGui.DragFloat( -- 491
		"Rotation", -- 491
		node.rotation, -- 491
		1, -- 491
		-360, -- 491
		360, -- 491
		"%.1f" -- 491
	) -- 491
	if angleChanged then -- 491
		node.rotation = angle -- 492
	end -- 492
	local visibleChanged, visible = ImGui.Checkbox("Visible", node.visible) -- 493
	if visibleChanged then -- 493
		node.visible = visible -- 494
	end -- 494
	ImGui.Separator() -- 495
	if ImGui.InputText("Script", node.scriptBuffer, inputTextFlags) then -- 495
		node.script = node.scriptBuffer.text -- 496
	end -- 496
	if ImGui.Button(zh and "打开脚本" or "Open Script") then -- 496
		openScriptForNode(state, node) -- 497
	end -- 497
	if node.kind == "Sprite" then -- 497
		ImGui.Separator() -- 499
		if ImGui.InputText("Texture", node.textureBuffer, inputTextFlags) then -- 499
			node.texture = node.textureBuffer.text -- 501
			state.previewDirty = true -- 502
		end -- 502
		if ImGui.Button(zh and "导入并绑定贴图" or "Import Texture") then -- 502
			App:openFileDialog( -- 505
				false, -- 505
				function(____, path) -- 505
					local asset = addAssetPath(state, path) -- 506
					if asset ~= nil and isTextureAsset(asset) then -- 506
						bindTextureToSprite(state, node, asset) -- 507
					end -- 507
				end -- 505
			) -- 505
		end -- 505
		ImGui.SameLine() -- 510
		if ImGui.Button(zh and "绑定选中贴图" or "Use Selected") then -- 510
			if state.selectedAsset ~= "" and isTextureAsset(state.selectedAsset) then -- 510
				bindTextureToSprite(state, node, state.selectedAsset) -- 512
			end -- 512
		end -- 512
	elseif node.kind == "Label" then -- 512
		ImGui.Separator() -- 515
		if ImGui.InputText("Text", node.textBuffer, inputTextFlags) then -- 515
			node.text = node.textBuffer.text -- 516
		end -- 516
	elseif node.kind == "Camera" then -- 516
		ImGui.Separator() -- 518
		ImGui.TextDisabled(zh and "Camera 显示真实取景框。" or "Camera shows a real frame in viewport.") -- 519
	end -- 519
end -- 477
local function drawConsole(state) -- 523
	ImGui.TextColored(themeColor, "Console") -- 524
	ImGui.SameLine() -- 525
	ImGui.TextColored(okColor, state.status) -- 526
	ImGui.Separator() -- 527
	for ____, line in ipairs(state.console) do -- 528
		ImGui.TextDisabled(line) -- 528
	end -- 528
end -- 523
local function drawVerticalSplitter(id, height, onDrag) -- 531
	ImGui.PushStyleColor( -- 532
		"Button", -- 532
		Color(4281612868), -- 532
		function() -- 532
			ImGui.PushStyleColor( -- 533
				"ButtonHovered", -- 533
				Color(4283259240), -- 533
				function() -- 533
					ImGui.PushStyleColor( -- 534
						"ButtonActive", -- 534
						Color(4294954035), -- 534
						function() -- 534
							ImGui.Button( -- 535
								"##" .. id, -- 535
								Vec2(12, height) -- 535
							) -- 535
						end -- 534
					) -- 534
				end -- 533
			) -- 533
		end -- 532
	) -- 532
	if ImGui.IsItemHovered() then -- 532
		ImGui.BeginTooltip(function() return ImGui.Text(zh and "拖动调整面板宽度" or "Drag to resize panel") end) -- 540
	end -- 540
	if ImGui.IsItemActive() and ImGui.IsMouseDragging(0) then -- 540
		local delta = ImGui.GetMouseDragDelta(0) -- 543
		if delta.x ~= 0 then -- 543
			onDrag(delta.x) -- 545
			ImGui.ResetMouseDragDelta(0) -- 546
		end -- 546
	end -- 546
end -- 531
function ____exports.drawEditor(state) -- 551
	local size = App.visualSize -- 552
	local margin = 10 -- 553
	local windowWidth = math.max(900, size.width - margin * 2) -- 554
	local windowHeight = math.max(620, size.height - margin * 2) -- 555
	ImGui.SetNextWindowPos( -- 556
		Vec2(margin, margin), -- 556
		"Always" -- 556
	) -- 556
	ImGui.SetNextWindowSize( -- 557
		Vec2(windowWidth, windowHeight), -- 557
		"Always" -- 557
	) -- 557
	ImGui.SetNextWindowBgAlpha(state.mode == "Script" and 0.96 or 0.1) -- 558
	ImGui.Begin( -- 559
		"Dora Visual Editor", -- 559
		mainWindowFlags, -- 559
		function() -- 559
			drawHeader(state) -- 560
			local avail = ImGui.GetContentRegionAvail() -- 561
			local bottomHeight = state.bottomHeight -- 562
			if state.mode == "Script" then -- 562
				local scriptHeight = math.max(360, avail.y - bottomHeight - 8) -- 564
				ImGui.PushStyleColor( -- 565
					"ChildBg", -- 565
					panelBg, -- 565
					function() -- 565
						ImGui.BeginChild( -- 566
							"ScriptWorkspaceRoot", -- 566
							Vec2(0, scriptHeight), -- 566
							{}, -- 566
							noScrollFlags, -- 566
							function() return drawScriptPanel(state) end -- 566
						) -- 566
					end -- 565
				) -- 565
				ImGui.BeginChild( -- 568
					"ScriptConsoleDock", -- 568
					Vec2(0, bottomHeight), -- 568
					{}, -- 568
					noScrollFlags, -- 568
					function() return drawConsole(state) end -- 568
				) -- 568
				return -- 569
			end -- 569
			local mainHeight = math.max(320, avail.y - bottomHeight - 10) -- 571
			local availableWidth = math.max(720, avail.x - 4) -- 572
			state.leftWidth = math.max( -- 573
				190, -- 573
				math.min(state.leftWidth, availableWidth - state.rightWidth - 420) -- 573
			) -- 573
			state.rightWidth = math.max( -- 574
				250, -- 574
				math.min(state.rightWidth, availableWidth - state.leftWidth - 420) -- 574
			) -- 574
			local centerWidth = math.max(360, availableWidth - state.leftWidth - state.rightWidth - 24) -- 575
			local leftTopHeight = math.floor(mainHeight * 0.58) -- 576
			local leftBottomHeight = mainHeight - leftTopHeight - 8 -- 577
			ImGui.BeginChild( -- 579
				"LeftDock", -- 579
				Vec2(state.leftWidth, mainHeight), -- 579
				{}, -- 579
				noScrollFlags, -- 579
				function() -- 579
					ImGui.BeginChild( -- 580
						"SceneDock", -- 580
						Vec2(0, leftTopHeight), -- 580
						{}, -- 580
						noScrollFlags, -- 580
						function() return drawScenePanel(state) end -- 580
					) -- 580
					ImGui.BeginChild( -- 581
						"AssetDock", -- 581
						Vec2(0, leftBottomHeight), -- 581
						{}, -- 581
						noScrollFlags, -- 581
						function() return drawAssetsPanel(state) end -- 581
					) -- 581
				end -- 579
			) -- 579
			ImGui.SameLine() -- 583
			drawVerticalSplitter( -- 584
				"LeftSplitter", -- 584
				mainHeight, -- 584
				function(deltaX) -- 584
					state.leftWidth = math.max( -- 585
						190, -- 585
						math.min(state.leftWidth + deltaX, availableWidth - state.rightWidth - 420) -- 585
					) -- 585
				end -- 584
			) -- 584
			ImGui.SameLine() -- 587
			ImGui.PushStyleColor( -- 588
				"ChildBg", -- 588
				transparent, -- 588
				function() -- 588
					ImGui.BeginChild( -- 589
						"CenterDock", -- 589
						Vec2(centerWidth, mainHeight), -- 589
						{}, -- 589
						noScrollFlags, -- 589
						function() -- 589
							if state.mode == "Script" then -- 589
								drawScriptPanel(state) -- 590
							else -- 590
								drawViewport(state) -- 590
							end -- 590
						end -- 589
					) -- 589
				end -- 588
			) -- 588
			ImGui.SameLine() -- 593
			drawVerticalSplitter( -- 594
				"RightSplitter", -- 594
				mainHeight, -- 594
				function(deltaX) -- 594
					state.rightWidth = math.max( -- 595
						250, -- 595
						math.min(state.rightWidth - deltaX, availableWidth - state.leftWidth - 420) -- 595
					) -- 595
				end -- 594
			) -- 594
			ImGui.SameLine() -- 597
			ImGui.BeginChild( -- 598
				"RightDock", -- 598
				Vec2(state.rightWidth, mainHeight), -- 598
				{}, -- 598
				noScrollFlags, -- 598
				function() return drawInspector(state) end -- 598
			) -- 598
			ImGui.BeginChild( -- 599
				"BottomConsoleDock", -- 599
				Vec2(0, bottomHeight), -- 599
				{}, -- 599
				noScrollFlags, -- 599
				function() return drawConsole(state) end -- 599
			) -- 599
		end -- 559
	) -- 559
end -- 551
function ____exports.drawRuntimeError(message) -- 603
	local size = App.visualSize -- 604
	ImGui.SetNextWindowPos( -- 605
		Vec2(10, 10), -- 605
		"Always" -- 605
	) -- 605
	ImGui.SetNextWindowSize( -- 606
		Vec2( -- 606
			math.max(320, size.width - 20), -- 606
			math.max(220, size.height - 20) -- 606
		), -- 606
		"Always" -- 606
	) -- 606
	ImGui.Begin( -- 607
		"Dora Visual Editor Error", -- 607
		mainWindowFlags, -- 607
		function() -- 607
			ImGui.TextColored(warnColor, "SceneImGuiEditor runtime error") -- 608
			ImGui.Separator() -- 609
			ImGui.TextWrapped(message or "unknown error") -- 610
		end -- 607
	) -- 607
end -- 603
return ____exports -- 603