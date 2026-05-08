import { App, ClipNode, Color, Director, DrawNode, Label, Line, Node, Sprite, Vec2 } from 'Dora';
import { EditorState, SceneNodeData } from 'Script/Tools/SceneEditor/Types';
import { greenAxisColor, gridMajorColor, gridMinorColor, helperColor, redAxisColor, selectionColor, viewportBgColor, viewportFrameColor, viewportGameFrameColor } from 'Script/Tools/SceneEditor/Theme';

function worldPointFromScreen(screenX: number, screenY: number): [number, number] {
	const size = App.visualSize;
	return [screenX - size.width / 2, size.height / 2 - screenY];
}

function makeLine(points: Vec2.Type[], color: Color.Type) {
	return Line(points, color);
}

function makeThickLine(a: Vec2.Type, b: Vec2.Type, color: Color.Type, horizontal: boolean) {
	const node = Node();
	for (let offset = -1; offset <= 1; offset++) {
		if (horizontal) {
			node.addChild(makeLine([Vec2(a.x, a.y + offset), Vec2(b.x, b.y + offset)], color));
		} else {
			node.addChild(makeLine([Vec2(a.x + offset, a.y), Vec2(b.x + offset, b.y)], color));
		}
	}
	return node;
}

function makeSegmentRect(width: number, height: number, color: Color.Type, thickness: number) {
	const hw = width / 2;
	const hh = height / 2;
	const rect = DrawNode();
	rect.drawSegment(Vec2(-hw, -hh), Vec2(hw, -hh), thickness, color);
	rect.drawSegment(Vec2(hw, -hh), Vec2(hw, hh), thickness, color);
	rect.drawSegment(Vec2(hw, hh), Vec2(-hw, hh), thickness, color);
	rect.drawSegment(Vec2(-hw, hh), Vec2(-hw, -hh), thickness, color);
	return rect;
}

function addCornerHandles(node: Node.Type, width: number, height: number, color: Color.Type) {
	const hw = width / 2;
	const hh = height / 2;
	const size = 8;
	const points = [
		Vec2(-hw, -hh),
		Vec2(hw, -hh),
		Vec2(hw, hh),
		Vec2(-hw, hh),
	];
	for (const point of points) {
		const handle = DrawNode();
		handle.drawPolygon([
			Vec2(point.x - size / 2, point.y - size / 2),
			Vec2(point.x + size / 2, point.y - size / 2),
			Vec2(point.x + size / 2, point.y + size / 2),
			Vec2(point.x - size / 2, point.y + size / 2),
		], color, 0, Color());
		node.addChild(handle);
	}
}

function selectionSize(item: SceneNodeData): [number, number] {
	if (item.kind === 'Camera') return [320, 180];
	if (item.kind === 'Sprite') return [128, 96];
	if (item.kind === 'Label') return [180, 56];
	return [72, 72];
}

function addSelectionOverlay(state: EditorState, item: SceneNodeData, node: Node.Type) {
	const [width, height] = selectionSize(item);
	const color = item.id === state.selectedId ? selectionColor : helperColor;
	node.addChild(makeSegmentRect(width, height, color, item.id === state.selectedId ? 1.6 : 0.8));
	if (item.id === state.selectedId) addCornerHandles(node, width, height, color);
}


function makeClipStencil(width: number, height: number) {
	const hw = width / 2;
	const hh = height / 2;
	const stencil = DrawNode();
	stencil.drawPolygon([
		Vec2(-hw, -hh),
		Vec2(hw, -hh),
		Vec2(hw, hh),
		Vec2(-hw, hh),
	], Color(0xffffffff), 0, Color());
	return stencil;
}

function makeCanvasBackground(width: number, height: number) {
	const hw = width / 2;
	const hh = height / 2;
	const bg = DrawNode();
	bg.drawPolygon([
		Vec2(-hw, -hh),
		Vec2(hw, -hh),
		Vec2(hw, hh),
		Vec2(-hw, hh),
	], viewportBgColor, 1.0, viewportFrameColor);
	return bg;
}

function makeGridLine(width: number, height: number) {
	const grid = Node();
	const hw = width / 2;
	const hh = height / 2;
	const step = 32;
	const minor = DrawNode();
	const major = DrawNode();
	let i = 0;
	let x = -math.floor(hw / step) * step;
	while (x <= hw) {
		if (i % 5 === 0) {
			major.drawSegment(Vec2(x, -hh), Vec2(x, hh), 0.55, gridMajorColor);
		} else {
			minor.drawSegment(Vec2(x, -hh), Vec2(x, hh), 0.25, gridMinorColor);
		}
		x += step;
		i += 1;
	}
	i = 0;
	let y = -math.floor(hh / step) * step;
	while (y <= hh) {
		if (i % 5 === 0) {
			major.drawSegment(Vec2(-hw, y), Vec2(hw, y), 0.55, gridMajorColor);
		} else {
			minor.drawSegment(Vec2(-hw, y), Vec2(hw, y), 0.25, gridMinorColor);
		}
		y += step;
		i += 1;
	}
	grid.addChild(minor);
	grid.addChild(major);
	return grid;
}

