/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Effect/Effect.h"

#include "Cache/ShaderCache.h"

NS_DORA_BEGIN

/* Effect */

Pass::Uniform::~Uniform() {
	if (bgfx::isValid(_handle)) {
		bgfx::destroy(_handle);
	}
}

Pass::Uniform::Uniform(bgfx::UniformHandle handle, Own<Value>&& value)
	: _handle(handle)
	, _value(std::move(value)) { }

bgfx::UniformHandle Pass::Uniform::getHandle() const noexcept {
	return _handle;
}

Value* Pass::Uniform::getValue() const noexcept {
	return _value.get();
}

void Pass::Uniform::apply() {
	if (auto value = _value->asVal<float>()) {
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
	, _vertShader(SharedShaderCache.load(vertShader))
	, _fragShader(SharedShaderCache.load(fragShader))
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
	if (it != _uniforms.end()) {
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
	if (it != _uniforms.end()) {
		it->second->getValue()->set(var);
	} else {
		bgfx::UniformHandle handle = bgfx::createUniform(uname.c_str(), bgfx::UniformType::Vec4);
		_uniforms[uname] = Uniform::create(handle, Value::alloc(var));
	}
}

void Pass::set(String name, Color var) {
	set(name, var.toVec4());
}

void Pass::set(String name, const Matrix& var) {
	auto it = _uniforms.find(name);
	if (it != _uniforms.end()) {
		it->second->getValue()->set(var);
	} else {
		std::string uname(name.toString());
		bgfx::UniformHandle handle = bgfx::createUniform(uname.c_str(), bgfx::UniformType::Mat4);
		_uniforms[uname] = Uniform::create(handle, Value::alloc(var));
	}
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
