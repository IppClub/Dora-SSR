/****************************************************************************
Copyright (c) 2010 cocos2d-x.org, modified by Li Jin, 2021

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
#pragma once

#include <functional>
#include <list>
#include <string>

#include "Common/Own.h"

// forward declaration
class ZipFilePrivate;

/**
 * Zip file - reader helper class.
 *
 * It will cache the file list of a particular zip file with positions inside an archive,
 * so it would be much faster to read some particular files or to check their existance.
 */
class ZipFile {
public:
	/**
	 * Constructor, open zip file and store file list.
	 *
	 * @param zipFile Zip file name
	 * @param filter The first part of file names, which should be accessible.
	 *               For example, "assets/". Other files will be missed.
	 */
	ZipFile(const std::string& zipFile, const std::string& filter = Slice::Empty);
	ZipFile(std::pair<Dora::OwnArray<uint8_t>, size_t>&& data, const std::string& filter = Slice::Empty);
	virtual ~ZipFile();

	/**
	 * Regenerate accessible file list based on a new filter string.
	 *
	 * @param filter New filter string (first part of files names)
	 * @return true whenever zip file is open successfully and it is possible to locate
	 *              at least the first file, false otherwise
	 */
	bool setFilter(const std::string& filter);

	/**
	 * Check does a file exists or not in zip file
	 *
	 * @param fileName File to be checked on existance
	 * @return true whenever file exists, false otherwise
	 */
	bool fileExists(const std::string& fileName) const;

	bool isFolder(const std::string& path) const;

	bool isOK() const;

	/**
	 * Get resource file data from a zip file.
	 * @param fileName File name
	 * @param[out] size If the file read operation succeeds, it will be the data size, otherwise 0.
	 * @return Upon success, a pointer to the data is returned, otherwise NULL.
	 * @warning Recall: you are responsible for calling delete[] on any Non-NULL pointer returned.
	 */
	uint8_t* getFileDataUnsafe(const std::string& filename, size_t* size);

	std::pair<Dora::OwnArray<uint8_t>, size_t> getFileData(const std::string& filename);

	bool getFileDataByChunks(const std::string& fileName, const std::function<bool(unsigned char*, int)>& handler);

	std::list<std::string> getDirEntries(const std::string& path, bool isFolder);
	std::list<std::string> getAllFiles(const std::string& path = Slice::Empty);

private:
	/* Internal data like zip file pointer / file list array and so on */
	Dora::Own<ZipFilePrivate> _file;

	/* In memory zip file data */
	std::pair<Dora::OwnArray<uint8_t>, size_t> _data;
};
