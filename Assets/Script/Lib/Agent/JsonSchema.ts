// @preview-file off clear
import { json } from 'Dora';

export type JsonSchemaType = "null" | "boolean" | "number" | "integer" | "string" | "array" | "object";

export type JsonSchema = boolean | JsonSchemaObject;

export interface JsonSchemaObject {
	[key: string]: unknown;
	$schema?: string;
	title?: string;
	description?: string;
	default?: unknown;
	examples?: unknown[];
	type?: JsonSchemaType | JsonSchemaType[];
	enum?: unknown[];
	const?: unknown;
	properties?: Record<string, JsonSchema>;
	required?: string[];
	additionalProperties?: JsonSchema;
	items?: JsonSchema;
	minItems?: number;
	maxItems?: number;
	minLength?: number;
	maxLength?: number;
	minimum?: number;
	maximum?: number;
	exclusiveMinimum?: number;
	exclusiveMaximum?: number;
	allOf?: JsonSchema[];
	anyOf?: JsonSchema[];
	oneOf?: JsonSchema[];
	not?: JsonSchema;
}

export interface JsonSchemaError {
	keyword: string;
	instancePath: string;
	schemaPath: string;
	message: string;
}

export interface JsonSchemaValidationOptions {
	maxDepth?: number;
	maxErrors?: number;
}

export interface JsonSchemaValidationResult {
	valid: boolean;
	errors: JsonSchemaError[];
	truncated: boolean;
}

export type CompiledJsonSchema = {
	schema: JsonSchema;
	validate(value: unknown): JsonSchemaValidationResult;
};

export type JsonSchemaCompileResult =
	| { success: true; validator: CompiledJsonSchema }
	| { success: false; errors: JsonSchemaError[]; truncated: boolean };

interface ValidationLimits {
	maxDepth: number;
	maxErrors: number;
}

interface ValidationState {
	errors: JsonSchemaError[];
	truncated: boolean;
	limits: ValidationLimits;
}

const JSON_SCHEMA_TYPES: JsonSchemaType[] = [
	"null",
	"boolean",
	"number",
	"integer",
	"string",
	"array",
	"object",
];

const SUPPORTED_KEYWORDS = [
	"$schema",
	"title",
	"description",
	"default",
	"examples",
	"type",
	"enum",
	"const",
	"properties",
	"required",
	"additionalProperties",
	"items",
	"minItems",
	"maxItems",
	"minLength",
	"maxLength",
	"minimum",
	"maximum",
	"exclusiveMinimum",
	"exclusiveMaximum",
	"allOf",
	"anyOf",
	"oneOf",
	"not",
];

function normalizeLimits(options?: JsonSchemaValidationOptions): ValidationLimits {
	const depth = typeof options?.maxDepth === "number" && Number.isFinite(options.maxDepth)
		? math.floor(options.maxDepth)
		: 64;
	const errors = typeof options?.maxErrors === "number" && Number.isFinite(options.maxErrors)
		? math.floor(options.maxErrors)
		: 32;
	return {
		maxDepth: math.max(1, depth),
		maxErrors: math.max(1, errors),
	};
}

function createState(options?: JsonSchemaValidationOptions): ValidationState {
	return {
		errors: [],
		truncated: false,
		limits: normalizeLimits(options),
	};
}

function addError(
	state: ValidationState,
	keyword: string,
	instancePath: string,
	schemaPath: string,
	message: string
): void {
	if (state.errors.length >= state.limits.maxErrors) {
		state.truncated = true;
		return;
	}
	state.errors.push({ keyword, instancePath, schemaPath, message });
}

function toResult(state: ValidationState): JsonSchemaValidationResult {
	return {
		valid: state.errors.length === 0 && !state.truncated,
		errors: state.errors,
		truncated: state.truncated,
	};
}

function escapePointerToken(value: string): string {
	return value.split("~").join("~0").split("/").join("~1");
}

function appendPointer(path: string, token: string | number): string {
	return `${path}/${escapePointerToken(tostring(token))}`;
}

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== undefined && !Array.isArray(value) && value !== json.null;
}

