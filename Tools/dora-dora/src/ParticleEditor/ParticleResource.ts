import * as Service from "../Service";
import Info from "../Info";
import { parseLegacyClip } from "../ActionEditor/ActionClip";
import { ParticleRect } from "./ParticleDocument";
import { ParticleTextureSource } from "./ParticleWebGLRenderer";

const imageExts = [".png", ".jpg", ".jpeg", ".webp"];

export type ParticleTextureResourceEntry = {
	kind: "image" | "clip";
	path: string;
	relative: string;
};

export type ParticleResourceResult = {
	texture?: ParticleTextureSource;
	source: "default" | "image" | "clip";
	label: string;
	warning?: string;
	objectUrl?: string;
};

export const particleResourceToServedUrl = (resourcePath: string, resourceBasePath: string) => {
	const normalized = resourcePath.replace(/\\/g, "/");
	const base = resourceBasePath.replace(/\\/g, "/");
	if (normalized.startsWith(base)) {
		return "/" + normalized.slice(base.length).replace(/^\/+/, "");
	}
	return "/" + normalized.replace(/^\/+/, "");
};

export const resolveParticleResourcePath = (resourcePath: string, resourceBasePath: string) => {
	if (resourcePath === "") return "";
	const normalized = resourcePath.replace(/\\/g, "/");
	if (normalized.startsWith("/") || /^[A-Za-z]:[\\/]/.test(resourcePath)) return resourcePath;
	return Info.path.normalize(Info.path.join(resourceBasePath, resourcePath));
};

export const isParticleTextureImageSource = (source: string) => {
	const lower = source.toLowerCase();
	return imageExts.some((ext) => lower.endsWith(ext));
};

const normalizeResourcePath = (path: string) => path.replace(/\\/g, "/");

const toResourceRelativePath = (path: string, root: string) => normalizeResourcePath(Info.path.relative(root, path));

export const findParticleTextureResourceFiles = async (root: string) => {
	const listed = await Service.list({ path: root });
	if (!listed.success) return [];
	const entries = listed.files.flatMap((file): ParticleTextureResourceEntry[] => {
		const fullPath = Info.path.isAbsolute(file) ? Info.path.normalize(file) : Info.path.normalize(Info.path.join(root, file));
		const relative = toResourceRelativePath(fullPath, root);
		if (isParticleTextureImageSource(file)) return [{ kind: "image", path: fullPath, relative }];
		if (Info.path.extname(file).toLowerCase() === ".clip") return [{ kind: "clip", path: fullPath, relative }];
		return [];
	});
	return entries.sort((a, b) => a.relative.localeCompare(b.relative));
};

const loadImageAsset = async (filePath: string, servedResourceBasePath: string, cacheKey?: number) => {
	const url = Service.addr(particleResourceToServedUrl(filePath, servedResourceBasePath));
	const response = await fetch(`${url}${url.includes("?") ? "&" : "?"}v=${cacheKey ?? Date.now()}`);
	if (!response.ok) throw new Error(`Failed to load image: ${filePath}`);
	const objectUrl = URL.createObjectURL(await response.blob());
	try {
		const image = await new Promise<HTMLImageElement>((resolve, reject) => {
			const element = new Image();
			element.onload = () => resolve(element);
			element.onerror = () => reject(new Error(`Failed to decode image: ${filePath}`));
			element.src = objectUrl;
		});
		return {
			image,
			width: image.naturalWidth || image.width,
			height: image.naturalHeight || image.height,
			objectUrl,
		};
	} catch (error) {
		URL.revokeObjectURL(objectUrl);
		throw error;
	}
};

const applyRectUv = (width: number, height: number, rect: ParticleRect) => {
	if (rect.width <= 0 || rect.height <= 0 || width <= 0 || height <= 0) return undefined;
	return {
		left: rect.x / width,
		top: rect.y / height,
		right: (rect.x + rect.width) / width,
		bottom: (rect.y + rect.height) / height,
	};
};

const textureRectWarning = (width: number, height: number, rect: ParticleRect) => {
	if (rect.width <= 0 || rect.height <= 0) return undefined;
	if (rect.x < 0 || rect.y < 0 || rect.x + rect.width > width || rect.y + rect.height > height) {
		return `textureRect ${rect.x},${rect.y},${rect.width},${rect.height} exceeds texture bounds ${width}x${height}.`;
	}
	return undefined;
};

export const loadParticleTexture = async (
	textureName: string,
	textureRect: ParticleRect,
	resourceBasePath: string,
	servedResourceBasePath: string,
	cacheKey?: number,
): Promise<ParticleResourceResult> => {
	if (textureName.trim() === "") {
		return { source: "default", label: "default particle texture" };
	}
	const lower = textureName.toLowerCase();
	try {
		if (lower.includes(".clip|")) {
			const clipIndex = textureName.indexOf(".clip|");
			const clipPath = resolveParticleResourcePath(textureName.slice(0, clipIndex + 5), resourceBasePath);
			const clipName = textureName.slice(clipIndex + 6);
			const res = await Service.read({ path: clipPath });
			if (!res.success) throw new Error(`Failed to read clip: ${clipPath}`);
			const clip = parseLegacyClip(res.content, clipPath);
			const rect = clip.rects[clipName];
			if (!rect) throw new Error(`Clip frame not found: ${clipName}`);
			const image = await loadImageAsset(clip.texturePath, servedResourceBasePath, cacheKey);
			return {
				source: "clip",
				label: `${Info.path.basename(clipPath)}|${clipName}`,
				objectUrl: image.objectUrl,
				texture: {
					image: image.image,
					width: image.width,
					height: image.height,
					uv: applyRectUv(image.width, image.height, rect),
				},
			};
		}
		if (isParticleTextureImageSource(textureName)) {
			const imagePath = resolveParticleResourcePath(textureName, resourceBasePath);
			const image = await loadImageAsset(imagePath, servedResourceBasePath, cacheKey);
			return {
				source: "image",
				label: textureName,
				warning: textureRectWarning(image.width, image.height, textureRect),
				objectUrl: image.objectUrl,
				texture: {
					image: image.image,
					width: image.width,
					height: image.height,
					uv: applyRectUv(image.width, image.height, textureRect),
				},
			};
		}
		return { source: "default", label: "default particle texture", warning: `Unsupported texture reference: ${textureName}` };
	} catch (error) {
		return {
			source: "default",
			label: "default particle texture",
			warning: error instanceof Error ? error.message : `Failed to load texture: ${textureName}`,
		};
	}
};