function makeAxisLine(width: number, height: number) {
	const hw = width / 2;
	const hh = height / 2;
	const axis = Node();
	const xAxis = DrawNode();
	xAxis.drawSegment(Vec2(-hw, 0), Vec2(hw, 0), 1.2, redAxisColor);
	const yAxis = DrawNode();
	yAxis.drawSegment(Vec2(0, -hh), Vec2(0, hh), 1.2, greenAxisColor);
	axis.addChild(xAxis);
	axis.addChild(yAxis);
	return axis;
}

function makeSpritePlaceholder() {
	const node = Node();
	node.addChild(makeSegmentRect(128, 96, helperColor, 1.1));
	const cross = DrawNode();
	cross.drawSegment(Vec2(-64, -48), Vec2(64, 48), 0.6, helperColor);
	cross.drawSegment(Vec2(-64, 48), Vec2(64, -48), 0.6, helperColor);
	node.addChild(cross);
	return node;
}

function makeCameraShape() {
	const node = Node();
	node.addChild(makeSegmentRect(320, 180, viewportGameFrameColor, 1.1));
	return node;
}

function createRuntimeVisual(state: EditorState, item: SceneNodeData) {
	const wrapper = Node();
	if (item.kind === 'Sprite') {
		let visual: Sprite.Type | undefined = undefined;
		if (item.texture !== '') {
			visual = Sprite(item.texture);
		}
		wrapper.addChild(visual !== undefined ? visual : makeSpritePlaceholder());
		addSelectionOverlay(state, item, wrapper);
	} else if (item.kind === 'Label') {
		const label = Label('sarasa-mono-sc-regular', 32);
		if (label !== undefined) {
			label.text = item.text || 'Label';
			state.runtimeLabels[item.id] = label;
			wrapper.addChild(label);
		} else {
			wrapper.addChild(makeSegmentRect(180, 56, Color(0xffffffff), 3));
		}
		addSelectionOverlay(state, item, wrapper);
	} else if (item.kind === 'Camera') {
		wrapper.addChild(makeCameraShape());
		addSelectionOverlay(state, item, wrapper);
	} else {
		wrapper.addChild(makeThickLine(Vec2(-20, 0), Vec2(20, 0), helperColor, true));
		wrapper.addChild(makeThickLine(Vec2(0, -20), Vec2(0, 20), helperColor, false));
		addSelectionOverlay(state, item, wrapper);
	}
	return wrapper;
}

const runtimeVisualKeys: Record<string, string> = {};
const runtimeParentKeys: Record<string, string> = {};
let previewLayoutKey = '';

function clearRecord<T>(record: Record<string, T>) {
	for (const key in record) {
		delete record[key];
	}
}

function resetPreviewCaches(state: EditorState) {
	previewLayoutKey = '';
	clearRecord(runtimeVisualKeys);
	clearRecord(runtimeParentKeys);
	state.runtimeNodes = {};
	state.runtimeLabels = {};
}

function runtimeVisualKey(state: EditorState, item: SceneNodeData) {
	return [
		item.kind,
		item.texture || '',
		item.text || '',
		item.name || '',
		item.id === state.selectedId ? 'selected' : 'normal',
	].join('|');
}

function ensurePreviewRuntime(state: EditorState) {
	if (state.previewRoot === undefined) {
		state.previewRoot = Node();
		state.previewRoot.tag = '__DoraImGuiEditorViewport__';
		Director.entry.addChild(state.previewRoot);
	}
	if (state.previewWorld === undefined) {
		state.previewWorld = Node();
	}
	if (state.previewContent === undefined) {
		state.previewContent = Node();
	}
	state.runtimeNodes.root = state.previewContent;
}

