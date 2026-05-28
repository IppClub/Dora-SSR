/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { useMemo, useState } from 'react';
import { Box, Button, Chip, LinearProgress, MenuItem, Stack, TextField, Typography } from '@mui/material';
import type { AlertColor } from '@mui/material';
import AutoAwesomeIcon from '@mui/icons-material/AutoAwesome';
import Info from '../Info';
import * as Service from '../Service';
import type { ImageSpriteDocument } from './SpriteDocument';
import { cloneImageSpriteDocument } from './SpriteDocument';
import { generateImageSpriteSheet } from './SpriteGeneration';
import { getSpriteMotionTemplateForAction, spriteMotionTemplates } from './SpriteMotionTemplate';
import { alignImageSpriteSheet, evaluateImageSpriteQuality, formatImageSpriteQualityReport } from './SpriteQuality';

interface SpriteGeneratePanelProps {
	document: ImageSpriteDocument;
	filePath: string;
	resourceBasePath: string;
	readOnly: boolean;
	onDocumentChange: (document: ImageSpriteDocument) => void;
	onStatusChange?: (status: string) => void;
	addAlert?: (message: string, severity: AlertColor, raw?: boolean) => void;
}

const { path } = Info;
const endpointStorageKey = "dora.sprite.gemini3ProImageEndpoint";
const defaultEndpoint = "";
const endpointPlaceholder = "http://127.0.0.1:8877/api/google-gemini/generate-sprite";
const generatedFrameSize = 128;

const toWebPath = (filePath: string) => filePath.split("\\").join("/");

const removeSpriteJsonSuffix = (fileName: string) => {
	const suffix = ".sprite.json";
	return fileName.toLowerCase().endsWith(suffix) ? fileName.slice(0, -suffix.length) : path.basename(fileName, path.extname(fileName));
};

const blobToDataUrl = (blob: Blob) => {
	return new Promise<string>((resolve, reject) => {
		const reader = new FileReader();
		reader.onload = () => {
			if (typeof reader.result === "string") {
				resolve(reader.result);
			} else {
				reject(new Error("failed to read image"));
			}
		};
		reader.onerror = () => reject(new Error("failed to read image"));
		reader.readAsDataURL(blob);
	});
};

const loadProjectImageDataUrl = async (imageName: string, filePath: string, resourceBasePath: string) => {
	const imagePath = path.join(path.dirname(filePath), imageName);
	const imageUrl = Service.addr(`/${toWebPath(path.relative(resourceBasePath, imagePath))}`);
	const response = await fetch(imageUrl);
	if (!response.ok) {
		throw new Error(`failed to load image ${imageName}: ${response.status}`);
	}
	return blobToDataUrl(await response.blob());
};

const loadInternalImageDataUrl = async (templatePath: string) => {
	const response = await fetch(Service.addr(templatePath));
	if (!response.ok) {
		throw new Error(`failed to load internal motion template: ${response.status}`);
	}
	return blobToDataUrl(await response.blob());
};

const uploadGeneratedSheet = async (directory: string, fileName: string, blob: Blob) => {
	const formData = new FormData();
	formData.append('file', blob, fileName);
	const response = await fetch(Service.addr(`/upload?path=${encodeURIComponent(directory)}`), {
		method: 'POST',
		body: formData,
	});
	if (!response.ok) {
		throw new Error(`failed to upload generated sheet: ${response.status}`);
	}
};

