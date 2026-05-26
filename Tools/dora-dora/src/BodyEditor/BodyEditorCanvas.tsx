import RedoIcon from "@mui/icons-material/Redo";
import UndoIcon from "@mui/icons-material/Undo";
import { Button, Dialog, DialogActions, DialogContent, DialogTitle, IconButton, Stack, TextField, Tooltip } from "@mui/material";
import { MacScrollbar } from "mac-scrollbar";
import { Fragment, memo, useCallback, useEffect, useMemo, useRef, useState } from "react";
import { useTranslation } from "react-i18next";
import ClipSliceDialog from "../ClipSliceDialog";
import Info from "../Info";
import * as Service from "../Service";
import { parseLegacyClip, type ActionClipRect } from "../ActionEditor/ActionClip";
import { BODY_STRUCTS_BY_TYPE, BodyDocument, BodyLuaValue, BodyStructDocument, BodyStructField, BodyVector } from "./BodyDocument";
import { BodyCreateJointRefs, BodyCreateJointType, BodyCreateShapeType, BodyCreateSubShapeType } from "./BodyEditorState";
import { BodyNumberConstraint, applyBodyNumberConstraint, getBodyNumberConstraint } from "./BodyFieldConstraints";
import { BodyIconName, drawBodyIcon } from "./BodyIcons";
import { BODY_PHYSICS_TIME_STEP, BodyPhysicsRuntime, type BodyPhysicsSnapshot } from "./BodyPhysicsRuntime";
import { BodyFacePreviewAsset, bodyResourceToServedUrl, isBodyFaceImageSource } from "./BodyResource";
import { BodyViewport, asArray, asNumber, asString, asVector, getItemName, getJointAnchorWorldPosition, getSubShapeItem, getSubShapeSelectionId, hitTestBodyDocument, isBodyItem, isJointItem, parseSubShapeSelectionId, renderBodyDocument } from "./BodyRender";

type BodyEditorAlertType = "success" | "info" | "warning" | "error";

export type BodyEditorCanvasProps = {
	document: BodyDocument;
	faceAssets?: ReadonlyMap<string, BodyFacePreviewAsset>;
	resourceBasePath: string;
	servedResourceBasePath: string;
	width: number;
	height: number;
	active: boolean;
	readOnly: boolean;
	canUndo: boolean;
	canRedo: boolean;
	onUndo?: () => void;
	onRedo?: () => void;
	onCreateShape?: (shapeType: BodyCreateShapeType, position: [number, number]) => void;
	onCreateSubShape?: (subShapeType: BodyCreateSubShapeType, selectedId: string | null, position: [number, number]) => void;
	onCreateJoint?: (jointType: BodyCreateJointType, position: [number, number], refs?: BodyCreateJointRefs) => void;
	onDeleteSelected?: (selectedId: string | null) => void;
	onDuplicateSelected?: (selectedId: string | null) => void;
	onUpdateField?: (selectedId: string, fieldName: string, value: BodyLuaValue, recordUndo?: boolean) => void;
	onBeginValueEdit?: () => void;
	onEndValueEdit?: (changed: boolean) => void;
	onBeginTranslateSelection?: () => void;
	onTranslateSelection?: (selectedId: string | null, delta: [number, number]) => void;
	onEndTranslateSelection?: (changed: boolean) => void;
	addAlert?: (msg: string, type: BodyEditorAlertType, openLog?: boolean) => void;
};

const defaultViewport = (): BodyViewport => ({
	center: [0, 0],
	scale: 1,
});

const iconLabels: Record<BodyIconName, string> = {
	menu: "Menu",
	rect: "Rectangle",
	disk: "Disk",
	poly: "Polygon",
	chain: "Chain",
	joint: "Joint",
	delete: "Delete",
	play: "Play",
	stop: "Stop",
	origin: "Origin",
	zoom: "Zoom",
	fixX: "Fix X",
	fixY: "Fix Y",
};

const jointCreateLabels: Record<BodyCreateJointType, string> = {
	distance: "Distance",
	friction: "Friction",
	gear: "Gear",
	spring: "Spring",
	prismatic: "Prismatic",
	pulley: "Pulley",
	revolute: "Revolute",
	rope: "Rope",
	weld: "Weld",
	wheel: "Wheel",
};

type FaceResourceEntry = {
	kind: "image" | "clip";
	path: string;
	relative: string;
};

type LoadedFaceImage = {
	image: HTMLImageElement;
	objectUrl: string;
};

const normalizeFacePath = (path: string) => path.replace(/\\/g, "/");

const toFaceRelativePath = (path: string, root: string) => normalizeFacePath(Info.path.relative(root, path));

const loadFaceImageElement = async (filePath: string, servedResourceBasePath: string): Promise<LoadedFaceImage> => {
	const response = await fetch(Service.addr(bodyResourceToServedUrl(filePath, servedResourceBasePath)));
	if (!response.ok) throw new Error(`Failed to load image: ${filePath}`);
	const objectUrl = URL.createObjectURL(await response.blob());
	try {
		const image = await new Promise<HTMLImageElement>((resolve, reject) => {
			const element = new Image();
			element.onload = () => resolve(element);
			element.onerror = () => reject(new Error(`Failed to decode image: ${filePath}`));
			element.src = objectUrl;
		});
		return { image, objectUrl };
	} catch (error) {
		URL.revokeObjectURL(objectUrl);
		throw error;
	}
};

const findFaceResourceFiles = async (root: string) => {
	const listed = await Service.list({ path: root });
	if (!listed.success) return [];
	const entries = listed.files.flatMap((file): FaceResourceEntry[] => {
		const fullPath = Info.path.isAbsolute(file) ? Info.path.normalize(file) : Info.path.normalize(Info.path.join(root, file));
		const relative = toFaceRelativePath(fullPath, root);
		if (isBodyFaceImageSource(file)) return [{ kind: "image", path: fullPath, relative }];
		if (Info.path.extname(file).toLowerCase() === ".clip") return [{ kind: "clip", path: fullPath, relative }];
		return [];
	});
	return entries.sort((a, b) => a.relative.localeCompare(b.relative));
};

const BodyIconGlyph = memo(function BodyIconGlyph(props: { name: BodyIconName; active?: boolean }) {
	const { name, active } = props;
	const ref = useRef<HTMLCanvasElement | null>(null);
	useEffect(() => {
		const canvas = ref.current;
		const context = canvas?.getContext("2d");
		if (!canvas || !context) return;
		const ratio = window.devicePixelRatio || 1;
		canvas.width = 24 * ratio;
		canvas.height = 24 * ratio;
		canvas.style.width = "24px";
		canvas.style.height = "24px";
		context.setTransform(ratio, 0, 0, ratio, 0, 0);
		context.clearRect(0, 0, 24, 24);
		drawBodyIcon(context, name, 0, 0, 24, active ? "#fac03d" : "#d7d7d7");
	}, [active, name]);
	return <canvas ref={ref} aria-hidden="true" />;
});

const isShapeTool = (name: BodyIconName): name is BodyCreateShapeType => (
	name === "rect" || name === "disk" || name === "poly" || name === "chain"
);

const getStructIconName = (item: BodyStructDocument): BodyIconName => {
	if (item.structType === "Phyx.Rect" || item.structType === "Phyx.SubRect") return "rect";
	if (item.structType === "Phyx.Disk" || item.structType === "Phyx.SubDisk") return "disk";
	if (item.structType === "Phyx.Poly" || item.structType === "Phyx.SubPoly") return "poly";
	if (item.structType === "Phyx.Chain" || item.structType === "Phyx.SubChain") return "chain";
	return "joint";
};

const snapValue = (value: number, fixed: boolean, step: number) => {
	if (!fixed) return value;
	const safeStep = Math.max(0.0001, step);
	return Math.round(value / safeStep) * safeStep;
};

const pointerAngleDegrees = (center: { x: number; y: number }, point: { x: number; y: number }) => (
	Math.atan2(point.y - center.y, point.x - center.x) * 180 / Math.PI
);

const pointerAngleStepDelta = (degrees: number) => {
	let result = degrees;
	while (result > 180) result -= 360;
	while (result < -180) result += 360;
	return result;
};

const worldToScreenPoint = (point: BodyVector, viewport: BodyViewport, width: number, height: number) => ({
	x: width / 2 + (point[0] - viewport.center[0]) * viewport.scale,
	y: height / 2 - (point[1] - viewport.center[1]) * viewport.scale,
});

const localToWorldPoint = (body: BodyStructDocument, local: BodyVector): BodyVector => {
	const position = asVector(body.fields.position);
	const angle = -asNumber(body.fields.angle) * Math.PI / 180;
	const cos = Math.cos(angle);
	const sin = Math.sin(angle);
	return [
		position[0] + local[0] * cos - local[1] * sin,
		position[1] + local[0] * sin + local[1] * cos,
	];
};

const worldDeltaToBodyLocalDelta = (body: BodyStructDocument, delta: BodyVector): BodyVector => {
	const angle = -asNumber(body.fields.angle) * Math.PI / 180;
	const cos = Math.cos(angle);
	const sin = Math.sin(angle);
	return [
		delta[0] * cos + delta[1] * sin,
		-delta[0] * sin + delta[1] * cos,
	];
};

const getVertexEditContext = (document: BodyDocument, selectedId: string | null) => {
	const context = getSelectedBodyContext(document, selectedId);
	if (!context || !Array.isArray(context.item.fields.vertices)) return null;
	const body = context.body ?? (isBodyItem(context.item) ? context.item : null);
	if (!body) return null;
	return {
		body,
		item: context.item,
		vertices: asArray(context.item.fields.vertices).map((point) => asVector(point)),
	};
};

const getVertexWorldPoints = (document: BodyDocument, selectedId: string | null) => {
	const context = getVertexEditContext(document, selectedId);
	if (!context) return [];
	return context.vertices.map((point) => localToWorldPoint(context.body, point));
};

const hitTestVertex = (
	document: BodyDocument,
	selectedId: string | null,
	world: BodyVector,
	viewport: BodyViewport,
) => {
	const worldPoints = getVertexWorldPoints(document, selectedId);
	const tolerance = Math.max(6, 9 / viewport.scale);
	let bestIndex = -1;
	let bestDistanceSq = tolerance * tolerance;
	for (let i = 0; i < worldPoints.length; i++) {
		const point = worldPoints[i];
		const dx = point[0] - world[0];
		const dy = point[1] - world[1];
		const distance = dx * dx + dy * dy;
		if (distance <= bestDistanceSq) {
			bestDistanceSq = distance;
			bestIndex = i;
		}
	}
	return bestIndex >= 0 ? bestIndex : null;
};

const drawVertexOverlay = (
	ctx: CanvasRenderingContext2D,
	document: BodyDocument,
	selectedId: string | null,
	selectedVertexIndex: number | null,
	viewport: BodyViewport,
	width: number,
	height: number,
) => {
	const points = getVertexWorldPoints(document, selectedId);
	if (points.length === 0) return;
	ctx.save();
	ctx.lineWidth = 1.5;
	ctx.font = "10px sans-serif";
	for (let i = 0; i < points.length; i++) {
		const screen = worldToScreenPoint(points[i], viewport, width, height);
		const selected = i === selectedVertexIndex;
		ctx.fillStyle = selected ? "#1f1f1f" : "#2b2b2b";
		ctx.strokeStyle = selected ? "#65d6ff" : "#aab0b8";
		ctx.beginPath();
		ctx.rect(screen.x - 4, screen.y - 4, 8, 8);
		ctx.fill();
		ctx.stroke();
		ctx.fillStyle = selected ? "#65d6ff" : "#c8c8c8";
		ctx.fillText(String(i + 1), screen.x + 6, screen.y - 6);
	}
	ctx.restore();
};

const averageVertices = (vertices: BodyLuaValue[]): BodyVector => {
	const points = vertices.map((point) => asVector(point));
	if (points.length === 0) return [0, 0];
	return [
		points.reduce((sum, point) => sum + point[0], 0) / points.length,
		points.reduce((sum, point) => sum + point[1], 0) / points.length,
	];
};

const rotateLocalPoint = (point: BodyVector, center: BodyVector, degrees: number): BodyVector => {
	const angle = -degrees * Math.PI / 180;
	const cos = Math.cos(angle);
	const sin = Math.sin(angle);
	const dx = point[0] - center[0];
	const dy = point[1] - center[1];
	return [
		center[0] + dx * cos - dy * sin,
		center[1] + dx * sin + dy * cos,
	];
};

