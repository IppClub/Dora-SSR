/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

/* Application */
inline Application* Application_shared() { return &SharedApplication; }

/* Event */
int dora_emit(lua_State* L);

/* Content */
void __Content_loadFile(lua_State* L, Content* self, String filename);
#define Content_loadFile(self,filename) {__Content_loadFile(tolua_S,self,filename);return 1;}
void __Content_getDirEntries(lua_State* L, Content* self, String path, bool isFolder);
#define Content_getDirEntries(self,path,isFolder) {__Content_getDirEntries(tolua_S,self,path,isFolder);return 1;}
void Content_setSearchPaths(Content* self, Slice paths[], int length);
inline Content* Content_shared() { return &SharedContent; }

/* Director */
inline Director* Director_shared() { return &SharedDirector; }

/* View */
inline View* View_shared() { return &SharedView; }

/* Log */
inline void Dora_Log(String msg) { Log("%s", msg); }

/* Node */
int Node_emit(lua_State* L);
int Node_slot(lua_State* L);
int Node_gslot(lua_State* L);

/* Cache */
struct Cache
{
	static bool load(String filename);
	static void loadAsync(String filename, const function<void()>& callback);
	static void update(String filename, String content);
	static void update(String filename, Texture2D* texture);
	static void unload();
	static bool unload(String name);
	static void removeUnused();
	static void removeUnused(String type);
};

/* Sprite */
Sprite* Sprite_create(String clipStr);

/* Vec2 */
Vec2* Vec2_create(float x, float y);

/* Size */
Size* Size_create(float width, float height);

/* BlendFunc */
BlendFunc* BlendFunc_create(Uint32 src, Uint32 dst);

/* Action */
int Action_create(lua_State* L);

/* Model */
Model* Model_create(String filename);
Vec2 Model_getKey(Model* model, String key);

/* Body */
typedef b2FixtureDef FixtureDef;
Body* Body_create(BodyDef* def, World* world, Vec2 pos, float rot);

/* Dictionary */
Array* __Dictionary_getKeys(Dictionary* self);
#define Dictionary_getKeys() __Dictionary_getKeys(self)
int Dictionary_get(lua_State* L);
int Dictionary_set(lua_State* L);

/* Array */
void Array_swap(Array* self, int indexA, int indexB);
int Array_index(Array* self, Object* object);
void Array_set(Array* self, int index, Object* object);
Object* Array_get(Array* self, int index);
void Array_insert(Array* self, int index, Object* object);
bool Array_removeAt(Array* self, int index);
bool Array_fastRemoveAt(Array* self, int index);
template <class Func>
bool Array_each(Array* self, const Func& handler)
{
	return self->each([&handler](Object* item, int index)
	{
		return handler(item, index + 1);
	});
}

NS_DOROTHY_END
