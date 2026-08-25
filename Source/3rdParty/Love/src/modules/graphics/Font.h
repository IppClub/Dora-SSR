/**
 * Copyright (c) 2006-2023 LOVE Development Team
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 **/

#pragma once

// Altered for Dora: this is LOVE 11.5's public Font contract without the
// native glyph-atlas and renderer storage. Dora implements it over the owning
// LoveRuntime's state-local font backend.

#include "common/Color.h"
#include "common/Object.h"
#include "common/StringMap.h"
#include "Texture.h"

#include <string>
#include <vector>

namespace love::graphics
{

class Font : public Object
{
public:
	static love::Type type;

	enum AlignMode
	{
		ALIGN_LEFT,
		ALIGN_CENTER,
		ALIGN_RIGHT,
		ALIGN_JUSTIFY,
		ALIGN_MAX_ENUM
	};

	struct ColoredString
	{
		std::string str;
		Colorf color;
	};

	virtual ~Font() = default;

	virtual float getHeight() const = 0;
	virtual int getWidth(const std::string &str) = 0;
	virtual int getWidth(uint32 glyph) = 0;
	virtual void getWrap(const std::vector<ColoredString> &text, float wraplimit,
		std::vector<std::string> &lines, std::vector<int> *lineWidths = nullptr) = 0;
	virtual void setLineHeight(float height) = 0;
	virtual float getLineHeight() const = 0;
	virtual void setFilter(const Texture::Filter &filter) = 0;
	virtual const Texture::Filter &getFilter() const = 0;
	virtual float getAscent() const = 0;
	virtual float getDescent() const = 0;
	virtual float getBaseline() const = 0;
	virtual bool hasGlyph(uint32 glyph) const = 0;
	virtual bool hasGlyphs(const std::string &text) const = 0;
	virtual float getKerning(uint32 leftGlyph, uint32 rightGlyph) = 0;
	virtual float getKerning(const std::string &leftCharacter,
		const std::string &rightCharacter) = 0;
	virtual void setFallbacks(const std::vector<Font *> &fallbacks) = 0;
	virtual float getDPIScale() const = 0;

	static bool getConstant(const char *in, AlignMode &out);
	static bool getConstant(AlignMode in, const char *&out);
	static std::vector<std::string> getConstants(AlignMode);

private:
	static StringMap<AlignMode, ALIGN_MAX_ENUM>::Entry alignModeEntries[];
	static StringMap<AlignMode, ALIGN_MAX_ENUM> alignModes;
};

} // namespace love::graphics
