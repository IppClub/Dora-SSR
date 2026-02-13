/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import { SpinePlayer as Spine, SkeletonBinary, ManagedWebGLRenderingContext, AssetManager, AtlasAttachmentLoader, TextureAtlas } from '@esotericsoftware/spine-player';
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
	const {skelFile, atlasFile} = props;
	const skelUrl = Service.addr("/" + skelFile.replace(/\\/g, "/"));
	const atlasUrl = Service.addr("/" + atlasFile.replace(/\\/g, "/"));
	const playerRef = useRef<HTMLDivElement>(null);
	const canvasRef = useRef<HTMLCanvasElement>(null);
	const {t} = useTranslation();

	useLayoutEffect(() => {
		let player: Spine | null = null;
		if (canvasRef.current && playerRef.current) {
			const currentPlayer = playerRef.current;
			const context = new ManagedWebGLRenderingContext(canvasRef.current, {
				preserveDrawingBuffer: false
			});
			const assetManager = new AssetManager(context, "");
			new Promise((resolve: (atlas: TextureAtlas) => void, reject: (reason: string) => void) => {
				assetManager.loadTextureAtlas(atlasUrl, (_path, atlas) => {
					resolve(atlas);
				}, (_path, message) => {
					reject(message);
				});
			}).then((atlas) => {
				return new Promise(() => {
					assetManager.loadBinary(skelUrl, (_path, binaryData) => {
						const binary = new SkeletonBinary(new AtlasAttachmentLoader(atlas));
						try {
							const skeletonData = binary.readSkeletonData(binaryData);
							const animations = skeletonData.animations.map(a => a.name);
							let animation: string | undefined;
							if (animations.indexOf("idle") > 0) {
								animation = "idle";
							}
							player = new Spine(currentPlayer, {
								backgroundColor: Color.BackgroundDark,
								animation,
								animations,
								preserveDrawingBuffer: false,
								binaryUrl: skelUrl,
								atlasUrl: atlasUrl,
								premultipliedAlpha: false,
								showControls: true,
							});
						} catch (error) {
							console.error(error);
							props.onLoadFailed(t("spine.load", {file: Info.path.basename(skelFile)}));
						} finally {
							assetManager.dispose();
						}
					}, (_path, message) => {
						console.error(message);
						props.onLoadFailed(t("spine.load", {file: Info.path.basename(skelFile)}));
					});
				});
			}).catch((message) => {
				console.error(message);
				props.onLoadFailed(t("spine.load", {file: Info.path.basename(atlasFile)}));
			})
		}
		return () => {
			if (player) {
				player.dispose();
			}
		};
		// eslint-disable-next-line
	}, []);

	return <div ref={playerRef} style={{height: '80vh'}}>
		<canvas ref={canvasRef} hidden/>
	</div>;
});

export default SpinePlayer;
