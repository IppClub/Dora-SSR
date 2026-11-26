import { useEffect, useRef, useState } from 'react';
import { Box, Button, Dialog, DialogActions, DialogContent, DialogTitle, Slider, Stack, Typography } from '@mui/material';
import Cropper, { type Area } from 'react-easy-crop';
import 'react-easy-crop/react-easy-crop.css';

export default function AtomPieCoverCrop({source, label, onClose, onConfirm}: {
	source: File | string;
	label: (zh: string, en: string) => string;
	onClose: () => void;
	onConfirm: (file: File) => void;
}) {
	const [url, setUrl] = useState('');
	const [position, setPosition] = useState({x:0, y:0});
	const [zoom, setZoom] = useState(1);
	const [area, setArea] = useState<Area>();
	const imageRef = useRef<React.RefObject<HTMLImageElement> | null>(null);
	const [busy, setBusy] = useState(false);
	const [error, setError] = useState(false);
	useEffect(() => {
		const url = typeof source === 'string' ? source : URL.createObjectURL(source);
		setUrl(url);
		return () => { if (typeof source !== 'string') URL.revokeObjectURL(url); };
	}, [source]);

	async function confirm() {
		const image = imageRef.current?.current;
		if (!area || !image || busy) return;
		setBusy(true);
		setError(false);
		try {
			const canvas = document.createElement('canvas');
			canvas.width = 1600;
			canvas.height = 900;
			const ctx = canvas.getContext('2d');
			if (!ctx) throw new Error('canvas');
			ctx.fillStyle = '#fff';
			ctx.fillRect(0, 0, canvas.width, canvas.height);
			ctx.imageSmoothingQuality = 'high';
			ctx.drawImage(image, area.x, area.y, area.width, area.height, 0, 0, canvas.width, canvas.height);
			const jpg = await new Promise<Blob | null>(resolve => canvas.toBlob(resolve, 'image/jpeg', 0.9));
			if (!jpg) throw new Error('jpeg');
			onConfirm(new File([jpg], 'banner.jpg', {type:'image/jpeg'}));
		} catch { setError(true); }
		finally { setBusy(false); }
	}
	return <Dialog open fullWidth maxWidth="sm" aria-labelledby="ap-crop-title" onClose={() => {if (!busy) onClose();}}>
		<DialogTitle id="ap-crop-title">{label('裁剪作品封面','Crop cover')}</DialogTitle>
		<DialogContent>
			<Box sx={{height:'clamp(160px, 38vh, 340px)', position:'relative', bgcolor:'#111', borderRadius:1, overflow:'hidden'}}>
				{url && <Cropper image={url} aspect={16/9} crop={position} zoom={zoom} maxZoom={3}
					onCropChange={setPosition} onZoomChange={setZoom} onCropComplete={(_, pixels) => setArea(pixels)}
					setImageRef={ref => {imageRef.current = ref;}} disableAutomaticStylesInjection
					mediaProps={{onError:() => setError(true), alt:label('待裁剪图片','Image to crop')}} />}
			</Box>
			<Typography variant="caption" color="text.secondary">{label('拖动图片调整构图','Drag to reframe')} · 1600 × 900</Typography>
			<Stack direction="row" alignItems="center" spacing={2} sx={{mt:1}}>
				<Typography variant="body2">{label('缩放','Zoom')}</Typography>
				<Slider aria-label={label('缩放','Zoom')} min={1} max={3} step={0.01} value={zoom} disabled={!area || busy}
					onChange={(_, value) => setZoom(Number(value))} />
			</Stack>
			{error && <Typography color="error" role="alert">{label('无法处理这张图片，请重新选择。','Unable to process this image. Please choose another.')}</Typography>}
		</DialogContent>
		<DialogActions>
			<Button disabled={busy} onClick={onClose}>{label('取消','Cancel')}</Button>
			<Button variant="contained" disabled={!area || busy} onClick={confirm}>{label('确认裁剪','Apply crop')}</Button>
		</DialogActions>
	</Dialog>;
}
