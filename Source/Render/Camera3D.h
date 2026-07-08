/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Render/Camera.h"

NS_DORA_BEGIN

class Camera3D : public Camera {
public:
	PROPERTY(float, FieldOfView);
	PROPERTY(float, NearClip);
	PROPERTY(float, FarClip);
	PROPERTY(float, AspectRatio);
	PROPERTY_BOOL(AutoAspect);
	PROPERTY_BOOL(Orthographic);
	PROPERTY(float, OrthoHeight);

	void setPosition(float x, float y, float z);
	void setPosition(const Vec3& position);
	void setTarget(float x, float y, float z);
	void setTarget(const Vec3& target);
	void setUp(float x, float y, float z);
	void setUp(const Vec3& up);
	void lookAt(float px, float py, float pz, float tx, float ty, float tz, float ux = 0.0f, float uy = 1.0f, float uz = 0.0f);
	void lookAt(const Vec3& position, const Vec3& target, const Vec3& up = Vec3{0.0f, 1.0f, 0.0f});

	virtual const Vec3& getPosition() override;
	virtual const Vec3& getTarget() override;
	virtual const Vec3& getUp() override;
	virtual const Matrix& getView() override;
	virtual bool hasProjection() const override;

	const Matrix& getViewMatrix();
	const Matrix& getProjectionMatrix();
	CREATE_FUNC_NOT_NULL(Camera3D);

protected:
	Camera3D(String name);
	void updateMatrices();

private:
	float _fieldOfView;
	float _nearClip;
	float _farClip;
	float _aspectRatio;
	float _orthoHeight;
	bool _autoAspect;
	bool _orthographic;
	bool _transformDirty;
	bool _projectionDirty;
	Matrix _viewMatrix;
	Matrix _projectionMatrix;
	DORA_TYPE_OVERRIDE(Camera3D);
};

NS_DORA_END
