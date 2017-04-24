/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Dorothy.h"
#include "Lua/ToLua/tolua++.h"
#include "LuaManual.h"

NS_DOROTHY_BEGIN

/* Event */

int dora_emit(lua_State* L)
{
	int top = lua_gettop(L);
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isstring(L, 1, 0, &tolua_err))
	{
		tolua_error(L, "#vinvalid type in variable assignment", &tolua_err);
	}
#endif
	Slice name = tolua_toslice(L, 1, nullptr);
	LuaEventArgs::send(name, top - 1);
	return 0;
}

/* Content */

void __Content_loadFile(lua_State* L, Content* self, String filename)
{
	OwnArray<Uint8> data = self->loadFile(filename);
	if (data) lua_pushlstring(L, r_cast<char*>(data.get()), data.size());
	else lua_pushnil(L);
}

void __Content_getDirs(lua_State* L, Content* self, String path)
{
	auto dirs = self->getDirs(path);
	lua_createtable(L, s_cast<int>(dirs.size()), 0);
	for (int i = 0; i < s_cast<int>(dirs.size()); i++)
	{
		lua_pushstring(L, dirs[i].c_str());
		lua_rawseti(L, -2, i+1);
	}
}

void __Content_getFiles(lua_State* L, Content* self, String path)
{
	auto dirs = self->getFiles(path);
	lua_createtable(L, s_cast<int>(dirs.size()), 0);
	for (int i = 0; i < s_cast<int>(dirs.size()); i++)
	{
		lua_pushstring(L, dirs[i].c_str());
		lua_rawseti(L, -2, i+1);
	}
}

void Content_setSearchPaths(Content* self, Slice paths[], int length)
{
	vector<string> searchPaths(length);
	for (int i = 0; i < length; i++)
	{
		searchPaths[i] = paths[i];
	}
	self->setSearchPaths(searchPaths);
}

/* Node */

int Node_emit(lua_State* L)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Node", 0, &tolua_err) ||
		!tolua_isstring(L, 2, 0, &tolua_err))
	{
		goto tolua_lerror;
	}
	else
