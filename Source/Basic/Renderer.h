/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Support/Geometry.h"

NS_DOROTHY_BEGIN

class Node;

class Renderer
{
public:
	virtual void render();
};

class RendererManager
{
public:
	PROPERTY(Renderer*, Current);
	PROPERTY_READONLY(Uint32, CurrentStencilState);
	PROPERTY_READONLY_BOOL(Grouping);
	void flush();

	template <typename Func>
	void pushStencilState(Uint32 stencilState, const Func& workHere)
	{
		pushStencilState(stencilState);
		workHere();
		popStencilState();
	}

	void pushGroupItem(Node* item);

	template <typename Func>
	void pushGroup(Uint32 capacity, const Func& workHere)
	{
		pushGroup(capacity);
		workHere();
		popGroup();
	}
protected:
	RendererManager();
	void pushStencilState(Uint32 stencilState);
	void popStencilState();
	void pushGroup(Uint32 capacity);
	void popGroup();
private:
	stack<Uint32> _stencilStates;
	Renderer* _currentRenderer;
	stack<Own<vector<Node*>>> _renderGroups;
	SINGLETON_REF(RendererManager, BGFXDora);
};

#define SharedRendererManager \
	Dorothy::Singleton<Dorothy::RendererManager>::shared()

NS_DOROTHY_END