function isJsonNull(value: unknown): boolean {
	return value === json.null;
}

function isFiniteNumber(value: unknown): value is number {
	return typeof value === "number" && Number.isFinite(value);
}

function isNonNegativeInteger(value: unknown): value is number {
	return isFiniteNumber(value) && value >= 0 && math.floor(value) === value;
}

function getStringLength(value: string): number {
	const [length] = utf8.len(value);
	return length ?? value.length;
}

function deepEqual(left: unknown, right: unknown, depth = 0): boolean {
	if (left === right) return true;
	if (isJsonNull(left) || isJsonNull(right)) return isJsonNull(left) && isJsonNull(right);
	if (depth > 64 || typeof left !== typeof right) return false;
	if (Array.isArray(left) || Array.isArray(right)) {
		if (!Array.isArray(left) || !Array.isArray(right) || left.length !== right.length) return false;
		for (let i = 0; i < left.length; i++) {
			if (!deepEqual(left[i], right[i], depth + 1)) return false;
		}
		return true;
	}
	if (isRecord(left) || isRecord(right)) {
		if (!isRecord(left) || !isRecord(right)) return false;
		const leftKeys = Object.keys(left);
		const rightKeys = Object.keys(right);
		if (leftKeys.length !== rightKeys.length) return false;
		for (const key of leftKeys) {
			if (right[key] === undefined || !deepEqual(left[key], right[key], depth + 1)) return false;
		}
		return true;
	}
	return false;
}

function validateJsonData(
	value: unknown,
	instancePath: string,
	depth: number,
	state: ValidationState,
	stack: unknown[]
): void {
	if (state.truncated) return;
	if (depth > state.limits.maxDepth) {
		addError(state, "json", instancePath, "", `JSON value exceeds maximum depth ${state.limits.maxDepth}`);
		return;
	}
	if (isJsonNull(value) || typeof value === "string" || typeof value === "boolean") return;
	if (typeof value === "number") {
		if (!Number.isFinite(value)) {
			addError(state, "json", instancePath, "", "number must be finite JSON data");
		}
		return;
	}
	if (Array.isArray(value)) {
		if (stack.indexOf(value) >= 0) {
			addError(state, "json", instancePath, "", "cyclic arrays are not valid JSON data");
			return;
		}
		stack.push(value);
		for (let i = 0; i < value.length && !state.truncated; i++) {
			if (value[i] === undefined) {
				addError(state, "json", appendPointer(instancePath, i), "", "sparse or undefined array item is not valid JSON data");
				continue;
			}
			validateJsonData(value[i], appendPointer(instancePath, i), depth + 1, state, stack);
		}
		stack.pop();
		return;
	}
	if (isRecord(value)) {
		if (stack.indexOf(value) >= 0) {
			addError(state, "json", instancePath, "", "cyclic objects are not valid JSON data");
			return;
		}
		stack.push(value);
		for (const key of Object.keys(value)) {
			if (state.truncated) break;
			if (value[key] === undefined) {
				addError(state, "json", appendPointer(instancePath, key), "", "undefined object property is not valid JSON data");
				continue;
			}
			validateJsonData(value[key], appendPointer(instancePath, key), depth + 1, state, stack);
		}
		stack.pop();
		return;
	}
	addError(state, "json", instancePath, "", `unsupported JSON value type: ${typeof value}`);
}

function validateAnnotationValue(
	value: unknown,
	keyword: string,
	schemaPath: string,
	depth: number,
	state: ValidationState
): void {
	const annotationState = createState({
		maxDepth: state.limits.maxDepth - depth,
		maxErrors: state.limits.maxErrors - state.errors.length,
	});
	validateJsonData(value, "", 0, annotationState, []);
	for (const error of annotationState.errors) {
		addError(state, keyword, "", schemaPath, `${keyword} must contain JSON data: ${error.message}`);
	}
	if (annotationState.truncated) state.truncated = true;
}