function updatePreviewLayout(state: EditorState) {
	const renderScale = App.devicePixelRatio || 1;
	const width = math.max(160, state.preview.width * renderScale);
	const height = math.max(120, state.preview.height * renderScale);
	const layoutKey = [
		math.floor(width),
		math.floor(height),
		renderScale,
		state.showGrid ? 'grid' : 'no-grid',
	].join('|');
	if (layoutKey === previewLayoutKey) return;
	previewLayoutKey = layoutKey;

	const root = state.previewRoot;
	const world = state.previewWorld;
	const content = state.previewContent;
	if (root === undefined || world === undefined || content === undefined) return;

	world.removeFromParent(false);
	content.removeFromParent(false);
	root.removeAllChildren(true);
	world.removeAllChildren(true);

	const clip = ClipNode(makeClipStencil(width, height));
	clip.alphaThreshold = 0.01;
	root.addChild(clip);
	clip.addChild(makeCanvasBackground(width, height));

	clip.addChild(world);
	const worldWidth = 20000;
	const worldHeight = 20000;
	if (state.showGrid) {
		world.addChild(makeGridLine(worldWidth, worldHeight));
	}
	world.addChild(makeAxisLine(worldWidth, worldHeight));
	world.addChild(content);
	clip.addChild(makeSegmentRect(width, height, viewportGameFrameColor, 0.9));
}

function applyRuntimeTransform(state: EditorState, item: SceneNodeData, runtime: Node.Type) {
	runtime.x = item.x;
	runtime.y = item.y;
	runtime.scaleX = item.scaleX;
	runtime.scaleY = item.scaleY;
	runtime.angle = item.rotation;
	runtime.visible = item.visible;
	runtime.tag = item.name;
	const label = state.runtimeLabels[item.id] as Label.Type | undefined;
	if (label !== undefined) label.text = item.text || 'Label';
}

function ensureRuntimeVisual(state: EditorState, item: SceneNodeData) {
	const key = runtimeVisualKey(state, item);
	let runtime = state.runtimeNodes[item.id];
	if (runtime === undefined || runtimeVisualKeys[item.id] !== key) {
		if (runtime !== undefined) {
			// Do not cleanup here: this wrapper may currently own child scene nodes.
			// They are re-parented in syncPreviewNodes after the new wrapper is created.
			runtime.removeFromParent(false);
		}
		delete state.runtimeLabels[item.id];
		runtime = createRuntimeVisual(state, item);
		state.runtimeNodes[item.id] = runtime;
		runtimeVisualKeys[item.id] = key;
		clearRecord(runtimeParentKeys);
	}
	return runtime;
}

function syncPreviewNodes(state: EditorState) {
	const content = state.previewContent;
	if (content === undefined) return;
	const alive: Record<string, boolean> = {};

	for (const id of state.order) {
		if (id === 'root') continue;
		const item = state.nodes[id];
		if (item === undefined) continue;
		alive[id] = true;
		const runtime = ensureRuntimeVisual(state, item);
		applyRuntimeTransform(state, item, runtime);
	}

	for (const id of state.order) {
		if (id === 'root') continue;
		const item = state.nodes[id];
		const runtime = state.runtimeNodes[id];
		if (item === undefined || runtime === undefined) continue;
		const parentId = item.parentId || 'root';
		const parent = state.runtimeNodes[parentId] || content;
		if (runtimeParentKeys[id] !== parentId) {
			runtime.removeFromParent(false);
			parent.addChild(runtime);
			runtimeParentKeys[id] = parentId;
		}
	}

	for (const id in state.runtimeNodes) {
		if (id === 'root') continue;
		if (alive[id]) continue;
		const runtime = state.runtimeNodes[id];
		if (runtime !== undefined) runtime.removeFromParent(true);
		delete state.runtimeNodes[id];
		delete state.runtimeLabels[id];
		delete runtimeVisualKeys[id];
		delete runtimeParentKeys[id];
	}
}

export function rebuildPreviewRuntime(state: EditorState) {
	if (state.previewRoot !== undefined) {
		state.previewRoot.removeAllChildren(true);
	}
	state.previewWorld = undefined;
	state.previewContent = undefined;
	resetPreviewCaches(state);
	state.previewDirty = true;
	updatePreviewRuntime(state);
}

export function updatePreviewRuntime(state: EditorState) {
	ensurePreviewRuntime(state);
	updatePreviewLayout(state);
	const p = state.preview;
	const [cx, cy] = worldPointFromScreen(p.x + p.width / 2, p.y + p.height / 2);
	const previewRoot = state.previewRoot;
	if (previewRoot === undefined) return;
	previewRoot.x = cx;
	previewRoot.y = cy;
	if (state.previewWorld !== undefined) {
		const scale = math.max(0.25, state.zoom / 100);
		state.previewWorld.x = state.viewportPanX;
		state.previewWorld.y = state.viewportPanY;
		state.previewWorld.scaleX = scale;
		state.previewWorld.scaleY = scale;
	}
	syncPreviewNodes(state);
	state.previewDirty = false;
}
