/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/Label.h"

#include "Basic/Content.h"
#include "Basic/Director.h"
#include "Cache/ShaderCache.h"
#include "Effect/Effect.h"
#include "Node/Sprite.h"
#include "Other/atlas.h"
#include "Other/sdf_gen2d.h"
#include "Other/utf8.h"
#include "font/font_manager.h"

NS_DORA_BEGIN

/* TrueTypeFont */

bgfx::TrueTypeHandle TrueTypeFile::getHandle() const noexcept {
	return _handle;
}

TrueTypeFile::TrueTypeFile(bgfx::TrueTypeHandle handle)
	: _handle(handle) { }

TrueTypeFile::~TrueTypeFile() {
	if (bgfx::isValid(_handle)) {
		SharedFontManager.destroyTtf(_handle);
		_handle = BGFX_INVALID_HANDLE;
	}
}

/* Font */

bgfx::FontHandle Font::getHandle() const noexcept {
	return _handle;
}

Font::Font(NotNull<TrueTypeFile, 1> file, bgfx::FontHandle handle)
	: _file(file)
	, _handle(handle) { }

Font::~Font() {
	if (bgfx::isValid(_handle)) {
		SharedFontManager.destroyFont(_handle);
		_handle = BGFX_INVALID_HANDLE;
	}
}

const bgfx::FontInfo& Font::getInfo() const {
	return SharedFontManager.getFontInfo(_handle);
}

TrueTypeFile* Font::getFile() const noexcept {
	return _file;
}

/* FontCache */

FontCache::FontCache()
	: _defaultEffect(SpriteEffect::create("builtin:vs_sprite"_slice, "builtin:fs_spritewhite"_slice))
	, _sdfEffect(SpriteEffect::create("builtin:vs_sprite"_slice, "builtin:fs_spritesdfoutline"_slice)) { }

FontCache::~FontCache() {
	unload();
}

SpriteEffect* FontCache::getDefaultEffect() const noexcept {
	return _defaultEffect;
}

SpriteEffect* FontCache::getSDFEffect() const noexcept {
	return _sdfEffect;
}

std::tuple<std::string, int, bool> FontCache::getArgsFromStr(String fontStr) {
	auto tokens = fontStr.split(";"_slice);
	if (tokens.size() >= 2) {
		auto it = tokens.begin();
		Slice fontName = *it;
		int fontSize = (++it)->toInt();
		bool sdf = false;
		if (tokens.size() == 3 && *(++it) == "true"_slice) {
			sdf = true;
		}
		return {fontName.toString(), fontSize, sdf};
	} else {
		Error("invalid fontStr for \"{}\", expecting \"[fontName];[fontSize];[true or false as sdf]\".", fontStr.toString());
		return {Slice::Empty, 0, false};
	}
}

bool FontCache::unload() {
	if (_fonts.empty() && _fontFiles.empty()) {
		return false;
	}
	_fonts.clear();
	_fontFiles.clear();
	return true;
}

bool FontCache::unload(String fontStr) {
	std::string fontName;
	int fontSize = 0;
	bool sdf = false;
	std::tie(fontName, fontSize, sdf) = getArgsFromStr(fontStr);
	auto fontIt = _fonts.find(fontStr);
	if (fontIt != _fonts.end()) {
		TrueTypeFile* fontFile = fontIt->second->getFile();
		_fonts.erase(fontIt);
		if (fontFile->isSingleReferenced()) {
			auto fileIt = _fontFiles.find(fontName);
			if (fileIt != _fontFiles.end()) {
				_fontFiles.erase(fileIt);
			}
		}
		return true;
	}
	return false;
}

bool FontCache::unload(String fontName, uint32_t fontSize) {
	auto fontNameStr = fontName.toString();
	std::string fontFaceName = fmt::format("{};{}", fontNameStr, fontSize);
	auto fontIt = _fonts.find(fontFaceName);
	if (fontIt != _fonts.end()) {
		TrueTypeFile* fontFile = fontIt->second->getFile();
		_fonts.erase(fontIt);
		if (fontFile->isSingleReferenced()) {
			auto fileIt = _fontFiles.find(fontNameStr);
			if (fileIt != _fontFiles.end()) {
				_fontFiles.erase(fileIt);
			}
		}
		return true;
	}
	return false;
}

