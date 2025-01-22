/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Render/Camera.h"

#include "Basic/Application.h"
#include "Basic/Director.h"
#include "Node/Node.h"
#include "Render/View.h"

NS_DORA_BEGIN

/* Camera */

Camera::Camera(String name)
	: _name(name)
	, _view{}
	, _position{0, 0, 0}
	, _target{0, 0, 1}
	, _up{0, 1, 0} { }

const std::string& Camera::getName() const noexcept {
	return _name;
}

const Vec3& Camera::getPosition() {
	return _position;
}

const Vec3& Camera::getTarget() {
	return _target;
}

const Vec3& Camera::getUp() {
	return _up;
}

const Matrix& Camera::getView() {
	return _view;
}

bool Camera::hasProjection() const {
	return false;
}

/* CameraBasic */

CameraBasic::CameraBasic(String name)
	: Camera(name)
	, _transformDirty(true)
	, _rotation(0.0f) { }

void CameraBasic::setRotation(float var) {
	_rotation = var;
	_transformDirty = true;
}

float CameraBasic::getRotation() const noexcept {
	return _rotation;
}

void CameraBasic::setPosition(const Vec3& position) {
	_position = position;
	_transformDirty = true;
}

void CameraBasic::setTarget(const Vec3& target) {
	_target = target;
	_transformDirty = true;
}

const Vec3& CameraBasic::getUp() {
	updateView();
	return _up;
}

void CameraBasic::updateView() {
	if (_transformDirty) {
		_transformDirty = false;
		bx::Vec3 dest = bx::sub(_target, _position);
		float distance = bx::length(dest);
		if (distance == 0.0f) {
			bx::mtxIdentity(_view.m);
		} else {
			float rotateX = std::asin(dest.y / distance);
			float rotateY = 0.0f;
			if (dest.x != 0.0f) {
				rotateY = -std::atan(dest.z / dest.x);
			}
			Matrix transform;
			bx::mtxRotateZYX(transform.m, rotateX, rotateY, -bx::toRad(_rotation));
			bx::Vec3 up = bx::mul(bx::Vec3{0, 1.0f, 0}, transform.m);
			_up = Vec3::from(bx::normalize(up));
			bx::mtxLookAt(_view.m, _position, _target, _up);
		}
		Updated();
	}
}

const Matrix& CameraBasic::getView() {
	updateView();
	return Camera::getView();
}

/* Camera2D */

Camera2D::Camera2D(String name)
	: Camera(name)
	, _transformDirty(true)
	, _rotation(0.0f)
	, _zoom(1.0f) { }

void Camera2D::setPosition(const Vec2& position) {
	_position.x = _target.x = position.x;
	_position.y = _target.y = position.y;
	_transformDirty = true;
}

void Camera2D::setRotation(float var) {
	_rotation = var;
	_transformDirty = true;
}

float Camera2D::getRotation() const noexcept {
	return _rotation;
}

void Camera2D::setZoom(float var) {
	_zoom = var;
}

float Camera2D::getZoom() const noexcept {
	return _zoom;
}

const Vec3& Camera2D::getUp() {
	updateView();
	return _up;
}

const Matrix& Camera2D::getView() {
	updateView();
	return Camera::getView();
}

void Camera2D::updateView() {
	float z = -SharedView.getStandardDistance() / _zoom;
	if (_position.z != z) {
		_position.z = z;
		_transformDirty = true;
	}
	if (_transformDirty) {
		_transformDirty = false;
		Matrix rotateZ;
		bx::mtxRotateZ(rotateZ.m, -bx::toRad(_rotation));
		bx::Vec3 up = bx::mul(bx::Vec3{0, 1.0f, 0}, rotateZ.m);
		_up = Vec3::from(bx::normalize(up));
		bx::mtxLookAt(_view.m, _position, _target, _up);
		Updated();
	}
}

/* CameraOtho */

CameraOtho::CameraOtho(String name)
	: Camera(name)
	, _transformDirty(true) { }

void CameraOtho::setPosition(const Vec2& position) {
	_position.x = _target.x = position.x;
	_position.y = _target.y = position.y;
	_transformDirty = true;
}

const Matrix& CameraOtho::getView() {
	float z = SharedView.getStandardDistance();
	if (_position.z != z) {
		_position.z = z;
		_transformDirty = true;
	}
	if (_transformDirty) {
		_transformDirty = false;
		Size viewSize = SharedView.getSize();
		Matrix view;
		bx::mtxOrtho(view.m, 0, viewSize.width, 0, viewSize.height, -1000.0f, 1000.0f, 0, bgfx::getCaps()->homogeneousDepth);
		if (_position.toVec2() != Vec2::zero) {
			Matrix move;
			Matrix temp = view;
			bx::mtxTranslate(move.m, _position.x, _position.y, 0);
			Matrix::mulMtx(view, temp, move);
		}
		_view = view;
		Updated();
	}
	return Camera::getView();
}

bool CameraOtho::hasProjection() const {
	return true;
}

/* CameraUI */

CameraUI::CameraUI(String name)
	: Camera(name)
	, _viewSize{Size::zero} { }

const Matrix& CameraUI::getView() {
	auto size = SharedApplication.getBufferSize();
	if (_viewSize != size) {
		_viewSize = size;
		_position.x = size.width / 2;
		_position.y = size.height / 2;
		Matrix move;
		bx::mtxTranslate(move.m, _position.x, _position.y, 0);
		Matrix tmp;
		bx::mtxOrtho(tmp.m, 0, size.width, 0, size.height, -1000.0f, 1000.0f, 0,
			bgfx::getCaps()->homogeneousDepth);
		Matrix::mulMtx(_view, tmp, move);
		Updated();
	}
	return Camera::getView();
}

bool CameraUI::hasProjection() const {
	return true;
}

/* CameraUI3D */

CameraUI3D::CameraUI3D(String name)
	: Camera(name)
	, _viewSize{Size::zero} { }

const Matrix& CameraUI3D::getView() {
	auto size = SharedApplication.getBufferSize();
	if (_viewSize != size) {
		_viewSize = size;
		const float fieldOfView = 45.0f;
		const float aspectRatio = size.width / size.height;
		const float nearPlaneDistance = 0.1f;
		const float farPlaneDistance = 10000.0f;
		_position.z = -size.height * 0.5f / std::tan(bx::toRad(fieldOfView) * 0.5f);
		Matrix view;
		bx::mtxLookAt(view.m, _position, _target, _up);
		Matrix projection;
		bx::mtxProj(
			projection.m,
			fieldOfView,
			aspectRatio,
			nearPlaneDistance,
			farPlaneDistance,
			bgfx::getCaps()->homogeneousDepth);
		Matrix::mulMtx(_view, projection, view);
		Updated();
	}
	return Camera::getView();
}

bool CameraUI3D::hasProjection() const {
	return true;
}

NS_DORA_END
