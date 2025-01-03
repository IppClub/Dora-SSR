/* Copyright (c) 2025 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node.h"
#include "Node/Sprite.h"
#include "Support/Geometry.h"
#include "font/font_manager.h"

NS_DORA_BEGIN

class TrueTypeFile : public Object {
public:
	PROPERTY_READONLY(bgfx::TrueTypeHandle, Handle);
	CREATE_FUNC_NOT_NULL(TrueTypeFile);
	virtual ~TrueTypeFile();

protected:
	TrueTypeFile(bgfx::TrueTypeHandle handle);

private:
	bgfx::TrueTypeHandle _handle;
};

class Font : public Object {
public:
	PROPERTY_READONLY(bgfx::FontHandle, Handle);
	PROPERTY_READONLY_CREF_EXCEPT(bgfx::FontInfo, Info);
	PROPERTY_READONLY(TrueTypeFile*, File);
	CREATE_FUNC_NOT_NULL(Font);
	virtual ~Font();

protected:
	Font(NotNull<TrueTypeFile, 1> file, bgfx::FontHandle handle);

private:
	bgfx::FontHandle _handle;
	Ref<TrueTypeFile> _file;
};

class FontManager : public bgfx::FontManager {
protected:
	FontManager()
		: bgfx::FontManager(DORA_FONT_TEXTURE_SIZE) { }
	SINGLETON_REF(FontManager, BGFXDora);
};

#define SharedFontManager \
	Dora::Singleton<Dora::FontManager>::shared()

class FontCache {
public:
	PROPERTY_READONLY(SpriteEffect*, DefaultEffect);
	PROPERTY_READONLY(SpriteEffect*, SDFEffect);
	PROPERTY_READONLY(bgfx::FontManager*, Manager);
	virtual ~FontCache();
	void loadAync(String fontStr,
		const std::function<void(Font* font)>& callback);
	void loadAync(String fontName, uint32_t fontSize, bool sdf,
		const std::function<void(Font* font)>& callback);
	Font* load(String fontStr);
	Font* load(String fontName, uint32_t fontSize, bool sdf);
	bool unload();
	bool unload(String fontStr);
	bool unload(String fontName, uint32_t fontSize);
	void removeUnused();
	Sprite* createCharacter(Font* font, bgfx::CodePoint character);
	std::tuple<Texture2D*, Rect> getCharacterInfo(Font* font, bgfx::CodePoint character);
	const bgfx::GlyphInfo* getGlyphInfo(Font* font, bgfx::CodePoint character);
	const bgfx::GlyphInfo* updateCharacter(Sprite* sp, Font* font, bgfx::CodePoint character);

protected:
	FontCache();

private:
	std::tuple<std::string, int, bool> getArgsFromStr(String fontStr);
	Ref<SpriteEffect> _defaultEffect;
	Ref<SpriteEffect> _sdfEffect;
	StringMap<Ref<TrueTypeFile>> _fontFiles;
	StringMap<Ref<Font>> _fonts;
	SINGLETON_REF(FontCache, FontManager, BGFXDora);
};

#define SharedFontCache \
	Dora::Singleton<Dora::FontCache>::shared()

enum struct TextAlign {
	Left = 0,
	Center = 1,
	Right = 2
};

class Label : public Node {
public:
	virtual ~Label();
	PROPERTY(TextAlign, Alignment);
	PROPERTY(float, TextWidth);
	PROPERTY(float, Spacing);
	PROPERTY(float, LineGap);
	PROPERTY_STRING(Text);
	PROPERTY(SpriteEffect*, Effect);
	PROPERTY_CREF(BlendFunc, BlendFunc);
	PROPERTY_BOOL(DepthWrite);
	PROPERTY(float, AlphaRef);
	PROPERTY(Color, OutlineColor);
	PROPERTY(float, OutlineWidth);
	PROPERTY(Vec2, Smooth);
	PROPERTY_BOOL(Batched);
	virtual void setRenderOrder(int var) override;
	Sprite* getCharacter(int index) const;
	int getCharacterCount() const;
	virtual bool init() override;
	virtual void cleanup() override;
	virtual void render() override;
	virtual const Matrix& getWorld() override;
	static const float AutomaticWidth;
	CREATE_FUNC_NULLABLE(Label);

protected:
	Label(String fontStr);
	Label(String fontName, uint32_t fontSize, bool sdf = false);
	void updateCharacters(const std::vector<uint32_t>& chars);
	void updateLabel();
	struct CharItem {
		CharItem()
			: code(0)
			, texture(nullptr)
			, rect{}
			, pos{}
			, sprite(nullptr) { }
		uint32_t code;
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
	uint8_t _alphaRef;
	float _spacing;
	float _textWidth;
	float _lineGap;
	Color _outlineColor;
	float _outlineWidth;
	Vec2 _smooth;
	Ref<Font> _font;
	Ref<SpriteEffect> _effect;
	BlendFunc _blendFunc;
	TextAlign _alignment;
	std::string _textUTF8;
	std::vector<uint32_t> _text;
	OwnVector<CharItem> _characters;
	std::vector<SpriteQuad::Position> _quadPos;
	std::vector<SpriteQuad> _quads;
	enum : Flag::ValueType {
		DepthWrite = Node::UserFlag,
		TextBatched = Node::UserFlag << 1,
		QuadDirty = Node::UserFlag << 2,
		VertexColorDirty = Node::UserFlag << 3,
		VertexPosDirty = Node::UserFlag << 4,
	};
	DORA_TYPE_OVERRIDE(Label);
};

NS_DORA_END
