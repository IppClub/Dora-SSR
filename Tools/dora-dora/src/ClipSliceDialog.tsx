import { Button, Dialog, DialogActions, DialogContent, DialogTitle, TextField } from "@mui/material";
import type { SxProps, Theme } from "@mui/material/styles";
import { memo, useEffect, useMemo, useRef, useState } from "react";
import type { ActionClipRect } from "./ActionEditor/ActionClip";

export const ClipSliceThumbnail = memo(function ClipSliceThumbnail(props: {
	image: HTMLImageElement | null;
	rect: ActionClipRect;
}) {
	const { image, rect } = props;
	const ref = useRef<HTMLCanvasElement | null>(null);
	useEffect(() => {
		const canvas = ref.current;
		const context = canvas?.getContext("2d");
		if (!canvas || !context) return;
		const ratio = window.devicePixelRatio || 1;
		const size = 54;
		canvas.width = size * ratio;
		canvas.height = size * ratio;
		canvas.style.width = `${size}px`;
		canvas.style.height = `${size}px`;
		context.setTransform(ratio, 0, 0, ratio, 0, 0);
		context.clearRect(0, 0, size, size);
		context.fillStyle = "#181818";
		context.fillRect(0, 0, size, size);
		if (!image || rect.width <= 0 || rect.height <= 0) return;
		const scale = Math.min((size - 8) / rect.width, (size - 8) / rect.height);
		const width = rect.width * scale;
		const height = rect.height * scale;
		context.drawImage(image, rect.x, rect.y, rect.width, rect.height, (size - width) / 2, (size - height) / 2, width, height);
	}, [image, rect]);
	return <canvas ref={ref} aria-hidden="true" style={{ border: "1px solid #3a3a3a", background: "#181818" }} />;
});

const defaultSelectedBorder = "#fac03d";
const defaultSelectedBackground = "#5f4917";

const ClipSliceDialog = memo(function ClipSliceDialog(props: {
	open: boolean;
	title: string;
	clipLabel: string;
	rects: ActionClipRect[];
	atlasImage: HTMLImageElement | null;
	filterPlaceholder: string;
	noSlicesText: string;
	cancelText: string;
	selectedRectName?: string;
	selectedBorderColor?: string;
	selectedBackground?: string;
	contentHeight?: number;
	paperSx?: SxProps<Theme>;
	onClose: () => void;
	onSelect: (rect: ActionClipRect) => void;
}) {
	const {
		open,
		title,
		clipLabel,
		rects,
		atlasImage,
		filterPlaceholder,
		noSlicesText,
		cancelText,
		selectedRectName,
		selectedBorderColor = defaultSelectedBorder,
		selectedBackground = defaultSelectedBackground,
		contentHeight,
		paperSx,
		onClose,
		onSelect,
	} = props;
	const [filter, setFilter] = useState("");
	useEffect(() => {
		if (open) setFilter("");
	}, [open]);
	const visibleRects = useMemo(() => {
		const query = filter.trim().toLowerCase();
		return query === "" ? rects : rects.filter((rect) => rect.name.toLowerCase().includes(query));
	}, [filter, rects]);
	return (
		<Dialog open={open} onClose={onClose} fullWidth maxWidth="md" PaperProps={paperSx ? { sx: paperSx } : undefined}>
			<DialogTitle>{title}</DialogTitle>
			<DialogContent sx={{ display: "flex", flexDirection: "column", gap: 1.25, background: "#181818" }}>
				<div style={{ color: "#8f9aa6", fontSize: 12, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis" }}>{clipLabel}</div>
				<TextField size="small" value={filter} onChange={(event) => setFilter(event.currentTarget.value)} placeholder={filterPlaceholder} />
				<div style={{ minHeight: contentHeight ?? 260, maxHeight: 420, height: contentHeight, overflow: "auto" }}>
					{visibleRects.length === 0 ? (
						<div style={{ color: "#8f9aa6", padding: 12 }}>{noSlicesText}</div>
					) : (
						<div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(150px, 1fr))", gap: 8 }}>
							{visibleRects.map((rect) => {
								const selected = rect.name === selectedRectName;
								return (
									<button
										key={rect.name}
										type="button"
										onClick={() => onSelect(rect)}
										style={{
											display: "flex",
											alignItems: "center",
											gap: 8,
											padding: 8,
											minHeight: 72,
											border: selected ? `1px solid ${selectedBorderColor}` : "1px solid #3a3a3a",
											background: selected ? selectedBackground : "#252525",
											color: "#d7d7d7",
											cursor: "pointer",
											textAlign: "left",
										}}
									>
										<ClipSliceThumbnail image={atlasImage} rect={rect} />
										<div style={{ minWidth: 0 }}>
											<div style={{ fontSize: 12, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{rect.name}</div>
											<div style={{ fontSize: 10, color: "#8f9aa6" }}>{rect.width} x {rect.height}</div>
										</div>
									</button>
								);
							})}
						</div>
					)}
				</div>
			</DialogContent>
			<DialogActions>
				<Button onClick={onClose}>{cancelText}</Button>
			</DialogActions>
		</Dialog>
	);
});

export default ClipSliceDialog;
