/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node.h"

NS_DORA_BEGIN

class Camera3D;
class Camera;
class Node3D;

class View3D : public Node {
public:
	PROPERTY_READONLY_CALL(Node3D*, Scene);
	using Node::addChild;
	void addChild(Node3D* child, int order, String tag);
	void addChild(Node3D* child, int order);
	void addChild(Node3D* child);
	bool setEnvironmentMap(String path);
	void setEnvironmentIntensity(float diffuse, float specular, float exposure = 1.0f);
	virtual bool init() override;
	virtual void render() override;
	virtual void cleanup() override;
	CREATE_FUNC_NOT_NULL(View3D);

protected:
	View3D();
	~View3D();

private:
	void render3D(bgfx::ViewId viewId);
	std::string _environmentMap;
	float _environmentDiffuse;
	float _environmentSpecular;
	float _environmentExposure;
	Ref<Node3D> _scene;
	DORA_TYPE_OVERRIDE(View3D);
};

NS_DORA_END
