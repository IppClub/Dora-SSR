/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Render/VGRender.h"

#include "Basic/Application.h"
#include "Basic/Content.h"
#include "Basic/Director.h"
#include "Node/Node.h"
#include "Render/View.h"
#include "Support/Common.h"

#include "bimg/decode.h"
#include "nanovg/nanovg_bgfx.h"

NS_DORA_BEGIN

NVGcontext* nvg::_currentContext = nullptr;

void nvg::Save() {
	nvgSave(Context());
}

void nvg::Restore() {
	nvgRestore(Context());
}

void nvg::Reset() {
	nvgReset(Context());
}

int nvg::CreateImage(int w, int h, String filename, Slice* imageFlags, int flagCount) {
	uint32_t flags = 0;
	for (int i = 0; i < flagCount; i++) {
		switch (Switch::hash(imageFlags[i])) {
			case "Mipmaps"_hash: flags |= NVG_IMAGE_GENERATE_MIPMAPS; break;
			case "RepeatX"_hash: flags |= NVG_IMAGE_REPEATX; break;
			case "RepeatY"_hash: flags |= NVG_IMAGE_REPEATY; break;
			case "FlipY"_hash: flags |= NVG_IMAGE_FLIPY; break;
			case "Premultiplied"_hash: flags |= NVG_IMAGE_PREMULTIPLIED; break;
			case "Nearest"_hash: flags |= NVG_IMAGE_NEAREST; break;
			default:
				Issue("nvg image flag named \"{}\" is invalid.", imageFlags[i].toString());
				break;
		}
	}
	auto data = SharedContent.load(filename);
	bx::DefaultAllocator allocator;
	bimg::ImageContainer* imageContainer = bimg::imageParse(&allocator, data.first.get(), s_cast<uint32_t>(data.second), bimg::TextureFormat::RGBA8);
	int result = nvgCreateImageRGBA(Context(), w, h, s_cast<int>(flags), r_cast<uint8_t*>(imageContainer->m_data));
	bimg::imageFree(imageContainer);
	return result;
}

int nvg::CreateImage(int w, int h, String filename, int imageFlags) {
	auto data = SharedContent.load(filename);
	bx::DefaultAllocator allocator;
	bimg::ImageContainer* imageContainer = bimg::imageParse(&allocator, data.first.get(), s_cast<uint32_t>(data.second), bimg::TextureFormat::RGBA8);
	int result = nvgCreateImageRGBA(Context(), w, h, imageFlags, r_cast<uint8_t*>(imageContainer->m_data));
	bimg::imageFree(imageContainer);
	return result;
}

int nvg::CreateFont(String name) {
	return nvgCreateFont(Context(), name.c_str(), name.c_str());
}

float nvg::TextBounds(float x, float y, String text, Dora::Rect& bounds) {
	float bds[4]{};
	float result = nvgTextBounds(Context(), x, y, text.begin(), text.end(), bds);
	bounds.setLeft(bds[0]);
	bounds.setTop(bds[1]);
	bounds.setRight(bds[2]);
	bounds.setBottom(bds[3]);
	return result;
}

Rect nvg::TextBoxBounds(float x, float y, float breakRowWidth, String text) {
	Dora::Rect bounds;
	float bds[4]{};
	nvgTextBoxBounds(Context(), x, y, breakRowWidth, text.begin(), text.end(), bds);
	bounds.setLeft(bds[0]);
	bounds.setTop(bds[1]);
	bounds.setRight(bds[2]);
	bounds.setBottom(bds[3]);
	return bounds;
}

float nvg::Text(float x, float y, String text) {
	return nvgText(Context(), x, y, text.begin(), text.end());
}

void nvg::TextBox(float x, float y, float breakRowWidth, String text) {
	nvgTextBox(Context(), x, y, breakRowWidth, text.begin(), text.end());
}

void nvg::StrokeColor(Color color) {
	nvgStrokeColor(Context(), nvgColor(color));
}

void nvg::StrokeColor(uint32_t color) {
	nvgStrokeColor(Context(), nvgColor(Color(color)));
}

void nvg::StrokePaint(const NVGpaint& paint) {
	nvgStrokePaint(Context(), paint);
}

void nvg::FillColor(Color color) {
	nvgFillColor(Context(), nvgColor(color));
}

void nvg::FillColor(uint32_t color) {
	nvgFillColor(Context(), nvgColor(Color(color)));
}

void nvg::FillPaint(const NVGpaint& paint) {
	nvgFillPaint(Context(), paint);
}

void nvg::MiterLimit(float limit) {
	nvgMiterLimit(Context(), limit);
}

void nvg::StrokeWidth(float size) {
	nvgStrokeWidth(Context(), size);
}

void nvg::LineCap(String cap) {
	int value = NVG_BUTT;
	switch (Switch::hash(cap)) {
		case "Butt"_hash: value = NVG_BUTT; break;
		case "Round"_hash: value = NVG_ROUND; break;
		case "Square"_hash: value = NVG_SQUARE; break;
		case ""_hash: break;
		default:
			Error("nvg::LineCap param cap must be one of: Butt, Round, Square.");
			break;
	}
	nvgLineCap(Context(), value);
}

void nvg::LineCap(int cap) {
	nvgLineCap(Context(), cap);
}

void nvg::LineJoin(String join) {
	int value = NVG_MITER;
	switch (Switch::hash(join)) {
		case "Miter"_hash: value = NVG_MITER; break;
		case "Round"_hash: value = NVG_ROUND; break;
		case "Bevel"_hash: value = NVG_BEVEL; break;
		case ""_hash: break;
		default:
			Error("nvg::LineCap param cap must be one of: Miter, Round, Bevel.");
			break;
	}
	nvgLineJoin(Context(), value);
}

void nvg::LineJoin(int join) {
	nvgLineJoin(Context(), join);
}

void nvg::GlobalAlpha(float alpha) {
	nvgGlobalAlpha(Context(), alpha);
}

void nvg::ResetTransform() {
	nvgResetTransform(Context());
}

void nvg::CurrentTransform(Transform& t) {
	nvgCurrentTransform(Context(), t);
}

void nvg::ApplyTransform(const Transform& t) {
	nvgTransform(Context(), t.t[0], t.t[1], t.t[2], t.t[3], t.t[4], t.t[5]);
}

void nvg::ApplyTransform(NotNull<Node, 1> node) {
	auto size = SharedApplication.getVisualSize();
	auto scale = SharedApplication.getDevicePixelRatio() / SharedView.getScale();
	auto transform = AffineTransform::Indentity;
	transform.translate(size.width / 2, size.height / 2);
	transform.scale(1.0f / scale, -1.0f / scale);
	const auto& world = node->getWorld();
	transform.concat({world.m[0], world.m[1], world.m[4], world.m[5], world.m[12], world.m[13]});
	nvgSetTransform(Context(), &transform.a);
}