function validateSchemaArray(
	value: unknown,
	keyword: "allOf" | "anyOf" | "oneOf",
	schemaPath: string,
	depth: number,
	state: ValidationState,
	stack: unknown[]
): void {
	if (!Array.isArray(value) || value.length === 0) {
		addError(state, keyword, "", schemaPath, `${keyword} must be a non-empty array of schemas`);
		return;
	}
	for (let i = 0; i < value.length; i++) {
		validateSchemaNode(value[i], appendPointer(schemaPath, i), depth + 1, state, stack);
	}
}

function validateSchemaNode(
	schema: unknown,
	schemaPath: string,
	depth: number,
	state: ValidationState,
	stack: unknown[]
): void {
	if (state.truncated) return;
	if (depth > state.limits.maxDepth) {
		addError(state, "schema", "", schemaPath, `schema exceeds maximum depth ${state.limits.maxDepth}`);
		return;
	}
	if (typeof schema === "boolean") return;
	if (!isRecord(schema)) {
		addError(state, "schema", "", schemaPath, "schema must be a boolean or object");
		return;
	}
	if (stack.indexOf(schema) >= 0) {
		addError(state, "schema", "", schemaPath, "cyclic schemas are not supported");
		return;
	}
	stack.push(schema);

	for (const keyword of Object.keys(schema)) {
		if (SUPPORTED_KEYWORDS.indexOf(keyword) < 0) {
			addError(state, keyword, "", appendPointer(schemaPath, keyword), `unsupported JSON Schema keyword: ${keyword}`);
		}
	}

	for (const keyword of ["$schema", "title", "description"]) {
		const value = schema[keyword];
		if (value !== undefined && typeof value !== "string") {
			addError(state, keyword, "", appendPointer(schemaPath, keyword), `${keyword} must be a string`);
		}
	}
	if (schema.default !== undefined) {
		validateAnnotationValue(schema.default, "default", appendPointer(schemaPath, "default"), depth + 1, state);
	}
	if (schema.examples !== undefined) {
		if (!Array.isArray(schema.examples)) {
			addError(state, "examples", "", appendPointer(schemaPath, "examples"), "examples must be an array");
		} else {
			validateAnnotationValue(schema.examples, "examples", appendPointer(schemaPath, "examples"), depth + 1, state);
		}
	}

	if (schema.type !== undefined) {
		const types: unknown[] = Array.isArray(schema.type) ? schema.type : [schema.type as JsonSchemaType];
		if (types.length === 0) {
			addError(state, "type", "", appendPointer(schemaPath, "type"), "type array must not be empty");
		}
		const seen: string[] = [];
		for (let i = 0; i < types.length; i++) {
			const item = types[i];
			if (typeof item !== "string" || JSON_SCHEMA_TYPES.indexOf(item as JsonSchemaType) < 0) {
				addError(state, "type", "", appendPointer(appendPointer(schemaPath, "type"), i), `unsupported JSON Schema type: ${tostring(item)}`);
			} else if (seen.indexOf(item) >= 0) {
				addError(state, "type", "", appendPointer(schemaPath, "type"), `duplicate JSON Schema type: ${item}`);
			} else {
				seen.push(item);
			}
		}
	}

	if (schema.enum !== undefined) {
		if (!Array.isArray(schema.enum) || schema.enum.length === 0) {
			addError(state, "enum", "", appendPointer(schemaPath, "enum"), "enum must be a non-empty array");
		} else {
			validateAnnotationValue(schema.enum, "enum", appendPointer(schemaPath, "enum"), depth + 1, state);
			for (let i = 0; i < schema.enum.length; i++) {
				for (let j = 0; j < i; j++) {
					if (deepEqual(schema.enum[i], schema.enum[j])) {
						addError(state, "enum", "", appendPointer(appendPointer(schemaPath, "enum"), i), "enum values must be unique");
						break;
					}
				}
			}
		}
	}
	if (schema.const !== undefined) {
		validateAnnotationValue(schema.const, "const", appendPointer(schemaPath, "const"), depth + 1, state);
	}

	if (schema.properties !== undefined) {
		if (!isRecord(schema.properties)) {
			addError(state, "properties", "", appendPointer(schemaPath, "properties"), "properties must be an object of schemas");
		} else {
			for (const key of Object.keys(schema.properties)) {
				validateSchemaNode(
					schema.properties[key],
					appendPointer(appendPointer(schemaPath, "properties"), key),
					depth + 1,
					state,
					stack
				);
			}
		}
	}
	if (schema.required !== undefined) {
		if (!Array.isArray(schema.required)) {
			addError(state, "required", "", appendPointer(schemaPath, "required"), "required must be an array of unique strings");
		} else {
			const seen: string[] = [];
			for (let i = 0; i < schema.required.length; i++) {
				const item = schema.required[i];
				if (typeof item !== "string" || seen.indexOf(item) >= 0) {
					addError(state, "required", "", appendPointer(appendPointer(schemaPath, "required"), i), "required entries must be unique strings");
				} else {
					seen.push(item);
				}
			}
		}
	}
	if (schema.additionalProperties !== undefined) {
		validateSchemaNode(schema.additionalProperties, appendPointer(schemaPath, "additionalProperties"), depth + 1, state, stack);
	}
	if (schema.items !== undefined) {
		validateSchemaNode(schema.items, appendPointer(schemaPath, "items"), depth + 1, state, stack);
	}
	if (schema.not !== undefined) {
		validateSchemaNode(schema.not, appendPointer(schemaPath, "not"), depth + 1, state, stack);
	}

	for (const keyword of ["minItems", "maxItems", "minLength", "maxLength"]) {
		const value = schema[keyword];
		if (value !== undefined && !isNonNegativeInteger(value)) {
			addError(state, keyword, "", appendPointer(schemaPath, keyword), `${keyword} must be a non-negative integer`);
		}
	}
	if (isNonNegativeInteger(schema.minItems) && isNonNegativeInteger(schema.maxItems) && schema.minItems > schema.maxItems) {
		addError(state, "maxItems", "", appendPointer(schemaPath, "maxItems"), "maxItems must be greater than or equal to minItems");
	}
	if (isNonNegativeInteger(schema.minLength) && isNonNegativeInteger(schema.maxLength) && schema.minLength > schema.maxLength) {
		addError(state, "maxLength", "", appendPointer(schemaPath, "maxLength"), "maxLength must be greater than or equal to minLength");
	}
	for (const keyword of ["minimum", "maximum", "exclusiveMinimum", "exclusiveMaximum"]) {
		const value = schema[keyword];
		if (value !== undefined && !isFiniteNumber(value)) {
			addError(state, keyword, "", appendPointer(schemaPath, keyword), `${keyword} must be a finite number`);
		}
	}
	if (isFiniteNumber(schema.minimum) && isFiniteNumber(schema.maximum) && schema.minimum > schema.maximum) {
		addError(state, "maximum", "", appendPointer(schemaPath, "maximum"), "maximum must be greater than or equal to minimum");
	}
	if (isFiniteNumber(schema.exclusiveMinimum) && isFiniteNumber(schema.exclusiveMaximum) && schema.exclusiveMinimum >= schema.exclusiveMaximum) {
		addError(state, "exclusiveMaximum", "", appendPointer(schemaPath, "exclusiveMaximum"), "exclusiveMaximum must be greater than exclusiveMinimum");
	}

	if (schema.allOf !== undefined) validateSchemaArray(schema.allOf, "allOf", appendPointer(schemaPath, "allOf"), depth, state, stack);
	if (schema.anyOf !== undefined) validateSchemaArray(schema.anyOf, "anyOf", appendPointer(schemaPath, "anyOf"), depth, state, stack);
	if (schema.oneOf !== undefined) validateSchemaArray(schema.oneOf, "oneOf", appendPointer(schemaPath, "oneOf"), depth, state, stack);

	stack.pop();
}

