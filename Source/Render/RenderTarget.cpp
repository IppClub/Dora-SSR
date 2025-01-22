/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Render/RenderTarget.h"

#include "Basic/Application.h"
#include "Basic/Content.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Cache/TextureCache.h"
#include "Common/Async.h"
#include "Node/Sprite.h"
#include "Render/Camera.h"
#include "Render/View.h"
#include "lodepng.h"
using namespace lodepnglib;

NS_DORA_BEGIN

std::stack<RenderTarget*> RenderTarget::_applyingStack;

RenderTarget::RenderTarget(uint16_t width, uint16_t height, bgfx::TextureFormat::Enum format)
	: _textureWidth(width)
	, _textureHeight(height)
	, _format(format)
	, _frameBufferHandle(BGFX_INVALID_HANDLE)
	, _dummy(Node::create(false)) {
}

RenderTarget::~RenderTarget() {
	if (bgfx::isValid(_frameBufferHandle)) {
		bgfx::destroy(_frameBufferHandle);
		_frameBufferHandle = BGFX_INVALID_HANDLE;
	}
}

uint16_t RenderTarget::getWidth() const noexcept {
	return _textureWidth;
}

uint16_t RenderTarget::getHeight() const noexcept {
	return _textureHeight;
}

void RenderTarget::setCamera(Camera* camera) {
	_camera = camera;
}

Camera* RenderTarget::getCamera() const noexcept {
	return _camera;
}

Texture2D* RenderTarget::getTexture() const noexcept {
	return _texture;
}

Texture2D* RenderTarget::getDepthTexture() const noexcept {
	return _depthTexture;
}

bool RenderTarget::init() {
	if (!Object::init()) return false;

	const uint64_t textureFlags = BGFX_SAMPLER_U_CLAMP | BGFX_SAMPLER_V_CLAMP | BGFX_TEXTURE_RT;
	bgfx::TextureHandle textureHandle = bgfx::createTexture2D(_textureWidth, _textureHeight, false, 1, _format, textureFlags);
	if (!bgfx::isValid(textureHandle)) return false;

	const uint64_t depthTextureFlags = BGFX_TEXTURE_RT | BGFX_TEXTURE_RT_WRITE_ONLY;
	const auto depthTextureFormat = bgfx::TextureFormat::D24S8;
	bgfx::TextureHandle depthTextureHandle = bgfx::createTexture2D(_textureWidth, _textureHeight, false, 1, depthTextureFormat, depthTextureFlags);
	if (!bgfx::isValid(depthTextureHandle)) return false;

	bgfx::TextureHandle texHandles[] = {textureHandle, depthTextureHandle};
	_frameBufferHandle = bgfx::createFrameBuffer(2, texHandles);
	if (!bgfx::isValid(_frameBufferHandle)) return false;

	bgfx::TextureInfo info;
	bgfx::calcTextureSize(info,
		_textureWidth, _textureHeight,
		0, false, false, 1, _format);
	_texture = Texture2D::create(textureHandle, info, textureFlags);

	bgfx::calcTextureSize(info,
		_textureWidth, _textureHeight,
		0, false, false, 1, depthTextureFormat);
	_depthTexture = Texture2D::create(depthTextureHandle, info, depthTextureFlags);

	return true;
}

void RenderTarget::renderAfterClear(Node* target, bool clear, Color color, float depth, uint8_t stencil) {
	SharedRendererManager.flush();
	SharedView.pushFront("RenderTarget"_slice, [&]() {
		bgfx::ViewId viewId = SharedView.getId();
		bgfx::setViewFrameBuffer(viewId, _frameBufferHandle);
		bgfx::setViewRect(viewId, 0, 0, _textureWidth, _textureHeight);
		if (clear) {
			bgfx::setViewClear(viewId, BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH | BGFX_CLEAR_STENCIL,
				color.toRGBA(), depth, stencil);
		} else {
			bgfx::setViewClear(viewId, BGFX_CLEAR_NONE);
		}
		Matrix viewProj;
		switch (bgfx::getCaps()->rendererType) {
			case bgfx::RendererType::OpenGL:
			case bgfx::RendererType::OpenGLES: {
				if (_camera) {
					Matrix tmpVP;
					Matrix revertY;
					bx::mtxScale(revertY.m, 1.0f, -1.0f, 1.0f);
					if (_camera->hasProjection())
						tmpVP = _camera->getView();
					else
						Matrix::mulMtx(tmpVP, SharedView.getProjection(), _camera->getView());
					Matrix::mulMtx(viewProj, revertY, tmpVP);
				} else {
					bx::mtxOrtho(viewProj.m, 0, s_cast<float>(_textureWidth), s_cast<float>(_textureHeight), 0, -1000.0f, 1000.0f, 0, bgfx::getCaps()->homogeneousDepth);
				}
				break;
			}
			default: {
				if (_camera) {
					if (_camera->hasProjection())
						viewProj = _camera->getView();
					else
						Matrix::mulMtx(viewProj, SharedView.getProjection(), _camera->getView());
				} else {
					bx::mtxOrtho(viewProj.m, 0, s_cast<float>(_textureWidth), 0, s_cast<float>(_textureHeight), -1000.0f, 1000.0f, 0, bgfx::getCaps()->homogeneousDepth);
				}
				break;
			}
		}
		SharedDirector.pushViewProjection(viewProj, [&]() {
			bgfx::setViewTransform(viewId, nullptr, viewProj.m);
			_applyingStack.push(this);
			renderOnly(target);
			_applyingStack.pop();
		});
	});
}

