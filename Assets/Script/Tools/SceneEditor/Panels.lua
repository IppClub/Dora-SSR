-- [ts]: Panels.ts
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local App = ____Dora.App -- 1
local Color = ____Dora.Color -- 1
local Content = ____Dora.Content -- 1
local Path = ____Dora.Path -- 1
local Vec2 = ____Dora.Vec2 -- 1
local json = ____Dora.json -- 1
local ImGui = require("ImGui") -- 2
local ____Theme = require("Script.Tools.SceneEditor.Theme") -- 5
local inputTextFlags = ____Theme.inputTextFlags -- 5
local mainWindowFlags = ____Theme.mainWindowFlags -- 5
local noScrollFlags = ____Theme.noScrollFlags -- 5
local okColor = ____Theme.okColor -- 5
local themeColor = ____Theme.themeColor -- 5
local transparent = ____Theme.transparent -- 5
local warnColor = ____Theme.warnColor -- 5
local ____Model = require("Script.Tools.SceneEditor.Model") -- 6
local addChildNode = ____Model.addChildNode -- 6
local deleteNode = ____Model.deleteNode -- 6
local iconFor = ____Model.iconFor -- 6
local importFileDialog = ____Model.importFileDialog -- 6
local importFolderDialog = ____Model.importFolderDialog -- 6
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
	end -- 19
	for ____, childId in ipairs(node.children) do -- 21
		drawNodeRow(state, childId, depth + 1) -- 22
	end -- 22
end -- 13
local function drawAddNodePopup(state) -- 26
	ImGui.BeginPopup( -- 27
		"AddNodePopup", -- 27
		function() -- 27
			ImGui.TextColored(themeColor, zh and "添加节点" or "Add Node") -- 28
			ImGui.Separator() -- 29
			if ImGui.Selectable("○  Node", false) then -- 29
				addChildNode(state, "Node") -- 30
				ImGui.CloseCurrentPopup() -- 30
			end -- 30
			if ImGui.Selectable("▣  Sprite", false) then -- 30
				addChildNode(state, "Sprite") -- 31
				ImGui.CloseCurrentPopup() -- 31
			end -- 31
			if ImGui.Selectable("T  Label", false) then -- 31
				addChildNode(state, "Label") -- 32
				ImGui.CloseCurrentPopup() -- 32
			end -- 32
			if ImGui.Selectable("◉  Camera", false) then -- 32
				addChildNode(state, "Camera") -- 33
				ImGui.CloseCurrentPopup() -- 33
			end -- 33
		end -- 27
	) -- 27
end -- 26
local function saveScene(state) -- 37
	Content:mkdir(Path(Content.writablePath, ".dora")) -- 38
	local data = {version = 1, nodes = {}} -- 39
	for ____, id in ipairs(state.order) do -- 40
		local node = state.nodes[id] -- 41
		if node ~= nil then -- 41
			local ____data_nodes_0 = data.nodes -- 41
			____data_nodes_0[#____data_nodes_0 + 1] = { -- 43
				id = node.id, -- 44
				kind = node.kind, -- 45
				name = node.name, -- 46
				parentId = node.parentId, -- 47
				x = node.x, -- 48
				y = node.y, -- 49
				scaleX = node.scaleX, -- 50
				scaleY = node.scaleY, -- 51
				rotation = node.rotation, -- 52
				visible = node.visible, -- 53
				texture = node.texture, -- 54
				text = node.text, -- 55
				script = node.script -- 56
			} -- 56
		end -- 56
	end -- 56
	local text = json.encode(data) -- 60
	if text ~= nil and Content:save(sceneSaveFile, text) then -- 60
		state.status = (zh and "已保存：" or "Saved: ") .. sceneSaveFile -- 62
	else -- 62
		state.status = zh and "保存失败" or "Save failed" -- 64
	end -- 64
	pushConsole(state, state.status) -- 66
