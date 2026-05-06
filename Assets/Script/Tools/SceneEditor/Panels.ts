import { App, Color, Content, Path, Vec2, json } from 'Dora';
import * as ImGui from 'ImGui';
import { SetCond, StyleColor } from 'ImGui';
import { EditorState, SceneNodeData } from 'Script/Tools/SceneEditor/Types';
import { inputTextFlags, mainWindowFlags, noScrollFlags, okColor, themeColor, transparent, warnColor } from 'Script/Tools/SceneEditor/Theme';
import { addChildNode, deleteNode, iconFor, importFileDialog, importFolderDialog, isScriptAsset, isTextureAsset, lowerExt, pushConsole, zh } from 'Script/Tools/SceneEditor/Model';
import { updatePreviewRuntime } from 'Script/Tools/SceneEditor/Runtime';

declare function pcall(fn: () => void): LuaMultiReturn<[boolean, unknown]>;

const sceneSaveFile = Path(Content.writablePath, '.dora', 'imgui-editor.scene.json');

function drawNodeRow(state: EditorState, id: string, depth: number) {
	const node = state.nodes[id];
	if (node === undefined) return;
	const indent = string.rep('  ', depth);
	const label = indent + iconFor(node.kind) + '  ' + node.name + '##tree_' + id;
	if (ImGui.Selectable(label, state.selectedId === id)) {
		state.selectedId = id;
	}
	for (const childId of node.children) {
		drawNodeRow(state, childId, depth + 1);
	}
}

function drawAddNodePopup(state: EditorState) {
	ImGui.BeginPopup('AddNodePopup', () => {
		ImGui.TextColored(themeColor, zh ? '添加节点' : 'Add Node');
		ImGui.Separator();
		if (ImGui.Selectable('○  Node', false)) { addChildNode(state, 'Node'); ImGui.CloseCurrentPopup(); }
		if (ImGui.Selectable('▣  Sprite', false)) { addChildNode(state, 'Sprite'); ImGui.CloseCurrentPopup(); }
		if (ImGui.Selectable('T  Label', false)) { addChildNode(state, 'Label'); ImGui.CloseCurrentPopup(); }
		if (ImGui.Selectable('◉  Camera', false)) { addChildNode(state, 'Camera'); ImGui.CloseCurrentPopup(); }
	});
}

function saveScene(state: EditorState) {
	Content.mkdir(Path(Content.writablePath, '.dora'));
	const data = { version: 1, nodes: [] as object[] };
	for (const id of state.order) {
		const node = state.nodes[id];
		if (node !== undefined) {
			data.nodes.push({
				id: node.id,
				kind: node.kind,
				name: node.name,
				parentId: node.parentId,
				x: node.x,
				y: node.y,
				scaleX: node.scaleX,
				scaleY: node.scaleY,
				rotation: node.rotation,
				visible: node.visible,
				texture: node.texture,
				text: node.text,
				script: node.script,
			});
		}
	}
	const [text] = json.encode(data);
	if (text !== undefined && Content.save(sceneSaveFile, text)) {
		state.status = (zh ? '已保存：' : 'Saved: ') + sceneSaveFile;
	} else {
		state.status = zh ? '保存失败' : 'Save failed';
	}
	pushConsole(state, state.status);
}

function drawHeader(state: EditorState) {
	ImGui.TextColored(themeColor, '✦ Dora Visual Editor');
	ImGui.SameLine();
	if (ImGui.Button('2D')) state.mode = '2D';
	ImGui.SameLine();
	if (ImGui.Button('Script')) state.mode = 'Script';
	ImGui.SameLine();
	ImGui.TextDisabled(zh ? 'Native ImGui / Godot-like' : 'Native ImGui / Godot-like');
	ImGui.Separator();
	if (ImGui.Button('▶ Run')) {
		state.status = zh ? 'Run 会在下一步接入场景运行' : 'Run will be wired in the next step';
		pushConsole(state, state.status);
	}
	ImGui.SameLine();
	if (ImGui.Button('▣ Save')) saveScene(state);
	ImGui.SameLine();
	if (ImGui.Button('◇ Build')) {
		state.status = zh ? 'Build 会在代码生成稳定后接入' : 'Build will be wired after codegen is stable';
		pushConsole(state, state.status);
	}
	ImGui.SameLine();
	ImGui.TextDisabled('|');
	ImGui.SameLine();
	if (ImGui.Button('＋ Add')) ImGui.OpenPopup('AddNodePopup');
	drawAddNodePopup(state);
	ImGui.SameLine();
	if (ImGui.Button('Delete')) deleteNode(state, state.selectedId);
	ImGui.Separator();
}

