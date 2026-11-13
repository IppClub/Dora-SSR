import { React } from "DoraX";
import { DrawNode } from "Dora";
import { paintSurface, type SurfaceStyle } from "Dev/Mobile/Surface";

export function NativeRoundedSurface(props: SurfaceStyle & {width: number; height: number; radius: number; renderOrder?: number}) {
	return <custom-node renderOrder={props.renderOrder} onCreate={() => {
		const draw = DrawNode();
		paintSurface(draw, props.width, props.height, props.radius, props);
		return draw;
	}} />;
}

export function NativePanelSurface(props: {width: number; height: number; renderOrder?: number}) {
	return <NativeRoundedSurface {...props} radius={24} topColor={0xff242d3c} bottomColor={0xff111620} borderColor={0xff4a5568} shadow={true} />;
}

export function NativeButton(props: {tag?: string; x: number; y: number; width: number; height?: number; text: string; fontSize?: number; primary?: boolean; renderOrder?: number; onTapped(): void}) {
	const height = props.height ?? 48;
	return <node tag={props.tag} x={props.x} y={props.y} width={props.width} height={height} anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true} onTapped={props.onTapped}>
		<NativeRoundedSurface width={props.width} height={height} radius={14} renderOrder={props.renderOrder}
			topColor={props.primary ? 0xffffdf6b : 0xff293140} bottomColor={props.primary ? 0xffffbd2e : 0xff1b202b}
			borderColor={props.primary ? 0xffffdd63 : 0xff343b48} shadow={props.primary} />
		<label x={props.width / 2} y={height / 2} renderOrder={0} fontName="sarasa-mono-sc-regular" fontSize={props.fontSize ?? 17} text={props.text} color3={props.primary ? 0x17130a : 0xf4f1e8} />
	</node>;
}