void RenderTarget::renderOnly(Node* target) {
	if (!target) return;
	Node* transformTarget = target->getTransformTarget();
	target->setTransformTarget(_dummy);
	target->markDirty();
	target->visitInner();
	SharedRendererManager.flush();
	target->setTransformTarget(transformTarget);
}

void RenderTarget::render(Node* target) {
	renderAfterClear(target, false);
}

void RenderTarget::renderWithClear(Color color, float depth, uint8_t stencil) {
	renderAfterClear(nullptr, true, color, depth, stencil);
}

void RenderTarget::renderWithClear(Node* target, Color color, float depth, uint8_t stencil) {
	renderAfterClear(target, true, color, depth, stencil);
}

void RenderTarget::saveAsync(String filename, const std::function<void(bool)>& callback) {
	AssertIf((bgfx::getCaps()->supported & BGFX_CAPS_TEXTURE_READ_BACK) == 0, "texture read back not supported.");

	uint64_t extraFlags = 0;
	switch (bgfx::getCaps()->rendererType) {
		case bgfx::RendererType::Direct3D11:
		case bgfx::RendererType::Direct3D12:
		case bgfx::RendererType::OpenGLES:
			extraFlags = BGFX_TEXTURE_BLIT_DST;
			break;
		default:
			break;
	}
	bgfx::TextureHandle textureHandle;
	if (extraFlags) {
		const uint64_t textureFlags = BGFX_SAMPLER_U_CLAMP | BGFX_SAMPLER_V_CLAMP | BGFX_TEXTURE_READ_BACK;
		textureHandle = bgfx::createTexture2D(_textureWidth, _textureHeight, false, 1, _format, textureFlags | extraFlags);
		SharedView.pushBack("SaveTarget"_slice, [&]() {
			bgfx::blit(SharedView.getId(), textureHandle, 0, 0, _texture->getHandle());
		});
	} else {
		textureHandle = _texture->getHandle();
	}
	uint8_t* data = new uint8_t[_texture->getInfo().storageSize];
	uint32_t frame = bgfx::readTexture(textureHandle, data);
	uint32_t width = s_cast<uint32_t>(_textureWidth);
	uint32_t height = s_cast<uint32_t>(_textureHeight);
	std::string file(filename);
	SharedDirector.getSystemScheduler()->schedule([frame, textureHandle, extraFlags, data, width, height, file, callback](double deltaTime) {
		DORA_UNUSED_PARAM(deltaTime);
		if (frame <= SharedApplication.getFrame()) {
			if (extraFlags) {
				bgfx::destroy(textureHandle);
			}
			SharedAsyncThread.run(
				[data, width, height]() {
					unsigned error;
					LodePNGState state;
					lodepng_state_init(&state);
					uint8_t* out = nullptr;
					size_t outSize = 0;
					error = lodepng_encode(&out, &outSize, data, width, height, &state);
					lodepng_state_cleanup(&state);
					delete[] data;
					return Values::alloc(out, outSize);
				},
				[callback, file](Own<Values> values) {
					uint8_t* out;
					size_t outSize;
					values->get(out, outSize);
					Slice content(r_cast<char*>(out), outSize);
					SharedContent.saveAsync(file, content, [out, callback](bool success) {
						::free(out);
						callback(success);
					});
				});
			return true;
		}
		return false;
	});
}

RenderTarget* RenderTarget::getCurrent() {
	if (_applyingStack.empty()) {
		return nullptr;
	}
	return _applyingStack.top();
}

NS_DORA_END
