import esbuild from "esbuild";
import fs from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { pathToFileURL } from "node:url";

const repoRoot = path.resolve(import.meta.dirname, "../../..");
const entry = path.join(repoRoot, "Tools/dora-dora/src/ActionEditor/index.ts");
const outFile = path.join(os.tmpdir(), `action-editor-data-${Date.now()}.mjs`);

await esbuild.build({
	entryPoints: [entry],
	bundle: true,
	platform: "node",
	format: "esm",
	outfile: outFile,
	logLevel: "silent",
});

const {
	parseLegacyModel,
	writeLegacyModel,
	loadActionDocumentFromModelContent,
	parseLegacyClip,
	validateActionDocumentClips,
	chooseActionClipsDirectory,
	getActionAtlasPaths,
	defaultActionViewport,
	addChildActionNode,
	removeActionNode,
	reorderActionNode,
	addActionKeyPoint,
	updateActionKeyPoint,
	removeActionKeyPoint,
	addActionLook,
	setActionNodeLookHidden,
	buildActionRenderRects,
	hitTestActionRenderRects,
	screenToModel,
	addActionAnimation,
	removeActionAnimation,
	upsertActionKeyFrame,
	deleteActionKeyFrame,
	copyActionKeyFrame,
	pasteActionKeyFrame,
	moveActionKeyFrame,
	setActionKeyFrameEvent,
	sampleActionKeyTrack,
	getActionAnimationDuration,
	packActionImages,
	writePackedActionClip,
} = await import(pathToFileURL(outFile).href);

const fixture = (name) => path.join(repoRoot, "Docs/design/Dorothy/project/Resources/ActionEditor/Model/Output", name);
const readFixture = (name) => fs.readFile(fixture(name), "utf8");
const assert = (condition, message) => {
	if (!condition) throw new Error(message);
};

const countNodes = (node) => 1 + node.children.reduce((sum, child) => sum + countNodes(child), 0);

for (const name of ["role", "flandre"]) {
	const modelPath = fixture(`${name}.model`);
	const xml = await readFixture(`${name}.model`);
	const doc = parseLegacyModel(xml, modelPath);
	assert(doc.source === "model", `${name}: source should be model`);
	assert(doc.clipFile === `${name}.clip`, `${name}: clip file should round-trip`);
	assert(countNodes(doc.root) > 1, `${name}: expected child nodes`);
	assert(doc.animations.length > 0, `${name}: expected animation names`);

	const written = writeLegacyModel(doc);
	const reparsed = parseLegacyModel(written, modelPath);
	assert(reparsed.clipFile === doc.clipFile, `${name}: writer lost clip file`);
	assert(countNodes(reparsed.root) === countNodes(doc.root), `${name}: writer changed node count`);
	assert(reparsed.animations.join("|") === doc.animations.join("|"), `${name}: writer changed animations`);

	const clip = parseLegacyClip(await readFixture(`${name}.clip`), fixture(`${name}.clip`));
	assert(clip.texturePath.endsWith(`/Output/${name}.png`), `${name}: texture path should resolve beside .clip`);
	const diagnostics = validateActionDocumentClips(doc, clip);
	assert(diagnostics.length === 0, `${name}: expected all node clips to exist`);
	if (name === "role") {
		doc.root.children[0].clip = "__missing__";
		const missingDiagnostics = validateActionDocumentClips(doc, clip);
		assert(missingDiagnostics.some((item) => item.nodeId === doc.root.children[0].id), `${name}: missing clip should report node diagnostic`);
	}
}

const failed = loadActionDocumentFromModelContent("<A><B>", "Hero.model");
assert(failed.dirty === true, "bad .model should mark document dirty");
assert(failed.diagnostics.some((item) => item.severity === "error"), "bad .model should report an error");
assert(failed.document.clipFile === "Hero.clip", "bad .model should create empty document with same-basename clip");

