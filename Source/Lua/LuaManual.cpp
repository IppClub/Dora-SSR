/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Dora.h"

#include "Lua/LuaManual.h"

#include "Lua/LuaEngine.h"
#include "Lua/ToLua/tolua++.h"
#include "Other/xlsxtext.hpp"
#include "SQLiteCpp/SQLiteCpp.h"

extern "C" {
int colibc_json_decode(lua_State* L);
int colibc_json_encode(lua_State* L);
}

NS_DORA_BEGIN

/* Event */

int dora_emit(lua_State* L) {
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isstring(L, 1, 0, &tolua_err)) {
		tolua_error(L, "#vinvalid type in variable assignment", &tolua_err);
	}
#endif
	Slice name = tolua_toslice(L, 1, nullptr);
	int top = lua_gettop(L);
	int count = top - 1;
	if (count > 0) {
		for (int i = 2; i <= top; i++) {
			lua_pushvalue(L, i);
		}
		lua_State* baseL = SharedLuaEngine.getState();
		int baseTop = lua_gettop(baseL);
		DEFER(lua_settop(baseL, baseTop));
		lua_xmove(L, baseL, count);
		LuaEventArgs::send(name, count);
	} else {
		LuaEventArgs::send(name, 0);
	}
	return 0;
}

static std::vector<std::string> getVectorString(lua_State* L, int loc) {
	int length = s_cast<int>(lua_rawlen(L, loc));
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isslicearray(L, loc, length, 0, &tolua_err)) {
		goto tolua_lerror;
	} else
#endif
	{
		std::vector<std::string> array(length);
		for (int i = 0; i < length; i++) {
			array[i] = tolua_tofieldslice(L, loc, i + 1, 0).toString();
		}
		return array;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'getVectorString'.", &tolua_err);
	return std::vector<std::string>();
#endif
}

static void pushVectorString(lua_State* L, const std::vector<std::string>& array) {
	lua_createtable(L, s_cast<int>(array.size()), 0);
	int i = 0;
	for (const auto& item : array) {
		lua_pushlstring(L, item.c_str(), item.size());
		lua_rawseti(L, -2, ++i);
	}
}

static void pushVectorString(lua_State* L, const std::vector<Slice>& array) {
	lua_createtable(L, s_cast<int>(array.size()), 0);
	int i = 0;
	for (const auto& item : array) {
		lua_pushlstring(L, item.rawData(), item.size());
		lua_rawseti(L, -2, ++i);
	}
}

static void pushListString(lua_State* L, const std::list<std::string>& array) {
	lua_createtable(L, s_cast<int>(array.size()), 0);
	int i = 0;
	for (const auto& item : array) {
		lua_pushlstring(L, item.c_str(), item.size());
		lua_rawseti(L, -2, ++i);
	}
}

static Slice GetString(lua_State* L, int loc) {
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isstring(L, loc, 0, &tolua_err)) {
		goto tolua_lerror;
	} else
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
int Path_create(lua_State* L) {
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertable(L, 1, "Path"_slice, 0, &tolua_err)) {
		tolua_error(L, "#ferror in function 'Path_create'.", &tolua_err);
		return 0;
	}
#endif
	int top = lua_gettop(L);
	std::list<Slice> paths;
	for (int i = 2; i <= top; i++) {
#ifndef TOLUA_RELEASE
		if (!tolua_isstring(L, i, 0, &tolua_err)) {
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

void __Content_loadFile(lua_State* L, Content* self, String filename) {
	auto data = self->load(filename);
	if (data.first)
		lua_pushlstring(L, r_cast<char*>(data.first.get()), data.second);
	else
		lua_pushnil(L);
}

void __Content_getDirs(lua_State* L, Content* self, String path) {
	auto dirs = self->getDirs(path);
	pushListString(L, dirs);
}

void __Content_getFiles(lua_State* L, Content* self, String path) {
	auto files = self->getFiles(path);
	pushListString(L, files);
}

void __Content_getAllFiles(lua_State* L, Content* self, String path) {
	auto files = self->getAllFiles(path);
	pushListString(L, files);
}

int Content_GetSearchPaths(lua_State* L) {
	Content* self = r_cast<Content*>(tolua_tousertype(L, 1, 0));
	pushVectorString(L, self->getSearchPaths());
	return 1;
}

int Content_SetSearchPaths(lua_State* L) {
	Content* self = r_cast<Content*>(tolua_tousertype(L, 1, 0));
	self->setSearchPaths(getVectorString(L, 2));
	return 0;
}

void Content_insertSearchPath(Content* self, int index, String path) {
	self->insertSearchPath(index - 1, path);
}

void pushExcelData(lua_State* L, const xlsxtext::workbook& workbook, const std::list<std::string>& sheets) {
	const auto& strs = workbook.shared_strings();
	lua_createtable(L, strs.size(), 0); // sharedStrings
	for (int i = 0; i < s_cast<int>(strs.size()); i++) {
		tolua_pushslice(L, strs[i]);
		lua_rawseti(L, -2, i + 1);
	}
	int strIndex = lua_gettop(L);
	lua_createtable(L, 0, 0); // sharedStrings res
	for (const auto& worksheet : workbook) {
		if (!sheets.empty()) {
			if (std::find(sheets.begin(), sheets.end(), worksheet.name()) == sheets.end()) {
				continue;
			}
		}
		unsigned maxRow = worksheet.max_row();
		unsigned maxCol = worksheet.max_col();
		lua_createtable(L, maxRow, 0); // sheet
		lua_pushvalue(L, -1); // sheet sheet
		tolua_pushslice(L, worksheet.name()); // sheet sheet name
		lua_insert(L, -2); // sheet name sheet
		lua_rawset(L, -4); // tb[name] = sheet, sheet
		for (unsigned i = 0; i < maxRow; i++) {
			lua_pushboolean(L, 0);
			lua_rawseti(L, -2, i + 1); // sheet[i + 1] = false
		}
		for (const auto& row : worksheet) {
			bool rowCreated = false;
			for (const auto& cell : row) {
				if (!rowCreated) {
					rowCreated = true;
					lua_createtable(L, maxCol, 0); // sheet row
					lua_pushvalue(L, -1); // sheet row row
					lua_rawseti(L, -3, cell.refer.row); // sheet[cell.refer.row] = row, sheet row
					for (unsigned i = 0; i < maxCol; i++) {
						lua_pushboolean(L, 0);
						lua_rawseti(L, -2, i + 1); // row[i + 1] = false, sheet row
					}
				}
				if (cell.value.empty() && cell.string_id >= 0) {
					lua_rawgeti(L, strIndex, cell.string_id + 1);
				} else {
					char* endptr = nullptr;
					double d = std::strtod(cell.value.c_str(), &endptr);
					if (*endptr != '\0' || endptr == cell.value.c_str()) {
						tolua_pushslice(L, cell.value);
					} else {
						lua_pushnumber(L, d);
					}
				}
				lua_rawseti(L, -2, cell.refer.col); // row[cell.refer.col] = cell.value, sheet row
			}
			if (rowCreated) {
				lua_pop(L, 1); // sheet
			}
		}
		lua_pop(L, 1); // sharedStrings res
	}
	lua_remove(L, -2); // res
}

int Content_loadExcel(lua_State* L) {
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Content"_slice, 0, &tolua_err) || !tolua_isstring(L, 2, 0, &tolua_err) || !tolua_istable(L, 3, 1, &tolua_err) || !tolua_isnoobj(L, 4, &tolua_err)) {
		goto tolua_lerror;
	} else
#endif
	{
#ifndef TOLUA_RELEASE
		Content* self = r_cast<Content*>(tolua_tousertype(L, 1, 0));
		if (!self) tolua_error(L, "invalid 'self' in function 'Node_emit'", nullptr);
#endif
		Slice filename = tolua_toslice(L, 2, 0);
		std::list<std::string> sheets;
		if (lua_istable(L, 3) != 0) {
			int length = s_cast<int>(lua_rawlen(L, 3));
#ifndef TOLUA_RELEASE
			if (!tolua_isstringarray(L, 3, length, 0, &tolua_err)) {
				goto tolua_lerror;
			}
#endif
			for (int i = 0; i < length; i++) {
				lua_geti(L, 3, i + 1);
				sheets.push_back(tolua_toslice(L, -1, nullptr).toString());
				lua_pop(L, 1);
			}
		}
		xlsxtext::workbook workbook(SharedContent.load(filename));
		if (workbook.read()) {
			for (auto& worksheet : workbook) {
				if (!sheets.empty()) {
					if (std::find(sheets.begin(), sheets.end(), worksheet.name()) == sheets.end()) {
						continue;
					}
				}
				auto errors = worksheet.read();
				if (!errors.empty()) {
					Error("failed to read excel sheet \"{}\" from file \"{}\":", worksheet.name(), filename.toString());
					for (auto [refer, msg] : errors) {
						Error("{}: {}", refer, msg);
					}
					lua_pushnil(L);
					return 1;
				}
			}
			pushExcelData(L, workbook, sheets);
		} else
			lua_pushnil(L);
	}
	return 1;
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Content_loadExcel'.", &tolua_err);
	return 0;
#endif
}

int Content_loadExcelAsync(lua_State* L) {
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Content"_slice, 0, &tolua_err) || !tolua_isstring(L, 2, 0, &tolua_err) || !((tolua_istable(L, 3, 0, &tolua_err) && tolua_isfunction(L, 4, &tolua_err) && tolua_isnoobj(L, 5, &tolua_err)) || (tolua_isfunction(L, 3, &tolua_err) && tolua_isnoobj(L, 4, &tolua_err)))) {
		goto tolua_lerror;
	} else
#endif
	{
#ifndef TOLUA_RELEASE
		Content* self = r_cast<Content*>(tolua_tousertype(L, 1, 0));
		if (!self) tolua_error(L, "invalid 'self' in function 'Node_emit'", nullptr);
#endif
		std::string filename = tolua_toslice(L, 2, 0).toString();
		std::list<std::string> sheets;
		if (lua_istable(L, 3) != 0) {
			int length = s_cast<int>(lua_rawlen(L, 3));
#ifndef TOLUA_RELEASE
			if (!tolua_isstringarray(L, 3, length, 0, &tolua_err)) {
				goto tolua_lerror;
			}
#endif
			for (int i = 0; i < length; i++) {
				lua_geti(L, 3, i + 1);
				sheets.push_back(tolua_toslice(L, -1, nullptr).toString());
				lua_pop(L, 1);
			}
		}
		int funcIndex = lua_isfunction(L, 3) != 0 ? 3 : 4;
		Ref<LuaHandler> handler(LuaHandler::create(tolua_ref_function(L, funcIndex)));
		SharedContent.loadAsyncData(filename, [filename, sheets = std::move(sheets), handler](OwnArray<uint8_t>&& data, size_t size) {
			auto excelData = std::make_shared<OwnArray<uint8_t>>(std::move(data));
			SharedAsyncThread.run(
				[filename, sheets, excelData = std::move(excelData), size]() {
					auto workbook = New<xlsxtext::workbook>(std::make_pair(std::move(*excelData), size));
					if (workbook->read()) {
						for (auto& worksheet : *workbook) {
							if (!sheets.empty()) {
								if (std::find(sheets.begin(), sheets.end(), worksheet.name()) == sheets.end()) {
									continue;
								}
							}
							auto errors = worksheet.read();
							if (!errors.empty()) {
								Error("failed to read excel sheet \"{}\" from file \"{}\":", worksheet.name(), filename);
								for (auto [refer, msg] : errors) {
									Error("{}: {}", refer, msg);
								}
							}
						}
						return Values::alloc(true, std::move(workbook));
					}
					return Values::alloc(false, std::move(workbook));
				},
				[handler, sheets](Own<Values>&& values) {
					bool success = false;
					Own<xlsxtext::workbook> workbook;
					values->get(success, workbook);
					auto L = SharedLuaEngine.getState();
					if (success) {
						pushExcelData(L, *workbook, sheets);
						SharedLuaEngine.executeFunction(handler->get(), 1);
					} else {
						lua_pushboolean(L, 0);
						SharedLuaEngine.executeFunction(handler->get(), 1);
					}
				});
		});
	}
	return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Content_loadExcel'.", &tolua_err);
	return 0;
#endif
}

/* Node */

int Node_emit(lua_State* L) {
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Node"_slice, 0, &tolua_err) || !tolua_isstring(L, 2, 0, &tolua_err)) {
		goto tolua_lerror;
	} else
