/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

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

static bool needsReadbackStaging(const bgfx::Caps* caps) {
	switch (caps->rendererType) {
		case bgfx::RendererType::Direct3D11:
		case bgfx::RendererType::Direct3D12:
		case bgfx::RendererType::Metal:
			return true;
		case bgfx::RendererType::OpenGLES:
			// Prefer a read-back staging texture when the active GLES backend advertises
			// blit support. Backends without blit can still use bgfx's direct FBO readback.
			return (caps->supported & BGFX_CAPS_TEXTURE_BLIT) != 0;
		default:
			return false;
	}
}

RenderTarget::RenderTarget(uint16_t width, uint16_t height, bgfx::TextureFormat::Enum format,
	uint64_t textureFlags)
	: _textureWidth(width)
	, _textureHeight(height)
	, _format(format)
	, _textureFlags(textureFlags)
	, _frameBufferHandle(BGFX_INVALID_HANDLE)
	, _dummy(Node::create(false)) {
}

RenderTarget::RenderTarget(std::vector<Texture2D*> colorTextures, Texture2D* depthTexture)
	: RenderTarget([&]() {
		std::vector<Attachment> attachments;
		attachments.reserve(colorTextures.size());
		for (auto* texture : colorTextures) attachments.push_back({texture});
		return attachments;
	}(), depthTexture ? std::optional<Attachment>(Attachment{depthTexture}) : std::nullopt) { }

