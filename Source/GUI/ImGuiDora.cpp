/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

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
#include "Input/Keyboard.h"

NS_DOROTHY_BEGIN

class LogPanel
{
public:
	LogPanel():
	_scrollToBottom(false),
	_autoScroll(true)
	{
		LogHandler += std::make_pair(this, &LogPanel::addLog);
	}

	~LogPanel()
	{
		LogHandler -= std::make_pair(this, &LogPanel::addLog);
	}

	void clear()
	{
		_buf.clear();
		_lineOffsets.clear();
	}

	void addLog(const string& text)
	{
		int old_size = _buf.size();
		_buf.append("%s", text.c_str());
		for (int new_size = _buf.size(); old_size < new_size; old_size++)
		{
			if (_buf[old_size] == '\n')
			{
				_lineOffsets.push_back(old_size);
			}
		}
		_scrollToBottom = true;
	}

	void Draw(const char* title, bool* p_open = nullptr)
	{
		ImGui::SetNextWindowSize(ImVec2(400,300), ImGuiCond_FirstUseEver);
		ImGui::Begin(title, p_open);
		if (ImGui::Button("Clear")) clear();
		ImGui::SameLine();
		bool copy = ImGui::Button("Copy");
		ImGui::SameLine();
		if (ImGui::Checkbox("Scroll", &_autoScroll))
		{
			if (_autoScroll) _scrollToBottom = true;
		}
		ImGui::SameLine();
		_filter.Draw("Filter", -55.0f);
		ImGui::Separator();
		ImGui::BeginChild("scrolling", ImVec2(0,0), false, ImGuiWindowFlags_HorizontalScrollbar);
		if (copy) ImGui::LogToClipboard();
		const char* buf_begin = _buf.begin();
		const char* line = buf_begin;
		for (int line_no = 0; line != nullptr; line_no++)
		{
			const char* line_end = (line_no < _lineOffsets.Size) ? buf_begin + _lineOffsets[line_no] : nullptr;
			if (!_filter.IsActive())
			{
				ImVec2 itemSpacing = ImGui::GetStyle().ItemSpacing;
				ImGui::PushStyleVar(ImGuiStyleVar_ItemSpacing, ImVec2(itemSpacing.x, 0));
				ImGui::TextWrappedUnformatted(line, line_end);
				ImGui::PopStyleVar();
			}
			else if (_filter.PassFilter(line, line_end))
			{
				ImGui::TextWrappedUnformatted(line, line_end);
			}
			line = line_end && line_end[1] ? line_end + 1 : nullptr;
		}
		if (_scrollToBottom && _autoScroll)
		{
			ImGui::SetScrollHere(1.0f);
		}
		_scrollToBottom = false;
		ImGui::EndChild();
		ImGui::End();
	}
	
private:
	ImGuiTextBuffer _buf;
	ImGuiTextFilter _filter;
	ImVector<int> _lineOffsets;
	bool _scrollToBottom;
	bool _autoScroll;
};

int ImGuiDora::_lastIMEPosX;
int ImGuiDora::_lastIMEPosY;

ImGuiDora::ImGuiDora():
_isLoadingFont(false),
_textInputing(false),
_mouseVisible(true),
_lastCursor(0),
_backSpaceIgnore(false),
_mousePressed{ false, false, false },
_mouseWheel(0.0f),
_log(New<LogPanel>())
{
	_vertexDecl
		.begin()
			.add(bgfx::Attrib::Position, 2, bgfx::AttribType::Float)
			.add(bgfx::Attrib::TexCoord0, 2, bgfx::AttribType::Float)
			.add(bgfx::Attrib::Color0, 4, bgfx::AttribType::Uint8, true)
		.end();

	SharedApplication.eventHandler += std::make_pair(this, &ImGuiDora::handleEvent);
}

ImGuiDora::~ImGuiDora()
{
	SharedApplication.eventHandler -= std::make_pair(this, &ImGuiDora::handleEvent);
	ImGui::Shutdown();
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
	if (x == 1 && y == 1) return;
	_lastIMEPosX = x;
	_lastIMEPosY = y;
	float scale = SharedApplication.getSize().width / SharedApplication.getWinSize().width;
	SharedKeyboard.updateIMEPosHint({x / scale, y / scale});
}

