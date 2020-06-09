/****************************************************************************
Copyright (c) 2010 cocos2d-x.org

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

#include <list>
#include <string>
#include <functional>

// forward declaration
class ZipFilePrivate;

/**
* Zip file - reader helper class.
*
* It will cache the file list of a particular zip file with positions inside an archive,
* so it would be much faster to read some particular files or to check their existance.
*
* @since v2.0.5
*/
class ZipFile
{
public:
	/**
	* Constructor, open zip file and store file list.
	*
	* @param zipFile Zip file name
	* @param filter The first part of file names, which should be accessible.
	*               For example, "assets/". Other files will be missed.
	*
	* @since v2.0.5
	*/
	ZipFile(const std::string& zipFile, const std::string& filter = "");
	virtual ~ZipFile();

	/**
	* Regenerate accessible file list based on a new filter string.
	*
	* @param filter New filter string (first part of files names)
	* @return true whenever zip file is open successfully and it is possible to locate
	*              at least the first file, false otherwise
	*
	* @since v2.0.5
	*/
	bool setFilter(const std::string& filter);

	/**
	* Check does a file exists or not in zip file
	*
	* @param fileName File to be checked on existance
	* @return true whenever file exists, false otherwise
	*
	* @since v2.0.5
	*/
	bool fileExists(const std::string& fileName) const;
	bool isFolder(const std::string& path) const;
	/**
	* Get resource file data from a zip file.
	* @param fileName File name
	* @param[out] pSize If the file read operation succeeds, it will be the data size, otherwise 0.
	* @return Upon success, a pointer to the data is returned, otherwise NULL.
	* @warning Recall: you are responsible for calling delete[] on any Non-NULL pointer returned.
	*
	* @since v2.0.5
	*/
	uint8_t* getFileData(const std::string&, unsigned long* size);

	void getFileDataByChunks(const std::string& fileName, const std::function<void(unsigned char*,int)>& handler);

	std::list<std::string> getDirEntries(const std::string& path, bool isFolder);
	std::list<std::string> getAllFiles(const std::string& path);
private:
	/** Internal data like zip file pointer / file list array and so on */
	ZipFilePrivate* m_data;
};
