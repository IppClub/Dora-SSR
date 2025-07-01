/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/DrawNode.h"

#include "Basic/Application.h"
#include "Basic/Director.h"
#include "Cache/ShaderCache.h"
#include "Effect/Effect.h"
#include "Render/View.h"

NS_DORA_BEGIN

/* DrawNode */

bgfx::VertexLayout DrawVertex::ms_layout;
DrawVertex::Init DrawVertex::init;

DrawNode::DrawNode()
	: _renderState(BGFX_STATE_NONE)
	, _blendFunc(BlendFunc::Default) { }

void DrawNode::setBlendFunc(const BlendFunc& var) {
	_blendFunc = var;
}

const BlendFunc& DrawNode::getBlendFunc() const noexcept {
	return _blendFunc;
}

void DrawNode::setDepthWrite(bool var) {
	_flags.set(DrawNode::DepthWrite, var);
}

bool DrawNode::isDepthWrite() const noexcept {
	return _flags.isOn(DrawNode::DepthWrite);
}

uint64_t DrawNode::getRenderState() const noexcept {
	return _renderState;
}

const std::vector<DrawVertex>& DrawNode::getVertices() const noexcept {
	return _vertices;
}

const std::vector<uint16_t>& DrawNode::getIndices() const noexcept {
	return _indices;
}

void DrawNode::updateRealColor3() {
	Node::updateRealColor3();
	_flags.setOn(DrawNode::VertexColorDirty);
}

void DrawNode::updateRealOpacity() {
	Node::updateRealOpacity();
	_flags.setOn(DrawNode::VertexColorDirty);
}

const Matrix& DrawNode::getWorld() {
	if (_flags.isOn(Node::WorldDirty)) {
		_flags.setOn(DrawNode::VertexPosDirty);
	}
	return Node::getWorld();
}

void DrawNode::render() {
	if (_vertices.empty()) {
		Node::render();
		return;
	}

	if (SharedDirector.isFrustumCulling()) {
		auto [minX, maxX] = std::minmax_element(_posColors.begin(), _posColors.end(), [](const auto& a, const auto& b) {
			return a.pos.x < b.pos.x;
		});
		auto [minY, maxY] = std::minmax_element(_posColors.begin(), _posColors.end(), [](const auto& a, const auto& b) {
			return a.pos.y < b.pos.y;
		});
		AABB aabb;
		Matrix::mulAABB(aabb, getWorld(), {
										  {minX->pos.x, minY->pos.y, 0},
										  {maxX->pos.x, maxY->pos.y, 0},
									  });
		if (!SharedDirector.isInFrustum(aabb)) {
			return;
		}
	}

	if (_flags.isOn(DrawNode::VertexColorDirty)) {
		_flags.setOff(DrawNode::VertexColorDirty);
		Vec4 ucolor = _realColor.toVec4();
		for (size_t i = 0; i < _posColors.size(); i++) {
			const Vec4& acolor = _posColors[i].color;
			Vec4 color{
				acolor.x * ucolor.x,
				acolor.y * ucolor.y,
				acolor.z * ucolor.z,
				acolor.w * ucolor.w};
			_vertices[i].abgr = Color(color).toABGR();
		}
	}

	if (_flags.isOn(DrawNode::VertexPosDirty)) {
		_flags.setOff(DrawNode::VertexPosDirty);
		Matrix transform;
		Matrix::mulMtx(transform, SharedDirector.getViewProjection(), getWorld());
		for (size_t i = 0; i < _vertices.size(); i++) {
			Matrix::mulVec4(&_vertices[i].x, transform, _posColors[i].pos);
		}
	}

	_renderState = BGFX_STATE_WRITE_RGB | BGFX_STATE_WRITE_A | _blendFunc.toValue();
	if (_flags.isOn(DrawNode::DepthWrite)) {
		_renderState |= (BGFX_STATE_WRITE_Z | BGFX_STATE_DEPTH_TEST_LESS);
	}

	SharedRendererManager.setCurrent(SharedDrawRenderer.getTarget());
	SharedDrawRenderer.push(this);

	Node::render();
}

void DrawNode::pushVertex(const Vec2& pos, const Vec4& color, const Vec2& coord) {
	_posColors.push_back({{pos.x, pos.y, 0, 1}, color});
	_vertices.push_back({0, 0, 0, 0, 0, coord.x, coord.y});
}

