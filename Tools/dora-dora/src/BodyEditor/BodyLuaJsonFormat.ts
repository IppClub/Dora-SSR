import {
	BODY_STRUCTS_BY_TYPE,
	BodyDocument,
	BodyStructField,
	BodyLuaValue,
	BodyStructDefinition,
	BodyStructDocument,
	BodyStructType,
	BodyVector,
} from "./BodyDocument";
import { getBodyNumberConstraint, validateBodyNumberValue } from "./BodyFieldConstraints";
import { decomposeBodyPolygon, normalizeBodyPolygon } from "./BodyPolygon";
import { asArray, asVector } from "./BodyRender";

export type BodyDiagnosticSeverity = "error" | "warning" | "info";

export type BodyDiagnostic = {
	severity: BodyDiagnosticSeverity;
	message: string;
	path: string;
};

export type BodyLoadResult = {
	document: BodyDocument;
	diagnostics: BodyDiagnostic[];
	canSave: boolean;
};

type JsonArray = unknown[];

const isStructType = (value: unknown): value is BodyStructType => {
	return typeof value === "string" && Object.prototype.hasOwnProperty.call(BODY_STRUCTS_BY_TYPE, value);
};

const isLuaPrimitive = (value: unknown): value is string | number | boolean | null => {
	return value === null || typeof value === "string" || typeof value === "number" || typeof value === "boolean";
};

const isLuaValue = (value: unknown): value is BodyLuaValue => {
	if (isLuaPrimitive(value)) return true;
	if (!Array.isArray(value)) return false;
	for (const item of value) {
		if (!isLuaValue(item)) return false;
	}
	return true;
};

const isEmptyObject = (value: unknown) => (
	typeof value === "object" &&
	value !== null &&
	!Array.isArray(value) &&
	Object.keys(value).length === 0
);

const normalizeFieldValue = (field: BodyStructField, value: unknown): BodyLuaValue | undefined => {
	if (value === undefined && field.name === "faceScale") return 1;
	if (field.kind === "hidden" && value === undefined) return [];
	if (field.kind === "subShapes") {
		if (value === undefined || value === null || isEmptyObject(value)) return [];
		if (Array.isArray(value) && value[0] === "Array") {
			const items = value.slice(1);
			return items.every(isLuaValue) ? items : undefined;
		}
	}
	return isLuaValue(value) ? value : undefined;
};

const makeDiagnostic = (path: string, message: string): BodyDiagnostic => ({
	severity: "error",
	path,
	message,
});

const validateNumberFieldValue = (
	item: BodyStructDocument,
	field: BodyStructField,
	value: BodyLuaValue,
	path: string,
	diagnostics: BodyDiagnostic[],
) => {
	if (field.kind === "number") {
		if (typeof value !== "number") return;
		const message = validateBodyNumberValue(value, getBodyNumberConstraint(item, field.name));
		if (message) diagnostics.push(makeDiagnostic(path, `${item.structType}.${field.name} ${message}`));
		return;
	}
	if (field.kind !== "size") return;
	if (!Array.isArray(value)) return;
	for (let index = 0; index < 2; index++) {
		const axisValue = value[index];
		if (typeof axisValue !== "number") continue;
		const message = validateBodyNumberValue(axisValue, getBodyNumberConstraint(item, field.name, index === 0 ? "X" : "Y"));
		if (message) diagnostics.push(makeDiagnostic(`${path}[${index}]`, `${item.structType}.${field.name}${index === 0 ? "X" : "Y"} ${message}`));
	}
};

const makeEmptyDocument = (): BodyDocument => ({
	version: 1,
	source: "b.lua",
	items: [],
	dirty: false,
});

