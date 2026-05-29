/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { useMemo, useState } from 'react';
import { Box, Button, Chip, FormControl, InputLabel, LinearProgress, MenuItem, Select, Stack, TextField, Typography } from '@mui/material';
import AutoAwesomeIcon from '@mui/icons-material/AutoAwesome';
import type { SelectChangeEvent } from '@mui/material/Select';
import type { AlertColor } from '@mui/material';
import Info from '../Info';
import * as Service from '../Service';
import type { PixelDocument } from './PixelDocument';
import { clonePixelDocument } from './PixelDocument';
import {
	buildPixelGenerationPlan,
	generateDraftAnimation,
	generateGoogleVertexSpriteSheetAnimation,
	getPixelGenerationProvider,
	isPixelGenerationProviderId,
	pixelGenerationProviders,
	type PixelGenerationOutputMode,
	type PixelGenerationProviderId,
} from './PixelGeneration';

interface PixelGeneratePanelProps {
	document: PixelDocument;
	filePath: string;
	resourceBasePath: string;
	readOnly: boolean;
	onDocumentChange: (document: PixelDocument) => void;
	onStatusChange?: (status: string) => void;
	addAlert?: (message: string, severity: AlertColor, raw?: boolean) => void;
}

const { path } = Info;

const outputModeLabels: Record<PixelGenerationOutputMode, string> = {
	replace: "Replace timeline",
	append: "Append frames",
};

const getProviderEndpointStorageKey = (providerId: PixelGenerationProviderId) => `dora.pixel.providerEndpoint.${providerId}`;
const internalIdleTemplatePath = "/pixel-templates/idle_front_4_mannequin.png";
const internalIdleTemplateLabel = "Idle Front 4 internal template";
const maximumIdentityReferenceSize = 512;

interface GenerationReferenceImages {
	identityReferenceImage?: string;
	motionReferenceImage?: string;
}

const toWebPath = (filePath: string) => filePath.split("\\").join("/");

const blobToDataUrl = (blob: Blob) => {
	return new Promise<string>((resolve, reject) => {
		const reader = new FileReader();
		reader.onload = () => {
			if (typeof reader.result === "string") {
				resolve(reader.result);
			} else {
				reject(new Error("failed to read reference image"));
			}
		};
		reader.onerror = () => reject(new Error("failed to read reference image"));
		reader.readAsDataURL(blob);
	});
};

const createImageElement = (source: string) => {
	return new Promise<HTMLImageElement>((resolve, reject) => {
		const image = new Image();
		image.onload = () => resolve(image);
		image.onerror = () => reject(new Error("failed to decode reference image"));
		image.src = source;
	});
};

const resizeReferenceDataUrl = async (source: string, maximumSize: number) => {
	const image = await createImageElement(source);
	const maxDimension = Math.max(image.naturalWidth, image.naturalHeight);
	if (maxDimension <= maximumSize) return source;
	const scale = maximumSize / maxDimension;
	const width = Math.max(1, Math.round(image.naturalWidth * scale));
	const height = Math.max(1, Math.round(image.naturalHeight * scale));
	const canvas = window.document.createElement("canvas");
	canvas.width = width;
	canvas.height = height;
	const context = canvas.getContext("2d");
	if (context === null) {
		throw new Error("failed to create reference image resize context");
	}
	context.imageSmoothingEnabled = true;
	context.imageSmoothingQuality = "high";
	context.drawImage(image, 0, 0, width, height);
	return canvas.toDataURL("image/png");
};

const loadReferenceDataUrl = async (referenceImage: string, filePath: string, resourceBasePath: string) => {
	const referenceFilePath = path.join(path.dirname(filePath), referenceImage);
	const referenceUrl = Service.addr(`/${toWebPath(path.relative(resourceBasePath, referenceFilePath))}`);
	const response = await fetch(referenceUrl);
	if (!response.ok) {
		throw new Error(`failed to load reference image: ${response.status}`);
	}
	return blobToDataUrl(await response.blob());
};

const loadInternalReferenceDataUrl = async (templatePath: string) => {
	const response = await fetch(Service.addr(templatePath));
	if (!response.ok) {
		throw new Error(`failed to load internal motion template: ${response.status}`);
	}
	return blobToDataUrl(await response.blob());
};

