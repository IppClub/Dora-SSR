import { BODY_STRUCTS_BY_TYPE, BodyDocument, BodyJointType, BodyLuaValue, BodyShapeType, BodyStructDocument, BodySubShapeType, BodyVector } from "./BodyDocument";
import { BodyDiagnostic } from "./BodyLuaJsonFormat";
import { asArray, asNumber, asString, asVector, getSubShapeSelectionId, isBodyItem, isJointItem, parseSubShapeSelectionId } from "./BodyRender";

export type BodyCreateShapeType = "rect" | "disk" | "poly" | "chain";
export type BodyCreateSubShapeType = "subRect" | "subDisk" | "subPoly" | "subChain";
export type BodyCreateJointType =
	| "distance"
	| "friction"
	| "gear"
	| "spring"
	| "prismatic"
	| "pulley"
	| "revolute"
	| "rope"
	| "weld"
	| "wheel";

export type BodyStateResult = {
	document: BodyDocument;
	selectedId?: string | null;
	diagnostics: BodyDiagnostic[];
};

let nextId = 1;

const markDirty = (document: BodyDocument): BodyDocument => ({
	...document,
	dirty: true,
});

const error = (message: string, path = "$"): BodyDiagnostic => ({
	severity: "error",
	path,
	message,
});

const cloneItem = (item: BodyStructDocument): BodyStructDocument => ({
	...item,
	fields: Object.fromEntries(Object.entries(item.fields).map(([key, value]) => [key, cloneLuaValue(value)])),
});

const cloneDocument = (document: BodyDocument): BodyDocument => ({
	...document,
	items: document.items.map(cloneItem),
});

const cloneLuaValue = (value: BodyLuaValue): BodyLuaValue => {
	if (Array.isArray(value)) return value.map(cloneLuaValue);
	return value;
};

export const sortBodyDocumentItems = (items: BodyStructDocument[]) => {
	const bodies: BodyStructDocument[] = [];
	const joints: BodyStructDocument[] = [];
	const gears: BodyStructDocument[] = [];
	for (const item of items) {
		if (isBodyItem(item)) {
			bodies.push(item);
		} else if (item.structType === "Phyx.Gear") {
			gears.push(item);
		} else {
			joints.push(item);
		}
	}
	return [...bodies, ...joints, ...gears];
};

const uniqueName = (document: BodyDocument, base: string) => {
	const used = new Set(document.items.map((item) => asString(item.fields.name)));
	if (!used.has(base)) return base;
	let index = 2;
	while (used.has(`${base}${index}`)) index++;
	return `${base}${index}`;
};

const createShapeFields = (type: BodyShapeType, name: string, position: [number, number]): Record<string, BodyLuaValue> => {
	const common: Record<string, BodyLuaValue> = {
		name,
		type: "Dynamic",
		position,
		angle: 0,
		friction: 0.4,
		restitution: 0,
		linearDamping: 0,
		angularDamping: 0,
		fixedRotation: false,
		linearAcceleration: [0, -10],
		bullet: false,
		subShapes: [],
		face: "",
		facePos: [0, 0],
	};
	switch (type) {
		case "Phyx.Rect":
			return {
				...common,
				center: [0, 0],
				size: [120, 80],
				density: 1,
				sensor: false,
				sensorTag: 0,
			};
		case "Phyx.Disk":
			return {
				...common,
				center: [0, 0],
				radius: 48,
				density: 1,
				sensor: false,
				sensorTag: 0,
			};
		case "Phyx.Poly":
			return {
				...common,
				vertices: [[-60, -40], [60, -40], [0, 60]],
				density: 1,
				sensor: false,
				sensorTag: 0,
			};
		case "Phyx.Chain":
			return {
				...common,
				vertices: [[-70, 0], [-20, 30], [35, -12], [80, 22]],
			};
	}
};

export const createBodyShape = (
	document: BodyDocument,
	shapeType: BodyCreateShapeType,
	position: [number, number],
): BodyStateResult => {
	const structType: BodyShapeType = shapeType === "rect" ? "Phyx.Rect"
		: shapeType === "disk" ? "Phyx.Disk"
			: shapeType === "poly" ? "Phyx.Poly"
				: "Phyx.Chain";
	const name = uniqueName(document, shapeType);
	const item: BodyStructDocument = {
		id: `${structType}:${name}:${nextId++}`,
		structType,
		fields: createShapeFields(structType, name, position),
	};
	const nextDocument = markDirty(cloneDocument(document));
	nextDocument.items = sortBodyDocumentItems([...nextDocument.items, item]);
	return {
		document: nextDocument,
		selectedId: item.id,
		diagnostics: [],
	};
};

