// @preview-file on clear nolog
import { React, toNode } from 'DoraX';
import { App, Color } from 'Dora';

const themeColor = App.themeColor.toColor3();
const fillColor = Color(themeColor, 0.5 * 255).toARGB();
const bolderColor = Color(themeColor, 255).toARGB();
const size = 300;
const Rect = ({x, y, z, angleX, angleY}: {x?: number, y?: number, z?: number, angleX?: number, angleY?: number}) => {
	return (
		<draw-node x={x} y={y} z={z} angleX={angleX} angleY={angleY}>
			<rect-shape width={size} height={size} fillColor={fillColor} borderColor={bolderColor} borderWidth={2}/>
		</draw-node>
	);
};
toNode(
	<node>
		<sprite file='Image/logo.png' width={size} height={size}/>
		<Rect z={size / 2}/>
		<Rect z={-size / 2}/>
		<Rect x={size / 2} angleY={90}/>
		<Rect x={-size / 2} angleY={90}/>
		<Rect y={size / 2} angleX={90}/>
		<Rect y={-size / 2} angleX={90}/>
		<loop>
			<angle-x time={3} start={0} stop={360} />
			<angle-y time={3} start={0} stop={360} />
		</loop>
	</node>
);
