import { BodyDocument, BodyLuaValue, BodyStructDocument, BodyVector } from "./BodyDocument";
import { getBodyFaceLabel } from "./BodyResource";

export type BodyViewport = {
	center: BodyVector;
	scale: number;
};

export type BodyRenderOptions = {
	document: BodyDocument;
	viewport: BodyViewport;
	selectedId?: string | null;
	width: number;
	height: number;
	physicsBodies?: readonly BodyRenderPhysicsBody[];
	physicsJoints?: readonly BodyRenderPhysicsJoint[];
};

export type BodyRenderPhysicsBody = {
	id: string;
	name: string;
	type?: string;
	position: BodyVector;
	angle: number;
};

export type BodyRenderPhysicsJoint = {
	id: string;
	name: string;
	anchorA: BodyVector;
	anchorB: BodyVector;
};

type ScreenPoint = {
	x: number;
	y: number;
};

const bodyTypes = new Set(["Phyx.Rect", "Phyx.Disk", "Phyx.Poly", "Phyx.Chain"]);
const jointTypes = new Set([
	"Phyx.Distance",
	"Phyx.Friction",
	"Phyx.Gear",
	"Phyx.Spring",
	"Phyx.Prismatic",
	"Phyx.Pulley",
	"Phyx.Revolute",
	"Phyx.Rope",
	"Phyx.Weld",
	"Phyx.Wheel",
]);

type DebugDrawColor = readonly [number, number, number];

const debugDrawColors = {
	staticBody: [0.5, 0.9, 0.5],
	kinematicBody: [0.5, 0.5, 0.9],
	activeBody: [0.9, 0.7, 0.7],
	sensor: [1, 0.9, 0],
	joint: [0.5, 0.8, 0.8],
} satisfies Record<string, DebugDrawColor>;

const colorChannel = (value: number) => Math.round(value * 255);
const rgbColor = (color: DebugDrawColor) => `rgb(${colorChannel(color[0])}, ${colorChannel(color[1])}, ${colorChannel(color[2])})`;
const debugFillColor = (color: DebugDrawColor) => `rgba(${colorChannel(color[0] * 0.5)}, ${colorChannel(color[1] * 0.5)}, ${colorChannel(color[2] * 0.5)}, 0.5)`;

const selectionBoundsColor = "rgba(170, 176, 184, 0.95)";
const selectionMarkerColor = "#65d6ff";

const polygonSignedArea = (vertices: BodyVector[]) => {
	let area = 0;
	for (let i = 0; i < vertices.length; i++) {
		const a = vertices[i];
		const b = vertices[(i + 1) % vertices.length];
		area += a[0] * b[1] - b[0] * a[1];
	}
	return area * 0.5;
};

const filterConcavePolygonVertices = (vertices: BodyVector[]) => {
	if (vertices.length <= 3) return vertices;
	const result = vertices.map((point) => [...point] as BodyVector);
	const winding = polygonSignedArea(result) >= 0 ? 1 : -1;
	const epsilon = 0.000001;
	let changed = true;
	while (changed && result.length >= 3) {
		changed = false;
		for (let i = 0; i < result.length; i++) {
			const previous = result[(i + result.length - 1) % result.length];
			const current = result[i];
			const next = result[(i + 1) % result.length];
			const cross = (current[0] - previous[0]) * (next[1] - current[1]) - (current[1] - previous[1]) * (next[0] - current[0]);
			if (cross * winding <= epsilon) {
				result.splice(i, 1);
				changed = true;
				break;
			}
		}
	}
	return result;
};

export const isBodyItem = (item: BodyStructDocument) => bodyTypes.has(item.structType);
export const isJointItem = (item: BodyStructDocument) => jointTypes.has(item.structType);

export const asNumber = (value: BodyLuaValue | undefined, fallback = 0): number => {
	return typeof value === "number" && Number.isFinite(value) ? value : fallback;
};

export const asString = (value: BodyLuaValue | undefined, fallback = ""): string => {
	return typeof value === "string" ? value : fallback;
};