void FontCache::removeUnused() {
	for (auto it = _fontFiles.begin(); it != _fontFiles.end();) {
		if (it->second->isSingleReferenced()) {
			it = _fontFiles.erase(it);
		} else
			++it;
	}
	for (auto it = _fonts.begin(); it != _fonts.end();) {
		if (it->second->isSingleReferenced()) {
			it = _fonts.erase(it);
		} else
			++it;
	}
}

Font* FontCache::load(String fontStr) {
	std::string fontName;
	int fontSize = 0;
	bool sdf = false;
	std::tie(fontName, fontSize, sdf) = getArgsFromStr(fontStr);
	if (fontName.empty()) return nullptr;
	return load(fontName, fontSize, sdf);
}

Font* FontCache::load(String fontName, uint32_t fontSize, bool sdf) {
	auto name = Path::getName(fontName);
	std::string fontFaceName = fmt::format("{};{};{}", name, fontSize, sdf);
	auto fontIt = _fonts.find(fontFaceName);
	if (fontIt != _fonts.end()) {
		return fontIt->second;
	} else {
		std::string fontNameStr = fontName.toString();
		std::string fontFile;
		BLOCK_START
		fontFile = SharedContent.getFullPath(fontNameStr);
		BREAK_IF(SharedContent.exist(fontFile));
		fontFile = SharedContent.getFullPath("Font/"s + fontNameStr + ".ttf"s);
		BREAK_IF(SharedContent.exist(fontFile));
		fontFile = SharedContent.getFullPath("Font/"s + fontNameStr + ".otf"s);
		BREAK_IF(SharedContent.exist(fontFile));
		Error("can not load font file named \"{}\".", fontNameStr);
		return nullptr;
		BLOCK_END
		auto fileIt = _fontFiles.find(fontFile);
		if (fileIt != _fontFiles.end()) {
			bgfx::FontHandle fontHandle = SharedFontManager.createFontByPixelSize(fileIt->second->getHandle(), fontSize, sdf);
			Font* font = Font::create(fileIt->second.get(), fontHandle);
			_fonts[fontFaceName] = font;
			return font;
		} else {
			auto data = SharedContent.load(fontFile);
			if (!data.first) {
				Error("failed to load font \"{}\".", fontNameStr);
				return nullptr;
			}
			bgfx::TrueTypeHandle trueTypeHandle = SharedFontManager.createTtf(data.first.get(), s_cast<uint32_t>(data.second));
			TrueTypeFile* file = TrueTypeFile::create(trueTypeHandle);
			_fontFiles[fontFile] = file;
			bgfx::FontHandle fontHandle = SharedFontManager.createFontByPixelSize(trueTypeHandle, fontSize, sdf);
			Font* font = Font::create(file, fontHandle);
			_fonts[fontFaceName] = font;
			return font;
		}
	}
}

void FontCache::loadAync(String fontStr, const std::function<void(Font* fontHandle)>& callback) {
	std::string fontName;
	int fontSize = 0;
	bool sdf = false;
	std::tie(fontName, fontSize, sdf) = getArgsFromStr(fontStr);
	if (fontName.empty()) {
		callback(nullptr);
		return;
	}
	loadAync(fontName, fontSize, sdf, callback);
}

void FontCache::loadAync(String fontName, uint32_t fontSize, bool sdf, const std::function<void(Font* fontHandle)>& callback) {
	auto name = Path::getName(fontName);
	std::string fontFaceName = fmt::format("{};{};{}", name, fontSize, sdf);
	auto fontIt = _fonts.find(fontFaceName);
	if (fontIt != _fonts.end()) {
		callback(fontIt->second);
	} else {
		std::string fontNameStr = fontName.toString();
		std::string fontFile;
		BLOCK_START
		fontFile = SharedContent.getFullPath(fontNameStr);
		BREAK_IF(SharedContent.exist(fontFile));
		fontFile = SharedContent.getFullPath("Font/"s + fontNameStr + ".ttf"s);
		BREAK_IF(SharedContent.exist(fontFile));
		fontFile = SharedContent.getFullPath("Font/"s + fontNameStr + ".otf"s);
		BREAK_IF(SharedContent.exist(fontFile));
		Error("can not load font file named \"{}\".", fontNameStr);
		callback(nullptr);
		BLOCK_END
		auto fileIt = _fontFiles.find(fontFile);
		if (fileIt != _fontFiles.end()) {
			bgfx::FontHandle fontHandle = SharedFontManager.createFontByPixelSize(fileIt->second->getHandle(), fontSize, sdf);
			Font* font = Font::create(fileIt->second.get(), fontHandle);
			_fonts[fontFaceName] = font;
			callback(font);
		} else {
			SharedContent.loadAsyncUnsafe(fontFile, [this, fontFaceName, fontFile, fontSize, sdf, callback](uint8_t* data, int64_t size) {
				bgfx::TrueTypeHandle trueTypeHandle = SharedFontManager.createTtf(data, s_cast<uint32_t>(size));
				TrueTypeFile* file = TrueTypeFile::create(trueTypeHandle);
				_fontFiles[fontFile] = file;
				bgfx::FontHandle fontHandle = SharedFontManager.createFontByPixelSize(trueTypeHandle, fontSize, sdf);
				Font* font = Font::create(file, fontHandle);
				_fonts[fontFaceName] = font;
				callback(font);
			});
		}
	}
}

