object class Array
{
	readonly common size_t count;
	readonly common size_t capacity;
	readonly boolean bool empty;
	void addRange(Array* other);
	void removeFrom(Array* other);
	void clear();
	void reverse();
	void shrink();
	void swap(int indexA, int indexB);
	bool removeAt(int index);
	bool fastRemoveAt(int index);
	static Array* create();
};

object class Dictionary
{
	readonly common int count;
	readonly common VecStr keys;
	void clear();
	static Dictionary* create();
};

value struct Rect
{
	Vec2 origin;
	Size size;
	common float x;
	common float y;
	common float width;
	common float height;
	common float left;
	common float right;
	common float centerX;
	common float centerY;
	common float bottom;
	common float top;
	common Vec2 lowerBound;
	common Vec2 upperBound;
	void set(float x, float y, float width, float height);
	bool containsPoint(Vec2 point) const;
	bool intersectsRect(Rect rect) const;
	bool operator== @ equals(Rect other) const;
	static Rect create(Vec2 origin, Size size);
	static outside Rect rect_get_zero @ zero();
};

singleton class Application @ App
{
	readonly common uint32_t frame;
	readonly common Size bufferSize;
	readonly common Size visualSize;
	readonly common float deviceRatio;
	readonly common string platform;
	readonly common string version;
	readonly common string deps;
	readonly common double eclapsedTime;
	readonly common double totalTime;
	readonly common double runningTime;
	readonly common uint32_t rand;
	readonly boolean bool debugging;
	common uint32_t seed;
	void shutdown();
};

object class Entity
{
	static readonly common uint32_t count;
	readonly common int index;
	static void clear();
	void remove(string key);
	void destroy();
	static Entity* create();
};

object class EntityGroup @ Group
{
	readonly common int count;
	optional Entity* find(function<bool(Entity* e)> func) const;
	static EntityGroup* create(VecStr components);
};

object class EntityObserver @ Observer
{
	static EntityObserver* create(EntityEvent event, VecStr components);
};

struct Path
{
	static string getExt(string path);
	static string getPath(string path);
	static string getName(string path);
	static string getFilename(string path);
	static string replaceExt(string path, string newExt);
	static string replaceFilename(string path, string newFile);
};

singleton class Content
{
	common VecStr searchPaths;
	readonly common string assetPath;
	readonly common string writablePath;
	void save(string filename, string content);
	bool exist(string filename);
	bool createFolder @ mkdir(string path);
	bool isFolder @ isdir(string path);
	bool remove(string path);
	string getFullPath(string filename);
	void addSearchPath(string path);
	void insertSearchPath(int index, string path);
	void removeSearchPath(string path);
	void clearPathCache();
	VecStr getDirs(string path);
	VecStr getFiles(string path);
	VecStr getAllFiles(string path);
	void loadAsync(string filename, function<void(string content)> callback);
	void copyAsync(string srcFile, string targetFile, function<void()> callback);
	void saveAsync(string filename, string content, function<void()> callback);
};

object class Scheduler
{
	common float timeScale;
	void schedule(function<bool(double deltaTime)> func);
	static Scheduler* create();
};

interface object class Camera
{
	readonly common string name;
};

object class Camera2D : public ICamera
{
	common float rotation;
	common float zoom;
	common Vec2 position;
	static Camera2D* create(string name);
};

object class CameraOtho : public ICamera
{
	common Vec2 position;
	static CameraOtho* create(string name);
};

object class Pass
{
	boolean bool grabPass;
	void set @ set(string name, float var);
	void set @ setVec4(string name, float var1, float var2, float var3, float var4);
	void set @ setColor(string name, Color var);
	static Pass* create(string vertShader, string fragShader);
};

interface object class Effect
{
	void add(Pass* pass);
	outside optional Pass* effect_get_pass @ get(size_t index) const;
	void clear();
	static Effect* create(string vertShader, string fragShader);
};

object class SpriteEffect : public IEffect
{
	static SpriteEffect* create(string vertShader, string fragShader);
};

