/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Dorothy.h"
#include "Lua/ToLua/tolua++.h"
#include "LuaManual.h"
#include "Lua/LuaEngine.h"

NS_DOROTHY_BEGIN

/* Event */

int dora_emit(lua_State* L)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isstring(L, 1, 0, &tolua_err))
	{
		tolua_error(L, "#vinvalid type in variable assignment", &tolua_err);
	}
#endif
	Slice name = tolua_toslice(L, 1, nullptr);
	int top = lua_gettop(L);
	int count = top - 1;
	if (count > 0)
	{
		for (int i = 2; i <= top; i++)
		{
			lua_pushvalue(L, i);
		}
		lua_State* baseL = SharedLuaEngine.getState();
		int baseTop = lua_gettop(baseL);
		DEFER(lua_settop(baseL, baseTop));
		lua_xmove(L, baseL, count);
		LuaEventArgs::send(name, count);
	}
	else
	{
		LuaEventArgs::send(name, 0);
	}
	return 0;
}

static std::vector<std::string> getVectorString(lua_State* L, int loc)
{
	int length = s_cast<int>(lua_rawlen(L, loc));
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isslicearray(L, loc, length, 0, &tolua_err))
	{
		goto tolua_lerror;
	}
	else
#endif
	{
		std::vector<std::string> array(length);
		for (int i = 0; i < length; i++)
		{
			array[i] = tolua_tofieldslice(L, loc, i + 1, 0);
		}
		return array;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'getVectorString'.", &tolua_err);
	return std::vector<std::string>();
#endif
}

static void pushVectorString(lua_State* L, const std::vector<std::string>& array)
{
	lua_createtable(L, s_cast<int>(array.size()), 0);
	int i = 0;
	for (const auto& item : array)
	{
		lua_pushlstring(L, item.c_str(), item.size());
		lua_rawseti(L, -2, ++i);
	}
}

static void pushListString(lua_State* L, const std::list<std::string>& array)
{
	lua_createtable(L, s_cast<int>(array.size()), 0);
	int i = 0;
	for (const auto& item : array)
	{
		lua_pushlstring(L, item.c_str(), item.size());
		lua_rawseti(L, -2, ++i);
	}
}

static Slice GetString(lua_State* L, int loc)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isstring(L, loc, 0, &tolua_err))
	{
		goto tolua_lerror;
	}
	else
#endif
	{
		return tolua_toslice(L, loc, nullptr);
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'getString'.", &tolua_err);
	return Slice::Empty;
#endif
}

/* Path */
int Path_create(lua_State* L)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertable(L, 1, "Path"_slice, 0, &tolua_err))
	{
		tolua_error(L, "#ferror in function 'Path_create'.", &tolua_err);
		return 0;
	}
#endif
	int top = lua_gettop(L);
	std::list<Slice> paths;
	for (int i = 2; i <= top; i++)
	{
#ifndef TOLUA_RELEASE
		if (!tolua_isstring(L, i, 0, &tolua_err))
		{
			tolua_error(L, "#ferror in function 'Path_create'.", &tolua_err);
			return 0;
		}
#endif
		auto str = tolua_toslice(L, i, 0);
		paths.push_back(str);
	}
	auto result = Path::concat(paths);
	lua_pushlstring(L, result.c_str(), result.size());
	return 1;
}

/* Content */

void __Content_loadFile(lua_State* L, Content* self, String filename)
{
	auto data = self->load(filename);
	if (data.first) lua_pushlstring(L, r_cast<char*>(data.first.get()), data.second);
	else lua_pushnil(L);
}

void __Content_getDirs(lua_State* L, Content* self, String path)
{
	auto dirs = self->getDirs(path);
	pushListString(L, dirs);
}

void __Content_getFiles(lua_State* L, Content* self, String path)
{
	auto files = self->getFiles(path);
	pushListString(L, files);
}

void __Content_getAllFiles(lua_State* L, Content* self, String path)
{
	auto files = self->getAllFiles(path);
	pushListString(L, files);
}

int Content_GetSearchPaths(lua_State* L)
{
	Content* self = r_cast<Content*>(tolua_tousertype(L, 1, 0));
	pushVectorString(L, self->getSearchPaths());
	return 1;
}

int Content_SetSearchPaths(lua_State* L)
{
	Content* self = r_cast<Content*>(tolua_tousertype(L, 1, 0));
	self->setSearchPaths(getVectorString(L, 2));
	return 0;
}

void Content_insertSearchPath(Content* self, int index, String path)
{
	self->insertSearchPath(index-1, path);
}

/* Node */

int Node_emit(lua_State* L)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Node"_slice, 0, &tolua_err) ||
		!tolua_isstring(L, 2, 0, &tolua_err))
	{
		goto tolua_lerror;
	}
	else
#endif
	{
		Node* self = r_cast<Node*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Node_emit'", nullptr);
#endif
		Slice name = tolua_toslice(L, 2, 0);
		int top = lua_gettop(L);
		int count = top - 2;
		if (count > 0)
		{
			for (int i = 3; i <= top; i++)
			{
				lua_pushvalue(L, i);
			}
			lua_State* baseL = SharedLuaEngine.getState();
			int baseTop = lua_gettop(baseL);
			DEFER(lua_settop(baseL, baseTop));
			lua_xmove(L, baseL, count);
			LuaEventArgs luaEvent(name, count);
			self->emit(&luaEvent);
		}
		else
		{
			LuaEventArgs luaEvent(name, 0);
			self->emit(&luaEvent);
		}
	}
	return 0;
#ifndef TOLUA_RELEASE
tolua_lerror :
	tolua_error(L, "#ferror in function 'emit'.", &tolua_err);
	return 0;
#endif
}

int Node_slot(lua_State* L)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(L, 1, "Node"_slice, 0, &tolua_err) ||
		!tolua_isstring(L, 2, 0, &tolua_err) ||
		!(tolua_isfunction(L, 3, &tolua_err) ||
			lua_isnil(L, 3) ||
			tolua_isnoobj(L, 3, &tolua_err)) ||
		!tolua_isnoobj(L, 4, &tolua_err)
		)
	{
		goto tolua_lerror;
	}
	else
#endif
	{
		Node* self = r_cast<Node*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Node_slot'", nullptr);
#endif
		Slice name = tolua_toslice(L, 2, 0);
		if (tolua_isfunction(L, 3))
		{
			int handler = tolua_ref_function(L, 3);
			self->slot(name, LuaFunction<void>(handler));
			return 0;
		}
		else if (lua_isnil(L, 3))
		{
			self->slot(name, nullptr);
			return 0;
		}
		else tolua_pushobject(L, self->slot(name));
	}
	return 1;
#ifndef TOLUA_RELEASE
tolua_lerror :
	tolua_error(L, "#ferror in function 'slot'.", &tolua_err);
	return 0;
#endif
}

int Node_gslot(lua_State* L)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Node"_slice, 0, &tolua_err) ||
		!(tolua_isstring(L, 2, 0, &tolua_err) || tolua_isusertype(L, 2, "GSlot", 0, &tolua_err)) ||
		!(tolua_isfunction(L, 3, &tolua_err) || lua_isnil(L, 3) || tolua_isnoobj(L, 3, &tolua_err)) ||
		!tolua_isnoobj(L, 4, &tolua_err))
	{
		goto tolua_lerror;
	}
	else
#endif
	{
		Node* self = r_cast<Node*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Node_gslot'", NULL);
#endif
		if (lua_isstring(L, 2))
		{
			Slice name = tolua_toslice(L, 2, 0);
			if (tolua_isfunction(L, 3)) // set
			{
				int handler = tolua_ref_function(L, 3);
				Listener* listener =self->gslot(name, LuaFunction<void>(handler));
				tolua_pushobject(L, listener);
				return 1;
			}
			else if (lua_gettop(L) < 3) // get
			{
				RefVector<Listener> gslots = self->gslot(name);
				if (!gslots.empty())
				{
					int size = s_cast<int>(gslots.size());
					lua_createtable(L, size, 0);
					for (int i = 0; i < size; i++)
					{
						tolua_pushobject(L, gslots[i]);
						lua_rawseti(L, -2, i + 1);
					}
				}
				else lua_pushnil(L);
				return 1;
			}
			else if (lua_isnil(L, 3))// del
			{
				self->gslot(name, nullptr);
				return 0;
			}
		}
		else
		{
			Listener* listener = r_cast<Listener*>(tolua_tousertype(L, 2, 0));
			self->gslot(listener, nullptr);
			return 0;
		}
	}
#ifndef TOLUA_RELEASE
tolua_lerror :
	tolua_error(L, "#ferror in function 'gslot'.", &tolua_err);
#endif
	return 0;
}

bool Node_eachChild(Node* self, const LuaFunction<bool>& func)
{
	int index = 0;
	return self->eachChild([&](Node* child)
	{
		return func(child, ++index);
	});
}

bool Cache::load(String filename)
{
	std::string ext = Path::getExt(filename);
	if (!ext.empty())
	{
		switch (Switch::hash(ext))
		{
			case "atlas"_hash:
				return SharedAtlasCache.load(filename);
			case "clip"_hash:
				return SharedClipCache.load(filename);
			case "frame"_hash:
				return SharedFrameCache.load(filename);
			case "model"_hash:
				return SharedModelCache.load(filename);
			case "par"_hash:
				return SharedParticleCache.load(filename);
			case "jpg"_hash:
			case "png"_hash:
			case "dds"_hash:
			case "pvr"_hash:
			case "ktx"_hash:
				return SharedTextureCache.load(filename);
			case "svg"_hash:
				return SharedSVGCache.load(filename);
			case "bin"_hash:
				return SharedShaderCache.load(filename);
			case "wav"_hash:
			case "ogg"_hash:
				return SharedSoundCache.load(filename);
			default:
			{
				if (filename.split("|"_slice).size() == 2)
				{
					return SharedSkeletonCache.load(filename);
				}
				Error("failed to load unsupported resource \"{}\".", filename);
				return false;
			}
		}
	}
	return false;
}

void Cache::loadAsync(String filename, const std::function<void()>& callback)
{
	if (filename.split("|"_slice).size() == 2)
	{
		SharedSkeletonCache.loadAsync(filename, [callback](SkeletonData*) { callback(); });
		return;
	}
	std::string ext = Path::getExt(filename);
	if (!ext.empty())
	{
		switch (Switch::hash(ext))
		{
			case "atlas"_hash:
				SharedAtlasCache.loadAsync(filename, [callback](Atlas*) { callback(); });
				break;
			case "clip"_hash:
				SharedClipCache.loadAsync(filename, [callback](ClipDef*) { callback(); });
				break;
			case "frame"_hash:
				SharedFrameCache.loadAsync(filename, [callback](FrameActionDef*) { callback(); });
				break;
			case "model"_hash:
				SharedModelCache.loadAsync(filename, [callback](ModelDef*) { callback(); });
				break;
			case "par"_hash:
				SharedParticleCache.loadAsync(filename, [callback](ParticleDef*) { callback(); });
				break;
			case "jpg"_hash:
			case "png"_hash:
			case "dds"_hash:
			case "pvr"_hash:
			case "ktx"_hash:
				SharedTextureCache.loadAsync(filename, [callback](Texture2D*) { callback(); });
				break;
			case "svg"_hash:
				SharedSVGCache.loadAsync(filename, [callback](SVGDef*) { callback(); });
				break;
			case "bin"_hash:
				SharedShaderCache.loadAsync(filename, [callback](Shader*) { callback(); });
				break;
			case "wav"_hash:
			case "ogg"_hash:
				SharedSoundCache.loadAsync(filename, [callback](SoundFile*) { callback(); });
				break;
			default:
				Error("resource is not supported by name: \"{}\".", filename);
				break;
		}
	}
}

void Cache::update(String filename, String content)
{
	std::string ext = Path::getExt(filename);
	if (!ext.empty())
	{
		switch (Switch::hash(ext))
		{
			case "clip"_hash:
				SharedClipCache.update(filename, content);
				break;
			case "frame"_hash:
				SharedFrameCache.update(filename, content);
				break;
			case "model"_hash:
				SharedModelCache.update(filename, content);
				break;
			case "par"_hash:
				SharedParticleCache.update(filename, content);
				break;
			case "svg"_hash:
				SharedSVGCache.update(filename, content);
				break;
			default:
				Error("failed to update unsupported resource \"{}\".", filename);
				break;
		}
	}
}

void Cache::update(String filename, Texture2D* texture)
{
	SharedTextureCache.update(filename, texture);
}

bool Cache::unload(String name)
{
	std::string ext = Path::getExt(name);
	if (!ext.empty())
	{
		switch (Switch::hash(ext))
		{
			case "atlas"_hash:
				return SharedAtlasCache.unload(name);
			case "skel"_hash:
				return SharedSkeletonCache.unload(name);
			case "clip"_hash:
				return SharedClipCache.unload(name);
			case "frame"_hash:
				return SharedFrameCache.unload(name);
			case "model"_hash:
				return SharedModelCache.unload(name);
			case "par"_hash:
				return SharedParticleCache.unload(name);
			case "jpg"_hash:
			case "png"_hash:
			case "dds"_hash:
			case "pvr"_hash:
			case "ktx"_hash:
				return SharedTextureCache.unload(name);
			case "svg"_hash:
				return SharedSVGCache.unload(name);
			case "bin"_hash:
				return SharedShaderCache.unload(name);
			case "wav"_hash:
			case "ogg"_hash:
				return SharedSoundCache.unload(name);
			default:
				Warn("failed to unload resource \"{}\".", name);
				break;
		}
	}
	else
	{
		switch (Switch::hash(name))
		{
			case "Texture"_hash:
				return SharedTextureCache.unload();
			case "SVG"_hash:
				return SharedSVGCache.unload();
			case "Clip"_hash:
				return SharedClipCache.unload();
			case "Frame"_hash:
				return SharedFrameCache.unload();
			case "Model"_hash:
				return SharedModelCache.unload();
			case "Particle"_hash:
				return SharedParticleCache.unload();
			case "Shader"_hash:
				return SharedShaderCache.unload();
			case "Font"_hash:
				return SharedFontCache.unload();
			case "Sound"_hash:
				return SharedSoundCache.unload();
			default:
			{
				auto tokens = name.split("::"_slice);
				if (tokens.size() == 2)
				{
					auto it = tokens.begin();
					Slice fontName = *it;
					int fontSize = Slice::stoi(*(++it));
					return SharedFontCache.unload(fontName, fontSize);
				}
				break;
			}
		}
	}
	return false;
}