Sprite* FontCache::createCharacter(Font* font, bgfx::CodePoint character) {
	Texture2D* texture;
	Rect rect;
	std::tie(texture, rect) = getCharacterInfo(font, character);
	Sprite* sprite = Sprite::create(texture, rect);
	return sprite;
}

std::tuple<Texture2D*, Rect> FontCache::getCharacterInfo(Font* font, bgfx::CodePoint character) {
	const bgfx::GlyphInfo* glyphInfo = SharedFontManager.getGlyphInfo(font->getHandle(), character);
	bgfx::Atlas* atlas = glyphInfo->atlas;
	const bgfx::AtlasRegion& region = atlas->getRegion(glyphInfo->regionIndex);
	if (font->getInfo().sdf) {
		return std::make_tuple(atlas->getTexture(), Rect(region.x, region.y, region.width, region.height));
	}
	return std::make_tuple(atlas->getTexture(), Rect(region.x, region.y, region.width, region.height));
}

const bgfx::GlyphInfo* FontCache::getGlyphInfo(Font* font, bgfx::CodePoint character) {
	return SharedFontManager.getGlyphInfo(font->getHandle(), character);
}

const bgfx::GlyphInfo* FontCache::updateCharacter(Sprite* sp, Font* font, bgfx::CodePoint character) {
	const bgfx::GlyphInfo* glyphInfo = SharedFontManager.getGlyphInfo(font->getHandle(), character);
	bgfx::Atlas* atlas = glyphInfo->atlas;
	const bgfx::AtlasRegion& region = atlas->getRegion(glyphInfo->regionIndex);
	sp->setTexture(atlas->getTexture());
	sp->setTextureRect(Rect(region.x, region.y, region.width, region.height));
	sp->setSize(sp->getTextureRect().size);
	return glyphInfo;
}

/* Label*/

const float Label::AutomaticWidth = -1.0f;

Label::Label(String fontName, uint32_t fontSize, bool sdf)
	: _alphaRef(0)
	, _spacing(0)
	, _textWidth(Label::AutomaticWidth)
	, _alignment(TextAlign::Center)
	, _outlineColor(0x0)
	, _outlineWidth(0.0f)
	, _smooth{sdf::sdf_gen2d::suggested_edge_x, sdf::sdf_gen2d::suggested_edge_y}
	, _font(SharedFontCache.load(fontName, fontSize, sdf))
	, _blendFunc(BlendFunc::Default)
	, _effect(sdf ? SharedFontCache.getSDFEffect() : SharedFontCache.getDefaultEffect()) {
	if (_font) {
		_lineGap = _font->getInfo().lineGap;
		_flags.setOff(Node::TraverseEnabled);
		_flags.setOn(Label::TextBatched);
	}
}

Label::Label(String fontStr)
	: _alphaRef(0)
	, _spacing(0)
	, _textWidth(Label::AutomaticWidth)
	, _alignment(TextAlign::Center)
	, _font(SharedFontCache.load(fontStr))
	, _blendFunc(BlendFunc::Default) {
	if (_font) {
		_effect = _font->getInfo().sdf ? SharedFontCache.getSDFEffect() : SharedFontCache.getDefaultEffect();
		_lineGap = _font->getInfo().lineGap;
		_flags.setOff(Node::TraverseEnabled);
		_flags.setOn(Label::TextBatched);
	}
}

Label::~Label() { }

bool Label::init() {
	if (!Node::init()) return false;
	if (!_font) {
		setAsManaged();
		return false;
	}
	return true;
}