export const asArray = (value: BodyLuaValue | undefined): BodyLuaValue[] => {
	return Array.isArray(value) ? value : [];
};

export const asVector = (value: BodyLuaValue | undefined, fallback: BodyVector = [0, 0]): BodyVector => {
	if (!Array.isArray(value)) return fallback;
	return [asNumber(value[0], fallback[0]), asNumber(value[1], fallback[1])];
};

export const getItemName = (item: BodyStructDocument) => {
	const named = asString(item.fields.name);
	return named || item.id;
};

const worldToScreen = (point: BodyVector, viewport: BodyViewport, width: number, height: number): ScreenPoint => ({
	x: width / 2 + (point[0] - viewport.center[0]) * viewport.scale,
	y: height / 2 - (point[1] - viewport.center[1]) * viewport.scale,
});

const localToWorld = (body: BodyStructDocument, local: BodyVector, pose?: BodyRenderPhysicsBody): BodyVector => {
	const position = pose?.position ?? asVector(body.fields.position);
	const angle = -(pose?.angle ?? asNumber(body.fields.angle)) * Math.PI / 180;
	const cos = Math.cos(angle);
	const sin = Math.sin(angle);
	return [
		position[0] + local[0] * cos - local[1] * sin,
		position[1] + local[0] * sin + local[1] * cos,
	];
};

export const getJointAnchorWorldPosition = (
	document: BodyDocument,
	item: BodyStructDocument,
	fieldName: "anchorA" | "anchorB",
	physicsBodies?: readonly BodyRenderPhysicsBody[],
): BodyVector | null => {
	if (!Array.isArray(item.fields[fieldName])) return null;
	const bodyName = fieldName === "anchorA" ? asString(item.fields.bodyA) : asString(item.fields.bodyB);
	const body = document.items.find((entry) => isBodyItem(entry) && getItemName(entry) === bodyName);
	if (!body) return null;
	const pose = physicsBodies?.find((entry) => entry.id === body.id || entry.name === getItemName(body));
	return localToWorld(body, asVector(item.fields[fieldName]), pose);
};

const rotateAround = (point: BodyVector, center: BodyVector, angleDegrees: number): BodyVector => {
	const angle = -angleDegrees * Math.PI / 180;
	const cos = Math.cos(angle);
	const sin = Math.sin(angle);
	const dx = point[0] - center[0];
	const dy = point[1] - center[1];
	return [
		center[0] + dx * cos - dy * sin,
		center[1] + dx * sin + dy * cos,
	];
};

const drawPath = (
	ctx: CanvasRenderingContext2D,
	points: BodyVector[],
	viewport: BodyViewport,
	width: number,
	height: number,
	closePath: boolean,
) => {
	if (points.length === 0) return;
	const first = worldToScreen(points[0], viewport, width, height);
	ctx.beginPath();
	ctx.moveTo(first.x, first.y);
	for (let i = 1; i < points.length; i++) {
		const point = worldToScreen(points[i], viewport, width, height);
		ctx.lineTo(point.x, point.y);
	}
	if (closePath) ctx.closePath();
};

const rectPoints = (center: BodyVector, size: BodyVector): BodyVector[] => {
	const halfWidth = size[0] / 2;
	const halfHeight = size[1] / 2;
	return [
		[center[0] - halfWidth, center[1] - halfHeight],
		[center[0] + halfWidth, center[1] - halfHeight],
		[center[0] + halfWidth, center[1] + halfHeight],
		[center[0] - halfWidth, center[1] + halfHeight],
	];
};

const drawCircle = (
	ctx: CanvasRenderingContext2D,
	center: BodyVector,
	radius: number,
	viewport: BodyViewport,
	width: number,
	height: number,
) => {
	const screen = worldToScreen(center, viewport, width, height);
	ctx.beginPath();
	ctx.arc(screen.x, screen.y, Math.max(1, radius * viewport.scale), 0, Math.PI * 2);
};