void Cache::unload()
{
	SharedShaderCache.unload();
	SharedModelCache.unload();
	SharedFrameCache.unload();
	SharedParticleCache.unload();
	SharedClipCache.unload();
	SharedTextureCache.unload();
	SharedSVGCache.unload();
	SharedFontCache.unload();
	SharedSoundCache.unload();
}

void Cache::removeUnused()
{
	SharedShaderCache.removeUnused();
	SharedModelCache.removeUnused();
	SharedFrameCache.removeUnused();
	SharedParticleCache.removeUnused();
	SharedClipCache.removeUnused();
	SharedTextureCache.removeUnused();
	SharedSVGCache.removeUnused();
	SharedFontCache.removeUnused();
	SharedSoundCache.removeUnused();
}

void Cache::removeUnused(String name)
{
	switch (Switch::hash(name))
	{
		case "atlas"_hash:
			SharedAtlasCache.removeUnused();
			break;
		case "skel"_hash:
			SharedSkeletonCache.removeUnused();
			break;
		case "Texture"_hash:
			SharedTextureCache.removeUnused();
			break;
		case "SVG"_hash:
			SharedSVGCache.removeUnused();
			break;
		case "Clip"_hash:
			SharedClipCache.removeUnused();
			break;
		case "Frame"_hash:
			SharedFrameCache.removeUnused();
			break;
		case "Model"_hash:
			SharedModelCache.removeUnused();
			break;
		case "Particle"_hash:
			SharedParticleCache.removeUnused();
			break;
		case "Shader"_hash:
			SharedShaderCache.removeUnused();
			break;
		case "Font"_hash:
			SharedFontCache.removeUnused();
			break;
		case "Sound"_hash:
			SharedSoundCache.removeUnused();
			break;
		default:
			Error("failed to remove unused cache type \"{}\".", name);
			break;
	}
}

/* Sprite */

Sprite* Sprite_create(String clipStr)
{
	return SharedClipCache.loadSprite(clipStr);
}

static TextureWrap toTextureWrap(lua_State* L, String value)
{
	switch (Switch::hash(value))
	{
		case "None"_hash: return TextureWrap::None;
		case "Mirror"_hash: return TextureWrap::Mirror;
		case "Clamp"_hash: return TextureWrap::Clamp;
		case "Border"_hash: return TextureWrap::Border;
		default:
			luaL_error(L, LogFormat("Texture wrap \"{}\" is invalid, only \"None\", \"Mirror\", \"Clamp\", \"Border\" are allowed.", value).c_str());
			break;
	}
	return TextureWrap::None;
}

static Slice getTextureWrap(TextureWrap value)
{
	switch (value)
	{
		case TextureWrap::None: return "None"_slice;
		case TextureWrap::Mirror: return "Mirror"_slice;
		case TextureWrap::Clamp: return "Clamp"_slice;
		case TextureWrap::Border: return "Border"_slice;
		default: return "None"_slice;
	}
}

int Sprite_GetUWrap(lua_State* L)
{
	Sprite* self = r_cast<Sprite*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in accessing variable 'Sprite_GetUWrap'", nullptr);
#endif
	tolua_pushslice(L, getTextureWrap(self->getUWrap()));
	return 1;
}

int Sprite_SetUWrap(lua_State* L)
{
	Sprite* self = r_cast<Sprite*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in accessing variable 'Sprite_SetUWrap'", nullptr);
#endif
	auto value = GetString(L, 2);
	self->setUWrap(toTextureWrap(L, value));
	return 0;
}

int Sprite_GetVWrap(lua_State* L)
{
	Sprite* self = r_cast<Sprite*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in accessing variable 'Sprite_GetVWrap'", nullptr);
#endif
	tolua_pushslice(L, getTextureWrap(self->getVWrap()));
	return 1;
}

int Sprite_SetVWrap(lua_State* L)
{
	Sprite* self = r_cast<Sprite*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in accessing variable 'Sprite_SetVWrap'", nullptr);
#endif
	auto value = GetString(L, 2);
	self->setVWrap(toTextureWrap(L, value));
	return 0;
}

int Sprite_GetTextureFilter(lua_State* L)
{
	Sprite* self = r_cast<Sprite*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in accessing variable 'Sprite_GetTextureFilter'", nullptr);
#endif
	switch (self->getFilter())
	{
		case TextureFilter::None: tolua_pushslice(L, "None"_slice);
		case TextureFilter::Point: tolua_pushslice(L, "Point"_slice);
		case TextureFilter::Anisotropic: tolua_pushslice(L, "Anisotropic"_slice);
		default: tolua_pushslice(L, "None"_slice);
	}
	return 1;
}

int Sprite_SetTextureFilter(lua_State* L)
{
	Sprite* self = r_cast<Sprite*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in accessing variable 'Sprite_SetTextureFilter'", nullptr);
#endif
	auto value = GetString(L, 2);
	switch (Switch::hash(value))
	{
		case "None"_hash: self->setFilter(TextureFilter::None); break;
		case "Point"_hash: self->setFilter(TextureFilter::Point); break;
		case "Anisotropic"_hash: self->setFilter(TextureFilter::Anisotropic); break;
		default:
			luaL_error(L, LogFormat("Texture filter \"{}\" is invalid, only \"None\", \"Point\", \"Anisotropic\" are allowed.", value).c_str());
			break;
	}
	return 0;
}

/* Label */

Sprite* Label_getCharacter(Label* self, int index)
{
	return self->getCharacter(index - 1);
}

int Label_GetTextAlign(lua_State* L)
{
	Label* self = r_cast<Label*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in accessing variable 'Label_GetTextAlign'", nullptr);
#endif
	switch (self->getAlignment())
	{
		case TextAlign::Left: tolua_pushslice(L, "Left"_slice);
		case TextAlign::Center: tolua_pushslice(L, "Center"_slice);
		case TextAlign::Right: tolua_pushslice(L, "Right"_slice);
		default: tolua_pushslice(L, "Left"_slice);
	}
	return 1;
}

int Label_SetTextAlign(lua_State* L)
{
	Label* self = r_cast<Label*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in accessing variable 'Label_SetTextAlign'", nullptr);
#endif
	auto value = GetString(L, 2);
	switch (Switch::hash(value))
	{
		case "Left"_hash: self->setAlignment(TextAlign::Left); break;
		case "Center"_hash: self->setAlignment(TextAlign::Center); break;
		case "Right"_hash: self->setAlignment(TextAlign::Right); break;
		default:
			luaL_error(L, LogFormat("Label text alignment \"{}\" is invalid, only \"Left\", \"Center\", \"Right\" are allowed.", value).c_str());
			break;
	}
	return 0;
}

/* Vec2 */

Vec2* Vec2_create(float x, float y)
{
	return Mtolua_new((Vec2)({x, y}));
}

Vec2* Vec2_create(const Size& size)
{
	return Mtolua_new((Vec2)({size.width, size.height}));
}

/* Size */

Size* Size_create(float width, float height)
{
	return Mtolua_new((Size)({width, height}));
}

Size* Size_create(const Vec2& vec)
{
	return Mtolua_new((Size)({vec.x, vec.y}));
}

/* BlendFunc */

Uint32 getBlendFuncVal(String name)
{
	switch (Switch::hash(name))
	{
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
			AssertIf(true, "blendfunc name \"{}\" is invalid. use one of [One, Zero,\n"
			"SrcColor, SrcAlpha, DstColor, DstAlpha,\n"
			"InvSrcColor, InvSrcAlpha, InvDstColor, InvDstAlpha]", name);
			break;
	}
	return BlendFunc::Zero;
}

BlendFunc* BlendFunc_create(String src, String dst)
{
	return Mtolua_new((BlendFunc)({getBlendFuncVal(src), getBlendFuncVal(dst)}));
}

Uint32 BlendFunc_get(String func)
{
	return getBlendFuncVal(func);
}

namespace LuaAction
{
	static float toNumber(lua_State* L, int location, int index, bool useDefault = false)
	{
		lua_rawgeti(L, location, index);
		if (useDefault)
		{
			float number = s_cast<float>(tolua_tonumber(L, -1, 0));
			lua_pop(L, 1);
			return number;
		}
		else
		{
#ifndef TOLUA_RELEASE
			tolua_Error tolua_err;
			if (!tolua_isnumber(L, -1, 0, &tolua_err))
			{
				tolua_error(L, "#ferror when reading action definition params.", &tolua_err);
				return 0.0f;
			}
#endif
			float number = s_cast<float>(lua_tonumber(L, -1));
			lua_pop(L, 1);
			return number;
		}
	}

	static Own<ActionDuration> create(lua_State* L, int location)
	{
#ifndef TOLUA_RELEASE
		tolua_Error tolua_err;
		if (!tolua_istable(L, location, 0, &tolua_err))
		{
			goto tolua_lerror;
		}
		else
#endif
		{
			if (location == -1) location = lua_gettop(L);
			int length = s_cast<int>(lua_rawlen(L, location));
			if (length > 0)
			{
				lua_rawgeti(L, location, 1);
				tolua_Error tolua_err;
				if (tolua_isslice(L, -1, 0, &tolua_err))
				{
					Slice name = tolua_toslice(L, -1, nullptr);
					lua_pop(L, 1);
					size_t nameHash = Switch::hash(name);
					switch (nameHash)
					{
						case "X"_hash:
						case "Y"_hash:
						case "Z"_hash:
						case "ScaleX"_hash:
						case "ScaleY"_hash:
						case "SkewX"_hash:
						case "SkewY"_hash:
						case "Angle"_hash:
						case "AngleX"_hash:
						case "AngleY"_hash:
						case "Width"_hash:
						case "Height"_hash:
						case "AnchorX"_hash:
						case "AnchorY"_hash:
						case "Opacity"_hash:
						{
							float duration = toNumber(L, location, 2);
							float start = toNumber(L, location, 3);
							float stop = toNumber(L, location, 4);
							Ease::Enum ease = s_cast<Ease::Enum>(s_cast<int>(toNumber(L, location, 5, true)));
							Property::Enum prop = Property::None;
							switch (nameHash)
							{
								case "X"_hash: prop = Property::X; break;
								case "Y"_hash: prop = Property::Y; break;
								case "Z"_hash: prop = Property::Z; break;
								case "ScaleX"_hash: prop = Property::ScaleX; break;
								case "ScaleY"_hash: prop = Property::ScaleY; break;
								case "SkewX"_hash: prop = Property::SkewX; break;
								case "SkewY"_hash: prop = Property::SkewY; break;
								case "Angle"_hash: prop = Property::Angle; break;
								case "AngleX"_hash: prop = Property::AngleX; break;
								case "AngleY"_hash: prop = Property::AngleY; break;
								case "Width"_hash: prop = Property::Width; break;
								case "Height"_hash: prop = Property::Height; break;
								case "AnchorX"_hash: prop = Property::AnchorX; break;
								case "AnchorY"_hash: prop = Property::AnchorY; break;
								case "Opacity"_hash: prop = Property::Opacity; break;
							}
							return PropertyAction::alloc(duration, start, stop, prop, ease);
						}
						case "Roll"_hash:
						{
							float duration = toNumber(L, location, 2);
							float start = toNumber(L, location, 3);
							float stop = toNumber(L, location, 4);
							Ease::Enum ease = s_cast<Ease::Enum>(s_cast<int>(toNumber(L, location, 5, true)));
							return Roll::alloc(duration, start, stop, ease);
						}
						case "Hide"_hash: return Hide::alloc();
						case "Show"_hash: return Show::alloc();
						case "Delay"_hash:
						{
							float duration = toNumber(L, location, 2);
							return Delay::alloc(duration);
						}
						case "Emit"_hash:
						{
							lua_rawgeti(L, location, 2);
							Slice name = tolua_toslice(L, -1, nullptr);
							lua_rawgeti(L, location, 3);
							Slice arg = tolua_toslice(L, -1, nullptr);
							lua_pop(L, 2);
							return Emit::alloc(name, arg);
						}
						case "Spawn"_hash:
						{
							std::vector<Own<ActionDuration>> actions(length - 1);
							for (int i = 2; i <= length; i++)
							{
								lua_rawgeti(L, location, i);
								actions[i - 2] = create(L, -1);
								lua_pop(L, 1);
							}
							return Spawn::alloc(actions);
						}
						case "Sequence"_hash:
						{
							std::vector<Own<ActionDuration>> actions(length - 1);
							for (int i = 2; i <= length; i++)
							{
								lua_rawgeti(L, location, i);
								actions[i - 2] = create(L, -1);
								lua_pop(L, 1);
							}
							return Sequence::alloc(std::move(actions));
						}
						default:
						{
							luaL_error(L, "action named \"%s\" is not exist.", name.toString().c_str());
							return Own<ActionDuration>();
						}
					}
				}
				else
				{
					tolua_error(L, "#ferror in function 'Action_create', reading action name.", &tolua_err);
					return Own<ActionDuration>();
				}
			}
#ifndef TOLUA_RELEASE
			else
			{
				luaL_error(L, "action definition is invalid with empty table.");
			}
#endif
		}
		return Own<ActionDuration>();

#ifndef TOLUA_RELEASE
tolua_lerror:
		tolua_error(L, "#ferror in function 'Action_create'.", &tolua_err);
		return Own<ActionDuration>();
#endif
	}
}

/* Action */

int Action_create(lua_State* L)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertable(L, 1, "Action"_slice, 0, &tolua_err) ||
		!tolua_istable(L, 2, 0, &tolua_err) ||
		!tolua_isnoobj(L, 3, &tolua_err))
	{
		goto tolua_lerror;
	}
	else
