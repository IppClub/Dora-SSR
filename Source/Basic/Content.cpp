/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Basic/Content.h"

#include "Basic/Application.h"
#include "Basic/VGRender.h"
#include "Common/Async.h"
#include <fstream>
using std::ofstream;
#include <mutex>

#if BX_PLATFORM_LINUX
#include <limits.h>
#include <unistd.h>

#include "ghc/fs_impl.hpp"

#include "ghc/fs_fwd.hpp"
namespace fs = ghc::filesystem;
#else
#include <filesystem>
namespace fs = std::filesystem;
#endif // BX_PLATFORM_LINUX

#include "ZipUtils.h"

#include "miniz.h"

#include "SDL.h"

static void releaseFileData(void* _ptr, void* _userData) {
	DORA_UNUSED_PARAM(_userData);
	if (_ptr) {
		uint8_t* data = r_cast<uint8_t*>(_ptr);
		delete[] data;
	}
}

NS_DORA_BEGIN

#if BX_PLATFORM_ANDROID

bool Content::isAndroidAsset(String fullPath) const {
	return fullPath.left(_assetPath.length()) == _assetPath;
}

std::string Content::getAndroidAssetName(String fullPath) const {
	const auto& apkPath = SharedApplication.getAPKPath();
	fullPath.skip(apkPath.length() + 1);
	return fullPath.toString();
}

#endif // BX_PLATFORM_ANDROID

Content::~Content() { }

Async* Content::getThread() const {
	return _thread;
}

std::pair<OwnArray<uint8_t>, size_t> Content::load(String filename) {
	_thread->pause();
	int64_t size = 0;
	uint8_t* data = Content::loadUnsafe(filename, size);
	_thread->resume();
	return {OwnArray<uint8_t>(data), s_cast<size_t>(size)};
}

const bgfx::Memory* Content::loadBX(String filename) {
	_thread->pause();
	int64_t size = 0;
	uint8_t* data = Content::loadUnsafe(filename, size);
	_thread->resume();
	return bgfx::makeRef(data, (uint32_t)size, releaseFileData);
}

bool Content::copy(String src, String dst) {
	_thread->pause();
	bool result = Content::copyUnsafe(src, dst);
	_thread->resume();
	return result;
}

bool Content::move(String src, String dst) {
	std::error_code err;
	fs::rename(src.toString(), dst.toString(), err);
	WarnIf(err, "failed to move file from \"{}\" to \"{}\" due to \"{}\".", src.toString(), dst.toString(), err.message());
	return !err;
}

bool Content::save(String filename, String content) {
	auto fullPathAndPackage = Content::getFullPathAndPackage(filename);
	if (fullPathAndPackage.zipFile) {
		Error("can not save file \"{}\" to a zip package", filename.toString());
		return false;
	}
	auto fullPath = fullPathAndPackage.fullPath.empty() ? filename.toString() : fullPathAndPackage.fullPath;
	ofstream stream(fullPath, std::ios::trunc | std::ios::binary);
	if (!stream) return false;
	if (stream.write(content.rawData(), content.size())) {
		return true;
	}
	return false;
}

bool Content::save(String filename, uint8_t* content, int64_t size) {
	auto fullPathAndPackage = Content::getFullPathAndPackage(filename);
	if (fullPathAndPackage.zipFile) {
		Error("can not save file \"{}\" to a zip package", filename.toString());
		return false;
	}
	auto fullPath = fullPathAndPackage.fullPath.empty() ? filename.toString() : fullPathAndPackage.fullPath;
	ofstream stream(fullPath, std::ios::trunc | std::ios::binary);
	if (!stream) return false;
	if (stream.write(r_cast<char*>(content), s_cast<std::streamsize>(size))) {
		return true;
	}
	return false;
}

bool Content::remove(String filename) {
	auto fullPathAndPackage = Content::getFullPathAndPackage(filename);
	if (fullPathAndPackage.zipFile) {
		Error("can not remove file \"{}\" from a zip package", filename.toString());
		return false;
	}
	auto fullPath = fullPathAndPackage.fullPath.empty() ? filename.toString() : fullPathAndPackage.fullPath;
	if (!Content::isFileExist(fullPath)) return false;
	std::error_code err;
	fs::remove_all(fullPath, err);
	WarnIf(err, "failed to remove files from \"{}\" due to \"{}\".", filename.toString(), err.message());
	return !err;
}

