/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Common/Async.h"
#include "Input/TouchDispather.h"

struct ImDrawData;
struct ImFontAtlas;

NS_DOROTHY_BEGIN

class Listener;
class Texture2D;
class SpriteEffect;
class ConsolePanel;

class ImGuiDora : public TouchHandler
{
public:
	virtual ~ImGuiDora();
	bool init();
	void begin();
	void end();
	void render();
	void loadFontTTF(String ttfFontFile, float fontSize, String glyphRanges = "Default");
	void showStats();
	void showConsole();
	void handleEvent(const SDL_Event& event);
	void updateTexture(Uint8* data, int width, int height);
	virtual bool handle(const SDL_Event& event) override;
protected:
	ImGuiDora();
	void sendKey(int key, int count);
	static const char* getClipboardText(void*);
	static void setClipboardText(void*, const char* text);
	static void setImePositionHint(int x, int y);
	static int _lastIMEPosX, _lastIMEPosY;
private:
	bool _textInputing;
	bool _backSpaceIgnore;
	bool _mouseVisible;
	bool _mousePressed[3];
	bool _rejectAllEvents;
	float _mouseWheel;
	int _lastCursor;
	UITouchHandler* _touchHandler;
	Ref<Texture2D> _fontTexture;
	Ref<SpriteEffect> _defaultEffect;
	Ref<SpriteEffect> _imageEffect;
	bgfx::VertexLayout _vertexLayout;
	list<SDL_Event> _inputs;
	vector<Uint32> _textEditing;
	string _iniFilePath;
	Own<ConsolePanel> _console;
	Own<ImFontAtlas> _defaultFonts;
	Own<ImFontAtlas> _fonts;
	SINGLETON_REF(ImGuiDora, BGFXDora);
	// font building is calling in thread, so make thread depend on ImGui
	SINGLETON_REF(AsyncThread, ImGuiDora);
};

#define SharedImGui \
	Dorothy::Singleton<Dorothy::ImGuiDora>::shared()

NS_DOROTHY_END
