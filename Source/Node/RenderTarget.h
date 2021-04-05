/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node.h"

NS_DOROTHY_BEGIN

class Camera;
class Sprite;
class Texture2D;

class RenderTarget : public Node
{
public:
	PROPERTY(Camera*, Camera);
	PROPERTY_READONLY(Sprite*, Surface);
	virtual ~RenderTarget();
	virtual bool init() override;
	void render(Node* target);
	void renderWithClear(Color color, float depth = 1.0f, Uint8 stencil = 0);
	void renderWithClear(Node* target, Color color, float depth = 1.0f, Uint8 stencil = 0);
	void saveAsync(String filename, const std::function<void()>& callback);
	CREATE_FUNC(RenderTarget);
protected:
	RenderTarget(Uint16 width, Uint16 height, bgfx::TextureFormat::Enum format = bgfx::TextureFormat::RGBA8);
	void renderAfterClear(Node* target, bool clear, Color color = 0x0, float depth = 1.0f, Uint8 stencil = 0);
	void renderOnly(Node* target);
	void end();
private:
	Uint16 _textureWidth;
	Uint16 _textureHeight;
	bgfx::TextureFormat::Enum _format;
	Ref<Texture2D> _texture;
	Ref<Texture2D> _depthTexture;
	Ref<Sprite> _surface;
	Ref<Camera> _camera;
	Ref<Node> _dummy;
	bgfx::FrameBufferHandle _frameBufferHandle;
	enum
	{
		ViewCleared = Node::UserFlag,
	};
	DORA_TYPE_OVERRIDE(RenderTarget);
};

NS_DOROTHY_END
