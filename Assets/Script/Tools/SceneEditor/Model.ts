import { App, Buffer, Content, Path } from 'Dora';
import { EditorState, SceneNodeData, SceneNodeKind } from 'Script/Tools/SceneEditor/Types';

const [localeMatch] = string.match(App.locale, '^zh');
export const zh = localeMatch !== undefined;

export function makeBuffer(text: string, size: number) {
	const buffer = Buffer(size);
	buffer.text = text;
	return buffer;
}

export function createEditorState(): EditorState {
	return {
		nextId: 0,
		selectedId: 'root',
		mode: '2D',
		zoom: 100,
		showGrid: true,
		leftWidth: 280,
		rightWidth: 340,
		bottomHeight: 132,
		status: zh ? 'Dora Visual Editor 已加载' : 'Dora Visual Editor loaded',
		console: [zh ? '真实 Dora Viewport 已启用。' : 'Real Dora viewport enabled.'],
		nodes: {},
		order: [],
		preview: { x: 0, y: 0, width: 640, height: 360 },
		previewDirty: true,
		runtimeNodes: {},
		runtimeLabels: {},
		assetImportBuffer: makeBuffer('Image/new.png', 256),
		scriptPathBuffer: makeBuffer('', 256),
		scriptContentBuffer: makeBuffer('', 8192),
		selectedAsset: '',
		assets: ['Image/player.png', 'Image/enemy.png', 'Audio/bgm.ogg', 'Script/player.lua'],
	};
}

export function pushConsole(state: EditorState, message: string) {
	state.console.push(message);
	if (state.console.length > 7) {
		table.remove(state.console, 1);
	}
}

export function iconFor(kind: SceneNodeKind) {
	if (kind === 'Sprite') return '▣';
	if (kind === 'Label') return 'T';
	if (kind === 'Camera') return '◉';
	return '○';
}

export function lowerExt(path: string) {
	const ext = Path.getExt(path || '') || '';
	return string.lower(ext);
}

export function assetFolderForExt(ext: string) {
	if (ext === 'png' || ext === 'jpg' || ext === 'jpeg' || ext === 'ktx' || ext === 'pvr' || ext === 'clip') return 'Image';
	if (ext === 'lua' || ext === 'ts' || ext === 'tsx' || ext === 'yue') return 'Script';
	if (ext === 'wav' || ext === 'mp3' || ext === 'ogg') return 'Audio';
	if (ext === 'anim' || ext === 'model' || ext === 'skel') return 'Animation';
	return 'Resource';
}

export function isTextureAsset(path: string) {
	const ext = lowerExt(path);
	return ext === 'png' || ext === 'jpg' || ext === 'jpeg' || ext === 'ktx' || ext === 'pvr' || ext === 'clip';
}

export function isScriptAsset(path: string) {
	const ext = lowerExt(path);
	return ext === 'lua' || ext === 'ts' || ext === 'tsx' || ext === 'yue';
}

function hasAsset(state: EditorState, asset: string) {
	for (const item of state.assets) {
		if (item === asset) return true;
	}
	return false;
}

export function addAssetPath(state: EditorState, path: string) {
	if (path === '') return;
	const ext = lowerExt(path);
	const folder = assetFolderForExt(ext);
	const name = Path.getName(path);
	let asset = Path(folder, name);
	const target = Path(Content.writablePath, asset);
	Content.mkdir(Path(Content.writablePath, folder));
	if (Content.exist(path) && path !== target) {
		if (!Content.copy(path, target)) {
			asset = path;
		}
	}
	if (!hasAsset(state, asset)) {
		state.assets.push(asset);
	}
	state.selectedAsset = asset;
	state.status = (zh ? '已加入资源：' : 'Asset added: ') + asset;
	pushConsole(state, state.status);
}

export function importFileDialog(state: EditorState) {
	App.openFileDialog(false, (path) => addAssetPath(state, path));
}

export function importFolderDialog(state: EditorState) {
	App.openFileDialog(true, (path) => {
		if (path === '') return;
		for (const file of Content.getFiles(path)) {
			addAssetPath(state, Path(path, file));
		}
	});
}

function newNodeId(state: EditorState, kind: SceneNodeKind) {
	state.nextId += 1;
	return string.lower(kind) + '-' + tostring(state.nextId);
}

export function addNode(state: EditorState, kind: SceneNodeKind, name: string, parentId?: string) {
	const resolvedParentId = parentId || 'root';
	const id = kind === 'Root' ? 'root' : newNodeId(state, kind);
	const index = state.nextId;
	const node: SceneNodeData = {
		id,
		kind,
		name,
		parentId: resolvedParentId,
		children: [],
		x: (kind === 'Root' || kind === 'Camera') ? 0 : ((index % 5) - 2) * 70,
		y: (kind === 'Root' || kind === 'Camera') ? 0 : (math.floor(index / 5) % 4) * 55,
		scaleX: 1,
		scaleY: 1,
		rotation: 0,
		visible: true,
		texture: '',
		text: kind === 'Label' ? 'Label' : '',
		script: '',
		nameBuffer: makeBuffer(name, 128),
		textureBuffer: makeBuffer('', 256),
		textBuffer: makeBuffer(kind === 'Label' ? 'Label' : '', 256),
		scriptBuffer: makeBuffer('', 256),
	};
	state.nodes[id] = node;
	state.order.push(id);
	const parent = state.nodes[resolvedParentId];
	if (id !== 'root' && parent !== undefined) {
		parent.children.push(id);
	}
	return node;
}

function removeFromOrder(state: EditorState, id: string) {
	for (let i = state.order.length; i >= 1; i--) {
		if (state.order[i - 1] === id) {
			table.remove(state.order, i);
		}
	}
}

export function deleteNode(state: EditorState, id: string) {
	if (id === 'root') {
		state.status = zh ? '根节点不能删除' : 'Root cannot be deleted';
		return;
	}
	const node = state.nodes[id];
	if (node === undefined) return;
	for (let i = node.children.length; i >= 1; i--) {
		deleteNode(state, node.children[i - 1]);
	}
	const parent = node.parentId !== undefined ? state.nodes[node.parentId] : undefined;
	if (parent !== undefined) {
		for (let i = parent.children.length; i >= 1; i--) {
			if (parent.children[i - 1] === id) table.remove(parent.children, i);
		}
	}
	delete state.nodes[id];
	removeFromOrder(state, id);
	state.selectedId = 'root';
	state.previewDirty = true;
	state.status = zh ? '已删除节点' : 'Node deleted';
	pushConsole(state, state.status);
}

export function addChildNode(state: EditorState, kind: SceneNodeKind) {
	let parentId = state.selectedId || 'root';
	if (state.nodes[parentId] === undefined) parentId = 'root';
	const node = addNode(state, kind, kind + tostring(state.nextId + 1), parentId);
	state.selectedId = node.id;
	state.previewDirty = true;
	state.status = (zh ? '已添加 ' : 'Added ') + node.name;
	pushConsole(state, state.status);
}
