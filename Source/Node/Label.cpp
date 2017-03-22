/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Node/Label.h"
#include "font/font_manager.h"
#include "Other/atlas.h"
#include "Other/utf8.h"
#include "Node/Sprite.h"
#include "Effect/Effect.h"
#include "Cache/ShaderCache.h"
#include "Basic/Content.h"
#include "fmt/format.h"

NS_DOROTHY_BEGIN

/* TrueTypeFont */

bgfx::TrueTypeHandle TrueTypeFile::getHandle() const
{
	return _handle;
}

TrueTypeFile::TrueTypeFile(bgfx::TrueTypeHandle handle):
_handle(handle)
{ }

TrueTypeFile::~TrueTypeFile()
{
	if (bgfx::isValid(_handle))
	{
		SharedFontManager.destroyTtf(_handle);
		_handle = BGFX_INVALID_HANDLE;
	}
}

/* Font */

bgfx::FontHandle Font::getHandle() const
{
	return _handle;
}

Font::Font(TrueTypeFile* file, bgfx::FontHandle handle):
_file(file),
_handle(handle)
{ }

Font::~Font()
{
	if (bgfx::isValid(_handle))
	{
		SharedFontManager.destroyFont(_handle);
		_handle = BGFX_INVALID_HANDLE;
	}
}

const bgfx::FontInfo& Font::getInfo() const
{
	return SharedFontManager.getFontInfo(_handle);
}

/* FontCache */

FontCache::FontCache():
_defaultEffect(SpriteEffect::create("built-in/vs_sprite.bin"_slice, "built-in/fs_spritewhite.bin"_slice))
{ }

FontCache::~FontCache()
{
	unload();
}

void FontCache::unload()
{
	_fonts.clear();
	_fontFiles.clear();
}

Font* FontCache::load(String fontName, Uint32 fontSize, Uint32 fontIndex)
{
	fmt::MemoryWriter writer;
	writer << fontName.toString() << '_' << fontSize << '_' << fontIndex;
	string fontFaceName = writer.str();
	auto fontIt = _fonts.find(fontFaceName);
	if (fontIt != _fonts.end())
	{
		return fontIt->second;
	}
	else
	{
		auto fileIt = _fontFiles.find(fontName);
		if (fileIt != _fontFiles.end())
		{
			bgfx::FontHandle fontHandle = SharedFontManager.createFontByPixelSize(fileIt->second->getHandle(), fontIndex, fontSize);
			Font* font = Font::create(fileIt->second, fontHandle);
			_fonts[fontFaceName] = font;
			return font;
		}
		else
		{
			string fontFile = "Font/" + fontName.toString() + ".ttf";
			if (!SharedContent.isFileExist(fontFile))
			{
				fontFile = "Font/" + fontName.toString() + ".otf";
				if (!SharedContent.isFileExist(fontFile))
				{
					Log("can not load font file named \"%s\".", fontName);
					return nullptr;
				}
			}
			auto data = SharedContent.loadFile(fontFile);
			bgfx::TrueTypeHandle trueTypeHandle = SharedFontManager.createTtf(data, s_cast<Uint32>(data.size()));
			TrueTypeFile* file = TrueTypeFile::create(trueTypeHandle);
			_fontFiles[fontName] = file;
			bgfx::FontHandle fontHandle = SharedFontManager.createFontByPixelSize(trueTypeHandle, fontIndex, fontSize);
			Font* font = Font::create(file, fontHandle);
			_fonts[fontFaceName] = font;
			return font;
		}
	}
}

