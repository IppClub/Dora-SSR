local Vec2 = require("Vec2").Type
local Rect = require("Rect").Type
local Size = require("Size").Type
local Color = require("Color").Type
local VGPaint = require("VGPaint").Type
local record Transform
	indentity: function(self: Transform)
	translate: function(self: Transform, tx: number, ty: number)
	scale: function(self: Transform, sx: number, sy: number)
	rotate: function(self: Transform, a: number)
	skewX: function(self: Transform, a: number)
	skewY: function(self: Transform, a: number)
	multiply: function(self: Transform, src: Transform)
	inverseFrom: function(self: Transform, src: Transform): boolean
	applyPoint: function(self: Transform, src: Vec2): Vec2
end
local record TransformClass
	type Type = Transform
	metamethod __call: function(cls: TransformClass): Transform
end
local record nvg
	enum LineCapMode
		"Butt"
		"Round"
		"Square"
	end
	enum LineJoinMode
		"Miter"
		"Round"
		"Bevel"
	end
	enum WindingMode
		"CW"
		"CCW"
		"Solid"
		"Hole"
	end
	enum ArcDir
		"CW"
		"CCW"
	end
	enum TextAlignMode
		"Left"
		"Center"
		"Right"
		"Top"
		"Middle"
		"Bottom"
		"Baseline"
	end
	enum ImageFlag
		"Mipmaps"
		"RepeatX"
		"RepeatY"
		"FlipY"
		"Premultiplied"
		"Nearest"
	end
	Transform: TransformClass
	TouchPos: function(): Vec2
	LeftButtonPressed: function(): boolean
	RightButtonPressed: function(): boolean
	MiddleButtonPressed: function(): boolean
	MouseWheel: function(): number
	Save: function()
	Restore: function()
	Reset: function()
	CreateImage: function(w: integer, h: integer, filename: string, imageFlags: {ImageFlag}): integer
	CreateImage: function(w: integer, h: integer, filename: string): integer
	CreateFont: function(name: string): integer
	TextBounds: function(x: number, y: number, text: string, bounds: Rect): number
	TextBoxBounds: function(x: number, y: number, breakRowWidth: number, text: string): Rect
	Text: function(x: number, y: number, text: string): number
	TextBox: function(x: number, y: number, breakRowWidth: number, text: string)
	StrokeColor: function(color: Color)
	StrokePaint: function(paint: VGPaint)
	FillColor: function(color: Color)
	FillPaint: function(paint: VGPaint)
	MiterLimit: function(limit: number)
	StrokeWidth: function(size: number)
	LineCap: function(cap: LineCapMode)
	LineJoin: function(join: LineJoinMode)
	GlobalAlpha: function(alpha: number)
	ResetTransform: function()
	ApplyTransform: function(t: Transform)
	CurrentTransform: function(t: Transform)
	Translate: function(x: number, y: number)
	Rotate: function(angle: number)
	SkewX: function(angle: number)
	SkewY: function(angle: number)
	Scale: function(x: number, y: number)
	ImageSize: function(image: integer): Size
	DeleteImage: function(image: integer)
	NVGpaLinearGradient: function(sx: number, sy: number, ex: number, ey: number, icol: Color, ocol: Color): VGPaint
	NVGpaBoxGradient: function(x: number, y: number, w: number, h: number, r: number, f: number, icol: Color, ocol: Color): VGPaint
	NVGpaRadialGradient: function(cx: number, cy: number, inr: number, outr: number, icol: Color, ocol: Color): VGPaint
	NVGpaImagePattern: function(ox: number, oy: number, ex: number, ey: number, angle: number, image: integer, alpha: number): VGPaint
	Scissor: function(x: number, y: number, w: number, h: number)
	IntersectScissor: function(x: number, y: number, w: number, h: number)
	ResetScissor: function()
	BeginPath: function()
	MoveTo: function(x: number, y: number)
	LineTo: function(x: number, y: number)
	BezierTo: function(c1x: number, c1y: number, c2x: number, c2y: number, x: number, y: number)
	QuadTo: function(cx: number, cy: number, x: number, y: number)
	ArcTo: function(x1: number, y1: number, x2: number, y2: number, radius: number)
	ClosePath: function()
	PathWinding: function(dir: WindingMode)
	Arc: function(cx: number, cy: number, r: number, a0: number, a1: number, dir: ArcDir)
	Rect: function(x: number, y: number, w: number, h: number)
	RoundedRect: function(x: number, y: number, w: number, h: number, r: number)
	RoundedRectVarying: function(x: number, y: number, w: number, h: number, radTopLeft: number, radTopRight: number, radBottomRight: number, radBottomLeft: number)
	Ellipse: function(cx: number, cy: number, rx: number, ry: number)
	Circle: function(cx: number, cy: number, r: number)
	Fill: function()
	Stroke: function()
	FindFont: function(name: string): integer
	AddFallbackFontId: function(baseFont: integer, fallbackFont: integer): integer
	AddFallbackFont: function(baseFont: string, fallbackFont: string): integer
	FontSize: function(size: number)
	FontBlur: function(blur: number)
	TextLetterSpacing: function(spacing: number)
	TextLineHeight: function(lineHeight: number)
	TextAlign: function(align: TextAlignMode)
	FontFaceId: function(font: integer)
	FontFace: function(font: string)
	DorothySSR: function()
	DorothySSRWhite: function()
	DorothySSRHappy: function()
	DorothySSRHappyWhite: function()
end
print(nvg.TouchPos)
print(nvg.TextBoxBounds())
print(nvg.ImageSize())
local nvg_: nvg
return nvg_
