/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Basic/Content.h"
#include "Basic/Application.h"
#include "Common/Async.h"
#ifdef DORA_FILESYSTEM_ALTER
#include "ghc/fs_impl.hpp"
#include "ghc/fs_fwd.hpp"
namespace fs = ghc::filesystem;
#else
#include <filesystem>
namespace fs = std::filesystem;
#endif // DORA_FILESYSTEM_ALTER
#include <fstream>
using std::ofstream;

#if BX_PLATFORM_ANDROID
#include "Zip/Support/ZipUtils.h"
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

std::pair<OwnArray<Uint8>,size_t> Content::load(String filename)
{
	SharedAsyncThread.FileIO.pause();
	Sint64 size = 0;
	Uint8* data = Content::_loadFileUnsafe(filename, size);
	SharedAsyncThread.FileIO.resume();
	return {OwnArray<Uint8>(data), s_cast<size_t>(size)};
}

const bgfx::Memory* Content::loadBX(String filename)
{
	SharedAsyncThread.FileIO.pause();
	Sint64 size = 0;
	Uint8* data = Content::_loadFileUnsafe(filename, size);
	SharedAsyncThread.FileIO.resume();
	return bgfx::makeRef(data, (uint32_t)size, releaseFileData);
}

void Content::copy(String src, String dst)
{
	SharedAsyncThread.FileIO.pause();
	Content::copyUnsafe(src, dst);
	SharedAsyncThread.FileIO.resume();
}

void Content::save(String filename, String content)
{
	ofstream stream(Content::getFullPath(filename), std::ios::trunc | std::ios::binary);
	stream.write(content.rawData(), content.size());
}

void Content::save(String filename, Uint8* content, Sint64 size)
{
	ofstream stream(Content::getFullPath(filename), std::ios::trunc | std::ios::binary);
	stream.write(r_cast<char*>(content), s_cast<std::streamsize>(size));
}

bool Content::remove(String filename)
{
	std::string fullpath = Content::getFullPath(filename);
	return fs::remove_all(fullpath) > 0;
}

bool Content::createFolder(String folder)
{
	fs::path path = folder.toString();
	return fs::create_directories(path);
}

std::list<std::string> Content::getDirs(String path)
{
	return Content::getDirEntries(path, true);
}

std::list<std::string> Content::getFiles(String path)
{
	return Content::getDirEntries(path, false);
}

std::list<std::string> Content::getAllFiles(String path)
{
	std::string searchName = path.empty() ? _assetPath : path.toString();
	std::string fullPath = Content::getFullPath(searchName);
#if BX_PLATFORM_ANDROID
	if (fullPath[0] != '/')
	{
		return g_apkFile->getAllFiles(fullPath);
	}
#endif // BX_PLATFORM_ANDROID
	std::list<std::string> files;
	if (Content::isFileExist(fullPath))
	{
		fs::path parentPath = fullPath;
		for (const auto& item : fs::recursive_directory_iterator(parentPath))
		{
			if (!item.is_directory())
			{
				files.push_back(item.path().lexically_relative(parentPath).string());
			}
		}
	}
	else
	{
		Error("Content failed to get entry of \"{}\"", fullPath);
	}
	return files;
}

bool Content::visitDir(String path, const std::function<bool(String,String)>& func)
{
	std::function<bool(String)> visit;
	visit = [&visit,&func,this](String path)
	{
		auto files = getFiles(path);
		for (const auto& file : files)
		{
			if (func(file, path)) return true;
		}
		auto dirs = getDirs(path);
		auto parent = fs::path(path.begin(), path.end());
		for (const auto& dir : dirs)
		{
			if (visit((parent / dir).string())) return true;
		}
		return false;
	};
	return visit(path);
}

const std::string& Content::getAssetPath() const
{
	return _assetPath;
}

const std::string& Content::getWritablePath() const
{
	return _writablePath;
}

static std::tuple<std::string,std::string> splitDirectoryAndFilename(const std::string& filePath)
{
	std::string file = filePath;
	std::string path;
	size_t pos = filePath.find_last_of("/\\");
	if (pos != std::string::npos)
	{
		path = filePath.substr(0, pos + 1);
		file = filePath.substr(pos + 1);
	}
	return std::make_tuple(path, file);
}

