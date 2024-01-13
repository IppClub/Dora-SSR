/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "GUI/ImGuiDora.h"

#include "Basic/Application.h"
#include "Basic/Content.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Basic/View.h"
#include "Cache/ShaderCache.h"
#include "Cache/TextureCache.h"
#include "Effect/Effect.h"
#include "Event/Event.h"
#include "Event/Listener.h"
#include "Input/Keyboard.h"
#include "Lua/LuaEngine.h"
#include "Wasm/WasmRuntime.h"

#include "Other/utf8.h"
#include "imgui.h"
#include "implot.h"

#include "SDL.h"

NS_DORA_BEGIN

void pushYue(lua_State* L, String name) {
	lua_getglobal(L, "package"); // package
	lua_getfield(L, -1, "loaded"); // package loaded
	lua_getfield(L, -1, "yue"); // package loaded yue
	lua_pushlstring(L, name.begin(), name.size()); // package loaded yue name
	lua_gettable(L, -2); // loaded[name], package loaded yue item
	lua_insert(L, -4); // item package loaded yue
	lua_pop(L, 3); // item
}

void pushOptions(lua_State* L, int lineOffset) {
	lua_newtable(L);
	lua_pushliteral(L, "lint_global");
	lua_pushboolean(L, 0);
	lua_rawset(L, -3);
	lua_pushliteral(L, "implicit_return_root");
	lua_pushboolean(L, 1);
	lua_rawset(L, -3);
	lua_pushliteral(L, "reserve_line_number");
	lua_pushboolean(L, 1);
	lua_rawset(L, -3);
	lua_pushliteral(L, "space_over_tab");
	lua_pushboolean(L, 0);
	lua_rawset(L, -3);
	lua_pushliteral(L, "same_module");
	lua_pushboolean(L, 1);
	lua_rawset(L, -3);
	lua_pushliteral(L, "line_offset");
	lua_pushinteger(L, lineOffset);
	lua_rawset(L, -3);
}

class ConsolePanel {
public:
	ConsolePanel()
		: _forceScroll(0)
		, _historyPos(-1)
		, _fullScreen(false)
		, _scrollToBottom(false)
		, _commands({"print",
			  "import"}) {
		_buf.fill('\0');
		LogHandler += std::make_pair(this, &ConsolePanel::addLog);
		_commandListener = Listener::create("AppCommand"s, [this](Event* event) {
			std::string codes;
			if (event->get(codes)) {
				runCodes(std::move(codes));
			}
		});
	}

	~ConsolePanel() {
		LogHandler -= std::make_pair(this, &ConsolePanel::addLog);
	}

	void clear() {
		_logs.clear();
	}

	void addLog(const std::string& text) {
		size_t start = 0, end = 0;
		std::list<Slice> lines;
		const char* str = text.c_str();
		while ((end = text.find_first_of("\n", start)) != std::string::npos) {
			lines.push_back(Slice(str + start, end - start));
			start = end + 1;
		}
		for (auto line : lines) {
			_logs.push_back(line.toString());
		}
		if (_logs.size() > DORA_MAX_IMGUI_LOG) {
			_logs.erase(_logs.begin(), _logs.begin() + _logs.size() - DORA_MAX_IMGUI_LOG);
		}
		_scrollToBottom = true;
	}

	static int TextEditCallbackStub(ImGuiInputTextCallbackData* data) {
		ConsolePanel* panel = r_cast<ConsolePanel*>(data->UserData);
		return panel->TextEditCallback(data);
	}

	int TextEditCallback(ImGuiInputTextCallbackData* data) {
		switch (data->EventFlag) {
			case ImGuiInputTextFlags_CallbackCompletion: {
				const char* word_end = data->Buf + data->CursorPos;
				const char* word_start = word_end;
				while (word_start > data->Buf) {
					const char c = word_start[-1];
					if (c == ' ' || c == '\t' || c == ',' || c == ';') {
						break;
					}
					word_start--;
				}
				ImVector<const char*> candidates;
				for (size_t i = 0; i < _commands.size(); i++) {
					if (std::strncmp(_commands[i], word_start, (int)(word_end - word_start)) == 0) {
						candidates.push_back(_commands[i]);
					}
				}
				if (candidates.Size == 1) {
					data->DeleteChars((int)(word_start - data->Buf), (int)(word_end - word_start));
					data->InsertChars(data->CursorPos, candidates[0]);
					data->InsertChars(data->CursorPos, " ");
				} else if (candidates.Size > 1) {
					int match_len = (int)(word_end - word_start);
					for (;;) {
						int c = 0;
						bool all_candidates_matches = true;
						for (int i = 0; i < candidates.Size && all_candidates_matches; i++) {
							if (i == 0) {
								c = toupper(candidates[i][match_len]);
							} else if (c == 0 || c != toupper(candidates[i][match_len])) {
								all_candidates_matches = false;
							}
						}
						if (!all_candidates_matches) break;
						match_len++;
					}
					if (match_len > 0) {
						data->DeleteChars((int)(word_start - data->Buf), (int)(word_end - word_start));
						data->InsertChars(data->CursorPos, candidates[0], candidates[0] + match_len);
					}
				}
				break;
			}
			case ImGuiInputTextFlags_CallbackHistory: {
				const int prev_history_pos = _historyPos;
				if (data->EventKey == ImGuiKey_UpArrow) {
					if (_historyPos == -1)
						_historyPos = s_cast<int>(_history.size()) - 1;
					else if (_historyPos > 0)
						_historyPos--;
				} else if (data->EventKey == ImGuiKey_DownArrow) {
					if (_historyPos != -1)
						if (++_historyPos >= s_cast<int>(_history.size())) {
							_historyPos = -1;
						}
				}
				if (prev_history_pos != _historyPos) {
					const char* history_str = (_historyPos >= 0) ? _history[_historyPos].c_str() : "";
					data->DeleteChars(0, data->BufTextLen);
					data->InsertChars(0, history_str);
				}
				break;
			}
		}
		return 0;
	}

	void Draw(const char* title, bool useChinese, bool* pOpen) {
		if (_fullScreen) {
			ImGui::SetNextWindowPos(Vec2::zero);
			ImGui::SetNextWindowSize(Vec2{1, 1} * SharedApplication.getVisualSize(), ImGuiCond_Always);
			ImGui::Begin("DoraConsole_full", nullptr, ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoSavedSettings);
		} else {
			ImGui::SetNextWindowSize(ImVec2(400, 300), ImGuiCond_FirstUseEver);
			ImGui::Begin(title, pOpen);
		}
		if (ImGui::Button(useChinese ? r_cast<const char*>(u8"清空") : "Clear")) clear();
		ImGui::SameLine();
		if (ImGui::Button(useChinese ? r_cast<const char*>(u8"复制") : "Copy") && !_logs.empty()) {
			std::string logText;
			for (const auto& line : _logs) {
				logText.append(line);
				if (line != _logs.back()) {
					logText.append("\n");
				}
			}
			SDL_SetClipboardText(logText.c_str());
		}
		ImGui::SameLine();
		if (ImGui::Button(_fullScreen ? "]  [" : "[  ]")) {
			_forceScroll = 2;
			_scrollToBottom = true;
			_fullScreen = !_fullScreen;
		}
		ImGui::SameLine();
		_filter.Draw(useChinese ? r_cast<const char*>(u8"筛选") : "Filter", -60.0f);
		const float footer_height_to_reserve = ImGui::GetStyle().ItemSpacing.y + ImGui::GetFrameHeightWithSpacing();
		ImGui::BeginChild(_fullScreen ? "scrolling_full" : "scrolling", ImVec2(0, -footer_height_to_reserve), false);
		if (_forceScroll == 0 && _scrollToBottom && ImGui::GetScrollY() + footer_height_to_reserve < ImGui::GetScrollMaxY()) {
			_scrollToBottom = false;
		}
		if (!_filter.IsActive()) {
			ImVec2 itemSpacing = ImGui::GetStyle().ItemSpacing;
			ImGui::PushStyleVar(ImGuiStyleVar_ItemSpacing, ImVec2(itemSpacing.x, 0));
			ImGuiListClipper clipper;
			clipper.Begin(s_cast<int>(_logs.size()));
			while (clipper.Step()) {
				for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
					ImGui::TextUnformatted(&_logs.at(i).front(), &_logs.at(i).back() + 1);
				}
			}
			clipper.End();
			ImGui::PopStyleVar();
		} else {
			_filteredLogs.clear();
			for (const auto& line : _logs) {
				if (_filter.PassFilter(line.c_str())) {
					_filteredLogs.push_back(line);
				}
			}
			ImGuiListClipper clipper;
			clipper.Begin(s_cast<int>(_filteredLogs.size()));
			while (clipper.Step()) {
				for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
					ImGui::TextUnformatted(_filteredLogs.at(i).begin(), _filteredLogs.at(i).end());
				}
			}
			clipper.End();
		}
		if (_scrollToBottom) {
			_scrollToBottom = false;
			ImGui::SetScrollHereY();
		}
		if (_forceScroll > 0) {
			_forceScroll--;
			ImGui::SetScrollHereY();
		}
		ImGui::EndChild();

		bool reclaimFocus = false;
		ImGuiInputTextFlags inputTextFlags = ImGuiInputTextFlags_EnterReturnsTrue | ImGuiInputTextFlags_CallbackCompletion | ImGuiInputTextFlags_CallbackHistory;
		ImGui::PushItemWidth(-60);
		if (ImGui::InputText(useChinese ? r_cast<const char*>(u8"命令行") : "REPL", _buf.data(), _buf.size(), inputTextFlags, &TextEditCallbackStub, r_cast<void*>(this))) {
			_historyPos = -1;
			for (int i = s_cast<int>(_history.size()) - 1; i >= 0; i--) {
				if (_history[i] == _buf.data()) {
					_history.erase(_history.begin() + i);
					break;
				}
			}
			std::string codes = _buf.data();
			_buf.fill('\0');
			_history.push_back(codes);
			runCodes(std::move(codes));
			_scrollToBottom = true;
			reclaimFocus = true;
		}
		ImGui::PopItemWidth();
		ImGui::SetItemDefaultFocus();
		if (reclaimFocus) ImGui::SetKeyboardFocusHere(-1);
		ImGui::End();
	}

	void runCodes(std::string codes) {
		LogPrintInThread(codes + '\n');
		codes.insert(0,
			"rawset dora, '_REPL', <index>: dora unless dora._REPL\n"
			"_ENV = dora._REPL\n"
			"global *\n"s);
		lua_State* L = SharedLuaEngine.getState();
		int top = lua_gettop(L);
		DEFER(lua_settop(L, top));
		pushYue(L, "loadstring"_slice);
		lua_pushlstring(L, codes.c_str(), codes.size());
		lua_pushliteral(L, "=(repl)");
		pushOptions(L, -3);
		BLOCK_START
		if (lua_pcall(L, 3, 2, 0) != 0) {
			LogPrint("{}\n", lua_tostring(L, -1));
			break;
		}
		if (lua_isnil(L, -2) != 0) {
			std::string err = lua_tostring(L, -1);
			auto modName = "(repl):"_slice;
			if (err.substr(0, modName.size()) == modName) {
				err = err.substr(modName.size());
			}
			auto pos = err.find(':');
			if (pos != std::string::npos) {
				int lineNum = std::stoi(err.substr(0, pos));
				err = std::to_string(lineNum - 1) + err.substr(pos);
			}
			LogPrint("{}\n", err);
			break;
		}
		lua_pop(L, 1);
		pushYue(L, "pcall"_slice);
		lua_insert(L, -2);
		int last = lua_gettop(L) - 2;
		if (lua_pcall(L, 1, LUA_MULTRET, 0) != 0) {
			LogPrint("{}\n", lua_tostring(L, -1));
			break;
		}
		int cur = lua_gettop(L);
		int retCount = cur - last;
		bool success = lua_toboolean(L, -retCount) != 0;
		if (success) {
			if (retCount > 1) {
				for (int i = 1; i < retCount; ++i) {
					LogPrint("{}\n", luaL_tolstring(L, -retCount + i, nullptr));
					lua_pop(L, 1);
				}
			}
		} else {
			LogPrint("{}\n", lua_tostring(L, -1));
		}
		BLOCK_END
	}