#endif
	{
		Node* self = r_cast<Node*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Node_emit'", nullptr);
#endif
		Slice name = tolua_toslice(L, 2, 0);
		int top = lua_gettop(L);
		int count = top - 2;
		if (count > 0) {
			for (int i = 3; i <= top; i++) {
				lua_pushvalue(L, i);
			}
			lua_State* baseL = SharedLuaEngine.getState();
			int baseTop = lua_gettop(baseL);
			DEFER(lua_settop(baseL, baseTop));
			lua_xmove(L, baseL, count);
			LuaEventArgs luaEvent(name, count);
			self->emit(&luaEvent);
		} else {
			LuaEventArgs luaEvent(name, 0);
			self->emit(&luaEvent);
		}
	}
	return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'emit'.", &tolua_err);
	return 0;
#endif
}

int Node_slot(lua_State* L) {
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(L, 1, "Node"_slice, 0, &tolua_err) || !tolua_isstring(L, 2, 0, &tolua_err) || !(tolua_isfunction(L, 3, &tolua_err) || lua_isnil(L, 3) || tolua_isnoobj(L, 3, &tolua_err)) || !tolua_isnoobj(L, 4, &tolua_err)) {
		goto tolua_lerror;
	} else
#endif
	{
		Node* self = r_cast<Node*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Node_slot'", nullptr);
#endif
		Slice name = tolua_toslice(L, 2, 0);
		if (tolua_isfunction(L, 3)) {
			int handler = tolua_ref_function(L, 3);
			self->slot(name, LuaFunction<void>(handler));
			return 0;
		} else if (lua_isnil(L, 3)) {
			self->slot(name, nullptr);
			return 0;
		} else
			tolua_pushusertype(L, self->slot(name), LuaType<Slot>());
	}
	return 1;
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'slot'.", &tolua_err);
	return 0;
#endif
}

int Node_gslot(lua_State* L) {
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Node"_slice, 0, &tolua_err) || !(tolua_isstring(L, 2, 0, &tolua_err) || tolua_isusertype(L, 2, "GSlot", 0, &tolua_err)) || !(tolua_isfunction(L, 3, &tolua_err) || lua_isnil(L, 3) || tolua_isnoobj(L, 3, &tolua_err)) || !tolua_isnoobj(L, 4, &tolua_err)) {
		goto tolua_lerror;
	} else
#endif
	{
		Node* self = r_cast<Node*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Node_gslot'", NULL);
#endif
		if (lua_isstring(L, 2)) {
			Slice name = tolua_toslice(L, 2, 0);
			if (tolua_isfunction(L, 3)) { // set
				int handler = tolua_ref_function(L, 3);
				Listener* listener = self->gslot(name, LuaFunction<void>(handler));
				tolua_pushobject(L, listener);
				return 1;
			} else if (lua_gettop(L) < 3) { // get
				RefVector<Listener> gslots = self->gslot(name);
				if (!gslots.empty()) {
					int size = s_cast<int>(gslots.size());
					lua_createtable(L, size, 0);
					for (int i = 0; i < size; i++) {
						tolua_pushobject(L, gslots[i]);
						lua_rawseti(L, -2, i + 1);
					}
				} else
					lua_pushnil(L);
				return 1;
			} else if (lua_isnil(L, 3)) { // del
				self->gslot(name, nullptr);
				return 0;
			}
		} else {
			Listener* listener = r_cast<Listener*>(tolua_tousertype(L, 2, 0));
			self->gslot(listener, nullptr);
			return 0;
		}
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'gslot'.", &tolua_err);
#endif
	return 0;
}

bool Node_eachChild(Node* self, const LuaFunction<bool>& func) {
	int index = 0;
	return self->eachChild([&](Node* child) {
		return func(child, ++index);
	});
}

static TextureWrap toTextureWrap(lua_State* L, String value) {
	switch (Switch::hash(value)) {
		case "None"_hash: return TextureWrap::None;
		case "Mirror"_hash: return TextureWrap::Mirror;
		case "Clamp"_hash: return TextureWrap::Clamp;
		case "Border"_hash: return TextureWrap::Border;
		default:
			luaL_error(L, fmt::format("Texture wrap \"{}\" is invalid, only \"None\", \"Mirror\", \"Clamp\", \"Border\" are allowed.", value.toString()).c_str());
			break;
	}
	return TextureWrap::None;
}

static Slice getTextureWrap(TextureWrap value) {
	switch (value) {
		case TextureWrap::None: return "None"_slice;
		case TextureWrap::Mirror: return "Mirror"_slice;
		case TextureWrap::Clamp: return "Clamp"_slice;
		case TextureWrap::Border: return "Border"_slice;
		default: return "None"_slice;
	}
}

int Sprite_GetUWrap(lua_State* L) {
	Sprite* self = r_cast<Sprite*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in accessing variable 'Sprite_GetUWrap'", nullptr);
#endif
	tolua_pushslice(L, getTextureWrap(self->getUWrap()));
	return 1;
}

int Sprite_SetUWrap(lua_State* L) {
	Sprite* self = r_cast<Sprite*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in accessing variable 'Sprite_SetUWrap'", nullptr);
#endif
	auto value = GetString(L, 2);
	self->setUWrap(toTextureWrap(L, value));
	return 0;
}

int Sprite_GetVWrap(lua_State* L) {
	Sprite* self = r_cast<Sprite*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in accessing variable 'Sprite_GetVWrap'", nullptr);
#endif
	tolua_pushslice(L, getTextureWrap(self->getVWrap()));
	return 1;
}

int Sprite_SetVWrap(lua_State* L) {
	Sprite* self = r_cast<Sprite*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in accessing variable 'Sprite_SetVWrap'", nullptr);
#endif
	auto value = GetString(L, 2);
	self->setVWrap(toTextureWrap(L, value));
	return 0;
}

int Sprite_GetTextureFilter(lua_State* L) {
	Sprite* self = r_cast<Sprite*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in accessing variable 'Sprite_GetTextureFilter'", nullptr);
#endif
	switch (self->getFilter()) {
		case TextureFilter::None: tolua_pushslice(L, "None"_slice);
		case TextureFilter::Point: tolua_pushslice(L, "Point"_slice);
		case TextureFilter::Anisotropic: tolua_pushslice(L, "Anisotropic"_slice);
		default: tolua_pushslice(L, "None"_slice);
	}
	return 1;
}

int Sprite_SetTextureFilter(lua_State* L) {
	Sprite* self = r_cast<Sprite*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in accessing variable 'Sprite_SetTextureFilter'", nullptr);
#endif
	auto value = GetString(L, 2);
	switch (Switch::hash(value)) {
		case "None"_hash: self->setFilter(TextureFilter::None); break;
		case "Point"_hash: self->setFilter(TextureFilter::Point); break;
		case "Anisotropic"_hash: self->setFilter(TextureFilter::Anisotropic); break;
		default:
			luaL_error(L, fmt::format("Texture filter \"{}\" is invalid, only \"None\", \"Point\", \"Anisotropic\" are allowed.", value.toString()).c_str());
			break;
	}
	return 0;
}

int Sprite_GetClips(lua_State* L) {
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(L, 1, "Sprite", 0, &tolua_err) || !tolua_isslice(L, 2, 0, &tolua_err) || !tolua_isnoobj(L, 3, &tolua_err))
		goto tolua_lerror;
	else
#endif
	{
#ifndef TOLUA_RELEASE
		try {
#endif
			Slice filename = tolua_toslice(L, 2, nullptr);
			if (auto clipDef = SharedClipCache.load(filename)) {
				lua_newtable(L);
				for (const auto& pair : clipDef->rects) {
					tolua_pushslice(L, pair.first);
					LuaEngine::push(L, *pair.second);
					lua_rawset(L, -3);
				}
				return 1;
			} else {
				lua_pushnil(L);
				return 1;
			}
#ifndef TOLUA_RELEASE
		} catch (std::runtime_error& e) {
			luaL_error(L, e.what());
		}
#endif
	}
	return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Sprite_GetClips'.", &tolua_err);
	return 0;
#endif
}

/* TileNode */
int TileNode_GetTextureFilter(lua_State* L) {
	TileNode* self = r_cast<TileNode*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in accessing variable 'Sprite_GetTextureFilter'", nullptr);
#endif
	switch (self->getFilter()) {
		case TextureFilter::None: tolua_pushslice(L, "None"_slice);
		case TextureFilter::Point: tolua_pushslice(L, "Point"_slice);
		case TextureFilter::Anisotropic: tolua_pushslice(L, "Anisotropic"_slice);
		default: tolua_pushslice(L, "None"_slice);
	}
	return 1;
}

int TileNode_SetTextureFilter(lua_State* L) {
	TileNode* self = r_cast<TileNode*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in accessing variable 'Sprite_SetTextureFilter'", nullptr);
#endif
	auto value = GetString(L, 2);
	switch (Switch::hash(value)) {
		case "None"_hash: self->setFilter(TextureFilter::None); break;
		case "Point"_hash: self->setFilter(TextureFilter::Point); break;
		case "Anisotropic"_hash: self->setFilter(TextureFilter::Anisotropic); break;
		default:
			luaL_error(L, fmt::format("Texture filter \"{}\" is invalid, only \"None\", \"Point\", \"Anisotropic\" are allowed.", value.toString()).c_str());
			break;
	}
	return 0;
}

/* Label */

int Label_GetTextAlign(lua_State* L) {
	Label* self = r_cast<Label*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in accessing variable 'Label_GetTextAlign'", nullptr);
#endif
	switch (self->getAlignment()) {
		case TextAlign::Left: tolua_pushslice(L, "Left"_slice);
		case TextAlign::Center: tolua_pushslice(L, "Center"_slice);
		case TextAlign::Right: tolua_pushslice(L, "Right"_slice);
		default: tolua_pushslice(L, "Left"_slice);
	}
	return 1;
}

int Label_SetTextAlign(lua_State* L) {
	Label* self = r_cast<Label*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in accessing variable 'Label_SetTextAlign'", nullptr);
#endif
	auto value = GetString(L, 2);
	switch (Switch::hash(value)) {
		case "Left"_hash: self->setAlignment(TextAlign::Left); break;
		case "Center"_hash: self->setAlignment(TextAlign::Center); break;
		case "Right"_hash: self->setAlignment(TextAlign::Right); break;
		default:
			luaL_error(L, fmt::format("Label text alignment \"{}\" is invalid, only \"Left\", \"Center\", \"Right\" are allowed.", value.toString()).c_str());
			break;
	}
	return 0;
}

/* DrawNode */

int DrawNode_drawVertices(lua_State* L) {
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(L, 1, "DrawNode"_slice, 0, &tolua_err) || !tolua_istable(L, 2, 0, &tolua_err) || !tolua_isnoobj(L, 3, &tolua_err))
		goto tolua_lerror;
	else
#endif
	{
		DrawNode* self = (DrawNode*)tolua_tousertype(L, 1, 0);
		int tolua_len = static_cast<int>(lua_rawlen(L, 2));
		std::vector<VertexColor> verts(tolua_len);
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'DrawNode.drawVertices'", nullptr);
#endif
#ifndef TOLUA_RELEASE
		if (!tolua_istablearray(L, 2, tolua_len, 0, &tolua_err))
			goto tolua_lerror;
		else
#endif
		{
			for (int i = 0; i < (int)tolua_len; i++) {
				lua_geti(L, 2, i + 1); // item
				lua_geti(L, -1, 1); // item Vec2
#ifndef TOLUA_RELEASE
				if (!tolua_isusertype(L, -1, "Vec2"_slice, 0, &tolua_err)) {
					goto tolua_lerror;
				}
#endif
				Vec2* vec = r_cast<Vec2*>(tolua_tousertype(L, -1, 0));
				lua_pop(L, 1); // item
				lua_geti(L, -1, 2); // item Color
#ifndef TOLUA_RELEASE
				if (!tolua_isusertype(L, -1, "Color"_slice, 0, &tolua_err)) {
					goto tolua_lerror;
				}
#endif
				Color* color = r_cast<Color*>(tolua_tousertype(L, -1, 0));
				lua_pop(L, 1); // item
				verts[i] = VertexColor(*vec, *color);
				lua_pop(L, 1); // clear
			}
			self->drawVertices(verts);
		}
	}
	return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'DrawNode.drawVertices'.", &tolua_err);
	return 0;
#endif
}

/* BlendFunc */

uint32_t getBlendFuncVal(String name) {
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
			Issue(
				"blendfunc name \"{}\" is invalid. use one of [One, Zero,\n"
				"SrcColor, SrcAlpha, DstColor, DstAlpha,\n"
				"InvSrcColor, InvSrcAlpha, InvDstColor, InvDstAlpha]",
				name.toString());
			break;
	}
	return BlendFunc::Zero;
}

BlendFunc* BlendFunc_create(String src, String dst) {
	return Mtolua_new((BlendFunc)({getBlendFuncVal(src), getBlendFuncVal(dst)}));
}

