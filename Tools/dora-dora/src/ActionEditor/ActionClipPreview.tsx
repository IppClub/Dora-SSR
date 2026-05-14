import React, { memo, useEffect, useMemo, useRef, useState } from "react";
import { Alert, Box, Typography } from "@mui/material";
import { useTranslation } from "react-i18next";
import * as Service from "../Service";
import { parseLegacyClip, type ActionClipDocument } from "./ActionClip";
import { toServedResourceUrl } from "./ActionResource";

type ActionClipPreviewProps = {
	filePath: string;
	resourceBasePath: string;
	sourceContent: string;
	refreshKey?: number;
	width: number;
	height: number;
	addAlert: (msg: string, type: "success" | "info" | "warning" | "error", openLog?: boolean) => void;
};

type AtlasImage = {
	image: HTMLImageElement;
	width: number;
	height: number;
	objectUrl: string;
};

type ClipHitArea = {
	name: string;
	x: number;
	y: number;
	width: number;
	height: number;
};

const previewSize = 94;
const cellWidth = 168;
const cellHeight = 166;
const padding = 20;
const titleHeight = 64;

const loadImageElement = (objectUrl: string): Promise<HTMLImageElement> => {
	return new Promise((resolve, reject) => {
		const image = new window.Image();
		image.onload = () => resolve(image);
		image.onerror = () => reject(new Error("failed"));
		image.src = objectUrl;
	});
};

const appendCacheKey = (url: string, key?: number) => {
	if (key === undefined) return url;
	return `${url}${url.includes("?") ? "&" : "?"}v=${key}`;
};

