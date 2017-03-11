/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Basic/Renderer.h"

NS_DOROTHY_BEGIN

void Renderer::render()
{
	Uint32 stencilState = SharedRendererManager.getCurrentStencilState();
	if (stencilState != BGFX_STENCIL_NONE)
	{
		bgfx::setStencil(stencilState);
	}
}

RendererManager::RendererManager():
_currentRenderer(nullptr)
{ }

void RendererManager::setCurrent(Renderer* var)
{
	if (_currentRenderer && _currentRenderer != var)
	{
		_currentRenderer->render();
	}
	_currentRenderer = var;
}

Renderer* RendererManager::getCurrent() const
{
	return _currentRenderer;
}

Uint32 RendererManager::getCurrentStencilState() const
{
	return _stencilStates.empty() ? BGFX_STENCIL_NONE : _stencilStates.top();
}

void RendererManager::flush()
{
	if (_currentRenderer)
	{
		_currentRenderer->render();
		_currentRenderer = nullptr;
	}
}

void RendererManager::pushStencilState(Uint32 stencilState)
{
	_stencilStates.push(stencilState);
}

void RendererManager::popStencilState()
{
	_stencilStates.pop();
}

NS_DOROTHY_END