const parseStruct = (
	value: JsonArray,
	path: string,
	index: number,
	diagnostics: BodyDiagnostic[],
): BodyStructDocument | null => {
	const typeName = value[0];
	if (!isStructType(typeName)) {
		diagnostics.push(makeDiagnostic(`${path}[0]`, `Unknown BodyEx struct: ${String(typeName)}`));
		return null;
	}
	const definition: BodyStructDefinition = BODY_STRUCTS_BY_TYPE[typeName];
	const fields: Record<string, BodyLuaValue> = {};
	for (let i = 0; i < definition.fields.length; i++) {
		const field = definition.fields[i];
		const rawValue = value[i + 1];
		const fieldValue = normalizeFieldValue(field, rawValue);
		if (fieldValue === undefined) {
			diagnostics.push(makeDiagnostic(`${path}[${i + 1}]`, `Unsupported value for ${typeName}.${field.name}`));
			continue;
		}
		fields[field.name] = fieldValue;
	}
	if (value.length > definition.fields.length + 1) {
		diagnostics.push(makeDiagnostic(path, `${typeName} expects ${definition.fields.length} fields, got ${value.length - 1}`));
	}
	const name = typeof fields.name === "string" && fields.name.length > 0 ? fields.name : `${typeName}:${index}`;
	const item = {
		id: `${typeName}:${name}:${index}`,
		structType: typeName,
		fields,
	};
	for (let i = 0; i < definition.fields.length; i++) {
		const field = definition.fields[i];
		const fieldValue = fields[field.name];
		if (fieldValue !== undefined) {
			validateNumberFieldValue(item, field, fieldValue, `${path}[${i + 1}]`, diagnostics);
		}
	}
	return item;
};

export const loadBodyDocumentFromJsonArray = (root: unknown): BodyLoadResult => {
	const diagnostics: BodyDiagnostic[] = [];
	const document = makeEmptyDocument();
	if (!Array.isArray(root)) {
		diagnostics.push(makeDiagnostic("$", "Body JSON root must be an array."));
		return { document, diagnostics, canSave: false };
	}
	if (root[0] !== "Array") {
		diagnostics.push(makeDiagnostic("$[0]", "Body JSON root must start with \"Array\"."));
		return { document, diagnostics, canSave: false };
	}
	for (let i = 1; i < root.length; i++) {
		const value = root[i];
		const path = `$[${i}]`;
		if (!Array.isArray(value)) {
			diagnostics.push(makeDiagnostic(path, "Body item must be an array."));
			continue;
		}
		const item = parseStruct(value, path, i - 1, diagnostics);
		if (item) {
			document.items.push(item);
		}
	}
	return {
		document,
		diagnostics,
		canSave: diagnostics.every((item) => item.severity !== "error"),
	};
};

export const loadBodyDocumentFromJson = (jsonText: string): BodyLoadResult => {
	try {
		return loadBodyDocumentFromJsonArray(JSON.parse(jsonText));
	} catch (error) {
		return {
			document: makeEmptyDocument(),
			diagnostics: [makeDiagnostic("$", error instanceof Error ? error.message : "Failed to parse Body JSON.")],
			canSave: false,
		};
	}
};

export const validateBodyDocument = (document: BodyDocument): BodyDiagnostic[] => {
	const diagnostics: BodyDiagnostic[] = [];
	for (let itemIndex = 0; itemIndex < document.items.length; itemIndex++) {
		const item = document.items[itemIndex];
		const definition = BODY_STRUCTS_BY_TYPE[item.structType];
		if (!definition) {
			diagnostics.push(makeDiagnostic(`$[${itemIndex + 1}][0]`, `Unknown BodyEx struct: ${item.structType}`));
			continue;
		}
		for (let fieldIndex = 0; fieldIndex < definition.fields.length; fieldIndex++) {
			const field = definition.fields[fieldIndex];
			const value = item.fields[field.name];
			if (normalizeFieldValue(field, value) === undefined) {
				diagnostics.push(makeDiagnostic(`$[${itemIndex + 1}][${fieldIndex + 1}]`, `Unsupported value for ${item.structType}.${field.name}`));
				continue;
			}
			validateNumberFieldValue(item, field, value, `$[${itemIndex + 1}][${fieldIndex + 1}]`, diagnostics);
		}
	}
	return diagnostics;
};

const luaEscapeString = (value: string) => {
	return `"${value.replace(/\\/g, "\\\\").replace(/"/g, "\\\"").replace(/\n/g, "\\n").replace(/\r/g, "\\r").replace(/\t/g, "\\t")}"`;
};