#endif
	{
		Node* self = r_cast<Node*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'CCNode_emit'", NULL);
#endif
		Slice name = tolua_toslice(L, 2, 0);
		int top = lua_gettop(L);
		LuaEventArgs luaEvent(name, top - 2);
		self->emit(&luaEvent);
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
		!tolua_isusertype(L, 1, "Node", 0, &tolua_err) ||
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
		if (!self) tolua_error(L, "invalid 'self' in function 'CCNode_slot'", NULL);
#endif
		Slice name = tolua_toslice(L, 2, 0);
		if (lua_isfunction(L, 3))
		{
			int handler = tolua_ref_function(L, 3);
			self->slot(name, LuaFunction(handler));
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
	if (!tolua_isusertype(L, 1, "Node", 0, &tolua_err) ||
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
			if (lua_isfunction(L, 3)) // set
			{
				int handler = tolua_ref_function(L, 3);
				Listener* listener =self->gslot(name, LuaFunction(handler));
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

bool Cache::load(String filename)
{
	string ext = filename.getFileExtension();
	if (!ext.empty())
	{
		switch (Switch::hash(ext))
		{
			case "clip"_hash:
				return SharedClipCache.load(filename);
			case "frame"_hash:
				return SharedFrameCache.load(filename);
			case "model"_hash:
				return SharedModelCache.load(filename);
			case "par"_hash:
				return SharedParticleCache.load(filename);
			case "png"_hash:
			case "dds"_hash:
			case "pvr"_hash:
			case "ktx"_hash:
				return SharedTextureCache.load(filename);
			case "bin"_hash:
				return SharedShaderCache.load(filename);
			case "wav"_hash:
			case "ogg"_hash:
				return SharedSoundCache.load(filename);
		}
	}
	return false;
}

void Cache::loadAsync(String filename, const function<void()>& callback)
{
	string ext = filename.getFileExtension();
	if (!ext.empty())
	{
		switch (Switch::hash(ext))
		{
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
			case "png"_hash:
			case "dds"_hash:
			case "pvr"_hash:
			case "ktx"_hash:
				SharedTextureCache.loadAsync(filename, [callback](Texture2D*) { callback(); });
				break;
			case "bin"_hash:
				SharedShaderCache.loadAsync(filename, [callback](Shader*) { callback(); });
				break;
			case "wav"_hash:
			case "ogg"_hash:
				SharedSoundCache.loadAsync(filename, [callback](SoundFile*) { callback(); });
				break;
		}
	}
}

void Cache::update(String filename, String content)
{
	string ext = filename.getFileExtension();
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
		}
	}
}

void Cache::update(String filename, Texture2D* texture)
{
	SharedTextureCache.update(filename, texture);
}

bool Cache::unload(String name)
{
	string ext = name.getFileExtension();
	if (!ext.empty())
	{
		switch (Switch::hash(ext))
		{
			case "clip"_hash:
				return SharedClipCache.unload(name);
			case "frame"_hash:
				return SharedFrameCache.unload(name);
			case "model"_hash:
				return SharedModelCache.unload(name);
			case "par"_hash:
				return SharedParticleCache.unload(name);
			case "png"_hash:
			case "dds"_hash:
			case "pvr"_hash:
			case "ktx"_hash:
				return SharedTextureCache.unload(name);
			case "bin"_hash:
				return SharedShaderCache.unload(name);
			case "wav"_hash:
			case "ogg"_hash:
				return SharedSoundCache.unload(name);
		}
	}
	else
	{
		switch (Switch::hash(name))
		{
			case "Texture"_hash:
				return SharedTextureCache.unload();
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
				auto tokens = name.split(":");
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
	SharedFontCache.removeUnused();
	SharedSoundCache.removeUnused();
}

void Cache::removeUnused(String name)
{
	switch (Switch::hash(name))
	{
		case "Texture"_hash:
			SharedTextureCache.removeUnused();
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
	}
}

Sprite* Sprite_create(String clipStr)
{
	if (clipStr.toString().find('|') != string::npos)
	{
		return SharedClipCache.loadSprite(clipStr);
	}
	else if (clipStr.getFileExtension() == "clip"_slice)
	{
		ClipDef* def = SharedClipCache.load(clipStr);
		return Sprite::create(def->textureFile);
	}
	return Sprite::create(clipStr);
}

/* Vec2 */

Vec2* Vec2_create(float x, float y)
{
	return Mtolua_new((Vec2)({x, y}));
}

/* Size */

Size* Size_create(float width, float height)
{
	return Mtolua_new((Size)({width, height}));
}

/* BlendFunc */

BlendFunc* BlendFunc_create(Uint32 src, Uint32 dst)
{
	return Mtolua_new((BlendFunc)({src, dst}));
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
			int length = s_cast<int>(lua_objlen(L, location));
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
						case "Hide"_hash: return Hide::alloc();
						case "Show"_hash: return Show::alloc();
						case "Delay"_hash:
						{
							float duration = toNumber(L, location, 2);
							return Delay::alloc(duration);
						}
						case "Call"_hash:
						{
							lua_rawgeti(L, location, 2);
							LuaFunction callback(tolua_ref_function(L, -1));
							lua_pop(L, 1);
							return Call::alloc(callback);
						}
						case "Spawn"_hash:
						{
							vector<Own<ActionDuration>> actions(length - 1);
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
							vector<Own<ActionDuration>> actions(length - 1);
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
							luaL_error(L, "action named \"%s\" is not exist.", name.rawData());
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
	if (!tolua_isusertable(L, 1, "Action", 0, &tolua_err) ||
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

Model* Model_create(String filename)
{
	Model* model = Model::create(filename);
	model->handlers.each([](String name, AnimationHandler& handler)
	{
		handler = [name](Model* model)
		{
			model->emit("AnimationEnd"_slice, name, model);
		};
	});
	return model;
}

Vec2 Model_getKey(Model* model, String key)
{
	return model->getModelDef()->getKeyPoint(key);
}

void __Model_getClipFile(lua_State* L, String filename)
{
	ModelDef* modelDef = SharedModelCache.load(filename);
	const string& clipFile = modelDef->getClipFile();
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
		lua_pushnil(L);
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
		lua_pushnil(L);
	}
}

/* Body */

Body* Body_create(BodyDef* def, World* world, Vec2 pos, float rot)
{
	Body* body = Body::create(def, world, pos, rot);
	auto sensorAddHandler = [](Sensor* sensor, Body* body)
	{
		sensor->bodyEnter = [body](Sensor* sensor, Body* other)
		{
			body->emit("BodyEnter"_slice, other, sensor);
		};
		sensor->bodyLeave = [body](Sensor* sensor, Body* other)
		{
			body->emit("BodyLeave"_slice, other, sensor);
		};
	};
	body->eachSensor(sensorAddHandler);
	body->sensorAdded = sensorAddHandler;
	body->contactStart = [body](Body* other, const Vec2& point, const Vec2& normal)
	{
		body->emit("ContactStart"_slice, other, point, normal);
	};
	body->contactEnd = [body](Body* other, const Vec2& point, const Vec2& normal)
	{
		body->emit("ContactEnd"_slice, other, point, normal);
	};
	return body;
}

/* Dictionary */

Array* __Dictionary_getKeys(Dictionary* self)
{
	vector<Slice> keys = self->getKeys();
	Array* array = Array::create(s_cast<int>(keys.size()));
	for (size_t i = 0; i < keys.size(); i++)
	{
		array->set(s_cast<int>(i), Value::create(keys[i].toString()));
	}
	return array;
}

int Dictionary_get(lua_State* L)
{
	/* 1 self, 2 key */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Dictionary", 0, &tolua_err) || !tolua_isslice(L, 2, 0, &tolua_err))
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
		Object* value = self->get(key);
		if (value)
		{
			auto numberVal = DoraCast<ValueEx<lua_Number>>(value);
			if (numberVal)
			{
				lua_pushnumber(L, numberVal->get());
				return 1;
			}
			auto boolVal = DoraCast<ValueEx<bool>>(value);
			if (boolVal)
			{
				lua_pushboolean(L, boolVal->get() ? 1 : 0);
				return 1;
			}
			auto stringVal = DoraCast<ValueEx<string>>(value);
			if (stringVal)
			{
				tolua_pushslice(L, stringVal->get());
				return 1;
			}
			tolua_pushobject(L, value);
			return 1;
		}
		else
		{
			lua_pushnil(L);
			return 1;
		}
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Dictionary_get'.", &tolua_err);
	return 0;
#endif
}

int Dictionary_set(lua_State* L)
{
	/* 1 self, 2 key, 3 value */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Dictionary", 0, &tolua_err) || !tolua_isslice(L, 2, 0, &tolua_err))
	{
		goto tolua_lerror;
	}
#endif
    {
		Dictionary* self = r_cast<Dictionary*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Dictionary_set'", nullptr);
#endif
		Object* object = nullptr;
		if (!lua_isnil(L, 3))
		{
			if (lua_isnumber(L, 3))
			{
				object = Value::create(lua_tonumber(L, 3));
			}
			else if (lua_isboolean(L, 3))
			{
				object = Value::create(lua_toboolean(L, 3) != 0);
			}
			else if (lua_isstring(L, 3))
			{
				object = Value::create(tolua_toslice(L, 3, nullptr).toString());
			}
			else if (tolua_isobject(L, 3))
			{
				object = s_cast<Object*>(tolua_tousertype(L, 3, 0));
			}
#ifndef TOLUA_RELEASE
			else
			{
				tolua_error(L, "Dictionary can only store number, boolean, string and Object.", nullptr);
			}
#endif
		}
		Slice key = tolua_toslice(L, 2, nullptr);
		if (object) self->set(key, object);
		else self->remove(key);
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror :
	tolua_error(L, "#ferror in function 'Dictionary_set'.", &tolua_err);
	return 0;
#endif
}

/* Array */

void Array_swap(Array* self, int indexA, int indexB)
{
	self->swap(indexA - 1, indexB - 1);
}

int Array_index(Array* self, Object* object)
{
	return self->index(object) + 1;
}

void Array_set(Array* self, int index, Object* object)
{
	self->set(index - 1, object);
}

Object* Array_get(Array* self, int index)
{
	return self->get(index - 1);
}

void Array_insert(Array* self, int index, Object* object)
{
	self->insert(index - 1, object);
}

bool Array_removeAt(Array* self, int index)
{
	return self->removeAt(index - 1);
}

bool Array_fastRemoveAt(Array* self, int index)
{
	return self->fastRemoveAt(index - 1);
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
	memcpy(_data.data(), str.begin(), length);
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

NS_DOROTHY_END

using namespace Dorothy;

/* ImGui */

namespace ImGui { namespace Binding
{
	void LoadFontTTF(String ttfFontFile, int fontSize, String glyphRanges)
	{
		SharedImGUI.loadFontTTF(ttfFontFile, fontSize, glyphRanges);
	}

	void ShowStats()
	{
		SharedImGUI.showStats();
	}

	void ShowLog()
	{
		SharedImGUI.showLog();
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
		ImGui::SetNextWindowPosCenter(getSetCond(setCond));
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

	void ColorEditMode(String colorEditMode)
	{
		ImGui::ColorEditMode(getColorEditMode(colorEditMode));
	}

	bool InputText(const char* label, Buffer* buffer, String inputTextFlags)
	{
		if (!buffer) return false;
		return ImGui::InputText(label, buffer->get(), buffer->size(), getInputTextFlags(inputTextFlags));
	}

	bool InputTextMultiline(const char* label, Buffer* buffer, const Vec2& size, String inputTextFlags)
	{
		if (!buffer) return false;
		return ImGui::InputTextMultiline(label, buffer->get(), buffer->size(), size, getInputTextFlags(inputTextFlags));
	}

	bool InputFloat(const char* label, float* v, float step, float step_fast, int decimal_precision, String inputTextFlags)
	{
		return ImGui::InputFloat(label, v, step, step_fast, decimal_precision, getInputTextFlags(inputTextFlags));
	}

	bool InputInt(const char* label, int* v, int step, int step_fast, String inputTextFlags)
	{
		return ImGui::InputInt(label, v, step, step_fast, getInputTextFlags(inputTextFlags));
	}

	bool TreeNodeEx(const char* label, String treeNodeFlags)
	{
		return ImGui::TreeNodeEx(label, getTreeNodeFlags(treeNodeFlags));
	}

	void SetNextTreeNodeOpen(bool is_open, String setCond)
	{
		ImGui::SetNextTreeNodeOpen(is_open, getSetCond(setCond));
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
		return ImGui::BeginPopupModal(name, nullptr, getWindowFlags(windowsFlags));
	}

	bool BeginPopupModal(const char* name, bool* p_open, String windowsFlags)
	{
		return ImGui::BeginPopupModal(name, p_open, getWindowFlags(windowsFlags));
	}

	bool BeginChildFrame(ImGuiID id, const Vec2& size, String windowsFlags)
	{
		return ImGui::BeginChildFrame(id, size, getWindowFlags(windowsFlags));
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
			case "ChildWindowRounding"_hash: styleVar = ImGuiStyleVar_ChildWindowRounding; break;
			case "FrameRounding"_hash: styleVar = ImGuiStyleVar_FrameRounding; break;
			case "IndentSpacing"_hash: styleVar = ImGuiStyleVar_IndentSpacing; break;
			case "GrabMinSize"_hash: styleVar = ImGuiStyleVar_GrabMinSize; break;
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

	bool DragFloat2(const char* label, Vec2& v, float v_speed, float v_min, float v_max, const char* display_format, float power)
	{
		return ImGui::DragFloat2(label, &v.x, v_speed, v_min, v_max, display_format, power);
	}

	bool DragInt2(const char* label, Vec2& v, float v_speed, int v_min, int v_max, const char* display_format)
	{
		int ints[2] = {s_cast<int>(v.x), s_cast<int>(v.y)};
		bool changed = ImGui::DragInt2(label, ints, v_speed, v_min, v_max, display_format);
		v.x = s_cast<float>(ints[0]);
		v.y = s_cast<float>(ints[1]);
		return changed;
	}

	bool InputFloat2(const char* label, Vec2& v, int decimal_precision, String extra_flags)
	{
		return ImGui::InputFloat2(label, &v.x, decimal_precision, getInputTextFlags(extra_flags));
	}

	bool InputInt2(const char* label, Vec2& v, String extra_flags)
	{
		int ints[2] = {s_cast<int>(v.x), s_cast<int>(v.y)};
		bool changed = ImGui::InputInt2(label, ints, getInputTextFlags(extra_flags));
		v.x = s_cast<float>(ints[0]);
		v.y = s_cast<float>(ints[1]);
		return changed;
	}

	bool SliderFloat2(const char* label, Vec2& v, float v_min, float v_max, const char* display_format, float power)
	{
		return ImGui::SliderFloat2(label, &v.x, v_min, v_max, display_format, power);
	}

	bool SliderInt2(const char* label, Vec2& v, int v_min, int v_max, const char* display_format)
	{
		int ints[2] = {s_cast<int>(v.x), s_cast<int>(v.y)};
		bool changed = ImGui::SliderInt2(label, ints, v_min, v_max, display_format);
		v.x = s_cast<float>(ints[0]);
		v.y = s_cast<float>(ints[1]);
		return changed;
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

	void Image(Texture2D* user_texture, const Vec2& size, const Vec2& uv0, const Vec2& uv1, Color tint_col, Color border_col)
	{
		union
		{
			ImTextureID ptr;
			struct { bgfx::TextureHandle handle; } s;
		} texture;
		texture.s.handle = user_texture->getHandle();
		ImGui::Image(texture.ptr, size, uv0, uv1, tint_col.toVec4(), border_col.toVec4());
	}

	bool ImageButton(Texture2D* user_texture, const Vec2& size, const Vec2& uv0, const Vec2& uv1, int frame_padding, Color bg_col, Color tint_col)
	{
		union
		{
			ImTextureID ptr;
			struct { bgfx::TextureHandle handle; } s;
		} texture;
		texture.s.handle = user_texture->getHandle();
		return ImGui::ImageButton(texture.ptr, size, uv0, uv1, frame_padding, bg_col.toVec4(), tint_col.toVec4());
	}

	bool ColorButton(Color col, bool small_height, bool outline_border)
	{
		return ImGui::ColorButton(col.toVec4(), small_height, outline_border);
	}

	void ValueColor(const char* prefix, Color v)
	{
		return ImGui::ValueColor(prefix, v.toVec4());
	}

	void Columns(int count, bool border)
	{
		ImGui::Columns(count, nullptr, border);
	}

	void Columns(int count, bool border, const char* id)
	{
		ImGui::Columns(count, id, border);
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
		}
	}

	void SetStyleVar(String name, float var)
	{
		ImGuiStyle& style = ImGui::GetStyle();
		switch (Switch::hash(name))
		{
			case "Alpha"_hash: style.Alpha = var; break;
			case "WindowRounding"_hash: style.WindowRounding = var; break;
			case "ChildWindowRounding"_hash: style.ChildWindowRounding = var; break;
			case "FrameRounding"_hash: style.FrameRounding = var; break;
			case "IndentSpacing"_hash: style.IndentSpacing = var; break;
			case "ColumnsMinSpacing"_hash: style.ColumnsMinSpacing = var; break;
			case "ScrollbarSize"_hash: style.ScrollbarSize = var; break;
			case "ScrollbarRounding"_hash: style.ScrollbarRounding = var; break;
			case "GrabMinSize"_hash: style.GrabMinSize = var; break;
			case "GrabRounding"_hash: style.GrabRounding = var; break;
			case "CurveTessellationTol"_hash: style.CurveTessellationTol = var; break;
		}
	}

	void SetStyleVar(String name, bool var)
	{
		ImGuiStyle& style = ImGui::GetStyle();
		switch (Switch::hash(name))
		{
			case "AntiAliasedLines"_hash: style.AntiAliasedLines = var; break;
			case "AntiAliasedShapes"_hash: style.AntiAliasedShapes = var; break;
		}
	}

	void SetStyleColor(String name, Color color)
	{
		ImGuiCol_ index = getColorIndex(name);
		ImGuiStyle& style = ImGui::GetStyle();
		style.Colors[index] = color.toVec4();
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
			case "ShowBorders"_hash: return ImGuiWindowFlags_ShowBorders;
			case "NoSavedSettings"_hash: return ImGuiWindowFlags_NoSavedSettings;
			case "NoInputs"_hash: return ImGuiWindowFlags_NoInputs;
			case "MenuBar"_hash: return ImGuiWindowFlags_MenuBar;
			case "HorizontalScrollbar"_hash: return ImGuiWindowFlags_HorizontalScrollbar;
			case "NoFocusOnAppearing"_hash: return ImGuiWindowFlags_NoFocusOnAppearing;
			case "NoBringToFrontOnFocus"_hash: return ImGuiWindowFlags_NoBringToFrontOnFocus;
			case "AlwaysVerticalScrollbar"_hash: return ImGuiWindowFlags_AlwaysVerticalScrollbar;
			case "AlwaysHorizontalScrollbar"_hash: return ImGuiWindowFlags_AlwaysHorizontalScrollbar;
			case "AlwaysUseWindowPadding"_hash: return ImGuiWindowFlags_AlwaysUseWindowPadding;
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

	ImGuiInputTextFlags_ getInputTextFlags(String flag)
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
			case "AlwaysInsertMode"_hash: return ImGuiInputTextFlags_AlwaysInsertMode;
			case "ReadOnly"_hash: return ImGuiInputTextFlags_ReadOnly;
			case "Password"_hash: return ImGuiInputTextFlags_Password;
		}
		return ImGuiInputTextFlags_(0);
	}

	ImGuiTreeNodeFlags_ getTreeNodeFlags(String flag)
	{
		switch (Switch::hash(flag))
		{
			case "Selected"_hash: return ImGuiTreeNodeFlags_Selected;
			case "Framed"_hash: return ImGuiTreeNodeFlags_Framed;
			case "AllowOverlapMode"_hash: return ImGuiTreeNodeFlags_AllowOverlapMode;
			case "NoTreePushOnOpen"_hash: return ImGuiTreeNodeFlags_NoTreePushOnOpen;
			case "NoAutoOpenOnLog"_hash: return ImGuiTreeNodeFlags_NoAutoOpenOnLog;
			case "DefaultOpen"_hash: return ImGuiTreeNodeFlags_DefaultOpen;
			case "OpenOnDoubleClick"_hash: return ImGuiTreeNodeFlags_OpenOnDoubleClick;
			case "OpenOnArrow"_hash: return ImGuiTreeNodeFlags_OpenOnArrow;
			case "Leaf"_hash: return ImGuiTreeNodeFlags_Leaf;
			case "Bullet"_hash: return ImGuiTreeNodeFlags_Bullet;
			case "CollapsingHeader"_hash: return ImGuiTreeNodeFlags_CollapsingHeader;
		}
		return ImGuiTreeNodeFlags_(0);
	}

	ImGuiSelectableFlags_ getSelectableFlags(String flag)
	{
		switch (Switch::hash(flag))
		{
			case "DontClosePopups"_hash: return ImGuiSelectableFlags_DontClosePopups;
			case "SpanAllColumns"_hash: return ImGuiSelectableFlags_SpanAllColumns;
			case "AllowDoubleClick"_hash: return ImGuiSelectableFlags_AllowDoubleClick;
		}
		return ImGuiSelectableFlags_(0);
	}

	ImGuiCol_ getColorIndex(String col)
	{
		switch (Switch::hash(col))
		{
			case "Text"_hash: return ImGuiCol_Text;
			case "TextDisabled"_hash: return ImGuiCol_TextDisabled;
			case "WindowBg"_hash: return ImGuiCol_WindowBg;
			case "ChildWindowBg"_hash: return ImGuiCol_ChildWindowBg;
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
			case "ComboBg"_hash: return ImGuiCol_ComboBg;
			case "CheckMark"_hash: return ImGuiCol_CheckMark;
			case "SliderGrab"_hash: return ImGuiCol_SliderGrab;
			case "SliderGrabActive"_hash: return ImGuiCol_SliderGrabActive;
			case "Button"_hash: return ImGuiCol_Button;
			case "ButtonHovered"_hash: return ImGuiCol_ButtonHovered;
			case "ButtonActive"_hash: return ImGuiCol_ButtonActive;
			case "Header"_hash: return ImGuiCol_Header;
			case "HeaderHovered"_hash: return ImGuiCol_HeaderHovered;
			case "HeaderActive"_hash: return ImGuiCol_HeaderActive;
			case "Column"_hash: return ImGuiCol_Column;
			case "ColumnHovered"_hash: return ImGuiCol_ColumnHovered;
			case "ColumnActive"_hash: return ImGuiCol_ColumnActive;
			case "ResizeGrip"_hash: return ImGuiCol_ResizeGrip;
			case "ResizeGripHovered"_hash: return ImGuiCol_ResizeGripHovered;
			case "ResizeGripActive"_hash: return ImGuiCol_ResizeGripActive;
			case "CloseButton"_hash: return ImGuiCol_CloseButton;
			case "CloseButtonHovered"_hash: return ImGuiCol_CloseButtonHovered;
			case "CloseButtonActive"_hash: return ImGuiCol_CloseButtonActive;
			case "PlotLines"_hash: return ImGuiCol_PlotLines;
			case "PlotLinesHovered"_hash: return ImGuiCol_PlotLinesHovered;
			case "PlotHistogram"_hash: return ImGuiCol_PlotHistogram;
			case "PlotHistogramHovered"_hash: return ImGuiCol_PlotHistogramHovered;
			case "TextSelectedBg"_hash: return ImGuiCol_TextSelectedBg;
			case "ModalWindowDarkening"_hash: return ImGuiCol_ModalWindowDarkening;
		}
		return ImGuiCol_(0);
	}

	ImGuiColorEditMode_ getColorEditMode(String mode)
	{
		switch (Switch::hash(mode))
		{
			case "UserSelect"_hash: return ImGuiColorEditMode_UserSelect;
			case "UserSelectShowButton"_hash: return ImGuiColorEditMode_UserSelectShowButton;
			case "RGB"_hash: return ImGuiColorEditMode_RGB;
			case "HSV"_hash: return ImGuiColorEditMode_HSV;
			case "HEX"_hash: return ImGuiColorEditMode_HEX;
		}
		return ImGuiColorEditMode_(0);
	}

	ImGuiSetCond_ getSetCond(String cond)
	{
		switch (Switch::hash(cond))
		{
			case "Always"_hash: return ImGuiSetCond_Always;
			case "Once"_hash: return ImGuiSetCond_Once;
			case "FirstUseEver"_hash: return ImGuiSetCond_FirstUseEver;
			case "Appearing"_hash: return ImGuiSetCond_Appearing;
		}
		return ImGuiSetCond_(0);
	}
} }
