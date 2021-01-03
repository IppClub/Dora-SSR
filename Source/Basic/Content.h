/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

class Content
{
public:
	PROPERTY_READONLY_CREF(string, AssetPath);
	PROPERTY_READONLY_CREF(string, WritablePath);
	PROPERTY_CREF(vector<string>, SearchPaths);
	virtual ~Content();
	bool isExist(String filename);
	bool isFolder(String path);
	bool isAbsolutePath(String strPath);
	string getFullPath(String filename);
	std::pair<OwnArray<Uint8>,size_t> loadFile(String filename);
	const bgfx::Memory* loadFileBX(String filename);
	void copyFile(String src, String dst);
	bool removeFile(String filename);
	void saveToFile(String filename, String content);
	void saveToFile(String filename, Uint8* content, Sint64 size);
	bool createFolder(String path);
	list<string> getDirs(String path);
	list<string> getFiles(String path);
	list<string> getAllFiles(String path);
	bool visitDir(String path, const function<bool(String,String)>& func);
	void insertSearchPath(int index, String path);
	void addSearchPath(String path);
	void removeSearchPath(String path);
	void loadFileAsync(String filename, const function<void(String)>& callback);
	void loadFileAsyncBX(String filename, const function<void(const bgfx::Memory*)>& callback);
	void loadFileAsyncData(String filename, const function<void(OwnArray<Uint8>&&,size_t)>& callback);
	void copyFileAsync(String src, String dst, const function<void()>& callback);
	void saveToFileAsync(String filename, String content, const function<void()>& callback);
	void saveToFileAsync(String filename, OwnArray<Uint8> content, size_t size, const function<void()>& callback);
public:
	void loadFileAsyncUnsafe(String filename, const function<void (Uint8*, Sint64)>& callback);
	Uint8* loadFileUnsafe(String filename, Sint64& size);
protected:
	Content();
	string getFullPathForDirectoryAndFilename(String directory, String filename);
	void copyFileUnsafe(String srcFile, String dstFile);
	void loadFileByChunks(String filename, const function<void(Uint8*,int)>& handler);
	void saveToFileUnsafe(String filename, String content);
	void saveToFileUnsafe(String filename, Uint8* content, Sint64 size);
	bool isFileExist(String filePath);
	bool isPathFolder(String filePath);
	list<string> getDirEntries(String path, bool isFolder);
private:
	Uint8* _loadFileUnsafe(String filename, Sint64& size);
	string _assetPath;
	string _writablePath;
	vector<string> _searchPaths;
	unordered_map<string, string> _fullPathCache;
	SINGLETON_REF(Content, Application);
};

#define SharedContent \
	Dorothy::Singleton<Dorothy::Content>::shared()

NS_DOROTHY_END
