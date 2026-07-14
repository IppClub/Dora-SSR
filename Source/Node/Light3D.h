/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node3D.h"

NS_DORA_BEGIN

class DirectionalLight3D : public Node3D {
public:
	PROPERTY(Color3, Color);
	PROPERTY(float, Intensity);
	PROPERTY_BOOL(CastShadow);
	PROPERTY(float, ShadowBias);
	PROPERTY(float, ShadowNormalBias);
	PROPERTY(float, ShadowSoftness);
	virtual bool init() override;
	CREATE_FUNC_NOT_NULL(DirectionalLight3D);

protected:
	DirectionalLight3D() = default;
	virtual ~DirectionalLight3D() = default;
	DORA_TYPE_OVERRIDE(DirectionalLight3D);
};

class PointLight3D : public Node3D {
public:
	PROPERTY(Color3, Color);
	PROPERTY(float, Intensity);
	PROPERTY(float, Range);
	virtual bool init() override;
	CREATE_FUNC_NOT_NULL(PointLight3D);

protected:
	PointLight3D() = default;
	virtual ~PointLight3D() = default;
	DORA_TYPE_OVERRIDE(PointLight3D);
};

NS_DORA_END
