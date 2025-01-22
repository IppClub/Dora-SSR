/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/VGNode.h"

#include "Node/Sprite.h"
#include "Render/VGRender.h"
#include "Render/View.h"
#include "nanovg/nanovg_bgfx.h"

NS_DORA_BEGIN

VGNode::VGNode(float width, float height, float scale, int edgeAA)
	: _frameWidth(width)
	, _frameHeight(height)
	, _frameScale(scale)
	, _edgeAA(edgeAA) { }

Sprite* VGNode::getSurface() const noexcept {
	return _surface;
}

bool VGNode::init() {
	if (!Node::init()) return false;
	NVGcontext* context = nvgCreate(_edgeAA, 0);
	NVGLUframebuffer* framebuffer = nvgluCreateFramebuffer(context,
		s_cast<int>(_frameWidth * _frameScale),
		s_cast<int>(_frameHeight * _frameScale), 0);
	bgfx::TextureInfo info;
	bgfx::calcTextureSize(info,
		s_cast<uint16_t>(_frameWidth * _frameScale),
		s_cast<uint16_t>(_frameHeight * _frameScale),
		0, false, false, 1, bgfx::TextureFormat::RGBA8);
	uint64_t flags = BGFX_TEXTURE_RT | BGFX_SAMPLER_U_CLAMP | BGFX_SAMPLER_V_CLAMP;
	_surface = Sprite::create(VGTexture::create(context, framebuffer, info, flags));
	_surface->addTo(this);
	return true;
}

void VGNode::cleanup() {
	if (_flags.isOff(Node::Cleanup)) {
		Node::cleanup();
		_surface = nullptr;
	}
}

void VGNode::render(const std::function<void()>& func) {
	VGTexture* texture = s_cast<VGTexture*>(_surface->getTexture());
	NVGLUframebuffer* framebuffer = texture->getFramebuffer();
	NVGcontext* context = texture->getContext();
	SharedView.pushFront("VGNode"_slice, [&]() {
		bgfx::ViewId viewId = SharedView.getId();
		bgfx::setViewClear(viewId,
			BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH | BGFX_CLEAR_STENCIL,
			0x0);
		nvgluSetViewFramebuffer(viewId, framebuffer);
		bgfx::setViewRect(viewId, 0, 0, texture->getWidth(), texture->getHeight());
		nvgluBindFramebuffer(framebuffer);
		nvgBeginFrame(context, _frameWidth, _frameHeight, _frameScale);
		nvg::BindContext(context);
		switch (bgfx::getCaps()->rendererType) {
			case bgfx::RendererType::OpenGL:
			case bgfx::RendererType::OpenGLES:
				nvgScale(context, 1.0f, -1.0f);
				nvgTranslate(context, 0.0f, -_frameHeight);
				break;
			default:
				break;
		}
		func();
		nvg::BindContext(nullptr);
		nvgEndFrame(context);
		nvgluBindFramebuffer(nullptr);
	});
}

NS_DORA_END
