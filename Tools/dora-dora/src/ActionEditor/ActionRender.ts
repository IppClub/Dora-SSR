import type {ActionClipDocument, ActionClipRect} from "./ActionClip";
import type {ActionDocument, ActionNode} from "./ActionDocument";
import type {ActionViewport} from "./ActionEditorState";
import {sampleActionKeyTrack} from "./ActionPlayback";

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
	visible: boolean;
	missingClip: boolean;
};

export type ActionViewportRect = {
	x: number;
	y: number;
	width: number;
	height: number;
};

const fallbackRect = (node: ActionNode, document: ActionDocument): ActionClipRect => {
	const width = node.id === document.root.id && document.size.width > 0 ? document.size.width : 80;
	const height = node.id === document.root.id && document.size.height > 0 ? document.size.height : 80;
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
	rotation: number;
}): ActionRenderMatrix => {
	const scaleX = transform.scale.x === 0 ? 1 : transform.scale.x;
	const scaleY = transform.scale.y === 0 ? 1 : transform.scale.y;
	const radians = -transform.rotation * Math.PI / 180;
	const cos = Math.cos(radians);
	const sin = Math.sin(radians);
	return {
		a: cos * scaleX,
		b: sin * scaleX,
		c: -sin * scaleY,
		d: cos * scaleY,
		tx: transform.position.x,
		ty: transform.position.y,
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
	out: ActionRenderRect[],
) => {
	const rect = node.clip ? clip?.rects[node.clip] : undefined;
	const base = rect ?? fallbackRect(node, document);
	const track = animation ? node.tracks[animation] : undefined;
	const sampled = track?.type === "key" ? sampleActionKeyTrack(track, time) : null;
	const transform = sampled ?? node.transform;
	const nodeMatrix = multiplyMatrix(parentMatrix, transformMatrix(transform));
	const left = -base.width * node.transform.anchor.x;
	const right = left + base.width;
	const bottom = -base.height * node.transform.anchor.y;
	const top = bottom + base.height;
	const corners: ActionRenderRect["corners"] = [
		transformPoint(nodeMatrix, {x: left, y: top}),
		transformPoint(nodeMatrix, {x: right, y: top}),
		transformPoint(nodeMatrix, {x: right, y: bottom}),
		transformPoint(nodeMatrix, {x: left, y: bottom}),
	];
	const minX = Math.min(corners[0].x, corners[1].x, corners[2].x, corners[3].x);
	const maxX = Math.max(corners[0].x, corners[1].x, corners[2].x, corners[3].x);
	const minY = Math.min(corners[0].y, corners[1].y, corners[2].y, corners[3].y);
	const maxY = Math.max(corners[0].y, corners[1].y, corners[2].y, corners[3].y);
	const visible = (look === null || node.hiddenInLooks.indexOf(look) < 0) && (sampled?.visible ?? true);
	out.push({
		nodeId: node.id,
		name: node.name,
		clip: node.clip,
		sourceX: base.x,
		sourceY: base.y,
		sourceWidth: base.width,
		sourceHeight: base.height,
		x: minX,
		y: minY,
		width: Math.max(1, maxX - minX),
		height: Math.max(1, maxY - minY),
		corners,
		visible,
		missingClip: node.clip !== "" && rect === undefined,
	});
	for (const child of node.children) {
		collectRenderRects(document, clip, child, nodeMatrix, look, animation, time, out);
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
	collectRenderRects(document, clip, document.root, identityMatrix(), look, animation, time, rects);
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
) => {
	for (let index = rects.length - 1; index >= 0; index -= 1) {
		const rect = rects[index];
		if (!rect.visible) continue;
		if (pointInQuad(point, rect.corners)) {
			return rect.nodeId;
		}
	}
	return null;
};
