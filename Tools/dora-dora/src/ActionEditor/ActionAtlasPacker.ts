import Info from "../Info";
import * as Service from "../Service";
import type {ActionClipDocument} from "./ActionClip";
import {writeLegacyClip} from "./ActionClip";
import {packActionImages, writePackedActionClip} from "./ActionAtlasCore";
import type {ActionPackResult} from "./ActionAtlasCore";
import {getActionAtlasPaths} from "./ActionPaths";

type LoadedActionPackInput = {
	name: string;
	path: string;
	width: number;
	height: number;
	blob: Blob;
};

const imageExts = new Set([".png", ".jpg", ".jpeg", ".webp"]);
const maxInputImageSize = 2048;
const maxAtlasSize = 4096;
const maxAtlasPixels = maxAtlasSize * maxAtlasSize;

const formatPixels = (width: number, height: number) => `${Math.ceil(width)}x${Math.ceil(height)}`;

const validateInputImageSize = (filePath: string, width: number, height: number) => {
	if (width > maxInputImageSize || height > maxInputImageSize) {
		throw new Error(`Image is too large: ${Info.path.basename(filePath)} (${formatPixels(width, height)}), max ${maxInputImageSize}x${maxInputImageSize}`);
	}
};

const validateAtlasSize = (width: number, height: number) => {
	if (width > maxAtlasSize || height > maxAtlasSize || width * height > maxAtlasPixels) {
		throw new Error(`Packed atlas is too large: ${formatPixels(width, height)}, max ${maxAtlasSize}x${maxAtlasSize}. Use smaller images or split them into multiple .clips directories.`);
	}
};

const loadImageElement = (filePath: string, objectUrl: string): Promise<HTMLImageElement> => {
	return new Promise((resolve, reject) => {
		const image = new Image();
		image.onload = () => resolve(image);
		image.onerror = () => reject(new Error(`Failed to load image: ${filePath}`));
		image.src = objectUrl;
	});
};

const loadImageFromBlob = async (filePath: string, blob: Blob): Promise<{image: CanvasImageSource; width: number; height: number; objectUrl?: string}> => {
	if (typeof createImageBitmap === "function") {
		try {
			const image = await createImageBitmap(blob);
			return {image, width: image.width, height: image.height};
		} catch {
			// Fall through to the HTMLImageElement path for browsers or image encodings
			// where createImageBitmap is unavailable or stricter than <img> decoding.
		}
	}
	const objectUrl = URL.createObjectURL(blob);
	try {
		const image = await loadImageElement(filePath, objectUrl);
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

const releaseDecodedImage = (decoded: {image: CanvasImageSource; objectUrl?: string}) => {
	if (decoded.objectUrl) URL.revokeObjectURL(decoded.objectUrl);
	if (decoded.image instanceof ImageBitmap) decoded.image.close();
};

const loadImageBlob = async (filePath: string) => {
	const response = await fetch(Service.addr(`/${filePath.replace(/\\/g, "/")}`));
	if (!response.ok) throw new Error(`Failed to load image: ${filePath}`);
	return response.blob();
};

const loadImageInfo = async (filePath: string): Promise<LoadedActionPackInput> => {
	const blob = await loadImageBlob(filePath);
	const decoded = await loadImageFromBlob(filePath, blob);
	try {
		validateInputImageSize(filePath, decoded.width, decoded.height);
		return {
			name: baseName(filePath),
			path: filePath,
			width: decoded.width,
			height: decoded.height,
			blob,
		};
	} finally {
		releaseDecodedImage(decoded);
	}
};

const canvasToBlob = (canvas: HTMLCanvasElement) => {
	return new Promise<Blob>((resolve, reject) => {
		canvas.toBlob((blob) => {
			if (blob) resolve(blob);
			else reject(new Error("Failed to encode atlas png"));
		}, "image/png");
	});
};

const uploadFile = async (directory: string, fileName: string, blob: Blob) => {
	const formData = new FormData();
	formData.append("file", blob, fileName);
	const response = await fetch(Service.addr(`/upload?path=${encodeURIComponent(directory)}`), {
		method: "POST",
		body: formData,
	});
	if (!response.ok) {
		throw new Error(`Failed to upload ${fileName}: ${response.status}`);
	}
};

const baseName = (file: string) => {
	const name = Info.path.basename(file);
	const ext = Info.path.extname(name);
	return ext ? name.slice(0, -ext.length) : name;
};

const clipsEntryPath = (clipsDirPath: string, file: string) => {
	const normalized = file.replace(/\\/g, "/");
	if (normalized.startsWith("/") || normalized.indexOf("/") >= 0) return normalized;
	return Info.path.join(clipsDirPath, normalized).replace(/\\/g, "/");
};

export const packActionClipsDirectory = async (
	modelPath: string,
	clipsDir: string,
): Promise<{clip: ActionClipDocument; result: ActionPackResult}> => {
	const paths = getActionAtlasPaths(modelPath, clipsDir);
	const listed = await Service.list({path: paths.clipsDirPath});
	if (!listed.success) throw new Error(`Failed to list ${paths.clipsDirPath}`);
	const imageFiles = listed.files
		.filter((file) => imageExts.has(Info.path.extname(file).toLowerCase()))
		.map((file) => clipsEntryPath(paths.clipsDirPath, file));
	if (imageFiles.length === 0) throw new Error(`No images found in ${paths.clipsDirPath}`);
	const inputs: LoadedActionPackInput[] = [];
	for (const file of imageFiles) {
		inputs.push(await loadImageInfo(file));
	}
	const result = packActionImages(inputs);
	validateAtlasSize(result.width, result.height);
	const canvas = document.createElement("canvas");
	canvas.width = result.width;
	canvas.height = result.height;
	const ctx = canvas.getContext("2d");
	if (!ctx) throw new Error("Failed to create atlas canvas");
	ctx.clearRect(0, 0, canvas.width, canvas.height);
	for (const rect of result.rects) {
		const input = inputs.find((item) => item.path === rect.sourcePath);
		if (input) {
			const decoded = await loadImageFromBlob(input.path, input.blob);
			try {
				ctx.drawImage(decoded.image, rect.x, rect.y, rect.width, rect.height);
			} finally {
				releaseDecodedImage(decoded);
			}
		}
	}
	const clip: ActionClipDocument = {
		...writePackedActionClip(Info.path.basename(paths.pngPath), result),
		clipPath: paths.clipPath,
		texturePath: paths.pngPath,
	};
	const png = await canvasToBlob(canvas);
	await uploadFile(Info.path.dirname(paths.pngPath), Info.path.basename(paths.pngPath), png);
	const written = await Service.write({path: paths.clipPath, content: writeLegacyClip(clip)});
	if (!written.success) throw new Error(`Failed to write ${paths.clipPath}`);
	return {clip, result};
};