bool Content::createFolder(String folder) {
	fs::path path = folder.toString();
	return fs::create_directories(path);
}

std::list<std::string> Content::getDirs(String path) {
	return Content::getDirEntries(path, true);
}

std::list<std::string> Content::getFiles(String path) {
	return Content::getDirEntries(path, false);
}

std::list<std::string> Content::getAllFiles(String path) {
	std::string searchName = path.empty() ? _assetPath : path.toString();
	auto fullPathAndPackage = Content::getFullPathAndPackage(searchName);
	if (fullPathAndPackage.zipFile) {
		return fullPathAndPackage.zipFile->getAllFiles();
	}
	auto fullPath = fullPathAndPackage.fullPath.empty() ? searchName : fullPathAndPackage.fullPath;
#if BX_PLATFORM_ANDROID
	if (isAndroidAsset(fullPath)) {
		return _apkFile->getAllFiles(getAndroidAssetName(fullPath));
	}
#endif // BX_PLATFORM_ANDROID
	std::list<std::string> files;
	if (Content::isFileExist(fullPath)) {
		fs::path parentPath = fullPath;
		for (const auto& item : fs::recursive_directory_iterator(parentPath)) {
			if (!item.is_directory()) {
				files.push_back(item.path().lexically_relative(parentPath).string());
			}
		}
	} else {
		Error("Content failed to get entry of \"{}\"", fullPath);
	}
	return files;
}

bool Content::visitDir(String path, const std::function<bool(String, String)>& func) {
	std::function<bool(String)> visit;
	visit = [&visit, &func, this](String path) {
		auto files = getFiles(path);
		for (const auto& file : files) {
			if (func(file, path)) return true;
		}
		auto dirs = getDirs(path);
		auto parent = fs::path(path.begin(), path.end());
		for (const auto& dir : dirs) {
			if (visit((parent / dir).string())) return true;
		}
		return false;
	};
	return visit(path);
}

const std::string& Content::getAssetPath() const {
	return _assetPath;
}

const std::string& Content::getWritablePath() const {
	return _writablePath;
}

static std::tuple<std::string, std::string> splitDirectoryAndFilename(const std::string& filePath) {
	std::string file = filePath;
	std::string path;
	size_t pos = filePath.find_last_of("/\\");
	if (pos != std::string::npos) {
		path = filePath.substr(0, pos + 1);
		file = filePath.substr(pos + 1);
	}
	return std::make_tuple(path, file);
}

Content::SearchPath Content::getFullPathAndPackage(String filename) {
	AssertIf(filename.empty(), "invalid filename for full path.");

	Slice targetFile = filename;
	targetFile.trimSpace();

	if (Content::isAbsolutePath(targetFile)) {
		for (const auto& zipFile : _searchZipPaths) {
			auto relative = fs::path(targetFile.begin(), targetFile.end()).lexically_relative(zipFile.first).string();
			auto relSlice = Slice(relative);
			if (!relSlice.empty() && targetFile.left(3) != "..\\"_slice && targetFile.left(3) != "../"_slice) {
				if (relative == "."_slice || zipFile.second->fileExists(relative)) {
					return {targetFile.toString(), zipFile.second.get(), relative};
				}
			}
		}

		return {targetFile.toString(), nullptr, Slice::Empty};
	}

	while (targetFile.size() > 1 && (targetFile.back() == '\\' || targetFile.back() == '/')) {
		targetFile.skipRight(1);
	}

	static std::mutex pathMutex;
	{
		std::lock_guard<std::mutex> lock(pathMutex);
		auto fName = fs::path(targetFile.begin(), targetFile.end()).lexically_normal();
		auto fStr = fName.string();

		auto it = _fullPathCache.find(fStr);
		if (it != _fullPathCache.end()) {
			return {it->second.first, it->second.second, it->second.second ? fStr : Slice::Empty};
		}

		std::string path, file, fullPath;
		for (const auto& searchPath : _searchPaths) {
			auto it = _searchZipPaths.find(searchPath);
			if (it != _searchZipPaths.end()) {
				auto fstr = fName.string();
				if (it->second->fileExists(fstr)) {
					fullPath = (fs::path(searchPath) / fName).string();
					auto zipPair = std::make_pair(fullPath, it->second.get());
					_fullPathCache[fStr] = zipPair;
					return {zipPair.first, zipPair.second, fStr};
				}
				continue;
			}
			std::tie(path, file) = splitDirectoryAndFilename((fs::path(searchPath) / fName).string());
			fullPath = Content::getFullPathForDirectoryAndFilename(path, file);
			if (!fullPath.empty()) {
				_fullPathCache[fStr] = {fullPath, nullptr};
				return {fullPath, nullptr, Slice::Empty};
			}
		}

		std::tie(path, file) = splitDirectoryAndFilename(targetFile.toString());
		fullPath = Content::getFullPathForDirectoryAndFilename(path, file);
		if (!fullPath.empty()) {
			_fullPathCache[targetFile.toString()] = {fullPath, nullptr};
			return {fullPath, nullptr, Slice::Empty};
		}
	}

	return {Slice::Empty, nullptr, Slice::Empty};
}