private:
	bool _fullScreen;
	int _forceScroll;
	bool _scrollToBottom;
	std::array<char, 256> _buf;
	std::vector<const char*> _commands;
	std::vector<std::string> _history;
	int _historyPos;
	std::deque<std::string> _logs;
	std::deque<Slice> _filteredLogs;
	ImGuiTextFilter _filter;
	Ref<Listener> _commandListener;
};

static void DoraSetupTheme(Color color) {
	auto themeColor = color.toVec4();
	// dora theme colors, 3 intensities
	auto HI = [&themeColor](float v) {
		return ImVec4(
			themeColor.x * 0.9f,
			themeColor.y * 0.9f,
			themeColor.z * 0.9f,
			themeColor.w * v);
	};
	auto MED = [&themeColor](float v) {
		return ImVec4(
			themeColor.x * 0.6f,
			themeColor.y * 0.6f,
			themeColor.z * 0.6f,
			themeColor.w * v);
	};
	auto LOW = [](float v) {
		return ImVec4(0.204f, 0.204f, 0.204f, v);
	};
	// backgrounds
	auto BG = [](float v) {
		return ImVec4(0.102f, 0.102f, 0.102f, v);
	};
	// text
	auto TEXT = [](float v) {
		return ImVec4(0.860f, 0.860f, 0.860f, v);
	};
	// button
	auto BUTTON = ImVec4(0.77f, 0.77f, 0.77f, 0.14f);
	auto TRANSPARENT = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);

	auto& colors = ImGui::GetStyle().Colors;
	colors[ImGuiCol_Text] = TEXT(1.00f);
	colors[ImGuiCol_TextDisabled] = TEXT(0.28f);
	colors[ImGuiCol_WindowBg] = BG(1.00f);
	colors[ImGuiCol_ChildBg] = TRANSPARENT;
	colors[ImGuiCol_PopupBg] = BG(0.9f);
	colors[ImGuiCol_Border] = TRANSPARENT;
	colors[ImGuiCol_BorderShadow] = TRANSPARENT;
	colors[ImGuiCol_FrameBg] = BUTTON;
	colors[ImGuiCol_FrameBgHovered] = MED(0.78f);
	colors[ImGuiCol_FrameBgActive] = MED(1.00f);
	colors[ImGuiCol_TitleBg] = LOW(1.00f);
	colors[ImGuiCol_TitleBgActive] = MED(1.00f);
	colors[ImGuiCol_TitleBgCollapsed] = BG(0.75f);
	colors[ImGuiCol_MenuBarBg] = BG(0.47f);
	colors[ImGuiCol_ScrollbarBg] = TRANSPARENT;
	colors[ImGuiCol_ScrollbarGrab] = LOW(0.5f);
	colors[ImGuiCol_ScrollbarGrabHovered] = MED(0.78f);
	colors[ImGuiCol_ScrollbarGrabActive] = MED(1.00f);
	colors[ImGuiCol_CheckMark] = HI(1.00f);
	colors[ImGuiCol_SliderGrab] = BUTTON;
	colors[ImGuiCol_SliderGrabActive] = HI(1.00f);
	colors[ImGuiCol_Button] = BUTTON;
	colors[ImGuiCol_ButtonHovered] = MED(0.86f);
	colors[ImGuiCol_ButtonActive] = MED(1.00f);
	colors[ImGuiCol_Header] = BUTTON;
	colors[ImGuiCol_HeaderHovered] = MED(0.86f);
	colors[ImGuiCol_HeaderActive] = HI(1.00f);
	colors[ImGuiCol_Separator] = LOW(1.00f);
	colors[ImGuiCol_SeparatorHovered] = colors[ImGuiCol_FrameBgHovered];
	colors[ImGuiCol_SeparatorActive] = colors[ImGuiCol_FrameBgActive];
	colors[ImGuiCol_ResizeGrip] = ImVec4(0.77f, 0.77f, 0.77f, 0.04f);
	colors[ImGuiCol_ResizeGripHovered] = MED(0.78f);
	colors[ImGuiCol_ResizeGripActive] = MED(1.00f);
	colors[ImGuiCol_Tab] = MED(0.80f);
	colors[ImGuiCol_TabHovered] = HI(0.90f);
	colors[ImGuiCol_TabActive] = HI(0.90f);
	colors[ImGuiCol_TabUnfocused] = MED(0.80f);
	colors[ImGuiCol_TabUnfocusedActive] = HI(0.90f);
	colors[ImGuiCol_PlotLines] = TEXT(0.63f);
	colors[ImGuiCol_PlotLinesHovered] = MED(1.00f);
	colors[ImGuiCol_PlotHistogram] = TEXT(0.63f);
	colors[ImGuiCol_PlotHistogramHovered] = MED(1.00f);
	colors[ImGuiCol_TableHeaderBg] = ImVec4(0.19f, 0.19f, 0.19f, 1.00f);
	colors[ImGuiCol_TableBorderStrong] = ImVec4(0.31f, 0.31f, 0.31f, 1.00f); // Prefer using Alpha=1.0 here
	colors[ImGuiCol_TableBorderLight] = ImVec4(0.23f, 0.23f, 0.23f, 1.00f); // Prefer using Alpha=1.0 here
	colors[ImGuiCol_TableRowBg] = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
	colors[ImGuiCol_TableRowBgAlt] = ImVec4(1.00f, 1.00f, 1.00f, 0.06f);
	colors[ImGuiCol_TextSelectedBg] = MED(0.43f);
	colors[ImGuiCol_DragDropTarget] = ImVec4(1.00f, 1.00f, 0.00f, 0.90f);
	colors[ImGuiCol_NavHighlight] = HI(1.00f);
	colors[ImGuiCol_NavWindowingHighlight] = ImVec4(1.00f, 1.00f, 1.00f, 0.70f);
	colors[ImGuiCol_NavWindowingDimBg] = ImVec4(0.80f, 0.80f, 0.80f, 0.20f);
	colors[ImGuiCol_ModalWindowDimBg] = ImVec4(0.80f, 0.80f, 0.80f, 0.35f);
}

int ImGuiDora::_lastIMEPosX;
int ImGuiDora::_lastIMEPosY;

