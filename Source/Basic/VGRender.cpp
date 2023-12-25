/* Copyright (c) 2023 Jin Li, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Basic/VGRender.h"

#include "Basic/Content.h"
#include "Basic/Director.h"
#include "Basic/View.h"
#include "Input/TouchDispather.h"
#include "Support/Common.h"
#include "bimg/decode.h"
#include "nanovg/nanovg_bgfx.h"

NS_DORA_BEGIN

NVGcontext* nvg::_currentContext = nullptr;

Vec2 nvg::TouchPos() {
	return SharedDirector.getUITouchHandler()->getMousePos();
}

bool nvg::LeftButtonPressed() {
	return SharedDirector.getUITouchHandler()->isLeftButtonPressed();
}

bool nvg::RightButtonPressed() {
	return SharedDirector.getUITouchHandler()->isRightButtonPressed();
}

bool nvg::MiddleButtonPressed() {
	return SharedDirector.getUITouchHandler()->isMiddleButtonPressed();
}

float nvg::MouseWheel() {
	return SharedDirector.getUITouchHandler()->getMouseWheel();
}

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

int nvg::CreateFont(String name) {
	std::string fontFile;
	BLOCK_START {
		fontFile = "Font/" + name.toString() + ".ttf";
		BREAK_IF(SharedContent.exist(fontFile));
		fontFile = "Font/" + name.toString() + ".otf";
		BREAK_IF(SharedContent.exist(fontFile));
		fontFile = name.toString();
		BREAK_IF(SharedContent.exist(fontFile));
		fontFile.clear();
	}
	BLOCK_END
	if (fontFile.empty()) return -1;
	auto data = SharedContent.load(fontFile);
	uint8_t* fontData = r_cast<uint8_t*>(malloc(data.second));
	bx::memCopy(fontData, data.first.get(), data.second);
	return nvgCreateFontMem(Context(), name.c_str(), fontData, s_cast<int>(data.second), 1);
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

void nvg::StrokePaint(const NVGpaint& paint) {
	nvgStrokePaint(Context(), paint);
}

void nvg::FillColor(Color color) {
	nvgFillColor(Context(), nvgColor(color));
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

void nvg::TextAlign(String align) {
	int value = NVG_ALIGN_LEFT;
	switch (Switch::hash(align)) {
		case "Left"_hash: value = NVG_ALIGN_LEFT; break;
		case "Center"_hash: value = NVG_ALIGN_CENTER; break;
		case "Right"_hash: value = NVG_ALIGN_RIGHT; break;
		case "Top"_hash: value = NVG_ALIGN_TOP; break;
		case "Middle"_hash: value = NVG_ALIGN_MIDDLE; break;
		case "Bottom"_hash: value = NVG_ALIGN_BOTTOM; break;
		case "Baseline"_hash: value = NVG_ALIGN_BASELINE; break;
		default:
			Error("nvg::TextAlign param must be one of: Left, Center, Right, Top, Middle, Bottom, Baseline.");
			break;
	}
	nvgTextAlign(Context(), value);
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
	const float size = 1080.0f;
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
	const int width = 1080, height = 1080;
	return GetDoraSSRTexture(RenderDoraSSR, width, height, scale);
}

void RenderDoraSSR(NVGcontext* context) {
	nvgBeginPath(context);
	nvgMoveTo(context, 544.01f, 65.235f);
	nvgLineTo(context, 916.85f, 280.445f);
	nvgLineTo(context, 916.85f, 762.875f);
	nvgLineTo(context, 544.01f, 978.085f);
	nvgLineTo(context, 171.17f, 762.875f);
	nvgLineTo(context, 171.17f, 280.525f);
	nvgLineTo(context, 544.01f, 65.315f);
	nvgMoveTo(context, 544.01f, 2.425f);
	nvgLineTo(context, 516.77f, 18.145f);
	nvgLineTo(context, 143.93f, 233.355f);
	nvgLineTo(context, 116.69f, 249.075f);
	nvgLineTo(context, 116.69f, 794.395f);
	nvgLineTo(context, 143.93f, 810.115f);
	nvgLineTo(context, 516.77f, 1025.33f);
	nvgLineTo(context, 544.01f, 1041.05f);
	nvgLineTo(context, 571.25f, 1025.33f);
	nvgLineTo(context, 944.09f, 810.115f);
	nvgLineTo(context, 971.33f, 794.395f);
	nvgLineTo(context, 971.33f, 249.075f);
	nvgLineTo(context, 944.09f, 233.355f);
	nvgLineTo(context, 571.25f, 18.065f);
	nvgLineTo(context, 544.01f, 2.345f);
	nvgLineTo(context, 544.01f, 2.425f);
	nvgClosePath(context);
	nvgPathWinding(context, NVG_HOLE);
	nvgFillColor(context, nvgRGBA(251, 196, 0, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 1036.92f, 51.895f);
	nvgBezierTo(context, 1036.92f, 51.895f, 1022.86f, 75.005f, 981.57f, 75.005f);
	nvgBezierTo(context, 970.77f, 75.005f, 958.14f, 73.415f, 943.37f, 69.445f);
	nvgBezierTo(context, 903.03f, 59.515f, 874.68f, 51.895f, 831.64f, 52.455f);
	nvgBezierTo(context, 758.42f, 52.455f, 691.48f, 95.255f, 662.33f, 156.965f);
	nvgBezierTo(context, 634.69f, 151.725f, 605.79f, 149.025f, 575.77f, 149.025f);
	nvgBezierTo(context, 562.19f, 149.025f, 548.13f, 149.585f, 534.16f, 150.615f);
	nvgBezierTo(context, 521.45f, 151.325f, 419.65f, 159.275f, 315.86f, 229.395f);
	nvgBezierTo(context, 240.34f, 204.855f, 190.95f, 154.115f, 167.92f, 77.005f);
	nvgBezierTo(context, 144.25f, 156.325f, 92.71f, 207.785f, 13.38f, 231.525f);
	nvgBezierTo(context, 92.71f, 255.185f, 147.59f, 314.115f, 167.04f, 393.045f);
	nvgBezierTo(context, 167.04f, 393.045f, 167.12f, 393.045f, 167.2f, 392.965f);
	nvgBezierTo(context, 116.3f, 489.525f, 116.14f, 604.515f, 168.31f, 698.625f);
	nvgBezierTo(context, 228.9f, 807.975f, 348.89f, 870.635f, 497.47f, 870.635f);
	nvgBezierTo(context, 531.14f, 870.635f, 566.64f, 867.455f, 602.93f, 861.185f);
	nvgBezierTo(context, 792.8f, 828.545f, 877.62f, 736.345f, 915.34f, 664.795f);
	nvgBezierTo(context, 979.43f, 543.135f, 950.76f, 411.155f, 923.76f, 352.305f);
	nvgBezierTo(context, 922.73f, 350.085f, 921.54f, 347.935f, 920.42f, 345.715f);
	nvgBezierTo(context, 960.92f, 324.595f, 1008.65f, 287.585f, 1033.5f, 224.535f);
	nvgBezierTo(context, 1033.5f, 224.535f, 1008.09f, 239.305f, 990.54f, 241.525f);
	nvgBezierTo(context, 990.54f, 241.525f, 1061.22f, 149.965f, 1036.84f, 51.965f);
	nvgLineTo(context, 1036.92f, 51.885f);
	nvgLineTo(context, 1036.92f, 51.895f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(35, 24, 21, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 596.9f, 812.025f);
	nvgBezierTo(context, 562.44f, 817.985f, 530.11f, 820.685f, 499.94f, 820.685f);
	nvgBezierTo(context, 305.86f, 820.685f, 199.6f, 706.335f, 183.88f, 579.435f);
	nvgBezierTo(context, 213.42f, 571.975f, 322.93f, 541.395f, 442.76f, 472.305f);
	nvgBezierTo(context, 442.76f, 472.305f, 450.7f, 449.035f, 454.12f, 405.365f);
	nvgBezierTo(context, 454.12f, 405.365f, 542.43f, 523.845f, 490.09f, 735.085f);
	nvgBezierTo(context, 490.09f, 735.085f, 581.89f, 696.415f, 621.2f, 578.485f);
	nvgBezierTo(context, 632.48f, 569.435f, 658.13f, 553.315f, 682.82f, 569.595f);
	nvgBezierTo(context, 698.62f, 579.915f, 704.66f, 604.775f, 697.11f, 628.515f);
	nvgBezierTo(context, 687.26f, 659.485f, 658.75f, 677.115f, 620.72f, 675.925f);
	nvgLineTo(context, 619.69f, 706.335f);
	nvgBezierTo(context, 621.44f, 706.335f, 623.1f, 706.415f, 624.77f, 706.415f);
	nvgBezierTo(context, 635.01f, 706.415f, 644.38f, 705.305f, 653.12f, 703.315f);
	nvgBezierTo(context, 662.33f, 727.295f, 684.57f, 759.375f, 724.27f, 774.705f);
	nvgBezierTo(context, 688.61f, 790.665f, 646.53f, 803.455f, 597.05f, 811.945f);
	nvgLineTo(context, 596.89f, 812.025f);
	nvgLineTo(context, 596.9f, 812.025f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(251, 233, 236, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 880.32f, 379.865f);
	nvgBezierTo(context, 917.17f, 460.075f, 939.08f, 652.085f, 768.51f, 757.545f);
	nvgBezierTo(context, 711.25f, 755.245f, 689.42f, 714.345f, 682.9f, 697.825f);
	nvgBezierTo(context, 705.53f, 684.485f, 719.59f, 663.995f, 725.94f, 643.985f);
	nvgBezierTo(context, 737.69f, 606.825f, 726.73f, 568.385f, 699.34f, 550.435f);
	nvgBezierTo(context, 675.91f, 535.105f, 651.69f, 536.535f, 631.6f, 544.085f);
	nvgBezierTo(context, 637.87f, 511.685f, 640.34f, 474.675f, 636.92f, 432.195f);
	nvgBezierTo(context, 636.92f, 432.195f, 614.29f, 570.685f, 538.21f, 651.845f);
	nvgBezierTo(context, 538.21f, 651.845f, 563.34f, 425.155f, 430.64f, 352.495f);
	nvgBezierTo(context, 430.64f, 352.495f, 427.23f, 405.545f, 412.85f, 454.535f);
	nvgBezierTo(context, 412.85f, 454.535f, 333.04f, 501.225f, 180.89f, 538.715f);
	nvgBezierTo(context, 183.03f, 492.255f, 198.09f, 446.885f, 224.14f, 405.195f);
	nvgBezierTo(context, 341.99f, 216.355f, 539.72f, 207.455f, 539.72f, 207.455f);
	nvgBezierTo(context, 552.82f, 206.425f, 565.61f, 205.945f, 578.08f, 205.945f);
	nvgBezierTo(context, 603.73f, 205.945f, 627.79f, 208.245f, 650.5f, 212.215f);
	nvgBezierTo(context, 639.62f, 299.805f, 705.61f, 375.405f, 799.56f, 381.995f);
	nvgBezierTo(context, 803.85f, 382.315f, 808.14f, 382.475f, 812.42f, 382.475f);
	nvgBezierTo(context, 826.24f, 382.475f, 839.9f, 380.965f, 853.08f, 378.025f);
	nvgBezierTo(context, 866.26f, 375.085f, 862.13f, 376.355f, 876.27f, 371.835f);
	nvgBezierTo(context, 877.62f, 374.535f, 879.13f, 377.235f, 880.4f, 380.015f);
	nvgLineTo(context, 880.32f, 379.855f);
	nvgLineTo(context, 880.32f, 379.865f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(251, 196, 0, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 895.49f, 281.155f);
	nvgLineTo(context, 929.08f, 284.175f);
	nvgBezierTo(context, 901.37f, 303.635f, 873.02f, 313.005f, 857.85f, 317.055f);
	nvgLineTo(context, 844.03f, 320.075f);
	nvgBezierTo(context, 834.18f, 322.215f, 824.26f, 323.335f, 814.41f, 323.335f);
	nvgBezierTo(context, 811.31f, 323.335f, 808.22f, 323.255f, 805.12f, 323.015f);
	nvgBezierTo(context, 771.69f, 320.715f, 742.78f, 306.415f, 723.8f, 282.755f);
	nvgBezierTo(context, 707.04f, 261.945f, 700.06f, 235.745f, 704.03f, 208.825f);
	nvgBezierTo(context, 712.77f, 149.665f, 769.39f, 103.925f, 834.58f, 103.365f);
	nvgBezierTo(context, 871.98f, 103.045f, 907.48f, 113.135f, 934.16f, 118.615f);
	nvgBezierTo(context, 952.5f, 122.345f, 969.58f, 125.925f, 985.78f, 125.925f);
	nvgBezierTo(context, 987.61f, 125.925f, 989.35f, 125.925f, 991.1f, 125.845f);
	nvgBezierTo(context, 977.44f, 206.055f, 895.57f, 281.175f, 895.57f, 281.175f);
	nvgLineTo(context, 895.49f, 281.175f);
	nvgLineTo(context, 895.49f, 281.155f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(251, 196, 0, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 934.16f, 118.605f);
	nvgBezierTo(context, 907.48f, 113.205f, 871.98f, 103.045f, 834.58f, 103.355f);
	nvgBezierTo(context, 769.3f, 103.915f, 712.68f, 149.655f, 704.03f, 208.815f);
	nvgBezierTo(context, 700.06f, 235.655f, 707.13f, 261.945f, 723.8f, 282.745f);
	nvgBezierTo(context, 742.78f, 306.335f, 771.69f, 320.625f, 805.12f, 323.005f);
	nvgLineTo(context, 806.47f, 323.005f);
	nvgBezierTo(context, 792.1f, 319.115f, 755.96f, 305.615f, 738.73f, 264.955f);
	nvgBezierTo(context, 712.68f, 203.495f, 754.06f, 114.545f, 881.83f, 128.205f);
	nvgBezierTo(context, 949.17f, 135.435f, 978.55f, 131.775f, 991.02f, 126.295f);
	nvgBezierTo(context, 991.02f, 126.135f, 991.02f, 125.975f, 991.1f, 125.815f);
	nvgBezierTo(context, 989.35f, 125.815f, 987.61f, 125.895f, 985.78f, 125.895f);
	nvgBezierTo(context, 969.58f, 125.895f, 952.51f, 122.325f, 934.16f, 118.585f);
	nvgLineTo(context, 934.16f, 118.605f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(255, 255, 255, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 482.5f, 644.185f);
	nvgBezierTo(context, 491.27f, 656.775f, 479.52f, 680.115f, 456.26f, 696.295f);
	nvgBezierTo(context, 433, 712.475f, 407.04f, 715.375f, 398.27f, 702.785f);
	nvgBezierTo(context, 389.5f, 690.185f, 401.25f, 666.855f, 424.51f, 650.665f);
	nvgBezierTo(context, 447.77f, 634.475f, 473.73f, 631.585f, 482.5f, 644.185f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(237, 122, 149, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 449.43f, 531.865f);
	nvgBezierTo(context, 458.32f, 583.805f, 416.32f, 639.705f, 355.64f, 656.705f);
	nvgBezierTo(context, 302.75f, 671.555f, 253.2f, 651.865f, 235.41f, 612.235f);
	nvgLineTo(context, 444.98f, 516.305f);
	nvgBezierTo(context, 446.89f, 521.225f, 448.47f, 526.395f, 449.43f, 531.795f);
	nvgLineTo(context, 449.43f, 531.875f);
	nvgLineTo(context, 449.43f, 531.865f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(35, 24, 21, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 386.38f, 569.825f);
	nvgBezierTo(context, 386.38f, 569.825f, 390.51f, 596.825f, 362.79f, 627.635f);
	nvgBezierTo(context, 362.79f, 627.635f, 413.3f, 611.915f, 416.47f, 556.165f);
	nvgLineTo(context, 386.37f, 569.825f);
	nvgLineTo(context, 386.38f, 569.825f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(255, 255, 255, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 168.128f, 306.209f);
	nvgBezierTo(context, 156.688f, 267.769f, 131.758f, 242.839f, 93.318f, 231.399f);
	nvgBezierTo(context, 131.758f, 219.959f, 156.688f, 195.029f, 168.128f, 156.589f);
	nvgBezierTo(context, 179.568f, 195.029f, 204.498f, 219.959f, 242.938f, 231.399f);
	nvgBezierTo(context, 204.498f, 242.839f, 179.568f, 267.769f, 168.128f, 306.209f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(251, 196, 0, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 430.64f, 352.505f);
	nvgBezierTo(context, 430.64f, 352.505f, 409.04f, 414.925f, 395.86f, 432.555f);
	nvgBezierTo(context, 395.86f, 432.555f, 303.03f, 470.835f, 241.72f, 483.145f);
	nvgBezierTo(context, 241.72f, 483.145f, 295.65f, 208.335f, 649.82f, 218.815f);
	nvgBezierTo(context, 649.98f, 216.275f, 650.18f, 214.775f, 650.5f, 212.235f);
	nvgBezierTo(context, 627.79f, 208.265f, 602.65f, 204.805f, 577, 204.805f);
	nvgBezierTo(context, 564.53f, 204.805f, 551.83f, 205.285f, 538.64f, 206.315f);
	nvgBezierTo(context, 538.64f, 206.315f, 340.9f, 215.205f, 223.06f, 404.055f);
	nvgBezierTo(context, 197.01f, 445.825f, 183.04f, 492.285f, 180.89f, 538.735f);
	nvgBezierTo(context, 185.65f, 537.545f, 233.04f, 525.695f, 286.42f, 508.055f);
	nvgBezierTo(context, 393.85f, 469.445f, 412.85f, 454.565f, 412.85f, 454.565f);
	nvgBezierTo(context, 427.22f, 405.565f, 430.64f, 352.525f, 430.64f, 352.525f);
	nvgFillColor(context, nvgRGBA(255, 255, 255, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 1030.33f, 932.175f);
	nvgBezierTo(context, 1040.1f, 924.475f, 1046.29f, 911.445f, 1046.21f, 896.205f);
	nvgBezierTo(context, 1046.21f, 896.205f, 1047.32f, 814.095f, 1047.32f, 812.985f);
	nvgBezierTo(context, 1047.32f, 787.495f, 1066.62f, 773.275f, 1066.62f, 773.195f);
	nvgLineTo(context, 21.24f, 773.195f);
	nvgBezierTo(context, 21.24f, 773.195f, 40.54f, 791.615f, 40.46f, 813.215f);
	nvgBezierTo(context, 40.46f, 813.215f, 41.25f, 1035.49f, 41.25f, 1035.4f);
	nvgBezierTo(context, 373.67f, 960.995f, 715.85f, 961.155f, 1048.19f, 1035.81f);
	nvgBezierTo(context, 1048.19f, 1035.81f, 1047.32f, 982.125f, 1030.24f, 932.175f);
	nvgLineTo(context, 1030.33f, 932.175f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(35, 24, 21, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 174.9f, 800.195f);
	nvgBezierTo(context, 148.38f, 800.675f, 121.77f, 801.145f, 95.25f, 801.705f);
	nvgBezierTo(context, 92.47f, 801.705f, 89.61f, 801.785f, 86.83f, 801.865f);
	nvgBezierTo(context, 84.92f, 801.865f, 82.94f, 801.945f, 81.03f, 802.025f);
	nvgBezierTo(context, 81.03f, 802.025f, 86.83f, 809.415f, 86.83f, 819.415f);
	nvgLineTo(context, 86.83f, 819.815f);
	nvgBezierTo(context, 86.75f, 879.775f, 86.59f, 939.725f, 86.51f, 999.605f);
	nvgLineTo(context, 86.83f, 999.605f);
	nvgBezierTo(context, 98.82f, 997.385f, 110.81f, 995.155f, 122.88f, 993.095f);
	nvgBezierTo(context, 139.87f, 990.155f, 156.87f, 987.455f, 173.86f, 984.835f);
	nvgBezierTo(context, 189.03f, 982.455f, 201.5f, 968.635f, 201.57f, 953.625f);
	nvgBezierTo(context, 201.89f, 911.455f, 202.13f, 869.215f, 202.44f, 827.045f);
	nvgBezierTo(context, 202.52f, 812.035f, 190.21f, 799.965f, 174.88f, 800.205f);
	nvgLineTo(context, 174.9f, 800.195f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(251, 196, 0, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 165.45f, 955.685f);
	nvgBezierTo(context, 151.24f, 957.595f, 137.1f, 959.495f, 122.96f, 961.645f);
	nvgBezierTo(context, 123.12f, 918.605f, 123.2f, 875.645f, 123.36f, 832.605f);
	nvgBezierTo(context, 137.57f, 831.965f, 151.79f, 831.415f, 166, 830.775f);
	nvgBezierTo(context, 165.84f, 872.385f, 165.68f, 913.995f, 165.52f, 955.615f);
	nvgLineTo(context, 165.44f, 955.695f);
	nvgLineTo(context, 165.45f, 955.685f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(35, 24, 21, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 305.22f, 798.365f);
	nvgBezierTo(context, 285.05f, 798.605f, 264.88f, 798.845f, 244.71f, 799.075f);
	nvgBezierTo(context, 229.46f, 799.235f, 217, 811.545f, 216.92f, 826.555f);
	nvgBezierTo(context, 216.84f, 868.325f, 216.68f, 910.095f, 216.6f, 951.785f);
	nvgBezierTo(context, 216.6f, 966.715f, 228.83f, 977.115f, 244.08f, 975.215f);
	nvgBezierTo(context, 264.17f, 972.755f, 284.26f, 970.605f, 304.35f, 968.625f);
	nvgBezierTo(context, 319.68f, 967.115f, 332.06f, 954.725f, 332.14f, 940.755f);
	nvgLineTo(context, 332.62f, 823.305f);
	nvgBezierTo(context, 332.62f, 809.325f, 320.31f, 798.135f, 305.06f, 798.295f);
	nvgLineTo(context, 305.22f, 798.375f);
	nvgLineTo(context, 305.22f, 798.365f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(251, 196, 0, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 295.69f, 941.465f);
	nvgBezierTo(context, 281.48f, 942.655f, 267.26f, 944.005f, 253.05f, 945.435f);
	nvgBezierTo(context, 253.21f, 906.205f, 253.45f, 866.895f, 253.61f, 827.665f);
	nvgBezierTo(context, 267.82f, 827.265f, 282.04f, 826.795f, 296.25f, 826.475f);
	nvgBezierTo(context, 296.09f, 864.835f, 295.93f, 903.105f, 295.69f, 941.465f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(35, 24, 21, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 565.93f, 797.015f);
	nvgLineTo(context, 505.42f, 797.015f);
	nvgBezierTo(context, 490.17f, 797.015f, 477.71f, 807.895f, 477.71f, 821.315f);
	nvgBezierTo(context, 477.71f, 866.815f, 477.55f, 912.405f, 477.47f, 957.905f);
	nvgBezierTo(context, 489.7f, 957.585f, 501.93f, 957.345f, 514.24f, 957.195f);
	nvgLineTo(context, 514.24f, 890.255f);
	nvgBezierTo(context, 528.53f, 890.175f, 542.75f, 890.095f, 557.04f, 890.175f);
	nvgLineTo(context, 557.04f, 957.035f);
	nvgBezierTo(context, 569.27f, 957.035f, 581.58f, 957.275f, 593.81f, 957.515f);
	nvgBezierTo(context, 593.81f, 912.095f, 593.73f, 866.665f, 593.65f, 821.245f);
	nvgBezierTo(context, 593.65f, 807.905f, 581.26f, 797.025f, 565.94f, 797.025f);
	nvgLineTo(context, 565.93f, 797.015f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(251, 196, 0, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 514.31f, 823.145f);
	nvgLineTo(context, 557.03f, 823.145f);
	nvgLineTo(context, 557.03f, 863.885f);
	nvgLineTo(context, 514.31f, 863.885f);
	nvgLineTo(context, 514.31f, 823.145f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(35, 24, 21, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 717.92f, 866.905f);
	nvgBezierTo(context, 699.26f, 866.265f, 680.68f, 865.715f, 662.01f, 865.315f);
	nvgBezierTo(context, 662.01f, 851.575f, 662.01f, 837.755f, 661.93f, 824.025f);
	nvgBezierTo(context, 688.14f, 824.345f, 714.26f, 824.815f, 740.47f, 825.295f);
	nvgBezierTo(context, 740.47f, 816.165f, 740.47f, 807.035f, 740.39f, 797.895f);
	nvgBezierTo(context, 711.25f, 797.655f, 682.1f, 797.415f, 652.96f, 797.255f);
	nvgBezierTo(context, 637.71f, 797.255f, 625.32f, 807.975f, 625.32f, 821.395f);
	nvgBezierTo(context, 625.32f, 836.485f, 625.32f, 851.575f, 625.4f, 866.655f);
	nvgBezierTo(context, 625.4f, 880.075f, 637.87f, 891.195f, 653.19f, 891.595f);
	nvgBezierTo(context, 670.42f, 892.075f, 687.65f, 892.705f, 704.89f, 893.345f);
	nvgBezierTo(context, 704.89f, 907.325f, 704.97f, 921.215f, 705.05f, 935.195f);
	nvgBezierTo(context, 678.69f, 933.685f, 652.24f, 932.655f, 625.88f, 931.855f);
	nvgLineTo(context, 625.88f, 958.295f);
	nvgBezierTo(context, 655.26f, 959.245f, 684.72f, 960.755f, 714.03f, 962.825f);
	nvgBezierTo(context, 729.36f, 963.935f, 741.74f, 953.695f, 741.67f, 939.715f);
	nvgBezierTo(context, 741.43f, 922.565f, 741.19f, 905.405f, 740.88f, 888.255f);
	nvgBezierTo(context, 740.72f, 876.815f, 730.48f, 867.215f, 717.85f, 866.815f);
	nvgLineTo(context, 717.93f, 866.895f);
	nvgLineTo(context, 717.92f, 866.905f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(255, 255, 255, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 848.32f, 873.015f);
	nvgBezierTo(context, 829.74f, 871.905f, 811.08f, 870.875f, 792.49f, 869.995f);
	nvgBezierTo(context, 792.49f, 855.465f, 792.33f, 841.005f, 792.25f, 826.475f);
	nvgBezierTo(context, 818.46f, 827.185f, 844.58f, 827.985f, 870.71f, 828.855f);
	nvgBezierTo(context, 870.71f, 819.085f, 870.63f, 809.245f, 870.55f, 799.475f);
	nvgBezierTo(context, 841.41f, 798.995f, 812.26f, 798.685f, 783.12f, 798.365f);
	nvgBezierTo(context, 767.87f, 798.205f, 755.48f, 809.405f, 755.56f, 823.375f);
	nvgBezierTo(context, 755.56f, 839.095f, 755.72f, 854.825f, 755.8f, 870.545f);
	nvgBezierTo(context, 755.8f, 884.525f, 768.27f, 896.515f, 783.59f, 897.465f);
	nvgBezierTo(context, 800.82f, 898.495f, 817.98f, 899.685f, 835.21f, 900.955f);
	nvgBezierTo(context, 835.21f, 915.805f, 835.37f, 930.655f, 835.45f, 945.505f);
	nvgBezierTo(context, 809.16f, 942.805f, 782.8f, 940.585f, 756.44f, 938.595f);
	nvgBezierTo(context, 756.44f, 947.805f, 756.52f, 956.935f, 756.6f, 966.155f);
	nvgBezierTo(context, 785.98f, 968.695f, 815.29f, 971.715f, 844.51f, 975.285f);
	nvgBezierTo(context, 859.76f, 977.195f, 872.07f, 966.785f, 871.99f, 951.775f);
	nvgBezierTo(context, 871.75f, 933.355f, 871.43f, 914.925f, 871.2f, 896.505f);
	nvgBezierTo(context, 871.04f, 884.195f, 860.8f, 873.635f, 848.25f, 872.915f);
	nvgLineTo(context, 848.33f, 872.995f);
	nvgLineTo(context, 848.32f, 873.015f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(255, 255, 255, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 462.29f, 871.665f);
	nvgBezierTo(context, 462.29f, 854.905f, 462.29f, 838.235f, 462.37f, 821.475f);
	nvgBezierTo(context, 462.37f, 808.055f, 450.06f, 797.255f, 434.73f, 797.335f);
	nvgBezierTo(context, 414.8f, 797.415f, 394.87f, 797.575f, 374.93f, 797.735f);
	nvgBezierTo(context, 359.68f, 797.815f, 347.22f, 809.175f, 347.14f, 823.145f);
	nvgBezierTo(context, 346.98f, 870.395f, 346.74f, 917.725f, 346.58f, 964.975f);
	nvgBezierTo(context, 358.81f, 964.025f, 371.04f, 963.145f, 383.27f, 962.355f);
	nvgBezierTo(context, 383.43f, 916.455f, 383.59f, 870.635f, 383.75f, 824.735f);
	nvgBezierTo(context, 397.96f, 824.495f, 412.18f, 824.255f, 426.47f, 824.095f);
	nvgBezierTo(context, 426.47f, 837.835f, 426.47f, 851.655f, 426.39f, 865.385f);
	nvgBezierTo(context, 413.92f, 865.705f, 401.53f, 866.025f, 389.07f, 866.415f);
	nvgBezierTo(context, 389.07f, 866.575f, 426.23f, 915.655f, 426.16f, 959.965f);
	nvgBezierTo(context, 438.39f, 959.405f, 450.62f, 958.855f, 462.93f, 958.455f);
	nvgBezierTo(context, 462.93f, 958.455f, 461.18f, 928.355f, 440.22f, 891.595f);
	nvgBezierTo(context, 452.45f, 891.275f, 462.3f, 882.385f, 462.38f, 871.745f);
	nvgLineTo(context, 462.3f, 871.665f);
	nvgLineTo(context, 462.29f, 871.665f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(251, 196, 0, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 1001.1f, 893.185f);
	nvgBezierTo(context, 1001.1f, 868.485f, 1001.02f, 843.795f, 1000.94f, 819.095f);
	nvgBezierTo(context, 1001.02f, 809.245f, 1006.74f, 802.025f, 1006.74f, 802.025f);
	nvgBezierTo(context, 1004.83f, 802.025f, 1002.85f, 801.945f, 1000.94f, 801.865f);
	nvgBezierTo(context, 998.16f, 801.865f, 995.3f, 801.785f, 992.52f, 801.705f);
	nvgBezierTo(context, 966.23f, 801.145f, 939.95f, 800.675f, 913.58f, 800.195f);
	nvgBezierTo(context, 898.33f, 799.955f, 886.02f, 812.025f, 886.02f, 827.035f);
	nvgBezierTo(context, 886.26f, 878.335f, 886.5f, 929.555f, 886.66f, 980.855f);
	nvgBezierTo(context, 898.81f, 982.525f, 910.96f, 984.345f, 923.19f, 986.255f);
	nvgBezierTo(context, 923.03f, 934.475f, 922.79f, 882.705f, 922.63f, 830.845f);
	nvgBezierTo(context, 936.84f, 831.405f, 951.06f, 832.035f, 965.27f, 832.675f);
	nvgBezierTo(context, 965.27f, 848.955f, 965.35f, 865.235f, 965.43f, 881.435f);
	nvgBezierTo(context, 953.04f, 880.405f, 940.65f, 879.445f, 928.27f, 878.495f);
	nvgBezierTo(context, 928.27f, 878.015f, 965.67f, 939.805f, 965.75f, 993.165f);
	nvgBezierTo(context, 977.9f, 995.225f, 989.97f, 997.455f, 1002.12f, 999.675f);
	nvgBezierTo(context, 1002.12f, 999.835f, 1000.29f, 961.715f, 979.25f, 914.385f);
	nvgBezierTo(context, 991.4f, 915.815f, 1001.17f, 906.365f, 1001.17f, 893.185f);
	nvgLineTo(context, 1001.09f, 893.185f);
	nvgLineTo(context, 1001.1f, 893.185f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(255, 255, 255, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 41.41f, 1077.65f);
	nvgBezierTo(context, 187.85f, 1044.86f, 334.6f, 1028.18f, 463.48f, 1023.18f);
	nvgLineTo(context, 427.43f, 1002.37f);
	nvgBezierTo(context, 298.07f, 1008.96f, 169.02f, 1026.27f, 41.33f, 1054.38f);
	nvgLineTo(context, 41.33f, 1077.64f);
	nvgLineTo(context, 41.41f, 1077.64f);
	nvgLineTo(context, 41.41f, 1077.65f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(251, 196, 0, 255));
	nvgFill(context);
	nvgBeginPath(context);
	nvgMoveTo(context, 624.69f, 1023.19f);
	nvgBezierTo(context, 767.15f, 1027.56f, 909.3f, 1045.11f, 1049.78f, 1076);
	nvgBezierTo(context, 1049.62f, 1069.4f, 1049.3f, 1061.79f, 1048.99f, 1054.32f);
	nvgBezierTo(context, 920.66f, 1026.05f, 790.9f, 1008.74f, 660.83f, 1002.31f);
	nvgLineTo(context, 624.7f, 1023.2f);
	nvgLineTo(context, 624.69f, 1023.19f);
	nvgClosePath(context);
	nvgFillColor(context, nvgRGBA(251, 196, 0, 255));
	nvgFill(context);
}

VGTexture::VGTexture(NVGcontext* context, NVGLUframebuffer* framebuffer, const bgfx::TextureInfo& info, uint64_t flags)
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

NVGcontext* VGTexture::getContext() const {
	return _context;
}

NVGLUframebuffer* VGTexture::getFramebuffer() const {
	return _framebuffer;
}

NS_DORA_END