function drawScenePanel(state: EditorState) {
	ImGui.TextColored(themeColor, 'Scene Tree');
	ImGui.SameLine();
	if (ImGui.SmallButton('＋##scene_add')) ImGui.OpenPopup('AddNodePopup');
	drawAddNodePopup(state);
	ImGui.Separator();
	drawNodeRow(state, 'root', 0);
	ImGui.Separator();
	ImGui.TextDisabled(zh ? '＋ 添加到当前选中节点下' : '+ adds under selected node');
}

function drawAssetRow(state: EditorState, asset: string) {
	if (ImGui.Selectable('  ' + asset, state.selectedAsset === asset)) {
		state.selectedAsset = asset;
		const node = state.nodes[state.selectedId];
		if (node !== undefined && node.kind === 'Sprite' && isTextureAsset(asset)) {
			node.texture = asset;
			node.textureBuffer.text = asset;
			state.previewDirty = true;
			state.status = (zh ? '已绑定贴图：' : 'Texture assigned: ') + asset;
		} else if (node !== undefined && isScriptAsset(asset)) {
			node.script = asset;
			node.scriptBuffer.text = asset;
			state.status = (zh ? '已绑定脚本：' : 'Script assigned: ') + asset;
		} else {
			state.status = zh ? '选择 Sprite 可绑定图片，选择节点可绑定 Lua 脚本' : 'Select a Sprite for images, or a node for Lua scripts';
		}
		pushConsole(state, state.status);
	}
}

function drawAssetsPanel(state: EditorState) {
	ImGui.TextColored(themeColor, 'FileSystem');
	ImGui.SameLine();
	if (ImGui.SmallButton('＋ File')) importFileDialog(state);
	ImGui.SameLine();
	if (ImGui.SmallButton('＋ Folder')) importFolderDialog(state);
	ImGui.Separator();
	ImGui.TextDisabled(zh ? '拖拽导入需要原生 FileDrop 绑定；当前先用系统文件选择器。' : 'OS drag-drop needs a native FileDrop binding; use the file picker for now.');
	ImGui.Separator();
	const groups = [
		{ title: 'Textures', filter: isTextureAsset },
		{ title: 'Scripts', filter: isScriptAsset },
		{ title: 'Audio', filter: (path: string) => { const ext = lowerExt(path); return ext === 'wav' || ext === 'mp3' || ext === 'ogg'; } },
		{ title: 'Animations', filter: (path: string) => { const ext = lowerExt(path); return ext === 'anim' || ext === 'model' || ext === 'skel'; } },
	];
	for (const group of groups) {
		ImGui.TreeNode(group.title, () => {
			for (const asset of state.assets) {
				if (group.filter(asset)) drawAssetRow(state, asset);
			}
		});
	}
	if (state.selectedAsset !== '' && isTextureAsset(state.selectedAsset)) {
		ImGui.Separator();
		ImGui.TextColored(themeColor, 'Texture Preview');
		const [ok] = pcall(() => ImGui.Image(state.selectedAsset, Vec2(160, 120)));
		if (!ok) ImGui.TextDisabled(zh ? '无法预览该贴图' : 'Unable to preview this texture');
	}
}

function openScriptForNode(state: EditorState, node: SceneNodeData) {
	if (node.script === '') {
		node.script = 'Script/' + node.name + '.lua';
		node.scriptBuffer.text = node.script;
	}
	state.activeScriptNodeId = node.id;
	state.scriptPathBuffer.text = node.script;
	const scriptFile = Path(Content.writablePath, node.script);
	if (Content.exist(scriptFile)) {
		state.scriptContentBuffer.text = Content.load(scriptFile) || '';
	} else {
		state.scriptContentBuffer.text = '-- ' + node.name + ' behavior\nreturn function(node, scene)\n\t-- write behavior here\nend\n';
	}
	state.mode = 'Script';
}

