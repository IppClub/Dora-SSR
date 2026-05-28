/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { ChangeEvent, useMemo, useRef, useState } from 'react';
import { Box, Button, Stack, Typography } from '@mui/material';
import type { AlertColor } from '@mui/material';
import AddPhotoAlternateIcon from '@mui/icons-material/AddPhotoAlternate';
import DeleteOutlineIcon from '@mui/icons-material/DeleteOutline';
import Info from '../Info';
import * as Service from '../Service';
import type { ImageSpriteDocument } from './SpriteDocument';
import { cloneImageSpriteDocument } from './SpriteDocument';

interface SpriteReferencePanelProps {
	document: ImageSpriteDocument;
	filePath: string;
	resourceBasePath: string;
	readOnly: boolean;
	onDocumentChange: (document: ImageSpriteDocument) => void;
	addAlert?: (message: string, severity: AlertColor, raw?: boolean) => void;
}

const { path } = Info;
const referenceImageSize = 512;
const supportedExtensions = new Set([".png", ".jpg", ".jpeg", ".webp"]);

const removeSpriteJsonSuffix = (fileName: string) => {
	const suffix = ".sprite.json";
	return fileName.toLowerCase().endsWith(suffix) ? fileName.slice(0, -suffix.length) : path.basename(fileName, path.extname(fileName));
};

const normalizeExtension = (fileName: string) => {
	const extension = path.extname(fileName).toLowerCase();
	return extension === ".jpeg" ? ".jpg" : extension;
};

const toWebPath = (filePath: string) => filePath.split("\\").join("/");

const createImageElement = (source: string) => {
	return new Promise<HTMLImageElement>((resolve, reject) => {
		const image = new Image();
		image.onload = () => resolve(image);
		image.onerror = () => reject(new Error("failed to decode character portrait"));
		image.src = source;
	});
};

const canvasToBlob = (canvas: HTMLCanvasElement) => {
	return new Promise<Blob>((resolve, reject) => {
		canvas.toBlob((blob) => {
			if (blob === null) {
				reject(new Error("failed to encode character portrait"));
				return;
			}
			resolve(blob);
		}, "image/png");
	});
};

const normalizeReferenceImageBlob = async (file: File) => {
	const objectUrl = URL.createObjectURL(file);
	try {
		const image = await createImageElement(objectUrl);
		const canvas = window.document.createElement("canvas");
		canvas.width = referenceImageSize;
		canvas.height = referenceImageSize;
		const context = canvas.getContext("2d");
		if (context === null) {
			throw new Error("failed to create character portrait canvas");
		}
		context.clearRect(0, 0, canvas.width, canvas.height);
		context.imageSmoothingEnabled = true;
		context.imageSmoothingQuality = "high";
		const scale = Math.min(referenceImageSize / image.naturalWidth, referenceImageSize / image.naturalHeight);
		const drawWidth = Math.max(1, Math.round(image.naturalWidth * scale));
		const drawHeight = Math.max(1, Math.round(image.naturalHeight * scale));
		const drawX = Math.round((referenceImageSize - drawWidth) / 2);
		const drawY = Math.round((referenceImageSize - drawHeight) / 2);
		context.drawImage(image, drawX, drawY, drawWidth, drawHeight);
		return canvasToBlob(canvas);
	} finally {
		URL.revokeObjectURL(objectUrl);
	}
};

const uploadFileBlob = async (directory: string, fileName: string, blob: Blob) => {
	const formData = new FormData();
	formData.append('file', blob, fileName);
	const response = await fetch(Service.addr(`/upload?path=${encodeURIComponent(directory)}`), {
		method: 'POST',
		body: formData,
	});
	if (!response.ok) {
		throw new Error(`upload failed: ${response.status}`);
	}
};

const getPreviewUrl = (resourceBasePath: string, filePath: string, imageName: string | undefined, previewRevision: number) => {
	if (imageName === undefined || resourceBasePath === "") return undefined;
	const imagePath = path.join(path.dirname(filePath), imageName);
	return Service.addr(`/${toWebPath(path.relative(resourceBasePath, imagePath))}?t=${previewRevision}`);
};

export default function SpriteReferencePanel(props: SpriteReferencePanelProps) {
	const { document, filePath, resourceBasePath, readOnly, onDocumentChange, addAlert } = props;
	const inputRef = useRef<HTMLInputElement | null>(null);
	const [uploading, setUploading] = useState(false);
	const [previewRevision, setPreviewRevision] = useState(0);
	const previewUrl = useMemo(() => {
		return getPreviewUrl(resourceBasePath, filePath, document.identityReferenceImage, previewRevision);
	}, [document.identityReferenceImage, filePath, previewRevision, resourceBasePath]);

	const handleUpload = (event: ChangeEvent<HTMLInputElement>) => {
		const file = event.target.files?.[0];
		event.target.value = "";
		if (file === undefined) return;
		const extension = normalizeExtension(file.name);
		if (!supportedExtensions.has(extension)) {
			addAlert?.("Character portrait must be PNG, JPG, or WebP.", "warning", true);
			return;
		}
		const directory = path.dirname(filePath);
		const baseName = removeSpriteJsonSuffix(path.basename(filePath));
		const referenceName = `${baseName}.portrait.png`;
		setUploading(true);
		normalizeReferenceImageBlob(file).then((blob) => uploadFileBlob(directory, referenceName, blob)).then(() => {
			const nextDocument = cloneImageSpriteDocument(document);
			nextDocument.identityReferenceImage = referenceName;
			onDocumentChange(nextDocument);
			Service.emitUpdateFile(path.join(directory, referenceName), true);
			setPreviewRevision((revision) => revision + 1);
			addAlert?.(`Character portrait saved as ${referenceName}`, "success", true);
		}).catch((error: unknown) => {
			const message = error instanceof Error ? error.message : "Failed to upload character portrait";
			addAlert?.(message, "error", true);
		}).finally(() => {
			setUploading(false);
		});
	};

	return <Stack spacing={1.25} className="image-sprite-panel">
		<Typography variant="subtitle2" className="image-sprite-panel-title">Character Reference</Typography>
		<Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.62)', lineHeight: 1.45 }}>
			Upload one character portrait. The generator stores it as a project PNG and uses internal action templates.
		</Typography>
		<input ref={inputRef} type="file" accept="image/png,image/jpeg,image/webp" hidden onChange={handleUpload} />
		<Button
			variant="outlined"
			startIcon={<AddPhotoAlternateIcon />}
			disabled={readOnly || uploading}
			onClick={() => inputRef.current?.click()}
		>
			{uploading ? "Preparing portrait..." : "Upload Character Portrait"}
		</Button>
		{document.identityReferenceImage === undefined ? <Box className="image-sprite-reference-empty">
			<Typography variant="caption">No character portrait selected.</Typography>
		</Box> : <Stack spacing={1}>
			<Stack direction="row" justifyContent="space-between" alignItems="center" gap={1}>
				<Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.72)', wordBreak: 'break-all' }}>
					{document.identityReferenceImage}
				</Typography>
				<Button
					size="small"
					color="inherit"
					disabled={readOnly || uploading}
					startIcon={<DeleteOutlineIcon fontSize="small" />}
					onClick={() => {
						const nextDocument = cloneImageSpriteDocument(document);
						delete nextDocument.identityReferenceImage;
						onDocumentChange(nextDocument);
					}}
				>
					Clear
				</Button>
			</Stack>
			<Box className="image-sprite-reference-preview">
				{previewUrl === undefined ? null : <img src={previewUrl} alt="Character portrait" />}
			</Box>
		</Stack>}
	</Stack>;
}
