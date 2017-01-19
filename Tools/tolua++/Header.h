typedef Slice String;

module TargetPlatform
{
    #define TargetPlatform::Windows @ Windows
    #define TargetPlatform::Android @ Android
    #define TargetPlatform::macOS @ macOS
    #define TargetPlatform::iOS @ iOS
}

class Application
{
	tolua_readonly tolua_property__common int width;
	tolua_readonly tolua_property__common int height;
	tolua_readonly tolua_property__common int platform;
	tolua_property__common unsigned int seed;
	static tolua_outside Application* Application_shared @ create();
};

class Object
{
	tolua_readonly tolua_property__common Uint32 id;
	tolua_readonly tolua_property__common Uint32 luaRef @ ref;
	static tolua_readonly tolua_property__common Uint32 objectCount @ count;
	static tolua_readonly tolua_property__common Uint32 maxObjectCount @ maxCount;
	static tolua_readonly tolua_property__common Uint32 luaRefCount;
	static tolua_readonly tolua_property__common Uint32 maxLuaRefCount;
	static tolua_readonly tolua_property__common Uint32 luaCallbackCount @ callRefCount;
	static tolua_readonly tolua_property__common Uint32 maxLuaCallbackCount @ maxCallRefCount;
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
	void loadFileAsync @ loadAsync(String filename, tolua_function handler);
	void copyFileAsync @ copyAsync(String src, String dst, tolua_function handler);
	tolua_outside void Content_getDirEntries @ getEntries(String path, bool isFolder);
	tolua_outside void Content_loadFile @ load(String filename);
	tolua_outside void Content_setSearchPaths @ setSearchPaths(String paths[tolua_len]);
	static tolua_outside Content* Content_shared @ create();
};

class Listener @ GSlot : public Object
{
	tolua_readonly tolua_property__common string name;
	tolua_property__bool bool enabled;
};

class Scheduler : public Object
{
	tolua_property__common float timeScale;
	void schedule(Object* object);
	void schedule(tolua_handler handler);
	void unschedule(Object* object);
	static Scheduler* create();
};

class Director
{
	tolua_property__common Scheduler* scheduler;
	tolua_readonly tolua_property__common Scheduler* systemScheduler;
	tolua_readonly tolua_property__common Array* entries;
	tolua_readonly tolua_property__common double deltaTime;
	void setEntry(Node* entry);
	void pushEntry(Node* entry);
	Node* popEntry();
	void popToEntry(Node* entry);
	void popToRootEntry();
	void swapEntry(Node* entryA, Node* entryB);
	void clearEntry();
	static tolua_outside Director* Director_shared @ create();
};

void Dora_Log @ Log(String msg);

struct Color3
{
    Uint8 r;
    Uint8 g;
    Uint8 b;
	Color3();
	Color3(Uint32 rgb);
	Color3(Uint8 r, Uint8 g, Uint8 b);
	~Color3();
};

struct Color
{
    Uint8 r;
    Uint8 g;
    Uint8 b;
    Uint8 a;
	tolua_property__common float opacity;
	Color();
	Color(Color3 color);
	Color(Uint32 argb);
	~Color();
	Color(Uint8 r, Uint8 g, Uint8 b, Uint8 a);
	Color3 toColor3();
};

struct Size;

struct Vec2
{
	float x;
	float y;
	tolua_readonly tolua_property__qt float length;
	tolua_readonly tolua_property__qt float lengthSquared;
	tolua_readonly tolua_property__qt float angle;
	Vec2(float x, float y);
	Vec2(Vec2 vec);
	~Vec2();
	void set(float x, float y);
	Vec2 operator+(Vec2 vec);
	Vec2 operator-(Vec2 vec);
	Vec2 operator*(float value);
	Vec2 operator*(Vec2 vec);
	Vec2 operator/(float value);
	bool operator==(Vec2 vec);
	Vec2 operator*(Size size);
	float distance(Vec2 vec);
	float distanceSquared(Vec2 vec);
	void normalize();
	void clamp(Vec2 from, Vec2 to);
	static tolua_readonly Vec2 zero;
};

struct Size
{
    float width;
    float height;
    Size();
    Size(float width, float height);
    Size(Size other);
    ~Size();
	void set(float width, float height);
	bool operator==(Size other);
	Size operator*(Vec2 vec);
	static tolua_readonly Size zero;
};