std::string Content::getFullPath(String filename) {
	auto fullPath = getFullPathAndPackage(filename).fullPath;
	return fullPath.empty() ? filename.toString() : fullPath;
}

std::list<std::string> Content::getFullPathsToTry(String filename) {
	AssertIf(filename.empty(), "invalid filename for full path.");

	Slice targetFile = filename;
	targetFile.trimSpace();

	while (targetFile.size() > 1 && (targetFile.back() == '\\' || targetFile.back() == '/')) {
		targetFile.skipRight(1);
	}

	if (Content::isAbsolutePath(targetFile)) {
		return {targetFile.toString()};
	}

	std::list<std::string> paths;
	std::string path, file, fullPath;
	auto fname = fs::path(targetFile.begin(), targetFile.end()).lexically_normal();
	for (const auto& searchPath : _searchPaths) {
		paths.push_back((fs::path(searchPath) / fname).string());
	}
	return paths;
}

void Content::insertSearchPath(int index, String path) {
	_thread->pause();
	std::string searchPath = Content::getFullPath(path);
	if (Content::isFileExist(searchPath)) {
		if (Content::isPathFolder(searchPath)) {
			if (index >= _searchPaths.size()) {
				_searchPaths.push_back(searchPath);
			} else {
				_searchPaths.insert(_searchPaths.begin() + index, searchPath);
				_fullPathCache.clear();
			}
		} else {
			auto relativePath = fs::path(searchPath).lexically_relative(fs::path(Content::getAssetPath())).string();
			auto relSlice = Slice(relativePath);
			if (!relativePath.empty() && relSlice.left(3) != "..\\"_slice && relSlice.left(3) != "../"_slice) {
				Error("can not set file \"{}\" under asset path as search package", path.toString());
			} else {
				auto zipFile = New<ZipFile>(searchPath);
				if (zipFile->isOK()) {
					if (index >= _searchPaths.size()) {
						_searchPaths.push_back(searchPath);
					} else {
						_searchPaths.insert(_searchPaths.begin() + index, searchPath);
						_fullPathCache.clear();
					}
					_searchZipPaths[searchPath] = std::move(zipFile);
				} else {
					Error("search path \"{}\" is neither a folder nor a zip file", path.toString());
				}
			}
		}
	} else {
		Warn("search path \"{}\" is not existed", path.toString());
	}
	_thread->resume();
}

void Content::addSearchPath(String path) {
	Content::insertSearchPath(_searchPaths.size(), path);
}

void Content::removeSearchPath(String path) {
	_thread->pause();
	std::string realPath = Content::getFullPath(path);
	for (auto it = _searchPaths.begin(); it != _searchPaths.end(); ++it) {
		if (*it == realPath) {
			_searchPaths.erase(it);
			_searchZipPaths.erase(*it);
			_fullPathCache.clear();
			break;
		}
	}
	_thread->resume();
}

void Content::setSearchPaths(const std::vector<std::string>& searchPaths) {
	_thread->pause();
	_searchPaths.clear();
	_fullPathCache.clear();
	_thread->resume();
	for (const std::string& searchPath : searchPaths) {
		Content::addSearchPath(searchPath);
	}
}

const std::vector<std::string>& Content::getSearchPaths() const {
	return _searchPaths;
}

