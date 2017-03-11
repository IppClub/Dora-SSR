/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Basic/View.h"
#include "Basic/Application.h"
#include "Basic/Director.h"
#include "Node/Node.h"

NS_DOROTHY_BEGIN

View::View():
_id(-1),
_nearPlaneDistance(0.1f),
_farPlaneDistance(10000.0f),
_fieldOfView(45.0f),
_flag(BGFX_RESET_NONE | BGFX_RESET_VSYNC)
{ }

Uint8 View::getId() const
{
	AssertIf(_ids.empty(), "invalid view id.")
	return _ids.top();
}

void View::clear()
{
	_id = -1;
	if (!empty())
	{
		stack<Uint8> dummy;
		_ids.swap(dummy);
	}
}

void View::push(String viewName)
{
	AssertIf(_id == 255, "running views exceeded 256.");
	Uint8 viewId = s_cast<Uint8>(++_id);
	bgfx::resetView(viewId);
	if (!viewName.empty())
	{
		bgfx::setViewName(viewId, viewName.toString().c_str());
	}
	bgfx::setViewRect(viewId, 0, 0, bgfx::BackbufferRatio::Equal);
	bgfx::setViewSeq(viewId, true);
	bgfx::touch(viewId);
	_ids.push(viewId);
}

void View::pop()
{
	AssertIf(_ids.empty(), "already pop to the last view, no more views to pop.");
	_ids.pop();
}

bool View::empty()
{
	return _ids.empty();
}

Size View::getSize() const
{
	return Size{s_cast<float>(SharedApplication.getWidth()), s_cast<float>(SharedApplication.getHeight())};
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
		bgfx::reset(s_cast<Uint32>(SharedApplication.getWidth()), s_cast<Uint32>(SharedApplication.getHeight()), _flag);
	}
}

bool View::isVSync() const
{
	return (_flag & BGFX_RESET_VSYNC) != 0;
}

float View::getStandardDistance() const
{
	return SharedApplication.getHeight() * 0.5f / std::tan(bx::toRad(_fieldOfView) * 0.5f);
}

float View::getAspectRatio() const
{
	return s_cast<float>(SharedApplication.getWidth()) / s_cast<float>(SharedApplication.getHeight());
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
	Node* entry = SharedDirector.getCurrentEntry();
	if (entry)
	{
		entry->markDirty();
	}
}

const float* View::getProjection() const
{
	return _projection;
}

void View::reset()
{
	bgfx::reset(
		s_cast<uint32_t>(SharedApplication.getWidth()),
		s_cast<uint32_t>(SharedApplication.getHeight()),
		_flag);
	updateProjection();
}

NS_DOROTHY_END
