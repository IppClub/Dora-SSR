/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

class Camera : public Object
{
public:
	PROPERTY_READONLY_REF(string, Name);
	virtual const Vec3& getPosition();
	virtual const Vec3& getTarget();
	virtual const Vec3& getUp();
	virtual void getView(float* view);
protected:
	Camera(String name);
protected:
	string _name;
	Vec3 _position;
	Vec3 _target;
	Vec3 _up;
	float _view[16];
};

class BasicCamera : public Camera
{
public:
	PROPERTY(float, Rotation);
	void setPosition(const Vec3& position);
	void setTarget(const Vec3& position);
	virtual const Vec3& getUp();
	virtual void getView(float* view);
	CREATE_FUNC(BasicCamera);
protected:
	BasicCamera(String name);
	void updateView();
private:
	bool _transformDirty;
	float _rotation;
};

NS_DOROTHY_END
