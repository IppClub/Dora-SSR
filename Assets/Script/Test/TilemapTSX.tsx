// @preview-file on
import { React, toNode, useRef } from 'DoraX';
import {TextureFilter, App, TileNode} from 'Dora';

const scale = 1 / App.devicePixelRatio;
const tileNodeRef = useRef<TileNode.Type>();

toNode(
	<align-node windowRoot onTapMoved={(touch) => {
			if (tileNodeRef.current) {
				tileNodeRef.current.position = tileNodeRef.current.position.add(touch.delta);
			}
		}}>
		<tile-node ref={tileNodeRef} file='TMX/platform.tmx' filter={TextureFilter.Point}/>
	</align-node>
);