/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { Box, Button, Stack, Typography } from '@mui/material';
import type { AlertColor } from '@mui/material';
import AddPhotoAlternateIcon from '@mui/icons-material/AddPhotoAlternate';
import DeleteOutlineIcon from '@mui/icons-material/DeleteOutline';
import { ChangeEvent, useMemo, useRef, useState } from 'react';
import Info from '../Info';
import * as Service from '../Service';
import type { PixelDocument } from './PixelDocument';
import { clonePixelDocument } from './PixelDocument';

interface PixelReferencePanelProps {
	document: PixelDocument;
	filePath: string;
	resourceBasePath: string;
	readOnly: boolean;
	onDocumentChange: (document: PixelDocument) => void;
	addAlert?: (message: string, severity: AlertColor, raw?: boolean) => void;
}

type PixelReferenceField = "identityReferenceImage" | "motionReferenceImage";
type PixelReferenceRole = "identity" | "motion";

interface PixelReferenceSlot {
	role: PixelReferenceRole;
	field: PixelReferenceField;
	suffix: string;
	title: string;
	description: string;
	emptyText: string;
}

const { path } = Info;

const referenceImageSize = 256;
const supportedReferenceExtensions = new Set([".png", ".jpg", ".jpeg", ".webp"]);
const referenceSlots: PixelReferenceSlot[] = [
	{
		role: "identity",
		field: "identityReferenceImage",
		suffix: "portrait",
		title: "Character Portrait 256×256",
		description: "Character identity reference. Clothes, skin tone, hair color and face details come from this image.",
		emptyText: "No character portrait selected.",
	},
	{
		role: "motion",
		field: "motionReferenceImage",
		suffix: "motion",
		title: "Motion Reference Sheet 256×256",
		description: "Pose, layout and facing-direction reference. Use a single 256×256 packed sprite sheet.",
		emptyText: "No motion reference sheet selected.",
	},
];
const visibleReferenceSlots = referenceSlots.filter((slot) => slot.role === "identity");

const removePixelJsonSuffix = (fileName: string) => {
	const suffix = ".pixel.json";
	return fileName.toLowerCase().endsWith(suffix) ? fileName.slice(0, -suffix.length) : path.basename(fileName, path.extname(fileName));
};

const normalizeReferenceExtension = (fileName: string) => {
	const extension = path.extname(fileName).toLowerCase();
	return extension === ".jpeg" ? ".jpg" : extension;
};

const toWebPath = (filePath: string) => filePath.split("\\").join("/");

const createImageElement = (source: string) => {
	return new Promise<HTMLImageElement>((resolve, reject) => {
		const image = new Image();
		image.onload = () => resolve(image);
		image.onerror = () => reject(new Error("Failed to decode reference image."));
		image.src = source;
	});
};

const canvasToBlob = (canvas: HTMLCanvasElement) => {
	return new Promise<Blob>((resolve, reject) => {
		canvas.toBlob((blob) => {
			if (blob === null) {
				reject(new Error("Failed to encode 256×256 reference PNG."));
				return;
			}
			resolve(blob);
		}, "image/png");
	});
};