singleton class Director
{
	boolean bool displayStats @ statDisplay;
	common Color clearColor;
	common Scheduler* scheduler;
	readonly common Node* uI @ ui;
	readonly common Node* uI3D @ ui_3d;
	readonly common Node* entry;
	readonly common Node* postNode;
	readonly common Scheduler* systemScheduler;
	readonly common Scheduler* postScheduler;
	readonly common Camera* currentCamera;
	readonly common double deltaTime;
	void pushCamera(Camera* camera);
	void popCamera();
	bool removeCamera(Camera* camera);
	void clearCamera();
	void cleanup();
};

singleton class View
{
	readonly common Size size;
	readonly common float standardDistance;
	readonly common float aspectRatio;
	common float nearPlaneDistance;
	common float farPlaneDistance;
	common float fieldOfView;
	common float scale;
	optional common SpriteEffect* postEffect;
	boolean bool vSync @ vsync;
};

value class ActionDef
{
};

object class Action
{
	readonly common float duration;
	readonly boolean bool running;
	readonly boolean bool paused;
	boolean bool reversed;
	common float speed;
	void pause();
	void resume();
	void updateTo(float eclapsed, bool reversed);
	static outside ActionDef action_def_prop @ prop(float duration, float start, float stop,
		Property prop, EaseType easing);
	static outside ActionDef action_def_tint @ tint(float duration, Color3 start, Color3 stop,
		EaseType easing);
	static outside ActionDef action_def_roll @ roll(float duration, float start, float stop,
		EaseType easing);
	static outside ActionDef action_def_spawn @ spawn(VecActionDef defs);
	static outside ActionDef action_def_sequence @ sequence(VecActionDef defs);
	static outside ActionDef action_def_delay @ delay(float duration);
	static outside ActionDef action_def_show @ show();
	static outside ActionDef action_def_hide @ hide();
	static outside ActionDef action_def_emit @ emit(string eventName, string msg);
	static outside ActionDef action_def_move @ move_to(float duration, Vec2 start, Vec2 stop,
		EaseType easing);
	static outside ActionDef action_def_scale @ scale(float duration, float start, float stop,
		EaseType easing);
};

object class Grabber
{
	optional common Camera* camera;
	optional common SpriteEffect* effect;
	common BlendFunc blendFunc;
	common Color clearColor;
	void setPos(int x, int y, Vec2 pos, float z);
	Vec2 getPos(int x, int y) const;
	void setColor(int x, int y, Color color);
	Color getColor(int x, int y) const;
	void moveUV @ move_uv(int x, int y, Vec2 offset);
};

interface object class Node
{
	common int order;
	common float angle;
	common float angleX;
	common float angleY;
	common float scaleX;
	common float scaleY;
	common float x;
	common float y;
	common float z;
	common Vec2 position;
	common float skewX;
	common float skewY;
	boolean bool visible;
	common Vec2 anchor;
	common float width;
	common float height;
	common Size size;
	common string tag;
	common float opacity;
	common Color color;
	common Color3 color3;
	boolean bool passOpacity;
	boolean bool passColor3;
	optional common Node* transformTarget;
	common Scheduler* scheduler;
	optional readonly common Array* children;
	optional readonly common Node* parent;
	readonly common Rect boundingBox;
	readonly boolean bool running;
	readonly boolean bool updating;
	readonly boolean bool scheduled;
	readonly common int actionCount;
	readonly common Dictionary* userData @ data;
	boolean bool touchEnabled;
	boolean bool swallowTouches;
	boolean bool swallowMouseWheel;
	boolean bool keyboardEnabled;
	boolean bool renderGroup;
	common int renderOrder;

	void addChild @ addChildWithOrderTag(Node* child, int order, string tag);
	void addChild @ addChildWithOrder(Node* child, int order);
	void addChild(Node* child);

	Node* addTo @ addToWithOrderTag(Node* parent, int order, string tag);
	Node* addTo @ addToWithOrder(Node* parent, int order);
	Node* addTo(Node* parent);