const formatNumber = (value: number) => {
	if (!Number.isFinite(value)) return "0";
	const rounded = Math.round(value * 100) / 100;
	return Object.is(rounded, -0) ? "0" : String(rounded);
};

const writeLuaValue = (value: BodyLuaValue): string => {
	if (Array.isArray(value)) {
		return `{${value.map(writeLuaValue).join(",")}}`;
	}
	switch (typeof value) {
		case "string": return luaEscapeString(value);
		case "number": return formatNumber(value);
		case "boolean": return value ? "true" : "false";
		default: return "nil";
	}
};

const writeLuaFieldValue = (field: BodyStructField, value: BodyLuaValue | undefined): string => {
	if (field.kind === "subShapes" && (!Array.isArray(value) || value.length === 0)) {
		return "false";
	}
	return writeLuaValue(value ?? null);
};

const validVertices = (value: BodyLuaValue | undefined): BodyVector[] => (
	asArray(value)
		.map((point) => asVector(point))
		.filter((point) => Number.isFinite(point[0]) && Number.isFinite(point[1]))
);

const getConvexes = (item: BodyStructDocument) => {
	const result = decomposeBodyPolygon(validVertices(item.fields.vertices), 254);
	return result.parts.map((part) => part.map((point) => [point[0], point[1]]));
};

const sameVertex = (a: BodyVector, b: BodyVector) => (
	Math.abs(a[0] - b[0]) <= 0.000001 && Math.abs(a[1] - b[1]) <= 0.000001
);

const isUnchangedSingleConvex = (item: BodyStructDocument, parts: number[][][]) => {
	if (parts.length !== 1) return false;
	const vertices = normalizeBodyPolygon(validVertices(item.fields.vertices));
	const part = parts[0];
	if (part.length !== vertices.length) return false;
	return part.every((point, index) => sameVertex([point[0], point[1]], vertices[index]));
};

const writeConvexes = (item: BodyStructDocument) => {
	const parts = getConvexes(item);
	if (isUnchangedSingleConvex(item, parts)) return "nil";
	return writeLuaValue(parts);
};

const writeSubShape = (value: BodyLuaValue) => {
	if (!Array.isArray(value) || typeof value[0] !== "string") return writeLuaValue(value);
	if (value[0] !== "Phyx.SubPoly") return writeLuaValue(value);
	const fields: Record<string, BodyLuaValue> = {};
	const definition = BODY_STRUCTS_BY_TYPE[value[0]];
	for (let i = 0; i < definition.fields.length; i++) {
		const field = definition.fields[i];
		fields[field.name] = value[i + 1] ?? [];
	}
	const item: BodyStructDocument = {
		id: "export:subPoly",
		structType: value[0],
		fields,
	};
	const values = definition.fields.map((field, index) => (
		field.name === "convexes" ? writeConvexes(item) : writeLuaFieldValue(field, value[index + 1] ?? null)
	));
	while (values.length > 0 && values[values.length - 1] === "nil") values.pop();
	return `{${[luaEscapeString(value[0]), ...values].join(",")}}`;
};

const writeSubShapes = (value: BodyLuaValue | undefined) => {
	if (!Array.isArray(value) || value.length === 0) return "false";
	return `{${value.map(writeSubShape).join(",")}}`;
};

const writeStruct = (item: BodyStructDocument) => {
	const definition = BODY_STRUCTS_BY_TYPE[item.structType];
	const values = definition.fields.map((field) => {
		if (field.name === "convexes" && (item.structType === "Phyx.Poly" || item.structType === "Phyx.SubPoly")) {
			return writeConvexes(item);
		}
		if (field.kind === "subShapes") {
			return writeSubShapes(item.fields[field.name]);
		}
		const value = item.fields[field.name];
		return writeLuaFieldValue(field, value);
	});
	while (values.length > 0 && values[values.length - 1] === "nil") values.pop();
	return `\t{${[luaEscapeString(item.structType), ...values].join(",")}}`;
};

export const writeBodyDocumentToLua = (document: BodyDocument) => {
	if (document.items.length === 0) {
		return `return {"Array"}`;
	}
	return `return {\n\t"Array",\n${document.items.map(writeStruct).join(",\n")}\n}`;
};
