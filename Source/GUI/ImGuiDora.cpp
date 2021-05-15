/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "GUI/ImGuiDora.h"
#include "Basic/Application.h"
#include "Cache/ShaderCache.h"
#include "Effect/Effect.h"
#include "Basic/Content.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Basic/View.h"
#include "Cache/TextureCache.h"
#include "Other/utf8.h"
#include "imgui.h"
#include "implot.h"
#include "Input/Keyboard.h"
#include "Lua/LuaEngine.h"
#include "Event/Event.h"
#include "Event/Listener.h"

#include "SDL.h"

NS_DOROTHY_BEGIN

#define MAX_FONT_TEXTURE_WIDTH 8192

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

class ConsolePanel
{
public:
	ConsolePanel():
	_forceScroll(0),
	_historyPos(-1),
	_fullScreen(false),
	_scrollToBottom(false),
	_commands({
		"print",
		"import"
	})
	{
		_buf.fill('\0');
		LogHandler += std::make_pair(this, &ConsolePanel::addLog);
	}

	~ConsolePanel()
	{
		LogHandler -= std::make_pair(this, &ConsolePanel::addLog);
	}

	void clear()
	{
		_logs.clear();
	}

	void addLog(const std::string& text)
	{
		size_t start = 0, end = 0;
		std::list<Slice> lines;
		const char* str = text.c_str();
		while ((end = text.find_first_of("\n", start)) != std::string::npos)
		{
			lines.push_back(Slice(str + start, end - start));
			start = end+1;
		}
		for (auto line : lines)
		{
			_logs.push_back(line);
		}
		_scrollToBottom = true;
	}

	static int TextEditCallbackStub(ImGuiInputTextCallbackData* data)
	{
		ConsolePanel* panel = r_cast<ConsolePanel*>(data->UserData);
		return panel->TextEditCallback(data);
	}

	int TextEditCallback(ImGuiInputTextCallbackData* data)
	{
		switch (data->EventFlag)
		{
			case ImGuiInputTextFlags_CallbackCompletion:
			{
				const char* word_end = data->Buf + data->CursorPos;
				const char* word_start = word_end;
				while (word_start > data->Buf)
				{
					const char c = word_start[-1];
					if (c == ' ' || c == '\t' || c == ',' || c == ';')
					{
						break;
					}
					word_start--;
				}
				ImVector<const char*> candidates;
				for (size_t i = 0; i < _commands.size(); i++)
				{
					if (std::strncmp(_commands[i], word_start, (int)(word_end - word_start)) == 0)
					{
						candidates.push_back(_commands[i]);
					}
				}
				if (candidates.Size == 1)
				{
					data->DeleteChars((int)(word_start - data->Buf), (int)(word_end - word_start));
					data->InsertChars(data->CursorPos, candidates[0]);
					data->InsertChars(data->CursorPos, " ");
				}
				else if (candidates.Size > 1)
				{
					int match_len = (int)(word_end - word_start);
					for (;;)
					{
						int c = 0;
						bool all_candidates_matches = true;
						for (int i = 0; i < candidates.Size && all_candidates_matches; i++)
						{
							if (i == 0)
							{
								c = toupper(candidates[i][match_len]);
							}
							else if (c == 0 || c != toupper(candidates[i][match_len]))
							{
								all_candidates_matches = false;
							}
						}
						if (!all_candidates_matches) break;
						match_len++;
					}
					if (match_len > 0)
					{
						data->DeleteChars((int)(word_start - data->Buf), (int)(word_end - word_start));
						data->InsertChars(data->CursorPos, candidates[0], candidates[0] + match_len);
					}
				}
				break;
			}
			case ImGuiInputTextFlags_CallbackHistory:
			{
				const int prev_history_pos = _historyPos;
				if (data->EventKey == ImGuiKey_UpArrow)
				{
					if (_historyPos == -1) _historyPos = s_cast<int>(_history.size()) - 1;
					else if (_historyPos > 0) _historyPos--;
				}
				else if (data->EventKey == ImGuiKey_DownArrow)
				{
					if (_historyPos != -1)
					if (++_historyPos >= s_cast<int>(_history.size()))
					{
						_historyPos = -1;
					}
				}
				if (prev_history_pos != _historyPos)
				{
					const char* history_str = (_historyPos >= 0) ? _history[_historyPos].c_str() : "";
					data->DeleteChars(0, data->BufTextLen);
					data->InsertChars(0, history_str);
				}
				break;
			}
		}
		return 0;
	}

