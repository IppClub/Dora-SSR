import { React } from "DoraX";
import { RoundedSurface } from "Dev/Mobile/Visual";

const fontName = "sarasa-mono-sc-regular";

export function MobileButton(props: {
	tag?: string;
	x: number;
	y: number;
	width: number;
	text: string;
	fontSize?: number;
	primary?: boolean;
	danger?: boolean;
	renderOrder?: number;
	onTapped(): void;
}) {
	// Keep the NanoVG surface above the panel surface even when callers use the
	// panel's render order for the button container.
	const surfaceRenderOrder = (props.renderOrder ?? 0) + 1;
	return <node tag={props.tag} x={props.x} y={props.y} anchorX={0} anchorY={0}
		width={props.width} height={48} renderOrder={props.renderOrder}
		touchEnabled={true} swallowTouches={true} onTapped={props.onTapped}>
		<RoundedSurface width={props.width} height={48} radius={14} renderOrder={surfaceRenderOrder}
			topColor={props.danger ? 0xffff8585 : props.primary ? 0xffffdf6b : 0xff293140}
			bottomColor={props.danger ? 0xffdf4e56 : props.primary ? 0xffffbd2e : 0xff1b202b}
			borderWidth={1} borderColor={props.danger ? 0xffff6b6b : props.primary ? 0xffffdd63 : 0xff343b48} shadow={props.primary || props.danger} />
		<label x={props.width / 2} y={24} fontName={fontName}
			fontSize={props.fontSize ?? 17} text={props.text}
			color3={props.primary ? 0x17130a : 0xf4f1e8} />
	</node>;
}

export function MobilePanelSurface(props: { width: number; height: number; renderOrder?: number }) {
	return <RoundedSurface width={props.width} height={props.height} radius={24}
			topColor={0xff242d3c} bottomColor={0xff111620}
			borderWidth={1} borderColor={0xff4a5568} shadow={true} renderOrder={props.renderOrder} />;
}
