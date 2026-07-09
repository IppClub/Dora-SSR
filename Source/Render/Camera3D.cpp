/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Render/Camera3D.h"

#include "Render/View.h"

NS_DORA_BEGIN

Camera3D::Camera3D(String name)
	: Camera(name)
	, _transformDirty(true)
	, _viewMatrix(Matrix::Indentity) {
	_position = {0.0f, 0.0f, 10.0f};
	_target = {0.0f, 0.0f, 0.0f};
	_up = {0.0f, 1.0f, 0.0f};
}

void Camera3D::setPosition(float x, float y, float z) {
	setPosition({x, y, z});
}

void Camera3D::setPosition(const Vec3& position) {
	_position = position;
	_transformDirty = true;
}

void Camera3D::setTarget(float x, float y, float z) {
	setTarget({x, y, z});
}

void Camera3D::setTarget(const Vec3& target) {
	_target = target;
	_transformDirty = true;
}

void Camera3D::setUp(float x, float y, float z) {
	setUp({x, y, z});
}

void Camera3D::setUp(const Vec3& up) {
	_up = Vec3::from(bx::normalize(up));
	_transformDirty = true;
}

void Camera3D::lookAt(float px, float py, float pz, float tx, float ty, float tz, float ux, float uy, float uz) {
	lookAt({px, py, pz}, {tx, ty, tz}, {ux, uy, uz});
}

void Camera3D::lookAt(const Vec3& position, const Vec3& target, const Vec3& up) {
	_position = position;
	_target = target;
	_up = Vec3::from(bx::normalize(up));
	_transformDirty = true;
}

const Vec3& Camera3D::getPosition() {
	return _position;
}

const Vec3& Camera3D::getTarget() {
	return _target;
}

const Vec3& Camera3D::getUp() {
	return _up;
}

void Camera3D::updateMatrices() {
	if (_transformDirty) {
		_transformDirty = false;
		bx::mtxLookAt(_viewMatrix.m, _position, _target, _up);
	}
	Matrix::mulMtx(_view, SharedView.getProjection(), _viewMatrix);
	Updated();
}

const Matrix& Camera3D::getView() {
	updateMatrices();
	return Camera::getView();
}

bool Camera3D::hasProjection() const {
	return true;
}

const Matrix& Camera3D::getViewMatrix() {
	updateMatrices();
	return _viewMatrix;
}

NS_DORA_END
