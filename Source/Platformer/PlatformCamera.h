/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Render/Camera.h"

NS_DORA_BEGIN
class Node;
NS_DORA_END

NS_DORA_PLATFORMER_BEGIN

typedef Acf::Delegate<void(float deltaX, float deltaY)> CameraMoveHandler;
typedef Acf::Delegate<void()> CameraResetHandler;

class PlatformCamera : public Camera {
public:
	PlatformCamera();
	PROPERTY_CREF(Rect, Boundary);
	PROPERTY_CREF(Vec2, FollowRatio);
	PROPERTY_CREF(Vec2, FollowOffset);
	PROPERTY(Node*, FollowTarget);
	PROPERTY(float, Rotation);
	PROPERTY(float, Zoom);
	void setPosition(const Vec2& position);
	virtual bool init() override;
	virtual const Vec3& getUp() override;
	virtual const Matrix& getView() override;
	CameraMoveHandler moved;
	CameraResetHandler reset;
	CREATE_FUNC_NOT_NULL(PlatformCamera);

protected:
	PlatformCamera(String name);
	void updateView();

private:
	Vec2 _camPos;
	Rect _boundary;
	Size _viewSize;
	Vec2 _ratio;
	Vec2 _offset;
	WRef<Node> _followTarget;
	bool _transformDirty;
	float _rotation;
	float _zoom;
	DORA_TYPE_OVERRIDE(PlatformCamera);
};

NS_DORA_PLATFORMER_END
