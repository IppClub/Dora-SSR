typedef const char* String;

class Object
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

class Content
{
    tolua_readonly tolua_property__common string writablePath;
	void saveToFile @ save(String filename, String content);
	bool isFileExist @ exist(String path);
	bool createFolder @ mkdir(String path);
    bool isFolder @ isdir(String path);
	bool removeFile @ remove(String path);
    string getFullPath(String filename);
	void addSearchPath(String path);
	void removeSearchPath(String path);
	tolua_outside void Content_getDirEntries @ getEntries(String path, bool isFolder);
	tolua_outside void Content_loadFile @ load(String filename);
	tolua_outside void Content_setSearchPaths @ setSearchPaths(String paths[tolua_len]);
	tolua_outside void Content_setSearchPaths @ setSearchPaths(String paths[tolua_len]);
    tolua_outside void Content_loadFileAsync @ loadAsync(String filename, tolua_function handler);
	tolua_outside void Content_copyFileAsync @ copyAsync(String src, String dst, tolua_function handler);
	static tolua_outside Content* Content_shared @ create();
};

class Event
{
	tolua_readonly tolua_property__common string name;
};
void Event::send @ emit(String name);

class Listener @ Slot : public Object
{
	tolua_readonly tolua_property__common string name;
	tolua_property__bool bool enabled;
};

class Scheduler : public Object
{
	tolua_property__common float timeScale;
	void schedule(Object* object);
	tolua_outside void Scheduler_schedule @ schedule(tolua_function handler);
	void unschedule(Object* object);
	tolua_outside void Scheduler_unschedule @ unschedule(tolua_function handler);
	static Scheduler* create();
};

class Director
{
	tolua_property__common Scheduler* scheduler;
	tolua_readonly tolua_property__common double deltaTime;
	tolua_outside void Director_schedule @ schedule(tolua_function handler);
	tolua_outside void Director_unschedule @ unschedule(tolua_function handler);
	static tolua_outside Director* Director_shared @ create();
};

void Dora_Log @ Log(String msg);