bool Content::copyUnsafe(String src, String dst) {
	std::string srcPath = Content::getFullPath(src);
	// Info("copy file from {}", srcPath);
	// Info("copy file to {}", dst);
	if (Content::isPathFolder(srcPath)) {
		std::string dstPath = dst.toString();
		auto folders = Content::getDirEntries(src, true);
		for (const std::string& folder : folders) {
			std::string dstFolder = (fs::path(dstPath) / folder).string();
			if (!Content::isFileExist(dstFolder)) {
				if (!Content::createFolder(dstFolder)) {
					Error("failed to create folder \"{}\"", dstFolder);
					return false;
				}
			}
			std::string srcFolder = (fs::path(srcPath) / folder).string();
			if (!Content::copyUnsafe(srcFolder, dstFolder)) {
				return false;
			}
		}
		auto files = Content::getDirEntries(src, false);
		for (const std::string& file : files) {
			// Info("now copy file {}",file);
			ofstream stream(fs::path(dstPath) / file, std::ios::out | std::ios::trunc | std::ios::binary);
			if (!stream) return false;
			bool result = Content::loadByChunks((fs::path(srcPath) / file).string(), [&](uint8_t* buffer, int size) {
				if (!stream.write(r_cast<char*>(buffer), size)) {
					Error("failed to copy to file \"{}\"", (fs::path(dstPath) / file).string());
					return true;
				}
				return false;
			});
			if (!result) {
				return false;
			}
		}
	} else {
		ofstream stream(dst.toString(), std::ios::out | std::ios::trunc | std::ios::binary);
		if (!stream) {
			Error("failed to open file: \"{}\"", dst.toString());
			return false;
		}
		bool result = Content::loadByChunks(src, [&](uint8_t* buffer, int size) {
			if (!stream.write(r_cast<char*>(buffer), size)) {
				Error("failed to copy to file \"{}\"", dst.toString());
				return true;
			}
			return false;
		});
		if (!result) {
			return false;
		}
	}
	return true;
}

void Content::loadAsyncUnsafe(String filename, const std::function<void(uint8_t*, int64_t)>& callback) {
	std::string fileStr = filename.toString();
	_thread->run(
		[fileStr, this]() {
			int64_t size = 0;
			uint8_t* buffer = this->loadUnsafe(fileStr, size);
			return Values::alloc(buffer, size);
		},
		[callback](Own<Values> result) {
			uint8_t* buffer;
			int64_t size;
			result->get(buffer, size);
			callback(buffer, size);
		});
}

void Content::loadAsync(String filename, const std::function<void(String)>& callback) {
	Content::loadAsyncUnsafe(filename, [callback](uint8_t* buffer, int64_t size) {
		auto data = MakeOwnArray(buffer);
		callback(Slice(r_cast<char*>(data.get()), s_cast<size_t>(size)));
	});
}

void Content::loadAsyncData(String filename, const std::function<void(OwnArray<uint8_t>&&, size_t)>& callback) {
	Content::loadAsyncUnsafe(filename, [callback](uint8_t* buffer, int64_t size) {
		callback(MakeOwnArray(buffer), s_cast<size_t>(size));
	});
}

void Content::loadAsyncBX(String filename, const std::function<void(const bgfx::Memory*)>& callback) {
	Content::loadAsyncUnsafe(filename, [callback](uint8_t* buffer, int64_t size) {
		callback(bgfx::makeRef(buffer, s_cast<uint32_t>(size), releaseFileData));
	});
}

void Content::copyAsync(String src, String dst, const std::function<void(bool)>& callback) {
	std::string srcFile(src.toString()), dstFile(dst.toString());
	_thread->run(
		[srcFile, dstFile, this]() {
			bool success = Content::copyUnsafe(srcFile, dstFile);
			return Values::alloc(success);
		},
		[callback](Own<Values> result) {
			bool success = false;
			result->get(success);
			callback(success);
		});
}

void Content::saveAsync(String filename, String content, const std::function<void(bool)>& callback) {
	std::string file(filename.toString());
	auto data = std::make_shared<std::string>(content);
	_thread->run(
		[file, data, this]() {
			bool success = Content::save(file, *data);
			return Values::alloc(success);
		},
		[callback](Own<Values> result) {
			bool success = false;
			result->get(success);
			callback(success);
		});
}

void Content::saveAsync(String filename, OwnArray<uint8_t> content, size_t size, const std::function<void(bool)>& callback) {
	std::string file(filename.toString());
	auto data = std::make_shared<OwnArray<uint8_t>>(std::move(content));
	_thread->run(
		[file, data, size, this]() {
			bool success = Content::save(file, Slice(r_cast<char*>((*data).get()), size));
			return Values::alloc(success);
		},
		[callback](Own<Values> result) {
			bool success = false;
			result->get(success);
			callback(success);
		});
}

