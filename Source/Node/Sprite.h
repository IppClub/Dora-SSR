/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node.h"
#include "Basic/Renderer.h"
#include "Cache/TextureCache.h"

NS_DOROTHY_BEGIN

struct SpriteVertex
{
	float x;
	float y;
	float z;
	float w;
	float u;
	float v;
	uint32_t abgr;
	struct Init
	{
		Init()
		{
			ms_layout.begin()
				.add(bgfx::Attrib::Position, 4, bgfx::AttribType::Float)
				.add(bgfx::Attrib::TexCoord0, 2, bgfx::AttribType::Float)
				.add(bgfx::Attrib::Color0, 4, bgfx::AttribType::Uint8, true)
			.end();
		}
	};
	static bgfx::VertexLayout ms_layout;
	static Init init;
};

struct SpriteQuad
{
	SpriteVertex rb;
	SpriteVertex lb;
	SpriteVertex lt;
	SpriteVertex rt;
	inline operator SpriteVertex*()
	{
		return r_cast<SpriteVertex*>(this);
	}
	inline operator const SpriteVertex*() const
	{
		return r_cast<const SpriteVertex*>(this);
	}
	struct Position
	{
		Vec4 rb;
		Vec4 lb;
		Vec4 lt;
		Vec4 rt;
	};
};

class SpriteEffect;

class Sprite : public Node
{
public:
	PROPERTY(SpriteEffect*, Effect);
	PROPERTY(Texture2D*, Texture);
	PROPERTY(float, AlphaRef);
	PROPERTY_CREF(Rect, TextureRect);
	PROPERTY_CREF(BlendFunc, BlendFunc);
	PROPERTY_BOOL(DepthWrite);
	PROPERTY_READONLY(Uint64, RenderState);
	PROPERTY_READONLY_CREF(SpriteQuad, Quad);
	PROPERTY_READONLY(Uint64, TextureFlags);
	PROPERTY_READONLY(Uint32, SamplerFlags);
	PROPERTY(TextureFilter, Filter);
	PROPERTY(TextureWrap, UWrap);
	PROPERTY(TextureWrap, VWrap);
	virtual ~Sprite();
	virtual bool init() override;
	virtual void render() override;
	virtual const Matrix& getWorld() override;
	CREATE_FUNC(Sprite);
protected:
	Sprite();
	Sprite(String filename);
	Sprite(Texture2D* texture);
	Sprite(Texture2D* texture, const Rect& textureRect);
	void updateVertTexCoord();
	void updateVertPosition();
	void updateVertColor();
	virtual void updateRealColor3() override;
	virtual void updateRealOpacity() override;
private:
	Uint8 _alphaRef;
	TextureFilter _filter;
	TextureWrap _uwrap;
	TextureWrap _vwrap;
	Rect _textureRect;
	Ref<SpriteEffect> _effect;
	Ref<Texture2D> _texture;
	SpriteQuad::Position _quadPos;
	SpriteQuad _quad;
	BlendFunc _blendFunc;
	Uint64 _renderState;
	enum
	{
		VertexColorDirty = Node::UserFlag,
		VertexPosDirty = Node::UserFlag << 1,
		DepthWrite = Node::UserFlag << 2,
	};
	DORA_TYPE_OVERRIDE(Sprite);
};

class SpriteRenderer : public Renderer
{
public:
	PROPERTY_READONLY(SpriteEffect*, DefaultEffect);
	PROPERTY_READONLY(SpriteEffect*, DefaultModelEffect);
	PROPERTY_READONLY(SpriteEffect*, AlphaTestEffect);
	virtual ~SpriteRenderer() { }
	virtual void render() override;
	void push(Sprite* sprite);
	void push(SpriteVertex* verts, size_t size,
		SpriteEffect* effect, Texture2D* texture, Uint64 state, Uint32 flags = UINT32_MAX,
		const Matrix* localWorld = nullptr);
	void push(SpriteVertex* verts, size_t vsize, uint16_t* inds, size_t isize,
		SpriteEffect* effect, Texture2D* texture, Uint64 state, Uint32 flags = UINT32_MAX,
		const Matrix* localWorld = nullptr);
protected:
	SpriteRenderer();
private:
	Ref<SpriteEffect> _defaultEffect;
	Ref<SpriteEffect> _defaultModelEffect;
	Ref<SpriteEffect> _alphaTestEffect;
	Texture2D* _lastTexture;
	SpriteEffect* _lastEffect;
	Uint64 _lastState;
	Uint32 _lastFlags;
	std::vector<SpriteVertex> _vertices;
	std::vector<uint16_t> _indices;
	const uint16_t _spriteIndices[6];
	SINGLETON_REF(SpriteRenderer, RendererManager);
};

#define SharedSpriteRenderer \
	Dorothy::Singleton<Dorothy::SpriteRenderer>::shared()

NS_DOROTHY_END