void DrawNode::drawDot(const Vec2& pos, float radius, Color color) {
	const size_t vertexCount = 4;
	const size_t indexCount = 6;

	_posColors.reserve(_posColors.size() + vertexCount);
	_vertices.reserve(_vertices.size() + vertexCount);
	_indices.reserve(_indices.size() + indexCount);

	Vec4 color4 = color.toVec4();
	uint16_t start = s_cast<uint16_t>(_vertices.size());
	pushVertex({pos.x - radius, pos.y - radius}, color4, {-1, -1});
	pushVertex({pos.x - radius, pos.y + radius}, color4, {-1, 1});
	pushVertex({pos.x + radius, pos.y + radius}, color4, {1, 1});
	pushVertex({pos.x + radius, pos.y - radius}, color4, {1, -1});

	const uint16_t indices[] = {0, 1, 2, 0, 2, 3};
	for (uint16_t index : indices) {
		_indices.push_back(start + index);
	}

	_flags.setOn(DrawNode::VertexColorDirty);
	_flags.setOn(DrawNode::VertexPosDirty);
}

void DrawNode::drawSegment(const Vec2& from, const Vec2& to, float radius, Color color) {
	const size_t vertexCount = 6 * 3;
	const size_t indexCount = vertexCount;
	_posColors.reserve(_posColors.size() + vertexCount);
	_vertices.reserve(_vertices.size() + vertexCount);
	_indices.reserve(_indices.size() + indexCount);

	Vec2 a = from;
	Vec2 b = to;

	Vec2 n = Vec2::normalize(Vec2::perp(b - a));
	Vec2 t = Vec2::perp(n);

	Vec2 nw = n * radius;
	Vec2 tw = t * radius;
	Vec2 v0 = b - (nw + tw);
	Vec2 v1 = b + (nw - tw);
	Vec2 v2 = b - nw;
	Vec2 v3 = b + nw;
	Vec2 v4 = a - nw;
	Vec2 v5 = a + nw;
	Vec2 v6 = a - (nw - tw);
	Vec2 v7 = a + nw + tw;

	uint16_t start = s_cast<uint16_t>(_vertices.size());
	Vec4 color4 = color.toVec4();

	pushVertex(v0, color4, -(n + t));
	pushVertex(v1, color4, n - t);
	pushVertex(v2, color4, -n);

	pushVertex(v3, color4, n);
	pushVertex(v1, color4, n - t);
	pushVertex(v2, color4, -n);

	pushVertex(v3, color4, n);
	pushVertex(v4, color4, -n);
	pushVertex(v2, color4, -n);

	pushVertex(v3, color4, n);
	pushVertex(v4, color4, -n);
	pushVertex(v5, color4, n);

	pushVertex(v6, color4, t - n);
	pushVertex(v4, color4, -n);
	pushVertex(v5, color4, n);

	pushVertex(v6, color4, t - n);
	pushVertex(v7, color4, n + t);
	pushVertex(v5, color4, n);

	for (uint16_t i = 0; i < indexCount; i++) {
		_indices.push_back(start + i);
	}

	_flags.setOn(DrawNode::VertexColorDirty);
	_flags.setOn(DrawNode::VertexPosDirty);
}

void DrawNode::drawPolygon(const std::vector<Vec2>& verts, Color fillColor, float borderWidth, Color borderColor) {
	drawPolygon(verts.data(), s_cast<uint32_t>(verts.size()), fillColor, borderWidth, borderColor);
}

