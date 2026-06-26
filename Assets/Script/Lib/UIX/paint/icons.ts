import { Color } from "Dora";
import * as nvg from "nvg";
import type { PaintContext } from "UIX/paint/PaintNode";
import type { Rect } from "UIX/types";

export type IconPainter = (this: void, ctx: PaintContext, rect: Rect, color: number) => void;

function lineIcon(this: void, points: number[], rect: Rect, color: number, width: number) {
	nvg.BeginPath();
	for (let i of $range(1, points.length / 2)) {
		const x = rect.x + points[(i - 1) * 2] * rect.width;
		const y = rect.y + points[(i - 1) * 2 + 1] * rect.height;
		if (i === 1) nvg.MoveTo(x, y);
		else nvg.LineTo(x, y);
	}
	nvg.StrokeWidth(width);
	nvg.StrokeColor(Color(color));
	nvg.Stroke();
}

export const iconPainters: Record<string, IconPainter> = {
	play(_ctx, r, color) {
		nvg.BeginPath();
		nvg.MoveTo(r.x + r.width * 0.32, r.y + r.height * 0.22);
		nvg.LineTo(r.x + r.width * 0.32, r.y + r.height * 0.78);
		nvg.LineTo(r.x + r.width * 0.78, r.y + r.height * 0.5);
		nvg.ClosePath();
		nvg.FillColor(Color(color));
		nvg.Fill();
	},
	close(_ctx, r, color) {
		lineIcon([0.25, 0.25, 0.75, 0.75], r, color, 2);
		lineIcon([0.75, 0.25, 0.25, 0.75], r, color, 2);
	},
	gear(_ctx, r, color) {
		nvg.BeginPath();
		nvg.Circle(r.x + r.width / 2, r.y + r.height / 2, math.min(r.width, r.height) * 0.32);
		nvg.StrokeWidth(2);
		nvg.StrokeColor(Color(color));
		nvg.Stroke();
		nvg.BeginPath();
		nvg.Circle(r.x + r.width / 2, r.y + r.height / 2, math.min(r.width, r.height) * 0.11);
		nvg.FillColor(Color(color));
		nvg.Fill();
	},
	coin(_ctx, r, color) {
		nvg.BeginPath();
		nvg.Circle(r.x + r.width / 2, r.y + r.height / 2, math.min(r.width, r.height) * 0.38);
		nvg.FillColor(Color(color));
		nvg.Fill();
		nvg.BeginPath();
		nvg.Circle(r.x + r.width / 2, r.y + r.height / 2, math.min(r.width, r.height) * 0.24);
		nvg.StrokeWidth(2);
		nvg.StrokeColor(Color(0x55000000));
		nvg.Stroke();
	},
	heart(_ctx, r, color) {
		nvg.BeginPath();
		nvg.MoveTo(r.x + r.width * 0.5, r.y + r.height * 0.78);
		nvg.BezierTo(r.x + r.width * 0.18, r.y + r.height * 0.55, r.x + r.width * 0.15, r.y + r.height * 0.25, r.x + r.width * 0.36, r.y + r.height * 0.25);
		nvg.BezierTo(r.x + r.width * 0.46, r.y + r.height * 0.25, r.x + r.width * 0.5, r.y + r.height * 0.36, r.x + r.width * 0.5, r.y + r.height * 0.36);
		nvg.BezierTo(r.x + r.width * 0.5, r.y + r.height * 0.36, r.x + r.width * 0.54, r.y + r.height * 0.25, r.x + r.width * 0.64, r.y + r.height * 0.25);
		nvg.BezierTo(r.x + r.width * 0.85, r.y + r.height * 0.25, r.x + r.width * 0.82, r.y + r.height * 0.55, r.x + r.width * 0.5, r.y + r.height * 0.78);
		nvg.FillColor(Color(color));
		nvg.Fill();
	},
	mana(_ctx, r, color) {
		nvg.BeginPath();
		nvg.MoveTo(r.x + r.width * 0.5, r.y + r.height * 0.12);
		nvg.BezierTo(r.x + r.width * 0.28, r.y + r.height * 0.42, r.x + r.width * 0.2, r.y + r.height * 0.58, r.x + r.width * 0.5, r.y + r.height * 0.86);
		nvg.BezierTo(r.x + r.width * 0.8, r.y + r.height * 0.58, r.x + r.width * 0.72, r.y + r.height * 0.42, r.x + r.width * 0.5, r.y + r.height * 0.12);
		nvg.FillColor(Color(color));
		nvg.Fill();
	},
	lock(_ctx, r, color) {
		nvg.BeginPath();
		nvg.RoundedRect(r.x + r.width * 0.25, r.y + r.height * 0.44, r.width * 0.5, r.height * 0.38, 3);
		nvg.FillColor(Color(color));
		nvg.Fill();
		nvg.BeginPath();
		nvg.Arc(r.x + r.width * 0.5, r.y + r.height * 0.45, r.width * 0.22, math.pi, math.pi * 2, nvg.ArcDir.CW);
		nvg.StrokeWidth(2);
		nvg.StrokeColor(Color(color));
		nvg.Stroke();
	},
	check(_ctx, r, color) {
		lineIcon([0.22, 0.52, 0.42, 0.72, 0.78, 0.28], r, color, 3);
	},
	warning(_ctx, r, color) {
		nvg.BeginPath();
		nvg.MoveTo(r.x + r.width * 0.5, r.y + r.height * 0.16);
		nvg.LineTo(r.x + r.width * 0.86, r.y + r.height * 0.82);
		nvg.LineTo(r.x + r.width * 0.14, r.y + r.height * 0.82);
		nvg.ClosePath();
		nvg.StrokeWidth(2);
		nvg.StrokeColor(Color(color));
		nvg.Stroke();
	},
	arrow(_ctx, r, color) {
		lineIcon([0.25, 0.5, 0.75, 0.5, 0.55, 0.3, 0.75, 0.5, 0.55, 0.7], r, color, 2);
	},
};

export function drawIcon(this: void, name: string, ctx: PaintContext, rect: Rect, color: number): void {
	nvg.Save();
	nvg.Translate(rect.x, rect.y + rect.height);
	nvg.Scale(1, -1);
	const drawRect = { x: 0, y: 0, width: rect.width, height: rect.height };
	const painter = iconPainters[name];
	if (painter !== undefined) {
		painter(ctx, drawRect, color);
		nvg.Restore();
		return;
	}
	nvg.BeginPath();
	nvg.RoundedRect(2, 2, rect.width - 4, rect.height - 4, 3);
	nvg.StrokeWidth(2);
	nvg.StrokeColor(Color(color));
	nvg.Stroke();
	nvg.Restore();
}