void Label::setTextWidth(float var) {
	if (var < 0.0f) {
		var = Label::AutomaticWidth;
	}
	if (_textWidth != var) {
		_textWidth = var;
		updateLabel();
	}
}

float Label::getTextWidth() const noexcept {
	return _textWidth;
}

void Label::setSpacing(float var) {
	if (_spacing != var) {
		_spacing = var;
		updateLabel();
	}
}

float Label::getSpacing() const noexcept {
	return _spacing;
}

void Label::setLineGap(float var) {
	if (_lineGap != var) {
		_lineGap = var;
		updateLabel();
	}
}

float Label::getLineGap() const noexcept {
	return _lineGap;
}

void Label::setAlignment(TextAlign var) {
	if (_alignment != var) {
		_alignment = var;
		updateLabel();
	}
}

TextAlign Label::getAlignment() const noexcept {
	return _alignment;
}

void Label::setText(String var) {
	_textUTF8 = var.toString();
	updateLabel();
}

const std::string& Label::getText() const noexcept {
	return _textUTF8;
}

void Label::setBlendFunc(const BlendFunc& var) {
	_blendFunc = var;
	for (const auto& fontChar : _characters) {
		if (fontChar && fontChar->sprite) {
			fontChar->sprite->setBlendFunc(var);
		}
	}
}

const BlendFunc& Label::getBlendFunc() const noexcept {
	return _blendFunc;
}

void Label::setEffect(SpriteEffect* var) {
	_effect = var;
	for (const auto& fontChar : _characters) {
		if (fontChar && fontChar->sprite) {
			fontChar->sprite->setEffect(var);
		}
	}
}

SpriteEffect* Label::getEffect() const noexcept {
	return _effect;
}

void Label::setDepthWrite(bool var) {
	_flags.set(Label::DepthWrite, var);
}

bool Label::isDepthWrite() const noexcept {
	return _flags.isOn(Label::DepthWrite);
}

void Label::setAlphaRef(float var) {
	_alphaRef = s_cast<uint8_t>(255.0f * Math::clamp(var, 0.0f, 1.0f));
}

float Label::getAlphaRef() const noexcept {
	return _alphaRef / 255.0f;
}

void Label::setRenderOrder(int var) {
	Node::setRenderOrder(var);
	for (const auto& fontChar : _characters) {
		if (fontChar && fontChar->sprite) {
			fontChar->sprite->setRenderOrder(var);
		}
	}
}

void Label::setBatched(bool var) {
	if (_flags.isOn(Label::TextBatched) == var) {
		return;
	}
	_flags.set(Label::TextBatched, var);
	if (var) {
		for (const auto& fontChar : _characters) {
			if (fontChar && fontChar->sprite) {
				removeChild(fontChar->sprite);
				fontChar->sprite = nullptr;
			}
		}
		_flags.setOn(Label::QuadDirty);
	} else {
		setText(_textUTF8.c_str());
	}
}

bool Label::isBatched() const noexcept {
	return _flags.isOn(Label::TextBatched);
}

void Label::setOutlineColor(Color var) {
	_outlineColor = var;
}

Color Label::getOutlineColor() const noexcept {
	return _outlineColor;
}

void Label::setOutlineWidth(float var) {
	_outlineWidth = var;
}

float Label::getOutlineWidth() const noexcept {
	return _outlineWidth;
}

void Label::setSmooth(Vec2 var) {
	_smooth = var;
}

Vec2 Label::getSmooth() const noexcept {
	return _smooth;
}

Sprite* Label::getCharacter(int index) const {
	if (0 <= index && index < s_cast<int>(_text.size())) {
		return _characters[index] ? _characters[index]->sprite : nullptr;
	}
	return nullptr;
}

int Label::getCharacterCount() const {
	return s_cast<int>(_text.size());
}

float Label::getLetterPosXLeft(CharItem* item) {
	return item->pos.x - item->rect.getWidth() * 0.5f;
}

float Label::getLetterPosXRight(CharItem* item) {
	return item->pos.x + item->rect.getWidth() * 0.5f;
}

