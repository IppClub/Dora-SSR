/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
#include "Const/oHeader.h"
#include "Basic/oContent.h"
#include "FileSystem/mkdir.h"
#include "FileSystem/tinydir.h"
#include <fstream>
using std::ofstream;

#if BX_PLATFORM_WINDOWS
#include <Shlobj.h>
#endif // BX_PLATFORM_WINDOWS

#if BX_PLATFORM_ANDROID
#include "Zip/Support/ZipUtils.h"
#include "Basic/AndroidMain.h"
static Dorothy::oOwn<ZipFile> g_zipFile;
#endif // BX_PLATFORM_ANDROID

NS_DOROTHY_BEGIN

oContent::~oContent()
{ }

oOwnArray<Uint8> oContent::loadFile(oSlice filename, Sint64& size)
{
	return oOwnArray<Uint8>(oContent::loadFileUnsafe(filename,size));
}

void oContent::copyFile(oSlice src, oSlice dst)
{
	string srcPath = oContent::getFullPath(src);
	//CCLOG("copy file from %s",srcPath);
	//CCLOG("copy file to %s",dst);
	if (oContent::isFolder(srcPath))
	{
		string dstPath = dst;
		auto folders = oContent::getDirEntries(src, true);
		for (const string& folder : folders)
		{
			if (folder != "." && folder != "..")
			{
				//CCLOG("now copy folder %s",folder);
				string dstFolder = dstPath+'/'+folder;
				if (!oContent::isFileExist(dstFolder))
				{
					if (!oContent::createFolder(dstFolder))
					{
						oLog("Create folder failed! %s", dstFolder);
					}
				}
				oContent::copyFile((srcPath+'/'+folder), dstFolder);
			}
		}
		auto files = oContent::getDirEntries(src, false);
		for (const string& file : files)
		{
			Sint64 size;
			//CCLOG("now copy file %s",file);
			auto buffer = oContent::loadFile((srcPath + '/' + file), size);
			ofstream stream((dstPath + '/' + file), std::ios::out | std::ios::trunc | std::ios::binary);
			if (!stream.write((char*)buffer.get(), size))
			{
				oLog("write file failed! %s", dstPath + '/' + file);
			}
		}
	}
	else
	{
		Sint64 size;
		auto buffer = oContent::loadFile(src, size);
		ofstream stream(dst, std::ios::out | std::ios::trunc | std::ios::binary);
		stream.write((char*)buffer.get(), size);
	}
}

bool oContent::removeFile(oSlice filename)
{
	string fullpath = oContent::getFullPath(filename);
	return ::remove(fullpath.c_str()) == 0 || RMDIR(fullpath.c_str()) == 0;
}

void oContent::saveToFile(oSlice filename, oSlice content)
{
	ofstream stream(oContent::getFullPath(filename), std::ios::trunc);
	stream.write(content.c_str(), content.size());
}

bool oContent::createFolder(oSlice path)
{
	return CreateDir(path.c_str(), path.size()) == 0;
}

const string& oContent::getWritablePath() const
{
	return _writablePath;
}

static tuple<string,string> splitDirectoryAndFilename(const string& filePath)
{
	string file = filePath;
	string path;
	size_t pos = filePath.find_last_of("/\\");
	if (pos != std::string::npos)
	{
		path = filePath.substr(0, pos + 1);
		file = filePath.substr(pos + 1);
	}
	return std::make_tuple(path, file);
}

string oContent::getFullPath(oSlice filename)
{
	oAssertIf(filename.empty(), "Invalid filename for full path");

	Slice targetFile = filename;
	if (filename[0] == '.' && (filename[1] == '/' || filename[1] == '\\'))
	{
		targetFile.skip(2);
	}

	if (oContent::isAbsolutePath(targetFile))
	{
		return targetFile;
	}

	auto it  = _fullPathCache.find(targetFile);
	if (it != _fullPathCache.end())
	{
		return it->second;
	}

	string path, file;
	std::tie(path, file) = splitDirectoryAndFilename(targetFile);
	string fullPath = oContent::getFullPathForDirectoryAndFilename(path, file);
	if (!fullPath.empty())
	{
		_fullPathCache[targetFile] = fullPath;
		return fullPath;
	}

	for (const string& searchPath : _searchPaths)
	{
		std::tie(path, file) = splitDirectoryAndFilename(searchPath + targetFile);
		fullPath = oContent::getFullPathForDirectoryAndFilename(path, file);
		if (!fullPath.empty())
		{
			_fullPathCache[targetFile] = fullPath;
			return fullPath;
		}
	}

	return targetFile;
}

