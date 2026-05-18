import {
	BODY_STRUCTS_BY_TYPE,
	BodyDocument,
	BodyStructField,
	BodyLuaValue,
	BodyStructDefinition,
	BodyStructDocument,
	BodyStructType,
} from "./BodyDocument";

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

const makeEmptyDocument = (): BodyDocument => ({
	version: 1,
	source: "body.lua",
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
	if (value.length !== definition.fields.length + 1) {
		diagnostics.push(makeDiagnostic(path, `${typeName} expects ${definition.fields.length} fields, got ${value.length - 1}`));
	}
	const name = typeof fields.name === "string" && fields.name.length > 0 ? fields.name : `${typeName}:${index}`;
	return {
		id: `${typeName}:${name}:${index}`,
		structType: typeName,
		fields,
	};
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

const writeStruct = (item: BodyStructDocument) => {
	const definition = BODY_STRUCTS_BY_TYPE[item.structType];
	const values = definition.fields.map((field) => {
		const value = item.fields[field.name];
		return writeLuaFieldValue(field, value);
	});
	return `\t{${[luaEscapeString(item.structType), ...values].join(",")}}`;
};

export const writeBodyDocumentToLua = (document: BodyDocument) => {
	if (document.items.length === 0) {
		return `return {"Array"}`;
	}
	return `return {\n\t"Array",\n${document.items.map(writeStruct).join(",\n")}\n}`;
};