void Label::updateCharacters(const std::vector<uint32_t>& chars) {
	if (!_font) return;
	float nextFontPositionX = 0;
	float nextFontPositionY = 0;
	uint32_t prev = 0;
	float kerningAmount = 0;
	Size finalSize;
	float longestLine = 0;
	float totalHeight = 0;
	uint32_t quantityOfLines = 1;

	for (size_t i = 0; i < _characters.size(); i++) {
		if (_characters[i] && _characters[i]->sprite) {
			_characters[i]->sprite->setVisible(false);
		}
	}

	if (_characters.size() < chars.size()) {
		_characters.resize(chars.size());
	}

	for (uint32_t ch : chars) {
		if (ch == '\n') {
			quantityOfLines++;
		}
	}

	const bgfx::FontInfo& fontInfo = _font->getInfo();
	float lineHeight = fontInfo.ascender - fontInfo.descender + _lineGap;
	totalHeight = lineHeight * quantityOfLines - (quantityOfLines > 0 ? _lineGap : 0);
	nextFontPositionY = lineHeight * quantityOfLines - lineHeight;

	float padding = fontInfo.sdf ? fontInfo.pixelSize * SDF_FONT_BUFFER_PADDING_RATIO : 0;

	const bgfx::GlyphInfo* fontDef = nullptr;
	for (size_t i = 0; i < chars.size(); i++) {
		uint32_t ch = chars[i];
		CharItem* fontChar = _characters[i].get();

		bool isTab = ch == '\t';
		if (isTab) {
			ch = ' ';
		}

		if (ch == '\n') {
			nextFontPositionX = 0;
			nextFontPositionY -= lineHeight;
			if (fontChar) {
				fontChar->code = ch;
				if (fontChar->sprite) {
					fontChar->sprite->setVisible(false);
				}
			}
			continue;
		}

		kerningAmount = s_cast<float>(SharedFontManager.getKerning(_font->getHandle(), prev, ch)) + _spacing;

		fontDef = SharedFontCache.getGlyphInfo(_font, ch);
		if (!fontDef) {
			ch = '?';
			fontDef = SharedFontCache.getGlyphInfo(_font, '?');
			if (!fontDef) {
				Warn("attempted to use character not defined in this font: {}", ch);
				continue;
			}
		}

		if (fontChar) {
			if (fontChar->sprite) {
				SharedFontCache.updateCharacter(fontChar->sprite, _font, ch);
				fontChar->sprite->setVisible(ch != '\0');
			}
		} else {
			_characters[i] = New<CharItem>();
			fontChar = _characters[i].get();
			if (_flags.isOff(Label::TextBatched)) {
				Sprite* sprite = SharedFontCache.createCharacter(_font, ch);
				sprite->setBlendFunc(_blendFunc);
				sprite->setRenderOrder(getRenderOrder());
				sprite->setDepthWrite(isDepthWrite());
				sprite->setEffect(_effect);
				sprite->setVisible(ch != '\0');
				addChild(sprite);
				fontChar->sprite = sprite;
			}
		}
		fontChar->code = ch;
		std::tie(fontChar->texture, fontChar->rect) = SharedFontCache.getCharacterInfo(_font, ch);

		float yOffset = -fontDef->offset_y;
		Vec2 fontPos = Vec2{
			nextFontPositionX + fontDef->offset_x + fontDef->width * 0.5f + kerningAmount - padding,
			nextFontPositionY + yOffset - fontDef->height * 0.5f - fontInfo.descender + padding};
		fontChar->pos = fontPos;
		if (fontChar->sprite) {
			fontChar->sprite->setPosition(fontPos);
		}

		// update kerning
		nextFontPositionX += fontDef->advance_x * (isTab ? 2 : 1) + kerningAmount;
		prev = ch;
		if (longestLine < nextFontPositionX) {
			longestLine = nextFontPositionX;
		}
	}

	if (_textWidth > 0) {
		finalSize.width = _textWidth;
	} else if (fontDef) {
		// If the last character processed has an xAdvance which is less that the width of the characters image, then we need
		// to adjust the width of the string to take this into account, or the character will overlap the end of the bounding
		// box
		if (fontDef->advance_x < fontDef->width) {
			finalSize.width = longestLine + fontDef->width - fontDef->advance_x;
		} else {
			finalSize.width = longestLine;
		}
	} else {
		finalSize.width = 0.0f;
	}
	finalSize.height = totalHeight;
	setSize(finalSize);
}

