/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/Grid.h"

#include "Basic/Director.h"
#include "Cache/ClipCache.h"
#include "Effect/Effect.h"

NS_DORA_BEGIN

Grid::Grid(float width, float height, uint32_t gridX, uint32_t gridY)
	: Grid(nullptr, {width, height}, Rect(0, 0, width, height), gridX, gridY) { }

Grid::Grid(Texture2D* texture, uint32_t gridX, uint32_t gridY)
	: Grid(
		  texture,
		  Size{s_cast<float>(texture->getWidth()), s_cast<float>(texture->getHeight())},
		  Rect(0, 0, s_cast<float>(texture->getWidth()), s_cast<float>(texture->getHeight())),
		  gridX, gridY) { }

Grid::Grid(Texture2D* texture, const Rect& textureRect, uint32_t gridX, uint32_t gridY)
	: Grid(
		  texture,
		  Size{s_cast<float>(texture->getWidth()), s_cast<float>(texture->getHeight())},
		  textureRect, gridX, gridY) { }

Grid::Grid(Texture2D* texture, const Size& texSize, const Rect& textureRect, uint32_t gridX, uint32_t gridY)
	: _gridX(gridX)
	, _gridY(gridY)
	, _effect(SharedSpriteRenderer.getDefaultEffect())
	, _texture(texture)
	, _texSize(texSize)
	, _textureRect(textureRect)
	, _blendFunc(BlendFunc::Default) { }

bool Grid::init() {
	if (!Node::init()) return false;
	setupVertices();
	return true;
}

uint32_t Grid::getGridX() const noexcept {
	return _gridX;
}

uint32_t Grid::getGridY() const noexcept {
	return _gridY;
}

void Grid::setTexture(Texture2D* var) {
	_texture = var;
	if (!_texture) return;
	_texSize = Size{
		s_cast<float>(_texture->getWidth()),
		s_cast<float>(_texture->getHeight())};
	if (_textureRect == Rect::zero) {
		_textureRect.set(0, 0, s_cast<float>(var->getWidth()), s_cast<float>(var->getHeight()));
		updateUV();
	}
}

Texture2D* Grid::getTexture() const noexcept {
	return _texture;
}

void Grid::setTextureRect(const Rect& var) {
	if (_textureRect != var) {
		_textureRect = var;
		updateUV();
	}
}

const Rect& Grid::getTextureRect() const noexcept {
	return _textureRect;
}

void Grid::setEffect(SpriteEffect* var) {
	_effect = var ? var : SharedSpriteRenderer.getDefaultEffect();
}

SpriteEffect* Grid::getEffect() const noexcept {
	return _effect;
}

void Grid::setBlendFunc(const BlendFunc& var) {
	_blendFunc = var;
}

const BlendFunc& Grid::getBlendFunc() const noexcept {
	return _blendFunc;
}

void Grid::setDepthWrite(bool var) {
	_flags.set(Grid::DepthWrite, var);
}

bool Grid::isDepthWrite() const noexcept {
	return _flags.isOn(Grid::DepthWrite);
}

void Grid::setPos(int x, int y, Vec2 pos, float z) {
	AssertIf(x < 0 || x > s_cast<int>(_gridX) || y < 0 || y > s_cast<int>(_gridY), "Grid vertex index {}, {} is out of bounds [0, {}], [0, {}]", x, y, _gridX, _gridY);
	auto index = y * (_gridX + 1) + x;
	_points[index].position = {pos.x, pos.y, z, 1.0f};
	_flags.setOn(Grid::VertexPosDirty);
}

Vec2 Grid::getPos(int x, int y, float* z) const {
	AssertIf(x < 0 || x > s_cast<int>(_gridX) || y < 0 || y > s_cast<int>(_gridY), "Grid vertex index {}, {} is out of bounds [0, {}], [0, {}]", x, y, _gridX, _gridY);
	auto index = y * (_gridX + 1) + x;
	if (z) *z = _points[index].position.z;
	return {_points[index].position.x, _points[index].position.y};
}

Color Grid::getColor(int x, int y) const {
	AssertIf(x < 0 || x > s_cast<int>(_gridX) || y < 0 || y > s_cast<int>(_gridY), "Grid vertex index {}, {} is out of bounds [0, {}], [0, {}]", x, y, _gridX, _gridY);
	auto index = y * (_gridX + 1) + x;
	return Color(_vertices[index].abgr);
}

void Grid::setColor(int x, int y, Color color) {
	AssertIf(x < 0 || x > s_cast<int>(_gridX) || y < 0 || y > s_cast<int>(_gridY), "Grid vertex index {}, {} is out of bounds [0, {}], [0, {}]", x, y, _gridX, _gridY);
	auto index = y * (_gridX + 1) + x;
	_points[index].color = color.toVec4();
	_flags.setOn(Grid::VertexColorDirty);
}

void Grid::moveUV(int x, int y, Vec2 offset) {
	AssertIf(x < 0 || x > s_cast<int>(_gridX) || y < 0 || y > s_cast<int>(_gridY), "Grid vertex index {}, {} is out of bounds [0, {}], [0, {}]", x, y, _gridX, _gridY);
	auto index = y * (_gridX + 1) + x;
	_vertices[index].u += offset.x / _texSize.width;
	_vertices[index].v += offset.y / _texSize.height;
	_points[index].position.x += offset.x;
	_points[index].position.y -= offset.y;
	_flags.setOn(Grid::VertexPosDirty);
}