	void removeChild(Node* child, bool cleanup);
	void removeChildByTag(string tag, bool cleanup);
	void removeAllChildren(bool cleanup);
	void removeFromParent(bool cleanup);
	void moveToParent(Node* parent);

	void cleanup();

	optional Node* getChildByTag(string tag);

	void schedule(function<bool(double deltaTime)> func);
	void unschedule();

	Vec2 convertToNodeSpace(Vec2 worldPoint);
	Vec2 convertToWorldSpace(Vec2 nodePoint);
	void convertToWindowSpace(Vec2 nodePoint, function<void(Vec2 result)> callback);

	bool eachChild(function<bool(Node* child)> func);
	bool traverse(function<bool(Node* child)> func);
	bool traverseAll(function<bool(Node* child)> func);

	outside optional Action* node_run_action_def @ run_action(ActionDef def);
	void stopAllActions();
	outside optional Action* node_perform_def @ perform(ActionDef def);
	void stopAction(Action* action);

	Size alignItemsVertically(float padding);
	Size alignItemsVertically @ alignItemsVerticallyWithSize(Size size, float padding);
	Size alignItemsHorizontally(float padding);
	Size alignItemsHorizontally @ alignItemsHorizontallyWithSize(Size size, float padding);
	Size alignItems(float padding);
	Size alignItems @ alignItemsWithSize(Size size, float padding);
	void moveAndCullItems(Vec2 delta);

	void attachIME @ attach_ime();
	void detachIME @ detach_ime();

	outside Grabber* node_start_grabbing @ grab();
	Grabber* grab @ grabWithSize(uint32_t gridX, uint32_t gridY);
	outside void node_stop_grabbing @ stop_grab();

	bool slot(string name, function<void(Event* e)> func);
	bool gslot(string name, function<void(Event* e)> func);

	static Node* create();
};

object class Texture2D
{
	readonly common int width;
	readonly common int height;
};

object class Sprite : public INode
{
	boolean bool depthWrite;
	common float alphaRef;
	common Rect textureRect;
	optional readonly common Texture2D* texture;
	common BlendFunc blendFunc;
	common SpriteEffect* effect;
	common TextureWrap uWrap @ uwrap;
	common TextureWrap vWrap @ vwrap;
	common TextureFilter filter;
	static Sprite* create();
	static Sprite* create @ createTextureRect(Texture2D* texture, Rect textureRect);
	static Sprite* create @ createTexture(Texture2D* texture);
	static outside optional Sprite* sprite_create @ createFile(string clipStr);
};

object class Grid : public INode
{
	boolean bool depthWrite;
	common BlendFunc blendFunc;
	common SpriteEffect* effect;
	common Rect textureRect;
	optional common Texture2D* texture;
	void setPos(int x, int y, Vec2 pos, float z);
	Vec2 getPos(int x, int y) const;
	void setColor(int x, int y, Color color);
	Color getColor(int x, int y) const;
	void moveUV @ move_uv(int x, int y, Vec2 offset);
	static Grid* create(float width, float height, uint32_t gridX, uint32_t gridY);
	static Grid* create @ createTextureRect(Texture2D* texture, Rect textureRect, uint32_t gridX, uint32_t gridY);
	static Grid* create @ createTexture(Texture2D* texture, uint32_t gridX, uint32_t gridY);
	static outside optional Grid* grid_create @ createFile(string clipStr, uint32_t gridX, uint32_t gridY);
};

object class Touch
{
	boolean bool enabled;
	readonly boolean bool mouse @ fromMouse;
	readonly boolean bool first;
	readonly common int id;
	readonly common Vec2 delta;
	readonly common Vec2 location;
	readonly common Vec2 worldLocation;
};

singleton struct Ease
{
	static float func(EaseType easing, float time);
};