	void Draw(const char* title, bool* p_open = nullptr)
	{
		if (_fullScreen)
		{
			ImGui::SetNextWindowPos(Vec2::zero);
			ImGui::SetNextWindowSize(Vec2{1,1}*SharedApplication.getVisualSize(), ImGuiCond_Always);
			ImGui::Begin((std::string(title)+"_full").c_str(), nullptr, ImGuiWindowFlags_NoTitleBar|ImGuiWindowFlags_NoResize|ImGuiWindowFlags_NoCollapse|ImGuiWindowFlags_NoMove|ImGuiWindowFlags_NoSavedSettings);
		}
		else
		{
			ImGui::SetNextWindowSize(ImVec2(400,300), ImGuiCond_FirstUseEver);
			ImGui::Begin(title, p_open);
		}
		if (ImGui::Button("Clear")) clear();
		ImGui::SameLine();
		if (ImGui::Button("Copy") && !_logs.empty())
		{
			std::string logText;
			for (const auto& line : _logs)
			{
				logText.append(line);
				if (line != _logs.back())
				{
					logText.append("\n");
				}
			}
			SDL_SetClipboardText(logText.c_str());
		}
		ImGui::SameLine();
		if (ImGui::Button(_fullScreen ? "]  [" : "[  ]"))
		{
			_forceScroll = 2;
			_scrollToBottom = true;
			_fullScreen = !_fullScreen;
		}
		ImGui::SameLine();
		_filter.Draw("Filter", -55.0f);
		ImGui::Separator();
		const float footer_height_to_reserve = ImGui::GetStyle().ItemSpacing.y + ImGui::GetFrameHeightWithSpacing();
		ImGui::BeginChild(_fullScreen ? "scrolling_full" : "scrolling", ImVec2(0, -footer_height_to_reserve), false);
		if (_forceScroll == 0 && _scrollToBottom && ImGui::GetScrollY()+footer_height_to_reserve < ImGui::GetScrollMaxY())
		{
			_scrollToBottom = false;
		}
		if (!_filter.IsActive())
		{
			ImVec2 itemSpacing = ImGui::GetStyle().ItemSpacing;
			ImGui::PushStyleVar(ImGuiStyleVar_ItemSpacing, ImVec2(itemSpacing.x, 0));
			ImGuiListClipper clipper;
			clipper.Begin(s_cast<int>(_logs.size()));
			while (clipper.Step())
			{
				for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++)
				{
					ImGui::TextUnformatted(&_logs.at(i).front(), &_logs.at(i).back()+1);
				}
			}
			clipper.End();
			ImGui::PopStyleVar();
		}
		else
		{
			_filteredLogs.clear();
			for (const auto& line : _logs)
			{
				if (_filter.PassFilter(line.c_str()))
				{
					_filteredLogs.push_back(line);
				}
			}
			ImGuiListClipper clipper;
			clipper.Begin(s_cast<int>(_filteredLogs.size()));
			while (clipper.Step())
			{
				for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++)
				{
					ImGui::TextUnformatted(_filteredLogs.at(i).begin(), _filteredLogs.at(i).end());
				}
			}
			clipper.End();
		}
		if (_scrollToBottom)
		{
			_scrollToBottom = false;
			ImGui::SetScrollHereY();
		}
		if (_forceScroll > 0)
		{
			_forceScroll--;
			ImGui::SetScrollHereY();
		}
		ImGui::EndChild();
		ImGui::Separator();

		bool reclaimFocus = false;
		ImGuiInputTextFlags inputTextFlags = ImGuiInputTextFlags_EnterReturnsTrue | ImGuiInputTextFlags_CallbackCompletion | ImGuiInputTextFlags_CallbackHistory;
		ImGui::PushItemWidth(-55);
		if (ImGui::InputText("Input", _buf.data(), _buf.size(), inputTextFlags, &TextEditCallbackStub, r_cast<void*>(this)))
		{
			_historyPos = -1;
			for (int i = s_cast<int>(_history.size()) - 1; i >= 0; i--)
			{
				if (_history[i] == _buf.data())
				{
					_history.erase(_history.begin() + i);
					break;
				}
			}
			std::string codes = _buf.data();
			_buf.fill('\0');
			_history.push_back(codes);
			LogPrint(codes + '\n');
			codes.insert(0,
				"rawset builtin, '_REPL', index#: builtin unless builtin._REPL\n"
				"_ENV = builtin._REPL\n"
				"global *\n"_slice);
			lua_State* L = SharedLuaEngine.getState();
			int top = lua_gettop(L);
			DEFER(lua_settop(L, top));
			pushYue(L, "loadstring"_slice);
			lua_pushlstring(L, codes.c_str(), codes.size());
			lua_pushliteral(L, "=(repl)");
			pushOptions(L, -3);
			BLOCK_START
			if (lua_pcall(L, 3, 2, 0) != 0)
			{
				LogPrint("{}\n", lua_tostring(L, -1));
				break;
			}
			if (lua_isnil(L, -2) != 0)
			{
				std::string err = lua_tostring(L, -1);
				auto modName = "(repl):"_slice;
				if (err.substr(0, modName.size()) == modName)
				{
					err = err.substr(modName.size());
				}
				auto pos = err.find(':');
				if (pos != std::string::npos)
				{
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
			if (lua_pcall(L, 1, LUA_MULTRET, 0) != 0)
			{
				LogPrint("{}\n", lua_tostring(L, -1));
				break;
			}
			int cur = lua_gettop(L);
			int retCount = cur - last;
			bool success = lua_toboolean(L, -retCount) != 0;
			if (success)
			{
				if (retCount > 1)
				{
					for (int i = 1; i < retCount; ++i)
					{
						LogPrint("{}\n", luaL_tolstring(L, -retCount + i, nullptr));
						lua_pop(L, 1);
					}
				}
			}
			else
			{
				LogPrint("{}\n", lua_tostring(L, -1));
			}
			BLOCK_END
			_scrollToBottom = true;
			reclaimFocus = true;
		}
		ImGui::PopItemWidth();
		ImGui::SetItemDefaultFocus();
		if (reclaimFocus) ImGui::SetKeyboardFocusHere(-1);
		ImGui::End();
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
};

int ImGuiDora::_lastIMEPosX;
int ImGuiDora::_lastIMEPosY;

ImGuiDora::ImGuiDora():
_touchHandler(nullptr),
_rejectAllEvents(false),
_textInputing(false),
_mouseVisible(true),
_lastCursor(0),
_backSpaceIgnore(false),
_mousePressed{false, false, false},
_mouseWheel(0.0f),
_console(New<ConsolePanel>()),
_defaultFonts(New<ImFontAtlas>()),
_fonts(New<ImFontAtlas>()),
_showPlot(false),
_timeFrames(0),
_memFrames(0),
_profileFrames(0),
_cpuTime(0),
_gpuTime(0),
_deltaTime(0),
_logicTime(0),
_renderTime(0),
_avgCPUTime(0),
_avgGPUTime(0),
_avgDeltaTime(1000.0 / SharedApplication.getTargetFPS()),
_memPoolSize(0),
_memLua(0),
_lastMemPoolSize(0),
_lastMemLua(0),
_maxCPU(0),
_maxGPU(0),
_maxDelta(0),
_yLimit(0)
{
	_vertexLayout
		.begin()
			.add(bgfx::Attrib::Position, 2, bgfx::AttribType::Float)
			.add(bgfx::Attrib::TexCoord0, 2, bgfx::AttribType::Float)
			.add(bgfx::Attrib::Color0, 4, bgfx::AttribType::Uint8, true)
		.end();
	SharedApplication.eventHandler += std::make_pair(this, &ImGuiDora::handleEvent);
	_costListener = Listener::create("_TIMECOST_"_slice, [&](Event* e)
	{
		std::string name;
		double cost;
		e->get(name, cost);
		if (!_timeCosts.insert({name, cost}).second)
		{
			_timeCosts[name] += cost;
		}
	});
}

ImGuiDora::~ImGuiDora()
{
	SharedApplication.eventHandler -= std::make_pair(this, &ImGuiDora::handleEvent);
	ImPlot::DestroyContext();
	ImGui::DestroyContext();
}

const char* ImGuiDora::getClipboardText(void*)
{
	return SDL_GetClipboardText();
}

void ImGuiDora::setClipboardText(void*, const char* text)
{
	SDL_SetClipboardText(text);
}

void ImGuiDora::setImePositionHint(int x, int y)
{
	if (x <= 1 && y <= 1) return;
	_lastIMEPosX = x;
	_lastIMEPosY = y;
	float scale =
#if BX_PLATFORM_WINDOWS
		SharedApplication.getDeviceRatio();
#else
		1.0f;
#endif // BX_PLATFORM_WINDOWS
	SharedKeyboard.updateIMEPosHint({s_cast<float>(x) * scale, s_cast<float>(y) * scale});
}

void ImGuiDora::loadFontTTF(String ttfFontFile, float fontSize, String glyphRanges)
{
	static bool isLoadingFont = false;
	AssertIf(isLoadingFont, "font is loading.");
	isLoadingFont = true;

	float scale = SharedApplication.getDeviceRatio();
	fontSize *= scale;

	int64_t size;
	uint8_t* fileData = SharedContent.loadUnsafe(ttfFontFile, size);

	if (!fileData)
	{
		Warn("failed to load ttf file for ImGui!");
		return;
	}
	
	ImGuiIO& io = ImGui::GetIO();
	io.FontGlobalScale = 1.0f / scale;
	io.Fonts->ClearFonts();
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
	io.Fonts->ClearInputData();

	const ImWchar* targetGlyphRanges = nullptr;
	switch (Switch::hash(glyphRanges))
	{
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
	}

	if (targetGlyphRanges)
	{
		_fonts->AddFontFromMemoryTTF(fileData, s_cast<int>(size), s_cast<float>(fontSize), &fontConfig, targetGlyphRanges);
		SharedAsyncThread.run([this]()
		{
			_fonts->Flags |= ImFontAtlasFlags_NoPowerOfTwoHeight;
			_fonts->TexDesiredWidth = MAX_FONT_TEXTURE_WIDTH;
			_fonts->Build();
			return nullptr;
		}, [this, fileData, size](Own<Values> result)
		{
			ImGuiIO& io = ImGui::GetIO();
			io.Fonts->Clear();
			io.Fonts = _fonts.get();
			updateTexture(_fonts->TexPixelsAlpha8, _fonts->TexWidth, _fonts->TexHeight);
			MakeOwnArray(fileData);
			isLoadingFont = false;
		});
	}
	else
	{
		MakeOwnArray(fileData);
		isLoadingFont = false;
	}
}

void ImGuiDora::showStats()
{
	/* print debug text */
	if (ImGui::Begin("Dorothy Stats", nullptr,
		ImGuiWindowFlags_NoResize |
		ImGuiWindowFlags_NoSavedSettings |
		ImGuiWindowFlags_AlwaysAutoResize))
	{
		if (ImGui::CollapsingHeader("Basic"))
		{
			static const char* rendererNames[] = {
				"Noop", //!< No rendering.
				"Direct3D9", //!< Direct3D 9.0
				"Direct3D11", //!< Direct3D 11.0
				"Direct3D12", //!< Direct3D 12.0
				"Gnm", //!< GNM
				"Metal", //!< Metal
				"OpenGLES", //!< OpenGL ES 2.0+
				"OpenGL", //!< OpenGL 2.1+
				"Vulkan", //!< Vulkan
			};
			ImGui::TextColored(Color(0xff00ffff).toVec4(), "Renderer:");
			ImGui::SameLine();
			ImGui::TextUnformatted(rendererNames[bgfx::getCaps()->rendererType]);
			ImGui::TextColored(Color(0xff00ffff).toVec4(), "Multithreaded:");
			ImGui::SameLine();
			ImGui::TextUnformatted((bgfx::getCaps()->supported & BGFX_CAPS_RENDERER_MULTITHREADED) ? "true" : "false");
			ImGui::TextColored(Color(0xff00ffff).toVec4(), "Backbuffer:");
			ImGui::SameLine();
			Size size = SharedView.getSize();
			ImGui::Text("%d x %d", s_cast<int>(size.width), s_cast<int>(size.height));
			ImGui::TextColored(Color(0xff00ffff).toVec4(), "Drawcall:");
			ImGui::SameLine();
			ImGui::Text("%d", bgfx::getStats()->numDraw);
			bool vsync = SharedView.isVSync();
			if (ImGui::Checkbox("VSync", &vsync))
			{
				SharedView.setVSync(vsync);
			}
			ImGui::SameLine();
			bool fpsLimited = SharedApplication.isFPSLimited();
			if (ImGui::Checkbox("FPS Limited", &fpsLimited))
			{
				SharedApplication.setFPSLimited(fpsLimited);
			}
			ImGui::TextColored(Color(0xff00ffff).toVec4(), "FPS:");
			ImGui::SameLine();
			int targetFPS = SharedApplication.getTargetFPS();
			if (ImGui::RadioButton("30", &targetFPS, 30))
			{
				SharedApplication.setTargetFPS(targetFPS);
			}
			ImGui::SameLine();
			if (ImGui::RadioButton("60", &targetFPS, 60))
			{
				SharedApplication.setTargetFPS(targetFPS);
			}
			if (SharedApplication.getMaxFPS() > 60)
			{
				ImGui::SameLine();
				int maxFPS = SharedApplication.getMaxFPS();
				std::string fpsStr = std::to_string(maxFPS);
				if (ImGui::RadioButton(fpsStr.c_str(), &targetFPS, maxFPS))
				{
					SharedApplication.setTargetFPS(targetFPS);
				}
			}
			int fixedFPS = SharedDirector.getScheduler()->getFixedFPS();
			ImGui::PushItemWidth(100.0f);
			if (ImGui::DragInt("Fixed FPS", &fixedFPS, 1, 30, SharedApplication.getMaxFPS()))
			{
				SharedDirector.getScheduler()->setFixedFPS(fixedFPS);
			}
			ImGui::PopItemWidth();
		}
		if (ImGui::CollapsingHeader("Time"))
		{
			_timeFrames++;
			_cpuTime += SharedApplication.getCPUTime();
			_gpuTime += SharedApplication.getGPUTime();
			_deltaTime += SharedApplication.getDeltaTime();
			if (_timeFrames >= SharedApplication.getTargetFPS())
			{
				_avgCPUTime = 1000.0 * _cpuTime / _timeFrames;
				_avgGPUTime = 1000.0 * _gpuTime / _timeFrames;
				_avgDeltaTime = 1000.0 * _deltaTime / _timeFrames;
				_cpuTime = _gpuTime = _deltaTime = 0.0;
				_timeFrames = 0;
			}
			ImGui::Checkbox("Show Plot", &_showPlot);
			ImGui::TextColored(Color(0xff00ffff).toVec4(), "AVG FPS:");
			ImGui::SameLine();
			ImGui::Text("%.1f", 1000.0f / _avgDeltaTime);
			ImGui::TextColored(Color(0xff00ffff).toVec4(), "AVG CPU:");
			ImGui::SameLine();
			if (_avgCPUTime == 0) ImGui::Text("-");
			else ImGui::Text("%.1f ms", _avgCPUTime);
			ImGui::TextColored(Color(0xff00ffff).toVec4(), "AVG GPU:");
			ImGui::SameLine();
			if (_avgGPUTime == 0) ImGui::Text("-");
			else ImGui::Text("%.1f ms", _avgGPUTime);
		}
		if (ImGui::CollapsingHeader("Object"))
		{
			ImGui::TextColored(Color(0xff00ffff).toVec4(), "C++ Object:");
			ImGui::SameLine();
			ImGui::Text("%d", Object::getCount());
			ImGui::TextColored(Color(0xff00ffff).toVec4(), "Lua Object:");
			ImGui::SameLine();
			ImGui::Text("%d", Object::getLuaRefCount());
			ImGui::TextColored(Color(0xff00ffff).toVec4(), "Lua Callback:");
			ImGui::SameLine();
			ImGui::Text("%d", Object::getLuaCallbackCount());
		}
		if (ImGui::CollapsingHeader("Memory"))
		{
			_memFrames++;
			_memPoolSize += (MemoryPool::getCapacity() / 1024);
			int k = lua_gc(SharedLuaEngine.getState(), LUA_GCCOUNT);
			int b = lua_gc(SharedLuaEngine.getState(), LUA_GCCOUNTB);
			_memLua += (k + b / 1024);
			if (_memFrames >= SharedApplication.getTargetFPS())
			{
				_lastMemPoolSize = _memPoolSize / _memFrames;
				_lastMemLua = _memLua / _memFrames;
				_memPoolSize = _memLua = 0;
				_memFrames = 0;
			}
			ImGui::TextColored(Color(0xff00ffff).toVec4(), "Memory Pool:");
			ImGui::SameLine();
			ImGui::Text("%d kb", _lastMemPoolSize);
			ImGui::TextColored(Color(0xff00ffff).toVec4(), "Lua Memory:");
			ImGui::SameLine();
			ImGui::Text("%.2f mb", _lastMemLua / 1024.0f);
			ImGui::TextColored(Color(0xff00ffff).toVec4(), "Texture Size:");
			ImGui::SameLine();
			ImGui::Text("%.2f mb", Texture2D::getStorageSize() / 1024.0f / 1024.0f);
		}
		ImGui::Dummy(Vec2{200.0f, 0.0f});
	}
	ImGui::End();

	if (_showPlot)
	{
		const int PlotCount = 30;
		_profileFrames++;
		_maxCPU = std::max(_maxCPU, SharedApplication.getCPUTime());
		_maxGPU = std::max(_maxGPU, SharedApplication.getGPUTime());
		_maxDelta = std::max(_maxDelta, SharedApplication.getDeltaTime());
		double targetTime = 1000.0 / SharedApplication.getTargetFPS();
		_logicTime += SharedApplication.getLogicTime();
		_renderTime += SharedApplication.getRenderTime();
		if (_profileFrames >= SharedApplication.getTargetFPS())
		{
			_cpuValues.push_back(_maxCPU * 1000.0);
			_gpuValues.push_back(_maxGPU * 1000.0);
			_dtValues.push_back(_maxDelta * 1000.0);
			_maxCPU = _maxGPU = _maxDelta = 0;
			if (_cpuValues.size() > PlotCount + 1) _cpuValues.erase(_cpuValues.begin());
			if (_gpuValues.size() > PlotCount + 1) _gpuValues.erase(_gpuValues.begin());
			if (_dtValues.size() > PlotCount + 1) _dtValues.erase(_dtValues.begin());
			else _times.push_back(_dtValues.size() - 1);
			_yLimit = 0;
			for (auto v : _cpuValues) if (v > _yLimit) _yLimit = v;
			for (auto v : _gpuValues) if (v > _yLimit) _yLimit = v;
			for (auto v : _dtValues) if (v > _yLimit) _yLimit = v;
			_updateCosts.clear();
			double time = 0;
			for (const auto& item : _timeCosts)
			{
				time += item.second;
				_updateCosts[item.first] = item.second * 1000.0 / _profileFrames;
			}
			_timeCosts.clear();
			_updateCosts["Logic"_slice] = (_logicTime - time) * 1000.0 / _profileFrames;
			_updateCosts["Render"_slice] = _renderTime * 1000.0 / _profileFrames;
			_logicTime = _renderTime = 0;
			_profileFrames = 0;
		}
		Size size = SharedApplication.getVisualSize();
		ImGui::SetNextWindowPos(Vec2{size.width/2 - 160.0f, 10.0f}, ImGuiCond_FirstUseEver);
		if (ImGui::Begin("Frame Time Peaks(ms) in Seconds", nullptr, ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_AlwaysAutoResize))
		{
			ImPlot::SetNextPlotLimits(0, PlotCount, 0, std::max(_yLimit, targetTime) + 1.0, ImGuiCond_Always);
			ImPlot::PushStyleColor(ImPlotCol_FrameBg, ImVec4(0,0,0,0));
			ImPlot::PushStyleColor(ImPlotCol_PlotBg, ImVec4(0,0,0,0));
			if (ImPlot::BeginPlot("Time Profiler", nullptr, nullptr, Vec2{300.0f, 130.0f},
				ImPlotFlags_NoChild | ImPlotFlags_NoMenus | ImPlotFlags_NoBoxSelect | ImPlotFlags_NoTitle, ImPlotAxisFlags_NoTickLabels))
			{
				ImPlot::SetLegendLocation(ImPlotLocation_South, ImPlotOrientation_Horizontal, true);
				ImPlot::PlotHLines("Base", &targetTime, 1);
				ImPlot::PlotLine("CPU", _times.data(), _cpuValues.data(),
					s_cast<int>(_cpuValues.size()));
				ImPlot::PlotLine("GPU", _times.data(), _gpuValues.data(),
					s_cast<int>(_gpuValues.size()));
				ImPlot::PlotLine("Delta", _times.data(), _dtValues.data(),
					s_cast<int>(_dtValues.size()));
				ImPlot::EndPlot();
			}
			ImPlot::PopStyleColor(2);
		}
		ImGui::End();
		ImGui::SetNextWindowPos(Vec2{size.width/2 + 170.0f, 10.0f}, ImGuiCond_FirstUseEver);
		if (ImGui::Begin("CPU Time", nullptr, ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_AlwaysAutoResize))
		{
			ImPlot::PushStyleColor(ImPlotCol_FrameBg, ImVec4(0,0,0,0));
			ImPlot::PushStyleColor(ImPlotCol_PlotBg, ImVec4(0,0,0,0));
			ImPlot::PushStyleColor(ImPlotCol_LegendBg, ImVec4(0,0,0,0.3f));
			ImPlot::SetNextPlotLimits(0, 1, 0, 1, ImGuiCond_Always);
			if (_updateCosts.size() > 0 && ImPlot::BeginPlot("Update Pie", nullptr, nullptr, ImVec2(200.0f, 200.0f), ImPlotFlags_NoTitle | ImPlotFlags_Equal | ImPlotFlags_NoMousePos | ImPlotFlags_NoChild, ImPlotAxisFlags_NoDecorations, ImPlotAxisFlags_NoDecorations)) {
				std::vector<const char*> pieLabels(_updateCosts.size());
				std::vector<double> pieValues(_updateCosts.size());
				int i = 0;
				for (const auto& item : _updateCosts)
				{
					pieLabels[i] = item.first.c_str();
					pieValues[i] = item.second;
					i++;
				}
				ImPlot::SetLegendLocation(ImPlotLocation_SouthEast, ImPlotOrientation_Vertical, false);
				ImPlot::PlotPieChart(pieLabels.data(), pieValues.data(), s_cast<int>(pieValues.size()), 0.5, 0.5, 0.45, true, "%.1f");
				ImPlot::EndPlot();
			}
			ImPlot::PopStyleColor(3);
		}
		ImGui::End();
	}
}

void ImGuiDora::showConsole()
{
	_console->Draw("Dorothy Console");
}

bool ImGuiDora::init()
{
	ImGui::CreateContext(_defaultFonts.get());
	ImPlot::CreateContext();
	ImGuiStyle& style = ImGui::GetStyle();
	float rounding = 0.0f;
	style.Alpha = 1.0f;
	style.WindowPadding = ImVec2(10, 10);
	style.WindowMinSize = ImVec2(100, 32);
	style.WindowRounding = rounding;
	style.WindowBorderSize = 0.0f;
	style.WindowTitleAlign = ImVec2(0.5f, 0.5f);
	style.FramePadding = ImVec2(5, 5);
	style.FrameRounding = rounding;
	style.FrameBorderSize = 0.0f;
	style.ItemSpacing = ImVec2(10, 10);
	style.ItemInnerSpacing = ImVec2(5, 5);
	style.TouchExtraPadding = ImVec2(5, 5);
	style.IndentSpacing = 10.0f;
	style.ColumnsMinSpacing = 5.0f;
	style.ScrollbarSize = 25.0f;
	style.ScrollbarRounding = 5.0f;
	style.GrabMinSize = 20.0f;
	style.GrabRounding = rounding;
	style.ButtonTextAlign = ImVec2(0.5f, 0.5f);
	style.DisplayWindowPadding = ImVec2(50, 50);
	style.DisplaySafeAreaPadding = ImVec2(5, 5);
	style.AntiAliasedLines = true;
	style.AntiAliasedFill = false;
	style.CurveTessellationTol = 1.0f;

	style.Colors[ImGuiCol_Text] = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
	style.Colors[ImGuiCol_TextDisabled] = ImVec4(0.60f, 0.60f, 0.60f, 1.00f);
	style.Colors[ImGuiCol_WindowBg] = ImVec4(0.00f, 0.00f, 0.00f, 0.80f);
	style.Colors[ImGuiCol_PopupBg] = ImVec4(0.0f, 0.05f, 0.05f, 0.80f);
	style.Colors[ImGuiCol_Border] = ImVec4(0.00f, 0.70f, 0.70f, 0.65f);
	style.Colors[ImGuiCol_BorderShadow] = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
	style.Colors[ImGuiCol_FrameBg] = ImVec4(0.00f, 0.80f, 0.80f, 0.30f);
	style.Colors[ImGuiCol_FrameBgHovered] = ImVec4(0.00f, 0.80f, 0.80f, 0.40f);
	style.Colors[ImGuiCol_FrameBgActive] = ImVec4(0.00f, 0.65f, 0.65f, 0.45f);
	style.Colors[ImGuiCol_TitleBg] = ImVec4(0.00f, 0.00f, 0.00f, 0.80f);
	style.Colors[ImGuiCol_TitleBgCollapsed] = ImVec4(0.0f, 0.0f, 0.0f, 0.30f);
	style.Colors[ImGuiCol_TitleBgActive] = ImVec4(0.0f, 0.20f, 0.20f, 0.80f);
	style.Colors[ImGuiCol_MenuBarBg] = ImVec4(0.00f, 0.55f, 0.55f, 0.80f);
	style.Colors[ImGuiCol_ScrollbarBg] = ImVec4(0.00f, 0.30f, 0.30f, 0.60f);
	style.Colors[ImGuiCol_ScrollbarGrab] = ImVec4(0.00f, 0.40f, 0.40f, 0.30f);
	style.Colors[ImGuiCol_ScrollbarGrabHovered] = ImVec4(0.00f, 0.40f, 0.40f, 0.40f);
	style.Colors[ImGuiCol_ScrollbarGrabActive] = ImVec4(0.00f, 0.50f, 0.50f, 0.40f);
	style.Colors[ImGuiCol_CheckMark] = ImVec4(0.00f, 0.90f, 0.90f, 0.50f);
	style.Colors[ImGuiCol_SliderGrab] = ImVec4(0.00f, 1.00f, 1.00f, 0.30f);
	style.Colors[ImGuiCol_SliderGrabActive] = ImVec4(0.00f, 0.50f, 0.50f, 1.00f);
	style.Colors[ImGuiCol_Button] = ImVec4(0.00f, 0.40f, 0.40f, 0.60f);
	style.Colors[ImGuiCol_ButtonHovered] = ImVec4(0.00f, 0.40f, 0.40f, 1.00f);
	style.Colors[ImGuiCol_ButtonActive] = ImVec4(0.00f, 0.50f, 0.50f, 1.00f);
	style.Colors[ImGuiCol_Header] = ImVec4(0.00f, 0.40f, 0.40f, 0.45f);
	style.Colors[ImGuiCol_HeaderHovered] = ImVec4(0.00f, 0.55f, 0.55f, 0.80f);
	style.Colors[ImGuiCol_HeaderActive] = ImVec4(0.00f, 0.53f, 0.53f, 0.80f);
	style.Colors[ImGuiCol_Separator] = ImVec4(0.00f, 0.50f, 0.50f, 1.00f);
	style.Colors[ImGuiCol_SeparatorHovered] = ImVec4(0.00f, 0.60f, 0.60f, 1.00f);
	style.Colors[ImGuiCol_SeparatorActive] = ImVec4(0.00f, 0.70f, 0.70f, 1.00f);
	style.Colors[ImGuiCol_ResizeGrip] = ImVec4(0.00f, 1.00f, 1.00f, 0.30f);
	style.Colors[ImGuiCol_ResizeGripHovered] = ImVec4(0.00f, 1.00f, 1.00f, 0.60f);
	style.Colors[ImGuiCol_ResizeGripActive] = ImVec4(0.00f, 1.00f, 1.00f, 0.90f);
	style.Colors[ImGuiCol_Tab] = style.Colors[ImGuiCol_Header];
	style.Colors[ImGuiCol_TabHovered] = style.Colors[ImGuiCol_HeaderHovered];
	style.Colors[ImGuiCol_TabActive] = style.Colors[ImGuiCol_HeaderActive];
	style.Colors[ImGuiCol_TabUnfocused] = style.Colors[ImGuiCol_Tab];
	style.Colors[ImGuiCol_TabUnfocusedActive] = style.Colors[ImGuiCol_TabActive];
	style.Colors[ImGuiCol_PlotLines] = ImVec4(0.00f, 1.00f, 1.00f, 1.00f);
	style.Colors[ImGuiCol_PlotLinesHovered] = ImVec4(0.00f, 0.70f, 0.70f, 1.00f);
	style.Colors[ImGuiCol_PlotHistogram] = ImVec4(0.00f, 0.70f, 0.70f, 1.00f);
	style.Colors[ImGuiCol_PlotHistogramHovered] = ImVec4(0.00f, 0.60f, 0.60f, 1.00f);
	style.Colors[ImGuiCol_TableHeaderBg] = ImVec4(0.00f, 0.19f, 0.20f, 1.00f);
	style.Colors[ImGuiCol_TableBorderStrong] = ImVec4(0.00f, 0.31f, 0.35f, 1.00f);
	style.Colors[ImGuiCol_TableBorderLight] = ImVec4(0.00f, 0.23f, 0.25f, 1.00f);
	style.Colors[ImGuiCol_TableRowBg] = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
	style.Colors[ImGuiCol_TableRowBgAlt] = ImVec4(1.00f, 1.00f, 1.00f, 0.06f);
	style.Colors[ImGuiCol_TextSelectedBg] = ImVec4(0.00f, 1.00f, 1.00f, 0.35f);
	style.Colors[ImGuiCol_DragDropTarget] = ImVec4(1.00f, 1.00f, 0.00f, 0.90f);
	style.Colors[ImGuiCol_NavHighlight] = ImVec4(0.00f, 0.59f, 0.98f, 1.00f);
	style.Colors[ImGuiCol_NavWindowingHighlight] = ImVec4(0.00f, 1.00f, 1.00f, 0.70f);
	style.Colors[ImGuiCol_NavWindowingDimBg] = ImVec4(0.80f, 0.80f, 0.80f, 0.20f);
	style.Colors[ImGuiCol_ModalWindowDimBg] = ImVec4(0.20f, 0.20f, 0.20f, 0.35f);

	ImGuiIO& io = ImGui::GetIO();
	io.KeyMap[ImGuiKey_Tab] = SDLK_TAB;
	io.KeyMap[ImGuiKey_LeftArrow] = SDL_SCANCODE_LEFT;
	io.KeyMap[ImGuiKey_RightArrow] = SDL_SCANCODE_RIGHT;
	io.KeyMap[ImGuiKey_UpArrow] = SDL_SCANCODE_UP;
	io.KeyMap[ImGuiKey_DownArrow] = SDL_SCANCODE_DOWN;
	io.KeyMap[ImGuiKey_PageUp] = SDL_SCANCODE_PAGEUP;
	io.KeyMap[ImGuiKey_PageDown] = SDL_SCANCODE_PAGEDOWN;
	io.KeyMap[ImGuiKey_Home] = SDL_SCANCODE_HOME;
	io.KeyMap[ImGuiKey_End] = SDL_SCANCODE_END;
	io.KeyMap[ImGuiKey_Delete] = SDLK_DELETE;
	io.KeyMap[ImGuiKey_Backspace] = SDLK_BACKSPACE;
	io.KeyMap[ImGuiKey_Enter] = SDLK_RETURN;
	io.KeyMap[ImGuiKey_Escape] = SDLK_ESCAPE;
	io.KeyMap[ImGuiKey_A] = SDLK_a;
	io.KeyMap[ImGuiKey_C] = SDLK_c;
	io.KeyMap[ImGuiKey_V] = SDLK_v;
	io.KeyMap[ImGuiKey_X] = SDLK_x;
	io.KeyMap[ImGuiKey_Y] = SDLK_y;
	io.KeyMap[ImGuiKey_Z] = SDLK_z;

	io.SetClipboardTextFn = ImGuiDora::setClipboardText;
	io.GetClipboardTextFn = ImGuiDora::getClipboardText;
	io.ImeSetInputScreenPosFn = ImGuiDora::setImePositionHint;
	io.ClipboardUserData = nullptr;

	_iniFilePath = SharedContent.getWritablePath() + "imgui.ini";
	io.IniFilename = _iniFilePath.c_str();

	_defaultEffect = SpriteEffect::create(
		"builtin::vs_ocornut_imgui"_slice,
		"builtin::fs_ocornut_imgui"_slice);

	_imageEffect = SpriteEffect::create(
		"builtin::vs_ocornut_imgui"_slice,
		"builtin::fs_ocornut_imgui_image"_slice);

	uint8_t* texData;
	int width;
	int height;
	io.Fonts->GetTexDataAsAlpha8(&texData, &width, &height);
	updateTexture(texData, width, height);
	io.Fonts->ClearTexData();
	io.Fonts->ClearInputData();

	SharedDirector.getSystemScheduler()->schedule([this](double deltaTime)
	{
		if (_backSpaceIgnore) _backSpaceIgnore = false;
		if (!_inputs.empty())
		{
			auto& event = *std::any_cast<SDL_Event>(&_inputs.front());
			ImGuiIO& io = ImGui::GetIO();
			switch (event.type)
			{
				case SDL_MOUSEBUTTONUP:
				{
					if (event.button.button == SDL_BUTTON_LEFT) _mousePressed[0] = false;
					if (event.button.button == SDL_BUTTON_RIGHT) _mousePressed[1] = false;
					if (event.button.button == SDL_BUTTON_MIDDLE) _mousePressed[2] = false;
					break;
				}
				case SDL_TEXTINPUT:
				{
					if (event.text.text[0] != '\0')
					{
						io.AddInputCharactersUTF8(event.text.text);
					}
					break;
				}
				case SDL_KEYDOWN:
				case SDL_KEYUP:
				{
					SDL_Keycode code = event.key.keysym.sym;
					int key = code & ~SDLK_SCANCODE_MASK;
					uint16_t mod = event.key.keysym.mod;
					io.KeyShift = ((mod & KMOD_SHIFT) != 0);
					io.KeyCtrl = ((mod & KMOD_CTRL) != 0);
					io.KeyAlt = ((mod & KMOD_ALT) != 0);
					io.KeySuper = ((mod & KMOD_GUI) != 0);
					if (_textEditing.empty() || code == SDLK_BACKSPACE || code == SDLK_LEFT || code == SDLK_RIGHT)
					{
						io.KeysDown[key] = (event.type == SDL_KEYDOWN);
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

void ImGuiDora::begin()
{
	ImGuiIO& io = ImGui::GetIO();
	Size visualSize = SharedApplication.getVisualSize();
	io.DisplaySize.x = visualSize.width;
	io.DisplaySize.y = visualSize.height;
	io.DeltaTime = s_cast<float>(SharedApplication.getDeltaTime());

	if (_textInputing != io.WantTextInput)
	{
		_textInputing = io.WantTextInput;
		if (_textInputing || !SharedKeyboard.isIMEAttached())
		{
			if (_textInputing)
			{
				_textEditing.clear();
				_lastCursor = 0;
				SharedKeyboard.detachIME();
			}
			SharedApplication.invokeInRender(_textInputing ? SDL_StartTextInput : SDL_StopTextInput);
			if (_textInputing)
			{
				setImePositionHint(_lastIMEPosX, _lastIMEPosY);
			}
		}
	}

	io.MouseDown[0] = _mousePressed[0];
	io.MouseDown[1] = _mousePressed[1];
	io.MouseDown[2] = _mousePressed[2];

	io.MouseWheel = _mouseWheel;
	_mouseWheel = 0.0f;

	if (_mouseVisible != io.MouseDrawCursor)
	{
		_mouseVisible = io.MouseDrawCursor;
		SharedApplication.invokeInRender([this]()
		{
			// Hide OS mouse cursor if ImGui is drawing it
			SDL_ShowCursor(_mouseVisible ? SDL_FALSE : SDL_TRUE);
		});
	}

	// Start the frame
	ImGui::NewFrame();
}

void ImGuiDora::end()
{
	ImGui::Render();
}

inline bool checkAvailTransientBuffers(uint32_t _numVertices, const bgfx::VertexLayout& _decl, uint32_t _numIndices)
{
	return _numVertices == bgfx::getAvailTransientVertexBuffer(_numVertices, _decl)
		&& _numIndices == bgfx::getAvailTransientIndexBuffer(_numIndices);
}

void ImGuiDora::render()
{
	ImDrawData* drawData = ImGui::GetDrawData();
	if (drawData->CmdListsCount == 0)
	{
		return;
	}

	SharedView.pushName("ImGui"_slice, [&]()
	{
		bgfx::ViewId viewId = SharedView.getId();

		float scale = SharedApplication.getDeviceRatio();
		_defaultEffect->set("u_scale"_slice,  scale);
		_imageEffect->set("u_scale"_slice,  scale);

		// Render command lists
		for (int32_t ii = 0, num = drawData->CmdListsCount; ii < num; ++ii)
		{
			bgfx::TransientVertexBuffer tvb;
			bgfx::TransientIndexBuffer tib;

			const ImDrawList* drawList = drawData->CmdLists[ii];
			uint32_t numVertices = s_cast<uint32_t>(drawList->VtxBuffer.size());
			uint32_t numIndices = s_cast<uint32_t>(drawList->IdxBuffer.size());

			if (!checkAvailTransientBuffers(numVertices, _vertexLayout, numIndices))
			{
				Warn("not enough space in transient buffer just quit drawing the rest.");
				break;
			}

			bgfx::allocTransientVertexBuffer(&tvb, numVertices, _vertexLayout);
			bgfx::allocTransientIndexBuffer(&tib, numIndices, std::is_same_v<ImDrawIdx, uint32_t>);

			ImDrawVert* verts = r_cast<ImDrawVert*>(tvb.data);
			std::memcpy(verts, drawList->VtxBuffer.begin(), numVertices * sizeof(drawList->VtxBuffer[0]));

			ImDrawIdx* indices = r_cast<ImDrawIdx*>(tib.data);
			std::memcpy(indices, drawList->IdxBuffer.begin(), numIndices * sizeof(drawList->IdxBuffer[0]));

			uint32_t offset = 0;
			for (const ImDrawCmd* cmd = drawList->CmdBuffer.begin(), *cmdEnd = drawList->CmdBuffer.end(); cmd != cmdEnd; ++cmd)
			{
				if (cmd->UserCallback)
				{
					cmd->UserCallback(drawList, cmd);
				}
				else if (0 != cmd->ElemCount)
				{
					bgfx::TextureHandle textureHandle;
					bgfx::UniformHandle sampler;
					bgfx::ProgramHandle program;
					if (nullptr != cmd->TextureId)
					{
						union
						{
							ImTextureID ptr;
							struct { bgfx::TextureHandle handle; } s;
						} texture = { cmd->TextureId };
						textureHandle = texture.s.handle;
						sampler = _imageEffect->getSampler();
						program = _imageEffect->apply();
					}
					else
					{
						textureHandle = _fontTexture->getHandle();
						sampler = _defaultEffect->getSampler();
						program = _defaultEffect->apply();
					}

					uint64_t state = 0
						| BGFX_STATE_WRITE_RGB
						| BGFX_STATE_WRITE_A
						| BGFX_STATE_MSAA
						| BGFX_STATE_BLEND_FUNC(BGFX_STATE_BLEND_SRC_ALPHA, BGFX_STATE_BLEND_INV_SRC_ALPHA);

					const uint16_t xx = uint16_t(bx::max(cmd->ClipRect.x*scale, 0.0f));
					const uint16_t yy = uint16_t(bx::max(cmd->ClipRect.y*scale, 0.0f));
					bgfx::setScissor(xx, yy,
						uint16_t(bx::min(cmd->ClipRect.z*scale, 65535.0f) - xx),
						uint16_t(bx::min(cmd->ClipRect.w*scale, 65535.0f) - yy));
					bgfx::setState(state);
					bgfx::setTexture(0, sampler, textureHandle);
					bgfx::setVertexBuffer(0, &tvb, 0, numVertices);
					bgfx::setIndexBuffer(&tib, offset, cmd->ElemCount);
					bgfx::submit(viewId, program);
				}

				offset += cmd->ElemCount;
			}
		}
	});
}

void ImGuiDora::sendKey(int key, int count)
{
	for (int i = 0; i < count; i++)
	{
		SDL_Event e = {};
		e.type = SDL_KEYDOWN;
		e.key.keysym.sym = key;
		_inputs.push_back(e);
		e.type = SDL_KEYUP;
		_inputs.push_back(e);
	}
}

void ImGuiDora::updateTexture(uint8_t* data, int width, int height)
{
	const uint64_t textureFlags = BGFX_SAMPLER_MIN_POINT | BGFX_SAMPLER_MAG_POINT;

	bgfx::TextureHandle textureHandle = bgfx::createTexture2D(
		s_cast<uint16_t>(width), s_cast<uint16_t>(height),
		false, 1, bgfx::TextureFormat::A8, textureFlags,
		bgfx::copy(data, width*height * 1));

	bgfx::TextureInfo info;
	bgfx::calcTextureSize(info,
		s_cast<uint16_t>(width), s_cast<uint16_t>(height),
		0, false, false, 1, bgfx::TextureFormat::A8);

	_fontTexture = Texture2D::create(textureHandle, info, textureFlags);
}

void ImGuiDora::handleEvent(const SDL_Event& event)
{
	switch (event.type)
	{
		case SDL_MOUSEWHEEL:
		{
			if (event.wheel.y > 0)
			{
				_mouseWheel = 1;
			}
			if (event.wheel.y < 0)
			{
				_mouseWheel = -1;
			}
			break;
		}
		case SDL_MOUSEBUTTONDOWN:
		{
			if (event.button.button == SDL_BUTTON_LEFT) _mousePressed[0] = true;
			if (event.button.button == SDL_BUTTON_RIGHT) _mousePressed[1] = true;
			if (event.button.button == SDL_BUTTON_MIDDLE) _mousePressed[2] = true;
			break;
		}
		case SDL_MOUSEBUTTONUP:
		{
			SharedDirector.getSystemScheduler()->schedule([this,event](double deltaTime)
			{
				DORA_UNUSED_PARAM(deltaTime);
				_inputs.push_back(event);
				return true;
			});
			break;
		}
		case SDL_MOUSEMOTION:
		{
			Size visualSize = SharedApplication.getVisualSize();
			Size winSize = SharedApplication.getWinSize();
			ImGui::GetIO().MousePos = Vec2{
				s_cast<float>(event.motion.x) * visualSize.width / winSize.width,
				s_cast<float>(event.motion.y) * visualSize.height / winSize.height
			};
			break;
		}
		case SDL_KEYDOWN:
		case SDL_KEYUP:
		{
			if (_textEditing.empty())
			{
				int key = event.key.keysym.sym & ~SDLK_SCANCODE_MASK;
				if (key != SDLK_BACKSPACE || !_backSpaceIgnore)
				{
					_inputs.push_back(event);
				}
			}
			break;
		}
		case SDL_TEXTINPUT:
		{
			int size = s_cast<int>(_textEditing.size());
			if (_lastCursor < size)
			{
				sendKey(SDLK_RIGHT, size - _lastCursor);
			}
			
			auto newText = utf8_get_characters(event.text.text);
			size_t start = _textEditing.size();
			for (size_t i = 0; i < _textEditing.size(); i++)
			{
				if (i >= newText.size() || newText[i] != _textEditing[i])
				{
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
			utf8_each_character(event.edit.text, [&](int stop, uint32_t code)
			{
				if (count >= s_cast<int>(_textEditing.size()) || _textEditing[count] != code)
				{
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
		case SDL_TEXTEDITING:
		{
			auto newText = utf8_get_characters(event.edit.text);
			if (newText.size() == _textEditing.size())
			{
				bool changed = false;
				for (size_t i = 0; i < newText.size(); i++)
				{
					if (newText[i] != _textEditing[i])
					{
						changed = true;
					}
				}
				if (!changed)
				{
					int32_t cursor = event.edit.start;
					if (cursor > _lastCursor)
					{
						sendKey(SDLK_RIGHT, cursor - _lastCursor);
					}
					else if (cursor < _lastCursor)
					{
						sendKey(SDLK_LEFT, _lastCursor - cursor);
					}
					_lastCursor = cursor;
					break;
				}
			}

			if (_lastCursor == _textEditing.size())
			{
				size_t start = _textEditing.size();
				for (size_t i = 0; i < _textEditing.size(); i++)
				{
					if (i >= newText.size() || newText[i] != _textEditing[i])
					{
						start = i;
						break;
					}
				}
				int count = s_cast<int>(_textEditing.size() - start);
				sendKey(SDLK_BACKSPACE, count);
				_lastCursor -= count;
			}
			else
			{
				sendKey(SDLK_RIGHT, s_cast<int>(_textEditing.size()) - _lastCursor);
				_lastCursor += (_textEditing.size() - _lastCursor);
				int count = 0;
				bool different = false;
				for (size_t i = 0; i < _textEditing.size(); i++)
				{
					if (different || (i >= newText.size() || newText[i] != _textEditing[i]))
					{
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
			utf8_each_character(event.edit.text, [&](int stop, uint32_t code)
			{
				if (count >= _textEditing.size() || _textEditing[count] != code)
				{
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
			if (cursor > _lastCursor)
			{
				sendKey(SDLK_RIGHT, cursor - _lastCursor);
			}
			else if (cursor < _lastCursor)
			{
				sendKey(SDLK_LEFT, _lastCursor - cursor);
			}
			_lastCursor = cursor;

			_textEditing = newText;
			if (_textEditing.empty()) _backSpaceIgnore = true;
			break;
		}
	}
}

bool ImGuiDora::handle(const SDL_Event& event)
{
	switch (event.type)
	{
		case SDL_MOUSEBUTTONDOWN:
			if (ImGui::IsAnyItemHovered() || ImGui::IsAnyItemActive() || ImGui::IsAnyItemFocused() ||
				ImGui::IsPopupOpen(nullptr, ImGuiPopupFlags_AnyPopupId | ImGuiPopupFlags_AnyPopupLevel))
			{
				_rejectAllEvents = true;
			}
			break;
		case SDL_MOUSEBUTTONUP:
			if (_rejectAllEvents)
			{
				_rejectAllEvents = false;
			}
			break;
		default:
			break;
	}
	switch (event.type)
	{
		case SDL_MOUSEBUTTONDOWN:
		case SDL_FINGERDOWN:
		case SDL_MULTIGESTURE:
			return _rejectAllEvents;
		case SDL_MOUSEWHEEL:
			return ImGui::IsAnyItemHovered() || ImGui::IsAnyItemActive() || ImGui::IsAnyItemFocused() ||
				ImGui::IsPopupOpen(nullptr, ImGuiPopupFlags_AnyPopupId | ImGuiPopupFlags_AnyPopupLevel);
	}
	return false;
}

NS_DOROTHY_END
