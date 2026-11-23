import { useEffect, useId, useRef, useState } from 'react';
import { Box, Button, Container, Menu, MenuItem, Stack, Typography } from '@mui/material';
import ArrowDropDownIcon from '@mui/icons-material/ArrowDropDown';
import { Image } from 'antd';
import { MacScrollbar } from 'mac-scrollbar';
import { useTranslation } from 'react-i18next';
import { DrawerHeader } from './Frame';

function compareEdges(first: Uint8ClampedArray, last: Uint8ClampedArray) {
	let difference = 0;
	let position = 0;
	for (let i = 0; i < first.length; i += 4) {
		const alphaA = first[i + 3] / 255;
		const alphaB = last[i + 3] / 255;
		const delta = Math.max(
			Math.abs(alphaA - alphaB),
			Math.abs(first[i] * alphaA - last[i] * alphaB) / 255,
			Math.abs(first[i + 1] * alphaA - last[i + 1] * alphaB) / 255,
			Math.abs(first[i + 2] * alphaA - last[i + 2] * alphaB) / 255,
		);
		if (delta > difference) {
			difference = delta;
			position = i / 4;
		}
	}
	return { difference, position };
}

function drawPreview(canvas: HTMLCanvasElement, image: HTMLImageElement) {
	const { naturalWidth: width, naturalHeight: height } = image;
	const edge = document.createElement('canvas');
	const edgeContext = edge.getContext('2d', { willReadFrequently: true });
	const preview = canvas.getContext('2d');
	if (!width || !height || !edgeContext || !preview) throw new Error('Texture unavailable');
	const compareOppositeEdges = (alongY: boolean) => {
		const length = alongY ? height : width;
		const opposite = alongY ? width - 1 : height - 1;
		const chunkSize = 4096;
		let difference = 0;
		let position = 0;
		for (let offset = 0; offset < length; offset += chunkSize) {
			const count = Math.min(chunkSize, length - offset);
			edge.width = alongY ? 1 : count;
			edge.height = alongY ? count : 1;
			const readEdge = (side: number) => {
				edgeContext.clearRect(0, 0, edge.width, edge.height);
				const x = alongY ? side : offset;
				const y = alongY ? offset : side;
				edgeContext.drawImage(image, x, y, edge.width, edge.height, 0, 0, edge.width, edge.height);
				return edgeContext.getImageData(0, 0, edge.width, edge.height).data;
			};
			const chunk = compareEdges(readEdge(0), readEdge(opposite));
			if (chunk.difference > difference) {
				difference = chunk.difference;
				position = (offset + chunk.position + 0.5) / length;
			}
		}
		return { difference, position };
	};
	const horizontal = compareOppositeEdges(true);
	const vertical = compareOppositeEdges(false);
	const scale = Math.min(3, 320 / Math.max(width, height));
	const tileWidth = Math.max(1, Math.round(width * scale));
	const tileHeight = Math.max(1, Math.round(height * scale));
	canvas.width = 3 * tileWidth;
	canvas.height = 3 * tileHeight;
	preview.imageSmoothingEnabled = false;
	for (let row = 0; row < 3; row++) {
		for (let col = 0; col < 3; col++) {
			preview.drawImage(image, col * tileWidth, row * tileHeight, tileWidth, tileHeight);
		}
	}
	const mark = (x: number, y: number) => {
		preview.beginPath();
		preview.arc(x, y, 4, 0, 2 * Math.PI);
		preview.fillStyle = '#ffcc55';
		preview.fill();
		preview.strokeStyle = '#202020';
		preview.stroke();
	};
	for (let boundary = 1; boundary < 3; boundary++) {
		for (let tile = 0; tile < 3; tile++) {
			if (horizontal.difference > 0) mark(boundary * tileWidth, (tile + horizontal.position) * tileHeight);
			if (vertical.difference > 0) mark((tile + vertical.position) * tileWidth, boundary * tileHeight);
		}
	}
	const formatDifference = (difference: number) => {
		const percent = difference * 100;
		return percent > 0 && percent < 1 ? '<1' : String(Math.round(percent));
	};
	return {
		horizontal: formatDifference(horizontal.difference),
		vertical: formatDifference(vertical.difference),
	};
}

export default function TextureSeamChecker({ src, height }: { src: string; height: number }) {
	const { t } = useTranslation();
	const canvas = useRef<HTMLCanvasElement>(null);
	const buttonId = useId();
	const menuId = useId();
	const [menuAnchor, setMenuAnchor] = useState<HTMLButtonElement | null>(null);
	const [open, setOpen] = useState(false);
	const [result, setResult] = useState<ReturnType<typeof drawPreview> | 'error' | null>(null);
	const menuOpen = menuAnchor !== null;

	useEffect(() => {
		if (!open) return;
		setResult(null);
		const image = new window.Image();
		image.crossOrigin = 'anonymous';
		image.onload = () => {
			if (!canvas.current) return;
			try {
				setResult(drawPreview(canvas.current, image));
			} catch {
				setResult('error');
			}
		};
		image.onerror = () => setResult('error');
		image.src = src;
		return () => {
			image.onload = null;
			image.onerror = null;
		};
	}, [open, src]);

	return (
		<Box sx={{ position: 'relative', height }}>
			<MacScrollbar skin="dark" style={{ height: '100%' }}>
				<Container maxWidth="lg" sx={{ pb: 8 }}>
					<DrawerHeader />
					<Stack spacing={1} alignItems="flex-start">
						{open ? (
							<>
								<Typography variant="body2" color="text.primary" role="status">
									{result === 'error' ? t('textureSeams.failed')
										: result ? t('textureSeams.result', result) : t('textureSeams.loading')}
								</Typography>
								<Box
									component="canvas"
									ref={canvas}
									role="img"
									aria-label={t('textureSeams.preview')}
									sx={{ display: result && result !== 'error' ? 'block' : 'none', maxWidth: '100%', height: 'auto' }}
								/>
							</>
						) : <Image src={src} preview={false} />}
					</Stack>
				</Container>
			</MacScrollbar>
			<Button
				id={buttonId}
				variant="outlined"
				size="small"
				endIcon={<ArrowDropDownIcon />}
				sx={{
					position: 'absolute',
					left: 16,
					bottom: 16,
					zIndex: 1,
					bgcolor: 'background.paper',
					boxShadow: 3,
				}}
				aria-haspopup="menu"
				aria-expanded={menuOpen}
				aria-controls={menuOpen ? menuId : undefined}
				onClick={event => setMenuAnchor(event.currentTarget)}
			>
				{t('imageTools')}
			</Button>
			<Menu
				anchorEl={menuAnchor}
				open={menuOpen}
				onClose={() => setMenuAnchor(null)}
				anchorOrigin={{ vertical: 'top', horizontal: 'left' }}
				transformOrigin={{ vertical: 'bottom', horizontal: 'left' }}
				slotProps={{ list: { id: menuId, 'aria-labelledby': buttonId } }}
			>
				<MenuItem selected={open} onClick={() => {
					setOpen(true);
					setMenuAnchor(null);
				}}>
					{t('textureSeams.open')}
				</MenuItem>
				{open && (
					<MenuItem onClick={() => {
						setOpen(false);
						setMenuAnchor(null);
					}}>
						{t('textureSeams.close')}
					</MenuItem>
				)}
			</Menu>
		</Box>
	);
}
