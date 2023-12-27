/// <reference path="dora.d.ts" />

import {
	Vec2Type as Vec2,
	ColorType as Color,
	RectType as Rect,
	VGPaintType as VGPaint,
	SizeType as Size,
	Texture2DType as Texture2D
} from "dora";

declare module "nvg" {

class Transform {
	private constructor();
	identity(): void;
	translate(tx: number, ty: number): void;
	scale(sx: number, sy: number): void;
	rotate(a: number): void;
	skewX(a: number): void;
	skewY(a: number): void;
	multiply(src: Transform): void;
	inverseFrom(src: Transform): boolean;
	applyPoint(src: Vec2): Vec2;
}

export type {Transform as TransformType};

interface TransformClass {
	(this: void): Transform;
}

const transformClass: TransformClass;
export {transformClass as Transform};

export const enum LineCapMode {
	Butt = "Butt",
	Round = "Round",
	Square = "Square",
}

export const enum LineJoinMode {
	Miter = "Miter",
	Round = "Round",
	Bevel = "Bevel",
}

export const enum WindingMode {
	CW = "CW",
	CCW = "CCW",
	Solid = "Solid",
	Hole = "Hole",
}

export const enum ArcDir {
	CW = "CW",
	CCW = "CCW",
}

export const enum TextAlignMode {
	Left = "Left",
	Center = "Center",
	Right = "Right",
	Top = "Top",
	Middle = "Middle",
	Bottom = "Bottom",
	Baseline = "Baseline",
}

export const enum ImageFlag {
	Mipmaps = "Mipmaps",
	RepeatX = "RepeatX",
	RepeatY = "RepeatY",
	FlipY = "FlipY",
	Premultiplied = "Premultiplied",
	Nearest = "Nearest",
}

interface nvg {
	TouchPos(): Vec2;
	LeftButtonPressed(): boolean;
	RightButtonPressed(): boolean;
	MiddleButtonPressed(): boolean;
	MouseWheel(): number;
	Save(): void;
	Restore(): void;
	Reset(): void;
	CreateImage(w: number, h: number, filename: string, imageFlags?: ImageFlag[]): number;
	CreateFont(name: string): number;
	TextBounds(x: number, y: number, text: string, bounds: Rect): number;
	TextBoxBounds(x: number, y: number, breakRowWidth: number, text: string): Rect;
	Text(x: number, y: number, text: string): number;
	TextBox(x: number, y: number, breakRowWidth: number, text: string): void;
	StrokeColor(color: Color): void;
	StrokePaint(paint: VGPaint): void;
	FillColor(color: Color): void;
	FillPaint(paint: VGPaint): void;
	MiterLimit(limit: number): void;
	StrokeWidth(size: number): void;
	LineCap(cap: LineCapMode): void;
	LineJoin(join: LineJoinMode): void;
	GlobalAlpha(alpha: number): void;
	ResetTransform(): void;
	ApplyTransform(t: Transform): void;
	CurrentTransform(t: Transform): void;
	Translate(x: number, y: number): void;
	Rotate(angle: number): void;
	SkewX(angle: number): void;
	SkewY(angle: number): void;
	Scale(x: number, y: number): void;
	ImageSize(image: number): Size;
	DeleteImage(image: number): void;
	NVGpaLinearGradient(
		sx: number,
		sy: number,
		ex: number,
		ey: number,
		icol: Color,
		ocol: Color
	): VGPaint;
	NVGpaBoxGradient(
		x: number,
		y: number,
		w: number,
		h: number,
		r: number,
		f: number,
		icol: Color,
		ocol: Color
	): VGPaint;
	NVGpaRadialGradient(
		cx: number,
		cy: number,
		inr: number,
		outr: number,
		icol: Color,
		ocol: Color
	): VGPaint;
	NVGpaImagePattern(
		ox: number,
		oy: number,
		ex: number,
		ey: number,
		angle: number,
		image: number,
		alpha: number
	): VGPaint;
	Scissor(x: number, y: number, w: number, h: number): void;
	IntersectScissor(x: number, y: number, w: number, h: number): void;
	ResetScissor(): void;
	BeginPath(): void;
	MoveTo(x: number, y: number): void;
	LineTo(x: number, y: number): void;
	BezierTo(c1x: number, c1y: number, c2x: number, c2y: number, x: number, y: number): void;
	QuadTo(cx: number, cy: number, x: number, y: number): void;
	ArcTo(x1: number, y1: number, x2: number, y2: number, radius: number): void;
	ClosePath(): void;
	PathWinding(dir: WindingMode): void;
	Arc(cx: number, cy: number, r: number, a0: number, a1: number, dir: ArcDir): void;
	Rect(x: number, y: number, w: number, h: number): void;
	RoundedRect(x: number, y: number, w: number, h: number, r: number): void;
	RoundedRectVarying(
		x: number,
		y: number,
		w: number,
		h: number,
		radTopLeft: number,
		radTopRight: number,
		radBottomRight: number,
		radBottomLeft: number
	): void;
	Ellipse(cx: number, cy: number, rx: number, ry: number): void;
	Circle(cx: number, cy: number, r: number): void;
	Fill(): void;
	Stroke(): void;
	FindFont(name: string): number;
	AddFallbackFontId(baseFont: number, fallbackFont: number): number;
	AddFallbackFont(baseFont: string, fallbackFont: string): number;
	FontSize(size: number): void;
	FontBlur(blur: number): void;
	TextLetterSpacing(spacing: number): void;
	TextLineHeight(lineHeight: number): void;
	TextAlign(align: TextAlignMode): void;
	FontFaceId(font: number): void;
	FontFace(font: string): void;
	DoraSSR(): void;
	GetDoraSSR(scale?: number): Texture2D;
}

const nvg: nvg;
export = nvg;

} // module "nvg"
