/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Basic/Content.h"
#include "FileSystem/mkdir.h"
#include "FileSystem/tinydir.h"
#include "Common/Async.h"

#include <fstream>
using std::ofstream;

#if BX_PLATFORM_WINDOWS
#include <Shlobj.h>
#endif // BX_PLATFORM_WINDOWS

#if BX_PLATFORM_ANDROID
#include "Zip/Support/ZipUtils.h"
#include "Basic/AndroidMain.h"
static Dorothy::Own<ZipFile> g_apkFile;
#endif // BX_PLATFORM_ANDROID

static void releaseFileData(void* _ptr, void* _userData)
{
	DORA_UNUSED_PARAM(_userData);
	if (_ptr)
	{
		Uint8* data = r_cast<Uint8*>(_ptr);
		delete [] data;
	}
}

NS_DOROTHY_BEGIN

Content::~Content()
{ }

OwnArray<Uint8> Content::loadFile(String filename)
{
	SharedAsyncThread.FileIO.pause();
	Sint64 size = 0;
	Uint8* data = Content::loadFileUnsafe(filename, size);
	SharedAsyncThread.FileIO.resume();
	return OwnArray<Uint8>(data, s_cast<size_t>(size));
}

const bgfx::Memory* Content::loadFileBX(String filename)
{
	SharedAsyncThread.FileIO.pause();
	Sint64 size = 0;
	Uint8* data = Content::loadFileUnsafe(filename, size);
	SharedAsyncThread.FileIO.resume();
	return bgfx::makeRef(data, (uint32_t)size, releaseFileData);
}

void Content::copyFile(String src, String dst)
{
	SharedAsyncThread.FileIO.pause();
	Content::copyFileUnsafe(src, dst);
	SharedAsyncThread.FileIO.resume();
}

void Content::saveToFile(String filename, String content)
{
	ofstream stream(Content::getFullPath(filename), std::ios::trunc | std::ios::binary);
	stream.write(content.rawData(), content.size());
}

void Content::saveToFile(String filename, Uint8* content, Sint64 size)
{
	ofstream stream(Content::getFullPath(filename), std::ios::trunc | std::ios::binary);
	stream.write(r_cast<char*>(content), s_cast<std::streamsize>(size));
}

bool Content::removeFile(String filename)
{
	string fullpath = Content::getFullPath(filename);
	return ::remove(fullpath.c_str()) == 0 || RMDIR(fullpath.c_str()) == 0;
}

bool Content::createFolder(String path)
{
	const int MAX_PATH_LEN = 256;
	size_t len = path.size();
	if (len > MAX_PATH_LEN - 2)
	{
		return false;
	}
	char pszDir[MAX_PATH_LEN];
	path.copyTo(pszDir);

	if (pszDir[len - 1] != '\\' && pszDir[len - 1] != '/')
	{
		pszDir[len] = '/';
		pszDir[len + 1] = '\0';
	}
	for (size_t i = 0; i < len + 1; i++)
	{
		if (i != 0 && (pszDir[i] == '\\' || pszDir[i] == '/') && pszDir[i - 1] != ':')
		{
			pszDir[i] = '\0';
			// file exist
			struct stat buf;
			int iRet = ::stat(pszDir, &buf);
			if (iRet != 0)
			{
				iRet = MKDIR(pszDir);
				if (iRet != 0)
				{
					return false;
				}
			}
			pszDir[i] = '/';
		}
	}
	return true;
}

const string& Content::getAssetPath() const
{
	return _assetPath;
}

const string& Content::getWritablePath() const
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

string Content::getFullPath(String filename)
{
	AssertIf(filename.empty(), "invalid filename for full path.");

	Slice targetFile = filename;
	if (filename[0] == '.' && (filename[1] == '/' || filename[1] == '\\'))
	{
		targetFile.skip(2);
	}

	if (Content::isAbsolutePath(targetFile))
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
	string fullPath = Content::getFullPathForDirectoryAndFilename(path, file);
	if (!fullPath.empty())
	{
		_fullPathCache[targetFile] = fullPath;
		return fullPath;
	}

	for (const string& searchPath : _searchPaths)
	{
		std::tie(path, file) = splitDirectoryAndFilename(searchPath + targetFile);
		fullPath = Content::getFullPathForDirectoryAndFilename(path, file);
		if (!fullPath.empty())
		{
			_fullPathCache[targetFile] = fullPath;
			return fullPath;
		}
	}

	return targetFile;
}

