typedef Slice String;

class Application
{
	tolua_readonly tolua_property__common Size size;
	tolua_readonly tolua_property__common Size designSize;
	tolua_readonly tolua_property__common String platform;
	tolua_readonly tolua_property__common double eclapsedTime;
	tolua_property__common unsigned int seed;
	void shutdown();
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

class Entity : public Object
{
	tolua_readonly tolua_property__common int index;
	void destroy();
	static Entity* create();
};

class EntityGroup : public Object
{
	void each(tolua_function_bool func);
	static Entity* create(String components[tolua_len]);	
};

class EntityObserver : public Object
{
	void clear();
	void each(tolua_function_bool func);
	static tolua_outside EntityObserver* EntityObserver_create @ create(String option, String components[tolua_len]);
};

class Content
{
	tolua_readonly tolua_property__common string assetPath;
	tolua_readonly tolua_property__common string writablePath;
	void saveToFile @ save(String filename, String content);
	bool isExist @ exist(String filename);
	bool createFolder @ mkdir(String path);
    bool isFolder @ isdir(String path);
	bool removeFile @ remove(String path);
    string getFullPath(String filename);
	void insertSearchPath(int index, String path);
	void addSearchPath(String path);
	void removeSearchPath(String path);
	void loadFileAsync @ loadAsync(String filename, tolua_function handler);
	void saveToFileAsync @ saveAsync(String filename, String content, tolua_function handler);
	void copyFileAsync @ copyAsync(String src, String dst, tolua_function handler);
	tolua_outside void Content_getDirs @ getDirs(String path);
	tolua_outside void Content_getFiles @ getFiles(String path);
	tolua_outside void Content_loadFile @ load(String filename);
	tolua_outside void Content_setSearchPaths @ setSearchPaths(String paths[tolua_len]);
	static tolua_outside Content* Content_shared @ create();
};

class Listener @ GSlot : public 
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

class Camera : public Object
{
	tolua_readonly tolua_property__common string name;
};

class Director
{
	tolua_property__common Scheduler* scheduler;
	tolua_property__common Node* uI @ ui;
	tolua_property__common Node* postNode;
	tolua_property__common Camera* camera;
	tolua_property__bool bool displayStats;
	tolua_readonly tolua_property__common Scheduler* systemScheduler;
	tolua_readonly tolua_property__common Scheduler* postScheduler;
	tolua_readonly tolua_property__common Array* entries;
	tolua_readonly tolua_property__common Node* currentEntry;
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

struct Vec2
{
	float x;
	float y;
	tolua_readonly tolua_property__qt float length;
	tolua_readonly tolua_property__qt float lengthSquared;
	tolua_readonly tolua_property__qt float angle;
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
	static tolua_outside Vec2* Vec2_create @ create(float x = 0, float y = 0);
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
	static tolua_outside Size* Size_create @ create(float width = 0, float height = 0);
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
	bool fastRemove(Object* object);
	void swap(Object* objectA, Object* objectB);
	void reverse();
	void shrink();

	tolua_outside void Array_swap @ swap(int indexA, int indexB);
	tolua_outside int Array_index @ index(Object* object);
	tolua_outside void Array_set @ set(int index, Object* object);
	tolua_outside Object* Array_get @ get(int index);
	tolua_outside void Array_insert @ insert(int index, Object* object);
	tolua_outside bool Array_removeAt @ removeAt(int index);
	tolua_outside bool Array_fastRemoveAt @ fastRemoveAt(int index);
	tolua_outside bool Array_each @ each(tolua_function_bool func);

	static Array* create();
	static Array* create(Array* other);
	static Array* create(int capacity);
	static Array* create(Object* objects[tolua_len]);
};

class Dictionary : public Object
{
    tolua_readonly tolua_property__common int count;
	tolua_outside tolua_readonly tolua_property__qt Array* Dictionary_getKeys @ keys;
	bool each(tolua_function_bool func);
    void clear();
    static Dictionary* create();
}

class Slot : public Object
{
	void add(tolua_function handler);
	void set(tolua_function handler);
	void remove(tolua_function handler);
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
	void updateTo(float eclapsed, bool reversed = false);
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
	tolua_property__common Object* userData;
	tolua_readonly tolua_property__common Node* parent;
	tolua_readonly tolua_property__common Array* children;
	tolua_readonly tolua_property__common Rect boundingBox;
	tolua_readonly tolua_property__bool bool running;
	tolua_readonly tolua_property__bool bool updating;
	tolua_readonly tolua_property__bool bool scheduled;
	tolua_readonly tolua_property__common int actionCount;
	tolua_property__bool bool touchEnabled;
	tolua_property__bool bool swallowTouches;
	tolua_property__bool bool swallowMouseWheel;
	tolua_property__bool bool keyboardEnabled;
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

	void cleanup();