void nvg::Translate(float x, float y) {
	nvgTranslate(Context(), x, y);
}

void nvg::Rotate(float angle) {
	nvgRotate(Context(), bx::toRad(angle));
}

void nvg::SkewX(float angle) {
	nvgSkewX(Context(), bx::toRad(angle));
}

void nvg::SkewY(float angle) {
	nvgSkewY(Context(), bx::toRad(angle));
}

void nvg::Scale(float x, float y) {
	nvgScale(Context(), x, y);
}

Size nvg::ImageSize(int image) {
	int w, h;
	nvgImageSize(Context(), image, &w, &h);
	return Size{s_cast<float>(w), s_cast<float>(h)};
}

void nvg::DeleteImage(int image) {
	nvgDeleteImage(Context(), image);
}

NVGpaint nvg::LinearGradient(float sx, float sy, float ex, float ey, Color icol, Color ocol) {
	return nvgLinearGradient(Context(), sx, sy, ex, ey, nvgColor(icol), nvgColor(ocol));
}

NVGpaint nvg::BoxGradient(float x, float y, float w, float h, float r, float f, Color icol, Color ocol) {
	return nvgBoxGradient(Context(), x, y, w, h, r, f, nvgColor(icol), nvgColor(ocol));
}

NVGpaint nvg::RadialGradient(float cx, float cy, float inr, float outr, Color icol, Color ocol) {
	return nvgRadialGradient(Context(), cx, cy, inr, outr, nvgColor(icol), nvgColor(ocol));
}

NVGpaint nvg::ImagePattern(float ox, float oy, float ex, float ey, float angle, int image, float alpha) {
	return nvgImagePattern(Context(), ox, oy, ex, ey, angle, image, alpha);
}

void nvg::Scissor(float x, float y, float w, float h) {
	nvgScissor(Context(), x, y, w, h);
}

void nvg::IntersectScissor(float x, float y, float w, float h) {
	nvgIntersectScissor(Context(), x, y, w, h);
}

void nvg::ResetScissor() {
	nvgResetScissor(Context());
}

void nvg::BeginPath() {
	nvgBeginPath(Context());
}

void nvg::MoveTo(float x, float y) {
	nvgMoveTo(Context(), x, y);
}

void nvg::LineTo(float x, float y) {
	nvgLineTo(Context(), x, y);
}

void nvg::BezierTo(float c1x, float c1y, float c2x, float c2y, float x, float y) {
	nvgBezierTo(Context(), c1x, c1y, c2x, c2y, x, y);
}

void nvg::QuadTo(float cx, float cy, float x, float y) {
	nvgQuadTo(Context(), cx, cy, x, y);
}

void nvg::ArcTo(float x1, float y1, float x2, float y2, float radius) {
	nvgArcTo(Context(), x1, y1, x2, y2, radius);
}

void nvg::ClosePath() {
	nvgClosePath(Context());
}

void nvg::PathWinding(String dir) {
	int value = NVG_CCW;
	switch (Switch::hash(dir)) {
		case "CW"_hash: value = NVG_CW; break;
		case "CCW"_hash: value = NVG_CCW; break;
		case "Solid"_hash: value = NVG_SOLID; break;
		case "Hole"_hash: value = NVG_HOLE; break;
		case ""_hash: break;
		default:
			Error("nvg::PathWinding param dir must be one of: CW, CCW, Solid, Hole.");
			break;
	}
	nvgPathWinding(Context(), value);
}

void nvg::PathWinding(int dir) {
	nvgPathWinding(Context(), dir);
}

void nvg::Arc(float cx, float cy, float r, float a0, float a1, String dir) {
	int value = NVG_CCW;
	switch (Switch::hash(dir)) {
		case "CW"_hash: value = NVG_CW; break;
		case "CCW"_hash: value = NVG_CCW; break;
		case ""_hash: break;
		default:
			Error("nvg::Arc param dir must be one of: CW, CCW.");
			break;
	}
	nvgArc(Context(), cx, cy, r, a0, a1, value);
}

void nvg::Arc(float cx, float cy, float r, float a0, float a1, int dir) {
	nvgArc(Context(), cx, cy, r, a0, a1, dir);
}

void nvg::Rectangle(float x, float y, float w, float h) {
	nvgRect(Context(), x, y, w, h);
}

void nvg::RoundedRect(float x, float y, float w, float h, float r) {
	nvgRoundedRect(Context(), x, y, w, h, r);
}

void nvg::RoundedRectVarying(float x, float y, float w, float h, float radTopLeft, float radTopRight, float radBottomRight, float radBottomLeft) {
	nvgRoundedRectVarying(Context(), x, y, w, h, radTopLeft, radTopRight, radBottomRight, radBottomLeft);
}

void nvg::Ellipse(float cx, float cy, float rx, float ry) {
	nvgEllipse(Context(), cx, cy, rx, ry);
}

void nvg::Circle(float cx, float cy, float r) {
	nvgCircle(Context(), cx, cy, r);
}

void nvg::Fill() {
	nvgFill(Context());
}

void nvg::Stroke() {
	nvgStroke(Context());
}

int nvg::FindFont(String name) {
	return nvgFindFont(Context(), name.c_str());
}

int nvg::AddFallbackFontId(int baseFont, int fallbackFont) {
	return nvgAddFallbackFontId(Context(), baseFont, fallbackFont);
}

int nvg::AddFallbackFont(String baseFont, String fallbackFont) {
	return nvgAddFallbackFont(Context(), baseFont.c_str(), fallbackFont.c_str());
}

void nvg::FontSize(float size) {
	nvgFontSize(Context(), size);
}

void nvg::FontBlur(float blur) {
	nvgFontBlur(Context(), blur);
}

void nvg::TextLetterSpacing(float spacing) {
	nvgTextLetterSpacing(Context(), spacing);
}

void nvg::TextLineHeight(float lineHeight) {
	nvgTextLineHeight(Context(), lineHeight);
}