end -- 37
local function drawHeader(state) -- 69
	ImGui.TextColored(themeColor, "✦ Dora Visual Editor") -- 70
	ImGui.SameLine() -- 71
	if ImGui.Button("2D") then -- 71
		state.mode = "2D" -- 72
	end -- 72
	ImGui.SameLine() -- 73
	if ImGui.Button("Script") then -- 73
		state.mode = "Script" -- 74
	end -- 74
	ImGui.SameLine() -- 75
	ImGui.TextDisabled(zh and "Native ImGui / Godot-like" or "Native ImGui / Godot-like") -- 76
	ImGui.Separator() -- 77
	if ImGui.Button("▶ Run") then -- 77
		state.status = zh and "Run 会在下一步接入场景运行" or "Run will be wired in the next step" -- 79
		pushConsole(state, state.status) -- 80
	end -- 80
	ImGui.SameLine() -- 82
	if ImGui.Button("▣ Save") then -- 82
		saveScene(state) -- 83
	end -- 83
	ImGui.SameLine() -- 84
	if ImGui.Button("◇ Build") then -- 84
		state.status = zh and "Build 会在代码生成稳定后接入" or "Build will be wired after codegen is stable" -- 86
		pushConsole(state, state.status) -- 87
	end -- 87
	ImGui.SameLine() -- 89
	ImGui.TextDisabled("|") -- 90
	ImGui.SameLine() -- 91
	if ImGui.Button("＋ Add") then -- 91
		ImGui.OpenPopup("AddNodePopup") -- 92
	end -- 92
	drawAddNodePopup(state) -- 93
	ImGui.SameLine() -- 94
	if ImGui.Button("Delete") then -- 94
		deleteNode(state, state.selectedId) -- 95
	end -- 95
	ImGui.Separator() -- 96
end -- 69
local function drawScenePanel(state) -- 99
	ImGui.TextColored(themeColor, "Scene Tree") -- 100
	ImGui.SameLine() -- 101
	if ImGui.SmallButton("＋##scene_add") then -- 101
		ImGui.OpenPopup("AddNodePopup") -- 102
	end -- 102
	drawAddNodePopup(state) -- 103
	ImGui.Separator() -- 104
	drawNodeRow(state, "root", 0) -- 105
	ImGui.Separator() -- 106
	ImGui.TextDisabled(zh and "＋ 添加到当前选中节点下" or "+ adds under selected node") -- 107
end -- 99
local function drawAssetRow(state, asset) -- 110
	if ImGui.Selectable("  " .. asset, state.selectedAsset == asset) then -- 110
		state.selectedAsset = asset -- 112
		local node = state.nodes[state.selectedId] -- 113
		if node ~= nil and node.kind == "Sprite" and isTextureAsset(asset) then -- 113
			node.texture = asset -- 115
			node.textureBuffer.text = asset -- 116
			state.previewDirty = true -- 117
			state.status = (zh and "已绑定贴图：" or "Texture assigned: ") .. asset -- 118
		elseif node ~= nil and isScriptAsset(asset) then -- 118
			node.script = asset -- 120
			node.scriptBuffer.text = asset -- 121
			state.status = (zh and "已绑定脚本：" or "Script assigned: ") .. asset -- 122
		else -- 122
			state.status = zh and "选择 Sprite 可绑定图片，选择节点可绑定 Lua 脚本" or "Select a Sprite for images, or a node for Lua scripts" -- 124
		end -- 124
		pushConsole(state, state.status) -- 126
	end -- 126