	Node* getChildByTag(String tag);

	void schedule(tolua_function_bool func);
	void unschedule();

	Vec2 convertToNodeSpace(Vec2 worldPoint);
	Vec2 convertToWorldSpace(Vec2 nodePoint);
	void convertToWindowSpace(Vec2 nodePoint, tolua_function callback);

	void scheduleUpdate();
	void unscheduleUpdate();

	tolua_outside bool Node_eachChild @ eachChild(tolua_function_bool func);
	bool traverse(tolua_function_bool func);

	void runAction(Action* action);
	void stopAllActions();
	void perform(Action* action);
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
	static Node* create();
};

class Texture2D : public Object
{
	tolua_readonly tolua_property__common int width;
	tolua_readonly tolua_property__common int height;
};

struct BlendFunc
{
	Uint32 src;
	Uint32 dst;
	BlendFunc(BlendFunc other);
	~BlendFunc();
	static tolua_outside BlendFunc* BlendFunc_create @ create(String src, String dst);
	static const BlendFunc Default;
};

struct TextureWrap
{
	enum {
		None,
		Mirror,
		Clamp,
		Border
	};
};
enum TextureWrap {};

struct TextureFilter
{
	enum {
		None,
		Point,
		Anisotropic
	};
};
enum TextureFilter {};

class Effect : public Object
{
	void set(String name, float var);
	void set(String name, float var1, float var2, float var3, float var4);
	static Effect* create(String vertShader, String fragShader);
};

class SpriteEffect : public Effect
{
	static SpriteEffect* create(String vertShader, String fragShader);
};

class Sprite : public Node
{
	tolua_property__bool bool depthWrite @ is3D;
	tolua_property__common float alphaRef;
	tolua_property__common Rect textureRect;
	tolua_property__common BlendFunc blendFunc;
	tolua_property__common TextureFilter filter;
	tolua_property__common TextureWrap uWrap @ uwrap;
	tolua_property__common TextureWrap vWrap @ vwrap;
	tolua_property__common SpriteEffect* effect;
	tolua_readonly tolua_property__common Texture2D* texture;
	static Sprite* create();
	static Sprite* create(Texture2D* texture, Rect textureRect);
	static Sprite* create(Texture2D* texture);
	static tolua_outside Sprite* Sprite_create @ create(String clipStr);
};

class Touch : public Object
{
	#define Touch::FromMouse @ FromMouse 
	#define Touch::FromTouch @ FromTouch
	#define Touch::FromMouseAndTouch @ FromMouseAndTouch
	tolua_property__bool bool enabled;
	tolua_readonly tolua_property__bool bool mouse @ fromMouse;
	tolua_readonly tolua_property__common int id;
	tolua_readonly tolua_property__common Vec2 delta;
	tolua_readonly tolua_property__common Vec2 location;
	tolua_readonly tolua_property__common Vec2 worldLocation;
	static Uint32 source;
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

class Camera2D : public Camera
{
	tolua_property__common float rotation;
	tolua_property__common float zoom;
	tolua_property__common Vec2 position;
	Camera2D* create(String name);
};

struct TextAlign
{
	enum {
		Left,
		Center,
		Right
	};
};
enum TextAlign {};

class Label : public Node
{
	tolua_property__common TextAlign alignment;
	tolua_property__common float alphaRef;
	tolua_property__common float textWidth;
	tolua_property__common float lineGap;
	tolua_property__common char* text;
	tolua_property__common BlendFunc blendFunc;
	tolua_property__bool bool depthWrite @ is3D;
	tolua_property__bool bool batched;
	tolua_property__common SpriteEffect* effect;
	tolua_readonly tolua_property__common int characterCount;
	tolua_outside Sprite* Label_getCharacter @ getCharacter(int index);
	static const float AutomaticWidth;
	static Label* create(String fontName, Uint32 fontSize);
};

class RenderTarget : public Node
{
	tolua_property__common Camera* camera;
	void render(Node* target);
	void renderWithClear(Node* target, Color color, float depth = 1.0f, Uint8 stencil = 0);
	void saveAsync(String filename, tolua_function handler);
	static RenderTarget* create(Uint16 width, Uint16 height);
};

class ClipNode : public Node
{
	tolua_property__common Node* stencil;
	tolua_property__common float alphaThreshold;
	tolua_property__bool bool inverted;
	static ClipNode* create(Node* stencil = nullptr);
};

struct VertexColor
{
	VertexColor(Vec2 vertex, Color color);
	~VertexColor();
};

class DrawNode : public Node
{
	tolua_property__bool bool depthWrite @ is3D;
	tolua_property__common BlendFunc blendFunc;
	void drawDot(Vec2 pos, float radius, Color color);
	void drawSegment(Vec2 from, Vec2 to, float radius, Color color);
	void drawPolygon(Vec2 verts[tolua_len], Color fillColor, float borderWidth = 0.0f, Color borderColor = Color());
	void drawPolygon(VertexColor verts[tolua_len]);
	void clear();
	static DrawNode* create();
};

class Line : public Node
{
	tolua_property__bool bool depthWrite @ is3D;
	tolua_property__common BlendFunc blendFunc;
	void add(Vec2 verts[tolua_len], Color color);
	void set(Vec2 verts[tolua_len], Color color);
	void clear();
	static Line* create();
	static Line* create(Vec2 verts[tolua_len], Color color);
};

class Model: public Node
{
	tolua_property__common string look;
	tolua_property__common float speed;
	tolua_property__bool bool loop;
	tolua_readonly tolua_property__common float duration;
	tolua_property__common float recovery;
	tolua_property__bool bool faceRight;
	tolua_property__bool bool reversed;
	tolua_readonly tolua_property__bool bool playing;
	tolua_readonly tolua_property__bool bool paused;
	tolua_readonly tolua_property__common string currentAnimationName @ currentAnimation;
	tolua_outside Vec2 Model_getKey @ getKey(String key);
	float play(String name);
	void pause();
	void resume();
	void resume(String name);
	void stop();
	void reset();
	void updateTo(float eclapsed, bool reversed = false);
	static tolua_outside Model* Model_create @ create(String filename);
	static Model* none();
	
