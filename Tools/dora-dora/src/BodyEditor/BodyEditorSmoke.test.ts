import { BODY_STRUCTS, BODY_STRUCTS_BY_TYPE, BodyDocument, BodyStructDocument } from "./BodyDocument";
import { createBodyJoint, createBodyShape, duplicateBodyItem, translateBodySelection, updateBodyItemField } from "./BodyEditorState";
import { loadBodyDocumentFromJson, writeBodyDocumentToLua } from "./BodyLuaJsonFormat";
import { createBodyPhysicsRuntime } from "./BodyPhysicsRuntime";

const assert = (condition: unknown, message: string) => {
	if (!condition) throw new Error(message);
};

const sampleJson = JSON.stringify([
	"Array",
	["Phyx.Rect", "rect", "Dynamic", [0, 0], 0, [0, 0], [100, 50], 1, 0.4, 0, 0, 0, false, [0, -10], false, false, 0, [
		["Phyx.SubDisk", [20, 0], 12, 1, 0.2, 0, false, 0],
	], "Images/hero.png", [0, 0]],
	["Phyx.Disk", "disk", "Dynamic", [160, 0], 0, [0, 0], 30, 1, 0.3, 0, 0, 0, false, [10, 0], false, false, 0, [], "Atlas/actors.clip|idle", [0, 0]],
	["Phyx.Distance", "link", false, "rect", "disk", [0, 0], [160, 0], 2, 0.7],
]);

export const runBodyEditorSmokeTests = () => {
	const loaded = loadBodyDocumentFromJson(sampleJson);
	assert(loaded.canSave, "sample fixture should be saveable");
	assert(loaded.document.items.length === 3, "sample fixture item count");
	const serialized = writeBodyDocumentToLua(loaded.document);
	assert(serialized.includes("\"Phyx.Rect\",\"rect\",\"Dynamic\""), "serializer preserves Rect field order");
	assert(serialized.includes("\"Phyx.Distance\",\"link\",false,\"rect\",\"disk\""), "serializer preserves Distance field order");
	const roundTrip = loadBodyDocumentFromJson(JSON.stringify(JSON.parse(sampleJson)));
	assert(writeBodyDocumentToLua(roundTrip.document) === serialized, "parser/serializer round-trip should be stable");

	const invalid = loadBodyDocumentFromJson(JSON.stringify(["Array", ["Phyx.Rect", "missing fields"]]));
	assert(!invalid.canSave, "invalid field count should block save");
	assert(invalid.diagnostics.some((item) => item.path === "$[1]" && item.message.includes("Phyx.Rect")), "invalid field diagnostic should locate struct");

	const emptySubShapeForms = loadBodyDocumentFromJson(JSON.stringify([
		"Array",
		["Phyx.Rect", "rectObject", "Static", [0, 0], 0, [0, 0], [120, 80], 1, 0.4, 0, 0, 0, false, [0, -10], false, false, 0, {}, "", [0, 0]],
		["Phyx.Rect", "rectNull", "Static", [0, 0], 0, [0, 0], [120, 80], 1, 0.4, 0, 0, 0, false, [0, -10], false, false, 0, null, "", [0, 0]],
		["Phyx.Rect", "rectArray", "Static", [0, 0], 0, [0, 0], [120, 80], 1, 0.4, 0, 0, 0, false, [0, -10], false, false, 0, ["Array"], "", [0, 0]],
		["Phyx.Rect", "rectFalse", "Static", [0, 0], 0, [0, 0], [120, 80], 1, 0.4, 0, 0, 0, false, [0, -10], false, false, 0, false, "", [0, 0]],
	]));
	assert(emptySubShapeForms.canSave, "empty subShapes object/null/Array/false forms should be normalized");
	const emptySubShapeLua = writeBodyDocumentToLua(emptySubShapeForms.document);
	assert(emptySubShapeLua.includes(",false,\"\""), "empty subShapes should serialize as false");
	assert(!emptySubShapeLua.includes(",nil,\"\""), "empty subShapes should not serialize as nil");

	for (const definition of BODY_STRUCTS) {
		assert(BODY_STRUCTS_BY_TYPE[definition.type].fields.length === definition.fields.length, `${definition.type} field definition mismatch`);
	}

	let doc: BodyDocument = { version: 1, source: "body.lua", items: [], dirty: false };
	let result = createBodyShape(doc, "rect", [0, 0]);
	doc = result.document;
	result = createBodyShape(doc, "disk", [200, 0]);
	doc = result.document;
	result = createBodyJoint(doc, "distance");
	assert(result.diagnostics.length === 0, "distance joint creation should succeed");
	doc = result.document;
	const rect = doc.items.find((item) => item.structType === "Phyx.Rect") as BodyStructDocument;
	result = updateBodyItemField(doc, rect.id, "name", "hero");
	assert(result.diagnostics.length === 0, "rename should succeed");
	assert(result.document.items.some((item) => item.fields.bodyA === "hero" || item.fields.bodyB === "hero"), "rename should update joint refs");
	const copied = duplicateBodyItem(result.document, rect.id);
	assert(copied.diagnostics.length === 0 && copied.document.items.length === 4, "duplicate should add one item");
	const moved = translateBodySelection(copied.document, copied.selectedId ?? null, [12, 8]);
	assert(moved.diagnostics.length === 0, "translate duplicate should succeed");

	const runtime = createBodyPhysicsRuntime(loaded.document);
	assert(runtime.snapshot().bodyCount === 2, "runtime should build bodies");
	assert(runtime.snapshot().fixtureCount === 3, "runtime should build fixtures including subshape");
	for (let i = 0; i < 10; i++) runtime.step(1 / 60);
	assert(runtime.snapshot().bodies.some((body) => body.position[1] < 0), "linearAcceleration should move a dynamic body");

	return true;
};
