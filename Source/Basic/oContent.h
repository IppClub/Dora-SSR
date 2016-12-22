/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#ifndef __DOROTHY_BASIC_OCONTENT_H__
#define __DOROTHY_BASIC_OCONTENT_H__

NS_DOROTHY_BEGIN

class oContent : public oObject
{
public:
	PROPERTY_READONLY_REF(string, CurrentPath);
	PROPERTY_READONLY_REF(string, WritablePath);
	virtual ~oContent();
	oOwnArray<Uint8> loadFile(oSlice filename, Sint64& size);
	void copyFile(oSlice src, oSlice dst);

	bool isFileExist(oSlice filePath);
	bool isFolder(oSlice path);
	vector<string> getDirEntries(oSlice path, bool isFolder);
    bool isAbsolutePath(oSlice strPath);

	bool removeFile(oSlice filename);
	void saveToFile(oSlice filename, oSlice content);
	bool createFolder(oSlice path);

	string getFullPath(oSlice filename);

	void addSearchPath(oSlice path);
	void removeSearchPath(oSlice path);
	void setSearchPaths(const vector<string>& searchPaths);

	Uint8* loadFileUnsafe(oSlice filename, Sint64& size);
protected:
	oContent();
	string getFullPathForDirectoryAndFilename(oSlice directory, oSlice filename);
private:
	string _currentPath;
	string _writablePath;
	vector<string> _searchPaths;
	unordered_map<string, string> _fullPathCache;
	LUA_TYPE_OVERRIDE(oContent)
};

#define oSharedContent \
	silly::Singleton<oContent, oSingletonIndex::ContentManager>::shared()

NS_DOROTHY_END

#endif // __DOROTHY_BASIC_OCONTENT_H__