ImGuiDora::ImGuiDora()
	: _isChineseSupported(false)
	, _useChinese(false)
	, _isLoadingFont(false)
	, _fontLoaded(false)
	, _rejectAllEvents(false)
	, _textInputing(false)
	, _mouseVisible(true)
	, _lastCursor(0)
	, _backSpaceIgnore(false)
	, _mousePressed{false, false, false}
	, _mouseWheel{0.0f, 0.0f}
	, _console(New<ConsolePanel>())
	, _defaultFonts(New<ImFontAtlas>())
	, _fonts(New<ImFontAtlas>())
	, _showPlot(false)
	, _timeFrames(0)
	, _memFrames(0)
	, _profileFrames(0)
	, _objectElapsed(0)
	, _memElapsed(0)
	, _profileElapsed(0)
	, _cpuTime(0)
	, _gpuTime(0)
	, _deltaTime(0)
	, _logicTime(0)
	, _renderTime(0)
	, _avgCPUTime(0)
	, _avgGPUTime(0)
	, _loaderTotalTime(0)
	, _avgDeltaTime(1000.0 / SharedApplication.getTargetFPS())
	, _objectFrames(0)
	, _maxCppObjects(0)
	, _maxLuaObjects(0)
	, _maxCallbacks(0)
	, _memPoolSize(0)
	, _memLua(0)
	, _memWASM(0)
	, _lastMemPoolSize(0)
	, _lastMemLua(0)
	, _lastMemWASM(0)
	, _maxCPU(0)
	, _maxGPU(0)
	, _maxDelta(0)
	, _yLimit(0)
	, _sampler(BGFX_INVALID_HANDLE) {
	_touchHandler = std::make_shared<ImGuiTouchHandler>(this);
	_vertexLayout
		.begin()
		.add(bgfx::Attrib::Position, 2, bgfx::AttribType::Float)
		.add(bgfx::Attrib::TexCoord0, 2, bgfx::AttribType::Float)
		.add(bgfx::Attrib::Color0, 4, bgfx::AttribType::Uint8, true)
		.end();
	SharedApplication.eventHandler += std::make_pair(this, &ImGuiDora::handleEvent);
	_costListener = Listener::create(Profiler::EventName, [&](Event* e) {
		std::string name;
		std::string msg;
		int level = 0;
		double cost;
		e->get(name, msg, level, cost);
		if (name == "Loader"_slice) {
			const auto& assetPath = SharedContent.getAssetPath();
			if (Slice(msg).left(assetPath.size()) == assetPath) {
				msg = Path::concat({"assets"_slice, msg.substr(assetPath.size())});
			}
			if (level == 0) _loaderTotalTime += cost;
			_loaderCosts.push_front({s_cast<int>(_loaderCosts.size()),
				level,
				msg + '\t',
				cost,
				std::string(level, ' ') + std::to_string(level),
				fmt::format("{:.2f} ms", cost * 1000.0)});
		} else {
			if (!_timeCosts.insert({name, cost}).second) {
				_timeCosts[name] += cost;
			}
		}
	});
	_themeListener = Listener::create("AppTheme"s, [&](Event* e) {
		uint32_t argb = 0;
		e->get(argb);
		DoraSetupTheme(Color(argb));
	});
	_localeListener = Listener::create("AppLocale"s, [&](Event* e) {
		std::string locale;
		e->get(locale);
		_useChinese = Slice(locale).left(2) == "zh";
	});
	_useChinese = Slice(SharedApplication.getLocale()).left(2) == "zh";
}

ImGuiDora::ImGuiTouchHandler* ImGuiDora::getTouchHandler() const {
	return _touchHandler.get();
}

ImGuiDora::~ImGuiDora() {
	if (bgfx::isValid(_sampler)) {
		bgfx::destroy(_sampler);
		_sampler = BGFX_INVALID_HANDLE;
	}
	SharedApplication.eventHandler -= std::make_pair(this, &ImGuiDora::handleEvent);
	ImPlot::DestroyContext();
	ImGui::DestroyContext();
}

const char* ImGuiDora::getClipboardText(void*) {
	return SDL_GetClipboardText();
}

void ImGuiDora::setClipboardText(void*, const char* text) {
	SDL_SetClipboardText(text);
}

void ImGuiDora::setImePositionHint(int x, int y) {
	if (x <= 1 && y <= 1) return;
	_lastIMEPosX = x;
	_lastIMEPosY = y;
	float scale =
#if BX_PLATFORM_WINDOWS
		SharedApplication.getDevicePixelRatio();
#else
		1.0f;
#endif // BX_PLATFORM_WINDOWS
	SharedKeyboard.updateIMEPosHint({s_cast<float>(x) * scale, s_cast<float>(y) * scale});
}

void ImGuiDora::loadFontTTFAsync(String ttfFontFile, float fontSize, String glyphRanges, const std::function<void(bool)>& handler) {
	AssertIf(_isLoadingFont, "font is loading.");
	AssertIf(ImGui::GetIO().Fonts->Locked, "font is locked, can only load font in system scheduler.");

	ImGuiIO& io = ImGui::GetIO();

	const ImWchar* targetGlyphRanges = nullptr;
	switch (Switch::hash(glyphRanges)) {
		case "Default"_hash:
			targetGlyphRanges = io.Fonts->GetGlyphRangesDefault();
			break;
		case "Chinese"_hash:
			targetGlyphRanges = io.Fonts->GetGlyphRangesChineseFull();
			break;
		case "Korean"_hash:
			targetGlyphRanges = io.Fonts->GetGlyphRangesKorean();
			break;
		case "Japanese"_hash:
			targetGlyphRanges = io.Fonts->GetGlyphRangesJapanese();
			break;
		case "Cyrillic"_hash:
			targetGlyphRanges = io.Fonts->GetGlyphRangesCyrillic();
			break;
		case "Thai"_hash:
			targetGlyphRanges = io.Fonts->GetGlyphRangesThai();
			break;
		case "Greek"_hash:
			targetGlyphRanges = io.Fonts->GetGlyphRangesGreek();
			break;
		case "Vietnamese"_hash:
			targetGlyphRanges = io.Fonts->GetGlyphRangesVietnamese();
			break;
		default:
			break;
	}

	if (!targetGlyphRanges) {
		Warn("unsupported glyph ranges: \"{}\".", glyphRanges.toString());
		handler(false);
		return;
	}

	_isLoadingFont = true;
	_isChineseSupported = false;

	float scale =
#if BX_PLATFORM_LINUX // || BX_PLATFORM_ANDROID || BX_PLATFORM_IOS
		1.0f;
#else
		SharedApplication.getDevicePixelRatio();
	fontSize *= scale;
#endif

	int64_t size;
	uint8_t* fileData = SharedContent.loadInMainUnsafe(ttfFontFile, size);

	if (!fileData) {
		Warn("failed to load ttf file for ImGui!");
		handler(false);
		return;
	}

	io.FontGlobalScale = 1.0f / scale;
	io.Fonts = _defaultFonts.get();
	io.Fonts->Clear();
	ImFontConfig fontConfig;
	fontConfig.FontDataOwnedByAtlas = false;
	fontConfig.PixelSnapH = true;
	fontConfig.OversampleH = 1;
	fontConfig.OversampleV = 1;
	io.Fonts->AddFontFromMemoryTTF(fileData, s_cast<int>(size), fontSize, &fontConfig, io.Fonts->GetGlyphRangesDefault());
	uint8_t* texData;
	int width;
	int height;
	io.Fonts->GetTexDataAsAlpha8(&texData, &width, &height);
	updateTexture(texData, width, height);
	io.Fonts->ClearTexData();

	_fonts->Clear();
	_fonts->AddFontFromMemoryTTF(fileData, s_cast<int>(size), s_cast<float>(fontSize), &fontConfig, targetGlyphRanges);
	SharedAsyncThread.run(
		[this]() {
			_fonts->Flags |= ImFontAtlasFlags_NoPowerOfTwoHeight;
			_fonts->TexDesiredWidth = bgfx::getCaps()->limits.maxTextureSize;
			_fonts->Build();
			return nullptr;
		},
		[this, fileData, size, glyphRanges = glyphRanges.toString(), handler](Own<Values> result) {
			ImGuiIO& io = ImGui::GetIO();
			io.Fonts->Clear();
			io.Fonts = _fonts.get();
			updateTexture(_fonts->TexPixelsAlpha8, _fonts->TexWidth, _fonts->TexHeight);
			MakeOwnArray(fileData);
			_isChineseSupported = glyphRanges == "Chinese"_slice;
			_isLoadingFont = false;
			_fontLoaded = true;
			handler(true);
		});
}

static void HelpMarker(Slice desc) {
	if (ImGui::BeginTooltip()) {
		ImGui::PushTextWrapPos(ImGui::GetFontSize() * 15.0f);
		ImGui::TextUnformatted(desc.begin(), desc.end());
		ImGui::PopTextWrapPos();
		ImGui::EndTooltip();
	}
}

