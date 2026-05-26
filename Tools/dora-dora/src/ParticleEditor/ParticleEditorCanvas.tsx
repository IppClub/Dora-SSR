import { Fragment, memo, useCallback, useEffect, useMemo, useRef, useState } from "react";
import type { CSSProperties, KeyboardEvent, PointerEvent } from "react";
import { useTranslation } from "react-i18next";
import { Box, Button, Checkbox, Dialog, DialogActions, DialogContent, DialogTitle, Divider, FormControlLabel, IconButton, Stack, TextField, Tooltip, Typography } from "@mui/material";
import PlayArrowIcon from "@mui/icons-material/PlayArrow";
import PauseIcon from "@mui/icons-material/Pause";
import ReplayIcon from "@mui/icons-material/Replay";
import UndoIcon from "@mui/icons-material/Undo";
import RedoIcon from "@mui/icons-material/Redo";
import { BodyIconName, drawBodyIcon } from "../BodyEditor/BodyIcons";
import ClipSliceDialog from "../ClipSliceDialog";
import * as Service from "../Service";
import { parseLegacyClip, type ActionClipRect } from "../ActionEditor/ActionClip";
import { ParticleDocument, ParticleFields, validateParticleDocument } from "./ParticleDocument";
import { ParticlePreviewRuntime, ParticleRuntimeSnapshot } from "./ParticlePreviewRuntime";
import { ParticleTextureSource, ParticleWebGLRenderer } from "./ParticleWebGLRenderer";
import { ParticleFieldPath, readParticleFieldPath } from "./ParticleEditorState";
import { ParticleTextureResourceEntry, findParticleTextureResourceFiles, isParticleTextureImageSource, particleResourceToServedUrl } from "./ParticleResource";
import { ParticlePresetId, particlePresets } from "./ParticlePresets";

export type ParticleEditorCanvasProps = {
	document: ParticleDocument;
	width: number;
	height: number;
	resourceBasePath: string;
	servedResourceBasePath: string;
	active: boolean;
	readOnly: boolean;
	texture?: ParticleTextureSource;
	textureLabel: string;
	textureWarning?: string;
	canUndo: boolean;
	canRedo: boolean;
	onUndo: () => void;
	onRedo: () => void;
	onUpdateField: (path: ParticleFieldPath, value: number | string | boolean, recordUndo?: boolean) => void;
	onUpdateColor: (basePath: ParticleColorPath, value: ColorRgba, recordUndo?: boolean) => void;
	onSelectTexture: (textureName: string, resetRect?: boolean) => void;
	onApplyPreset: (presetId: ParticlePresetId) => void;
	addAlert?: (msg: string, type: "success" | "info" | "warning" | "error", openLog?: boolean) => void;
};

const inputStyle = {
	width: "100%",
	boxSizing: "border-box" as const,
	background: "#181818",
	color: "#d7d7d7",
	border: "1px solid #3a3a3a",
	minHeight: 26,
	fontSize: 12,
};

const toolButtonSx = {
	width: 30,
	height: 30,
	border: "1px solid #343434",
	borderRadius: 0,
	background: "#303030",
	color: "#d7d7d7",
	"&:hover": { background: "#383838" },
	"&.Mui-disabled": {
		color: "rgba(215, 215, 215, 0.32)",
		borderColor: "#2b2b2b",
		background: "#252525",
	},
};

const selectStyle = {
	...inputStyle,
	height: 26,
};

const rowStyle = {
	display: "grid",
	gridTemplateColumns: "minmax(82px, 1fr) minmax(116px, 170px)",
	alignItems: "center",
	gap: 8,
};

const specialButtonStyle = {
	height: 26,
	minWidth: 30,
	border: "1px solid #3a3a3a",
	background: "#252525",
	color: "#d7d7d7",
	cursor: "pointer",
	padding: "0 6px",
	fontSize: 12,
};

const sectionTitleStyle = {
	fontSize: 11,
	textTransform: "uppercase" as const,
	color: "#8f9aa6",
	fontWeight: 700,
	letterSpacing: 0,
	margin: "10px 0 6px",
};

const blendOptions = [
	{ value: 0x1000, label: "Zero" },
	{ value: 0x2000, label: "One" },
	{ value: 0x3000, label: "SrcColor" },
	{ value: 0x4000, label: "InvSrcColor" },
	{ value: 0x5000, label: "SrcAlpha" },
	{ value: 0x6000, label: "InvSrcAlpha" },
	{ value: 0x7000, label: "DstAlpha" },
	{ value: 0x8000, label: "InvDstAlpha" },
	{ value: 0x9000, label: "DstColor" },
	{ value: 0xa000, label: "InvDstColor" },
];

const viewToolNames: readonly BodyIconName[] = ["origin", "zoom"];
const editorAssistColor = "#65d6ff";
const editorAssistSecondaryColor = "rgba(101, 214, 255, 0.65)";

const viewToolLabels: Record<BodyIconName, string> = {
	menu: "Menu",
	rect: "Rectangle",
	disk: "Disk",
	poly: "Polygon",
	chain: "Chain",
	joint: "Joint",
	delete: "Delete",
	play: "Play",
	stop: "Stop",
	origin: "Origin",
	zoom: "Zoom",
	fixX: "Fix X",
	fixY: "Fix Y",
};

const BodyIconGlyph = memo(function BodyIconGlyph(props: { name: BodyIconName; active?: boolean }) {
	const { name, active } = props;
	const ref = useRef<HTMLCanvasElement | null>(null);
	useEffect(() => {
		const canvas = ref.current;
		const context = canvas?.getContext("2d");
		if (!canvas || !context) return;
		const ratio = window.devicePixelRatio || 1;
		canvas.width = 24 * ratio;
		canvas.height = 24 * ratio;
		canvas.style.width = "24px";
		canvas.style.height = "24px";
		context.setTransform(ratio, 0, 0, ratio, 0, 0);
		context.clearRect(0, 0, 24, 24);
		drawBodyIcon(context, name, 0, 0, 24, active ? "#fac03d" : "#d7d7d7");
	}, [active, name]);
	return <canvas ref={ref} aria-hidden="true" />;
});

const ParticleNumberInput = (props: {
	value: number;
	readOnly?: boolean;
	min?: number;
	max?: number;
	step?: number;
	style?: CSSProperties;
	onPreview: (value: number) => void;
	onCommit: (value: number) => void;
}) => {
	const { value, readOnly, min, max, step, style, onPreview, onCommit } = props;
	const textValue = Number.isFinite(value) ? String(value) : "0";
	return (
		<input
			type="number"
			value={textValue}
			min={min}
			max={max}
			step={step}
			readOnly={readOnly}
			onChange={(event) => {
				if (!readOnly) onPreview(Number(event.currentTarget.value));
			}}
			onBlur={(event) => {
				if (!readOnly) onCommit(Number(event.currentTarget.value));
			}}
			style={{ ...inputStyle, opacity: readOnly ? 0.72 : 1, ...style }}
		/>
	);
};

const ParticleTextInput = (props: {
	value: string;
	readOnly?: boolean;
	onPreview: (value: string) => void;
	onCommit: (value: string) => void;
}) => {
	const { value, readOnly, onPreview, onCommit } = props;
	return (
		<input
			value={value}
			readOnly={readOnly}
			onChange={(event) => {
				if (!readOnly) onPreview(event.currentTarget.value);
			}}
			onBlur={(event) => {
				if (!readOnly) onCommit(event.currentTarget.value);
			}}
			style={{ ...inputStyle, opacity: readOnly ? 0.72 : 1 }}
		/>
	);
};

type NumberRowProps = {
	label: string;
	path: ParticleFieldPath;
	fields: ParticleFields;
	min?: number;
	max?: number;
	step?: number;
	disabled?: boolean;
	actions?: Array<{
		label: string;
		tooltip: string;
		value: number;
	}>;
	onUpdateField: ParticleEditorCanvasProps["onUpdateField"];
};

