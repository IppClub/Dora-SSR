--[[
Dora Visual Editor - ImGui/Godot-like native viewport prototype.
This tool is intentionally standalone under Script/Tools and does not change the
existing Dora Dev layout.
]]

local ____Dora = require("Dora")
local App = ____Dora.App
local Buffer = ____Dora.Buffer
local Color = ____Dora.Color
local Content = ____Dora.Content
local Director = ____Dora.Director
local DrawNode = ____Dora.DrawNode
local Label = ____Dora.Label
local Line = ____Dora.Line
local Node = ____Dora.Node
local Path = ____Dora.Path
local Sprite = ____Dora.Sprite
local Vec2 = ____Dora.Vec2
local json = ____Dora.json
local threadLoop = ____Dora.threadLoop
local ImGui = require("ImGui")

local zh = string.match(App.locale, "^zh") ~= nil
local themeColor = App.themeColor
local okColor = Color(0xff66d17a)
local warnColor = Color(0xffffcc33)
local redAxisColor = Color(0xffff1f1f)
local greenAxisColor = Color(0xff22ff44)
local gridMinorColor = Color(0xdd8796b0)
local gridMajorColor = Color(0xffffffff)
local panelBg = Color(0xee15191f)
local transparent = Color(0x00000000)

local mainWindowFlags = {"NoDecoration", "NoSavedSettings", "NoMove", "NoCollapse", "NoNav", "NoScrollbar"}
local noScrollFlags = {"NoScrollbar", "NoScrollWithMouse"}
local inputTextFlags = {"AutoSelectAll"}
local sceneSaveFile = Path(Content.writablePath, ".dora", "imgui-editor.scene.json")

local function makeBuffer(text, size)
	local buffer = Buffer(size)
	buffer.text = text or ""
	return buffer
end

local editor = {
	nextId = 0,
	selectedId = "root",
	mode = "2D",
	zoom = 100,
	showGrid = true,
	leftWidth = 280,
	rightWidth = 340,
	bottomHeight = 132,
	status = zh and "Dora Visual Editor 已加载" or "Dora Visual Editor loaded",
	console = {
		zh and "真实 Dora Viewport 已启用。" or "Real Dora viewport enabled.",
	},
	nodes = {},
	order = {},
	preview = {x = 0, y = 0, width = 640, height = 360},
	previewDirty = true,
	previewRoot = nil,
	previewContent = nil,
	runtimeNodes = {},
	runtimeLabels = {},
	assetImportBuffer = makeBuffer("Image/new.png", 256),
	scriptPathBuffer = makeBuffer("", 256),
	scriptContentBuffer = makeBuffer("", 8192),
	activeScriptNodeId = nil,
	selectedAsset = "",
	assets = {
		"Image/player.png",
		"Image/enemy.png",
		"Audio/bgm.ogg",
		"Script/player.lua",
	},
}