function matchesType(value: unknown, expected: JsonSchemaType): boolean {
	if (expected === "null") return isJsonNull(value);
	if (expected === "boolean") return typeof value === "boolean";
	if (expected === "number") return isFiniteNumber(value);
	if (expected === "integer") return isFiniteNumber(value) && math.floor(value) === value;
	if (expected === "string") return typeof value === "string";
	if (expected === "array") return Array.isArray(value);
	return isRecord(value);
}

function validateInstanceNode(
	schema: JsonSchema,
	value: unknown,
	instancePath: string,
	schemaPath: string,
	depth: number,
	state: ValidationState
): void {
	if (state.truncated) return;
	if (depth > state.limits.maxDepth) {
		addError(state, "schema", instancePath, schemaPath, `validation exceeds maximum depth ${state.limits.maxDepth}`);
		return;
	}
	if (schema === true) return;
	if (schema === false) {
		addError(state, "falseSchema", instancePath, schemaPath, "value is rejected by false schema");
		return;
	}

	if (schema.type !== undefined) {
		const types: JsonSchemaType[] = Array.isArray(schema.type) ? schema.type : [schema.type as JsonSchemaType];
		let matched = false;
		for (const expected of types) {
			if (matchesType(value, expected)) {
				matched = true;
				break;
			}
		}
		if (!matched) {
			addError(state, "type", instancePath, appendPointer(schemaPath, "type"), `expected type ${types.join(" or ")}`);
			return;
		}
	}

	if (schema.enum !== undefined) {
		let matched = false;
		for (const item of schema.enum) {
			if (deepEqual(value, item)) {
				matched = true;
				break;
			}
		}
		if (!matched) addError(state, "enum", instancePath, appendPointer(schemaPath, "enum"), "value is not one of the allowed enum values");
	}
	if (schema.const !== undefined && !deepEqual(value, schema.const)) {
		addError(state, "const", instancePath, appendPointer(schemaPath, "const"), "value does not equal const");
	}

	if (isRecord(value)) {
		const properties = isRecord(schema.properties) ? schema.properties as Record<string, JsonSchema> : {};
		for (const name of schema.required ?? []) {
			if (value[name] === undefined) {
				addError(state, "required", instancePath, appendPointer(schemaPath, "required"), `required property is missing: ${name}`);
			}
		}
		for (const key of Object.keys(value)) {
			const childSchema = properties[key];
			if (childSchema !== undefined) {
				validateInstanceNode(
					childSchema,
					value[key],
					appendPointer(instancePath, key),
					appendPointer(appendPointer(schemaPath, "properties"), key),
					depth + 1,
					state
				);
			} else if (schema.additionalProperties !== undefined) {
				validateInstanceNode(
					schema.additionalProperties,
					value[key],
					appendPointer(instancePath, key),
					appendPointer(schemaPath, "additionalProperties"),
					depth + 1,
					state
				);
			}
		}
	}

	if (Array.isArray(value)) {
		if (schema.minItems !== undefined && value.length < schema.minItems) {
			addError(state, "minItems", instancePath, appendPointer(schemaPath, "minItems"), `array must contain at least ${schema.minItems} items`);
		}
		if (schema.maxItems !== undefined && value.length > schema.maxItems) {
			addError(state, "maxItems", instancePath, appendPointer(schemaPath, "maxItems"), `array must contain at most ${schema.maxItems} items`);
		}
		if (schema.items !== undefined) {
			for (let i = 0; i < value.length; i++) {
				validateInstanceNode(schema.items, value[i], appendPointer(instancePath, i), appendPointer(schemaPath, "items"), depth + 1, state);
			}
		}
	}

	if (typeof value === "string") {
		const length = getStringLength(value);
		if (schema.minLength !== undefined && length < schema.minLength) {
			addError(state, "minLength", instancePath, appendPointer(schemaPath, "minLength"), `string must contain at least ${schema.minLength} characters`);
		}
		if (schema.maxLength !== undefined && length > schema.maxLength) {
			addError(state, "maxLength", instancePath, appendPointer(schemaPath, "maxLength"), `string must contain at most ${schema.maxLength} characters`);
		}
	}

	if (isFiniteNumber(value)) {
		if (schema.minimum !== undefined && value < schema.minimum) {
			addError(state, "minimum", instancePath, appendPointer(schemaPath, "minimum"), `number must be greater than or equal to ${schema.minimum}`);
		}
		if (schema.maximum !== undefined && value > schema.maximum) {
			addError(state, "maximum", instancePath, appendPointer(schemaPath, "maximum"), `number must be less than or equal to ${schema.maximum}`);
		}
		if (schema.exclusiveMinimum !== undefined && value <= schema.exclusiveMinimum) {
			addError(state, "exclusiveMinimum", instancePath, appendPointer(schemaPath, "exclusiveMinimum"), `number must be greater than ${schema.exclusiveMinimum}`);
		}
		if (schema.exclusiveMaximum !== undefined && value >= schema.exclusiveMaximum) {
			addError(state, "exclusiveMaximum", instancePath, appendPointer(schemaPath, "exclusiveMaximum"), `number must be less than ${schema.exclusiveMaximum}`);
		}
	}

	for (let i = 0; i < (schema.allOf ?? []).length; i++) {
		validateInstanceNode(schema.allOf![i], value, instancePath, appendPointer(appendPointer(schemaPath, "allOf"), i), depth + 1, state);
	}
	if (schema.anyOf !== undefined) {
		let matches = 0;
		for (let i = 0; i < schema.anyOf.length; i++) {
			const branch = createState(state.limits);
			validateInstanceNode(schema.anyOf[i], value, instancePath, appendPointer(appendPointer(schemaPath, "anyOf"), i), depth + 1, branch);
			if (branch.errors.length === 0 && !branch.truncated) matches++;
		}
		if (matches === 0) addError(state, "anyOf", instancePath, appendPointer(schemaPath, "anyOf"), "value must match at least one anyOf schema");
	}
	if (schema.oneOf !== undefined) {
		let matches = 0;
		for (let i = 0; i < schema.oneOf.length; i++) {
			const branch = createState(state.limits);
			validateInstanceNode(schema.oneOf[i], value, instancePath, appendPointer(appendPointer(schemaPath, "oneOf"), i), depth + 1, branch);
			if (branch.errors.length === 0 && !branch.truncated) matches++;
		}
		if (matches !== 1) addError(state, "oneOf", instancePath, appendPointer(schemaPath, "oneOf"), `value must match exactly one oneOf schema; matched ${matches}`);
	}
	if (schema.not !== undefined) {
		const branch = createState(state.limits);
		validateInstanceNode(schema.not, value, instancePath, appendPointer(schemaPath, "not"), depth + 1, branch);
		if (branch.errors.length === 0 && !branch.truncated) {
			addError(state, "not", instancePath, appendPointer(schemaPath, "not"), "value must not match the not schema");
		}
	}
}