const drawShape = (
	ctx: CanvasRenderingContext2D,
	body: BodyStructDocument,
	shape: BodyStructDocument,
	viewport: BodyViewport,
	width: number,
	height: number,
	pose?: BodyRenderPhysicsBody,
) => {
	const sensor = shape.fields.sensor === true;
	const bodyType = pose?.type ?? asString(body.fields.type, "Static");
	const debugColor = sensor
		? debugDrawColors.sensor
		: bodyType === "Kinematic" || bodyType === "kinematic"
			? debugDrawColors.kinematicBody
			: bodyType === "Dynamic" || bodyType === "dynamic"
				? debugDrawColors.activeBody
				: debugDrawColors.staticBody;
	ctx.lineWidth = 1.5;
	ctx.strokeStyle = rgbColor(debugColor);
	ctx.fillStyle = debugFillColor(debugColor);
	if (shape.structType === "Phyx.Rect" || shape.structType === "Phyx.SubRect") {
		const center = asVector(shape.fields.center);
		const size = asVector(shape.fields.size, [40, 40]);
		const shapeAngle = shape.structType === "Phyx.SubRect" ? asNumber(shape.fields.angle) : 0;
		const points = rectPoints(center, size).map((point) => localToWorld(body, rotateAround(point, center, shapeAngle), pose));
		drawPath(ctx, points, viewport, width, height, true);
		ctx.fill();
		ctx.stroke();
		return;
	}
	if (shape.structType === "Phyx.Disk" || shape.structType === "Phyx.SubDisk") {
		const center = localToWorld(body, asVector(shape.fields.center), pose);
		drawCircle(ctx, center, asNumber(shape.fields.radius, 20), viewport, width, height);
		ctx.fill();
		ctx.stroke();
		return;
	}
	if (shape.structType === "Phyx.Poly" || shape.structType === "Phyx.SubPoly") {
		const points = filterConcavePolygonVertices(asArray(shape.fields.vertices).map((point) => asVector(point)))
			.map((point) => localToWorld(body, point, pose));
		if (points.length < 3) return;
		drawPath(ctx, points, viewport, width, height, true);
		ctx.fill();
		ctx.stroke();
		return;
	}
	if (shape.structType === "Phyx.Chain" || shape.structType === "Phyx.SubChain") {
		ctx.strokeStyle = rgbColor(debugColor);
		const points = asArray(shape.fields.vertices).map((point) => localToWorld(body, asVector(point), pose));
		drawPath(ctx, points, viewport, width, height, false);
		ctx.stroke();
	}
};

const getShapeWorldBoundsPoints = (
	body: BodyStructDocument,
	shape: BodyStructDocument,
	pose?: BodyRenderPhysicsBody,
): BodyVector[] => {
	if (shape.structType === "Phyx.Rect" || shape.structType === "Phyx.SubRect") {
		const center = asVector(shape.fields.center);
		const size = asVector(shape.fields.size, [40, 40]);
		const shapeAngle = shape.structType === "Phyx.SubRect" ? asNumber(shape.fields.angle) : 0;
		return rectPoints(center, size).map((point) => localToWorld(body, rotateAround(point, center, shapeAngle), pose));
	}
	if (shape.structType === "Phyx.Disk" || shape.structType === "Phyx.SubDisk") {
		const center = localToWorld(body, asVector(shape.fields.center), pose);
		const radius = Math.abs(asNumber(shape.fields.radius, 20));
		return [
			[center[0] - radius, center[1] - radius],
			[center[0] + radius, center[1] - radius],
			[center[0] + radius, center[1] + radius],
			[center[0] - radius, center[1] + radius],
		];
	}
	if (shape.structType === "Phyx.Poly" || shape.structType === "Phyx.SubPoly" || shape.structType === "Phyx.Chain" || shape.structType === "Phyx.SubChain") {
		return asArray(shape.fields.vertices).map((point) => localToWorld(body, asVector(point), pose));
	}
	return [];
};

