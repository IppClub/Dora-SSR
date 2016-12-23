/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#ifndef __DOROTHY_BASIC_CONTENT_H__
#define __DOROTHY_BASIC_CONTENT_H__

NS_DOROTHY_BEGIN

class Content : public Object
{
public:
	PROPERTY_READONLY_REF(string, CurrentPath);
	PROPERTY_READONLY_REF(string, WritablePath);
	virtual ~Content();
	OwnArray<Uint8> loadFile(String filename, Sint64& size);
	void copyFile(String src, String dst);

	bool isFileExist(String filePath);
	bool isFolder(String path);
	vector<string> getDirEntries(String path, bool isFolder);
    bool isAbsolutePath(String strPath);

	bool removeFile(String filename);
	void saveToFile(String filename, String content);
	bool createFolder(String path);

	string getFullPath(String filename);

	void addSearchPath(String path);
	void removeSearchPath(String path);
	void setSearchPaths(const vector<string>& searchPaths);

	Uint8* loadFileUnsafe(String filename, Sint64& size);
protected:
	Content();
	string getFullPathForDirectoryAndFilename(String directory, String filename);
private:
	string _currentPath;
	string _writablePath;
	vector<string> _searchPaths;
	unordered_map<string, string> _fullPathCache;
	LUA_TYPE_OVERRIDE(Content)
};

#define SharedContent \
	silly::Singleton<Content, SingletonIndex::ContentManager>::shared()

NS_DOROTHY_END

#endif // __DOROTHY_BASIC_CONTENT_H__