export function validateJsonSchema(schema: unknown, options?: JsonSchemaValidationOptions): JsonSchemaValidationResult {
	const state = createState(options);
	validateSchemaNode(schema, "", 0, state, []);
	return toResult(state);
}

export function compileJsonSchema(schema: unknown, options?: JsonSchemaValidationOptions): JsonSchemaCompileResult {
	const schemaResult = validateJsonSchema(schema, options);
	if (!schemaResult.valid) {
		return { success: false, errors: schemaResult.errors, truncated: schemaResult.truncated };
	}
	const typedSchema = schema as JsonSchema;
	const limits = normalizeLimits(options);
	return {
		success: true,
		validator: {
			schema: typedSchema,
			validate(value: unknown): JsonSchemaValidationResult {
				const state: ValidationState = { errors: [], truncated: false, limits };
				validateJsonData(value, "", 0, state, []);
				if (state.errors.length === 0 && !state.truncated) {
					validateInstanceNode(typedSchema, value, "", "", 0, state);
				}
				return toResult(state);
			},
		},
	};
}

export function validateJsonValue(
	schema: unknown,
	value: unknown,
	options?: JsonSchemaValidationOptions
): JsonSchemaValidationResult {
	const compiled = compileJsonSchema(schema, options);
	if (!compiled.success) {
		return { valid: false, errors: compiled.errors, truncated: compiled.truncated };
	}
	return compiled.validator.validate(value);
}
