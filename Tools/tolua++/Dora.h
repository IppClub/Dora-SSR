typedef Slice String;

class Profiler
{
	static tolua_readonly string EventName;
	static int level;
};

struct Color3
{
	uint8_t r;
	uint8_t g;
	uint8_t b;
	Color3();
	Color3(uint32_t rgb);
	Color3(uint8_t r, uint8_t g, uint8_t b);
	~Color3();
	uint32_t toRGB();
};

struct Color
{
	uint8_t r;
	uint8_t g;
	uint8_t b;
	uint8_t a;
	tolua_property__common float opacity;
	Color();
	Color(Color3 color, uint8_t a = 0);
	Color(uint32_t argb);
	Color(uint8_t r, uint8_t g, uint8_t b, uint8_t a);
	~Color();
	Color3 toColor3();
	uint32_t toARGB();
};

struct Vec2
{
	tolua_readonly float x;
	tolua_readonly float y;
	tolua_readonly tolua_property__qt float length;
	tolua_readonly tolua_property__qt float lengthSquared;
	tolua_readonly tolua_property__qt float angle;
	Vec2 operator+(Vec2 vec);
	Vec2 operator-(Vec2 vec);
	Vec2 operator*(float value);
	Vec2 operator*(Vec2 vec);
	Vec2 operator*(Size size);
	Vec2 operator/(float value);
	bool operator==(Vec2 vec);
	float distance(Vec2 vec);
	float distanceSquared(Vec2 vec);
	tolua_outside Vec2 Vec2::normalize @ normalize();
	tolua_outside Vec2 Vec2::perp @ perp();
	tolua_outside Vec2 Vec2::clamp @ clamp(Vec2 from, Vec2 to);
	static tolua_outside Vec2 Vec2_create @ create(float x, float y);
	static tolua_outside Vec2 Vec2_create @ create(Size size);
	static tolua_readonly Vec2 zero;
};

struct Size
{
	float width;
	float height;
	Size(Size other);
	~Size();
	void set(float width, float height);
	bool operator==(Size other);
	Size operator*(Vec2 vec);
	static tolua_readonly Size zero;
	static tolua_outside Size* Size_create @ create(Vec2 vec);
	static tolua_outside Size* Size_create @ create(float width, float height);
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

class Application
{
	tolua_readonly tolua_property__common uint32_t frame;
	tolua_readonly tolua_property__common Size bufferSize;
	tolua_readonly tolua_property__common Size visualSize;
	tolua_readonly tolua_property__common float devicePixelRatio;
	tolua_readonly tolua_property__common String platform;
	tolua_readonly tolua_property__common String version;
	tolua_readonly tolua_property__common String deps;
	tolua_readonly tolua_property__common double deltaTime;
	tolua_readonly tolua_property__common double elapsedTime;
	tolua_readonly tolua_property__common double totalTime;
	tolua_readonly tolua_property__common double runningTime;
	tolua_readonly tolua_property__common uint32_t rand;
	tolua_readonly tolua_property__common uint32_t maxFPS;
	tolua_readonly tolua_property__bool bool debugging;
	tolua_property__common string locale;
	tolua_property__common Color themeColor;
	tolua_property__common unsigned int seed;
	tolua_property__common uint32_t targetFPS;
	tolua_property__common Size winSize;
	tolua_property__common Vec2 winPosition;
	tolua_property__bool bool fPSLimited @ fpsLimited;
	tolua_property__bool bool idled;
	void shutdown();
	static tolua_outside Application* Application_shared @ create();
};

class Object
{
	tolua_readonly tolua_property__common uint32_t id;
	tolua_readonly tolua_property__common uint32_t luaRef @ ref;
	static tolua_readonly tolua_property__common uint32_t count;
	static tolua_readonly tolua_property__common uint32_t maxCount;
	static tolua_readonly tolua_property__common uint32_t luaRefCount;
	static tolua_readonly tolua_property__common uint32_t maxLuaRefCount;
	static tolua_readonly tolua_property__common uint32_t luaCallbackCount @ callRefCount;
	static tolua_readonly tolua_property__common uint32_t maxLuaCallbackCount @ maxCallRefCount;
};

class Array : public Object
{
	tolua_readonly tolua_property__common size_t count;
	tolua_readonly tolua_property__bool bool empty;
	void addRange(Array* other);
	void removeFrom(Array* other);
	void clear();
	void reverse();
	void shrink();

