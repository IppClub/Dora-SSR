/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Camera.h"

NS_DOROTHY_BEGIN
class Node;
NS_DOROTHY_END

NS_DOROTHY_PLATFORMER_BEGIN

typedef Acf::Delegate<void (float deltaX, float deltaY)> CameraHandler;

class PlatformCamera : public Camera
{
public:
	PlatformCamera();
	PROPERTY_CREF(Rect, Boundary);
	PROPERTY_CREF(Vec2, FollowRatio);
	PROPERTY(Node*, FollowTarget);
	PROPERTY(float, Rotation);
	PROPERTY(float, Zoom);
	void setPosition(const Vec2& position);
	virtual bool init() override;
	virtual const Vec3& getUp() override;
	virtual const Matrix& getView() override;
	CameraHandler moved;
	CREATE_FUNC(PlatformCamera);
protected:
	PlatformCamera(String name);
	void updateView();
private:
	Vec2 _camPos;
	Rect _boundary;
	Size _viewSize;
	Vec2 _ratio;
	WRef<Node> _followTarget;
	bool _transformDirty;
	float _rotation;
	float _zoom;
	DORA_TYPE_OVERRIDE(PlatformCamera);
};

NS_DOROTHY_PLATFORMER_END