const isBodyReferenced = (document: BodyDocument, name: string) => {
	return document.items.some((item) => {
		if (!isJointItem(item)) return false;
		return item.fields.bodyA === name || item.fields.bodyB === name;
	});
};

const isJointReferencedByGear = (document: BodyDocument, name: string) => {
	return document.items.some((item) => {
		if (item.structType !== "Phyx.Gear") return false;
		return item.fields.jointA === name || item.fields.jointB === name;
	});
};

export const deleteBodyItem = (document: BodyDocument, selectedId: string | null): BodyStateResult => {
	if (!selectedId) {
		return { document, diagnostics: [error("No item selected.")] };
	}
	const subSelection = parseSubShapeSelectionId(selectedId);
	if (subSelection) {
		const nextDocument = markDirty(cloneDocument(document));
		const body = nextDocument.items.find((item) => item.id === subSelection.bodyId);
		if (!body || !isBodyItem(body)) {
			return { document, diagnostics: [error("Selected subshape parent no longer exists.")] };
		}
		const subShapes = [...asArray(body.fields.subShapes)];
		if (subSelection.index >= subShapes.length) {
			return { document, diagnostics: [error("Selected subshape no longer exists.")] };
		}
		subShapes.splice(subSelection.index, 1);
		body.fields.subShapes = subShapes;
		return {
			document: nextDocument,
			selectedId: body.id,
			diagnostics: [],
		};
	}
	const target = document.items.find((item) => item.id === selectedId);
	if (!target) {
		return { document, diagnostics: [error("Selected item no longer exists.")] };
	}
	const name = asString(target.fields.name);
	if (isBodyItem(target) && isBodyReferenced(document, name)) {
		return { document, diagnostics: [error(`Body "${name}" is referenced by a joint.`)] };
	}
	if (isJointItem(target) && isJointReferencedByGear(document, name)) {
		return { document, diagnostics: [error(`Joint "${name}" is referenced by a gear joint.`)] };
	}
	const nextDocument = markDirty(cloneDocument(document));
	nextDocument.items = nextDocument.items.filter((item) => item.id !== selectedId);
	return {
		document: nextDocument,
		selectedId: nextDocument.items[0]?.id ?? null,
		diagnostics: [],
	};
};

export const duplicateBodyItem = (document: BodyDocument, selectedId: string | null): BodyStateResult => {
	if (!selectedId) return { document, diagnostics: [error("No item selected.")] };
	const subSelection = parseSubShapeSelectionId(selectedId);
	if (subSelection) {
		const nextDocument = markDirty(cloneDocument(document));
		const body = nextDocument.items.find((item) => item.id === subSelection.bodyId);
		if (!body || !isBodyItem(body)) return { document, diagnostics: [error("Selected subshape parent no longer exists.")] };
		const subShapes = [...asArray(body.fields.subShapes)];
		const source = subShapes[subSelection.index];
		if (!Array.isArray(source)) return { document, diagnostics: [error("Selected subshape no longer exists.")] };
		subShapes.splice(subSelection.index + 1, 0, cloneLuaValue(source) as BodyLuaValue[]);
		body.fields.subShapes = subShapes;
		return {
			document: nextDocument,
			selectedId: getSubShapeSelectionId(body.id, subSelection.index + 1),
			diagnostics: [],
		};
	}
	const source = document.items.find((item) => item.id === selectedId);
	if (!source) return { document, diagnostics: [error("Selected item no longer exists.")] };
	const copy = cloneItem(source);
	const baseName = asString(copy.fields.name, source.structType.split(".")[1] ?? "item");
	copy.fields.name = uniqueName(document, `${baseName}Copy`);
	copy.id = `${copy.structType}:${copy.fields.name}:${nextId++}`;
	if (isBodyItem(copy)) {
		copy.fields.position = translateVector(copy.fields.position, [20, -20]) ?? copy.fields.position;
	}
	const nextDocument = markDirty(cloneDocument(document));
	nextDocument.items = sortBodyDocumentItems([...nextDocument.items, copy]);
	return {
		document: nextDocument,
		selectedId: copy.id,
		diagnostics: [],
	};
};