const drawSelectionBounds = (
	ctx: CanvasRenderingContext2D,
	points: BodyVector[],
	viewport: BodyViewport,
	width: number,
	height: number,
) => {
	if (points.length === 0) return;
	const screenPoints = points.map((point) => worldToScreen(point, viewport, width, height));
	const minX = Math.min(...screenPoints.map((point) => point.x));
	const maxX = Math.max(...screenPoints.map((point) => point.x));
	const minY = Math.min(...screenPoints.map((point) => point.y));
	const maxY = Math.max(...screenPoints.map((point) => point.y));
	const padding = 6;
	ctx.save();
	ctx.strokeStyle = selectionBoundsColor;
	ctx.lineWidth = 1.5;
	ctx.setLineDash([5, 3]);
	ctx.strokeRect(minX - padding, minY - padding, maxX - minX + padding * 2, maxY - minY + padding * 2);
	ctx.restore();
};

export const getSubShapeSelectionId = (bodyId: string, index: number) => `${bodyId}::sub::${index}`;

export const parseSubShapeSelectionId = (id: string | null): { bodyId: string; index: number } | null => {
	if (!id) return null;
	const marker = "::sub::";
	const markerIndex = id.lastIndexOf(marker);
	if (markerIndex < 0) return null;
	const bodyId = id.slice(0, markerIndex);
	const index = Number(id.slice(markerIndex + marker.length));
	return Number.isInteger(index) && index >= 0 ? { bodyId, index } : null;
};

export const getSubShapeItem = (value: BodyLuaValue, index: number, bodyId?: string): BodyStructDocument | null => {
	if (!Array.isArray(value) || typeof value[0] !== "string") return null;
	const structType = value[0];
	if (!structType.startsWith("Phyx.Sub")) return null;
	const fields: Record<string, BodyLuaValue> = {};
	const names: Record<string, string[]> = {
		"Phyx.SubRect": ["center", "angle", "size", "density", "friction", "restitution", "sensor", "sensorTag"],
		"Phyx.SubDisk": ["center", "radius", "density", "friction", "restitution", "sensor", "sensorTag"],
		"Phyx.SubPoly": ["vertices", "density", "friction", "restitution", "sensor", "sensorTag"],
		"Phyx.SubChain": ["vertices", "friction", "restitution"],
	};
	const fieldNames = names[structType];
	if (!fieldNames) return null;
	for (let i = 0; i < fieldNames.length; i++) {
		fields[fieldNames[i]] = value[i + 1] ?? null;
	}
	return {
		id: bodyId ? getSubShapeSelectionId(bodyId, index) : `${structType}:${index}`,
		structType: structType as BodyStructDocument["structType"],
		fields,
	};
};

export const getBodyFocusPoint = (item: BodyStructDocument): BodyVector => {
	if (isBodyItem(item)) return asVector(item.fields.position);
	if (isJointItem(item)) return asVector(item.fields.worldPos, asVector(item.fields.anchorA, asVector(item.fields.linearOffset)));
	return [0, 0];
};

const distanceSq = (a: BodyVector, b: BodyVector) => {
	const dx = a[0] - b[0];
	const dy = a[1] - b[1];
	return dx * dx + dy * dy;
};

const pointInPolygon = (point: BodyVector, vertices: BodyVector[]) => {
	let inside = false;
	for (let i = 0, j = vertices.length - 1; i < vertices.length; j = i++) {
		const a = vertices[i];
		const b = vertices[j];
		const crosses = (a[1] > point[1]) !== (b[1] > point[1]);
		if (crosses) {
			const x = (b[0] - a[0]) * (point[1] - a[1]) / (b[1] - a[1]) + a[0];
			if (point[0] < x) inside = !inside;
		}
	}
	return inside;
};

const distanceToSegment = (point: BodyVector, a: BodyVector, b: BodyVector) => {
	const dx = b[0] - a[0];
	const dy = b[1] - a[1];
	const lengthSq = dx * dx + dy * dy;
	if (lengthSq <= 0) return Math.sqrt(distanceSq(point, a));
	const t = Math.max(0, Math.min(1, ((point[0] - a[0]) * dx + (point[1] - a[1]) * dy) / lengthSq));
	return Math.sqrt(distanceSq(point, [a[0] + t * dx, a[1] + t * dy]));
};