void Content::zipAsync(String folderPath, String zipFile, const std::function<bool(String)>& filter, const std::function<void(bool)>& callback) {
	std::error_code err;
	auto fullFolderPath = Content::getFullPath(folderPath);
	if (!fs::exists(fullFolderPath, err)) {
		Error("\"{}\" must be a local disk folder to zip", folderPath.toString());
		callback(false);
		return;
	}
	if (!Content::isFolder(fullFolderPath)) {
		Error("\"{}\" must be a folder to zip", folderPath.toString());
		callback(false);
		return;
	}
	if (!Content::isAbsolutePath(zipFile)) {
		Error("target zip file must be of an absolute path instead of \"{}\"", zipFile.toString());
		callback(false);
		return;
	}
	auto files = Content::getAllFiles(fullFolderPath);
	std::list<std::pair<std::string, std::string>> filePairs;
	for (auto& file : files) {
		if (!filter(file)) continue;
		for (auto& ch : file) {
			if (ch == '\\') ch = '/';
		}
		auto fullPath = Path::concat({fullFolderPath, file});
		filePairs.push_back({fullPath, file});
	}
	SharedAsyncThread.run([files = std::move(filePairs), zipFile = zipFile.toString()]() {
		mz_zip_archive archive;
		mz_zip_zero_struct(&archive);
		if (mz_zip_writer_init_file(&archive, zipFile.c_str(), 0)) {
			for (const auto& file : files) {
				if (!mz_zip_writer_add_file(&archive, file.second.c_str(), file.first.c_str(), nullptr, 0, MZ_DEFAULT_COMPRESSION)) {
					Error("failed to write file \"{}\" to zip, due to: {}", file.first, mz_zip_get_error_string(mz_zip_get_last_error(&archive)));
					mz_zip_writer_end(&archive);
					return Values::alloc(false);
				}
			}
			mz_zip_writer_finalize_archive(&archive);
			mz_zip_writer_end(&archive);
			return Values::alloc(true);
		} else {
			Error("failed to init zip file \"{}\", due to: {}", zipFile, mz_zip_get_error_string(mz_zip_get_last_error(&archive)));
			mz_zip_writer_end(&archive);
			return Values::alloc(false);
		}
	},
		[callback](Own<Values> values) {
			bool success = false;
			values->get(success);
			callback(success);
		});
}

void Content::unzipAsync(String zipFile, String folderPath, const std::function<bool(String)>& filter, const std::function<void(bool)>& callback) {
	std::error_code err;
	auto fullZipPath = getFullPath(zipFile);
	if (!fs::exists(fullZipPath, err)) {
		Error("\"{}\" must be a local disk zip file to unzip", zipFile.toString());
		callback(false);
		return;
	}
	if (Content::exist(folderPath)) {
		Error("unzip target \"{}\" existed", folderPath.toString());
		callback(false);
		return;
	}
	if (!Content::isAbsolutePath(folderPath)) {
		Error("target unzip folder must be of an absolute path instead of \"{}\"", folderPath.toString());
		callback(false);
		return;
	}
	auto zip = std::make_shared<ZipFile>(fullZipPath);
	std::string rootDir;
	BLOCK_START
	auto entries = zip->getDirEntries(""s, false);
	for (const auto& file : entries) {
		if (filter(file)) {
			break;
		}
	}
	auto dirs = zip->getDirEntries(""s, true);
	std::list<std::string> rootDirs;
	for (const auto& dir : dirs) {
		if (filter(dir)) {
			rootDirs.push_back(dir);
		}
	}
	BREAK_IF(rootDirs.size() != 1);
	rootDir = Path::getName(fullZipPath);
	if (rootDirs.front() != rootDir) {
		rootDir.clear();
	}
	BLOCK_END
	auto files = zip->getAllFiles();
	std::list<std::string> filtered;
	for (const auto& file : files) {
		if (filter(file)) {
			filtered.push_back(file);
		}
	}
	SharedAsyncThread.run([zip = std::move(zip), folderPath = folderPath.toString(), files = std::move(filtered), zipFile = zipFile.toString(), rootDir, this]() {
		for (const auto& file : files) {
			auto path = Path::concat({folderPath, rootDir.empty() ? file : Path::getRelative(file, rootDir)});
			if (auto parent = Path::getPath(path); !exist(parent)) {
				createFolder(parent);
			}
			std::ofstream stream(path);
			if (stream) {
				if (!zip->getFileDataByChunks(file, [&stream](uint8_t* data, size_t size) {
						if (stream.write(r_cast<const char*>(data), size)) {
							return false;
						}
						return true;
					})) {
					Error("failed to unzip file \"{}\" from \"{}\"", file, zipFile);
					return Values::alloc(false);
				}
			} else {
				Error("failed to unzip file \"{}\" from \"{}\"", file, zipFile);
				return Values::alloc(false);
			}
		}
		return Values::alloc(true);
	},
		[callback](Own<Values> values) {
			bool success = false;
			values->get(success);
			callback(success);
		});
}

