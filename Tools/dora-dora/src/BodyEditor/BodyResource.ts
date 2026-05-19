import Info from "../Info";

export type BodyFaceKind = "empty" | "sprite" | "clip" | "playable";

export type BodyFaceReference = {
	kind: BodyFaceKind;
	source: string;
	clipName?: string;
};

const imageExts = [".png", ".jpg", ".jpeg", ".webp"];

export type BodyFacePreviewAsset = {
	kind: "image";
	image: HTMLImageElement;
	width: number;
	height: number;
	objectUrl: string;
} | {
	kind: "clip";
	image: HTMLImageElement;
	x: number;
	y: number;
	width: number;
	height: number;
	objectUrl: string;
} | {
	kind: "placeholder";
	label: string;
};

export const isBodyFaceImageSource = (source: string) => {
	const lower = source.toLowerCase();
	return imageExts.some((ext) => lower.endsWith(ext));
};

export const parseBodyFace = (face: string): BodyFaceReference => {
	if (face === "") return { kind: "empty", source: "" };
	if (face.includes(":")) return { kind: "playable", source: face };
	const clipIndex = face.indexOf(".clip|");
	if (clipIndex >= 0) {
		return {
			kind: "clip",
			source: face.slice(0, clipIndex + 5),
			clipName: face.slice(clipIndex + 6),
		};
	}
	if (isBodyFaceImageSource(face)) {
		return { kind: "sprite", source: face };
	}
	return { kind: "sprite", source: face };
};

export const getBodyFaceLabel = (face: string) => {
	const parsed = parseBodyFace(face);
	switch (parsed.kind) {
		case "empty": return "";
		case "clip": return `clip ${parsed.clipName ?? ""}`;
		case "playable": return "playable";
		case "sprite": return "sprite";
	}
};

export const bodyResourceToServedUrl = (resourcePath: string, resourceBasePath: string) => {
	const normalized = resourcePath.replace(/\\/g, "/");
	const base = resourceBasePath.replace(/\\/g, "/");
	if (normalized.startsWith(base)) {
		return "/" + normalized.slice(base.length).replace(/^\/+/, "");
	}
	return "/" + normalized.replace(/^\/+/, "");
};

export const resolveBodyFaceResourcePath = (resourcePath: string, resourceBasePath: string) => {
	if (resourcePath === "") return "";
	const normalized = resourcePath.replace(/\\/g, "/");
	if (normalized.startsWith("/") || /^[A-Za-z]:[\\/]/.test(resourcePath)) return resourcePath;
	return Info.path.normalize(Info.path.join(resourceBasePath, resourcePath));
};