export default function SpriteGeneratePanel(props: SpriteGeneratePanelProps) {
	const { document, filePath, resourceBasePath, readOnly, onDocumentChange, onStatusChange, addAlert } = props;
	const [endpoint, setEndpoint] = useState(() => window.localStorage.getItem(endpointStorageKey) ?? defaultEndpoint);
	const [generating, setGenerating] = useState(false);
	const activeAction = document.actions[document.selectedAction] ?? document.actions[0];
	const activeTemplate = useMemo(() => {
		return getSpriteMotionTemplateForAction(document.motionTemplate, activeAction?.direction);
	}, [activeAction?.direction, document.motionTemplate]);
	const generationReady = document.identityReferenceImage !== undefined && activeAction !== undefined;
	const expectedFrameCount = useMemo(() => Math.max(1, activeAction?.frames.length ?? activeTemplate.frameCount), [activeAction, activeTemplate.frameCount]);

	const runGeneration = () => {
		if (activeAction === undefined) return;
		if (document.identityReferenceImage === undefined) {
			addAlert?.("Upload a character portrait before generating.", "warning", true);
			return;
		}
		if (endpoint.trim() === "") {
			addAlert?.("Image generation endpoint is empty.", "warning", true);
			return;
		}
		setGenerating(true);
		onStatusChange?.("Loading generation references...");
		Promise.all([
			loadProjectImageDataUrl(document.identityReferenceImage, filePath, resourceBasePath),
			loadInternalImageDataUrl(activeTemplate.referenceImagePath),
		]).then(([identityReferenceImage, motionReferenceImage]) => {
			return generateImageSpriteSheet({
				endpoint: endpoint.trim(),
				identityReferenceImage,
				motionReferenceImage,
				expectedFrameCount,
				frameSize: generatedFrameSize,
				motionName: activeTemplate.name,
				facingPrompt: activeTemplate.prompt,
				frameNamePrefix: activeTemplate.id,
				frameDurationMs: activeAction.frames[0]?.duration,
				onProgress: (message, stepIndex, stepCount) => {
					onStatusChange?.(`${message} (${stepIndex + 1}/${stepCount})`);
				},
			});
		}).then(async (result) => {
			onStatusChange?.("Evaluating generated sprite quality...");
			let acceptedResult = result;
			let qualityReport = await evaluateImageSpriteQuality({
				imageDataUrl: acceptedResult.imageDataUrl,
				imageWidth: acceptedResult.imageWidth,
				imageHeight: acceptedResult.imageHeight,
				frames: acceptedResult.frames,
			});
			if (qualityReport.status === "fixable") {
				onStatusChange?.("Auto-aligning generated sprite frames...");
				const alignedResult = await alignImageSpriteSheet({
					imageDataUrl: acceptedResult.imageDataUrl,
					imageWidth: acceptedResult.imageWidth,
					imageHeight: acceptedResult.imageHeight,
					frames: acceptedResult.frames,
				}, qualityReport);
				const alignedQualityReport = await evaluateImageSpriteQuality(alignedResult);
				if (alignedQualityReport.status === "pass") {
					acceptedResult = {
						...acceptedResult,
						...alignedResult,
					};
					qualityReport = alignedQualityReport;
				} else {
					qualityReport = alignedQualityReport;
				}
			}
			if (qualityReport.status !== "pass") {
				throw new Error(`Generated sprite failed quality gate: ${formatImageSpriteQualityReport(qualityReport)}`);
			}
			return acceptedResult;
		}).then((result) => {
			const directory = path.dirname(filePath);
			const baseName = removeSpriteJsonSuffix(path.basename(filePath));
			const sheetName = `${baseName}.${activeTemplate.id}.png`;
			return uploadGeneratedSheet(directory, sheetName, result.imageBlob).then(() => ({ result, sheetName, directory }));
		}).then(({ result, sheetName, directory }) => {
			const nextDocument = cloneImageSpriteDocument(document);
			const nextAction = nextDocument.actions[nextDocument.selectedAction] ?? nextDocument.actions[0];
			if (nextAction === undefined) {
				throw new Error("sprite document does not contain an action");
			}
			nextAction.id = activeTemplate.id;
			nextAction.name = activeTemplate.name;
			nextAction.direction = activeTemplate.facing;
			nextAction.image = sheetName;
			nextAction.imageWidth = result.imageWidth;
			nextAction.imageHeight = result.imageHeight;
			nextAction.frames = result.frames;
			nextDocument.motionTemplate = activeTemplate.id;
			nextDocument.selectedFrame = 0;
			onDocumentChange(nextDocument);
			Service.emitUpdateFile(path.join(directory, sheetName), true);
			const message = `Generated ${result.frames.length} frame(s) into ${sheetName}`;
			onStatusChange?.(message);
			addAlert?.(message, "success", true);
		}).catch((error: unknown) => {
			const message = error instanceof Error ? error.message : "Failed to generate image sprite";
			onStatusChange?.(message);
			addAlert?.(message, "error", true);
		}).finally(() => {
			setGenerating(false);
		});
	};

	const handleTemplateChange = (templateId: string) => {
		const template = spriteMotionTemplates.find((item) => item.id === templateId);
		if (template === undefined || activeAction === undefined) return;
		const nextDocument = cloneImageSpriteDocument(document);
		const nextAction = nextDocument.actions[nextDocument.selectedAction] ?? nextDocument.actions[0];
		if (nextAction === undefined) return;
		nextDocument.motionTemplate = template.id;
		nextDocument.selectedFrame = 0;
		nextAction.id = template.id;
		nextAction.name = template.name;
		nextAction.direction = template.facing;
		nextAction.imageWidth = generatedFrameSize * Math.max(1, nextAction.frames.length);
		nextAction.imageHeight = generatedFrameSize;
		nextAction.frames = nextAction.frames.map((frame, index) => ({
			...frame,
			name: `${template.id}_${index + 1}`,
			rect: {
				x: index * generatedFrameSize,
				y: 0,
				width: generatedFrameSize,
				height: generatedFrameSize,
			},
		}));
		delete nextAction.image;
		onDocumentChange(nextDocument);
	};

	return <Stack spacing={1.25} className="image-sprite-panel">
		<Stack direction="row" justifyContent="space-between" alignItems="center" gap={1}>
			<Typography variant="subtitle2" className="image-sprite-panel-title">AI Sprite Sheet</Typography>
			<Chip size="small" label="Gemini 3 Pro Image" />
		</Stack>
		<Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.62)', lineHeight: 1.45 }}>
			Generates a PNG sprite sheet and frame metadata. No palette quantization and no pixel-grid conversion.
		</Typography>
		<TextField
			select
			size="small"
			label="Action / Facing"
			value={activeTemplate.id}
			disabled={readOnly || generating}
			onChange={(event) => handleTemplateChange(event.target.value)}
			fullWidth
		>
			{spriteMotionTemplates.map((template) => <MenuItem value={template.id} key={template.id}>{template.name}</MenuItem>)}
		</TextField>
		<TextField
			size="small"
			label="Endpoint"
			placeholder={endpointPlaceholder}
			value={endpoint}
			disabled={readOnly || generating}
			onChange={(event) => {
				setEndpoint(event.target.value);
				window.localStorage.setItem(endpointStorageKey, event.target.value);
			}}
			fullWidth
		/>
		<Stack direction="row" flexWrap="wrap" gap={0.75} useFlexGap>
			<Chip size="small" label={`${expectedFrameCount} frames`} />
			<Chip size="small" label={activeTemplate.facing} />
			<Chip size="small" label={`${generatedFrameSize}×${generatedFrameSize} frame rect`} />
			<Chip size="small" color={document.identityReferenceImage === undefined ? "default" : "success"} label={document.identityReferenceImage === undefined ? "no portrait" : "portrait ready"} />
			<Chip size="small" color="success" label="direction template" />
		</Stack>
		{generating ? <LinearProgress /> : null}
		<Button
			variant="contained"
			startIcon={<AutoAwesomeIcon />}
			disabled={readOnly || generating || !generationReady}
			onClick={runGeneration}
		>
			{generating ? "Generating..." : "Generate Image Sprite"}
		</Button>
		{generationReady ? null : <Box className="image-sprite-reference-empty">
			<Typography variant="caption">Upload a character portrait first.</Typography>
		</Box>}
	</Stack>;
}
