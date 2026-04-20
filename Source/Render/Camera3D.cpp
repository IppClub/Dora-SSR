/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Render/Camera3D.h"

#include "Basic/Application.h"

NS_DORA_BEGIN

Camera3D::Camera3D(String name)
	: Camera(name)
	, _fieldOfView(45.0f)
	, _nearClip(0.1f)
	, _farClip(10000.0f)
	, _aspectRatio(16.0f / 9.0f)
	, _orthoHeight(10.0f)
	, _autoAspect(true)
	, _orthographic(false)
	, _transformDirty(true)
	, _projectionDirty(true)
	, _viewMatrix(Matrix::Indentity)
	, _projectionMatrix(Matrix::Indentity) {
	_position = {0.0f, 0.0f, 10.0f};
	_target = {0.0f, 0.0f, 0.0f};
	_up = {0.0f, 1.0f, 0.0f};
}

void Camera3D::setPosition(const Vec3& position) {
	_position = position;
	_transformDirty = true;
}

void Camera3D::setTarget(const Vec3& target) {
	_target = target;
	_transformDirty = true;
}

void Camera3D::setUp(const Vec3& up) {
	_up = Vec3::from(bx::normalize(up));
	_transformDirty = true;
}

void Camera3D::lookAt(const Vec3& position, const Vec3& target, const Vec3& up) {
	_position = position;
	_target = target;
	_up = Vec3::from(bx::normalize(up));
	_transformDirty = true;
}

void Camera3D::setFieldOfView(float var) {
	_fieldOfView = var;
	_projectionDirty = true;
}

float Camera3D::getFieldOfView() const noexcept {
	return _fieldOfView;
}

void Camera3D::setNearClip(float var) {
	_nearClip = var;
	_projectionDirty = true;
}

float Camera3D::getNearClip() const noexcept {
	return _nearClip;
}

void Camera3D::setFarClip(float var) {
	_farClip = var;
	_projectionDirty = true;
}

float Camera3D::getFarClip() const noexcept {
	return _farClip;
}

void Camera3D::setAspectRatio(float var) {
	_aspectRatio = var;
	_projectionDirty = true;
}

float Camera3D::getAspectRatio() const noexcept {
	return _aspectRatio;
}

void Camera3D::setAutoAspect(bool var) {
	_autoAspect = var;
	_projectionDirty = true;
}

bool Camera3D::isAutoAspect() const noexcept {
	return _autoAspect;
}

void Camera3D::setOrthographic(bool var) {
	_orthographic = var;
	_projectionDirty = true;
}

bool Camera3D::isOrthographic() const noexcept {
	return _orthographic;
}

void Camera3D::setOrthoHeight(float var) {
	_orthoHeight = var;
	_projectionDirty = true;
}

float Camera3D::getOrthoHeight() const noexcept {
	return _orthoHeight;
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
	if (_autoAspect) {
		Size bufferSize = SharedApplication.getBufferSize();
		float aspectRatio = bufferSize.height > 0.0f ? bufferSize.width / bufferSize.height : 1.0f;
		if (std::abs(_aspectRatio - aspectRatio) > FLT_EPSILON) {
			_aspectRatio = aspectRatio;
			_projectionDirty = true;
		}
	}
	if (_transformDirty) {
		_transformDirty = false;
		bx::mtxLookAt(_viewMatrix.m, _position, _target, _up);
	}
	if (_projectionDirty) {
		_projectionDirty = false;
		if (_orthographic) {
			float halfHeight = _orthoHeight * 0.5f;
			float halfWidth = halfHeight * _aspectRatio;
			bx::mtxOrtho(_projectionMatrix.m,
				-halfWidth, halfWidth,
				-halfHeight, halfHeight,
				_nearClip, _farClip, 0,
				bgfx::getCaps()->homogeneousDepth);
		} else {
			bx::mtxProj(_projectionMatrix.m,
				_fieldOfView,
				_aspectRatio,
				_nearClip,
				_farClip,
				bgfx::getCaps()->homogeneousDepth);
		}
	}
	Matrix::mulMtx(_view, _projectionMatrix, _viewMatrix);
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

const Matrix& Camera3D::getProjectionMatrix() {
	updateMatrices();
	return _projectionMatrix;
}

NS_DORA_END