function drawScriptPanel(state: EditorState) {
	const activeId = state.activeScriptNodeId || state.selectedId;
	const node = state.nodes[activeId];
	ImGui.TextColored(themeColor, 'Script');
	ImGui.SameLine();
	ImGui.TextDisabled(node !== undefined ? node.name : 'No Node');
	ImGui.Separator();
	if (node === undefined) {
		ImGui.TextDisabled(zh ? '先选择一个节点' : 'Select a node first');
		return;
	}
	ImGui.InputText('Path', state.scriptPathBuffer, inputTextFlags);
	ImGui.SameLine();
	if (ImGui.Button(zh ? '保存脚本' : 'Save Script')) {
		node.script = state.scriptPathBuffer.text;
		node.scriptBuffer.text = node.script;
		const scriptFile = Path(Content.writablePath, node.script);
		Content.mkdir(Path.getPath(scriptFile));
		if (Content.save(scriptFile, state.scriptContentBuffer.text)) {
			state.status = (zh ? '脚本已保存：' : 'Script saved: ') + node.script;
		} else {
			state.status = zh ? '脚本保存失败' : 'Failed to save script';
		}
		pushConsole(state, state.status);
	}
	ImGui.InputTextMultiline('##ScriptEditor', state.scriptContentBuffer, Vec2(0, -4), []);
}

function drawViewport(state: EditorState) {
	ImGui.TextColored(themeColor, 'Viewport');
	ImGui.SameLine();
	ImGui.TextDisabled('Main.scene');
	ImGui.SameLine();
	const [gridChanged, grid] = ImGui.Checkbox('Grid', state.showGrid);
	if (gridChanged) { state.showGrid = grid; state.previewDirty = true; }
	ImGui.SameLine();
	const [zoomChanged, zoom] = ImGui.DragFloat('Zoom', state.zoom, 1, 25, 400, '%.0f%%');
	if (zoomChanged) state.zoom = zoom;
	ImGui.Separator();
	const cursor = ImGui.GetCursorScreenPos();
	const avail = ImGui.GetContentRegionAvail();
	const viewportWidth = math.max(360, avail.x - 8);
	const viewportHeight = math.max(300, avail.y - 38);
	if (math.abs(state.preview.width - viewportWidth) > 1 || math.abs(state.preview.height - viewportHeight) > 1) {
		state.previewDirty = true;
	}
	state.preview.x = cursor.x;
	state.preview.y = cursor.y;
	state.preview.width = viewportWidth;
	state.preview.height = viewportHeight;
	updatePreviewRuntime(state);
	ImGui.Dummy(Vec2(viewportWidth, viewportHeight));
	ImGui.Separator();
	ImGui.TextColored(okColor, zh ? '真实 Dora Viewport' : 'Real Dora Viewport');
	ImGui.SameLine();
	ImGui.TextDisabled(zh ? '红=X 绿=Y，拖动左右分割条可放大' : 'Red=X Green=Y, drag splitters to resize');
}

function drawInspector(state: EditorState) {
	ImGui.TextColored(themeColor, 'Inspector');
	ImGui.Separator();
	const node = state.nodes[state.selectedId];
	if (node === undefined) {
		ImGui.TextDisabled(zh ? '没有选中节点' : 'No node selected');
		return;
	}
	ImGui.Text(iconFor(node.kind) + '  ' + node.kind);
	if (ImGui.InputText('Name', node.nameBuffer, inputTextFlags)) node.name = node.nameBuffer.text;
	let [changed, x, y] = ImGui.DragFloat2('Position', node.x, node.y, 1, -10000, 10000, '%.1f');
	if (changed) { node.x = x; node.y = y; }
	[changed, x, y] = ImGui.DragFloat2('Scale', node.scaleX, node.scaleY, 0.01, -100, 100, '%.2f');
	if (changed) { node.scaleX = x; node.scaleY = y; }
	const [angleChanged, angle] = ImGui.DragFloat('Rotation', node.rotation, 1, -360, 360, '%.1f');
	if (angleChanged) node.rotation = angle;
	const [visibleChanged, visible] = ImGui.Checkbox('Visible', node.visible);
	if (visibleChanged) node.visible = visible;
	ImGui.Separator();
	if (ImGui.InputText('Script', node.scriptBuffer, inputTextFlags)) node.script = node.scriptBuffer.text;
	if (ImGui.Button(zh ? '打开脚本' : 'Open Script')) openScriptForNode(state, node);
	if (node.kind === 'Sprite') {
		ImGui.Separator();
		if (ImGui.InputText('Texture', node.textureBuffer, inputTextFlags)) {
			node.texture = node.textureBuffer.text;
			state.previewDirty = true;
		}
	} else if (node.kind === 'Label') {
		ImGui.Separator();
		if (ImGui.InputText('Text', node.textBuffer, inputTextFlags)) node.text = node.textBuffer.text;
	} else if (node.kind === 'Camera') {
		ImGui.Separator();
		ImGui.TextDisabled(zh ? 'Camera 显示真实取景框。' : 'Camera shows a real frame in viewport.');
	}
}

