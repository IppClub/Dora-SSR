/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { SpinePlayer as Spine } from '@esotericsoftware/spine-player';
import { memo, useLayoutEffect, useRef } from 'react';
import '@esotericsoftware/spine-player/dist/spine-player.css';
import { Color } from './Theme';
import * as Service from './Service';
import Info from './Info';
import { useTranslation } from 'react-i18next';

export interface SpinePlayerProps {
	skelFile: string;
	atlasFile: string;
	onLoadFailed: (message: string) => void;
};

const SpinePlayer = memo((props: SpinePlayerProps) => {
	const { skelFile, atlasFile } = props;
	const skelUrl = Service.addr("/" + skelFile.replace(/\\/g, "/"));
	const atlasUrl = Service.addr("/" + atlasFile.replace(/\\/g, "/"));
	const playerRef = useRef<HTMLDivElement>(null);
	const { t } = useTranslation();

	useLayoutEffect(() => {
		let player: Spine | null = null;
		let loadFailed = false;
		const reportLoadFailed = (file: string, error?: unknown) => {
			if (loadFailed) return;
			loadFailed = true;
			if (error) console.error(error);
			props.onLoadFailed(t("spine.load", { file: Info.path.basename(file) }));
		};
		if (playerRef.current) {
			const currentPlayer = playerRef.current;
			try {
				player = new Spine(currentPlayer, {
					backgroundColor: Color.BackgroundDark,
					preserveDrawingBuffer: false,
					skeleton: skelUrl,
					atlasUrl: atlasUrl,
					premultipliedAlpha: false,
					showControls: true,
					success: (player) => {
						if (player.skeleton?.data.findAnimation("idle")) {
							player.setAnimation("idle");
						}
					},
					error: (_player, message) => {
						reportLoadFailed(message.includes("atlas") ? atlasFile : skelFile, message);
					},
				});
			} catch (error) {
				reportLoadFailed(skelFile, error);
			}
		}
		return () => {
			if (player) {
				player.dispose();
			}
		};
		// eslint-disable-next-line
	}, []);

	return <div ref={playerRef} style={{ height: '80vh' }} />;
});

export default SpinePlayer;
