import type {ActionClipDocument, ActionClipRect} from "./ActionClip";
import type {ActionDocument, ActionNode} from "./ActionDocument";
import type {ActionViewport} from "./ActionEditorState";
import {parseActionFrameSpec, sampleActionKeyTrack} from "./ActionPlayback";

export type ActionRenderRect = {
	nodeId: string;
	name: string;
	clip: string;
	sourceX: number;
	sourceY: number;
	sourceWidth: number;
	sourceHeight: number;
	x: number;
	y: number;
	width: number;
	height: number;
	corners: [
		{x: number; y: number},
		{x: number; y: number},
		{x: number; y: number},
		{x: number; y: number},
	];
	anchor: {x: number; y: number};
	visible: boolean;
	opacity: number;
	missingClip: boolean;
};

export type ActionViewportRect = {
	x: number;
	y: number;
	width: number;
	height: number;
};

const fallbackRect = (node: ActionNode, document: ActionDocument): ActionClipRect => {
	const width = node.id === document.root.id && document.size.width > 0 ? document.size.width : (node.clip === "" ? 0 : 80);
	const height = node.id === document.root.id && document.size.height > 0 ? document.size.height : (node.clip === "" ? 0 : 80);
	return {name: node.clip, x: 0, y: 0, width, height};
};

type ActionRenderMatrix = {
	a: number;
	b: number;
	c: number;
	d: number;
	tx: number;
	ty: number;
};

const identityMatrix = (): ActionRenderMatrix => ({a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0});

const multiplyMatrix = (left: ActionRenderMatrix, right: ActionRenderMatrix): ActionRenderMatrix => ({
	a: left.a * right.a + left.c * right.b,
	b: left.b * right.a + left.d * right.b,
	c: left.a * right.c + left.c * right.d,
	d: left.b * right.c + left.d * right.d,
	tx: left.a * right.tx + left.c * right.ty + left.tx,
	ty: left.b * right.tx + left.d * right.ty + left.ty,
});

const transformPoint = (matrix: ActionRenderMatrix, point: {x: number; y: number}) => ({
	x: matrix.a * point.x + matrix.c * point.y + matrix.tx,
	y: matrix.b * point.x + matrix.d * point.y + matrix.ty,
});

const transformMatrix = (transform: {
	position: {x: number; y: number};
	scale: {x: number; y: number};
	skew?: {x: number; y: number};
	rotation: number;
	anchor?: {x: number; y: number};
	size?: {width: number; height: number};
}): ActionRenderMatrix => {
	const scaleX = transform.scale.x === 0 ? 1 : transform.scale.x;
	const scaleY = transform.scale.y === 0 ? 1 : transform.scale.y;
	const radians = -transform.rotation * Math.PI / 180;
	const skewX = (transform.skew?.x ?? 0) * Math.PI / 180;
	const skewY = (transform.skew?.y ?? 0) * Math.PI / 180;
	const tanX = Math.tan(skewX);
	const tanY = Math.tan(skewY);
	const cos = Math.cos(radians);
	const sin = Math.sin(radians);
	const a = (cos + tanX * sin) * scaleX;
	const b = (tanY * cos + sin) * scaleX;
	const c = (cos * tanX - sin) * scaleY;
	const d = (cos - tanY * sin) * scaleY;
	const anchorPoint = {
		x: (transform.anchor?.x ?? 0) * (transform.size?.width ?? 0),
		y: (transform.anchor?.y ?? 0) * (transform.size?.height ?? 0),
	};
	return {
		a,
		b,
		c,
		d,
		tx: transform.position.x - a * anchorPoint.x - c * anchorPoint.y,
		ty: transform.position.y - b * anchorPoint.x - d * anchorPoint.y,
	};
};

const clampOpacity = (opacity: number) => Math.max(0, Math.min(1, opacity));