void Label::updateLabel() {
	if (!_font) return;
	_text = utf8_get_characters(_textUTF8.c_str());
	_text.push_back('\0');

	if (_flags.isOn(Label::TextBatched)) {
		_flags.setOn(Label::QuadDirty);
	}

	// Step 0: Create characters
	updateCharacters(_text);

	if (_text.empty()) return;

	// Step 1: Make multiline
	if (_textWidth >= 0) {
		// Step 1: Make multiline
		int stringLength = s_cast<int>(_text.size());
		std::vector<uint32_t> multiline_string;
		multiline_string.reserve(stringLength);
		std::vector<uint32_t> last_word;
		last_word.reserve(stringLength);

		int i = 0;
		bool start_line = false, start_word = false, skiped_one = false;
		float startOfLine = -1, startOfWord = -1;

		for (int j = 0; j < stringLength; j++) {
			int justSkipped = 0;
			CharItem* characterItem;
			while (!(characterItem = _characters[j + justSkipped].get()) || characterItem->code == '\n') {
				justSkipped++;
				if (j + justSkipped >= stringLength) {
					break;
				}
			}
			j += justSkipped;

			if (i >= stringLength || !characterItem) break;

			uint32_t character = _text[i];

			if (!start_word) {
				startOfWord = getLetterPosXLeft(characterItem);
				start_word = true;
			}
			if (!start_line) {
				startOfLine = startOfWord;
				start_line = true;
			}

			// Newline.
			if (character == '\n') {
				utf8_trim_ws(last_word);
				for (int n = 0; n < justSkipped; n++) {
					last_word.push_back('\n');
				}
				multiline_string.insert(
					multiline_string.end(),
					last_word.begin(),
					last_word.end());
				last_word.clear();
				start_word = false;
				start_line = false;
				startOfWord = -1;
				startOfLine = -1;
				i += justSkipped;

				if (i >= stringLength) break;

				character = _text[i];
				if (!start_word) {
					startOfWord = getLetterPosXLeft(characterItem);
					start_word = true;
				}
				if (!start_line) {
					startOfLine = startOfWord;
					start_line = true;
				}
			}

			// Whitespace.
			if (utf8_isspace(character)) {
				last_word.push_back(character);
				multiline_string.insert(
					multiline_string.end(),
					last_word.begin(),
					last_word.end());
				last_word.clear();
				start_word = false;
				startOfWord = -1;
				i++;
				continue;
			}

			// Out of bounds.
			if (i > 0 && !skiped_one && getLetterPosXRight(characterItem) - startOfLine > _textWidth) {
				if (character <= 255 && std::isalnum(character)) {
					last_word.push_back(character);
					int found = utf8_find_last_not_alnum(last_word);
					if (found != -1) {
						auto begin = last_word.begin();
						auto end = last_word.begin() + found + 1;
						multiline_string.insert(multiline_string.end(), begin, end);
						multiline_string.push_back('\n');
						last_word.erase(begin, end);
						startOfWord = getLetterPosXLeft(_characters[i - last_word.size()].get());
						start_word = true;
						startOfLine = startOfWord;
						start_line = true;
						i++;
					} else {
						found = -1;
						for (auto it = multiline_string.rbegin(); it != multiline_string.rend(); ++it) {
							if (!utf8_isspace(*it)) {
								found = s_cast<int>(std::distance(multiline_string.rend(), it));
								break;
							}
						}
						if (found != -1) {
							utf8_trim_ws(multiline_string);
						} else {
							multiline_string.clear();
						}
						if (multiline_string.size() > 0) {
							multiline_string.push_back('\n');
						}
						start_line = false;
						startOfLine = -1;
						i++;
					}
				} else {
					utf8_trim_ws(last_word);

					last_word.push_back('\n');
					multiline_string.insert(
						multiline_string.end(),
						last_word.begin(),
						last_word.end());
					last_word.clear();
					start_word = false;
					start_line = false;
					startOfWord = -1;
					startOfLine = -1;

					if (i >= stringLength) break;

					if (!startOfWord) {
						startOfWord = getLetterPosXLeft(characterItem);
						start_word = true;
					}
					if (!startOfLine) {
						startOfLine = startOfWord;
						start_line = true;
					}
					j--;
					skiped_one = true;
				}
			} else {
				skiped_one = false;
				// Character is normal.
				last_word.push_back(character);
				i++;
			}
		}

		multiline_string.insert(
			multiline_string.end(),
			last_word.begin(),
			last_word.end());

		size_t size = multiline_string.size();
		std::vector<uint32_t> str_new(size + 1);
		for (size_t i = 0; i < size; ++i) {
			str_new[i] = multiline_string[i];
		}
		str_new[str_new.size() - 1] = '\0';
		updateCharacters(str_new);
		_text = std::move(str_new);
	}

	// Step 2: Make alignment
	if (_alignment != TextAlign::Left) {
		int i = 0;
		int lineNumber = 0;
		std::vector<uint32_t> last_line;
		for (size_t ctr = 0; ctr < _text.size(); ++ctr) {
			if (_text[ctr] == '\n' || _text[ctr] == '\0') {
				float lineWidth = 0.0f;
				int line_length = s_cast<int>(last_line.size());
				// if last line is empty we must just increase lineNumber and work with next line
				if (line_length == 0) {
					lineNumber++;
					continue;
				}
				int index = i + line_length - 1 + lineNumber;
				if (index < 0) continue;
				CharItem* lastChar = _characters[index].get();
				if (!lastChar) continue;
				lineWidth = getLetterPosXRight(lastChar);

				float shift = 0;
				switch (_alignment) {
					case TextAlign::Center:
						shift = getWidth() * 0.5f - lineWidth * 0.5f;
						break;
					case TextAlign::Right:
						shift = getWidth() - lineWidth;
						break;
					default:
						break;
				}
				if (shift != 0) {
					for (int j = 0; j < line_length; j++) {
						index = i + j + lineNumber;
						if (index < 0) continue;
						CharItem* characterItem = _characters[index].get();
						if (characterItem) {
							characterItem->pos += Vec2{shift, 0.0f};
							if (characterItem->sprite) {
								characterItem->sprite->setPosition(characterItem->pos);
							}
						}
					}
				}

				i += line_length;
				lineNumber++;
				last_line.clear();
				continue;
			}
			last_line.push_back(_text[ctr]);
		}
	}
}