end -- 110
local function drawAssetsPanel(state) -- 130
	ImGui.TextColored(themeColor, "FileSystem") -- 131
	ImGui.SameLine() -- 132
	if ImGui.SmallButton("＋ File") then -- 132
		importFileDialog(state) -- 133
	end -- 133
	ImGui.SameLine() -- 134
	if ImGui.SmallButton("＋ Folder") then -- 134
		importFolderDialog(state) -- 135
	end -- 135
	ImGui.Separator() -- 136
	ImGui.TextDisabled(zh and "拖拽导入需要原生 FileDrop 绑定；当前先用系统文件选择器。" or "OS drag-drop needs a native FileDrop binding; use the file picker for now.") -- 137
	ImGui.Separator() -- 138
	local groups = { -- 139
		{title = "Textures", filter = isTextureAsset}, -- 140
		{title = "Scripts", filter = isScriptAsset}, -- 141
		{ -- 142
			title = "Audio", -- 142
			filter = function(path) -- 142
				local ext = lowerExt(path) -- 142
				return ext == "wav" or ext == "mp3" or ext == "ogg" -- 142
			end -- 142
		}, -- 142
		{ -- 143
			title = "Animations", -- 143
			filter = function(path) -- 143
				local ext = lowerExt(path) -- 143
				return ext == "anim" or ext == "model" or ext == "skel" -- 143
			end -- 143
		} -- 143
	} -- 143
	for ____, group in ipairs(groups) do -- 145
		ImGui.TreeNode( -- 146
			group.title, -- 146
			function() -- 146
				for ____, asset in ipairs(state.assets) do -- 147
					if group.filter(asset) then -- 147
						drawAssetRow(state, asset) -- 148
					end -- 148
				end -- 148
			end -- 146
		) -- 146
	end -- 146
	if state.selectedAsset ~= "" and isTextureAsset(state.selectedAsset) then -- 146
		ImGui.Separator() -- 153
		ImGui.TextColored(themeColor, "Texture Preview") -- 154
		local ok = pcall(function() return ImGui.Image( -- 155
			state.selectedAsset, -- 155
			Vec2(160, 120) -- 155
		) end) -- 155
		if not ok then -- 155
			ImGui.TextDisabled(zh and "无法预览该贴图" or "Unable to preview this texture") -- 156
		end -- 156
	end -- 156
end -- 130
local function openScriptForNode(state, node) -- 160
	if node.script == "" then -- 160
		node.script = ("Script/" .. node.name) .. ".lua" -- 162
		node.scriptBuffer.text = node.script -- 163
	end -- 163
	state.activeScriptNodeId = node.id -- 165
	state.scriptPathBuffer.text = node.script -- 166
	local scriptFile = Path(Content.writablePath, node.script) -- 167
	if Content:exist(scriptFile) then -- 167
		state.scriptContentBuffer.text = Content:load(scriptFile) or "" -- 169
	else -- 169
		state.scriptContentBuffer.text = ("-- " .. node.name) .. " behavior\nreturn function(node, scene)\n\t-- write behavior here\nend\n"
	end -- 171
	state.mode = "Script" -- 173
end -- 160
local function drawScriptPanel(state) -- 176
	local activeId = state.activeScriptNodeId or state.selectedId -- 177
	local node = state.nodes[activeId] -- 178
	ImGui.TextColored(themeColor, "Script") -- 179
	ImGui.SameLine() -- 180
	ImGui.TextDisabled(node ~= nil and node.name or "No Node") -- 181
	ImGui.Separator() -- 182
	if node == nil then -- 182
		ImGui.TextDisabled(zh and "先选择一个节点" or "Select a node first") -- 184
		return -- 185
	end -- 185
	ImGui.InputText("Path", state.scriptPathBuffer, inputTextFlags) -- 187
	ImGui.SameLine() -- 188
	if ImGui.Button(zh and "保存脚本" or "Save Script") then -- 188
		node.script = state.scriptPathBuffer.text -- 190
		node.scriptBuffer.text = node.script -- 191
		local scriptFile = Path(Content.writablePath, node.script) -- 192
		Content:mkdir(Path:getPath(scriptFile)) -- 193
		if Content:save(scriptFile, state.scriptContentBuffer.text) then -- 193
			state.status = (zh and "脚本已保存：" or "Script saved: ") .. node.script -- 195
		else -- 195
			state.status = zh and "脚本保存失败" or "Failed to save script" -- 197
		end -- 197
		pushConsole(state, state.status) -- 199
	end -- 199
	ImGui.InputTextMultiline( -- 201
		"##ScriptEditor", -- 201
		state.scriptContentBuffer, -- 201
		Vec2(0, -4), -- 201
		{} -- 201
	) -- 201
