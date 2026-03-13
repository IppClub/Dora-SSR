/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Support/Common.h"
#include "Support/Geometry.h"
#include "Support/Value.h"
#include "Render/RenderTarget.h"

NS_DORA_BEGIN

class Shader;
class Texture2D;

class ComputePass : public Object {
public:
	virtual ~ComputePass();
	virtual bool init() override;
	
	void set(String name, float var);
	void set(String name, float x, float y, float z, float w);
	void set(String name, const Vec4& var);
	void set(String name, const Matrix& var);
	void set(String name, Color var);
	
	Value* get(String name) const;
	
	// setImage with format auto-detection (format = Count means auto-detect from texture)
	void setImage(uint8_t stage, Texture2D* texture, ComputeAccess access, bgfx::TextureFormat::Enum format = bgfx::TextureFormat::Count);
	
	// dispatch compute shader (viewId is automatically obtained from SharedView)
	// Must be called within a valid render context (e.g., in Render slot callback)
	void dispatch(uint32_t numX, uint32_t numY, uint32_t numZ = 1);
	
	static bool isSupported();
	CREATE_FUNC_NULLABLE(ComputePass);

protected:
	ComputePass(Shader* computeShader);
	ComputePass(String computeShader);

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
	
	Ref<Shader> _computeShader;
	bgfx::ProgramHandle _program;
	StringMap<Ref<Uniform>> _uniforms;
	// Store bound textures to prevent dangling pointers
	std::vector<Ref<Texture2D>> _boundTextures;
	DORA_TYPE_OVERRIDE(ComputePass);
};

NS_DORA_END