const loadAtlasImage = async (filePath: string, resourceBasePath: string, refreshKey?: number): Promise<AtlasImage> => {
	const response = await fetch(appendCacheKey(Service.addr(toServedResourceUrl(filePath, resourceBasePath)), refreshKey));
	if (!response.ok) throw new Error(`Failed to load atlas image: ${filePath}`);
	const objectUrl = URL.createObjectURL(await response.blob());
	try {
		const image = await loadImageElement(objectUrl);
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

const fitRect = (width: number, height: number, maxSize: number) => {
	if (width <= 0 || height <= 0) return { width: 0, height: 0 };
	const scale = Math.min(maxSize / width, maxSize / height, 1);
	return {
		width: Math.max(1, Math.round(width * scale)),
		height: Math.max(1, Math.round(height * scale)),
	};
};

const drawRoundedRect = (
	context: CanvasRenderingContext2D,
	x: number,
	y: number,
	width: number,
	height: number,
	radius: number,
) => {
	context.beginPath();
	context.moveTo(x + radius, y);
	context.lineTo(x + width - radius, y);
	context.quadraticCurveTo(x + width, y, x + width, y + radius);
	context.lineTo(x + width, y + height - radius);
	context.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
	context.lineTo(x + radius, y + height);
	context.quadraticCurveTo(x, y + height, x, y + height - radius);
	context.lineTo(x, y + radius);
	context.quadraticCurveTo(x, y, x + radius, y);
	context.closePath();
};

const ellipsizeText = (context: CanvasRenderingContext2D, text: string, maxWidth: number) => {
	if (context.measureText(text).width <= maxWidth) return text;
	const ellipsis = "...";
	const ellipsisWidth = context.measureText(ellipsis).width;
	let low = 0;
	let high = text.length;
	while (low < high) {
		const mid = Math.ceil((low + high) / 2);
		if (context.measureText(text.slice(0, mid)).width + ellipsisWidth <= maxWidth) {
			low = mid;
		} else {
			high = mid - 1;
		}
	}
	return `${text.slice(0, Math.max(0, low))}${ellipsis}`;
};

const drawClipPreview = (
	canvas: HTMLCanvasElement,
	clip: ActionClipDocument,
	atlas: AtlasImage | null,
	width: number,
	t: (key: string, options?: Record<string, unknown>) => string,
) => {
	const entries = Object.values(clip.rects).sort((a, b) => a.name.localeCompare(b.name));
	const hitAreas: ClipHitArea[] = [];
	const logicalWidth = Math.max(320, Math.floor(width));
	const columns = Math.max(1, Math.floor((logicalWidth - padding * 2) / cellWidth));
	const rows = Math.max(1, Math.ceil(entries.length / columns));
	const logicalHeight = Math.max(180, padding + titleHeight + rows * cellHeight + padding);
	const cardWidth = cellWidth - 14;
	const cardHeight = cellHeight - 16;
	const ratio = window.devicePixelRatio || 1;
	canvas.width = Math.floor(logicalWidth * ratio);
	canvas.height = Math.floor(logicalHeight * ratio);
	canvas.style.width = `${logicalWidth}px`;
	canvas.style.height = `${logicalHeight}px`;
	const context = canvas.getContext("2d");
	if (!context) return;
	context.setTransform(ratio, 0, 0, ratio, 0, 0);
	context.clearRect(0, 0, logicalWidth, logicalHeight);
	context.fillStyle = "#1f1f1f";
	context.fillRect(0, 0, logicalWidth, logicalHeight);
	context.fillStyle = "#ffffff";
	context.font = "600 15px system-ui, -apple-system, BlinkMacSystemFont, sans-serif";
	context.fillText(t("actionEditor.clipValue", { clip: clip.clipPath ?? "" }), padding, 28);
	context.fillStyle = "#a7a7a7";
	context.font = "12px system-ui, -apple-system, BlinkMacSystemFont, sans-serif";
	context.fillText(
		t("actionEditor.clipPreviewInfo", {
			texture: clip.textureFile || t("actionEditor.none"),
			count: entries.length,
			width: atlas?.width ?? 0,
			height: atlas?.height ?? 0,
		}),
		padding,
		48,
	);

	for (let i = 0; i < entries.length; i++) {
		const rect = entries[i];
		const column = i % columns;
		const row = Math.floor(i / columns);
		const x = padding + column * cellWidth;
		const y = padding + titleHeight + row * cellHeight;
		context.fillStyle = "#2b2b2b";
		drawRoundedRect(context, x, y, cardWidth, cardHeight, 6);
		context.fill();
		context.strokeStyle = "#3a3a3a";
		context.stroke();

		const previewX = x + Math.floor((cardWidth - previewSize) / 2);
		const previewY = y + 14;
		hitAreas.push({ name: rect.name, x: previewX, y: previewY, width: previewSize, height: previewSize });
		context.fillStyle = "#202020";
		context.fillRect(previewX, previewY, previewSize, previewSize);
		context.strokeStyle = "#464646";
		context.strokeRect(previewX + 0.5, previewY + 0.5, previewSize - 1, previewSize - 1);

		if (atlas && rect.width > 0 && rect.height > 0) {
			const fitted = fitRect(rect.width, rect.height, previewSize - 12);
			const imageX = previewX + (previewSize - fitted.width) / 2;
			const imageY = previewY + (previewSize - fitted.height) / 2;
			context.drawImage(
				atlas.image,
				rect.x,
				rect.y,
				rect.width,
				rect.height,
				imageX,
				imageY,
				fitted.width,
				fitted.height,
			);
		}

		context.fillStyle = "#f0f0f0";
		context.font = "13px system-ui, -apple-system, BlinkMacSystemFont, \"Segoe UI\", sans-serif";
		const label = ellipsizeText(context, rect.name || t("actionEditor.none"), cardWidth - 24);
		context.fillText(label, x + 12, y + 128);
		context.fillStyle = "#9f9f9f";
		context.font = "12px system-ui, -apple-system, BlinkMacSystemFont, \"Segoe UI\", sans-serif";
		const sizeLabel = ellipsizeText(context, `${rect.width}x${rect.height}`, cardWidth - 24);
		context.fillText(sizeLabel, x + 12, y + 146);
	}
	return hitAreas;
};

export default memo(function ActionClipPreview(props: ActionClipPreviewProps) {
	const { t } = useTranslation();
	const { filePath, resourceBasePath, sourceContent, refreshKey, width, height, addAlert } = props;
	const canvasRef = useRef<HTMLCanvasElement | null>(null);
	const hitAreasRef = useRef<ClipHitArea[]>([]);
	const parsed = useMemo(() => {
		try {
			return { clip: parseLegacyClip(sourceContent, filePath), error: null as string | null };
		} catch (error) {
			return {
				clip: null,
				error: error instanceof Error ? error.message : t("actionEditor.failedParseClipFile", { path: filePath }),
			};
		}
	}, [filePath, sourceContent, t]);
	const [atlas, setAtlas] = useState<AtlasImage | null>(null);
	const [loadError, setLoadError] = useState<string | null>(null);

	useEffect(() => {
		if (!parsed.clip?.texturePath) {
			setAtlas(null);
			setLoadError(null);
			return;
		}
		let cancelled = false;
		let objectUrl: string | null = null;
		setAtlas(null);
		setLoadError(null);
		loadAtlasImage(parsed.clip.texturePath, resourceBasePath, refreshKey).then((loaded) => {
			objectUrl = loaded.objectUrl;
			if (cancelled) {
				URL.revokeObjectURL(loaded.objectUrl);
				return;
			}
			setAtlas(loaded);
		}).catch((error) => {
			if (!cancelled) {
				setAtlas(null);
				setLoadError(error instanceof Error ? error.message : t("actionEditor.failedLoadAtlasImage", { path: parsed.clip?.texturePath ?? "" }));
			}
		});
		return () => {
			cancelled = true;
			if (objectUrl) URL.revokeObjectURL(objectUrl);
		};
	}, [parsed.clip, resourceBasePath, refreshKey, t]);

	useEffect(() => {
		const canvas = canvasRef.current;
		if (!canvas || !parsed.clip) return;
		hitAreasRef.current = drawClipPreview(canvas, parsed.clip, atlas, width, t) ?? [];
	}, [atlas, parsed.clip, t, width]);

	const findHitArea = (event: React.MouseEvent<HTMLCanvasElement>) => {
		const canvas = canvasRef.current;
		if (!canvas) return null;
		const bounds = canvas.getBoundingClientRect();
		const x = event.clientX - bounds.left;
		const y = event.clientY - bounds.top;
		return hitAreasRef.current.find((area) =>
			x >= area.x && x <= area.x + area.width && y >= area.y && y <= area.y + area.height
		) ?? null;
	};

	const copyWithFallback = async (text: string) => {
		try {
			if (navigator.clipboard?.writeText) {
				await navigator.clipboard.writeText(text);
				return true;
			}
		} catch {
			// Fall through to the selection-based fallback for non-secure origins.
		}
		const textarea = document.createElement("textarea");
		textarea.value = text;
		textarea.setAttribute("readonly", "true");
		textarea.style.position = "fixed";
		textarea.style.left = "-1000px";
		textarea.style.top = "-1000px";
		document.body.appendChild(textarea);
		textarea.focus();
		textarea.select();
		let copied = false;
		try {
			copied = document.execCommand("copy");
		} catch {
			copied = false;
		}
		document.body.removeChild(textarea);
		if (copied) return true;
		window.prompt(t("actionEditor.copyClipManually"), text);
		return false;
	};

	const handleCanvasClick = (event: React.MouseEvent<HTMLCanvasElement>) => {
		const hit = findHitArea(event);
		if (!hit) return;
		const clipRef = `${filePath.split(/[\\/]/).pop() ?? filePath}|${hit.name}`;
		copyWithFallback(clipRef).then((copied) => {
			addAlert(
				copied
					? t("actionEditor.copiedClip", { clip: clipRef })
					: t("actionEditor.copyClipFallback", { clip: clipRef }),
				copied ? "success" : "info",
			);
		});
	};

	const handleCanvasMouseMove = (event: React.MouseEvent<HTMLCanvasElement>) => {
		const canvas = canvasRef.current;
		if (!canvas) return;
		canvas.style.cursor = findHitArea(event) ? "pointer" : "default";
	};

	if (parsed.error) {
		return <Box sx={{ height, bgcolor: "#1f1f1f", p: 2 }}>
			<Alert severity="error">{parsed.error}</Alert>
		</Box>;
	}

	return <Box sx={{ minHeight: height, bgcolor: "#1f1f1f" }}>
		{loadError ? <Alert severity="warning" sx={{ borderRadius: 0 }}>{loadError}</Alert> : null}
		{parsed.clip && !parsed.clip.textureFile ? <Alert severity="info" sx={{ borderRadius: 0 }}>{t("actionEditor.noClipAtlasLoaded")}</Alert> : null}
		{parsed.clip && Object.keys(parsed.clip.rects).length === 0 ? <Typography sx={{ color: "#a7a7a7", p: 2 }}>{t("actionEditor.noClipsFound")}</Typography> : null}
		<canvas ref={canvasRef} onClick={handleCanvasClick} onMouseMove={handleCanvasMouseMove} />
	</Box>;
});
