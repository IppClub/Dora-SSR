/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Basic/Camera.h"
#include "Basic/View.h"
#include "Basic/Director.h"
#include "Node/Node.h"

NS_DOROTHY_BEGIN

/* Camera */

Camera::Camera(String name):
_name(name),
_view{},
_position{0, 0, 0},
_target{0, 0, 1},
_up{0, 1, 0}
{ }

const string& Camera::getName() const
{
	return _name;
}

const Vec3& Camera::getPosition()
{
	return _position;
}

const Vec3& Camera::getTarget()
{
	return _target;
}

const Vec3& Camera::getUp()
{
	return _up;
}

const float* Camera::getView()
{
	return _view;
}

/* BasicCamera */

BasicCamera::BasicCamera(String name):
Camera(name),
_transformDirty(true),
_rotation(0.0f)
{ }

void BasicCamera::setRotation(float var)
{
	_rotation = var;
	_transformDirty = true;
}

float BasicCamera::getRotation() const
{
	return _rotation;
}

void BasicCamera::setPosition(const Vec3& position)
{
	_position = position;
	_transformDirty = true;
}

void BasicCamera::setTarget(const Vec3& target)
{
	_target = target;
	_transformDirty = true;
}

const Vec3& BasicCamera::getUp()
{
	updateView();
	return _up;
}

void BasicCamera::updateView()
{
	if (_transformDirty)
	{
		_transformDirty = false;
		Vec3 dest {};
		bx::vec3Sub(dest, _target, _position);
		float distance = bx::vec3Length(dest);
		if (distance == 0.0f)
		{
			bx::mtxIdentity(_view);
		}
		else
		{
			float rotateX = std::asin(dest.y / distance);
			float rotateY = 0.0f;
			if (dest.x != 0.0f)
			{
				rotateY = -std::atan(dest.z / dest.x);
			}
			Matrix transform;
			bx::mtxRotateZYX(transform, rotateX, rotateY, -bx::toRad(_rotation));
			bx::vec3MulMtx(_up, Vec3{0, 1.0f, 0}, transform);
			bx::vec3Norm(_up, _up);
			bx::mtxLookAt(_view, _position, _target, _up);
		}
		Node* entry = SharedDirector.getCurrentEntry();
		if (entry) entry->markDirty();
	}
}

const float* BasicCamera::getView()
{
	updateView();
	return Camera::getView();
}

/* Camera2D */

Camera2D::Camera2D(String name):
Camera(name),
_transformDirty(true),
_rotation(0.0f),
_zoom(1.0f)
{ }

void Camera2D::setPosition(const Vec2& position)
{
	_position.x = _target.x = position.x;
	_position.y = _target.y = position.y;
	_transformDirty = true;
}

void Camera2D::setRotation(float var)
{
	_rotation = var;
	_transformDirty = true;
}

float Camera2D::getRotation() const
{
	return _rotation;
}

void Camera2D::setZoom(float var)
{
	_zoom = var;
}

float Camera2D::getZoom() const
{
	return _zoom;
}

const Vec3& Camera2D::getUp()
{
	updateView();
	return _up;
}

const float* Camera2D::getView()
{
	updateView();
	return Camera::getView();
}

void Camera2D::updateView()
{
	float z = -SharedView.getStandardDistance() / _zoom;
	if (_position.z != z)
	{
		_position.z = z;
		_transformDirty = true;
	}
	if (_transformDirty)
	{
		_transformDirty = false;
		Matrix rotateZ;
		bx::mtxRotateZ(rotateZ, -bx::toRad(_rotation));
		bx::vec3MulMtx(_up, Vec3{0, 1.0f, 0}, rotateZ);
		bx::vec3Norm(_up, _up);
		bx::mtxLookAt(_view, _position, _target, _up);
		Node* entry = SharedDirector.getCurrentEntry();
		if (entry) entry->markDirty();
	}
}

NS_DOROTHY_END
