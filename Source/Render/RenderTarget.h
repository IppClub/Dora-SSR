/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

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
	void saveAsync(String filename, const std::function<void(bool)>& callback);
	static RenderTarget* getCurrent();
	CREATE_FUNC_NULLABLE(RenderTarget);

protected:
	RenderTarget(uint16_t width, uint16_t height, bgfx::TextureFormat::Enum format = bgfx::TextureFormat::RGBA8);
	void renderAfterClear(Node* target, bool clear, Color color = 0x0, float depth = 1.0f, uint8_t stencil = 0);
	void renderOnly(Node* target);
	void end();

private:
	uint16_t _textureWidth;
	uint16_t _textureHeight;
	bgfx::TextureFormat::Enum _format;
	Ref<Texture2D> _texture;
	Ref<Texture2D> _depthTexture;
	Ref<Camera> _camera;
	Ref<Node> _dummy;
	bgfx::TextureHandle _textureHandle;
	bgfx::TextureHandle _depthTextureHandle;
	bgfx::FrameBufferHandle _frameBufferHandle;
	static std::stack<RenderTarget*> _applyingStack;
	DORA_TYPE_OVERRIDE(RenderTarget);
};

NS_DORA_END
