typedef const char* String;

class Object @ oObject
{
	tolua_readonly tolua_property__common unsigned int id;
	tolua_readonly tolua_property__common unsigned int luaRef @ ref;
	static tolua_readonly tolua_property__common unsigned int objectCount @ count;
	static tolua_readonly tolua_property__common unsigned int maxObjectCount @ maxCount;
	static tolua_readonly tolua_property__common unsigned int luaRefCount;
	static tolua_readonly tolua_property__common unsigned int maxLuaRefCount;
	static tolua_readonly tolua_property__common unsigned int luaCallbackCount @ callRefCount;
	static tolua_readonly tolua_property__common unsigned int maxLuaCallbackCount @ maxCallRefCount;
};

class Content @ oContent
{
    tolua_readonly tolua_property__common string writablePath;
	void saveToFile(String filename, String content);
	bool isFileExist @ exist(String path);
	bool createFolder @ mkdir(String path);
    bool isFolder @ isdir(String path);
	bool removeFile @ remove(String path);
    string getFullPath(String filename);

	void addSearchPath(String path);
	void removeSearchPath(String path);
	tolua_outside void Content_getDirEntries @ getEntries(String path, bool isFolder);
	tolua_outside void Content_loadFile @ loadFile(String filename);
	tolua_outside void Content_setSearchPaths @ setSearchPaths(String paths[tolua_len]);
	tolua_outside void Content_setSearchPaths @ setSearchPaths(String paths[tolua_len]);
	static tolua_outside Content* Content_shared @ create();
};

class Event @ oEvent
{
	tolua_readonly tolua_property__common string name;
};
void Event::send @ emit(String name);

class Listener @ oSlot : public Object
{
	tolua_readonly tolua_property__common string name;
	tolua_property__bool bool enabled;
};