const selected = chooseActionClipsDirectory("res/Hero.model", ["Other.clips", "Hero.clips", "notes.txt"]);
assert(selected === "Hero.clips", "same-basename .clips directory should be selected by default");
const paths = getActionAtlasPaths("res/Hero.model", "Other.clips");
assert(paths.clipsDirPath === "res/Other.clips", "clips input path mismatch");
assert(paths.clipPath === "res/Other.clip", "clip output path mismatch");
assert(paths.pngPath === "res/Other.png", "png output path mismatch");
assert(paths.modelClipReference === "Other.clip", "model clip reference mismatch");

const roleDoc = parseLegacyModel(await readFixture("role.model"), fixture("role.model"));
const roleClip = parseLegacyClip(await readFixture("role.clip"), fixture("role.clip"));
const childCount = roleDoc.root.children.length;
const withChild = addChildActionNode(roleDoc, roleDoc.root.id);
assert(withChild.root.children.length === childCount + 1, "add child should append a node to selected parent");
const addedNodeId = withChild.root.children[withChild.root.children.length - 1].id;
const withoutChild = removeActionNode(withChild, addedNodeId);
assert(withoutChild.root.children.length === childCount, "delete node should remove selected child");
if (roleDoc.root.children.length > 1) {
	const firstId = roleDoc.root.children[0].id;
	const reordered = reorderActionNode(roleDoc, firstId, 1);
	assert(reordered.root.children[1].id === firstId, "reorder should move node among siblings");
}
const withLook = addActionLook(roleDoc);
const newLook = withLook.looks[withLook.looks.length - 1];
const hiddenDoc = setActionNodeLookHidden(withLook, withLook.root.children[0].id, newLook, true);
assert(hiddenDoc.root.children[0].hiddenInLooks.includes(newLook), "look edit should store hidden node");
let keyPointDoc = addActionKeyPoint(roleDoc);
assert(keyPointDoc.keyPoints.length === roleDoc.keyPoints.length + 1, "add key point should append point");
keyPointDoc = updateActionKeyPoint(keyPointDoc, keyPointDoc.keyPoints.length - 1, (point) => ({ ...point, name: "Weapon", x: 12, y: 34 }));
assert(keyPointDoc.keyPoints[keyPointDoc.keyPoints.length - 1].name === "Weapon", "update key point should edit point fields");
keyPointDoc = removeActionKeyPoint(keyPointDoc, keyPointDoc.keyPoints.length - 1);
assert(keyPointDoc.keyPoints.length === roleDoc.keyPoints.length, "remove key point should delete selected point");
const rects = buildActionRenderRects(hiddenDoc, roleClip, null);
assert(rects.length === countNodes(hiddenDoc.root), "default pose render should include all nodes");
const firstVisibleChild = rects.find((rect) => rect.nodeId === hiddenDoc.root.children[0].id);
assert(firstVisibleChild, "render rect should preserve node id");
const topmostRect = rects[rects.length - 1];
const hit = hitTestActionRenderRects(rects, {
	x: topmostRect.x + topmostRect.width / 2,
	y: topmostRect.y + topmostRect.height / 2,
});
assert(hit === topmostRect.nodeId, "hit test should select topmost node rect");
const hiddenRects = buildActionRenderRects(hiddenDoc, roleClip, newLook);
const hiddenRect = hiddenRects.find((rect) => rect.nodeId === hiddenDoc.root.children[0].id);
assert(hiddenRect && hiddenRect.visible === false, "look render should hide nodes listed in hiddenInLooks");
const viewport = defaultActionViewport();
const modelPoint = screenToModel({ x: 320, y: 240 }, viewport, { x: 0, y: 0, width: 640, height: 480 });
assert(modelPoint.x === 0 && modelPoint.y === 0, "viewport origin should map screen center to model origin");