const worldToBodyLocal = (body: BodyStructDocument, point: [number, number]): [number, number] => {
	const position = asVector(body.fields.position);
	const angle = -asNumber(body.fields.angle) * Math.PI / 180;
	const cos = Math.cos(angle);
	const sin = Math.sin(angle);
	const dx = point[0] - position[0];
	const dy = point[1] - position[1];
	return [
		dx * cos + dy * sin,
		-dx * sin + dy * cos,
	];
};

const translateVertices = (vertices: [number, number][], offset: [number, number]): BodyLuaValue[] => (
	vertices.map((point) => [point[0] + offset[0], point[1] + offset[1]])
);

const createSubShapeArray = (type: BodySubShapeType, center: [number, number]): BodyLuaValue[] => {
	switch (type) {
		case "Phyx.SubRect":
			return ["Phyx.SubRect", center, 0, [80, 48], 1, 0.4, 0, false, 0];
		case "Phyx.SubDisk":
			return ["Phyx.SubDisk", center, 32, 1, 0.4, 0, false, 0];
		case "Phyx.SubPoly":
			return ["Phyx.SubPoly", translateVertices([[-40, -28], [40, -28], [0, 42]], center), 1, 0.4, 0, false, 0];
		case "Phyx.SubChain":
			return ["Phyx.SubChain", translateVertices([[-50, 0], [0, 24], [50, 0]], center), 0.4, 0];
	}
};

export const createBodySubShape = (
	document: BodyDocument,
	selectedId: string | null,
	subShapeType: BodyCreateSubShapeType,
	position: [number, number],
): BodyStateResult => {
	const bodyId = parseSubShapeSelectionId(selectedId)?.bodyId ?? selectedId;
	if (!bodyId) return { document, diagnostics: [error("Select a body before adding a subshape.")] };
	const structType: BodySubShapeType = subShapeType === "subRect" ? "Phyx.SubRect"
		: subShapeType === "subDisk" ? "Phyx.SubDisk"
			: subShapeType === "subPoly" ? "Phyx.SubPoly"
				: "Phyx.SubChain";
	const nextDocument = markDirty(cloneDocument(document));
	const body = nextDocument.items.find((item) => item.id === bodyId);
	if (!body || !isBodyItem(body)) {
		return { document, diagnostics: [error("Select a body before adding a subshape.")] };
	}
	const localPosition = worldToBodyLocal(body, position);
	const subShapes = [...asArray(body.fields.subShapes), createSubShapeArray(structType, localPosition)];
	body.fields.subShapes = subShapes;
	return {
		document: nextDocument,
		selectedId: getSubShapeSelectionId(body.id, subShapes.length - 1),
		diagnostics: [],
	};
};

const jointStructType = (type: BodyCreateJointType): BodyJointType => {
	switch (type) {
		case "distance": return "Phyx.Distance";
		case "friction": return "Phyx.Friction";
		case "gear": return "Phyx.Gear";
		case "spring": return "Phyx.Spring";
		case "prismatic": return "Phyx.Prismatic";
		case "pulley": return "Phyx.Pulley";
		case "revolute": return "Phyx.Revolute";
		case "rope": return "Phyx.Rope";
		case "weld": return "Phyx.Weld";
		case "wheel": return "Phyx.Wheel";
	}
};

const bodyLocalFromWorld = (body: BodyStructDocument | undefined, world: BodyVector): BodyVector => {
	if (!body) return [0, 0];
	const position = asVector(body.fields.position);
	const angle = asNumber(body.fields.angle) * Math.PI / 180;
	const dx = world[0] - position[0];
	const dy = world[1] - position[1];
	const cos = Math.cos(angle);
	const sin = Math.sin(angle);
	return [
		dx * cos - dy * sin,
		dx * sin + dy * cos,
	];
};

const pickJointBodies = (bodies: BodyStructDocument[], position: BodyVector) => {
	const ranked = [...bodies].sort((a, b) => {
		const pa = asVector(a.fields.position);
		const pb = asVector(b.fields.position);
		const da = (pa[0] - position[0]) ** 2 + (pa[1] - position[1]) ** 2;
		const db = (pb[0] - position[0]) ** 2 + (pb[1] - position[1]) ** 2;
		return da - db;
	});
	return [ranked[0], ranked[1]] as const;
};