void ImGuiDora::loadFontTTF(String ttfFontFile, int fontSize, String glyphRanges)
{
	if (_isLoadingFont) return;
	_isLoadingFont = true;

	Sint64 size;
	Uint8* fileData = SharedContent.loadFileUnsafe(ttfFontFile, size);

	if (!fileData)
	{
		Log("load ttf file for imgui failed!");
		return;
	}
	
	ImGuiIO& io = ImGui::GetIO();
	io.Fonts->ClearFonts();
	ImFontConfig fontConfig;
	fontConfig.FontDataOwnedByAtlas = false;
	fontConfig.PixelSnapH = true;
	fontConfig.OversampleH = 1;
	fontConfig.OversampleV = 1;
	io.Fonts->AddFontFromMemoryTTF(fileData, s_cast<int>(size), s_cast<float>(fontSize), &fontConfig, io.Fonts->GetGlyphRangesDefault());
	Uint8* texData;
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
			targetGlyphRanges = io.Fonts->GetGlyphRangesChinese();
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
		io.Fonts->AddFontFromMemoryTTF(fileData, s_cast<int>(size), s_cast<float>(fontSize), &fontConfig, targetGlyphRanges);
		SharedAsyncThread.Process.run([]()
		{
			ImGuiIO& io = ImGui::GetIO();
			int texWidth, texHeight;
			ImVec2 texUvWhitePixel;
			unsigned char* texPixelsAlpha8;
			io.Fonts->Build(texWidth, texHeight, texUvWhitePixel, texPixelsAlpha8);
			return Values::create(texWidth, texHeight, texUvWhitePixel, texPixelsAlpha8);
		}, [this, fileData, size](Values* result)
		{
			ImGuiIO& io = ImGui::GetIO();
			result->get(io.Fonts->TexWidth, io.Fonts->TexHeight, io.Fonts->TexUvWhitePixel, io.Fonts->TexPixelsAlpha8);
			io.Fonts->Fonts.erase(io.Fonts->Fonts.begin());
			updateTexture(io.Fonts->TexPixelsAlpha8, io.Fonts->TexWidth, io.Fonts->TexHeight);
			io.Fonts->ClearTexData();
			io.Fonts->ClearInputData();
			MakeOwnArray(fileData, s_cast<size_t>(size));
			_isLoadingFont = false;
		});
	}
	else
	{
		MakeOwnArray(fileData, s_cast<size_t>(size));
		_isLoadingFont = false;
	}
}

