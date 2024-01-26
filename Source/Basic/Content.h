/* Copyright (c) 2024 Li Jin, dragon-fly@qq.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

class ZipFile;

NS_DORA_BEGIN

class Async;

class Content {
public:
	PROPERTY_READONLY_CREF(std::string, AssetPath);
	PROPERTY_READONLY_CREF(std::string, WritablePath);
	PROPERTY_CREF(std::vector<std::string>, SearchPaths);
	PROPERTY_READONLY(Async*, Thread);
	virtual ~Content();
	bool exist(String filename);
	bool isFolder(String path);
	bool isAbsolutePath(String strPath);
	std::string getFullPath(String filename);
	std::list<std::string> getFullPathsToTry(String filename);
	std::pair<OwnArray<uint8_t>, size_t> load(String filename);
	const bgfx::Memory* loadBX(String filename);
	bool copy(String src, String dst);
	bool move(String src, String dst);
	bool remove(String filename);
	bool save(String filename, String content);
	bool save(String filename, uint8_t* content, int64_t size);
	bool createFolder(String path);
	std::list<std::string> getDirs(String path);
	std::list<std::string> getFiles(String path);
	std::list<std::string> getAllFiles(String path);
	bool visitDir(String path, const std::function<bool(String, String)>& func);
	void insertSearchPath(int index, String path);
	void addSearchPath(String path);
	void removeSearchPath(String path);
	void loadAsync(String filename, const std::function<void(String)>& callback);
	void loadAsyncBX(String filename, const std::function<void(const bgfx::Memory*)>& callback);
	void loadAsyncData(String filename, const std::function<void(OwnArray<uint8_t>&&, size_t)>& callback);
	void copyAsync(String src, String dst, const std::function<void(bool)>& callback);
	void saveAsync(String filename, String content, const std::function<void(bool)>& callback);
	void saveAsync(String filename, OwnArray<uint8_t> content, size_t size, const std::function<void(bool)>& callback);
	void zipAsync(String folderPath, String zipFile, const std::function<bool(String)>& filter, const std::function<void(bool)>& callback);
	void unzipAsync(String zipFile, String folderPath, const std::function<bool(String)>& filter, const std::function<void(bool)>& callback);
	void clearPathCache();

public:
	void loadAsyncUnsafe(String filename, const std::function<void(uint8_t*, int64_t)>& callback);
	uint8_t* loadInMainUnsafe(String filename, int64_t& size);
	uint8_t* loadUnsafe(String filename, int64_t& size);

protected:
	Content();
	std::string getFullPathForDirectoryAndFilename(String directory, String filename);
	bool copyUnsafe(String srcFile, String dstFile);
	bool loadByChunks(String filename, const std::function<bool(uint8_t*, int)>& handler);
	void saveUnsafe(String filename, String content);
	void saveUnsafe(String filename, uint8_t* content, int64_t size);
	bool isFileExist(String filePath);
	bool isPathFolder(String filePath);
	std::list<std::string> getDirEntries(String path, bool isFolder);
	struct SearchPath {
		std::string fullPath;
		ZipFile* zipFile;
		std::string zipRelativePath;
	};
	SearchPath getFullPathAndPackage(String filename);

private:
	std::string _assetPath;
	std::string _writablePath;
#if BX_PLATFORM_ANDROID
	bool isAndroidAsset(String fullPath) const;
	std::string getAndroidAssetName(String fullPath) const;
	Own<ZipFile> _apkFile;
	std::string _apkFilter;
#endif
	std::vector<std::string> _searchPaths;
	StringMap<Own<ZipFile>> _searchZipPaths;
	StringMap<std::pair<std::string, ZipFile*>> _fullPathCache;
	Async* _thread;
	SINGLETON_REF(Content, Application);
};

#define SharedContent \
	Dora::Singleton<Dora::Content>::shared()

NS_DORA_END
