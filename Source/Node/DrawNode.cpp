/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Node/DrawNode.h"
#include "Basic/Application.h"
#include "Cache/ShaderCache.h"
#include "Effect/Effect.h"

NS_DOROTHY_BEGIN

/* DrawEffect */

bgfx::VertexDecl PosColorVertex::ms_decl;
PosColorVertex::Init PosColorVertex::init;

bgfx::VertexDecl PosVertex::ms_decl;
PosVertex::Init PosVertex::init;

DrawEffect::DrawEffect():
_posColor(Effect::create(
	SharedShaderCache.load("vs_poscolor.bin"_slice),
	SharedShaderCache.load("fs_poscolor.bin"_slice))),
_posUColor(Effect::create(
	SharedShaderCache.load("vs_posucolor.bin"_slice),
	SharedShaderCache.load("fs_poscolor.bin"_slice)))
{ }

Effect* DrawEffect::getPosColor() const
{
	return _posColor;
}

Effect* DrawEffect::getPosUColor() const
{
	return _posUColor;
}

NS_DOROTHY_END
