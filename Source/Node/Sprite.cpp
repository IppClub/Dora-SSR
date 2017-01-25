/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Node/Sprite.h"

NS_DOROTHY_BEGIN

bgfx::VertexDecl SpriteVertex::ms_decl;
SpriteVertex::Init SpriteVertex::init;

SpriteBuffer::SpriteBuffer():
_spriteIndices{0, 1, 2, 1, 3, 2},
_lastEffect(nullptr),
_lastTexture(nullptr),
_lastState(0)
{ }

SpriteBuffer::~SpriteBuffer()
{ }

void SpriteBuffer::doRender()
{
	if (!_vertices.empty())
	{
		bgfx::TransientVertexBuffer vertexBuffer;
		bgfx::TransientIndexBuffer indexBuffer;
		Uint32 vertexCount = s_cast<Uint32>(_vertices.size());
		Uint32 spriteCount = vertexCount >> 2;
		Uint32 indexCount = spriteCount * 6;
		if (bgfx::allocTransientBuffers(
			&vertexBuffer, SpriteVertex::ms_decl, vertexCount,
			&indexBuffer, indexCount))
		{
			memcpy(vertexBuffer.data, _vertices.data(), _vertices.size() * sizeof(SpriteVertex));
			uint16_t* indices = r_cast<uint16_t*>(indexBuffer.data);
			for (size_t i = 0; i < spriteCount; i++)
			{
				for (size_t j = 0; j < 6; j++)
				{
					indices[i * 6 + j] = s_cast<uint16_t>(_spriteIndices[j] + i * 4);
				}
			}
			bgfx::setVertexBuffer(&vertexBuffer);
			bgfx::setIndexBuffer(&indexBuffer);
			bgfx::setTexture(0, _lastEffect->getSampler(), _lastTexture->getHandle());
			bgfx::setState(_lastState);
			bgfx::submit(0, _lastEffect->getProgram());
		}
		else
		{
			Log("not enough transient buffer for %d vertices, %d indices.", vertexCount, indexCount);
		}
		_vertices.clear();
		_lastEffect = nullptr;
		_lastTexture = nullptr;
		_lastState = 0;
	}
}

void SpriteBuffer::render(Sprite* sprite)
{
	if (!sprite)
	{
		doRender();
		return;
	}

	Effect* effect = sprite->getEffect();
	Texture2D* texture = sprite->getTexture();
	Uint64 state = sprite->getRenderState();
	if (effect != _lastEffect || texture != _lastTexture || state != _lastState)
	{
		doRender();
	}

	_lastEffect = effect;
	_lastTexture = texture;
	_lastState = state;

	const SpriteVertex* verts = sprite->getVertices();
	float transform[16];
	bx::mtxMul(transform, sprite->getWorld(), SharedDirector.getViewProjection());
	for (int i = 0; i < 4; i++)
	{
		SpriteVertex vertex = verts[i];
		bx::vec4MulMtx(r_cast<float*>(&vertex), r_cast<float*>(c_cast<SpriteVertex*>(verts) + i), transform);
		_vertices.push_back(vertex);
	}
}

Sprite::Sprite():
_effect(&SharedSpriteEffect),
_vertices{{0,0,0,1},{0,0,0,1},{0,0,0,1},{0,0,0,1}},
_blendFunc(BlendFunc::Normal),
_renderState(BGFX_STATE_NONE)
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
{ }

bool Sprite::init()
{
	setDepthWrite(false);
	setSize(_textureRect.size);
	updateVertPosition();
	updateVertTexCoord();
	updateVertColor();
	return true;
}

void Sprite::setEffect(Effect* var)
{
	_effect = var;
}

Effect* Sprite::getEffect() const
{
	return _effect;
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

void Sprite::setBlendFunc(const BlendFunc& var)
{
	_blendFunc = var;
}

const BlendFunc& Sprite::getBlendFunc() const
{
	return _blendFunc;
}

void Sprite::setDepthWrite(bool var)
{
	_flags.setFlag(Sprite::DepthWrite, var);
}

bool Sprite::isDepthWrite() const
{
	return _flags.isOn(Sprite::DepthWrite);
}

Uint64 Sprite::getRenderState() const
{
	return _renderState;
}

const SpriteVertex* Sprite::getVertices() const
{
	return _vertices;
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
		_vertices[1].u = right;
		_vertices[1].v = top;
		_vertices[2].u = left;
		_vertices[2].v = bottom;
		_vertices[3].u = right;
		_vertices[3].v = bottom;
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
		_vertices[1].x = right;
		_vertices[1].y = top;
		_vertices[2].x = left;
		_vertices[2].y = bottom;
		_vertices[3].x = right;
		_vertices[3].y = bottom;
	}
}

void Sprite::updateVertColor()
{
	if (_texture)
	{
		Uint32 abgr = _realColor.toABGR();
		_vertices[0].abgr = abgr;
		_vertices[1].abgr = abgr;
		_vertices[2].abgr = abgr;
		_vertices[3].abgr = abgr;
	}
}

void Sprite::updateRealColor3()
{
	Node::updateRealColor3();
	_flags.setOn(Sprite::VertexColorDirty);
}

void Sprite::updateRealOpacity()
{
	Node::updateRealOpacity();
	_flags.setOn(Sprite::VertexColorDirty);
}

void Sprite::render()
{
	if (!_texture || !_effect) return;

	if (_flags.isOn(Sprite::VertexColorDirty))
	{
		_flags.setOff(Sprite::VertexColorDirty);
		updateVertColor();
	}

	_renderState = (
		BGFX_STATE_RGB_WRITE | BGFX_STATE_ALPHA_WRITE |
		BGFX_STATE_MSAA | _blendFunc.toValue());
	if (_flags.isOn(Sprite::DepthWrite))
	{
		_renderState |= (BGFX_STATE_DEPTH_WRITE | BGFX_STATE_DEPTH_TEST_LESS);
	}

	SharedSpriteBuffer.render(this);
}

NS_DOROTHY_END
