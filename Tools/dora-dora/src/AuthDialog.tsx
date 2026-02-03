import React from 'react';

import {
	Box,
	Dialog,
	DialogActions,
	DialogContent,
	DialogTitle,
	TextField,
	Typography,
	CircularProgress,
} from '@mui/material';
import {ThemeProvider} from '@mui/material/styles';
import {theme as authTheme, Color} from './Theme';
import {useTranslation} from 'react-i18next';
import * as Service from './Service';

export type AuthDialogProps = {
	origFetch: typeof window.fetch;
	onToken: (token: string) => void;
};

type PinInputProps = {
	length?: number;
	value: string;
	onChange: (value: string) => void;
	onComplete?: (value: string) => void;
	disabled?: boolean;
	error?: boolean;
	helperText?: string;
	autoFocus?: boolean;
};

const PinInput = ({
	length = 6,
	value,
	onChange,
	onComplete,
	disabled,
	error,
	helperText,
	autoFocus,
}: PinInputProps) => {
	const inputsRef = React.useRef<Array<HTMLInputElement | null>>([]);
	const values = React.useMemo(() => {
		const trimmed = (value || '').replace(/\D/g, '').slice(0, length);
		return Array.from({length}, (_, index) => trimmed[index] || '');
	}, [value, length]);

	React.useEffect(() => {
		if (value === '') {
			focusIndex(0);
		}
	}, [value]);

	const focusIndex = (index: number) => {
		const target = inputsRef.current[index];
		if (target) {
			target.focus();
			target.select();
		}
	};

	const emitChange = (nextValue: string) => {
		const sanitized = nextValue.replace(/\D/g, '').slice(0, length);
		onChange(sanitized);
		if (sanitized.length === length && onComplete) {
			onComplete(sanitized);
		}
	};

	const handleChange = (index: number, nextRaw: string) => {
		if (disabled) return;
		const digits = nextRaw.replace(/\D/g, '');
		if (!digits) {
			const next = values.slice();
			next[index] = '';
			emitChange(next.join(''));
			return;
		}
		const next = values.slice();
		let cursor = index;
		for (const char of digits) {
			if (cursor >= length) break;
			next[cursor] = char;
			cursor += 1;
		}
		emitChange(next.join(''));
		if (cursor < length) {
			focusIndex(cursor);
		} else {
			focusIndex(length - 1);
		}
	};

	const handleKeyDown = (index: number, event: React.KeyboardEvent<HTMLDivElement>) => {
		if (disabled) return;
		if (event.key === 'Backspace' && !values[index] && index > 0) {
			focusIndex(index - 1);
		}
		if (event.key === 'ArrowLeft' && index > 0) {
			event.preventDefault();
			focusIndex(index - 1);
		}
		if (event.key === 'ArrowRight' && index < length - 1) {
			event.preventDefault();
			focusIndex(index + 1);
		}
	};

	const handlePaste = (event: React.ClipboardEvent<HTMLInputElement>) => {
		if (disabled) return;
		const text = event.clipboardData.getData('Text');
		if (!text) return;
		event.preventDefault();
		const digits = text.replace(/\D/g, '');
		if (!digits) return;
		emitChange(digits);
		const nextIndex = Math.min(digits.length, length) - 1;
		if (nextIndex >= 0) {
			focusIndex(nextIndex);
		}
	};

	return (
		<Box>
			<Box sx={{display: 'flex', gap: 1, justifyContent: 'space-between'}}>
				{Array.from({length}, (_, index) => (
					<TextField
						key={index}
						inputRef={(node) => {
							inputsRef.current[index] = node;
						}}
						autoComplete="off"
						autoFocus={autoFocus && index === 0}
						value={values[index]}
						onChange={(event) => handleChange(index, event.target.value)}
						onKeyDown={(event) => handleKeyDown(index, event)}
						onPaste={handlePaste}
						disabled={disabled}
						error={error}
						size="small"
						slotProps={{
							htmlInput: {
								inputMode: 'numeric',
								style: {textAlign: 'center', fontSize: 18, fontWeight: 600},
							},
						}}
						sx={{
							width: 44,
							'& .MuiOutlinedInput-root': {
								borderRadius: 2,
							},
							"& .MuiInputBase-root": {
								backgroundColor: Color.BackgroundDark,
							},
							"& .MuiOutlinedInput-notchedOutline": {
								borderColor: Color.Line,
							},
							"&:hover .MuiOutlinedInput-notchedOutline": {
								borderColor: Color.TextSecondary,
							},
						}}
					/>
				))}
			</Box>
			<Typography
				variant="caption"
				sx={{
					color: error ? 'error.main' : 'text.secondary',
					minHeight: 20,
					mt: 1,
					display: 'block',
				}}
			>
				{helperText || ' '}
			</Typography>
		</Box>
	);
};