RenderTarget::RenderTarget(std::vector<Attachment> colorAttachments,
	std::optional<Attachment> depthAttachment)
	: _textureWidth(0)
	, _textureHeight(0)
	, _format(!colorAttachments.empty() && colorAttachments.front().texture
		? colorAttachments.front().texture->getInfo().format
		: depthAttachment && depthAttachment->texture
			? depthAttachment->texture->getInfo().format : bgfx::TextureFormat::RGBA8)
	, _texture(colorAttachments.empty() ? nullptr : colorAttachments.front().texture)
	, _depthTexture(depthAttachment ? depthAttachment->texture : nullptr)
	, _colorAttachments(std::move(colorAttachments))
	, _depthAttachment(depthAttachment)
	, _externalAttachments(true)
	, _frameBufferHandle(BGFX_INVALID_HANDLE)
	, _dummy(Node::create(false)) {
	const Attachment* first = !_colorAttachments.empty() ? &_colorAttachments.front()
		: _depthAttachment ? &*_depthAttachment : nullptr;
	if (first && first->texture) {
		_textureWidth = s_cast<uint16_t>(std::max(1, first->texture->getWidth() >> first->mip));
		_textureHeight = s_cast<uint16_t>(std::max(1, first->texture->getHeight() >> first->mip));
	}
	_colorTextures.reserve(_colorAttachments.size());
	for (const auto& attachment : _colorAttachments) _colorTextures.emplace_back(attachment.texture);
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
	if (_externalAttachments) {
		if (_colorTextures.empty() && !_depthTexture) return false;
		std::vector<bgfx::Attachment> attachments;
		attachments.reserve(_colorAttachments.size() + (_depthAttachment ? 1 : 0));
		auto append = [&](const Attachment& attachment) {
			if (!attachment.texture || !bgfx::isValid(attachment.texture->getHandle())) return false;
			const auto& info = attachment.texture->getInfo();
			if (attachment.mip >= info.numMips
				|| std::max(1, attachment.texture->getWidth() >> attachment.mip) != _textureWidth
				|| std::max(1, attachment.texture->getHeight() >> attachment.mip) != _textureHeight)
				return false;
			uint16_t layers = info.cubeMap ? 6 : info.depth > 1
				? std::max<uint16_t>(1, info.depth >> attachment.mip) : info.numLayers;
			if (attachment.layer >= layers) return false;
			bgfx::Attachment value;
			value.init(attachment.texture->getHandle(), bgfx::Access::Write,
				attachment.layer, 1, attachment.mip, attachment.resolve);
			attachments.push_back(value);
			return true;
		};
		for (const auto& attachment : _colorAttachments)
			if (!append(attachment)) return false;
		if (_depthAttachment && !append(*_depthAttachment)) return false;
		if (attachments.size() > std::numeric_limits<uint8_t>::max()) return false;
		_frameBufferHandle = bgfx::createFrameBuffer(s_cast<uint8_t>(attachments.size()), attachments.data(), false);
		return bgfx::isValid(_frameBufferHandle);
	}

	const uint64_t textureFlags = BGFX_SAMPLER_U_CLAMP | BGFX_SAMPLER_V_CLAMP
		| BGFX_TEXTURE_RT | _textureFlags;
	bgfx::TextureHandle textureHandle = bgfx::createTexture2D(_textureWidth, _textureHeight, false, 1, _format, textureFlags);
	if (!bgfx::isValid(textureHandle)) return false;

	const uint64_t depthTextureFlags = BGFX_TEXTURE_RT | BGFX_TEXTURE_RT_WRITE_ONLY
		| (_textureFlags & BGFX_TEXTURE_RT_MSAA_MASK);
	const auto depthTextureFormat = bgfx::TextureFormat::D24S8;
	bgfx::TextureHandle depthTextureHandle = bgfx::createTexture2D(_textureWidth, _textureHeight, false, 1, depthTextureFormat, depthTextureFlags);
	if (!bgfx::isValid(depthTextureHandle)) {
		bgfx::destroy(textureHandle);
		return false;
	}

	bgfx::TextureHandle texHandles[] = {textureHandle, depthTextureHandle};
	_frameBufferHandle = bgfx::createFrameBuffer(2, texHandles);
	if (!bgfx::isValid(_frameBufferHandle)) {
		bgfx::destroy(textureHandle);
		bgfx::destroy(depthTextureHandle);
		return false;
	}

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

void RenderTarget::renderAfterClear(Node* target, uint16_t clearFlags, Color color, float depth, uint8_t stencil) {
	submitAfterClear([&]() { renderOnly(target); }, clearFlags, color, depth, stencil);
}

void RenderTarget::submitAfterClear(const std::function<void()>& commands, uint16_t clearFlags,
	Color color, float depth, uint8_t stencil) {
	SharedRendererManager.flush();
	SharedView.pushFront("RenderTarget"_slice, [&]() {
		bgfx::ViewId viewId = SharedView.getId();
		bgfx::setViewFrameBuffer(viewId, _frameBufferHandle);
		bgfx::setViewRect(viewId, 0, 0, _textureWidth, _textureHeight);
		bgfx::setViewClear(viewId, clearFlags, color.toRGBA(), depth, stencil);
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
			// A touched view is required for clear-only passes and for framebuffer
			// resolve operations such as Love Canvas manual mipmap generation.
			bgfx::touch(viewId);
			_applyingStack.push(this);
			if (commands) commands();
			SharedRendererManager.flush();
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
	renderAfterClear(target, BGFX_CLEAR_NONE);
}

void RenderTarget::submit(const std::function<void()>& commands) {
	submitAfterClear(commands, BGFX_CLEAR_NONE);
}

void RenderTarget::submitWithClearFlags(const std::function<void()>& commands,
	uint16_t clearFlags, Color color, float depth, uint8_t stencil) {
	submitAfterClear(commands, clearFlags, color, depth, stencil);
}

void RenderTarget::renderWithClear(Color color, float depth, uint8_t stencil) {
	renderAfterClear(nullptr, BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH | BGFX_CLEAR_STENCIL,
		color, depth, stencil);
}

void RenderTarget::renderWithClear(Node* target, Color color, float depth, uint8_t stencil) {
	renderAfterClear(target, BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH | BGFX_CLEAR_STENCIL,
		color, depth, stencil);
}

void RenderTarget::renderWithClearFlags(Node* target, uint16_t clearFlags, Color color,
	float depth, uint8_t stencil) {
	renderAfterClear(target, clearFlags, color, depth, stencil);
}

bool RenderTarget::readPixelsAsync(const std::function<void(uint16_t, uint16_t, std::vector<uint8_t>)>& callback) {
	if (!callback) {
		Warn("RenderTarget async readback requires a completion callback.");
		return false;
	}
	if (!_texture) {
		Warn("RenderTarget async readback failed because the target has no color texture.");
		return false;
	}
	if ((_textureFlags & BGFX_TEXTURE_RT_WRITE_ONLY) != 0) {
		Warn("RenderTarget async readback is unavailable for a write-only target.");
		return false;
	}
	const auto* caps = bgfx::getCaps();
	if ((caps->supported & BGFX_CAPS_TEXTURE_READ_BACK) == 0) {
		Warn("RenderTarget async readback is unsupported by renderer {}.",
			bgfx::getRendererName(caps->rendererType));
		return false;
	}
	const uint64_t extraFlags = needsReadbackStaging(caps) ? BGFX_TEXTURE_BLIT_DST : 0;
	if (extraFlags && (caps->supported & BGFX_CAPS_TEXTURE_BLIT) == 0) {
		Warn("RenderTarget async readback requires texture blit support on renderer {}.",
			bgfx::getRendererName(caps->rendererType));
		return false;
	}
	bgfx::TextureHandle textureHandle;
	if (extraFlags) {
		const uint64_t textureFlags = BGFX_SAMPLER_U_CLAMP | BGFX_SAMPLER_V_CLAMP | BGFX_TEXTURE_READ_BACK;
		textureHandle = bgfx::createTexture2D(_textureWidth, _textureHeight, false, 1, _format, textureFlags | extraFlags);
		if (!bgfx::isValid(textureHandle)) {
			Warn("RenderTarget async readback failed to create a {}x{} staging texture.",
				_textureWidth, _textureHeight);
			return false;
		}
		SharedView.pushBack("SaveTarget"_slice, [&]() {
			bgfx::blit(SharedView.getId(), textureHandle, 0, 0, _texture->getHandle());
		});
	} else {
		textureHandle = _texture->getHandle();
	}
	if (!bgfx::isValid(textureHandle)) {
		Warn("RenderTarget async readback received an invalid color texture handle.");
		return false;
	}
	auto data = std::make_shared<std::vector<uint8_t>>(_texture->getInfo().storageSize);
	uint32_t frame = bgfx::readTexture(textureHandle, data->data());
	uint16_t width = _textureWidth;
	uint16_t height = _textureHeight;
	SharedDirector.getSystemScheduler()->schedule([frame, textureHandle, extraFlags, data, width, height, callback](double deltaTime) mutable {
		DORA_UNUSED_PARAM(deltaTime);
		if (frame <= SharedApplication.getFrame()) {
			if (extraFlags) {
				bgfx::destroy(textureHandle);
			}
			callback(width, height, std::move(*data));
			return true;
		}
		return false;
	});
	return true;
}

RenderTarget::ReadPixelsResult RenderTarget::readPixelsSync(std::vector<uint8_t>& pixels) {
	uint16_t layer = 0;
	uint8_t mip = 0;
	if (_externalAttachments && !_colorAttachments.empty()) {
		layer = _colorAttachments.front().layer;
		mip = _colorAttachments.front().mip;
	}
	return readPixelsSync(pixels, layer, mip);
}

RenderTarget::ReadPixelsResult RenderTarget::readPixelsSync(std::vector<uint8_t>& pixels,
	uint16_t layer, uint8_t mip) {
	pixels.clear();
	if (!_texture)
		return ReadPixelsResult::NoTexture;
	if ((_textureFlags & BGFX_TEXTURE_RT_WRITE_ONLY) != 0)
		return ReadPixelsResult::WriteOnly;
	const auto* caps = bgfx::getCaps();
	if ((caps->supported & BGFX_CAPS_TEXTURE_READ_BACK) == 0)
		return ReadPixelsResult::Unsupported;
	if (SharedView.hasActiveView())
		return ReadPixelsResult::ActiveView;

	const auto& sourceInfo = _texture->getInfo();
	if (mip >= sourceInfo.numMips)
		return ReadPixelsResult::InvalidTexture;
	const uint16_t layers = sourceInfo.cubeMap ? 6
		: sourceInfo.depth > 1 ? std::max<uint16_t>(1, sourceInfo.depth >> mip)
		: sourceInfo.numLayers;
	if (layer >= layers)
		return ReadPixelsResult::InvalidTexture;
	const uint16_t width = std::max<uint16_t>(1, _texture->getWidth() >> mip);
	const uint16_t height = std::max<uint16_t>(1, _texture->getHeight() >> mip);

	bool needsStaging = layer != 0 || mip != 0 || sourceInfo.numMips > 1
		|| sourceInfo.numLayers > 1 || sourceInfo.depth > 1 || sourceInfo.cubeMap;
	needsStaging = needsStaging || needsReadbackStaging(caps);

	bgfx::TextureHandle textureHandle = _texture->getHandle();
	if (!bgfx::isValid(textureHandle))
		return ReadPixelsResult::InvalidTexture;
	if (needsStaging) {
		if ((caps->supported & BGFX_CAPS_TEXTURE_BLIT) == 0)
			return ReadPixelsResult::Unsupported;
		const uint64_t flags = BGFX_SAMPLER_U_CLAMP | BGFX_SAMPLER_V_CLAMP
			| BGFX_TEXTURE_READ_BACK | BGFX_TEXTURE_BLIT_DST;
		textureHandle = bgfx::createTexture2D(width, height, false, 1, _format, flags);
		if (!bgfx::isValid(textureHandle))
			return ReadPixelsResult::StagingTextureFailed;
		SharedView.pushBack("ReadTarget"_slice, [&]() {
			bgfx::blit(SharedView.getId(), textureHandle, 0, 0, 0, 0,
				_texture->getHandle(), mip, 0, 0, layer, width, height, 1);
		});
	}

	bgfx::TextureInfo readInfo;
	bgfx::calcTextureSize(readInfo, width, height, 1, false, false, 1, _format);
	pixels.resize(readInfo.storageSize);
	const uint32_t readyFrame = bgfx::readTexture(textureHandle, pixels.data(),
		needsStaging ? 0 : mip);
	auto [order, count] = SharedView.getOrders();
	if (count > 0)
		bgfx::setViewOrder(0, count, order);
	SharedView.clear();

	uint32_t submittedFrame = 0;
	int remainingFrames = 16;
	do {
		submittedFrame = bgfx::frame();
	} while (submittedFrame < readyFrame && --remainingFrames > 0);

	if (needsStaging)
		bgfx::destroy(textureHandle);
	if (submittedFrame < readyFrame) {
		pixels.clear();
		return ReadPixelsResult::TimedOut;
	}
	return ReadPixelsResult::Success;
}

void RenderTarget::saveAsync(String filename, const std::function<void(bool)>& callback) {
	std::string file(filename);
	if (!readPixelsAsync([file, callback](uint16_t width, uint16_t height, std::vector<uint8_t> pixels) {
		auto data = std::make_shared<std::vector<uint8_t>>(std::move(pixels));
		SharedAsyncThread.run(
				[data, width, height]() {
					unsigned error;
					LodePNGState state;
					lodepng_state_init(&state);
					uint8_t* out = nullptr;
					size_t outSize = 0;
					error = lodepng_encode(&out, &outSize, data->data(), width, height, &state);
					lodepng_state_cleanup(&state);
					return Values::alloc(error, out, outSize);
				},
				[callback, file](Own<Values> values) {
					unsigned error;
					uint8_t* out;
					size_t outSize;
					values->get(error, out, outSize);
					if (error != 0 || !out || outSize == 0) {
						Warn("RenderTarget PNG encoding failed for \"{}\" with error code {}.",
							file, error);
						::free(out);
						callback(false);
						return;
					}
					Slice content(r_cast<char*>(out), outSize);
					SharedContent.saveAsync(file, content, [out, callback, file](bool success) {
						::free(out);
						if (!success)
							Warn("RenderTarget failed to save PNG through Content: \"{}\".", file);
						callback(success);
					});
				});
	})) callback(false);
}

RenderTarget* RenderTarget::getCurrent() {
	if (_applyingStack.empty()) {
		return nullptr;
	}
	return _applyingStack.top();
}

NS_DORA_END