BlendFunc* BlendFunc_create(String srcC, String dstC, String srcA, String dstA) {
	return Mtolua_new((BlendFunc)({getBlendFuncVal(srcC), getBlendFuncVal(dstC), getBlendFuncVal(srcA), getBlendFuncVal(dstA)}));
}

uint32_t BlendFunc_get(String func) {
	return getBlendFuncVal(func);
}

namespace LuaAction {
static uint32_t toInteger(lua_State* L, int location, int index, bool useDefault = false) {
	lua_rawgeti(L, location, index);
	if (useDefault) {
		uint32_t number = s_cast<uint32_t>(tolua_tointeger(L, -1, 0));
		lua_pop(L, 1);
		return number;
	} else {
#ifndef TOLUA_RELEASE
		tolua_Error tolua_err;
		if (!tolua_isinteger(L, -1, 0, &tolua_err)) {
			tolua_error(L, "#ferror when reading action definition params.", &tolua_err);
			return 0;
		}
#endif
		uint32_t number = s_cast<uint32_t>(lua_tointeger(L, -1));
		lua_pop(L, 1);
		return number;
	}
}

static float toNumber(lua_State* L, int location, int index, bool useDefault = false) {
	lua_rawgeti(L, location, index);
	if (useDefault) {
		float number = s_cast<float>(tolua_tonumber(L, -1, 0));
		lua_pop(L, 1);
		return number;
	} else {
#ifndef TOLUA_RELEASE
		tolua_Error tolua_err;
		if (!tolua_isnumber(L, -1, 0, &tolua_err)) {
			tolua_error(L, "#ferror when reading action definition params.", &tolua_err);
			return 0.0f;
		}
#endif
		float number = s_cast<float>(lua_tonumber(L, -1));
		lua_pop(L, 1);
		return number;
	}
}

static Own<ActionDuration> create(lua_State* L, int location) {
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_istable(L, location, 0, &tolua_err)) {
		goto tolua_lerror;
	} else
#endif
	{
		if (location == -1) location = lua_gettop(L);
		int length = s_cast<int>(lua_rawlen(L, location));
		if (length > 0) {
			lua_rawgeti(L, location, 1);
			tolua_Error tolua_err;
			if (tolua_isslice(L, -1, 0, &tolua_err)) {
				Slice name = tolua_toslice(L, -1, nullptr);
				lua_pop(L, 1);
				size_t nameHash = Switch::hash(name);
				switch (nameHash) {
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
					case "Opacity"_hash: {
						float duration = toNumber(L, location, 2);
						float start = toNumber(L, location, 3);
						float stop = toNumber(L, location, 4);
						Ease::Enum ease = s_cast<Ease::Enum>(s_cast<int>(toNumber(L, location, 5, true)));
						Property::Enum prop = Property::X;
						switch (nameHash) {
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
					case "Tint"_hash: {
						float duration = toNumber(L, location, 2);
						uint32_t start = toInteger(L, location, 3);
						uint32_t stop = toInteger(L, location, 4);
						Ease::Enum ease = s_cast<Ease::Enum>(s_cast<int>(toNumber(L, location, 5, true)));
						return Tint::alloc(duration, Color3(start), Color3(stop), ease);
					}
					case "Roll"_hash: {
						float duration = toNumber(L, location, 2);
						float start = toNumber(L, location, 3);
						float stop = toNumber(L, location, 4);
						Ease::Enum ease = s_cast<Ease::Enum>(s_cast<int>(toNumber(L, location, 5, true)));
						return Roll::alloc(duration, start, stop, ease);
					}
					case "Hide"_hash: return Hide::alloc();
					case "Show"_hash: return Show::alloc();
					case "Delay"_hash: {
						float duration = toNumber(L, location, 2);
						return Delay::alloc(duration);
					}
					case "Event"_hash: {
						lua_rawgeti(L, location, 2);
						Slice name = tolua_toslice(L, -1, nullptr);
						lua_rawgeti(L, location, 3);
						Slice arg = tolua_toslice(L, -1, nullptr);
						lua_pop(L, 2);
						return Emit::alloc(name, arg);
					}
					case "Spawn"_hash: {
						std::vector<Own<ActionDuration>> actions(length - 1);
						for (int i = 2; i <= length; i++) {
							lua_rawgeti(L, location, i);
							actions[i - 2] = create(L, -1);
							lua_pop(L, 1);
						}
						return Spawn::alloc(actions);
					}
					case "Sequence"_hash: {
						std::vector<Own<ActionDuration>> actions(length - 1);
						for (int i = 2; i <= length; i++) {
							lua_rawgeti(L, location, i);
							actions[i - 2] = create(L, -1);
							lua_pop(L, 1);
						}
						return Sequence::alloc(std::move(actions));
					}
					case "Frame"_hash: {
						auto def = FrameActionDef::create();
						lua_rawgeti(L, location, 2);
						Slice clipStr = tolua_toslice(L, -1, nullptr);
						auto [tex, rect] = SharedClipCache.loadTexture(clipStr);
						if (!tex) {
							luaL_error(L, "invalid texture \"%s\" used for creating frame action.", clipStr.c_str().get());
						}
						if (rect.getHeight() > rect.getWidth()) {
							luaL_error(L, "invalid texture \"%s\" (height > width) used for creating frame action.", clipStr.c_str().get());
						}
						def->clipStr = clipStr.toString();
						auto totalFrames = s_cast<int>(rect.getWidth() / rect.getHeight());
						std::vector<Rect> rects(totalFrames);
						for (int i = 0; i < totalFrames; i++) {
							rects[i] = {rect.getX() + i * rect.getHeight(), rect.getY(), rect.getHeight(), rect.getHeight()};
						}
						float duration = toNumber(L, location, 3);
						def->duration = duration;
						lua_rawgeti(L, location, 4);
						if (lua_istable(L, -1)) {
							int lo = lua_gettop(L);
							if (!tolua_isintegerarray(L, lo, totalFrames, 0, &tolua_err)) {
								tolua_error(L, "#ferror in creating frame action.", &tolua_err);
							}
							for (int i = 0; i < totalFrames; i++) {
								auto count = tolua_tofieldinteger(L, lo, i + 1, 0);
								for (int c = 0; c < count; c++) {
									def->rects.push_back(New<Rect>(rects[i]));
								}
							}
						} else {
							for (const auto& rc : rects) {
								def->rects.push_back(New<Rect>(rc));
							}
						}
						lua_pop(L, 2);
						return FrameAction::alloc(def);
					}
					default: {
						luaL_error(L, "action named \"%s\" is not exist.", name.c_str().get());
						return Own<ActionDuration>();
					}
				}
			} else {
				tolua_error(L, "#ferror in function 'Action_create', reading action name.", &tolua_err);
				return Own<ActionDuration>();
			}
		}
#ifndef TOLUA_RELEASE
		else {
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
} // namespace LuaAction

/* Action */

int Action_create(lua_State* L) {
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertable(L, 1, "Action"_slice, 0, &tolua_err) || !tolua_istable(L, 2, 0, &tolua_err) || !tolua_isnoobj(L, 3, &tolua_err)) {
		goto tolua_lerror;
	} else
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

void __Model_getClipFile(lua_State* L, String filename) {
	if (ModelDef* modelDef = SharedModelCache.load(filename)) {
		const std::string& clipFile = modelDef->getClipFile();
		lua_pushlstring(L, clipFile.c_str(), clipFile.size());
	} else
		lua_pushnil(L);
}

void __Model_getLookNames(lua_State* L, String filename) {
	if (ModelDef* modelDef = SharedModelCache.load(filename)) {
		auto names = modelDef->getLookNames();
		int size = s_cast<int>(names.size());
		lua_createtable(L, size, 0);
		for (int i = 0; i < size; i++) {
			lua_pushlstring(L, names[i].c_str(), names[i].size());
			lua_rawseti(L, -2, i + 1);
		}
	} else {
		lua_createtable(L, 0, 0);
	}
}

void __Model_getAnimationNames(lua_State* L, String filename) {
	if (ModelDef* modelDef = SharedModelCache.load(filename)) {
		auto names = modelDef->getAnimationNames();
		int size = s_cast<int>(names.size());
		lua_createtable(L, size, 0);
		for (int i = 0; i < size; i++) {
			lua_pushlstring(L, names[i].c_str(), names[i].size());
			lua_rawseti(L, -2, i + 1);
		}
	} else {
		lua_createtable(L, 0, 0);
	}
}

/* Spine */

void __Spine_getLookNames(lua_State* L, String spineStr) {
	auto skelData = SharedSkeletonCache.load(spineStr);
	if (skelData) {
		auto& skins = skelData->getSkel()->getSkins();
		int size = s_cast<int>(skins.size());
		lua_createtable(L, size, 0);
		for (int i = 0; i < size; i++) {
			const auto& name = skins[i]->getName();
			lua_pushlstring(L, name.buffer(), name.length());
			lua_rawseti(L, -2, i + 1);
		}
	} else {
		lua_createtable(L, 0, 0);
	}
}

void __Spine_getAnimationNames(lua_State* L, String spineStr) {
	auto skelData = SharedSkeletonCache.load(spineStr);
	if (skelData) {
		auto& anims = skelData->getSkel()->getAnimations();
		int size = s_cast<int>(anims.size());
		lua_createtable(L, size, 0);
		for (int i = 0; i < size; i++) {
			const auto& name = anims[i]->getName();
			lua_pushlstring(L, name.buffer(), name.length());
			lua_rawseti(L, -2, i + 1);
		}
	} else {
		lua_createtable(L, 0, 0);
	}
}

int Spine_containsPoint(lua_State* L) {
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Spine"_slice, 0, &tolua_err) || !tolua_isnumber(L, 2, 0, &tolua_err) || !tolua_isnumber(L, 3, 0, &tolua_err) || !tolua_isnoobj(L, 4, &tolua_err)) {
		goto tolua_lerror;
	} else
#endif
	{
		Spine* self = r_cast<Spine*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in accessing variable 'Spine_containsPoint'", nullptr);
#endif
		float x = s_cast<float>(lua_tonumber(L, 2));
		float y = s_cast<float>(lua_tonumber(L, 3));
		auto result = self->containsPoint(x, y);
		if (result.empty())
			lua_pushnil(L);
		else
			tolua_pushslice(L, result);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Spine_containsPoint'.", &tolua_err);
	return 0;
#endif
}

int Spine_intersectsSegment(lua_State* L) {
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Spine"_slice, 0, &tolua_err) || !tolua_isnumber(L, 2, 0, &tolua_err) || !tolua_isnumber(L, 3, 0, &tolua_err) || !tolua_isnumber(L, 4, 0, &tolua_err) || !tolua_isnumber(L, 5, 0, &tolua_err) || !tolua_isnoobj(L, 6, &tolua_err)) {
		goto tolua_lerror;
	} else
#endif
	{
		Spine* self = r_cast<Spine*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in accessing variable 'Spine_intersectsSegment'", nullptr);
#endif
		float x1 = s_cast<float>(lua_tonumber(L, 2));
		float y1 = s_cast<float>(lua_tonumber(L, 3));
		float x2 = s_cast<float>(lua_tonumber(L, 4));
		float y2 = s_cast<float>(lua_tonumber(L, 5));
		auto result = self->intersectsSegment(x1, y1, x2, y2);
		if (result.empty())
			lua_pushnil(L);
		else
			tolua_pushslice(L, result);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Spine_intersectsSegment'.", &tolua_err);
	return 0;
#endif
}

/* DragonBone */

void __DragonBone_getLookNames(lua_State* L, String boneStr) {
	auto boneData = SharedDragonBoneCache.load(boneStr);
	if (boneData.first) {
		if (boneData.second.empty()) {
			boneData.second = boneData.first->getArmatureNames().front();
		}
		const auto& skins = boneData.first->getArmature(boneData.second)->skins;
		int size = s_cast<int>(skins.size());
		lua_createtable(L, size, 0);
		int i = 0;
		for (const auto& item : skins) {
			lua_pushlstring(L, item.first.c_str(), item.first.size());
			lua_rawseti(L, -2, i + 1);
			i++;
		}
	} else {
		lua_createtable(L, 0, 0);
	}
}

void __DragonBone_getAnimationNames(lua_State* L, String boneStr) {
	auto boneData = SharedDragonBoneCache.load(boneStr);
	if (boneData.first) {
		if (boneData.second.empty()) {
			boneData.second = boneData.first->getArmatureNames().front();
		}
		const auto& anims = boneData.first->getArmature(boneData.second)->animationNames;
		int size = s_cast<int>(anims.size());
		lua_createtable(L, size, 0);
		for (int i = 0; i < size; i++) {
			const auto& name = anims[i];
			lua_pushlstring(L, name.c_str(), name.size());
			lua_rawseti(L, -2, i + 1);
		}
	} else {
		lua_createtable(L, 0, 0);
	}
}

int DragonBone_containsPoint(lua_State* L) {
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "DragonBone"_slice, 0, &tolua_err) || !tolua_isnumber(L, 2, 0, &tolua_err) || !tolua_isnumber(L, 3, 0, &tolua_err) || !tolua_isnoobj(L, 4, &tolua_err)) {
		goto tolua_lerror;
	} else
#endif
	{
		DragonBone* self = r_cast<DragonBone*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in accessing variable 'DragonBone_containsPoint'", nullptr);
#endif
		float x = s_cast<float>(lua_tonumber(L, 2));
		float y = s_cast<float>(lua_tonumber(L, 3));
		auto result = self->containsPoint(x, y);
		if (result.empty())
			lua_pushnil(L);
		else
			tolua_pushslice(L, result);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'DragonBone_containsPoint'.", &tolua_err);
	return 0;
#endif
}

int DragonBone_intersectsSegment(lua_State* L) {
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "DragonBone"_slice, 0, &tolua_err) || !tolua_isnumber(L, 2, 0, &tolua_err) || !tolua_isnumber(L, 3, 0, &tolua_err) || !tolua_isnumber(L, 4, 0, &tolua_err) || !tolua_isnumber(L, 5, 0, &tolua_err) || !tolua_isnoobj(L, 6, &tolua_err)) {
		goto tolua_lerror;
	} else
#endif
	{
		DragonBone* self = r_cast<DragonBone*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in accessing variable 'DragonBone_intersectsSegment'", nullptr);
#endif
		float x1 = s_cast<float>(lua_tonumber(L, 2));
		float y1 = s_cast<float>(lua_tonumber(L, 3));
		float x2 = s_cast<float>(lua_tonumber(L, 4));
		float y2 = s_cast<float>(lua_tonumber(L, 5));
		auto result = self->intersectsSegment(x1, y1, x2, y2);
		if (result.empty())
			lua_pushnil(L);
		else
			tolua_pushslice(L, result);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'DragonBone_intersectsSegment'.", &tolua_err);
	return 0;
#endif
}

/* BodyDef */

int BodyDef_GetType(lua_State* L) {
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

int BodyDef_SetType(lua_State* L) {
	BodyDef* self = r_cast<BodyDef*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in function 'BodyDef_SetType'", nullptr);
#endif
	auto value = GetString(L, 2);
	switch (Switch::hash(value)) {
		case "Static"_hash: self->setType(pr::BodyType::Static); break;
		case "Dynamic"_hash: self->setType(pr::BodyType::Dynamic); break;
		case "Kinematic"_hash: self->setType(pr::BodyType::Kinematic); break;
		default:
			luaL_error(L, fmt::format("Body type \"{}\" is invalid, only \"Static\", \"Dynamic\", \"Kinematic\" are allowed.", value.toString()).c_str());
			break;
	}
	return 0;
}

/* Dictionary */

int Dictionary_getKeys(lua_State* L) {
	Dictionary* self = r_cast<Dictionary*>(tolua_tousertype(L, 1, 0));
	pushVectorString(L, self->getKeys());
	return 1;
}

int Dictionary_get(lua_State* L) {
	/* 1 self, 2 key */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Dictionary"_slice, 0, &tolua_err) || !tolua_isslice(L, 2, 0, &tolua_err) || !tolua_isnoobj(L, 3, &tolua_err)) {
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
		if (value)
			value->pushToLua(L);
		else
			lua_pushnil(L);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Dictionary_get'.", &tolua_err);
	return 0;
#endif
}

static Own<Value> Dora_getValue(lua_State* L, int loc) {
	if (!lua_isnil(L, loc)) {
		if (lua_isinteger(L, loc)) {
			return Value::alloc(lua_tointeger(L, loc));
		} else if (lua_isnumber(L, loc)) {
			return Value::alloc(lua_tonumber(L, loc));
		} else if (lua_isboolean(L, loc)) {
			return Value::alloc(lua_toboolean(L, loc) != 0);
		} else if (lua_isstring(L, loc)) {
			return Value::alloc(tolua_toslice(L, loc, nullptr).toString());
		} else if (lua_isthread(L, loc)) {
			return Value::alloc(LuaHandler::create(tolua_ref_function(L, loc)));
		} else if (tolua_isobject(L, loc)) {
			return Value::alloc(r_cast<Object*>(tolua_tousertype(L, loc, 0)));
		} else {
			auto name = tolua_typename(L, loc);
			lua_pop(L, 1);
			switch (Switch::hash(name)) {
				case "Vec2"_hash:
					return Value::alloc(tolua_tolight(L, loc).value);
				case "Size"_hash:
					return Value::alloc(*r_cast<Size*>(tolua_tousertype(L, loc, 0)));
				default:
#ifndef TOLUA_RELEASE
					tolua_error(L, "Can only store number, boolean, string, thread, Object, Vec2, Size in containers.", nullptr);
#endif // TOLUA_RELEASE
					break;
			}
		}
	}
	return nullptr;
}

int Dictionary_set(lua_State* L) {
	/* 1 self, 2 key, 3 value */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Dictionary"_slice, 0, &tolua_err) || !tolua_isslice(L, 2, 0, &tolua_err) || !tolua_isnoobj(L, 4, &tolua_err)) {
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
		if (value)
			self->set(key, std::move(value));
		else
			self->remove(key);
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Dictionary_set'.", &tolua_err);
	return 0;
#endif
}

/* Array */

int Array_getFirst(lua_State* L) {
	Array* self = r_cast<Array*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in function 'Array_getFirst'", nullptr);
#endif
	if (self->isEmpty()) {
		tolua_error(L, "'Array' indexing out of bound", nullptr);
	}
#ifndef TOLUA_RELEASE
	try {
#endif
		self->getFirst()->pushToLua(L);
#ifndef TOLUA_RELEASE
	} catch (std::runtime_error& e) {
		luaL_error(L, e.what());
	}
#endif
	return 1;
}

int Array_getLast(lua_State* L) {
	Array* self = r_cast<Array*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in function 'Array_getLast'", nullptr);
#endif
	if (self->isEmpty()) {
		tolua_error(L, "'Array' indexing out of bound", nullptr);
	}
#ifndef TOLUA_RELEASE
	try {
#endif
		self->getLast()->pushToLua(L);
#ifndef TOLUA_RELEASE
	} catch (std::runtime_error& e) {
		luaL_error(L, e.what());
	}
#endif
	return 1;
}

int Array_getRandomObject(lua_State* L) {
	Array* self = r_cast<Array*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
	if (!self) tolua_error(L, "invalid 'self' in function 'Array_getRandomObject'", nullptr);
#endif
	if (self->isEmpty()) {
		tolua_error(L, "'Array' indexing out of bound", nullptr);
	}
#ifndef TOLUA_RELEASE
	try {
#endif
		self->getRandomObject()->pushToLua(L);
#ifndef TOLUA_RELEASE
	} catch (std::runtime_error& e) {
		luaL_error(L, e.what());
	}
#endif
	return 1;
}

int Array_index(lua_State* L) {
	/* 1 self, 2 value */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Array"_slice, 0, &tolua_err) || !tolua_isnoobj(L, 3, &tolua_err)) {
		goto tolua_lerror;
	}
#endif
	{
		Array* self = r_cast<Array*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Array_index'", nullptr);
#endif
		auto value = Dora_getValue(L, 2);
#ifndef TOLUA_RELEASE
		try {
#endif
			lua_Integer index = s_cast<lua_Integer>(self->index(value.get()) + 1);
			lua_pushinteger(L, index);
			return 1;
#ifndef TOLUA_RELEASE
		} catch (std::runtime_error& e) {
			luaL_error(L, e.what());
		}
#endif
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Array_index'.", &tolua_err);
	return 0;
#endif
}

int Array_set(lua_State* L) {
	/* 1 self, 2 index, 3 value */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Array"_slice, 0, &tolua_err) || !tolua_isnumber(L, 2, 0, &tolua_err) || !tolua_isnoobj(L, 4, &tolua_err)) {
		goto tolua_lerror;
	}
#endif
	{
		Array* self = r_cast<Array*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Array_set'", nullptr);
#endif
		int index = s_cast<int>(tolua_tonumber(L, 2, 0)) - 1;
		if (index < 0 || s_cast<int>(self->getCount()) <= index) {
			tolua_error(L, "'Array' indexing out of bound", nullptr);
		}
		auto value = Dora_getValue(L, 3);
		self->set(index, std::move(value));
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Array_set'.", &tolua_err);
	return 0;
#endif
}

int Array_get(lua_State* L) {
	/* 1 self, 2 index */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Array"_slice, 0, &tolua_err) || !tolua_isnumber(L, 2, 0, &tolua_err) || !tolua_isnoobj(L, 3, &tolua_err)) {
		goto tolua_lerror;
	}
#endif
	{
		Array* self = r_cast<Array*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Array_get'", nullptr);
#endif
		int index = s_cast<int>(tolua_tonumber(L, 2, 0)) - 1;
		if (index < 0 || s_cast<int>(self->getCount()) <= index) {
			tolua_error(L, "'Array' indexing out of bound", nullptr);
		}
		const auto& value = self->get(index);
		if (value)
			value->pushToLua(L);
		else
			lua_pushnil(L);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Array_get'.", &tolua_err);
	return 0;
#endif
}

int Array_insert(lua_State* L) {
	/* 1 self, 2 index, 3 value */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Array"_slice, 0, &tolua_err) || !tolua_isnumber(L, 2, 0, &tolua_err) || !tolua_isnoobj(L, 4, &tolua_err)) {
		goto tolua_lerror;
	}
#endif
	{
		Array* self = r_cast<Array*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Array_insert'", nullptr);
#endif
		int index = s_cast<int>(tolua_tonumber(L, 2, 0)) - 1;
		if (index < 0 || s_cast<int>(self->getCount()) <= index) {
			tolua_error(L, "'Array' indexing out of bound", nullptr);
		}
		auto value = Dora_getValue(L, 3);
		if (!value) tolua_error(L, "expecting value to insert, got nil", nullptr);
		self->insert(index, std::move(value));
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Array_insert'.", &tolua_err);
	return 0;
#endif
}

int Array_fastRemove(lua_State* L) {
	/* 1 self, 2 value */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Array"_slice, 0, &tolua_err) || !tolua_isnoobj(L, 3, &tolua_err)) {
		goto tolua_lerror;
	}
#endif
	{
		Array* self = r_cast<Array*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Array_fastRemove'", nullptr);
#endif
		auto value = Dora_getValue(L, 2);
		if (!value) tolua_error(L, "expecting value to remove, got nil", nullptr);
		bool result = self->fastRemove(value.get());
		lua_pushboolean(L, result ? 1 : 0);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Array_fastRemove'.", &tolua_err);
	return 0;
#endif
}

int Array_add(lua_State* L) {
	/* 1 self, 2 value */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Array"_slice, 0, &tolua_err) || !tolua_isnoobj(L, 3, &tolua_err)) {
		goto tolua_lerror;
	}
#endif
	{
		Array* self = r_cast<Array*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Array_add'", nullptr);
#endif
		auto value = Dora_getValue(L, 2);
		if (!value) tolua_error(L, "expecting value to add, got nil", nullptr);
		self->add(std::move(value));
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Array_add'.", &tolua_err);
	return 0;
#endif
}

int Array_contains(lua_State* L) {
	/* 1 self, 2 value */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Array"_slice, 0, &tolua_err) || !tolua_isnoobj(L, 3, &tolua_err)) {
		goto tolua_lerror;
	}
#endif
	{
		Array* self = r_cast<Array*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Array_contains'", nullptr);
#endif
		auto value = Dora_getValue(L, 2);
		if (!value) tolua_error(L, "expecting value to search, got nil", nullptr);
		lua_pushboolean(L, self->contains(value.get()) ? 1 : 0);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Array_fastRemove'.", &tolua_err);
	return 0;
#endif
}

int Array_removeLast(lua_State* L) {
	/* 1 self, 2 index */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Array"_slice, 0, &tolua_err) || !tolua_isnoobj(L, 2, &tolua_err)) {
		goto tolua_lerror;
	}
#endif
	{
		Array* self = r_cast<Array*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Array_removeLast'", nullptr);
#endif
		if (self->isEmpty()) {
			lua_pushnil(L);
			return 1;
		}
		auto value = self->removeLast();
		if (value)
			value->pushToLua(L);
		else
			lua_pushnil(L);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Array_removeLast'.", &tolua_err);
	return 0;
#endif
}

int Array_create(lua_State* L) {
	tolua_Error tolua_err;
#ifndef TOLUA_RELEASE
	if (!tolua_isusertable(L, 1, "Array"_slice, 0, &tolua_err)) {
		goto tolua_lerror;
	} else
#endif
	{
		if (tolua_isusertype(L, 2, "Array"_slice, 0, &tolua_err) && tolua_isnoobj(L, 3, &tolua_err)) {
			Array* other = r_cast<Array*>(tolua_tousertype(L, 2, 0));
#ifndef TOLUA_RELEASE
			try {
#endif
				Array* tolua_ret = Array::create(other);
				tolua_pushobject(L, tolua_ret);
#ifndef TOLUA_RELEASE
			} catch (std::runtime_error& e) {
				luaL_error(L, e.what());
			}
#endif
			return 1;
		} else if (tolua_istable(L, 2, 0, &tolua_err) && tolua_isnoobj(L, 3, &tolua_err)) {
			int tolua_len = s_cast<int>(lua_rawlen(L, 2));
			Array* tolua_ret = Array::create(tolua_len);
			for (int i = 0; i < tolua_len; i++) {
				lua_pushnumber(L, i + 1);
				lua_gettable(L, 2);
				auto value = Dora_getValue(L, -1);
				if (!value) luaL_error(L, "got nil from table index %d, value expected", i + 1);
				tolua_ret->add(std::move(value));
				lua_pop(L, 1);
			}
			tolua_pushobject(L, tolua_ret);
			return 1;
		} else if (tolua_isnoobj(L, 3, &tolua_err)) {
			Array* tolua_ret = Array::create();
			tolua_pushobject(L, tolua_ret);
			return 1;
		}
#ifndef TOLUA_RELEASE
		else {
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

int Entity_get(lua_State* L) {
	/* 1 self, 2 name */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Entity"_slice, 0, &tolua_err) || !tolua_isinteger(L, 2, 0, &tolua_err)) {
		goto tolua_lerror;
	}
#endif
	{
		Entity* self = r_cast<Entity*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Entity_get'", nullptr);
#endif
		int index = s_cast<int>(lua_tointeger(L, 2));
		Value* com = self->getComponent(index);
		if (com)
			com->pushToLua(L);
		else
			lua_pushnil(L);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Entity_get'.", &tolua_err);
	return 0;
#endif
}

int Entity_getOld(lua_State* L) {
	/* 1 self, 2 name */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Entity"_slice, 0, &tolua_err) || !tolua_isinteger(L, 2, 0, &tolua_err)) {
		goto tolua_lerror;
	}
#endif
	{
		Entity* self = r_cast<Entity*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Entity_getOld'", nullptr);
#endif
		int index = s_cast<int>(lua_tointeger(L, 2));
		Value* com = self->getOldCom(index);
		if (com)
			com->pushToLua(L);
		else
			lua_pushnil(L);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Entity_getOld'.", &tolua_err);
	return 0;
#endif
}

static void entitySet(Entity* self, int index, lua_State* L, int loc) {
	if (lua_isinteger(L, loc)) {
		self->set(index, lua_tointeger(L, loc));
	} else if (lua_isnumber(L, loc)) {
		self->set(index, lua_tonumber(L, loc));
	} else if (lua_isboolean(L, loc)) {
		self->set(index, lua_toboolean(L, loc) != 0);
	} else if (lua_isstring(L, loc)) {
		self->set(index, tolua_toslice(L, loc, nullptr).toString());
	} else if (tolua_isobject(L, loc)) {
		self->set(index, s_cast<Object*>(tolua_tousertype(L, loc, 0)));
	} else {
		auto name = tolua_typename(L, loc);
		lua_pop(L, 1);
		switch (Switch::hash(name)) {
			case "Vec2"_hash:
				self->set(index, tolua_tolight(L, loc).value);
				break;
			case "Size"_hash:
				self->set(index, *r_cast<Size*>(tolua_tousertype(L, loc, 0)));
				break;
			default:
#ifndef TOLUA_RELEASE
				tolua_error(L, "Entity can only store number, boolean, string, Object, Vec2, Size, Rect in containers.", nullptr);
#endif // TOLUA_RELEASE
				break;
		}
	}
}

int Entity_set(lua_State* L) {
	/* 1 self, 2 name, 3 value */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Entity"_slice, 0, &tolua_err) || !tolua_isinteger(L, 2, 0, &tolua_err)) {
		goto tolua_lerror;
	}
#endif
	{
		Entity* self = r_cast<Entity*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'Entity_setNext'", nullptr);
#endif
		int comIndex = s_cast<int>(lua_tointeger(L, 2));
#ifndef TOLUA_RELEASE
		try {
#endif
			if (lua_isnil(L, 3)) {
				self->remove(comIndex);
			} else
				entitySet(self, comIndex, L, 3);
#ifndef TOLUA_RELEASE
		} catch (std::runtime_error& e) {
			luaL_error(L, e.what());
		}
#endif
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Entity_setNext'.", &tolua_err);
	return 0;
#endif
}

int Entity_create(lua_State* L) {
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertable(L, 1, "Entity"_slice, 0, &tolua_err) || !tolua_istable(L, 2, 0, &tolua_err) || !tolua_isnoobj(L, 3, &tolua_err)) {
		goto tolua_lerror;
	} else
#endif
	{
		Entity* self = Entity::create();
		lua_pushnil(L);
		while (lua_next(L, 2)) {
			lua_pushvalue(L, -2);
			if (lua_isinteger(L, -1)) {
				auto index = lua_tointeger(L, -1);
				entitySet(self, index, L, -2);
			}
			lua_pop(L, 2);
		}
		tolua_pushobject(L, self);
	}
	return 1;
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Entity.new'.", &tolua_err);
	return 0;
#endif
}

/* EntityGroup */

int EntityGroup_watch(lua_State* L) {
	/* 1 self, 2 handler */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "EntityGroup"_slice, 0, &tolua_err)
		|| !tolua_isfunction(L, 2, &tolua_err)
		|| !tolua_isnoobj(L, 3, &tolua_err)) {
		goto tolua_lerror;
	}
#endif
	{
		EntityGroup* self = r_cast<EntityGroup*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'EntityGroup_every'", nullptr);
#endif
#ifndef TOLUA_RELEASE
		try {
#endif
			auto handler = LuaHandler::create(tolua_ref_function(L, 2));
			self->watch(handler);
			tolua_pushobject(L, self);
			return 1;
#ifndef TOLUA_RELEASE
		} catch (std::runtime_error& e) {
			luaL_error(L, e.what());
		}
#endif
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'EntityGroup_every'.", &tolua_err);
	return 0;
#endif
	return 0;
}

/* EntityObserver */

EntityObserver* EntityObserver_create(String option, Slice components[], int count) {
	int optionVal = 0;
	switch (Switch::hash(option)) {
		case "Add"_hash: optionVal = Entity::Add; break;
		case "Change"_hash: optionVal = Entity::Change; break;
		case "Remove"_hash: optionVal = Entity::Remove; break;
		case "AddOrChange"_hash: optionVal = Entity::AddOrChange; break;
		default:
			Issue("EntityObserver option name \"{}\" is invalid.", option.toString());
			break;
	}
	return EntityObserver::create(optionVal, components, count);
}

int EntityObserver_watch(lua_State* L) {
	/* 1 self, 2 handler */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "EntityObserver"_slice, 0, &tolua_err)
		|| !tolua_isfunction(L, 2, &tolua_err)
		|| !tolua_isnoobj(L, 3, &tolua_err)) {
		goto tolua_lerror;
	}
#endif
	{
		EntityObserver* self = r_cast<EntityObserver*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'EntityObserver_every'", nullptr);
#endif
#ifndef TOLUA_RELEASE
		try {
#endif
			auto handler = LuaHandler::create(tolua_ref_function(L, 2));
			self->watch(handler);
			tolua_pushobject(L, self);
			return 1;
#ifndef TOLUA_RELEASE
		} catch (std::runtime_error& e) {
			luaL_error(L, e.what());
		}
#endif
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'EntityObserver_every'.", &tolua_err);
	return 0;
#endif
	return 0;
}

/* QLearner */
int QLearner_pack(lua_State* L) {
	/* 1 class, 2 table, 3 table */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertable(L, 1, "ML::QLearner"_slice, 0, &tolua_err)
		|| !tolua_istable(L, 2, 0, &tolua_err)
		|| !tolua_istable(L, 3, 0, &tolua_err)
		|| !tolua_isnoobj(L, 4, &tolua_err)) {
		goto tolua_lerror;
	}
#endif
	{
		int hintsCount = s_cast<int>(lua_rawlen(L, 2));
#ifndef TOLUA_RELEASE
		if (!tolua_isintegerarray(L, 2, hintsCount, 0, &tolua_err)) {
			goto tolua_lerror;
		}
#endif
		std::vector<uint32_t> hints;
		hints.resize(hintsCount);
		for (int i = 0; i < hintsCount; i++) {
			hints[i] = s_cast<uint32_t>(tolua_tofieldinteger(L, 2, i + 1, 0));
		}

		int valuesCount = s_cast<int>(lua_rawlen(L, 3));
#ifndef TOLUA_RELEASE
		if (!tolua_isintegerarray(L, 3, valuesCount, 0, &tolua_err)) {
			goto tolua_lerror;
		}
#endif
		std::vector<uint32_t> values;
		values.resize(valuesCount);
		for (int i = 0; i < valuesCount; i++) {
			values[i] = s_cast<uint32_t>(tolua_tofieldinteger(L, 3, i + 1, 0));
		}
		ML::QLearner::QState state = 0;
#ifndef TOLUA_RELEASE
		try {
#endif
			state = ML::QLearner::pack(hints, values);
#ifndef TOLUA_RELEASE
		} catch (std::runtime_error& e) {
			luaL_error(L, e.what());
		}
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

int QLearner_unpack(lua_State* L) {
	/* 1 class, 2 table, 3 integer */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertable(L, 1, "ML::QLearner"_slice, 0, &tolua_err)
		|| !tolua_istable(L, 2, 0, &tolua_err)
		|| !tolua_isinteger(L, 3, 0, &tolua_err)
		|| !tolua_isnoobj(L, 4, &tolua_err)) {
		goto tolua_lerror;
	}
#endif
	{
		int hintsCount = s_cast<int>(lua_rawlen(L, 2));
#ifndef TOLUA_RELEASE
		if (!tolua_isintegerarray(L, 2, hintsCount, 0, &tolua_err)) {
			goto tolua_lerror;
		}
#endif
		std::vector<uint32_t> hints;
		hints.resize(hintsCount);
		for (int i = 0; i < hintsCount; i++) {
			hints[i] = s_cast<uint32_t>(tolua_tofieldinteger(L, 2, i + 1, 0));
		}
		ML::QLearner::QState state = s_cast<ML::QLearner::QState>(lua_tointeger(L, 3));
		std::vector<uint32_t> values = ML::QLearner::unpack(hints, state);
		lua_createtable(L, hintsCount, 0);
		for (size_t i = 0; i < values.size(); i++) {
			lua_pushinteger(L, values[i]);
			lua_rawseti(L, -2, i + 1);
		}
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'QLearner_unpack'.", &tolua_err);
	return 0;
#endif
}

int QLearner_load(lua_State* L) {
	/* 1 self, 2 table */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "ML::QLearner"_slice, 0, &tolua_err)
		|| !tolua_istable(L, 2, 0, &tolua_err)
		|| !tolua_isnoobj(L, 3, &tolua_err)) {
		goto tolua_lerror;
	}
#endif
	{
		ML::QLearner* self = r_cast<ML::QLearner*>(tolua_tousertype(L, 1, 0));
		int size = s_cast<int>(lua_rawlen(L, 2));
#ifndef TOLUA_RELEASE
		if (!tolua_istablearray(L, 2, size, 0, &tolua_err)) {
			goto tolua_lerror;
		}
#endif
		for (int i = 0; i < size; i++) {
			lua_rawgeti(L, 2, i + 1);
			int index = lua_gettop(L);
#ifndef TOLUA_RELEASE
			if (!tolua_isnumberarray(L, index, 3, 0, &tolua_err)) {
				goto tolua_lerror;
			}
#endif
			lua_rawgeti(L, -1, 1);
			ML::QLearner::QState state = s_cast<ML::QLearner::QState>(lua_tointeger(L, -1));
			lua_pop(L, 1);
			lua_rawgeti(L, -1, 2);
			ML::QLearner::QAction action = s_cast<ML::QLearner::QAction>(lua_tointeger(L, -1));
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

int QLearner_getMatrix(lua_State* L) {
	/* 1 self */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "ML::QLearner"_slice, 0, &tolua_err)
		|| !tolua_isnoobj(L, 2, &tolua_err)) {
		goto tolua_lerror;
	}
#endif
	{
		ML::QLearner* self = r_cast<ML::QLearner*>(tolua_tousertype(L, 1, 0));
		const auto& matrix = self->getMatrix();
		int i = 0;
		lua_createtable(L, s_cast<int>(matrix.size()), 0);
		for (const auto& row : matrix) {
			lua_createtable(L, 3, 0);
			ML::QLearner::QState state = row.first;
			for (const auto& col : row.second) {
				ML::QLearner::QAction action = col.first;
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

/* DB */

static Own<Value> Dora_getDBValue(lua_State* L, int loc) {
	if (!lua_isnil(L, loc)) {
		if (lua_isinteger(L, loc)) {
			return Value::alloc(s_cast<int64_t>(lua_tointeger(L, loc)));
		} else if (lua_isnumber(L, loc)) {
			return Value::alloc(s_cast<double>(lua_tonumber(L, loc)));
		} else if (lua_isboolean(L, loc)) {
			if (lua_toboolean(L, loc) > 0) {
				tolua_error(L, "DB only accepts value of boolean false as NULL value.", nullptr);
			}
			return Value::alloc(false);
		} else if (lua_isstring(L, loc)) {
			return Value::alloc(tolua_toslice(L, loc, nullptr).toString());
		}
#ifndef TOLUA_RELEASE
		else {
			tolua_error(L, "Can only store number, string and boolean false as NULL in DB.", nullptr);
		}
#endif // TOLUA_RELEASE
	}
	return Value::alloc(false);
}

static int DB_transactionInner(lua_State* L, bool async) {
	/* 1 self, 2 table */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (async) {
		if (!tolua_isusertype(L, 1, "DB"_slice, 0, &tolua_err)
			|| !tolua_istable(L, 2, 0, &tolua_err)
			|| !tolua_isfunction(L, 3, &tolua_err)
			|| !tolua_isnoobj(L, 4, &tolua_err)) {
			goto tolua_lerror;
		}
	} else {
		if (!tolua_isusertype(L, 1, "DB"_slice, 0, &tolua_err)
			|| !tolua_istable(L, 2, 0, &tolua_err)
			|| !tolua_isnoobj(L, 3, &tolua_err)) {
			goto tolua_lerror;
		}
	}
#endif
	{
		DB* self = r_cast<DB*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'DB_transactionInner'", nullptr);
#endif
		struct SQLData {
			SQLData() { }
			SQLData(SQLData&& other)
				: sql(std::move(other.sql))
				, rows(std::move(other.rows)) { }
			std::string sql;
			std::deque<std::vector<Own<Value>>> rows;
		};
		auto sqls = std::make_shared<std::vector<SQLData>>();
		int itemCount = s_cast<int>(lua_rawlen(L, 2));
		sqls->resize(itemCount);
		for (int i = 0; i < itemCount; i++) {
			lua_rawgeti(L, 2, i + 1);
#ifndef TOLUA_RELEASE
			if (!tolua_isstring(L, -1, 0, &tolua_err)
				&& !tolua_istable(L, -1, 0, &tolua_err)) {
				goto tolua_lerror;
			}
#endif
			auto& sql = (*sqls)[i];
			if (lua_istable(L, -1) != 0) {
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
				sql.sql = tolua_toslice(L, strLoc, 0).toString();
				int argListSize = s_cast<int>(lua_rawlen(L, tableLoc));
				sql.rows.resize(argListSize);
				for (int j = 0; j < argListSize; j++) {
					lua_rawgeti(L, tableLoc, j + 1);
#ifndef TOLUA_RELEASE
					if (!tolua_istable(L, -1, 0, &tolua_err)) {
						goto tolua_lerror;
					}
#endif
					auto& args = sql.rows[j];
					int argSize = s_cast<int>(lua_rawlen(L, -1));
					args.resize(argSize);
					for (int k = 0; k < argSize; k++) {
						lua_rawgeti(L, -1, k + 1);
						args[k] = Dora_getDBValue(L, -1);
						lua_pop(L, 1);
					}
					lua_pop(L, 1);
				}
				lua_pop(L, 2);
			} else {
				sql.sql = tolua_toslice(L, -1, 0).toString();
			}
			lua_pop(L, 1);
		}
		if (async) {
			LuaFunction<void> callback(tolua_ref_function(L, 3));
			self->transactionAsync([sqls = std::move(sqls)](SQLite::Database* db) {
				for (const auto& sql : *sqls) {
					if (sql.rows.empty()) {
						DB::execUnsafe(db, sql.sql);
					} else {
						DB::execUnsafe(db, sql.sql, sql.rows);
					}
				}
			},
				callback);
			return 0;
		} else {
			bool result = self->transaction([&sqls](SQLite::Database* db) {
				for (const auto& sql : *sqls) {
					if (sql.rows.empty()) {
						DB::execUnsafe(db, sql.sql);
					} else {
						DB::execUnsafe(db, sql.sql, sql.rows);
					}
				}
			});
			lua_pushboolean(L, result ? 1 : 0);
			return 1;
		}
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'DB_transactionInner'.", &tolua_err);
	return 0;
#endif
}

int DB_transaction(lua_State* L) {
	return DB_transactionInner(L, false);
}

int DB_transactionAsync(lua_State* L) {
	return DB_transactionInner(L, true);
}

static void DB_colToLua(lua_State* L, const DB::Col& c) {
	if (std::holds_alternative<int64_t>(c)) {
		lua_pushinteger(L, s_cast<lua_Integer>(std::get<int64_t>(c)));
	} else if (std::holds_alternative<double>(c)) {
		lua_pushinteger(L, s_cast<lua_Number>(std::get<double>(c)));
	} else if (std::holds_alternative<std::string>(c)) {
		tolua_pushslice(L, std::get<std::string>(c));
	} else {
		lua_pushboolean(L, std::get<bool>(c) ? 1 : 0);
	}
}

int DB_query(lua_State* L) {
	/* 1 self, 2 sql, 3 args or noobj */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "DB"_slice, 0, &tolua_err)
		|| !tolua_isslice(L, 2, 0, &tolua_err)
		|| !(
			(
				tolua_isboolean(L, 3, 1, &tolua_err) && tolua_isnoobj(L, 4, &tolua_err))
			|| (tolua_istable(L, 3, 0, &tolua_err) && tolua_isboolean(L, 4, 1, &tolua_err) && tolua_isnoobj(L, 5, &tolua_err)))) {
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
		if (lua_istable(L, 3) != 0) {
			int size = s_cast<int>(lua_rawlen(L, 3));
			args.resize(size);
			for (int i = 0; i < size; i++) {
				lua_rawgeti(L, 3, i + 1);
				args[i] = Dora_getDBValue(L, -1);
				lua_pop(L, 1);
			}
			withColumns = tolua_toboolean(L, 4, 0);
		} else
			withColumns = tolua_toboolean(L, 3, 0) != 0;
#ifndef TOLUA_RELEASE
		try {
#endif
			auto result = self->query(sql, args, withColumns);
			if (result) {
				lua_createtable(L, s_cast<int>((*result).size()), 0);
				int i = 0;
				for (const auto& row : *result) {
					lua_createtable(L, s_cast<int>(row.size()), 0);
					int j = 0;
					for (const auto& col : row) {
						DB_colToLua(L, col);
						lua_rawseti(L, -2, ++j);
					}
					lua_rawseti(L, -2, ++i);
				}
			} else {
				lua_pushnil(L);
			}
			return 1;
#ifndef TOLUA_RELEASE
		} catch (std::exception& e) {
			luaL_error(L, e.what());
		}
#endif
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'DB_query'.", &tolua_err);
	return 0;
#endif
}

int DB_insert(lua_State* L) {
	/* 1 self, 2 tableName, 3 values */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "DB"_slice, 0, &tolua_err)
		|| !tolua_isslice(L, 2, 0, &tolua_err)
		|| !tolua_istable(L, 3, 0, &tolua_err)
		|| !tolua_isnoobj(L, 4, &tolua_err)) {
		goto tolua_lerror;
	}
#endif
	{
		DB* self = r_cast<DB*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'DB_insert'", nullptr);
#endif
		auto tableName = tolua_toslice(L, 2, nullptr);
		std::deque<std::vector<Own<Value>>> rows;
		int size = s_cast<int>(lua_rawlen(L, 3));
		rows.resize(size);
		for (int i = 0; i < size; i++) {
			lua_rawgeti(L, 3, i + 1);
#ifndef TOLUA_RELEASE
			if (lua_istable(L, -1) == 0) {
				tolua_error(L, "invalid row value in function 'DB_insert'", nullptr);
			}
#endif
			int colSize = s_cast<int>(lua_rawlen(L, -1));
			auto& row = rows[i];
			row.resize(colSize);
			for (int j = 0; j < colSize; j++) {
				lua_rawgeti(L, -1, j + 1);
				row[j] = Dora_getDBValue(L, -1);
				lua_pop(L, 1);
			}
			lua_pop(L, 1);
		}
		bool result = SharedDB.transaction([&](SQLite::Database* db) {
			DB::insertUnsafe(db, tableName, rows);
		});
		lua_pushboolean(L, result ? 1 : 0);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'DB_insert'.", &tolua_err);
	return 0;
#endif
}

int DB_exec(lua_State* L) {
	/* 1 self, 2 sql, 3 values or noobj */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "DB"_slice, 0, &tolua_err)
		|| !tolua_isslice(L, 2, 0, &tolua_err)
		|| !(
			tolua_isnoobj(L, 3, &tolua_err) || (tolua_istable(L, 3, 0, &tolua_err) && tolua_isnoobj(L, 4, &tolua_err)))) {
		goto tolua_lerror;
	}
#endif
	{
		DB* self = r_cast<DB*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'DB_exec'", nullptr);
#endif
		auto sql = tolua_toslice(L, 2, nullptr);
		std::deque<std::vector<Own<Value>>> rows;
		if (lua_istable(L, 3) != 0) {
			int rowCount = s_cast<int>(lua_rawlen(L, 3));
			if (rowCount == 0) {
				int rowChanged = self->exec(sql);
				lua_pushinteger(L, rowChanged);
				return 1;
			}
			lua_rawgeti(L, 3, 1);
			if (lua_istable(L, -1) == 0) {
				lua_pop(L, 1);
				std::vector<Own<Value>> args;
				args.resize(rowCount);
				for (int i = 0; i < rowCount; i++) {
					lua_rawgeti(L, 3, i + 1);
					args[i] = Dora_getDBValue(L, -1);
					lua_pop(L, 1);
				}
				int rowChanged = self->exec(sql, args);
				lua_pushinteger(L, rowChanged);
				return 1;
			}
			lua_pop(L, 1);
#ifndef TOLUA_RELEASE
			if (!tolua_istablearray(L, 3, rowCount, 0, &tolua_err)) {
				goto tolua_lerror;
			}
#endif
			for (int i = 0; i < rowCount; i++) {
				lua_rawgeti(L, 3, i + 1);
				auto& row = rows.emplace_back();
				int size = s_cast<int>(lua_rawlen(L, -1));
				row.resize(size);
				for (int j = 0; j < size; j++) {
					lua_rawgeti(L, -1, i + 1);
					row[i] = Dora_getDBValue(L, -1);
					lua_pop(L, 1);
				}
				lua_pop(L, 1);
			}
		}
		int rowChanged = 0;
		SharedDB.transaction([&](SQLite::Database* db) {
			rowChanged = DB::execUnsafe(db, sql, rows);
		});
		lua_pushinteger(L, rowChanged);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'DB_exec'.", &tolua_err);
	return 0;
#endif
}

int DB_queryAsync(lua_State* L) {
	/* 1 self, 2 func, 3 sql, (4 args, 5 col) or (4 col) */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "DB"_slice, 0, &tolua_err)
		|| !tolua_isfunction(L, 2, &tolua_err)
		|| !tolua_isslice(L, 3, 0, &tolua_err)
		|| !(
			(
				tolua_isboolean(L, 4, 1, &tolua_err) && tolua_isnoobj(L, 5, &tolua_err))
			|| (tolua_istable(L, 4, 0, &tolua_err) && tolua_isboolean(L, 5, 1, &tolua_err) && tolua_isnoobj(L, 6, &tolua_err)))) {
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
		if (lua_istable(L, 4) != 0) {
			int size = s_cast<int>(lua_rawlen(L, 4));
			args.resize(size);
			for (int i = 0; i < size; i++) {
				lua_rawgeti(L, 4, i + 1);
				args[i] = Dora_getDBValue(L, -1);
				lua_pop(L, 1);
			}
			withColumns = tolua_toboolean(L, 5, 0);
		} else
			withColumns = tolua_toboolean(L, 4, 0);
		self->queryAsync(sql, std::move(args), withColumns, [handler](const std::optional<DB::Rows>& result) {
			lua_State* L = SharedLuaEngine.getState();
			int top = lua_gettop(L);
			DEFER(lua_settop(L, top));
			if (result) {
				lua_createtable(L, s_cast<int>((*result).size()), 0);
				int i = 0;
				for (const auto& row : *result) {
					lua_createtable(L, s_cast<int>(row.size()), 0);
					int j = 0;
					for (const auto& col : row) {
						DB_colToLua(L, col);
						lua_rawseti(L, -2, ++j);
					}
					lua_rawseti(L, -2, ++i);
				}
			} else {
				lua_pushnil(L);
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

int DB_insertAsync(lua_State* L) {
	/* 1 self, 2 tableName, 3 values, 4 func */
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "DB"_slice, 0, &tolua_err)
		|| !tolua_isslice(L, 2, 0, &tolua_err)
		|| !tolua_istable(L, 3, 0, &tolua_err)
		|| !tolua_isfunction(L, 4, &tolua_err)
		|| !tolua_isnoobj(L, 5, &tolua_err)) {
		goto tolua_lerror;
	}
	{
		DB* self = r_cast<DB*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'DB_insertAsync'", nullptr);
#endif
		auto tableName = tolua_toslice(L, 2, nullptr);
		std::deque<std::vector<Own<Value>>> rows;
		int size = s_cast<int>(lua_rawlen(L, 3));
		rows.resize(size);
		for (int i = 0; i < size; i++) {
			lua_rawgeti(L, 3, i + 1);
#ifndef TOLUA_RELEASE
			if (lua_istable(L, -1) == 0) {
				tolua_error(L, "invalid row value in function 'DB_insertAsync'", nullptr);
			}
#endif
			int colSize = s_cast<int>(lua_rawlen(L, -1));
			auto& row = rows[i];
			row.resize(colSize);
			for (int j = 0; j < colSize; j++) {
				lua_rawgeti(L, -1, j + 1);
				row[j] = Dora_getDBValue(L, -1);
				lua_pop(L, 1);
			}
			lua_pop(L, 1);
		}
		LuaFunction<void> callback(tolua_ref_function(L, 4));
		self->insertAsync(tableName, std::move(rows), callback);
		return 0;
	}
tolua_lerror:
	return DB_insertAsync01(L);
}

int DB_insertAsync01(lua_State* L) {
	/* 1 self, 2 {{tableName, sheetName}}, 3 excelFile */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "DB"_slice, 0, &tolua_err)
		|| !tolua_istable(L, 2, 0, &tolua_err)
		|| !tolua_isslice(L, 3, 0, &tolua_err)
		|| !tolua_isinteger(L, 4, 0, &tolua_err)
		|| !tolua_isfunction(L, 5, &tolua_err)
		|| !tolua_isnoobj(L, 6, &tolua_err)) {
		goto tolua_lerror;
	}
#endif
	{
		DB* self = r_cast<DB*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'DB_insertAsync01'", nullptr);
#endif
		int size = s_cast<int>(lua_rawlen(L, 2));
		struct NamePair {
			NamePair() { }
			NamePair(String tableName, String sheetName)
				: tableName(tableName)
				, sheetName(sheetName) { }
			std::string tableName;
			std::string sheetName;
		};
		auto names = std::make_shared<std::vector<NamePair>>();
		for (int i = 0; i < size; i++) {
			lua_geti(L, 2, i + 1);
			int loc = lua_gettop(L);
			if (lua_istable(L, loc)) {
#ifndef TOLUA_RELEASE
				if (!tolua_isstringarray(L, loc, 2, 0, &tolua_err)) goto tolua_lerror;
#endif
				lua_geti(L, loc, 1);
				auto tableName = tolua_toslice(L, -1, nullptr);
				lua_geti(L, loc, 2);
				auto sheetName = tolua_toslice(L, -1, nullptr);
				names->emplace_back(tableName, sheetName);
				lua_pop(L, 3);
			} else {
#ifndef TOLUA_RELEASE
				if (!tolua_isstring(L, loc, 0, &tolua_err)) goto tolua_lerror;
#endif
				auto sheetName = tolua_toslice(L, loc, nullptr);
				names->emplace_back(sheetName, sheetName);
				lua_pop(L, 1);
			}
		}
		std::string excelFile = tolua_toslice(L, 3, nullptr).toString();
		int startRow = std::max(0, s_cast<int>(lua_tointeger(L, 4)) - 1);
		Ref<LuaHandler> handler(LuaHandler::create(tolua_ref_function(L, 5)));
		SharedContent.loadAsyncData(excelFile, [excelFile, names, startRow, handler](OwnArray<uint8_t>&& data, size_t size) {
			auto excelData = std::make_shared<OwnArray<uint8_t>>(std::move(data));
			SharedDB.getThread()->run(
				[excelFile, names, startRow, excelData = std::move(excelData), size, database = SharedDB.getDatabase()]() {
					auto workbook = New<xlsxtext::workbook>(std::make_pair(std::move(*excelData), size));
					if (workbook->read()) {
						bool result = DB::transactionUnsafe(database, [&](SQLite::Database* db) {
							const auto& strs = workbook->shared_strings();
							for (auto& worksheet : *workbook) {
								if (auto it = std::find_if(names->begin(), names->end(),
										[&](const NamePair& pair) {
											return pair.sheetName == worksheet.name();
										});
									it != names->end()) {
									auto errors = worksheet.read();
									if (!errors.empty()) {
										Error("failed to read excel sheet \"{}\" from file \"{}\":", worksheet.name(), excelFile);
										for (auto [refer, msg] : errors) {
											Error("{}: {}", refer, msg);
										}
									}
									std::string valueHolder;
									for (size_t i = 0; i < worksheet.max_col(); i++) {
										valueHolder += '?';
										if (i != worksheet.max_col() - 1) valueHolder += ',';
									}
									SQLite::Statement query(*db, fmt::format("INSERT INTO {} VALUES ({})", it->tableName, valueHolder));
									int rowIndex = 0;
									for (const auto& row : worksheet) {
										if (rowIndex < startRow) {
											rowIndex++;
											continue;
										}
										query.clearBindings();
										for (const auto& cell : row) {
											if (cell.value.empty() && cell.string_id >= 0) {
												query.bind(cell.refer.col, strs[cell.string_id]);
											} else {
												char* endptr = nullptr;
												double d = std::strtod(cell.value.c_str(), &endptr);
												if (*endptr != '\0' || endptr == cell.value.c_str()) {
													query.bind(cell.refer.col, cell.value);
												} else {
													query.bind(cell.refer.col, d);
												}
											}
										}
										query.exec();
										query.reset();
										rowIndex++;
									}
								}
							}
						});
						return Values::alloc(result);
					}
					return Values::alloc(false);
				},
				[handler](Own<Values>&& values) {
					bool success = false;
					values->get(success);
					auto L = SharedLuaEngine.getState();
					lua_pushboolean(L, success ? 1 : 0);
					SharedLuaEngine.executeFunction(handler->get(), 1);
				});
		});
	}
	return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'DB_insertAsync01'.", &tolua_err);
	return 0;
#endif
}

int DB_execAsync(lua_State* L) {
	/* 1 self, 2 sql, (3 values, 4 func) or (3 func) */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "DB"_slice, 0, &tolua_err)
		|| !tolua_isslice(L, 2, 0, &tolua_err)
		|| !((
				 tolua_isfunction(L, 3, &tolua_err) && tolua_isnoobj(L, 4, &tolua_err))
			 || (tolua_istable(L, 3, 0, &tolua_err) && tolua_isfunction(L, 4, &tolua_err) && tolua_isnoobj(L, 5, &tolua_err)))) {
		goto tolua_lerror;
	}
#endif
	{
		DB* self = r_cast<DB*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'DB_select'", nullptr);
#endif
		auto sql = tolua_toslice(L, 2, nullptr);
		std::deque<std::vector<Own<Value>>> rows;
		int funcId = 0;
		if (lua_istable(L, 3) != 0) {
			int rowCount = s_cast<int>(lua_rawlen(L, 3));
			if (rowCount > 0) {
				lua_rawgeti(L, 3, 1);
				if (lua_istable(L, -1) == 0) {
					lua_pop(L, 1);
					auto& args = rows.emplace_back();
					args.resize(rowCount);
					for (int i = 0; i < rowCount; i++) {
						lua_rawgeti(L, 3, i + 1);
						args[i] = Dora_getDBValue(L, -1);
						lua_pop(L, 1);
					}
				} else {
					lua_pop(L, 1);
#ifndef TOLUA_RELEASE
					if (!tolua_istablearray(L, 3, rowCount, 0, &tolua_err)) {
						goto tolua_lerror;
					}
#endif
					for (int i = 0; i < rowCount; i++) {
						lua_rawgeti(L, 3, i + 1);
						auto& row = rows.emplace_back();
						int size = s_cast<int>(lua_rawlen(L, -1));
						row.resize(size);
						for (int j = 0; j < size; j++) {
							lua_rawgeti(L, -1, j + 1);
							row[j] = Dora_getDBValue(L, -1);
							lua_pop(L, 1);
						}
						lua_pop(L, 1);
					}
				}
			}
			funcId = tolua_ref_function(L, 4);
		} else
			funcId = tolua_ref_function(L, 3);
		LuaFunction<void> callback(funcId);
		self->execAsync(sql, std::move(rows), callback);
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'DB_execAsync'.", &tolua_err);
	return 0;
#endif
}

int HttpServer_post(lua_State* L) {
	/* 1 self, 2 pattern, 3 handler */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "HttpServer"_slice, 0, &tolua_err)
		|| !tolua_isslice(L, 2, 0, &tolua_err)
		|| !tolua_isfunction(L, 3, &tolua_err)
		|| !tolua_isnoobj(L, 4, &tolua_err)) {
		goto tolua_lerror;
	}
#endif
	{
		HttpServer* self = r_cast<HttpServer*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'HttpServer_post'", nullptr);
#endif
		Slice pattern = tolua_toslice(L, 2, nullptr);
		Ref<LuaHandler> handler(LuaHandler::create(tolua_ref_function(L, 3)));
		self->post(pattern, [handler](const HttpServer::Request& req) {
			auto L = SharedLuaEngine.getState();
			int top = lua_gettop(L);
			DEFER(lua_settop(L, top));
			lua_createtable(L, 0, 0);
			lua_pushliteral(L, "headers");
			lua_createtable(L, 0, 0);
			std::string key;
			bool startPair = true;
			for (const auto& v : req.headers) {
				if (startPair) {
					startPair = false;
					key = v.toString();
				} else {
					startPair = true;
					tolua_pushslice(L, key);
					tolua_pushslice(L, v);
					lua_rawset(L, -3);
				}
			}
			lua_rawset(L, -3);
			lua_pushliteral(L, "params");
			lua_createtable(L, 0, 0);
			key.clear();
			startPair = true;
			for (const auto& v : req.params) {
				if (startPair) {
					startPair = false;
					key = v.toString();
				} else {
					startPair = true;
					tolua_pushslice(L, key);
					tolua_pushslice(L, v);
					lua_rawset(L, -3);
				}
			}
			lua_rawset(L, -3);
			lua_pushliteral(L, "body");
			if (req.contentType == "application/json"_slice) {
				lua_pushcfunction(L, colibc_json_decode);
				tolua_pushslice(L, req.body);
				if (!LuaEngine::call(L, 1, 1)) {
					lua_pop(L, 1);
					lua_pushnil(L);
				}
			} else {
				tolua_pushslice(L, req.body);
			}
			lua_rawset(L, -3);
			LuaEngine::invoke(L, handler->get(), 1, 1);
			HttpServer::Response res;
			if (lua_istable(L, -1)) {
				lua_pushcfunction(L, colibc_json_encode);
				lua_insert(L, -2);
				if (LuaEngine::call(L, 1, 1)) {
					res.content = tolua_toslice(L, -1, nullptr).toString();
					res.contentType = "application/json"s;
				} else {
					res.status = 500;
				}
			} else if (lua_isstring(L, -1)) {
				res.content = tolua_toslice(L, -1, nullptr).toString();
				res.contentType = "text/plain"s;
			} else {
				res.status = 500;
			}
			return res;
		});
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'HttpServer_post'.", &tolua_err);
	return 0;
#endif
}

int HttpServer_postSchedule(lua_State* L) {
	/* 1 self, 2 pattern, 3 handler */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "HttpServer"_slice, 0, &tolua_err)
		|| !tolua_isslice(L, 2, 0, &tolua_err)
		|| !tolua_isfunction(L, 3, &tolua_err)
		|| !tolua_isnoobj(L, 4, &tolua_err)) {
		goto tolua_lerror;
	}
#endif
	{
		HttpServer* self = r_cast<HttpServer*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'HttpServer_postSchedule'", nullptr);
#endif
		Slice pattern = tolua_toslice(L, 2, nullptr);
		Ref<LuaHandler> handler(LuaHandler::create(tolua_ref_function(L, 3)));
		self->postSchedule(pattern, [handler](const HttpServer::Request& req) -> HttpServer::PostScheduledFunc {
			auto L = SharedLuaEngine.getState();
			int top = lua_gettop(L);
			DEFER(lua_settop(L, top));
			lua_createtable(L, 0, 0);
			lua_pushliteral(L, "headers");
			lua_createtable(L, 0, 0);
			std::string key;
			bool startPair = true;
			for (const auto& v : req.headers) {
				if (startPair) {
					startPair = false;
					key = v.toString();
				} else {
					startPair = true;
					tolua_pushslice(L, key);
					tolua_pushslice(L, v);
					lua_rawset(L, -3);
				}
			}
			lua_rawset(L, -3);
			lua_pushliteral(L, "params");
			lua_createtable(L, 0, 0);
			key.clear();
			startPair = true;
			for (const auto& v : req.params) {
				if (startPair) {
					startPair = false;
					key = v.toString();
				} else {
					startPair = true;
					tolua_pushslice(L, key);
					tolua_pushslice(L, v);
					lua_rawset(L, -3);
				}
			}
			lua_rawset(L, -3);
			lua_pushliteral(L, "body");
			if (req.contentType == "application/json"_slice) {
				lua_pushcfunction(L, colibc_json_decode);
				tolua_pushslice(L, req.body);
				if (!LuaEngine::call(L, 1, 1)) {
					lua_pop(L, 1);
					lua_pushnil(L);
				}
			} else {
				tolua_pushslice(L, req.body);
			}
			lua_rawset(L, -3);
			LuaHandler* func = nullptr;
			SharedLuaEngine.executeReturn(func, handler->get(), 1);
			if (!func) {
				return HttpServer::PostScheduledFunc([]() {
					return std::optional<HttpServer::Response>(HttpServer::Response(500));
				});
			}
			Ref<LuaHandler> scheduledFunc(func);
			return HttpServer::PostScheduledFunc([scheduledFunc]() -> std::optional<HttpServer::Response> {
				auto L = SharedLuaEngine.getState();
				int top = lua_gettop(L);
				DEFER(lua_settop(L, top));
				LuaEngine::invoke(L, scheduledFunc->get(), 0, 1);
				if (lua_isboolean(L, -1) != 0 && lua_toboolean(L, -1) == 0) {
					return std::nullopt;
				} else {
					HttpServer::Response res;
					if (lua_istable(L, -1)) {
						lua_pushcfunction(L, colibc_json_encode);
						lua_insert(L, -2);
						if (LuaEngine::call(L, 1, 1)) {
							res.content = tolua_toslice(L, -1, nullptr).toString();
							res.contentType = "application/json"s;
						} else {
							res.status = 500;
						}
					} else if (lua_isstring(L, -1)) {
						res.content = tolua_toslice(L, -1, nullptr).toString();
						res.contentType = "text/plain"s;
					} else {
						res.status = 500;
					}
					return res;
				}
			});
		});
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'HttpServer_postSchedule'.", &tolua_err);
	return 0;
#endif
}

int HttpServer_upload(lua_State* L) {
	/* 1 self, 2 pattern, 3 handler */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "HttpServer"_slice, 0, &tolua_err)
		|| !tolua_isslice(L, 2, 0, &tolua_err)
		|| !tolua_isfunction(L, 3, &tolua_err)
		|| !tolua_isfunction(L, 4, &tolua_err)
		|| !tolua_isnoobj(L, 5, &tolua_err)) {
		goto tolua_lerror;
	}
