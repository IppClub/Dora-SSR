/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node.h"

NS_DORA_BEGIN

class Sprite;

class VGNode : public Node {
public:
	PROPERTY_READONLY(Sprite*, Surface);
	virtual bool init() override;
	virtual void cleanup() override;
	void render(const std::function<void()>& func);
	CREATE_FUNC_NOT_NULL(VGNode);

protected:
	VGNode(float width, float height, float scale = 1.0f, int edgeAA = 1);

private:
	float _frameWidth;
	float _frameHeight;
	float _frameScale;
	int _edgeAA;
	Ref<Sprite> _surface;
	DORA_TYPE_OVERRIDE(VGNode);
};

NS_DORA_END
