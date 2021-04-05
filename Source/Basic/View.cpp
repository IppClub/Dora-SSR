/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Basic/View.h"
#include "Basic/Application.h"
#include "Basic/Director.h"
#include "Node/Node.h"
#include "Effect/Effect.h"

NS_DOROTHY_BEGIN

View::View():
_id(-1),
_nearPlaneDistance(0.1f),
_farPlaneDistance(10000.0f),
_fieldOfView(45.0f),
_flag(BGFX_RESET_HIDPI),
_size(SharedApplication.getBufferSize()),
_scale(1.0f),
_projection(Matrix::Indentity)
{
#if !BX_PLATFORM_WINDOWS
	_flag |= BGFX_RESET_VSYNC;
#endif // BX_PLATFORM
}

bgfx::ViewId View::getId() const
{
	AssertIf(_views.empty(), "invalid view id.");
	return _views.top().first;
}

const std::string& View::getName() const
{
	AssertIf(_views.empty(), "invalid view id.");
	return _views.top().second;
}

void View::clear()
{
	_id = -1;
	if (!empty())
	{
		decltype(_views) dummy;
		_views.swap(dummy);
	}
}

void View::push(String viewName)
{
	AssertIf(_id > 255, "running views exceeded 256.");
	bgfx::ViewId viewId = s_cast<bgfx::ViewId>(++_id);
	bgfx::resetView(viewId);
	std::string name = viewName.toString();
	if (!name.empty())
	{
		bgfx::setViewName(viewId, name.c_str());
	}
	bgfx::setViewRect(viewId, 0, 0, bgfx::BackbufferRatio::Equal);
	bgfx::setViewMode(viewId, bgfx::ViewMode::Sequential);
	bgfx::touch(viewId);
	_views.push(std::make_pair(viewId, name));
}

void View::pop()
{
	AssertIf(_views.empty(), "already pop to the last view, no more views to pop.");
	_views.pop();
}

bool View::empty()
{
	return _views.empty();
}

Size View::getSize() const
{
	return _size;
}

void View::setScale(float var)
{
	_scale = var;
	Size bufferSize = SharedApplication.getBufferSize();
	_size = {bufferSize.width / _scale, bufferSize.height / _scale};
	View::updateProjection();
	Event::send("AppSizeChanged"_slice);
}

float View::getScale() const
{
	return _scale;
}

void View::setVSync(bool var)
{
	if (var != isVSync())
	{
		if (var)
		{
			_flag |= BGFX_RESET_VSYNC;
		}
		else
		{
			_flag &= ~BGFX_RESET_VSYNC;
		}
		Size bufferSize = SharedApplication.getBufferSize();
		bgfx::reset(s_cast<Uint32>(bufferSize.width), s_cast<Uint32>(bufferSize.height), _flag);
	}
}

bool View::isVSync() const
{
	return (_flag & BGFX_RESET_VSYNC) != 0;
}

bool View::isPostProcessNeeded() const
{
	return _scale != 1.0f || _effect != nullptr;
}

float View::getStandardDistance() const
{
	return _size.height * 0.5f / std::tan(bx::toRad(_fieldOfView) * 0.5f);
}

float View::getAspectRatio() const
{
	return _size.width / _size.height;
}

void View::setNearPlaneDistance(float var)
{
	_nearPlaneDistance = var;
	updateProjection();
}

float View::getNearPlaneDistance() const
{
	return _nearPlaneDistance;
}

void View::setFarPlaneDistance(float var)
{
	_farPlaneDistance = var;
	updateProjection();
}

float View::getFarPlaneDistance() const
{
	return _farPlaneDistance;
}

void View::setFieldOfView(float var)
{
	_fieldOfView = var;
	updateProjection();
}

float View::getFieldOfView() const
{
	return _fieldOfView;
}

void View::updateProjection()
{
	bx::mtxProj(_projection, _fieldOfView, getAspectRatio(), _nearPlaneDistance, _farPlaneDistance, bgfx::getCaps()->homogeneousDepth);
	SharedDirector.markDirty();
}

const Matrix& View::getProjection() const
{
	return _projection;
}

void View::setPostEffect(SpriteEffect* var)
{
	_effect = var;
}

SpriteEffect* View::getPostEffect() const
{
	return _effect;
}

void View::reset()
{
	Size bufferSize = SharedApplication.getBufferSize();
	_size = {bufferSize.width / _scale, bufferSize.height / _scale};
	bgfx::reset(
		s_cast<uint32_t>(bufferSize.width),
		s_cast<uint32_t>(bufferSize.height),
		_flag);
	updateProjection();
}

NS_DOROTHY_END