#endif
	{
		HttpServer* self = r_cast<HttpServer*>(tolua_tousertype(L, 1, 0));
#ifndef TOLUA_RELEASE
		if (!self) tolua_error(L, "invalid 'self' in function 'HttpServer_upload'", nullptr);
#endif
		Slice pattern = tolua_toslice(L, 2, nullptr);
		Ref<LuaHandler> acceptHandler(LuaHandler::create(tolua_ref_function(L, 3)));
		Ref<LuaHandler> doneHandler(LuaHandler::create(tolua_ref_function(L, 4)));
		self->upload(
			pattern, [=](const HttpServer::Request& req, const std::string& filename) -> std::optional<std::string> {
				auto L = SharedLuaEngine.getState();
				int top = lua_gettop(L);
				DEFER(lua_settop(L, top));
				lua_createtable(L, 0, 0);
				lua_pushliteral(L, "params");
				lua_createtable(L, 0, 0);
				std::string key;
				bool startPair = true;
				for (const auto& v : req.params) {
					if (startPair) {
						startPair = false;
						key = v.toString();
					} else {
						startPair = true;
						tolua_pushslice(L, key);
						tolua_pushslice(L, v);
						lua_rawset(L, -3);
					}
				}
				lua_rawset(L, -3);
				tolua_pushslice(L, filename);
				LuaEngine::invoke(L, acceptHandler->get(), 2, 1);
				if (lua_isstring(L, -1)) {
					return tolua_toslice(L, -1, nullptr).toString();
				}
				return std::nullopt;
			},
			[=](const HttpServer::Request& req, const std::string& file) {
				auto L = SharedLuaEngine.getState();
				int top = lua_gettop(L);
				DEFER(lua_settop(L, top));
				lua_createtable(L, 0, 0);
				lua_pushliteral(L, "params");
				lua_createtable(L, 0, 0);
				std::string key;
				bool startPair = true;
				for (const auto& v : req.params) {
					if (startPair) {
						startPair = false;
						key = v.toString();
					} else {
						startPair = true;
						tolua_pushslice(L, key);
						tolua_pushslice(L, v);
						lua_rawset(L, -3);
					}
				}
				lua_rawset(L, -3);
				tolua_pushslice(L, file);
				LuaEngine::invoke(L, doneHandler->get(), 2, 1);
				if (lua_toboolean(L, -1) != 0) {
					return true;
				}
				return false;
			});
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'HttpServer_upload'.", &tolua_err);
	return 0;
#endif
}