const createJointFields = (structType: BodyJointType, name: string, bodyA: string, bodyB: string, jointA: string, jointB: string): Record<string, BodyLuaValue> => {
	const common = { name, collision: false, bodyA, bodyB };
	switch (structType) {
		case "Phyx.Distance": return { ...common, anchorA: [0, 0], anchorB: [0, 0], frequency: 4, damping: 0.7 };
		case "Phyx.Friction": return { ...common, worldPos: [0, 0], maxForce: 20, maxTorque: 10 };
		case "Phyx.Gear": return { name, collision: false, jointA, jointB, ratio: 1 };
		case "Phyx.Spring": return { ...common, linearOffset: [0, 0], angularOffset: 0, maxForce: 100, maxTorque: 40, correctionFactor: 0.3 };
		case "Phyx.Prismatic": return { ...common, worldPos: [0, 0], axis: [1, 0], lowerTranslation: -50, upperTranslation: 50, maxMotorForce: 100, motorSpeed: 0 };
		case "Phyx.Pulley": return { ...common, anchorA: [0, 0], anchorB: [0, 0], groundAnchorA: [-100, 100], groundAnchorB: [100, 100], ratio: 1 };
		case "Phyx.Revolute": return { ...common, worldPos: [0, 0], lowerAngle: -45, upperAngle: 45, maxMotorTorque: 100, motorSpeed: 0 };
		case "Phyx.Rope": return { ...common, anchorA: [0, 0], anchorB: [0, 0], maxLength: 200 };
		case "Phyx.Weld": return { ...common, worldPos: [0, 0], frequency: 4, damping: 0.7 };
		case "Phyx.Wheel": return { ...common, worldPos: [0, 0], axis: [0, 1], maxMotorTorque: 100, motorSpeed: 0, frequency: 4, damping: 0.7 };
	}
};

export const createBodyJoint = (document: BodyDocument, jointType: BodyCreateJointType, position: [number, number] = [0, 0]): BodyStateResult => {
	const bodies = document.items.filter(isBodyItem);
	if (jointType !== "gear" && bodies.length < 2) {
		return { document, diagnostics: [error("Create at least two bodies before adding a joint.")] };
	}
	const structType = jointStructType(jointType);
	const name = uniqueName(document, jointType);
	const gearCandidates = document.items.filter((item) => item.structType === "Phyx.Revolute" || item.structType === "Phyx.Prismatic");
	if (structType === "Phyx.Gear" && gearCandidates.length < 2) {
		return { document, diagnostics: [error("Gear requires two Revolute or Prismatic joints.")] };
	}
	const [bodyA, bodyB] = pickJointBodies(bodies, position);
	const item: BodyStructDocument = {
		id: `${structType}:${name}:${nextId++}`,
		structType,
		fields: createJointFields(
			structType,
			name,
			asString(bodyA?.fields.name),
			asString(bodyB?.fields.name),
			asString(gearCandidates[0]?.fields.name),
			asString(gearCandidates[1]?.fields.name),
		),
	};
	if (item.fields.worldPos) item.fields.worldPos = position;
	if (item.fields.anchorA) item.fields.anchorA = bodyLocalFromWorld(bodyA, position);
	if (item.fields.anchorB) item.fields.anchorB = bodyLocalFromWorld(bodyB, position);
	const nextDocument = markDirty(cloneDocument(document));
	nextDocument.items = sortBodyDocumentItems([...nextDocument.items, item]);
	return {
		document: nextDocument,
		selectedId: item.id,
		diagnostics: [],
	};
};

const renameReferences = (items: BodyStructDocument[], oldName: string, newName: string) => {
	for (const item of items) {
		if (item.fields.bodyA === oldName) item.fields.bodyA = newName;
		if (item.fields.bodyB === oldName) item.fields.bodyB = newName;
		if (item.fields.jointA === oldName) item.fields.jointA = newName;
		if (item.fields.jointB === oldName) item.fields.jointB = newName;
	}
};