bool Content::exist(String filename) {
	return Content::isFileExist(Content::getFullPath(filename));
}

bool Content::isFolder(String path) {
	return Content::isPathFolder(Content::getFullPath(path));
}

std::list<std::string> Content::getDirEntries(String path, bool isFolder) {
	std::string searchName = path.empty() ? _assetPath : path.toString();
	auto fullPathAndPackage = Content::getFullPathAndPackage(searchName);
	if (fullPathAndPackage.zipFile) {
		return fullPathAndPackage.zipFile->getDirEntries(fullPathAndPackage.zipRelativePath, isFolder);
	}
	std::string fullPath = fullPathAndPackage.fullPath;
#if BX_PLATFORM_ANDROID
	if (isAndroidAsset(fullPath)) {
		return _apkFile->getDirEntries(getAndroidAssetName(fullPath), isFolder);
	}
#endif // BX_PLATFORM_ANDROID
	std::list<std::string> files;
	if (Content::isFileExist(fullPath)) {
		fs::path parentPath = fullPath;
		for (const auto& item : fs::directory_iterator(parentPath)) {
			if (isFolder == item.is_directory()) {
				files.push_back(item.path().lexically_relative(parentPath).string());
			}
		}
	} else {
		Error("Content failed to get entry of \"{}\"", fullPath);
	}
	return files;
}

uint8_t* Content::loadInMainUnsafe(String filename, int64_t& size) {
	_thread->pause();
	uint8_t* data = Content::loadUnsafe(filename, size);
	_thread->resume();
	return data;
}

void Content::clearPathCache() {
	_fullPathCache.clear();
}

#if BX_PLATFORM_ANDROID
Content::Content()
	: _thread(SharedAsyncThread.newThread()) {
	_apkFilter = "assets/"s;
	_assetPath = SharedApplication.getAPKPath() + '/' + _apkFilter;
	_apkFile = New<ZipFile>(SharedApplication.getAPKPath(), _apkFilter);

	char* prefPath = SDL_GetPrefPath(DORA_DEFAULT_ORG_NAME, DORA_DEFAULT_APP_NAME);
	_writablePath = prefPath;
	SDL_free(prefPath);
}

uint8_t* Content::loadUnsafe(String filename, int64_t& size) {
	uint8_t* data = nullptr;
	if (filename.empty()) {
		return data;
	}
	auto fullPathAndPackage = Content::getFullPathAndPackage(filename);
	if (fullPathAndPackage.zipFile) {
		size_t s = 0;
		auto res = fullPathAndPackage.zipFile->getFileDataUnsafe(fullPathAndPackage.zipRelativePath, &s);
		size = s_cast<int64_t>(s);
		return res;
	}
	std::string fullPath = fullPathAndPackage.fullPath;
	if (isAndroidAsset(fullPath)) {
		data = _apkFile->getFileDataUnsafe(getAndroidAssetName(fullPath), r_cast<size_t*>(&size));
	} else {
		BLOCK_START {
			FILE* fp = fopen(fullPath.c_str(), "rb");
			BREAK_IF(!fp);
			fseek(fp, 0, SEEK_END);
			unsigned long dataSize = ftell(fp);
			fseek(fp, 0, SEEK_SET);
			data = new unsigned char[dataSize];
			dataSize = fread(data, sizeof(data[0]), dataSize, fp);
			fclose(fp);
			if (dataSize) {
				size = dataSize;
			}
		}
		BLOCK_END
	}
	if (!data) {
		Error("failed to load file: {}", fullPath);
	}
	return data;
}

