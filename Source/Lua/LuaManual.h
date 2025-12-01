/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Dora.h"

NS_DORA_BEGIN

/* Application */
inline Application* Application_shared() { return &SharedApplication; }

/* Event */
int dora_emit(lua_State* L);

/* Path */
int Path_create(lua_State* L);

/* Content */
void __Content_loadFile(lua_State* L, Content* self, String filename);
#define Content_loadFile(self, filename) \
	{ \
		__Content_loadFile(tolua_S, self, filename); \
		return 1; \
	}
void __Content_getDirs(lua_State* L, Content* self, String path);
#define Content_getDirs(self, path) \
	{ \
		__Content_getDirs(tolua_S, self, path); \
		return 1; \
	}
void __Content_getFiles(lua_State* L, Content* self, String path);
#define Content_getFiles(self, path) \
	{ \
		__Content_getFiles(tolua_S, self, path); \
		return 1; \
	}
void __Content_getAllFiles(lua_State* L, Content* self, String path);
#define Content_getAllFiles(self, path) \
	{ \
		__Content_getAllFiles(tolua_S, self, path); \
		return 1; \
	}
int Content_GetSearchPaths(lua_State* L);
int Content_SetSearchPaths(lua_State* L);
void Content_insertSearchPath(Content* self, int index, String path);
int Content_loadExcel(lua_State* L);
int Content_loadExcelAsync(lua_State* L);
inline Content* Content_shared() { return &SharedContent; }

/* Director */
inline Director* Director_shared() { return &SharedDirector; }

/* View */
inline View* View_shared() { return &SharedView; }

/* Log */
inline void Dora_Log(String level, String msg) { LogThreaded(level.toString(), msg.toString()); }

/* Node */
int Node_emit(lua_State* L);
int Node_slot(lua_State* L);
int Node_gslot(lua_State* L);
bool Node_eachChild(Node* self, const LuaFunction<bool>& func);

/* Node.Grabber */
inline void Grabber_setPos(Node::Grabber* self, uint32_t x, uint32_t y, Vec2 pos, float z) { self->setPos(x - 1, y - 1, pos, z); }
inline Vec2 Grabber_getPos(Node::Grabber* self, uint32_t x, uint32_t y) { return self->getPos(x - 1, y - 1); }
inline Color Grabber_getColor(Node::Grabber* self, uint32_t x, uint32_t y) { return self->getColor(x - 1, y - 1); }
inline void Grabber_setColor(Node::Grabber* self, uint32_t x, uint32_t y, Color color) { self->setColor(x - 1, y - 1, color); }
inline void Grabber_moveUV(Node::Grabber* self, uint32_t x, uint32_t y, Vec2 offset) { self->moveUV(x - 1, y - 1, offset); }

/* Texture2D */
inline Texture2D* Texture2D_create(String filename) { return SharedTextureCache.load(filename); }

/* Sprite */
int Sprite_GetUWrap(lua_State* L);
int Sprite_SetUWrap(lua_State* L);
int Sprite_GetVWrap(lua_State* L);
int Sprite_SetVWrap(lua_State* L);
int Sprite_GetTextureFilter(lua_State* L);
int Sprite_SetTextureFilter(lua_State* L);
int Sprite_GetClips(lua_State* L);

/* TileNode */
int TileNode_GetTextureFilter(lua_State* L);
int TileNode_SetTextureFilter(lua_State* L);

/* Grid */
inline void Grid_setPos(Grid* self, uint32_t x, uint32_t y, Vec2 pos, float z) { self->setPos(x - 1, y - 1, pos, z); }
inline Vec2 Grid_getPos(Grid* self, uint32_t x, uint32_t y) { return self->getPos(x - 1, y - 1); }
inline Color Grid_getColor(Grid* self, uint32_t x, uint32_t y) { return self->getColor(x - 1, y - 1); }
inline void Grid_setColor(Grid* self, uint32_t x, uint32_t y, Color color) { self->setColor(x - 1, y - 1, color); }
inline void Grid_moveUV(Grid* self, uint32_t x, uint32_t y, Vec2 offset) { self->moveUV(x - 1, y - 1, offset); }

/* Label */
inline Sprite* Label_getCharacter(Label* self, int index) { return self->getCharacter(index - 1); }
int Label_GetTextAlign(lua_State* L);
int Label_SetTextAlign(lua_State* L);

/* DrawNode */
int DrawNode_drawVertices(lua_State* L);

