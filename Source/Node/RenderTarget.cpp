/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Node/RenderTarget.h"
#include "Cache/TextureCache.h"
#include "Node/Sprite.h"
#include "Basic/Camera.h"
#include "Basic/View.h"
#include "Basic/Director.h"

NS_DOROTHY_BEGIN

RenderTarget::RenderTarget(Uint16 width, Uint16 height, bgfx::TextureFormat::Enum format):
_textureWidth(width),
_textureHeight(height),
_format(format),
_dummyParent(Node::create())
{ }

RenderTarget::~RenderTarget()
{
	if (bgfx::isValid(_frameBufferHandle))
	{
		bgfx::destroyFrameBuffer(_frameBufferHandle);
		_frameBufferHandle = BGFX_INVALID_HANDLE;
	}
}

bool RenderTarget::init()
{
	const Uint32 textureFlags = (
		BGFX_TEXTURE_U_CLAMP | BGFX_TEXTURE_V_CLAMP |
		BGFX_TEXTURE_RT);
	_frameBufferHandle = bgfx::createFrameBuffer(_textureWidth, _textureHeight, _format, textureFlags);
	bgfx::TextureHandle textureHandle = bgfx::getTexture(_frameBufferHandle);
	bgfx::TextureInfo info;
	bgfx::calcTextureSize(info,
		_textureWidth, _textureHeight,
		0, false, false, 1, _format);
	_texture = Texture2D::create(textureHandle, info, textureFlags);

	setSize(Size{s_cast<float>(_textureWidth), s_cast<float>(_textureHeight)});

	_sprite = Sprite::create(_texture);
	_sprite->setPosition(Vec2{getWidth() / 2.0f, getHeight() / 2.0f});
	addChild(_sprite);

	return true;
}

void RenderTarget::begin(Color color, float depth, Uint8 stencil)
{
	Uint8 viewId = SharedView.push("RenderTarget");
	bgfx::setViewFrameBuffer(viewId, _frameBufferHandle);
	bgfx::setViewRect(viewId, 0, 0, _textureWidth, _textureHeight);
	bgfx::setViewClear(viewId, BGFX_CLEAR_COLOR | BGFX_CLEAR_DEPTH | BGFX_CLEAR_STENCIL, color.toRGBA(), depth, stencil);
	if (_camera)
	{
		Matrix viewProj;
		bx::mtxMul(viewProj, _camera->getView(), SharedView.getProjection());
		SharedDirector.pushViewProjection(viewProj);
		bgfx::setViewTransform(viewId, nullptr, viewProj);
	}
	else
	{
		Matrix ortho;
		switch (bgfx::getCaps()->rendererType)
		{
		case bgfx::RendererType::Direct3D9:
		case bgfx::RendererType::Direct3D11:
		case bgfx::RendererType::Direct3D12:
			bx::mtxOrtho(ortho, 0, s_cast<float>(_textureWidth), 0, s_cast<float>(_textureHeight), -1000.0f, 1000.0f);
			break;
		default:
			bx::mtxOrtho(ortho, 0, s_cast<float>(_textureWidth), s_cast<float>(_textureHeight), 0, -1000.0f, 1000.0f);
			break;
		}
		SharedDirector.pushViewProjection(ortho);
		bgfx::setViewTransform(viewId, nullptr, ortho);
	}
}

void RenderTarget::render(Node* target)
{
	Node* parent = target->getParent();
	if (parent)
	{
		parent->removeChild(target);
		target->addTo(_dummyParent);
	}
	target->markDirty();
	target->visit();
	SharedRendererManager.setCurrent(nullptr);
	if (parent)
	{
		_dummyParent->removeChild(target);
		target->addTo(parent);
	}
}

void RenderTarget::end()
{
	SharedDirector.popViewProjection();
	SharedView.pop();
}

NS_DOROTHY_END