void ImGuiDora::showStats()
{
	/* print debug text */
	ImGui::Begin("Dorothy Stats", nullptr, Vec2{195,305}, 0.8f, ImGuiWindowFlags_AlwaysAutoResize);
	const bgfx::Stats* stats = bgfx::getStats();
	const char* rendererNames[] = {
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
	ImGui::Text("%d x %d", stats->width, stats->height);
	ImGui::TextColored(Color(0xff00ffff).toVec4(), "Draw call:");
	ImGui::SameLine();
	ImGui::Text("%d", stats->numDraw);
	static int frames = 0;
	static double cpuTime = 0, gpuTime = 0, deltaTime = 0;
	cpuTime += SharedApplication.getCPUTime();
	gpuTime += std::abs(double(stats->gpuTimeEnd) - double(stats->gpuTimeBegin)) / double(stats->gpuTimerFreq);
	deltaTime += SharedApplication.getDeltaTime();
	frames++;
	static double lastCpuTime = 0, lastGpuTime = 0, lastDeltaTime = 1000.0 / SharedApplication.getMaxFPS();
	ImGui::TextColored(Color(0xff00ffff).toVec4(), "CPU time:");
	ImGui::SameLine();
	ImGui::Text("%.1f ms", lastCpuTime);
	ImGui::TextColored(Color(0xff00ffff).toVec4(), "GPU time:");
	ImGui::SameLine();
	ImGui::Text("%.1f ms", lastGpuTime);
	ImGui::TextColored(Color(0xff00ffff).toVec4(), "Delta time:");
	ImGui::SameLine();
	ImGui::Text("%.1f ms", lastDeltaTime);
	if (frames == SharedApplication.getMaxFPS())
	{
		lastCpuTime = 1000.0 * cpuTime / frames;
		lastGpuTime = 1000.0 * gpuTime / frames;
		lastDeltaTime = 1000.0 * deltaTime / frames;
		frames = 0;
		cpuTime = gpuTime = deltaTime = 0.0;
	}
	ImGui::TextColored(Color(0xff00ffff).toVec4(), "C++ Object:");
	ImGui::SameLine();
	ImGui::Text("%d", Object::getObjectCount());
	ImGui::TextColored(Color(0xff00ffff).toVec4(), "Lua Object:");
	ImGui::SameLine();
	ImGui::Text("%d", Object::getLuaRefCount());
	ImGui::TextColored(Color(0xff00ffff).toVec4(), "Callback:");
	ImGui::SameLine();
	ImGui::Text("%d", Object::getLuaCallbackCount());
	ImGui::End();
}

void ImGuiDora::showLog()
{
	_log->Draw("Dorothy Log");
}

bool ImGuiDora::init()
{
	ImGuiStyle& style = ImGui::GetStyle();
	style.Alpha = 1.0f;
	style.WindowPadding = ImVec2(10, 10);
	style.WindowMinSize = ImVec2(100, 32);
	style.WindowRounding = 0.0f;
	style.WindowTitleAlign = ImVec2(0.5f, 0.5f);
	style.ChildWindowRounding = 0.0f;
	style.FramePadding = ImVec2(5, 5);
	style.FrameRounding = 0.0f;
	style.ItemSpacing = ImVec2(10, 10);
	style.ItemInnerSpacing = ImVec2(5, 5);
	style.TouchExtraPadding = ImVec2(5, 5);
	style.IndentSpacing = 10.0f;
	style.ColumnsMinSpacing = 5.0f;
	style.ScrollbarSize = 25.0f;
	style.ScrollbarRounding = 0.0f;
	style.GrabMinSize = 20.0f;
	style.GrabRounding = 0.0f;
	style.ButtonTextAlign = ImVec2(0.5f, 0.5f);
	style.DisplayWindowPadding = ImVec2(50, 50);
	style.DisplaySafeAreaPadding = ImVec2(5, 5);
	style.AntiAliasedLines = true;
	style.AntiAliasedShapes = false;
	style.CurveTessellationTol = 1.0f;

	style.Colors[ImGuiCol_Text] = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
	style.Colors[ImGuiCol_TextDisabled] = ImVec4(0.60f, 0.60f, 0.60f, 1.00f);
	style.Colors[ImGuiCol_WindowBg] = ImVec4(0.00f, 0.00f, 0.00f, 0.80f);
	style.Colors[ImGuiCol_ChildWindowBg] = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
	style.Colors[ImGuiCol_PopupBg] = ImVec4(0.0f, 0.05f, 0.10f, 0.90f);
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
	style.Colors[ImGuiCol_ComboBg] = ImVec4(0.00f, 0.20f, 0.20f, 0.99f);
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
	style.Colors[ImGuiCol_CloseButton] = ImVec4(0.00f, 0.50f, 0.50f, 0.50f);
	style.Colors[ImGuiCol_CloseButtonHovered] = ImVec4(0.00f, 0.70f, 0.70f, 0.60f);
	style.Colors[ImGuiCol_CloseButtonActive] = ImVec4(0.00f, 0.70f, 0.70f, 1.00f);
	style.Colors[ImGuiCol_PlotLines] = ImVec4(0.00f, 1.00f, 1.00f, 1.00f);
	style.Colors[ImGuiCol_PlotLinesHovered] = ImVec4(0.00f, 0.70f, 0.70f, 1.00f);
	style.Colors[ImGuiCol_PlotHistogram] = ImVec4(0.00f, 0.70f, 0.70f, 1.00f);
	style.Colors[ImGuiCol_PlotHistogramHovered] = ImVec4(0.00f, 0.60f, 0.60f, 1.00f);
	style.Colors[ImGuiCol_TextSelectedBg] = ImVec4(0.00f, 1.00f, 1.00f, 0.35f);
	style.Colors[ImGuiCol_ModalWindowDarkening] = ImVec4(0.00f, 0.20f, 0.20f, 0.35f);

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

	_effect = SpriteEffect::create(
		"built-in/vs_ocornut_imgui.bin"_slice,
		"built-in/fs_ocornut_imgui.bin"_slice);

	Uint8* texData;
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
			const auto& event = _inputs.front();
			ImGuiIO& io = ImGui::GetIO();
			switch (event.type)
			{
				case SDL_MOUSEBUTTONUP:
				{
					if ((Touch::source & Touch::FromMouse) == 0) break;
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
					Uint16 mod = event.key.keysym.mod;
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
	Size winSize = SharedApplication.getSize();
	io.DisplaySize.x = winSize.width;
	io.DisplaySize.y = winSize.height;
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

inline bool checkAvailTransientBuffers(uint32_t _numVertices, const bgfx::VertexDecl& _decl, uint32_t _numIndices)
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
		Uint8 viewId = SharedView.getId();

		ImGuiDora* guiDora = SharedImGui.getTarget();
		bgfx::TextureHandle textureHandle = guiDora->_fontTexture->getHandle();
		bgfx::UniformHandle sampler = guiDora->_effect->getSampler();
		bgfx::ProgramHandle program = guiDora->_effect->apply();

		// Render command lists
		for (int32_t ii = 0, num = drawData->CmdListsCount; ii < num; ++ii)
		{
			bgfx::TransientVertexBuffer tvb;
			bgfx::TransientIndexBuffer tib;

			const ImDrawList* drawList = drawData->CmdLists[ii];
			uint32_t numVertices = (uint32_t)drawList->VtxBuffer.size();
			uint32_t numIndices = (uint32_t)drawList->IdxBuffer.size();

			if (!checkAvailTransientBuffers(numVertices, guiDora->_vertexDecl, numIndices))
			{
				Log("not enough space in transient buffer just quit drawing the rest.");
				break;
			}

			bgfx::allocTransientVertexBuffer(&tvb, numVertices, guiDora->_vertexDecl);
			bgfx::allocTransientIndexBuffer(&tib, numIndices);

			ImDrawVert* verts = (ImDrawVert*)tvb.data;
			std::memcpy(verts, drawList->VtxBuffer.begin(), numVertices * sizeof(drawList->VtxBuffer[0]));

			ImDrawIdx* indices = (ImDrawIdx*)tib.data;
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
					if (nullptr != cmd->TextureId)
					{
						union
						{
							ImTextureID ptr;
							struct { bgfx::TextureHandle handle; } s;
						} texture = { cmd->TextureId };
						textureHandle = texture.s.handle;
					}

					uint64_t state = 0
						| BGFX_STATE_RGB_WRITE
						| BGFX_STATE_ALPHA_WRITE
						| BGFX_STATE_MSAA
						| BGFX_STATE_BLEND_FUNC(BGFX_STATE_BLEND_SRC_ALPHA, BGFX_STATE_BLEND_INV_SRC_ALPHA);

					const uint16_t xx = uint16_t(bx::fmax(cmd->ClipRect.x, 0.0f));
					const uint16_t yy = uint16_t(bx::fmax(cmd->ClipRect.y, 0.0f));
					bgfx::setScissor(xx, yy,
						uint16_t(bx::fmin(cmd->ClipRect.z, 65535.0f) - xx),
						uint16_t(bx::fmin(cmd->ClipRect.w, 65535.0f) - yy));
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

void ImGuiDora::updateTexture(Uint8* data, int width, int height)
{
	const Uint32 textureFlags = BGFX_TEXTURE_MIN_POINT | BGFX_TEXTURE_MAG_POINT;

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
			if ((Touch::source & Touch::FromMouse) == 0) break;
			if (event.button.button == SDL_BUTTON_LEFT) _mousePressed[0] = true;
			if (event.button.button == SDL_BUTTON_RIGHT) _mousePressed[1] = true;
			if (event.button.button == SDL_BUTTON_MIDDLE) _mousePressed[2] = true;
			break;
		}
		case SDL_FINGERDOWN:
		{
			if ((Touch::source & Touch::FromTouch) == 0) break;
			Size size = SharedApplication.getSize();
			ImGui::GetIO().MousePos = ImVec2(event.tfinger.x * size.width, event.tfinger.y * size.height);
			_mousePressed[0] = true;
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
			if ((Touch::source & Touch::FromMouse) == 0) break;
			int mx = event.motion.x, my = event.motion.y;
			Size winSize = SharedApplication.getWinSize();
			Size size = SharedApplication.getSize();
			ImGui::GetIO().MousePos = Vec2{mx / winSize.width, my / winSize.height} * size;
			break;
		}
		case SDL_FINGERMOTION:
		{
			if ((Touch::source & Touch::FromTouch) == 0) break;
			Size size = SharedApplication.getSize();
			ImGui::GetIO().MousePos = ImVec2(event.tfinger.x * size.width, event.tfinger.y * size.height);
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
			utf8_each_character(event.edit.text, [&](int stop, Uint32 code)
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
					Sint32 cursor = event.edit.start;
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
			utf8_each_character(event.edit.text, [&](int stop, Uint32 code)
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
			Sint32 cursor = event.edit.start;
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
	case SDL_FINGERDOWN:
		return ImGui::IsAnyItemActive();
	}
	return false;
}

NS_DOROTHY_END