struct Rect
{
    Vec2 origin;
    Size size;
	tolua_property__common float x;
	tolua_property__common float y;
	tolua_property__common float width;
	tolua_property__common float height;
	tolua_property__common float left;
	tolua_property__common float right;
	tolua_property__common float centerX;
	tolua_property__common float centerY;
	tolua_property__common float bottom;
	tolua_property__common float top;
	tolua_property__common Vec2 lowerBound;
	tolua_property__common Vec2 upperBound;
	Rect();
	Rect(Vec2 origin, Size size);
	Rect(float x, float y, float width, float height);
	Rect(Rect other);
	~Rect();
	bool operator==(Rect other);
	void set(float x, float y, float width, float height);
    bool containsPoint(Vec2 point);
	bool intersectsRect(Rect rect);
	static tolua_readonly Rect zero;
};

class Array : public Object
{
	tolua_readonly tolua_property__common int count;
	tolua_readonly tolua_property__common int capacity;
	tolua_readonly tolua_property__common Object* last;
	tolua_readonly tolua_property__common Object* first;
	tolua_readonly tolua_property__common Object* randomObject;
	tolua_readonly tolua_property__bool bool empty;
	bool contains(Object* object);
	void add(Object* object);
	void addRange(Array* other);
	void removeFrom(Array* other);
	Object* removeLast();
	bool remove(Object* object);
	void clear();
	void fastRemove(Object* object);
	void swap(Object* objectA, Object* objectB);
	void swap(int indexA, int indexB);
	void reverse();
	void shrink();
	int index(Object* object);
	void set(int index, Object* object);
	Object* get(int index);
	void insert(int index, Object* object);
	void removeAt(int index);
	void fastRemoveAt(int index);
	bool each(tolua_function_bool func);

	static Array* create();
	static Array* create(Array* other);
	static Array* create(int capacity);
	static Array* create(Object* objects[tolua_len]);
};

class Slot : public Object
{
	void add(tolua_function handler);
	void set(tolua_function handler);
	void remove(tolua_function handler);
	void clear();
};

class Node : public Object
{
	tolua_property__common int order;
	tolua_property__common float angle;
	tolua_property__common float angleX;
	tolua_property__common float angleY;
	tolua_property__common float scaleX;
	tolua_property__common float scaleY;
	tolua_property__common float x;
	tolua_property__common float y;
	tolua_property__common float z;
	tolua_property__common Vec2 position;
	tolua_property__common float skewX;
	tolua_property__common float skewY;
	tolua_property__bool bool visible;
	tolua_property__common Vec2 anchor;
	tolua_property__common float width;
	tolua_property__common float height;
	tolua_property__common Size size;
	tolua_property__common string name;
	tolua_property__common float opacity;
	tolua_property__common Color color;
	tolua_property__common Color3 color3;
	tolua_property__bool bool passOpacity;
	tolua_property__bool bool passColor3;
	tolua_property__common Node* transformTarget;
	tolua_property__common Scheduler* scheduler;
	tolua_property__common Object* userData;
	tolua_readonly tolua_property__common Node* parent;
	tolua_readonly tolua_property__common Array* children;
	tolua_readonly tolua_property__common Rect boundingBox;
	tolua_readonly tolua_property__bool bool running;
	tolua_readonly tolua_property__bool bool updating;
	tolua_readonly tolua_property__bool bool scheduled;

	void addChild(Node* child, int order, String name);
	void addChild(Node* child, int order);
	void addChild(Node* child);

	Node* addTo(Node* parent, int order, String name);
	Node* addTo(Node* parent, int order);
	Node* addTo(Node* parent);

	void removeChild(Node* child, bool cleanup = true);
	void removeChildByName(String name, bool cleanup = true);
	void removeAllChildren(bool cleanup = true);

	void cleanup();

	Node* getChildByName(String name);

	void schedule(tolua_function_bool func);
	void unschedule();

	Vec2 convertToNodeSpace(Vec2 worldPoint);
	Vec2 convertToWorldSpace(Vec2 nodePoint);

	void scheduleUpdate();
	void unscheduleUpdate();
	
	bool eachChild(tolua_function_bool func);
	bool traverse(tolua_function_bool func);

	static Node* create();
};

class Sprite : public Node
{
	static Sprite* create();
	//static Sprite* create(Texture2D* texture, const Rect& textureRect);
	//static Sprite* create(Texture2D* texture);
	static Sprite* create(String filename);
};