bool Content::loadByChunks(String filename, const std::function<bool(uint8_t*, int)>& handler) {
	if (filename.empty()) {
		return false;
	}
	auto fullPathAndPackage = getFullPathAndPackage(filename);
	if (fullPathAndPackage.zipFile) {
		return fullPathAndPackage.zipFile->getFileDataByChunks(fullPathAndPackage.zipRelativePath, handler);
	}
	std::string fullPath = fullPathAndPackage.fullPath;
	if (isAndroidAsset(fullPath)) {
		if (_apkFile->getFileDataByChunks(getAndroidAssetName(fullPath), handler)) {
			return true;
		}
	} else {
		BLOCK_START {
			FILE* file = fopen(fullPath.c_str(), "rb");
			BREAK_IF(!file);
			uint8_t buffer[DORA_COPY_BUFFER_SIZE];
			int size = 0;
			do {
				size = s_cast<int>(fread(buffer, sizeof(uint8_t), DORA_COPY_BUFFER_SIZE, file));
				if (size > 0) {
					if (handler(buffer, size)) {
						return false;
					}
				}
			} while (size > 0);
			fclose(file);
			return true;
		}
		BLOCK_END
	}
	return false;
}

bool Content::isFileExist(String filename) {
	if (filename.empty()) {
		return false;
	}
	if (isAndroidAsset(filename)) {
		if (_apkFile->fileExists(getAndroidAssetName(filename))) {
			return true;
		}
	} else if (!isAbsolutePath(filename) && _apkFile->fileExists("assets/"s + filename)) {
		return true;
	}
	bool found = false;
	FILE* file = fopen(filename.c_str(), "r");
	if (file) {
		found = true;
		fclose(file);
	}
	return found;
}

bool Content::isPathFolder(String path) {
	if (isAndroidAsset(path)) {
		if (_apkFile->isFolder(getAndroidAssetName(path))) {
			return true;
		}
	} else if (!isAbsolutePath(path) && _apkFile->isFolder("assets/"s + path)) {
		return true;
	}
	return fs::is_directory(path.toString());
}
#endif // BX_PLATFORM_ANDROID

#if BX_PLATFORM_ANDROID || BX_PLATFORM_LINUX
bool Content::isAbsolutePath(String strPath) {
	if (strPath[0] == '/') {
		return true;
	}
	return false;
}
#endif // BX_PLATFORM_ANDROID || BX_PLATFORM_LINUX

#if BX_PLATFORM_WINDOWS
Content::Content()
	: _thread(SharedAsyncThread.newThread()) {
	_assetPath = fs::current_path().string();

	char* prefPath = SDL_GetPrefPath(DORA_DEFAULT_ORG_NAME, DORA_DEFAULT_APP_NAME);
	_writablePath = prefPath;
	SDL_free(prefPath);
}

bool Content::isAbsolutePath(String strPath) {
	if (strPath.size() > 2
		&& ((strPath[0] >= 'a' && strPath[0] <= 'z') || (strPath[0] >= 'A' && strPath[0] <= 'Z'))
		&& strPath[1] == ':') {
		return true;
	}
	return false;
}
#endif // BX_PLATFORM_WINDOWS

#if BX_PLATFORM_WINDOWS || BX_PLATFORM_LINUX
bool Content::isFileExist(String filePath) {
	std::string strPath = filePath.toString();
	if (!Content::isAbsolutePath(strPath)) {
		strPath.insert(0, _assetPath);
	}
	std::error_code err;
	return fs::exists(strPath, err);
}
#endif // BX_PLATFORM_WINDOWS || BX_PLATFORM_LINUX

#if BX_PLATFORM_OSX || BX_PLATFORM_IOS
Content::Content()
	: _thread(SharedAsyncThread.newThread()) {
	char* currentPath = SDL_GetBasePath();
	_assetPath = currentPath;
	SDL_free(currentPath);

	char* prefPath = SDL_GetPrefPath(DORA_DEFAULT_ORG_NAME, DORA_DEFAULT_APP_NAME);
	_writablePath = prefPath;
	SDL_free(prefPath);
}
#endif // BX_PLATFORM_OSX || BX_PLATFORM_IOS

#if BX_PLATFORM_LINUX
Content::Content()
	: _thread(SharedAsyncThread.newThread()) {
	auto currentPath = NewArray<char>(PATH_MAX);
	::getcwd(currentPath.get(), PATH_MAX);
	_assetPath = currentPath.get();

	char* prefPath = SDL_GetPrefPath(DORA_DEFAULT_ORG_NAME, DORA_DEFAULT_APP_NAME);
	_writablePath = prefPath;
	SDL_free(prefPath);
}
#endif // BX_PLATFORM_LINUX