void nvg::TextAlign(String hAlign, String vAlign) {
	int flags = 0;
	switch (Switch::hash(hAlign)) {
		case "Left"_hash: flags |= NVG_ALIGN_LEFT; break;
		case "Center"_hash: flags |= NVG_ALIGN_CENTER; break;
		case "Right"_hash: flags |= NVG_ALIGN_RIGHT; break;
		default:
			Error("nvg::TextAlign horizental param must be one of: Left, Center, Right.");
			break;
	}
	switch (Switch::hash(vAlign)) {
		case "Top"_hash: flags |= NVG_ALIGN_TOP; break;
		case "Middle"_hash: flags |= NVG_ALIGN_MIDDLE; break;
		case "Bottom"_hash: flags |= NVG_ALIGN_BOTTOM; break;
		case "Baseline"_hash: flags |= NVG_ALIGN_BASELINE; break;
		default:
			Error("nvg::TextAlign vertical param must be one of: Top, Middle, Bottom, Baseline.");
			break;
	}
	nvgTextAlign(Context(), flags);
}

void nvg::TextAlign(int hAlign, int vAlign) {
	nvgTextAlign(Context(), hAlign | vAlign);
}

void nvg::FontFaceId(int font) {
	nvgFontFaceId(Context(), font);
}

void nvg::FontFace(String font) {
	nvgFontFace(Context(), font.c_str());
}

void nvg::BindContext(NVGcontext* context) {
	_currentContext = context;
}

NVGcontext* nvg::Context() {
	return _currentContext ? _currentContext : SharedDirector.markNVGDirty();
}

void nvg::DoraSSR() {
	RenderDoraSSR(Context());
}

static VGTexture* GetDoraSSRTexture(void (*render)(NVGcontext* context), int width, int height, float scale) {
	const float size = 1133.0f;
	VGTexture* texture = nullptr;
	SharedView.pushFront("DoraSSRTex"_slice, [&]() {
		bgfx::ViewId viewId = SharedView.getId();
		bgfx::setViewClear(viewId,
			BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH | BGFX_CLEAR_STENCIL,
			Color::Black.toRGBA());
		NVGcontext* context = nvgCreate(2, viewId);
		NVGLUframebuffer* framebuffer = nvgluCreateFramebuffer(context,
			s_cast<int32_t>(width * scale),
			s_cast<int32_t>(height * scale), 0);
		nvgluSetViewFramebuffer(viewId, framebuffer);
		bgfx::setViewRect(viewId, 0, 0, s_cast<int16_t>(width * scale), s_cast<int16_t>(height * scale));
		nvgluBindFramebuffer(framebuffer);
		nvgBeginFrame(context, s_cast<float>(width), s_cast<float>(height), scale);
		switch (bgfx::getCaps()->rendererType) {
			case bgfx::RendererType::OpenGL:
			case bgfx::RendererType::OpenGLES:
				nvgScale(context, 1.0f, -1.0f);
				nvgTranslate(context, 0.0f, -s_cast<float>(height));
				break;
			default:
				break;
		}
		nvgTranslate(context, -(size - width) / 2.0f, -(size - height) / 2.0f);
		render(context);
		nvgEndFrame(context);
		nvgluBindFramebuffer(nullptr);
		bgfx::TextureInfo info;
		bgfx::calcTextureSize(info,
			s_cast<uint16_t>(width * scale),
			s_cast<uint16_t>(height * scale),
			0, false, false, 1, bgfx::TextureFormat::RGBA8);
		uint64_t flags = BGFX_TEXTURE_RT | BGFX_SAMPLER_U_CLAMP | BGFX_SAMPLER_V_CLAMP;
		texture = VGTexture::create(context, framebuffer, info, flags);
	});
	return texture;
}

Texture2D* nvg::GetDoraSSR(float scale) {
	const int width = 1133, height = 1133;
	return GetDoraSSRTexture(RenderDoraSSR, width, height, scale);
}

