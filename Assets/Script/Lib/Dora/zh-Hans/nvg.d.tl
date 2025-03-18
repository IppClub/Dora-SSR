local Rect = require("Rect").Type
local Size = require("Size").Type
local Color = require("Color").Type
local VGPaint = require("VGPaint").Type
local Texture2D = require("Texture2D").Type
local Node = require("Node").Type
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
	enum TextHAlign
		"Left"
		"Center"
		"Right"
	end
	enum TextVAlign
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
	Save: function()
	Restore: function()
	Reset: function()
	CreateImage: function(w: integer, h: integer, filename: string, imageFlags?: {ImageFlag}): integer
	CreateFont: function(name: string): integer
	TextBounds: function(x: number, y: number, text: string, bounds: Rect): number
	TextBoxBounds: function(x: number, y: number, breakRowWidth: number, text: string): Rect
	Text: function(x: number, y: number, text: string): number
	TextBox: function(x: number, y: number, breakRowWidth: number, text: string)
	StrokeColor: function(color: integer)
	StrokeColor: function(color: Color)
	StrokePaint: function(paint: VGPaint)
	FillColor: function(color: integer)
	FillColor: function(color: Color)
	FillPaint: function(paint: VGPaint)
	MiterLimit: function(limit: number)
	StrokeWidth: function(size: number)
	LineCap: function(cap: LineCapMode)
	LineJoin: function(join: LineJoinMode)
	GlobalAlpha: function(alpha: number)
	ResetTransform: function()
	ApplyTransform: function(node: Node)
	Translate: function(x: number, y: number)
	Rotate: function(angle: number)
	SkewX: function(angle: number)
	SkewY: function(angle: number)
	Scale: function(x: number, y: number)
	ImageSize: function(image: integer): Size
	DeleteImage: function(image: integer)
	LinearGradient: function(sx: number, sy: number, ex: number, ey: number, icol: Color, ocol: Color): VGPaint
	BoxGradient: function(x: number, y: number, w: number, h: number, r: number, f: number, icol: Color, ocol: Color): VGPaint
	RadialGradient: function(cx: number, cy: number, inr: number, outr: number, icol: Color, ocol: Color): VGPaint
	ImagePattern: function(ox: number, oy: number, ex: number, ey: number, angle: number, image: integer, alpha: number): VGPaint
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
	TextAlign: function(hAlign: TextHAlign, vAlign: TextVAlign)
	FontFaceId: function(font: integer)
	FontFace: function(font: string)
	DoraSSR: function()
	GetDoraSSR: function(scale?: number --[[1.0]]): Texture2D
end
local nvg_: nvg
return nvg_
