/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node3D.h"

NS_DORA_BEGIN

class Material;

class Visual3D : public Node3D {
public:
	PROPERTY_BOOL(FrustumCulling);
	PROPERTY_CREF(AABB, LocalBounds);
	PROPERTY_READONLY_CREF(AABB, WorldBounds);
	PROPERTY(Material*, Material);
	PROPERTY(void*, MeshHandle);
	PROPERTY(uint64_t, RustVisual);

	CREATE_FUNC_NOT_NULL(Visual3D);

protected:
	Visual3D();

private:
	bool _frustumCulling;
	AABB _localBounds;
	mutable AABB _worldBounds;
	Ref<Material> _material;
	void* _meshHandle;
	uint64_t _rustVisual;
	DORA_TYPE_OVERRIDE(Visual3D);
};

NS_DORA_END
