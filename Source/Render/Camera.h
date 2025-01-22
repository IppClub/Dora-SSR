/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Support/Geometry.h"

NS_DORA_BEGIN

class Camera : public Object {
public:
	PROPERTY_READONLY_CREF(std::string, Name);
	virtual const Vec3& getPosition();
	virtual const Vec3& getTarget();
	virtual const Vec3& getUp();
	virtual const Matrix& getView();
	virtual bool hasProjection() const;
	Acf::Delegate<void()> Updated;

protected:
	Camera(String name);

protected:
	std::string _name;
	Vec3 _position;
	Vec3 _target;
	Vec3 _up;
	Matrix _view;
	DORA_TYPE_OVERRIDE(Camera);
};

class CameraBasic : public Camera {
public:
	PROPERTY(float, Rotation);
	void setPosition(const Vec3& position);
	void setTarget(const Vec3& position);
	virtual const Vec3& getUp() override;
	virtual const Matrix& getView() override;
	CREATE_FUNC_NOT_NULL(CameraBasic);

protected:
	CameraBasic(String name);
	void updateView();

private:
	bool _transformDirty;
	float _rotation;
	DORA_TYPE_OVERRIDE(CameraBasic);
};

class Camera2D : public Camera {
public:
	PROPERTY(float, Rotation);
	PROPERTY(float, Zoom);
	void setPosition(const Vec2& position);
	virtual const Vec3& getUp() override;
	virtual const Matrix& getView() override;
	CREATE_FUNC_NOT_NULL(Camera2D);

protected:
	Camera2D(String name);
	void updateView();

private:
	bool _transformDirty;
	float _rotation;
	float _zoom;
	DORA_TYPE_OVERRIDE(Camera2D);
};

class CameraOtho : public Camera {
public:
	void setPosition(const Vec2& position);
	virtual const Matrix& getView() override;
	virtual bool hasProjection() const override;
	CREATE_FUNC_NOT_NULL(CameraOtho);

protected:
	CameraOtho(String name);

private:
	float _zoom;
	bool _transformDirty;
	DORA_TYPE_OVERRIDE(CameraOtho);
};

class CameraUI : public Camera {
public:
	virtual const Matrix& getView() override;
	virtual bool hasProjection() const override;
	CREATE_FUNC_NOT_NULL(CameraUI);

protected:
	CameraUI(String name);
	void updateView();

private:
	Size _viewSize;
};

class CameraUI3D : public Camera {
public:
	virtual const Matrix& getView() override;
	virtual bool hasProjection() const override;
	CREATE_FUNC_NOT_NULL(CameraUI3D);

protected:
	CameraUI3D(String name);
	void updateView();

private:
	Size _viewSize;
};

NS_DORA_END
