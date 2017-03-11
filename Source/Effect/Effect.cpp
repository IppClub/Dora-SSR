/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

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
		bgfx::destroyUniform(_handle);
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

Effect::Effect(Shader* vertShader, Shader* fragShader):
_vertShader(vertShader),
_fragShader(fragShader)
{ }

Effect::~Effect()
{
	if (bgfx::isValid(_program))
	{
		bgfx::destroyProgram(_program);
	}
}

bgfx::ProgramHandle Effect::getProgram() const
{
	return _program;
}

bool Effect::init()
{
	_program = bgfx::createProgram(_vertShader->getHandle(), _fragShader->getHandle());
	return bgfx::isValid(_program);
}

void Effect::set(String name, float var)
{
	string uname(name);
	Vec4 var4 {var};
	auto it = _uniforms.find(uname);
	if (it != _uniforms.end())
	{
		bgfx::setUniform(it->second->getHandle(), var4);
		it->second->getValue()->as<float>()->set(var);
	}
	else
	{
		bgfx::UniformHandle handle = bgfx::createUniform(uname.c_str(), bgfx::UniformType::Vec4);
		bgfx::setUniform(handle, var4);
		_uniforms[uname] = Uniform::create(handle, Value::create(var));
	}
}

void Effect::set(String name, const Vec4& var)
{
	string uname(name);
	auto it = _uniforms.find(uname);
	if (it != _uniforms.end())
	{
		bgfx::setUniform(it->second->getHandle(), var);
		it->second->getValue()->as<Vec4>()->set(var);
	}
	else
	{
		bgfx::UniformHandle handle = bgfx::createUniform(uname.c_str(), bgfx::UniformType::Vec4);
		bgfx::setUniform(handle, var);
		_uniforms[uname] = Uniform::create(handle, Value::create(var));
	}
}

void Effect::set(String name, const Matrix& var)
{
	string uname(name);
	auto it = _uniforms.find(uname);
	if (it != _uniforms.end())
	{
		bgfx::setUniform(it->second->getHandle(), &var);
		it->second->getValue()->as<Matrix>()->set(var);
	}
	else
	{
		bgfx::UniformHandle handle = bgfx::createUniform(uname.c_str(), bgfx::UniformType::Mat4);
		bgfx::setUniform(handle, &var);
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
_sampler(bgfx::createUniform("s_texColor", bgfx::UniformType::Int1))
{ }

SpriteEffect::~SpriteEffect()
{
	if (bgfx::isValid(_sampler))
	{
		bgfx::destroyUniform(_sampler);
	}
}

bgfx::UniformHandle SpriteEffect::getSampler() const
{
	return _sampler;
}

NS_DOROTHY_END