const getSelectedBodyContext = (document: BodyDocument, selectedId: string | null) => {
	const subSelection = parseSubShapeSelectionId(selectedId);
	if (subSelection) {
		const body = document.items.find((item) => item.id === subSelection.bodyId);
		if (!body || !isBodyItem(body)) return null;
		const subShapeValue = asArray(body.fields.subShapes)[subSelection.index];
		const subShape = getSubShapeItem(subShapeValue, subSelection.index, body.id);
		return subShape ? { body, item: subShape, isSubShape: true } : null;
	}
	const item = document.items.find((candidate) => candidate.id === selectedId);
	if (!item) return null;
	return { body: isBodyItem(item) ? item : null, item, isSubShape: false };
};

const getGizmoWorldCenter = (document: BodyDocument, selectedId: string | null): BodyVector | null => {
	const context = getSelectedBodyContext(document, selectedId);
	if (!context) return null;
	if (context.isSubShape && context.body) {
		const { item, body } = context;
		if (Array.isArray(item.fields.center)) return localToWorldPoint(body, asVector(item.fields.center));
		if (Array.isArray(item.fields.vertices)) return localToWorldPoint(body, averageVertices(asArray(item.fields.vertices)));
		return asVector(body.fields.position);
	}
	if (isBodyItem(context.item)) return asVector(context.item.fields.position);
	if (isJointItem(context.item)) return asVector(context.item.fields.worldPos, asVector(context.item.fields.anchorA, asVector(context.item.fields.linearOffset)));
	return null;
};

const rectLocalPoints = (center: BodyVector, size: BodyVector): BodyVector[] => {
	const halfWidth = size[0] / 2;
	const halfHeight = size[1] / 2;
	return [
		[center[0] - halfWidth, center[1] - halfHeight],
		[center[0] + halfWidth, center[1] - halfHeight],
		[center[0] + halfWidth, center[1] + halfHeight],
		[center[0] - halfWidth, center[1] + halfHeight],
	];
};

const getShapeLocalBoundsPoints = (item: BodyStructDocument): BodyVector[] => {
	if (item.structType === "Phyx.Rect" || item.structType === "Phyx.SubRect") {
		const center = asVector(item.fields.center);
		const angle = item.structType === "Phyx.SubRect" ? asNumber(item.fields.angle) : 0;
		return rectLocalPoints(center, asVector(item.fields.size, [40, 40])).map((point) => rotateLocalPoint(point, center, angle));
	}
	if (item.structType === "Phyx.Disk" || item.structType === "Phyx.SubDisk") {
		const center = asVector(item.fields.center);
		const radius = Math.max(1, asNumber(item.fields.radius, 20));
		return rectLocalPoints(center, [radius * 2, radius * 2]);
	}
	if (item.structType === "Phyx.Poly" || item.structType === "Phyx.SubPoly" || item.structType === "Phyx.Chain" || item.structType === "Phyx.SubChain") {
		return asArray(item.fields.vertices).map((point) => asVector(point));
	}
	return [];
};

const getBodyLocalBoundsPoints = (body: BodyStructDocument): BodyVector[] => {
	const points = [...getShapeLocalBoundsPoints(body)];
	for (const [index, subShapeValue] of asArray(body.fields.subShapes).entries()) {
		const subShape = getSubShapeItem(subShapeValue, index, body.id);
		if (subShape) points.push(...getShapeLocalBoundsPoints(subShape));
	}
	return points;
};

const getGizmoScreenBounds = (
	document: BodyDocument,
	selectedId: string | null,
	viewport: BodyViewport,
	width: number,
	height: number,
) => {
	const context = getSelectedBodyContext(document, selectedId);
	if (!context || !context.body) return null;
	const localPoints = context.isSubShape ? getShapeLocalBoundsPoints(context.item) : getBodyLocalBoundsPoints(context.body);
	const worldPoints = localPoints.map((point) => localToWorldPoint(context.body!, point));
	if (worldPoints.length === 0) return null;
	const screenPoints = worldPoints.map((point) => worldToScreenPoint(point, viewport, width, height));
	const minX = Math.min(...screenPoints.map((point) => point.x));
	const maxX = Math.max(...screenPoints.map((point) => point.x));
	const minY = Math.min(...screenPoints.map((point) => point.y));
	const maxY = Math.max(...screenPoints.map((point) => point.y));
	return {
		minX,
		maxX,
		minY,
		maxY,
		center: {
			x: (minX + maxX) / 2,
			y: (minY + maxY) / 2,
		},
		width: Math.max(1, maxX - minX),
		height: Math.max(1, maxY - minY),
	};
};

const scaleVertices = (vertices: BodyLuaValue[], center: BodyVector, factorX: number, factorY: number): BodyLuaValue[] => (
	vertices.map((point) => {
		const vertex = asVector(point);
		return [
			center[0] + (vertex[0] - center[0]) * factorX,
			center[1] + (vertex[1] - center[1]) * factorY,
		];
	})
);

const rotateVertices = (vertices: BodyLuaValue[], center: BodyVector, degrees: number): BodyLuaValue[] => (
	vertices.map((point) => rotateLocalPoint(asVector(point), center, degrees))
);

type PrismaticMoveHandle = "worldPos" | "lower" | "upper";
type PulleyMoveHandle = "anchorA" | "anchorB" | "groundAnchorA" | "groundAnchorB";
type WorldPosMoveHandle = "worldPos";

const normalizeVector = (value: BodyVector, fallback: BodyVector = [1, 0]): BodyVector => {
	const length = Math.hypot(value[0], value[1]);
	if (length <= 0.000001) return fallback;
	return [value[0] / length, value[1] / length];
};

const getPrismaticGuidePoints = (item: BodyStructDocument) => {
	const worldPos = asVector(item.fields.worldPos);
	const axis = normalizeVector(asVector(item.fields.axis, [1, 0]));
	const lower = asNumber(item.fields.lowerTranslation);
	const upper = asNumber(item.fields.upperTranslation);
	return {
		worldPos,
		axis,
		lowerPoint: [worldPos[0] + axis[0] * lower, worldPos[1] + axis[1] * lower] as BodyVector,
		upperPoint: [worldPos[0] + axis[0] * upper, worldPos[1] + axis[1] * upper] as BodyVector,
	};
};

const getPrismaticMoveHandle = (
	item: BodyStructDocument,
	point: BodyVector,
	tolerance: number,
): PrismaticMoveHandle | null => {
	if (item.structType !== "Phyx.Prismatic") return null;
	const guide = getPrismaticGuidePoints(item);
	const candidates: Array<[PrismaticMoveHandle, BodyVector]> = [
		["worldPos", guide.worldPos],
		["lower", guide.lowerPoint],
		["upper", guide.upperPoint],
	];
	const distances = candidates.map(([handle, handlePoint]) => {
		const dx = handlePoint[0] - point[0];
		const dy = handlePoint[1] - point[1];
		return [handle, Math.hypot(dx, dy)] as const;
	});
	distances.sort((a, b) => a[1] - b[1]);
	return distances[0] && distances[0][1] <= tolerance ? distances[0][0] : null;
};

const getPulleyHandleWorldPosition = (
	document: BodyDocument,
	item: BodyStructDocument,
	handle: PulleyMoveHandle,
	physicsBodies?: BodyPhysicsSnapshot["bodies"],
): BodyVector | null => {
	if (handle === "anchorA" || handle === "anchorB") {
		return getJointAnchorWorldPosition(document, item, handle, physicsBodies);
	}
	return Array.isArray(item.fields[handle]) ? asVector(item.fields[handle]) : null;
};

const getPulleyMoveHandle = (
	document: BodyDocument,
	item: BodyStructDocument,
	point: BodyVector,
	tolerance: number,
	physicsBodies?: BodyPhysicsSnapshot["bodies"],
): PulleyMoveHandle | null => {
	if (item.structType !== "Phyx.Pulley") return null;
	const candidates: Array<[PulleyMoveHandle, number]> = [];
	for (const handle of ["anchorA", "anchorB", "groundAnchorA", "groundAnchorB"] as const) {
		const handlePoint = getPulleyHandleWorldPosition(document, item, handle, physicsBodies);
		if (!handlePoint) continue;
		const dx = handlePoint[0] - point[0];
		const dy = handlePoint[1] - point[1];
		candidates.push([handle, Math.hypot(dx, dy)]);
	}
	candidates.sort((a, b) => a[1] - b[1]);
	return candidates[0] && candidates[0][1] <= tolerance ? candidates[0][0] : null;
};

const getWorldPosMoveHandle = (
	item: BodyStructDocument,
	point: BodyVector,
	tolerance: number,
): WorldPosMoveHandle | null => {
	if ((item.structType !== "Phyx.Weld" && item.structType !== "Phyx.Friction") || !Array.isArray(item.fields.worldPos)) return null;
	const worldPos = asVector(item.fields.worldPos);
	const dx = worldPos[0] - point[0];
	const dy = worldPos[1] - point[1];
	return Math.hypot(dx, dy) <= tolerance ? "worldPos" : null;
};

const getJointAnchorHitField = (
	document: BodyDocument,
	item: BodyStructDocument,
	point: BodyVector,
	tolerance: number,
	physicsBodies?: BodyPhysicsSnapshot["bodies"],
): "anchorA" | "anchorB" | null => {
	const candidates: Array<["anchorA" | "anchorB", number]> = [];
	for (const fieldName of ["anchorA", "anchorB"] as const) {
		const anchor = getJointAnchorWorldPosition(document, item, fieldName, physicsBodies);
		if (!anchor) continue;
		const dx = anchor[0] - point[0];
		const dy = anchor[1] - point[1];
		candidates.push([fieldName, Math.sqrt(dx * dx + dy * dy)]);
	}
	candidates.sort((a, b) => a[1] - b[1]);
	return candidates[0] && candidates[0][1] <= tolerance ? candidates[0][0] : null;
};

const getJointAnchorBody = (document: BodyDocument, item: BodyStructDocument, fieldName: "anchorA" | "anchorB") => {
	const bodyName = fieldName === "anchorA" ? asString(item.fields.bodyA) : asString(item.fields.bodyB);
	return document.items.find((entry) => isBodyItem(entry) && getItemName(entry) === bodyName) ?? null;
};

const drawGizmoOverlay = (
	ctx: CanvasRenderingContext2D,
	document: BodyDocument,
	selectedId: string | null,
	mode: BodyGizmoMode,
	axisTool: BodyIconName,
	viewport: BodyViewport,
	width: number,
	height: number,
) => {
	if (mode === "select") return;
	const selectedContext = getSelectedBodyContext(document, selectedId);
	if (!selectedContext || isJointItem(selectedContext.item)) return;
	const center = getGizmoWorldCenter(document, selectedId);
	if (!center) return;
	const screen = worldToScreenPoint(center, viewport, width, height);
	const bounds = getGizmoScreenBounds(document, selectedId, viewport, width, height);
	ctx.save();
	ctx.lineWidth = 1.5;
	ctx.strokeStyle = "#ffffff";
	ctx.fillStyle = "#ffffff";
	const selectedPreviewColor = "#65d6ff";
	const radius = 34;
	if (mode === "move") {
		ctx.beginPath();
		ctx.arc(screen.x, screen.y, 3, 0, Math.PI * 2);
		ctx.fill();
		ctx.strokeStyle = selectedPreviewColor;
		ctx.beginPath();
		if (axisTool !== "fixY") {
			ctx.moveTo(screen.x, screen.y);
			ctx.lineTo(screen.x + radius, screen.y);
			ctx.lineTo(screen.x + radius - 8, screen.y - 5);
			ctx.moveTo(screen.x + radius, screen.y);
			ctx.lineTo(screen.x + radius - 8, screen.y + 5);
			ctx.moveTo(screen.x - radius * 0.55, screen.y);
			ctx.lineTo(screen.x, screen.y);
		}
		if (axisTool !== "fixX") {
			ctx.moveTo(screen.x, screen.y);
			ctx.lineTo(screen.x, screen.y - radius);
			ctx.lineTo(screen.x - 5, screen.y - radius + 8);
			ctx.moveTo(screen.x, screen.y - radius);
			ctx.lineTo(screen.x + 5, screen.y - radius + 8);
			ctx.moveTo(screen.x, screen.y + radius * 0.55);
			ctx.lineTo(screen.x, screen.y);
		}
		ctx.stroke();
	} else if (mode === "scale") {
		const box = bounds ?? {
			minX: screen.x - 18,
			maxX: screen.x + 18,
			minY: screen.y - 18,
			maxY: screen.y + 18,
			center: screen,
			width: 36,
			height: 36,
		};
		const padding = Math.max(6, Math.min(18, Math.max(box.width, box.height) * 0.12));
		const left = box.minX - padding;
		const right = box.maxX + padding;
		const top = box.minY - padding;
		const bottom = box.maxY + padding;
		ctx.strokeStyle = selectedPreviewColor;
		ctx.strokeRect(left, top, right - left, bottom - top);
		for (const point of [
			[left, top],
			[(left + right) / 2, top],
			[right, top],
			[right, (top + bottom) / 2],
			[right, bottom],
			[(left + right) / 2, bottom],
			[left, bottom],
			[left, (top + bottom) / 2],
		]) {
			ctx.fillRect(point[0] - 3, point[1] - 3, 6, 6);
		}
	} else if (mode === "rotate") {
		const rotateRadius = bounds
			? Math.max(28, Math.sqrt(bounds.width * bounds.width + bounds.height * bounds.height) * 0.5 + 18)
			: radius;
		const rotateCenter = screen;
		ctx.strokeStyle = selectedPreviewColor;
		ctx.beginPath();
		ctx.arc(rotateCenter.x, rotateCenter.y, rotateRadius, 0, Math.PI * 2);
		ctx.stroke();
		const angle = -Math.PI * 0.2;
		const end = { x: rotateCenter.x + Math.cos(angle) * rotateRadius, y: rotateCenter.y + Math.sin(angle) * rotateRadius };
		ctx.beginPath();
		ctx.moveTo(rotateCenter.x, rotateCenter.y);
		ctx.lineTo(end.x, end.y);
		ctx.lineTo(end.x - 9, end.y - 2);
		ctx.moveTo(end.x, end.y);
		ctx.lineTo(end.x - 4, end.y + 8);
		ctx.stroke();
		ctx.beginPath();
		ctx.arc(rotateCenter.x, rotateCenter.y, 3, 0, Math.PI * 2);
		ctx.fill();
	}
	ctx.restore();
};

