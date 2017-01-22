/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Node/Sprite.h"

NS_DOROTHY_BEGIN

bgfx::VertexDecl SpriteVertex::ms_decl;
SpriteVertex::Init SpriteVertex::init;

const uint16_t SpriteIndexBuffer::spriteIndices[] = {0, 1, 2, 3};

SpriteIndexBuffer::SpriteIndexBuffer():
_indexBuffer(bgfx::createIndexBuffer(bgfx::makeRef(spriteIndices, sizeof(spriteIndices))))
{ }

SpriteIndexBuffer::~SpriteIndexBuffer()
{
	if (bgfx::isValid(_indexBuffer))
	{
		bgfx::destroyIndexBuffer(_indexBuffer);
	}
}

bgfx::IndexBufferHandle SpriteIndexBuffer::getHandler() const
{
	return _indexBuffer;
}

Sprite::Sprite():
_effect(&SharedSpriteEffect),
_vertices{},
_blendState(BlendState::Normal),
_vertexBuffer(bgfx::createDynamicVertexBuffer(4, SpriteVertex::ms_decl))
{ }

Sprite::Sprite(Texture2D* texture):
Sprite()
{
	_texture = texture;
	_textureRect = texture ? Rect{
		0.0f, 0.0f,
		float(texture->getInfo().width),
		float(texture->getInfo().height)
	} : Rect::zero;
}

Sprite::Sprite(Texture2D* texture, const Rect& textureRect):
Sprite()
{
	_texture = texture;
	_textureRect = textureRect;
}

Sprite::Sprite(String filename):
Sprite(SharedTextureCache.load(filename))
{ }

Sprite::~Sprite()
{
	if (bgfx::isValid(_vertexBuffer))
	{
		bgfx::destroyDynamicVertexBuffer(_vertexBuffer);
	}
}

bool Sprite::init()
{
	setDepthWrite(false);
	setSize(_textureRect.size);
	updateVertPosition();
	updateVertTexCoord();
	updateVertColor();
	return true;
}

void Sprite::setTextureRect(const Rect& var)
{
	_textureRect = var;
	updateVertPosition();
	updateVertTexCoord();
}

const Rect& Sprite::getTextureRect() const
{
	return _textureRect;
}

void Sprite::setTexture(Texture2D* var)
{
	_texture = var;
	updateVertTexCoord();
}

Texture2D* Sprite::getTexture() const
{
	return _texture;
}

void Sprite::setBlendState(const BlendState& var)
{
	_blendState = var;
}

const BlendState& Sprite::getBlendState() const
{
	return _blendState;
}

void Sprite::setDepthWrite(bool var)
{
	setFlag(Sprite::DepthWrite, var);
}

bool Sprite::isDepthWrite() const
{
	return isOn(Sprite::DepthWrite);
}

void Sprite::updateVertTexCoord()
{
	if (_texture)
	{
		const bgfx::TextureInfo& info = _texture->getInfo();
		float left = _textureRect.getX() / info.width;
		float top = _textureRect.getY() / info.height;
		float right = (_textureRect.getX() + _textureRect.getWidth()) / info.width;
		float bottom = (_textureRect.getY() + _textureRect.getHeight()) / info.height;
		_vertices[0].u = left;
		_vertices[0].v = top;
		_vertices[1].u = left;
		_vertices[1].v = bottom;
		_vertices[2].u = right;
		_vertices[2].v = top;
		_vertices[3].u = right;
		_vertices[3].v = bottom;
		setOn(Sprite::VertexDirty);
	}
}

void Sprite::updateVertPosition()
{
	if (_texture)
	{
		float width = _textureRect.getWidth();
		float height = _textureRect.getHeight();
		float left = 0, right = width, top = height, bottom = 0;
		_vertices[0].x = left;
		_vertices[0].y = top;
		_vertices[1].x = left;
		_vertices[1].y = bottom;
		_vertices[2].x = right;
		_vertices[2].y = top;
		_vertices[3].x = right;
		_vertices[3].y = bottom;
		setOn(Sprite::VertexDirty);
	}
}

void Sprite::updateVertColor()
{
	if (_texture)
	{
		Uint32 abgr = _color.toABGR();
		_vertices[0].abgr = abgr;
		_vertices[1].abgr = abgr;
		_vertices[2].abgr = abgr;
		_vertices[3].abgr = abgr;
		setOn(Sprite::VertexDirty);
	}
}

void Sprite::render()
{
	if (!_texture || !_effect) return;

	if (isOn(Sprite::VertexDirty))
	{
		setOff(Sprite::VertexDirty);
		bgfx::updateDynamicVertexBuffer(_vertexBuffer, 0, bgfx::makeRef(_vertices, sizeof(_vertices)));
	}

	Uint64 state = (
		BGFX_STATE_RGB_WRITE | BGFX_STATE_ALPHA_WRITE /*|
		BGFX_STATE_CULL_CW*/ | BGFX_STATE_MSAA |
		BGFX_STATE_PT_TRISTRIP | _blendState.toValue());
	if (isOn(Sprite::DepthWrite))
	{
		state |= (BGFX_STATE_DEPTH_WRITE | BGFX_STATE_DEPTH_TEST_LESS);
	}

	bgfx::setTransform(getWorld());
	bgfx::setVertexBuffer(_vertexBuffer);
	bgfx::setIndexBuffer(SharedSpriteIndexBuffer.getHandler());
	bgfx::setTexture(0, _effect->getSampler(), _texture->getHandle());
	bgfx::setState(state);
	bgfx::submit(0, _effect->getProgram());
}

NS_DOROTHY_END