const hitTestShape = (point: BodyVector, body: BodyStructDocument, shape: BodyStructDocument, tolerance: number, pose?: BodyRenderPhysicsBody) => {
	if (shape.structType === "Phyx.Rect" || shape.structType === "Phyx.SubRect") {
		const center = asVector(shape.fields.center);
		const size = asVector(shape.fields.size, [40, 40]);
		const shapeAngle = shape.structType === "Phyx.SubRect" ? asNumber(shape.fields.angle) : 0;
		const points = rectPoints(center, size).map((vertex) => localToWorld(body, rotateAround(vertex, center, shapeAngle), pose));
		return pointInPolygon(point, points);
	}
	if (shape.structType === "Phyx.Disk" || shape.structType === "Phyx.SubDisk") {
		const center = localToWorld(body, asVector(shape.fields.center), pose);
		const radius = asNumber(shape.fields.radius, 20);
		return distanceSq(point, center) <= (radius + tolerance) * (radius + tolerance);
	}
	if (shape.structType === "Phyx.Poly" || shape.structType === "Phyx.SubPoly") {
		const points = filterConcavePolygonVertices(asArray(shape.fields.vertices).map((vertex) => asVector(vertex)))
			.map((vertex) => localToWorld(body, vertex, pose));
		return points.length >= 3 && pointInPolygon(point, points);
	}
	if (shape.structType === "Phyx.Chain" || shape.structType === "Phyx.SubChain") {
		const points = asArray(shape.fields.vertices).map((vertex) => localToWorld(body, asVector(vertex), pose));
		for (let i = 1; i < points.length; i++) {
			if (distanceToSegment(point, points[i - 1], points[i]) <= tolerance) return true;
		}
	}
	return false;
};

export const hitTestBodyDocument = (options: BodyRenderOptions, point: BodyVector): string | null => {
	const { document, viewport } = options;
	const tolerance = Math.max(4, 8 / viewport.scale);
	const jointTolerance = Math.max(tolerance, 12 / viewport.scale);
	const bodies = new Map<string, BodyStructDocument>();
	const physicsById = new Map(options.physicsBodies?.map((body) => [body.id, body]));
	const physicsByName = new Map(options.physicsBodies?.map((body) => [body.name, body]));
	const physicsJointsById = new Map(options.physicsJoints?.map((joint) => [joint.id, joint]));
	for (const item of document.items) {
		if (isBodyItem(item)) bodies.set(getItemName(item), item);
	}
	for (let i = document.items.length - 1; i >= 0; i--) {
		const item = document.items[i];
		if (!isJointItem(item)) continue;
		const bodyA = bodies.get(asString(item.fields.bodyA));
		const bodyB = bodies.get(asString(item.fields.bodyB));
		if (!bodyA || !bodyB) continue;
		const physicsJoint = physicsJointsById.get(item.id);
		const a = physicsJoint?.anchorA
			?? getJointAnchorWorldPosition(document, item, "anchorA", options.physicsBodies)
			?? physicsByName.get(getItemName(bodyA))?.position
			?? asVector(bodyA.fields.position);
		const b = physicsJoint?.anchorB
			?? getJointAnchorWorldPosition(document, item, "anchorB", options.physicsBodies)
			?? physicsByName.get(getItemName(bodyB))?.position
			?? asVector(bodyB.fields.position);
		if (
			distanceSq(point, a) <= jointTolerance * jointTolerance ||
			distanceSq(point, b) <= jointTolerance * jointTolerance ||
			distanceToSegment(point, a, b) <= jointTolerance
		) return item.id;
	}
	for (let i = document.items.length - 1; i >= 0; i--) {
		const item = document.items[i];
		if (!isBodyItem(item)) continue;
		const pose = physicsById.get(item.id);
		const subShapes = asArray(item.fields.subShapes);
		for (let subIndex = subShapes.length - 1; subIndex >= 0; subIndex--) {
			const subItem = getSubShapeItem(subShapes[subIndex], subIndex, item.id);
			if (subItem && hitTestShape(point, item, subItem, tolerance, pose)) return subItem.id;
		}
		if (hitTestShape(point, item, item, tolerance, pose)) return item.id;
	}
	return null;
};