std::string Content::getFullPath(String filename)
{
	AssertIf(filename.empty(), "invalid filename for full path.");

	Slice targetFile = filename;
	targetFile.trimSpace();

	while (targetFile.size() > 1 &&
		(targetFile.back() == '\\' || targetFile.back() == '/'))
	{
		targetFile.skipRight(1);
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

	std::string path, file, fullPath;
	auto fname = fs::path(targetFile.begin(), targetFile.end()).lexically_normal();
	for (const auto& searchPath : _searchPaths)
	{
		std::tie(path, file) = splitDirectoryAndFilename((fs::path(searchPath) / fname).string());
		fullPath = Content::getFullPathForDirectoryAndFilename(path, file);
		if (!fullPath.empty())
		{
			_fullPathCache[fname.string()] = fullPath;
			return fullPath;
		}
	}

	std::tie(path, file) = splitDirectoryAndFilename(targetFile);
	fullPath = Content::getFullPathForDirectoryAndFilename(path, file);
	if (!fullPath.empty())
	{
		_fullPathCache[targetFile] = fullPath;
		return fullPath;
	}

	return targetFile;
}

void Content::insertSearchPath(int index, String path)
{
	std::string searchPath = Content::getFullPath(path);
	_searchPaths.insert(_searchPaths.begin() + index, searchPath);
	_fullPathCache.clear();
}

void Content::addSearchPath(String path)
{
	std::string searchPath = Content::getFullPath(path);
	_searchPaths.push_back(searchPath);
}

void Content::removeSearchPath(String path)
{
	std::string realPath = Content::getFullPath(path);
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

void Content::setSearchPaths(const std::vector<std::string>& searchPaths)
{
	_searchPaths.clear();
	_fullPathCache.clear();
	for (const std::string& searchPath : searchPaths)
	{
		Content::addSearchPath(searchPath);
	}
}

const std::vector<std::string>& Content::getSearchPaths() const
{
	return _searchPaths;
}

void Content::copyUnsafe(String src, String dst)
{
	std::string srcPath = Content::getFullPath(src);
	// Info("copy file from {}", srcPath);
	// Info("copy file to {}", dst);
	if (Content::isPathFolder(srcPath))
	{
		std::string dstPath = dst;
		auto folders = Content::getDirEntries(src, true);
		for (const std::string& folder : folders)
		{
			std::string dstFolder = (fs::path(dstPath) / folder).string();
			if (!Content::isFileExist(dstFolder))
			{
				if (!Content::createFolder(dstFolder))
				{
					Error("Create folder failed! {}", dstFolder);
				}
			}
			std::string srcFolder = (fs::path(srcPath) / folder).string();
			Content::copyUnsafe(srcFolder, dstFolder);
		}
		auto files = Content::getDirEntries(src, false);
		for (const std::string& file : files)
		{
			// Info("now copy file {}",file);
			ofstream stream(fs::path(dstPath) / file, std::ios::out | std::ios::trunc | std::ios::binary);
			Content::loadByChunks((fs::path(srcPath) / file).string(), [&](Uint8* buffer, int size)
			{
				if (!stream.write(r_cast<char*>(buffer), size))
				{
					Error("write file failed! {}", (fs::path(dstPath) / file).string());
				}
			});
		}
	}
	else
	{
		ofstream stream(dst, std::ios::out | std::ios::trunc | std::ios::binary);
		Content::loadByChunks(src, [&](Uint8* buffer, int size)
		{
			if (!stream.write(r_cast<char*>(buffer), size))
			{
				Error("write file failed! {}", dst);
			}
		});
	}
}

void Content::loadAsyncUnsafe(String filename, const std::function<void (Uint8*, Sint64)>& callback)
{
	std::string fileStr = filename;
	SharedAsyncThread.FileIO.run([fileStr, this]()
	{
		Sint64 size = 0;
		Uint8* buffer = this->_loadFileUnsafe(fileStr, size);
		return Values::alloc(buffer, size);
	},
	[callback](Own<Values> result)
	{
		Uint8* buffer;
		Sint64 size;
		result->get(buffer, size);
		callback(buffer,size);
	});
}

void Content::loadAsync(String filename, const std::function<void(String)>& callback)
{
	Content::loadAsyncUnsafe(filename, [callback](Uint8* buffer, Sint64 size)
	{
		auto data = MakeOwnArray(buffer);
		callback(Slice(r_cast<char*>(data.get()), s_cast<size_t>(size)));
	});
}

void Content::loadAsyncData(String filename, const std::function<void(OwnArray<Uint8>&&,size_t)>& callback)
{
	Content::loadAsyncUnsafe(filename, [callback](Uint8* buffer, Sint64 size)
	{
		callback(MakeOwnArray(buffer), s_cast<size_t>(size));
	});
}


void Content::loadAsyncBX(String filename, const std::function<void(const bgfx::Memory*)>& callback)
{
	Content::loadAsyncUnsafe(filename, [callback](Uint8* buffer, Sint64 size)
	{
		callback(bgfx::makeRef(buffer, s_cast<uint32_t>(size), releaseFileData));
	});
}

void Content::copyAsync(String src, String dst, const std::function<void()>& callback)
{
	std::string srcFile(src), dstFile(dst);
	SharedAsyncThread.FileIO.run([srcFile,dstFile,this]()
	{
		Content::copyUnsafe(srcFile, dstFile);
		return nullptr;
	},
	[callback](Own<Values> result)
	{
		DORA_UNUSED_PARAM(result);
		callback();
	});
}

void Content::saveAsync(String filename, String content, const std::function<void()>& callback)
{
	std::string file(filename);
	auto data = std::make_shared<std::string>(content);
	SharedAsyncThread.FileIO.run([file,data,this]()
	{
		Content::save(file, *data);
		return nullptr;
	},
	[callback](Own<Values> result)
	{
		DORA_UNUSED_PARAM(result);
		callback();
	});
}

void Content::saveAsync(String filename, OwnArray<Uint8> content, size_t size, const std::function<void()>& callback)
{
	std::string file(filename);
	auto data = std::make_shared<OwnArray<Uint8>>(std::move(content));
	SharedAsyncThread.FileIO.run([file,data,size,this]()
	{
		Content::save(file, Slice(r_cast<char*>((*data).get()), size));
		return nullptr;
	},
	[callback](Own<Values> result)
	{
		DORA_UNUSED_PARAM(result);
		callback();
	});
}

bool Content::exist(String filename)
{
	return Content::isFileExist(Content::getFullPath(filename));
}

bool Content::isFolder(String path)
{
	return Content::isPathFolder(Content::getFullPath(path));
}

std::list<std::string> Content::getDirEntries(String path, bool isFolder)
{
	std::string searchName = path.empty() ? _assetPath : path.toString();
	std::string fullPath = Content::getFullPath(searchName);
#if BX_PLATFORM_ANDROID
	if (fullPath[0] != '/')
	{
		return g_apkFile->getDirEntries(fullPath, isFolder);
	}
#endif // BX_PLATFORM_ANDROID
	std::list<std::string> files;
	if (Content::isFileExist(fullPath))
	{
		fs::path parentPath = fullPath;
		for (const auto& item : fs::directory_iterator(parentPath))
		{
			if (isFolder == item.is_directory())
			{
				files.push_back(item.path().lexically_relative(parentPath).string());
			}
		}
	}
	else
	{
		Error("Content failed to get entry of \"{}\"", fullPath);
	}
	return files;
}

Uint8* Content::loadUnsafe(String filename, Sint64& size)
{
	SharedAsyncThread.FileIO.pause();
	Uint8* data = Content::_loadFileUnsafe(filename, size);
	SharedAsyncThread.FileIO.resume();
	return data;
}

#if BX_PLATFORM_ANDROID
Content::Content()
{
	_assetPath = "assets/";
	g_apkFile = New<ZipFile>(SharedApplication.getAPKPath(), _assetPath);

	char* prefPath = SDL_GetPrefPath(DORA_DEFAULT_ORG_NAME, DORA_DEFAULT_APP_NAME);
	_writablePath = prefPath;
	SDL_free(prefPath);
}

Uint8* Content::_loadFileUnsafe(String filename, Sint64& size)
{
	Uint8* data = nullptr;
	if (filename.empty())
	{
		return data;
	}
	std::string fullPath = Content::getFullPath(filename);
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
			dataSize = fread(data, sizeof(data[0]), dataSize,fp);
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
		Error("failed to load file: {}", fullPath);
	}
	return data;
}

void Content::loadByChunks(String filename, const std::function<void(Uint8*,int)>& handler)
{
	if (filename.empty())
	{
		return;
	}
	std::string fullPath = Content::getFullPath(filename);
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
				size = s_cast<int>(fread(buffer, sizeof(Uint8), DORA_COPY_BUFFER_SIZE, file));
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
		std::string strPath = strFilePath;
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

bool Content::isPathFolder(String path)
{
	return g_apkFile->isFolder(path);
}

bool Content::isAbsolutePath(String strPath)
{
	// On Android, there are two situations for full path.
	// 1) Files in APK, e.g. assets/path/path/file.png
	// 2) Files not in APK, e.g. /data/data/org.luvfight.dorothy/cache/path/path/file.png, or /sdcard/path/path/file.png.
	// So these two situations need to be checked on Android.
	if (strPath[0] == '/' || std::string(strPath).find(_assetPath) == 0)
	{
		return true;
	}
	return false;
}
#endif // BX_PLATFORM_ANDROID

#if BX_PLATFORM_WINDOWS

Content::Content()
{
	_assetPath = fs::current_path().string();

	char* prefPath = SDL_GetPrefPath(DORA_DEFAULT_ORG_NAME, DORA_DEFAULT_APP_NAME);
	_writablePath = prefPath;
	SDL_free(prefPath);
}

bool Content::isFileExist(String filePath)
{
	std::string strPath = filePath;
	if (!Content::isAbsolutePath(strPath))
	{
		strPath.insert(0, _assetPath);
	}
	bool res = true;
	if (GetFileAttributesA(strPath.c_str()) == INVALID_FILE_ATTRIBUTES)
	{
		switch (GetLastError())
		{
		case ERROR_FILE_NOT_FOUND:
		case ERROR_PATH_NOT_FOUND:
		case ERROR_INVALID_NAME:
		case ERROR_INVALID_DRIVE:
		case ERROR_NOT_READY:
		case ERROR_INVALID_PARAMETER:
		case ERROR_BAD_PATHNAME:
		case ERROR_BAD_NETPATH:
			res = false;
			break;
		}
	}
	return res;
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

#if BX_PLATFORM_WINDOWS
static std::string toUTF8String(const std::string& str)
{
	int wsize = MultiByteToWideChar(CP_ACP, 0, str.data(), str.length(), 0, 0);
	std::wstring wstr(wsize, 0);
	MultiByteToWideChar(CP_ACP, 0, str.data(), str.length(), &wstr[0], wsize);
	int u8size = WideCharToMultiByte(CP_UTF8, 0, wstr.c_str(),
		wstr.length(), nullptr, 0,
		nullptr, nullptr);
	std::string u8str(u8size, '\0');
	WideCharToMultiByte(CP_UTF8, 0, wstr.c_str(),
		wstr.length(), &u8str[0], u8size,
		nullptr, nullptr);
	return u8str;
}
#endif // BX_PLATFORM_WINDOWS

Uint8* Content::_loadFileUnsafe(String filename, Sint64& size)
{
	if (filename.empty()) return nullptr;
	std::string fullPath =
#if BX_PLATFORM_WINDOWS
		toUTF8String(Content::getFullPath(filename));
#else
		Content::getFullPath(filename);
#endif // BX_PLATFORM_WINDOWS
	SDL_RWops* io = SDL_RWFromFile(fullPath.c_str(), "rb");
	if (io == nullptr)
	{
		Error("failed to load file: {}", filename);
		return nullptr;
	}
	size = SDL_RWsize(io);
	Uint8* buffer = new Uint8[s_cast<size_t>(size)];
	SDL_RWread(io, buffer, sizeof(Uint8), s_cast<size_t>(size));
	SDL_RWclose(io);
	return buffer;
}

void Content::loadByChunks(String filename, const std::function<void(Uint8*,int)>& handler)
{
	if (filename.empty()) return;
	std::string fullPath = Content::getFullPath(filename);
	SDL_RWops* io = SDL_RWFromFile(fullPath.c_str(), "rb");
	if (io == nullptr)
	{
		Error("failed to load file: {}", fullPath);
		return;
	}
	Uint8 buffer[DORA_COPY_BUFFER_SIZE];
	int size = 0;
	while ((size = s_cast<int>(SDL_RWread(io, buffer, sizeof(Uint8), DORA_COPY_BUFFER_SIZE))))
	{
		handler(buffer, size);
	}
	SDL_RWclose(io);
}

bool Content::isPathFolder(String path)
{
	return fs::is_directory(path.toString());
}
#endif // BX_PLATFORM_WINDOWS || BX_PLATFORM_OSX || BX_PLATFORM_IOS

#if BX_PLATFORM_WINDOWS || BX_PLATFORM_ANDROID
string Content::getFullPathForDirectoryAndFilename(String directory, String filename)
{
	auto rootPath = fs::path(Content::isAbsolutePath(directory) ? Slice::Empty : _assetPath);
	std::string fullPath = (rootPath / directory.toString() / filename.toString()).string();
	if (!Content::isFileExist(fullPath))
	{
		fullPath.clear();
	}
	return fullPath;
}
#endif // BX_PLATFORM_WINDOWS || BX_PLATFORM_ANDROID

NS_DOROTHY_END