	tolua_outside void Array_swap @ swap(int indexA, int indexB);
	tolua_outside bool Array_removeAt @ removeAt(int index);
	tolua_outside bool Array_fastRemoveAt @ fastRemoveAt(int index);
	tolua_outside bool Array_each @ each(tolua_function_bool func);
};

class Dictionary : public Object
{
	tolua_readonly tolua_property__common int count;
	bool each(tolua_function_bool func);
	void clear();
	static Dictionary* create();
};

class Entity : public Object
{
	static tolua_readonly tolua_property__common uint32_t count;
	tolua_readonly tolua_property__common int index;
	static void clear();
	static int getComIndex(String name);
	static int tryGetComIndex(String name);
	void destroy();
};

class EntityGroup @ Group
{
	tolua_readonly tolua_property__common int count;
	bool each(tolua_function_bool func);
	Entity* find(tolua_function_bool func);
	static EntityGroup* create(String components[tolua_len]);
};

class EntityObserver @ Observer
{
	static tolua_outside EntityObserver* EntityObserver_create @ create(String option, String components[tolua_len]);
};

struct Path
{
	static string getExt(String path);
	static string getPath(String path);
	static string getName(String path);
	static string getFilename(String path);
	static string getRelative(String path, String target);
	static string replaceExt(String path, String newExt);
	static string replaceFilename(String path, String newFile);
};

class Content
{
	tolua_readonly tolua_property__common string assetPath;
	tolua_readonly tolua_property__common string writablePath;
	bool save(String filename, String content);
	bool exist(String filename);
	bool createFolder @ mkdir(String path);
	bool isFolder @ isdir(String path);
	bool copy(String src, String dst);
	bool move(String src, String dst);
	bool remove(String path);
	string getFullPath(String filename);
	tolua_outside void Content_insertSearchPath @ insertSearchPath(int index, String path);
	void addSearchPath(String path);
	void removeSearchPath(String path);
	void loadAsync(String filename, tolua_function_void handler);
	void saveAsync(String filename, String content, tolua_function_void handler);
	void copyAsync(String src, String dst, tolua_function_void handler);
	void zipAsync(String folderPath, String zipFile, tolua_function_bool filter, tolua_function_void callback);
	void unzipAsync(String zipFile, String folderPath, tolua_function_bool filter, tolua_function_void callback);
	void clearPathCache();
	tolua_outside void Content_getDirs @ getDirs(String path);
	tolua_outside void Content_getFiles @ getFiles(String path);
	tolua_outside void Content_getAllFiles @ getAllFiles(String path);
	tolua_outside void Content_loadFile @ load(String filename);
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
	tolua_property__common int fixedFPS;
	void schedule(tolua_function_bool handler);
	static Scheduler* create();
};

class Camera : public Object
{
	tolua_readonly tolua_property__common string name;
};

class Camera2D : public Camera
{
	tolua_property__common float rotation;
	tolua_property__common float zoom;
	tolua_property__common Vec2 position;
	Camera2D* create(String name = nullptr);
};

class CameraOtho : public Camera
{
	tolua_property__common Vec2 position;
	CameraOtho* create(String name = nullptr);
};

class Director
{
	tolua_property__common Color clearColor;
	tolua_property__common Scheduler* scheduler;
	tolua_readonly tolua_property__common Node* uI @ ui;
	tolua_readonly tolua_property__common Node* uI3D @ ui3D;
	tolua_readonly tolua_property__common Node* entry;
	tolua_readonly tolua_property__common Node* postNode;
	tolua_readonly tolua_property__common Scheduler* systemScheduler;
	tolua_readonly tolua_property__common Scheduler* postScheduler;
	tolua_readonly tolua_property__common Camera* currentCamera;
	void pushCamera(Camera* camera);
	void popCamera();
	bool removeCamera(Camera* camera);
	void clearCamera();
	void cleanup();
	static tolua_outside Director* Director_shared @ create();
};

class View
{
	tolua_readonly tolua_property__common Size size;
	tolua_readonly tolua_property__common float standardDistance;
	tolua_readonly tolua_property__common float aspectRatio;
	tolua_property__common float nearPlaneDistance;
	tolua_property__common float farPlaneDistance;
	tolua_property__common float fieldOfView;
	tolua_property__common float scale;
	tolua_property__common SpriteEffect* postEffect;
	tolua_property__bool bool vSync @ vsync;
	static tolua_outside View* View_shared @ create();
}

void Dora_Log @ Log(String msg);

class Slot
{
	void add(tolua_function_void handler);
	void set(tolua_function_void handler);
	void remove(tolua_function_void handler);
	void clear();
};

class Action : public Object
{
	tolua_readonly tolua_property__common float duration;
	tolua_readonly tolua_property__bool bool running;
	tolua_readonly tolua_property__bool bool paused;
	tolua_property__bool bool reversed;
	tolua_property__common float speed;
	void pause();
	void resume();
	void updateTo(float elapsed, bool reversed = false);
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
	tolua_property__common string tag;
	tolua_property__common float opacity;
	tolua_property__common Color color;
	tolua_property__common Color3 color3;
	tolua_property__bool bool passOpacity;
	tolua_property__bool bool passColor3;
	tolua_property__common Node* transformTarget;
	tolua_property__common Scheduler* scheduler;
	tolua_readonly tolua_property__qt bool hasChildren;
	tolua_readonly tolua_property__common Array* children;
	tolua_readonly tolua_property__common Node* parent;
	tolua_readonly tolua_property__common Rect boundingBox;
	tolua_readonly tolua_property__bool bool running;
	tolua_readonly tolua_property__bool bool scheduled;
	tolua_readonly tolua_property__common int actionCount;
	tolua_readonly tolua_property__common Dictionary* userData @ data;
	tolua_property__bool bool touchEnabled;
	tolua_property__bool bool swallowTouches;
	tolua_property__bool bool swallowMouseWheel;
	tolua_property__bool bool keyboardEnabled;
	tolua_property__bool bool controllerEnabled;
	tolua_property__bool bool renderGroup;
	tolua_property__common int renderOrder;