end -- 176
local function drawViewport(state) -- 204
	ImGui.TextColored(themeColor, "Viewport") -- 205
	ImGui.SameLine() -- 206
	ImGui.TextDisabled("Main.scene") -- 207
	ImGui.SameLine() -- 208
	local gridChanged, grid = ImGui.Checkbox("Grid", state.showGrid) -- 209
	if gridChanged then -- 209
		state.showGrid = grid -- 210
		state.previewDirty = true -- 210
	end -- 210
	ImGui.SameLine() -- 211
	local zoomChanged, zoom = ImGui.DragFloat( -- 212
		"Zoom", -- 212
		state.zoom, -- 212
		1, -- 212
		25, -- 212
		400, -- 212
		"%.0f%%" -- 212
	) -- 212
	if zoomChanged then -- 212
		state.zoom = zoom -- 213
	end -- 213
	ImGui.Separator() -- 214
	local cursor = ImGui.GetCursorScreenPos() -- 215
	local avail = ImGui.GetContentRegionAvail() -- 216
	local viewportWidth = math.max(360, avail.x - 8) -- 217
	local viewportHeight = math.max(300, avail.y - 38) -- 218
	if math.abs(state.preview.width - viewportWidth) > 1 or math.abs(state.preview.height - viewportHeight) > 1 then -- 218
		state.previewDirty = true -- 220
	end -- 220
	state.preview.x = cursor.x -- 222
	state.preview.y = cursor.y -- 223
	state.preview.width = viewportWidth -- 224
	state.preview.height = viewportHeight -- 225
	updatePreviewRuntime(state) -- 226
	ImGui.Dummy(Vec2(viewportWidth, viewportHeight)) -- 227
	ImGui.Separator() -- 228
	ImGui.TextColored(okColor, zh and "真实 Dora Viewport" or "Real Dora Viewport") -- 229
	ImGui.SameLine() -- 230
	ImGui.TextDisabled(zh and "红=X 绿=Y，拖动左右分割条可放大" or "Red=X Green=Y, drag splitters to resize") -- 231
end -- 204
local function drawInspector(state) -- 234
	ImGui.TextColored(themeColor, "Inspector") -- 235
	ImGui.Separator() -- 236
	local node = state.nodes[state.selectedId] -- 237
	if node == nil then -- 237
		ImGui.TextDisabled(zh and "没有选中节点" or "No node selected") -- 239
		return -- 240
	end -- 240
	ImGui.Text((iconFor(node.kind) .. "  ") .. node.kind) -- 242
	if ImGui.InputText("Name", node.nameBuffer, inputTextFlags) then -- 242
		node.name = node.nameBuffer.text -- 243
	end -- 243
	local changed, x, y = ImGui.DragFloat2( -- 244
		"Position", -- 244
		node.x, -- 244
		node.y, -- 244
		1, -- 244
		-10000, -- 244
		10000, -- 244
		"%.1f" -- 244
	) -- 244
	if changed then -- 244
		node.x = x -- 245
		node.y = y -- 245
	end -- 245
	changed, x, y = ImGui.DragFloat2( -- 246
		"Scale", -- 246
		node.scaleX, -- 246
		node.scaleY, -- 246
		0.01, -- 246
		-100, -- 246
		100, -- 246
		"%.2f" -- 246
	) -- 246
	if changed then -- 246
		node.scaleX = x -- 247
		node.scaleY = y -- 247
	end -- 247
	local angleChanged, angle = ImGui.DragFloat( -- 248
		"Rotation", -- 248
		node.rotation, -- 248
		1, -- 248
		-360, -- 248
		360, -- 248
		"%.1f" -- 248
	) -- 248
	if angleChanged then -- 248
		node.rotation = angle -- 249
	end -- 249
	local visibleChanged, visible = ImGui.Checkbox("Visible", node.visible) -- 250
	if visibleChanged then -- 250
		node.visible = visible -- 251
	end -- 251
	ImGui.Separator() -- 252
	if ImGui.InputText("Script", node.scriptBuffer, inputTextFlags) then -- 252
		node.script = node.scriptBuffer.text -- 253
	end -- 253
	if ImGui.Button(zh and "打开脚本" or "Open Script") then -- 253
		openScriptForNode(state, node) -- 254
	end -- 254
	if node.kind == "Sprite" then -- 254
		ImGui.Separator() -- 256
		if ImGui.InputText("Texture", node.textureBuffer, inputTextFlags) then -- 256
			node.texture = node.textureBuffer.text -- 258
			state.previewDirty = true -- 259
		end -- 259
	elseif node.kind == "Label" then -- 259
		ImGui.Separator() -- 262
		if ImGui.InputText("Text", node.textBuffer, inputTextFlags) then -- 262
			node.text = node.textBuffer.text -- 263
		end -- 263
	elseif node.kind == "Camera" then -- 263
		ImGui.Separator() -- 265
		ImGui.TextDisabled(zh and "Camera 显示真实取景框。" or "Camera shows a real frame in viewport.") -- 266
	end -- 266
