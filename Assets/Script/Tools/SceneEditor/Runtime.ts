import { App, Color, Director, DrawNode, Label, Line, Node, Sprite, Vec2 } from 'Dora';
import { EditorState, SceneNodeData } from 'Script/Tools/SceneEditor/Types';
import { greenAxisColor, gridMajorColor, gridMinorColor, redAxisColor } from 'Script/Tools/SceneEditor/Theme';

function worldPointFromScreen(screenX: number, screenY: number): [number, number] {
	const size = App.visualSize;
	return [screenX - size.width / 2, size.height / 2 - screenY];
}

function makeLine(points: Vec2.Type[], color: Color.Type) {
	return Line(points, color);
}

function makeThickLine(a: Vec2.Type, b: Vec2.Type, color: Color.Type, horizontal: boolean) {
	const node = Node();
	for (let offset = -2; offset <= 2; offset++) {
		if (horizontal) {
			node.addChild(makeLine([Vec2(a.x, a.y + offset), Vec2(b.x, b.y + offset)], color));
		} else {
			node.addChild(makeLine([Vec2(a.x + offset, a.y), Vec2(b.x + offset, b.y)], color));
		}
	}
	return node;
}

function makeRectLine(width: number, height: number, color: Color.Type) {
	const hw = width / 2;
	const hh = height / 2;
	return makeLine([
		Vec2(-hw, -hh),
		Vec2(hw, -hh),
		Vec2(hw, hh),
		Vec2(-hw, hh),
		Vec2(-hw, -hh),
	], color);
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
	], Color(0xff0b1118), 6, Color(0xffffcc33));
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
			major.drawSegment(Vec2(x, -hh), Vec2(x, hh), 1.2, gridMajorColor);
		} else {
			minor.drawSegment(Vec2(x, -hh), Vec2(x, hh), 0.55, gridMinorColor);
		}
		x += step;
		i += 1;
	}
	i = 0;
	let y = -math.floor(hh / step) * step;
	while (y <= hh) {
		if (i % 5 === 0) {
			major.drawSegment(Vec2(-hw, y), Vec2(hw, y), 1.2, gridMajorColor);
		} else {
			minor.drawSegment(Vec2(-hw, y), Vec2(hw, y), 0.55, gridMinorColor);
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
	xAxis.drawSegment(Vec2(-hw, 0), Vec2(hw, 0), 3.5, redAxisColor);
	const yAxis = DrawNode();
	yAxis.drawSegment(Vec2(0, -hh), Vec2(0, hh), 3.5, greenAxisColor);
	axis.addChild(xAxis);
	axis.addChild(yAxis);
	return axis;
}

function makeSpritePlaceholder() {
	const node = Node();
	const frame = makeRectLine(96, 64, Color(0xff4fa3ff));
	frame.addChild(makeLine([Vec2(-48, -32), Vec2(48, 32), Vec2(-48, 32), Vec2(48, -32)], Color(0xff4fa3ff)));
	node.addChild(frame);
	return node;
}

function makeCameraShape() {
	const node = Node();
	node.addChild(makeRectLine(180, 100, Color(0xffffcc33)));
	node.addChild(makeLine([Vec2(-90, 0), Vec2(90, 0), Vec2(0, -50), Vec2(0, 50)], Color(0xffffcc33)));
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
	} else if (item.kind === 'Label') {
		const label = Label('sarasa-mono-sc-regular', 32);
		if (label !== undefined) {
			label.text = item.text || 'Label';
			state.runtimeLabels[item.id] = label;
			wrapper.addChild(label);
		} else {
			wrapper.addChild(makeRectLine(120, 38, Color(0xffdcdcdc)));
		}
	} else if (item.kind === 'Camera') {
		wrapper.addChild(makeCameraShape());
	} else {
		wrapper.addChild(makeThickLine(Vec2(-14, 0), Vec2(14, 0), Color(0xffffffff), true));
		wrapper.addChild(makeThickLine(Vec2(0, -14), Vec2(0, 14), Color(0xffffffff), false));
	}
	return wrapper;
}

export function rebuildPreviewRuntime(state: EditorState) {
	if (state.previewRoot === undefined) {
		state.previewRoot = Node();
		state.previewRoot.tag = '__DoraImGuiEditorViewport__';
		Director.entry.addChild(state.previewRoot);
	}
	state.previewRoot.removeAllChildren(true);
	state.runtimeNodes = {};
	state.runtimeLabels = {};

	const renderScale = App.devicePixelRatio || 1;
	const width = math.max(160, state.preview.width * renderScale);
	const height = math.max(120, state.preview.height * renderScale);
	state.previewRoot.addChild(makeCanvasBackground(width, height));
	if (state.showGrid) {
		state.previewRoot.addChild(makeGridLine(width, height));
	}
	state.previewRoot.addChild(makeAxisLine(width, height));
	for (let offset = 0; offset <= 8; offset += 2) {
		state.previewRoot.addChild(makeRectLine(width + offset, height + offset, Color(0xffffcc33)));
	}

	const content = Node();
	const scale = math.max(0.25, state.zoom / 100);
	content.scaleX = scale;
	content.scaleY = scale;
	state.previewContent = content;
	state.previewRoot.addChild(content);
	state.runtimeNodes.root = content;

	for (const id of state.order) {
		const item = state.nodes[id];
		if (item !== undefined && id !== 'root') {
			const runtime = createRuntimeVisual(state, item);
			state.runtimeNodes[id] = runtime;
			const parent = state.runtimeNodes[item.parentId || 'root'] || content;
			parent.addChild(runtime);
		}
	}
	state.previewDirty = false;
}

export function updatePreviewRuntime(state: EditorState) {
	if (state.previewDirty || state.previewRoot === undefined) {
		rebuildPreviewRuntime(state);
	}
	const p = state.preview;
	const [cx, cy] = worldPointFromScreen(p.x + p.width / 2, p.y + p.height / 2);
	const previewRoot = state.previewRoot;
	if (previewRoot === undefined) return;
	previewRoot.x = cx;
	previewRoot.y = cy;
	if (state.previewContent !== undefined) {
		const scale = math.max(0.25, state.zoom / 100);
		state.previewContent.scaleX = scale;
		state.previewContent.scaleY = scale;
	}
	for (const id of state.order) {
		const item = state.nodes[id];
		const runtime = state.runtimeNodes[id];
		if (item !== undefined && runtime !== undefined) {
			runtime.x = item.x;
			runtime.y = item.y;
			runtime.scaleX = item.scaleX;
			runtime.scaleY = item.scaleY;
			runtime.angle = item.rotation;
			runtime.visible = item.visible;
			const label = state.runtimeLabels[id] as Label.Type | undefined;
			if (label !== undefined) label.text = item.text || 'Label';
		}
	}
}