void DrawNode::drawPolygon(const Vec2* verts, uint32_t count, Color fillColor, float borderWidth, Color borderColor) {
	bool outline = (borderColor.a > 0 && borderWidth > 0.0f);
	bool fillPoly = (fillColor.a > 0);

	if (fillPoly && !outline) {
		const size_t triangleCount = 3 * count - 2;
		const size_t vertexCount = 3 * triangleCount;
		_posColors.reserve(vertexCount);
		_vertices.reserve(vertexCount);

		Vec4 fillColor4 = fillColor.toVec4();
		uint16_t start = s_cast<uint16_t>(_vertices.size());
		for (uint32_t i = 0; i < count - 2; i++) {
			Vec2 v0 = verts[0];
			Vec2 v1 = verts[i + 1];
			Vec2 v2 = verts[i + 2];

			pushVertex(v0, fillColor4, Vec2::zero);
			pushVertex(v1, fillColor4, Vec2::zero);
			pushVertex(v2, fillColor4, Vec2::zero);
		}

		const size_t indexCount = _vertices.size() - start;
		_indices.reserve(indexCount);

		for (uint16_t i = 0; i < indexCount; i++) {
			_indices.push_back(start + i);
		}

		_flags.setOn(DrawNode::VertexColorDirty);
		_flags.setOn(DrawNode::VertexPosDirty);
		return;
	}

	struct ExtrudeVerts {
		Vec2 offset, n;
	};
	std::vector<ExtrudeVerts> extrude(count, {Vec2::zero, Vec2::zero});
	for (uint32_t i = 0; i < count; i++) {
		Vec2 v0 = verts[(i - 1 + count) % count];
		Vec2 v1 = verts[i];
		Vec2 v2 = verts[(i + 1) % count];
		Vec2 n1 = Vec2::normalize(Vec2::perp(v1 - v0));
		Vec2 n2 = Vec2::normalize(Vec2::perp(v2 - v1));
		Vec2 offset = (n1 + n2) * (1.0f / (n1.dot(n2) + 1.0f));
		extrude[i] = {offset, n2};
	}

	const size_t triangleCount = 3 * count - 2;
	const size_t vertexCount = 3 * triangleCount - (fillPoly ? 0 : count - 2);
	_posColors.reserve(vertexCount);
	_vertices.reserve(vertexCount);

	Vec4 fillColor4 = fillColor.toVec4();
	Vec4 borderColor4 = borderColor.toVec4();
	uint16_t start = s_cast<uint16_t>(_vertices.size());

	float inset = (outline ? 0.0f : 0.5f);
	if (fillPoly) {
		for (uint32_t i = 0; i < count - 2; i++) {
			Vec2 v0 = verts[0] - (extrude[0].offset * inset);
			Vec2 v1 = verts[i + 1] - (extrude[i + 1].offset * inset);
			Vec2 v2 = verts[i + 2] - (extrude[i + 2].offset * inset);

			pushVertex(v0, fillColor4, Vec2::zero);
			pushVertex(v1, fillColor4, Vec2::zero);
			pushVertex(v2, fillColor4, Vec2::zero);
		}
	}

	for (uint32_t i = 0; i < count; i++) {
		uint32_t j = (i + 1) % count;
		Vec2 v0 = verts[i];
		Vec2 v1 = verts[j];
		Vec2 n0 = extrude[i].n;
		Vec2 offset0 = extrude[i].offset;
		Vec2 offset1 = extrude[j].offset;
		if (outline) {
			Vec2 inner0 = v0 - (offset0 * borderWidth);
			Vec2 inner1 = v1 - (offset1 * borderWidth);
			Vec2 outer0 = v0 + (offset0 * borderWidth);
			Vec2 outer1 = v1 + (offset1 * borderWidth);

			pushVertex(inner0, borderColor4, -n0);
			pushVertex(inner1, borderColor4, -n0);
			pushVertex(outer1, borderColor4, n0);

			pushVertex(inner0, borderColor4, -n0);
			pushVertex(outer0, borderColor4, n0);
			pushVertex(outer1, borderColor4, n0);
		} else {
			Vec2 inner0 = v0 - (offset0 * 0.5f);
			Vec2 inner1 = v1 - (offset1 * 0.5f);
			Vec2 outer0 = v0 + (offset0 * 0.5f);
			Vec2 outer1 = v1 + (offset1 * 0.5f);

			pushVertex(inner0, fillColor4, Vec2::zero);
			pushVertex(inner1, fillColor4, Vec2::zero);
			pushVertex(outer1, fillColor4, n0);

			pushVertex(inner0, fillColor4, Vec2::zero);
			pushVertex(outer0, fillColor4, n0);
			pushVertex(outer1, fillColor4, n0);
		}
	}

	const size_t indexCount = _vertices.size() - start;
	_indices.reserve(indexCount);

	for (uint16_t i = 0; i < indexCount; i++) {
		_indices.push_back(start + i);
	}

	_flags.setOn(DrawNode::VertexColorDirty);
	_flags.setOn(DrawNode::VertexPosDirty);
}