void Label::cleanup() {
	if (_flags.isOff(Node::Cleanup)) {
		Node::cleanup();
		_font = nullptr;
	}
}

void Label::updateVertTexCoord() {
	_quads.clear();
	_quads.reserve(_characters.size());
	uint32_t abgr = _realColor.toABGR();
	for (size_t i = 0; i < _text.size(); i++) {
		CharItem* item = _characters[i].get();
		if (item && _text[i] != '\n' && _text[i] != '\0') {
			const bgfx::TextureInfo& info = item->texture->getInfo();
			const Rect& rect = item->rect;
			float left = rect.getX() / info.width;
			float top = rect.getY() / info.height;
			float right = (rect.getX() + rect.getWidth()) / info.width;
			float bottom = (rect.getY() + rect.getHeight()) / info.height;
			SpriteQuad quad;
			quad.lt.u = left;
			quad.lt.v = top;
			quad.rt.u = right;
			quad.rt.v = top;
			quad.lb.u = left;
			quad.lb.v = bottom;
			quad.rb.u = right;
			quad.rb.v = bottom;
			quad.lt.abgr = abgr;
			quad.rt.abgr = abgr;
			quad.lb.abgr = abgr;
			quad.rb.abgr = abgr;
			_quads.push_back(quad);
		}
	}
}

void Label::updateVertPosition() {
	_quadPos.clear();
	_quadPos.reserve(_characters.size());
	for (size_t i = 0; i < _text.size(); i++) {
		CharItem* item = _characters[i].get();
		if (item && _text[i] != '\n' && _text[i] != '\0') {
			const Vec2& pos = item->pos;
			const Rect& rect = item->rect;
			float halfW = rect.getWidth() * 0.5f;
			float halfH = rect.getHeight() * 0.5f;
			float left = pos.x - halfW, right = pos.x + halfW, top = pos.y + halfH, bottom = pos.y - halfH;
			SpriteQuad::Position quadPos{{0, 0, 0, 1}, {0, 0, 0, 1}, {0, 0, 0, 1}, {0, 0, 0, 1}};
			quadPos.lt.x = left;
			quadPos.lt.y = top;
			quadPos.rt.x = right;
			quadPos.rt.y = top;
			quadPos.lb.x = left;
			quadPos.lb.y = bottom;
			quadPos.rb.x = right;
			quadPos.rb.y = bottom;
			_quadPos.push_back(quadPos);
			_flags.setOn(Label::VertexPosDirty);
		}
	}
}

void Label::updateVertColor() {
	uint32_t abgr = _realColor.toABGR();
	for (auto& quad : _quads) {
		quad.lt.abgr = abgr;
		quad.rt.abgr = abgr;
		quad.lb.abgr = abgr;
		quad.rb.abgr = abgr;
	}
}

