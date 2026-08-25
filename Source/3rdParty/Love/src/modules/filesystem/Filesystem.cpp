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

// LOVE
#include "Filesystem.h"

namespace love
{
namespace filesystem
{

love::Type Filesystem::type("filesystem", &Module::type);

Filesystem::Filesystem()
{
}

Filesystem::~Filesystem()
{
}

void Filesystem::setAndroidSaveExternal(bool useExternal)
{	
	this->useExternal = useExternal;
}

bool Filesystem::isAndroidSaveExternal() const
{ 
	return useExternal;
}

FileData *Filesystem::newFileData(const void *data, size_t size, const char *filename) const
{
	FileData *fd = new FileData(size, std::string(filename));
	memcpy(fd->getData(), data, size);
	return fd;
}

bool Filesystem::isRealDirectory(const std::string &path) const
{
	(void) path;
	return false;
}

std::string Filesystem::getExecutablePath() const
{
	return {};
}

bool Filesystem::getConstant(const char *in, FileType &out)
{
	return fileTypes.find(in, out);
}

bool Filesystem::getConstant(FileType in, const char *&out)
{
	return fileTypes.find(in, out);
}

std::vector<std::string> Filesystem::getConstants(FileType)
{
	return fileTypes.getNames();
}

StringMap<Filesystem::FileType, Filesystem::FILETYPE_MAX_ENUM>::Entry Filesystem::fileTypeEntries[] =
{
	{ "file",      FILETYPE_FILE      },
	{ "directory", FILETYPE_DIRECTORY },
	{ "symlink",   FILETYPE_SYMLINK   },
	{ "other",     FILETYPE_OTHER     },
};

StringMap<Filesystem::FileType, Filesystem::FILETYPE_MAX_ENUM> Filesystem::fileTypes(Filesystem::fileTypeEntries, sizeof(Filesystem::fileTypeEntries));

} // filesystem
} // love