function drawConsole(state: EditorState) {
	ImGui.TextColored(themeColor, 'Console');
	ImGui.SameLine();
	ImGui.TextColored(okColor, state.status);
	ImGui.Separator();
	for (const line of state.console) ImGui.TextDisabled(line);
}

function drawVerticalSplitter(id: string, height: number, onDrag: (deltaX: number) => void) {
	ImGui.PushStyleColor(StyleColor.Button, Color(0xff343a44), () => {
		ImGui.PushStyleColor(StyleColor.ButtonHovered, Color(0xff4d5968), () => {
			ImGui.PushStyleColor(StyleColor.ButtonActive, Color(0xffffcc33), () => {
				ImGui.Button('##' + id, Vec2(12, height));
			});
		});
	});
	if (ImGui.IsItemHovered()) {
		ImGui.BeginTooltip(() => ImGui.Text(zh ? '拖动调整面板宽度' : 'Drag to resize panel'));
	}
	if (ImGui.IsItemActive() && ImGui.IsMouseDragging(0)) {
		const delta = ImGui.GetMouseDragDelta(0);
		if (delta.x !== 0) {
			onDrag(delta.x);
			ImGui.ResetMouseDragDelta(0);
		}
	}
}

export function drawEditor(state: EditorState) {
	const size = App.visualSize;
	const margin = 10;
	const windowWidth = math.max(900, size.width - margin * 2);
	const windowHeight = math.max(620, size.height - margin * 2);
	ImGui.SetNextWindowPos(Vec2(margin, margin), SetCond.Always);
	ImGui.SetNextWindowSize(Vec2(windowWidth, windowHeight), SetCond.Always);
	ImGui.Begin('Dora Visual Editor', mainWindowFlags, () => {
		drawHeader(state);
		const avail = ImGui.GetContentRegionAvail();
		const bottomHeight = state.bottomHeight;
		const mainHeight = math.max(320, avail.y - bottomHeight - 10);
		const availableWidth = math.max(720, avail.x - 4);
		state.leftWidth = math.max(190, math.min(state.leftWidth, availableWidth - state.rightWidth - 420));
		state.rightWidth = math.max(250, math.min(state.rightWidth, availableWidth - state.leftWidth - 420));
		const centerWidth = math.max(360, availableWidth - state.leftWidth - state.rightWidth - 24);
		const leftTopHeight = math.floor(mainHeight * 0.58);
		const leftBottomHeight = mainHeight - leftTopHeight - 8;

		ImGui.BeginChild('LeftDock', Vec2(state.leftWidth, mainHeight), [], noScrollFlags, () => {
			ImGui.BeginChild('SceneDock', Vec2(0, leftTopHeight), [], noScrollFlags, () => drawScenePanel(state));
			ImGui.BeginChild('AssetDock', Vec2(0, leftBottomHeight), [], noScrollFlags, () => drawAssetsPanel(state));
		});
		ImGui.SameLine();
		drawVerticalSplitter('LeftSplitter', mainHeight, (deltaX) => {
			state.leftWidth = math.max(190, math.min(state.leftWidth + deltaX, availableWidth - state.rightWidth - 420));
		});
		ImGui.SameLine();
		ImGui.PushStyleColor(StyleColor.ChildBg, transparent, () => {
			ImGui.BeginChild('CenterDock', Vec2(centerWidth, mainHeight), [], noScrollFlags, () => {
				if (state.mode === 'Script') drawScriptPanel(state); else drawViewport(state);
			});
		});
		ImGui.SameLine();
		drawVerticalSplitter('RightSplitter', mainHeight, (deltaX) => {
			state.rightWidth = math.max(250, math.min(state.rightWidth - deltaX, availableWidth - state.leftWidth - 420));
		});
		ImGui.SameLine();
		ImGui.BeginChild('RightDock', Vec2(state.rightWidth, mainHeight), [], noScrollFlags, () => drawInspector(state));
		ImGui.BeginChild('BottomConsoleDock', Vec2(0, bottomHeight), [], noScrollFlags, () => drawConsole(state));
	});
}

export function drawRuntimeError(message: string) {
	const size = App.visualSize;
	ImGui.SetNextWindowPos(Vec2(10, 10), SetCond.Always);
	ImGui.SetNextWindowSize(Vec2(math.max(320, size.width - 20), math.max(220, size.height - 20)), SetCond.Always);
	ImGui.Begin('Dora Visual Editor Error', mainWindowFlags, () => {
		ImGui.TextColored(warnColor, 'SceneImGuiEditor runtime error');
		ImGui.Separator();
		ImGui.TextWrapped(message || 'unknown error');
	});
}