const drawGrid = (ctx: CanvasRenderingContext2D, viewport: BodyViewport, width: number, height: number) => {
	ctx.fillStyle = "#1f1f1f";
	ctx.fillRect(0, 0, width, height);
	const spacing = 100;
	const left = viewport.center[0] - width / viewport.scale / 2;
	const right = viewport.center[0] + width / viewport.scale / 2;
	const bottom = viewport.center[1] - height / viewport.scale / 2;
	const top = viewport.center[1] + height / viewport.scale / 2;
	ctx.lineWidth = 1;
	ctx.strokeStyle = "#303030";
	for (let x = Math.floor(left / spacing) * spacing; x <= right; x += spacing) {
		const a = worldToScreen([x, bottom], viewport, width, height);
		const b = worldToScreen([x, top], viewport, width, height);
		ctx.beginPath();
		ctx.moveTo(a.x, a.y);
		ctx.lineTo(b.x, b.y);
		ctx.stroke();
	}
	for (let y = Math.floor(bottom / spacing) * spacing; y <= top; y += spacing) {
		const a = worldToScreen([left, y], viewport, width, height);
		const b = worldToScreen([right, y], viewport, width, height);
		ctx.beginPath();
		ctx.moveTo(a.x, a.y);
		ctx.lineTo(b.x, b.y);
		ctx.stroke();
	}
	const origin = worldToScreen([0, 0], viewport, width, height);
	ctx.strokeStyle = "#585858";
	ctx.beginPath();
	ctx.moveTo(0, origin.y);
	ctx.lineTo(width, origin.y);
	ctx.moveTo(origin.x, 0);
	ctx.lineTo(origin.x, height);
	ctx.stroke();
	ctx.fillStyle = "#7c8794";
	ctx.font = "11px sans-serif";
	ctx.fillText(`x ${Math.round(viewport.center[0])}`, 12, 18);
	ctx.fillText(`y ${Math.round(viewport.center[1])}`, 12, 34);
};

const drawJointAnchorPlaceholder = (
	ctx: CanvasRenderingContext2D,
	point: BodyVector,
	label: string,
	viewport: BodyViewport,
	width: number,
	height: number,
) => {
	const screen = worldToScreen(point, viewport, width, height);
	ctx.save();
	ctx.strokeStyle = selectionMarkerColor;
	ctx.fillStyle = "rgba(101, 214, 255, 0.22)";
	ctx.lineWidth = 1.5;
	ctx.beginPath();
	ctx.arc(screen.x, screen.y, 6, 0, Math.PI * 2);
	ctx.fill();
	ctx.stroke();
	ctx.beginPath();
	ctx.moveTo(screen.x - 10, screen.y);
	ctx.lineTo(screen.x + 10, screen.y);
	ctx.moveTo(screen.x, screen.y - 10);
	ctx.lineTo(screen.x, screen.y + 10);
	ctx.stroke();
	ctx.fillStyle = selectionMarkerColor;
	ctx.font = "11px sans-serif";
	ctx.fillText(label, screen.x + 8, screen.y - 8);
	ctx.restore();
};

const drawSelectedJointAnchors = (
	ctx: CanvasRenderingContext2D,
	document: BodyDocument,
	item: BodyStructDocument,
	physicsJoint: BodyRenderPhysicsJoint | undefined,
	physicsBodies: readonly BodyRenderPhysicsBody[] | undefined,
	viewport: BodyViewport,
	width: number,
	height: number,
) => {
	const anchorA = physicsJoint?.anchorA ?? getJointAnchorWorldPosition(document, item, "anchorA", physicsBodies);
	const anchorB = physicsJoint?.anchorB ?? getJointAnchorWorldPosition(document, item, "anchorB", physicsBodies);
	if (anchorA) {
		drawJointAnchorPlaceholder(ctx, anchorA, "A", viewport, width, height);
	}
	if (anchorB) {
		drawJointAnchorPlaceholder(ctx, anchorB, "B", viewport, width, height);
	}
};