void oContent::addSearchPath(oSlice path)
{
	string searchPath = (oContent::isAbsolutePath(path) ? "" : _currentPath) + path;
	if (searchPath.length() > 0 && (searchPath.back() != '/' && searchPath.back() != '\\'))
	{
		searchPath += "/";
	}
	_searchPaths.push_back(searchPath);
}

void oContent::removeSearchPath(oSlice path)
{
	string realPath = (oContent::isAbsolutePath(path) ? "" : _currentPath) + path;
	if (realPath.length() > 0 && (realPath.back() != '/' && realPath.back() != '\\'))
	{
		realPath += "/";
	}
	for (auto it = _searchPaths.begin(); it != _searchPaths.end(); ++it)
	{
		if (*it == realPath)
		{
			_searchPaths.erase(it);
			_fullPathCache.clear();
			break;
		}
	}
}

void oContent::setSearchPaths(const vector<string>& searchPaths)
{
	_searchPaths.clear();
	_fullPathCache.clear();
	for (const string& searchPath : searchPaths)
	{
		oContent::addSearchPath(searchPath);
	}
}

vector<string> oContent::getDirEntries(oSlice path, bool isFolder)
{
	string searchName = path.empty() ? _currentPath : path.toString();
	char last = searchName.back();
	if (last == '/' || last == '\\')
	{
		searchName.erase(--searchName.end());
	}
	string fullPath = oContent::getFullPath(searchName);
#if BX_PLATFORM_ANDROID
	if (fullPath[0] != '/')
	{
		return g_zipFile->getDirEntries(fullPath, isFolder);
	}
#endif // BX_PLATFORM_ANDROID
	vector<string> files;
	tinydir_dir dir;
	int ret = tinydir_open(&dir, fullPath.c_str());
	if (ret == 0)
	{
		while (dir.has_next)
		{
			tinydir_file file;
			tinydir_readfile(&dir, &file);
			if ((file.is_dir != 0) == isFolder)
			{
				files.push_back(file.name);
			}
			tinydir_next(&dir);
		}
		tinydir_close(&dir);
	}
	else
	{
		oLog("oContent get entry error, %s, %s", strerror(errno), fullPath);
	}
	return files;
}

#if BX_PLATFORM_ANDROID
oContent::oContent()
{
	_currentPath = "assets/";
	g_zipFile = oOwnNew<ZipFile>(getAndroidAPKPath(), _currentPath);

	char* prefPath = SDL_GetPrefPath(DORA_DEFAULT_ORG_NAME, DORA_DEFAULT_APP_NAME);
	_writablePath = prefPath;
	SDL_free(prefPath);
}

Uint8* oContent::loadFileUnsafe(oSlice filename, Sint64& size)
{
	Uint8* data = nullptr;
	if (filename.empty())
	{
		return data;
	}
	string fullPath = oContent::getFullPath(filename);
	if (fullPath[0] != '/')
	{
		data = g_zipFile->getFileData(fullPath, (unsigned long*)&size);
	}
	else
	{
		BLOCK_START
		{
			FILE* fp = fopen(fullPath.c_str(), "rb");
			BREAK_IF(!fp);
			fseek(fp,0,SEEK_END);
			unsigned long dataSize = ftell(fp);
			fseek(fp,0,SEEK_SET);
			data = new unsigned char[dataSize];
			dataSize = fread(data,sizeof(unsigned char), dataSize,fp);
			fclose(fp);
			if (dataSize)
			{
				size = dataSize;
			}
		}
		BLOCK_END
	}
	if (!data)
	{
		oLog("fail to load file: %s", fullPath);
	}
	return data;
}

