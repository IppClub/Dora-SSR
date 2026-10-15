/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Effect/Effect.h"

#include "Cache/ShaderCache.h"
#include "Cache/TextureCache.h"

NS_DORA_BEGIN

/* Effect */

Pass::Uniform::~Uniform() {
	if (bgfx::isValid(_handle)) {
		bgfx::destroy(_handle);
	}
}

Pass::Uniform::Uniform(bgfx::UniformHandle handle, Own<Value>&& value)
	: _handle(handle)
	, _value(std::move(value))
	, _slot(0)
	, _samplerFlags(UINT32_MAX) { }

bgfx::UniformHandle Pass::Uniform::getHandle() const noexcept {
	return _handle;
}

Value* Pass::Uniform::getValue() const noexcept {
	return _value.get();
}

void Pass::Uniform::setSlot(uint8_t var) {
	_slot = var;
}

uint8_t Pass::Uniform::getSlot() const noexcept {
	return _slot;
}

void Pass::Uniform::setSamplerFlags(uint32_t var) {
	_samplerFlags = var;
}

uint32_t Pass::Uniform::getSamplerFlags() const noexcept {
	return _samplerFlags;
}

void Pass::Uniform::setVec4Array(std::span<const Vec4> values) {
	_vec4Array.assign(values.begin(), values.end());
	_matrixArray.clear();
}

void Pass::Uniform::setMatrixArray(std::span<const Matrix> values) {
	_matrixArray.assign(values.begin(), values.end());
	_vec4Array.clear();
}

void Pass::Uniform::apply() {
	if (!_vec4Array.empty()) {
		bgfx::setUniform(_handle, _vec4Array.data(), static_cast<uint16_t>(_vec4Array.size()));
	} else if (!_matrixArray.empty()) {
		bgfx::setUniform(_handle, _matrixArray.data(), static_cast<uint16_t>(_matrixArray.size()));
	} else if (auto texture = _value->as<Texture2D>()) {
		bgfx::setTexture(_slot, _handle, texture->getHandle(), _samplerFlags);
	} else if (auto value = _value->asVal<float>()) {
		Vec4 v4{*value, 0, 0, 0};
		bgfx::setUniform(_handle, &v4.x);
	} else if (auto value = _value->asVal<Vec4>()) {
		bgfx::setUniform(_handle, &value->x);
	} else if (auto value = _value->asVal<Matrix>()) {
		bgfx::setUniform(_handle, value->m);
	}
}

bgfx::ProgramHandle Pass::apply() {
	for (const auto& pair : _uniforms) {
		pair.second->apply();
	}
	return _program;
}

Pass::Pass(Shader* vertShader, Shader* fragShader)
	: _program(BGFX_INVALID_HANDLE)
	, _vertShader(vertShader)
	, _fragShader(fragShader)
	, _grabPass(false) { }

Pass::Pass(String vertShader, String fragShader)
	: _program(BGFX_INVALID_HANDLE)
	, _vertShader(SharedShaderCache.load(vertShader, ShaderStage::Vertex))
	, _fragShader(SharedShaderCache.load(fragShader, ShaderStage::Fragment))
	, _grabPass(false) { }

Pass::~Pass() {
	if (bgfx::isValid(_program)) {
		bgfx::destroy(_program);
	}
}

bool Pass::init() {
	if (!Object::init()) return false;
	if (_vertShader && _fragShader) {
		_program = bgfx::createProgram(_vertShader->getHandle(), _fragShader->getHandle());
		return bgfx::isValid(_program);
	}
	return false;
}

void Pass::setGrabPass(bool var) {
	_grabPass = var;
}

bool Pass::isGrabPass() const noexcept {
	return _grabPass;
}

void Pass::set(String name, float var) {
	std::string uname(name);
	auto it = _uniforms.find(uname);
	if (it != _uniforms.end() && !it->second->getValue()->as<Texture2D>()) {
		it->second->getValue()->set(var);
	} else {
		bgfx::UniformHandle handle = bgfx::createUniform(uname.c_str(), bgfx::UniformType::Vec4);
		_uniforms[uname] = Uniform::create(handle, Value::alloc(var));
	}
}

void Pass::set(String name, float var1, float var2, float var3, float var4) {
	set(name, Vec4{var1, var2, var3, var4});
}

void Pass::set(String name, const Vec4& var) {
	std::string uname(name);
	auto it = _uniforms.find(uname);
	if (it != _uniforms.end() && !it->second->getValue()->as<Texture2D>()) {
		it->second->getValue()->set(var);
	} else {
		bgfx::UniformHandle handle = bgfx::createUniform(uname.c_str(), bgfx::UniformType::Vec4);
		_uniforms[uname] = Uniform::create(handle, Value::alloc(var));
	}
}

