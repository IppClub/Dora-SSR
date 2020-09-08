/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node.h"
#include "Common/Singleton.h"
#include "Basic/Renderer.h"

NS_DOROTHY_BEGIN

struct DrawVertex
{
	float x;
	float y;
	float z;
	float w;
	uint32_t abgr;
	float u;
	float v;
	struct Init
	{
		Init()
		{
			ms_layout.begin()
				.add(bgfx::Attrib::Position, 4, bgfx::AttribType::Float)
				.add(bgfx::Attrib::Color0, 4, bgfx::AttribType::Uint8, true)
				.add(bgfx::Attrib::TexCoord0, 2, bgfx::AttribType::Float)
			.end();
		}
	};
	static bgfx::VertexLayout ms_layout;
	static Init init;
};

class Effect;

struct VertexColor
{
	VertexColor() { }
	VertexColor(const Vec2& vertex, Color color):
	vertex(vertex),
	color(color) { }
	Vec2 vertex;
	Color color;
};

class DrawNode : public Node
{
public:
	PROPERTY_CREF(BlendFunc, BlendFunc);
	PROPERTY_BOOL(DepthWrite);
	PROPERTY_READONLY(Uint64, RenderState);
	PROPERTY_READONLY_CREF(vector<DrawVertex>, Vertices);
	PROPERTY_READONLY_CREF(vector<Uint16>, Indices);
	virtual void render() override;
	virtual const Matrix& getWorld() override;
	void drawDot(const Vec2& pos, float radius, Color color);
	void drawSegment(const Vec2& from, const Vec2& to, float radius, Color color);
	void drawPolygon(const vector<Vec2>& verts, Color fillColor, float borderWidth, Color borderColor);
	void drawPolygon(const Vec2* verts, Uint32 count, Color fillColor, float borderWidth = 0.0f, Color borderColor = Color());
	void drawVertices(const VertexColor* verts, Uint32 count);
	void clear();
	CREATE_FUNC(DrawNode);
protected:
	DrawNode();
	virtual void updateRealColor3() override;
	virtual void updateRealOpacity() override;
	void pushVertex(const Vec2& pos, const Vec4& color, const Vec2& coord);
private:
	struct PosColor
	{
		Vec4 pos;
		Vec4 color;
	};
	Uint64 _renderState;
	BlendFunc _blendFunc;
	vector<DrawVertex> _vertices;
	vector<PosColor> _posColors;
	vector<Uint16> _indices;
	enum
	{
		VertexColorDirty = Node::UserFlag,
		VertexPosDirty = Node::UserFlag << 1,
		DepthWrite = Node::UserFlag << 2,
	};
	DORA_TYPE_OVERRIDE(DrawNode);
};

class DrawRenderer : public Renderer
{
public:
	PROPERTY_READONLY(Effect*, DefaultEffect);
	virtual ~DrawRenderer() { }
	virtual void render() override;
	void push(DrawNode* node);
protected:
	DrawRenderer();
private:
	Ref<Effect> _defaultEffect;
	Uint64 _lastState;
	vector<DrawVertex> _vertices;
	vector<Uint16> _indices;
	SINGLETON_REF(DrawRenderer, RendererManager);
};

#define SharedDrawRenderer \
	Dorothy::Singleton<Dorothy::DrawRenderer>::shared()

struct PosColorVertex
{
	float x;
	float y;
	float z;
	float w;
	uint32_t abgr;
	struct Init
	{
		Init()
		{
			ms_layout.begin()
				.add(bgfx::Attrib::Position, 4, bgfx::AttribType::Float)
				.add(bgfx::Attrib::Color0, 4, bgfx::AttribType::Uint8, true)
			.end();
		}
	};
	static bgfx::VertexLayout ms_layout;
	static Init init;
};

class Line : public Node
{
public:
	PROPERTY(BlendFunc, BlendFunc);
	PROPERTY_BOOL(DepthWrite);
	PROPERTY_READONLY(Uint64, RenderState);
	PROPERTY_READONLY_CREF(vector<PosColorVertex>, Vertices);
	virtual void render() override;
	virtual const Matrix& getWorld() override;
	void add(const vector<Vec2>& verts, Color color);
	void add(const Vec2* verts, Uint32 size, Color color);
	void set(const vector<Vec2>& verts, Color color);
	void set(const Vec2* verts, Uint32 size, Color color);
	void clear();
	CREATE_FUNC(Line);
protected:
	Line();
	Line(const vector<Vec2>& verts, Color color);
	Line(const Vec2* verts, Uint32 size, Color color);
	virtual void updateRealColor3() override;
	virtual void updateRealOpacity() override;
private:
	struct PosColor
	{
		Vec4 pos;
		Vec4 color;
	};
	Uint64 _renderState;
	BlendFunc _blendFunc;
	vector<PosColor> _posColors;
	vector<PosColorVertex> _vertices;
	enum
	{
		VertexColorDirty = Node::UserFlag,
		VertexPosDirty = Node::UserFlag << 1,
		DepthWrite = Node::UserFlag << 2,
	};
	DORA_TYPE_OVERRIDE(Line);
};

class LineRenderer: public Renderer
{
public:
	PROPERTY_READONLY(Effect*, DefaultEffect);
	virtual ~LineRenderer() { }
	virtual void render() override;
	void push(Line* line);
protected:
	LineRenderer();
private:
	Ref<Effect> _defaultEffect;
	Uint64 _lastState;
	vector<PosColorVertex> _vertices;
	SINGLETON_REF(LineRenderer, RendererManager);
};

#define SharedLineRenderer \
	Dorothy::Singleton<Dorothy::LineRenderer>::shared()

NS_DOROTHY_END
