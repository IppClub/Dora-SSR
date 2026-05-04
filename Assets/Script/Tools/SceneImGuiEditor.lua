--[[
Godot-like ImGui scene editor shell for Dora.

Design goal of this first step:
- Pure ImGui editor chrome, stable and visible.
- Additive tool entry only; no change to the existing Dora Dev layout.
- Do not create/modify the user's running scene yet. The real Dora viewport and
  runtime node binding will be plugged into the center panel after the shell is stable.
]]

local ____Dora = require("Dora")
local App = ____Dora.App
local Buffer = ____Dora.Buffer
local Color = ____Dora.Color
local Content = ____Dora.Content
local Director = ____Dora.Director
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
local textMutedColor = Color(0xff9aa0a6)
local okColor = Color(0xff66d17a)
local warnColor = Color(0xffffcc33)

local mainWindowFlags = {"NoDecoration", "NoSavedSettings", "NoMove", "NoCollapse", "NoNav"}
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
	toolMode = 1,
	zoom = 100,
	showGrid = true,
	status = zh and "Godot-like ImGui 壳子已加载" or "Godot-like ImGui shell loaded",
	console = {
		zh and "编辑器 UI 已启动。当前阶段只做稳定壳子，不改旧 UI 布局。" or "Editor UI started. This step only builds the stable shell without changing the old UI layout.",
	},
	nodes = {},
	order = {},
	preview = {x = 0, y = 0, width = 640, height = 360},
	previewDirty = true,
	previewRoot = nil,
	previewContent = nil,
	runtimeNodes = {},
	runtimeLabels = {},
	assets = {
		"Image/player.png",
		"Image/enemy.png",
		"Audio/bgm.ogg",
		"Script/player.lua",
	},
}