const normalizeReferenceImageBlob = async (file: File, role: PixelReferenceRole) => {
	const objectUrl = URL.createObjectURL(file);
	try {
		const image = await createImageElement(objectUrl);
		const canvas = document.createElement("canvas");
		canvas.width = referenceImageSize;
		canvas.height = referenceImageSize;
		const context = canvas.getContext("2d");
		if (context === null) {
			throw new Error("Failed to create 256×256 reference canvas.");
		}
		context.imageSmoothingEnabled = role === "identity";
		context.clearRect(0, 0, canvas.width, canvas.height);
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

const uploadReferenceImage = async (directory: string, fileName: string, blob: Blob) => {
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

const getReferencePreviewUrl = (resourceBasePath: string, filePath: string, referenceName: string | undefined, previewRevision: number) => {
	if (referenceName === undefined || resourceBasePath === "") return undefined;
	const referenceFilePath = path.join(path.dirname(filePath), referenceName);
	return Service.addr(`/${toWebPath(path.relative(resourceBasePath, referenceFilePath))}?t=${previewRevision}`);
};

export default function PixelReferencePanel(props: PixelReferencePanelProps) {
	const { document, filePath, resourceBasePath, readOnly, onDocumentChange, addAlert } = props;
	const inputRef = useRef<HTMLInputElement | null>(null);
	const [uploadingRole, setUploadingRole] = useState<PixelReferenceRole | undefined>(undefined);
	const [pendingSlot, setPendingSlot] = useState<PixelReferenceSlot | undefined>(undefined);
	const [previewRevision, setPreviewRevision] = useState(0);
	const previewUrls = useMemo(() => {
		return referenceSlots.reduce<Record<PixelReferenceField, string | undefined>>((urls, slot) => {
			urls[slot.field] = getReferencePreviewUrl(resourceBasePath, filePath, document[slot.field], previewRevision);
			return urls;
		}, {
			identityReferenceImage: undefined,
			motionReferenceImage: undefined,
		});
	}, [document, filePath, previewRevision, resourceBasePath]);

	const handleUpload = (event: ChangeEvent<HTMLInputElement>) => {
		const file = event.target.files?.[0];
		event.target.value = "";
		const slot = pendingSlot;
		setPendingSlot(undefined);
		if (file === undefined || slot === undefined) return;
		const extension = normalizeReferenceExtension(file.name);
		if (!supportedReferenceExtensions.has(extension)) {
			addAlert?.("Reference image must be PNG, JPG, or WebP.", "warning", true);
			return;
		}
		const directory = path.dirname(filePath);
		const baseName = removePixelJsonSuffix(path.basename(filePath));
		const referenceName = `${baseName}.${slot.suffix}.png`;
		setUploadingRole(slot.role);
		normalizeReferenceImageBlob(file, slot.role).then((blob) => uploadReferenceImage(directory, referenceName, blob)).then(() => {
			const nextDocument = clonePixelDocument(document);
			nextDocument[slot.field] = referenceName;
			onDocumentChange(nextDocument);
			Service.emitUpdateFile(path.join(directory, referenceName), true);
			setPreviewRevision((revision) => revision + 1);
			addAlert?.(`${slot.title} saved as ${referenceName}`, "success", true);
		}).catch((error: unknown) => {
			const message = error instanceof Error ? error.message : `Failed to upload ${slot.title}`;
			addAlert?.(message, "error", true);
		}).finally(() => {
			setUploadingRole(undefined);
		});
	};

	return <Stack spacing={1.25} className="pixel-panel pixel-reference-panel">
		<Typography variant="subtitle2" className="pixel-panel-title">Generation References</Typography>
		<Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.62)', lineHeight: 1.45 }}>
			Upload a 256×256 character portrait. Motion templates are provided internally so character identity is not polluted by external sprite sheets.
		</Typography>
		<input
			ref={inputRef}
			type="file"
			accept="image/png,image/jpeg,image/webp"
			hidden
			onChange={handleUpload}
		/>
		{visibleReferenceSlots.map((slot) => {
			const referenceName = document[slot.field];
			const previewUrl = previewUrls[slot.field];
			const uploading = uploadingRole === slot.role;
			return <Stack key={slot.role} spacing={1} className="pixel-reference-slot">
				<Stack direction="row" justifyContent="space-between" alignItems="center" gap={1}>
					<Typography variant="caption" className="pixel-reference-slot-title">{slot.title}</Typography>
					{referenceName === undefined ? null : <Button
						size="small"
						color="inherit"
						disabled={readOnly || uploadingRole !== undefined}
						startIcon={<DeleteOutlineIcon fontSize="small" />}
						onClick={() => {
							const nextDocument = clonePixelDocument(document);
							delete nextDocument[slot.field];
							onDocumentChange(nextDocument);
						}}
					>
						Clear
					</Button>}
				</Stack>
				<Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.54)', lineHeight: 1.35 }}>
					{slot.description}
				</Typography>
				<Button
					variant="outlined"
					startIcon={<AddPhotoAlternateIcon />}
					disabled={readOnly || uploadingRole !== undefined}
					onClick={() => {
						setPendingSlot(slot);
						inputRef.current?.click();
					}}
				>
					{uploading ? "Normalizing 256×256..." : "Upload 256×256 Reference"}
				</Button>
				{referenceName === undefined ? <Box className="pixel-reference-empty">
					<Typography variant="caption">{slot.emptyText}</Typography>
				</Box> : <Stack spacing={1}>
					<Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.72)', wordBreak: 'break-all' }}>
						{referenceName}
					</Typography>
					<Box className="pixel-reference-preview">
						{previewUrl === undefined ? null : <img src={previewUrl} alt={slot.title} />}
					</Box>
				</Stack>}
			</Stack>;
		})}
	</Stack>;
}