/* WasmRuntime */

void WasmRuntime_clear() {
	if (Singleton<WasmRuntime>::isInitialized()) {
		SharedWasmRuntime.clear();
	}
}

/* Test */

int Test_getNames(lua_State* L) {
	auto names = Test::getNames();
	lua_createtable(L, names.size(), 0);
	int i = 1;
	for (const auto& name : names) {
		tolua_pushslice(L, name);
		lua_rawseti(L, -2, i);
		i++;
	}
	return 1;
}

int Test_run(lua_State* L) {
	size_t len = 0;
	const char* name = luaL_checklstring(L, 2, &len);
	bool result = Test::run({name, len});
	lua_pushboolean(L, result ? 1 : 0);
	return 1;
}

NS_DORA_END

NS_DORA_PLATFORMER_BEGIN

static Relation toRelation(String value) {
	switch (Switch::hash(value)) {
		case "Enemy"_hash: return Relation::Enemy;
		case "Friend"_hash: return Relation::Friend;
		case "Neutral"_hash: return Relation::Neutral;
		case "Unknown"_hash: return Relation::Unknown;
		case "Any"_hash: return Relation::Any;
		default:
			Issue("Relation \"{}\" is invalid, only \"Enemy\", \"Friend\", \"Neutral\", \"Unknown\", \"Any\" are allowed.", value.toString());
			break;
	}
	return Relation::Unknown;
}

