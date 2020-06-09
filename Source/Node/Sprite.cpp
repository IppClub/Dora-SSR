/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Node/Sprite.h"
#include "Effect/Effect.h"
#include "Cache/ShaderCache.h"
#include "Cache/TextureCache.h"
#include "Basic/Director.h"
#include "Basic/View.h"

NS_DOROTHY_BEGIN

/* Sprite */

bgfx::VertexLayout SpriteVertex::ms_layout;
SpriteVertex::Init SpriteVertex::init;

Sprite::Sprite():
_filter(TextureFilter::None),
_uwrap(TextureWrap::None),
_vwrap(TextureWrap::None),
_effect(SharedSpriteRenderer.getDefaultEffect()),
_quadPos{{0,0,0,1},{0,0,0,1},{0,0,0,1},{0,0,0,1}},
_blendFunc(BlendFunc::Default),
_alphaRef(0),
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
	if (!Node::init()) return false;
	setDepthWrite(false);
	setSize(_textureRect.size);
	updateVertPosition();
	updateVertTexCoord();
	updateVertColor();
	return true;
}

void Sprite::setEffect(SpriteEffect* var)
{
	_effect = var ? var : SharedSpriteRenderer.getDefaultEffect();
}

SpriteEffect* Sprite::getEffect() const
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

void Sprite::setAlphaRef(float var)
{
	_alphaRef = s_cast<Uint8>(255.0f * Math::clamp(var, 0.0f, 1.0f));
}

float Sprite::getAlphaRef() const
{
	return _alphaRef / 255.0f;
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
	_flags.set(Sprite::DepthWrite, var);
}

bool Sprite::isDepthWrite() const
{
	return _flags.isOn(Sprite::DepthWrite);
}

Uint64 Sprite::getRenderState() const
{
	return _renderState;
}

const SpriteQuad& Sprite::getQuad() const
{
	return _quad;
}

Uint32 Sprite::getSamplerFlags() const
{
	return getTextureFlags() & UINT32_MAX;
}

Uint64 Sprite::getTextureFlags() const
{
	Uint64 textureFlags = _texture->getFlags();
	if (_filter == TextureFilter::None && _uwrap == TextureWrap::None && _vwrap == TextureWrap::None)
	{
		return UINT32_MAX;
	}
	const Uint64 mask = (
		BGFX_SAMPLER_MIN_MASK | BGFX_SAMPLER_MAG_MASK |
		BGFX_SAMPLER_U_MASK | BGFX_SAMPLER_V_MASK);
	Uint64 flags = 0;
	switch (_filter)
	{
		case TextureFilter::Point:
			flags |= (BGFX_SAMPLER_MIN_POINT | BGFX_SAMPLER_MAG_POINT);
			break;
		case TextureFilter::Anisotropic:
			flags |= (BGFX_SAMPLER_MIN_ANISOTROPIC | BGFX_SAMPLER_MAG_ANISOTROPIC);
			break;
		default:
			break;
	}
	switch (_uwrap)
	{
		case TextureWrap::Mirror:
			flags |= BGFX_SAMPLER_U_MIRROR;
			break;
		case TextureWrap::Clamp:
			flags |= BGFX_SAMPLER_U_CLAMP;
			break;
		case TextureWrap::Border:
			flags |= BGFX_SAMPLER_U_BORDER;
			break;
		default:
			break;
	}
	switch (_vwrap)
	{
		case TextureWrap::Mirror:
			flags |= BGFX_SAMPLER_V_MIRROR;
			break;
		case TextureWrap::Clamp:
			flags |= BGFX_SAMPLER_V_CLAMP;
			break;
		case TextureWrap::Border:
			flags |= BGFX_SAMPLER_V_BORDER;
			break;
		default:
			break;
	}
	if (flags == (textureFlags & mask))
	{
		return UINT32_MAX;
	}
	else
	{
		return (textureFlags & (~mask)) | flags;
	}
}

void Sprite::setFilter(TextureFilter var)
{
	_filter = var;
}

TextureFilter Sprite::getFilter() const
{
	return _filter;
}

void Sprite::setUWrap(TextureWrap var)
{
	_uwrap = var;
}

TextureWrap Sprite::getUWrap() const
{
	return _uwrap;
}

void Sprite::setVWrap(TextureWrap var)
{
	_vwrap = var;
}

