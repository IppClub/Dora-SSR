/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

struct SpriteVertex
{
	float x;
	float y;
	float u;
	float v;
	uint32_t abgr;
	struct Init
	{
		Init()
		{
			ms_decl
				.begin()
					.add(bgfx::Attrib::Position, 2, bgfx::AttribType::Float)
					.add(bgfx::Attrib::TexCoord0, 2, bgfx::AttribType::Float)
					.add(bgfx::Attrib::Color0, 4, bgfx::AttribType::Uint8, true)
				.end();
		}
	};
	static bgfx::VertexDecl ms_decl;
	static Init init;
};

class SpriteIndexBuffer : public Object
{
public:
	SpriteIndexBuffer();
	virtual ~SpriteIndexBuffer();
	PROPERTY_READONLY(bgfx::IndexBufferHandle, Handler);
private:
	static const uint16_t spriteIndices[4];
	bgfx::IndexBufferHandle _indexBuffer;
};

#define SharedSpriteIndexBuffer \
	silly::Singleton<SpriteIndexBuffer, SingletonIndex::SpriteIndexBuffer>::shared()

class Sprite : public Node
{
public:
	PROPERTY(Effect*, Effect);
	PROPERTY(Texture2D*, Texture);
	PROPERTY_REF(Rect, TextureRect);
	PROPERTY_REF(BlendFunc, BlendFunc);
	PROPERTY_BOOL(DepthWrite);
	virtual ~Sprite();
	virtual bool init() override;
	virtual void render() override;
	CREATE_FUNC(Sprite);
protected:
	Sprite();
	Sprite(String filename);
	Sprite(Texture2D* texture);
	Sprite(Texture2D* texture, const Rect& textureRect);
	void updateVertTexCoord();
	void updateVertPosition();
	void updateVertColor();
private:
	Rect _textureRect;
	Ref<Effect> _effect;
	Ref<Texture2D> _texture;
	SpriteVertex _vertices[4];
	bgfx::DynamicVertexBufferHandle _vertexBuffer;
	BlendFunc _blendFunc;
	enum
	{
		VertexDirty = Node::UserFlag,
		DepthWrite = Node::UserFlag<<1
	};
	DORA_TYPE_OVERRIDE(Sprite);
};

NS_DOROTHY_END
