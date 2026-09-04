import { React } from "DoraX";
import { Color, Color3, DrawNode, Label, Node, Size, Vec2 } from "Dora";
import { RoundedSurface } from "Dev/Mobile/Visual";

const fontName = "sarasa-mono-sc-regular";

function roundedVerts(width: number, height: number, radius: number) {
	const verts: Vec2.Type[] = [];
	const r = math.max(0, math.min(radius, width / 2, height / 2));
	const corners = [
		{ x: width - r, y: r, start: -math.pi / 2 },
		{ x: width - r, y: height - r, start: 0 },
		{ x: r, y: height - r, start: math.pi / 2 },
		{ x: r, y: r, start: math.pi },
	];
	for (const corner of corners) {
		for (let step = 0; step <= 6; step++) {
			const angle = corner.start + step * math.pi / 12;
			verts.push(Vec2(corner.x + math.cos(angle) * r, corner.y + math.sin(angle) * r));
		}
	}
	return verts;
}

function createMobileNewButton(options: {
	tag: string;
	text: string;
	renderOrder?: number;
	onTapped(): void;
}) {
	const renderOrder = options.renderOrder ?? 0;
	const root = Node();
	root.tag = options.tag; root.anchor = Vec2.zero; root.size = Size(70, 44);
	root.renderOrder = renderOrder; root.touchEnabled = true; root.swallowTouches = true; root.onTapped(options.onTapped);
	const shape = DrawNode();
	shape.renderOrder = renderOrder;
	shape.drawPolygon(roundedVerts(70, 44, 22), Color(0x33151921), 0.5, Color(0xffffcc33));
	shape.addTo(root);
	const label = Label(fontName, 14, true)!;
	label.text = options.text; label.color3 = Color3(0xffffcc33); label.position = Vec2(35, 22);
	label.renderOrder = renderOrder + 1; label.addTo(root);
	return root;
}

export function MobileNewButton(props: {
	tag: string;
	x: number;
	y: number;
	text: string;
	renderOrder?: number;
	onTapped(): void;
}) {
	return <custom-node tag={props.tag} x={props.x} y={props.y} width={70} height={44}
		onCreate={() => createMobileNewButton(props)} />;
}

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
