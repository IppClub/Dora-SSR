/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE. */

import { useCallback, useEffect, useRef, useState } from 'react';
import Box from '@mui/material/Box';
import IconButton from '@mui/material/IconButton';
import Tooltip from '@mui/material/Tooltip';
import Typography from '@mui/material/Typography';
import CloseIcon from '@mui/icons-material/Close';
import PauseRoundedIcon from '@mui/icons-material/PauseRounded';
import PlayArrowRoundedIcon from '@mui/icons-material/PlayArrowRounded';
import MusicNoteRoundedIcon from '@mui/icons-material/MusicNoteRounded';
import { useTranslation } from 'react-i18next';
import { Color } from './Theme';

const formatTime = (value: number) => {
	if (!Number.isFinite(value) || value < 0) return "0:00";
	const total = Math.floor(value);
	const minutes = Math.floor(total / 60);
	const seconds = total % 60;
	return `${minutes}:${seconds.toString().padStart(2, "0")}`;
};

export default function AudioPreviewCard(props: {
	title: string;
	src: string;
	playRequest: number;
	top: number;
	onClose: () => void;
}) {
	const { title, src, playRequest, top, onClose } = props;
	const { t } = useTranslation();
	const audioRef = useRef<HTMLAudioElement>(null);
	const lastSrcRef = useRef("");
	const lastPlayRequestRef = useRef(playRequest);
	const [playing, setPlaying] = useState(false);
	const [currentTime, setCurrentTime] = useState(0);
	const [duration, setDuration] = useState(0);
	const [failed, setFailed] = useState(false);

	const play = useCallback(() => {
		const audio = audioRef.current;
		if (audio === null) return;
		void audio.play().catch(() => {
			setPlaying(false);
		});
	}, []);

	useEffect(() => {
		const audio = audioRef.current;
		if (audio === null) return;
		const sourceChanged = lastSrcRef.current !== src;
		const playRequested = lastPlayRequestRef.current !== playRequest;
		lastSrcRef.current = src;
		lastPlayRequestRef.current = playRequest;
		if (sourceChanged) {
			setCurrentTime(0);
			setDuration(0);
			setFailed(false);
			audio.load();
			play();
		} else if (playRequested && audio.paused) {
			play();
		} else if (playRequested) {
			audio.pause();
		}
	}, [src, playRequest, play]);

	useEffect(() => {
		const audio = audioRef.current;
		const pauseWhenHidden = () => {
			if (document.visibilityState !== "hidden") return;
			audio?.pause();
		};
		document.addEventListener("visibilitychange", pauseWhenHidden);
		return () => {
			document.removeEventListener("visibilitychange", pauseWhenHidden);
			if (audio !== null) {
				audio.pause();
				audio.removeAttribute("src");
				audio.load();
			}
		};
	}, []);

	const togglePlayback = () => {
		const audio = audioRef.current;
		if (audio === null) return;
		if (audio.paused) play(); else audio.pause();
	};

	return (
		<Box
			role="region"
			aria-label={t("audioPreview.title")}
			sx={{
				position: "fixed",
				top,
				right: { xs: 12, sm: 16 },
				zIndex: 1200,
				width: { xs: "calc(100vw - 24px)", sm: 320 },
				maxWidth: 320,
				px: 1,
				py: 0.75,
				borderRadius: 2,
				border: `1px solid ${Color.LineStrong}`,
				backgroundColor: "rgba(22, 22, 22, 0.96)",
				boxShadow: "0 10px 28px rgba(0, 0, 0, 0.42)",
				backdropFilter: "blur(10px)",
			}}
		>
			<audio
				ref={audioRef}
				src={src}
				preload="metadata"
				onPlay={() => {
					setPlaying(true);
				}}
				onPause={() => {
					setPlaying(false);
				}}
				onTimeUpdate={(event) => setCurrentTime(event.currentTarget.currentTime)}
				onLoadedMetadata={(event) => setDuration(Number.isFinite(event.currentTarget.duration) ? event.currentTarget.duration : 0)}
				onEnded={() => {
					setPlaying(false);
				}}
				onError={() => {
					setPlaying(false);
					setFailed(true);
				}}
			/>
			<Box sx={{ display: "flex", alignItems: "center", minWidth: 0 }}>
				<Tooltip title={t(playing ? "audioPreview.pause" : "audioPreview.play")}>
					<IconButton
						size="small"
						aria-label={t(playing ? "audioPreview.pause" : "audioPreview.play")}
						onClick={togglePlayback}
						sx={{ color: Color.Theme, flexShrink: 0 }}
					>
						{playing ? <PauseRoundedIcon /> : <PlayArrowRoundedIcon />}
					</IconButton>
				</Tooltip>
				<MusicNoteRoundedIcon sx={{ ml: 0.25, mr: 0.75, fontSize: 16, color: Color.TextSecondary, flexShrink: 0 }} />
				<Typography
					variant="body2"
					title={title}
					sx={{ flex: 1, minWidth: 0, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap", color: Color.TextPrimary }}
				>
					{title}
				</Typography>
				<Tooltip title={t("action.close")}>
					<IconButton
						size="small"
						aria-label={t("action.close")}
						onClick={onClose}
						sx={{ color: Color.TextSecondary, flexShrink: 0 }}
					>
						<CloseIcon fontSize="small" />
					</IconButton>
				</Tooltip>
			</Box>
			<Box sx={{ display: "flex", alignItems: "center", gap: 1, px: 0.75, pb: 0.25 }}>
				<Box
					component="input"
					type="range"
					aria-label={t("audioPreview.seek")}
					min={0}
					max={duration > 0 ? duration : 0}
					step={0.01}
					value={Math.min(currentTime, duration > 0 ? duration : 0)}
					disabled={duration <= 0}
					onChange={(event) => {
						const next = Number(event.currentTarget.value);
						if (audioRef.current !== null && Number.isFinite(next)) {
							audioRef.current.currentTime = next;
							setCurrentTime(next);
						}
					}}
					sx={{
						flex: 1,
						minWidth: 0,
						height: 3,
						m: 0,
						accentColor: Color.Theme,
						cursor: duration > 0 ? "pointer" : "default",
					}}
				/>
				<Typography variant="caption" sx={{ color: failed ? Color.Error : Color.TextSecondary, minWidth: 70, textAlign: "right" }}>
					{failed ? t("audioPreview.failed") : `${formatTime(currentTime)} / ${formatTime(duration)}`}
				</Typography>
			</Box>
		</Box>
	);
}