static Slice getRelation(Relation relation) {
	switch (relation) {
		case Relation::Enemy: return "Enemy"_slice;
		case Relation::Friend: return "Friend"_slice;
		case Relation::Neutral: return "Neutral"_slice;
		case Relation::Unknown: return "Unknown"_slice;
		case Relation::Any: return "Any"_slice;
		default: return "Unknown"_slice;
	}
}

/* TargetAllow */

void TargetAllow_allow(TargetAllow* self, String flag, bool allow) {
	self->allow(toRelation(flag), allow);
}

bool TargetAllow_isAllow(TargetAllow* self, String relation) {
	return self->isAllow(toRelation(relation));
}

/* UnitAction */

LuaActionDef::LuaActionDef(
	LuaFunction<bool> available,
	LuaFunction<LuaFunction<bool>> create,
	LuaFunction<void> stop)
	: available(available)
	, create(create)
	, stop(stop) { }

Own<UnitAction> LuaActionDef::toAction(Unit* unit) {
	LuaUnitAction* action = new LuaUnitAction(name, priority, queued, unit);
	action->reaction = reaction;
	action->recovery = recovery;
	action->_available = available;
	action->_create = create;
	action->_stop = stop;
	return MakeOwn(s_cast<UnitAction*>(action));
}

LuaUnitAction::LuaUnitAction(String name, int priority, bool queued, Unit* owner)
	: UnitAction(name, priority, queued, owner) { }