const sampleActionFrameRect = (
	track: {file: string; delay: number},
	clip: ActionClipDocument | null,
	time: number,
): ActionClipRect | null => {
	const spec = parseActionFrameSpec(track.file);
	if (!spec || !clip) return null;
	const base = clip.rects[spec.clipName];
	if (!base) return null;
	const frameCount = Math.max(1, Math.round(spec.frameCount));
	const localTime = Math.max(0, time - Math.max(0, track.delay));
	const rawFrame = spec.duration <= 0 ? 0 : Math.floor((localTime / spec.duration) * frameCount);
	const frameIndex = Math.max(0, Math.min(frameCount - 1, rawFrame));
	const columns = Math.max(1, Math.floor(base.width / spec.frameWidth));
	const column = frameIndex % columns;
	const row = Math.floor(frameIndex / columns);
	const sourceX = base.x + column * spec.frameWidth;
	const sourceY = base.y + row * spec.frameHeight;
	const maxWidth = Math.max(0, base.x + base.width - sourceX);
	const maxHeight = Math.max(0, base.y + base.height - sourceY);
	return {
		name: spec.clipName,
		x: sourceX,
		y: sourceY,
		width: Math.min(spec.frameWidth, maxWidth),
		height: Math.min(spec.frameHeight, maxHeight),
	};
};

const findParentMatrix = (
	document: ActionDocument,
	clip: ActionClipDocument | null,
	node: ActionNode,
	targetNodeId: string,
	parentMatrix: ActionRenderMatrix,
): ActionRenderMatrix | null => {
	if (node.id === targetNodeId) return parentMatrix;
	const rect = node.clip ? clip?.rects[node.clip] : undefined;
	const base = rect ?? fallbackRect(node, document);
	const nodeMatrix = multiplyMatrix(parentMatrix, transformMatrix({...node.transform, size: base}));
	for (const child of node.children) {
		const result = findParentMatrix(document, clip, child, targetNodeId, nodeMatrix);
		if (result) return result;
	}
	return null;
};

export const screenDeltaToNodeLocalDelta = (
	document: ActionDocument,
	clip: ActionClipDocument | null,
	nodeId: string,
	delta: {x: number; y: number},
	viewport: ActionViewport,
) => {
	const worldDelta = {
		x: delta.x / viewport.zoom,
		y: -delta.y / viewport.zoom,
	};
	const parentMatrix = findParentMatrix(document, clip, document.root, nodeId, identityMatrix()) ?? identityMatrix();
	const det = parentMatrix.a * parentMatrix.d - parentMatrix.b * parentMatrix.c;
	if (Math.abs(det) < 0.000001) return worldDelta;
	return {
		x: (parentMatrix.d * worldDelta.x - parentMatrix.c * worldDelta.y) / det,
		y: (-parentMatrix.b * worldDelta.x + parentMatrix.a * worldDelta.y) / det,
	};
};

const collectRenderRects = (
	document: ActionDocument,
	clip: ActionClipDocument | null,
	node: ActionNode,
	parentMatrix: ActionRenderMatrix,
	look: string | null,
	animation: string | null,
	time: number,
	parentOpacity: number,
	parentHiddenByLook: boolean,
	parentHiddenByAnimation: boolean,
	out: ActionRenderRect[],
) => {
	const hiddenByLook = parentHiddenByLook || (look !== null && node.hiddenInLooks.indexOf(look) >= 0);
	if (node.id === document.root.id) {
		for (const child of node.children) {
			collectRenderRects(document, clip, child, parentMatrix, look, animation, time, parentOpacity, hiddenByLook, parentHiddenByAnimation, out);
		}
		return;
	}
	const track = animation ? node.tracks[animation] : undefined;
	const sampled = track?.type === "key" ? sampleActionKeyTrack(track, time) : null;
	const frameRect = track?.type === "frame" ? sampleActionFrameRect(track, clip, time) : null;
	const rect = frameRect ?? (node.clip ? clip?.rects[node.clip] : undefined);
	const base = rect ?? fallbackRect(node, document);
	const transform = sampled ?? node.transform;
	const nodeMatrix = multiplyMatrix(parentMatrix, transformMatrix({...transform, anchor: node.transform.anchor, size: base}));
	const opacity = parentOpacity * clampOpacity(transform.opacity ?? node.transform.opacity);
	const hiddenByAnimation = parentHiddenByAnimation || sampled?.visible === false;
	const visible = !hiddenByLook && !hiddenByAnimation;
	if (node.clip !== "" || frameRect !== null) {
		const left = 0;
		const right = base.width;
		const bottom = 0;
		const top = base.height;
		const corners: ActionRenderRect["corners"] = [
			transformPoint(nodeMatrix, {x: left, y: top}),
			transformPoint(nodeMatrix, {x: right, y: top}),
			transformPoint(nodeMatrix, {x: right, y: bottom}),
			transformPoint(nodeMatrix, {x: left, y: bottom}),
		];
		const anchor = transformPoint(nodeMatrix, {
			x: node.transform.anchor.x * base.width,
			y: node.transform.anchor.y * base.height,
		});
		const minX = Math.min(corners[0].x, corners[1].x, corners[2].x, corners[3].x);
		const maxX = Math.max(corners[0].x, corners[1].x, corners[2].x, corners[3].x);
		const minY = Math.min(corners[0].y, corners[1].y, corners[2].y, corners[3].y);
		const maxY = Math.max(corners[0].y, corners[1].y, corners[2].y, corners[3].y);
		out.push({
			nodeId: node.id,
			name: node.name,
			clip: frameRect?.name ?? node.clip,
			sourceX: base.x,
			sourceY: base.y,
			sourceWidth: base.width,
			sourceHeight: base.height,
			x: minX,
			y: minY,
			width: Math.max(1, maxX - minX),
			height: Math.max(1, maxY - minY),
			corners,
			anchor,
			visible,
			opacity,
			missingClip: rect === undefined || base.width <= 0 || base.height <= 0,
		});
	}
	for (const child of node.children) {
		collectRenderRects(document, clip, child, nodeMatrix, look, animation, time, opacity, hiddenByLook, hiddenByAnimation, out);
	}
};

