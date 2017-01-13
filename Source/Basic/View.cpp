/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Basic/View.h"

NS_DOROTHY_BEGIN

View::View():
_nearPlaneDistance(0.0f),
_farPlaneDistance(1000.0f),
_fieldOfView(45.0f),
_flag(BGFX_RESET_NONE | BGFX_RESET_VSYNC)
{ }

Size View::getSize() const
{
	return Size((float)SharedApplication.getWidth(), (float)SharedApplication.getHeight());
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
		bgfx::reset((uint32_t)SharedApplication.getWidth(), (uint32_t)SharedApplication.getHeight(), _flag);
	}
}

bool View::isVSync() const
{
	return (_flag & BGFX_RESET_VSYNC) != 0;
}

float View::getStandardDistance() const
{
	return SharedApplication.getHeight() * 0.5f / std::tan(_fieldOfView * 0.5f);
}

float View::getAspectRatio() const
{
	return (float)SharedApplication.getHeight() / (float)SharedApplication.getWidth();
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
	bx::mtxProj(_projection, _fieldOfView, getAspectRatio(), _nearPlaneDistance, _farPlaneDistance);
}

const float* View::getProjection() const
{
	return _projection;
}

void View::reset()
{
	bgfx::reset(
		(uint32_t)SharedApplication.getWidth(),
		(uint32_t)SharedApplication.getHeight(),
		_flag);
	updateProjection();
}

NS_DOROTHY_END
