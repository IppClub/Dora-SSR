import { React } from "DoraX";
import { Color, Node, Size, Vec2 } from "Dora";
import * as nvg from "nvg";

interface RoundedSurfaceProps {
	x?: number;
	y?: number;
	width: number;
	height: number;
	radius: number;
	fillColor?: number;
	topColor?: number;
	bottomColor?: number;
	borderWidth?: number;
	borderColor?: number;
	shadow?: boolean;
	opacity?: number;
	renderOrder?: number;
}

/** NanoVG surface following Dora-Example/UIX's PaintNode + roundedPanel pattern. */
export function RoundedSurface(props: RoundedSurfaceProps) {
	const onCreate = () => {
		const node = Node();
		node.anchor = Vec2.zero;
		node.size = Size(props.width, props.height);
		node.onRender(() => {
			nvg.Save();
			nvg.ApplyTransform(node);
			const radius = math.max(0, math.min(props.radius, props.width / 2, props.height / 2));
			if (props.shadow) {
				nvg.BeginPath();
				nvg.RoundedRect(2, -3, props.width, props.height, radius);
				nvg.FillColor(Color(0x52000000));
				nvg.Fill();
			}
			nvg.BeginPath();
			nvg.RoundedRect(0, 0, props.width, props.height, radius);
			if (props.topColor !== undefined && props.bottomColor !== undefined) {
				nvg.FillPaint(nvg.LinearGradient(0, props.height, 0, 0, Color(props.topColor), Color(props.bottomColor)));
			} else {
				nvg.FillColor(Color(props.fillColor ?? 0xffffffff));
			}
			nvg.Fill();
			const borderWidth = props.borderWidth ?? 0;
			if (borderWidth > 0) {
				nvg.BeginPath();
				nvg.RoundedRect(borderWidth / 2, borderWidth / 2, props.width - borderWidth, props.height - borderWidth, math.max(0, radius - borderWidth / 2));
				nvg.StrokeWidth(borderWidth);
				nvg.StrokeColor(Color(props.borderColor ?? 0xffffffff));
				nvg.Stroke();
			}
			nvg.Restore();
			return false;
		});
		return node;
	};
	return <custom-node x={props.x ?? 0} y={props.y ?? 0} width={props.width} height={props.height} opacity={props.opacity ?? 1} renderOrder={props.renderOrder} onCreate={onCreate} />;
}

export function VerticalGradient(props: { x?: number; y?: number; width: number; height: number; topColor: number; bottomColor: number }) {
	const onCreate = () => {
		const node = Node();
		node.anchor = Vec2.zero;
		node.size = Size(props.width, props.height);
		node.onRender(() => {
			nvg.Save();
			nvg.ApplyTransform(node);
			nvg.BeginPath();
			nvg.Rect(0, 0, props.width, props.height);
			nvg.FillPaint(nvg.LinearGradient(0, props.height, 0, 0, Color(props.topColor), Color(props.bottomColor)));
			nvg.Fill();
			nvg.Restore();
			return false;
		});
		return node;
	};
	return <custom-node x={props.x ?? 0} y={props.y ?? 0} width={props.width} height={props.height} onCreate={onCreate} />;
}

function roundedRectVerts(width: number, height: number, radius: number) {
	const r = math.max(0, math.min(radius, width / 2, height / 2));
	const verts: Vec2.Type[] = [];
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

/** Stencil-only rounded path for clipping sprites and other scene nodes. */
export function RoundedStencil(props: { width: number; height: number; radius: number }) {
	return <draw-node><polygon-shape verts={roundedRectVerts(props.width, props.height, props.radius)} fillColor={0xffffffff} /></draw-node>;
}