object class Label : public INode
{
	common TextAlign alignment;
	common float alphaRef;
	common float textWidth;
	common float spacing;
	common float lineGap;
	common string text;
	common BlendFunc blendFunc;
	boolean bool depthWrite;
	boolean bool batched;
	common SpriteEffect* effect;
	readonly common int characterCount;
	optional Sprite* getCharacter(int index);
	static readonly float AutomaticWidth @ automaticWidth;
	static Label* create(string fontName, uint32_t fontSize);
};

object class RenderTarget
{
	readonly common uint16_t width;
	readonly common uint16_t height;
	optional common Camera* camera;
	readonly common Texture2D* texture;
	void render(Node* target);
	void renderWithClear @ renderClear(Color color, float depth, uint8_t stencil);
	void renderWithClear @ renderClearWithTarget(Node* target, Color color, float depth, uint8_t stencil);
	void saveAsync(string filename, function<void()> handler);
	static RenderTarget* create(uint16_t width, uint16_t height);
};

object class ClipNode : public INode
{
	common Node* stencil;
	common float alphaThreshold;
	boolean bool inverted;
	static ClipNode* create(Node* stencil);
};

value struct VertexColor
{
	Vec2 vertex;
	Color color;
	static VertexColor create(Vec2 vec, Color color);
};

object class DrawNode : public INode
{
	boolean bool depthWrite;
	common BlendFunc blendFunc;
	void drawDot(Vec2 pos, float radius, Color color);
	void drawSegment(Vec2 from, Vec2 to, float radius, Color color);
	void drawPolygon(VecVec2 verts, Color fillColor, float borderWidth, Color borderColor);
	void drawVertices(VecVertexColor verts);
	void clear();
	static DrawNode* create();
};

object class Line : public INode
{
	boolean bool depthWrite;
	common BlendFunc blendFunc;
	void add(VecVec2 verts, Color color);
	void set(VecVec2 verts, Color color);
	void clear();
	static Line* create();
	static Line* create @ createVecColor(VecVec2 verts, Color color);
};

object class ParticleNode @ Particle : public INode
{
	readonly boolean bool active;
	void start();
	void stop();
	static optional ParticleNode* create(string filename);
};

interface object class Playable : public INode
{
	common string look;
	common float speed;
	common float recovery;
	boolean bool fliped;
	readonly common string current;
	readonly common string lastCompleted;
	Vec2 getKeyPoint @ getKey(string name);
	float play(string name, bool looping);
	void stop();
	void setSlot(string name, Node* item);
	optional Node* getSlot(string name);
	static optional Playable* create(string filename);
};

object class Model : public IPlayable
{
	readonly common float duration;
	boolean bool reversed;
	readonly boolean bool playing;
	readonly boolean bool paused;
	bool hasAnimation(string name);
	void pause();
	void resume();
	void resume @ resumeAnimation(string name, bool looping);
	void reset();
	void updateTo(float eclapsed, bool reversed);
	Node* getNodeByName(string name);
	bool eachNode(function<bool(Node* node)> func);
	static Model* create(string filename);
	static outside string model_get_clip_filename @ getClipFile(string filename);	
	static outside VecStr model_get_look_names @ getLooks(string filename);
	static outside VecStr model_get_animation_names @ getAnimations(string filename);
};

object class Spine : public IPlayable
{
	boolean bool showDebug;
	boolean bool hitTestEnabled;
	string containsPoint(float x, float y);
	string intersectsSegment(float x1, float y1, float x2, float y2);
	static Spine* create @ createFiles(string skelFile, string atlasFile);
	static Spine* create(string spineStr);
	static outside void spine_get_look_names @ getLooks(string spineStr);
	static outside void spine_get_animation_names @ getAnimations(string spineStr);
};

object class DragonBone : public IPlayable
{
	boolean bool showDebug;
	boolean bool hitTestEnabled;
	string containsPoint(float x, float y);
	string intersectsSegment(float x1, float y1, float x2, float y2);
	static DragonBone* create @ createFiles(string boneFile, string atlasFile);
	static DragonBone* create(string boneStr);
	static outside void dragon_bone_get_look_names @ getLooks(string boneStr);
	static outside void dragon_bone_get_animation_names @ getAnimations(string boneStr);
};