/* Vec2 */
inline Vec2 Vec2_create(float x, float y) { return {x, y}; }
inline Vec2 Vec2_create(const Size& size) { return {size.width, size.height}; }

/* Size */
inline Size* Size_create(float width, float height) {
	return Mtolua_new((Size)({width, height}));
}
inline Size* Size_create(const Vec2& vec) {
	return Mtolua_new((Size)({vec.x, vec.y}));
}

/* Color */
inline Color* Color_create(double argb = 0) {
	return Mtolua_new((Color)(s_cast<uint32_t>(argb)));
}

inline Color* Color_create(String argb) {
	auto value = argb.trimSpace();
	if (value.size() == 9 && value[0] == '#') {
		value.skip(1);
		try {
			uint32_t rgba = static_cast<uint32_t>(std::stoul(value.toString(), nullptr, 16));
			uint32_t r = (rgba >> 24) & 0xFF;
			uint32_t g = (rgba >> 16) & 0xFF;
			uint32_t b = (rgba >> 8) & 0xFF;
			uint32_t a = rgba & 0xFF;
			uint32_t argb_value = (a << 24) | (r << 16) | (g << 8) | b;
			return Mtolua_new((Color)(argb_value));
		} catch (const std::exception&) { }
	}
	Issue("failed to convert string \"{}\" to RGBA color value.", argb.toString());
	return Mtolua_new((Color)(0));
}

/* Color3 */
inline Color3* Color3_create(double rgb = 0) {
	return Mtolua_new((Color3)(s_cast<uint32_t>(rgb)));
}

/* BlendFunc */
BlendFunc* BlendFunc_create(String src, String dst);
BlendFunc* BlendFunc_create(String srcC, String dstC, String srcA, String dstA);
uint32_t BlendFunc_get(String func);

/* Action */
int Action_create(lua_State* L);

/* Model */
void __Model_getClipFile(lua_State* L, String filename);
#define Model_getClipFile(filename) \
	{ \
		__Model_getClipFile(tolua_S, filename); \
		return 1; \
	}
void __Model_getLookNames(lua_State* L, String filename);
#define Model_getLookNames(filename) \
	{ \
		__Model_getLookNames(tolua_S, filename); \
		return 1; \
	}
void __Model_getAnimationNames(lua_State* L, String filename);
#define Model_getAnimationNames(filename) \
	{ \
		__Model_getAnimationNames(tolua_S, filename); \
		return 1; \
	}

/* Spine */
void __Spine_getLookNames(lua_State* L, String spineStr);
#define Spine_getLookNames(spineStr) \
	{ \
		__Spine_getLookNames(tolua_S, spineStr); \
		return 1; \
	}
void __Spine_getAnimationNames(lua_State* L, String spineStr);
#define Spine_getAnimationNames(spineStr) \
	{ \
		__Spine_getAnimationNames(tolua_S, spineStr); \
		return 1; \
	}
int Spine_containsPoint(lua_State* L);
int Spine_intersectsSegment(lua_State* L);

/* DragonBone */
void __DragonBone_getLookNames(lua_State* L, String boneStr);
#define DragonBone_getLookNames(boneStr) \
	{ \
		__DragonBone_getLookNames(tolua_S, boneStr); \
		return 1; \
	}
void __DragonBone_getAnimationNames(lua_State* L, String boneStr);
#define DragonBone_getAnimationNames(boneStr) \
	{ \
		__DragonBone_getAnimationNames(tolua_S, boneStr); \
		return 1; \
	}
int DragonBone_containsPoint(lua_State* L);
int DragonBone_intersectsSegment(lua_State* L);

/* BodyDef */
int BodyDef_GetType(lua_State* L);
int BodyDef_SetType(lua_State* L);

/* Dictionary */
int Dictionary_getKeys(lua_State* L);
int Dictionary_get(lua_State* L);
int Dictionary_set(lua_State* L);

/* Array */
int Array_getFirst(lua_State* L);
int Array_getLast(lua_State* L);
int Array_getRandomObject(lua_State* L);
int Array_index(lua_State* L);
int Array_set(lua_State* L);
int Array_get(lua_State* L);
int Array_insert(lua_State* L);
int Array_add(lua_State* L);
int Array_contains(lua_State* L);
int Array_fastRemove(lua_State* L);
int Array_removeLast(lua_State* L);
int Array_create(lua_State* L);
inline void Array_swap(Array* self, int indexA, int indexB) { self->swap(indexA - 1, indexB - 1); }
inline bool Array_removeAt(Array* self, int index) { return self->removeAt(index - 1); }
inline bool Array_fastRemoveAt(Array* self, int index) { return self->fastRemoveAt(index - 1); }
inline bool Array_each(Array* self, const LuaFunction<bool>& handler) {
	int index = 0;
	return self->each([&](Value* item) {
		return handler(item, ++index);
	});
}

