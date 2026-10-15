/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Basic/Object.h"
#include "Cache/TextureCache.h"
#include "Effect/Effect.h"

NS_DORA_BEGIN

enum class MaterialType {
	Unlit,
	Lambert
};

class Material : public Object {
public:
	PROPERTY(MaterialType, Type);
	PROPERTY_BOOL(Transparent);
	PROPERTY_BOOL(DoubleSided);
	PROPERTY_BOOL(DepthTest);
	PROPERTY_BOOL(DepthWrite);
	PROPERTY(Color, BaseColor);
	PROPERTY(float, Metallic);
	PROPERTY(float, Roughness);
	PROPERTY(float, AlphaCutoff);
	PROPERTY_READONLY_CREF(RefVector<Pass>, Passes);

	void add(Pass* pass);
	Pass* getPass(uint32_t index = 0) const;
	void clear();

	void setTexture(String slot, Texture2D* texture, uint8_t stage = 0);
	Texture2D* getTexture(String slot) const;
	void setFloat(String name, float value);
	void setVec4(String name, const Vec4& value);
	void setMatrix(String name, const Matrix& value);

	CREATE_FUNC_NOT_NULL(Material);

protected:
	Material();

private:
	MaterialType _type;
	bool _transparent;
	bool _doubleSided;
	bool _depthTest;
	bool _depthWrite;
	Color _baseColor;
	float _metallic;
	float _roughness;
	float _alphaCutoff;
	RefVector<Pass> _passes;
	StringMap<Ref<Texture2D>> _textures;
	DORA_TYPE_OVERRIDE(Material);
};

NS_DORA_END