local function pushConsole(message)
	editor.console[#editor.console + 1] = message
	if #editor.console > 6 then
		table.remove(editor.console, 1)
	end
end

local function newNodeId(kind)
	editor.nextId = editor.nextId + 1
	return string.lower(kind) .. "-" .. tostring(editor.nextId)
end

local function addNode(kind, name, parentId)
	parentId = parentId or "root"
	local id = kind == "Root" and "root" or newNodeId(kind)
	local node = {
		id = id,
		kind = kind,
		name = name,
		parentId = parentId,
		children = {},
		x = 0,
		y = 0,
		scaleX = 1,
		scaleY = 1,
		rotation = 0,
		visible = true,
		texture = "",
		text = "Label",
		nameBuffer = makeBuffer(name, 128),
		textureBuffer = makeBuffer("", 256),
		textBuffer = makeBuffer("Label", 256),
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

local function iconFor(kind)
	if kind == "Sprite" then return "▣" end
	if kind == "Label" then return "T" end
	if kind == "Camera" then return "◉" end
	return "○"
end

local function worldPointFromScreen(screenX, screenY)
	local size = App.visualSize
	return screenX - size.width / 2, size.height / 2 - screenY
end

local function makeRectLine(width, height, color)
	local hw = width / 2
	local hh = height / 2
	return Line({
		Vec2(-hw, -hh),
		Vec2(hw, -hh),
		Vec2(hw, hh),
		Vec2(-hw, hh),
		Vec2(-hw, -hh),
	}, color)
end

local function makeGridLine(width, height)
	local verts = {}
	local hw = width / 2
	local hh = height / 2
	local step = 32
	local x = -math.floor(hw / step) * step
	while x <= hw do
		verts[#verts + 1] = Vec2(x, -hh)
		verts[#verts + 1] = Vec2(x, hh)
		x = x + step
	end
	local y = -math.floor(hh / step) * step
	while y <= hh do
		verts[#verts + 1] = Vec2(-hw, y)
		verts[#verts + 1] = Vec2(hw, y)
		y = y + step
	end
	return Line(verts, Color(0x334c566a))
end

local function makeAxisLine(width, height)
	local hw = width / 2
	local hh = height / 2
	local axis = Node()
	axis:addChild(Line({Vec2(-hw, 0), Vec2(hw, 0)}, Color(0xaae04646)))
	axis:addChild(Line({Vec2(0, -hh), Vec2(0, hh)}, Color(0xaa63d471)))
	return axis
end

local function makeSpritePlaceholder()
	local node = Node()
	local frame = makeRectLine(96, 64, Color(0xff4fa3ff))
	frame:addChild(Line({Vec2(-48, -32), Vec2(48, 32), Vec2(-48, 32), Vec2(48, -32)}, Color(0x884fa3ff)))
	node:addChild(frame)
	return node
end

local function makeCameraShape()
	local node = Node()
	node:addChild(makeRectLine(160, 90, Color(0xffffcc33)))
	node:addChild(Line({Vec2(-80, 0), Vec2(80, 0), Vec2(0, -45), Vec2(0, 45)}, Color(0x88ffcc33)))
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
		wrapper:addChild(Line({Vec2(-8, 0), Vec2(8, 0), Vec2(0, -8), Vec2(0, 8)}, Color(0xffcccccc)))
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

	local width = math.max(160, editor.preview.width)
	local height = math.max(120, editor.preview.height)
	if editor.showGrid then
		editor.previewRoot:addChild(makeGridLine(width, height))
	end
	editor.previewRoot:addChild(makeAxisLine(width, height))
	editor.previewRoot:addChild(makeRectLine(width, height, Color(0x99ffcc33)))

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

local function drawHeader()
	ImGui.TextColored(themeColor, "✦ Dora Visual Editor")
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
				data.nodes[#data.nodes + 1] = {
					id = n.id,
					kind = n.kind,
					name = n.name,
					parentId = n.parentId,
					x = n.x,
					y = n.y,
					scaleX = n.scaleX,
					scaleY = n.scaleY,
					rotation = n.rotation,
					visible = n.visible,
					texture = n.texture,
					text = n.text,
				}
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
	if ImGui.Button("+ Node") then addChildNode("Node") end
	ImGui.SameLine()
	if ImGui.Button("+ Sprite") then addChildNode("Sprite") end
	ImGui.SameLine()
	if ImGui.Button("+ Label") then addChildNode("Label") end
	ImGui.SameLine()
	if ImGui.Button("+ Camera") then addChildNode("Camera") end
	ImGui.SameLine()
	if ImGui.Button("Delete") then deleteNode(editor.selectedId) end
	ImGui.Separator()
end

local function drawScenePanel()
	ImGui.TextColored(themeColor, zh and "Scene Tree" or "Scene Tree")
	ImGui.Separator()
	drawNodeRow("root", 0)
	ImGui.Separator()
	ImGui.TextDisabled(zh and "新增节点会挂到当前选中节点下面。" or "New nodes are parented under the selected node.")
end

local function drawAssetsPanel()
	ImGui.TextColored(themeColor, "Assets")
	ImGui.Separator()
	for _, asset in ipairs(editor.assets) do
		if ImGui.Selectable("  " .. asset, false) then
			local node = editor.nodes[editor.selectedId]
			if node and node.kind == "Sprite" then
				node.texture = asset
				node.textureBuffer.text = asset
				editor.previewDirty = true
				editor.status = (zh and "已绑定贴图：" or "Texture assigned: ") .. asset
			else
				editor.status = zh and "先选择一个 Sprite 节点再绑定资源" or "Select a Sprite node before assigning an asset"
			end
			pushConsole(editor.status)
		end
	end
end

local function drawViewport()
	ImGui.TextColored(themeColor, "Viewport")
	ImGui.SameLine()
	ImGui.TextDisabled("Main.scene")
	ImGui.SameLine()
	local changed, grid = ImGui.Checkbox("Grid", editor.showGrid)
	if changed then
		editor.showGrid = grid
		editor.previewDirty = true
	end
	ImGui.SameLine()
	local zoomChanged, zoom = ImGui.DragFloat("Zoom", editor.zoom, 1, 25, 400, "%.0f%%")
	if zoomChanged then editor.zoom = zoom end
	ImGui.Separator()

	local cursor = ImGui.GetCursorScreenPos()
	local avail = ImGui.GetContentRegionAvail()
	local viewportWidth = math.max(260, avail.x - 8)
	local viewportHeight = math.max(180, avail.y - 90)
	editor.preview.x = cursor.x
	editor.preview.y = cursor.y
	editor.preview.width = viewportWidth
	editor.preview.height = viewportHeight
	updatePreviewRuntime()

	ImGui.Dummy(Vec2(viewportWidth, viewportHeight))
	ImGui.Separator()
	ImGui.TextColored(okColor, zh and "真实 Dora Viewport" or "Real Dora Viewport")
	ImGui.SameLine()
	ImGui.TextDisabled(zh and "下一步：picking / gizmo" or "Next: picking / gizmo")
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
	if ImGui.InputText("Name", node.nameBuffer, inputTextFlags) then
		node.name = node.nameBuffer.text
	end
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
	if node.kind == "Sprite" then
		ImGui.Separator()
		if ImGui.InputText("Texture", node.textureBuffer, inputTextFlags) then
			node.texture = node.textureBuffer.text
			editor.previewDirty = true
		end
	elseif node.kind == "Label" then
		ImGui.Separator()
		if ImGui.InputText("Text", node.textBuffer, inputTextFlags) then
			node.text = node.textBuffer.text
		end
	elseif node.kind == "Camera" then
		ImGui.Separator()
		ImGui.TextDisabled(zh and "Camera 跟随目标、缩放会在下一步接入。" or "Camera follow target and zoom will be wired next.")
	end
end

local function drawConsole()
	ImGui.TextColored(themeColor, "Console")
	ImGui.SameLine()
	ImGui.TextColored(okColor, editor.status)
	ImGui.Separator()
	for _, line in ipairs(editor.console) do
		ImGui.TextDisabled(line)
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

		local leftWidth = 260
		local rightWidth = 330
		local bottomHeight = 92
		local panelGap = 8
		local contentHeight = math.max(360, windowHeight - 108)
		local centerWidth = math.max(360, windowWidth - leftWidth - rightWidth - panelGap * 4 - 20)
		local mainHeight = math.max(300, contentHeight - bottomHeight - panelGap)
		local leftTopHeight = math.floor(mainHeight * 0.58)
		local leftBottomHeight = mainHeight - leftTopHeight - panelGap

		ImGui.BeginChild("LeftDock", Vec2(leftWidth, mainHeight), function()
			ImGui.BeginChild("SceneDock", Vec2(0, leftTopHeight), function()
				drawScenePanel()
			end)
			ImGui.BeginChild("AssetDock", Vec2(0, leftBottomHeight), function()
				drawAssetsPanel()
			end)
		end)
		ImGui.SameLine()
		ImGui.BeginChild("CenterDock", Vec2(centerWidth, mainHeight), function()
			drawViewport()
		end)
		ImGui.SameLine()
		ImGui.BeginChild("RightDock", Vec2(rightWidth, mainHeight), function()
			drawInspector()
		end)

		ImGui.BeginChild("BottomConsoleDock", Vec2(0, bottomHeight), function()
			drawConsole()
		end)
	end)
end

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
	if runtimeError then
		drawRuntimeError()
		return false
	end
	local ok, err = pcall(drawEditor)
	if not ok then
		runtimeError = debug.traceback(tostring(err))
	end
	return false
end)

return editor