	void addChild(Node* child, int order, String tag);
	void addChild(Node* child, int order);
	void addChild(Node* child);

	Node* addTo(Node* parent, int order, String tag);
	Node* addTo(Node* parent, int order);
	Node* addTo(Node* parent);

	void removeChild(Node* child, bool cleanup = true);
	void removeChildByTag(String tag, bool cleanup = true);
	void removeAllChildren(bool cleanup = true);
	void removeFromParent(bool cleanup = true);
	void moveToParent(Node* parent);

	void cleanup();

	Node* getChildByTag(String tag);

	void schedule(tolua_function_bool func);
	void unschedule();

	Vec2 convertToNodeSpace(Vec2 worldPoint);
	Vec2 convertToNodeSpace(Vec2 worldPoint, float& zInOut);
	Vec2 convertToWorldSpace(Vec2 nodePoint);
	Vec2 convertToWorldSpace(Vec2 nodePoint, float& zInOut);
	void convertToWindowSpace(Vec2 nodePoint, tolua_function_void callback);

	tolua_outside bool Node_eachChild @ eachChild(tolua_function_bool func);
	bool traverse(tolua_function_bool func);
	bool traverseAll(tolua_function_bool func);

	float runAction(Action* action);
	void stopAllActions();
	float perform(Action* action);
	void stopAction(Action* action);

	Size alignItemsVertically(float padding = 10.0f);
	Size alignItemsVertically(Size size, float padding = 10.0f);
	Size alignItemsHorizontally(float padding = 10.0f);
	Size alignItemsHorizontally(Size size, float padding = 10.0f);
	Size alignItems(float padding = 10.0f);
	Size alignItems(Size size, float padding = 10.0f);
	void moveAndCullItems(Vec2 delta);

	void attachIME();
	void detachIME();

	class Grabber : public Object
	{
		tolua_property__common Camera* camera;
		tolua_property__common SpriteEffect* effect;
		tolua_property__common BlendFunc blendFunc;
		tolua_property__common Color clearColor;
		tolua_outside void Grabber_setPos @ setPos(int x, int y, Vec2 pos, float z = 0.0f);
		tolua_outside Vec2 Grabber_getPos @ getPos(int x, int y);
		tolua_outside Color Grabber_getColor @ getColor(int x, int y);
		tolua_outside void Grabber_setColor @ setColor(int x, int y, Color color);
		tolua_outside void Grabber_moveUV @ moveUV(int x, int y, Vec2 offset);
	};
	Grabber* grab(bool enabled = true);
	Grabber* grab(uint32_t gridX, uint32_t gridY);