export const updateBodyItemField = (
	document: BodyDocument,
	selectedId: string,
	fieldName: string,
	value: BodyLuaValue,
): BodyStateResult => {
	const nextDocument = markDirty(cloneDocument(document));
	const subSelection = parseSubShapeSelectionId(selectedId);
	if (subSelection) {
		const body = nextDocument.items.find((item) => item.id === subSelection.bodyId);
		if (!body || !isBodyItem(body)) {
			return { document, diagnostics: [error("Selected subshape parent no longer exists.")] };
		}
		const subShapes = [...asArray(body.fields.subShapes)];
		const subShape = subShapes[subSelection.index];
		if (!Array.isArray(subShape) || typeof subShape[0] !== "string") {
			return { document, diagnostics: [error("Selected subshape no longer exists.")] };
		}
		const definition = BODY_STRUCTS_BY_TYPE[subShape[0] as BodySubShapeType];
		const fieldIndex = definition.fields.findIndex((field) => field.name === fieldName);
		if (fieldIndex < 0) {
			return { document, diagnostics: [error(`Unknown subshape field "${fieldName}".`)] };
		}
		subShape[fieldIndex + 1] = value;
		body.fields.subShapes = subShapes;
		return {
			document: nextDocument,
			selectedId,
			diagnostics: [],
		};
	}
	const target = nextDocument.items.find((item) => item.id === selectedId);
	if (!target) {
		return { document, diagnostics: [error("Selected item no longer exists.")] };
	}
	if (fieldName === "name" && typeof value === "string") {
		const oldName = asString(target.fields.name);
		if (value.trim() === "") {
			return { document, diagnostics: [error("Name cannot be empty.")] };
		}
		const duplicate = nextDocument.items.some((item) => item.id !== selectedId && item.fields.name === value);
		if (duplicate) {
			return { document, diagnostics: [error(`Name "${value}" already exists.`)] };
		}
		target.fields.name = value;
		if (oldName !== value) renameReferences(nextDocument.items, oldName, value);
	} else {
		target.fields[fieldName] = value;
	}
	return {
		document: nextDocument,
		selectedId,
		diagnostics: [],
	};
};

const translateVector = (value: BodyLuaValue | undefined, delta: [number, number]): BodyLuaValue | undefined => {
	if (!Array.isArray(value)) return value;
	if (typeof value[0] === "number" && typeof value[1] === "number") {
		return [value[0] + delta[0], value[1] + delta[1]];
	}
	return value.map((item) => translateVector(item, delta) ?? item);
};

export const translateBodySelection = (
	document: BodyDocument,
	selectedId: string | null,
	delta: [number, number],
): BodyStateResult => {
	if (!selectedId) return { document, diagnostics: [error("No item selected.")] };
	const nextDocument = markDirty(cloneDocument(document));
	const subSelection = parseSubShapeSelectionId(selectedId);
	if (subSelection) {
		const body = nextDocument.items.find((item) => item.id === subSelection.bodyId);
		const subShapes = body ? [...asArray(body.fields.subShapes)] : [];
		const subShape = subShapes[subSelection.index];
		if (!body || !Array.isArray(subShape) || typeof subShape[0] !== "string") {
			return { document, diagnostics: [error("Selected subshape no longer exists.")] };
		}
		const definition = BODY_STRUCTS_BY_TYPE[subShape[0] as BodySubShapeType];
		for (let i = 0; i < definition.fields.length; i++) {
			const field = definition.fields[i];
			if (field.kind === "vector" || field.kind === "vertices") {
				subShape[i + 1] = translateVector(subShape[i + 1], delta) ?? subShape[i + 1];
			}
		}
		body.fields.subShapes = subShapes;
		return { document: nextDocument, selectedId, diagnostics: [] };
	}
	const target = nextDocument.items.find((item) => item.id === selectedId);
	if (!target) return { document, diagnostics: [error("Selected item no longer exists.")] };
	for (const field of BODY_STRUCTS_BY_TYPE[target.structType].fields) {
		if (field.name === "axis") continue;
		if (field.kind === "vector" || field.kind === "vertices") {
			target.fields[field.name] = translateVector(target.fields[field.name], delta) ?? target.fields[field.name];
			if (isBodyItem(target) && field.name === "position") break;
		}
	}
	return { document: nextDocument, selectedId, diagnostics: [] };
};