end -- 234
local function drawConsole(state) -- 270
	ImGui.TextColored(themeColor, "Console") -- 271
	ImGui.SameLine() -- 272
	ImGui.TextColored(okColor, state.status) -- 273
	ImGui.Separator() -- 274
	for ____, line in ipairs(state.console) do -- 275
		ImGui.TextDisabled(line) -- 275
	end -- 275
end -- 270
local function drawVerticalSplitter(id, height, onDrag) -- 278
	ImGui.PushStyleColor( -- 279
		"Button", -- 279
		Color(4281612868), -- 279
		function() -- 279
			ImGui.PushStyleColor( -- 280
				"ButtonHovered", -- 280
				Color(4283259240), -- 280
				function() -- 280
					ImGui.PushStyleColor( -- 281
						"ButtonActive", -- 281
						Color(4294954035), -- 281
						function() -- 281
							ImGui.Button( -- 282
								"##" .. id, -- 282
								Vec2(12, height) -- 282
							) -- 282
						end -- 281
					) -- 281
				end -- 280
			) -- 280
		end -- 279
	) -- 279
	if ImGui.IsItemHovered() then -- 279
		ImGui.BeginTooltip(function() return ImGui.Text(zh and "拖动调整面板宽度" or "Drag to resize panel") end) -- 287
	end -- 287
	if ImGui.IsItemActive() and ImGui.IsMouseDragging(0) then -- 287
		local delta = ImGui.GetMouseDragDelta(0) -- 290
		if delta.x ~= 0 then -- 290
			onDrag(delta.x) -- 292
			ImGui.ResetMouseDragDelta(0) -- 293
		end -- 293
	end -- 293