void FontCache::loadAync(String fontName, Uint32 fontSize, Uint32 fontIndex, const function<void(Font* fontHandle)>& callback)
{
	fmt::MemoryWriter writer;
	writer << fontName.toString() << '_' << fontSize << '_' << fontIndex;
	string fontFaceName = writer.str();
	auto faceIt = _fonts.find(fontFaceName);
	if (faceIt != _fonts.end())
	{
		callback(faceIt->second);
	}
	else
	{
		auto fileIt = _fontFiles.find(fontName);
		if (fileIt != _fontFiles.end())
		{
			bgfx::FontHandle fontHandle = SharedFontManager.createFontByPixelSize(fileIt->second->getHandle(), fontIndex, fontSize);
			Font* font = Font::create(fileIt->second, fontHandle);
			_fonts[fontFaceName] = font;
			callback(font);
		}
		else
		{
			string fontFile = "Font/" + fontName.toString() + ".ttf";
			if (!SharedContent.isFileExist(fontFile))
			{
				fontFile = "Font/" + fontName.toString() + ".otf";
				if (!SharedContent.isFileExist(fontFile))
				{
					callback(nullptr);
				}
			}
			SharedContent.loadFileAsyncUnsafe(fontFile, [this, fontFaceName, fontName, fontIndex, fontSize, callback](Uint8* data, Sint64 size)
			{
				bgfx::TrueTypeHandle trueTypeHandle = SharedFontManager.createTtf(data, s_cast<Uint32>(size));
				TrueTypeFile* file = TrueTypeFile::create(trueTypeHandle);
				_fontFiles[fontName] = file;
				bgfx::FontHandle fontHandle = SharedFontManager.createFontByPixelSize(trueTypeHandle, fontIndex, fontSize);
				Font* font = Font::create(file, fontHandle);
				_fonts[fontFaceName] = font;
				callback(font);
			});
		}
	}
}

Sprite* FontCache::createCharacter(Font* font, bgfx::CodePoint character)
{
	Texture2D* texture;
	Rect rect;
	std::tie(texture, rect) = getCharacterInfo(font, character);
	Sprite* sprite = Sprite::create(texture, rect);
	sprite->setEffect(_defaultEffect);
	return sprite;
}

std::tuple<Texture2D*, Rect> FontCache::getCharacterInfo(Font* font, bgfx::CodePoint character)
{
	const bgfx::GlyphInfo* glyphInfo = SharedFontManager.getGlyphInfo(font->getHandle(), character);
	bgfx::Atlas* atlas = glyphInfo->atlas;
	const bgfx::AtlasRegion& region = atlas->getRegion(glyphInfo->regionIndex);
	return std::make_tuple(atlas->getTexture(), Rect(region.x, region.y, region.width, region.height));
}

const bgfx::GlyphInfo* FontCache::getGlyphInfo(Font* font, bgfx::CodePoint character)
{
	return SharedFontManager.getGlyphInfo(font->getHandle(), character);
}