void Content::addSearchPath(String path)
{
	string searchPath = (Content::isAbsolutePath(path) ? "" : _assetPath) + path;
	if (searchPath.length() > 0 && (searchPath.back() != '/' && searchPath.back() != '\\'))
	{
		searchPath.append("/");
	}
	_searchPaths.push_back(searchPath);
}

void Content::removeSearchPath(String path)
{
	string realPath = (Content::isAbsolutePath(path) ? "" : _assetPath) + path;
	if (realPath.length() > 0 && (realPath.back() != '/' && realPath.back() != '\\'))
	{
		realPath.append("/");
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

void Content::setSearchPaths(const vector<string>& searchPaths)
{
	_searchPaths.clear();
	_fullPathCache.clear();
	for (const string& searchPath : searchPaths)
	{
		Content::addSearchPath(searchPath);
	}
}

void Content::copyFileUnsafe(String src, String dst)
{
	string srcPath = Content::getFullPath(src);
	// Log("copy file from %s", srcPath);
	// Log("copy file to %s", dst);
	if (Content::isFolder(srcPath))
	{
		string dstPath = dst;
		auto folders = Content::getDirEntries(src, true);
		for (const string& folder : folders)
		{
			if (folder != "." && folder != "..")
			{
				// Log("now copy folder %s", folder);
				string dstFolder = dstPath+'/'+folder;
				if (!Content::isFileExist(dstFolder))
				{
					if (!Content::createFolder(dstFolder))
					{
						Log("Create folder failed! %s", dstFolder);
					}
				}
				Content::copyFileUnsafe((srcPath+'/'+folder), dstFolder);
			}
		}
		auto files = Content::getDirEntries(src, false);
		for (const string& file : files)
		{
			// Log("now copy file %s",file);
			ofstream stream((dstPath + '/' + file), std::ios::out | std::ios::trunc | std::ios::binary);
			Content::loadFileByChunks((srcPath + '/' + file), [&](Uint8* buffer, int size)
			{
				if (!stream.write(r_cast<char*>(buffer), size))
				{
					Log("write file failed! %s", dstPath + '/' + file);
				}
			});
		}
	}
	else
	{
		ofstream stream(dst, std::ios::out | std::ios::trunc | std::ios::binary);
		Content::loadFileByChunks(src, [&](Uint8* buffer, int size)
		{
			if (!stream.write(r_cast<char*>(buffer), size))
			{
				Log("write file failed! %s", dst);
			}
		});
	}
}

void Content::loadFileAsyncUnsafe(String filename, const function<void (Uint8*, Sint64)>& callback)
{
	string fileStr = filename;
	SharedAsyncThread.FileIO.run([fileStr, this]()
	{
		Sint64 size = 0;
		Uint8* buffer = this->loadFileUnsafe(fileStr, size);
		return Values::create(buffer, size);
	},
	[callback](Values* result)
	{
		Uint8* buffer;
		Sint64 size;
		result->get(buffer, size);
		callback(buffer,size);
	});
}

void Content::loadFileAsync(String filename, const function<void(String)>& callback)
{
	Content::loadFileAsyncUnsafe(filename, [callback](Uint8* buffer, Sint64 size)
	{
		auto data = MakeOwnArray(buffer, s_cast<size_t>(size));
		callback(Slice(r_cast<char*>(data.get()), data.size()));
	});
}

void Content::loadFileAsyncBX(String filename, const function<void(const bgfx::Memory*)>& callback)
{
	Content::loadFileAsyncUnsafe(filename, [callback](Uint8* buffer, Sint64 size)
	{
		callback(bgfx::makeRef(buffer, s_cast<uint32_t>(size), releaseFileData));
	});
}

void Content::copyFileAsync(String src, String dst, const function<void()>& callback)
{
	string srcFile(src), dstFile(dst);
	SharedAsyncThread.FileIO.run([srcFile,dstFile,this]()
	{
		Content::copyFileUnsafe(srcFile, dstFile);
		return Values::None;
	},
	[callback](Values* result)
	{
		DORA_UNUSED_PARAM(result);
		callback();
	});
}

void Content::saveToFileAsync(String filename, String content, const function<void()>& callback)
{
	string file(filename);
	auto data = new string(content);
	SharedAsyncThread.FileIO.run([file,data,this]()
	{
		Content::saveToFile(file, *MakeOwn(data));
		return Values::None;
	},
	[callback](Values* result)
	{
		DORA_UNUSED_PARAM(result);
		callback();
	});
}

void Content::saveToFileAsync(String filename, OwnArray<Uint8> content, const function<void()>& callback)
{
	string file(filename);
	auto data = new OwnArray<Uint8>(std::move(content));
	SharedAsyncThread.FileIO.run([file,data,this]()
	{
		Content::saveToFile(file, *MakeOwn(data).get(), data->size());
		return Values::None;
	},
	[callback](Values* result)
	{
		DORA_UNUSED_PARAM(result);
		callback();
	});
}

bool Content::isExist(String filename)
{
	return Content::isFileExist(Content::getFullPath(filename));
}

vector<string> Content::getDirEntries(String path, bool isFolder)
{
	string searchName = path.empty() ? _assetPath : path.toString();
	char last = searchName.back();
	if (last == '/' || last == '\\')
	{
		searchName.erase(--searchName.end());
	}
	string fullPath = Content::getFullPath(searchName);
#if BX_PLATFORM_ANDROID
	if (fullPath[0] != '/')
	{
		return g_apkFile->getDirEntries(fullPath, isFolder);
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
		Log("Content get entry error, %s, %s", strerror(errno), fullPath);
	}
	return files;
}

#if BX_PLATFORM_ANDROID
Content::Content()
{
	_assetPath = "assets/";
	g_apkFile = New<ZipFile>(getAndroidAPKPath(), _assetPath);

	char* prefPath = SDL_GetPrefPath(DORA_DEFAULT_ORG_NAME, DORA_DEFAULT_APP_NAME);
	_writablePath = prefPath;
	SDL_free(prefPath);
}

Uint8* Content::loadFileUnsafe(String filename, Sint64& size)
{
	Uint8* data = nullptr;
	if (filename.empty())
	{
		return data;
	}
	string fullPath = Content::getFullPath(filename);
	if (fullPath[0] != '/')
	{
		data = g_apkFile->getFileData(fullPath, r_cast<unsigned long*>(&size));
	}
	else
	{
		BLOCK_START
		{
			FILE* fp = fopen(fullPath.c_str(), "rb");
			BREAK_IF(!fp);
			fseek(fp, 0, SEEK_END);
			unsigned long dataSize = ftell(fp);
			fseek(fp, 0, SEEK_SET);
			data = new unsigned char[dataSize];
			dataSize = fread(data, sizeof(unsigned char), dataSize,fp);
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
		Log("fail to load file: %s", fullPath);
	}
	return data;
}

void Content::loadFileByChunks(String filename, const std::function<void(Uint8*,int)>& handler)
{
	if (filename.empty())
	{
		return;
	}
	string fullPath = Content::getFullPath(filename);
	if (fullPath[0] != '/')
	{
		g_apkFile->getFileDataByChunks(fullPath, handler);
	}
	else
	{
		BLOCK_START
		{
			FILE* file = fopen(fullPath.c_str(), "rb");
			BREAK_IF(!file);
			Uint8 buffer[DORA_COPY_BUFFER_SIZE];
			int size = 0;
			do
			{
				size = (int)fread(buffer, sizeof(Uint8), DORA_COPY_BUFFER_SIZE, file);
				if (size > 0)
				{
					handler(buffer, size);
				}
			}
			while (size > 0);
			fclose(file);
		}
		BLOCK_END
	}
}

bool Content::isFileExist(String strFilePath)
{
	if (strFilePath.empty())
	{
		return false;
	}
	bool found = false;
	// Check whether file exists in apk.
	if (strFilePath[0] != '/')
	{
		string strPath = strFilePath;
		if (strPath.find(_assetPath) != 0)
		{
			// Didn't find "assets/" at the beginning of the path, adding it.
			strPath.insert(0, _assetPath);
		}
		if (g_apkFile->fileExists(strPath))
		{
			found = true;
		}
	}
	else
	{
		FILE* file = fopen(strFilePath.toString().c_str(), "r");
		if (file)
		{
			found = true;
			fclose(file);
		}
	}
	return found;
}

bool Content::isFolder(String path)
{
	return g_apkFile->isFolder(path);
}

bool Content::isAbsolutePath(String strPath)
{
	// On Android, there are two situations for full path.
	// 1) Files in APK, e.g. assets/path/path/file.png
	// 2) Files not in APK, e.g. /data/data/org.cocos2dx.hellocpp/cache/path/path/file.png, or /sdcard/path/path/file.png.
	// So these two situations need to be checked on Android.
	if (strPath[0] == '/' || string(strPath).find(_assetPath) == 0)
	{
		return true;
	}
	return false;
}
#endif // BX_PLATFORM_ANDROID

#if BX_PLATFORM_WINDOWS
Content::Content()
{
	char currentPath[MAX_PATH] = {0};
	GetCurrentDirectory(sizeof(currentPath), currentPath);
	_assetPath = string(currentPath) + "\\";

	char* prefPath = SDL_GetPrefPath(DORA_DEFAULT_ORG_NAME, DORA_DEFAULT_APP_NAME);
	_writablePath = prefPath;
	SDL_free(prefPath);
}

bool Content::isFileExist(String filePath)
{
	string strPath = filePath;
	if (!Content::isAbsolutePath(strPath))
	{
		strPath.insert(0, _assetPath);
	}
	return GetFileAttributesA(strPath.c_str()) != -1 ? true : false;
}

bool Content::isAbsolutePath(String strPath)
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
Content::Content()
{
	char* currentPath = SDL_GetBasePath();
	_assetPath = currentPath;
	SDL_free(currentPath);

	char* prefPath = SDL_GetPrefPath(DORA_DEFAULT_ORG_NAME, DORA_DEFAULT_APP_NAME);
	_writablePath = prefPath;
	SDL_free(prefPath);
}
#endif // BX_PLATFORM_OSX || BX_PLATFORM_IOS

#if BX_PLATFORM_WINDOWS || BX_PLATFORM_OSX || BX_PLATFORM_IOS
Uint8* Content::loadFileUnsafe(String filename, Sint64& size)
{
	if (filename.empty()) return nullptr;
	string fullPath = Content::getFullPath(filename);
	SDL_RWops* io = SDL_RWFromFile(fullPath.c_str(), "rb");
	if (io == nullptr)
	{
		Log("fail to load file: %s", filename);
		return nullptr;
	}
	size = SDL_RWsize(io);
	Uint8* buffer = new Uint8[(size_t)size];
	SDL_RWread(io, buffer, sizeof(Uint8), (size_t)size);
	SDL_RWclose(io);
	return buffer;
}

void Content::loadFileByChunks(String filename, const std::function<void(Uint8*,int)>& handler)
{
	if (filename.empty()) return;
	string fullPath = Content::getFullPath(filename);
	SDL_RWops* io = SDL_RWFromFile(fullPath.c_str(), "rb");
	if (io == nullptr)
	{
		Log("fail to load file: %s", filename);
		return;
	}
	Uint8 buffer[DORA_COPY_BUFFER_SIZE];
	int size = 0;
	while ((size = (int)SDL_RWread(io, buffer, sizeof(Uint8), DORA_COPY_BUFFER_SIZE)))
	{
		handler(buffer, size);
	}
	SDL_RWclose(io);
}

bool Content::isFolder(String path)
{
	struct stat buf;
	if (::stat(path.toString().c_str(), &buf) == 0)
	{
		return (buf.st_mode & S_IFDIR) != 0;
	}
	return false;
}
#endif // BX_PLATFORM_WINDOWS || BX_PLATFORM_OSX || BX_PLATFORM_IOS

#if BX_PLATFORM_WINDOWS || BX_PLATFORM_ANDROID
string Content::getFullPathForDirectoryAndFilename(String directory, String filename)
{
	string fullPath = (Content::isAbsolutePath(directory) ? "" : _assetPath);
	fullPath.append(directory + filename);
	if (!Content::isFileExist(fullPath))
	{
		fullPath.clear();
	}
	return fullPath;
}
#endif // BX_PLATFORM_WINDOWS || BX_PLATFORM_ANDROID

NS_DOROTHY_END
