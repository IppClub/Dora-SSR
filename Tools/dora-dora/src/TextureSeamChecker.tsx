import { useEffect, useRef, useState } from 'react';
import { Box, Button, Stack, Typography } from '@mui/material';
import { Image } from 'antd';
import { useTranslation } from 'react-i18next';

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
			position = (i + 2) / first.length;
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
	const readEdge = (x: number, y: number, w: number, h: number) => {
		edge.width = Math.min(w, 4096);
		edge.height = Math.min(h, 4096);
		edgeContext.drawImage(image, x, y, w, h, 0, 0, edge.width, edge.height);
		return edgeContext.getImageData(0, 0, edge.width, edge.height).data;
	};
	const horizontal = compareEdges(readEdge(0, 0, 1, height), readEdge(width - 1, 0, 1, height));
	const vertical = compareEdges(readEdge(0, 0, width, 1), readEdge(0, height - 1, width, 1));
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
	return {
		horizontal: Math.round(horizontal.difference * 100),
		vertical: Math.round(vertical.difference * 100),
	};
}

export default function TextureSeamChecker({ src }: { src: string }) {
	const { t } = useTranslation();
	const canvas = useRef<HTMLCanvasElement>(null);
	const [open, setOpen] = useState(false);
	const [result, setResult] = useState<ReturnType<typeof drawPreview> | 'error' | null>(null);

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
		<Stack spacing={1} alignItems="flex-start">
			<Button variant="outlined" size="small" onClick={() => setOpen(!open)} aria-pressed={open}>
				{t(open ? 'textureSeams.close' : 'textureSeams.open')}
			</Button>
			{open ? (
				<>
					<Typography variant="body2" role="status">
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
	);
}
