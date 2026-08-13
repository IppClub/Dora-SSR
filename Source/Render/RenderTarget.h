/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Object.h"
#include "Support/Common.h"

NS_DORA_BEGIN

class Camera;
class Node;
class Texture2D;

class RenderTarget : public Object {
public:
	struct Attachment {
		Texture2D* texture = nullptr;
		uint16_t layer = 0;
		uint16_t mip = 0;
		uint8_t resolve = BGFX_RESOLVE_AUTO_GEN_MIPS;
	};
	enum class ReadPixelsResult {
		Success,
		NoTexture,
		WriteOnly,
		Unsupported,
		ActiveView,
		InvalidTexture,
		StagingTextureFailed,
		TimedOut,
	};
	PROPERTY_READONLY(uint16_t, Width);
	PROPERTY_READONLY(uint16_t, Height);
	PROPERTY(Camera*, Camera);
	PROPERTY_READONLY(Texture2D*, Texture);
	PROPERTY_READONLY(Texture2D*, DepthTexture);
	virtual ~RenderTarget();
	virtual bool init() override;
	void render(Node* target);
	void renderWithClear(Color color, float depth = 1.0f, uint8_t stencil = 0);
	void renderWithClear(Node* target, Color color, float depth = 1.0f, uint8_t stencil = 0);
	void renderWithClearFlags(Node* target, uint16_t clearFlags, Color color = 0x0,
		float depth = 1.0f, uint8_t stencil = 0);
	void submit(const std::function<void()>& commands);
	void submitWithClearFlags(const std::function<void()>& commands, uint16_t clearFlags,
		Color color = 0x0, float depth = 1.0f, uint8_t stencil = 0);
	bool readPixelsAsync(const std::function<void(uint16_t, uint16_t, std::vector<uint8_t>)>& callback);
	ReadPixelsResult readPixelsSync(std::vector<uint8_t>& pixels);
	ReadPixelsResult readPixelsSync(std::vector<uint8_t>& pixels, uint16_t layer, uint8_t mip);
	void saveAsync(String filename, const std::function<void(bool)>& callback);
	static RenderTarget* getCurrent();
	CREATE_FUNC_NULLABLE(RenderTarget);

protected:
	RenderTarget(uint16_t width, uint16_t height, bgfx::TextureFormat::Enum format = bgfx::TextureFormat::RGBA8,
		uint64_t textureFlags = 0);
	RenderTarget(std::vector<Texture2D*> colorTextures, Texture2D* depthTexture);
	RenderTarget(std::vector<Attachment> colorAttachments,
		std::optional<Attachment> depthAttachment = std::nullopt);
	void renderAfterClear(Node* target, uint16_t clearFlags, Color color = 0x0,
		float depth = 1.0f, uint8_t stencil = 0);
	void submitAfterClear(const std::function<void()>& commands, uint16_t clearFlags,
		Color color = 0x0, float depth = 1.0f, uint8_t stencil = 0);
	void renderOnly(Node* target);
	void end();

private:
	uint16_t _textureWidth;
	uint16_t _textureHeight;
	bgfx::TextureFormat::Enum _format;
	uint64_t _textureFlags = 0;
	Ref<Texture2D> _texture;
	Ref<Texture2D> _depthTexture;
	std::vector<Ref<Texture2D>> _colorTextures;
	std::vector<Attachment> _colorAttachments;
	std::optional<Attachment> _depthAttachment;
	bool _externalAttachments = false;
	Ref<Camera> _camera;
	Ref<Node> _dummy;
	bgfx::TextureHandle _textureHandle;
	bgfx::TextureHandle _depthTextureHandle;
	bgfx::FrameBufferHandle _frameBufferHandle;
	static std::stack<RenderTarget*> _applyingStack;
	DORA_TYPE_OVERRIDE(RenderTarget);
};

NS_DORA_END