export const buildActionRenderRects = (
	document: ActionDocument,
	clip: ActionClipDocument | null,
	look: string | null,
	animation: string | null = null,
	time = 0,
) => {
	const rects: ActionRenderRect[] = [];
	collectRenderRects(document, clip, document.root, identityMatrix(), look, animation, time, 1, false, false, rects);
	return rects;
};

export const modelToScreen = (
	model: {x: number; y: number},
	viewport: ActionViewport,
	area: {x: number; y: number; width: number; height: number},
) => ({
	x: area.x + area.width / 2 + viewport.pan.x + model.x * viewport.zoom,
	y: area.y + area.height / 2 + viewport.pan.y - model.y * viewport.zoom,
});

export const screenToModel = (
	screen: {x: number; y: number},
	viewport: ActionViewport,
	area: {x: number; y: number; width: number; height: number},
) => ({
	x: (screen.x - area.x - area.width / 2 - viewport.pan.x) / viewport.zoom,
	y: -(screen.y - area.y - area.height / 2 - viewport.pan.y) / viewport.zoom,
});

export const renderRectToViewport = (
	rect: ActionRenderRect,
	viewport: ActionViewport,
	area: {x: number; y: number; width: number; height: number},
): ActionViewportRect => {
	const topLeft = modelToScreen({x: rect.x, y: rect.y + rect.height}, viewport, area);
	return {
		x: topLeft.x,
		y: topLeft.y,
		width: rect.width * viewport.zoom,
		height: rect.height * viewport.zoom,
	};
};

export const renderRectCornersToViewport = (
	rect: ActionRenderRect,
	viewport: ActionViewport,
	area: {x: number; y: number; width: number; height: number},
) => rect.corners.map((corner) => modelToScreen(corner, viewport, area)) as ActionRenderRect["corners"];

const pointInQuad = (point: {x: number; y: number}, corners: ActionRenderRect["corners"]) => {
	const area = Math.abs(corners.reduce((sum, current, index) => {
		const next = corners[(index + 1) % corners.length];
		return sum + current.x * next.y - next.x * current.y;
	}, 0)) * 0.5;
	if (area < 0.0001) return false;
	let sign = 0;
	for (let index = 0; index < corners.length; index += 1) {
		const current = corners[index];
		const next = corners[(index + 1) % corners.length];
		const cross = (next.x - current.x) * (point.y - current.y) - (next.y - current.y) * (point.x - current.x);
		if (Math.abs(cross) < 0.0001) continue;
		const nextSign = cross > 0 ? 1 : -1;
		if (sign === 0) sign = nextSign;
		else if (sign !== nextSign) return false;
	}
	return true;
};

export const hitTestActionRenderRects = (
	rects: ActionRenderRect[],
	point: {x: number; y: number},
	accept?: (rect: ActionRenderRect) => boolean,
) => {
	for (let index = rects.length - 1; index >= 0; index -= 1) {
		const rect = rects[index];
		if (!rect.visible) continue;
		if (accept !== undefined && !accept(rect)) continue;
		if (pointInQuad(point, rect.corners)) {
			return rect.nodeId;
		}
	}
	return null;
};