void DrawNode::drawVertices(const std::vector<VertexColor>& verts) {
	uint32_t count = s_cast<uint32_t>(verts.size());
	const size_t triangleCount = 3 * count - 2;
	const size_t vertexCount = 3 * triangleCount;
	_posColors.reserve(vertexCount);
	_vertices.reserve(vertexCount);

	uint16_t start = s_cast<uint16_t>(_vertices.size());

	for (uint32_t i = 0; i < count - 2; i++) {
		pushVertex(verts[0].vertex, verts[0].color.toVec4(), Vec2::zero);
		pushVertex(verts[i + 1].vertex, verts[i + 1].color.toVec4(), Vec2::zero);
		pushVertex(verts[i + 2].vertex, verts[i + 2].color.toVec4(), Vec2::zero);
	}

	const size_t indexCount = _vertices.size() - start;
	_indices.reserve(indexCount);

	for (uint16_t i = 0; i < indexCount; i++) {
		_indices.push_back(start + i);
	}

	_flags.setOn(DrawNode::VertexColorDirty);
	_flags.setOn(DrawNode::VertexPosDirty);
}

void DrawNode::clear() {
	_posColors.clear();
	_vertices.clear();
	_indices.clear();
}

/* DrawRenderer */

DrawRenderer::DrawRenderer()
	: _defaultPass(Pass::create("builtin:vs_draw"_slice, "builtin:fs_draw"_slice))
	, _lastState(BGFX_STATE_NONE) { }

Pass* DrawRenderer::getDefaultPass() const noexcept {
	return _defaultPass;
}

void DrawRenderer::push(DrawNode* node) {
	uint64_t state = node->getRenderState();
	if (state != _lastState) {
		render();
	}
	_lastState = state;

	uint16_t start = s_cast<uint16_t>(_vertices.size());
	const auto& verts = node->getVertices();
	_vertices.reserve(_vertices.size() + verts.size());
	_vertices.insert(_vertices.end(), verts.begin(), verts.end());

	const auto& indices = node->getIndices();
	_indices.reserve(_indices.size() + indices.size());
	for (const auto& index : indices) {
		_indices.push_back(start + index);
	}
}

void DrawRenderer::render() {
	if (!_vertices.empty()) {
		bgfx::TransientVertexBuffer vertexBuffer;
		bgfx::TransientIndexBuffer indexBuffer;
		uint32_t vertexCount = s_cast<uint32_t>(_vertices.size());
		uint32_t indexCount = s_cast<uint32_t>(_indices.size());
		if (bgfx::allocTransientBuffers(
				&vertexBuffer, DrawVertex::ms_layout, vertexCount,
				&indexBuffer, indexCount)) {
			Renderer::render();
			std::memcpy(vertexBuffer.data, _vertices.data(), _vertices.size() * sizeof(_vertices[0]));
			std::memcpy(indexBuffer.data, _indices.data(), _indices.size() * sizeof(_indices[0]));
			bgfx::setVertexBuffer(0, &vertexBuffer);
			bgfx::setIndexBuffer(&indexBuffer);
			bgfx::setState(_lastState);
			bgfx::ViewId viewId = SharedView.getId();
			bgfx::submit(viewId, _defaultPass->apply());
		} else {
			Warn("not enough transient buffer for {} vertices, {} indices.", vertexCount, indexCount);
		}
		_vertices.clear();
		_indices.clear();
		_lastState = BGFX_STATE_NONE;
	}
}

/* Line */

bgfx::VertexLayout PosColorVertex::ms_layout;
PosColorVertex::Init PosColorVertex::init;

Line::Line()
	: _blendFunc{BlendFunc::One, BlendFunc::InvSrcAlpha}
	, _renderState(BGFX_STATE_NONE) { }

Line::Line(const std::vector<Vec2>& verts, Color color)
	: Line() {
	if (verts.empty()) return;
	_posColors.reserve(verts.size());
	_vertices.reserve(verts.size());
	Vec4 color4 = color.toVec4();
	for (const auto& vert : verts) {
		_posColors.push_back({{vert.x, vert.y, 0, 1}, color4});
	}
	_flags.setOn(Line::VertexColorDirty);
	_flags.setOn(Line::VertexPosDirty);
}

Line::Line(const Vec2* verts, uint32_t size, Color color)
	: Line() {
	if (size == 0) return;
	_posColors.reserve(size);
	_vertices.reserve(size);
	Vec4 color4 = color.toVec4();
	for (uint32_t i = 0; i < size; i++) {
		Vec2 vert = verts[i];
		_posColors.push_back({{vert.x, vert.y, 0, 1}, color4});
	}
	_flags.setOn(Line::VertexColorDirty);
	_flags.setOn(Line::VertexPosDirty);
}