const loadReferenceImages = async (document: PixelDocument, filePath: string, resourceBasePath: string) => {
	const references: GenerationReferenceImages = {};
	if (document.identityReferenceImage !== undefined) {
		references.identityReferenceImage = await loadReferenceDataUrl(document.identityReferenceImage, filePath, resourceBasePath);
	}
	if (document.motionReferenceImage !== undefined) {
		references.motionReferenceImage = await loadReferenceDataUrl(document.motionReferenceImage, filePath, resourceBasePath);
	} else {
		references.motionReferenceImage = await loadInternalReferenceDataUrl(internalIdleTemplatePath);
	}
	return references;
};

const getDefaultProviderEndpoint = (providerId: PixelGenerationProviderId) => {
	const savedEndpoint = window.localStorage.getItem(getProviderEndpointStorageKey(providerId));
	return savedEndpoint ?? getPixelGenerationProvider(providerId).defaultEndpoint ?? "";
};

const isGoogleImageProvider = (providerId: PixelGenerationProviderId) => {
	return providerId === "google_gemini_3_pro_image" || providerId === "google_vertex";
};

export default function PixelGeneratePanel(props: PixelGeneratePanelProps) {
	const { document, filePath, resourceBasePath, readOnly, onDocumentChange, onStatusChange, addAlert } = props;
	const [generating, setGenerating] = useState(false);
	const [outputMode, setOutputMode] = useState<PixelGenerationOutputMode>("replace");
	const [providerId, setProviderId] = useState<PixelGenerationProviderId>("google_gemini_3_pro_image");
	const [providerEndpoint, setProviderEndpoint] = useState(() => getDefaultProviderEndpoint("google_gemini_3_pro_image"));
	const plan = useMemo(() => buildPixelGenerationPlan(document, providerId), [document, providerId]);
	const selectedProvider = getPixelGenerationProvider(providerId);
	const googleImageReferencesReady = plan.identityReferenceImage !== undefined;

	const handleOutputModeChange = (event: SelectChangeEvent<string>) => {
		const value = event.target.value;
		if (value === "replace" || value === "append") {
			setOutputMode(value);
		}
	};

	const handleProviderChange = (event: SelectChangeEvent<string>) => {
		const value = event.target.value;
		if (isPixelGenerationProviderId(value)) {
			setProviderId(value);
			setProviderEndpoint(getDefaultProviderEndpoint(value));
		}
	};

	const applyGeneratedFrames = (result: Awaited<ReturnType<typeof generateDraftAnimation>>) => {
		const nextDocument = clonePixelDocument(document);
		if (result.width !== undefined && result.height !== undefined) {
			nextDocument.width = result.width;
			nextDocument.height = result.height;
		}
		nextDocument.palette = result.palette;
		nextDocument.fps = plan.fps;
		if (outputMode === "replace") {
			nextDocument.frames = result.frames;
			nextDocument.selectedFrame = 0;
		} else {
			const firstGeneratedFrame = nextDocument.frames.length;
			nextDocument.frames = [...nextDocument.frames, ...result.frames];
			nextDocument.selectedFrame = firstGeneratedFrame;
		}
		onDocumentChange(nextDocument);
		const status = `${outputModeLabels[outputMode]} with ${result.frames.length} generated frame(s).`;
		onStatusChange?.(status);
		addAlert?.(status, "success", true);
	};

	const runGeneration = () => {
		setGenerating(true);
		onStatusChange?.(`Generating ${plan.steps.length} ${plan.templateName} frame(s)...`);
		const generationTask = isGoogleImageProvider(providerId) ?
			loadReferenceImages(document, filePath, resourceBasePath).then((referenceImages) => {
				if (providerEndpoint.trim() === "") {
					throw new Error(`${selectedProvider.name} endpoint is empty`);
				}
				if (referenceImages.identityReferenceImage === undefined) {
					throw new Error("Character portrait reference is required");
				}
				return resizeReferenceDataUrl(referenceImages.identityReferenceImage, maximumIdentityReferenceSize).then((identityReferenceImage) => {
					return generateGoogleVertexSpriteSheetAnimation(document, plan, {
						endpoint: providerEndpoint.trim(),
						identityReferenceImage,
						motionReferenceImage: referenceImages.motionReferenceImage,
						onProgress: (message, frameIndex, frameCount) => {
							onStatusChange?.(`${message} (${frameIndex + 1}/${frameCount})`);
						},
					});
				});
			}) :
			generateDraftAnimation(document, plan);
		generationTask.then((result) => {
			applyGeneratedFrames(result);
		}).catch((error: unknown) => {
			const message = error instanceof Error ? error.message : "Failed to generate animation";
			onStatusChange?.(message);
			addAlert?.(message, "error", true);
		}).finally(() => {
			setGenerating(false);
		});
	};

	return <Stack spacing={1.25} className="pixel-panel pixel-generation-panel">
		<Stack direction="row" justifyContent="space-between" alignItems="center" gap={1}>
			<Typography variant="subtitle2" className="pixel-panel-title">Generate Animation</Typography>
			<Chip size="small" label={plan.providerName} />
		</Stack>
		<Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.62)', lineHeight: 1.45 }}>
			Gemini generates a reference-guided sprite sheet. The editor then detects generated pose regions and extracts them into timeline frames.
		</Typography>
		<FormControl size="small" fullWidth disabled={readOnly || generating}>
			<InputLabel id="pixel-generate-provider-label">Provider</InputLabel>
			<Select
				labelId="pixel-generate-provider-label"
				label="Provider"
				value={providerId}
				onChange={handleProviderChange}
			>
				{pixelGenerationProviders.map((provider) => (
					<MenuItem key={provider.id} value={provider.id}>{provider.name}</MenuItem>
				))}
			</Select>
		</FormControl>
		{isGoogleImageProvider(providerId) ? <TextField
			size="small"
			label={`${selectedProvider.name} endpoint`}
			placeholder={selectedProvider.endpointPlaceholder}
			value={providerEndpoint}
			disabled={readOnly || generating}
			onChange={(event) => {
				setProviderEndpoint(event.target.value);
				window.localStorage.setItem(getProviderEndpointStorageKey(providerId), event.target.value);
			}}
			fullWidth
		/> : null}
		<Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.5)', lineHeight: 1.35 }}>
			{selectedProvider.description}
		</Typography>
		<Stack direction="row" flexWrap="wrap" gap={0.75} useFlexGap>
			<Chip size="small" label={`${plan.steps.length} frames`} />
			<Chip size="small" label={`${plan.fps} fps`} />
			<Chip size="small" label={`${plan.width}×${plan.height}`} />
			<Chip size="small" color={plan.identityReferenceImage === undefined ? "default" : "success"} label={plan.identityReferenceImage === undefined ? "no portrait" : "portrait ready"} />
			<Chip size="small" color="success" label={internalIdleTemplateLabel} />
		</Stack>
		<FormControl size="small" fullWidth disabled={readOnly || generating}>
			<InputLabel id="pixel-generate-output-label">Output</InputLabel>
			<Select
				labelId="pixel-generate-output-label"
				label="Output"
				value={outputMode}
				onChange={handleOutputModeChange}
			>
				<MenuItem value="replace">{outputModeLabels.replace}</MenuItem>
				<MenuItem value="append">{outputModeLabels.append}</MenuItem>
			</Select>
		</FormControl>
		<Box className="pixel-generation-plan">
			{plan.steps.slice(0, 4).map((step) => (
				<Typography key={step.name} variant="caption" className="pixel-generation-step">
					{step.index + 1}. {step.name}
				</Typography>
			))}
			{plan.steps.length > 4 ? <Typography variant="caption" className="pixel-generation-step">
				+ {plan.steps.length - 4} more frame(s)
			</Typography> : null}
		</Box>
		{generating ? <LinearProgress /> : null}
		<Button
			variant="contained"
			startIcon={<AutoAwesomeIcon />}
			disabled={readOnly || generating || (isGoogleImageProvider(providerId) && !googleImageReferencesReady)}
			onClick={runGeneration}
		>
			{generating ? "Generating..." : isGoogleImageProvider(providerId) ? "Generate Sprite Sheet" : `Generate ${plan.steps.length} Frames`}
		</Button>
		{isGoogleImageProvider(providerId) && !googleImageReferencesReady ? <Typography variant="caption" sx={{ color: 'rgba(255,213,74,0.76)', lineHeight: 1.35 }}>
			Upload the character portrait before generating. The idle motion template is built in.
		</Typography> : null}
	</Stack>;
}
