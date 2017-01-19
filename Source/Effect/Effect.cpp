/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Effect/Effect.h"

NS_DOROTHY_BEGIN

/* Effect */

Effect::Effect(Shader* fragShader, Shader* vertShader):
_fragShader(fragShader),
_vertShader(vertShader)
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

bgfx::UniformHandle Effect::getSampler() const
{
	return bgfx::UniformHandle{bgfx::invalidHandle};
}

bool Effect::init()
{
	_program = bgfx::createProgram(_vertShader->getHandle(), _fragShader->getHandle());
	return bgfx::isValid(_program);
}

/* SpriteEffect */

SpriteEffect::SpriteEffect():
Effect(SharedShaderCache.load("fs_sprite.bin"_slice), SharedShaderCache.load("vs_sprite.bin"_slice)),
_sampler(bgfx::createUniform("s_texColor", bgfx::UniformType::Int1))
{
	Effect::init();
}

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