export const renderBodyDocument = (ctx: CanvasRenderingContext2D, options: BodyRenderOptions) => {
	const { document, viewport, selectedId, width, height } = options;
	drawGrid(ctx, viewport, width, height);
	const bodies = new Map<string, BodyStructDocument>();
	const physicsById = new Map(options.physicsBodies?.map((body) => [body.id, body]));
	const physicsByName = new Map(options.physicsBodies?.map((body) => [body.name, body]));
	const physicsJointsById = new Map(options.physicsJoints?.map((joint) => [joint.id, joint]));
	for (const item of document.items) {
		if (isBodyItem(item)) bodies.set(getItemName(item), item);
	}
	for (const item of document.items) {
		if (!isBodyItem(item)) continue;
		const selected = selectedId === item.id;
		const pose = physicsById.get(item.id);
		drawShape(ctx, item, item, viewport, width, height, pose);
		const selectionBoundsPoints: BodyVector[] = selected ? getShapeWorldBoundsPoints(item, item, pose) : [];
		for (const [index, subShape] of asArray(item.fields.subShapes).entries()) {
			const subItem = getSubShapeItem(subShape, index, item.id);
			if (subItem) {
				drawShape(ctx, item, subItem, viewport, width, height, pose);
				if (selected) {
					selectionBoundsPoints.push(...getShapeWorldBoundsPoints(item, subItem, pose));
				} else if (selectedId === subItem.id) {
					drawSelectionBounds(ctx, getShapeWorldBoundsPoints(item, subItem, pose), viewport, width, height);
				}
			}
		}
		if (selected) drawSelectionBounds(ctx, selectionBoundsPoints, viewport, width, height);
		const label = worldToScreen(pose?.position ?? asVector(item.fields.position), viewport, width, height);
		ctx.fillStyle = "#d7d7d7";
		ctx.font = "12px sans-serif";
		ctx.fillText(getItemName(item), label.x + 6, label.y - 6);
		const face = asString(item.fields.face);
		const faceLabel = getBodyFaceLabel(face);
		if (faceLabel) {
			const facePos = worldToScreen(localToWorld(item, asVector(item.fields.facePos), pose), viewport, width, height);
			ctx.fillStyle = "rgba(70, 70, 70, 0.75)";
			ctx.fillRect(facePos.x - 28, facePos.y - 12, 56, 20);
			ctx.strokeStyle = "#8f9aa6";
			ctx.strokeRect(facePos.x - 28, facePos.y - 12, 56, 20);
			ctx.fillStyle = "#d7d7d7";
			ctx.fillText(faceLabel, facePos.x - 24, facePos.y + 3);
		}
	}
	for (const item of document.items) {
		if (!isJointItem(item)) continue;
		const physicsJoint = physicsJointsById.get(item.id);
		if (selectedId === item.id) drawSelectedJointAnchors(ctx, document, item, physicsJoint, options.physicsBodies, viewport, width, height);
				const bodyA = bodies.get(asString(item.fields.bodyA));
				const bodyB = bodies.get(asString(item.fields.bodyB));
				if (!bodyA || !bodyB) continue;
				const pointA = physicsJoint?.anchorA
					?? getJointAnchorWorldPosition(document, item, "anchorA", options.physicsBodies)
					?? physicsByName.get(getItemName(bodyA))?.position
					?? asVector(bodyA.fields.position);
				const pointB = physicsJoint?.anchorB
					?? getJointAnchorWorldPosition(document, item, "anchorB", options.physicsBodies)
					?? physicsByName.get(getItemName(bodyB))?.position
					?? asVector(bodyB.fields.position);
			const a = worldToScreen(pointA, viewport, width, height);
			const b = worldToScreen(pointB, viewport, width, height);
		ctx.strokeStyle = rgbColor(debugDrawColors.joint);
		ctx.lineWidth = 1.25;
		ctx.beginPath();
		ctx.moveTo(a.x, a.y);
		ctx.lineTo(b.x, b.y);
		ctx.stroke();
		const midX = (a.x + b.x) / 2;
		const midY = (a.y + b.y) / 2;
		ctx.fillStyle = rgbColor(debugDrawColors.joint);
		ctx.fillRect(midX - 3, midY - 3, 6, 6);
	}
};
