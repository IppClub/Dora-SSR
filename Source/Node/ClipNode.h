/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node.h"
#include "Common/Singleton.h"

NS_DOROTHY_BEGIN

struct SimpleVertex
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
			ms_decl.begin()
				.add(bgfx::Attrib::Position, 4, bgfx::AttribType::Float)
				.add(bgfx::Attrib::Color0, 4, bgfx::AttribType::Uint8, true)
			.end();
		}
	};
	static bgfx::VertexDecl ms_decl;
	static Init init;
};

class Effect;

class SimpleEffect
{
public:
	virtual ~SimpleEffect();
	Effect* get() const;
protected:
	SimpleEffect();
private:
	Ref<Effect> _effect;
	SINGLETON_REF(SimpleEffect, BGFXDora);
};

#define SharedSimpleEffect \
	Dorothy::Singleton<Dorothy::SimpleEffect>::shared()

class ClipNode : public Node
{
public:
	PROPERTY(Node*, Stencil);
	PROPERTY_BOOL(Inverted);
	virtual ~ClipNode();
	virtual bool init() override;
	virtual void onEnter() override;
	virtual void onExit() override;
	virtual void cleanup() override;
	virtual void visit() override;
	CREATE_FUNC(ClipNode);
protected:
	ClipNode(Node* stencil);
	void drawFullscreenQuad();
private:
	Ref<Node> _stencil;
	static int _layer;
	static stack<Uint32> _stencilStates;
	enum
	{
		Inverted = Node::UserFlag
	};
	DORA_TYPE_OVERRIDE(ClipNode);
};

NS_DOROTHY_END