	static Node* create();
};

class Texture2D : public Object
{
	tolua_readonly tolua_property__common int width;
	tolua_readonly tolua_property__common int height;
};

struct BlendFunc
{
	BlendFunc(BlendFunc other);
	~BlendFunc();
	static tolua_outside BlendFunc* BlendFunc_create @ create(String src, String dst);
	static tolua_outside BlendFunc* BlendFunc_create @ create(String srcColor, String dstColor, String srcAlpha, String dstAlpha);
	static tolua_outside uint32_t BlendFunc_get @ get(String func);
	static const BlendFunc Default;
};

class Pass : public Object
{
	tolua_property__bool bool grabPass;
	void set(String name, float var1, float var2 = 0.0f, float var3 = 0.0f, float var4 = 0.0f);
	void set(String name, Color var);
	static Pass* create(String vertShader, String fragShader);
};

class Effect : public Object
{
	void add(Pass* pass);
	tolua_outside Pass* Effect_get @ get(size_t index);
	void clear();
	static Effect* create();
	static Effect* create(String vertShader, String fragShader);
};

class SpriteEffect : public Effect
{
	static SpriteEffect* create();
	static SpriteEffect* create(String vertShader, String fragShader);
};

class Sprite : public Node
{
	tolua_property__bool bool depthWrite;
	tolua_property__common float alphaRef;
	tolua_property__common Rect textureRect;
	tolua_readonly tolua_property__common Texture2D* texture;
	tolua_property__common BlendFunc blendFunc;
	tolua_property__common SpriteEffect* effect;
	static Sprite* create();
	static Sprite* create(Texture2D* texture, Rect textureRect);
	static Sprite* create(Texture2D* texture);
	static Sprite* from @ create(String clipStr);
};

class Grid : public Node
{
	tolua_readonly tolua_property__common uint32_t gridX;
	tolua_readonly tolua_property__common uint32_t gridY;
	tolua_property__bool bool depthWrite;
	tolua_property__common BlendFunc blendFunc;
	tolua_property__common SpriteEffect* effect;
	tolua_property__common Rect textureRect;
	tolua_property__common Texture2D* texture;
	tolua_outside void Grid_setPos @ setPos(int x, int y, Vec2 pos, float z = 0.0f);
	tolua_outside Vec2 Grid_getPos @ getPos(int x, int y);
	tolua_outside Color Grid_getColor @ getColor(int x, int y);
	tolua_outside void Grid_setColor @ setColor(int x, int y, Color color);
	tolua_outside void Grid_moveUV @ moveUV(int x, int y, Vec2 offset);
	static Grid* create(float width, float height, uint32_t gridX, uint32_t gridY);
	static Grid* create(Texture2D* texture, Rect textureRect, uint32_t gridX, uint32_t gridY);
	static Grid* create(Texture2D* texture, uint32_t gridX, uint32_t gridY);
	static Grid* from @ create(String clipStr, uint32_t gridX, uint32_t gridY);
};

class Touch : public Object
{
	tolua_property__bool bool enabled;
	tolua_readonly tolua_property__bool bool mouse @ fromMouse;
	tolua_readonly tolua_property__bool bool first;
	tolua_readonly tolua_property__common int id;
	tolua_readonly tolua_property__common Vec2 delta;
	tolua_readonly tolua_property__common Vec2 location;
	tolua_readonly tolua_property__common Vec2 worldLocation;
};

struct Ease
{
	enum Enum
	{
		Linear,
		InQuad,
		OutQuad,
		InOutQuad,
		OutInQuad,
		InCubic,
		OutCubic,
		InOutCubic,
		OutInCubic,
		InQuart,
		OutQuart,
		InOutQuart,
		OutInQuart,
		InQuint,
		OutQuint,
		InOutQuint,
		OutInQuint,
		InSine,
		OutSine,
		InOutSine,
		OutInSine,
		InExpo,
		OutExpo,
		InOutExpo,
		OutInExpo,
		InCirc,
		OutCirc,
		InOutCirc,
		OutInCirc,
		InElastic,
		OutElastic,
		InOutElastic,
		OutInElastic,
		InBack,
		OutBack,
		InOutBack,
		OutInBack,
		InBounce,
		OutBounce,
		InOutBounce,
		OutInBounce
	};
	static float func(Ease::Enum easing, float time);
};

class Label : public Node
{
	tolua_property__common float alphaRef;
	tolua_property__common float textWidth;
	tolua_property__common float spacing;
	tolua_property__common float lineGap;
	tolua_property__common string text;
	tolua_property__common BlendFunc blendFunc;
	tolua_property__bool bool depthWrite;
	tolua_property__bool bool batched;
	tolua_property__common SpriteEffect* effect;
	tolua_readonly tolua_property__common int characterCount;
	tolua_outside Sprite* Label_getCharacter @ getCharacter(int index);
	static const float AutomaticWidth;
	static Label* create(String fontName, uint32_t fontSize);
};

class RenderTarget : public Object
{
	tolua_readonly tolua_property__common uint16_t width;
	tolua_readonly tolua_property__common uint16_t height;
	tolua_property__common Camera* camera;
	tolua_readonly tolua_property__common Texture2D* texture;
	void render(Node* target);
	void renderWithClear(Color color, float depth = 1.0f, uint8_t stencil = 0);
	void renderWithClear(Node* target, Color color, float depth = 1.0f, uint8_t stencil = 0);
	void saveAsync(String filename, tolua_function_void handler);
	static RenderTarget* create(uint16_t width, uint16_t height);
};

class ClipNode : public Node
{
	tolua_property__common Node* stencil;
	tolua_property__common float alphaThreshold;
	tolua_property__bool bool inverted;
	static ClipNode* create(Node* stencil = nullptr);
};

class DrawNode : public Node
{
	tolua_property__bool bool depthWrite;
	tolua_property__common BlendFunc blendFunc;
	void drawDot(Vec2 pos, float radius, Color color = Color::White);
	void drawSegment(Vec2 from, Vec2 to, float radius, Color color = Color::White);
	void drawPolygon(Vec2 verts[tolua_len], Color fillColor = Color::White, float borderWidth = 0.0f, Color borderColor = Color::White);
	void clear();
	static DrawNode* create();
};

class Line : public Node
{
	tolua_property__bool bool depthWrite;
	tolua_property__common BlendFunc blendFunc;
	void add(Vec2 verts[tolua_len], Color color = Color::White);
	void set(Vec2 verts[tolua_len], Color color = Color::White);
	void clear();
	static Line* create();
	static Line* create(Vec2 verts[tolua_len], Color color = Color::White);
};

class ParticleNode @ Particle : public Node
{
	tolua_readonly tolua_property__bool bool active;
	void start();
	void stop();
	static ParticleNode* create(String filename);
};

class Playable : public Node
{
	tolua_property__common string look;
	tolua_property__common float speed;
	tolua_property__common float recovery;
	tolua_property__bool bool fliped;
	tolua_readonly tolua_property__common string current;
	tolua_readonly tolua_property__common string lastCompleted;
	Vec2 getKeyPoint @ getKey(String name);
	float play(String name, bool loop = false);
	void stop();
	void setSlot(String name, Node* item);
	Node* getSlot(String name);
	static Playable* create(String filename);
};

class Model : public Playable
{
	tolua_property__bool bool reversed;
	tolua_readonly tolua_property__common float duration;
	tolua_readonly tolua_property__bool bool playing;
	tolua_readonly tolua_property__bool bool paused;
	bool hasAnimation(String name);
	void pause();
	void resume();
	void resume(String name, bool loop = false);
	void reset();
	void updateTo(float elapsed, bool reversed = false);
	Node* getNodeByName(String name);
	bool eachNode(tolua_function_bool func);
	static Model* create(String filename);
	static Model* dummy();