void ImGuiDora::showStats(bool* pOpen, const std::function<void()>& extra) {
	/* print debug text */
	bool useChinese = _useChinese && _isChineseSupported;
	auto themeColor = SharedApplication.getThemeColor().toVec4();
	bool itemHovered = false;
	if (ImGui::Begin(useChinese ? r_cast<const char*>(u8"Dora 状态###DoraStats") : "Dora Stats###DoraStats", pOpen,
			ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_AlwaysAutoResize)) {
		if (ImGui::CollapsingHeader(useChinese ? r_cast<const char*>(u8"基础") : "Basic")) {
			const char* rendererNames[] = {
				"Noop", //!< No rendering.
				"Agc", //!< AGC
				"Direct3D11", //!< Direct3D 11.0
				"Direct3D12", //!< Direct3D 12.0
				"Gnm", //!< GNM
				"Metal", //!< Metal
				"Nvn", //!< NVN
				"OpenGLES", //!< OpenGL ES 2.0+
				"OpenGL", //!< OpenGL 2.1+
				"Vulkan", //!< Vulkan
			};
			ImGui::TextColored(themeColor, useChinese ? r_cast<const char*>(u8"渲染器：") : "Renderer:");
			itemHovered |= ImGui::IsItemHovered();
			ImGui::SameLine();
			ImGui::TextUnformatted(rendererNames[bgfx::getCaps()->rendererType]);
			itemHovered |= ImGui::IsItemHovered();
			if (itemHovered) HelpMarker(useChinese ? u8"当前使用的渲染底层的图形接口，可能是OpenGL、OpenGLES、DirectX11、Metal和Vulkan之一"sv : "the current rendering graphics interface which can be OpenGL, OpenGLES, DirectX11, Metal or Vulkan"_slice);
			ImGui::TextColored(themeColor, useChinese ? r_cast<const char*>(u8"多线程渲染：") : "Multi Threaded:");
			itemHovered = ImGui::IsItemHovered();
			ImGui::SameLine();
			ImGui::TextUnformatted((bgfx::getCaps()->supported & BGFX_CAPS_RENDERER_MULTITHREADED) ? "true" : "false");
			itemHovered |= ImGui::IsItemHovered();
			if (itemHovered) HelpMarker(useChinese ? u8"显示当前环境是否使用多线程渲染"sv : "whether the current environment uses multi-threaded rendering"_slice);
			ImGui::TextColored(themeColor, useChinese ? r_cast<const char*>(u8"渲染缓冲区：") : "Back Buffer:");
			itemHovered = ImGui::IsItemHovered();
			ImGui::SameLine();
			Size size = SharedView.getSize();
			ImGui::Text("%d x %d", s_cast<int>(size.width), s_cast<int>(size.height));
			itemHovered |= ImGui::IsItemHovered();
			if (itemHovered) HelpMarker(useChinese ? u8"主渲染缓冲区的大小，渲染缓冲区越大会越发明显的增加GPU渲染的开销"sv : "the size of the main rendering buffer, larger rendering buffer will increase GPU rendering overhead"_slice);
			ImGui::TextColored(themeColor, useChinese ? r_cast<const char*>(u8"渲染调用：") : "Draw Call:");
			itemHovered = ImGui::IsItemHovered();
			ImGui::SameLine();
			ImGui::Text("%d", bgfx::getStats()->numDraw);
			itemHovered |= ImGui::IsItemHovered();
			if (itemHovered) HelpMarker(useChinese ? u8"底层图形接口的调用次数，图形接口的调用，包括设置渲染状态，传输渲染数据之类的操作。这些操作调用的次数减少对改善性能会有一定的帮助"sv : "the number of calls to the low-level graphics interface, including operations such as setting rendering states and transferring rendering data, a reduction of these operations can improve performance"_slice);
			ImGui::TextColored(themeColor, useChinese ? r_cast<const char*>(u8"三角形：") : "Tri:");
			itemHovered = ImGui::IsItemHovered();
			ImGui::SameLine();
			ImGui::Text("%d", bgfx::getStats()->numPrims[bgfx::Topology::TriStrip] + bgfx::getStats()->numPrims[bgfx::Topology::TriList]);
			itemHovered |= ImGui::IsItemHovered();
			if (itemHovered) HelpMarker(useChinese ? u8"当前提交到GPU进行渲染的三角形的数量"sv : "the number of triangles submitted to the GPU for rendering"_slice);
			ImGui::SameLine();
			ImGui::TextColored(themeColor, useChinese ? r_cast<const char*>(u8"线段：") : "Line:");
			itemHovered = ImGui::IsItemHovered();
			ImGui::SameLine();
			ImGui::Text("%d", bgfx::getStats()->numPrims[bgfx::Topology::LineStrip] + bgfx::getStats()->numPrims[bgfx::Topology::LineList]);
			itemHovered |= ImGui::IsItemHovered();
			if (itemHovered) HelpMarker(useChinese ? u8"当前提交到GPU进行渲染的线段的数量"sv : "the number of line segments submitted to the GPU for rendering"_slice);
			ImGui::TextColored(themeColor, useChinese ? r_cast<const char*>(u8"可视区尺寸：") : "Visual Size:");
			itemHovered = ImGui::IsItemHovered();
			ImGui::SameLine();
			auto visualSize = SharedApplication.getVisualSize();
#if BX_PLATFORM_ANDROID || BX_PLATFORM_IOS
			ImGui::Text("%.0f x %.0f", visualSize.width, visualSize.height);
#else
			if (ImGui::Button(fmt::format("{:.0f} x {:.0f}", visualSize.width, visualSize.height).c_str())) {
				ImGui::OpenPopup("WindowSizeSelector");
			}
			itemHovered |= ImGui::IsItemHovered();
			if (itemHovered) HelpMarker(useChinese ? u8"当前进行渲染的图形窗口的逻辑尺寸，通常等于渲染缓冲区大小除以显示屏的像素密度"sv : "the logical size of the graphics window currently being rendered, equals to the renderbuffer size divided by the pixel density of the display"_slice);
			static Size sizes[] = {
				{4096, 2160},
				{2560, 1440},
				{1920, 1080},
				{1280, 720},
				{720, 480},
				{640, 480},
				{320, 240}};
			if (ImGui::BeginPopup("WindowSizeSelector")) {
				if (ImGui::Selectable(useChinese ? r_cast<const char*>(u8"全屏模式") : "Full Screen")) {
					SharedApplication.setWinSize(Size::zero);
				}
				for (const auto& size : sizes) {
					ImGui::Separator();
					if (ImGui::Selectable(fmt::format("{:.0f} x {:.0f}", size.width, size.height).c_str())) {
						auto ratio = SharedApplication.getWinSize().width / SharedApplication.getVisualSize().width;
						SharedApplication.setWinSize(size * Vec2{ratio, ratio});
					}
				}
				ImGui::EndPopup();
			}
#endif
			bool vsync = SharedView.isVSync();
			if (ImGui::Checkbox(useChinese ? r_cast<const char*>(u8"垂直同步") : "VSync", &vsync)) {
				SharedView.setVSync(vsync);
			}
			if (ImGui::IsItemHovered()) HelpMarker(useChinese ? u8"垂直同步用于使GPU将在显示屏每次刷新之前进行等待，防止图形渲染过快导致的画面撕裂的现象"sv : "vertical synchronization is used to make the GPU wait before each refresh of the display to prevent screen tearing caused by too fast graphics rendering"_slice);
			ImGui::SameLine();
			bool fpsLimited = SharedApplication.isFPSLimited();
			if (ImGui::Checkbox(useChinese ? r_cast<const char*>(u8"限制帧数") : "FPS Limited", &fpsLimited)) {
				SharedApplication.setFPSLimited(fpsLimited);
			}
			if (ImGui::IsItemHovered()) HelpMarker(useChinese ? u8"帧数限制会使引擎通过执行一个忙等待的死循环以获取更加精准的机器时间，并计算切换到下一帧的时间点。这是在PC机Windows系统上的通常做法，以提升CPU占用率来提升游戏的性能。但这也会导致额外的芯片热量产生和电力消耗"sv : "FPS limiting will make engine run in a busy loop to track the  precise frame time to switch to the next frame. And this behavior can lead to 100% CPU usage. This is usually common practice on Windows PCs for better CPU usage occupation. But it also results in extra heat and power consumption"_slice);
			ImGui::TextColored(themeColor, useChinese ? r_cast<const char*>(u8"帧数：") : "FPS:");
			itemHovered = ImGui::IsItemHovered();
			ImGui::SameLine();
			int targetFPS = SharedApplication.getTargetFPS();
			if (ImGui::RadioButton("30", &targetFPS, 30)) {
				SharedApplication.setTargetFPS(targetFPS);
			}
			itemHovered |= ImGui::IsItemHovered();
			ImGui::SameLine();
			if (ImGui::RadioButton("60", &targetFPS, 60)) {
				SharedApplication.setTargetFPS(targetFPS);
			}
			itemHovered |= ImGui::IsItemHovered();
			if (SharedApplication.getMaxFPS() > 60) {
				ImGui::SameLine();
				int maxFPS = SharedApplication.getMaxFPS();
				std::string fpsStr = std::to_string(maxFPS);
				if (ImGui::RadioButton(fpsStr.c_str(), &targetFPS, maxFPS)) {
					SharedApplication.setTargetFPS(targetFPS);
				}
				itemHovered |= ImGui::IsItemHovered();
			}
			if (itemHovered) HelpMarker(useChinese ? u8"游戏引擎应该运行的每秒目标帧数，仅在“限制帧数”选项被勾选时有效"sv : "the target frames per second the game engine is supposed to run at, only works when 'FPS Limited' is checked"_slice);
			int fixedFPS = SharedDirector.getScheduler()->getFixedFPS();
			ImGui::PushItemWidth(100.0f);
			if (ImGui::DragInt(useChinese ? r_cast<const char*>(u8"固定更新帧数") : "Fixed FPS", &fixedFPS, 1, 30, SharedApplication.getMaxFPS())) {
				SharedDirector.getScheduler()->setFixedFPS(fixedFPS);
			}
			if (ImGui::IsItemHovered()) HelpMarker(useChinese ? u8"固定更新模式下的目标帧速率（以每秒帧数为单位），固定更新将确保更新函数以恒定的帧速率被调度，使用恒定的更新时间间隔值，用于防止物理引擎产生奇怪行为或是用于通过网络通信同步一些状态"sv : "the target frame rate (in frames per second) for a fixed update mode and the fixed update will ensure a constant frame rate, and the operation handled in a fixed update can use a constant delta time value, it is used for preventing weird behavior of a physics engine or synchronizing some states via network communications"_slice);
			ImGui::PopItemWidth();
		}
		if (ImGui::CollapsingHeader(useChinese ? r_cast<const char*>(u8"时间") : "Time")) {
			_timeFrames++;
			_cpuTime += SharedApplication.getCPUTime();
			_gpuTime += SharedApplication.getGPUTime();
			_deltaTime += SharedApplication.getDeltaTime();
			if (_deltaTime >= 1.0) {
				_avgCPUTime = 1000.0 * _cpuTime / _timeFrames;
				_avgGPUTime = 1000.0 * _gpuTime / _timeFrames;
				_avgDeltaTime = 1000.0 * _deltaTime / _timeFrames;
				_cpuTime = _gpuTime = _deltaTime = 0.0;
				_timeFrames = 0;
			}
			ImGui::Checkbox(useChinese ? r_cast<const char*>(u8"显示图表") : "Show Plot", &_showPlot);
			if (ImGui::IsItemHovered()) HelpMarker(useChinese ? u8"显示每秒内的帧耗时峰值和CPU时间的占比的图表"sv : "display the graphs showing the peak frame time spent per second and the percentage of CPU time"_slice);
			ImGui::TextColored(themeColor, useChinese ? r_cast<const char*>(u8"当前帧数：") : "Current FPS:");
			itemHovered = ImGui::IsItemHovered();
			ImGui::SameLine();
			ImGui::Text("%.1f", 1000.0f / _avgDeltaTime);
			itemHovered |= ImGui::IsItemHovered();
			if (itemHovered) HelpMarker(useChinese ? u8"最近一秒内过去的游戏帧数"sv : "the passd frames in the last second"_slice);
			ImGui::TextColored(themeColor, useChinese ? r_cast<const char*>(u8"平均CPU耗时：") : "AVG CPU:");
			itemHovered = ImGui::IsItemHovered();
			ImGui::SameLine();
			if (_avgCPUTime == 0)
				ImGui::Text("-");
			else
				ImGui::Text("%.1f ms", _avgCPUTime);
			itemHovered |= ImGui::IsItemHovered();
			if (itemHovered) HelpMarker(useChinese ? u8"最近一秒内每帧平均CPU耗时"sv : "average CPU time per frame in the last second"_slice);
			ImGui::TextColored(themeColor, useChinese ? r_cast<const char*>(u8"平均GPU耗时：") : "AVG GPU:");
			itemHovered = ImGui::IsItemHovered();
			ImGui::SameLine();
			if (_avgGPUTime == 0)
				ImGui::Text("-");
			else
				ImGui::Text("%.1f ms", _avgGPUTime);
			itemHovered |= ImGui::IsItemHovered();
			if (itemHovered) HelpMarker(useChinese ? u8"最近一秒内每帧平均GPU耗时"sv : "average GPU time per frame in the last second"_slice);
		}
		if (ImGui::CollapsingHeader(useChinese ? r_cast<const char*>(u8"对象") : "Object")) {
			_objectFrames++;
			_objectElapsed += SharedApplication.getDeltaTime();
			ImGui::TextColored(themeColor, useChinese ? r_cast<const char*>(u8"C++对象：") : "C++ Object:");
			itemHovered = ImGui::IsItemHovered();
			ImGui::SameLine();
			_maxCppObjects = std::max(_maxCppObjects, Object::getCount());
			ImGui::Text("%d", _maxCppObjects);
			itemHovered |= ImGui::IsItemHovered();
			if (itemHovered) HelpMarker(useChinese ? u8"所有现存的C++对象的数量"sv : "the number of total existing C++ objects"_slice);
			ImGui::TextColored(themeColor, useChinese ? r_cast<const char*>(u8"Lua对象") : "Lua Object:");
			itemHovered = ImGui::IsItemHovered();
			ImGui::SameLine();
			_maxLuaObjects = std::max(_maxLuaObjects, Object::getLuaRefCount());
			ImGui::Text("%d", _maxLuaObjects);
			itemHovered |= ImGui::IsItemHovered();
			if (itemHovered) HelpMarker(useChinese ? u8"所有现存的Lua引用的C++对象的计数"sv : "the number of total existing Lua references to C++ objects"_slice);
			ImGui::TextColored(themeColor, useChinese ? r_cast<const char*>(u8"Lua回调：") : "Lua Callback:");
			itemHovered = ImGui::IsItemHovered();
			ImGui::SameLine();
			_maxCallbacks = std::max(_maxCallbacks, Object::getLuaCallbackCount());
			ImGui::Text("%d", _maxCallbacks);
			itemHovered |= ImGui::IsItemHovered();
			if (itemHovered) HelpMarker(useChinese ? u8"Lua引用的C++函数对象的数量"sv : "the number of C++ function call objects referenced by Lua"_slice);
			if (_objectElapsed >= 1.0) {
				_objectFrames = _maxCppObjects = _maxLuaObjects = _maxCallbacks = _objectElapsed = 0;
			}
		}
		if (ImGui::CollapsingHeader(useChinese ? r_cast<const char*>(u8"内存") : "Memory")) {
			_memFrames++;
			_memElapsed += SharedApplication.getDeltaTime();
			_memPoolSize = std::max(MemoryPool::getTotalCapacity(), _memPoolSize);
			_memLua = std::max(SharedLuaEngine.getMemoryCount(), _memLua);
			if (Singleton<WasmRuntime>::isInitialized()) {
				_memWASM = std::max(s_cast<int>(SharedWasmRuntime.getMemorySize()), _memWASM);
			}
			if (_memElapsed >= 1.0) {
				_lastMemPoolSize = _memPoolSize;
				_lastMemLua = _memLua;
				_lastMemWASM = _memWASM;
				_memPoolSize = _memLua = _memWASM = 0;
				_memFrames = _memElapsed = 0;
			}
			ImGui::TextColored(themeColor, useChinese ? r_cast<const char*>(u8"内存池：") : "Memory Pool:");
			itemHovered = ImGui::IsItemHovered();
			ImGui::SameLine();
			ImGui::Text("%d kb", _lastMemPoolSize / 1024);
			itemHovered |= ImGui::IsItemHovered();
			if (itemHovered) HelpMarker(useChinese ? u8"引擎用于频繁分配小数据对象的内存池大小"sv : "the size of the memory pool used by the engine to frequently allocate small data objects"_slice);
			ImGui::TextColored(themeColor, useChinese ? r_cast<const char*>(u8"Lua内存：") : "Lua Memory:");
			itemHovered = ImGui::IsItemHovered();
			ImGui::SameLine();
			ImGui::Text("%.2f mb", _lastMemLua / 1024.0f / 1024.0f);
			itemHovered |= ImGui::IsItemHovered();
			if (itemHovered) HelpMarker(useChinese ? u8"正在运行Lua虚拟机所分配的内存大小"sv : "the size of memory allocated by the running Lua virtual machine"_slice);
			if (Singleton<WasmRuntime>::isInitialized()) {
				ImGui::TextColored(themeColor, useChinese ? r_cast<const char*>(u8"WASM内存：") : "WASM Memory:");
				itemHovered = ImGui::IsItemHovered();
				ImGui::SameLine();
				ImGui::Text("%.2f mb", _lastMemWASM / 1024.0f / 1024.0f);
				itemHovered |= ImGui::IsItemHovered();
				if (itemHovered) HelpMarker(useChinese ? u8"正在运行WASM虚拟机所分配的内存大小"sv : "the size of memory allocated by the running WASM virtual machine"_slice);
			}
			ImGui::TextColored(themeColor, useChinese ? r_cast<const char*>(u8"纹理内存：") : "Texture Size:");
			itemHovered = ImGui::IsItemHovered();
			ImGui::SameLine();
			ImGui::Text("%.2f mb", Texture2D::getStorageSize() / 1024.0f / 1024.0f);
			itemHovered |= ImGui::IsItemHovered();
			if (itemHovered) HelpMarker(useChinese ? u8"引擎已加载的纹理占用的内存大小"sv : "the memory footprint used by loaded textures"_slice);
		}
		if (ImGui::CollapsingHeader(useChinese ? r_cast<const char*>(u8"加载脚本") : "Loader")) {
			if (ImGui::Button(useChinese ? r_cast<const char*>(u8"清除") : "Clear")) {
				_loaderCosts.clear();
				_loaderTotalTime = 0;
			}
			ImGui::SameLine();
			ImGui::TextColored(themeColor, useChinese ? r_cast<const char*>(u8"耗时：") : "Time Cost:");
			ImGui::SameLine();
			ImGui::Text("%.4f s", _loaderTotalTime);
			const ImGuiTableFlags flags = ImGuiTableFlags_Resizable
										| ImGuiTableFlags_Sortable
										| ImGuiTableFlags_SortMulti
										| ImGuiTableFlags_RowBg
										| ImGuiTableFlags_BordersOuter
										| ImGuiTableFlags_BordersV
										| ImGuiTableFlags_NoBordersInBody
										| ImGuiTableFlags_ScrollY
										| ImGuiTableFlags_SizingFixedFit;
			if (ImGui::BeginTable(useChinese ? r_cast<const char*>(u8"加载器") : "Loaders", 4, flags, ImVec2(0.0f, 400.0f))) {
				ImGui::TableSetupColumn(useChinese ? r_cast<const char*>(u8"序号") : "Order",
					ImGuiTableColumnFlags_DefaultSort
						| ImGuiTableColumnFlags_PreferSortDescending
						| ImGuiTableColumnFlags_WidthFixed);
				ImGui::TableSetupColumn(useChinese ? r_cast<const char*>(u8"时间") : "Time",
					ImGuiTableColumnFlags_PreferSortDescending
						| ImGuiTableColumnFlags_WidthFixed);
				ImGui::TableSetupColumn(useChinese ? r_cast<const char*>(u8"层级") : "Depth",
					ImGuiTableColumnFlags_PreferSortAscending
						| ImGuiTableColumnFlags_WidthFixed);
				ImGui::TableSetupColumn(useChinese ? r_cast<const char*>(u8"模块名") : "Module",
					ImGuiTableColumnFlags_NoSort
						| ImGuiTableColumnFlags_WidthStretch);
				ImGui::TableSetupScrollFreeze(0, 1);
				ImGui::TableHeadersRow();

				if (ImGuiTableSortSpecs* sortsSpecs = ImGui::TableGetSortSpecs())
					if (sortsSpecs->SpecsDirty) {
						sortsSpecs->SpecsDirty = false;
						std::sort(_loaderCosts.begin(), _loaderCosts.end(), [&](const auto& itemA, const auto& itemB) {
							for (int n = 0; n < sortsSpecs->SpecsCount; n++) {
								const auto& spec = sortsSpecs->Specs[n];
								bool ascending = spec.SortDirection == ImGuiSortDirection_Ascending;
								switch (spec.ColumnIndex) {
									case 0:
										if (itemA.id == itemB.id) continue;
										if (ascending) {
											return itemA.id < itemB.id;
										} else {
											return itemA.id > itemB.id;
										}
									case 1:
										if (itemA.time == itemB.time) continue;
										if (ascending) {
											return itemA.time < itemB.time;
										} else {
											return itemA.time > itemB.time;
										}
									case 2:
										if (itemA.level == itemB.level) continue;
										if (ascending) {
											return itemA.level < itemB.level;
										} else {
											return itemA.level > itemB.level;
										}
								}
							}
							return false;
						});
					}

				auto targetFPS = SharedApplication.getTargetFPS();
				ImGuiListClipper clipper;
				clipper.Begin(_loaderCosts.size());
				while (clipper.Step())
					for (int row = clipper.DisplayStart; row < clipper.DisplayEnd; row++) {
						const auto& item = _loaderCosts[row];
						ImGui::PushID(item.id);
						ImGui::TableNextRow();
						ImGui::TableNextColumn();
						ImGui::Text("%d", item.id);
						ImGui::TableNextColumn();
						if (item.time > 1.0 / targetFPS) {
							ImGui::PushStyleColor(ImGuiCol_Text, themeColor);
							ImGui::TextUnformatted(&item.timeStr.front(), &item.timeStr.back() + 1);
							ImGui::PopStyleColor();
						} else {
							ImGui::TextUnformatted(&item.timeStr.front(), &item.timeStr.back() + 1);
						}
						ImGui::TableNextColumn();
						ImGui::TextUnformatted(&item.levelStr.front(), &item.levelStr.back() + 1);
						ImGui::TableNextColumn();
						ImGui::TextUnformatted(&item.module.front(), &item.module.back() + 1);
						ImGui::PopID();
					}
				ImGui::EndTable();
			}
		}
		if (ImGui::CollapsingHeader(useChinese ? r_cast<const char*>(u8"杂项") : "Misc")) {
			ImGui::PushItemWidth(150);
			ImGui::TextColored(themeColor, useChinese ? r_cast<const char*>(u8"版本号：") : "Version:");
			ImGui::SameLine();
			auto version = SharedApplication.getVersion();
			ImGui::TextUnformatted(&version.front(), &version.back() + 1);
			ImGui::TextColored(themeColor, useChinese ? r_cast<const char*>(u8"调试模式：") : "Debug Mode:");
			ImGui::SameLine();
			auto isDebugging = SharedApplication.isDebugging();
			if (useChinese) {
				ImGui::TextUnformatted(r_cast<const char*>(isDebugging ? u8"开启" : u8"关闭"));
			} else {
				ImGui::TextUnformatted(isDebugging ? "true" : "false");
			}
			if (ImGui::ColorEdit3(useChinese ? r_cast<const char*>(u8"主题色") : "Theme Color", themeColor, ImGuiColorEditFlags_DisplayHex)) {
				SharedApplication.setThemeColor(Color(themeColor));
			}
			static const char* languages[] = {
				"English",
				r_cast<const char*>(u8"简体中文")};
			int index = useChinese ? 1 : 0;
			if (ImGui::Combo(useChinese ? r_cast<const char*>(u8"语言") : "Language", &index, languages, _isChineseSupported ? 2 : 1)) {
				SharedApplication.setLocale(index == 0 ? "en"_slice : "zh-Hans"_slice);
			}
			if (extra) extra();
			ImGui::PopItemWidth();
		}
		ImGui::Dummy(Vec2{200.0f, 0.0f});
	}
	ImGui::End();

	if (_showPlot) {
		const int PlotCount = 30;
		_profileFrames++;
		_profileElapsed += SharedApplication.getDeltaTime();
		_maxCPU = std::max(_maxCPU, SharedApplication.getCPUTime());
		_maxGPU = std::max(_maxGPU, SharedApplication.getGPUTime());
		_maxDelta = std::max(_maxDelta, SharedApplication.getDeltaTime());
		double targetTime = 1000.0 / SharedApplication.getTargetFPS();
		_logicTime += SharedApplication.getLogicTime();
		_renderTime += SharedApplication.getRenderTime();
		if (_profileElapsed >= 1.0) {
			_cpuValues.push_back(_maxCPU * 1000.0);
			_gpuValues.push_back(_maxGPU * 1000.0);
			_dtValues.push_back(_maxDelta * 1000.0);
			_maxCPU = _maxGPU = _maxDelta = 0;
			if (_cpuValues.size() > PlotCount + 1) _cpuValues.erase(_cpuValues.begin());
			if (_gpuValues.size() > PlotCount + 1) _gpuValues.erase(_gpuValues.begin());
			if (_dtValues.size() > PlotCount + 1)
				_dtValues.erase(_dtValues.begin());
			else
				_times.push_back(_dtValues.size() - 1);
			_yLimit = 0;
			for (auto v : _cpuValues)
				if (v > _yLimit) _yLimit = v;
			for (auto v : _gpuValues)
				if (v > _yLimit) _yLimit = v;
			for (auto v : _dtValues)
				if (v > _yLimit) _yLimit = v;
			_updateCosts.clear();
			double time = 0;
			for (const auto& item : _timeCosts) {
				time += item.second;
				_updateCosts[item.first] = std::max(0.0, item.second * 1000.0 / _profileFrames);
			}
			_timeCosts.clear();
			_updateCosts["Logic"s] = std::max(0.0, (_logicTime - time) * 1000.0 / _profileFrames);
			_updateCosts["Render"s] = std::max(0.0, _renderTime * 1000.0 / _profileFrames);
			_logicTime = _renderTime = 0;
			_profileFrames = _profileElapsed = 0;
		}
		Size size = SharedApplication.getVisualSize();
		ImGui::SetNextWindowPos(Vec2{size.width / 2 - 160.0f, 10.0f}, ImGuiCond_FirstUseEver);
		if (ImGui::Begin(useChinese ? r_cast<const char*>(u8"每秒内帧耗时峰值(ms)") : "Frame Time Peaks(ms/s)", nullptr, ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_AlwaysAutoResize)) {
			ImPlot::SetNextAxesLimits(0, PlotCount, 0, std::max(_yLimit, targetTime) + 1.0, ImGuiCond_Always);
			ImPlot::PushStyleColor(ImPlotCol_FrameBg, ImVec4(0, 0, 0, 0));
			ImPlot::PushStyleColor(ImPlotCol_PlotBg, ImVec4(0, 0, 0, 0));
			if (ImPlot::BeginPlot("Time Profiler", Vec2{300.0f, 130.0f},
					ImPlotFlags_NoFrame | ImPlotFlags_NoMenus | ImPlotFlags_NoBoxSelect | ImPlotFlags_NoTitle | ImPlotFlags_NoInputs)) {
				ImPlot::SetupAxis(ImAxis_X1, nullptr, ImPlotAxisFlags_NoTickLabels);
				ImPlot::SetupLegend(ImPlotLocation_South, ImPlotLegendFlags_Horizontal | ImPlotLegendFlags_Outside);
				ImPlot::PlotInfLines(useChinese ? r_cast<const char*>(u8"基准") : "Base", &targetTime, 1, ImPlotInfLinesFlags_Horizontal);
				ImPlot::PlotLine("CPU", _times.data(), _cpuValues.data(),
					s_cast<int>(_cpuValues.size()));
				ImPlot::PlotLine("GPU", _times.data(), _gpuValues.data(),
					s_cast<int>(_gpuValues.size()));
				ImPlot::PlotLine(useChinese ? r_cast<const char*>(u8"帧间隔") : "Delta", _times.data(), _dtValues.data(),
					s_cast<int>(_dtValues.size()));
				ImPlot::EndPlot();
			}
			ImPlot::PopStyleColor(2);
		}
		ImGui::End();
		if (!_updateCosts.empty()) {
			ImGui::SetNextWindowPos(Vec2{size.width / 2 + 170.0f, 10.0f}, ImGuiCond_FirstUseEver);
			if (ImGui::Begin(useChinese ? r_cast<const char*>(u8"每秒内CPU耗时(ms)") : "Total CPU Time(ms/s)", nullptr, ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_AlwaysAutoResize)) {
				ImPlot::PushStyleColor(ImPlotCol_FrameBg, ImVec4(0, 0, 0, 0));
				ImPlot::PushStyleColor(ImPlotCol_PlotBg, ImVec4(0, 0, 0, 0));
				ImPlot::PushStyleColor(ImPlotCol_LegendBg, ImVec4(0, 0, 0, 0.3f));
				ImPlot::SetNextAxesLimits(0, 1, 0, 1, ImGuiCond_Always);
				if (ImPlot::BeginPlot("Update Pie", ImVec2(200.0f, 200.0f), ImPlotFlags_NoTitle | ImPlotFlags_Equal | ImPlotFlags_NoInputs | ImPlotFlags_NoFrame)) {
					std::vector<const char*> pieLabels(_updateCosts.size());
					std::vector<double> pieValues(_updateCosts.size());
					int i = 0;
					for (const auto& item : _updateCosts) {
						pieLabels[i] = item.first.c_str();
						pieValues[i] = item.second;
						i++;
					}
					ImPlot::SetupAxis(ImAxis_X1, nullptr, ImPlotAxisFlags_NoDecorations);
					ImPlot::SetupAxis(ImAxis_Y1, nullptr, ImPlotAxisFlags_NoDecorations);
					ImPlot::SetupLegend(ImPlotLocation_SouthEast);
					ImPlot::PlotPieChart(pieLabels.data(), pieValues.data(), s_cast<int>(pieValues.size()), 0.5, 0.5, 0.45, "%.1f", 90.0, ImPlotPieChartFlags_Normalize);
					ImPlot::EndPlot();
				}
				ImPlot::PopStyleColor(3);
			}
			ImGui::End();
		}
	}
}