const NumberRow = ({ label, path, fields, min, max, step = 1, disabled, actions, onUpdateField }: NumberRowProps) => {
	const value = Number(readParticleFieldPath(fields, path) ?? 0);
	return (
		<Box sx={rowStyle}>
			<Typography sx={{ color: "#8f9aa6", fontSize: 12 }}>{label}</Typography>
			<Box sx={{ display: "flex", gap: "4px", minWidth: 0 }}>
				<ParticleNumberInput
					value={Number.isFinite(value) ? value : 0}
					readOnly={disabled}
					step={step}
					min={min}
					max={max}
					onPreview={(next) => onUpdateField(path, next, false)}
					onCommit={(next) => onUpdateField(path, next, true)}
				/>
				{actions?.map((action) => (
					<Tooltip key={action.label} title={action.tooltip}>
						<span>
							<button
								type="button"
								disabled={disabled}
								onClick={() => onUpdateField(path, action.value, true)}
								style={{ ...specialButtonStyle, opacity: disabled ? 0.55 : 1, cursor: disabled ? "default" : "pointer" }}
							>
								{action.label}
							</button>
						</span>
					</Tooltip>
				))}
			</Box>
		</Box>
	);
};

const clamp01 = (value: number) => Math.max(0, Math.min(1, Number.isFinite(value) ? value : 0));

const colorChannelToHex = (value: number) => Math.round(clamp01(value) * 255).toString(16).padStart(2, "0");

const colorToHex = (color: ParticleFields["startColor"]) => (
	`#${colorChannelToHex(color.x)}${colorChannelToHex(color.y)}${colorChannelToHex(color.z)}`
);

const colorToHexAlpha = (color: ParticleFields["startColor"]) => (
	`${colorToHex(color)}${colorChannelToHex(color.w)}`
);

