/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Effect/ComputePass.h"

#include "Cache/ShaderCache.h"
#include "Cache/TextureCache.h"
#include "Render/View.h"

NS_DORA_BEGIN

/* ComputePass::Uniform */

ComputePass::Uniform::~Uniform() {
	if (bgfx::isValid(_handle)) {
		bgfx::destroy(_handle);
	}
}

ComputePass::Uniform::Uniform(bgfx::UniformHandle handle, Own<Value>&& value)
	: _handle(handle)
	, _value(std::move(value)) { }

bgfx::UniformHandle ComputePass::Uniform::getHandle() const noexcept {
	return _handle;
}

Value* ComputePass::Uniform::getValue() const noexcept {
	return _value.get();
}

void ComputePass::Uniform::apply() {
	if (auto value = _value->asVal<float>()) {
		Vec4 v4{*value, 0, 0, 0};
		bgfx::setUniform(_handle, &v4.x);
	} else if (auto value = _value->asVal<Vec4>()) {
		bgfx::setUniform(_handle, &value->x);
	} else if (auto value = _value->asVal<Matrix>()) {
		bgfx::setUniform(_handle, value->m);
	}
}

/* ComputePass */

ComputePass::ComputePass(Shader* computeShader)
	: _program(BGFX_INVALID_HANDLE)
	, _computeShader(computeShader) { }

ComputePass::ComputePass(String computeShader)
	: _program(BGFX_INVALID_HANDLE)
	, _computeShader(SharedShaderCache.load(computeShader, ShaderStage::Compute)) { }

ComputePass::~ComputePass() {
	if (bgfx::isValid(_program)) {
		bgfx::destroy(_program);
	}
}

bool ComputePass::init() {
	if (!Object::init()) return false;
	
	// Check compute capability
	if (!isSupported()) {
		Error("compute shader is not supported on this platform.");
		return false;
	}
	
	if (_computeShader) {
		_program = bgfx::createComputeProgram(_computeShader->getHandle());
		return bgfx::isValid(_program);
	}
	return false;
}

bool ComputePass::isSupported() {
	return (bgfx::getCaps()->supported & BGFX_CAPS_COMPUTE) != 0;
}

void ComputePass::set(String name, float var) {
	std::string uname(name);
	auto it = _uniforms.find(uname);
	if (it != _uniforms.end()) {
		it->second->getValue()->set(var);
	} else {
		bgfx::UniformHandle handle = bgfx::createUniform(uname.c_str(), bgfx::UniformType::Vec4);
		_uniforms[uname] = Uniform::create(handle, Value::alloc(var));
	}
}

void ComputePass::set(String name, float x, float y, float z, float w) {
	set(name, Vec4{x, y, z, w});
}

void ComputePass::set(String name, const Vec4& var) {
	std::string uname(name);
	auto it = _uniforms.find(uname);
	if (it != _uniforms.end()) {
		it->second->getValue()->set(var);
	} else {
		bgfx::UniformHandle handle = bgfx::createUniform(uname.c_str(), bgfx::UniformType::Vec4);
		_uniforms[uname] = Uniform::create(handle, Value::alloc(var));
	}
}

void ComputePass::set(String name, const Matrix& var) {
	auto it = _uniforms.find(name);
	if (it != _uniforms.end()) {
		it->second->getValue()->set(var);
	} else {
		std::string uname(name.toString());
		bgfx::UniformHandle handle = bgfx::createUniform(uname.c_str(), bgfx::UniformType::Mat4);
		_uniforms[uname] = Uniform::create(handle, Value::alloc(var));
	}
}

void ComputePass::set(String name, Color var) {
	// Convert Color (ARGB) to Vec4 (RGBA normalized 0-1)
	float a = ((var >> 24) & 0xFF) / 255.0f;
	float r = ((var >> 16) & 0xFF) / 255.0f;
	float g = ((var >> 8) & 0xFF) / 255.0f;
	float b = (var & 0xFF) / 255.0f;
	set(name, Vec4{r, g, b, a});
}

Value* ComputePass::get(String name) const {
	auto it = _uniforms.find(name);
	if (it != _uniforms.end()) {
		return it->second->getValue();
	}
	return nullptr;
}

void ComputePass::setImage(uint8_t stage, Texture2D* texture, ComputeAccess access, bgfx::TextureFormat::Enum format) {
	if (!texture) {
		Error("ComputePass::setImage failed: texture is null.");
		return;
	}
	
	// Store texture reference to prevent dangling pointer
	// Ensure we don't store duplicates for the same stage
	if (stage >= _boundTextures.size()) {
		_boundTextures.resize(stage + 1);
	}
	_boundTextures[stage] = texture;
	
	uint8_t bgfxAccess = BGFX_ACCESS_READ;
	switch (access) {
		case ComputeAccess::Read:
			bgfxAccess = BGFX_ACCESS_READ;
			break;
		case ComputeAccess::Write:
			bgfxAccess = BGFX_ACCESS_WRITE;
			break;
		case ComputeAccess::ReadWrite:
			bgfxAccess = BGFX_ACCESS_READWRITE;
			break;
		default:
			Error("ComputePass::setImage failed: invalid access type.");
			return;
	}
	
	// Auto-detect format if not specified
	bgfx::TextureFormat::Enum actualFormat = format;
	if (format == bgfx::TextureFormat::Count) {
		// Get format from texture info
		actualFormat = texture->getInfo().format;
	}
	
	bgfx::setImage(stage, texture->getHandle(), 0, bgfxAccess, actualFormat);
}

void ComputePass::dispatch(uint32_t numX, uint32_t numY, uint32_t numZ) {
	// Check if we're in a valid render context
	if (!SharedView.hasView()) {
		Error("ComputePass::dispatch must be called within a valid render context (e.g., in Render slot callback).");
		return;
	}
	
	// Get viewId from SharedView
	bgfx::ViewId viewId = SharedView.getId();
	
	// Apply uniforms
	for (const auto& pair : _uniforms) {
		pair.second->apply();
	}
	
	// Dispatch compute shader
	bgfx::dispatch(viewId, _program, numX, numY, numZ);
}

NS_DORA_END
