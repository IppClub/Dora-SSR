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

#include "Drawable.h"
#include "Texture.h"
#include "audio/Source.h"
#include "video/VideoStream.h"

namespace love
{
namespace graphics
{

// Public Love Video object contract. Embedded renderer backends implement
// storage, frame upload and draw submission without importing native GL state.
class Video : public Drawable
{
public:
	static love::Type type;
	virtual ~Video() = default;

	virtual love::video::VideoStream *getStream() = 0;
	virtual love::audio::Source *getSource() = 0;
	virtual void setSource(love::audio::Source *source) = 0;
	virtual int getWidth() const = 0;
	virtual int getHeight() const = 0;
	virtual int getPixelWidth() const = 0;
	virtual int getPixelHeight() const = 0;
	virtual void setFilter(const Texture::Filter &filter) = 0;
	virtual const Texture::Filter &getFilter() const = 0;
};

} // graphics
} // love
