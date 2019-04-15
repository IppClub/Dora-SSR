/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Effect/Effect.h"
#include "Cache/ShaderCache.h"

NS_DOROTHY_BEGIN

/* Effect */

Effect::Uniform::~Uniform()
{
	if (bgfx::isValid(_handle))
	{
		bgfx::destroy(_handle);
	}
}

Effect::Uniform::Uniform(bgfx::UniformHandle handle, Value* value):
_handle(handle),
_value(value)
{ }

bgfx::UniformHandle Effect::Uniform::getHandle() const
{
	return _handle;
}

Value* Effect::Uniform::getValue() const
{
	return _value;
}

void Effect::Uniform::apply()
{
	if (_value->as<float>())
	{
		float value = _value->as<float>()->get();
		bgfx::setUniform(_handle, Vec4{value});
	}
	else if (_value->as<Vec4>())
	{
		const Vec4& value = _value->as<Vec4>()->get();
		bgfx::setUniform(_handle, value);
	}
	else if (_value->as<Matrix>())
	{
		const Matrix& value = _value->as<Matrix>()->get();
		bgfx::setUniform(_handle, value);
	}
}

bgfx::ProgramHandle Effect::apply()
{
	for (const auto& pair : _uniforms)
	{
		pair.second->apply();
	}
	return _program;
}

Effect::Effect(Shader* vertShader, Shader* fragShader):
_program(BGFX_INVALID_HANDLE),
_vertShader(vertShader),
_fragShader(fragShader)
{ }

Effect::Effect(String vertShader, String fragShader):
_program(BGFX_INVALID_HANDLE),
_vertShader(SharedShaderCache.load(vertShader)),
_fragShader(SharedShaderCache.load(fragShader))
{ }

Effect::~Effect()
{
	if (bgfx::isValid(_program))
	{
		bgfx::destroy(_program);
	}
}

bool Effect::init()
{
	if (!Object::init()) return false;
	_program = bgfx::createProgram(_vertShader->getHandle(), _fragShader->getHandle());
	return bgfx::isValid(_program);
}

void Effect::set(String name, float var)
{
	string uname(name);
	auto it = _uniforms.find(uname);
	if (it != _uniforms.end())
	{
		it->second->getValue()->as<float>()->set(var);
	}
	else
	{
		bgfx::UniformHandle handle = bgfx::createUniform(uname.c_str(), bgfx::UniformType::Vec4);
		_uniforms[uname] = Uniform::create(handle, Value::create(var));
	}
}

void Effect::set(String name, float var1, float var2, float var3, float var4)
{
	set(name, Vec4{var1, var2, var3, var4});
}

void Effect::set(String name, const Vec4& var)
{
	string uname(name);
	auto it = _uniforms.find(uname);
	if (it != _uniforms.end())
	{
		it->second->getValue()->as<Vec4>()->set(var);
	}
	else
	{
		bgfx::UniformHandle handle = bgfx::createUniform(uname.c_str(), bgfx::UniformType::Vec4);
		_uniforms[uname] = Uniform::create(handle, Value::create(var));
	}
}

void Effect::set(String name, const Matrix& var)
{
	string uname(name);
	auto it = _uniforms.find(uname);
	if (it != _uniforms.end())
	{
		it->second->getValue()->as<Matrix>()->set(var);
	}
	else
	{
		bgfx::UniformHandle handle = bgfx::createUniform(uname.c_str(), bgfx::UniformType::Mat4);
		_uniforms[uname] = Uniform::create(handle, Value::create(var));
	}
}

Value* Effect::get(String name) const
{
	auto it = _uniforms.find(name);
	if (it != _uniforms.end())
	{
		return it->second->getValue();
	}
	return nullptr;
}

/* SpriteEffect */

SpriteEffect::SpriteEffect(Shader* vertShader, Shader* fragShader):
Effect(vertShader, fragShader),
_sampler(bgfx::createUniform("s_texColor", bgfx::UniformType::Sampler))
{ }

SpriteEffect::SpriteEffect(String vertShader, String fragShader):
Effect(vertShader, fragShader),
_sampler(bgfx::createUniform("s_texColor", bgfx::UniformType::Sampler))
{ }

SpriteEffect::~SpriteEffect()
{
	if (bgfx::isValid(_sampler))
	{
		bgfx::destroy(_sampler);
	}
}

bgfx::UniformHandle SpriteEffect::getSampler() const
{
	return _sampler;
}

NS_DOROTHY_END
