/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Render/Renderer.h"

#include "Node/Node.h"

NS_DORA_BEGIN

void Renderer::render() {
	uint32_t stencilState = SharedRendererManager.getCurrentStencilState();
	if (stencilState != BGFX_STENCIL_NONE) {
		bgfx::setStencil(stencilState);
	}
}

RendererManager::RendererManager()
	: _currentRenderer(nullptr) { }

void RendererManager::setCurrent(Renderer* var) {
	if (_currentRenderer && _currentRenderer != var) {
		_currentRenderer->render();
	}
	_currentRenderer = var;
}

Renderer* RendererManager::getCurrent() const noexcept {
	return _currentRenderer;
}

uint32_t RendererManager::getCurrentStencilState() const noexcept {
	return _stencilStates.empty() ? BGFX_STENCIL_NONE : _stencilStates.top();
}

void RendererManager::flush() {
	if (_currentRenderer) {
		_currentRenderer->render();
		_currentRenderer = nullptr;
	}
}

void RendererManager::pushStencilState(uint32_t stencilState) {
	_stencilStates.push(stencilState);
}

void RendererManager::popStencilState() {
	_stencilStates.pop();
}

bool RendererManager::isGrouping() const noexcept {
	return !_renderGroups.empty();
}

void RendererManager::pushGroupItem(Node* item) {
	std::vector<Node*>* renderGroup = _renderGroups.top().get();
	renderGroup->push_back(item);
}

void RendererManager::pushGroup(uint32_t capacity) {
	_renderGroups.push(New<std::vector<Node*>>());
	_renderGroups.top()->reserve(s_cast<size_t>(capacity));
}

void RendererManager::popGroup() {
	std::vector<Node*>* renderGroup = _renderGroups.top().get();
	std::stable_sort(renderGroup->begin(), renderGroup->end(), [](Node* nodeA, Node* nodeB) {
		return nodeA->getRenderOrder() < nodeB->getRenderOrder();
	});
	for (Node* node : *renderGroup) {
		node->render();
	}
	_renderGroups.pop();
}

NS_DORA_END
