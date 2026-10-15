/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Lua/LuaManual.h"

NS_DORA_BEGIN

namespace {

uint32_t getBlendFuncValue(String name) {
	switch (Switch::hash(name)) {
		case "One"_hash: return BlendFunc::One;
		case "Zero"_hash: return BlendFunc::Zero;
		case "SrcColor"_hash: return BlendFunc::SrcColor;
		case "SrcAlpha"_hash: return BlendFunc::SrcAlpha;
		case "DstColor"_hash: return BlendFunc::DstColor;
		case "DstAlpha"_hash: return BlendFunc::DstAlpha;
		case "InvSrcColor"_hash: return BlendFunc::InvSrcColor;
		case "InvSrcAlpha"_hash: return BlendFunc::InvSrcAlpha;
		case "InvDstColor"_hash: return BlendFunc::InvDstColor;
		case "InvDstAlpha"_hash: return BlendFunc::InvDstAlpha;
		default:
			Issue("blend function name \"{}\" is invalid", name.toString());
			return BlendFunc::Zero;
	}
}

} // namespace

BlendFunc* BlendFunc_create(String src, String dst) {
	return Mtolua_new((BlendFunc)({getBlendFuncValue(src), getBlendFuncValue(dst)}));
}

BlendFunc* BlendFunc_create(String srcColor, String dstColor, String srcAlpha, String dstAlpha) {
	return Mtolua_new((BlendFunc)({getBlendFuncValue(srcColor), getBlendFuncValue(dstColor),
		getBlendFuncValue(srcAlpha), getBlendFuncValue(dstAlpha)}));
}

int BodyDef_GetType(lua_State* L) {
	auto self = r_cast<BodyDef*>(tolua_tousertype(L, 1, nullptr));
	if (!self) return luaL_error(L, "invalid self in BodyDef.type");
	switch (self->getType()) {
		case pr::BodyType::Static: tolua_pushslice(L, "Static"_slice); break;
		case pr::BodyType::Dynamic: tolua_pushslice(L, "Dynamic"_slice); break;
		case pr::BodyType::Kinematic: tolua_pushslice(L, "Kinematic"_slice); break;
	}
	return 1;
}

int BodyDef_SetType(lua_State* L) {
	auto self = r_cast<BodyDef*>(tolua_tousertype(L, 1, nullptr));
	if (!self) return luaL_error(L, "invalid self in BodyDef.type");
	size_t size = 0;
	const char* value = luaL_checklstring(L, 2, &size);
	switch (Switch::hash(Slice{value, size})) {
		case "Static"_hash: self->setType(pr::BodyType::Static); break;
		case "Dynamic"_hash: self->setType(pr::BodyType::Dynamic); break;
		case "Kinematic"_hash: self->setType(pr::BodyType::Kinematic); break;
		default: return luaL_error(L, "BodyDef.type must be Static, Dynamic or Kinematic");
	}
	return 0;
}

NS_DORA_END