void Line::setBlendFunc(BlendFunc var) {
	_blendFunc = var;
}

BlendFunc Line::getBlendFunc() const noexcept {
	return _blendFunc;
}

void Line::setDepthWrite(bool var) {
	_flags.set(Line::DepthWrite, var);
}

bool Line::isDepthWrite() const noexcept {
	return _flags.isOn(Line::DepthWrite);
}

uint64_t Line::getRenderState() const noexcept {
	return _renderState;
}

const std::vector<PosColorVertex>& Line::getVertices() const noexcept {
	return _vertices;
}

void Line::add(const std::vector<Vec2>& verts, Color color) {
	if (verts.empty()) return;
	if (!_posColors.empty()) {
		_posColors.push_back(_posColors.back());
		_posColors.back().color = {0, 0, 0, 0};
		Vec2 front = verts.front();
		_posColors.push_back({{front.x, front.y, 0, 1}, {0, 0, 0, 0}});
	}
	_posColors.reserve(_posColors.size() + verts.size());
	Vec4 color4 = color.toVec4();
	for (const auto& vert : verts) {
		_posColors.push_back({{vert.x, vert.y, 0, 1}, color4});
	}
	_flags.setOn(Line::VertexColorDirty);
	_flags.setOn(Line::VertexPosDirty);
}

void Line::add(const Vec2* verts, uint32_t size, Color color) {
	if (size == 0) return;
	if (!_posColors.empty()) {
		_posColors.push_back(_posColors.back());
		_posColors.back().color = {0, 0, 0, 0};
		Vec2 front = verts[0];
		_posColors.push_back({{front.x, front.y, 0, 1}, {0, 0, 0, 0}});
	}
	_posColors.reserve(_posColors.size() + size);
	Vec4 color4 = color.toVec4();
	for (uint32_t i = 0; i < size; i++) {
		Vec2 vert = verts[i];
		_posColors.push_back({{vert.x, vert.y, 0, 1}, color4});
	}
	_flags.setOn(Line::VertexColorDirty);
	_flags.setOn(Line::VertexPosDirty);
}

void Line::set(const std::vector<Vec2>& verts, Color color) {
	clear();
	add(verts, color);
}

void Line::set(const Vec2* verts, uint32_t size, Color color) {
	clear();
	add(verts, size, color);
}

void Line::clear() {
	_posColors.clear();
	_flags.setOn(Line::VertexColorDirty);
	_flags.setOn(Line::VertexPosDirty);
}

void Line::updateRealColor3() {
	Node::updateRealColor3();
	_flags.setOn(Line::VertexColorDirty);
}

void Line::updateRealOpacity() {
	Node::updateRealOpacity();
	_flags.setOn(Line::VertexColorDirty);
}

const Matrix& Line::getWorld() {
	if (_flags.isOn(Node::WorldDirty)) {
		_flags.setOn(Line::VertexPosDirty);
	}
	return Node::getWorld();
}

void Line::render() {
	if (_posColors.empty()) {
		Node::render();
		return;
	}

	if (SharedDirector.isFrustumCulling()) {
		auto [minX, maxX] = std::minmax_element(_posColors.begin(), _posColors.end(), [](const auto& a, const auto& b) {
			return a.pos.x < b.pos.x;
		});
		auto [minY, maxY] = std::minmax_element(_posColors.begin(), _posColors.end(), [](const auto& a, const auto& b) {
			return a.pos.y < b.pos.y;
		});
		AABB aabb;
		Matrix::mulAABB(aabb, getWorld(), {
										  {minX->pos.x, minY->pos.y, 0},
										  {maxX->pos.x, maxY->pos.y, 0},
									  });
		if (!SharedDirector.isInFrustum(aabb)) {
			return;
		}
	}

	if (_vertices.size() != _posColors.size()) {
		_vertices.resize(_posColors.size());
	}

	if (_flags.isOn(Line::VertexColorDirty)) {
		_flags.setOff(Line::VertexColorDirty);
		Vec4 ucolor = _realColor.toVec4();
		for (size_t i = 0; i < _posColors.size(); i++) {
			const Vec4& acolor = _posColors[i].color;
			Vec4 color{
				acolor.x * ucolor.x,
				acolor.y * ucolor.y,
				acolor.z * ucolor.z,
				acolor.w * ucolor.w};
			_vertices[i].abgr = Color(color).toABGR();
		}
	}

	if (_flags.isOn(Line::VertexPosDirty)) {
		_flags.setOff(Line::VertexPosDirty);
		Matrix transform;
		Matrix::mulMtx(transform, SharedDirector.getViewProjection(), getWorld());
		for (size_t i = 0; i < _vertices.size(); i++) {
			Matrix::mulVec4(&_vertices[i].x, transform, _posColors[i].pos);
		}
	}

	_renderState = BGFX_STATE_WRITE_RGB | BGFX_STATE_WRITE_A | BGFX_STATE_PT_LINESTRIP | _blendFunc.toValue();
	if (_flags.isOn(Line::DepthWrite)) {
		_renderState |= (BGFX_STATE_WRITE_Z | BGFX_STATE_DEPTH_TEST_LESS);
	}

	SharedRendererManager.setCurrent(SharedLineRenderer.getTarget());
	SharedLineRenderer.push(this);

	Node::render();
}

