/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Shader/Builtin.h"

#include "Shader/Draw/vs_draw.bin.h"
#include "Shader/Draw/fs_draw.bin.h"

#include "Shader/ImGui/vs_ocornut_imgui.bin.h"
#include "Shader/ImGui/fs_ocornut_imgui.bin.h"

#include "Shader/Simple/vs_poscolor.bin.h"
#include "Shader/Simple/fs_poscolor.bin.h"

#include "Shader/Sprite/vs_sprite.bin.h"
#include "Shader/Sprite/vs_spritemodel.bin.h"
#include "Shader/Sprite/fs_sprite.bin.h"
#include "Shader/Sprite/fs_spritewhite.bin.h"
#include "Shader/Sprite/fs_spritealphatest.bin.h"
#include "Shader/Sprite/fs_spritesaturation.bin.h"

NS_DOROTHY_BEGIN

static const bgfx::EmbeddedShader _DoraShaders[] =
{
	BGFX_EMBEDDED_SHADER(vs_draw),
	BGFX_EMBEDDED_SHADER(fs_draw),
	BGFX_EMBEDDED_SHADER(vs_ocornut_imgui),
	BGFX_EMBEDDED_SHADER(fs_ocornut_imgui),
	BGFX_EMBEDDED_SHADER(vs_poscolor),
	BGFX_EMBEDDED_SHADER(fs_poscolor),
	BGFX_EMBEDDED_SHADER(vs_sprite),
	BGFX_EMBEDDED_SHADER(vs_spritemodel),
	BGFX_EMBEDDED_SHADER(fs_sprite),
	BGFX_EMBEDDED_SHADER(fs_spritewhite),
	BGFX_EMBEDDED_SHADER(fs_spritealphatest),
	BGFX_EMBEDDED_SHADER(fs_spritesaturation),
	BGFX_EMBEDDED_SHADER_END()
};

const bgfx::EmbeddedShader* DoraShaders = _DoraShaders;

NS_DOROTHY_END