end -- 278
function ____exports.drawEditor(state) -- 298
	local size = App.visualSize -- 299
	local margin = 10 -- 300
	local windowWidth = math.max(900, size.width - margin * 2) -- 301
	local windowHeight = math.max(620, size.height - margin * 2) -- 302
	ImGui.SetNextWindowPos( -- 303
		Vec2(margin, margin), -- 303
		"Always" -- 303
	) -- 303
	ImGui.SetNextWindowSize( -- 304
		Vec2(windowWidth, windowHeight), -- 304
		"Always" -- 304
	) -- 304
	ImGui.Begin( -- 305
		"Dora Visual Editor", -- 305
		mainWindowFlags, -- 305
		function() -- 305
			drawHeader(state) -- 306
			local avail = ImGui.GetContentRegionAvail() -- 307
			local bottomHeight = state.bottomHeight -- 308
			local mainHeight = math.max(320, avail.y - bottomHeight - 10) -- 309
			local availableWidth = math.max(720, avail.x - 4) -- 310
			state.leftWidth = math.max( -- 311
				190, -- 311
				math.min(state.leftWidth, availableWidth - state.rightWidth - 420) -- 311
			) -- 311
			state.rightWidth = math.max( -- 312
				250, -- 312
				math.min(state.rightWidth, availableWidth - state.leftWidth - 420) -- 312
			) -- 312
			local centerWidth = math.max(360, availableWidth - state.leftWidth - state.rightWidth - 24) -- 313
			local leftTopHeight = math.floor(mainHeight * 0.58) -- 314
			local leftBottomHeight = mainHeight - leftTopHeight - 8 -- 315
			ImGui.BeginChild( -- 317
				"LeftDock", -- 317
				Vec2(state.leftWidth, mainHeight), -- 317
				{}, -- 317
				noScrollFlags, -- 317
				function() -- 317
					ImGui.BeginChild( -- 318
						"SceneDock", -- 318
						Vec2(0, leftTopHeight), -- 318
						{}, -- 318
						noScrollFlags, -- 318
						function() return drawScenePanel(state) end -- 318
					) -- 318
					ImGui.BeginChild( -- 319
						"AssetDock", -- 319
						Vec2(0, leftBottomHeight), -- 319
						{}, -- 319
						noScrollFlags, -- 319
						function() return drawAssetsPanel(state) end -- 319
					) -- 319
				end -- 317
			) -- 317
			ImGui.SameLine() -- 321
			drawVerticalSplitter( -- 322
				"LeftSplitter", -- 322
				mainHeight, -- 322
				function(deltaX) -- 322
					state.leftWidth = math.max( -- 323
						190, -- 323
						math.min(state.leftWidth + deltaX, availableWidth - state.rightWidth - 420) -- 323
					) -- 323
				end -- 322
			) -- 322
			ImGui.SameLine() -- 325
			ImGui.PushStyleColor( -- 326
				"ChildBg", -- 326
				transparent, -- 326
				function() -- 326
					ImGui.BeginChild( -- 327
						"CenterDock", -- 327
						Vec2(centerWidth, mainHeight), -- 327
						{}, -- 327
						noScrollFlags, -- 327
						function() -- 327
							if state.mode == "Script" then -- 327
								drawScriptPanel(state) -- 328
							else -- 328
								drawViewport(state) -- 328
							end -- 328
						end -- 327
					) -- 327
				end -- 326
			) -- 326
			ImGui.SameLine() -- 331
			drawVerticalSplitter( -- 332
				"RightSplitter", -- 332
				mainHeight, -- 332
				function(deltaX) -- 332
					state.rightWidth = math.max( -- 333
						250, -- 333
						math.min(state.rightWidth - deltaX, availableWidth - state.leftWidth - 420) -- 333
					) -- 333
				end -- 332
			) -- 332
			ImGui.SameLine() -- 335
			ImGui.BeginChild( -- 336
				"RightDock", -- 336
				Vec2(state.rightWidth, mainHeight), -- 336
				{}, -- 336
				noScrollFlags, -- 336
				function() return drawInspector(state) end -- 336
			) -- 336
			ImGui.BeginChild( -- 337
				"BottomConsoleDock", -- 337
				Vec2(0, bottomHeight), -- 337
				{}, -- 337
				noScrollFlags, -- 337
				function() return drawConsole(state) end -- 337
			) -- 337
		end -- 305
	) -- 305
end -- 298
function ____exports.drawRuntimeError(message) -- 341
	local size = App.visualSize -- 342
	ImGui.SetNextWindowPos( -- 343
		Vec2(10, 10), -- 343
		"Always" -- 343
	) -- 343
	ImGui.SetNextWindowSize( -- 344
		Vec2( -- 344
			math.max(320, size.width - 20), -- 344
			math.max(220, size.height - 20) -- 344
		), -- 344
		"Always" -- 344
	) -- 344
	ImGui.Begin( -- 345
		"Dora Visual Editor Error", -- 345
		mainWindowFlags, -- 345
		function() -- 345
			ImGui.TextColored(warnColor, "SceneImGuiEditor runtime error") -- 346
			ImGui.Separator() -- 347
			ImGui.TextWrapped(message or "unknown error") -- 348
		end -- 345
	) -- 345
end -- 341
return ____exports -- 341