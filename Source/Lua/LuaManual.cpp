/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Dorothy.h"
#include "Lua/ToLua/tolua++.h"

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

void __Content_getDirEntries(lua_State* L, Content* self, String path, bool isFolder)
{
	auto dirs = self->getDirEntries(path, isFolder);
	lua_createtable(L, (int)dirs.size(), 0);
	for (int i = 0; i < (int)dirs.size(); i++)
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
			float number = tolua_tonumber(L, -1, 0);
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
							Ease::Enum ease = s_cast<Ease::Enum>(toNumber(L, location, 5, true));
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
							return Sequence::alloc(actions);
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

NS_DOROTHY_END