const bgfx::GlyphInfo* FontCache::updateCharacter(Sprite* sp, Font* font, bgfx::CodePoint character)
{
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

Label::Label(String fontName, Uint32 fontSize):
_lineGap(0),
_textWidth(Label::AutomaticWidth),
_alignment(TextAlignment::Center),
_font(SharedFontCache.load(fontName, fontSize)),
_blendFunc(BlendFunc::Default)
{
	_flags.setOff(Node::TraverseEnabled);
}

Label::~Label()
{ }

void Label::setTextWidth(float var)
{
	if (var < 0.0f)
	{
		var = Label::AutomaticWidth;
	}
	if (_textWidth != var)
	{
		_textWidth = var;
		updateLabel();
	}
}

float Label::getTextWidth() const
{
	return _textWidth;
}

void Label::setLineGap(float var)
{
	if (_lineGap != var)
	{
		_lineGap = var;
		updateLabel();
	}
}

float Label::getLineGap() const
{
	return _lineGap;
}

void Label::setAlignment(TextAlignment var)
{
	if (_alignment != var)
	{
		_alignment = var;
		updateLabel();
	}
}

TextAlignment Label::getAlignment() const
{
	return _alignment;
}

void Label::setText(const char* var)
{
	_textUTF8 = var;
	_text = utf8_get_characters(_textUTF8.c_str());
	updateLabel();
}

const char* Label::getText() const
{
	return _textUTF8.c_str();
}

void Label::setBlendFunc(const BlendFunc& var)
{
	_blendFunc = var;
	for (Sprite* fontChar : _characters)
	{
		if (fontChar)
		{
			fontChar->setBlendFunc(var);
		}
	}
}

const BlendFunc& Label::getBlendFunc() const
{
	return _blendFunc;
}

Sprite* Label::getCharacter(int index) const
{
	if (0 <= index && index < s_cast<int>(_text.size()))
	{
		return _characters[index];
	}
	return nullptr;
}

int Label::getCharacterCount() const
{
	return s_cast<int>(_text.size());
}

float Label::getLetterPosXLeft(Sprite* sp)
{
	return sp->getX() - sp->getAnchorPoint().x;
}

float Label::getLetterPosXRight(Sprite* sp)
{
	return sp->getX() + sp->getAnchorPoint().x;
}

void Label::updateCharacters(const vector<Uint32>& chars)
{
	if (chars.empty()) return;

	float nextFontPositionX = 0;
	float nextFontPositionY = 0;
	Uint32 prev = 0;
	float kerningAmount = 0;
	Size finalSize;
	float longestLine = 0;
	float totalHeight = 0;
	Uint32 quantityOfLines = 1;

	if (_characters.size() > chars.size())
	{
		for (size_t i = chars.size(); i < _characters.size(); i++)
		{
			if (_characters[i])
			{
				_characters[i]->setVisible(false);
			}
		}
	}

	if (_characters.size() < chars.size())
	{
		_characters.resize(chars.size());
	}

	for (Uint32 ch : chars)
	{
		if (ch == '\n')
		{
			quantityOfLines++;
		}
	}

	float commonHeight = _font->getInfo().commonHeight - _font->getInfo().lineGap + _lineGap;
	totalHeight = commonHeight * quantityOfLines;
	nextFontPositionY = 0 - (commonHeight - commonHeight * quantityOfLines);

	const bgfx::GlyphInfo* fontDef = nullptr;
	for (size_t i = 0; i < chars.size(); i++)
	{
		Uint32 ch = chars[i];
		Sprite* fontChar = _characters[i];

		if (ch == '\n')
		{
			nextFontPositionX = 0;
			nextFontPositionY -= commonHeight;
			if (fontChar)
			{
				fontChar->setVisible(false);
			}
			continue;
		}

		kerningAmount = s_cast<float>(SharedFontManager.getKerning(_font->getHandle(), prev, ch));

		fontDef = SharedFontCache.getGlyphInfo(_font, ch);
		if (!fontDef)
		{
			ch = '?';
			fontDef = SharedFontCache.getGlyphInfo(_font, '?');
			if (!fontDef)
			{
				Log("attempted to use character not defined in this font: %d", ch);
				continue;
			}
		}

		if (fontChar)
		{
			SharedFontCache.updateCharacter(fontChar, _font, ch);
			fontChar->setVisible(true);
		}
		else
		{
			fontChar = SharedFontCache.createCharacter(_font, ch);
			fontChar->setBlendFunc(_blendFunc);
			addChild(fontChar);
			_characters[i] = fontChar;
		}

		float yOffset = commonHeight - fontDef->offset_y;
		Vec2 fontPos = Vec2{
			nextFontPositionX + fontDef->offset_x + fontDef->width * 0.5f + kerningAmount,
			nextFontPositionY + yOffset - fontDef->height * 0.5f};
		fontChar->setPosition(fontPos);

		// update kerning
		nextFontPositionX += fontDef->advance_x + kerningAmount;
		prev = ch;
		if (longestLine < nextFontPositionX)
		{
			longestLine = nextFontPositionX;
		}
	}

	if (_textWidth > 0)
	{
		finalSize.width = _textWidth;
	}
	else
	{
		// If the last character processed has an xAdvance which is less that the width of the characters image, then we need
		// to adjust the width of the string to take this into account, or the character will overlap the end of the bounding
		// box
		if (fontDef->advance_x < fontDef->width)
		{
			finalSize.width = longestLine + fontDef->width - fontDef->advance_x;
		}
		else
		{
			finalSize.width = longestLine;
		}
	}
	finalSize.height = totalHeight;
	setSize(finalSize);
}

void Label::updateLabel()
{
	if (_textUTF8.empty())
	{
		return;
	}

	// Step 0: Create characters
	updateCharacters(_text);

	// Step 1: Make multiline
	if (_textWidth >= 0)
	{
		// Step 1: Make multiline
		int stringLength = s_cast<int>(_text.size());
		vector<Uint32> multiline_string;
		multiline_string.reserve(stringLength);
		vector<Uint32> last_word;
		last_word.reserve(stringLength);

		int i = 0;
		bool start_line = false, start_word = false, skiped_one = false;
		float startOfLine = -1, startOfWord = -1;

		for (int j = 0; j < stringLength; j++)
		{
			int justSkipped = 0;
			Sprite* characterSprite;
			while (!(characterSprite = _characters[j + justSkipped]) || !characterSprite->isVisible())
			{
				justSkipped++;
				if (j + justSkipped >= stringLength)
				{
					break;
				}
			}
			j += justSkipped;

			if (i >= stringLength) break;

			Uint32 character = _text[i];

			if (!start_word)
			{
				startOfWord = getLetterPosXLeft(characterSprite);
				start_word = true;
			}
			if (!start_line)
			{
				startOfLine = startOfWord;
				start_line = true;
			}

			// Newline.
			if (character == '\n')
			{
				utf8_trim_ws(last_word);
				for (int n = 0; n < justSkipped; n++)
				{
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
				if (!startOfWord)
				{
					startOfWord = getLetterPosXLeft(characterSprite);
					start_word = true;
				}
				if (!startOfLine)
				{
					startOfLine = startOfWord;
					start_line = true;
				}
			}

			// Whitespace.
			if (utf8_isspace(character))
			{
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
			if (i > 0 && !skiped_one && getLetterPosXRight(characterSprite) - startOfLine > _textWidth)
			{
				if (character <= 255 && std::isalnum(character))
				{
					last_word.push_back(character);
					int found = utf8_find_last_not_alnum(last_word);
					if (found != -1)
					{
						auto begin = last_word.begin();
						auto end = last_word.begin() + found + 1;
						multiline_string.insert(multiline_string.end(),
							begin, end);
						multiline_string.push_back('\n');
						last_word.erase(begin, end);
						startOfWord = getLetterPosXLeft(_characters[i - last_word.size()]);
						start_word = true;
						startOfLine = startOfWord;
						start_line = true;
						i++;
					}
					else
					{
						found = utf8_find_last_not_char(multiline_string, ' ');
						if (found != -1)
						{
							utf8_trim_ws(multiline_string);
						}
						else
						{
							multiline_string.clear();
						}
						if (multiline_string.size() > 0)
						{
							multiline_string.push_back('\n');
						}
						start_line = false;
						startOfLine = -1;
						i++;
					}
				}
				else
				{
					utf8_trim_ws(last_word);

					last_word.push_back('\n');
					multiline_string.insert(multiline_string.end(),
						last_word.begin(), last_word.end());
					last_word.clear();
					start_word = false;
					start_line = false;
					startOfWord = -1;
					startOfLine = -1;

					if (i >= stringLength) break;

					if (!startOfWord)
					{
						startOfWord = getLetterPosXLeft(characterSprite);
						start_word = true;
					}
					if (!startOfLine)
					{
						startOfLine = startOfWord;
						start_line = true;
					}
					j--;
					skiped_one = true;
				}
			}
			else
			{
				skiped_one = false;
				// Character is normal.
				last_word.push_back(character);
				i++;
			}
		}

		multiline_string.insert(multiline_string.end(), last_word.begin(), last_word.end());

		size_t size = multiline_string.size();
		vector<Uint32> str_new(size);
		for (size_t i = 0; i < size; ++i)
		{
			str_new[i] = multiline_string[i];
		}
		updateCharacters(str_new);
		_text = std::move(str_new);
	}

	// Step 2: Make alignment
	if (_alignment != TextAlignment::Left)
	{
		int i = 0;
		int lineNumber = 0;
		vector<Uint32> last_line;
		for (size_t ctr = 0; ctr <= _text.size(); ++ctr)
		{
			if (_text[ctr] == '\n' || _text[ctr] == '\0')
			{
				float lineWidth = 0.0f;
				int line_length = (int)last_line.size();
				// if last line is empty we must just increase lineNumber and work with next line
				if (line_length == 0)
				{
					lineNumber++;
					continue;
				}
				int index = i + line_length - 1 + lineNumber;
				if (index < 0) continue;
				Sprite* lastChar = _characters[index];
				if (lastChar == nullptr) continue;
				lineWidth = lastChar->getX() + lastChar->getWidth() / 2.0f;

				float shift = 0;
				switch (_alignment)
				{
				case TextAlignment::Center:
					shift = getWidth() / 2.0f - lineWidth / 2.0f;
					break;
				case TextAlignment::Right:
					shift = getWidth() - lineWidth;
					break;
				default:
					break;
				}
				if (shift != 0)
				{
					for (int j = 0; j < line_length; j++)
					{
						index = i + j + lineNumber;
						if (index < 0) continue;
						Sprite* characterSprite = _characters[index];
						if (characterSprite)
						{
							characterSprite->setPosition(characterSprite->getPosition() + Vec2{shift, 0.0f});
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

NS_DOROTHY_END
