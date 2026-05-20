export type BodyIconName =
	| "menu"
	| "rect"
	| "disk"
	| "poly"
	| "chain"
	| "joint"
	| "delete"
	| "play"
	| "stop"
	| "origin"
	| "zoom"
	| "fixX"
	| "fixY";

export const BODY_TOOL_ICON_NAMES: readonly BodyIconName[] = [
	"menu",
	"rect",
	"disk",
	"poly",
	"chain",
	"joint",
	"delete",
	"play",
	"stop",
	"origin",
	"zoom",
	"fixX",
	"fixY",
];

const stroke = (ctx: CanvasRenderingContext2D, color: string, width = 2) => {
	ctx.strokeStyle = color;
	ctx.lineWidth = width;
	ctx.lineCap = "round";
	ctx.lineJoin = "round";
};

export const drawBodyIcon = (
	ctx: CanvasRenderingContext2D,
	name: BodyIconName,
	x: number,
	y: number,
	size: number,
	color = "#d7d7d7",
) => {
	const unit = size / 24;
	const cx = x + size / 2;
	const cy = y + size / 2;
	ctx.save();
	stroke(ctx, color, Math.max(1.5, 2 * unit));
	ctx.fillStyle = color;
	ctx.beginPath();
	switch (name) {
		case "menu":
			for (let i = 0; i < 3; i++) {
				const yy = y + (7 + i * 5) * unit;
				ctx.moveTo(x + 5 * unit, yy);
				ctx.lineTo(x + 19 * unit, yy);
			}
			ctx.stroke();
			break;
		case "rect":
			ctx.rect(x + 5 * unit, y + 6 * unit, 14 * unit, 12 * unit);
			ctx.stroke();
			break;
		case "disk":
			ctx.arc(cx, cy, 7 * unit, 0, Math.PI * 2);
			ctx.stroke();
			break;
		case "poly":
			ctx.moveTo(cx, y + 4 * unit);
			ctx.lineTo(x + 20 * unit, y + 11 * unit);
			ctx.lineTo(x + 16 * unit, y + 20 * unit);
			ctx.lineTo(x + 6 * unit, y + 17 * unit);
			ctx.closePath();
			ctx.stroke();
			break;
		case "chain":
			ctx.moveTo(x + 4 * unit, y + 16 * unit);
			ctx.lineTo(x + 9 * unit, y + 8 * unit);
			ctx.lineTo(x + 15 * unit, y + 15 * unit);
			ctx.lineTo(x + 20 * unit, y + 7 * unit);
			ctx.stroke();
			for (const point of [[4, 16], [9, 8], [15, 15], [20, 7]]) {
				ctx.beginPath();
				ctx.arc(x + point[0] * unit, y + point[1] * unit, 2 * unit, 0, Math.PI * 2);
				ctx.fill();
			}
			break;
		case "joint":
			ctx.arc(x + 8 * unit, cy, 4 * unit, 0, Math.PI * 2);
			ctx.moveTo(x + 12 * unit, cy);
			ctx.lineTo(x + 16 * unit, cy);
			ctx.moveTo(x + 16 * unit, cy);
			ctx.arc(x + 18 * unit, cy, 4 * unit, Math.PI, Math.PI * 3);
			ctx.stroke();
			break;
		case "delete":
			ctx.moveTo(x + 7 * unit, y + 7 * unit);
			ctx.lineTo(x + 17 * unit, y + 17 * unit);
			ctx.moveTo(x + 17 * unit, y + 7 * unit);
			ctx.lineTo(x + 7 * unit, y + 17 * unit);
			ctx.stroke();
			break;
		case "play":
			ctx.moveTo(x + 8 * unit, y + 5 * unit);
			ctx.lineTo(x + 19 * unit, cy);
			ctx.lineTo(x + 8 * unit, y + 19 * unit);
			ctx.closePath();
			ctx.fill();
			break;
		case "stop":
			ctx.rect(x + 7 * unit, y + 7 * unit, 10 * unit, 10 * unit);
			ctx.fill();
			break;
		case "origin":
			ctx.arc(cx, cy, 7 * unit, 0, Math.PI * 2);
			ctx.moveTo(cx - 10 * unit, cy);
			ctx.lineTo(cx + 10 * unit, cy);
			ctx.moveTo(cx, cy - 10 * unit);
			ctx.lineTo(cx, cy + 10 * unit);
			ctx.stroke();
			break;
		case "zoom":
			ctx.arc(x + 10 * unit, y + 10 * unit, 5 * unit, 0, Math.PI * 2);
			ctx.moveTo(x + 14 * unit, y + 14 * unit);
			ctx.lineTo(x + 20 * unit, y + 20 * unit);
			ctx.stroke();
			break;
		case "fixX":
			ctx.moveTo(x + 5 * unit, cy);
			ctx.lineTo(x + 19 * unit, cy);
			ctx.moveTo(x + 15 * unit, y + 8 * unit);
			ctx.lineTo(x + 19 * unit, cy);
			ctx.lineTo(x + 15 * unit, y + 16 * unit);
			ctx.stroke();
			break;
		case "fixY":
			ctx.moveTo(cx, y + 5 * unit);
			ctx.lineTo(cx, y + 19 * unit);
			ctx.moveTo(x + 8 * unit, y + 15 * unit);
			ctx.lineTo(cx, y + 19 * unit);
			ctx.lineTo(x + 16 * unit, y + 15 * unit);
			ctx.stroke();
			break;
	}
	ctx.restore();
};
