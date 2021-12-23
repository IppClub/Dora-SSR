/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Node/Grid.h"
#include "Effect/Effect.h"
#include "Basic/Director.h"

NS_DOROTHY_BEGIN

Grid::Grid(const Rect& textureRect, uint32_t gridX, uint32_t gridY):
Grid(nullptr, textureRect, gridX, gridY)
{ }

Grid::Grid(Texture2D* texture, uint32_t gridX, uint32_t gridY):
Grid(texture, Rect(0, 0, s_cast<float>(texture->getWidth()), s_cast<float>(texture->getHeight())), gridX, gridY)
{ }

Grid::Grid(Texture2D* texture, const Rect& textureRect, uint32_t gridX, uint32_t gridY):
_gridX(gridX),
_gridY(gridY),
_effect(SharedSpriteRenderer.getDefaultEffect()),
_texture(texture),
_textureRect(textureRect),
_blendFunc(BlendFunc::Default)
{ }

bool Grid::init()
{
	if (!Node::init()) return false;
	setupVertices();
	return true;
}

uint32_t Grid::getGridX() const
{
	return _gridX;
}

uint32_t Grid::getGridY() const
{
	return _gridY;
}

void Grid::setTexture(Texture2D* var)
{
	_texture = var;
	if (_textureRect == Rect::zero)
	{
		_textureRect.set(0, 0, s_cast<float>(var->getWidth()), s_cast<float>(var->getHeight()));
		updateUV();
	}
}

Texture2D* Grid::getTexture() const
{
	return _texture;
}

void Grid::setTextureRect(const Rect& var)
{
	if (_textureRect != var)
	{
		_textureRect = var;
		updateUV();
	}
}

const Rect& Grid::getTextureRect() const
{
	return _textureRect;
}

void Grid::setEffect(SpriteEffect* var)
{
	_effect = var ? var : SharedSpriteRenderer.getDefaultEffect();
}

SpriteEffect* Grid::getEffect() const
{
	return _effect;
}

void Grid::setBlendFunc(const BlendFunc& var)
{
	_blendFunc = var;
}

const BlendFunc& Grid::getBlendFunc() const
{
	return _blendFunc;
}

void Grid::setDepthWrite(bool var)
{
	_flags.set(Grid::DepthWrite, var);
}

bool Grid::isDepthWrite() const
{
	return _flags.isOn(Grid::DepthWrite);
}

void Grid::setPos(uint32_t x, uint32_t y, Vec2 pos)
{
	AssertIf(x > _gridX || y > _gridY, "Grid vertex index ({},{}) out of bounds [{},{}]", x, y, _gridX, _gridY);
	auto index = y * (_gridX + 1) + x;
	_points[index] = {pos.x, pos.y, 0, 1.0f};
	_flags.setOn(Grid::VertexPosDirty);
}

Vec2 Grid::getPos(uint32_t x, uint32_t y) const
{
	AssertIf(x > _gridX || y > _gridY, "Grid index ({},{}) out of bounds [{},{}]", x, y, _gridX, _gridY);
	auto index = y * (_gridX + 1) + x;
	return {_points[index].x, _points[index].y};
}

Color Grid::getColor(uint32_t x, uint32_t y) const
{
	AssertIf(x > _gridX || y > _gridY, "Grid index ({},{}) out of bounds [{},{}]", x, y, _gridX, _gridY);
	auto index = y * (_gridX + 1) + x;
	return Color(_vertices[index].abgr);
}

void Grid::setColor(uint32_t x, uint32_t y, Color color)
{
	AssertIf(x > _gridX || y > _gridY, "Grid index ({},{}) out of bounds [{},{}]", x, y, _gridX, _gridY);
	auto index = y * (_gridX + 1) + x;
	_vertices[index].abgr = color.toABGR();
}

void Grid::setupVertices()
{
	float uStart = _textureRect.getX();
	float vStart = _textureRect.getY();
	float width = _textureRect.getWidth();
	float height = _textureRect.getHeight();
	float xStart = -width / 2.0f;
	float yStart = height / 2.0f;
	float yOffset = height / _gridY;
	float xOffset = width / _gridX;
	uint32_t xCount = _gridX + 1;
	for (uint32_t y = 0; y <= _gridY; y++)
	{
		float posY = yStart - y * yOffset;
		float v = (vStart + y * yOffset) / height;
		for (uint32_t x = 0; x <= _gridX; x++)
		{
			float posX = xStart + x * xOffset;
			float u = (uStart + x * xOffset) / width;
			_points.push_back({posX, posY, 0, 1.0f});
			_vertices.push_back({0, 0, 0, 0, u, v, Color::White.toABGR()});
			if (x < _gridX && y < _gridY)
			{
				_indices.push_back(y * xCount + x);
				_indices.push_back(y * xCount + x + 1);
				_indices.push_back((y + 1) * xCount + x);

				_indices.push_back((y + 1) * xCount + x);
				_indices.push_back(y * xCount + x + 1);
				_indices.push_back((y + 1) * xCount + x + 1);
			}
		}
	}
	_flags.setOn(Grid::VertexPosDirty);
}

void Grid::updateUV()
{
	float uStart = _textureRect.getX();
	float vStart = _textureRect.getY();
	float width = _textureRect.getWidth();
	float height = _textureRect.getHeight();
	float yOffset = height / _gridY;
	float xOffset = width / _gridX;
	uint32_t xCount = _gridX + 1;
	for (uint32_t y = 0; y <= _gridY; y++)
	{
		float v = (vStart + y * yOffset) / height;
		for (uint32_t x = 0; x <= _gridX; x++)
		{
			float u = (uStart + x * xOffset) / width;
			auto index = y * xCount + x;
			_vertices[index].u = u;
			_vertices[index].v = v;
		}
	}
}

const Matrix& Grid::getWorld()
{
	if (_flags.isOn(Node::WorldDirty))
	{
		_flags.setOn(Grid::VertexPosDirty);
	}
	return Node::getWorld();
}

void Grid::render()
{
	if (!_texture || !_effect || _vertices.empty()) return;

	if (_flags.isOn(Grid::VertexPosDirty))
	{
		_flags.setOff(Grid::VertexPosDirty);
		Matrix transform;
		bx::mtxMul(transform, _world, SharedDirector.getViewProjection());
		for (size_t i = 0; i < _points.size(); i++)
		{
			bx::vec4MulMtx(&_vertices[i].x, &_points[i].x, transform);
		}
	}

	uint64_t renderState = (
		BGFX_STATE_WRITE_RGB | BGFX_STATE_WRITE_A |
		BGFX_STATE_MSAA | _blendFunc.toValue());
	if (isDepthWrite())
	{
		renderState |= (BGFX_STATE_WRITE_Z | BGFX_STATE_DEPTH_TEST_LESS);
	}

	SharedRendererManager.setCurrent(SharedSpriteRenderer.getTarget());
	SharedSpriteRenderer.push(
		_vertices.data(), _vertices.size(),
		_indices.data(), _indices.size(),
		_effect, _texture, renderState);
}

NS_DOROTHY_END
