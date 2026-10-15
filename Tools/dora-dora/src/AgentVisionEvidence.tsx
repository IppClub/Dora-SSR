import React from 'react';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Collapse from '@mui/material/Collapse';
import Dialog from '@mui/material/Dialog';
import DialogContent from '@mui/material/DialogContent';
import DialogTitle from '@mui/material/DialogTitle';
import Stack from '@mui/material/Stack';
import Typography from '@mui/material/Typography';
import { useTranslation } from 'react-i18next';
import { getAgentVisionImageByPath, type AgentSessionStep, type AgentVisionImageResult } from './Service';
import { Color } from './Theme';
import Markdown from './Markdown';

function VisionImage({sessionId, path}: {sessionId: number; path: string}) {
	const {t} = useTranslation();
	const container = React.useRef<HTMLDivElement>(null);
	const [visible, setVisible] = React.useState(false);
	const [source, setSource] = React.useState('');
	const [message, setMessage] = React.useState('');
	const [caption, setCaption] = React.useState('');
	const [opened, setOpened] = React.useState(false);
	React.useEffect(() => {
		const element = container.current;
		if (!element) return;
		const observer = new IntersectionObserver(entries => {
			if (entries.some(entry => entry.isIntersecting)) { setVisible(true); observer.disconnect(); }
		});
		observer.observe(element);
		return () => observer.disconnect();
	}, []);
	React.useEffect(() => {
		if (!visible) return;
		let active = true;
		setSource(''); setMessage('');
		const apply = (result: AgentVisionImageResult) => {
			if (!active) return;
			if (result.success && result.dataUrl?.startsWith('data:image/')) {
				setSource(result.dataUrl);
				setCaption(`${result.path ?? path}${result.width !== undefined ? ` · ${result.width}×${result.height}` : ''}`);
			} else {
				setMessage(t('agent.vision.unavailable'));
			}
		};
		getAgentVisionImageByPath(sessionId, path).then(apply).catch(() => { if (active) setMessage(t('agent.vision.loadFailed')); });
		return () => { active = false; };
	}, [sessionId, path, visible, t]);
	const title = t('agent.vision.title');
	return <Box ref={container} sx={{minWidth: 100, maxWidth: 220}}>
		{source ? <Button onClick={() => setOpened(true)} aria-label={t('agent.vision.enlarge')} sx={{p: 0}}>
			<Box component="img" src={source} alt={title} sx={{maxWidth: '100%', height: 140, objectFit: 'contain', borderRadius: 1}} />
		</Button> : <Typography variant="caption" sx={{color: Color.TextSecondary}}>{message || t('agent.vision.loading')}</Typography>}
		{caption !== '' && <Typography variant="caption" component="div" sx={{color: Color.TextSecondary, overflowWrap: 'anywhere'}}>{caption}</Typography>}
		<Dialog open={opened} onClose={() => setOpened(false)} maxWidth="lg" fullWidth>
			<DialogTitle>{title}<Button onClick={() => setOpened(false)} sx={{float: 'right'}}>{t('agent.vision.close')}</Button></DialogTitle>
			<DialogContent><Box component="img" src={source} alt={title} sx={{display: 'block', maxWidth: '100%', maxHeight: '80vh', objectFit: 'contain', mx: 'auto'}} /></DialogContent>
		</Dialog>
	</Box>;
}

function collectImageRefs(step: AgentSessionStep): string[] {
	const result = step.result;
	const refs: string[] = [];
	// previewGame runs inside execute_command; mine its printed result for capture paths.
	if (step.tool === 'execute_command' && typeof result?.output === 'string') {
		const seen = new Set<string>();
		for (const match of result.output.matchAll(/\.agent\/vision\/[A-Za-z0-9_-]+\.png/g)) {
			if (!seen.has(match[0])) { seen.add(match[0]); refs.push(match[0]); }
		}
		return refs.slice(0, 3);
	}
	if (Array.isArray(result?.images)) {
		for (const value of result.images as unknown[]) {
			if (value && typeof value === 'object' && typeof (value as {path?: unknown}).path === 'string') {
				const path = (value as {path: string}).path;
				if (path.trim() !== '') refs.push(path);
			}
		}
	}
	return refs.slice(0, 3);
}

export default function AgentVisionEvidence({step}: {step: AgentSessionStep}) {
	const {t} = useTranslation();
	const [capturesOpen, setCapturesOpen] = React.useState(false);
	if (step.tool !== 'analyze_image' && step.tool !== 'execute_command') return null;
	const result = step.result;
	const refs = collectImageRefs(step);
	const report = typeof result?.report === 'string' ? result.report : '';
	const model = typeof result?.model === 'string' ? result.model : '';
	const questionParam = step.params?.question;
	const question = typeof questionParam === 'string' ? questionParam : '';
	return <Stack spacing={1} sx={{mt: 1}}>
		{question !== '' && (
			<Stack spacing={0.25}>
				<Typography variant="caption" sx={{color: Color.TextSecondary}}>{t('agent.vision.questionLabel')}</Typography>
				<Typography sx={{color: Color.TextPrimary, whiteSpace: 'pre-wrap', fontSize: 15, lineHeight: 1.7}}>{question}</Typography>
			</Stack>
		)}
		{report && (
			<Stack spacing={0.25}>
				<Typography variant="caption" sx={{color: Color.TextSecondary}}>{t('agent.vision.reportLabel')}</Typography>
				<Box
					sx={{
						width: '100%',
						maxWidth: '100%',
						minWidth: 0,
						color: Color.TextPrimary,
						fontSize: 14,
						lineHeight: 1.65,
						'& .markdown-body p': {whiteSpace: 'pre-wrap'},
						'& .markdown-body > :first-of-type': {marginTop: 0},
						'& .markdown-body > :last-child': {marginBottom: 0},
					}}
				>
					<Markdown content={report} contentPadding={0} inheritTypography />
				</Box>
			</Stack>
		)}
		{model && <Typography variant="caption" sx={{color: Color.TextSecondary}}>{t('agent.vision.modelLabel')}: {model}</Typography>}
		{refs.length > 0 && (
			<Box>
				<Button
					size="small"
					variant="text"
					onClick={() => setCapturesOpen(prev => !prev)}
					sx={{
						px: 0,
						minWidth: 0,
						color: Color.TextSecondary,
						textTransform: "none",
						"&:hover": {
							backgroundColor: "transparent",
							color: Color.TextPrimary,
						},
					}}
				>
					{capturesOpen ? "▾" : "▸"} {capturesOpen ? t('agent.vision.hideCaptures') : t('agent.vision.showCaptures', {count: refs.length})}
				</Button>
				{/* Captures load only after the section is expanded. */}
				<Collapse in={capturesOpen} timeout="auto" unmountOnExit>
					<Stack sx={{mt: 1, spacing: 1}}>
						<Stack direction="row" spacing={1} useFlexGap flexWrap="wrap">
							{refs.map(imagePath => <VisionImage key={imagePath} sessionId={step.sessionId} path={imagePath} />)}
						</Stack>
						<Typography variant="caption" sx={{color: Color.TextSecondary}}>{t('agent.vision.note')}</Typography>
					</Stack>
				</Collapse>
			</Box>
		)}
	</Stack>;
}
