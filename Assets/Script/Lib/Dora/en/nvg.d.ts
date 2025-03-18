/// <reference path="Dora.d.ts" />

declare module "nvg" {
import {
	Vec2,
	Color,
	Rect,
	VGPaint,
	Size,
	Texture2D,
	Node
} from "Dora";

type Vec2 = Vec2.Type;
type Color = Color.Type;
type Rect = Rect.Type;
type VGPaint = VGPaint.Type;
type Size = Size.Type;
type Texture2D = Texture2D.Type;

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

export const enum TextHAlign {
	Left = "Left",
	Center = "Center",
	Right = "Right",
}

export const enum TextVAlign {
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

export function Save(this: void): void;
export function Restore(this: void): void;
export function Reset(this: void): void;
export function CreateImage(this: void, w: number, h: number, filename: string, imageFlags?: ImageFlag[]): number;
export function CreateFont(this: void, name: string): number;
export function TextBounds(this: void, x: number, y: number, text: string, bounds: Rect): number;
export function TextBoxBounds(this: void, x: number, y: number, breakRowWidth: number, text: string): Rect;
export function Text(this: void, x: number, y: number, text: string): number;
export function TextBox(this: void, x: number, y: number, breakRowWidth: number, text: string): void;
export function StrokeColor(this: void, color: number): void;
export function StrokeColor(this: void, color: Color): void;
export function StrokePaint(this: void, paint: VGPaint): void;
export function FillColor(this: void, color: number): void;
export function FillColor(this: void, color: Color): void;
export function FillPaint(this: void, paint: VGPaint): void;
export function MiterLimit(this: void, limit: number): void;
export function StrokeWidth(this: void, size: number): void;
export function LineCap(this: void, cap: LineCapMode): void;
export function LineJoin(this: void, join: LineJoinMode): void;
export function GlobalAlpha(this: void, alpha: number): void;
export function ResetTransform(this: void): void;
export function ApplyTransform(this: void, node: Node.Type): void;
export function Translate(this: void, x: number, y: number): void;
export function Rotate(this: void, angle: number): void;
export function SkewX(this: void, angle: number): void;
export function SkewY(this: void, angle: number): void;
export function Scale(this: void, x: number, y: number): void;
export function ImageSize(this: void, image: number): Size;
export function DeleteImage(this: void, image: number): void;
export function LinearGradient(
	this: void,
	sx: number,
	sy: number,
	ex: number,
	ey: number,
	icol: Color,
	ocol: Color
): VGPaint;
export function BoxGradient(
	this: void,
	x: number,
	y: number,
	w: number,
	h: number,
	r: number,
	f: number,
	icol: Color,
	ocol: Color
): VGPaint;
export function RadialGradient(
	this: void,
	cx: number,
	cy: number,
	inr: number,
	outr: number,
	icol: Color,
	ocol: Color
): VGPaint;
export function ImagePattern(
	this: void,
	ox: number,
	oy: number,
	ex: number,
	ey: number,
	angle: number,
	image: number,
	alpha: number
): VGPaint;
export function Scissor(this: void, x: number, y: number, w: number, h: number): void;
export function IntersectScissor(this: void, x: number, y: number, w: number, h: number): void;
export function ResetScissor(this: void): void;
export function BeginPath(this: void): void;
export function MoveTo(this: void, x: number, y: number): void;
export function LineTo(this: void, x: number, y: number): void;
export function BezierTo(this: void, c1x: number, c1y: number, c2x: number, c2y: number, x: number, y: number): void;
export function QuadTo(this: void, cx: number, cy: number, x: number, y: number): void;
export function ArcTo(this: void, x1: number, y1: number, x2: number, y2: number, radius: number): void;
export function ClosePath(this: void): void;
export function PathWinding(this: void, dir: WindingMode): void;
export function Arc(this: void, cx: number, cy: number, r: number, a0: number, a1: number, dir: ArcDir): void;
function Rectangle(this: void, x: number, y: number, w: number, h: number): void;
export {Rectangle as Rect};
export function RoundedRect(this: void, x: number, y: number, w: number, h: number, r: number): void;
export function RoundedRectVarying(
	this: void,
	x: number,
	y: number,
	w: number,
	h: number,
	radTopLeft: number,
	radTopRight: number,
	radBottomRight: number,
	radBottomLeft: number
): void;
export function Ellipse(this: void, cx: number, cy: number, rx: number, ry: number): void;
export function Circle(this: void, cx: number, cy: number, r: number): void;
export function Fill(this: void): void;
export function Stroke(this: void): void;
export function FindFont(this: void, name: string): number;
export function AddFallbackFontId(this: void, baseFont: number, fallbackFont: number): number;
export function AddFallbackFont(this: void, baseFont: string, fallbackFont: string): number;
export function FontSize(this: void, size: number): void;
export function FontBlur(this: void, blur: number): void;
export function TextLetterSpacing(this: void, spacing: number): void;
export function TextLineHeight(this: void, lineHeight: number): void;
export function TextAlign(this: void, hAlign: TextHAlign, vAlign: TextVAlign): void;
export function FontFaceId(this: void, font: number): void;
export function FontFace(this: void, font: string): void;
export function DoraSSR(this: void): void;
export function GetDoraSSR(this: void, scale?: number): Texture2D;

} // module "nvg"