const AuthDialog = ({origFetch, onToken}: AuthDialogProps) => {
	const {t} = useTranslation();
	const [code, setCode] = React.useState('');
	const [error, setError] = React.useState('');
	const [busy, setBusy] = React.useState(false);
	const [lockedUntil, setLockedUntil] = React.useState(0);
	const [secondsLeft, setSecondsLeft] = React.useState(0);

	React.useEffect(() => {
		if (!lockedUntil) return;
		const tick = () => {
			const diff = Math.max(0, Math.ceil((lockedUntil - Date.now()) / 1000));
			setSecondsLeft(diff);
			if (diff === 0) {
				setLockedUntil(0);
			}
		};
		tick();
		const timer = window.setInterval(tick, 1000);
		return () => window.clearInterval(timer);
	}, [lockedUntil]);

	const handleSubmit = async (overrideCode?: string) => {
		const nextCode = (overrideCode ?? code).trim();
		if (!nextCode || busy || secondsLeft > 0) return;
		setBusy(true);
		setError('');
		try {
			const res = await origFetch(Service.addr('/auth'), {
				method: 'POST',
				headers: {'Content-Type': 'application/json'},
				body: JSON.stringify({code: nextCode}),
			});
			if (!res.ok) {
				setError(t('auth.error.authFailed'));
				setCode('');
				return;
			}
			const data = await res.json().catch(() => null);
			if (data && data.success && data.token) {
				onToken(data.token as string);
				return;
			}
			if (data && data.message === 'locked' && data.retryAfter) {
				const retryAfter = Number(data.retryAfter) || 30;
				setLockedUntil(Date.now() + retryAfter * 1000);
				setError(t('auth.error.tooManyAttempts', {seconds: retryAfter}));
				setCode('');
				return;
			}
			setError(t('auth.error.codeInvalid'));
			setCode('');
		} finally {
			setBusy(false);
		}
	};

	return (
		<ThemeProvider theme={authTheme}>
			<Dialog
				open
				disableEscapeKeyDown
				onClose={() => null}
				slotProps={{
					paper: {
						sx: {
							borderRadius: 3,
							maxWidth: 400,
							paddingBottom: 1,
							boxShadow: '0 18px 60px rgba(19,31,68,0.2)',
						},
					},
				}}
			>
				<DialogTitle variant='h6' sx={{pb: 0.5, fontWeight: 700}}>
					{t('auth.title')}
				</DialogTitle>
				<DialogContent sx={{pt: 1.5}}>
					<Typography variant="body2" sx={{color: 'text.secondary', mb: 2}}>
						{t('auth.description')}
					</Typography>
					<PinInput
						autoFocus
						value={code}
						onChange={setCode}
						onComplete={(value) => void handleSubmit(value)}
						disabled={busy || secondsLeft > 0}
						error={Boolean(error)}
						helperText={error || ' '}
					/>
					{secondsLeft > 0 ? (
						<Typography variant="caption" sx={{color: 'text.secondary'}}>
							{t('auth.waitRetry', {seconds: secondsLeft})}
						</Typography>
					) : null}
				</DialogContent>
				{busy ? (
					<DialogActions sx={{px: 3, pb: 2}}>
						<Box sx={{flex: 1}} />
						<Box sx={{display: 'flex', alignItems: 'center', gap: 1}}>
							<CircularProgress size={16} />
							<Typography variant="body2" sx={{color: 'text.secondary'}}>
								{t('auth.verifying')}
							</Typography>
						</Box>
					</DialogActions>
				) : null}
			</Dialog>
		</ThemeProvider>
	);
};

export default AuthDialog;
