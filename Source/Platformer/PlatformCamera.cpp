/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Platformer/Define.h"

#include "Platformer/PlatformCamera.h"

#include "Node/Node.h"
#include "Render/View.h"

NS_DORA_PLATFORMER_BEGIN

PlatformCamera::PlatformCamera(String name)
	: Camera(name)
	, _transformDirty(true)
	, _camPos{Vec2::zero}
	, _rotation(0.0f)
	, _zoom(1.0f)
	, _ratio{1.0f, 1.0f}
	, _offset{Vec2::zero}
	, _viewSize() { }

void PlatformCamera::setPosition(const Vec2& position) {
	_camPos = position;
	Vec2 newPos = position;
	Vec2 pos = _position;
	if (_boundary != Rect::zero) {
		Size viewSize = Size{_viewSize.width / _zoom, _viewSize.height / _zoom};
		float xOffset = viewSize.width / 2.0f;
		float yOffset = viewSize.height / 2.0f;
		newPos = {
			Math::clamp(position.x, _boundary.getLeft() + xOffset, _boundary.getRight() - xOffset),
			Math::clamp(position.y, _boundary.getBottom() + yOffset, _boundary.getTop() - yOffset)};
		pos = {
			Math::clamp(pos.x, _boundary.getLeft() + xOffset, _boundary.getRight() - xOffset),
			Math::clamp(pos.y, _boundary.getBottom() + yOffset, _boundary.getTop() - yOffset)};
	}
	_position.x = _target.x = newPos.x;
	_position.y = _target.y = newPos.y;
	_transformDirty = true;
	moved(newPos.x - pos.x, newPos.y - pos.y);
}

void PlatformCamera::setRotation(float var) {
	_rotation = var;
	_transformDirty = true;
}

float PlatformCamera::getRotation() const noexcept {
	return _rotation;
}

void PlatformCamera::setZoom(float var) {
	auto pos = _camPos;
	setPosition(Vec2::zero);
	_viewSize = SharedView.getSize();
	reset();
	_zoom = var;
	setPosition(pos);
}

float PlatformCamera::getZoom() const noexcept {
	return _zoom;
}

const Vec3& PlatformCamera::getUp() {
	updateView();
	return _up;
}

const Matrix& PlatformCamera::getView() {
	updateView();
	return Camera::getView();
}

void PlatformCamera::updateView() {
	if (SharedView.getSize() != _viewSize) {
		auto pos = _camPos;
		setPosition(Vec2::zero);
		_viewSize = SharedView.getSize();
		reset();
		setPosition(pos);
		_transformDirty = true;
	}
	if (_followTarget) {
		Vec2 targetPos = _followTarget->convertToWorldSpace(Vec2::zero) + _offset;
		Vec2 pos = Vec2{_position.x, _position.y};
		Vec2 delta = targetPos - pos;
		setPosition(pos + delta * _ratio);
		_transformDirty = true;
	}
	float z = -SharedView.getStandardDistance() / _zoom;
	if (_position.z != z) {
		_position.z = z;
		_transformDirty = true;
	}
	if (_transformDirty) {
		_transformDirty = false;
		Matrix rotateZ;
		bx::mtxRotateZ(rotateZ.m, -bx::toRad(_rotation));
		_up = Vec3::from(bx::mul(bx::Vec3{0, 1.0f, 0}, rotateZ.m));
		_up = Vec3::from(bx::normalize(_up));
		bx::mtxLookAt(_view.m, _position, _target, _up);
		Updated();
	}
}

bool PlatformCamera::init() {
	if (!Camera::init()) return false;
	return true;
}

void PlatformCamera::setBoundary(const Rect& var) {
	_boundary = var;
	PlatformCamera::setPosition(_position);
}

const Rect& PlatformCamera::getBoundary() const noexcept {
	return _boundary;
}

void PlatformCamera::setFollowRatio(const Vec2& var) {
	_ratio = var;
}

const Vec2& PlatformCamera::getFollowRatio() const noexcept {
	return _ratio;
}

void PlatformCamera::setFollowOffset(const Vec2& var) {
	_offset = var;
}

const Vec2& PlatformCamera::getFollowOffset() const noexcept {
	return _offset;
}

void PlatformCamera::setFollowTarget(Node* target) {
	_followTarget = target;
}

Node* PlatformCamera::getFollowTarget() const noexcept {
	return _followTarget;
}

NS_DORA_PLATFORMER_END
