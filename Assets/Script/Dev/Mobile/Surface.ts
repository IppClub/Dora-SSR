import { Color, DrawNode, Vec2 } from "Dora";

export interface SurfaceStyle {
	topColor: number;
	bottomColor?: number;
	borderColor?: number;
	borderWidth?: number;
	shadow?: boolean;
}

export function surfaceColor(bottom: number, top: number, fraction: number): number {
	const t = math.max(0, math.min(1, fraction));
	let result = 0;
	for (const divisor of [0x1000000, 0x10000, 0x100, 1]) {
		const a = math.floor(bottom / divisor) % 256;
		const b = math.floor(top / divisor) % 256;
		result += math.floor(a + (b - a) * t + 0.5) * divisor;
	}
	return result;
}

export function roundedSurfaceVertices(width: number, height: number, radius: number): Vec2.Type[] {
	const verts: Vec2.Type[] = [];
	const r = math.max(0, math.min(radius, width / 2, height / 2));
	for (const corner of [{x:width-r,y:r,a:-math.pi/2},{x:width-r,y:height-r,a:0},{x:r,y:height-r,a:math.pi/2},{x:r,y:r,a:math.pi}]) {
		for (let i = 0; i <= 8; i++) {
			const a = corner.a + i * math.pi / 16;
			verts.push(Vec2(corner.x + math.cos(a) * r, corner.y + math.sin(a) * r));
		}
	}
	return verts;
}

// Vertex colors provide the same vertical gradient as NanoVG, without moving
// modal backgrounds into a separate pass that can cover labels or let Feed text
// bleed through. The center fan stays entirely inside the rounded silhouette.
export function paintSurface(draw: DrawNode.Type, width: number, height: number, radius: number, style: SurfaceStyle) {
	const outline = roundedSurfaceVertices(width, height, radius);
	if (style.shadow) {
		draw.drawPolygon(outline.map(v => Vec2(v.x + 2, v.y - 3)), Color(0x52000000));
	}
	const bottom = style.bottomColor ?? style.topColor;
	const colorAt = (y: number) => Color(surfaceColor(bottom, style.topColor, height > 0 ? y / height : 0));
	const center = Vec2(width / 2, height / 2);
	const centerColor = colorAt(center.y);
	const verts: [Vec2.Type, Color.Type][] = [];
	for (let i = 0; i < outline.length; i++) {
		const a = outline[i], b = outline[(i + 1) % outline.length];
		verts.push([center, centerColor], [a, colorAt(a.y)], [b, colorAt(b.y)]);
	}
	draw.drawVertices(verts);
	if (style.borderColor !== undefined) draw.drawPolygon(outline, Color(0), style.borderWidth ?? 1, Color(style.borderColor));
}