	static tolua_outside void Model_getClipFile @ getClipFile(String filename);
	static tolua_outside void Model_getLookNames @ getLooks(String filename);
	static tolua_outside void Model_getAnimationNames @ getAnimations(String filename);
};

class World : public Node
{
	tolua_property__common Vec2 gravity;
	tolua_property__bool bool showDebug;
	void query(Rect rect, tolua_function_bool handler);
	void raycast(Vec2 start, Vec2 stop, bool closest, tolua_function_bool handler);
	void setIterations(int velocityIter, int positionIter);
	void setShouldContact(int groupA, int groupB, bool contact);
	bool getShouldContact(int groupA, int groupB);
	static float b2Factor;
	static World* create();
};

class FixtureDef {};

struct b2BodyType @ BodyType
{
	#define b2_staticBody @ Static
	#define b2_dynamicBody @ Dynamic
	#define b2_kinematicBody @ Kinematic
};
enum b2BodyType @ BodyType {};

class BodyDef : public Object
{
	b2BodyType type;
	float linearDamping;
	float angularDamping;
	bool fixedRotation;
	bool bullet @ isBullet;
	float gravityScale;
	Vec2 offset @ position;
	float angleOffset @ angle;
	string face;
	Vec2 facePos;
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
	static FixtureDef* loop(
		Vec2 vertices[tolua_len],
		float friction = 0.4f,
		float restitution = 0.0f);
	void attachLoop(
		Vec2 vertices[tolua_len],
		float friction = 0.4f,
		float restitution = 0.0f);
	static FixtureDef* circle(
		Vec2 center,
		float radius,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	static FixtureDef* circle(
		float radius,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	void attachCircle(
		Vec2 center,
		float radius,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	void attachCircle(
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
		float width,
		float height,
		Vec2 center,
		float angle = 0.0f);
	void attachPolygonSensor(
		int tag,
		Vec2 vertices[tolua_len]);
	void attachCircleSensor(
		int tag,
		Vec2 center,
		float radius);
	void attachCircleSensor(
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
	tolua_readonly tolua_property__common World* world;
	tolua_readonly tolua_property__common BodyDef* bodyDef;
	tolua_readonly tolua_property__common float mass;
	tolua_readonly tolua_property__bool bool sensor;
	tolua_property__common float velocityX;
	tolua_property__common float velocityY;
	tolua_property__common Vec2 velocity;
	tolua_property__common float angularRate;
	tolua_property__common int group;
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
	static tolua_outside Body* Body_create @ create(BodyDef* def, World* world, Vec2 pos = Vec2::zero, float rot = 0);
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
		Vec2 axis,
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
		Vec2 axis,
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
		Body* bodyA,
		Body* bodyB,
		Vec2 targetPos,
		float maxForce,
		float frequency = 5.0f,
		float damping = 0.7f);
	static MotorJoint* prismatic(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 worldPos,
		Vec2 axis,
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
		Vec2 axis,
		float maxMotorTorque = 0.0f,
		float motorSpeed = 0.0f,
		float frequency = 2.0f,
		float damping = 0.7f);
	tolua_readonly tolua_property__common World* world;
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
	static void loadAsync(String filename, tolua_function callback);
	static void update(String filename, String content);
	static void update(String filename, Texture2D* texture);
	static void unload();
	static bool unload(String name);
	static void removeUnused();
	static void removeUnused(String type);
}

class Audio
{
	Uint32 play(String filename, bool loop = false);
	void stop(Uint32 handle);
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