void ImGuiDora::showConsole(bool* pOpen) {
	bool useChinese = _useChinese && _isChineseSupported;
	_console->Draw(useChinese ? r_cast<const char*>(u8"Dora 控制台###DoraConsole") : "Dora Console###DoraConsole", useChinese, pOpen);
}

static void SetPlatformImeDataFn(ImGuiViewport*, ImGuiPlatformImeData* data) {
	ImGuiDora::setImePositionHint(s_cast<int>(data->InputPos.x), s_cast<int>(data->InputPos.y + data->InputLineHeight));
}

bool ImGuiDora::isFontLoaded() const {
	return _fontLoaded;
}

bool ImGuiDora::init() {
	ImGui::CreateContext(_defaultFonts.get());
	ImPlot::CreateContext();
	ImGuiStyle& style = ImGui::GetStyle();
	float rounding = 6.0f;
	style.Alpha = 0.8f;
	style.WindowPadding = ImVec2(10, 10);
	style.WindowMinSize = ImVec2(100, 32);
	style.WindowRounding = rounding;
	style.WindowBorderSize = 0.0f;
	style.WindowTitleAlign = ImVec2(0.5f, 0.5f);
	style.ChildRounding = rounding;
	style.ChildBorderSize = 0.0f;
	style.FramePadding = ImVec2(5, 5);
	style.FrameRounding = rounding;
	style.FrameBorderSize = 0.0f;
	style.ItemSpacing = ImVec2(10, 10);
	style.ItemInnerSpacing = ImVec2(5, 5);
	style.TouchExtraPadding = ImVec2(5, 5);
	style.IndentSpacing = 10.0f;
	style.ColumnsMinSpacing = 5.0f;
	style.ScrollbarSize = 25.0f;
	style.ScrollbarRounding = rounding;
	style.GrabMinSize = 20.0f;
	style.GrabRounding = rounding;
	style.TabRounding = rounding;
	style.TabBorderSize = 0.0f;
	style.PopupRounding = rounding;
	style.PopupBorderSize = 0.0f;
	style.ButtonTextAlign = ImVec2(0.5f, 0.5f);
	style.DisplayWindowPadding = ImVec2(50, 50);
	style.DisplaySafeAreaPadding = ImVec2(5, 5);
	style.AntiAliasedLines = true;
	style.AntiAliasedFill = true;
	style.CurveTessellationTol = 1.0f;

	DoraSetupTheme(SharedApplication.getThemeColor());

	ImGuiIO& io = ImGui::GetIO();
	_keymap[SDLK_TAB] = ImGuiKey_Tab;
	_keymap[SDLK_z] = ImGuiKey_Z;
	_keymap[SDLK_y] = ImGuiKey_Y;
	_keymap[SDLK_x] = ImGuiKey_X;
	_keymap[SDLK_v] = ImGuiKey_V;
	_keymap[SDLK_c] = ImGuiKey_C;
	_keymap[SDLK_a] = ImGuiKey_A;
	_keymap[SDLK_ESCAPE] = ImGuiKey_Escape;
	_keymap[SDLK_RETURN] = ImGuiKey_Enter;
	_keymap[SDLK_BACKSPACE] = ImGuiKey_Backspace;
	_keymap[SDLK_DELETE] = ImGuiKey_Delete;
	_keymap[SDL_SCANCODE_END] = ImGuiKey_End;
	_keymap[SDL_SCANCODE_HOME] = ImGuiKey_Home;
	_keymap[SDL_SCANCODE_PAGEDOWN] = ImGuiKey_PageDown;
	_keymap[SDL_SCANCODE_PAGEUP] = ImGuiKey_PageUp;
	_keymap[SDL_SCANCODE_DOWN] = ImGuiKey_DownArrow;
	_keymap[SDL_SCANCODE_UP] = ImGuiKey_UpArrow;
	_keymap[SDL_SCANCODE_RIGHT] = ImGuiKey_RightArrow;
	_keymap[SDL_SCANCODE_LEFT] = ImGuiKey_LeftArrow;

	io.SetClipboardTextFn = ImGuiDora::setClipboardText;
	io.GetClipboardTextFn = ImGuiDora::getClipboardText;
	io.SetPlatformImeDataFn = SetPlatformImeDataFn;
	io.ClipboardUserData = nullptr;

	_iniFilePath = SharedContent.getWritablePath() + "imgui.ini";
	io.IniFilename = _iniFilePath.c_str();

	_sampler = bgfx::createUniform("s_texColor", bgfx::UniformType::Sampler);

	_defaultPass = Pass::create(
		"builtin:vs_ocornut_imgui"_slice,
		"builtin:fs_ocornut_imgui"_slice);

	_imagePass = Pass::create(
		"builtin:vs_ocornut_imgui"_slice,
		"builtin:fs_ocornut_imgui_image"_slice);

	uint8_t* texData;
	int width;
	int height;
	io.Fonts->GetTexDataAsAlpha8(&texData, &width, &height);
	updateTexture(texData, width, height);
	io.Fonts->ClearTexData();

	SharedDirector.getSystemScheduler()->schedule([this](double deltaTime) {
		if (_backSpaceIgnore) _backSpaceIgnore = false;
		if (!_inputs.empty()) {
			auto& event = *std::any_cast<SDL_Event>(&_inputs.front());
			ImGuiIO& io = ImGui::GetIO();
			switch (event.type) {
				case SDL_MOUSEBUTTONUP: {
					switch (event.button.button) {
						case SDL_BUTTON_LEFT: _mousePressed[0] = false; break;
						case SDL_BUTTON_RIGHT: _mousePressed[1] = false; break;
						case SDL_BUTTON_MIDDLE: _mousePressed[2] = false; break;
					}
					break;
				}
				case SDL_TEXTINPUT: {
					if (event.text.text[0] != '\0') {
						io.AddInputCharactersUTF8(event.text.text);
					}
					break;
				}
				case SDL_KEYDOWN:
				case SDL_KEYUP: {
					SDL_Keycode code = event.key.keysym.sym;
					int key = code & ~SDLK_SCANCODE_MASK;
					uint16_t mod = event.key.keysym.mod;
					io.AddKeyEvent(ImGuiMod_Shift, (mod & KMOD_SHIFT) != 0);
					io.AddKeyEvent(ImGuiMod_Ctrl, (mod & KMOD_CTRL) != 0);
					io.AddKeyEvent(ImGuiMod_Alt, (mod & KMOD_ALT) != 0);
					io.AddKeyEvent(ImGuiMod_Super, (mod & KMOD_GUI) != 0);
					if (_textEditing.empty() || code == SDLK_BACKSPACE || code == SDLK_LEFT || code == SDLK_RIGHT) {
						if (auto it = _keymap.find(key); it != _keymap.end()) {
							io.AddKeyEvent(static_cast<ImGuiKey>(it->second), event.type == SDL_KEYDOWN);
						}
					}
					break;
				}
			}
			_inputs.pop_front();
		}
		return false;
	});

	return true;
}

