/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "font/font_manager.h"
#include "Support/Geometry.h"
#include "Node/Node.h"
#include "Node/Sprite.h"

NS_DOROTHY_BEGIN

class TrueTypeFile : public Object
{
public:
	PROPERTY_READONLY(bgfx::TrueTypeHandle, Handle);
	CREATE_FUNC(TrueTypeFile);
	virtual ~TrueTypeFile();
protected:
	TrueTypeFile(bgfx::TrueTypeHandle handle);
private:
	bgfx::TrueTypeHandle _handle;
};

class Font : public Object
{
public:
	PROPERTY_READONLY(bgfx::FontHandle, Handle);
	PROPERTY_READONLY_REF(bgfx::FontInfo, Info);
	PROPERTY_READONLY(TrueTypeFile*, File);
	CREATE_FUNC(Font);
	virtual ~Font();
protected:
	Font(TrueTypeFile* file, bgfx::FontHandle handle);
private:
	bgfx::FontHandle _handle;
	Ref<TrueTypeFile> _file;
};

class FontManager : public bgfx::FontManager
{
protected:
	FontManager() { }
	SINGLETON_REF(FontManager, BGFXDora);
};

#define SharedFontManager \
	Dorothy::Singleton<Dorothy::FontManager>::shared()

class FontCache
{
public:
	PROPERTY_READONLY(SpriteEffect*, DefaultEffect);
	PROPERTY_READONLY(bgfx::FontManager*, Manager);
	virtual ~FontCache();
	void loadAync(String fontName, Uint32 fontSize,
		const function<void(Font* font)>& callback);
	Font* load(String fontName, Uint32 fontSize);
	bool unload();
	bool unload(String fontName, Uint32 fontSize);
	void removeUnused();
	Sprite* createCharacter(Font* font, bgfx::CodePoint character);
	std::tuple<Texture2D*, Rect> getCharacterInfo(Font* font, bgfx::CodePoint character);
	const bgfx::GlyphInfo* getGlyphInfo(Font* font, bgfx::CodePoint character);
	const bgfx::GlyphInfo* updateCharacter(Sprite* sp, Font* font, bgfx::CodePoint character);
protected:
	FontCache();
private:
	Ref<SpriteEffect> _defaultEffect;
	unordered_map<string, Ref<TrueTypeFile>> _fontFiles;
	unordered_map<string, Ref<Font>> _fonts;
	SINGLETON_REF(FontCache, FontManager, BGFXDora);
};

#define SharedFontCache \
	Dorothy::Singleton<Dorothy::FontCache>::shared()

enum struct TextAlign
{
	Left,
	Center,
	Right
};

class Label : public Node
{
public:
	virtual ~Label();
	PROPERTY(TextAlign, Alignment);
	PROPERTY(float, TextWidth);
	PROPERTY(float, LineGap);
	PROPERTY(const char*, Text);
	PROPERTY(SpriteEffect*, Effect);
	PROPERTY_REF(BlendFunc, BlendFunc);
	PROPERTY_BOOL(DepthWrite);
	PROPERTY(float, AlphaRef);
	PROPERTY_BOOL(Batched);
	virtual void setRenderOrder(int var) override;
	Sprite* getCharacter(int index) const;
	int getCharacterCount() const;
	virtual void cleanup() override;
	virtual void render() override;
	virtual const Matrix& getWorld() override;
	static const float AutomaticWidth;
	CREATE_FUNC(Label);
protected:
	Label(String fontName, Uint32 fontSize);
	void updateCharacters(const vector<Uint32>& chars);
	void updateLabel();
	struct CharItem
	{
		CharItem():
		code(0),texture(nullptr),rect{},pos{},sprite(nullptr) { }
		Uint32 code;
		Texture2D* texture;
		Rect rect;
		Vec2 pos;
		Sprite* sprite;
	};
	float getLetterPosXLeft(CharItem* item);
	float getLetterPosXRight(CharItem* item);
	void updateVertTexCoord();
	void updateVertPosition();
	void updateVertColor();
	virtual void updateRealColor3() override;
	virtual void updateRealOpacity() override;
private:
	Uint8 _alphaRef;
	float _textWidth;
	float _lineGap;
	Ref<Font> _font;
	Ref<SpriteEffect> _effect;
	BlendFunc _blendFunc;
	TextAlign _alignment;
	string _textUTF8;
	vector<Uint32> _text;
	OwnVector<CharItem> _characters;
	vector<SpriteQuad::Position> _quadPos;
	vector<SpriteQuad> _quads;
	enum
	{
		DepthWrite = Node::UserFlag,
		TextBatched = Node::UserFlag << 1,
		QuadDirty = Node::UserFlag << 2,
		VertexColorDirty = Node::UserFlag << 3,
		VertexPosDirty = Node::UserFlag << 4,
	};
	DORA_TYPE_OVERRIDE(Label);
};

NS_DOROTHY_END