/* Audio */
inline Audio* Audio_shared() { return &SharedAudio; }

/* Controller */
inline Controller* Controller_shared() { return &SharedController; }

/* Keyboard */
inline Keyboard* Keyboard_shared() { return &SharedKeyboard; }

/* Entity */
int Entity_get(lua_State* L);
int Entity_getOld(lua_State* L);
int Entity_set(lua_State* L);
int Entity_create(lua_State* L);

/* EntityGroup */
int EntityGroup_watch(lua_State* L);

/* EntityObserver */
EntityObserver* EntityObserver_create(String option, Slice components[], int count);
int EntityObserver_watch(lua_State* L);

/* QLearner */
int QLearner_pack(lua_State* L);
int QLearner_unpack(lua_State* L);
int QLearner_load(lua_State* L);
int QLearner_getMatrix(lua_State* L);

/* DB */
inline DB* DB_shared() { return &SharedDB; }
int DB_transaction(lua_State* L);
int DB_transactionAsync(lua_State* L);
int DB_query(lua_State* L);
int DB_insert(lua_State* L);
int DB_exec(lua_State* L);
int DB_queryAsync(lua_State* L);
int DB_insertAsync(lua_State* L);
int DB_insertAsync01(lua_State* L);
int DB_execAsync(lua_State* L);

/* HttpServer */
int HttpServer_post(lua_State* L);
int HttpServer_postSchedule(lua_State* L);
int HttpServer_upload(lua_State* L);
inline HttpServer* HttpServer_shared() { return &SharedHttpServer; }

/* HttpClient */
inline HttpClient* HttpClient_shared() { return &SharedHttpClient; }

/* Effect */
inline Pass* Effect_get(Effect* self, size_t index) { return self->get(index - 1); }

/* Wasm */
void WasmRuntime_clear();

/* Test */
int Test_getNames(lua_State* L);
int Test_run(lua_State* L);

NS_DORA_END

NS_DORA_PLATFORMER_BEGIN

/* TargetAllow */
void TargetAllow_allow(TargetAllow* self, String flag, bool allow);
bool TargetAllow_isAllow(TargetAllow* self, String flag);

/* UnitAction */
class LuaActionDef : public UnitActionDef {
public:
	LuaActionDef(
		LuaFunction<bool> available,
		LuaFunction<LuaFunction<bool>> create,
		LuaFunction<void> stop);
	LuaFunction<bool> available;
	LuaFunction<LuaFunction<bool>> create;
	LuaFunction<void> stop;
	virtual Own<UnitAction> toAction(Unit* unit) override;
};

class LuaUnitAction : public UnitAction {
public:
	LuaUnitAction(String name, int priority, bool queued, Unit* owner);
	virtual bool isAvailable() override;
	virtual void run() override;
	virtual void update(float dt) override;
	virtual void stop() override;
	virtual void destroy() override;

private:
	std::function<bool(Unit*, UnitAction*)> _available;
	std::function<LuaFunction<bool>(Unit*, UnitAction*)> _create;
	std::function<bool(Unit*, UnitAction*, float)> _update;
	std::function<void(Unit*, UnitAction*)> _stop;
	friend class LuaActionDef;
};

void LuaUnitAction_add(
	String name,
	int priority,
	float reaction,
	float recovery,
	bool queued,
	LuaFunction<bool> available,
	LuaFunction<LuaFunction<bool>> create,
	LuaFunction<void> stop);

/* AI */
inline Decision::AI* AI_shared() { return &SharedAI; }
Array* AI_getUnitsByRelation(Decision::AI* self, String relation);
Unit* AI_getNearestUnit(Decision::AI* self, String relation);
float AI_getNearestUnitDistance(Decision::AI* self, String relation);

/* Blackboard */
int Blackboard_get(lua_State* L);
int Blackboard_set(lua_State* L);

/* Data */
inline Data* Data_shared() { return &SharedData; }
void Data_setRelation(Data* self, uint8_t groupA, uint8_t groupB, String relation);
Slice Data_getRelation(Data* self, uint8_t groupA, uint8_t groupB);
Slice Data_getRelation(Data* self, Body* bodyA, Body* bodyB);

NS_DORA_PLATFORMER_END
