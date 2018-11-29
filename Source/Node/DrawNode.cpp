/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Node/DrawNode.h"
#include "Basic/Application.h"
#include "Cache/ShaderCache.h"
#include "Effect/Effect.h"
#include "Basic/Director.h"
#include "Basic/View.h"

NS_DOROTHY_BEGIN

/* DrawNode */

bgfx::VertexDecl DrawVertex::ms_decl;
DrawVertex::Init DrawVertex::init;

DrawNode::DrawNode():
_blendFunc(BlendFunc::Default)
{ }

void DrawNode::setBlendFunc(const BlendFunc& var)
{
	_blendFunc = var;
}

const BlendFunc& DrawNode::getBlendFunc() const
{
	return _blendFunc;
}

void DrawNode::setDepthWrite(bool var)
{
	_flags.setFlag(DrawNode::DepthWrite, var);
}

bool DrawNode::isDepthWrite() const
{
	return _flags.isOn(DrawNode::DepthWrite);
}

Uint64 DrawNode::getRenderState() const
{
	return _renderState;
}

const vector<DrawVertex>& DrawNode::getVertices() const
{
	return _vertices;
}

const vector<Uint16>& DrawNode::getIndices() const
{
	return _indices;
}

void DrawNode::updateRealColor3()
{
	Node::updateRealColor3();
	_flags.setOn(DrawNode::VertexColorDirty);
}

void DrawNode::updateRealOpacity()
{
	Node::updateRealOpacity();
	_flags.setOn(DrawNode::VertexColorDirty);
}

const Matrix& DrawNode::getWorld()
{
	if (_flags.isOn(Node::WorldDirty))
	{
		_flags.setOn(DrawNode::VertexPosDirty);
	}
	return Node::getWorld();
}

void DrawNode::render()
{
	if (_vertices.empty()) return;

	if (_flags.isOn(DrawNode::VertexColorDirty))
	{
		_flags.setOff(DrawNode::VertexColorDirty);
		Vec4 ucolor = _realColor.toVec4();
		for (size_t i = 0; i < _posColors.size(); i++)
		{
			const Vec4& acolor = _posColors[i].color;
			float alpha = acolor.w * ucolor.w;
			Vec4 color {0, 0, 0, alpha};
			bx::vec3Mul(color, acolor, ucolor);
			_vertices[i].abgr = Color(color).toABGR();
		}
	}

	if (_flags.isOn(DrawNode::VertexPosDirty))
	{
		_flags.setOff(DrawNode::VertexPosDirty);
		Matrix transform;
		bx::mtxMul(transform, _world, SharedDirector.getViewProjection());
		for (size_t i = 0; i < _vertices.size(); i++)
		{
			bx::vec4MulMtx(&_vertices[i].x, &_posColors[i].pos.x, transform);
		}
	}

	_renderState = BGFX_STATE_WRITE_RGB | BGFX_STATE_WRITE_A |
		_blendFunc.toValue();
	if (_flags.isOn(DrawNode::DepthWrite))
	{
		_renderState |= BGFX_STATE_DEPTH_TEST_LESS;
	}

	SharedRendererManager.setCurrent(SharedDrawRenderer.getTarget());
	SharedDrawRenderer.push(this);
}

void DrawNode::pushVertex(const Vec2& pos, const Vec4& color, const Vec2& coord)
{
	_posColors.push_back({{pos.x, pos.y, 0, 1}, color});
	_vertices.push_back({0, 0, 0, 0, 0, coord.x, coord.y});
}

void DrawNode::drawDot(const Vec2& pos, float radius, Color color)
{
	const size_t vertexCount = 4;
	const size_t indexCount = 6;

	_posColors.reserve(_posColors.size() + vertexCount);
	_vertices.reserve(_vertices.size() + vertexCount);
	_indices.reserve(_indices.size() + indexCount);

	Vec4 color4 = color.toVec4();
	Uint16 start = s_cast<Uint16>(_vertices.size());
	pushVertex({pos.x - radius, pos.y - radius}, color4, {-1, -1});
	pushVertex({pos.x - radius, pos.y + radius}, color4, {-1, 1});
	pushVertex({pos.x + radius, pos.y + radius}, color4, {1, 1});
	pushVertex({pos.x + radius, pos.y - radius}, color4, {1, -1});

	const Uint16 indices[] = {0, 1, 2, 0, 2, 3};
	for (Uint16 index : indices)
	{
		_indices.push_back(start + index);
	}

	_flags.setOn(DrawNode::VertexColorDirty);
	_flags.setOn(DrawNode::VertexPosDirty);
}