void Label::updateRealColor3() {
	Node::updateRealColor3();
	_flags.setOn(Label::VertexColorDirty);
}

void Label::updateRealOpacity() {
	Node::updateRealOpacity();
	_flags.setOn(Label::VertexColorDirty);
}

const Matrix& Label::getWorld() {
	if (_flags.isOn(Node::WorldDirty)) {
		_flags.setOn(Label::VertexPosDirty);
	}
	return Node::getWorld();
}

void Label::render() {
	if (_font && _font->getInfo().sdf && _effect) {
		const auto& passes = _effect->getPasses();
		if (!passes.empty()) {
			passes.front()->set("u_smooth"sv, _smooth.x, _smooth.y, _outlineWidth, 0.0f);
			passes.front()->set("u_outlineColor"sv, _outlineColor);
		}
	}

	if (_flags.isOff(Label::TextBatched)) {
		Node::render();
		return;
	}

	if (_flags.isOn(Label::QuadDirty)) {
		_flags.setOff(Label::QuadDirty);
		updateVertTexCoord();
		updateVertPosition();
		_flags.setOff(Label::VertexColorDirty);
		_flags.setOn(Label::VertexPosDirty);
	}

	if (_flags.isOn(Label::VertexColorDirty)) {
		_flags.setOff(Label::VertexColorDirty);
		updateVertColor();
	}

	if (SharedDirector.isFrustumCulling() && !_quadPos.empty()) {
		float minX = _quadPos[0].lb.x;
		float minY = _quadPos[0].lb.y;
		float maxX = _quadPos[0].rt.x;
		float maxY = _quadPos[0].rt.y;
		for (size_t i = 1; i < _quadPos.size(); i++) {
			const SpriteQuad::Position& quadPos = _quadPos[i];
			minX = std::min(minX, quadPos.lb.x);
			minY = std::min(minY, quadPos.lb.y);
			maxX = std::max(maxX, quadPos.rt.x);
			maxY = std::max(maxY, quadPos.rt.y);
		}
		AABB aabb;
		Matrix::mulAABB(aabb, getWorld(), {
										  {minX, minY, 0},
										  {maxX, maxY, 0},
									  });
		if (!SharedDirector.isInFrustum(aabb)) {
			return;
		}
	}

	if (_flags.isOn(Label::VertexPosDirty)) {
		_flags.setOff(Label::VertexPosDirty);
		Matrix transform;
		Matrix::mulMtx(transform, SharedDirector.getViewProjection(), getWorld());
		for (size_t i = 0; i < _quadPos.size(); i++) {
			SpriteQuad& quad = _quads[i];
			SpriteQuad::Position& quadPos = _quadPos[i];
			Matrix::mulVec4(&quad.lt.x, transform, quadPos.lt);
			Matrix::mulVec4(&quad.rt.x, transform, quadPos.rt);
			Matrix::mulVec4(&quad.lb.x, transform, quadPos.lb);
			Matrix::mulVec4(&quad.rb.x, transform, quadPos.rb);
		}
	}

	uint64_t renderState = (BGFX_STATE_WRITE_RGB | BGFX_STATE_WRITE_A | BGFX_STATE_ALPHA_REF(_alphaRef) | BGFX_STATE_MSAA | _blendFunc.toValue());
	if (_flags.isOn(Label::DepthWrite)) {
		renderState |= (BGFX_STATE_WRITE_Z | BGFX_STATE_DEPTH_TEST_LESS);
	}

	SharedRendererManager.setCurrent(SharedSpriteRenderer.getTarget());

	Texture2D* lastTexture = nullptr;
	int start = 0, index = 0;
	for (size_t i = 0; i < _text.size(); i++) {
		CharItem* item = _characters[i].get();
		if (item && _text[i] != '\n' && _text[i] != '\0') {
			if (!lastTexture) lastTexture = item->texture;
			if (lastTexture != item->texture) {
				int count = index - start;
				if (count > 0) {
					SharedSpriteRenderer.push(*(_quads.data() + start), count * 4, _effect, lastTexture, renderState);
				}
				start = index;
				lastTexture = item->texture;
			}
			index++;
		}
	}
	int count = index - start;
	if (count > 0) {
		SharedSpriteRenderer.push(*(_quads.data() + start), count * 4, _effect, lastTexture, renderState);
	}

	Node::render();
}

NS_DORA_END
