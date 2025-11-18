/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/DrawNode.h"
#include "Node/Node.h"

NS_DORA_BEGIN

class ClipNode : public Node {
public:
	PROPERTY(Node*, Stencil);
	PROPERTY(float, AlphaThreshold);
	PROPERTY_BOOL(Inverted);
	virtual ~ClipNode();
	virtual bool init() override;
	virtual void onEnter() override;
	virtual void onExit() override;
	virtual void visit() override;
	virtual void cleanup() override;
	CREATE_FUNC_NOT_NULL(ClipNode);

protected:
	ClipNode(Node* stencil = nullptr);
	void drawFullScreenStencil(uint8_t maskLayer, bool value);
	void drawStencil(uint8_t maskLayer, bool value);
	void setupAlphaTest();

private:
	float _alphaThreshold;
	Ref<Node> _stencil;
	static int _layer;
	enum : Flag::ValueType {
		Inverted = Node::UserFlag
	};
	DORA_TYPE_OVERRIDE(ClipNode);
};

NS_DORA_END