void Grid::setupVertices() {
	float uStart = _textureRect.getX();
	float vStart = _textureRect.getY();
	float width = _textureRect.getWidth();
	float height = _textureRect.getHeight();
	float texWidth = _texSize.width;
	float texHeight = _texSize.height;
	float xStart = -width / 2.0f;
	float yStart = height / 2.0f;
	float yOffset = height / _gridY;
	float xOffset = width / _gridX;
	uint32_t xCount = _gridX + 1;
	for (uint32_t y = 0; y <= _gridY; y++) {
		float posY = yStart - y * yOffset;
		float v = (vStart + y * yOffset) / texHeight;
		for (uint32_t x = 0; x <= _gridX; x++) {
			float posX = xStart + x * xOffset;
			float u = (uStart + x * xOffset) / texWidth;
			_points.push_back({{posX, posY, 0, 1.0f}, {1.0f, 1.0f, 1.0f, 1.0f}});
			_vertices.push_back({0, 0, 0, 0, u, v, 0xffffffff});
			if (x < _gridX && y < _gridY) {
				_indices.push_back(y * xCount + x);
				_indices.push_back(y * xCount + x + 1);
				_indices.push_back((y + 1) * xCount + x);

				_indices.push_back((y + 1) * xCount + x);
				_indices.push_back(y * xCount + x + 1);
				_indices.push_back((y + 1) * xCount + x + 1);
			}
		}
	}
	_flags.setOn(Grid::VertexColorDirty);
	_flags.setOn(Grid::VertexPosDirty);
}

void Grid::updateUV() {
	float uStart = _textureRect.getX();
	float vStart = _textureRect.getY();
	float width = _textureRect.getWidth();
	float height = _textureRect.getHeight();
	float yOffset = height / _gridY;
	float xOffset = width / _gridX;
	uint32_t xCount = _gridX + 1;
	for (uint32_t y = 0; y <= _gridY; y++) {
		float v = (vStart + y * yOffset) / _texSize.height;
		for (uint32_t x = 0; x <= _gridX; x++) {
			float u = (uStart + x * xOffset) / _texSize.width;
			auto index = y * xCount + x;
			_vertices[index].u = u;
			_vertices[index].v = v;
		}
	}
}

const Matrix& Grid::getWorld() {
	if (_flags.isOn(Node::WorldDirty)) {
		_flags.setOn(Grid::VertexPosDirty);
	}
	return Node::getWorld();
}

void Grid::render() {
	if (!_texture || !_effect || _vertices.empty()) {
		Node::render();
		return;
	}

	if (SharedDirector.isFrustumCulling()) {
		auto [minX, maxX] = std::minmax_element(_points.begin(), _points.end(), [](const auto& a, const auto& b) {
			return a.position.x < b.position.x;
		});
		auto [minY, maxY] = std::minmax_element(_points.begin(), _points.end(), [](const auto& a, const auto& b) {
			return a.position.y < b.position.y;
		});
		AABB aabb;
		Matrix::mulAABB(aabb, getWorld(), {
											  {minX->position.x, minY->position.y, 0},
											  {maxX->position.x, maxY->position.y, 0},
										  });
		if (!SharedDirector.isInFrustum(aabb)) {
			return;
		}
	}

	if (_flags.isOn(Grid::VertexColorDirty)) {
		_flags.setOff(Grid::VertexColorDirty);
		for (size_t i = 0; i < _points.size(); i++) {
			auto rc = _realColor.toVec4();
			const auto& c = _points[i].color;
			_vertices[i].abgr = Color(Vec4{
										  c.x * rc.x,
										  c.y * rc.y,
										  c.z * rc.z,
										  c.w * rc.w})
									.toABGR();
		}
	}

	if (_flags.isOn(Grid::VertexPosDirty)) {
		_flags.setOff(Grid::VertexPosDirty);
		Matrix transform;
		Matrix::mulMtx(transform, SharedDirector.getViewProjection(), getWorld());
		for (size_t i = 0; i < _points.size(); i++) {
			Matrix::mulVec4(&_vertices[i].x, transform, _points[i].position);
		}
	}

	uint64_t renderState = (BGFX_STATE_WRITE_RGB | BGFX_STATE_WRITE_A | BGFX_STATE_MSAA | _blendFunc.toValue());
	if (isDepthWrite()) {
		renderState |= (BGFX_STATE_WRITE_Z | BGFX_STATE_DEPTH_TEST_LESS);
	}

	SharedRendererManager.setCurrent(SharedSpriteRenderer.getTarget());
	SharedSpriteRenderer.push(
		_vertices.data(), _vertices.size(),
		_indices.data(), _indices.size(),
		_effect, _texture, renderState);

	Node::render();
}

void Grid::updateRealColor3() {
	Node::updateRealColor3();
	_flags.setOn(Grid::VertexColorDirty);
}

void Grid::updateRealOpacity() {
	Node::updateRealOpacity();
	_flags.setOn(Grid::VertexColorDirty);
}

Grid* Grid::from(String clipStr, uint32_t gridX, uint32_t gridY) {
	Texture2D* tex = nullptr;
	Rect rect;
	std::tie(tex, rect) = SharedClipCache.loadTexture(clipStr);
	if (tex) {
		return Grid::create(tex, rect, gridX, gridY);
	}
	return nullptr;
}

NS_DORA_END