	static tolua_outside void Model_getClipFile @ getClipFile(String filename);
	static tolua_outside void Model_getLookNames @ getLooks(String filename);
	static tolua_outside void Model_getAnimationNames @ getAnimations(String filename);
};

class Spine : public Playable
{
	tolua_property__bool bool showDebug;
	tolua_property__bool bool hitTestEnabled;
	bool setBoneRotation(String name, float rotation);
	static Spine* create(String skelFile, String atlasFile);
	static Spine* create(String spineStr);
	static tolua_outside void Spine_getLookNames @ getLooks(String spineStr);
	static tolua_outside void Spine_getAnimationNames @ getAnimations(String spineStr);
};

class DragonBone : public Playable
{
	tolua_property__bool bool showDebug;
	tolua_property__bool bool hitTestEnabled;
	static DragonBone* create(String boneFile, String atlasFile);
	static DragonBone* create(String boneStr);
	static tolua_outside void DragonBone_getLookNames @ getLooks(String boneStr);
	static tolua_outside void DragonBone_getAnimationNames @ getAnimations(String boneStr);
};

class PhysicsWorld : public Node
{
	tolua_property__bool bool showDebug;
	bool query(Rect rect, tolua_function_bool handler);
	bool raycast(Vec2 start, Vec2 stop, bool closest, tolua_function_bool handler);
	void setIterations(int velocityIter, int positionIter);
	void setShouldContact(uint8_t groupA, uint8_t groupB, bool contact);
	bool getShouldContact(uint8_t groupA, uint8_t groupB);
	static float scaleFactor;
	static PhysicsWorld* create();
};

class FixtureDef : public Object {};

class BodyDef : public Object
{
	Vec2 offset @ position;
	float angleOffset @ angle;
	string face;
	Vec2 facePos;
	tolua_property__common float linearDamping;
	tolua_property__common float angularDamping;
	tolua_property__common Vec2 linearAcceleration;
	tolua_property__bool bool fixedRotation;
	tolua_property__bool bool bullet;
	static FixtureDef* polygon(
		Vec2 center,
		float width,
		float height,
		float angle = 0.0f,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	static FixtureDef* polygon(
		float width,
		float height,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	static FixtureDef* polygon(
		Vec2 vertices[tolua_len],
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	void attachPolygon(
		Vec2 center,
		float width,
		float height,
		float angle = 0.0f,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	void attachPolygon(
		float width,
		float height,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	void attachPolygon(
		Vec2 vertices[tolua_len],
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	static FixtureDef* multi(
		Vec2 vertices[tolua_len],
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	void attachMulti(
		Vec2 vertices[tolua_len],
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	static FixtureDef* disk(
		Vec2 center,
		float radius,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	static FixtureDef* disk(
		float radius,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	void attachDisk(
		Vec2 center,
		float radius,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	void attachDisk(
		float radius,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	static FixtureDef* chain(
		Vec2 vertices[tolua_len],
		float friction = 0.4f,
		float restitution = 0.0f);
	void attachChain(
		Vec2 vertices[tolua_len],
		float friction = 0.4f,
		float restitution = 0.0f);
	void attachPolygonSensor(
		int tag,
		float width,
		float height);
	void attachPolygonSensor(
		int tag,
		Vec2 center,
		float width,
		float height,
		float angle = 0.0f);
	void attachPolygonSensor(
		int tag,
		Vec2 vertices[tolua_len]);
	void attachDiskSensor(
		int tag,
		Vec2 center,
		float radius);
	void attachDiskSensor(
		int tag,
		float radius);
	static BodyDef* create();
};

class Sensor : public Object
{
	tolua_property__bool bool enabled;
	tolua_readonly tolua_property__common int tag;
	tolua_readonly tolua_property__common Body* owner;
	tolua_readonly tolua_property__bool bool sensed;
	tolua_readonly tolua_property__common Array* sensedBodies;
	bool contains(Body* body);
};

class Body : public Node
{
	tolua_readonly tolua_property__common PhysicsWorld* physicsWorld @ world;
	tolua_readonly tolua_property__common BodyDef* bodyDef;
	tolua_readonly tolua_property__common float mass;
	tolua_readonly tolua_property__bool bool sensor;
	tolua_property__common float velocityX;
	tolua_property__common float velocityY;
	tolua_property__common Vec2 velocity;
	tolua_property__common float angularRate;
	tolua_property__common uint8_t group;
	tolua_property__common float linearDamping;
	tolua_property__common float angularDamping;
	tolua_property__common Object* owner;
	tolua_property__bool bool receivingContact;
	void applyLinearImpulse(Vec2 impulse, Vec2 pos);
	void applyAngularImpulse(float impulse);
	Sensor* getSensorByTag(int tag);
	bool removeSensorByTag(int tag);
	bool removeSensor(Sensor* sensor);
	void attach(FixtureDef* fixtureDef);
	Sensor* attachSensor(int tag, FixtureDef* fixtureDef);
	void onContactFilter(tolua_function_bool handler);
	static Body* create(BodyDef* def, PhysicsWorld* world, Vec2 pos = Vec2::zero, float rot = 0.0f);
};

class JointDef : public Object
{
	Vec2 center;
	Vec2 position;
	float angle;
	static JointDef* distance(
		bool collision,
		String bodyA,
		String bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		float frequency = 0.0f,
		float damping = 0.0f);
	static JointDef* friction(
		bool collision,
		String bodyA,
		String bodyB,
		Vec2 worldPos,
		float maxForce,
		float maxTorque);
	static JointDef* gear(
		bool collision,
		String jointA,
		String jointB,
		float ratio = 1.0f);
	static JointDef* spring(
		bool collision,
		String bodyA,
		String bodyB,
		Vec2 linearOffset,
		float angularOffset,
		float maxForce,
		float maxTorque,
		float correctionFactor = 1.0f);
	static JointDef* prismatic(
		bool collision,
		String bodyA,
		String bodyB,
		Vec2 worldPos,
		float axisAngle,
		float lowerTranslation = 0.0f,
		float upperTranslation = 0.0f,
		float maxMotorForce = 0.0f,
		float motorSpeed = 0.0f);
	static JointDef* pulley(
		bool collision,
		String bodyA,
		String bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		Vec2 groundAnchorA,
		Vec2 groundAnchorB,
		float ratio = 1.0f);
	static JointDef* revolute(
		bool collision,
		String bodyA,
		String bodyB,
		Vec2 worldPos,
		float lowerAngle = 0.0f,
		float upperAngle = 0.0f,
		float maxMotorTorque = 0.0f,
		float motorSpeed = 0.0f);
	static JointDef* rope(
		bool collision,
		String bodyA,
		String bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		float maxLength);
	static JointDef* weld(
		bool collision,
		String bodyA,
		String bodyB,
		Vec2 worldPos,
		float frequency = 0.0f,
		float damping = 0.0f);
	static JointDef* wheel(
		bool collision,
		String bodyA,
		String bodyB,
		Vec2 worldPos,
		float axisAngle,
		float maxMotorTorque = 0.0f,
		float motorSpeed = 0.0f,
		float frequency = 2.0f,
		float damping = 0.7f);
};

class Joint : public Object
{
	static Joint* distance(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		float frequency = 0.0f,
		float damping = 0.0f);
	static Joint* friction(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 worldPos,
		float maxForce,
		float maxTorque);
	static Joint* gear(
		bool collision,
		Joint* jointA,
		Joint* jointB,
		float ratio = 1.0f);
	static Joint* spring(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 linearOffset,
		float angularOffset,
		float maxForce,
		float maxTorque,
		float correctionFactor = 1.0f);
	static MoveJoint* move(
		bool collision,
		Body* body,
		Vec2 targetPos,
		float maxForce,
		float frequency = 5.0f,
		float damping = 0.7f);
	static MotorJoint* prismatic(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 worldPos,
		float axisAngle,
		float lowerTranslation = 0.0f,
		float upperTranslation = 0.0f,
		float maxMotorForce = 0.0f,
		float motorSpeed = 0.0f);
	static Joint* pulley(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		Vec2 groundAnchorA,
		Vec2 groundAnchorB,
		float ratio = 1.0f);
	static MotorJoint* revolute(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 worldPos,
		float lowerAngle = 0.0f,
		float upperAngle = 0.0f,
		float maxMotorTorque = 0.0f,
		float motorSpeed = 0.0f);
	static Joint* rope(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		float maxLength);
	static Joint* weld(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 worldPos,
		float frequency = 0.0f,
		float damping = 0.0f);
	static MotorJoint* wheel(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 worldPos,
		float axisAngle,
		float maxMotorTorque = 0.0f,
		float motorSpeed = 0.0f,
		float frequency = 2.0f,
		float damping = 0.7f);
	tolua_readonly tolua_property__common PhysicsWorld* physicsWorld @ world;
	void destroy();
	static Joint* create(JointDef* def, Dictionary* itemDict);
};

class MoveJoint : public Joint
{
	tolua_property__common Vec2 position;
};

class MotorJoint : public Joint
{
	tolua_property__bool bool enabled;
	tolua_property__common float force;
	tolua_property__common float speed;
};

struct Cache
{
	static bool load(String filename);
	static void loadAsync(String filename, tolua_function_void callback);
	static void update(String filename, String content);
	static void update(String filename, Texture2D* texture);
	static void unload();
	static bool unload(String name);
	static void removeUnused();
	static void removeUnused(String type);
}

class Audio
{
	uint32_t play(String filename, bool loop = false);
	void stop(uint32_t handle);
	void playStream(String filename, bool loop = false, float crossFadeTime = 0.0f);
	void stopStream(float fadeTime = 0.0f);
	static tolua_outside Audio* Audio_shared @ create();
};

class Menu : public Node
{
	tolua_property__bool bool enabled;
	static Menu* create(float width, float height);
	static Menu* create();
};

class Keyboard
{
	bool isKeyDown(String name);
	bool isKeyUp(String name);
	bool isKeyPressed(String name);
	void updateIMEPosHint(Vec2 winPos);
	static tolua_outside Keyboard* Keyboard_shared @ create();
};

class Controller
{
	bool isButtonDown(int controllerId, String name);
	bool isButtonUp(int controllerId, String name);
	bool isButtonPressed(int controllerId, String name);
	float getAxis(int controllerId, String name);
	static tolua_outside Controller* Controller_shared @ create();
};

class SVGDef @ SVG : public Object
{
	tolua_readonly tolua_property__common float width;
	tolua_readonly tolua_property__common float height;
	void render();
	static SVGDef* from @ create(String filename);
};

class DB
{
	bool exist(String tableName, String schema = nullptr);
	static tolua_outside DB* DB_shared @ create();
};

class HttpServer
{
	tolua_readonly tolua_property__common string localIP;
	tolua_readonly tolua_property__common int wSConnectionCount @ wsConnectionCount;
	tolua_property__common string wWWPath @ wwwPath;
	bool start(int port);
	bool startWS(int port);
	void stop();
	static tolua_outside HttpServer* HttpServer_shared @ create();
};

namespace ML {

class QLearner : public Object
{
	void update(uint64_t state, uint32_t action, double reward);
	uint32_t getBestAction(uint64_t state);
	static QLearner* create(double gamma = 0.5, double alpha = 0.5, double maxQ = 100.0);
};

void BuildDecisionTreeAsync(String data, int maxDepth, tolua_function_void handleTree);

} // namespace ML

struct WasmRuntime @ Wasm
{
	static tolua_outside bool SharedWasmRuntime.executeMainFile @ executeMainFile(String filename);
	static tolua_outside void SharedWasmRuntime.executeMainFileAsync @ executeMainFileAsync(String filename, tolua_function_void handler);
	static tolua_outside void WasmRuntime_clear @ clear();
};

namespace Platformer {

class TargetAllow
{
	TargetAllow(uint32_t flag = 0);
	~TargetAllow();
	tolua_property__bool bool terrainAllowed;
	tolua_outside void TargetAllow_allow @ allow(String relation, bool allow);
	tolua_outside bool TargetAllow_isAllow @ isAllow(String relation);
	uint32_t toValue();
};

class Face : public Object
{
	void addChild(Face* face);
	Node* toNode();
	static Face* create(String faceStr, Vec2 point = Vec2::zero, float scale = 1.0f, float angle = 0.0f);
	static Face* create(tolua_function_Node* createFunc, Vec2 point = Vec2::zero, float scale = 1.0f, float angle = 0.0f);
};

class BulletDef : public Object
{
	string tag;
	string endEffect;
	float lifeTime;
	float damageRadius;
	tolua_property__bool bool highSpeedFix;
	tolua_property__common Vec2 gravity;
	tolua_property__common Face* face;
	tolua_readonly tolua_property__common BodyDef* bodyDef;
	tolua_readonly tolua_property__common Vec2 velocity;
	void setAsCircle(float radius);
	void setVelocity(float angle, float speed);
	static BulletDef* create();
};

class Unit;

class Bullet : public Body
{
	tolua_property__common uint32_t targetAllow;
	tolua_readonly tolua_property__bool bool faceRight;
	tolua_property__bool bool hitStop;
	tolua_readonly tolua_property__common Unit* emitter;
	tolua_readonly tolua_property__common BulletDef* bulletDef;
	tolua_property__common Node* face;
	void destroy();
	static Bullet* create(BulletDef* def, Unit* owner);
};

class Visual : public Node
{
	tolua_readonly tolua_property__bool bool playing;
	void start();
	void stop();
	Visual* autoRemove();
	static Visual* create(String name);
};

namespace Behavior {

class Blackboard
{
	tolua_readonly tolua_property__common double deltaTime;
	tolua_readonly tolua_property__common Unit* owner;
};

class Leaf : public Object { };

Leaf* Seq(Leaf* nodes[tolua_len]);
Leaf* Sel(Leaf* nodes[tolua_len]);
Leaf* Con(String name, tolua_function_bool handler);
Leaf* Act(String action);
Leaf* Command(String action);
Leaf* Wait(double duration);
Leaf* Countdown(double time, Leaf* node);
Leaf* Timeout(double time, Leaf* node);
Leaf* Repeat(int times, Leaf* node);
Leaf* Repeat(Leaf* node);
Leaf* Retry(int times, Leaf* node);
Leaf* Retry(Leaf* node);

} // namespace Behavior

namespace Decision {

class Leaf : public Object { };

Leaf* Sel(Leaf* nodes[tolua_len]);
Leaf* Seq(Leaf* nodes[tolua_len]);
Leaf* Con(String name, tolua_function_bool handler);
Leaf* Act(String action);
Leaf* Act(tolua_function_string handler);
Leaf* Accept();
Leaf* Reject();
Leaf* Behave(String name, Behavior::Leaf* root);

class AI
{
	tolua_outside Array* Platformer::AI_getUnitsByRelation @ getUnitsByRelation(String relation);
	Array* getDetectedUnits();
	Array* getDetectedBodies();
	tolua_outside Unit* Platformer::AI_getNearestUnit @ getNearestUnit(String relation);
	tolua_outside float Platformer::AI_getNearestUnitDistance @ getNearestUnitDistance(String relation);
	Array* getUnitsInAttackRange();
	Array* getBodiesInAttackRange();
	static tolua_outside AI* Platformer::AI_shared @ create();
};

} // namespace Decision

class UnitAction
{
	float reaction;
	float recovery;
	tolua_readonly tolua_property__common string name;
	tolua_readonly tolua_property__bool bool doing;
	tolua_readonly tolua_property__common Unit* owner;
	tolua_readonly tolua_property__common float elapsedTime;
	static tolua_outside void Platformer::LuaUnitAction_add @ add(
		String name,
		int priority,
		float reaction,
		float recovery,
		bool queued,
		tolua_function_bool available,
		tolua_function_LuaFunction<bool> create,
		tolua_function_void stop);
	static void clear();
};

class PlatformWorld;

class Unit : public Body
{
	enum
	{
		GroundSensorTag,
		DetectSensorTag,
		AttackSensorTag
	};
	tolua_property__common Playable* playable;
	tolua_property__common float detectDistance;
	tolua_property__common Size attackRange;
	tolua_property__bool bool faceRight;
	tolua_property__bool bool receivingDecisionTrace;
	tolua_property__common string decisionTreeName @ decisionTree;
	tolua_readonly tolua_property__bool bool onSurface;
	tolua_readonly tolua_property__common Sensor* groundSensor;
	tolua_readonly tolua_property__common Sensor* detectSensor;
	tolua_readonly tolua_property__common Sensor* attackSensor;
	tolua_readonly tolua_property__common Dictionary* unitDef;
	tolua_readonly tolua_property__common UnitAction* currentAction;
	tolua_readonly tolua_property__common float width;
	tolua_readonly tolua_property__common float height;
	tolua_readonly tolua_property__common Entity* entity;
	UnitAction* attachAction(String name);
	void removeAction(String name);
	void removeAllActions();
	UnitAction* getAction(String name);
	void eachAction(tolua_function_void func);
	bool start(String name);
	void stop();
	bool isDoing(String name);
	static Unit* create(Dictionary* unitDef, PhysicsWorld* physicsworld, Entity* entity, Vec2 pos, float rot = 0.0f);
	static Unit* create(String defName, String worldName, Entity* entity, Vec2 pos, float rot = 0.0f);
};

class PlatformCamera : public Camera
{
	tolua_property__common Vec2 position;
	tolua_property__common float rotation;
	tolua_property__common float zoom;
	tolua_property__common Rect boundary;
	tolua_property__common Vec2 followRatio;
	tolua_property__common Vec2 followOffset;
	tolua_property__common Node* followTarget;
	static PlatformCamera* create(String name = nullptr);
};

class PlatformWorld : public PhysicsWorld
{
	tolua_readonly tolua_property__common PlatformCamera* camera;
	void moveChild(Node* child, int newOrder);
	Node* getLayer(int order);
	void setLayerRatio(int order, Vec2 ratio);
	Vec2 getLayerRatio(int order);
	void setLayerOffset(int order, Vec2 offset);
	Vec2 getLayerOffset(int order);
	void swapLayer(int orderA, int orderB);
	void removeLayer(int order);
	void removeAllLayers();
	static PlatformWorld* create();
};

class Data
{
	tolua_readonly tolua_property__common uint8_t groupFirstPlayer;
	tolua_readonly tolua_property__common uint8_t groupLastPlayer;
	tolua_readonly tolua_property__common uint8_t groupHide;
	tolua_readonly tolua_property__common uint8_t groupDetectPlayer;
	tolua_readonly tolua_property__common uint8_t groupTerrain;
	tolua_readonly tolua_property__common uint8_t groupDetection;
	tolua_readonly tolua_property__common Dictionary* store;
	void setShouldContact(uint8_t groupA, uint8_t groupB, bool contact);
	bool getShouldContact(uint8_t groupA, uint8_t groupB);
	tolua_outside void Data_setRelation @ setRelation(uint8_t groupA, uint8_t groupB, String relation);
	tolua_outside Slice Data_getRelation @ getRelation(uint8_t groupA, uint8_t groupB);
	tolua_outside Slice Data_getRelation @ getRelation(Body* bodyA, Body* bodyB);
	bool isEnemy(uint8_t groupA, uint8_t groupB);
	bool isEnemy(Body* bodyA, Body* bodyB);
	bool isFriend(uint8_t groupA, uint8_t groupB);
	bool isFriend(Body* bodyA, Body* bodyB);
	bool isNeutral(uint8_t groupA, uint8_t groupB);
	bool isNeutral(Body* bodyA, Body* bodyB);
	void setDamageFactor(uint16_t damageType, uint16_t defenceType, float bounus);
	float getDamageFactor(uint16_t damageType, uint16_t defenceType);
	bool isPlayer(Body* body);
	bool isTerrain(Body* body);
	void clear();
	static tolua_outside Data* Platformer::Data_shared @ create();
};

} // namespace Platformer