void ImGuiDora::begin() {
	ImGuiIO& io = ImGui::GetIO();
	Size visualSize = SharedApplication.getVisualSize();
	io.DisplaySize.x = visualSize.width;
	io.DisplaySize.y = visualSize.height;
	io.DeltaTime = s_cast<float>(SharedApplication.getDeltaTime());

	if (_textInputing != io.WantTextInput) {
		_textInputing = io.WantTextInput;
		if (_textInputing || !SharedKeyboard.isIMEAttached()) {
			if (_textInputing) {
				_textEditing.clear();
				_lastCursor = 0;
				SharedKeyboard.detachIME();
			}
			SharedApplication.invokeInRender(_textInputing ? SDL_StartTextInput : SDL_StopTextInput);
			if (_textInputing) {
				setImePositionHint(_lastIMEPosX, _lastIMEPosY);
			}
		}
	}

	io.AddMouseButtonEvent(0, _mousePressed[0]);
	io.AddMouseButtonEvent(1, _mousePressed[1]);
	io.AddMouseButtonEvent(2, _mousePressed[2]);
	io.AddMouseWheelEvent(_mouseWheel.x, _mouseWheel.y);
	_mouseWheel = Vec2::zero;

	if (_mouseVisible != io.MouseDrawCursor) {
		_mouseVisible = io.MouseDrawCursor;
		SharedApplication.invokeInRender([this]() {
			// Hide OS mouse cursor if ImGui is drawing it
			SDL_ShowCursor(_mouseVisible ? SDL_FALSE : SDL_TRUE);
		});
	}

	// Start the frame
	ImGui::NewFrame();
}