void Pass::set(String name, std::span<const Vec4> values) {
	AssertUnless(!values.empty() && values.size() <= std::numeric_limits<uint16_t>::max(),
		"uniform Vec4 array count is out of range");
	std::string uname(name);
	auto it = _uniforms.find(uname);
	if (it != _uniforms.end()) {
		it->second->setVec4Array(values);
	} else {
		bgfx::UniformHandle handle = bgfx::createUniform(uname.c_str(), bgfx::UniformType::Vec4,
			static_cast<uint16_t>(values.size()));
		auto uniform = Uniform::create(handle, Value::alloc(Vec4{}));
		uniform->setVec4Array(values);
		_uniforms[uname] = uniform;
	}
}

void Pass::set(String name, Color var) {
	set(name, var.toVec4());
}

void Pass::set(String name, const Matrix& var) {
	std::string uname(name.toString());
	auto it = _uniforms.find(uname);
	if (it != _uniforms.end() && !it->second->getValue()->as<Texture2D>()) {
		it->second->getValue()->set(var);
	} else {
		bgfx::UniformHandle handle = bgfx::createUniform(uname.c_str(), bgfx::UniformType::Mat4);
		_uniforms[uname] = Uniform::create(handle, Value::alloc(var));
	}
}

void Pass::set(String name, std::span<const Matrix> values) {
	AssertUnless(!values.empty() && values.size() <= std::numeric_limits<uint16_t>::max(),
		"uniform Matrix array count is out of range");
	std::string uname(name);
	auto it = _uniforms.find(uname);
	if (it != _uniforms.end()) {
		it->second->setMatrixArray(values);
	} else {
		bgfx::UniformHandle handle = bgfx::createUniform(uname.c_str(), bgfx::UniformType::Mat4,
			static_cast<uint16_t>(values.size()));
		auto uniform = Uniform::create(handle, Value::alloc(Matrix{}));
		uniform->setMatrixArray(values);
		_uniforms[uname] = uniform;
	}
}

void Pass::set(String name, Texture2D* texture, uint8_t slot) {
	set(name, texture, slot, UINT32_MAX);
}

void Pass::set(String name, Texture2D* texture, uint8_t slot, uint32_t flags) {
	std::string uname(name);
	auto it = _uniforms.find(uname);
	if (it != _uniforms.end() && it->second->getValue()->as<Texture2D>()) {
		it->second->getValue()->set(texture);
		it->second->setSlot(slot);
		it->second->setSamplerFlags(flags);
	} else {
		bgfx::UniformHandle handle = bgfx::createUniform(uname.c_str(), bgfx::UniformType::Sampler);
		auto uniform = Uniform::create(handle, Value::alloc(texture));
		uniform->setSlot(slot);
		uniform->setSamplerFlags(flags);
		_uniforms[uname] = uniform;
	}
}

void Pass::remove(String name) {
	_uniforms.erase(std::string(name));
}

Value* Pass::get(String name) const {
	auto it = _uniforms.find(name);
	if (it != _uniforms.end()) {
		return it->second->getValue();
	}
	return nullptr;
}

/* Effect */

Effect::Effect() { }

Effect::Effect(Shader* vertShader, Shader* fragShader) {
	if (auto pass = Pass::create(vertShader, fragShader)) {
		_passes.push_back(pass);
	}
}

Effect::Effect(String vertShader, String fragShader) {
	if (auto pass = Pass::create(vertShader, fragShader)) {
		_passes.push_back(pass);
	}
}

const RefVector<Pass>& Effect::getPasses() const noexcept {
	return _passes;
}

void Effect::add(NotNull<Pass, 1> pass) {
	_passes.push_back(pass);
}

Pass* Effect::get(size_t index) const {
	AssertUnless(index < _passes.size(), "effect pass index out of range");
	return _passes[index];
}

void Effect::clear() {
	_passes.clear();
}

/* SpriteEffect */

SpriteEffect::SpriteEffect()
	: _sampler(bgfx::createUniform("s_texColor", bgfx::UniformType::Sampler)) { }

SpriteEffect::SpriteEffect(Shader* vertShader, Shader* fragShader)
	: Effect(vertShader, fragShader)
	, _sampler(bgfx::createUniform("s_texColor", bgfx::UniformType::Sampler)) { }

SpriteEffect::SpriteEffect(String vertShader, String fragShader)
	: Effect(vertShader, fragShader)
	, _sampler(bgfx::createUniform("s_texColor", bgfx::UniformType::Sampler)) { }

SpriteEffect::~SpriteEffect() {
	if (bgfx::isValid(_sampler)) {
		bgfx::destroy(_sampler);
	}
}

bgfx::UniformHandle SpriteEffect::getSampler() const noexcept {
	return _sampler;
}

NS_DORA_END
