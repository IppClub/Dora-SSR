/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

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
		ktm::fvec3 dest = _target.ktm() - _position.ktm();
		float distance = ktm::length(dest);
		if (distance == 0.0f) {
			_view = Matrix::Indentity;
		} else {
			float rotateX = std::asin(dest.y / distance);
			float rotateY = 0.0f;
			if (dest.x != 0.0f) {
				rotateY = -std::atan(dest.z / dest.x);
			}
			ktm::fmat4x4 transform = ktm::rotate3d_x(-rotateX) * ktm::rotate3d_y(-rotateY) * ktm::rotate3d_z(ktm::radians(_rotation));
			ktm::fvec3 up = (transform * ktm::fvec4{0.0f, 1.0f, 0.0f, 1.0f}).xyz();
			_up = Vec3::from(ktm::normalize(up));
			Matrix::lookAt(_view, _position, _target, _up);
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

Vec2 Camera2D::getPosition2D() const {
	return _position.toVec2();
}

void Camera2D::setPosition2D(const Vec2& position) {
	setPosition(position);
}

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
		ktm::fmat4x4 rotateZ = ktm::rotate3d_z(ktm::radians(_rotation));
		ktm::fvec3 up = (rotateZ * ktm::fvec4{0.0f, 1.0f, 0.0f, 1.0f}).xyz();
		_up = Vec3::from(ktm::normalize(up));
		Matrix::lookAt(_view, _position, _target, _up);
		Updated();
	}
}

/* CameraOtho */

CameraOtho::CameraOtho(String name)
	: Camera(name)
	, _transformDirty(true) { }

Vec2 CameraOtho::getPosition2D() const {
	return _position.toVec2();
}

void CameraOtho::setPosition2D(const Vec2& position) {
	setPosition(position);
}

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
		Matrix::ortho(view, 0.0f, viewSize.width, 0.0f, viewSize.height, -1000.0f, 1000.0f, 0.0f, bgfx::getCaps()->homogeneousDepth);
		if (_position.toVec2() != Vec2::zero) {
			Matrix move;
			Matrix temp = view;
			move.ktm() = ktm::translate3d(ktm::fvec3{_position.x, _position.y, 0.0f});
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
		move.ktm() = ktm::translate3d(ktm::fvec3{_position.x, _position.y, 0.0f});
		Matrix tmp;
		Matrix::ortho(tmp, 0.0f, size.width, 0.0f, size.height, -1000.0f, 1000.0f, 0.0f,
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
		_position.z = -size.height * 0.5f / std::tan(ktm::radians(fieldOfView) * 0.5f);
		Matrix view;
		Matrix::lookAt(view, _position, _target, _up);
		Matrix projection;
		Matrix::perspective(
			projection,
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