const toolbarGroups: readonly (readonly BodyIconName[])[] = [
	["rect", "disk", "poly", "chain", "joint"],
	["delete"],
	["play"],
];

const viewToolNames: readonly BodyIconName[] = ["origin", "zoom", "fixX", "fixY"];
const gizmoModes = ["select", "move", "scale", "rotate"] as const;
type BodyGizmoMode = typeof gizmoModes[number];
const jointCreateOptions: readonly BodyCreateJointType[] = ["distance", "friction", "gear", "spring", "prismatic", "pulley", "revolute", "rope", "weld", "wheel"];

type PendingJointSelection = {
	bodyA?: string;
	bodyB?: string;
	jointA?: string;
	jointB?: string;
};

const getJointCandidateName = (item: BodyStructDocument | null) => (
	item ? asString(item.fields.name, getItemName(item)) : ""
);

const isGearJointCandidate = (item: BodyStructDocument | null) => (
	item?.structType === "Phyx.Revolute" || item?.structType === "Phyx.Prismatic"
);

const createsJointAfterBodyPick = (type: BodyCreateJointType | null) => (
	type === "distance" || type === "pulley" || type === "rope" || type === "spring"
);

export default memo(function BodyEditorCanvas(props: BodyEditorCanvasProps) {
	const { t } = useTranslation();
	const { document, faceAssets, resourceBasePath, servedResourceBasePath, width, height, active } = props;
	const { onCreateShape, onCreateSubShape, onCreateJoint, onDeleteSelected, onDuplicateSelected, onUpdateField, onBeginValueEdit, onEndValueEdit } = props;
	const { addAlert } = props;
	const { readOnly, canUndo, canRedo, onUndo, onRedo } = props;
	const canvasRef = useRef<HTMLCanvasElement | null>(null);
	const dragRef = useRef<{
		x: number;
		y: number;
		center: [number, number];
		mode: "pan" | "edit" | "vertex";
		selectedId: string | null;
		changed: boolean;
		startPointer: { x: number; y: number };
		startCanvasPointer: { x: number; y: number };
		startFields: Record<string, BodyLuaValue>;
		startGizmoCenter: BodyVector | null;
		startPointerAngle: number | null;
		lastPointerAngle: number | null;
		accumulatedRotation: number;
		jointAnchorField: "anchorA" | "anchorB" | null;
		prismaticHandle: PrismaticMoveHandle | null;
		pulleyHandle: PulleyMoveHandle | null;
		worldPosHandle: WorldPosMoveHandle | null;
		vertexIndex: number | null;
	} | null>(null);
	const [viewport, setViewport] = useState(defaultViewport);
	const [selectedId, setSelectedId] = useState<string | null>(() => document.items[0]?.id ?? null);
	const [activeTool, setActiveTool] = useState<BodyIconName>("menu");
	const [gizmoMode, setGizmoMode] = useState<BodyGizmoMode>("select");
	const [fixedSnap, setFixedSnap] = useState(false);
	const [fixedStep, setFixedStep] = useState(10);
	const [jointPanelOpen, setJointPanelOpen] = useState(false);
	const [pendingJointType, setPendingJointType] = useState<BodyCreateJointType | null>(null);
	const [pendingJointSelection, setPendingJointSelection] = useState<PendingJointSelection>({});
	const [pendingSubShape, setPendingSubShape] = useState<{ type: BodyCreateSubShapeType; bodyId: string } | null>(null);
	const [isPlaying, setIsPlaying] = useState(false);
	const [isPointerDragging, setIsPointerDragging] = useState(false);
	const [physicsSnapshot, setPhysicsSnapshot] = useState<BodyPhysicsSnapshot | null>(null);
	const [, setRuntimeDiagnostics] = useState<string[]>([]);
	const [faceChooserOpen, setFaceChooserOpen] = useState(false);
	const [copiedId, setCopiedId] = useState<string | null>(null);
	const [selectedVertexIndex, setSelectedVertexIndex] = useState<number | null>(null);
	const runtimeRef = useRef<BodyPhysicsRuntime | null>(null);
	const previousItemIdsRef = useRef(new Set(document.items.map((item) => item.id)));
	const listWidth = Math.min(280, Math.max(180, Math.floor(width * 0.28)));
	const toolbarWidth = 44;
	const topToolbarHeight = 44;
	const mainHeight = Math.max(1, height - topToolbarHeight);
	const editDisabled = readOnly || isPlaying;
	const showSidePanel = width >= 620;
	const actualListWidth = showSidePanel ? listWidth : 0;
	const canvasWidth = Math.max(1, width - actualListWidth - toolbarWidth);
	const toolbarGroupLabels = useMemo(() => [
		t("bodyEditor.toolbar.new", "New"),
		t("bodyEditor.toolbar.edit", "Edit"),
		t("bodyEditor.toolbar.test", "Test"),
	], [t]);
	const getIconLabel = useCallback((name: BodyIconName) => (
		t(`bodyEditor.icons.${name}`, iconLabels[name])
	), [t]);
	const getJointLabel = useCallback((type: BodyCreateJointType) => (
		t(`bodyEditor.joints.${type}`, jointCreateLabels[type])
	), [t]);
	const getGizmoModeLabel = useCallback((mode: BodyGizmoMode) => (
		t(`bodyEditor.gizmo.${mode}`, mode[0].toUpperCase() + mode.slice(1))
	), [t]);

	const selectedItem = useMemo(() => {
		const subSelection = parseSubShapeSelectionId(selectedId);
		if (subSelection) {
			const body = document.items.find((item) => item.id === subSelection.bodyId);
			const subShape = body ? asArray(body.fields.subShapes)[subSelection.index] : undefined;
			return subShape ? getSubShapeItem(subShape, subSelection.index, subSelection.bodyId) : null;
		}
		return document.items.find((item) => item.id === selectedId) ?? null;
	}, [document.items, selectedId]);

	const jointCreateHint = useMemo(() => {
		if (!pendingJointType) return t("bodyEditor.jointHint.selectType", "Select a joint type.");
		if (pendingJointType === "gear") {
			if (!pendingJointSelection.jointA) return t("bodyEditor.jointHint.selectJointA", "Click a Revolute or Prismatic joint for JointA.");
			return t("bodyEditor.jointHint.selectJointB", "JointA: {{jointA}}. Click another Revolute or Prismatic joint for JointB.", { jointA: pendingJointSelection.jointA });
		}
		if (!pendingJointSelection.bodyA) return t("bodyEditor.jointHint.selectBodyA", "Click a body for BodyA.");
		if (!pendingJointSelection.bodyB) {
			return createsJointAfterBodyPick(pendingJointType)
				? t("bodyEditor.jointHint.selectBodyBToCreate", "BodyA: {{bodyA}}. Click another body to create the {{joint}} joint.", { bodyA: pendingJointSelection.bodyA, joint: getJointLabel(pendingJointType) })
				: t("bodyEditor.jointHint.selectBodyB", "BodyA: {{bodyA}}. Click another body for BodyB.", { bodyA: pendingJointSelection.bodyA });
		}
		return t("bodyEditor.jointHint.placeJoint", "BodyA: {{bodyA}}, BodyB: {{bodyB}}. Click the preview to place the joint.", { bodyA: pendingJointSelection.bodyA, bodyB: pendingJointSelection.bodyB });
	}, [getJointLabel, pendingJointSelection.bodyA, pendingJointSelection.bodyB, pendingJointSelection.jointA, pendingJointType, t]);

	useEffect(() => {
		const vertexContext = getVertexEditContext(document, selectedId);
		setSelectedVertexIndex((current) => (
			vertexContext && current !== null && current < vertexContext.vertices.length ? current : null
		));
	}, [document, selectedId]);

	useEffect(() => {
		const previousItemIds = previousItemIdsRef.current;
		const currentItemIds = new Set(document.items.map((item) => item.id));
		const addedItem = document.items.find((item) => !previousItemIds.has(item.id));
		previousItemIdsRef.current = currentItemIds;
		if (addedItem) {
			setSelectedId(addedItem.id);
			return;
		}
		const selectedSubShape = parseSubShapeSelectionId(selectedId);
		const selectedExists = selectedId && (
			currentItemIds.has(selectedId) ||
			(selectedSubShape !== null && currentItemIds.has(selectedSubShape.bodyId))
		);
		if (!selectedExists && document.items.length > 0) {
			setSelectedId(document.items[0].id);
		}
	}, [document.items, selectedId]);

	useEffect(() => {
		if (!isPlaying || !active) {
			runtimeRef.current = null;
			setPhysicsSnapshot(null);
			setRuntimeDiagnostics([]);
			return;
		}
		const runtime = new BodyPhysicsRuntime(document);
		runtimeRef.current = runtime;
		setPhysicsSnapshot(runtime.snapshot());
		const diagnostics = runtime.getDiagnostics().map((item) => `${item.id}: ${item.message}`);
		setRuntimeDiagnostics(diagnostics);
		for (const message of diagnostics) {
			addAlert?.(message, "warning");
		}
		let frame = 0;
		let lastTime = performance.now();
		let accumulator = 0;
		const tick = (time: number) => {
			const delta = Math.min(0.1, (time - lastTime) / 1000);
			lastTime = time;
			accumulator += delta;
			let snapshot = runtime.snapshot();
			while (accumulator >= BODY_PHYSICS_TIME_STEP) {
				snapshot = runtime.step(BODY_PHYSICS_TIME_STEP);
				accumulator -= BODY_PHYSICS_TIME_STEP;
			}
			setPhysicsSnapshot(snapshot);
			frame = requestAnimationFrame(tick);
		};
		frame = requestAnimationFrame(tick);
		return () => {
			cancelAnimationFrame(frame);
			runtimeRef.current = null;
		};
	}, [active, addAlert, document, isPlaying]);

	useEffect(() => {
		const canvas = canvasRef.current;
		const context = canvas?.getContext("2d");
		if (!canvas || !context) return;
		const ratio = window.devicePixelRatio || 1;
		canvas.width = Math.max(1, Math.floor(canvasWidth * ratio));
		canvas.height = Math.max(1, Math.floor(mainHeight * ratio));
		canvas.style.width = `${canvasWidth}px`;
		canvas.style.height = `${mainHeight}px`;
		context.setTransform(ratio, 0, 0, ratio, 0, 0);
		renderBodyDocument(context, {
			document,
			faceAssets,
			viewport,
			selectedId,
			width: canvasWidth,
			height: mainHeight,
			physicsBodies: physicsSnapshot?.bodies,
			physicsJoints: physicsSnapshot?.joints,
		});
		if (!isPlaying) drawVertexOverlay(context, document, selectedId, selectedVertexIndex, viewport, canvasWidth, mainHeight);
		if (!isPlaying) drawGizmoOverlay(context, document, selectedId, gizmoMode, activeTool, viewport, canvasWidth, mainHeight);
	}, [activeTool, canvasWidth, document, faceAssets, gizmoMode, isPlaying, mainHeight, physicsSnapshot, selectedId, selectedVertexIndex, viewport]);

	const selectItem = useCallback((id: string) => {
		setSelectedId(id);
		if (!isPlaying) {
			const center = getGizmoWorldCenter(document, id);
			if (center) setViewport((current) => ({ ...current, center }));
		}
	}, [document, isPlaying]);

	const addSelectedVertex = useCallback(() => {
		if (editDisabled || !selectedId) return;
		const context = getVertexEditContext(document, selectedId);
		if (!context) return;
		const vertices = context.vertices.map((point) => [...point] as BodyVector);
		const selectedIndex = selectedVertexIndex !== null && selectedVertexIndex >= 0 && selectedVertexIndex < vertices.length
			? selectedVertexIndex
			: vertices.length - 1;
		const insertIndex = Math.max(0, selectedIndex + 1);
		const previous = vertices[selectedIndex] ?? [0, 0];
		const next = vertices[insertIndex] ?? (
			context.item.structType === "Phyx.Poly" || context.item.structType === "Phyx.SubPoly"
				? vertices[0]
				: null
		);
		const inserted: BodyVector = next
			? [(previous[0] + next[0]) / 2, (previous[1] + next[1]) / 2]
			: [previous[0] + 20, previous[1]];
		const nextVertices = [...vertices.slice(0, insertIndex), inserted, ...vertices.slice(insertIndex)];
		setSelectedVertexIndex(insertIndex);
		onUpdateField?.(selectedId, "vertices", nextVertices, true);
	}, [document, editDisabled, onUpdateField, selectedId, selectedVertexIndex]);

	const chooseFaceResource = useCallback((face: string) => {
		if (!selectedId) return;
		onUpdateField?.(selectedId, "face", face, true);
		setFaceChooserOpen(false);
	}, [onUpdateField, selectedId]);

	const removeSelectedVertex = useCallback(() => {
		if (editDisabled || !selectedId) return;
		const context = getVertexEditContext(document, selectedId);
		if (!context) return;
		const minCount = context.item.structType === "Phyx.Chain" || context.item.structType === "Phyx.SubChain" ? 2 : 3;
		if (context.vertices.length <= minCount) return;
		const removeIndex = selectedVertexIndex !== null && selectedVertexIndex >= 0 && selectedVertexIndex < context.vertices.length
			? selectedVertexIndex
			: context.vertices.length - 1;
		const nextVertices = context.vertices.filter((_, index) => index !== removeIndex);
		setSelectedVertexIndex(Math.min(removeIndex, nextVertices.length - 1));
		onUpdateField?.(selectedId, "vertices", nextVertices, true);
	}, [document, editDisabled, onUpdateField, selectedId, selectedVertexIndex]);

	const getBodyItemFromHitId = useCallback((hitId: string | null) => {
		if (!hitId) return null;
		const subSelection = parseSubShapeSelectionId(hitId);
		const bodyId = subSelection?.bodyId ?? hitId;
		const item = document.items.find((entry) => entry.id === bodyId) ?? null;
		return item && isBodyItem(item) ? item : null;
	}, [document.items]);

	const getGearJointItemFromHitId = useCallback((hitId: string | null) => {
		if (!hitId) return null;
		const item = document.items.find((entry) => entry.id === hitId) ?? null;
		return isGearJointCandidate(item) ? item : null;
	}, [document.items]);

	const runTool = useCallback((name: BodyIconName) => {
		if (name === "origin") {
			setViewport((current) => ({ ...current, center: [0, 0], scale: 1 }));
			setActiveTool("menu");
			setJointPanelOpen(false);
			setPendingJointType(null);
			setPendingJointSelection({});
			setPendingSubShape(null);
		} else if (name === "zoom") {
			setViewport((current) => ({ ...current, scale: current.scale >= 2 ? 0.5 : current.scale >= 1 ? 2 : 1 }));
			setActiveTool("menu");
			setJointPanelOpen(false);
			setPendingJointType(null);
			setPendingJointSelection({});
			setPendingSubShape(null);
		} else if (name === "delete") {
			if (editDisabled) return;
			onDeleteSelected?.(selectedId);
			setActiveTool("menu");
			setJointPanelOpen(false);
			setPendingJointType(null);
			setPendingJointSelection({});
			setPendingSubShape(null);
		} else if (isShapeTool(name)) {
			setJointPanelOpen(false);
			setPendingJointType(null);
			setPendingJointSelection({});
			setPendingSubShape(null);
			setActiveTool((current) => current === name ? "menu" : name);
			return;
		} else if (name === "joint") {
			setPendingSubShape(null);
			if (activeTool === "joint") {
				setJointPanelOpen(false);
				setPendingJointType(null);
				setPendingJointSelection({});
				setActiveTool("menu");
			} else {
				setJointPanelOpen(true);
				setPendingJointType(null);
				setPendingJointSelection({});
				setActiveTool("joint");
			}
		} else if (name === "play") {
			setIsPlaying((value) => !value);
			setActiveTool("menu");
			setJointPanelOpen(false);
			setPendingJointType(null);
			setPendingJointSelection({});
			setPendingSubShape(null);
		} else if (name === "fixX" || name === "fixY") {
			setActiveTool((current) => current === name ? "menu" : name);
			setJointPanelOpen(false);
			setPendingJointType(null);
			setPendingJointSelection({});
			setPendingSubShape(null);
		} else {
			setActiveTool(name);
		}
	}, [activeTool, editDisabled, onDeleteSelected, selectedId]);

	const onKeyDown = useCallback((event: React.KeyboardEvent<HTMLDivElement>) => {
		const target = event.target as HTMLElement | null;
		if (target && ["INPUT", "TEXTAREA", "SELECT"].includes(target.tagName)) return;
		const key = event.key.toLowerCase();
		const command = event.metaKey || event.ctrlKey;
		if (command && key === "z") {
			event.preventDefault();
			if (editDisabled) return;
			if (event.shiftKey) {
				if (canRedo) onRedo?.();
			} else if (canUndo) {
				onUndo?.();
			}
		} else if (command && key === "y") {
			event.preventDefault();
			if (editDisabled) return;
			if (canRedo) onRedo?.();
		} else if (key === " " || key === "spacebar") {
			event.preventDefault();
			setIsPlaying((value) => !value);
		} else if (event.key === "Delete" || event.key === "Backspace") {
			event.preventDefault();
			if (editDisabled) return;
			onDeleteSelected?.(selectedId);
		} else if (command && key === "c") {
			event.preventDefault();
			setCopiedId(selectedId);
		} else if (command && key === "v") {
			event.preventDefault();
			if (editDisabled) return;
			onDuplicateSelected?.(copiedId ?? selectedId);
		} else if (key === "1") {
			event.preventDefault();
			if (editDisabled) return;
			setJointPanelOpen(false);
			setPendingJointType(null);
			setPendingJointSelection({});
			setPendingSubShape(null);
			setActiveTool("rect");
		} else if (key === "2") {
			event.preventDefault();
			if (editDisabled) return;
			setJointPanelOpen(false);
			setPendingJointType(null);
			setPendingJointSelection({});
			setPendingSubShape(null);
			setActiveTool("disk");
		} else if (key === "3") {
			event.preventDefault();
			if (editDisabled) return;
			setJointPanelOpen(false);
			setPendingJointType(null);
			setPendingJointSelection({});
			setPendingSubShape(null);
			setActiveTool("poly");
		} else if (key === "4") {
			event.preventDefault();
			if (editDisabled) return;
			setJointPanelOpen(false);
			setPendingJointType(null);
			setPendingJointSelection({});
			setPendingSubShape(null);
			setActiveTool("chain");
		} else if (key === "j") {
			event.preventDefault();
			if (editDisabled) return;
			setPendingSubShape(null);
			setJointPanelOpen((value) => {
				if (value) {
					setPendingJointType(null);
					setPendingJointSelection({});
					setActiveTool("menu");
					return false;
				}
				setActiveTool("joint");
				return true;
			});
		}
	}, [canRedo, canUndo, copiedId, editDisabled, onDeleteSelected, onDuplicateSelected, onRedo, onUndo, selectedId]);

	const onWheel = useCallback((event: React.WheelEvent<HTMLCanvasElement>) => {
		event.preventDefault();
		setViewport((current) => {
			const wheel = Math.max(-1, Math.min(1, -event.deltaY / 100));
			const nextScale = Math.max(0.1, Math.min(8, current.scale + wheel * 0.1));
			return { ...current, scale: nextScale };
		});
	}, []);

	const updateGizmoEdit = useCallback((
		drag: NonNullable<typeof dragRef.current>,
		pointer: { x: number; y: number },
		canvasPointer: { x: number; y: number },
		worldDelta: BodyVector,
	) => {
		const targetId = drag.selectedId;
		if (!targetId) return;
		const context = getSelectedBodyContext(document, targetId);
		if (!context) return;
		const { item, body, isSubShape } = context;
		const start = drag.startFields;
		if (gizmoMode === "move") {
			const constrainedWorldDelta: BodyVector = activeTool === "fixX"
				? [worldDelta[0], 0]
				: activeTool === "fixY"
					? [0, worldDelta[1]]
					: worldDelta;
			if (isSubShape && body) {
				const localDelta = worldDeltaToBodyLocalDelta(body, constrainedWorldDelta);
				if (Array.isArray(start.center)) {
					const center = asVector(start.center);
					onUpdateField?.(targetId, "center", [
						snapValue(center[0] + localDelta[0], fixedSnap, fixedStep),
						snapValue(center[1] + localDelta[1], fixedSnap, fixedStep),
					], false);
				} else if (Array.isArray(start.vertices)) {
					const vertices = asArray(start.vertices).map((point) => {
						const vertex = asVector(point);
						return [
							snapValue(vertex[0] + localDelta[0], fixedSnap, fixedStep),
							snapValue(vertex[1] + localDelta[1], fixedSnap, fixedStep),
						];
					});
					onUpdateField?.(targetId, "vertices", vertices, false);
				}
				return;
			}
			if (isBodyItem(item) && Array.isArray(start.position)) {
				const position = asVector(start.position);
				onUpdateField?.(targetId, "position", [
					snapValue(position[0] + constrainedWorldDelta[0], fixedSnap, fixedStep),
					snapValue(position[1] + constrainedWorldDelta[1], fixedSnap, fixedStep),
				], false);
				return;
			}
			if (isJointItem(item)) {
				if (item.structType === "Phyx.Prismatic" && drag.prismaticHandle) {
					if (!Array.isArray(start.worldPos)) return;
					const worldPos = asVector(start.worldPos);
					if (drag.prismaticHandle === "worldPos") {
						onUpdateField?.(targetId, "worldPos", [
							snapValue(worldPos[0] + constrainedWorldDelta[0], fixedSnap, fixedStep),
							snapValue(worldPos[1] + constrainedWorldDelta[1], fixedSnap, fixedStep),
						], false);
						return;
					}
					const axis = normalizeVector(asVector(start.axis, [1, 0]));
					const fieldName = drag.prismaticHandle === "lower" ? "lowerTranslation" : "upperTranslation";
					const startBound = asNumber(start[fieldName], drag.prismaticHandle === "lower" ? -50 : 50);
					const sign = startBound < 0 || (startBound === 0 && drag.prismaticHandle === "lower") ? -1 : 1;
					const startPoint: BodyVector = [
						worldPos[0] + axis[0] * startBound,
						worldPos[1] + axis[1] * startBound,
					];
					const nextPoint: BodyVector = [
						startPoint[0] + constrainedWorldDelta[0],
						startPoint[1] + constrainedWorldDelta[1],
					];
					const dx = nextPoint[0] - worldPos[0];
					const dy = nextPoint[1] - worldPos[1];
					const length = Math.hypot(dx, dy);
					if (length <= 0.000001) return;
					const nextAxis: BodyVector = [dx / length * sign, dy / length * sign];
					onUpdateField?.(targetId, "axis", [
						snapValue(nextAxis[0], fixedSnap, Math.max(0.0001, fixedStep / 100)),
						snapValue(nextAxis[1], fixedSnap, Math.max(0.0001, fixedStep / 100)),
					], false);
					onUpdateField?.(targetId, fieldName, snapValue(length * sign, fixedSnap, fixedStep), false);
					return;
				}
				if (item.structType === "Phyx.Pulley" && drag.pulleyHandle) {
					const fieldName = drag.pulleyHandle;
					const value = start[fieldName];
					if (!Array.isArray(value)) return;
					const vector = asVector(value);
					if (fieldName === "groundAnchorA" || fieldName === "groundAnchorB") {
						onUpdateField?.(targetId, fieldName, [
							snapValue(vector[0] + constrainedWorldDelta[0], fixedSnap, fixedStep),
							snapValue(vector[1] + constrainedWorldDelta[1], fixedSnap, fixedStep),
						], false);
						return;
					}
					const anchorBody = getJointAnchorBody(document, item, fieldName);
					if (!anchorBody) return;
					const localDelta = worldDeltaToBodyLocalDelta(anchorBody, constrainedWorldDelta);
					onUpdateField?.(targetId, fieldName, [
						snapValue(vector[0] + localDelta[0], fixedSnap, fixedStep),
						snapValue(vector[1] + localDelta[1], fixedSnap, fixedStep),
					], false);
					return;
				}
				if (drag.worldPosHandle) {
					const value = start[drag.worldPosHandle];
					if (!Array.isArray(value)) return;
					const worldPos = asVector(value);
					onUpdateField?.(targetId, drag.worldPosHandle, [
						snapValue(worldPos[0] + constrainedWorldDelta[0], fixedSnap, fixedStep),
						snapValue(worldPos[1] + constrainedWorldDelta[1], fixedSnap, fixedStep),
					], false);
					return;
				}
				const fieldName = drag.jointAnchorField;
				const value = fieldName ? start[fieldName] : null;
				if (!fieldName || !Array.isArray(value)) return;
				const anchorBody = getJointAnchorBody(document, item, fieldName);
				if (!anchorBody) return;
				const localDelta = worldDeltaToBodyLocalDelta(anchorBody, constrainedWorldDelta);
				const vector = asVector(value);
				onUpdateField?.(targetId, fieldName, [
					snapValue(vector[0] + localDelta[0], fixedSnap, fixedStep),
					snapValue(vector[1] + localDelta[1], fixedSnap, fixedStep),
				], false);
			}
			return;
		}
		if (gizmoMode === "scale") {
			const dx = pointer.x - drag.startPointer.x;
			const dy = pointer.y - drag.startPointer.y;
			const rawFactor = Math.max(0.05, 1 + (dx - dy) / 180);
			const rawFactorX = Math.max(0.05, 1 + dx / 140);
			const rawFactorY = Math.max(0.05, 1 - dy / 140);
			const scaleStep = Math.max(0.01, fixedStep / 100);
			const factor = snapValue(rawFactor, fixedSnap, scaleStep);
			const factorX = activeTool === "fixY" ? 1 : snapValue(activeTool === "fixX" ? rawFactorX : rawFactor, fixedSnap, scaleStep);
			const factorY = activeTool === "fixX" ? 1 : snapValue(activeTool === "fixY" ? rawFactorY : rawFactor, fixedSnap, scaleStep);
			if (Array.isArray(start.size)) {
				const size = asVector(start.size, [1, 1]);
				onUpdateField?.(targetId, "size", [Math.max(1, size[0] * factorX), Math.max(1, size[1] * factorY)], false);
			} else if (typeof start.radius === "number") {
				onUpdateField?.(targetId, "radius", Math.max(1, start.radius * factor), false);
			} else if (Array.isArray(start.vertices)) {
				const vertices = asArray(start.vertices);
				const center = averageVertices(vertices);
				onUpdateField?.(targetId, "vertices", scaleVertices(vertices, center, factorX, factorY), false);
			}
			return;
		}
		if (gizmoMode === "rotate") {
			if (!drag.startGizmoCenter || drag.startPointerAngle === null || drag.lastPointerAngle === null) return;
			const center = worldToScreenPoint(drag.startGizmoCenter, viewport, canvasWidth, mainHeight);
			const angle = pointerAngleDegrees(center, canvasPointer);
			drag.accumulatedRotation += pointerAngleStepDelta(angle - drag.lastPointerAngle);
			drag.lastPointerAngle = angle;
			if (typeof start.angle === "number") {
				onUpdateField?.(targetId, "angle", snapValue(start.angle + drag.accumulatedRotation, fixedSnap, 5), false);
			} else if (Array.isArray(start.vertices)) {
				const vertices = asArray(start.vertices);
				const centerLocal = averageVertices(vertices);
				const rotation = snapValue(drag.accumulatedRotation, fixedSnap, 5);
				onUpdateField?.(targetId, "vertices", rotateVertices(vertices, centerLocal, rotation), false);
			}
		}
	}, [activeTool, canvasWidth, document, fixedSnap, fixedStep, gizmoMode, mainHeight, onUpdateField, viewport]);

	const updateVertexEdit = useCallback((
		drag: NonNullable<typeof dragRef.current>,
		worldDelta: BodyVector,
	) => {
		const targetId = drag.selectedId;
		const vertexIndex = drag.vertexIndex;
		if (!targetId || vertexIndex === null || !Array.isArray(drag.startFields.vertices)) return false;
		const context = getVertexEditContext(document, targetId);
		if (!context) return false;
		const localDelta = worldDeltaToBodyLocalDelta(context.body, worldDelta);
		const vertices = asArray(drag.startFields.vertices).map((point, index) => {
			const vertex = asVector(point);
			if (index !== vertexIndex) return vertex;
			return [
				snapValue(vertex[0] + localDelta[0], fixedSnap, fixedStep),
				snapValue(vertex[1] + localDelta[1], fixedSnap, fixedStep),
			];
		});
		onUpdateField?.(targetId, "vertices", vertices, false);
		return true;
	}, [document, fixedSnap, fixedStep, onUpdateField]);

	const onPointerDown = useCallback((event: React.PointerEvent<HTMLCanvasElement>) => {
		event.currentTarget.setPointerCapture(event.pointerId);
		setIsPointerDragging(true);
		const world: [number, number] = [
			viewport.center[0] + (event.nativeEvent.offsetX - canvasWidth / 2) / viewport.scale,
			viewport.center[1] - (event.nativeEvent.offsetY - mainHeight / 2) / viewport.scale,
		];
		if (isShapeTool(activeTool) && !isPlaying) {
			onCreateShape?.(activeTool, world);
			setActiveTool("menu");
			dragRef.current = null;
			setIsPointerDragging(false);
			event.currentTarget.releasePointerCapture(event.pointerId);
			return;
		}
		if (pendingSubShape && !isPlaying) {
			const parent = document.items.find((item) => item.id === pendingSubShape.bodyId);
			const nextSubShapeIndex = parent && isBodyItem(parent) ? asArray(parent.fields.subShapes).length : -1;
			onCreateSubShape?.(pendingSubShape.type, pendingSubShape.bodyId, world);
			if (nextSubShapeIndex >= 0) setSelectedId(getSubShapeSelectionId(pendingSubShape.bodyId, nextSubShapeIndex));
			setPendingSubShape(null);
			setActiveTool("menu");
			dragRef.current = null;
			setIsPointerDragging(false);
			event.currentTarget.releasePointerCapture(event.pointerId);
			return;
		}
		if (activeTool === "joint" && pendingJointType && !isPlaying) {
			const hitId = hitTestBodyDocument({
				document,
				viewport,
				selectedId,
				width: canvasWidth,
				height: mainHeight,
				physicsBodies: physicsSnapshot?.bodies,
				physicsJoints: physicsSnapshot?.joints,
			}, world);
			if (pendingJointType === "gear") {
				const candidate = getGearJointItemFromHitId(hitId);
				if (candidate) {
					const name = getJointCandidateName(candidate);
					setSelectedId(candidate.id);
					if (!pendingJointSelection.jointA) {
						setPendingJointSelection({ jointA: name });
					} else if (pendingJointSelection.jointA !== name) {
						onCreateJoint?.(pendingJointType, world, { jointA: pendingJointSelection.jointA, jointB: name });
						setActiveTool("menu");
						setJointPanelOpen(false);
						setPendingJointType(null);
						setPendingJointSelection({});
					}
				}
			} else if (!pendingJointSelection.bodyA || !pendingJointSelection.bodyB) {
				const candidate = getBodyItemFromHitId(hitId);
				if (candidate) {
					const name = getJointCandidateName(candidate);
					setSelectedId(candidate.id);
					if (!pendingJointSelection.bodyA) {
						setPendingJointSelection({ bodyA: name });
					} else if (pendingJointSelection.bodyA !== name) {
						if (createsJointAfterBodyPick(pendingJointType)) {
							onCreateJoint?.(pendingJointType, world, {
								bodyA: pendingJointSelection.bodyA,
								bodyB: name,
							});
							setActiveTool("menu");
							setJointPanelOpen(false);
							setPendingJointType(null);
							setPendingJointSelection({});
						} else {
							setPendingJointSelection({ bodyA: pendingJointSelection.bodyA, bodyB: name });
						}
					}
				}
			} else {
				onCreateJoint?.(pendingJointType, world, {
					bodyA: pendingJointSelection.bodyA,
					bodyB: pendingJointSelection.bodyB,
				});
				setActiveTool("menu");
				setJointPanelOpen(false);
				setPendingJointType(null);
				setPendingJointSelection({});
			}
			dragRef.current = null;
			setIsPointerDragging(false);
			event.currentTarget.releasePointerCapture(event.pointerId);
			return;
		}
		const vertexIndex = !isPlaying && !readOnly ? hitTestVertex(document, selectedId, world, viewport) : null;
		if (vertexIndex !== null) {
			const editContext = getVertexEditContext(document, selectedId);
			if (editContext) {
				setSelectedVertexIndex(vertexIndex);
				onBeginValueEdit?.();
				dragRef.current = {
					x: event.clientX,
					y: event.clientY,
					center: [...viewport.center],
					mode: "vertex",
					selectedId,
					changed: false,
					startPointer: { x: event.clientX, y: event.clientY },
					startCanvasPointer: { x: event.nativeEvent.offsetX, y: event.nativeEvent.offsetY },
					startFields: {
						vertices: editContext.vertices.map((point) => [...point]),
					},
					startGizmoCenter: null,
					startPointerAngle: null,
					lastPointerAngle: null,
					accumulatedRotation: 0,
					jointAnchorField: null,
					prismaticHandle: null,
					pulleyHandle: null,
					worldPosHandle: null,
					vertexIndex,
				};
				return;
			}
		}
		const hitId = isPlaying ? null : hitTestBodyDocument({
			document,
			viewport,
			selectedId,
			width: canvasWidth,
			height: mainHeight,
			physicsBodies: physicsSnapshot?.bodies,
			physicsJoints: physicsSnapshot?.joints,
		}, world);
		if (hitId) setSelectedId(hitId);
		const editId = hitId ?? selectedId;
		const editContext = gizmoMode !== "select" && !event.shiftKey && !isPlaying ? getSelectedBodyContext(document, editId) : null;
		const prismaticHandle = editContext && editContext.item.structType === "Phyx.Prismatic" && gizmoMode === "move"
			? getPrismaticMoveHandle(editContext.item, world, Math.max(8, 12 / viewport.scale))
			: null;
		const pulleyHandle = editContext && editContext.item.structType === "Phyx.Pulley" && gizmoMode === "move"
			? getPulleyMoveHandle(document, editContext.item, world, Math.max(8, 12 / viewport.scale), physicsSnapshot?.bodies)
			: null;
		const worldPosHandle = editContext && isJointItem(editContext.item) && gizmoMode === "move" && prismaticHandle === null && pulleyHandle === null
			? getWorldPosMoveHandle(editContext.item, world, Math.max(8, 12 / viewport.scale))
			: null;
		const jointAnchorField = editContext && isJointItem(editContext.item) && gizmoMode === "move" && prismaticHandle === null && pulleyHandle === null && worldPosHandle === null
			? getJointAnchorHitField(document, editContext.item, world, Math.max(8, 12 / viewport.scale), physicsSnapshot?.bodies)
			: null;
		const shouldEdit = editContext !== null && (!isJointItem(editContext.item) || jointAnchorField !== null || prismaticHandle !== null || pulleyHandle !== null || worldPosHandle !== null);
		if (shouldEdit) onBeginValueEdit?.();
		const startGizmoCenter = shouldEdit ? getGizmoWorldCenter(document, editId) : null;
		const startGizmoScreen = startGizmoCenter ? worldToScreenPoint(startGizmoCenter, viewport, canvasWidth, mainHeight) : null;
		const startPointer = { x: event.clientX, y: event.clientY };
		const startCanvasPointer = { x: event.nativeEvent.offsetX, y: event.nativeEvent.offsetY };
		dragRef.current = {
			x: event.clientX,
			y: event.clientY,
			center: [...viewport.center],
			mode: shouldEdit ? "edit" : "pan",
			selectedId: shouldEdit ? editId : hitId,
			changed: false,
			startPointer,
			startCanvasPointer,
			startFields: Object.fromEntries(Object.entries(editContext?.item.fields ?? {}).map(([key, value]) => [key, Array.isArray(value) ? JSON.parse(JSON.stringify(value)) as BodyLuaValue : value])),
			startGizmoCenter,
			startPointerAngle: startGizmoScreen ? pointerAngleDegrees(startGizmoScreen, startCanvasPointer) : null,
			lastPointerAngle: startGizmoScreen ? pointerAngleDegrees(startGizmoScreen, startCanvasPointer) : null,
			accumulatedRotation: 0,
			jointAnchorField,
			prismaticHandle,
			pulleyHandle,
			worldPosHandle,
			vertexIndex: null,
		};
	}, [activeTool, canvasWidth, document, getBodyItemFromHitId, getGearJointItemFromHitId, gizmoMode, isPlaying, mainHeight, onBeginValueEdit, onCreateJoint, onCreateShape, onCreateSubShape, pendingJointSelection, pendingJointType, pendingSubShape, physicsSnapshot, readOnly, selectedId, viewport]);

	const onPointerMove = useCallback((event: React.PointerEvent<HTMLCanvasElement>) => {
		const drag = dragRef.current;
		if (!drag) return;
		if (drag.mode === "edit") {
			const worldDelta: BodyVector = [
				(event.clientX - drag.startPointer.x) / viewport.scale,
				-(event.clientY - drag.startPointer.y) / viewport.scale,
			];
			if (worldDelta[0] !== 0 || worldDelta[1] !== 0) {
				drag.changed = true;
				updateGizmoEdit(drag, { x: event.clientX, y: event.clientY }, { x: event.nativeEvent.offsetX, y: event.nativeEvent.offsetY }, worldDelta);
			}
			return;
		}
		if (drag.mode === "vertex") {
			const worldDelta: BodyVector = [
				(event.clientX - drag.startPointer.x) / viewport.scale,
				-(event.clientY - drag.startPointer.y) / viewport.scale,
			];
			if (worldDelta[0] !== 0 || worldDelta[1] !== 0) {
				drag.changed = updateVertexEdit(drag, worldDelta) || drag.changed;
			}
			return;
		}
		const dx = (event.clientX - drag.x) / viewport.scale;
		const dy = (event.clientY - drag.y) / viewport.scale;
		setViewport((current) => ({
			...current,
			center: [drag.center[0] - dx, drag.center[1] + dy],
		}));
	}, [updateGizmoEdit, updateVertexEdit, viewport.scale]);

	const onPointerUp = useCallback((event: React.PointerEvent<HTMLCanvasElement>) => {
		const drag = dragRef.current;
		event.currentTarget.releasePointerCapture(event.pointerId);
		if (drag?.mode === "edit" || drag?.mode === "vertex") {
			onEndValueEdit?.(drag.changed);
		}
		dragRef.current = null;
		setIsPointerDragging(false);
	}, [onEndValueEdit]);

	const setMotorDirection = useCallback((id: string, direction: -1 | 0 | 1) => {
		if (runtimeRef.current?.setMotorDirection(id, direction)) {
			setPhysicsSnapshot(runtimeRef.current.snapshot());
		}
	}, []);

	return (
		<div
			tabIndex={0}
			onKeyDown={onKeyDown}
			style={{ display: active ? "flex" : "none", width, height, minWidth: 0, minHeight: 0, flexDirection: "column", position: "relative", outline: "none" }}
		>
			<div
				style={{
					height: topToolbarHeight,
					flexShrink: 0,
					display: "flex",
					alignItems: "center",
					gap: 8,
					paddingTop: 2,
					paddingLeft: 10,
					boxSizing: "border-box",
					background: "#1a1a1a",
					borderBottom: "1px solid #2b2b2b",
				}}
			>
				<div style={{ display: "flex", alignItems: "center", gap: 6 }}>
					<span style={{ color: "#9aa4af", fontSize: 12, marginRight: 2 }}>{t("bodyEditor.toolbar.view", "View")}</span>
					{viewToolNames.map((name) => {
						const selected = activeTool === name;
						return (
							<Fragment key={name}>
								<button
									type="button"
									title={getIconLabel(name)}
									aria-label={getIconLabel(name)}
									onClick={() => runTool(name)}
									style={{
										width: 30,
										height: 30,
										border: "1px solid " + (selected ? "#fac03d" : "#343434"),
										background: selected ? "#5f4917" : "#303030",
										padding: 3,
										cursor: "pointer",
									}}
								>
									<BodyIconGlyph name={name} active={selected} />
								</button>
								{name === "zoom" ? <span style={{ color: "#d7d7d7", fontSize: 12, width: 58, flexShrink: 0, textAlign: "center" }}>{t("bodyEditor.zoomValue", { zoom: (viewport.scale * 100).toFixed(0) })}</span> : null}
							</Fragment>
						);
					})}
				</div>
				<div style={{ display: "flex", alignItems: "center", gap: 4, paddingLeft: 4 }}>
					<span style={{ color: "#9aa4af", fontSize: 12, marginRight: 2 }}>{t("bodyEditor.toolbar.tool", "Tool")}</span>
					{gizmoModes.map((mode) => {
						const selected = gizmoMode === mode;
						return (
							<button
								key={mode}
								type="button"
								disabled={editDisabled}
								onClick={() => setGizmoMode(mode)}
								style={{
									height: 30,
									minWidth: 52,
									border: "1px solid " + (selected ? "#fac03d" : "#343434"),
									background: selected ? "#5f4917" : "#303030",
									color: selected ? "#ffe7ad" : "#d7d7d7",
									cursor: editDisabled ? "default" : "pointer",
									opacity: editDisabled ? 0.55 : 1,
								}}
							>
								{getGizmoModeLabel(mode)}
							</button>
						);
					})}
					<label style={{ display: "flex", alignItems: "center", gap: 4, color: "#d7d7d7", fontSize: 12, marginLeft: 4 }}>
						<input
							type="checkbox"
							checked={fixedSnap}
							disabled={editDisabled}
							onChange={(event) => setFixedSnap(event.currentTarget.checked)}
						/>
						{t("bodyEditor.fixed", "Fixed")}
					</label>
					<input
						type="number"
						value={formatNumberInput(fixedStep)}
						min={0.1}
						step={1}
						title={t("bodyEditor.fixedEditStep", "Fixed edit step")}
						disabled={editDisabled}
						onChange={(event) => {
							const next = Number(event.currentTarget.value);
							if (Number.isFinite(next) && next > 0) setFixedStep(next);
						}}
						style={{
							width: 54,
							height: 28,
							boxSizing: "border-box",
							background: "#181818",
							color: "#d7d7d7",
							border: "1px solid #343434",
							opacity: editDisabled ? 0.55 : 1,
						}}
					/>
				</div>
				<Stack direction="row" spacing={1}>
					<Tooltip title={t("bodyEditor.undo", "Undo")}>
						<span>
							<IconButton
								size="small"
								disabled={editDisabled || !canUndo}
								onClick={onUndo}
								sx={{
									width: 30,
									height: 30,
									border: "1px solid #343434",
									borderRadius: 0,
									background: "#303030",
									color: "#d7d7d7",
									"&:hover": { background: "#383838" },
									"&.Mui-disabled": {
										color: "rgba(215, 215, 215, 0.32)",
										borderColor: "#2b2b2b",
										background: "#252525",
									},
								}}
							>
								<UndoIcon fontSize="small" />
							</IconButton>
						</span>
					</Tooltip>
					<Tooltip title={t("bodyEditor.redo", "Redo")}>
						<span>
							<IconButton
								size="small"
								disabled={editDisabled || !canRedo}
								onClick={onRedo}
								sx={{
									width: 30,
									height: 30,
									border: "1px solid #343434",
									borderRadius: 0,
									background: "#303030",
									color: "#d7d7d7",
									"&:hover": { background: "#383838" },
									"&.Mui-disabled": {
										color: "rgba(215, 215, 215, 0.32)",
										borderColor: "#2b2b2b",
										background: "#252525",
									},
								}}
							>
								<RedoIcon fontSize="small" />
							</IconButton>
						</span>
					</Tooltip>
				</Stack>
			</div>
			<div style={{ display: "flex", flex: 1, minHeight: 0, position: "relative" }}>
				<div style={{
					width: toolbarWidth,
					height: mainHeight,
					background: "#1a1a1a",
					borderRight: "1px solid #2b2b2b",
					display: "flex",
					flexDirection: "column",
					alignItems: "center",
					paddingTop: 6,
					gap: 7,
				}}>
					{toolbarGroups.map((group, groupIndex) => (
						<div
							key={group.join("-")}
							style={{
								display: "flex",
								flexDirection: "column",
								alignItems: "center",
								gap: 4,
								paddingBottom: groupIndex === toolbarGroups.length - 1 ? 0 : 7,
								borderBottom: groupIndex === toolbarGroups.length - 1 ? "none" : "1px solid #333",
							}}
						>
							<div
								style={{
									width: 34,
									color: "#8f9aa6",
									fontSize: 9,
									lineHeight: "12px",
									textAlign: "center",
									textTransform: "uppercase",
									letterSpacing: 0,
									overflow: "hidden",
									whiteSpace: "nowrap",
								}}
							>
								{toolbarGroupLabels[groupIndex]}
							</div>
							{group.map((name) => {
								const selected = name === "play" ? isPlaying : activeTool === name;
								const iconName = name === "play" && isPlaying ? "stop" : name;
								const disabled = editDisabled && name !== "play";
								return (
									<button
										key={name}
										type="button"
										title={getIconLabel(iconName)}
										aria-label={getIconLabel(iconName)}
										disabled={disabled}
										onClick={() => runTool(name)}
										style={{
											width: 34,
											height: 34,
											border: "1px solid " + (selected ? "#fac03d" : "#2b2b2b"),
											background: selected ? "#5f4917" : "#252525",
											padding: 4,
											cursor: disabled ? "default" : "pointer",
											opacity: disabled ? 0.55 : 1,
										}}
									>
										<BodyIconGlyph name={iconName} active={selected} />
									</button>
								);
							})}
						</div>
					))}
				</div>
				<canvas
					ref={canvasRef}
					width={canvasWidth}
					height={mainHeight}
					onWheel={onWheel}
					onPointerDown={onPointerDown}
					onPointerMove={onPointerMove}
					onPointerUp={onPointerUp}
					onPointerCancel={onPointerUp}
					style={{
						width: canvasWidth,
						height: mainHeight,
						cursor: isShapeTool(activeTool) || pendingSubShape || (activeTool === "joint" && pendingJointType) ? "crosshair" : gizmoMode !== "select" ? "crosshair" : isPointerDragging ? "grabbing" : "grab",
						touchAction: "none",
						background: "#1f1f1f",
					}}
				/>
				{isPlaying ? (
					<div style={{
						position: "absolute",
						left: toolbarWidth + 10,
						top: 10,
						background: "rgba(20, 20, 20, 0.86)",
						border: "1px solid #3a3a3a",
						color: "#d7d7d7",
						fontSize: 12,
						padding: "4px 8px",
						pointerEvents: "none",
					}}>
						{t("bodyEditor.playing", "Play")} {physicsSnapshot ? physicsSnapshot.time.toFixed(2) + "s" : ""}
					</div>
				) : null}
				{isPlaying && physicsSnapshot && physicsSnapshot.motorControls.length > 0 ? (
					<div style={{
						position: "absolute",
						left: toolbarWidth + 10,
						top: 42,
						display: "flex",
						flexDirection: "column",
						gap: 4,
						background: "rgba(20, 20, 20, 0.86)",
						border: "1px solid #3a3a3a",
						padding: 6,
					}}>
						{physicsSnapshot.motorControls.map((control) => (
							<div key={control.id} style={{ display: "flex", alignItems: "center", gap: 4 }}>
								<span style={{ color: "#d7d7d7", fontSize: 12, minWidth: 92, maxWidth: 140, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
									{control.name}
								</span>
								{([
									[-1, "-"],
									[0, "0"],
									[1, "+"],
								] as const).map(([direction, label]) => (
									<button
										key={direction}
										type="button"
										onClick={() => setMotorDirection(control.id, direction)}
										style={{
											width: 24,
											height: 22,
											border: "1px solid #3a3a3a",
											background: "#252525",
											color: "#d7d7d7",
											cursor: "pointer",
										}}
									>
										{label}
									</button>
								))}
							</div>
						))}
					</div>
				) : null}
				{jointPanelOpen ? (
					<div style={{
						position: "absolute",
						left: toolbarWidth + 8,
						top: 8,
						width: 220,
						display: "grid",
						gridTemplateColumns: "1fr 1fr",
						gap: 4,
						background: "rgba(25, 25, 25, 0.96)",
						border: "1px solid #3a3a3a",
						padding: 8,
						boxShadow: "0 8px 20px rgba(0,0,0,0.35)",
						zIndex: 2,
					}}>
						{jointCreateOptions.map((type) => {
							const selected = pendingJointType === type;
							const label = getJointLabel(type);
							return (
								<button
									key={type}
									type="button"
									onClick={() => {
										if (pendingJointType === type) {
											setPendingJointType(null);
											setPendingJointSelection({});
											setActiveTool("joint");
										} else {
											setPendingJointType(type);
											setPendingJointSelection({});
											setActiveTool("joint");
										}
									}}
									style={{
										height: 28,
										background: selected ? "#5f4917" : "#252525",
										color: selected ? "#ffe7ad" : "#d7d7d7",
										border: "1px solid " + (selected ? "#fac03d" : "#3a3a3a"),
										cursor: "pointer",
									}}
								>
									{label}
								</button>
							);
						})}
						<div style={{ gridColumn: "1 / -1", color: "#8f9aa6", fontSize: 11, lineHeight: "15px", paddingTop: 2 }}>
							{jointCreateHint}
						</div>
					</div>
				) : null}
				<div style={{
					display: showSidePanel ? "flex" : "none",
					flexDirection: "column",
					width: actualListWidth,
					height: mainHeight,
					overflow: "hidden",
					borderLeft: "1px solid #2b2b2b",
					background: "#1a1a1a",
					boxSizing: "border-box",
				}}>
					<div style={{ flex: "0 0 42%", minHeight: 120, overflow: "hidden", borderBottom: "1px solid #2b2b2b" }}>
						<MacScrollbar skin="dark" style={{ width: "100%", height: "100%" }}>
							{document.items.map((item) => {
								const selected = item.id === selectedId;
								return (
									<div key={item.id} style={{ padding: "4px 8px 0" }}>
										<button
											type="button"
											onClick={() => selectItem(item.id)}
											style={{
												width: "100%",
												minHeight: 44,
												display: "flex",
												alignItems: "center",
												gap: 10,
												textAlign: "left",
												padding: "7px 10px",
												border: "1px solid " + (selected ? "#fac03d" : "#3f3f3f"),
												background: selected ? "rgba(250, 192, 61, 0.16)" : "rgba(24, 24, 24, 0.7)",
												color: selected ? "#ffe7ad" : "#d7d7d7",
												cursor: "pointer",
												boxSizing: "border-box",
											}}
										>
											<BodyIconGlyph name={getStructIconName(item)} active={selected} />
											<div style={{ minWidth: 0, flex: 1 }}>
												<div style={{ fontSize: 13, color: selected ? "#fac03d" : "#d7d7d7", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", textAlign: "right" }}>{getItemName(item)}</div>
												<div style={{ fontSize: 10, color: selected ? "#ffd777" : "#8f9aa6", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", textAlign: "right" }}>{item.structType.replace("Phyx.", "")}</div>
											</div>
										</button>
										{isBodyItem(item) ? asArray(item.fields.subShapes).map((subShape, subIndex) => {
											const subItem = getSubShapeItem(subShape, subIndex, item.id);
											if (!subItem) return null;
											const subSelected = subItem.id === selectedId;
											return (
												<button
													key={subItem.id}
													type="button"
													onClick={() => selectItem(subItem.id)}
													style={{
														width: "calc(100% - 18px)",
														minHeight: 34,
														margin: "4px 0 0 18px",
														display: "flex",
														alignItems: "center",
														gap: 8,
														textAlign: "left",
														padding: "5px 8px",
														border: "1px solid " + (subSelected ? "#fac03d" : "#333"),
														background: subSelected ? "rgba(250, 192, 61, 0.14)" : "#1b1b1b",
														color: subSelected ? "#ffe7ad" : "#c8c8c8",
														cursor: "pointer",
														boxSizing: "border-box",
													}}
												>
													<BodyIconGlyph name={getStructIconName(subItem)} active={subSelected} />
													<div style={{ minWidth: 0, flex: 1 }}>
														<div style={{ fontSize: 12, color: subSelected ? "#fac03d" : "#c8c8c8", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", textAlign: "right" }}>{t("bodyEditor.subShapeIndex", "SubShape {{index}}", { index: subIndex + 1 })}</div>
														<div style={{ fontSize: 10, color: subSelected ? "#ffd777" : "#8f9aa6", whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", textAlign: "right" }}>{subItem.structType.replace("Phyx.", "")}</div>
													</div>
												</button>
											);
										}) : null}
									</div>
								);
							})}
							{selectedItem ? null : (
								<div style={{ padding: 12, color: "#8f9aa6", fontSize: 13 }}>{t("bodyEditor.noItems", "No BodyEx items")}</div>
							)}
						</MacScrollbar>
					</div>
					<div style={{ flex: "1 1 58%", minHeight: 0, overflow: "hidden", boxSizing: "border-box" }}>
						<MacScrollbar skin="dark" style={{ width: "100%", height: "100%" }}>
							<div style={{ paddingBottom: 96 }}>
								{selectedItem ? (
									<PropertyPanel
										document={document}
										item={selectedItem}
										readOnly={editDisabled}
										canAddSubShape={!parseSubShapeSelectionId(selectedId) && isBodyItem(selectedItem)}
										pendingSubShapeType={pendingSubShape?.bodyId === selectedItem.id ? pendingSubShape.type : null}
										selectedVertexIndex={selectedVertexIndex}
										onAddVertex={addSelectedVertex}
										onRemoveVertex={removeSelectedVertex}
										onCreateSubShape={(type) => {
											setJointPanelOpen(false);
											setPendingJointType(null);
											setPendingJointSelection({});
											setPendingSubShape((current) => (
												current?.bodyId === selectedItem.id && current.type === type
													? null
													: { type, bodyId: selectedItem.id }
											));
											setActiveTool("menu");
										}}
										onUpdateField={(fieldName, value, recordUndo) => onUpdateField?.(selectedItem.id, fieldName, value, recordUndo)}
										onChooseFace={() => setFaceChooserOpen(true)}
										onBeginValueEdit={onBeginValueEdit}
										onEndValueEdit={onEndValueEdit}
									/>
								) : null}
							</div>
						</MacScrollbar>
					</div>
				</div>
			</div>
			<FaceResourceDialog
				open={faceChooserOpen}
				resourceBasePath={resourceBasePath}
				servedResourceBasePath={servedResourceBasePath}
				onClose={() => setFaceChooserOpen(false)}
				onSelect={chooseFaceResource}
				addAlert={addAlert}
			/>
		</div>
	);
});

const valueToText = (value: BodyLuaValue | undefined) => {
	if (Array.isArray(value)) return JSON.stringify(value);
	if (value === null || value === undefined) return "";
	return String(value);
};

const parseValue = (field: BodyStructField, text: string, checked: boolean): BodyLuaValue => {
	switch (field.kind) {
		case "boolean":
			return checked;
		case "number": {
			const value = Number(text);
			return Number.isFinite(value) ? value : 0;
		}
		case "vector":
		case "size":
		case "vertices":
		case "subShapes":
			try {
				const parsed = JSON.parse(text);
				return Array.isArray(parsed) ? parsed as BodyLuaValue : [];
			} catch {
				return [];
			}
		default:
			return text;
	}
};

const parseNumberInput = (text: string, fallback: number, constraint?: BodyNumberConstraint) => {
	const value = Number(text);
	return applyBodyNumberConstraint(Number.isFinite(value) ? value : fallback, constraint);
};

const formatNumberInput = (value: number) => (
	Number.isInteger(value) ? String(value) : value.toFixed(4).replace(/\.?0+$/, "")
);

const formatFieldPrefix = (name: string) => {
	return name.length > 0 ? name[0].toUpperCase() + name.slice(1) : name;
};

const getBodyFieldLabel = (translate: (key: string, fallback: string) => string, name: string) => (
	translate(`bodyEditor.fields.${name}`, formatFieldPrefix(name))
);

const NumericField = memo(function NumericField(props: {
	label: string;
	value: number;
	readOnly: boolean;
	constraint?: BodyNumberConstraint;
	onCommit: (value: number, recordUndo?: boolean) => void;
	onBeginStep?: () => void;
	onEndStep?: (changed: boolean) => void;
}) {
	const { label, value, readOnly, constraint, onCommit, onBeginStep, onEndStep } = props;
	const stepRef = useRef<{ value: number; changed: boolean } | null>(null);
	const endStep = useCallback(() => {
		const step = stepRef.current;
		if (!step) return;
		stepRef.current = null;
		onEndStep?.(step.changed);
	}, [onEndStep]);
	const beginStep = useCallback(() => {
		stepRef.current = { value, changed: false };
		onBeginStep?.();
	}, [onBeginStep, value]);
	const commitNumber = useCallback((next: number, recordUndo: boolean) => {
		const step = stepRef.current;
		if (step) {
			step.changed = step.changed || next !== step.value;
			step.value = next;
		}
		onCommit(next, recordUndo && !step);
	}, [onCommit]);
	return (
		<label style={{ display: "block", color: "#8f9aa6", fontSize: 11, margin: "8px 0 3px" }}>
			{label}
			<div style={{ position: "relative", marginTop: 3 }}>
					<input
						type="number"
						value={formatNumberInput(value)}
					min={constraint?.min}
					max={constraint?.max}
					step={constraint?.step}
					readOnly={readOnly}
					onPointerDown={readOnly ? undefined : beginStep}
					onPointerUp={endStep}
					onPointerCancel={endStep}
					onChange={(event) => {
						if (!readOnly) commitNumber(parseNumberInput(event.currentTarget.value, value, constraint), false);
					}}
					onBlur={(event) => {
						if (readOnly) return;
						commitNumber(parseNumberInput(event.currentTarget.value, value, constraint), true);
						endStep();
					}}
					style={{
						width: "100%",
						boxSizing: "border-box",
						background: "#181818",
						color: "#d7d7d7",
						border: "1px solid #3a3a3a",
						minHeight: 26,
						opacity: readOnly ? 0.72 : 1,
					}}
				/>
			</div>
		</label>
	);
});

type LoadedClipSlices = {
	entry: FaceResourceEntry;
	rects: ActionClipRect[];
	atlasImage: HTMLImageElement;
	objectUrl: string;
};

const FaceResourceDialog = memo(function FaceResourceDialog(props: {
	open: boolean;
	resourceBasePath: string;
	servedResourceBasePath: string;
	onClose: () => void;
	onSelect: (face: string) => void;
	addAlert?: (msg: string, type: BodyEditorAlertType, openLog?: boolean) => void;
}) {
	const { t } = useTranslation();
	const { open, resourceBasePath, servedResourceBasePath, onClose, onSelect, addAlert } = props;
	const [resources, setResources] = useState<FaceResourceEntry[]>([]);
	const [selectedClip, setSelectedClip] = useState<LoadedClipSlices | null>(null);
	const [loadingClipPath, setLoadingClipPath] = useState<string | null>(null);
	const [loading, setLoading] = useState(false);
	const [filter, setFilter] = useState("");
	useEffect(() => {
		if (!open) return;
		let cancelled = false;
		setLoading(true);
		setFilter("");
		findFaceResourceFiles(resourceBasePath).then((items) => {
			if (!cancelled) setResources(items);
		}).catch((error) => {
			if (!cancelled) {
				setResources([]);
				addAlert?.(error instanceof Error ? error.message : t("bodyEditor.failedSearchFaceResources", "Failed to search face resources."), "warning");
			}
		}).finally(() => {
			if (!cancelled) setLoading(false);
		});
		return () => {
			cancelled = true;
		};
	}, [addAlert, open, resourceBasePath, t]);
	const visibleResources = useMemo(() => {
		const query = filter.trim().toLowerCase();
		return query === "" ? resources : resources.filter((entry) => entry.relative.toLowerCase().includes(query));
	}, [filter, resources]);
	const selectFace = useCallback((face: string) => {
		onSelect(face);
		setSelectedClip(null);
	}, [onSelect]);
	const openClipSlices = useCallback(async (entry: FaceResourceEntry) => {
		setLoadingClipPath(entry.path);
		try {
			const res = await Service.read({ path: entry.path });
			if (!res.success) throw new Error(t("bodyEditor.failedReadClip", "Failed to read clip: {{file}}", { file: entry.relative }));
			const clip = parseLegacyClip(res.content, entry.path);
			const loaded = await loadFaceImageElement(clip.texturePath, servedResourceBasePath);
			setSelectedClip({
				entry,
				rects: Object.values(clip.rects).sort((a, b) => a.name.localeCompare(b.name)),
				atlasImage: loaded.image,
				objectUrl: loaded.objectUrl,
			});
		} catch (error) {
			addAlert?.(error instanceof Error ? error.message : t("bodyEditor.failedLoadClip", "Failed to load clip: {{file}}", { file: entry.relative }), "warning");
		} finally {
			setLoadingClipPath(null);
		}
	}, [addAlert, servedResourceBasePath, t]);
	useEffect(() => () => {
		if (selectedClip?.objectUrl) URL.revokeObjectURL(selectedClip.objectUrl);
	}, [selectedClip]);
	return (
		<>
			<Dialog open={open} onClose={onClose} fullWidth maxWidth="sm">
				<DialogTitle>{t("bodyEditor.chooseFaceResource", "Choose Face Resource")}</DialogTitle>
				<DialogContent sx={{ display: "flex", flexDirection: "column", gap: 1.25, background: "#181818" }}>
					<div style={{ color: "#8f9aa6", fontSize: 12 }}>{resourceBasePath}</div>
					<TextField
						size="small"
						value={filter}
						onChange={(event) => setFilter(event.currentTarget.value)}
						placeholder={t("bodyEditor.filterResources", "Filter resources")}
					/>
					<div style={{ minHeight: 280, maxHeight: 460, overflow: "auto", border: "1px solid #2b2b2b" }}>
						{loading ? (
							<div style={{ color: "#8f9aa6", padding: 12 }}>{t("bodyEditor.searching", "Searching...")}</div>
						) : visibleResources.length === 0 ? (
							<div style={{ color: "#8f9aa6", padding: 12 }}>{t("bodyEditor.noFaceResources", "No image or clip resources")}</div>
						) : visibleResources.map((entry) => (
							<button
								key={`${entry.kind}:${entry.relative}`}
								type="button"
								onClick={() => {
									if (entry.kind === "clip") {
										openClipSlices(entry);
									} else {
										selectFace(entry.relative);
									}
								}}
								disabled={loadingClipPath !== null}
								style={{
									width: "100%",
									display: "flex",
									alignItems: "center",
									justifyContent: "space-between",
									gap: 8,
									padding: "8px 10px",
									border: "none",
									borderBottom: "1px solid #2b2b2b",
									background: "#1f1f1f",
									color: "#d7d7d7",
									cursor: loadingClipPath === null ? "pointer" : "default",
									opacity: loadingClipPath !== null && loadingClipPath !== entry.path ? 0.55 : 1,
									textAlign: "left",
								}}
							>
								<span style={{ minWidth: 0, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{entry.relative}</span>
								<span style={{ flex: "0 0 auto", color: entry.kind === "clip" ? "#fac03d" : "#8f9aa6", fontSize: 11 }}>
									{loadingClipPath === entry.path ? t("bodyEditor.loadingShort", "Loading...") : entry.kind}
								</span>
							</button>
						))}
					</div>
				</DialogContent>
				<DialogActions>
					<Button onClick={onClose}>{t("action.cancel", "Cancel")}</Button>
				</DialogActions>
			</Dialog>
			<ClipSliceDialog
				open={selectedClip !== null}
				title={t("bodyEditor.chooseClipSlice", "Choose Clip Slice")}
				clipLabel={selectedClip?.entry.relative ?? ""}
				rects={selectedClip?.rects ?? []}
				atlasImage={selectedClip?.atlasImage ?? null}
				filterPlaceholder={t("bodyEditor.filterSlices", "Filter slices")}
				noSlicesText={t("bodyEditor.noSlices", "No slices")}
				cancelText={t("action.cancel", "Cancel")}
				onClose={() => setSelectedClip(null)}
				onSelect={(rect) => {
					if (selectedClip) selectFace(`${selectedClip.entry.relative}|${rect.name}`);
				}}
			/>
		</>
	);
});

const PropertyPanel = memo(function PropertyPanel(props: {
	document: BodyDocument;
	item: BodyStructDocument;
	readOnly: boolean;
	canAddSubShape: boolean;
	pendingSubShapeType: BodyCreateSubShapeType | null;
	selectedVertexIndex: number | null;
	onAddVertex: () => void;
	onRemoveVertex: () => void;
	onCreateSubShape: (type: BodyCreateSubShapeType) => void;
	onUpdateField: (fieldName: string, value: BodyLuaValue, recordUndo?: boolean) => void;
	onChooseFace: () => void;
	onBeginValueEdit?: () => void;
	onEndValueEdit?: (changed: boolean) => void;
}) {
	const { t } = useTranslation();
	const { document, item, readOnly, canAddSubShape, pendingSubShapeType, selectedVertexIndex, onAddVertex, onRemoveVertex, onCreateSubShape, onUpdateField, onChooseFace, onBeginValueEdit, onEndValueEdit } = props;
	const definition = BODY_STRUCTS_BY_TYPE[item.structType];
	const bodyOptions = useMemo(() => document.items.filter(isBodyItem).map((entry) => getJointCandidateName(entry)), [document.items]);
	const jointOptions = useMemo(() => document.items.filter((entry) => isGearJointCandidate(entry)).map((entry) => getJointCandidateName(entry)), [document.items]);
	return (
		<div style={{ borderTop: "1px solid #3a3a3a", padding: 10 }}>
			<div style={{ color: "#d7d7d7", fontSize: 13, marginBottom: 8 }}>{t("bodyEditor.properties", "Properties")}</div>
			{canAddSubShape ? (
				<div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 4, marginBottom: 8 }}>
					{([
						["subRect", t("bodyEditor.subShapes.subRect", "SubRect")],
						["subDisk", t("bodyEditor.subShapes.subDisk", "SubDisk")],
						["subPoly", t("bodyEditor.subShapes.subPoly", "SubPoly")],
						["subChain", t("bodyEditor.subShapes.subChain", "SubChain")],
					] as const).map(([type, label]) => {
						const selected = pendingSubShapeType === type;
						return (
							<button
								key={type}
								type="button"
								disabled={readOnly}
								onClick={() => onCreateSubShape(type)}
								style={{
									background: selected ? "#5f4917" : "#252525",
									color: selected ? "#ffe7ad" : "#d7d7d7",
									border: "1px solid " + (selected ? "#fac03d" : "#3a3a3a"),
									height: 26,
									cursor: readOnly ? "default" : "pointer",
									opacity: readOnly ? 0.55 : 1,
								}}
							>
								{label}
							</button>
						);
					})}
					<div style={{ gridColumn: "1 / -1", color: "#8f9aa6", fontSize: 11, lineHeight: "15px", paddingTop: 2 }}>
						{t("bodyEditor.subShapeHint", "Select a sub shape type, then click the preview.")}
					</div>
				</div>
			) : null}
			{definition.fields.map((field) => {
				if (field.name === "subShapes" || field.kind === "hidden") return null;
				const value = item.fields[field.name];
				const valueText = valueToText(value);
				const inputKey = `${item.id}:${field.name}:${valueText}`;
				const labelStyle = { display: "block", color: "#8f9aa6", fontSize: 11, margin: "8px 0 3px" };
				const fieldLabel = getBodyFieldLabel(t, field.name);
				if (field.kind === "boolean") {
					return (
						<label key={field.name} style={{ display: "flex", alignItems: "center", gap: 6, color: "#d7d7d7", fontSize: 12, marginTop: 8 }}>
							<input
								type="checkbox"
								checked={value === true}
								disabled={readOnly}
								onChange={(event) => onUpdateField(field.name, parseValue(field, "", event.currentTarget.checked))}
							/>
							{fieldLabel}
						</label>
					);
				}
				if (field.kind === "number") {
					const numberValue = typeof value === "number" ? value : 0;
					return (
						<NumericField
							key={field.name}
							label={fieldLabel}
							value={numberValue}
							readOnly={readOnly}
							constraint={getBodyNumberConstraint(item, field.name)}
							onCommit={(next, recordUndo) => onUpdateField(field.name, next, recordUndo)}
							onBeginStep={onBeginValueEdit}
							onEndStep={onEndValueEdit}
						/>
					);
				}
				if (field.kind === "bodyType") {
					return (
						<label key={field.name} style={labelStyle}>
							{fieldLabel}
							<select
								value={valueToText(value)}
								disabled={readOnly}
								onChange={(event) => onUpdateField(field.name, event.currentTarget.value)}
								style={{ width: "100%", marginTop: 3, background: "#181818", color: "#d7d7d7", border: "1px solid #3a3a3a", height: 26 }}
							>
								<option value="Static">{t("bodyEditor.bodyTypes.static", "Static")}</option>
								<option value="Dynamic">{t("bodyEditor.bodyTypes.dynamic", "Dynamic")}</option>
								<option value="Kinematic">{t("bodyEditor.bodyTypes.kinematic", "Kinematic")}</option>
							</select>
						</label>
					);
				}
				if (field.kind === "bodyRef" || field.kind === "jointRef") {
					const options = field.kind === "bodyRef" ? bodyOptions : jointOptions;
					return (
						<label key={field.name} style={labelStyle}>
							{fieldLabel}
							<select
								value={valueToText(value)}
								disabled={readOnly}
								onChange={(event) => onUpdateField(field.name, event.currentTarget.value)}
								style={{ width: "100%", marginTop: 3, background: "#181818", color: "#d7d7d7", border: "1px solid #3a3a3a", height: 26 }}
							>
								<option value="">{t("bodyEditor.none", "None")}</option>
								{options.map((name) => (
									<option key={name} value={name}>{name}</option>
								))}
							</select>
						</label>
					);
				}
				if (field.kind === "vector" || field.kind === "size") {
					const vector = asArray(value);
					const x = typeof vector[0] === "number" ? vector[0] : 0;
					const y = typeof vector[1] === "number" ? vector[1] : 0;
					const prefix = fieldLabel;
					return (
						<div key={field.name} style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 6 }}>
							{([
								["X", x, y],
								["Y", y, x],
							] as const).map(([axis, axisValue, otherValue]) => (
								<NumericField
									key={`${field.name}${axis}`}
									label={`${prefix}${axis}`}
									value={axisValue}
									readOnly={readOnly}
									constraint={getBodyNumberConstraint(item, field.name, axis)}
									onCommit={(next, recordUndo) => onUpdateField(field.name, axis === "X" ? [next, otherValue] : [otherValue, next], recordUndo)}
									onBeginStep={onBeginValueEdit}
									onEndStep={onEndValueEdit}
								/>
							))}
						</div>
					);
				}
				if (field.name === "face") {
					return (
						<label key={inputKey} style={labelStyle}>
							{fieldLabel}
							<div style={{ display: "flex", gap: 4, marginTop: 3 }}>
								<input
									defaultValue={valueText}
									readOnly={readOnly}
									onBlur={(event) => {
										if (!readOnly) onUpdateField(field.name, parseValue(field, event.currentTarget.value, false));
									}}
									style={{ minWidth: 0, flex: 1, boxSizing: "border-box", background: "#181818", color: "#d7d7d7", border: "1px solid #3a3a3a", minHeight: 26, opacity: readOnly ? 0.72 : 1 }}
								/>
								<button
									type="button"
									disabled={readOnly}
									onClick={onChooseFace}
									style={{
										width: 34,
										border: "1px solid #3a3a3a",
										background: "#252525",
										color: "#d7d7d7",
										cursor: readOnly ? "default" : "pointer",
										opacity: readOnly ? 0.55 : 1,
									}}
								>
									...
								</button>
							</div>
						</label>
					);
				}
				const multiline = field.kind === "vertices" || field.kind === "subShapes";
				const InputTag = multiline ? "textarea" : "input";
				const vertexCount = field.kind === "vertices" ? asArray(value).length : 0;
				const minVertexCount = item.structType === "Phyx.Chain" || item.structType === "Phyx.SubChain" ? 2 : 3;
				if (field.kind === "vertices") {
					return (
						<div key={field.name} style={labelStyle}>
							<div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: 6 }}>
								<span>{fieldLabel}</span>
								<span style={{ display: "flex", alignItems: "center", gap: 4 }}>
									<span style={{ color: "#8f9aa6", fontSize: 10 }}>
										{selectedVertexIndex !== null ? `#${selectedVertexIndex + 1}` : `${vertexCount}`}
									</span>
									<button
										type="button"
										disabled={readOnly}
										onClick={onAddVertex}
										style={{
											width: 22,
											height: 22,
											border: "1px solid #3a3a3a",
											background: "#252525",
											color: "#d7d7d7",
											cursor: readOnly ? "default" : "pointer",
											opacity: readOnly ? 0.55 : 1,
										}}
									>
										+
									</button>
									<button
										type="button"
										disabled={readOnly || vertexCount <= minVertexCount}
										onClick={onRemoveVertex}
										style={{
											width: 22,
											height: 22,
											border: "1px solid #3a3a3a",
											background: "#252525",
											color: "#d7d7d7",
											cursor: readOnly || vertexCount <= minVertexCount ? "default" : "pointer",
											opacity: readOnly || vertexCount <= minVertexCount ? 0.55 : 1,
										}}
									>
										-
									</button>
								</span>
							</div>
						</div>
					);
				}
				return (
					<label key={field.name} style={labelStyle}>
						<div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: 6 }}>
							<span>{fieldLabel}</span>
						</div>
						<InputTag
							key={inputKey}
							defaultValue={valueText}
							readOnly={readOnly}
							onBlur={(event) => {
								if (!readOnly) onUpdateField(field.name, parseValue(field, event.currentTarget.value, false));
							}}
							style={{
								width: "100%",
								boxSizing: "border-box",
								marginTop: 3,
								background: "#181818",
								color: "#d7d7d7",
								border: "1px solid #3a3a3a",
								minHeight: multiline ? 58 : 26,
								resize: multiline ? "vertical" : "none",
								opacity: readOnly ? 0.72 : 1,
							}}
						/>
					</label>
				);
			})}
		</div>
	);
});
