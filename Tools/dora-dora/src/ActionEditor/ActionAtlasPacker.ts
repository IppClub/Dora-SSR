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
	image?: HTMLImageElement;
	objectUrl?: string;
};

const imageExts = new Set([".png", ".jpg", ".jpeg", ".webp"]);

const loadImageElement = (filePath: string, objectUrl: string): Promise<HTMLImageElement> => {
	return new Promise((resolve, reject) => {
		const image = new Image();
		image.onload = () => resolve(image);
		image.onerror = () => reject(new Error(`Failed to load image: ${filePath}`));
		image.src = objectUrl;
	});
};

const loadImage = async (filePath: string): Promise<{image: HTMLImageElement; objectUrl: string}> => {
	const response = await fetch(Service.addr(`/${filePath.replace(/\\/g, "/")}`));
	if (!response.ok) throw new Error(`Failed to load image: ${filePath}`);
	const objectUrl = URL.createObjectURL(await response.blob());
	try {
		return {image: await loadImageElement(filePath, objectUrl), objectUrl};
	} catch (error) {
		URL.revokeObjectURL(objectUrl);
		throw error;
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

export const packActionClipsDirectory = async (
	modelPath: string,
	clipsDir: string,
): Promise<{clip: ActionClipDocument; result: ActionPackResult}> => {
	const paths = getActionAtlasPaths(modelPath, clipsDir);
	const listed = await Service.list({path: paths.clipsDirPath});
	if (!listed.success) throw new Error(`Failed to list ${paths.clipsDirPath}`);
	const imageFiles = listed.files.filter((file) => imageExts.has(Info.path.extname(file).toLowerCase()));
	if (imageFiles.length === 0) throw new Error(`No images found in ${paths.clipsDirPath}`);
	const inputs = await Promise.all(imageFiles.map(async (file) => {
		const loaded = await loadImage(file);
		return {
			name: baseName(file),
			path: file,
			width: loaded.image.naturalWidth || loaded.image.width,
			height: loaded.image.naturalHeight || loaded.image.height,
			image: loaded.image,
			objectUrl: loaded.objectUrl,
		};
	}));
	try {
		const result = packActionImages(inputs);
		const canvas = document.createElement("canvas");
		canvas.width = result.width;
		canvas.height = result.height;
		const ctx = canvas.getContext("2d");
		if (!ctx) throw new Error("Failed to create atlas canvas");
		ctx.clearRect(0, 0, canvas.width, canvas.height);
		for (const rect of result.rects) {
			const input = inputs.find((item) => item.path === rect.sourcePath);
			if (input?.image) {
				ctx.drawImage(input.image, rect.x, rect.y, rect.width, rect.height);
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
	} finally {
		for (const input of inputs) {
			if (input.objectUrl) URL.revokeObjectURL(input.objectUrl);
		}
	}
};
