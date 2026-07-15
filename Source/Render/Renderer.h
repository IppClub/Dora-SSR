/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Support/Geometry.h"

NS_DORA_BEGIN

class Node;

class Renderer : public NonCopyable {
public:
	virtual void render();
};

class RendererManager : public NonCopyable {
public:
	PROPERTY(Renderer*, Current);
	PROPERTY_READONLY(uint32_t, CurrentStencilState);
	PROPERTY_READONLY_BOOL(Grouping);
	void flush();
	/**
	 * Applies the render-state requirements of the current scoped renderer.
	 * Surface3D uses this while submitting a 2D subtree into a 3D view so
	 * regular 2D batches can depth-test against the 3D scene.
	 */
	uint64_t applyState(uint64_t state) const noexcept;

	template <typename Func>
	void pushState(uint64_t state, const Func& workHere) {
		pushState(state);
		workHere();
		popState();
	}

	template <typename Func>
	void pushStencilState(uint32_t stencilState, const Func& workHere) {
		pushStencilState(stencilState);
		workHere();
		popStencilState();
	}

	void pushGroupItem(Node* item);

	template <typename Func>
	void pushGroup(uint32_t capacity, const Func& workHere) {
		pushGroup(capacity);
		workHere();
		popGroup();
	}

protected:
	RendererManager();
	void pushStencilState(uint32_t stencilState);
	void popStencilState();
	void pushGroup(uint32_t capacity);
	void popGroup();
	void pushState(uint64_t state);
	void popState();

private:
	std::stack<uint32_t> _stencilStates;
	Renderer* _currentRenderer;
	std::stack<Own<std::vector<Node*>>> _renderGroups;
	std::stack<uint64_t> _stateOverrides;
	SINGLETON_REF(RendererManager, BGFXDora);
};

#define SharedRendererManager \
	Dora::Singleton<Dora::RendererManager>::shared()

NS_DORA_END
