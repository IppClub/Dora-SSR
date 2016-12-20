class oContent
{
    tolua_readonly tolua_property__common string writablePath;
	void saveToFile(oSlice filename, oSlice content);
	bool isFileExist @ exist(oSlice path);
	bool createFolder @ mkdir(oSlice path);
    bool isFolder @ isdir(oSlice path);
	bool removeFile @ remove(oSlice path);
    string getFullPath(oSlice filename);

	void addSearchPath(oSlice path);
	void removeSearchPath(oSlice path);
	tolua_outside void oContent_getDirEntries @ getEntries(oSlice path, bool isFolder);
	tolua_outside void oContent_loadFile @ loadFile(oSlice filename);
	tolua_outside void oContent_setSearchPaths @ setSearchPaths(oSlice paths[tolua_len]);
	tolua_outside void oContent_setSearchPaths @ setSearchPaths(oSlice paths[tolua_len]);
	static tolua_outside oContent* oContent_shared @ create();
};