#if BX_PLATFORM_WINDOWS || BX_PLATFORM_OSX || BX_PLATFORM_IOS || BX_PLATFORM_LINUX

#if BX_PLATFORM_WINDOWS
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif // WIN32_LEAN_AND_MEAN
#include <windows.h>
static std::string toUTF8String(const std::string& str) {
	int wsize = MultiByteToWideChar(CP_ACP, 0, str.data(), str.length(), 0, 0);
	std::wstring wstr(wsize, 0);
	MultiByteToWideChar(CP_ACP, 0, str.data(), str.length(), &wstr[0], wsize);
	int u8size = WideCharToMultiByte(CP_UTF8, 0, wstr.c_str(), wstr.length(), nullptr, 0, nullptr, nullptr);
	std::string u8str(u8size, '\0');
	WideCharToMultiByte(CP_UTF8, 0, wstr.c_str(), wstr.length(), &u8str[0], u8size, nullptr, nullptr);
	return u8str;
}
#endif // BX_PLATFORM_WINDOWS

uint8_t* Content::loadUnsafe(String filename, int64_t& size) {
	if (filename.empty()) return nullptr;
	auto fullPathAndPackage = Content::getFullPathAndPackage(filename);
	if (fullPathAndPackage.zipFile) {
		size_t s = 0;
		auto res = fullPathAndPackage.zipFile->getFileDataUnsafe(fullPathAndPackage.zipRelativePath, &s);
		size = s_cast<int64_t>(s);
		return res;
	}
	std::string fullPath =
#if BX_PLATFORM_WINDOWS
		fullPath = toUTF8String(fullPathAndPackage.fullPath);
#else
		fullPathAndPackage.fullPath;
#endif // BX_PLATFORM_WINDOWS
	SDL_RWops* io = SDL_RWFromFile(fullPath.c_str(), "rb");
	if (io == nullptr) {
		Error("failed to load file: {}", filename.toString());
		return nullptr;
	}
	size = SDL_RWsize(io);
	uint8_t* buffer = new uint8_t[s_cast<size_t>(size)];
	SDL_RWread(io, buffer, sizeof(uint8_t), s_cast<size_t>(size));
	SDL_RWclose(io);
	return buffer;
}

bool Content::loadByChunks(String filename, const std::function<bool(uint8_t*, int)>& handler) {
	if (filename.empty()) return false;
	auto fullPathAndPackage = getFullPathAndPackage(filename);
	if (fullPathAndPackage.zipFile) {
		return fullPathAndPackage.zipFile->getFileDataByChunks(fullPathAndPackage.zipRelativePath, handler);
	}
	std::string fullPath =
#if BX_PLATFORM_WINDOWS
		fullPath = toUTF8String(fullPathAndPackage.fullPath);
#else
		fullPathAndPackage.fullPath;
#endif // BX_PLATFORM_WINDOWS
	SDL_RWops* io = SDL_RWFromFile(fullPath.c_str(), "rb");
	if (io == nullptr) {
		Error("failed to load file: \"{}\"", fullPath);
		return false;
	}
	uint8_t buffer[DORA_COPY_BUFFER_SIZE];
	int size = 0;
	while ((size = s_cast<int>(SDL_RWread(io, buffer, sizeof(uint8_t), DORA_COPY_BUFFER_SIZE)))) {
		if (handler(buffer, size)) {
			SDL_RWclose(io);
			return false;
		}
	}
	SDL_RWclose(io);
	return true;
}

bool Content::isPathFolder(String path) {
	return fs::is_directory(path.toString());
}
#endif // BX_PLATFORM_WINDOWS || BX_PLATFORM_OSX || BX_PLATFORM_IOS || BX_PLATFORM_LINUX

#if BX_PLATFORM_WINDOWS || BX_PLATFORM_ANDROID || BX_PLATFORM_LINUX
std::string Content::getFullPathForDirectoryAndFilename(String directory, String filename) {
	auto rootPath = fs::path(Content::isAbsolutePath(directory) ? Slice::Empty : _assetPath);
	std::string fullPath = (rootPath / directory.toString() / filename.toString()).string();
	if (!Content::isFileExist(fullPath)) {
		fullPath.clear();
	}
	return fullPath;
}
#endif // BX_PLATFORM_WINDOWS || BX_PLATFORM_ANDROID || BX_PLATFORM_LINUX

NS_DORA_END