void ImGuiDora::end() {
	ImGui::Render();
}

inline bool checkAvailTransientBuffers(uint32_t _numVertices, const bgfx::VertexLayout& _decl, uint32_t _numIndices) {
	return _numVertices == bgfx::getAvailTransientVertexBuffer(_numVertices, _decl)
		&& _numIndices == bgfx::getAvailTransientIndexBuffer(_numIndices);
}

void ImGuiDora::render() {
	ImDrawData* drawData = ImGui::GetDrawData();
	if (drawData->CmdListsCount == 0) {
		return;
	}

	SharedView.pushBack("ImGui"_slice, [&]() {
		bgfx::ViewId viewId = SharedView.getId();

		float scale = SharedApplication.getDevicePixelRatio();
		_defaultPass->set("u_scale"_slice, scale);
		_imagePass->set("u_scale"_slice, scale);

		// Render command lists
		for (int32_t ii = 0, num = drawData->CmdListsCount; ii < num; ++ii) {
			bgfx::TransientVertexBuffer tvb;
			bgfx::TransientIndexBuffer tib;

			const ImDrawList* drawList = drawData->CmdLists[ii];
			uint32_t numVertices = s_cast<uint32_t>(drawList->VtxBuffer.size());
			uint32_t numIndices = s_cast<uint32_t>(drawList->IdxBuffer.size());

			if (!checkAvailTransientBuffers(numVertices, _vertexLayout, numIndices)) {
				Warn("not enough space in transient buffer just quit drawing the rest.");
				break;
			}

			bgfx::allocTransientVertexBuffer(&tvb, numVertices, _vertexLayout);
			bgfx::allocTransientIndexBuffer(&tib, numIndices, std::is_same_v<ImDrawIdx, uint32_t>);

			ImDrawVert* verts = r_cast<ImDrawVert*>(tvb.data);
			std::memcpy(verts, drawList->VtxBuffer.begin(), numVertices * sizeof(drawList->VtxBuffer[0]));

			ImDrawIdx* indices = r_cast<ImDrawIdx*>(tib.data);
			std::memcpy(indices, drawList->IdxBuffer.begin(), numIndices * sizeof(drawList->IdxBuffer[0]));

			for (const ImDrawCmd *cmd = drawList->CmdBuffer.begin(), *cmdEnd = drawList->CmdBuffer.end(); cmd != cmdEnd; ++cmd) {
				if (cmd->UserCallback) {
					cmd->UserCallback(drawList, cmd);
				} else if (0 != cmd->ElemCount) {
					bgfx::TextureHandle textureHandle;
					bgfx::ProgramHandle program;
					if (nullptr != cmd->TextureId) {
						union {
							ImTextureID ptr;
							struct {
								bgfx::TextureHandle handle;
							} s;
						} texture = {cmd->TextureId};
						textureHandle = texture.s.handle;
						program = _imagePass->apply();
					} else {
						textureHandle = _fontTexture->getHandle();
						program = _defaultPass->apply();
					}

					uint64_t state = 0
								   | BGFX_STATE_WRITE_RGB
								   | BGFX_STATE_WRITE_A
								   | BGFX_STATE_MSAA
								   | BGFX_STATE_BLEND_FUNC(BGFX_STATE_BLEND_SRC_ALPHA, BGFX_STATE_BLEND_INV_SRC_ALPHA);

					const uint16_t xx = uint16_t(bx::max(cmd->ClipRect.x * scale, 0.0f));
					const uint16_t yy = uint16_t(bx::max(cmd->ClipRect.y * scale, 0.0f));
					bgfx::setScissor(xx, yy,
						uint16_t(bx::min(cmd->ClipRect.z * scale, 65535.0f) - xx),
						uint16_t(bx::min(cmd->ClipRect.w * scale, 65535.0f) - yy));
					bgfx::setState(state);
					bgfx::setTexture(0, _sampler, textureHandle);
					bgfx::setVertexBuffer(0, &tvb, 0, numVertices);
					bgfx::setIndexBuffer(&tib, cmd->IdxOffset, cmd->ElemCount);
					bgfx::submit(viewId, program);
				}
			}
		}
	});
}