bool LuaUnitAction::isAvailable() {
	return _available(_owner, s_cast<UnitAction*>(this));
}

void LuaUnitAction::run() {
	UnitAction::run();
	if (auto playable = _owner->getPlayable()) {
		playable->setRecovery(recovery);
	}
	_update = _create(_owner, s_cast<UnitAction*>(this));
	if (_update(_owner, s_cast<UnitAction*>(this), 0.0f)) {
		LuaUnitAction::stop();
	}
}

void LuaUnitAction::update(float dt) {
	if (_update && _update(_owner, s_cast<UnitAction*>(this), dt)) {
		LuaUnitAction::stop();
	}
	UnitAction::update(dt);
}

void LuaUnitAction::stop() {
	_update = nullptr;
	_stop(_owner, s_cast<UnitAction*>(this));
	UnitAction::stop();
}

void LuaUnitAction::destroy() {
	_update = nullptr;
	_available = nullptr;
	_create = nullptr;
	_update = nullptr;
	_stop = nullptr;
	UnitAction::destroy();
}

void LuaUnitAction_add(
	String name, int priority, float reaction, float recovery, bool queued,
	LuaFunction<bool> available,
	LuaFunction<LuaFunction<bool>> create,
	LuaFunction<void> stop) {
	UnitActionDef* actionDef = new LuaActionDef(available, create, stop);
	actionDef->name = name.toString();
	actionDef->priority = priority;
	actionDef->reaction = reaction;
	actionDef->recovery = recovery;
	actionDef->queued = queued;
	UnitAction::add(name, MakeOwn(actionDef));
}