/* LineRenderer */

LineRenderer::LineRenderer()
	: _defaultPass(Pass::create("builtin:vs_poscolor"_slice, "builtin:fs_poscolor"_slice))
	, _lastState(BGFX_STATE_NONE) { }

Pass* LineRenderer::getDefaultPass() const noexcept {
	return _defaultPass;
}

void LineRenderer::push(Line* line) {
	uint64_t state = line->getRenderState();
	if (state != _lastState) {
		render();
	}
	_lastState = state;
	const auto& verts = line->getVertices();
	_vertices.reserve(_vertices.size() + verts.size());
	if (!_vertices.empty()) {
		_vertices.push_back(_vertices.back());
		_vertices.back().abgr = 0;
		_vertices.push_back(verts.front());
		_vertices.back().abgr = 0;
	}
	_vertices.insert(_vertices.end(), verts.begin(), verts.end());
}

void LineRenderer::pushRect(PosColorVertex verts[4]) {
	uint64_t state = BGFX_STATE_WRITE_RGB | BGFX_STATE_WRITE_A | BGFX_STATE_PT_LINESTRIP | BlendFunc::Default.toValue();
	if (state != _lastState) {
		render();
	}
	_lastState = state;
	if (!_vertices.empty()) {
		_vertices.reserve(_vertices.size() + 6);
		_vertices.push_back(_vertices.back());
		_vertices.back().abgr = 0;
		_vertices.push_back(verts[0]);
		_vertices.back().abgr = 0;
	} else {
		_vertices.reserve(_vertices.size() + 4);
	}
	_vertices.push_back(verts[0]);
	_vertices.push_back(verts[1]);
	_vertices.push_back(verts[2]);
	_vertices.push_back(verts[3]);
	_vertices.push_back(verts[0]);
}

void LineRenderer::pushSegment(PosColorVertex verts[2]) {
	uint64_t state = BGFX_STATE_WRITE_RGB | BGFX_STATE_WRITE_A | BGFX_STATE_PT_LINESTRIP | BlendFunc::Default.toValue();
	if (state != _lastState) {
		render();
	}
	_lastState = state;
	if (!_vertices.empty()) {
		_vertices.reserve(_vertices.size() + 4);
		_vertices.push_back(_vertices.back());
		_vertices.back().abgr = 0;
		_vertices.push_back(verts[0]);
		_vertices.back().abgr = 0;
	} else {
		_vertices.reserve(_vertices.size() + 2);
	}
	_vertices.push_back(verts[0]);
	_vertices.push_back(verts[1]);
}

void LineRenderer::render() {
	if (!_vertices.empty()) {
		bgfx::TransientVertexBuffer vertexBuffer;
		uint32_t vertexCount = s_cast<uint32_t>(_vertices.size());
		if (bgfx::getAvailTransientVertexBuffer(vertexCount, PosColorVertex::ms_layout) >= vertexCount) {
			bgfx::allocTransientVertexBuffer(&vertexBuffer, vertexCount, PosColorVertex::ms_layout);
			Renderer::render();
			std::memcpy(vertexBuffer.data, _vertices.data(), _vertices.size() * sizeof(_vertices[0]));
			bgfx::setVertexBuffer(0, &vertexBuffer);
			bgfx::setState(_lastState);
			bgfx::ViewId viewId = SharedView.getId();
			bgfx::submit(viewId, _defaultPass->apply());
		} else {
			Warn("not enough transient buffer for {} vertices.", vertexCount);
		}
		_vertices.clear();
		_lastState = BGFX_STATE_NONE;
	}
}

NS_DORA_END