#endif
	{
		Action* action = Action::create(LuaAction::create(L, 2));
		tolua_pushobject(L, action);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Action_create'.", &tolua_err);
	return 0;
#endif
}

/* Model */

void __Model_getClipFile(lua_State* L, String filename)
{
	ModelDef* modelDef = SharedModelCache.load(filename);
	const std::string& clipFile = modelDef->getClipFile();
	lua_pushlstring(L, clipFile.c_str(), clipFile.size());
}

void __Model_getLookNames(lua_State* L, String filename)
{
	ModelDef* modelDef = SharedModelCache.load(filename);
	if (modelDef)
	{
		auto names = modelDef->getLookNames();
		int size = s_cast<int>(names.size());
		lua_createtable(L, size, 0);
		for (int i = 0; i < size;i++)
		{
			lua_pushlstring(L, names[i].c_str(), names[i].size());
			lua_rawseti(L, -2, i + 1);
		}
	}
	else
	{
		lua_createtable(L, 0, 0);
	}
}

void __Model_getAnimationNames(lua_State* L, String filename)
{
	ModelDef* modelDef = SharedModelCache.load(filename);
	if (modelDef)
	{
		auto names = modelDef->getAnimationNames();
		int size = s_cast<int>(names.size());
		lua_createtable(L, size, 0);
		for (int i = 0; i < size; i++)
		{
			lua_pushlstring(L, names[i].c_str(), names[i].size());
			lua_rawseti(L, -2, i + 1);
		}
	}
	else
	{
		lua_createtable(L, 0, 0);
	}
}

/* Spine */

void __Spine_getLookNames(lua_State* L, String spineStr)
{
	auto skelData = SharedSkeletonCache.load(spineStr);
	if (skelData)
	{
		auto& skins = skelData->getSkel()->getSkins();
		int size = s_cast<int>(skins.size());
		lua_createtable(L, size, 0);
		for (int i = 0; i < size;i++)
		{
			const auto& name = skins[i]->getName();
			lua_pushlstring(L, name.buffer(), name.length());
			lua_rawseti(L, -2, i + 1);
		}
	}
	else
	{
		lua_createtable(L, 0, 0);
	}
}

void __Spine_getAnimationNames(lua_State* L, String spineStr)
{
	auto skelData = SharedSkeletonCache.load(spineStr);
	if (skelData)
	{
		auto& anims = skelData->getSkel()->getAnimations();
		int size = s_cast<int>(anims.size());
		lua_createtable(L, size, 0);
		for (int i = 0; i < size; i++)
		{
			const auto& name = anims[i]->getName();
			lua_pushlstring(L, name.buffer(), name.length());
			lua_rawseti(L, -2, i + 1);
		}
	}
	else
	{
		lua_createtable(L, 0, 0);
	}
}

/* BodyDef */

int BodyDef_GetType(lua_State* L)
{
	BodyDef* self = r_cast<BodyDef*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in function 'BodyDef_GetType'", nullptr);
#endif
	Slice value;
	switch (self->getType()) {
		case pr::BodyType::Static: value = "Static"_slice; break;
		case pr::BodyType::Dynamic: value = "Dynamic"_slice; break;
		case pr::BodyType::Kinematic: value = "Kinematic"_slice; break;
	}
	tolua_pushslice(L, value);
	return 1;
}

int BodyDef_SetType(lua_State* L)
{
	BodyDef* self = r_cast<BodyDef*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in function 'BodyDef_SetType'", nullptr);
#endif
	auto value = GetString(L, 2);
	switch (Switch::hash(value))
	{
		case "Static"_hash: self->setType(pr::BodyType::Static); break;
		case "Dynamic"_hash: self->setType(pr::BodyType::Dynamic); break;
		case "Kinematic"_hash: self->setType(pr::BodyType::Kinematic); break;
		default:
			luaL_error(L, LogFormat("Body type \"{}\" is invalid, only \"Static\", \"Dynamic\", \"Kinematic\" are allowed.", value).c_str());
			break;
	}
	return 0;
}

/* Body */

Body* Body_create(BodyDef* def, PhysicsWorld* world, Vec2 pos, float rot)
{
	Body* body = Body::create(def, world, pos, rot);
	body->setEmittingEvent(true);
	return body;
}

/* Dictionary */

Array* __Dictionary_getKeys(Dictionary* self)
{
	std::vector<Slice> keys = self->getKeys();
	Array* array = Array::create(s_cast<int>(keys.size()));
	for (size_t i = 0; i < keys.size(); i++)
	{
		array->set(s_cast<int>(i), Value::alloc(keys[i].toString()));
	}
	return array;
}