const animationResult = addActionAnimation(roleDoc);
assert(animationResult.document.animations.includes(animationResult.animation), "add animation should register animation name");
const animatedNode = animationResult.document.root.children[0];
let keyedDoc = upsertActionKeyFrame(animationResult.document, animatedNode.id, animationResult.animation, 0);
keyedDoc = {
	...keyedDoc,
	root: {
		...keyedDoc.root,
		children: keyedDoc.root.children.map((child) => child.id === animatedNode.id ? {
			...child,
			transform: {
				...child.transform,
				position: { x: child.transform.position.x + 60, y: child.transform.position.y + 30 },
			},
		} : child),
	},
};
keyedDoc = upsertActionKeyFrame(keyedDoc, animatedNode.id, animationResult.animation, 1);
const keyedTrack = keyedDoc.root.children[0].tracks[animationResult.animation];
assert(keyedTrack.type === "key" && keyedTrack.keyframes.length === 2, "keyframe edit should create key track");
assert(getActionAnimationDuration(keyedDoc, animationResult.animation) === 1, "animation duration should follow last key");
const sampled = sampleActionKeyTrack(keyedTrack, 0.5);
assert(sampled && sampled.position.x !== keyedTrack.keyframes[0].transform.position.x, "playback sampler should interpolate transform");
keyedDoc = setActionKeyFrameEvent(keyedDoc, animatedNode.id, animationResult.animation, 1, "hit");
assert(keyedDoc.root.children[0].tracks[animationResult.animation].keyframes[1].event === "hit", "key event should round-trip in working model");
const copiedKey = copyActionKeyFrame(keyedDoc, animatedNode.id, animationResult.animation, 1);
assert(copiedKey && copiedKey.event === "hit", "copy key should return current keyframe");
keyedDoc = pasteActionKeyFrame(keyedDoc, animatedNode.id, animationResult.animation, 2, copiedKey);
assert(keyedDoc.root.children[0].tracks[animationResult.animation].keyframes.some((frame) => frame.time === 2), "paste key should insert copied key at target time");
keyedDoc = moveActionKeyFrame(keyedDoc, animatedNode.id, animationResult.animation, 2, 3);
assert(keyedDoc.root.children[0].tracks[animationResult.animation].keyframes.some((frame) => frame.time === 3), "move key should update keyframe absolute time");
const animatedRects = buildActionRenderRects(keyedDoc, roleClip, null, animationResult.animation, 1);
const animatedRect = animatedRects.find((rect) => rect.nodeId === animatedNode.id);
assert(animatedRect && animatedRect.x !== firstVisibleChild.x, "animated render should use sampled pose");
keyedDoc = deleteActionKeyFrame(keyedDoc, animatedNode.id, animationResult.animation, 1);
assert(!keyedDoc.root.children[0].tracks[animationResult.animation].keyframes.some((frame) => frame.time === 1), "delete key should remove matching keyframe");
const removedAnimation = removeActionAnimation(keyedDoc, animationResult.animation);
assert(!removedAnimation.animations.includes(animationResult.animation), "remove animation should delete animation name");
assert(removedAnimation.root.children[0].tracks[animationResult.animation] === undefined, "remove animation should delete node tracks");
const packed = packActionImages([
	{ name: "a", path: "a.png", width: 32, height: 16 },
	{ name: "b", path: "b.png", width: 16, height: 32 },
]);
assert(packed.width >= 64 && packed.height >= 64, "atlas packer should create a minimum atlas");
assert(packed.rects.length === 2, "atlas packer should include all images");
assert(packed.rects.every((rect) => rect.x >= 0 && rect.y >= 0 && rect.width > 0 && rect.height > 0), "atlas packer should assign valid rects");
const packedClip = writePackedActionClip("Hero.png", packed);
assert(Object.keys(packedClip.rects).length === 2 && packedClip.textureFile === "Hero.png", "packed clip writer should emit clip rect map");

await fs.unlink(outFile);
console.log("ActionEditor data verification passed");