const hexToRgba = (value: string, fallbackAlpha: number): ColorRgba | null => {
	const trimmed = value.trim().replace(/^#/, "");
	if (!/^[\da-fA-F]{6}([\da-fA-F]{2})?$/.test(trimmed)) return null;
	return {
		x: parseInt(trimmed.slice(0, 2), 16) / 255,
		y: parseInt(trimmed.slice(2, 4), 16) / 255,
		z: parseInt(trimmed.slice(4, 6), 16) / 255,
		w: trimmed.length === 8 ? parseInt(trimmed.slice(6, 8), 16) / 255 : fallbackAlpha,
	};
};

const colorToRgba = (color: ParticleFields["startColor"]) => (
	`rgba(${Math.round(clamp01(color.x) * 255)},${Math.round(clamp01(color.y) * 255)},${Math.round(clamp01(color.z) * 255)},${clamp01(color.w)})`
);

const checkerBackgroundImage = "linear-gradient(45deg, #2b2b2b 25%, transparent 25%), linear-gradient(-45deg, #2b2b2b 25%, transparent 25%), linear-gradient(45deg, transparent 75%, #2b2b2b 75%), linear-gradient(-45deg, transparent 75%, #2b2b2b 75%)";

const rgbToHsv = (r: number, g: number, b: number) => {
	const red = clamp01(r);
	const green = clamp01(g);
	const blue = clamp01(b);
	const max = Math.max(red, green, blue);
	const min = Math.min(red, green, blue);
	const delta = max - min;
	let h = 0;
	if (delta !== 0) {
		if (max === red) h = ((green - blue) / delta) % 6;
		else if (max === green) h = (blue - red) / delta + 2;
		else h = (red - green) / delta + 4;
		h *= 60;
		if (h < 0) h += 360;
	}
	return {
		h,
		s: max === 0 ? 0 : delta / max,
		v: max,
	};
};

const hsvToRgb = (h: number, s: number, v: number) => {
	const hue = ((h % 360) + 360) % 360;
	const saturation = clamp01(s);
	const value = clamp01(v);
	const c = value * saturation;
	const x = c * (1 - Math.abs((hue / 60) % 2 - 1));
	const m = value - c;
	let rgb = { x: 0, y: 0, z: 0 };
	if (hue < 60) rgb = { x: c, y: x, z: 0 };
	else if (hue < 120) rgb = { x, y: c, z: 0 };
	else if (hue < 180) rgb = { x: 0, y: c, z: x };
	else if (hue < 240) rgb = { x: 0, y: x, z: c };
	else if (hue < 300) rgb = { x, y: 0, z: c };
	else rgb = { x: c, y: 0, z: x };
	return {
		x: rgb.x + m,
		y: rgb.y + m,
		z: rgb.z + m,
	};
};

const loadParticleImageElement = async (filePath: string, servedResourceBasePath: string) => {
	const response = await fetch(Service.addr(particleResourceToServedUrl(filePath, servedResourceBasePath)));
	if (!response.ok) throw new Error(`Failed to load image: ${filePath}`);
	const objectUrl = URL.createObjectURL(await response.blob());
	try {
		const image = await new Promise<HTMLImageElement>((resolve, reject) => {
			const element = new Image();
			element.onload = () => resolve(element);
			element.onerror = () => reject(new Error(`Failed to decode image: ${filePath}`));
			element.src = objectUrl;
		});
		return { image, objectUrl };
	} catch (error) {
		URL.revokeObjectURL(objectUrl);
		throw error;
	}
};

type LoadedClipSlices = {
	entry: ParticleTextureResourceEntry;
	rects: ActionClipRect[];
	atlasImage: HTMLImageElement;
	objectUrl: string;
};

const TextureResourceDialog = memo(function TextureResourceDialog(props: {
	open: boolean;
	resourceBasePath: string;
	servedResourceBasePath: string;
	onClose: () => void;
	onSelect: (texture: string) => void;
	addAlert?: ParticleEditorCanvasProps["addAlert"];
}) {
	const { open, resourceBasePath, servedResourceBasePath, onClose, onSelect, addAlert } = props;
	const { t } = useTranslation();
	const [resources, setResources] = useState<ParticleTextureResourceEntry[]>([]);
	const [selectedClip, setSelectedClip] = useState<LoadedClipSlices | null>(null);
	const [loadingClipPath, setLoadingClipPath] = useState<string | null>(null);
	const [loading, setLoading] = useState(false);
	const [filter, setFilter] = useState("");
	useEffect(() => {
		if (!open) return;
		let cancelled = false;
		setLoading(true);
		setFilter("");
		findParticleTextureResourceFiles(resourceBasePath).then((items) => {
			if (!cancelled) setResources(items);
		}).catch((error) => {
			if (!cancelled) {
				setResources([]);
				addAlert?.(error instanceof Error ? error.message : t("particleEditor.dialogs.failedSearchTextureResources", "Failed to search texture resources."), "warning");
			}
		}).finally(() => {
			if (!cancelled) setLoading(false);
		});
		return () => {
			cancelled = true;
		};
	}, [addAlert, open, resourceBasePath, t]);
	const visibleResources = useMemo(() => {
		const query = filter.trim().toLowerCase();
		return query === "" ? resources : resources.filter((entry) => entry.relative.toLowerCase().includes(query));
	}, [filter, resources]);
	const selectTexture = (texture: string) => {
		onSelect(texture);
		setSelectedClip(null);
		onClose();
	};
	const openClipSlices = async (entry: ParticleTextureResourceEntry) => {
		setLoadingClipPath(entry.path);
		try {
			const res = await Service.read({ path: entry.path });
			if (!res.success) throw new Error(t("particleEditor.dialogs.failedReadClip", "Failed to read clip: {{file}}", { file: entry.relative }));
			const clip = parseLegacyClip(res.content, entry.path);
			const loaded = await loadParticleImageElement(clip.texturePath, servedResourceBasePath);
			setSelectedClip({
				entry,
				rects: Object.values(clip.rects).sort((a, b) => a.name.localeCompare(b.name)),
				atlasImage: loaded.image,
				objectUrl: loaded.objectUrl,
			});
		} catch (error) {
			addAlert?.(error instanceof Error ? error.message : t("particleEditor.dialogs.failedLoadClip", "Failed to load clip: {{file}}", { file: entry.relative }), "warning");
		} finally {
			setLoadingClipPath(null);
		}
	};
	useEffect(() => () => {
		if (selectedClip?.objectUrl) URL.revokeObjectURL(selectedClip.objectUrl);
	}, [selectedClip]);
	return (
		<>
			<Dialog open={open} onClose={onClose} fullWidth maxWidth="sm">
				<DialogTitle>{t("particleEditor.dialogs.chooseTextureResource", "Choose Texture Resource")}</DialogTitle>
				<DialogContent sx={{ display: "flex", flexDirection: "column", gap: 1.25, background: "#181818" }}>
					<div style={{ color: "#8f9aa6", fontSize: 12 }}>{resourceBasePath}</div>
					<TextField size="small" value={filter} onChange={(event) => setFilter(event.currentTarget.value)} placeholder={t("particleEditor.dialogs.filterImagesAndClips", "Filter images and clips")} />
					<div style={{ minHeight: 280, maxHeight: 460, overflow: "auto", border: "1px solid #2b2b2b" }}>
						{loading ? (
							<div style={{ color: "#8f9aa6", padding: 12 }}>{t("particleEditor.searching", "Searching...")}</div>
						) : visibleResources.length === 0 ? (
							<div style={{ color: "#8f9aa6", padding: 12 }}>{t("particleEditor.dialogs.noTextureResources", "No image or clip resources")}</div>
						) : visibleResources.map((entry) => (
							<button
								key={`${entry.kind}:${entry.relative}`}
								type="button"
								onClick={() => {
									if (entry.kind === "clip") openClipSlices(entry);
									else selectTexture(entry.relative);
								}}
								disabled={loadingClipPath !== null}
								style={{
									width: "100%",
									display: "flex",
									alignItems: "center",
									justifyContent: "space-between",
									gap: 8,
									padding: "8px 10px",
									border: "none",
									borderBottom: "1px solid #2b2b2b",
									background: "#1f1f1f",
									color: "#d7d7d7",
									cursor: loadingClipPath === null ? "pointer" : "default",
									opacity: loadingClipPath !== null && loadingClipPath !== entry.path ? 0.55 : 1,
									textAlign: "left",
								}}
							>
								<span style={{ minWidth: 0, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{entry.relative}</span>
								<span style={{ flex: "0 0 auto", color: entry.kind === "clip" ? "#fac03d" : "#8f9aa6", fontSize: 11 }}>
									{loadingClipPath === entry.path ? t("particleEditor.loadingShort", "loading") : t(`particleEditor.resourceKinds.${entry.kind}`, entry.kind)}
								</span>
							</button>
						))}
					</div>
				</DialogContent>
				<DialogActions>
					<Button onClick={onClose}>{t("particleEditor.cancel", "Cancel")}</Button>
				</DialogActions>
			</Dialog>
			<ClipSliceDialog
				open={selectedClip !== null}
				title={t("particleEditor.dialogs.chooseClipSlice", "Choose Clip Slice")}
				clipLabel={selectedClip?.entry.relative ?? ""}
				rects={selectedClip?.rects ?? []}
				atlasImage={selectedClip?.atlasImage ?? null}
				filterPlaceholder={t("particleEditor.dialogs.filterSlices", "Filter slices")}
				noSlicesText={t("particleEditor.dialogs.noSlices", "No slices")}
				cancelText={t("particleEditor.cancel", "Cancel")}
				contentHeight={420}
				paperSx={{ width: 900, maxWidth: "calc(100% - 64px)" }}
				onClose={() => setSelectedClip(null)}
				onSelect={(rect) => {
					if (selectedClip) selectTexture(`${selectedClip.entry.relative}|${rect.name}`);
				}}
			/>
		</>
	);
});

type ColorRgb = {
	x: number;
	y: number;
	z: number;
};

type ColorRgba = ColorRgb & {
	w: number;
};

type ParticleColorPath = "startColor" | "startColorVariance" | "finishColor" | "finishColorVariance";

const ColorRows = ({ label, basePath, fields, disabled, onUpdateColor }: {
	label: string;
	basePath: "startColor" | "finishColor";
	fields: ParticleFields;
	disabled?: boolean;
	onUpdateColor: ParticleEditorCanvasProps["onUpdateColor"];
}) => {
	const color = fields[basePath];
	const [pickerOpen, setPickerOpen] = useState(false);
	const [draftColor, setDraftColor] = useState<ColorRgba>({ x: color.x, y: color.y, z: color.z, w: color.w });
	const [draftHex, setDraftHex] = useState(colorToHexAlpha(color).toUpperCase());
	const displayColor = pickerOpen ? draftColor : color;
	const swatch = colorToRgba(displayColor);
	const hsv = rgbToHsv(displayColor.x, displayColor.y, displayColor.z);
	const hueColor = colorToHex({ ...hsvToRgb(hsv.h, 1, 1), w: 1 });
	const alphaColor = colorToRgba({ ...displayColor, w: 1 });
	useEffect(() => {
		if (!pickerOpen) {
			setDraftColor({ x: color.x, y: color.y, z: color.z, w: color.w });
			setDraftHex(colorToHexAlpha({ x: color.x, y: color.y, z: color.z, w: color.w }).toUpperCase());
		}
	}, [color.x, color.y, color.z, color.w, pickerOpen]);
	useEffect(() => {
		if (pickerOpen) setDraftHex(colorToHexAlpha({ x: draftColor.x, y: draftColor.y, z: draftColor.z, w: draftColor.w }).toUpperCase());
	}, [draftColor.x, draftColor.y, draftColor.z, draftColor.w, pickerOpen]);
	const applyColor = (next: ColorRgba) => onUpdateColor(basePath, {
		x: clamp01(next.x),
		y: clamp01(next.y),
		z: clamp01(next.z),
		w: clamp01(next.w),
	}, true);
	const closePicker = () => {
		applyColor(draftColor);
		setPickerOpen(false);
	};
	const commitHex = () => {
		const rgba = hexToRgba(draftHex, draftColor.w);
		if (!rgba) {
			setDraftHex(colorToHexAlpha({ x: draftColor.x, y: draftColor.y, z: draftColor.z, w: draftColor.w }).toUpperCase());
			return;
		}
		setDraftColor(rgba);
		setDraftHex(colorToHexAlpha(rgba).toUpperCase());
	};
	const updateSaturationValue = (event: PointerEvent<HTMLDivElement>) => {
		const rect = event.currentTarget.getBoundingClientRect();
		const s = clamp01((event.clientX - rect.left) / rect.width);
		const v = clamp01(1 - (event.clientY - rect.top) / rect.height);
		setDraftColor({ ...hsvToRgb(hsv.h, s, v), w: draftColor.w });
	};
	const updateHue = (event: PointerEvent<HTMLDivElement>) => {
		const rect = event.currentTarget.getBoundingClientRect();
		const h = clamp01((event.clientX - rect.left) / rect.width) * 360;
		setDraftColor({ ...hsvToRgb(h, hsv.s, hsv.v), w: draftColor.w });
	};
	const updateAlpha = (event: PointerEvent<HTMLDivElement>) => {
		const rect = event.currentTarget.getBoundingClientRect();
		const w = clamp01((event.clientX - rect.left) / rect.width);
		setDraftColor({ ...draftColor, w });
	};
	return (
		<Box sx={{ ...rowStyle, position: "relative" }}>
			<Typography sx={{ color: "#8f9aa6", fontSize: 12 }}>{label}</Typography>
			<Box sx={{ display: "flex", alignItems: "center", minWidth: 0 }}>
				<Box
					component="button"
					type="button"
					disabled={disabled}
					onClick={() => {
						if (pickerOpen) {
							closePicker();
						} else {
							setDraftColor({ x: color.x, y: color.y, z: color.z, w: color.w });
							setDraftHex(colorToHexAlpha(color).toUpperCase());
							setPickerOpen(true);
						}
					}}
					sx={{
						width: 32,
						height: 26,
						boxSizing: "border-box",
						background: "#181818",
						border: "1px solid #3a3a3a",
						padding: "3px",
						cursor: disabled ? "default" : "pointer",
						opacity: disabled ? 0.72 : 1,
						position: "relative",
						display: "block",
						flex: "0 0 auto",
						"&:focus": {
							outline: "2px solid #d7d7d7",
							outlineOffset: 0,
						},
					}}
				>
					<Box sx={{ width: "100%", height: "100%", background: swatch, border: "1px solid #666", boxSizing: "border-box" }} />
				</Box>
			</Box>
			{pickerOpen && !disabled ? (
				<Box
					sx={{
						position: "absolute",
						zIndex: 20,
						top: 30,
						left: "calc(100% - 184px)",
						width: 184,
						padding: "8px",
						background: "#1a1a1a",
						border: "1px solid #3a3a3a",
						boxShadow: "0 10px 24px rgba(0,0,0,0.45)",
					}}
				>
					<Box
						onPointerDown={(event) => {
							event.currentTarget.setPointerCapture(event.pointerId);
							updateSaturationValue(event);
						}}
						onPointerMove={(event) => {
							if (event.currentTarget.hasPointerCapture(event.pointerId)) updateSaturationValue(event);
						}}
						onPointerUp={(event) => {
							updateSaturationValue(event);
							event.currentTarget.releasePointerCapture(event.pointerId);
						}}
						sx={{
							position: "relative",
							height: 118,
							background: `linear-gradient(to top, #000, transparent), linear-gradient(to right, #fff, ${hueColor})`,
							border: "1px solid #3a3a3a",
							cursor: "crosshair",
						}}
					>
						<Box
							sx={{
								position: "absolute",
								left: `${hsv.s * 100}%`,
								top: `${(1 - hsv.v) * 100}%`,
								width: 8,
								height: 8,
								border: "2px solid #fff",
								boxShadow: "0 0 0 1px #000",
								transform: "translate(-50%, -50%)",
								pointerEvents: "none",
							}}
						/>
					</Box>
					<Box
						onPointerDown={(event) => {
							event.currentTarget.setPointerCapture(event.pointerId);
							updateHue(event);
						}}
						onPointerMove={(event) => {
							if (event.currentTarget.hasPointerCapture(event.pointerId)) updateHue(event);
						}}
						onPointerUp={(event) => {
							updateHue(event);
							event.currentTarget.releasePointerCapture(event.pointerId);
						}}
						sx={{
							position: "relative",
							height: 12,
							marginTop: "8px",
							background: "linear-gradient(to right, #f00, #ff0, #0f0, #0ff, #00f, #f0f, #f00)",
							border: "1px solid #3a3a3a",
							cursor: "ew-resize",
						}}
					>
						<Box
							sx={{
								position: "absolute",
								left: `${hsv.h / 360 * 100}%`,
								top: "50%",
								width: 6,
								height: 16,
								border: "2px solid #fff",
								boxShadow: "0 0 0 1px #000",
								transform: "translate(-50%, -50%)",
								pointerEvents: "none",
							}}
						/>
					</Box>
					<Box
						onPointerDown={(event) => {
							event.currentTarget.setPointerCapture(event.pointerId);
							updateAlpha(event);
						}}
						onPointerMove={(event) => {
							if (event.currentTarget.hasPointerCapture(event.pointerId)) updateAlpha(event);
						}}
						onPointerUp={(event) => {
							updateAlpha(event);
							event.currentTarget.releasePointerCapture(event.pointerId);
						}}
						sx={{
							position: "relative",
							height: 12,
							marginTop: "8px",
							backgroundColor: "#1a1a1a",
							backgroundImage: `linear-gradient(to right, rgba(0,0,0,0), ${alphaColor}), ${checkerBackgroundImage}`,
							backgroundPosition: "0 0, 0 0, 0 5px, 5px -5px, -5px 0",
							backgroundSize: "auto, 10px 10px, 10px 10px, 10px 10px, 10px 10px",
							border: "1px solid #3a3a3a",
							cursor: "ew-resize",
						}}
					>
						<Box
							sx={{
								position: "absolute",
								left: `${draftColor.w * 100}%`,
								top: "50%",
								width: 6,
								height: 16,
								border: "2px solid #fff",
								boxShadow: "0 0 0 1px #000",
								transform: "translate(-50%, -50%)",
								pointerEvents: "none",
							}}
						/>
					</Box>
					<Box sx={{ display: "flex", alignItems: "center", gap: "6px", marginTop: "6px" }}>
						<input
							value={draftHex}
							onChange={(event) => setDraftHex(event.currentTarget.value)}
							onBlur={commitHex}
							onKeyDown={(event) => {
								if (event.key === "Enter") {
									commitHex();
									event.currentTarget.blur();
								}
							}}
							style={{ ...inputStyle, flex: 1, minWidth: 0, minHeight: 24, padding: "0 6px", fontSize: 11 }}
						/>
						<button
							type="button"
							onClick={closePicker}
							style={{
								height: 24,
								border: "1px solid #3a3a3a",
								background: "#252525",
								color: "#d7d7d7",
								cursor: "pointer",
							}}
						>
							Done
						</button>
					</Box>
				</Box>
			) : null}
		</Box>
	);
};

type ParticleColorVariancePath = "startColorVariance" | "finishColorVariance";
type ParticleColorBasePath = "startColor" | "finishColor";

const colorComponentLabels = [
	{ key: "x", label: "R ±" },
	{ key: "y", label: "G ±" },
	{ key: "z", label: "B ±" },
	{ key: "w", label: "A ±" },
] as const;

const ColorVarianceRows = ({ label, basePath, variancePath, fields, disabled, onUpdateField }: {
	label: string;
	basePath: ParticleColorBasePath;
	variancePath: ParticleColorVariancePath;
	fields: ParticleFields;
	disabled?: boolean;
	onUpdateField: ParticleEditorCanvasProps["onUpdateField"];
}) => {
	const { t } = useTranslation();
	const base = fields[basePath];
	const variance = fields[variancePath];
	const minColor = {
		x: base.x - variance.x,
		y: base.y - variance.y,
		z: base.z - variance.z,
		w: base.w - variance.w,
	};
	const maxColor = {
		x: base.x + variance.x,
		y: base.y + variance.y,
		z: base.z + variance.z,
		w: base.w + variance.w,
	};
	return (
		<Box sx={{ ...rowStyle, alignItems: "start" }}>
			<Typography sx={{ color: "#8f9aa6", fontSize: 12, paddingTop: "2px" }}>{label}</Typography>
			<Box sx={{ minWidth: 0 }}>
				<Tooltip title={t("particleEditor.tooltips.colorVariation", "Per-particle random variation: base color plus or minus this RGBA range. This is not a target color.")}>
					<Box
						sx={{
							height: 20,
							border: "1px solid #3a3a3a",
							padding: "2px",
							boxSizing: "border-box",
							marginBottom: "5px",
						}}
					>
						<Box
							sx={{
								width: "100%",
								height: "100%",
								border: "1px solid #666",
								boxSizing: "border-box",
								backgroundColor: "#1a1a1a",
								backgroundImage: `linear-gradient(to right, ${colorToRgba(minColor)}, ${colorToRgba(maxColor)}), ${checkerBackgroundImage}`,
								backgroundPosition: "0 0, 0 0, 0 5px, 5px -5px, -5px 0",
								backgroundSize: "auto, 10px 10px, 10px 10px, 10px 10px, 10px 10px",
							}}
						/>
					</Box>
				</Tooltip>
				<Box sx={{ display: "grid", gridTemplateColumns: "repeat(4, minmax(0, 1fr))", gap: "4px" }}>
					{colorComponentLabels.map(({ key, label: channelLabel }) => (
						<Box key={key} sx={{ minWidth: 0 }}>
							<Typography sx={{ color: "#8f9aa6", fontSize: 10, lineHeight: "12px", marginBottom: "2px" }}>{channelLabel}</Typography>
							<ParticleNumberInput
								value={variance[key]}
								readOnly={disabled}
								min={0}
								max={1}
								step={0.01}
								style={{ minWidth: 0, padding: "0 4px", fontSize: 11 }}
								onPreview={(next) => onUpdateField(`${variancePath}.${key}`, clamp01(next), false)}
								onCommit={(next) => onUpdateField(`${variancePath}.${key}`, clamp01(next), true)}
							/>
						</Box>
					))}
				</Box>
			</Box>
		</Box>
	);
};

export default memo(function ParticleEditorCanvas(props: ParticleEditorCanvasProps) {
	const { document, width, height, resourceBasePath, servedResourceBasePath, active, readOnly, texture, textureLabel, textureWarning, canUndo, canRedo, onUndo, onRedo, onUpdateField, onUpdateColor, onSelectTexture, onApplyPreset, addAlert } = props;
	const { t } = useTranslation();
	const fieldLabel = (key: string, fallback: string) => t(`particleEditor.fields.${key}`, fallback);
	const canvasRef = useRef<HTMLCanvasElement | null>(null);
	const overlayRef = useRef<HTMLCanvasElement | null>(null);
	const rendererRef = useRef<ParticleWebGLRenderer | null>(null);
	const runtimeRef = useRef<ParticlePreviewRuntime | null>(null);
	const activeRef = useRef(active);
	const previewEmitterRef = useRef({ x: 0, y: 0 });
	const frameRef = useRef<number | null>(null);
	const drawGuidesRef = useRef<() => void>(() => { });
	const dragRef = useRef<{
		mode: "none" | "emitter" | "pan" | "variance-x" | "variance-y" | "radius-start" | "radius-finish";
		clientX: number;
		clientY: number;
		offsetX: number;
		offsetY: number;
		moved: boolean;
	}>({ mode: "none", clientX: 0, clientY: 0, offsetX: 0, offsetY: 0, moved: false });
	const [playing, setPlaying] = useState(true);
	const [zoom, setZoom] = useState(1);
	const [offset, setOffset] = useState({ x: 0, y: 0 });
	const [previewEmitter, setPreviewEmitter] = useState({ x: 0, y: 0 });
	const [snapshot, setSnapshot] = useState<ParticleRuntimeSnapshot>({ active: false, emitting: false, elapsed: 0, particleCount: 0, quads: [] });
	const [textureDialogOpen, setTextureDialogOpen] = useState(false);
	const fields = document.fields;
	const usesClipTexture = fields.textureName.toLowerCase().includes(".clip|");
	const usesImageTexture = isParticleTextureImageSource(fields.textureName);
	const canvasWidth = Math.max(1, width - 320);
	const canvasHeight = Math.max(1, height - 42);
	const diagnostics = useMemo(() => validateParticleDocument(document), [document]);

	useEffect(() => {
		const canvas = canvasRef.current;
		if (!canvas) return;
		const renderer = new ParticleWebGLRenderer(canvas);
		rendererRef.current = renderer;
		return () => {
			renderer.dispose();
			rendererRef.current = null;
		};
	}, []);

	useEffect(() => {
		activeRef.current = active;
		if (!active && frameRef.current !== null) {
			cancelAnimationFrame(frameRef.current);
			frameRef.current = null;
		}
	}, [active]);

	useEffect(() => {
		runtimeRef.current = new ParticlePreviewRuntime(document, undefined, true);
		runtimeRef.current.setPreviewEmitterPosition(previewEmitterRef.current);
		if (activeRef.current) setSnapshot(runtimeRef.current.snapshot());
	}, [document]);

	useEffect(() => {
		if (!active) return;
		const tick = () => {
			if (!activeRef.current) {
				frameRef.current = null;
				return;
			}
			const runtime = runtimeRef.current;
			const renderer = rendererRef.current;
			if (runtime && renderer) {
				const delta = 1 / 60;
				const nextSnapshot = playing ? runtime.step(delta) : runtime.snapshot();
				renderer.render(nextSnapshot.quads, {
					width: canvasWidth,
					height: canvasHeight,
					zoom,
					offsetX: offset.x,
					offsetY: offset.y,
					sourceBlend: fields.blendFuncSource,
					destinationBlend: fields.blendFuncDestination,
					depthWrite: false,
					texture,
				});
				drawGuidesRef.current();
				setSnapshot(nextSnapshot);
			}
			frameRef.current = requestAnimationFrame(tick);
		};
		frameRef.current = requestAnimationFrame(tick);
		return () => {
			if (frameRef.current !== null) cancelAnimationFrame(frameRef.current);
			frameRef.current = null;
		};
	}, [active, canvasHeight, canvasWidth, fields.blendFuncDestination, fields.blendFuncSource, offset, playing, texture, zoom]);

	const restart = () => {
		runtimeRef.current?.start();
		setPlaying(true);
	};

	const runViewTool = (name: BodyIconName) => {
		if (name === "origin") {
			const nextEmitter = { x: 0, y: 0 };
			previewEmitterRef.current = nextEmitter;
			setPreviewEmitter(nextEmitter);
			runtimeRef.current?.setPreviewEmitterPosition(nextEmitter);
			setOffset({ x: 0, y: 0 });
			setZoom(1);
		} else if (name === "zoom") {
			setZoom((current) => current >= 2 ? 0.5 : current >= 1 ? 2 : 1);
		}
	};

	const onKeyDown = useCallback((event: KeyboardEvent<HTMLDivElement>) => {
		const target = event.target as HTMLElement | null;
		if (target && ["INPUT", "TEXTAREA", "SELECT"].includes(target.tagName)) return;
		const key = event.key.toLowerCase();
		const command = event.metaKey || event.ctrlKey;
		if (command && key === "z") {
			event.preventDefault();
			if (readOnly) return;
			if (event.shiftKey) {
				if (canRedo) onRedo();
			} else if (canUndo) {
				onUndo();
			}
		} else if (command && key === "y") {
			event.preventDefault();
			if (readOnly) return;
			if (canRedo) onRedo();
		}
	}, [canRedo, canUndo, onRedo, onUndo, readOnly]);

	const screenToWorld = (clientX: number, clientY: number) => {
		const rect = canvasRef.current?.getBoundingClientRect();
		if (!rect) return { x: 0, y: 0 };
		return {
			x: (clientX - rect.left - canvasWidth / 2 - offset.x) / zoom,
			y: -(clientY - rect.top - canvasHeight / 2 - offset.y) / zoom,
		};
	};

	const updatePreviewEmitterPosition = (clientX: number, clientY: number) => {
		const world = screenToWorld(clientX, clientY);
		const next = {
			x: Number((world.x - fields.startPosition.x).toFixed(2)),
			y: Number((world.y - fields.startPosition.y).toFixed(2)),
		};
		previewEmitterRef.current = next;
		setPreviewEmitter(next);
		runtimeRef.current?.setPreviewEmitterPosition(next);
	};

	const spawnCenter = {
		x: previewEmitter.x + fields.startPosition.x,
		y: previewEmitter.y + fields.startPosition.y,
	};

	const worldToScreen = (x: number, y: number) => ({
		x: canvasWidth / 2 + offset.x + x * zoom,
		y: canvasHeight / 2 + offset.y - y * zoom,
	});

	const hitTestGizmo = (clientX: number, clientY: number) => {
		const rect = canvasRef.current?.getBoundingClientRect();
		if (!rect) return "emitter";
		const sx = clientX - rect.left;
		const sy = clientY - rect.top;
		const emitter = worldToScreen(spawnCenter.x, spawnCenter.y);
		if (Math.hypot(sx - emitter.x, sy - emitter.y) <= 12) return "emitter";
		const variance = fields.startPositionVariance;
		if (variance.x > 0 || variance.y > 0) {
			const left = worldToScreen(spawnCenter.x - variance.x, spawnCenter.y).x;
			const right = worldToScreen(spawnCenter.x + variance.x, spawnCenter.y).x;
			const top = worldToScreen(spawnCenter.x, spawnCenter.y + variance.y).y;
			const bottom = worldToScreen(spawnCenter.x, spawnCenter.y - variance.y).y;
			if (sy >= top - 8 && sy <= bottom + 8 && (Math.abs(sx - left) <= 8 || Math.abs(sx - right) <= 8)) return "variance-x";
			if (sx >= left - 8 && sx <= right + 8 && (Math.abs(sy - top) <= 8 || Math.abs(sy - bottom) <= 8)) return "variance-y";
		}
		if (fields.emitterMode === "radius") {
			const center = worldToScreen(0, 0);
			const distance = Math.hypot(sx - center.x, sy - center.y) / zoom;
			if (Math.abs(distance - Math.abs(fields.radius.startRadius)) <= 8 / zoom) return "radius-start";
			if (fields.radius.finishRadius >= 0 && Math.abs(distance - Math.abs(fields.radius.finishRadius)) <= 8 / zoom) return "radius-finish";
		}
		return "emitter";
	};

	drawGuidesRef.current = () => {
		const canvas = overlayRef.current;
		if (!canvas) return;
		if (canvas.width !== canvasWidth || canvas.height !== canvasHeight) {
			canvas.width = canvasWidth;
			canvas.height = canvasHeight;
		}
		const ctx = canvas.getContext("2d");
		if (!ctx) return;
		ctx.clearRect(0, 0, canvasWidth, canvasHeight);

		const variance = fields.startPositionVariance;
		if (variance.x > 0 || variance.y > 0) {
			const topLeft = worldToScreen(spawnCenter.x - variance.x, spawnCenter.y + variance.y);
			const bottomRight = worldToScreen(spawnCenter.x + variance.x, spawnCenter.y - variance.y);
			ctx.strokeStyle = editorAssistColor;
			ctx.setLineDash([5, 4]);
			ctx.strokeRect(topLeft.x, topLeft.y, bottomRight.x - topLeft.x, bottomRight.y - topLeft.y);
			ctx.setLineDash([]);
		}
		if (fields.emitterMode === "radius") {
			const center = worldToScreen(0, 0);
			ctx.strokeStyle = editorAssistColor;
			ctx.beginPath();
			ctx.arc(center.x, center.y, Math.abs(fields.radius.startRadius) * zoom, 0, Math.PI * 2);
			ctx.stroke();
			if (fields.radius.finishRadius >= 0) {
				ctx.strokeStyle = editorAssistSecondaryColor;
				ctx.beginPath();
				ctx.arc(center.x, center.y, Math.abs(fields.radius.finishRadius) * zoom, 0, Math.PI * 2);
				ctx.stroke();
			}
		}
	};

	return (
		<>
			<Box tabIndex={0} onKeyDown={onKeyDown} sx={{ width, height, display: "flex", flexDirection: "column", background: "#1f1f1f", overflow: "hidden", outline: "none" }}>
				<Stack direction="row" alignItems="center" spacing={1} sx={{ height: 44, borderBottom: "1px solid #2b2b2b", padding: "2px 10px 0", flexShrink: 0, background: "#1a1a1a", boxSizing: "border-box" }}>
					<Box sx={{ display: "flex", alignItems: "center", gap: "6px" }}>
						<Typography sx={{ color: "#9aa4af", fontSize: 12, marginRight: "2px" }}>{t("particleEditor.toolbar.view", "View")}</Typography>
						{viewToolNames.map((name) => (
							<Fragment key={name}>
								<button
									type="button"
									title={t(`bodyEditor.icons.${name}`, viewToolLabels[name])}
									aria-label={t(`bodyEditor.icons.${name}`, viewToolLabels[name])}
									onClick={() => runViewTool(name)}
									style={{
										width: 30,
										height: 30,
										border: "1px solid #343434",
										background: "#303030",
										padding: 3,
										cursor: "pointer",
									}}
								>
									<BodyIconGlyph name={name} />
								</button>
								{name === "zoom" ? <Typography sx={{ color: "#d7d7d7", fontSize: 12, width: 58, flexShrink: 0, textAlign: "center" }}>{t("particleEditor.zoomValue", { zoom: (zoom * 100).toFixed(0) })}</Typography> : null}
							</Fragment>
						))}
					</Box>
					<Tooltip title={playing ? t("particleEditor.toolbar.pause", "Pause") : t("particleEditor.toolbar.play", "Play")}>
						<IconButton size="small" onClick={() => setPlaying(!playing)} sx={toolButtonSx}>{playing ? <PauseIcon fontSize="small" /> : <PlayArrowIcon fontSize="small" />}</IconButton>
					</Tooltip>
					<Tooltip title={t("particleEditor.toolbar.restart", "Restart")}>
						<IconButton size="small" onClick={restart} sx={toolButtonSx}><ReplayIcon fontSize="small" /></IconButton>
					</Tooltip>
					<Tooltip title={t("particleEditor.toolbar.undo", "Undo")}>
						<span><IconButton size="small" disabled={!canUndo || readOnly} onClick={onUndo} sx={toolButtonSx}><UndoIcon fontSize="small" /></IconButton></span>
					</Tooltip>
					<Tooltip title={t("particleEditor.toolbar.redo", "Redo")}>
						<span><IconButton size="small" disabled={!canRedo || readOnly} onClick={onRedo} sx={toolButtonSx}><RedoIcon fontSize="small" /></IconButton></span>
					</Tooltip>
					<Box sx={{ flex: 1 }} />
					<Typography sx={{ color: "#8f9aa6", fontSize: 12 }}>{t("particleEditor.status.particles", "particles")} {snapshot.particleCount} · t {snapshot.elapsed.toFixed(2)} · {textureLabel}</Typography>
				</Stack>
				<Box sx={{ display: "flex", flex: 1, minHeight: 0 }}>
					<Box sx={{ position: "relative", width: canvasWidth, height: canvasHeight, flexShrink: 0, background: "#1f1f1f" }}>
						<canvas
							ref={canvasRef}
							style={{ position: "absolute", inset: 0, width: canvasWidth, height: canvasHeight, display: "block", zIndex: 0, pointerEvents: "none" }}
						/>
						<canvas
							ref={overlayRef}
							style={{ position: "absolute", inset: 0, width: canvasWidth, height: canvasHeight, display: "block", zIndex: 1, cursor: readOnly ? "grab" : "crosshair" }}
							onPointerDown={(event) => {
								const mode = event.shiftKey || event.button === 1 || readOnly ? "pan" : hitTestGizmo(event.clientX, event.clientY);
								dragRef.current = { mode, clientX: event.clientX, clientY: event.clientY, offsetX: offset.x, offsetY: offset.y, moved: false };
								event.currentTarget.setPointerCapture(event.pointerId);
							}}
							onPointerMove={(event) => {
								const drag = dragRef.current;
								if (drag.mode === "none") return;
								const moved = drag.moved || Math.hypot(event.clientX - drag.clientX, event.clientY - drag.clientY) > 2;
								if (moved !== drag.moved) dragRef.current = { ...drag, moved };
								if (drag.mode === "pan") {
									setOffset({
										x: drag.offsetX + event.clientX - drag.clientX,
										y: drag.offsetY + event.clientY - drag.clientY,
									});
									return;
								}
								if (readOnly) return;
								if (!moved) return;
								const world = screenToWorld(event.clientX, event.clientY);
								if (drag.mode === "emitter") {
									updatePreviewEmitterPosition(event.clientX, event.clientY);
								} else if (drag.mode === "variance-x") {
									onUpdateField("startPositionVariance.x", Number(Math.abs(world.x - spawnCenter.x).toFixed(2)), false);
								} else if (drag.mode === "variance-y") {
									onUpdateField("startPositionVariance.y", Number(Math.abs(world.y - spawnCenter.y).toFixed(2)), false);
								} else if (drag.mode === "radius-start" || drag.mode === "radius-finish") {
									const radius = Number(Math.hypot(world.x, world.y).toFixed(2));
									onUpdateField(drag.mode === "radius-start" ? "radius.startRadius" : "radius.finishRadius", radius, false);
								}
							}}
							onPointerUp={(event) => {
								const drag = dragRef.current;
								if (drag.mode === "none") return;
								dragRef.current = { ...drag, mode: "none" };
								event.currentTarget.releasePointerCapture(event.pointerId);
								if (drag.mode === "pan" || readOnly) return;
								if (!drag.moved) return;
								const world = screenToWorld(event.clientX, event.clientY);
								if (drag.mode === "emitter") {
									updatePreviewEmitterPosition(event.clientX, event.clientY);
								} else if (drag.mode === "variance-x") {
									onUpdateField("startPositionVariance.x", Number(Math.abs(world.x - spawnCenter.x).toFixed(2)), true);
								} else if (drag.mode === "variance-y") {
									onUpdateField("startPositionVariance.y", Number(Math.abs(world.y - spawnCenter.y).toFixed(2)), true);
								} else if (drag.mode === "radius-start" || drag.mode === "radius-finish") {
									const radius = Number(Math.hypot(world.x, world.y).toFixed(2));
									onUpdateField(drag.mode === "radius-start" ? "radius.startRadius" : "radius.finishRadius", radius, true);
								}
							}}
							onWheel={(event) => {
								event.preventDefault();
								setZoom((current) => {
									const wheel = Math.max(-1, Math.min(1, -event.deltaY / 100));
									return Math.max(0.1, Math.min(8, current + wheel * 0.1));
								});
							}}
						/>
					</Box>
					<Box sx={{ width: 320, borderLeft: "1px solid #2b2b2b", overflow: "auto", padding: "10px 12px 96px", flexShrink: 0, background: "#1a1a1a", boxSizing: "border-box" }}>
						<Typography sx={sectionTitleStyle}>{t("particleEditor.presets.title", "Presets")}</Typography>
						<Box sx={{ maxHeight: 124, overflowY: "auto", marginBottom: "8px", paddingRight: "4px" }}>
							<Box sx={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "6px" }}>
								{particlePresets.map((preset) => (
									<button
										key={preset.id}
										type="button"
										disabled={readOnly}
										onClick={() => onApplyPreset(preset.id)}
										style={{
											height: 28,
											border: "1px solid #3a3a3a",
											background: "#252525",
											color: "#d7d7d7",
											cursor: readOnly ? "default" : "pointer",
											opacity: readOnly ? 0.55 : 1,
											fontSize: 12,
										}}
									>
										{t(`particleEditor.presets.${preset.id}`, preset.label)}
									</button>
								))}
							</Box>
						</Box>
						{textureWarning ? <Box sx={{ color: "#f0b36a", fontSize: 12, marginBottom: 1 }}>{textureWarning}</Box> : null}
						{diagnostics.length > 0 ? (
							<Box sx={{ color: "#d7b66f", fontSize: 12, marginBottom: 1 }}>
								{diagnostics.slice(0, 4).map((item, index) => <div key={`${item.path}:${index}`}>{item.message}</div>)}
							</Box>
						) : null}
						<Typography sx={sectionTitleStyle}>{t("particleEditor.sections.general", "General")}</Typography>
						<Stack spacing={0.75}>
							<NumberRow
								label={fieldLabel("duration", "Duration")}
								path="duration"
								fields={fields}
								step={0.1}
								disabled={readOnly}
								actions={[{ label: "∞", tooltip: t("particleEditor.tooltips.durationInfinite", "Set to -1: emit forever until stopped."), value: -1 }]}
								onUpdateField={onUpdateField}
							/>
							<NumberRow label={fieldLabel("emission", "Emission")} path="emissionRate" fields={fields} min={0} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
							<NumberRow label={fieldLabel("max", "Max")} path="maxParticles" fields={fields} min={0} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
							<NumberRow label={fieldLabel("life", "Life")} path="particleLifespan" fields={fields} min={0} step={0.1} disabled={readOnly} onUpdateField={onUpdateField} />
							<NumberRow label={fieldLabel("lifeVar", "Life Var")} path="particleLifespanVariance" fields={fields} min={0} step={0.1} disabled={readOnly} onUpdateField={onUpdateField} />
						</Stack>
						<Typography sx={sectionTitleStyle}>{t("particleEditor.sections.emission", "Emission")}</Typography>
						<Stack spacing={0.75}>
							<NumberRow label={fieldLabel("angle", "Angle")} path="angle" fields={fields} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
							<NumberRow label={fieldLabel("angleVar", "Angle Var")} path="angleVariance" fields={fields} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
							<NumberRow label={fieldLabel("posX", "Pos X")} path="startPosition.x" fields={fields} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
							<NumberRow label={fieldLabel("posY", "Pos Y")} path="startPosition.y" fields={fields} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
							<NumberRow label={fieldLabel("varX", "Var X")} path="startPositionVariance.x" fields={fields} min={0} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
							<NumberRow label={fieldLabel("varY", "Var Y")} path="startPositionVariance.y" fields={fields} min={0} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
						</Stack>
						<Typography sx={sectionTitleStyle}>{t("particleEditor.sections.color", "Color")}</Typography>
						<Stack spacing={1}>
							<ColorRows label={fieldLabel("start", "Start")} basePath="startColor" fields={fields} disabled={readOnly} onUpdateColor={onUpdateColor} />
							<ColorVarianceRows label={fieldLabel("startVariation", "Start Variation")} basePath="startColor" variancePath="startColorVariance" fields={fields} disabled={readOnly} onUpdateField={onUpdateField} />
							<ColorRows label={fieldLabel("finish", "Finish")} basePath="finishColor" fields={fields} disabled={readOnly} onUpdateColor={onUpdateColor} />
							<ColorVarianceRows label={fieldLabel("finishVariation", "Finish Variation")} basePath="finishColor" variancePath="finishColorVariance" fields={fields} disabled={readOnly} onUpdateField={onUpdateField} />
						</Stack>
						<Typography sx={sectionTitleStyle}>{t("particleEditor.sections.sizeRotation", "Size / Rotation")}</Typography>
						<Stack spacing={0.75}>
							<NumberRow label={fieldLabel("startSize", "Start Size")} path="startParticleSize" fields={fields} min={0} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
							<NumberRow label={fieldLabel("startVar", "Start Var")} path="startParticleSizeVariance" fields={fields} min={0} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
							<NumberRow
								label={fieldLabel("finishSize", "Finish Size")}
								path="finishParticleSize"
								fields={fields}
								step={1}
								disabled={readOnly}
								actions={[{ label: t("particleEditor.actions.same", "Same"), tooltip: t("particleEditor.tooltips.finishSizeSame", "Set to -1: keep each particle at its start size."), value: -1 }]}
								onUpdateField={onUpdateField}
							/>
							<NumberRow label={fieldLabel("finishVar", "Finish Var")} path="finishParticleSizeVariance" fields={fields} min={0} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
							<NumberRow label={fieldLabel("rotStart", "Rot Start")} path="rotationStart" fields={fields} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
							<NumberRow label={fieldLabel("rotStartVar", "Rot Start Var")} path="rotationStartVariance" fields={fields} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
							<NumberRow label={fieldLabel("rotEnd", "Rot End")} path="rotationEnd" fields={fields} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
							<NumberRow label={fieldLabel("rotEndVar", "Rot End Var")} path="rotationEndVariance" fields={fields} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
						</Stack>
						<Typography sx={sectionTitleStyle}>{t("particleEditor.sections.texture", "Texture")}</Typography>
						<Stack spacing={0.75}>
							<Box sx={rowStyle}>
								<Typography sx={{ color: "#8f9aa6", fontSize: 12 }}>{fieldLabel("texture", "Texture")}</Typography>
								<Box sx={{ display: "flex", gap: "4px", minWidth: 0 }}>
									<ParticleTextInput
										value={fields.textureName}
										readOnly={readOnly}
										onPreview={(next) => onUpdateField("textureName", next, false)}
										onCommit={(next) => onUpdateField("textureName", next, true)}
									/>
									<Tooltip title={t("particleEditor.tooltips.chooseTexture", "Choose an image file or a .clip slice. Other resource types are not shown.")}>
										<span>
											<button
												type="button"
												disabled={readOnly}
												onClick={() => setTextureDialogOpen(true)}
												style={{ ...specialButtonStyle, opacity: readOnly ? 0.55 : 1, cursor: readOnly ? "default" : "pointer" }}
											>
												...
											</button>
										</span>
									</Tooltip>
								</Box>
							</Box>
							{usesClipTexture ? (
								<Box sx={{ color: "#8f9aa6", fontSize: 11, lineHeight: "15px" }}>
									{t("particleEditor.textureRectFromClip", "Texture Rect is provided by the selected .clip slice.")}
								</Box>
							) : usesImageTexture ? (
								<>
									<NumberRow label={fieldLabel("rectX", "Rect X")} path="textureRect.x" fields={fields} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
									<NumberRow label={fieldLabel("rectY", "Rect Y")} path="textureRect.y" fields={fields} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
									<NumberRow
										label={fieldLabel("rectW", "Rect W")}
										path="textureRect.width"
										fields={fields}
										step={1}
										disabled={readOnly}
										actions={[{ label: t("particleEditor.actions.full", "Full"), tooltip: t("particleEditor.tooltips.rectWidthFull", "Set width to 0: use the full texture rectangle."), value: 0 }]}
										onUpdateField={onUpdateField}
									/>
									<NumberRow
										label={fieldLabel("rectH", "Rect H")}
										path="textureRect.height"
										fields={fields}
										step={1}
										disabled={readOnly}
										actions={[{ label: t("particleEditor.actions.full", "Full"), tooltip: t("particleEditor.tooltips.rectHeightFull", "Set height to 0: use the full texture rectangle."), value: 0 }]}
										onUpdateField={onUpdateField}
									/>
								</>
							) : null}
							<Box sx={rowStyle}>
								<Typography sx={{ color: "#8f9aa6", fontSize: 12 }}>{fieldLabel("blendSrc", "Blend Src")}</Typography>
								<select
									value={fields.blendFuncSource}
									disabled={readOnly}
									onChange={(event) => onUpdateField("blendFuncSource", Number(event.currentTarget.value), true)}
									style={{ ...selectStyle, opacity: readOnly ? 0.72 : 1 }}
								>
									{blendOptions.map((item) => <option key={item.value} value={item.value}>{item.label}</option>)}
								</select>
							</Box>
							<Box sx={rowStyle}>
								<Typography sx={{ color: "#8f9aa6", fontSize: 12 }}>{fieldLabel("blendDst", "Blend Dst")}</Typography>
								<select
									value={fields.blendFuncDestination}
									disabled={readOnly}
									onChange={(event) => onUpdateField("blendFuncDestination", Number(event.currentTarget.value), true)}
									style={{ ...selectStyle, opacity: readOnly ? 0.72 : 1 }}
								>
									{blendOptions.map((item) => <option key={item.value} value={item.value}>{item.label}</option>)}
								</select>
							</Box>
						</Stack>
						<Typography sx={sectionTitleStyle}>{t("particleEditor.sections.emitter", "Emitter")}</Typography>
						<Stack direction="row" spacing={1}>
							{(["gravity", "radius"] as const).map((mode) => {
								const selected = fields.emitterMode === mode;
								return (
									<button
										key={mode}
										type="button"
										disabled={readOnly}
										onClick={() => onUpdateField("emitterMode", mode, true)}
										style={{
											height: 26,
											minWidth: 72,
											border: "1px solid " + (selected ? "#fac03d" : "#3a3a3a"),
											background: selected ? "#5f4917" : "#252525",
											color: selected ? "#ffe7ad" : "#d7d7d7",
											cursor: readOnly ? "default" : "pointer",
											opacity: readOnly ? 0.55 : 1,
										}}
									>
										{mode === "gravity" ? t("particleEditor.emitterModes.gravity", "Gravity") : t("particleEditor.emitterModes.radius", "Radius")}
									</button>
								);
							})}
						</Stack>
						<Divider sx={{ borderColor: "#2b2b2b", margin: "10px 0" }} />
						{fields.emitterMode === "gravity" ? (
							<Stack spacing={0.75}>
								<FormControlLabel control={<Checkbox size="small" checked={fields.gravity.rotationIsDir} disabled={readOnly} onChange={(event) => onUpdateField("gravity.rotationIsDir", event.target.checked, true)} sx={{ color: "#8f9aa6", "&.Mui-checked": { color: "#fac03d" } }} />} label={fieldLabel("rotationFollowsDirection", "Rotation follows direction")} sx={{ color: "#d7d7d7", "& .MuiFormControlLabel-label": { fontSize: 12 } }} />
								<NumberRow label={fieldLabel("gravityX", "Gravity X")} path="gravity.gravity.x" fields={fields} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
								<NumberRow label={fieldLabel("gravityY", "Gravity Y")} path="gravity.gravity.y" fields={fields} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
								<NumberRow label={fieldLabel("speed", "Speed")} path="gravity.speed" fields={fields} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
								<NumberRow label={fieldLabel("speedVar", "Speed Var")} path="gravity.speedVariance" fields={fields} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
								<NumberRow label={fieldLabel("radial", "Radial")} path="gravity.radialAcceleration" fields={fields} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
								<NumberRow label={fieldLabel("radialVar", "Radial Var")} path="gravity.radialAccelVariance" fields={fields} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
								<NumberRow label={fieldLabel("tangent", "Tangent")} path="gravity.tangentialAcceleration" fields={fields} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
								<NumberRow label={fieldLabel("tangentVar", "Tangent Var")} path="gravity.tangentialAccelVariance" fields={fields} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
							</Stack>
						) : (
							<Stack spacing={0.75}>
								<NumberRow label={fieldLabel("startR", "Start R")} path="radius.startRadius" fields={fields} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
								<NumberRow label={fieldLabel("startVar", "Start Var")} path="radius.startRadiusVariance" fields={fields} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
								<NumberRow
									label={fieldLabel("finishR", "Finish R")}
									path="radius.finishRadius"
									fields={fields}
									step={1}
									disabled={readOnly}
									actions={[{ label: t("particleEditor.actions.same", "Same"), tooltip: t("particleEditor.tooltips.finishRadiusSame", "Set to -1: keep radius at the start radius."), value: -1 }]}
									onUpdateField={onUpdateField}
								/>
								<NumberRow label={fieldLabel("finishVar", "Finish Var")} path="radius.finishRadiusVariance" fields={fields} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
								<NumberRow label={fieldLabel("rotate", "Rotate")} path="radius.rotatePerSecond" fields={fields} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
								<NumberRow label={fieldLabel("rotateVar", "Rotate Var")} path="radius.rotatePerSecondVariance" fields={fields} step={1} disabled={readOnly} onUpdateField={onUpdateField} />
							</Stack>
						)}
					</Box>
				</Box>
			</Box>
			<TextureResourceDialog
				open={textureDialogOpen}
				resourceBasePath={resourceBasePath}
				servedResourceBasePath={servedResourceBasePath}
				onClose={() => setTextureDialogOpen(false)}
				onSelect={(nextTexture) => {
					onSelectTexture(nextTexture, isParticleTextureImageSource(nextTexture));
				}}
				addAlert={addAlert}
			/>
		</>
	);
});
