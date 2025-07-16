/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Common/Async.h"
#include "Input/TouchDispather.h"

struct ImDrawData;
struct ImFontAtlas;
struct ImGuiContext;

NS_DORA_BEGIN

class Listener;
class Texture2D;
class Pass;
class ConsolePanel;
class TrueTypeFile;

class ImGuiDora : public NonCopyable {
public:
	virtual ~ImGuiDora();
	bool init();
	void begin();
	void end();
	void render();
	void setDefaultFont(String ttfFontFile, float fontSize);
	void showStats(bool* pOpen, uint32_t windowFlags, const std::function<void()>& extra = nullptr);
	void showConsole(bool initOnly);
	void handleEvent(const SDL_Event& event);

	class ImGuiTouchHandler : public TouchHandler {
	public:
		ImGuiTouchHandler(ImGuiDora* owner)
			: _owner(owner) { }
		virtual ~ImGuiTouchHandler() { }
		virtual bool handle(const SDL_Event& event) override;

	protected:
		ImGuiDora* _owner;
	};
	PROPERTY_READONLY(ImGuiTouchHandler*, TouchHandler);

public:
	static void setImePositionHint(int x, int y);

protected:
	ImGuiDora();
	void sendKey(int key, int count);
	Texture2D* createTexture(uint8_t* data, int width, int height, bgfx::TextureFormat::Enum format, uint32_t pixelSize);
	static const char* getClipboardText(ImGuiContext*);
	static void setClipboardText(ImGuiContext*, const char* text);
	static int _lastIMEPosX, _lastIMEPosY;

private:
	bool _showPlot;

private:
	bool _useChinese;
	bool _textInputing;
	bool _backSpaceIgnore;
	bool _mouseVisible;
	bool _mousePressed[3];
	Vec2 _mouseWheel;
	int _lastCursor;
	std::list<Ref<Texture2D>> _textures;
	Ref<TrueTypeFile> _fontFile;
	bgfx::UniformHandle _sampler;
	Ref<Pass> _imagePass;
	Ref<Pass> _defaultPass;
	Ref<Listener> _appChangeListener;
	bgfx::VertexLayout _vertexLayout;
	std::list<std::any> _inputs;
	std::vector<uint32_t> _textEditing;
	std::string _iniFilePath;
	Own<ConsolePanel> _console;
	std::shared_ptr<ImGuiTouchHandler> _touchHandler;
	std::unordered_map<int, int> _keymap;
	SINGLETON_REF(ImGuiDora, FontManager, BGFXDora);
};

#define SharedImGui \
	Dora::Singleton<Dora::ImGuiDora>::shared()

NS_DORA_END