TextureWrap Sprite::getVWrap() const
{
	return _vwrap;
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
		_quad.rb.u = right;
		_quad.rb.v = bottom;
		_quad.lb.u = left;
		_quad.lb.v = bottom;
		_quad.lt.u = left;
		_quad.lt.v = top;
		_quad.rt.u = right;
		_quad.rt.v = top;
	}
}

void Sprite::updateVertPosition()
{
	if (_texture)
	{
		float width = _textureRect.getWidth();
		float height = _textureRect.getHeight();
		float left = 0, right = width, top = height, bottom = 0;
		_quadPos.rb.x = right;
		_quadPos.rb.y = bottom;
		_quadPos.lb.x = left;
		_quadPos.lb.y = bottom;
		_quadPos.lt.x = left;
		_quadPos.lt.y = top;
		_quadPos.rt.x = right;
		_quadPos.rt.y = top;
		_flags.setOn(Sprite::VertexPosDirty);
	}
}

void Sprite::updateVertColor()
{
	if (_texture)
	{
		Uint32 abgr = _realColor.toABGR();
		_quad.rb.abgr = abgr;
		_quad.lb.abgr = abgr;
		_quad.lt.abgr = abgr;
		_quad.rt.abgr = abgr;
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

const Matrix& Sprite::getWorld()
{
	if (_flags.isOn(Node::WorldDirty))
	{
		_flags.setOn(Sprite::VertexPosDirty);
	}
	return Node::getWorld();
}

void Sprite::render()
{
	if (!_texture || !_effect || _textureRect.size == Size::zero) return;

	if (_flags.isOn(Sprite::VertexColorDirty))
	{
		_flags.setOff(Sprite::VertexColorDirty);
		updateVertColor();
	}

	if (_flags.isOn(Sprite::VertexPosDirty))
	{
		_flags.setOff(Sprite::VertexPosDirty);
		Matrix transform;
		bx::mtxMul(transform, _world, SharedDirector.getViewProjection());
		bx::vec4MulMtx(&_quad.rb.x, _quadPos.rb, transform);
		bx::vec4MulMtx(&_quad.lb.x, _quadPos.lb, transform);
		bx::vec4MulMtx(&_quad.lt.x, _quadPos.lt, transform);
		bx::vec4MulMtx(&_quad.rt.x, _quadPos.rt, transform);
	}

	_renderState = (
		BGFX_STATE_WRITE_RGB | BGFX_STATE_WRITE_A |
		BGFX_STATE_ALPHA_REF(_alphaRef) |
		BGFX_STATE_MSAA | _blendFunc.toValue());
	if (_flags.isOn(Sprite::DepthWrite))
	{
		_renderState |= (BGFX_STATE_WRITE_Z | BGFX_STATE_DEPTH_TEST_LESS);
	}

	SharedRendererManager.setCurrent(SharedSpriteRenderer.getTarget());
	SharedSpriteRenderer.push(this);
}

/* SpriteRenderer */

SpriteRenderer::SpriteRenderer():
_spriteIndices{0, 1, 2, 2, 3, 0},
_lastEffect(nullptr),
_lastTexture(nullptr),
_lastState(0),
_lastFlags(UINT32_MAX),
_defaultEffect(SpriteEffect::create("builtin::vs_sprite"_slice, "builtin::fs_sprite"_slice)),
_defaultModelEffect(SpriteEffect::create("builtin::vs_spritemodel"_slice, "builtin::fs_sprite"_slice)),
_alphaTestEffect(SpriteEffect::create("builtin::vs_sprite"_slice, "builtin::fs_spritealphatest"_slice))
{ }

SpriteEffect* SpriteRenderer::getDefaultEffect() const
{
	return _defaultEffect;
}

SpriteEffect* SpriteRenderer::getDefaultModelEffect() const
{
	return _defaultModelEffect;
}

SpriteEffect* SpriteRenderer::getAlphaTestEffect() const
{
	return _alphaTestEffect;
}

void SpriteRenderer::render()
{
	if (!_vertices.empty())
	{
		bgfx::TransientVertexBuffer vertexBuffer;
		bgfx::TransientIndexBuffer indexBuffer;
		Uint32 vertexCount = s_cast<Uint32>(_vertices.size());
		Uint32 indexCount = s_cast<Uint32>(_indices.size());
		if (bgfx::allocTransientBuffers(
			&vertexBuffer, SpriteVertex::ms_layout, vertexCount,
			&indexBuffer, indexCount))
		{
			Renderer::render();
			std::memcpy(vertexBuffer.data, _vertices.data(), _vertices.size() * sizeof(_vertices[0]));
			std::memcpy(indexBuffer.data, _indices.data(), _indices.size() * sizeof(_indices[0]));
			bgfx::setVertexBuffer(0, &vertexBuffer);
			bgfx::setIndexBuffer(&indexBuffer);
			bgfx::ViewId viewId = SharedView.getId();
			bgfx::setState(_lastState);
			bgfx::setTexture(0, _lastEffect->getSampler(), _lastTexture->getHandle(), _lastFlags);
			bgfx::submit(viewId, _lastEffect->apply());
		}
		else
		{
			Warn("not enough transient buffer for {} vertices, {} indices.", vertexCount, indexCount);
		}
		_vertices.clear();
		_indices.clear();
		_lastEffect = nullptr;
		_lastTexture = nullptr;
		_lastState = 0;
		_lastFlags = UINT32_MAX;
	}
}

void SpriteRenderer::push(Sprite* sprite)
{
	SpriteEffect* effect = sprite->getEffect();
	Texture2D* texture = sprite->getTexture();
	Uint64 state = sprite->getRenderState();
	Uint32 flags = sprite->getSamplerFlags();
	if (effect != _lastEffect || texture != _lastTexture || state != _lastState || flags != _lastFlags)
	{
		render();
	}

	_lastEffect = effect;
	_lastTexture = texture;
	_lastState = state;
	_lastFlags = flags;

	const SpriteVertex* verts = sprite->getQuad();
	size_t vertSize = _vertices.size();
	_vertices.resize(vertSize + 4);
	std::memcpy(_vertices.data() + vertSize, verts, sizeof(verts[0]) * 4);
	size_t indSize = _indices.size();
	_indices.resize(indSize + 6);
	auto indPtr = _indices.data() + indSize;
	for (size_t i = 0; i < 6; ++i)
	{
		indPtr[i] = _spriteIndices[i] + vertSize;
	}
}

void SpriteRenderer::push(SpriteVertex* verts, size_t size,
	SpriteEffect* effect, Texture2D* texture, Uint64 state, Uint32 flags, const Matrix* localWorld)
{
	AssertUnless(size % 4 == 0, "invalid sprite vertices size.");
	if (localWorld || effect != _lastEffect || texture != _lastTexture || state != _lastState || flags != _lastFlags)
	{
		render();
	}
	_lastEffect = effect;
	_lastTexture = texture;
	_lastState = state;
	_lastFlags = flags;

	size_t vertSize = _vertices.size();
	_vertices.resize(vertSize + size);
	std::memcpy(_vertices.data() + vertSize, verts, sizeof(verts[0]) * size);

	size_t indSize = _indices.size();
	size_t spriteCount = size / 4;
	size_t added = 6 * spriteCount;
	_indices.resize(indSize + added);
	auto indices = _indices.data() + indSize;
	for (size_t i = 0; i < spriteCount; i++)
	{
		for (size_t j = 0; j < 6; j++)
		{
			indices[i * 6 + j] = s_cast<uint16_t>(_spriteIndices[j] + i * 4 + vertSize);
		}
	}

	if (localWorld)
	{
		bgfx::setTransform(localWorld);
		render();
	}
}

void SpriteRenderer::push(
	SpriteVertex* verts, size_t vsize,
	uint16_t* inds, size_t isize,
	SpriteEffect* effect, Texture2D* texture,
	Uint64 state, Uint32 flags,
	const Matrix* localWorld)
{
	if (localWorld || effect != _lastEffect || texture != _lastTexture || state != _lastState || flags != _lastFlags)
	{
		render();
	}
	_lastEffect = effect;
	_lastTexture = texture;
	_lastState = state;
	_lastFlags = flags;

	size_t vertSize = _vertices.size();
	_vertices.resize(vertSize + vsize);
	std::memcpy(_vertices.data() + vertSize, verts, sizeof(verts[0]) * vsize);

	size_t indSize = _indices.size();
	_indices.resize(indSize + isize);
	auto indices = _indices.data() + indSize;
	for (size_t i = 0; i < isize; ++i)
	{
		indices[i] = inds[i] + vertSize;
	}

	if (localWorld)
	{
		bgfx::setTransform(localWorld);
		render();
	}
}

NS_DOROTHY_END