/* AI */

Array* AI_getUnitsByRelation(Decision::AI* self, String relation) {
	return self->getUnitsByRelation(toRelation(relation));
}

Unit* AI_getNearestUnit(Decision::AI* self, String relation) {
	return self->getNearestUnit(toRelation(relation));
}

float AI_getNearestUnitDistance(Decision::AI* self, String relation) {
	return self->getNearestUnitDistance(toRelation(relation));
}

/* Blackboard */

int Blackboard_get(lua_State* L) {
	/* 1 self, 2 key */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Platformer::Behavior::Blackboard"_slice, 0, &tolua_err) || !tolua_isslice(L, 2, 0, &tolua_err) || !tolua_isnoobj(L, 3, &tolua_err)) {
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
		if (value)
			value->pushToLua(L);
		else
			lua_pushnil(L);
		return 1;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Blackboard_get'.", &tolua_err);
	return 0;
#endif
}

int Blackboard_set(lua_State* L) {
	/* 1 self, 2 key, 3 value */
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isusertype(L, 1, "Platformer::Behavior::Blackboard"_slice, 0, &tolua_err) || !tolua_isslice(L, 2, 0, &tolua_err) || !tolua_isnoobj(L, 4, &tolua_err)) {
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
		if (value)
			self->set(key, std::move(value));
		else
			self->remove(key);
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror:
	tolua_error(L, "#ferror in function 'Blackboard_set'.", &tolua_err);
	return 0;
#endif
}

/* Data */

void Data_setRelation(Data* self, uint8_t groupA, uint8_t groupB, String relation) {
	self->setRelation(groupA, groupB, toRelation(relation));
}

Slice Data_getRelation(Data* self, uint8_t groupA, uint8_t groupB) {
	return getRelation(self->getRelation(groupA, groupB));
}

Slice Data_getRelation(Data* self, Body* bodyA, Body* bodyB) {
	return getRelation(self->getRelation(bodyA, bodyB));
}

NS_DORA_PLATFORMER_END
