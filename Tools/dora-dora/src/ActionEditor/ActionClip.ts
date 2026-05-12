import type { ActionDiagnostic, ActionDocument, ActionNode } from "./ActionDocument";
import { escapeXml, parseActionXml } from "./ActionXml";

export type ActionClipRect = {
	name: string;
	x: number;
	y: number;
	width: number;
	height: number;
};

export type ActionClipDocument = {
	clipPath?: string;
	textureFile: string;
	texturePath: string;
	rects: Record<string, ActionClipRect>;
};

const num = (value: string | undefined, fallback: number) => {
	if (value === undefined || value === "") return fallback;
	const parsed = Number(value);
	return Number.isFinite(parsed) ? parsed : fallback;
};

const parseRect = (value: string | undefined): Omit<ActionClipRect, "name"> => {
	const [x, y, width, height] = (value ?? "").split(",");
	return {
		x: num(x, 0),
		y: num(y, 0),
		width: num(width, 0),
		height: num(height, 0),
	};
};

const resolveSiblingPath = (filePath: string | undefined, sibling: string) => {
	if (!filePath || sibling === "" || sibling.startsWith("/")) return sibling;
	const normalized = filePath.replace(/\\/g, "/");
	const index = normalized.lastIndexOf("/");
	if (index < 0) return sibling;
	return `${normalized.slice(0, index)}/${sibling}`;
};

export const parseLegacyClip = (xml: string, clipPath?: string): ActionClipDocument => {
	const root = parseActionXml(xml);
	if (root.name !== "A") throw new Error("Expected .clip root <A>");
	const rects: Record<string, ActionClipRect> = {};
	for (const child of root.children) {
		if (child.name !== "B") continue;
		const name = child.attrs.A ?? "";
		rects[name] = { name, ...parseRect(child.attrs.B) };
	}
	const textureFile = root.attrs.A ?? "";
	return {
		clipPath,
		textureFile,
		texturePath: resolveSiblingPath(clipPath, textureFile),
		rects,
	};
};

export const writeLegacyClip = (clip: ActionClipDocument) => {
	let out = `<A A="${escapeXml(clip.textureFile)}">`;
	for (const rect of Object.values(clip.rects)) {
		out += `<B A="${escapeXml(rect.name)}" B="${rect.x},${rect.y},${rect.width},${rect.height}"/>`;
	}
	out += "</A>";
	return out;
};

const collectMissingClips = (node: ActionNode, clip: ActionClipDocument, diagnostics: ActionDiagnostic[]) => {
	if (node.clip && !clip.rects[node.clip]) {
		diagnostics.push({
			severity: "warning",
			message: `Clip "${node.clip}" is not defined in ${clip.clipPath ?? "clip document"}`,
			path: clip.clipPath,
			nodeId: node.id,
		});
	}
	for (const child of node.children) {
		collectMissingClips(child, clip, diagnostics);
	}
};

export const validateActionDocumentClips = (document: ActionDocument, clip: ActionClipDocument): ActionDiagnostic[] => {
	const diagnostics: ActionDiagnostic[] = [];
	collectMissingClips(document.root, clip, diagnostics);
	return diagnostics;
};
