import { SpinePlayer as Spine, SkeletonBinary, ManagedWebGLRenderingContext, AssetManager, AtlasAttachmentLoader, TextureAtlas } from '@esotericsoftware/spine-player';
import { useLayoutEffect, useRef } from 'react';
import '@esotericsoftware/spine-player/dist/spine-player.css';
import { Color } from './Frame';
import * as Service from './Service';
import Info from './Info';
import { useTranslation } from 'react-i18next';

export interface SpinePlayerProps {
	skelFile: string;
	atlasFile: string;
	onLoadFailed: (message: string) => void;
};

const SpinePlayer = (props: SpinePlayerProps) => {
	const {skelFile, atlasFile} = props;
	const skelUrl = Service.addr("/" + skelFile.replace("\\", "/"));
	const atlasUrl = Service.addr("/" + atlasFile.replace("\\", "/"));
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
						let binary = new SkeletonBinary(new AtlasAttachmentLoader(atlas));
						try {
							const skeletonData = binary.readSkeletonData(binaryData);
							const animations = skeletonData.animations.map(a => a.name);
							let animation: string | undefined = undefined;
							if (animations.indexOf("idle") > 0) {
								animation = "idle";
							}
							player = new Spine(currentPlayer, {
								backgroundColor: Color.BackgroundSecondary,
								animation,
								animations,
								preserveDrawingBuffer: false,
								binaryUrl: skelUrl,
								atlasUrl: atlasUrl,
								premultipliedAlpha: false,
								showControls: true,
							});
						} catch {
							props.onLoadFailed(t("spine.load", {file: Info.path.basename(skelFile)}));
						} finally {
							assetManager.dispose();
						}
					}, (_path, _message) => {
						props.onLoadFailed(t("spine.load", {file: Info.path.basename(skelFile)}));
					});
				});
			}).catch((_message) => {
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
};

export default SpinePlayer;