local function pushConsole(message)
	editor.console[#editor.console + 1] = message
	if #editor.console > 7 then
		table.remove(editor.console, 1)
	end
end

local function lowerExt(path)
	local ext = Path:getExt(path or "") or ""
	return string.lower(ext)
end

local function assetFolderForExt(ext)
	if ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "ktx" or ext == "pvr" or ext == "clip" then return "Image" end
	if ext == "lua" or ext == "ts" or ext == "tsx" or ext == "yue" then return "Script" end
	if ext == "wav" or ext == "mp3" or ext == "ogg" then return "Audio" end
	if ext == "anim" or ext == "model" or ext == "skel" then return "Animation" end
	return "Resource"
end

local function isTextureAsset(path)
	local ext = lowerExt(path)
	return ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "ktx" or ext == "pvr" or ext == "clip"
end

local function isScriptAsset(path)
	local ext = lowerExt(path)
	return ext == "lua" or ext == "ts" or ext == "tsx" or ext == "yue"
end

local function hasAsset(asset)
	for _, item in ipairs(editor.assets) do
		if item == asset then return true end
	end
	return false
end

local function addAssetPath(path)
	if not path or path == "" then return end
	local ext = lowerExt(path)
	local folder = assetFolderForExt(ext)
	local name = Path:getName(path)
	local asset = Path(folder, name)
	local target = Path(Content.writablePath, asset)
	Content:mkdir(Path(Content.writablePath, folder))
	if Content:exist(path) and path ~= target then
		if not Content:copy(path, target) then
			asset = path
		end
	end
	if not hasAsset(asset) then
		editor.assets[#editor.assets + 1] = asset
	end
	editor.selectedAsset = asset
	editor.status = (zh and "已加入资源：" or "Asset added: ") .. asset
	pushConsole(editor.status)
end

local function importFileDialog()
	App:openFileDialog(false, function(path)
		addAssetPath(path)
	end)
end

local function importFolderDialog()
	App:openFileDialog(true, function(path)
		if not path or path == "" then return end
		for _, file in ipairs(Content:getFiles(path)) do
			addAssetPath(Path(path, file))
		end
	end)
end

local function iconFor(kind)
	if kind == "Sprite" then return "▣" end
	if kind == "Label" then return "T" end
	if kind == "Camera" then return "◉" end
	return "○"
end

local function newNodeId(kind)
	editor.nextId = editor.nextId + 1
	return string.lower(kind) .. "-" .. tostring(editor.nextId)
end

local function addNode(kind, name, parentId)
	parentId = parentId or "root"
	local id = kind == "Root" and "root" or newNodeId(kind)
	local index = editor.nextId
	local node = {
		id = id,
		kind = kind,
		name = name,
		parentId = parentId,
		children = {},
		x = (kind == "Root" or kind == "Camera") and 0 or ((index % 5) - 2) * 70,
		y = (kind == "Root" or kind == "Camera") and 0 or (math.floor(index / 5) % 4) * 55,
		scaleX = 1,
		scaleY = 1,
		rotation = 0,
		visible = true,
		texture = "",
		text = kind == "Label" and "Label" or "",
		script = "",
		nameBuffer = makeBuffer(name, 128),
		textureBuffer = makeBuffer("", 256),
		textBuffer = makeBuffer(kind == "Label" and "Label" or "", 256),
		scriptBuffer = makeBuffer("", 256),
	}
	editor.nodes[id] = node
	editor.order[#editor.order + 1] = id
	if id ~= "root" and editor.nodes[parentId] then
		editor.nodes[parentId].children[#editor.nodes[parentId].children + 1] = id
	end
	return node
end

local function removeFromOrder(id)
	for i = #editor.order, 1, -1 do
		if editor.order[i] == id then
			table.remove(editor.order, i)
		end
	end
end

local function deleteNode(id)
	if id == "root" then
		editor.status = zh and "根节点不能删除" or "Root cannot be deleted"
		return
	end
	local node = editor.nodes[id]
	if not node then return end
	for i = #node.children, 1, -1 do
		deleteNode(node.children[i])
	end
	local parent = editor.nodes[node.parentId]
	if parent then
		for i = #parent.children, 1, -1 do
			if parent.children[i] == id then
				table.remove(parent.children, i)
			end
		end
	end
	editor.nodes[id] = nil
	removeFromOrder(id)
	editor.selectedId = "root"
	editor.previewDirty = true
	editor.status = zh and "已删除节点" or "Node deleted"
	pushConsole(editor.status)
end

local function addChildNode(kind)
	local parentId = editor.selectedId or "root"
	if not editor.nodes[parentId] then parentId = "root" end
	local node = addNode(kind, kind .. tostring(editor.nextId + 1), parentId)
	editor.selectedId = node.id
	editor.previewDirty = true
	editor.status = (zh and "已添加 " or "Added ") .. node.name
	pushConsole(editor.status)
end

local function worldPointFromScreen(screenX, screenY)
	local size = App.visualSize
	return screenX - size.width / 2, size.height / 2 - screenY
end

local function makeLine(points, color)
	return Line(points, color)
end

local function makeThickLine(a, b, color, horizontal)
	local node = Node()
	for offset = -2, 2 do
		if horizontal then
			node:addChild(makeLine({Vec2(a.x, a.y + offset), Vec2(b.x, b.y + offset)}, color))
		else
			node:addChild(makeLine({Vec2(a.x + offset, a.y), Vec2(b.x + offset, b.y)}, color))
		end
	end
	return node
end

local function makeRectLine(width, height, color)
	local hw = width / 2
	local hh = height / 2
	return makeLine({
		Vec2(-hw, -hh),
		Vec2(hw, -hh),
		Vec2(hw, hh),
		Vec2(-hw, hh),
		Vec2(-hw, -hh),
	}, color)
end

local function makeCanvasBackground(width, height)
	local hw = width / 2
	local hh = height / 2
	local bg = DrawNode()
	bg:drawPolygon({Vec2(-hw, -hh), Vec2(hw, -hh), Vec2(hw, hh), Vec2(-hw, hh)}, Color(0xff0b1118), 6, Color(0xffffcc33))
	return bg
end

local function makeGridLine(width, height)
	local grid = Node()
	local hw = width / 2
	local hh = height / 2
	local step = 32
	local minor = DrawNode()
	local major = DrawNode()
	local i = 0
	local x = -math.floor(hw / step) * step
	while x <= hw do
		if i % 5 == 0 then
			major:drawSegment(Vec2(x, -hh), Vec2(x, hh), 1.2, gridMajorColor)
		else
			minor:drawSegment(Vec2(x, -hh), Vec2(x, hh), 0.55, gridMinorColor)
		end
		x = x + step
		i = i + 1
	end
	i = 0
	local y = -math.floor(hh / step) * step
	while y <= hh do
		if i % 5 == 0 then
			major:drawSegment(Vec2(-hw, y), Vec2(hw, y), 1.2, gridMajorColor)
		else
			minor:drawSegment(Vec2(-hw, y), Vec2(hw, y), 0.55, gridMinorColor)
		end
		y = y + step
		i = i + 1
	end
	grid:addChild(minor)
	grid:addChild(major)
	return grid
end

local function makeAxisLine(width, height)
	local hw = width / 2
	local hh = height / 2
	local axis = Node()
	local xAxis = DrawNode()
	xAxis:drawSegment(Vec2(-hw, 0), Vec2(hw, 0), 3.5, redAxisColor)
	local yAxis = DrawNode()
	yAxis:drawSegment(Vec2(0, -hh), Vec2(0, hh), 3.5, greenAxisColor)
	axis:addChild(xAxis)
	axis:addChild(yAxis)
	return axis
end

local function makeSpritePlaceholder()
	local node = Node()
	local frame = makeRectLine(96, 64, Color(0xff4fa3ff))
	frame:addChild(makeLine({Vec2(-48, -32), Vec2(48, 32), Vec2(-48, 32), Vec2(48, -32)}, Color(0xff4fa3ff)))
	node:addChild(frame)
	return node
end

local function makeCameraShape()
	local node = Node()
	node:addChild(makeRectLine(180, 100, Color(0xffffcc33)))
	node:addChild(makeLine({Vec2(-90, 0), Vec2(90, 0), Vec2(0, -50), Vec2(0, 50)}, Color(0xffffcc33)))
	return node
end

local function createRuntimeVisual(item)
	local wrapper = Node()
	if item.kind == "Sprite" then
		local visual = nil
		if item.texture and item.texture ~= "" then
			visual = Sprite(item.texture)
		end
		wrapper:addChild(visual or makeSpritePlaceholder())
	elseif item.kind == "Label" then
		local label = Label("sarasa-mono-sc-regular", 32)
		if label then
			label.text = item.text or "Label"
			editor.runtimeLabels[item.id] = label
			wrapper:addChild(label)
		else
			wrapper:addChild(makeRectLine(120, 38, Color(0xffdcdcdc)))
		end
	elseif item.kind == "Camera" then
		wrapper:addChild(makeCameraShape())
	else
		wrapper:addChild(makeThickLine(Vec2(-14, 0), Vec2(14, 0), Color(0xffffffff), true))
		wrapper:addChild(makeThickLine(Vec2(0, -14), Vec2(0, 14), Color(0xffffffff), false))
	end
	return wrapper
end

local function rebuildPreviewRuntime()
	if not editor.previewRoot then
		editor.previewRoot = Node()
		editor.previewRoot.tag = "__DoraImGuiEditorViewport__"
		Director.entry:addChild(editor.previewRoot)
	end
	editor.previewRoot:removeAllChildren(true)
	editor.runtimeNodes = {}
	editor.runtimeLabels = {}

	local renderScale = App.devicePixelRatio or 1
	local width = math.max(160, editor.preview.width * renderScale)
	local height = math.max(120, editor.preview.height * renderScale)
	editor.previewRoot:addChild(makeCanvasBackground(width, height))
	if editor.showGrid then
		editor.previewRoot:addChild(makeGridLine(width, height))
	end
	editor.previewRoot:addChild(makeAxisLine(width, height))
	for offset = 0, 8, 2 do
		editor.previewRoot:addChild(makeRectLine(width + offset, height + offset, Color(0xffffcc33)))
	end

	local content = Node()
	local scale = math.max(0.25, editor.zoom / 100)
	content.scaleX = scale
	content.scaleY = scale
	editor.previewContent = content
	editor.previewRoot:addChild(content)
	editor.runtimeNodes.root = content

	for _, id in ipairs(editor.order) do
		local item = editor.nodes[id]
		if item and id ~= "root" then
			local runtime = createRuntimeVisual(item)
			editor.runtimeNodes[id] = runtime
			local parent = editor.runtimeNodes[item.parentId or "root"] or content
			parent:addChild(runtime)
		end
	end
	editor.previewDirty = false
end

local function updatePreviewRuntime()
	if editor.previewDirty or not editor.previewRoot then
		rebuildPreviewRuntime()
	end
	local p = editor.preview
	local cx, cy = worldPointFromScreen(p.x + p.width / 2, p.y + p.height / 2)
	editor.previewRoot.x = cx
	editor.previewRoot.y = cy
	if editor.previewContent then
		local scale = math.max(0.25, editor.zoom / 100)
		editor.previewContent.scaleX = scale
		editor.previewContent.scaleY = scale
	end
	for _, id in ipairs(editor.order) do
		local item = editor.nodes[id]
		local runtime = editor.runtimeNodes[id]
		if item and runtime then
			runtime.x = item.x
			runtime.y = item.y
			runtime.scaleX = item.scaleX
			runtime.scaleY = item.scaleY
			runtime.angle = item.rotation
			runtime.visible = item.visible
			local label = editor.runtimeLabels[id]
			if label then label.text = item.text or "Label" end
		end
	end
end

local function drawNodeRow(id, depth)
	local node = editor.nodes[id]
	if not node then return end
	local indent = string.rep("  ", depth)
	local label = indent .. iconFor(node.kind) .. "  " .. node.name .. "##tree_" .. id
	if ImGui.Selectable(label, editor.selectedId == id) then
		editor.selectedId = id
	end
	for _, childId in ipairs(node.children) do
		drawNodeRow(childId, depth + 1)
	end
end

local function drawAddNodePopup()
	ImGui.BeginPopup("AddNodePopup", function()
		ImGui.TextColored(themeColor, zh and "添加节点" or "Add Node")
		ImGui.Separator()
		if ImGui.Selectable("○  Node", false) then addChildNode("Node") ImGui.CloseCurrentPopup() end
		if ImGui.Selectable("▣  Sprite", false) then addChildNode("Sprite") ImGui.CloseCurrentPopup() end
		if ImGui.Selectable("T  Label", false) then addChildNode("Label") ImGui.CloseCurrentPopup() end
		if ImGui.Selectable("◉  Camera", false) then addChildNode("Camera") ImGui.CloseCurrentPopup() end
	end)
end

local function drawHeader()
	ImGui.TextColored(themeColor, "✦ Dora Visual Editor")
	ImGui.SameLine()
	if ImGui.Button("2D") then editor.mode = "2D" end
	ImGui.SameLine()
	if ImGui.Button("Script") then editor.mode = "Script" end
	ImGui.SameLine()
	ImGui.TextDisabled(zh and "Native ImGui / Godot-like" or "Native ImGui / Godot-like")
	ImGui.Separator()
	if ImGui.Button("▶ Run") then
		editor.status = zh and "Run 会在下一步接入场景运行" or "Run will be wired in the next step"
		pushConsole(editor.status)
	end
	ImGui.SameLine()
	if ImGui.Button("▣ Save") then
		Content:mkdir(Path(Content.writablePath, ".dora"))
		local data = {version = 1, nodes = {}}
		for _, id in ipairs(editor.order) do
			local n = editor.nodes[id]
			if n then
				data.nodes[#data.nodes + 1] = {id = n.id, kind = n.kind, name = n.name, parentId = n.parentId, x = n.x, y = n.y, scaleX = n.scaleX, scaleY = n.scaleY, rotation = n.rotation, visible = n.visible, texture = n.texture, text = n.text, script = n.script}
			end
		end
		local text = json.encode(data)
		if text and Content:save(sceneSaveFile, text) then
			editor.status = (zh and "已保存：" or "Saved: ") .. sceneSaveFile
		else
			editor.status = zh and "保存失败" or "Save failed"
		end
		pushConsole(editor.status)
	end
	ImGui.SameLine()
	if ImGui.Button("◇ Build") then
		editor.status = zh and "Build 会在代码生成稳定后接入" or "Build will be wired after codegen is stable"
		pushConsole(editor.status)
	end
	ImGui.SameLine()
	ImGui.TextDisabled("|")
	ImGui.SameLine()
	if ImGui.Button("＋ Add") then ImGui.OpenPopup("AddNodePopup") end
	drawAddNodePopup()
	ImGui.SameLine()
	if ImGui.Button("Delete") then deleteNode(editor.selectedId) end
	ImGui.Separator()
end

local function drawScenePanel()
	ImGui.TextColored(themeColor, "Scene Tree")
	ImGui.SameLine()
	if ImGui.SmallButton("＋##scene_add") then ImGui.OpenPopup("AddNodePopup") end
	drawAddNodePopup()
	ImGui.Separator()
	drawNodeRow("root", 0)
	ImGui.Separator()
	ImGui.TextDisabled(zh and "＋ 添加到当前选中节点下" or "+ adds under selected node")
end

local function drawImportAssetPopup()
	ImGui.BeginPopup("ImportAssetPopup", function()
		ImGui.TextColored(themeColor, zh and "加入资源" or "Import Asset")
		ImGui.Separator()
		ImGui.TextDisabled(zh and "输入路径，如 Image/player.png / Script/player.lua" or "Enter a path, e.g. Image/player.png / Script/player.lua")
		ImGui.InputText("Path", editor.assetImportBuffer, inputTextFlags)
		if ImGui.Button(zh and "加入" or "Add") then
			local value = editor.assetImportBuffer.text
			if value and value ~= "" then
				editor.assets[#editor.assets + 1] = value
				editor.status = (zh and "已加入资源：" or "Asset added: ") .. value
				pushConsole(editor.status)
			end
			ImGui.CloseCurrentPopup()
		end
		ImGui.SameLine()
		if ImGui.Button(zh and "关闭" or "Close") then ImGui.CloseCurrentPopup() end
	end)
end

local function drawAssetRow(asset)
	if ImGui.Selectable("  " .. asset, editor.selectedAsset == asset) then
		editor.selectedAsset = asset
		local node = editor.nodes[editor.selectedId]
		if node and node.kind == "Sprite" and isTextureAsset(asset) then
			node.texture = asset
			node.textureBuffer.text = asset
			editor.previewDirty = true
			editor.status = (zh and "已绑定贴图：" or "Texture assigned: ") .. asset
		elseif node and isScriptAsset(asset) then
			node.script = asset
			node.scriptBuffer.text = asset
			editor.status = (zh and "已绑定脚本：" or "Script assigned: ") .. asset
		else
			editor.status = zh and "选择 Sprite 可绑定图片，选择节点可绑定 Lua 脚本" or "Select a Sprite for images, or a node for Lua scripts"
		end
		pushConsole(editor.status)
	end
end

local function drawAssetsPanel()
	ImGui.TextColored(themeColor, "FileSystem")
	ImGui.SameLine()
	if ImGui.SmallButton("＋ File") then importFileDialog() end
	ImGui.SameLine()
	if ImGui.SmallButton("＋ Folder") then importFolderDialog() end
	ImGui.Separator()
	ImGui.TextDisabled(zh and "拖拽导入需要原生 FileDrop 绑定；当前先用系统文件选择器。" or "OS drag-drop needs a native FileDrop binding; use the file picker for now.")
	ImGui.Separator()
	local groups = {
		{title = "Textures", filter = isTextureAsset},
		{title = "Scripts", filter = isScriptAsset},
		{title = "Audio", filter = function(path) local ext = lowerExt(path) return ext == "wav" or ext == "mp3" or ext == "ogg" end},
		{title = "Animations", filter = function(path) local ext = lowerExt(path) return ext == "anim" or ext == "model" or ext == "skel" end},
	}
	for _, group in ipairs(groups) do
		if ImGui.TreeNode(group.title, function()
			for _, asset in ipairs(editor.assets) do
				if group.filter(asset) then drawAssetRow(asset) end
			end
		end) then end
	end
	if editor.selectedAsset ~= "" and isTextureAsset(editor.selectedAsset) then
		ImGui.Separator()
		ImGui.TextColored(themeColor, "Texture Preview")
		local ok = pcall(function()
			ImGui.Image(editor.selectedAsset, Vec2(160, 120))
		end)
		if not ok then
			ImGui.TextDisabled(zh and "无法预览该贴图" or "Unable to preview this texture")
		end
	end
end

local function openScriptForNode(node)
	if not node then return end
	if node.script == "" then
		node.script = "Script/" .. node.name .. ".lua"
		node.scriptBuffer.text = node.script
	end
	editor.activeScriptNodeId = node.id
	editor.scriptPathBuffer.text = node.script
	local scriptFile = Path(Content.writablePath, node.script)
	if Content:exist(scriptFile) then
		editor.scriptContentBuffer.text = Content:load(scriptFile) or ""
	else
		editor.scriptContentBuffer.text = "-- " .. node.name .. " behavior\nreturn function(node, scene)\n\t-- write behavior here\nend\n"
	end
	editor.mode = "Script"
end

local function drawScriptPanel()
	local node = editor.nodes[editor.activeScriptNodeId or editor.selectedId]
	ImGui.TextColored(themeColor, "Script")
	ImGui.SameLine()
	ImGui.TextDisabled(node and node.name or "No Node")
	ImGui.Separator()
	if not node then
		ImGui.TextDisabled(zh and "先选择一个节点" or "Select a node first")
		return
	end
	ImGui.InputText("Path", editor.scriptPathBuffer, inputTextFlags)
	ImGui.SameLine()
	if ImGui.Button(zh and "保存脚本" or "Save Script") then
		node.script = editor.scriptPathBuffer.text
		node.scriptBuffer.text = node.script
		local scriptFile = Path(Content.writablePath, node.script)
		Content:mkdir(Path:getPath(scriptFile))
		if Content:save(scriptFile, editor.scriptContentBuffer.text) then
			editor.status = (zh and "脚本已保存：" or "Script saved: ") .. node.script
		else
			editor.status = zh and "脚本保存失败" or "Failed to save script"
		end
		pushConsole(editor.status)
	end
	ImGui.InputTextMultiline("##ScriptEditor", editor.scriptContentBuffer, Vec2(0, -4), {})
end

local function drawViewport()
	ImGui.TextColored(themeColor, "Viewport")
	ImGui.SameLine()
	ImGui.TextDisabled("Main.scene")
	ImGui.SameLine()
	local changed, grid = ImGui.Checkbox("Grid", editor.showGrid)
	if changed then editor.showGrid = grid editor.previewDirty = true end
	ImGui.SameLine()
	local zoomChanged, zoom = ImGui.DragFloat("Zoom", editor.zoom, 1, 25, 400, "%.0f%%")
	if zoomChanged then editor.zoom = zoom end
	ImGui.Separator()

	local cursor = ImGui.GetCursorScreenPos()
	local avail = ImGui.GetContentRegionAvail()
	local viewportWidth = math.max(360, avail.x - 8)
	local viewportHeight = math.max(300, avail.y - 38)
	if math.abs(editor.preview.width - viewportWidth) > 1 or math.abs(editor.preview.height - viewportHeight) > 1 then
		editor.previewDirty = true
	end
	editor.preview.x = cursor.x
	editor.preview.y = cursor.y
	editor.preview.width = viewportWidth
	editor.preview.height = viewportHeight
	updatePreviewRuntime()

	ImGui.Dummy(Vec2(viewportWidth, viewportHeight))
	ImGui.Separator()
	ImGui.TextColored(okColor, zh and "真实 Dora Viewport" or "Real Dora Viewport")
	ImGui.SameLine()
	ImGui.TextDisabled(zh and "红=X 绿=Y，拖动左右分割条可放大" or "Red=X Green=Y, drag splitters to resize")
end

local function drawInspector()
	ImGui.TextColored(themeColor, "Inspector")
	ImGui.Separator()
	local node = editor.nodes[editor.selectedId]
	if not node then
		ImGui.TextDisabled(zh and "没有选中节点" or "No node selected")
		return
	end
	ImGui.Text(iconFor(node.kind) .. "  " .. node.kind)
	if ImGui.InputText("Name", node.nameBuffer, inputTextFlags) then node.name = node.nameBuffer.text end
	local changed, x, y = ImGui.DragFloat2("Position", node.x, node.y, 1, -10000, 10000, "%.1f")
	if changed then node.x = x node.y = y end
	changed, x, y = ImGui.DragFloat2("Scale", node.scaleX, node.scaleY, 0.01, -100, 100, "%.2f")
	if changed then node.scaleX = x node.scaleY = y end
	local angle
	changed, angle = ImGui.DragFloat("Rotation", node.rotation, 1, -360, 360, "%.1f")
	if changed then node.rotation = angle end
	local visible
	changed, visible = ImGui.Checkbox("Visible", node.visible)
	if changed then node.visible = visible end
	ImGui.Separator()
	if ImGui.InputText("Script", node.scriptBuffer, inputTextFlags) then node.script = node.scriptBuffer.text end
	if ImGui.Button(zh and "打开脚本" or "Open Script") then openScriptForNode(node) end
	if node.kind == "Sprite" then
		ImGui.Separator()
		if ImGui.InputText("Texture", node.textureBuffer, inputTextFlags) then
			node.texture = node.textureBuffer.text
			editor.previewDirty = true
		end
	elseif node.kind == "Label" then
		ImGui.Separator()
		if ImGui.InputText("Text", node.textBuffer, inputTextFlags) then node.text = node.textBuffer.text end
	elseif node.kind == "Camera" then
		ImGui.Separator()
		ImGui.TextDisabled(zh and "Camera 显示真实取景框。" or "Camera shows a real frame in viewport.")
	end
end

local function drawConsole()
	ImGui.TextColored(themeColor, "Console")
	ImGui.SameLine()
	ImGui.TextColored(okColor, editor.status)
	ImGui.Separator()
	for _, line in ipairs(editor.console) do ImGui.TextDisabled(line) end
end

local function drawVerticalSplitter(id, height, onDrag)
	ImGui.PushStyleColor("Button", Color(0xff343a44), function()
		ImGui.PushStyleColor("ButtonHovered", Color(0xff4d5968), function()
			ImGui.PushStyleColor("ButtonActive", Color(0xffffcc33), function()
				ImGui.Button("##" .. id, Vec2(12, height))
			end)
		end)
	end)
	if ImGui.IsItemHovered() then
		ImGui.BeginTooltip(function() ImGui.Text(zh and "拖动调整面板宽度" or "Drag to resize panel") end)
	end
	if ImGui.IsItemActive() and ImGui.IsMouseDragging(0) then
		local delta = ImGui.GetMouseDragDelta(0)
		if delta.x ~= 0 then
			onDrag(delta.x)
			ImGui.ResetMouseDragDelta(0)
		end
	end
end

local function drawEditor()
	local size = App.visualSize
	local margin = 10
	local windowWidth = math.max(900, size.width - margin * 2)
	local windowHeight = math.max(620, size.height - margin * 2)
	ImGui.SetNextWindowPos(Vec2(margin, margin), "Always")
	ImGui.SetNextWindowSize(Vec2(windowWidth, windowHeight), "Always")
	ImGui.Begin("Dora Visual Editor", mainWindowFlags, function()
		drawHeader()
		local avail = ImGui.GetContentRegionAvail()
		local bottomHeight = editor.bottomHeight
		local mainHeight = math.max(320, avail.y - bottomHeight - 10)
		local availableWidth = math.max(720, avail.x - 4)
		editor.leftWidth = math.max(190, math.min(editor.leftWidth, availableWidth - editor.rightWidth - 420))
		editor.rightWidth = math.max(250, math.min(editor.rightWidth, availableWidth - editor.leftWidth - 420))
		local centerWidth = math.max(360, availableWidth - editor.leftWidth - editor.rightWidth - 24)
		local leftTopHeight = math.floor(mainHeight * 0.58)
		local leftBottomHeight = mainHeight - leftTopHeight - 8

		ImGui.BeginChild("LeftDock", Vec2(editor.leftWidth, mainHeight), {}, noScrollFlags, function()
			ImGui.BeginChild("SceneDock", Vec2(0, leftTopHeight), {}, noScrollFlags, function() drawScenePanel() end)
			ImGui.BeginChild("AssetDock", Vec2(0, leftBottomHeight), {}, noScrollFlags, function() drawAssetsPanel() end)
		end)
		ImGui.SameLine()
		drawVerticalSplitter("LeftSplitter", mainHeight, function(deltaX)
			editor.leftWidth = math.max(190, math.min(editor.leftWidth + deltaX, availableWidth - editor.rightWidth - 420))
		end)
		ImGui.SameLine()
		ImGui.PushStyleColor("ChildBg", transparent, function()
			ImGui.BeginChild("CenterDock", Vec2(centerWidth, mainHeight), {}, noScrollFlags, function()
				if editor.mode == "Script" then drawScriptPanel() else drawViewport() end
			end)
		end)
		ImGui.SameLine()
		drawVerticalSplitter("RightSplitter", mainHeight, function(deltaX)
			editor.rightWidth = math.max(250, math.min(editor.rightWidth - deltaX, availableWidth - editor.leftWidth - 420))
		end)
		ImGui.SameLine()
		ImGui.BeginChild("RightDock", Vec2(editor.rightWidth, mainHeight), {}, noScrollFlags, function() drawInspector() end)

		ImGui.BeginChild("BottomConsoleDock", Vec2(0, bottomHeight), {}, noScrollFlags, function() drawConsole() end)
	end)
end

addNode("Root", "MainScene", nil)
addNode("Camera", "Camera2D", "root")

local runtimeError = nil
local function drawRuntimeError()
	local size = App.visualSize
	ImGui.SetNextWindowPos(Vec2(10, 10), "Always")
	ImGui.SetNextWindowSize(Vec2(math.max(320, size.width - 20), math.max(220, size.height - 20)), "Always")
	ImGui.Begin("Dora Visual Editor Error", mainWindowFlags, function()
		ImGui.TextColored(warnColor, "SceneImGuiEditor runtime error")
		ImGui.Separator()
		ImGui.TextWrapped(runtimeError or "unknown error")
	end)
end

threadLoop(function()
	if runtimeError then drawRuntimeError() return false end
	local ok, err = pcall(drawEditor)
	if not ok then runtimeError = debug.traceback(tostring(err)) end
	return false
end)

return editor