bool oContent::isFileExist(oSlice strFilePath)
{
	bool found = false;

	// Check whether file exists in apk.
	if (strFilePath[0] != '/')
	{
		std::string strPath = strFilePath;
		if (strPath.find(_currentPath) != 0)
		{
			// Didn't find "assets/" at the beginning of the path, adding it.
			strPath.insert(0, _currentPath);
		}

		if (g_zipFile->fileExists(strPath))
		{
			found = true;
		}
	}
	else
	{
		FILE* fp = fopen(strFilePath.c_str(), "r");
		if (fp)
		{
			found = true;
			fclose(fp);
		}
	}
	return found;
}

bool oContent::isFolder(oSlice path)
{
	return g_zipFile->isFolder(path);
}

bool oContent::isAbsolutePath(oSlice strPath)
{
	// On Android, there are two situations for full path.
	// 1) Files in APK, e.g. assets/path/path/file.png
	// 2) Files not in APK, e.g. /data/data/org.cocos2dx.hellocpp/cache/path/path/file.png, or /sdcard/path/path/file.png.
	// So these two situations need to be checked on Android.
	if (strPath[0] == '/' || string(strPath).find(_currentPath) == 0)
	{
		return true;
	}
	return false;
}
#endif // BX_PLATFORM_ANDROID

#if BX_PLATFORM_WINDOWS
oContent::oContent()
{
	char currentPath[MAX_PATH] = {0};
	GetCurrentDirectory(sizeof(currentPath), currentPath);
	_currentPath = string(currentPath) + "\\";

	char* prefPath = SDL_GetPrefPath(DORA_DEFAULT_ORG_NAME, DORA_DEFAULT_APP_NAME);
	_writablePath = prefPath;
	SDL_free(prefPath);
}

bool oContent::isFileExist(oSlice filePath)
{
	string strPath = filePath;
	if (!oContent::isAbsolutePath(strPath))
	{
		strPath.insert(0, _currentPath);
	}
	return GetFileAttributesA(strPath.c_str()) != -1 ? true : false;
}

bool oContent::isAbsolutePath(oSlice strPath)
{
	if (strPath.size() > 2
		&& ((strPath[0] >= 'a' && strPath[0] <= 'z') || (strPath[0] >= 'A' && strPath[0] <= 'Z'))
		&& strPath[1] == ':')
	{
		return true;
	}
	return false;
}
#endif // BX_PLATFORM_WINDOWS

#if BX_PLATFORM_OSX || BX_PLATFORM_IOS
oContent::oContent()
{
	char* currentPath = SDL_GetBasePath();
	_currentPath = currentPath;
	SDL_free(currentPath);

	char* prefPath = SDL_GetPrefPath(DORA_DEFAULT_ORG_NAME, DORA_DEFAULT_APP_NAME);
	_writablePath = prefPath;
	SDL_free(prefPath);
}
#endif // BX_PLATFORM_OSX || BX_PLATFORM_IOS

#if BX_PLATFORM_WINDOWS || BX_PLATFORM_OSX || BX_PLATFORM_IOS
Uint8* oContent::loadFileUnsafe(oSlice filename, Sint64& size)
{
	if (filename.empty()) return nullptr;
	string fullPath = oContent::getFullPath(filename);
	SDL_RWops* io = SDL_RWFromFile(fullPath.c_str(), "rb");
	if (io == nullptr)
	{
		oLog("fail to load file: %s", filename);
		return nullptr;
	}
	size = io->size(io);
	Uint8* buffer = new Uint8[(size_t)size];
	io->read(io, buffer, sizeof(Uint8), (size_t)size);
	return buffer;
}

bool oContent::isFolder(oSlice path)
{
	struct stat buf;
	if (::stat(path.c_str(), &buf) == 0)
	{
		return (buf.st_mode & S_IFDIR) != 0;
	}
	return false;
}
#endif // BX_PLATFORM_WINDOWS || BX_PLATFORM_OSX || BX_PLATFORM_IOS

#if BX_PLATFORM_WINDOWS || BX_PLATFORM_ANDROID
string oContent::getFullPathForDirectoryAndFilename(oSlice directory, oSlice filename)
{
	string fullPath = (oContent::isAbsolutePath(directory) ? "" : _currentPath);
	fullPath.append(directory + filename);
	if (!oContent::isFileExist(fullPath))
	{
		fullPath.clear();
	}
	return fullPath;
}
#endif // BX_PLATFORM_WINDOWS || BX_PLATFORM_ANDROID

NS_DOROTHY_END