void ImGuiDora::sendKey(int key, int count) {
	for (int i = 0; i < count; i++) {
		SDL_Event e = {};
		e.type = SDL_KEYDOWN;
		e.key.keysym.sym = key;
		_inputs.push_back(e);
		e.type = SDL_KEYUP;
		_inputs.push_back(e);
	}
}

void ImGuiDora::updateTexture(uint8_t* data, int width, int height) {
	const uint64_t textureFlags = BGFX_SAMPLER_MIN_POINT | BGFX_SAMPLER_MAG_POINT;

	bgfx::TextureHandle textureHandle = bgfx::createTexture2D(
		s_cast<uint16_t>(width), s_cast<uint16_t>(height),
		false, 1, bgfx::TextureFormat::A8, textureFlags,
		bgfx::copy(data, width * height * 1));

	bgfx::TextureInfo info;
	bgfx::calcTextureSize(info,
		s_cast<uint16_t>(width), s_cast<uint16_t>(height),
		0, false, false, 1, bgfx::TextureFormat::A8);

	_fontTexture = Texture2D::create(textureHandle, info, textureFlags);
}

void ImGuiDora::handleEvent(const SDL_Event& event) {
	switch (event.type) {
		case SDL_MOUSEWHEEL: {
			if (event.wheel.y > 0) {
				_mouseWheel.y = 1;
			} else if (event.wheel.y < 0) {
				_mouseWheel.y = -1;
			}
			if (event.wheel.x > 0) {
				_mouseWheel.x = 1;
			} else if (event.wheel.x < 0) {
				_mouseWheel.x = -1;
			}
			break;
		}
		case SDL_MOUSEBUTTONDOWN: {
			switch (event.button.button) {
				case SDL_BUTTON_LEFT: _mousePressed[0] = true; break;
				case SDL_BUTTON_RIGHT: _mousePressed[1] = true; break;
				case SDL_BUTTON_MIDDLE: _mousePressed[2] = true; break;
			}
			break;
		}
		case SDL_MOUSEBUTTONUP: {
			SharedDirector.getSystemScheduler()->schedule([this, event](double deltaTime) {
				DORA_UNUSED_PARAM(deltaTime);
				_inputs.push_back(event);
				return true;
			});
			break;
		}
		case SDL_MOUSEMOTION: {
			Size visualSize = SharedApplication.getVisualSize();
			Size winSize = SharedApplication.getWinSize();
			ImGui::GetIO().MousePos = Vec2{
				s_cast<float>(event.motion.x) * visualSize.width / winSize.width,
				s_cast<float>(event.motion.y) * visualSize.height / winSize.height};
			break;
		}
		case SDL_KEYDOWN:
		case SDL_KEYUP: {
			if (_textEditing.empty()) {
				int key = event.key.keysym.sym & ~SDLK_SCANCODE_MASK;
				if (key != SDLK_BACKSPACE || !_backSpaceIgnore) {
					_inputs.push_back(event);
				}
			}
			break;
		}
		case SDL_TEXTINPUT: {
			int size = s_cast<int>(_textEditing.size());
			if (_lastCursor < size) {
				sendKey(SDLK_RIGHT, size - _lastCursor);
			}

			auto newText = utf8_get_characters(event.text.text);
			size_t start = _textEditing.size();
			for (size_t i = 0; i < _textEditing.size(); i++) {
				if (i >= newText.size() || newText[i] != _textEditing[i]) {
					start = i;
					break;
				}
			}
			int count = s_cast<int>(_textEditing.size() - start);
			sendKey(SDLK_BACKSPACE, count);

			size_t length = strlen(event.edit.text);
			start = length;
			count = 0;
			int lastPos = -1;
			utf8_each_character(event.edit.text, [&](int stop, uint32_t code) {
				if (count >= s_cast<int>(_textEditing.size()) || _textEditing[count] != code) {
					start = lastPos + 1;
					return true;
				}
				count++;
				lastPos = stop;
				return false;
			});
			SDL_Event e = {};
			e.type = SDL_TEXTINPUT;
			memcpy(e.text.text, event.edit.text + start, length - start + 1);
			_inputs.push_back(e);

			_textEditing.clear();
			_lastCursor = 0;
			break;
		}
		case SDL_TEXTEDITING: {
			auto newText = utf8_get_characters(event.edit.text);
			if (newText.size() == _textEditing.size()) {
				bool changed = false;
				for (size_t i = 0; i < newText.size(); i++) {
					if (newText[i] != _textEditing[i]) {
						changed = true;
					}
				}
				if (!changed) {
					int32_t cursor = event.edit.start;
					if (cursor > _lastCursor) {
						sendKey(SDLK_RIGHT, cursor - _lastCursor);
					} else if (cursor < _lastCursor) {
						sendKey(SDLK_LEFT, _lastCursor - cursor);
					}
					_lastCursor = cursor;
					break;
				}
			}

			if (_lastCursor == _textEditing.size()) {
				size_t start = _textEditing.size();
				for (size_t i = 0; i < _textEditing.size(); i++) {
					if (i >= newText.size() || newText[i] != _textEditing[i]) {
						start = i;
						break;
					}
				}
				int count = s_cast<int>(_textEditing.size() - start);
				sendKey(SDLK_BACKSPACE, count);
				_lastCursor -= count;
			} else {
				sendKey(SDLK_RIGHT, s_cast<int>(_textEditing.size()) - _lastCursor);
				_lastCursor += (_textEditing.size() - _lastCursor);
				int count = 0;
				bool different = false;
				for (size_t i = 0; i < _textEditing.size(); i++) {
					if (different || (i >= newText.size() || newText[i] != _textEditing[i])) {
						count++;
						different = true;
					}
				}
				sendKey(SDLK_BACKSPACE, count);
				_lastCursor -= count;
			}
			size_t length = strlen(event.edit.text);
			size_t start = length;
			size_t count = 0;
			int lastPos = -1;
			utf8_each_character(event.edit.text, [&](int stop, uint32_t code) {
				if (count >= _textEditing.size() || _textEditing[count] != code) {
					start = lastPos + 1;
					return true;
				}
				count++;
				lastPos = stop;
				return false;
			});
			SDL_Event e = {};
			e.type = SDL_TEXTINPUT;
			memcpy(e.text.text, event.edit.text + start, length - start + 1);
			_inputs.push_back(e);
			int addCount = utf8_count_characters(e.text.text);
			_lastCursor += addCount;
			int32_t cursor = event.edit.start;
			if (cursor > _lastCursor) {
				sendKey(SDLK_RIGHT, cursor - _lastCursor);
			} else if (cursor < _lastCursor) {
				sendKey(SDLK_LEFT, _lastCursor - cursor);
			}
			_lastCursor = cursor;

			_textEditing = newText;
			if (_textEditing.empty()) _backSpaceIgnore = true;
			break;
		}
	}
}

bool ImGuiDora::ImGuiTouchHandler::handle(const SDL_Event& event) {
	switch (event.type) {
		case SDL_MOUSEBUTTONDOWN:
		case SDL_FINGERDOWN:
			if (ImGui::IsAnyItemHovered()
				|| ImGui::IsAnyItemActive()
				|| ImGui::IsAnyItemFocused()
				|| ImGui::IsPopupOpen(nullptr, ImGuiPopupFlags_AnyPopupId | ImGuiPopupFlags_AnyPopupLevel)) {
				_owner->_rejectAllEvents = true;
			}
			break;
		case SDL_MOUSEBUTTONUP:
			if (_owner->_rejectAllEvents) {
				_owner->_rejectAllEvents = false;
			}
			break;
		default:
			break;
	}
	switch (event.type) {
		case SDL_MOUSEBUTTONDOWN:
		case SDL_FINGERDOWN:
		case SDL_MULTIGESTURE:
			return _owner->_rejectAllEvents;
		case SDL_MOUSEWHEEL:
			return ImGui::IsAnyItemHovered()
				|| ImGui::IsAnyItemActive()
				|| ImGui::IsAnyItemFocused()
				|| ImGui::IsPopupOpen(nullptr, ImGuiPopupFlags_AnyPopupId | ImGuiPopupFlags_AnyPopupLevel);
	}
	return false;
}

NS_DORA_END