void RenderDoraSSR(NVGcontext* context) {
	nvgBeginPath(context);
	nvgMoveTo(context, 1100.702f, 774.247f);
	nvgLineTo(context, 1029.322f, 774.247f);
	nvgLineTo(context, 1029.322f, 349.38f);
	nvgBezierTo(context, 1106.641f, 283.374f, 1117.172f, 194.572f, 1117.172f, 194.572f);
	nvgLineTo(context, 1082.631f, 214.746f);
	nvgBezierTo(context, 1125.572f, 112.6f, 1081.292f, 41.113f, 1081.292f, 41.113f);
	nvgBezierTo(context, 1081.292f, 41.113f, 1053.641f, 85.753f, 986.307f, 71.615f);
	nvgLineTo(context, 986.07f, 71.615f);
	nvgLineTo(context, 985.832f, 71.456f);
	nvgLineTo(context, 979.178f, 69.788f);
	nvgBezierTo(context, 942.818f, 60.813f, 914.062f, 53.744f, 872.948f, 53.744f);
	nvgLineTo(context, 868.433f, 53.744f);
	nvgBezierTo(context, 823.676f, 53.744f, 779.79f, 68.12f, 743.35f, 94.49f);
	nvgLineTo(context, 618.426f, 22.209f);
	nvgLineTo(context, 591.255f, 6.483f);
	nvgLineTo(context, 579.372f, -0.427f);
	nvgLineTo(context, 567.49f, 6.483f);
	nvgLineTo(context, 540.318f, 22.209f);
	nvgLineTo(context, 273.359f, 176.699f);
	nvgBezierTo(context, 245.633f, 148.82f, 206.579f, 57.476f, 206.579f, 57.476f);
	nvgBezierTo(context, 206.579f, 57.476f, 178.299f, 181.863f, 7.509f, 256.686f);
	nvgBezierTo(context, 7.509f, 256.686f, 106.451f, 305.694f, 129.343f, 328.172f);
	nvgLineTo(context, 129.343f, 774.168f);
	nvgLineTo(context, 32.382f, 774.168f);
	nvgLineTo(context, 34.839f, 808.482f);
	nvgLineTo(context, 41.175f, 814.916f);
	nvgBezierTo(context, 47.037f, 820.952f, 53.376f, 830.721f, 53.376f, 838.03f);
	nvgLineTo(context, 53.376f, 838.427f);
	nvgBezierTo(context, 53.376f, 847.323f, 54.168f, 1098.562f, 54.168f, 1100.782f);
	nvgLineTo(context, 49.176f, 1133.422f);
	nvgLineTo(context, 83.16f, 1125.802f);
	nvgBezierTo(context, 216.164f, 1095.932f, 360.26f, 1077.352f, 499.918f, 1071.872f);
	nvgLineTo(context, 539.368f, 1070.362f);
	nvgLineTo(context, 540.24f, 1070.912f);
	nvgLineTo(context, 567.41f, 1086.642f);
	nvgLineTo(context, 579.293f, 1093.552f);
	nvgLineTo(context, 591.175f, 1086.642f);
	nvgLineTo(context, 618.347f, 1070.912f);
	nvgLineTo(context, 618.823f, 1070.602f);
	nvgLineTo(context, 658.985f, 1071.792f);
	nvgBezierTo(context, 799.753f, 1076.082f, 940.917f, 1093.712f, 1078.672f, 1124.052f);
	nvgLineTo(context, 1108.381f, 1130.642f);
	nvgLineTo(context, 1106.081f, 1060.193f);
	nvgBezierTo(context, 1106.081f, 1058.052f, 1105.131f, 1011.342f, 1091.192f, 962.893f);
	nvgBezierTo(context, 1099.432f, 951.296f, 1104.021f, 936.76f, 1104.021f, 921.112f);
	nvgBezierTo(context, 1104.021f, 921.112f, 1105.131f, 838.268f, 1105.131f, 837.711f);
	nvgBezierTo(context, 1105.131f, 825.242f, 1114.322f, 817.456f, 1115.351f, 816.583f);
	nvgLineTo(context, 1123.751f, 809.831f);
	nvgLineTo(context, 1125.491f, 774.089f);
	nvgLineTo(context, 1100.621f, 774.089f);
	nvgLineTo(context, 1100.702f, 774.247f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(255, 255, 255, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 78.052f, 1102.412f);
	nvgBezierTo(context, 224.492f, 1069.622f, 371.242f, 1052.943f, 500.121f, 1047.943f);
	nvgLineTo(context, 464.072f, 1027.132f);
	nvgBezierTo(context, 334.712f, 1033.722f, 205.661f, 1051.032f, 77.972f, 1079.142f);
	nvgLineTo(context, 77.972f, 1102.402f);
	nvgLineTo(context, 78.052f, 1102.402f);
	nvgLineTo(context, 78.052f, 1102.412f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(35, 24, 21, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 661.331f, 1047.952f);
	nvgBezierTo(context, 803.792f, 1052.323f, 945.941f, 1069.872f, 1086.422f, 1100.762f);
	nvgBezierTo(context, 1086.261f, 1094.162f, 1085.942f, 1086.552f, 1085.631f, 1079.082f);
	nvgBezierTo(context, 957.301f, 1050.812f, 827.542f, 1033.502f, 697.471f, 1027.073f);
	nvgLineTo(context, 661.341f, 1047.962f);
	nvgLineTo(context, 661.331f, 1047.952f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(35, 24, 21, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 580.651f, 89.997f);
	nvgLineTo(context, 953.491f, 305.208f);
	nvgLineTo(context, 953.491f, 787.638f);
	nvgLineTo(context, 580.651f, 1002.852f);
	nvgLineTo(context, 207.811f, 787.638f);
	nvgLineTo(context, 207.811f, 305.288f);
	nvgLineTo(context, 580.651f, 90.077f);
	nvgMoveTo(context, 580.651f, 27.188f);
	nvgLineTo(context, 553.411f, 42.907f);
	nvgLineTo(context, 180.571f, 258.118f);
	nvgLineTo(context, 153.331f, 273.838f);
	nvgLineTo(context, 153.331f, 819.158f);
	nvgLineTo(context, 180.571f, 834.878f);
	nvgLineTo(context, 553.411f, 1050.092f);
	nvgLineTo(context, 580.651f, 1065.812f);
	nvgLineTo(context, 607.891f, 1050.092f);
	nvgLineTo(context, 980.732f, 834.878f);
	nvgLineTo(context, 1007.971f, 819.158f);
	nvgLineTo(context, 1007.971f, 273.838f);
	nvgLineTo(context, 980.732f, 258.118f);
	nvgLineTo(context, 607.891f, 42.828f);
	nvgLineTo(context, 580.651f, 27.108f);
	nvgLineTo(context, 580.651f, 27.188f);
	nvgClosePath(context);
	nvgPathWinding(context, NVG_HOLE);
	nvgFillColor(context, nvgRGBA(35, 24, 21, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 1073.562f, 76.658f);
	nvgBezierTo(context, 1073.562f, 76.658f, 1059.501f, 99.768f, 1018.211f, 99.768f);
	nvgBezierTo(context, 1007.411f, 99.768f, 994.781f, 98.178f, 980.011f, 94.208f);
	nvgBezierTo(context, 939.672f, 84.277f, 911.321f, 76.658f, 868.281f, 77.217f);
	nvgBezierTo(context, 795.061f, 77.217f, 728.121f, 120.018f, 698.971f, 181.727f);
	nvgBezierTo(context, 671.331f, 176.488f, 642.431f, 173.787f, 612.411f, 173.787f);
	nvgBezierTo(context, 598.831f, 173.787f, 584.771f, 174.348f, 570.801f, 175.378f);
	nvgBezierTo(context, 558.091f, 176.087f, 456.292f, 184.037f, 352.501f, 254.157f);
	nvgBezierTo(context, 276.982f, 229.617f, 227.591f, 178.878f, 204.561f, 101.768f);
	nvgBezierTo(context, 180.891f, 181.087f, 129.352f, 232.548f, 50.021f, 256.288f);
	nvgBezierTo(context, 129.352f, 279.948f, 184.231f, 338.878f, 203.681f, 417.808f);
	nvgBezierTo(context, 203.681f, 417.808f, 203.761f, 417.808f, 203.841f, 417.728f);
	nvgBezierTo(context, 152.941f, 514.288f, 152.781f, 629.278f, 204.951f, 723.388f);
	nvgBezierTo(context, 265.542f, 832.737f, 385.532f, 895.398f, 534.111f, 895.398f);
	nvgBezierTo(context, 567.781f, 895.398f, 603.281f, 892.218f, 639.571f, 885.948f);
	nvgBezierTo(context, 829.441f, 853.307f, 914.261f, 761.107f, 951.982f, 689.557f);
	nvgBezierTo(context, 1016.072f, 567.898f, 987.401f, 435.918f, 960.401f, 377.068f);
	nvgBezierTo(context, 959.371f, 374.848f, 958.181f, 372.698f, 957.061f, 370.478f);
	nvgBezierTo(context, 997.561f, 349.358f, 1045.292f, 312.348f, 1070.141f, 249.298f);
	nvgBezierTo(context, 1070.141f, 249.298f, 1044.731f, 264.068f, 1027.182f, 266.288f);
	nvgBezierTo(context, 1027.182f, 266.288f, 1097.861f, 174.727f, 1073.481f, 76.727f);
	nvgLineTo(context, 1073.562f, 76.648f);
	nvgLineTo(context, 1073.562f, 76.658f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(35, 24, 21, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 633.542f, 836.788f);
	nvgBezierTo(context, 599.081f, 842.747f, 566.751f, 845.448f, 536.581f, 845.448f);
	nvgBezierTo(context, 342.501f, 845.448f, 236.242f, 731.098f, 220.521f, 604.198f);
	nvgBezierTo(context, 250.062f, 596.737f, 359.572f, 566.158f, 479.402f, 497.068f);
	nvgBezierTo(context, 479.402f, 497.068f, 487.342f, 473.798f, 490.762f, 430.128f);
	nvgBezierTo(context, 490.762f, 430.128f, 579.071f, 548.607f, 526.732f, 759.848f);
	nvgBezierTo(context, 526.732f, 759.848f, 618.531f, 721.177f, 657.841f, 603.247f);
	nvgBezierTo(context, 669.121f, 594.198f, 694.771f, 578.078f, 719.461f, 594.357f);
	nvgBezierTo(context, 735.261f, 604.677f, 741.301f, 629.538f, 733.751f, 653.278f);
	nvgBezierTo(context, 723.901f, 684.247f, 695.391f, 701.878f, 657.361f, 700.688f);
	nvgLineTo(context, 656.331f, 731.098f);
	nvgBezierTo(context, 658.081f, 731.098f, 659.741f, 731.177f, 661.411f, 731.177f);
	nvgBezierTo(context, 671.651f, 731.177f, 681.021f, 730.068f, 689.761f, 728.078f);
	nvgBezierTo(context, 698.971f, 752.057f, 721.211f, 784.138f, 760.911f, 799.468f);
	nvgBezierTo(context, 725.251f, 815.427f, 683.172f, 828.218f, 633.691f, 836.708f);
	nvgLineTo(context, 633.531f, 836.788f);
	nvgLineTo(context, 633.542f, 836.788f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(251, 233, 236, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 916.961f, 404.628f);
	nvgBezierTo(context, 953.811f, 484.838f, 975.721f, 676.848f, 805.151f, 782.307f);
	nvgBezierTo(context, 747.891f, 780.008f, 726.061f, 739.107f, 719.542f, 722.588f);
	nvgBezierTo(context, 742.172f, 709.247f, 756.232f, 688.758f, 762.581f, 668.747f);
	nvgBezierTo(context, 774.331f, 631.588f, 763.371f, 593.148f, 735.982f, 575.198f);
	nvgBezierTo(context, 712.551f, 559.867f, 688.331f, 561.297f, 668.241f, 568.848f);
	nvgBezierTo(context, 674.511f, 536.448f, 676.982f, 499.438f, 673.561f, 456.958f);
	nvgBezierTo(context, 673.561f, 456.958f, 650.931f, 595.448f, 574.852f, 676.607f);
	nvgBezierTo(context, 574.852f, 676.607f, 599.982f, 449.918f, 467.282f, 377.258f);
	nvgBezierTo(context, 467.282f, 377.258f, 463.872f, 430.308f, 449.492f, 479.298f);
	nvgBezierTo(context, 449.492f, 479.298f, 369.682f, 525.987f, 217.531f, 563.478f);
	nvgBezierTo(context, 219.671f, 517.018f, 234.731f, 471.648f, 260.782f, 429.958f);
	nvgBezierTo(context, 378.632f, 241.118f, 576.361f, 232.217f, 576.361f, 232.217f);
	nvgBezierTo(context, 589.461f, 231.187f, 602.251f, 230.708f, 614.721f, 230.708f);
	nvgBezierTo(context, 640.371f, 230.708f, 664.431f, 233.007f, 687.141f, 236.977f);
	nvgBezierTo(context, 676.261f, 324.568f, 742.251f, 400.168f, 836.201f, 406.758f);
	nvgBezierTo(context, 840.491f, 407.078f, 844.781f, 407.238f, 849.061f, 407.238f);
	nvgBezierTo(context, 862.881f, 407.238f, 876.542f, 405.728f, 889.721f, 402.788f);
	nvgBezierTo(context, 902.901f, 399.848f, 898.771f, 401.118f, 912.911f, 396.598f);
	nvgBezierTo(context, 914.261f, 399.298f, 915.771f, 401.997f, 917.042f, 404.778f);
	nvgLineTo(context, 916.961f, 404.618f);
	nvgLineTo(context, 916.961f, 404.628f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(250, 192, 61, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 932.131f, 305.918f);
	nvgLineTo(context, 965.721f, 308.938f);
	nvgBezierTo(context, 938.011f, 328.398f, 909.661f, 337.768f, 894.491f, 341.818f);
	nvgLineTo(context, 880.672f, 344.838f);
	nvgBezierTo(context, 870.821f, 346.978f, 860.901f, 348.098f, 851.051f, 348.098f);
	nvgBezierTo(context, 847.951f, 348.098f, 844.861f, 348.018f, 841.761f, 347.778f);
	nvgBezierTo(context, 808.331f, 345.478f, 779.422f, 331.178f, 760.441f, 307.518f);
	nvgBezierTo(context, 743.681f, 286.708f, 736.701f, 260.508f, 740.672f, 233.588f);
	nvgBezierTo(context, 749.411f, 174.427f, 806.031f, 128.688f, 871.221f, 128.128f);
	nvgBezierTo(context, 908.621f, 127.807f, 944.121f, 137.897f, 970.801f, 143.378f);
	nvgBezierTo(context, 989.141f, 147.107f, 1006.221f, 150.688f, 1022.422f, 150.688f);
	nvgBezierTo(context, 1024.251f, 150.688f, 1025.991f, 150.688f, 1027.741f, 150.607f);
	nvgBezierTo(context, 1014.081f, 230.817f, 932.211f, 305.938f, 932.211f, 305.938f);
	nvgLineTo(context, 932.131f, 305.938f);
	nvgLineTo(context, 932.131f, 305.918f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(250, 192, 61, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 970.801f, 143.367f);
	nvgBezierTo(context, 944.121f, 137.967f, 908.621f, 127.807f, 871.221f, 128.117f);
	nvgBezierTo(context, 805.941f, 128.677f, 749.321f, 174.417f, 740.672f, 233.577f);
	nvgBezierTo(context, 736.701f, 260.418f, 743.771f, 286.708f, 760.441f, 307.508f);
	nvgBezierTo(context, 779.422f, 331.098f, 808.331f, 345.388f, 841.761f, 347.768f);
	nvgLineTo(context, 843.111f, 347.768f);
	nvgBezierTo(context, 828.741f, 343.878f, 792.602f, 330.378f, 775.371f, 289.717f);
	nvgBezierTo(context, 749.321f, 228.257f, 790.701f, 139.307f, 918.471f, 152.967f);
	nvgBezierTo(context, 985.811f, 160.197f, 1015.192f, 156.537f, 1027.661f, 151.057f);
	nvgBezierTo(context, 1027.661f, 150.897f, 1027.661f, 150.738f, 1027.741f, 150.577f);
	nvgBezierTo(context, 1025.991f, 150.577f, 1024.251f, 150.658f, 1022.422f, 150.658f);
	nvgBezierTo(context, 1006.221f, 150.658f, 989.151f, 147.087f, 970.801f, 143.348f);
	nvgLineTo(context, 970.801f, 143.367f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(255, 255, 255, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 519.141f, 668.948f);
	nvgBezierTo(context, 527.911f, 681.538f, 516.161f, 704.878f, 492.902f, 721.057f);
	nvgBezierTo(context, 469.642f, 737.237f, 443.682f, 740.138f, 434.911f, 727.547f);
	nvgBezierTo(context, 426.142f, 714.948f, 437.892f, 691.617f, 461.152f, 675.427f);
	nvgBezierTo(context, 484.411f, 659.237f, 510.371f, 656.348f, 519.141f, 668.948f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(237, 122, 149, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 486.072f, 556.628f);
	nvgBezierTo(context, 494.962f, 608.568f, 452.962f, 664.468f, 392.282f, 681.468f);
	nvgBezierTo(context, 339.392f, 696.318f, 289.842f, 676.628f, 272.052f, 636.997f);
	nvgLineTo(context, 481.622f, 541.068f);
	nvgBezierTo(context, 483.532f, 545.987f, 485.112f, 551.158f, 486.072f, 556.557f);
	nvgLineTo(context, 486.072f, 556.638f);
	nvgLineTo(context, 486.072f, 556.628f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(35, 24, 21, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 423.022f, 594.588f);
	nvgBezierTo(context, 423.022f, 594.588f, 427.152f, 621.588f, 399.432f, 652.398f);
	nvgBezierTo(context, 399.432f, 652.398f, 449.941f, 636.677f, 453.112f, 580.927f);
	nvgLineTo(context, 423.012f, 594.588f);
	nvgLineTo(context, 423.022f, 594.588f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(255, 255, 255, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 204.77f, 330.972f);
	nvgBezierTo(context, 193.329f, 292.532f, 168.399f, 267.602f, 129.959f, 256.161f);
	nvgBezierTo(context, 168.399f, 244.722f, 193.329f, 219.792f, 204.77f, 181.352f);
	nvgBezierTo(context, 216.209f, 219.792f, 241.139f, 244.722f, 279.579f, 256.161f);
	nvgBezierTo(context, 241.139f, 267.602f, 216.209f, 292.532f, 204.77f, 330.972f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(250, 192, 61, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 467.282f, 377.268f);
	nvgBezierTo(context, 467.282f, 377.268f, 445.682f, 439.688f, 432.501f, 457.318f);
	nvgBezierTo(context, 432.501f, 457.318f, 339.672f, 495.598f, 278.362f, 507.908f);
	nvgBezierTo(context, 278.362f, 507.908f, 332.292f, 233.097f, 686.461f, 243.577f);
	nvgBezierTo(context, 686.621f, 241.037f, 686.821f, 239.537f, 687.141f, 236.997f);
	nvgBezierTo(context, 664.431f, 233.028f, 639.292f, 229.567f, 613.641f, 229.567f);
	nvgBezierTo(context, 601.172f, 229.567f, 588.471f, 230.048f, 575.281f, 231.077f);
	nvgBezierTo(context, 575.281f, 231.077f, 377.542f, 239.967f, 259.702f, 428.818f);
	nvgBezierTo(context, 233.651f, 470.588f, 219.681f, 517.047f, 217.531f, 563.497f);
	nvgBezierTo(context, 222.291f, 562.307f, 269.682f, 550.458f, 323.062f, 532.818f);
	nvgBezierTo(context, 430.492f, 494.208f, 449.492f, 479.328f, 449.492f, 479.328f);
	nvgBezierTo(context, 463.862f, 430.328f, 467.282f, 377.288f, 467.282f, 377.288f);
	nvgFillColor(context, nvgRGBA(255, 255, 255, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 1066.971f, 956.938f);
	nvgBezierTo(context, 1076.741f, 949.237f, 1082.932f, 936.208f, 1082.851f, 920.968f);
	nvgBezierTo(context, 1082.851f, 920.968f, 1083.961f, 838.857f, 1083.961f, 837.747f);
	nvgBezierTo(context, 1083.961f, 812.258f, 1103.261f, 798.038f, 1103.261f, 797.958f);
	nvgLineTo(context, 57.882f, 797.958f);
	nvgBezierTo(context, 57.882f, 797.958f, 77.182f, 816.378f, 77.102f, 837.978f);
	nvgBezierTo(context, 77.102f, 837.978f, 77.892f, 1060.252f, 77.892f, 1060.162f);
	nvgBezierTo(context, 410.312f, 985.763f, 752.491f, 985.913f, 1084.831f, 1060.573f);
	nvgBezierTo(context, 1084.831f, 1060.573f, 1083.961f, 1006.883f, 1066.881f, 956.938f);
	nvgLineTo(context, 1066.971f, 956.938f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(35, 24, 21, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 211.541f, 824.958f);
	nvgBezierTo(context, 185.021f, 825.438f, 158.411f, 825.908f, 131.891f, 826.468f);
	nvgBezierTo(context, 129.111f, 826.468f, 126.252f, 826.547f, 123.472f, 826.628f);
	nvgBezierTo(context, 121.562f, 826.628f, 119.582f, 826.708f, 117.672f, 826.788f);
	nvgBezierTo(context, 117.672f, 826.788f, 123.472f, 834.177f, 123.472f, 844.177f);
	nvgLineTo(context, 123.472f, 844.578f);
	nvgBezierTo(context, 123.392f, 904.538f, 123.231f, 964.487f, 123.151f, 1024.372f);
	nvgLineTo(context, 123.472f, 1024.372f);
	nvgBezierTo(context, 135.462f, 1022.143f, 147.451f, 1019.913f, 159.521f, 1017.862f);
	nvgBezierTo(context, 176.511f, 1014.913f, 193.511f, 1012.212f, 210.501f, 1009.602f);
	nvgBezierTo(context, 225.671f, 1007.212f, 238.141f, 993.393f, 238.212f, 978.383f);
	nvgBezierTo(context, 238.531f, 936.218f, 238.771f, 893.978f, 239.081f, 851.807f);
	nvgBezierTo(context, 239.161f, 836.797f, 226.852f, 824.728f, 211.521f, 824.968f);
	nvgLineTo(context, 211.541f, 824.958f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(250, 192, 61, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 202.091f, 980.453f);
	nvgBezierTo(context, 187.882f, 982.362f, 173.742f, 984.263f, 159.602f, 986.403f);
	nvgBezierTo(context, 159.761f, 943.367f, 159.841f, 900.408f, 160.001f, 857.367f);
	nvgBezierTo(context, 174.212f, 856.728f, 188.431f, 856.177f, 202.641f, 855.538f);
	nvgBezierTo(context, 202.481f, 897.148f, 202.321f, 938.758f, 202.161f, 980.383f);
	nvgLineTo(context, 202.081f, 980.463f);
	nvgLineTo(context, 202.091f, 980.453f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(35, 24, 21, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 341.862f, 823.128f);
	nvgBezierTo(context, 321.691f, 823.367f, 301.522f, 823.607f, 281.352f, 823.838f);
	nvgBezierTo(context, 266.102f, 823.997f, 253.641f, 836.307f, 253.562f, 851.318f);
	nvgBezierTo(context, 253.481f, 893.088f, 253.321f, 934.857f, 253.242f, 976.543f);
	nvgBezierTo(context, 253.242f, 991.482f, 265.471f, 1001.883f, 280.721f, 999.972f);
	nvgBezierTo(context, 300.812f, 997.513f, 320.902f, 995.372f, 340.992f, 993.383f);
	nvgBezierTo(context, 356.322f, 991.883f, 368.702f, 979.492f, 368.782f, 965.518f);
	nvgLineTo(context, 369.262f, 848.068f);
	nvgBezierTo(context, 369.262f, 834.088f, 356.952f, 822.898f, 341.702f, 823.057f);
	nvgLineTo(context, 341.862f, 823.138f);
	nvgLineTo(context, 341.862f, 823.128f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(250, 192, 61, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 332.332f, 966.228f);
	nvgBezierTo(context, 318.122f, 967.418f, 303.902f, 968.768f, 289.691f, 970.198f);
	nvgBezierTo(context, 289.852f, 930.968f, 290.092f, 891.658f, 290.251f, 852.427f);
	nvgBezierTo(context, 304.462f, 852.028f, 318.682f, 851.557f, 332.892f, 851.237f);
	nvgBezierTo(context, 332.732f, 889.598f, 332.572f, 927.867f, 332.332f, 966.228f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(35, 24, 21, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 602.571f, 821.778f);
	nvgLineTo(context, 542.061f, 821.778f);
	nvgBezierTo(context, 526.811f, 821.778f, 514.352f, 832.658f, 514.352f, 846.078f);
	nvgBezierTo(context, 514.352f, 891.578f, 514.191f, 937.168f, 514.111f, 982.663f);
	nvgBezierTo(context, 526.341f, 982.353f, 538.571f, 982.112f, 550.881f, 981.963f);
	nvgLineTo(context, 550.881f, 915.018f);
	nvgBezierTo(context, 565.172f, 914.938f, 579.391f, 914.857f, 593.681f, 914.938f);
	nvgLineTo(context, 593.681f, 981.793f);
	nvgBezierTo(context, 605.911f, 981.793f, 618.221f, 982.033f, 630.451f, 982.273f);
	nvgBezierTo(context, 630.451f, 936.857f, 630.371f, 891.427f, 630.292f, 846.008f);
	nvgBezierTo(context, 630.292f, 832.668f, 617.901f, 821.788f, 602.581f, 821.788f);
	nvgLineTo(context, 602.571f, 821.778f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(250, 192, 61, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 550.951f, 847.908f);
	nvgLineTo(context, 593.672f, 847.908f);
	nvgLineTo(context, 593.672f, 888.648f);
	nvgLineTo(context, 550.951f, 888.648f);
	nvgLineTo(context, 550.951f, 847.908f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(35, 24, 21, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 754.561f, 891.668f);
	nvgBezierTo(context, 735.901f, 891.028f, 717.321f, 890.478f, 698.651f, 890.078f);
	nvgBezierTo(context, 698.651f, 876.338f, 698.651f, 862.518f, 698.571f, 848.788f);
	nvgBezierTo(context, 724.781f, 849.107f, 750.901f, 849.578f, 777.111f, 850.057f);
	nvgBezierTo(context, 777.111f, 840.927f, 777.111f, 831.797f, 777.031f, 822.658f);
	nvgBezierTo(context, 747.891f, 822.418f, 718.741f, 822.177f, 689.602f, 822.018f);
	nvgBezierTo(context, 674.352f, 822.018f, 661.961f, 832.737f, 661.961f, 846.158f);
	nvgBezierTo(context, 661.961f, 861.247f, 661.961f, 876.338f, 662.042f, 891.418f);
	nvgBezierTo(context, 662.042f, 904.838f, 674.511f, 915.958f, 689.831f, 916.357f);
	nvgBezierTo(context, 707.061f, 916.838f, 724.292f, 917.468f, 741.531f, 918.107f);
	nvgBezierTo(context, 741.531f, 932.088f, 741.611f, 945.978f, 741.691f, 959.958f);
	nvgBezierTo(context, 715.331f, 958.448f, 688.881f, 957.418f, 662.521f, 956.617f);
	nvgLineTo(context, 662.521f, 983.062f);
	nvgBezierTo(context, 691.901f, 984.013f, 721.361f, 985.513f, 750.672f, 987.593f);
	nvgBezierTo(context, 766.001f, 988.703f, 778.381f, 978.463f, 778.311f, 964.478f);
	nvgBezierTo(context, 778.071f, 947.328f, 777.831f, 930.168f, 777.521f, 913.018f);
	nvgBezierTo(context, 777.361f, 901.578f, 767.121f, 891.978f, 754.491f, 891.578f);
	nvgLineTo(context, 754.571f, 891.658f);
	nvgLineTo(context, 754.561f, 891.668f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(255, 255, 255, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 884.961f, 897.778f);
	nvgBezierTo(context, 866.381f, 896.668f, 847.721f, 895.638f, 829.131f, 894.758f);
	nvgBezierTo(context, 829.131f, 880.228f, 828.971f, 865.768f, 828.891f, 851.237f);
	nvgBezierTo(context, 855.102f, 851.948f, 881.221f, 852.747f, 907.352f, 853.617f);
	nvgBezierTo(context, 907.352f, 843.848f, 907.271f, 834.008f, 907.191f, 824.237f);
	nvgBezierTo(context, 878.051f, 823.758f, 848.901f, 823.448f, 819.761f, 823.128f);
	nvgBezierTo(context, 804.511f, 822.968f, 792.121f, 834.168f, 792.201f, 848.138f);
	nvgBezierTo(context, 792.201f, 863.857f, 792.361f, 879.588f, 792.441f, 895.307f);
	nvgBezierTo(context, 792.441f, 909.288f, 804.911f, 921.278f, 820.232f, 922.228f);
	nvgBezierTo(context, 837.461f, 923.258f, 854.621f, 924.448f, 871.852f, 925.718f);
	nvgBezierTo(context, 871.852f, 940.568f, 872.011f, 955.418f, 872.091f, 970.268f);
	nvgBezierTo(context, 845.801f, 967.568f, 819.441f, 965.348f, 793.081f, 963.357f);
	nvgBezierTo(context, 793.081f, 972.568f, 793.161f, 981.703f, 793.241f, 990.913f);
	nvgBezierTo(context, 822.621f, 993.463f, 851.931f, 996.482f, 881.151f, 1000.053f);
	nvgBezierTo(context, 896.401f, 1001.952f, 908.711f, 991.543f, 908.631f, 976.533f);
	nvgBezierTo(context, 908.391f, 958.117f, 908.071f, 939.688f, 907.841f, 921.268f);
	nvgBezierTo(context, 907.681f, 908.958f, 897.441f, 898.398f, 884.891f, 897.677f);
	nvgLineTo(context, 884.971f, 897.758f);
	nvgLineTo(context, 884.961f, 897.778f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(255, 255, 255, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 498.931f, 896.427f);
	nvgBezierTo(context, 498.931f, 879.668f, 498.931f, 862.997f, 499.012f, 846.237f);
	nvgBezierTo(context, 499.012f, 832.818f, 486.702f, 822.018f, 471.372f, 822.098f);
	nvgBezierTo(context, 451.441f, 822.177f, 431.512f, 822.338f, 411.572f, 822.497f);
	nvgBezierTo(context, 396.322f, 822.578f, 383.862f, 833.938f, 383.782f, 847.908f);
	nvgBezierTo(context, 383.622f, 895.158f, 383.382f, 942.487f, 383.221f, 989.742f);
	nvgBezierTo(context, 395.452f, 988.783f, 407.682f, 987.903f, 419.911f, 987.122f);
	nvgBezierTo(context, 420.072f, 941.218f, 420.232f, 895.398f, 420.392f, 849.497f);
	nvgBezierTo(context, 434.602f, 849.258f, 448.822f, 849.018f, 463.112f, 848.857f);
	nvgBezierTo(context, 463.112f, 862.598f, 463.112f, 876.418f, 463.032f, 890.148f);
	nvgBezierTo(context, 450.562f, 890.468f, 438.172f, 890.788f, 425.712f, 891.177f);
	nvgBezierTo(context, 425.712f, 891.338f, 462.872f, 940.418f, 462.802f, 984.732f);
	nvgBezierTo(context, 475.032f, 984.163f, 487.262f, 983.622f, 499.572f, 983.223f);
	nvgBezierTo(context, 499.572f, 983.223f, 497.822f, 953.117f, 476.862f, 916.357f);
	nvgBezierTo(context, 489.092f, 916.038f, 498.941f, 907.148f, 499.022f, 896.508f);
	nvgLineTo(context, 498.941f, 896.427f);
	nvgLineTo(context, 498.931f, 896.427f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(250, 192, 61, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 1037.741f, 917.948f);
	nvgBezierTo(context, 1037.741f, 893.247f, 1037.661f, 868.557f, 1037.581f, 843.857f);
	nvgBezierTo(context, 1037.661f, 834.008f, 1043.381f, 826.788f, 1043.381f, 826.788f);
	nvgBezierTo(context, 1041.471f, 826.788f, 1039.491f, 826.708f, 1037.581f, 826.628f);
	nvgBezierTo(context, 1034.802f, 826.628f, 1031.942f, 826.547f, 1029.161f, 826.468f);
	nvgBezierTo(context, 1002.871f, 825.908f, 976.591f, 825.438f, 950.221f, 824.958f);
	nvgBezierTo(context, 934.971f, 824.718f, 922.661f, 836.788f, 922.661f, 851.797f);
	nvgBezierTo(context, 922.901f, 903.098f, 923.141f, 954.318f, 923.301f, 1005.622f);
	nvgBezierTo(context, 935.451f, 1007.293f, 947.602f, 1009.112f, 959.831f, 1011.023f);
	nvgBezierTo(context, 959.672f, 959.237f, 959.431f, 907.468f, 959.271f, 855.607f);
	nvgBezierTo(context, 973.482f, 856.168f, 987.701f, 856.797f, 1001.911f, 857.438f);
	nvgBezierTo(context, 1001.911f, 873.718f, 1001.991f, 889.997f, 1002.071f, 906.198f);
	nvgBezierTo(context, 989.681f, 905.168f, 977.292f, 904.208f, 964.911f, 903.258f);
	nvgBezierTo(context, 964.911f, 902.778f, 1002.311f, 964.568f, 1002.391f, 1017.923f);
	nvgBezierTo(context, 1014.542f, 1019.982f, 1026.611f, 1022.212f, 1038.761f, 1024.432f);
	nvgBezierTo(context, 1038.761f, 1024.602f, 1036.932f, 986.482f, 1015.891f, 939.148f);
	nvgBezierTo(context, 1028.042f, 940.578f, 1037.812f, 931.128f, 1037.812f, 917.948f);
	nvgLineTo(context, 1037.731f, 917.948f);
	nvgLineTo(context, 1037.741f, 917.948f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(255, 255, 255, 255));
	nvgFill(context);
}

VGTexture::VGTexture(NotNull<NVGcontext, 1> context, NotNull<NVGLUframebuffer, 2> framebuffer, const bgfx::TextureInfo& info, uint64_t flags)
	: Texture2D({s_cast<uint16_t>(framebuffer->image)}, info, flags)
	, _framebuffer(framebuffer)
	, _context(context) { }

VGTexture::~VGTexture() {
	if (_framebuffer) {
		nvgluDeleteFramebuffer(_framebuffer);
		_framebuffer = nullptr;
		_handle = BGFX_INVALID_HANDLE;
	}
	if (_context) {
		nvgDelete(_context);
		_context = nullptr;
	}
}

NVGcontext* VGTexture::getContext() const noexcept {
	return _context;
}

NVGLUframebuffer* VGTexture::getFramebuffer() const noexcept {
	return _framebuffer;
}

NS_DORA_END
