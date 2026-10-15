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

// Altered for Dora: retain LOVE 11.5's public Text contract and Drawable Type
// while the concrete layout cache and renderer submission are state-local.

#include "Drawable.h"
#include "Font.h"

namespace love::graphics
{

class Text : public Drawable
{
public:
	static love::Type type;
	virtual ~Text() = default;

	virtual void set(const std::vector<Font::ColoredString> &text) = 0;
	virtual void set(const std::vector<Font::ColoredString> &text, float wrap,
		Font::AlignMode align) = 0;
	virtual int add(const std::vector<Font::ColoredString> &text,
		const Matrix4 &transform) = 0;
	virtual int addf(const std::vector<Font::ColoredString> &text, float wrap,
		Font::AlignMode align, const Matrix4 &transform) = 0;
	virtual void clear() = 0;
	virtual void setFont(Font *font) = 0;
	virtual Font *getFont() const = 0;
	virtual int getWidth(int index = 0) const = 0;
	virtual int getHeight(int index = 0) const = 0;
};

} // namespace love::graphics
