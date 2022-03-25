/* Copyright (c) 2022 Jin Li, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Sprite.h"

NS_DOROTHY_BEGIN

class Grid : public Node
{
public:
	PROPERTY_CREF(Rect, TextureRect);
	PROPERTY(Texture2D*, Texture);
	PROPERTY(SpriteEffect*, Effect);
	PROPERTY_CREF(BlendFunc, BlendFunc);
	PROPERTY_BOOL(DepthWrite);
	PROPERTY_READONLY(uint32_t, GridX);
	PROPERTY_READONLY(uint32_t, GridY);
	void setPos(uint32_t x, uint32_t y, Vec2 pos, float z = 0.0f);
	Vec2 getPos(uint32_t x, uint32_t y) const;
	Color getColor(uint32_t x, uint32_t y) const;
	void setColor(uint32_t x, uint32_t y, Color color);
	void moveUV(uint32_t x, uint32_t y, Vec2 offset);
	virtual bool init() override;
	virtual void render() override;
	virtual const Matrix& getWorld() override;
	virtual void updateRealColor3() override;
	virtual void updateRealOpacity() override;
	CREATE_FUNC(Grid);
protected:
	Grid(float width, float height, uint32_t gridX, uint32_t gridY);
	Grid(Texture2D* texture, uint32_t gridX, uint32_t gridY);
	Grid(Texture2D* texture, const Rect& textureRect, uint32_t gridX, uint32_t gridY);
private:
	Grid(Texture2D* texture, const Size& texSize, const Rect& textureRect, uint32_t gridX, uint32_t gridY);
	void setupVertices();
	void updateUV();
	uint32_t _gridX;
	uint32_t _gridY;
	Size _texSize;
	Rect _textureRect;
	Ref<SpriteEffect> _effect;
	BlendFunc _blendFunc;
	Ref<Texture2D> _texture;
	struct Point
	{
		Vec4 position;
		Vec4 color;
	};
	std::vector<Point> _points;
	std::vector<SpriteVertex> _vertices;
	std::vector<SpriteRenderer::IndexType> _indices;
	enum
	{
		VertexPosDirty = Node::UserFlag,
		VertexColorDirty = Node::UserFlag << 1,
		DepthWrite = Node::UserFlag << 2,
	};
	DORA_TYPE_OVERRIDE(Grid);
};

NS_DOROTHY_END