int Dictionary_get(lua_State* L)
{
	/* 1 self, 2 key */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Dictionary"_slice, 0, &tolua_err) || !tolua_isslice(L, 2, 0, &tolua_err) || !tolua_isnoobj(L, 3, &tolua_err))
	{
		goto tolua_lerror;
	}
#endif
	{
		Dictionary* self = r_cast<Dictionary*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Dictionary_get'", nullptr);
#endif
		Slice key = tolua_toslice(L, 2, nullptr);
		const auto& value = self->get(key);
		if (value) value->pushToLua(L);
		else lua_pushnil(L);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Dictionary_get'.", &tolua_err);
	return 0;
#endif
}

static Own<Value> Dora_getValue(lua_State* L, int loc)
{
	if (!lua_isnil(L, loc))
	{
		if (lua_isinteger(L, loc))
		{
			return Value::alloc(lua_tointeger(L, loc));
		}
		else if (lua_isnumber(L, loc))
		{
			return Value::alloc(lua_tonumber(L, loc));
		}
		else if (lua_isboolean(L, loc))
		{
			return Value::alloc(lua_toboolean(L, loc) != 0);
		}
		else if (lua_isstring(L, loc))
		{
			return Value::alloc(tolua_toslice(L, loc, nullptr).toString());
		}
		else if (tolua_isobject(L, loc))
		{
			return Value::alloc(r_cast<Object*>(tolua_tousertype(L, loc, 0)));
		}
		else
		{
			auto name = tolua_typename(L, loc);
			lua_pop(L, 1);
			switch (Switch::hash(name))
			{
				case "Vec2"_hash:
					return Value::alloc(*r_cast<Vec2*>(tolua_tousertype(L, loc, 0)));
				case "Size"_hash:
					return Value::alloc(*r_cast<Size*>(tolua_tousertype(L, loc, 0)));
				case "Rect"_hash:
					return Value::alloc(*r_cast<Rect*>(tolua_tousertype(L, loc, 0)));
				case "Platformer::TargetAllow"_hash:
					return Value::alloc(*r_cast<Platformer::TargetAllow*>(tolua_tousertype(L, loc, 0)));
				default:
#ifndef TOLUA_RELEASE
					tolua_error(L, "Can only store number, boolean, string, Object, Vec2, Size, Rect and TargetAllow in containers.", nullptr);
#endif // TOLUA_RELEASE
					break;
			}
		}
	}
	return nullptr;
}

int Dictionary_set(lua_State* L)
{
	/* 1 self, 2 key, 3 value */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Dictionary"_slice, 0, &tolua_err) || !tolua_isslice(L, 2, 0, &tolua_err) || !tolua_isnoobj(L, 4, &tolua_err))
	{
		goto tolua_lerror;
	}
#endif
	{
		Dictionary* self = r_cast<Dictionary*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Dictionary_set'", nullptr);
#endif
		auto value = Dora_getValue(L, 3);
		Slice key = tolua_toslice(L, 2, nullptr);
		if (value) self->set(key, std::move(value));
		else self->remove(key);
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Dictionary_set'.", &tolua_err);
	return 0;
#endif
}

/* Array */

int Array_getFirst(lua_State* L)
{
	Array* self = r_cast<Array*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in function 'Array_getFirst'", nullptr);
#endif
	self->getFirst()->pushToLua(L);
	return 1;
}

int Array_getLast(lua_State* L)
{
	Array* self = r_cast<Array*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in function 'Array_getLast'", nullptr);
#endif
	self->getLast()->pushToLua(L);
	return 1;
}

int Array_getRandomObject(lua_State* L)
{
	Array* self = r_cast<Array*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in function 'Array_getRandomObject'", nullptr);
#endif
	self->getRandomObject()->pushToLua(L);
	return 1;
}

int Array_index(lua_State* L)
{
	/* 1 self, 2 value */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Array"_slice, 0, &tolua_err) || !tolua_isnoobj(L, 3, &tolua_err))
	{
		goto tolua_lerror;
	}
#endif
	{
		Array* self = r_cast<Array*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Array_index'", nullptr);
#endif
		auto value = Dora_getValue(L, 2);
		size_t index = self->index(value.get()) + 1;
		lua_pushnumber(L, index);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror :
	tolua_error(L, "#ferror in function 'Array_index'.", &tolua_err);
	return 0;
#endif
}

int Array_set(lua_State* L)
{
	/* 1 self, 2 index, 3 value */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Array"_slice, 0, &tolua_err) || !tolua_isnumber(L, 2, 0, &tolua_err) || !tolua_isnoobj(L, 4, &tolua_err))
	{
		goto tolua_lerror;
	}
#endif
	{
		Array* self = r_cast<Array*>(tolua_tousertype(L, 1, 0));
		int index = s_cast<int>(tolua_tonumber(L, 2, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Array_set'", nullptr);
#endif
		auto value = Dora_getValue(L, 3);
		self->set(index - 1, std::move(value));
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror :
	tolua_error(L, "#ferror in function 'Array_set'.", &tolua_err);
	return 0;
#endif
}

int Array_get(lua_State* L)
{
	/* 1 self, 2 index */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Array"_slice, 0, &tolua_err) || !tolua_isnumber(L, 2, 0, &tolua_err) || !tolua_isnoobj(L, 3, &tolua_err))
	{
		goto tolua_lerror;
	}
#endif
	{
		Array* self = r_cast<Array*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Array_get'", nullptr);
#endif
		int index = s_cast<int>(tolua_tonumber(L, 2, 0));
		const auto& value = self->get(index - 1);
		if (value) value->pushToLua(L);
		else lua_pushnil(L);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Array_get'.", &tolua_err);
	return 0;
#endif
}

int Array_insert(lua_State* L)
{
	/* 1 self, 2 index, 3 value */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Array"_slice, 0, &tolua_err) || !tolua_isnumber(L, 2, 0, &tolua_err) || !tolua_isnoobj(L, 4, &tolua_err))
	{
		goto tolua_lerror;
	}
#endif
	{
		Array* self = r_cast<Array*>(tolua_tousertype(L, 1, 0));
		int index = s_cast<int>(tolua_tonumber(L, 2, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Array_insert'", nullptr);
#endif
		auto value = Dora_getValue(L, 3);
		self->insert(index - 1, std::move(value));
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror :
	tolua_error(L, "#ferror in function 'Array_insert'.", &tolua_err);
	return 0;
#endif
}

int Array_fastRemove(lua_State* L)
{
	/* 1 self, 2 value */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Array"_slice, 0, &tolua_err) || !tolua_isnoobj(L, 3, &tolua_err))
	{
		goto tolua_lerror;
	}
#endif
	{
		Array* self = r_cast<Array*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Array_fastRemove'", nullptr);
#endif
		auto value = Dora_getValue(L, 2);
		self->fastRemove(value.get());
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror :
	tolua_error(L, "#ferror in function 'Array_fastRemove'.", &tolua_err);
	return 0;
#endif
}

int Array_add(lua_State* L)
{
	/* 1 self, 2 value */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Array"_slice, 0, &tolua_err) || !tolua_isnoobj(L, 3, &tolua_err))
	{
		goto tolua_lerror;
	}
#endif
	{
		Array* self = r_cast<Array*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Array_add'", nullptr);
#endif
		auto value = Dora_getValue(L, 2);
		self->add(std::move(value));
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror :
	tolua_error(L, "#ferror in function 'Array_add'.", &tolua_err);
	return 0;
#endif
}

int Array_contains(lua_State* L)
{
	/* 1 self, 2 value */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Array"_slice, 0, &tolua_err) || !tolua_isnoobj(L, 3, &tolua_err))
	{
		goto tolua_lerror;
	}
#endif
	{
		Array* self = r_cast<Array*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Array_contains'", nullptr);
#endif
		auto value = Dora_getValue(L, 2);
		lua_pushboolean(L, self->contains(value.get()) ? 1 : 0);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror :
	tolua_error(L, "#ferror in function 'Array_fastRemove'.", &tolua_err);
	return 0;
#endif
}

int Array_removeLast(lua_State* L)
{
	/* 1 self, 2 index */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Array"_slice, 0, &tolua_err) || !tolua_isnoobj(L, 2, &tolua_err))
	{
		goto tolua_lerror;
	}
#endif
	{
		Array* self = r_cast<Array*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Array_removeLast'", nullptr);
#endif
		auto value = self->removeLast();
		if (value) value->pushToLua(L);
		else lua_pushnil(L);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Array_removeLast'.", &tolua_err);
	return 0;
#endif
}

void Array_swap(Array* self, int indexA, int indexB)
{
	self->swap(indexA - 1, indexB - 1);
}

bool Array_removeAt(Array* self, int index)
{
	return self->removeAt(index - 1);
}

bool Array_fastRemoveAt(Array* self, int index)
{
	return self->fastRemoveAt(index - 1);
}

bool Array_each(Array* self, const LuaFunction<bool>& handler)
{
	int index = 0;
	return self->each([&](Value* item)
	{
		return handler(item, ++index);
	});
}

int Array_create(lua_State* L)
{
	tolua_Error tolua_err;
#ifndef TOLUA_RELEASE
	if (!tolua_isusertable(L, 1, "Array"_slice, 0, &tolua_err))
	{
		goto tolua_lerror;
	}
	else
#endif
 	{
 		if (tolua_isusertype(L, 2, "Array"_slice, 0, &tolua_err) &&
			tolua_isnoobj(L, 3, &tolua_err))
		{
			Array* other = r_cast<Array*>(tolua_tousertype(L, 2, 0));
			Array* tolua_ret = Array::create(other);
			tolua_pushobject(L, tolua_ret);
			return 1;
		}
		else if (tolua_istable(L, 2, 0, &tolua_err) &&
			tolua_isnoobj(L, 3, &tolua_err))
		{
			int tolua_len = s_cast<int>(lua_rawlen(L, 2));
			Array* tolua_ret = Array::create(tolua_len);
			for (int i=0; i< tolua_len; i++)
			{
				lua_pushnumber(L, i + 1);
				lua_gettable(L, 2);
				tolua_ret->set(i, Dora_getValue(L, -1));
				lua_pop(L, 1);
			}
			tolua_pushobject(L, tolua_ret);
			return 1;
		}
		else if (tolua_isnoobj(L, 3, &tolua_err))
 		{
			Array* tolua_ret = Array::create();
			tolua_pushobject(L, tolua_ret);
			return 1;
 		}
#ifndef TOLUA_RELEASE
 		else
 		{
			goto tolua_lerror;
		}
#endif
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'new'.", &tolua_err);
#endif
	return 0;
}

/* Buffer */

Buffer::Buffer(Uint32 size):
_data(size)
{
	zeroMemory();
}

void Buffer::resize(Uint32 size)
{
	_data.resize(s_cast<size_t>(size));
}

void Buffer::zeroMemory()
{
	std::memset(_data.data(), 0, _data.size());
}

char* Buffer::get()
{
	return _data.data();
}

Uint32 Buffer::size() const
{
	return s_cast<Uint32>(_data.size());
}

void Buffer::setString(String str)
{
	if (_data.empty()) return;
	size_t length = std::min(_data.size() - 1, str.size());
	std::memcpy(_data.data(), str.begin(), length);
	_data[length] = '\0';
}

Slice Buffer::toString()
{
	size_t size = 0;
	for (auto ch : _data)
	{
		if (ch == '\0')
		{
			break;
		}
		size++;
	}
	return Slice(_data.data(), size);
}

int Entity_get(lua_State* L)
{
	/* 1 self, 2 name */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Entity"_slice, 0, &tolua_err) || !tolua_isslice(L, 2, 0, &tolua_err))
	{
		goto tolua_lerror;
	}
#endif
	{
		Entity* self = r_cast<Entity*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Entity_get'", nullptr);
#endif
		Slice name = tolua_toslice(L, 2, nullptr);
		Value* com = self->getComponent(name);
		if (com) com->pushToLua(L);
		else lua_pushnil(L);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Entity_get'.", &tolua_err);
	return 0;
#endif
}

int Entity_getOld(lua_State* L)
{
	/* 1 self, 2 name */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Entity"_slice, 0, &tolua_err) || !tolua_isslice(L, 2, 0, &tolua_err))
	{
		goto tolua_lerror;
	}
#endif
	{
		Entity* self = r_cast<Entity*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Entity_getOld'", nullptr);
#endif
		Slice name = tolua_toslice(L, 2, nullptr);
		Value* com = self->getOldCom(name);
		if (com) com->pushToLua(L);
		else lua_pushnil(L);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Entity_getOld'.", &tolua_err);
	return 0;
#endif
}

int Entity_set(lua_State* L)
{
	/* 1 self, 2 name, 3 value, 4 raw_flag */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Entity"_slice, 0, &tolua_err) || !tolua_isslice(L, 2, 0, &tolua_err))
	{
		goto tolua_lerror;
	}
#endif
	{
		Entity* self = r_cast<Entity*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Entity_set'", nullptr);
#endif
		bool raw_flag = lua_toboolean(L, 4) != 0;
		Slice key = tolua_toslice(L, 2, nullptr);
#ifndef TOLUA_RELEASE
		try {
#endif
		if (lua_isnil(L, 3))
		{
			self->remove(key);
		}
		else
		{
			if (lua_isinteger(L, 3))
			{
				self->set(key, lua_tointeger(L, 3), raw_flag);
			}
			else if (lua_isnumber(L, 3))
			{
				self->set(key, lua_tonumber(L, 3), raw_flag);
			}
			else if (lua_isboolean(L, 3))
			{
				self->set(key, lua_toboolean(L, 3) != 0, raw_flag);
			}
			else if (lua_isstring(L, 3))
			{
				self->set(key, tolua_toslice(L, 3, nullptr).toString(), raw_flag);
			}
			else if (tolua_isobject(L, 3))
			{
				self->set(key, s_cast<Object*>(tolua_tousertype(L, 3, 0)), raw_flag);
			}
			else
			{
				auto name = tolua_typename(L, 3);
				lua_pop(L, 1);
				switch (Switch::hash(name))
				{
					case "Vec2"_hash:
						self->set(key, *r_cast<Vec2*>(tolua_tousertype(L, 3, 0)));
						break;
					case "Size"_hash:
						self->set(key, *r_cast<Size*>(tolua_tousertype(L, 3, 0)));
						break;
					case "Rect"_hash:
						self->set(key, *r_cast<Rect*>(tolua_tousertype(L, 3, 0)));
						break;
					case "Platformer::TargetAllow"_hash:
						self->set(key, *r_cast<Platformer::TargetAllow*>(tolua_tousertype(L, 3, 0)));
						break;
					default:
#ifndef TOLUA_RELEASE
						tolua_error(L, "Entity can only store number, boolean, string, Object, Vec2, Size, Rect and TargetAllow in containers.", nullptr);
#endif // TOLUA_RELEASE
						break;
				}
			}
		}
#ifndef TOLUA_RELEASE
		} catch (std::runtime_error& e) { luaL_error(L, e.what()); }
#endif
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror :
	tolua_error(L, "#ferror in function 'Entity_set'.", &tolua_err);
	return 0;
#endif
}

int Entity_setNext(lua_State* L)
{
	/* 1 self, 2 name, 3 value */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Entity"_slice, 0, &tolua_err) || !tolua_isslice(L, 2, 0, &tolua_err))
	{
		goto tolua_lerror;
	}
#endif
	{
		Entity* self = r_cast<Entity*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Entity_setNext'", nullptr);
#endif
		Slice key = tolua_toslice(L, 2, nullptr);
#ifndef TOLUA_RELEASE
		try {
#endif
		if (lua_isnil(L, 3))
		{
			self->removeNext(self->getIndex(key));
		}
		else
		{
			if (lua_isinteger(L, 3))
			{
				self->setNext(key, lua_tointeger(L, 3));
			}
			else if (lua_isnumber(L, 3))
			{
				self->setNext(key, lua_tonumber(L, 3));
			}
			else if (lua_isboolean(L, 3))
			{
				self->setNext(key, lua_toboolean(L, 3) != 0);
			}
			else if (lua_isstring(L, 3))
			{
				self->setNext(key, tolua_toslice(L, 3, nullptr).toString());
			}
			else if (tolua_isobject(L, 3))
			{
				self->setNext(key, s_cast<Object*>(tolua_tousertype(L, 3, 0)));
			}
			else
			{
				auto name = tolua_typename(L, 3);
				lua_pop(L, 1);
				switch (Switch::hash(name))
				{
					case "Vec2"_hash:
						self->setNext(key, *r_cast<Vec2*>(tolua_tousertype(L, 3, 0)));
						break;
					case "Size"_hash:
						self->setNext(key, *r_cast<Size*>(tolua_tousertype(L, 3, 0)));
						break;
					case "Rect"_hash:
						self->setNext(key, *r_cast<Rect*>(tolua_tousertype(L, 3, 0)));
						break;
					case "Platformer::TargetAllow"_hash:
						self->setNext(key, *r_cast<Platformer::TargetAllow*>(tolua_tousertype(L, 3, 0)));
						break;
					default:
#ifndef TOLUA_RELEASE
						tolua_error(L, "Entity can only store number, boolean, string, Object, Vec2, Size, Rect and TargetAllow in containers.", nullptr);
#endif // TOLUA_RELEASE
						break;
				}
			}
		}
#ifndef TOLUA_RELEASE
		} catch (std::runtime_error& e) { luaL_error(L, e.what()); }
#endif
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror :
	tolua_error(L, "#ferror in function 'Entity_setNext'.", &tolua_err);
	return 0;
#endif
}

/* EntityWorld */

EntityObserver* EntityObserver_create(String option, Slice components[], int count)
{
	Uint32 optionVal = -1;
	switch (Switch::hash(option))
	{
		case "Add"_hash: optionVal = Entity::Add; break;
		case "Change"_hash: optionVal = Entity::Change; break;
		case "Remove"_hash: optionVal = Entity::Remove; break;
		case "AddOrChange"_hash: optionVal = Entity::AddOrChange; break;
		default:
			AssertIf(true, "EntityObserver option name \"{}\" is invalid.", option);
			break;
	}
	return EntityObserver::create(optionVal, components, count);
}

/* SVGDef */

SVGDef* SVGDef_create(String filename)
{
	return SharedSVGCache.load(filename);
}

/* QLearner */
int QLearner_pack(lua_State* L)
{
	/* 1 table, 2 table */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_istable(L, 1, 0, &tolua_err)
		|| !tolua_istable(L, 2, 0, &tolua_err)
		|| !tolua_isnoobj(L, 3, &tolua_err))
	{
		goto tolua_lerror;
	}
#endif
	{
		int hintsCount = s_cast<int>(lua_rawlen(L, 1));
#ifndef TOLUA_RELEASE
		if (!tolua_isintegerarray(L, 1, hintsCount, 0, &tolua_err))
		{
			goto tolua_lerror;
		}
#endif
		std::vector<Uint32> hints;
		hints.resize(hintsCount);
		for (int i = 0; i < hintsCount; i++)
		{
			hints[i] = s_cast<Uint32>(tolua_tofieldinteger(L, 1, i + 1, 0));
		}
		
		int valuesCount = s_cast<int>(lua_rawlen(L, 2));
#ifndef TOLUA_RELEASE
		if (!tolua_isintegerarray(L, 2, valuesCount, 0, &tolua_err))
		{
			goto tolua_lerror;
		}
#endif
		std::vector<Uint32> values;
		values.resize(valuesCount);
		for (int i = 0; i < valuesCount; i++)
		{
			values[i] = s_cast<Uint32>(tolua_tofieldinteger(L, 2, i + 1, 0));
		}
		QLearner::QState state = 0;
#ifndef TOLUA_RELEASE
		try {
#endif
			state = QLearner::pack(hints, values);
#ifndef TOLUA_RELEASE
		} catch (std::runtime_error& e) { luaL_error(L, e.what()); }
#endif
		lua_pushinteger(L, s_cast<lua_Integer>(state));
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'QLearner_pack'.", &tolua_err);
	return 0;
#endif
}

int QLearner_load(lua_State* L)
{
	/* 1 self, 2 table */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "QLearner"_slice, 0, &tolua_err)
		|| !tolua_istable(L, 2, 0, &tolua_err)
		|| !tolua_isnoobj(L, 3, &tolua_err))
	{
		goto tolua_lerror;
	}
#endif
	{
		QLearner* self = r_cast<QLearner*>(tolua_tousertype(L, 1, 0));
		int size = s_cast<int>(lua_rawlen(L, 2));
#ifndef TOLUA_RELEASE
		if (!tolua_istablearray(L, 2, size, 0, &tolua_err))
		{
			goto tolua_lerror;
		}
#endif
		for (int i = 0; i < size; i++)
		{
			lua_rawgeti(L, 2, i + 1);
			int index = lua_gettop(L);
#ifndef TOLUA_RELEASE
			if (!tolua_isnumberarray(L, index, 3, 0, &tolua_err))
			{
				goto tolua_lerror;
			}
#endif
			lua_rawgeti(L, -1, 1);
			QLearner::QState state = s_cast<QLearner::QState>(lua_tointeger(L, -1));
			lua_pop(L, 1);
			lua_rawgeti(L, -1, 2);
			QLearner::QAction action = s_cast<QLearner::QAction>(lua_tointeger(L, -1));
			lua_pop(L, 1);
			lua_rawgeti(L, -1, 3);
			double q = lua_tonumber(L, -1);
			lua_pop(L, 1);
			self->setQ(state, action, q);
			lua_pop(L, 1);
		}
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'QLearner_load'.", &tolua_err);
	return 0;
#endif
}

int QLearner_getMatrix(lua_State* L)
{
	/* 1 self */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "QLearner"_slice, 0, &tolua_err)
		|| !tolua_isnoobj(L, 2, &tolua_err))
	{
		goto tolua_lerror;
	}
#endif
	{
		QLearner* self = r_cast<QLearner*>(tolua_tousertype(L, 1, 0));
		const auto& matrix = self->getMatrix();
		int i = 0;
		lua_createtable(L, s_cast<int>(matrix.size()), 0);
		for (const auto& row : matrix)
		{
			lua_createtable(L, 3, 0);
			QLearner::QState state = row.first;
			for (const auto& col : row.second)
			{
				QLearner::QAction action = col.first;
				double q = col.second;
				lua_pushinteger(L, s_cast<lua_Integer>(state));
				lua_rawseti(L, -2, 1);
				lua_pushinteger(L, s_cast<lua_Integer>(action));
				lua_rawseti(L, -2, 2);
				lua_pushnumber(L, q);
				lua_rawseti(L, -2, 3);
			}
			lua_rawseti(L, -2, i + 1);
			i++;
		}
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'QLearner_load'.", &tolua_err);
	return 0;
#endif
}

NS_DOROTHY_END

NS_DOROTHY_PLATFORMER_BEGIN

static Relation toRelation(String value)
{
	switch (Switch::hash(value))
	{
		case "Enemy"_hash: return Relation::Enemy;
		case "Friend"_hash: return Relation::Friend;
		case "Neutral"_hash: return Relation::Neutral;
		case "Unknown"_hash: return Relation::Unknown;
		case "Any"_hash: return Relation::Any;
		default:
			AssertIf(true, "Relation \"{}\" is invalid, only \"Enemy\", \"Friend\", \"Neutral\", \"Unknown\", \"Any\" are allowed.", value);
			break;
	}
	return Relation::Unknown;
}

static Slice getRelation(Relation relation)
{
	switch (relation)
	{
		case Relation::Enemy: return "Enemy"_slice;
		case Relation::Friend: return "Friend"_slice;
		case Relation::Neutral: return "Neutral"_slice;
		case Relation::Unknown: return "Unknown"_slice;
		case Relation::Any: return "Any"_slice;
		default: return "Unknown"_slice;
	}
}

/* TargetAllow */

void TargetAllow_allow(TargetAllow* self, String flag, bool allow)
{
	self->allow(toRelation(flag), allow);
}

bool TargetAllow_isAllow(TargetAllow* self, String relation)
{
	return self->isAllow(toRelation(relation));
}

/* AI */

Array* AI_getUnitsByRelation(Decision::AI* self, String relation)
{
	return self->getUnitsByRelation(toRelation(relation));
}

Unit* AI_getNearestUnit(Decision::AI* self, String relation)
{
	return self->getNearestUnit(toRelation(relation));
}

float AI_getNearestUnitDistance(Decision::AI* self, String relation)
{
	return self->getNearestUnitDistance(toRelation(relation));
}

/* Blackboard */

int Blackboard_get(lua_State* L)
{
	/* 1 self, 2 key */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Platformer::Behavior::Blackboard"_slice, 0, &tolua_err) || !tolua_isslice(L, 2, 0, &tolua_err) || !tolua_isnoobj(L, 3, &tolua_err))
	{
		goto tolua_lerror;
	}
#endif
	{
		Behavior::Blackboard* self = r_cast<Behavior::Blackboard*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Blackboard_get'", nullptr);
#endif
		Slice key = tolua_toslice(L, 2, nullptr);
		auto value = self->get(key);
		if (value) value->pushToLua(L);
		else lua_pushnil(L);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Blackboard_get'.", &tolua_err);
	return 0;
#endif
}

int Blackboard_set(lua_State* L)
{
	/* 1 self, 2 key, 3 value */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Platformer::Behavior::Blackboard"_slice, 0, &tolua_err) || !tolua_isslice(L, 2, 0, &tolua_err) || !tolua_isnoobj(L, 4, &tolua_err))
	{
		goto tolua_lerror;
	}
#endif
	{
		Behavior::Blackboard* self = r_cast<Behavior::Blackboard*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Blackboard_set'", nullptr);
#endif
		auto value = Dora_getValue(L, 3);
		Slice key = tolua_toslice(L, 2, nullptr);
		if (value) self->set(key, std::move(value));
		else self->remove(key);
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Blackboard_set'.", &tolua_err);
	return 0;
#endif
}

/* Bullet */

Bullet* Bullet_create(BulletDef* def, Unit* unit)
{
	Bullet* bullet = Bullet::create(def, unit);
	bullet->hitTarget += [](Bullet* bullet, Unit* target, Vec2 point)
	{
		bullet->emit("HitTarget"_slice, bullet, target, point);
		return bullet->isHitStop();
	};
	return bullet;
}

/* Data */

void Data_setRelation(Data* self, Uint8 groupA, Uint8 groupB, String relation)
{
	self->setRelation(groupA, groupB, toRelation(relation));
}

Slice Data_getRelation(Data* self, Uint8 groupA, Uint8 groupB)
{
	return getRelation(self->getRelation(groupA, groupB));
}

Slice Data_getRelation(Data* self, Body* bodyA, Body* bodyB)
{
	return getRelation(self->getRelation(bodyA, bodyB));
}

/* DB */

static Own<Value> Dora_getDBValue(lua_State* L, int loc)
{
	if (!lua_isnil(L, loc))
	{
		if (lua_isinteger(L, loc))
		{
			return Value::alloc(lua_tointeger(L, loc));
		}
		else if (lua_isnumber(L, loc))
		{
			return Value::alloc(lua_tonumber(L, loc));
		}
		else if (lua_isboolean(L, loc))
		{
#ifndef TOLUA_RELEASE
			if (lua_toboolean(L, loc) != 0)
			{
				tolua_error(L, "DB is not accepting value of boolean true.", nullptr);
			}
#endif // TOLUA_RELEASE
			return Value::alloc(false);
		}
		else if (lua_isstring(L, loc))
		{
			return Value::alloc(tolua_toslice(L, loc, nullptr).toString());
		}
#ifndef TOLUA_RELEASE
		else
		{
			tolua_error(L, "Can only store number, string and boolean false as NULL in DB.", nullptr);
		}
#endif // TOLUA_RELEASE
	}
	return Value::alloc(false);
}

int DB_transaction(lua_State* L)
{
	/* 1 self, 2 table */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "DB"_slice, 0, &tolua_err)
		|| !tolua_istable(L, 2, 0, &tolua_err)
		|| !tolua_isnoobj(L, 3, &tolua_err))
	{
		goto tolua_lerror;
	}
#endif
	{
		DB* self = r_cast<DB*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'DB_transaction'", nullptr);
#endif
		std::vector<std::pair<std::string, std::vector<std::vector<Own<Value>>>>> sqls;
		int itemCount = s_cast<int>(lua_rawlen(L, 2));
		sqls.resize(itemCount);
		for (int i = 0; i < itemCount; i++)
		{
			lua_rawgeti(L, 2, i + 1);
#ifndef TOLUA_RELEASE
			if (!tolua_isstring(L, -1, 0, &tolua_err)
				&& !tolua_istable(L, -1, 0, &tolua_err)) {
				goto tolua_lerror;
			}
#endif
			auto& sql = sqls[i];
			if (lua_istable(L, -1) != 0)
			{
				const int strLoc = -1;
				const int tableLoc = -2;
				lua_rawgeti(L, -1, 2);
				lua_rawgeti(L, -2, 1);
#ifndef TOLUA_RELEASE
				if (!tolua_isstring(L, strLoc, 0, &tolua_err)
					|| !tolua_istable(L, tableLoc, 0, &tolua_err)) {
					goto tolua_lerror;
				}
#endif
				sql.first = tolua_toslice(L, strLoc, 0);
				int argListSize = s_cast<int>(lua_rawlen(L, tableLoc));
				sql.second.resize(argListSize);
				for (int j = 0; j < argListSize; j++)
				{
					lua_rawgeti(L, tableLoc, j + 1);
#ifndef TOLUA_RELEASE
					if (!tolua_istable(L, -1, 0, &tolua_err)) {
						goto tolua_lerror;
					}
#endif
					auto& args = sql.second[j];
					int argSize = s_cast<int>(lua_rawlen(L, -1));
					args.resize(argSize);
					for (int k = 0; k < argSize; k++)
					{
						lua_rawgeti(L, -1, k + 1);
						args[k] = Dora_getDBValue(L, -1);
						lua_pop(L, 1);
					}
					lua_pop(L, 1);
				}
				lua_pop(L, 2);
			}
			else
			{
				sql.first = tolua_toslice(L, -1, 0);
			}
			lua_pop(L, 1);
		}
		bool result = self->transaction([&]()
		{
			for (const auto& sql : sqls)
			{
				if (sql.second.empty())
				{
					self->exec(sql.first);
				}
				else
				{
					for (const auto& arg : sql.second)
					{
						self->exec(sql.first, arg);
					}
				}
			}
		});
		lua_pushboolean(L, result ? 1 : 0);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'DB_transaction'.", &tolua_err);
	return 0;
#endif
}

int DB_query(lua_State* L)
{
	/* 1 self, 2 sql, 3 args or noobj */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "DB"_slice, 0, &tolua_err)
		|| !tolua_isslice(L, 2, 0, &tolua_err)
		|| !(
				(
					tolua_isboolean(L, 3, 1, &tolua_err) &&
					tolua_isnoobj(L, 4, &tolua_err)
				) || (
					tolua_istable(L, 3, 0, &tolua_err) &&
					tolua_isboolean(L, 4, 1, &tolua_err) &&
					tolua_isnoobj(L, 5, &tolua_err)
				)
			)
		)
	{
		goto tolua_lerror;
	}
#endif
	{
		DB* self = r_cast<DB*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'DB_query'", nullptr);
#endif
		auto sql = tolua_toslice(L, 2, nullptr);
		std::vector<Own<Value>> args;
		bool withColumns = false;
		if (lua_istable(L, 3) != 0)
		{
			int size = s_cast<int>(lua_rawlen(L, 3));
			args.resize(size);
			for (int i = 0; i < size; i++)
			{
				lua_rawgeti(L, 3, i + 1);
				args[i] = Dora_getDBValue(L, -1);
				lua_pop(L, 1);
			}
			withColumns = tolua_toboolean(L, 4, 0);
		}
		else withColumns = tolua_toboolean(L, 3, 0);
		auto result = self->query(sql, args, withColumns);
		lua_createtable(L, s_cast<int>(result.size()), 0);
		int i = 0;
		for (const auto& row : result)
		{
			lua_createtable(L, s_cast<int>(row.size()), 0);
			int j = 0;
			for (const auto& col : row)
			{
				col->pushToLua(L);
				lua_rawseti(L, -2, ++j);
			}
			lua_rawseti(L, -2, ++i);
		}
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'DB_query'.", &tolua_err);
	return 0;
#endif
}

int DB_insert(lua_State* L)
{
	/* 1 self, 2 tableName, 3 values */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "DB"_slice, 0, &tolua_err)
		|| !tolua_isslice(L, 2, 0, &tolua_err)
		|| !tolua_istable(L, 3, 0, &tolua_err)
		|| !tolua_isnoobj(L, 4, &tolua_err))
	{
		goto tolua_lerror;
	}
#endif
	{
		DB* self = r_cast<DB*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'DB_insert'", nullptr);
#endif
		auto tableName = tolua_toslice(L, 2, nullptr);
		std::vector<std::vector<Own<Value>>> values;
		int size = s_cast<int>(lua_rawlen(L, 3));
		values.resize(size);
		for (int i = 0; i < size; i++)
		{
			lua_rawgeti(L, 3, i + 1);
#ifndef TOLUA_RELEASE
			if (lua_istable(L, -1) == 0)
			{
				tolua_error(L, "invalid row value in function 'DB_insert'", nullptr);
			}
#endif
			int colSize = s_cast<int>(lua_rawlen(L, -1));
			auto& row = values[i];
			row.resize(colSize);
			for (int j = 0; j < colSize; j++)
			{
				lua_rawgeti(L, -1, j + 1);
				row[j] = Dora_getDBValue(L, -1);
				lua_pop(L, 1);
			}
			lua_pop(L, 1);
		}
		self->insert(tableName, values);
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'DB_insert'.", &tolua_err);
	return 0;
#endif
}

int DB_exec(lua_State* L)
{
	/* 1 self, 2 sql, 3 values or noobj */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "DB"_slice, 0, &tolua_err)
		|| !tolua_isslice(L, 2, 0, &tolua_err)
		|| !(
				tolua_isnoobj(L, 3, &tolua_err) ||
				(
					tolua_istable(L, 3, 0, &tolua_err) &&
					tolua_isnoobj(L, 4, &tolua_err)
				)
			)
		)
	{
		goto tolua_lerror;
	}
#endif
	{
		DB* self = r_cast<DB*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'DB_update'", nullptr);
#endif
		auto sql = tolua_toslice(L, 2, nullptr);
		std::vector<Own<Value>> values;
		if (lua_istable(L, 3) != 0)
		{
			int size = s_cast<int>(lua_rawlen(L, 3));
			values.resize(size);
			for (int i = 0; i < size; i++)
			{
				lua_rawgeti(L, 3, i + 1);
				values[i] = Dora_getDBValue(L, -1);
				lua_pop(L, 1);
			}
		}
		int result = self->exec(sql, values);
		lua_pushinteger(L, result);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'DB_update'.", &tolua_err);
	return 0;
#endif
}

int DB_queryAsync(lua_State* L)
{
	/* 1 self, 2 func, 3 sql, (4 args, 5 col) or (4 col) */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "DB"_slice, 0, &tolua_err)
		|| !tolua_isfunction(L, 2, &tolua_err)
		|| !tolua_isslice(L, 3, 0, &tolua_err)
		|| !(
				(
					tolua_isboolean(L, 4, 1, &tolua_err) &&
					tolua_isnoobj(L, 5, &tolua_err)
				) || (
					tolua_istable(L, 4, 0, &tolua_err) &&
					tolua_isboolean(L, 5, 1, &tolua_err) &&
					tolua_isnoobj(L, 6, &tolua_err)
				)
			)
		)
	{
		goto tolua_lerror;
	}
#endif
	{
		DB* self = r_cast<DB*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'DB_queryAsync'", nullptr);
#endif
		Ref<LuaHandler> handler(LuaHandler::create(tolua_ref_function(L, 2)));
		auto sql = tolua_toslice(L, 3, nullptr);
		std::vector<Own<Value>> args;
		bool withColumns = false;
		if (lua_istable(L, 4) != 0)
		{
			int size = s_cast<int>(lua_rawlen(L, 4));
			args.resize(size);
			for (int i = 0; i < size; i++)
			{
				lua_rawgeti(L, 4, i + 1);
				args[i] = Dora_getDBValue(L, -1);
				lua_pop(L, 1);
			}
			withColumns = tolua_toboolean(L, 5, 0);
		}
		else withColumns = tolua_toboolean(L, 4, 0);
		self->queryAsync(sql, std::move(args), withColumns, [handler](const std::deque<std::vector<Own<Value>>>& result)
		{
			lua_State* L = SharedLuaEngine.getState();
			int top = lua_gettop(L);
			DEFER(lua_settop(L, top));
			lua_createtable(L, s_cast<int>(result.size()), 0);
			int i = 0;
			for (const auto& row : result)
			{
				lua_createtable(L, s_cast<int>(row.size()), 0);
				int j = 0;
				for (const auto& col : row)
				{
					col->pushToLua(L);
					lua_rawseti(L, -2, ++j);
				}
				lua_rawseti(L, -2, ++i);
			}
			SharedLuaEngine.executeFunction(handler->get(), 1);
		});
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'DB_queryAsync'.", &tolua_err);
	return 0;
#endif
}

int DB_insertAsync(lua_State* L)
{
	/* 1 self, 2 tableName, 3 values, 4 func */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "DB"_slice, 0, &tolua_err)
		|| !tolua_isslice(L, 2, 0, &tolua_err)
		|| !tolua_istable(L, 3, 0, &tolua_err)
		|| !tolua_isfunction(L, 4, &tolua_err)
		|| !tolua_isnoobj(L, 5, &tolua_err))
	{
		goto tolua_lerror;
	}
#endif
	{
		DB* self = r_cast<DB*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'DB_select'", nullptr);
#endif
		auto tableName = tolua_toslice(L, 2, nullptr);
		std::vector<std::vector<Own<Value>>> values;
		int size = s_cast<int>(lua_rawlen(L, 3));
		values.resize(size);
		for (int i = 0; i < size; i++)
		{
			lua_rawgeti(L, 3, i + 1);
#ifndef TOLUA_RELEASE
			if (lua_istable(L, -1) == 0)
			{
				tolua_error(L, "invalid row value in function 'DB_insert'", nullptr);
			}
#endif
			int colSize = s_cast<int>(lua_rawlen(L, -1));
			auto& row = values[i];
			row.resize(colSize);
			for (int j = 0; j < colSize; j++)
			{
				lua_rawgeti(L, -1, j + 1);
				row[j] = Dora_getDBValue(L, -1);
				lua_pop(L, 1);
			}
			lua_pop(L, 1);
		}
		LuaFunction<void> callback(tolua_ref_function(L, 4));
		self->insertAsync(tableName, std::move(values), callback);
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'DB_insertAsync'.", &tolua_err);
	return 0;
#endif
}

int DB_execAsync(lua_State* L)
{
	/* 1 self, 2 sql, (3 values, 4 func) or (3 func) */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "DB"_slice, 0, &tolua_err)
		|| !tolua_isslice(L, 2, 0, &tolua_err)
		|| !((
				tolua_isfunction(L, 3, &tolua_err) &&
				tolua_isnoobj(L, 4, &tolua_err)
			) || (
				tolua_istable(L, 3, 0, &tolua_err) &&
				tolua_isfunction(L, 4, &tolua_err) &&
				tolua_isnoobj(L, 5, &tolua_err)
			))
		)
	{
		goto tolua_lerror;
	}
#endif
	{
		DB* self = r_cast<DB*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'DB_select'", nullptr);
#endif
		auto sql = tolua_toslice(L, 2, nullptr);
		std::vector<Own<Value>> values;
		int funcId = 0;
		if (lua_istable(L, 3) != 0)
		{
			int size = s_cast<int>(lua_rawlen(L, 3));
			values.resize(size);
			for (int i = 0; i < size; i++)
			{
				lua_rawgeti(L, 3, i + 1);
				values[i] = Dora_getDBValue(L, -1);
				lua_pop(L, 1);
			}
			funcId = tolua_ref_function(L, 4);
		}
		else funcId = tolua_ref_function(L, 3);
		LuaFunction<void> callback(funcId);
		self->execAsync(sql, std::move(values), callback);
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'DB_execAsync'.", &tolua_err);
	return 0;
#endif
}

NS_DOROTHY_PLATFORMER_END

using namespace Dorothy;

/* ImGui */

namespace ImGui { namespace Binding
{
	void LoadFontTTF(String ttfFontFile, float fontSize, String glyphRanges)
	{
		SharedImGui.loadFontTTF(ttfFontFile, fontSize, glyphRanges);
	}

	void ShowStats()
	{
		SharedImGui.showStats();
	}

	void ShowConsole()
	{
		SharedImGui.showConsole();
	}

	bool Begin(const char* name, String windowsFlags)
	{
		return ImGui::Begin(name, nullptr, getWindowCombinedFlags(windowsFlags));
	}

	bool Begin(const char* name, bool* p_open, String windowsFlags)
	{
		return ImGui::Begin(name, p_open, getWindowCombinedFlags(windowsFlags));
	}

	bool BeginChild(const char* str_id, const Vec2& size, bool border, String windowsFlags)
	{
		return ImGui::BeginChild(str_id, size, border, getWindowCombinedFlags(windowsFlags));
	}

	bool BeginChild(ImGuiID id, const Vec2& size, bool border, String windowsFlags)
	{
		return ImGui::BeginChild(id, size, border, getWindowCombinedFlags(windowsFlags));
	}

	void SetNextWindowPos(const Vec2& pos, String setCond)
	{
		ImGui::SetNextWindowPos(pos, getSetCond(setCond));
	}

	void SetNextWindowPosCenter(String setCond)
	{
		ImGui::SetNextWindowPos(Vec2(ImGui::GetIO().DisplaySize) * 0.5f, getSetCond(setCond));
	}

	void SetNextWindowSize(const Vec2& size, String setCond)
	{
		ImGui::SetNextWindowSize(size, getSetCond(setCond));
	}

	void SetNextWindowCollapsed(bool collapsed, String setCond)
	{
		ImGui::SetNextWindowCollapsed(collapsed, getSetCond(setCond));
	}

	void SetWindowPos(const char* name, const Vec2& pos, String setCond)
	{
		ImGui::SetWindowPos(name, pos, getSetCond(setCond));
	}
	
	void SetWindowSize(const char* name, const Vec2& size, String setCond)
	{
		ImGui::SetWindowSize(name, size, getSetCond(setCond));
	}

	void SetWindowCollapsed(const char* name, bool collapsed, String setCond)
	{
		ImGui::SetWindowCollapsed(name, collapsed, getSetCond(setCond));
	}

	void SetColorEditOptions(String colorEditMode)
	{
		ImGui::SetColorEditOptions(getColorEditFlags(colorEditMode));
	}

	bool InputText(const char* label, Buffer* buffer, String inputTextFlags)
	{
		if (!buffer) return false;
		return ImGui::InputText(label, buffer->get(), buffer->size(), getInputTextCombinedFlags(inputTextFlags));
	}

	bool InputTextMultiline(const char* label, Buffer* buffer, const Vec2& size, String inputTextFlags)
	{
		if (!buffer) return false;
		return ImGui::InputTextMultiline(label, buffer->get(), buffer->size(), size, getInputTextCombinedFlags(inputTextFlags));
	}

	bool TreeNodeEx(const char* label, String treeNodeFlags)
	{
		return ImGui::TreeNodeEx(label, getTreeNodeFlags(treeNodeFlags));
	}

	void SetNextItemOpen(bool is_open, String setCond)
	{
		ImGui::SetNextItemOpen(is_open, getSetCond(setCond));
	}

	bool CollapsingHeader(const char* label, String treeNodeFlags)
	{
		return ImGui::CollapsingHeader(label, getTreeNodeFlags(treeNodeFlags));
	}

	bool CollapsingHeader(const char* label, bool* p_open, String treeNodeFlags)
	{
		return ImGui::CollapsingHeader(label, p_open, getTreeNodeFlags(treeNodeFlags));
	}

	bool Selectable(const char* label, bool selected, String selectableFlags, const Vec2& size)
	{
		return ImGui::Selectable(label, selected, getSelectableFlags(selectableFlags), size);
	}

	bool Selectable(const char* label, bool* p_selected, String selectableFlags, const Vec2& size)
	{
		return ImGui::Selectable(label, p_selected, getSelectableFlags(selectableFlags), size);
	}

	bool BeginPopupModal(const char* name, String windowsFlags)
	{
		return ImGui::BeginPopupModal(name, nullptr, getWindowCombinedFlags(windowsFlags));
	}

	bool BeginPopupModal(const char* name, bool* p_open, String windowsFlags)
	{
		return ImGui::BeginPopupModal(name, p_open, getWindowCombinedFlags(windowsFlags));
	}

	bool BeginChildFrame(ImGuiID id, const Vec2& size, String windowsFlags)
	{
		return ImGui::BeginChildFrame(id, size, getWindowCombinedFlags(windowsFlags));
	}

	bool BeginPopupContextItem(const char* name, String popupFlags)
	{
		return ImGui::BeginPopupContextItem(name, getPopupCombinedFlags(popupFlags));
	}

	bool BeginPopupContextWindow(const char* name, String popupFlags)
	{
		return ImGui::BeginPopupContextWindow(name, getPopupCombinedFlags(popupFlags));
	}

	bool BeginPopupContextVoid(const char* name, String popupFlags)
	{
		return ImGui::BeginPopupContextVoid(name, getPopupCombinedFlags(popupFlags));
	}

	void PushStyleColor(String name, Color color)
	{
		ImGui::PushStyleColor(getColorIndex(name), color.toVec4());
	}

	void PushStyleVar(String name, const Vec2& val)
	{
		ImGuiStyleVar_ styleVar = ImGuiStyleVar_WindowPadding;
		switch (Switch::hash(name))
		{
			case "WindowPadding"_hash: styleVar = ImGuiStyleVar_WindowPadding; break;
			case "WindowMinSize"_hash: styleVar = ImGuiStyleVar_WindowMinSize; break;
			case "FramePadding"_hash: styleVar = ImGuiStyleVar_FramePadding; break;
			case "ItemSpacing"_hash: styleVar = ImGuiStyleVar_ItemSpacing; break;
			case "ItemInnerSpacing"_hash: styleVar = ImGuiStyleVar_ItemInnerSpacing; break;
			case "ButtonTextAlign"_hash: styleVar = ImGuiStyleVar_ButtonTextAlign; break;
			default:
				AssertIf(true, "ImGui style var name \"{}\" is invalid.", name);
				break;
		}
		ImGui::PushStyleVar(styleVar, val);
	}

	void PushStyleVar(String name, float val)
	{
		ImGuiStyleVar_ styleVar = ImGuiStyleVar_Alpha;
		switch (Switch::hash(name))
		{
			case "Alpha"_hash: styleVar = ImGuiStyleVar_Alpha; break;
			case "WindowRounding"_hash: styleVar = ImGuiStyleVar_WindowRounding; break;
			case "FrameRounding"_hash: styleVar = ImGuiStyleVar_FrameRounding; break;
			case "FrameBorderSize"_hash: styleVar = ImGuiStyleVar_FrameBorderSize; break;
			case "IndentSpacing"_hash: styleVar = ImGuiStyleVar_IndentSpacing; break;
			case "GrabMinSize"_hash: styleVar = ImGuiStyleVar_GrabMinSize; break;
			default:
				AssertIf(true, "ImGui style var name \"{}\" is invalid.", name);
				break;
		}
		ImGui::PushStyleVar(styleVar, val);
	}

	bool TreeNodeEx(const char* str_id, String treeNodeFlags, const char* text)
	{
		return ImGui::TreeNodeEx(str_id, getTreeNodeFlags(treeNodeFlags), "%s", text);
	}

	void Text(String text)
	{
		ImGui::TextUnformatted(text.begin(), text.end());
	}

	void TextColored(Color color, String text)
	{
		ImGui::PushStyleColor(ImGuiCol_Text, color.toVec4());
		ImGui::TextUnformatted(text.begin(), text.end());
		ImGui::PopStyleColor();
	}

	void TextDisabled(String text)
	{
		ImGui::PushStyleColor(ImGuiCol_Text, ImGui::GetStyle().Colors[ImGuiCol_TextDisabled]);
		ImGui::TextUnformatted(text.begin(), text.end());
		ImGui::PopStyleColor();
	}

	void TextWrapped(String text)
	{
		ImGui::TextWrappedUnformatted(text.begin(), text.end());
	}

	void LabelText(const char* label, const char* text)
	{
		ImGui::LabelText(label, "%s", text);
	}

	void BulletText(const char* text)
	{
		ImGui::BulletText("%s", text);
	}

	bool TreeNode(const char* str_id, const char* text)
	{
		return ImGui::TreeNode(str_id, "%s", text);
	}

	void SetTooltip(const char* text)
	{
		ImGui::SetTooltip("%s", text);
	}

	bool Combo(const char* label, int* current_item, const char* const* items, int items_count, int height_in_items)
	{
		--(*current_item); // for lua index start with 1
		bool result = ImGui::Combo(label, current_item, items, items_count, height_in_items);
		++(*current_item);
		return result;
	}

	bool DragFloat(const char* label, float* v, float v_speed, float v_min, float v_max, const char* display_format, String flags)
	{
		return ImGui::DragFloat(label, v, v_speed, v_min, v_max, display_format, getSliderCombinedFlags(flags));
	}

	bool DragFloat2(const char* label, float* v1, float* v2, float v_speed, float v_min, float v_max, const char* display_format, String flags)
	{
		float floats[2] = {*v1, *v2};
		bool changed = ImGui::DragFloat2(label, floats, v_speed, v_min, v_max, display_format, getSliderCombinedFlags(flags));
		*v1 = floats[0];
		*v2 = floats[1];
		return changed;
	}

	bool DragInt(const char* label, int* v, float v_speed, int v_min, int v_max, const char* display_format, String flags)
	{
		return ImGui::DragInt(label, v, v_speed, v_min, v_max, display_format, getSliderCombinedFlags(flags));
	}

	bool DragInt2(const char* label, int* v1, int* v2, float v_speed, int v_min, int v_max, const char* display_format, String flags)
	{
		int ints[2] = {*v1, *v2};
		bool changed = ImGui::DragInt2(label, ints, v_speed, v_min, v_max, display_format, getSliderCombinedFlags(flags));
		*v1 = ints[0];
		*v2 = ints[1];
		return changed;
	}

	bool InputFloat(const char* label, float* v, float step, float step_fast, const char* format, String flags)
	{
		return ImGui::InputFloat(label, v, step, step_fast, format, getInputTextCombinedFlags(flags));
	}

	bool InputFloat2(const char* label, float* v1, float* v2, const char* format, String flags)
	{
		float floats[2] = {*v1, *v2};
		bool changed = ImGui::InputFloat2(label, floats, format, getInputTextCombinedFlags(flags));
		*v1 = floats[0];
		*v2 = floats[1];
		return changed;
	}

	bool InputInt(const char* label, int* v, int step, int step_fast, String flags)
	{
		return ImGui::InputInt(label, v, step, step_fast, getInputTextCombinedFlags(flags));
	}

	bool InputInt2(const char* label, int* v1, int* v2, String flags)
	{
		int ints[2] = {*v1, *v2};
		bool changed = ImGui::InputInt2(label, ints, getInputTextCombinedFlags(flags));
		*v1 = ints[0];
		*v2 = ints[1];
		return changed;
	}

	bool SliderFloat(const char* label, float* v, float v_min, float v_max, const char* format, String flags)
	{
		return ImGui::SliderFloat(label, v, v_min, v_max, format, getSliderCombinedFlags(flags));
	}

	bool SliderFloat2(const char* label, float* v1, float* v2, float v_min, float v_max, const char* display_format, String flags)
	{
		float floats[2] = {*v1, *v2};
		bool changed = ImGui::SliderFloat2(label, floats, v_min, v_max, display_format, getSliderCombinedFlags(flags));
		*v1 = floats[0];
		*v2 = floats[1];
		return changed;
	}

	bool SliderInt(const char* label, int* v, int v_min, int v_max, const char* format, String flags)
	{
		return ImGui::SliderInt(label, v, v_min, v_max, format, getSliderCombinedFlags(flags));
	}

	bool SliderInt2(const char* label, int* v1, int* v2, int v_min, int v_max, const char* display_format, String flags)
	{
		int ints[2] = {*v1, *v2};
		bool changed = ImGui::SliderInt2(label, ints, v_min, v_max, display_format, getSliderCombinedFlags(flags));
		*v1 = ints[0];
		*v2 = ints[1];
		return changed;
	}
	
	bool DragFloatRange2(const char* label, float* v_current_min, float* v_current_max, float v_speed, float v_min, float v_max, const char* format, const char* format_max, String flags)
	{
		return ImGui::DragFloatRange2(label, v_current_min, v_current_max, v_speed, v_min, v_max, format, format_max, getSliderCombinedFlags(flags));
	}

	bool DragIntRange2(const char* label, int* v_current_min, int* v_current_max, float v_speed, int v_min, int v_max, const char* format, const char* format_max, String flags)
	{
		return ImGui::DragIntRange2(label, v_current_min, v_current_max, v_speed, v_min, v_max, format, format_max, getSliderCombinedFlags(flags));
	}

	bool VSliderFloat(const char* label, const ImVec2& size, float* v, float v_min, float v_max, const char* format, String flags)
	{
		return ImGui::VSliderFloat(label, size, v, v_min, v_max, format, getSliderCombinedFlags(flags));
	}

	bool VSliderInt(const char* label, const ImVec2& size, int* v, int v_min, int v_max, const char* format, String flags)
	{
		return ImGui::VSliderInt(label, size, v, v_min, v_max, format, getSliderCombinedFlags(flags));
	}

	bool ColorEdit3(const char* label, Color3& color3)
	{
		Vec3 vec3 = color3.toVec3();
		bool result = ImGui::ColorEdit3(label, vec3);
		color3 = vec3;
		return result;
	}

	bool ColorEdit4(const char* label, Color& color, bool show_alpha)
	{
		Vec4 vec4 = color.toVec4();
		bool result = ImGui::ColorEdit4(label, vec4);
		color = vec4;
		return result;
	}

	void Image(String clipStr, const Vec2& size, Color tint_col, Color border_col)
	{
		Texture2D* tex = nullptr;
		Rect rect;
		std::tie(tex, rect) = SharedClipCache.loadTexture(clipStr);
		union
		{
			ImTextureID ptr;
			struct { bgfx::TextureHandle handle; } s;
		} texture;
		texture.s.handle = tex->getHandle();
		Vec2 texSize{s_cast<float>(tex->getWidth()), s_cast<float>(tex->getHeight())};
		Vec2 uv0 = rect.origin / texSize;
		Vec2 uv1 = (rect.origin + Vec2{1,1} * rect.size) / texSize;
		ImGui::Image(texture.ptr, size, uv0, uv1, tint_col.toVec4(), border_col.toVec4());
	}

	bool ImageButton(String clipStr, const Vec2& size, int frame_padding, Color bg_col, Color tint_col)
	{
		Texture2D* tex = nullptr;
		Rect rect;
		std::tie(tex, rect) = SharedClipCache.loadTexture(clipStr);
		union
		{
			ImTextureID ptr;
			struct { bgfx::TextureHandle handle; } s;
		} texture;
		texture.s.handle = tex->getHandle();
		Vec2 texSize{s_cast<float>(tex->getWidth()), s_cast<float>(tex->getHeight())};
		Vec2 uv0 = rect.origin / texSize;
		Vec2 uv1 = (rect.origin + Vec2{1,1} * rect.size) / texSize;
		return ImGui::ImageButton(texture.ptr, size, uv0, uv1, frame_padding, bg_col.toVec4(), tint_col.toVec4());
	}

	bool ColorButton(const char* desc_id, Color col, String flags, const Vec2& size)
	{
		return ImGui::ColorButton(desc_id, col.toVec4(), getColorEditFlags(flags), size);
	}

	void Columns(int count, bool border)
	{
		ImGui::Columns(count, nullptr, border);
	}

	void Columns(int count, bool border, const char* id)
	{
		ImGui::Columns(count, id, border);
	}

	bool BeginTable(const char* str_id, int column, String flags, const Vec2& outer_size, float inner_width)
	{
		return ImGui::BeginTable(str_id, column, getTableCombinedFlags(flags), outer_size, inner_width);
	}

	void TableNextRow(String row_flags, float min_row_height)
	{
		ImGui::TableNextRow(getTableRowCombinedFlags(row_flags), min_row_height);
	}

	void TableSetupColumn(const char* label, String flags, float init_width_or_weight, ImU32 user_id)
	{
		ImGui::TableSetupColumn(label, getTableColumnCombinedFlags(flags), init_width_or_weight, user_id);
	}

	void SetStyleVar(String name, const Vec2& var)
	{
		ImGuiStyle& style = ImGui::GetStyle();
		switch (Switch::hash(name))
		{
			case "WindowPadding"_hash: style.WindowPadding = var; break;
			case "WindowMinSize"_hash: style.WindowMinSize = var; break;
			case "WindowTitleAlign"_hash: style.WindowTitleAlign = var; break;
			case "FramePadding"_hash: style.FramePadding = var; break;
			case "ItemSpacing"_hash: style.ItemSpacing = var; break;
			case "ItemInnerSpacing"_hash: style.ItemInnerSpacing = var; break;
			case "TouchExtraPadding"_hash: style.TouchExtraPadding = var; break;
			case "ButtonTextAlign"_hash: style.ButtonTextAlign = var; break;
			case "DisplayWindowPadding"_hash: style.DisplayWindowPadding = var; break;
			case "DisplaySafeAreaPadding"_hash: style.DisplaySafeAreaPadding = var; break;
			default:
				AssertIf(true, "ImGui style var name \"{}\" is invalid.", name);
				break;
		}
	}

	void SetStyleVar(String name, float var)
	{
		ImGuiStyle& style = ImGui::GetStyle();
		switch (Switch::hash(name))
		{
			case "Alpha"_hash: style.Alpha = var; break;
			case "WindowRounding"_hash: style.WindowRounding = var; break;
			case "FrameRounding"_hash: style.FrameRounding = var; break;
			case "FrameBorderSize"_hash: style.FrameBorderSize = var; break;
			case "IndentSpacing"_hash: style.IndentSpacing = var; break;
			case "ColumnsMinSpacing"_hash: style.ColumnsMinSpacing = var; break;
			case "ScrollbarSize"_hash: style.ScrollbarSize = var; break;
			case "ScrollbarRounding"_hash: style.ScrollbarRounding = var; break;
			case "GrabMinSize"_hash: style.GrabMinSize = var; break;
			case "GrabRounding"_hash: style.GrabRounding = var; break;
			case "CurveTessellationTol"_hash: style.CurveTessellationTol = var; break;
			default:
				AssertIf(true, "ImGui style var name \"{}\" is invalid.", name);
				break;
		}
	}

	void SetStyleVar(String name, bool var)
	{
		ImGuiStyle& style = ImGui::GetStyle();
		switch (Switch::hash(name))
		{
			case "AntiAliasedLines"_hash: style.AntiAliasedLines = var; break;
			case "AntiAliasedFill"_hash: style.AntiAliasedFill = var; break;
			default:
				AssertIf(true, "ImGui style var name \"{}\" is invalid.", name);
				break;
		}
	}

	void SetStyleColor(String name, Color color)
	{
		ImGuiCol_ index = getColorIndex(name);
		ImGuiStyle& style = ImGui::GetStyle();
		style.Colors[index] = color.toVec4();
	}

	ImGuiSliderFlags_ getSliderFlag(String flag)
	{
		switch (Switch::hash(flag))
		{
		case "None"_hash:
			return ImGuiSliderFlags_None;
		case "AlwaysClamp"_hash:
			return ImGuiSliderFlags_AlwaysClamp;
		case "Logarithmic"_hash:
			return ImGuiSliderFlags_Logarithmic;
		case "NoRoundToFormat"_hash:
			return ImGuiSliderFlags_NoRoundToFormat;
		case "NoInput"_hash:
			return ImGuiSliderFlags_NoInput;
		case ""_hash: return ImGuiSliderFlags_None;
		default:
			AssertIf(true, "ImGui slider flag named \"{}\" is invalid.", flag);
			break;
		}
		return ImGuiSliderFlags_None;
	}

	Uint32 getSliderCombinedFlags(String flags)
	{
		auto tokens = flags.split("|"_slice);
		Uint32 result = 0;
		for (const auto& token : tokens)
		{
			result |= getSliderFlag(token);
		}
		return result;
	}

	ImGuiWindowFlags_ getWindowFlags(String style)
	{
		switch (Switch::hash(style))
		{
			case "NoTitleBar"_hash: return ImGuiWindowFlags_NoTitleBar;
			case "NoResize"_hash: return ImGuiWindowFlags_NoResize;
			case "NoMove"_hash: return ImGuiWindowFlags_NoMove;
			case "NoScrollbar"_hash: return ImGuiWindowFlags_NoScrollbar;
			case "NoScrollWithMouse"_hash: return ImGuiWindowFlags_NoScrollWithMouse;
			case "NoCollapse"_hash: return ImGuiWindowFlags_NoCollapse;
			case "AlwaysAutoResize"_hash: return ImGuiWindowFlags_AlwaysAutoResize;
			case "NoSavedSettings"_hash: return ImGuiWindowFlags_NoSavedSettings;
			case "NoInputs"_hash: return ImGuiWindowFlags_NoInputs;
			case "MenuBar"_hash: return ImGuiWindowFlags_MenuBar;
			case "HorizontalScrollbar"_hash: return ImGuiWindowFlags_HorizontalScrollbar;
			case "NoFocusOnAppearing"_hash: return ImGuiWindowFlags_NoFocusOnAppearing;
			case "NoBringToFrontOnFocus"_hash: return ImGuiWindowFlags_NoBringToFrontOnFocus;
			case "AlwaysVerticalScrollbar"_hash: return ImGuiWindowFlags_AlwaysVerticalScrollbar;
			case "AlwaysHorizontalScrollbar"_hash: return ImGuiWindowFlags_AlwaysHorizontalScrollbar;
			case "AlwaysUseWindowPadding"_hash: return ImGuiWindowFlags_AlwaysUseWindowPadding;
			case ""_hash: return ImGuiWindowFlags_(0);
			default:
				AssertIf(true, "ImGui window flag named \"{}\" is invalid.", style);
				break;
		}
		return ImGuiWindowFlags_(0);
	}

	Uint32 getWindowCombinedFlags(String flags)
	{
		auto tokens = flags.split("|"_slice);
		Uint32 result = 0;
		for (const auto& token : tokens)
		{
			result |= getWindowFlags(token);
		}
		return result;
	}

	ImGuiInputTextFlags_ getInputTextFlag(String flag)
	{
		switch (Switch::hash(flag))
		{
			case "CharsDecimal"_hash: return ImGuiInputTextFlags_CharsDecimal;
			case "CharsHexadecimal"_hash: return ImGuiInputTextFlags_CharsHexadecimal;
			case "CharsUppercase"_hash: return ImGuiInputTextFlags_CharsUppercase;
			case "CharsNoBlank"_hash: return ImGuiInputTextFlags_CharsNoBlank;
			case "AutoSelectAll"_hash: return ImGuiInputTextFlags_AutoSelectAll;
			case "EnterReturnsTrue"_hash: return ImGuiInputTextFlags_EnterReturnsTrue;
			case "CallbackCompletion"_hash: return ImGuiInputTextFlags_CallbackCompletion;
			case "CallbackHistory"_hash: return ImGuiInputTextFlags_CallbackHistory;
			case "CallbackAlways"_hash: return ImGuiInputTextFlags_CallbackAlways;
			case "CallbackCharFilter"_hash: return ImGuiInputTextFlags_CallbackCharFilter;
			case "AllowTabInput"_hash: return ImGuiInputTextFlags_AllowTabInput;
			case "CtrlEnterForNewLine"_hash: return ImGuiInputTextFlags_CtrlEnterForNewLine;
			case "NoHorizontalScroll"_hash: return ImGuiInputTextFlags_NoHorizontalScroll;
			case "AlwaysOverwrite"_hash: return ImGuiInputTextFlags_AlwaysOverwrite;
			case "ReadOnly"_hash: return ImGuiInputTextFlags_ReadOnly;
			case "Password"_hash: return ImGuiInputTextFlags_Password;
			case ""_hash: return ImGuiInputTextFlags_(0);
			default:
				AssertIf(true, "ImGui input text flag named \"{}\" is invalid.", flag);
				return ImGuiInputTextFlags_(0);
		}
	}

	Uint32 getInputTextCombinedFlags(String flags)
	{
		auto tokens = flags.split("|"_slice);
		Uint32 result = 0;
		for (const auto& token : tokens)
		{
			result |= getInputTextFlag(token);
		}
		return result;
	}

	ImGuiTreeNodeFlags_ getTreeNodeFlags(String flag)
	{
		switch (Switch::hash(flag))
		{
			case "Selected"_hash: return ImGuiTreeNodeFlags_Selected;
			case "Framed"_hash: return ImGuiTreeNodeFlags_Framed;
			case "AllowItemOverlap"_hash: return ImGuiTreeNodeFlags_AllowItemOverlap;
			case "NoTreePushOnOpen"_hash: return ImGuiTreeNodeFlags_NoTreePushOnOpen;
			case "NoAutoOpenOnLog"_hash: return ImGuiTreeNodeFlags_NoAutoOpenOnLog;
			case "DefaultOpen"_hash: return ImGuiTreeNodeFlags_DefaultOpen;
			case "OpenOnDoubleClick"_hash: return ImGuiTreeNodeFlags_OpenOnDoubleClick;
			case "OpenOnArrow"_hash: return ImGuiTreeNodeFlags_OpenOnArrow;
			case "Leaf"_hash: return ImGuiTreeNodeFlags_Leaf;
			case "Bullet"_hash: return ImGuiTreeNodeFlags_Bullet;
			case "CollapsingHeader"_hash: return ImGuiTreeNodeFlags_CollapsingHeader;
			case ""_hash: return ImGuiTreeNodeFlags_(0);
			default:
				AssertIf(true, "ImGui tree node flag named \"{}\" is invalid.", flag);
				return ImGuiTreeNodeFlags_(0);
		}
	}

	ImGuiSelectableFlags_ getSelectableFlags(String flag)
	{
		switch (Switch::hash(flag))
		{
			case "DontClosePopups"_hash: return ImGuiSelectableFlags_DontClosePopups;
			case "SpanAllColumns"_hash: return ImGuiSelectableFlags_SpanAllColumns;
			case "AllowDoubleClick"_hash: return ImGuiSelectableFlags_AllowDoubleClick;
			case ""_hash: return ImGuiSelectableFlags_(0);
			default:
				AssertIf(true, "ImGui selectable flag named \"{}\" is invalid.", flag);
				return ImGuiSelectableFlags_(0);
		}
	}

	ImGuiCol_ getColorIndex(String col)
	{
		switch (Switch::hash(col))
		{
			case "Text"_hash: return ImGuiCol_Text;
			case "TextDisabled"_hash: return ImGuiCol_TextDisabled;
			case "WindowBg"_hash: return ImGuiCol_WindowBg;
			case "PopupBg"_hash: return ImGuiCol_PopupBg;
			case "Border"_hash: return ImGuiCol_Border;
			case "BorderShadow"_hash: return ImGuiCol_BorderShadow;
			case "FrameBg"_hash: return ImGuiCol_FrameBg;
			case "FrameBgHovered"_hash: return ImGuiCol_FrameBgHovered;
			case "FrameBgActive"_hash: return ImGuiCol_FrameBgActive;
			case "TitleBg"_hash: return ImGuiCol_TitleBg;
			case "TitleBgCollapsed"_hash: return ImGuiCol_TitleBgCollapsed;
			case "TitleBgActive"_hash: return ImGuiCol_TitleBgActive;
			case "MenuBarBg"_hash: return ImGuiCol_MenuBarBg;
			case "ScrollbarBg"_hash: return ImGuiCol_ScrollbarBg;
			case "ScrollbarGrab"_hash: return ImGuiCol_ScrollbarGrab;
			case "ScrollbarGrabHovered"_hash: return ImGuiCol_ScrollbarGrabHovered;
			case "ScrollbarGrabActive"_hash: return ImGuiCol_ScrollbarGrabActive;
			case "CheckMark"_hash: return ImGuiCol_CheckMark;
			case "SliderGrabActive"_hash: return ImGuiCol_SliderGrabActive;
			case "Button"_hash: return ImGuiCol_Button;
			case "ButtonHovered"_hash: return ImGuiCol_ButtonHovered;
			case "ButtonActive"_hash: return ImGuiCol_ButtonActive;
			case "Header"_hash: return ImGuiCol_Header;
			case "HeaderHovered"_hash: return ImGuiCol_HeaderHovered;
			case "HeaderActive"_hash: return ImGuiCol_HeaderActive;
			case "Separator"_hash: return ImGuiCol_Separator;
			case "SeparatorHovered"_hash: return ImGuiCol_SeparatorHovered;
			case "SeparatorActive"_hash: return ImGuiCol_SeparatorActive;
			case "ResizeGrip"_hash: return ImGuiCol_ResizeGrip;
			case "ResizeGripHovered"_hash: return ImGuiCol_ResizeGripHovered;
			case "ResizeGripActive"_hash: return ImGuiCol_ResizeGripActive;
			case "PlotLines"_hash: return ImGuiCol_PlotLines;
			case "PlotLinesHovered"_hash: return ImGuiCol_PlotLinesHovered;
			case "PlotHistogram"_hash: return ImGuiCol_PlotHistogram;
			case "PlotHistogramHovered"_hash: return ImGuiCol_PlotHistogramHovered;
			case "TextSelectedBg"_hash: return ImGuiCol_TextSelectedBg;
			case "ModalWindowDimBg"_hash: return ImGuiCol_ModalWindowDimBg;
			default:
				AssertIf(true, "ImGui color index named \"{}\" is invalid.", col);
				return ImGuiCol_(0);
		}
	}

	ImGuiColorEditFlags_ getColorEditFlags(String mode)
	{
		switch (Switch::hash(mode))
		{
			case "RGB"_hash: return ImGuiColorEditFlags_DisplayRGB;
			case "HSV"_hash: return ImGuiColorEditFlags_DisplayHSV;
			case "HEX"_hash: return ImGuiColorEditFlags_DisplayHex;
			case ""_hash: return ImGuiColorEditFlags_None;
			default:
				AssertIf(true, "ImGui color edit flag named \"{}\" is invalid.", mode);
				return ImGuiColorEditFlags_None;
		}
	}

	ImGuiCond_ getSetCond(String cond)
	{
		switch (Switch::hash(cond))
		{
			case "Always"_hash: return ImGuiCond_Always;
			case "Once"_hash: return ImGuiCond_Once;
			case "FirstUseEver"_hash: return ImGuiCond_FirstUseEver;
			case "Appearing"_hash: return ImGuiCond_Appearing;
			case ""_hash: return ImGuiCond_(0);
			default:
				AssertIf(true, "ImGui set cond named \"{}\" is invalid.", cond);
				return ImGuiCond_(0);
		}
	}

	ImGuiPopupFlags getPopupFlag(String flag)
	{
		switch (Switch::hash(flag))
		{
			case "None"_hash: return ImGuiPopupFlags_None;
			case "MouseButtonLeft"_hash: return ImGuiPopupFlags_MouseButtonLeft;
			case "MouseButtonRight"_hash: return ImGuiPopupFlags_MouseButtonRight;
			case "MouseButtonMiddle"_hash: return ImGuiPopupFlags_MouseButtonMiddle;
			case "NoOpenOverExistingPopup"_hash: return ImGuiPopupFlags_NoOpenOverExistingPopup;
			case "NoOpenOverItems"_hash: return ImGuiPopupFlags_NoOpenOverItems;
			case "AnyPopupId"_hash: return ImGuiPopupFlags_AnyPopupId;
			case "AnyPopupLevel"_hash: return ImGuiPopupFlags_AnyPopupLevel;
			case "AnyPopup"_hash: return ImGuiPopupFlags_AnyPopup;
			case ""_hash: return ImGuiPopupFlags_MouseButtonRight;
			default:
				AssertIf(true, "ImGui popup flag named \"{}\" is invalid.", flag);
				return ImGuiPopupFlags_None;
		}
	}

	Uint32 getPopupCombinedFlags(String flags)
	{
		auto tokens = flags.split("|"_slice);
		Uint32 result = 0;
		for (const auto& token : tokens)
		{
			result |= getPopupFlag(token);
		}
		return result;
	}

	ImGuiTableFlags_ getTableFlags(String flag)
	{
		switch (Switch::hash(flag))
		{
			case "Resizable"_hash: return ImGuiTableFlags_Resizable;
			case "Reorderable"_hash: return ImGuiTableFlags_Reorderable;
			case "Hideable"_hash: return ImGuiTableFlags_Hideable;
			case "Sortable"_hash: return ImGuiTableFlags_Sortable;
			case "NoSavedSettings"_hash: return ImGuiTableFlags_NoSavedSettings;
			case "ContextMenuInBody"_hash: return ImGuiTableFlags_ContextMenuInBody;
			case "RowBg"_hash: return ImGuiTableFlags_RowBg;
			case "BordersInnerH"_hash: return ImGuiTableFlags_BordersInnerH;
			case "BordersOuterH"_hash: return ImGuiTableFlags_BordersOuterH;
			case "BordersInnerV"_hash: return ImGuiTableFlags_BordersInnerV;
			case "BordersOuterV"_hash: return ImGuiTableFlags_BordersOuterV;
			case "BordersH"_hash: return ImGuiTableFlags_BordersH;
			case "BordersV"_hash: return ImGuiTableFlags_BordersV;
			case "BordersInner"_hash: return ImGuiTableFlags_BordersInner;
			case "BordersOuter"_hash: return ImGuiTableFlags_BordersOuter;
			case "Borders"_hash: return ImGuiTableFlags_Borders;
			case "NoBordersInBody"_hash: return ImGuiTableFlags_NoBordersInBody;
			case "NoBordersInBodyUntilResize"_hash: return ImGuiTableFlags_NoBordersInBodyUntilResize;
			case "SizingFixedFit"_hash: return ImGuiTableFlags_SizingFixedFit;
			case "SizingFixedSame"_hash: return ImGuiTableFlags_SizingFixedSame;
			case "SizingStretchProp"_hash: return ImGuiTableFlags_SizingStretchProp;
			case "SizingStretchSame"_hash: return ImGuiTableFlags_SizingStretchSame;
			case "NoHostExtendX"_hash: return ImGuiTableFlags_NoHostExtendX;
			case "NoHostExtendY"_hash: return ImGuiTableFlags_NoHostExtendY;
			case "NoKeepColumnsVisible"_hash: return ImGuiTableFlags_NoKeepColumnsVisible;
			case "PreciseWidths"_hash: return ImGuiTableFlags_PreciseWidths;
			case "NoClip"_hash: return ImGuiTableFlags_NoClip;
			case "PadOuterX"_hash: return ImGuiTableFlags_PadOuterX;
			case "NoPadOuterX"_hash: return ImGuiTableFlags_NoPadOuterX;
			case "NoPadInnerX"_hash: return ImGuiTableFlags_NoPadInnerX;
			case "ScrollX"_hash: return ImGuiTableFlags_ScrollX;
			case "ScrollY"_hash: return ImGuiTableFlags_ScrollY;
			case "SortMulti"_hash: return ImGuiTableFlags_SortMulti;
			case ""_hash: return ImGuiTableFlags_None;
			default:
				AssertIf(true, "ImGui table flag named \"{}\" is invalid.", flag);
				return ImGuiTableFlags_None;
		}
		return ImGuiTableFlags_None;
	}

	Uint32 getTableCombinedFlags(String flags)
	{
		auto tokens = flags.split("|"_slice);
		Uint32 result = 0;
		for (const auto& token : tokens)
		{
			result |= getTableFlags(token);
		}
		return result;
	}

	ImGuiTableRowFlags_ getTableRowFlags(String flag)
	{
		switch (Switch::hash(flag))
		{
			case "Headers"_hash: return ImGuiTableRowFlags_Headers;
			case ""_hash: return ImGuiTableRowFlags_None;
			default:
				AssertIf(true, "ImGui table row flag named \"{}\" is invalid.", flag);
				return ImGuiTableRowFlags_None;
		}
		return ImGuiTableRowFlags_None;
	}

	Uint32 getTableRowCombinedFlags(String flags)
	{
		auto tokens = flags.split("|"_slice);
		Uint32 result = 0;
		for (const auto& token : tokens)
		{
			result |= getTableRowFlags(token);
		}
		return result;
	}

	ImGuiTableColumnFlags_ getTableColumnFlags(String flag)
	{
		switch (Switch::hash(flag))
		{
			case "DefaultHide"_hash: return ImGuiTableColumnFlags_DefaultHide;
			case "DefaultSort"_hash: return ImGuiTableColumnFlags_DefaultSort;
			case "WidthStretch"_hash: return ImGuiTableColumnFlags_WidthStretch;
			case "WidthFixed"_hash: return ImGuiTableColumnFlags_WidthFixed;
			case "NoResize"_hash: return ImGuiTableColumnFlags_NoResize;
			case "NoReorder"_hash: return ImGuiTableColumnFlags_NoReorder;
			case "NoHide"_hash: return ImGuiTableColumnFlags_NoHide;
			case "NoClip"_hash: return ImGuiTableColumnFlags_NoClip;
			case "NoSort"_hash: return ImGuiTableColumnFlags_NoSort;
			case "NoSortAscending"_hash: return ImGuiTableColumnFlags_NoSortAscending;
			case "NoSortDescending"_hash: return ImGuiTableColumnFlags_NoSortDescending;
			case "NoHeaderWidth"_hash: return ImGuiTableColumnFlags_NoHeaderWidth;
			case "PreferSortAscending"_hash: return ImGuiTableColumnFlags_PreferSortAscending;
			case "PreferSortDescending"_hash: return ImGuiTableColumnFlags_PreferSortDescending;
			case "IndentEnable"_hash: return ImGuiTableColumnFlags_IndentEnable;
			case "IndentDisable"_hash: return ImGuiTableColumnFlags_IndentDisable;
			case "IsEnabled"_hash: return ImGuiTableColumnFlags_IsEnabled;
			case "IsVisible"_hash: return ImGuiTableColumnFlags_IsVisible;
			case "IsSorted"_hash: return ImGuiTableColumnFlags_IsSorted;
			case "IsHovered"_hash: return ImGuiTableColumnFlags_IsHovered;
			case ""_hash: return ImGuiTableColumnFlags_None;
			default:
				AssertIf(true, "ImGui table column flag named \"{}\" is invalid.", flag);
				return ImGuiTableColumnFlags_None;
		}
		return ImGuiTableColumnFlags_None;
	}

	Uint32 getTableColumnCombinedFlags(String flags)
	{
		auto tokens = flags.split("|"_slice);
		Uint32 result = 0;
		for (const auto& token : tokens)
		{
			result |= getTableColumnFlags(token);
		}
		return result;
	}
} }
