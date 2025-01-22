/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Support/Common.h"
#include "Support/Geometry.h"
#include "Support/Value.h"

NS_DORA_BEGIN

class Shader;

class Pass : public Object {
public:
	PROPERTY_BOOL(GrabPass);
	virtual ~Pass();
	virtual bool init() override;
	void set(String name, float var);
	void set(String name, float var1, float var2, float var3, float var4);
	void set(String name, const Vec4& var);
	void set(String name, Color var);
	void set(String name, const Matrix& var);
	Value* get(String name) const;
	bgfx::ProgramHandle apply();
	CREATE_FUNC_NULLABLE(Pass);

protected:
	Pass(Shader* vertShader, Shader* fragShader);
	Pass(String vertShader, String fragShader);

private:
	class Uniform : public Object {
	public:
		PROPERTY_READONLY(bgfx::UniformHandle, Handle);
		PROPERTY_READONLY(Value*, Value);
		virtual ~Uniform();
		void apply();
		CREATE_FUNC_NOT_NULL(Uniform);

	protected:
		Uniform(bgfx::UniformHandle handle, Own<Value>&& value);

	private:
		bgfx::UniformHandle _handle;
		Own<Value> _value;
	};
	bool _grabPass;
	Ref<Shader> _fragShader;
	Ref<Shader> _vertShader;
	bgfx::ProgramHandle _program;
	StringMap<Ref<Uniform>> _uniforms;
	DORA_TYPE_OVERRIDE(Pass);
};

class Effect : public Object {
public:
	PROPERTY_CREF(RefVector<Pass>, Passes);
	void add(NotNull<Pass, 1> pass);
	Pass* get(size_t index) const;
	void clear();
	CREATE_FUNC_NOT_NULL(Effect);

protected:
	Effect();
	Effect(Shader* vertShader, Shader* fragShader);
	Effect(String vertShader, String fragShader);

private:
	RefVector<Pass> _passes;
	DORA_TYPE_OVERRIDE(Effect);
};

class SpriteEffect : public Effect {
public:
	virtual ~SpriteEffect();
	PROPERTY_READONLY(bgfx::UniformHandle, Sampler);
	CREATE_FUNC_NOT_NULL(SpriteEffect);

protected:
	SpriteEffect();
	SpriteEffect(Shader* vertShader, Shader* fragShader);
	SpriteEffect(String vertShader, String fragShader);

private:
	bgfx::UniformHandle _sampler;
	DORA_TYPE_OVERRIDE(SpriteEffect);
};

NS_DORA_END