void DrawNode::drawSegment(const Vec2& from, const Vec2& to, float radius, Color color)
{
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

	Uint16 start = s_cast<Uint16>(_vertices.size());
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

	for (Uint16 i = 0; i < indexCount; i++)
	{
		_indices.push_back(start + i);
	}

	_flags.setOn(DrawNode::VertexColorDirty);
	_flags.setOn(DrawNode::VertexPosDirty);
}

void DrawNode::drawPolygon(const vector<Vec2>& verts, Color fillColor, float borderWidth, Color borderColor)
{
	drawPolygon(verts.data(), s_cast<Uint32>(verts.size()), fillColor, borderWidth, borderColor);
}

void DrawNode::drawPolygon(const Vec2* verts, Uint32 count, Color fillColor, float borderWidth, Color borderColor)
{
	struct ExtrudeVerts {Vec2 offset, n;};
	vector<ExtrudeVerts> extrude(count, {Vec2::zero,Vec2::zero});
	for (Uint32 i = 0; i < count; i++)
    {
		Vec2 v0 = verts[(i - 1 + count) % count];
		Vec2 v1 = verts[i];
		Vec2 v2 = verts[(i + 1) % count];
		Vec2 n1 = Vec2::normalize(Vec2::perp(v1 - v0));
		Vec2 n2 = Vec2::normalize(Vec2::perp(v2 - v1));
		Vec2 offset = (n1 + n2) * (1.0f / (n1.dot(n2) + 1.0f));
		extrude[i] = {offset, n2};
	}

	bool outline = (borderColor.a > 0 && borderWidth > 0.0f);
	bool fillPoly = (fillColor.a > 0);

	const size_t triangleCount = 3 * count - 2;
	const size_t vertexCount = 3 * triangleCount - (fillPoly ? 0 : count - 2);
	_posColors.reserve(vertexCount);
	_vertices.reserve(vertexCount);

	Vec4 fillColor4 = fillColor.toVec4();
	Vec4 borderColor4 = borderColor.toVec4();
	Uint16 start = s_cast<Uint16>(_vertices.size());

	float inset = (outline ? 0.0f : 0.5f);
	if (fillPoly)
	{
		for (Uint32 i = 0; i < count - 2; i++)
		{
			Vec2 v0 = verts[0] - (extrude[0].offset * inset);
			Vec2 v1 = verts[i+1] - (extrude[i+1].offset * inset);
			Vec2 v2 = verts[i+2] - (extrude[i+2].offset * inset);

			pushVertex(v0, fillColor4, Vec2::zero);
			pushVertex(v1, fillColor4, Vec2::zero);
			pushVertex(v2, fillColor4, Vec2::zero);
		}
	}

	for (Uint32 i = 0; i < count; i++)
    {
		Uint32 j = (i+1) % count;
		Vec2 v0 = verts[i];
		Vec2 v1 = verts[j];
		Vec2 n0 = extrude[i].n;
		Vec2 offset0 = extrude[i].offset;
		Vec2 offset1 = extrude[j].offset;
		if (outline)
        {
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
		}
        else
		{
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

	for (Uint16 i = 0; i < indexCount; i++)
	{
		_indices.push_back(start + i);
	}

	_flags.setOn(DrawNode::VertexColorDirty);
	_flags.setOn(DrawNode::VertexPosDirty);
}

void DrawNode::drawVertices(const VertexColor* verts, Uint32 count)
{
	const size_t triangleCount = 3 * count - 2;
	const size_t vertexCount = 3 * triangleCount;
	_posColors.reserve(vertexCount);
	_vertices.reserve(vertexCount);

	Uint16 start = s_cast<Uint16>(_vertices.size());

	for (Uint32 i = 0; i < count - 2; i++)
	{
		pushVertex(verts[0].vertex, verts[0].color.toVec4(), Vec2::zero);
		pushVertex(verts[i+1].vertex, verts[i+1].color.toVec4(), Vec2::zero);
		pushVertex(verts[i+2].vertex, verts[i+2].color.toVec4(), Vec2::zero);
	}

	const size_t indexCount = _vertices.size() - start;
	_indices.reserve(indexCount);

	for (Uint16 i = 0; i < indexCount; i++)
	{
		_indices.push_back(start + i);
	}

	_flags.setOn(DrawNode::VertexColorDirty);
	_flags.setOn(DrawNode::VertexPosDirty);
}

void DrawNode::clear()
{
	_posColors.clear();
	_vertices.clear();
	_indices.clear();
}

/* DrawRenderer */

DrawRenderer::DrawRenderer():
_defaultEffect(Effect::create("builtin::vs_draw"_slice, "builtin::fs_draw"_slice)),
_lastState(BGFX_STATE_NONE)
{ }

Effect* DrawRenderer::getDefaultEffect() const
{
	return _defaultEffect;
}

void DrawRenderer::push(DrawNode* node)
{
	Uint64 state = node->getRenderState();
	if (state != _lastState)
	{
		render();
	}
	_lastState = state;

	Uint16 start = s_cast<Uint16>(_vertices.size());
	const auto& verts = node->getVertices();
	_vertices.reserve(_vertices.size() + verts.size());
	_vertices.insert(_vertices.end(), verts.begin(), verts.end());

	const auto& indices = node->getIndices();
	_indices.reserve(_indices.size() + indices.size());
	for (const auto& index : indices)
	{
		_indices.push_back(start + index);
	}
}

void DrawRenderer::render()
{
	if (!_vertices.empty())
	{
		bgfx::TransientVertexBuffer vertexBuffer;
		bgfx::TransientIndexBuffer indexBuffer;
		Uint32 vertexCount = s_cast<Uint32>(_vertices.size());
		Uint32 indexCount = s_cast<Uint32>(_indices.size());
		if (bgfx::allocTransientBuffers(
			&vertexBuffer, DrawVertex::ms_decl, vertexCount,
			&indexBuffer, indexCount))
		{
			Renderer::render();
			std::memcpy(vertexBuffer.data, _vertices.data(), _vertices.size() * sizeof(_vertices[0]));
			std::memcpy(indexBuffer.data, _indices.data(), _indices.size() * sizeof(_indices[0]));
			bgfx::setVertexBuffer(0, &vertexBuffer);
			bgfx::setIndexBuffer(&indexBuffer);
			bgfx::setState(_lastState);
			Uint8 viewId = SharedView.getId();
			bgfx::submit(viewId, _defaultEffect->apply());
		}
		else
		{
			Warn("not enough transient buffer for {} vertices, {} indices.", vertexCount, indexCount);
		}
		_vertices.clear();
		_indices.clear();
		_lastState = BGFX_STATE_NONE;
	}
}

/* Line */

bgfx::VertexDecl PosColorVertex::ms_decl;
PosColorVertex::Init PosColorVertex::init;

Line::Line():
_blendFunc{BlendFunc::One, BlendFunc::InvSrcAlpha},
_renderState(BGFX_STATE_NONE)
{ }

Line::Line(const vector<Vec2>& verts, Color color):
Line()
{
	if (verts.empty()) return;
	_posColors.reserve(verts.size());
	_vertices.reserve(verts.size());
	Vec4 color4 = color.toVec4();
	for (const auto& vert : verts)
	{
		_posColors.push_back({{vert.x, vert.y, 0, 1}, color4});
	}
	_flags.setOn(Line::VertexColorDirty);
	_flags.setOn(Line::VertexPosDirty);
}

Line::Line(const Vec2* verts, Uint32 size, Color color):
Line()
{
	if (size == 0) return;
	_posColors.reserve(size);
	_vertices.reserve(size);
	Vec4 color4 = color.toVec4();
	for (Uint32 i = 0; i < size; i++)
	{
		Vec2 vert = verts[i];
		_posColors.push_back({{vert.x, vert.y, 0, 1}, color4});
	}
	_flags.setOn(Line::VertexColorDirty);
	_flags.setOn(Line::VertexPosDirty);
}

void Line::setBlendFunc(BlendFunc var)
{
	_blendFunc = var;
}

BlendFunc Line::getBlendFunc() const
{
	return _blendFunc;
}

void Line::setDepthWrite(bool var)
{
	_flags.setFlag(Line::DepthWrite, var);
}

bool Line::isDepthWrite() const
{
	return _flags.isOn(Line::DepthWrite);
}

Uint64 Line::getRenderState() const
{
	return _renderState;
}

const vector<PosColorVertex>& Line::getVertices() const
{
	return _vertices;
}

void Line::add(const vector<Vec2>& verts, Color color)
{
	if (verts.empty()) return;
	if (!_posColors.empty())
	{
		_posColors.push_back(_posColors.back());
		_posColors.back().color = {0, 0, 0, 0};
		Vec2 front = verts.front();
		_posColors.push_back({{front.x, front.y, 0, 1}, {0, 0, 0, 0}});
	}
	_posColors.reserve(_posColors.size() + verts.size());
	Vec4 color4 = color.toVec4();
	for (const auto& vert : verts)
	{
		_posColors.push_back({{vert.x, vert.y, 0, 1}, color4});
	}
	_flags.setOn(Line::VertexColorDirty);
	_flags.setOn(Line::VertexPosDirty);
}

void Line::add(const Vec2* verts, Uint32 size, Color color)
{
	if (size == 0) return;
	if (!_posColors.empty())
	{
		_posColors.push_back(_posColors.back());
		_posColors.back().color = {0, 0, 0, 0};
		Vec2 front = verts[0];
		_posColors.push_back({{front.x, front.y, 0, 1}, {0, 0, 0, 0}});
	}
	_posColors.reserve(_posColors.size() + size);
	Vec4 color4 = color.toVec4();
	for (Uint32 i = 0; i < size; i++)
	{
		Vec2 vert = verts[i];
		_posColors.push_back({{vert.x, vert.y, 0, 1}, color4});
	}
	_flags.setOn(Line::VertexColorDirty);
	_flags.setOn(Line::VertexPosDirty);
}

void Line::set(const vector<Vec2>& verts, Color color)
{
	clear();
	add(verts, color);
}

void Line::set(const Vec2* verts, Uint32 size, Color color)
{
	clear();
	add(verts, size, color);
}

void Line::clear()
{
	_posColors.clear();
	_flags.setOn(Line::VertexColorDirty);
	_flags.setOn(Line::VertexPosDirty);
}

void Line::updateRealColor3()
{
	Node::updateRealColor3();
	_flags.setOn(Line::VertexColorDirty);
}

void Line::updateRealOpacity()
{
	Node::updateRealOpacity();
	_flags.setOn(Line::VertexColorDirty);
}

const Matrix& Line::getWorld()
{
	if (_flags.isOn(Node::WorldDirty))
	{
		_flags.setOn(Line::VertexPosDirty);
	}
	return Node::getWorld();
}

void Line::render()
{
	if (_posColors.empty()) return;

	if (_vertices.size() != _posColors.size())
	{
		_vertices.resize(_posColors.size());
	}

	if (_flags.isOn(Line::VertexColorDirty))
	{
		_flags.setOff(Line::VertexColorDirty);
		Vec4 ucolor = _realColor.toVec4();
		for (size_t i = 0; i < _posColors.size(); i++)
		{
			const Vec4& acolor = _posColors[i].color;
			float alpha = acolor.w * ucolor.w;
			Vec4 color {0, 0, 0, alpha};
			bx::vec3Mul(color, acolor, ucolor);
			_vertices[i].abgr = Color(color).toABGR();
		}
	}

	if (_flags.isOn(Line::VertexPosDirty))
	{
		_flags.setOff(Line::VertexPosDirty);
		Matrix transform;
		bx::mtxMul(transform, _world, SharedDirector.getViewProjection());
		for (size_t i = 0; i < _vertices.size(); i++)
		{
			bx::vec4MulMtx(&_vertices[i].x, &_posColors[i].pos.x, transform);
		}
	}

	_renderState = BGFX_STATE_WRITE_RGB | BGFX_STATE_WRITE_A |
		BGFX_STATE_PT_LINESTRIP | _blendFunc.toValue();
	if (_flags.isOn(Line::DepthWrite))
	{
		_renderState |= BGFX_STATE_DEPTH_TEST_LESS;
	}

	SharedRendererManager.setCurrent(SharedLineRenderer.getTarget());
	SharedLineRenderer.push(this);
}

/* LineRenderer */

LineRenderer::LineRenderer():
_defaultEffect(Effect::create("builtin::vs_poscolor"_slice, "builtin::fs_poscolor"_slice)),
_lastState(BGFX_STATE_NONE)
{ }

Effect* LineRenderer::getDefaultEffect() const
{
	return _defaultEffect;
}

void LineRenderer::push(Line* line)
{
	Uint64 state = line->getRenderState();
	if (state != _lastState)
	{
		render();
	}
	_lastState = state;
	const auto& verts = line->getVertices();
	_vertices.reserve(_vertices.size() + verts.size());
	if (!_vertices.empty())
	{
		_vertices.push_back(_vertices.back());
		_vertices.back().abgr = 0;
		_vertices.push_back(verts.front());
		_vertices.back().abgr = 0;
	}
	_vertices.insert(_vertices.end(), verts.begin(), verts.end());
}

void LineRenderer::render()
{
	if (!_vertices.empty())
	{
		bgfx::TransientVertexBuffer vertexBuffer;
		Uint32 vertexCount = s_cast<Uint32>(_vertices.size());
		if (bgfx::getAvailTransientVertexBuffer(vertexCount, PosColorVertex::ms_decl) >= vertexCount)
		{
			bgfx::allocTransientVertexBuffer(&vertexBuffer, vertexCount, PosColorVertex::ms_decl);
			Renderer::render();
			std::memcpy(vertexBuffer.data, _vertices.data(), _vertices.size() * sizeof(_vertices[0]));
			bgfx::setVertexBuffer(0, &vertexBuffer);
			bgfx::setState(_lastState);
			Uint8 viewId = SharedView.getId();
			bgfx::submit(viewId, _defaultEffect->apply());
		}
		else
		{
			Warn("not enough transient buffer for {} vertices.", vertexCount);
		}
		_vertices.clear();
		_lastState = BGFX_STATE_NONE;
	}
}

NS_DOROTHY_END
