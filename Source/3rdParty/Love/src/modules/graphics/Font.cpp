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

// Altered for Dora: retain LOVE 11.5's Type and alignment enum maps while the
// concrete metrics and filtering operations are state-local backend methods.

#include "Font.h"

namespace love::graphics
{

love::Type Font::type("Font", &Object::type);

StringMap<Font::AlignMode, Font::ALIGN_MAX_ENUM>::Entry Font::alignModeEntries[] = {
	{"left", ALIGN_LEFT},
	{"center", ALIGN_CENTER},
	{"right", ALIGN_RIGHT},
	{"justify", ALIGN_JUSTIFY},
};

StringMap<Font::AlignMode, Font::ALIGN_MAX_ENUM> Font::alignModes(
	Font::alignModeEntries, sizeof(Font::alignModeEntries));

bool Font::getConstant(const char *in, AlignMode &out)
{
	return alignModes.find(in, out);
}

bool Font::getConstant(AlignMode in, const char *&out)
{
	return alignModes.find(in, out);
}

std::vector<std::string> Font::getConstants(AlignMode)
{
	return alignModes.getNames();
}

} // namespace love::graphics
