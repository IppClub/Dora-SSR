object class Array
{
	readonly common size_t count;
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
	readonly common float devicePixelRatio;
	readonly common string platform;
	readonly common string version;
	readonly common string deps;
	readonly common double deltaTime;
	readonly common double elapsedTime;
	readonly common double totalTime;
	readonly common double runningTime;
	readonly common uint32_t rand;
	readonly common uint32_t maxFPS @ max_fps;
	readonly boolean bool debugging;
	common string locale;
	common Color themeColor;
	common uint32_t seed;
	common uint32_t targetFPS @ target_fps;
	common Size winSize;
	common Vec2 winPosition;
	boolean bool fPSLimited @ fpsLimited;
	boolean bool idled;
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
	static string getRelative(string path, string target);
	static string replaceExt(string path, string newExt);
	static string replaceFilename(string path, string newFile);
};

singleton class Content
{
	common VecStr searchPaths;
	readonly common string assetPath;
	readonly common string writablePath;
	bool save(string filename, string content);
	bool exist(string filename);
	bool createFolder @ mkdir(string path);
	bool isFolder @ isdir(string path);
	bool copy(string src, string dst);
	bool move @ moveTo(string src, string dst);
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
	void copyAsync(string srcFile, string targetFile, function<void(bool success)> callback);
	void saveAsync(string filename, string content, function<void(bool success)> callback);
	void zipAsync(string folderPath, string zipFile, function<bool(string file)> filter, function<void(bool success)> callback);
	void unzipAsync(string zipFile, string folderPath, function<bool(string file)> filter, function<void(bool success)> callback);
};

object class Scheduler
{
	common float timeScale;
	common int fixedFPS @ fixed_fps;
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
	common Color clearColor;
	common Scheduler* scheduler;
	readonly common Node* uI @ ui;
	readonly common Node* uI3D @ ui_3d;
	readonly common Node* entry;
	readonly common Node* postNode;
	readonly common Scheduler* systemScheduler;
	readonly common Scheduler* postScheduler;
	readonly common Camera* currentCamera;
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
	outside void view_set_post_effect_nullptr @ set_post_effect_null();
	boolean bool vSync @ vsync;
};

value class ActionDef { };

object class Action
{
	readonly common float duration;
	readonly boolean bool running;
	readonly boolean bool paused;
	boolean bool reversed;
	common float speed;
	void pause();
	void resume();
	void updateTo(float elapsed, bool reversed);
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
	static outside ActionDef action_def_emit @ event(string eventName, string msg);
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
	readonly boolean bool scheduled;
	readonly common int actionCount;
	readonly common Dictionary* userData @ data;
	boolean bool touchEnabled;
	boolean bool swallowTouches;
	boolean bool swallowMouseWheel;
	boolean bool keyboardEnabled;
	boolean bool controllerEnabled;
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

	outside void node_set_transform_target_nullptr @ set_transform_target_null();

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
	outside void sprite_set_effect_nullptr @ set_effect_as_default();
	static Sprite* create();
	static Sprite* create @ createTextureRect(Texture2D* texture, Rect textureRect);
	static Sprite* create @ createTexture(Texture2D* texture);
	static optional Sprite* from @ createFile(string clipStr);
};

object class Grid : public INode
{
	readonly common uint32_t gridX;
	readonly common uint32_t gridY;
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
	static optional Grid* from @ createFile(string clipStr, uint32_t gridX, uint32_t gridY);
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
	void saveAsync(string filename, function<void(bool success)> handler);
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
	void updateTo(float elapsed, bool reversed);
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
	bool setBoneRotation(string name, float rotation);
	string containsPoint(float x, float y);
	string intersectsSegment(float x1, float y1, float x2, float y2);
	static Spine* create @ createFiles(string skelFile, string atlasFile);
	static Spine* create(string spineStr);
	static outside VecStr spine_get_look_names @ getLooks(string spineStr);
	static outside VecStr spine_get_animation_names @ getAnimations(string spineStr);
};

object class DragonBone : public IPlayable
{
	boolean bool showDebug;
	boolean bool hitTestEnabled;
	string containsPoint(float x, float y);
	string intersectsSegment(float x1, float y1, float x2, float y2);
	static DragonBone* create @ createFiles(string boneFile, string atlasFile);
	static DragonBone* create(string boneStr);
	static outside VecStr dragon_bone_get_look_names @ getLooks(string boneStr);
	static outside VecStr dragon_bone_get_animation_names @ getAnimations(string boneStr);
};

interface object class PhysicsWorld : public INode
{
	boolean bool showDebug;
	bool query(Rect rect, function<bool(Body* body)> handler);
	bool raycast(Vec2 start, Vec2 stop, bool closest, function<bool(Body* body, Vec2 point, Vec2 normal)> handler);
	void setIterations(int velocityIter, int positionIter);
	void setShouldContact(uint8_t groupA, uint8_t groupB, bool contact);
	bool getShouldContact(uint8_t groupA, uint8_t groupB);
	static float scaleFactor;
	static PhysicsWorld* create();
};

object class FixtureDef { };

object class BodyDef
{
	Vec2 offset @ position;
	float angleOffset @ angle;
	string face;
	Vec2 facePos;
	common float linearDamping;
	common float angularDamping;
	common Vec2 linearAcceleration;
	boolean bool fixedRotation;
	boolean bool bullet;
	static FixtureDef* polygon @ polygonWithCenter(
		Vec2 center,
		float width,
		float height,
		float angle,
		float density,
		float friction,
		float restitution);
	static FixtureDef* polygon(
		float width,
		float height,
		float density,
		float friction,
		float restitution);
	static FixtureDef* polygon @ polygonWithVertices(
		VecVec2 vertices,
		float density,
		float friction,
		float restitution);
	void attachPolygon @ attachPolygonCenter(
		Vec2 center,
		float width,
		float height,
		float angle,
		float density,
		float friction,
		float restitution);
	void attachPolygon(
		float width,
		float height,
		float density,
		float friction,
		float restitution);
	void attachPolygon @ attachPolygonWithVertices(
		VecVec2 vertices,
		float density,
		float friction,
		float restitution);
	static FixtureDef* multi(
		VecVec2 vertices,
		float density,
		float friction,
		float restitution);
	void attachMulti(
		VecVec2 vertices,
		float density,
		float friction,
		float restitution);
	static FixtureDef* disk @ diskWithCenter(
		Vec2 center,
		float radius,
		float density,
		float friction,
		float restitution);
	static FixtureDef* disk(
		float radius,
		float density,
		float friction,
		float restitution);
	void attachDisk @ attachDiskWithCenter(
		Vec2 center,
		float radius,
		float density,
		float friction,
		float restitution);
	void attachDisk(
		float radius,
		float density,
		float friction,
		float restitution);
	static FixtureDef* chain(
		VecVec2 vertices,
		float friction,
		float restitution);
	void attachChain(
		VecVec2 vertices,
		float friction,
		float restitution);
	void attachPolygonSensor(
		int tag,
		float width,
		float height);
	void attachPolygonSensor @ attachPolygonSensorWithCenter(
		int tag,
		Vec2 center,
		float width,
		float height,
		float angle);
	void attachPolygonSensor @ attachPolygonSensorWithVertices(
		int tag,
		VecVec2 vertices);
	void attachDiskSensor @ attachDiskSensorWithCenter(
		int tag,
		Vec2 center,
		float radius);
	void attachDiskSensor(
		int tag,
		float radius);
	static BodyDef* create();
};

object class Sensor
{
	boolean bool enabled;
	readonly common int tag;
	readonly common Body* owner;
	readonly boolean bool sensed;
	readonly common Array* sensedBodies;
	bool contains(Body* body);
};

interface object class Body : public INode
{
	readonly common PhysicsWorld* physicsWorld @ world;
	readonly common BodyDef* bodyDef;
	readonly common float mass;
	readonly boolean bool sensor;
	common float velocityX;
	common float velocityY;
	common Vec2 velocity;
	common float angularRate;
	common uint8_t group;
	common float linearDamping;
	common float angularDamping;
	common Object* owner;
	boolean bool receivingContact;
	void applyLinearImpulse(Vec2 impulse, Vec2 pos);
	void applyAngularImpulse(float impulse);
	Sensor* getSensorByTag(int tag);
	bool removeSensorByTag(int tag);
	bool removeSensor(Sensor* sensor);
	void attach(FixtureDef* fixtureDef);
	Sensor* attachSensor(int tag, FixtureDef* fixtureDef);
	void onContactFilter(function<bool(Body* body)> filter);
	static Body* create(BodyDef* def, PhysicsWorld* world, Vec2 pos, float rot);
};

object class JointDef
{
	Vec2 center;
	Vec2 position;
	float angle;
	static JointDef* distance(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		float frequency,
		float damping);
	static JointDef* friction(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 worldPos,
		float maxForce,
		float maxTorque);
	static JointDef* gear(
		bool collision,
		string jointA,
		string jointB,
		float ratio);
	static JointDef* spring(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 linearOffset,
		float angularOffset,
		float maxForce,
		float maxTorque,
		float correctionFactor);
	static JointDef* prismatic(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 worldPos,
		float axisAngle,
		float lowerTranslation,
		float upperTranslation,
		float maxMotorForce,
		float motorSpeed);
	static JointDef* pulley(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		Vec2 groundAnchorA,
		Vec2 groundAnchorB,
		float ratio);
	static JointDef* revolute(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 worldPos,
		float lowerAngle,
		float upperAngle,
		float maxMotorTorque,
		float motorSpeed);
	static JointDef* rope(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		float maxLength);
	static JointDef* weld(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 worldPos,
		float frequency,
		float damping);
	static JointDef* wheel(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 worldPos,
		float axisAngle,
		float maxMotorTorque,
		float motorSpeed,
		float frequency,
		float damping);
};

interface object class Joint
{
	static Joint* distance(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		float frequency,
		float damping);
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
		float ratio);
	static Joint* spring(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 linearOffset,
		float angularOffset,
		float maxForce,
		float maxTorque,
		float correctionFactor);
	static MoveJoint* move @ moveTarget(
		bool collision,
		Body* body,
		Vec2 targetPos,
		float maxForce,
		float frequency,
		float damping);
	static MotorJoint* prismatic(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 worldPos,
		float axisAngle,
		float lowerTranslation,
		float upperTranslation,
		float maxMotorForce,
		float motorSpeed);
	static Joint* pulley(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		Vec2 groundAnchorA,
		Vec2 groundAnchorB,
		float ratio);
	static MotorJoint* revolute(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 worldPos,
		float lowerAngle,
		float upperAngle,
		float maxMotorTorque,
		float motorSpeed);
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
		float frequency,
		float damping);
	static MotorJoint* wheel(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 worldPos,
		float axisAngle,
		float maxMotorTorque,
		float motorSpeed,
		float frequency,
		float damping);
	readonly common PhysicsWorld* physicsWorld @ world;
	void destroy();
	static Joint* create(JointDef* def, Dictionary* itemDict);
};

object class MoveJoint : public IJoint
{
	common Vec2 position;
};

object class MotorJoint : public IJoint
{
	boolean bool enabled;
	common float force;
	common float speed;
};

singleton struct Cache
{
	static bool load(string filename);
	static void loadAsync(string filename, function<void()> callback);
	static void update @ updateItem(string filename, string content);
	static void update @ updateTexture(string filename, Texture2D* texture);
	static void unload();
	static bool unload @ unloadItemOrType(string name);
	static void removeUnused();
	static void removeUnused @ removeUnusedByType(string typeName);
};

singleton class Audio
{
	uint32_t play(string filename, bool looping);
	void stop(uint32_t handle);
	void playStream(string filename, bool looping, float crossFadeTime);
	void stopStream(float fadeTime);
};

singleton class Keyboard
{
	bool isKeyDown(string name);
	bool isKeyUp(string name);
	bool isKeyPressed(string name);
	void updateIMEPosHint(Vec2 winPos);
};

singleton class Controller
{
	bool isButtonDown(int controllerId, string name);
	bool isButtonUp(int controllerId, string name);
	bool isButtonPressed(int controllerId, string name);
	float getAxis(int controllerId, string name);
};

object class SVGDef @ SVG
{
	readonly common float width;
	readonly common float height;
	void render();
	static optional SVGDef* from @ create(string filename);
};

value struct DBParams
{
	void add(Array* params);
};

value struct DBRecord
{
	bool read(Array* record);
};

value struct DBQuery
{
	void addWithParams(string sql, DBParams params);
	void add(string sql);
};

singleton class DB
{
	bool exist(string tableName);
	bool exist @ existSchema(string tableName, string schema);
	int exec(string sql);
	outside bool db_do_transaction @ transaction(DBQuery query);
	outside void db_do_transaction_async @ transactionAsync(DBQuery query, function<void(bool result)> callback);
	outside DBRecord db_do_query @ query(string sql, bool withColumns);
	outside DBRecord db_do_query_with_params @ queryWithParams(string sql, Array* param, bool withColumns);
	outside void db_do_insert @ insert(string tableName, DBParams params);
	outside int32_t db_do_exec_with_records @ execWithRecords(string sql, DBParams params);
	outside void db_do_query_with_params_async @ queryWithParamsAsync(string sql, Array* param, bool withColumns, function<void(DBRecord result)> callback);
	outside void db_do_insert_async @ insertAsync(string tableName, DBParams params, function<void(bool result)> callback);
	outside void db_do_exec_async @ execAsync(string sql, DBParams params, function<void(int64_t rowChanges)> callback);
};

object class MLQLearner @ QLearner
{
	void update(MLQState state, MLQAction action, double reward);
	uint32_t getBestAction(MLQState state);
	outside void ml_qlearner_visit_state_action_q @ visitMatrix(function<void(MLQState state, MLQAction action, double q)> handler);
	static MLQState pack(VecUint32 hints, VecUint32 values);
	static VecUint32 unpack(VecUint32 hints, MLQState state);
	static QLearner* create(double gamma, double alpha, double maxQ);
};

singleton class C45
{
	static outside void MLBuildDecisionTreeAsync @ buildDecisionTreeAsync(string data, int maxDepth, function<void(double depth, string name, string op, string value)> treeVisitor);
};

namespace Platformer {

value class TargetAllow
{
	boolean bool terrainAllowed;
	void allow(Platformer::Relation relation, bool allow);
	bool isAllow(Platformer::Relation relation);
	uint32_t toValue();
	static Platformer::TargetAllow create();
	static Platformer::TargetAllow create @ createValue(uint32_t value);
};

object class Face
{
	void addChild(Platformer::Face* face);
	Node* toNode();
	static Face* create(string faceStr, Vec2 point, float scale, float angle);
	static Face* create @ createFunc(function<Node*()> createFunc, Vec2 point, float scale, float angle);
};

object class BulletDef
{
	string tag;
	string endEffect;
	float lifeTime;
	float damageRadius;
	boolean bool highSpeedFix;
	common Vec2 gravity;
	common Platformer::Face* face;
	readonly common BodyDef* bodyDef;
	readonly common Vec2 velocity;
	void setAsCircle(float radius);
	void setVelocity(float angle, float speed);
	static BulletDef* create();
};

object class Bullet : public IBody
{
	common uint32_t targetAllow;
	readonly boolean bool faceRight;
	boolean bool hitStop;
	readonly common Platformer::Unit* emitter;
	readonly common Platformer::BulletDef* bulletDef;
	common Node* face;
	void destroy();
	static Bullet* create(Platformer::BulletDef* def, Platformer::Unit* owner);
};

object class Visual : public INode
{
	readonly boolean bool playing;
	void start();
	void stop();
	Platformer::Visual* autoRemove();
	static Visual* create(string name);
};

namespace Behavior {

class Blackboard
{
	readonly common double deltaTime;
	readonly common Platformer::Unit* owner;
};

object class Leaf @ Tree
{
	static outside Platformer::Behavior::Leaf* BSeq @ seq(VecBTree nodes);
	static outside Platformer::Behavior::Leaf* BSel @ sel(VecBTree nodes);
	static outside Platformer::Behavior::Leaf* BCon @ con(string name, function<bool(Platformer::Behavior::Blackboard blackboard)> handler);
	static outside Platformer::Behavior::Leaf* BAct @ act(string action);
	static outside Platformer::Behavior::Leaf* BCommand @ command(string action);
	static outside Platformer::Behavior::Leaf* BWait @ wait(double duration);
	static outside Platformer::Behavior::Leaf* BCountdown @ countdown(double time, Platformer::Behavior::Leaf* node);
	static outside Platformer::Behavior::Leaf* BTimeout @ timeout(double time, Platformer::Behavior::Leaf* node);
	static outside Platformer::Behavior::Leaf* BRepeat @ repeat(int times, Platformer::Behavior::Leaf* node);
	static outside Platformer::Behavior::Leaf* BRepeat @ repeatForever(Platformer::Behavior::Leaf* node);
	static outside Platformer::Behavior::Leaf* BRetry @ retry(int times, Platformer::Behavior::Leaf* node);
	static outside Platformer::Behavior::Leaf* BRetry @ retryUntilPass(Platformer::Behavior::Leaf* node);
};

}

namespace Decision {

object class Leaf @ Tree
{
	static outside Platformer::Decision::Leaf* DSel @ sel(VecDTree nodes);
	static outside Platformer::Decision::Leaf* DSeq @ seq(VecDTree nodes);
	static outside Platformer::Decision::Leaf* DCon @ con(string name, function<bool(Platformer::Unit* unit)> handler);
	static outside Platformer::Decision::Leaf* DAct @ act(string action);
	static outside Platformer::Decision::Leaf* DAct @ actDynamic(function<string(Platformer::Unit* unit)> handler);
	static outside Platformer::Decision::Leaf* DAccept @ accept();
	static outside Platformer::Decision::Leaf* DReject @ reject();
	static outside Platformer::Decision::Leaf* DBehave @ behave(string name, Platformer::Behavior::Leaf* root);
};

singleton class AI
{
	Array* getUnitsByRelation(Platformer::Relation relation);
	Array* getDetectedUnits();
	Array* getDetectedBodies();
	Platformer::Unit* getNearestUnit(Platformer::Relation relation);
	float getNearestUnitDistance(Platformer::Relation relation);
	Array* getUnitsInAttackRange();
	Array* getBodiesInAttackRange();
};

}

value class WasmActionUpdate @ ActionUpdate
{
	static WasmActionUpdate create(function<bool(Platformer::Unit* owner, Platformer::UnitAction action, float deltaTime)> update);
};

class UnitAction
{
	float reaction;
	float recovery;
	readonly common string name;
	readonly boolean bool doing;
	readonly common Platformer::Unit* owner;
	readonly common float elapsedTime;
	static void clear();
	static outside void platformer_wasm_unit_action_add @ add(
		string name, int priority, float reaction, float recovery, bool queued,
		function<bool(Platformer::Unit* owner, Platformer::UnitAction action)> available,
		function<Platformer::WasmActionUpdate(Platformer::Unit* owner, Platformer::UnitAction action)> create,
		function<void(Platformer::Unit* owner, Platformer::UnitAction action)> stop);
};

object class Unit : public IBody
{
	common Playable* playable;
	common float detectDistance;
	common Size attackRange;
	boolean bool faceRight;
	boolean bool receivingDecisionTrace;
	common string decisionTreeName @ decisionTree;
	readonly boolean bool onSurface;
	readonly common Sensor* groundSensor;
	readonly common Sensor* detectSensor;
	readonly common Sensor* attackSensor;
	readonly common Dictionary* unitDef;
	readonly common Platformer::UnitAction currentAction;
	readonly common float width;
	readonly common float height;
	readonly common Entity* entity;
	Platformer::UnitAction attachAction(string name);
	void removeAction(string name);
	void removeAllActions();
	optional Platformer::UnitAction getAction(string name);
	void eachAction(function<void(Platformer::UnitAction action)> func);
	bool start(string name);
	void stop();
	bool isDoing(string name);
	static Unit* create(Dictionary* unitDef, PhysicsWorld* physicsworld, Entity* entity, Vec2 pos, float rot);
	static Unit* create @ createStore(string defName, string worldName, Entity* entity, Vec2 pos, float rot);
};

object class PlatformCamera : public ICamera
{
	common Vec2 position;
	common float rotation;
	common float zoom;
	common Rect boundary;
	common Vec2 followRatio;
	common Vec2 followOffset;
	optional common Node* followTarget;
	outside void platform_camera_set_follow_target_nullptr @ set_follow_target_null();
	static PlatformCamera* create(string name);
};

object class PlatformWorld : public IPhysicsWorld
{
	readonly common Platformer::PlatformCamera* camera;
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

singleton class Data
{
	readonly common uint8_t groupFirstPlayer;
	readonly common uint8_t groupLastPlayer;
	readonly common uint8_t groupHide;
	readonly common uint8_t groupDetectPlayer;
	readonly common uint8_t groupTerrain;
	readonly common uint8_t groupDetection;
	readonly common Dictionary* store;
	void setShouldContact(uint8_t groupA, uint8_t groupB, bool contact);
	bool getShouldContact(uint8_t groupA, uint8_t groupB);
	void setRelation(uint8_t groupA, uint8_t groupB, Platformer::Relation relation);
	Platformer::Relation getRelation @ getRelationByGroup(uint8_t groupA, uint8_t groupB);
	Platformer::Relation getRelation(Body* bodyA, Body* bodyB);
	bool isEnemy @ isEnemyGroup(uint8_t groupA, uint8_t groupB);
	bool isEnemy(Body* bodyA, Body* bodyB);
	bool isFriend @ isFriendGroup(uint8_t groupA, uint8_t groupB);
	bool isFriend(Body* bodyA, Body* bodyB);
	bool isNeutral @ isNeutralGroup(uint8_t groupA, uint8_t groupB);
	bool isNeutral(Body* bodyA, Body* bodyB);
	void setDamageFactor(uint16_t damageType, uint16_t defenceType, float bounus);
	float getDamageFactor(uint16_t damageType, uint16_t defenceType);
	bool isPlayer(Body* body);
	bool isTerrain(Body* body);
	void clear();
};

}

object class Buffer {
	void resize(uint32_t size);
	void zeroMemory();
	uint32_t size() const;
	void setString(string str);
	string toString();
};

singleton struct ImGui {

static void Binding::LoadFontTTFAsync @ load_font_ttf_async(
	string ttfFontFile,
	float fontSize,
	string glyphRanges,
	function<void(bool success)> handler);

static bool Binding::IsFontLoaded @ is_font_loaded();

static void Binding::ShowStats @ showStats();
static void Binding::ShowConsole @ showConsole();

static bool Binding::Begin @ begin(string name);

static bool Binding::Begin @ beginOpts(
	string name,
	VecStr windowsFlags);

static void End @ end();

static bool Binding::BeginChild @ beginChild(string str_id);

static bool Binding::BeginChild @ beginChildOpts(
	string str_id,
	Vec2 size,
	VecStr childFlags,
	VecStr windowFlags);

static bool Binding::BeginChild @ beginChildWith_id(uint32_t id);

static bool Binding::BeginChild @ beginChildWith_idOpts(
	uint32_t id,
	Vec2 size,
	VecStr childFlags,
	VecStr windowFlags);

static void EndChild @ endChild();

static void Binding::SetNextWindowPosCenter @ setNextWindowPosCenter();

static void Binding::SetNextWindowPosCenter @ setNextWindowPosCenterWithCond(string setCond);

static void Binding::SetNextWindowSize @ setNextWindowSize(Vec2 size);

static void Binding::SetNextWindowSize @ setNextWindowSizeWithCond(
	Vec2 size,
	string setCond);

static void Binding::SetNextWindowCollapsed @ setNextWindowCollapsed(bool collapsed);

static void Binding::SetNextWindowCollapsed @ setNextWindowCollapsedWithCond(
	bool collapsed,
	string setCond);

static void Binding::SetWindowPos @ setWindowPos(string name, Vec2 pos);

static void Binding::SetWindowPos @ setWindowPosWithCond(
	string name,
	Vec2 pos,
	string setCond);

static void Binding::SetWindowSize @ setWindowSize(
	string name,
	Vec2 size);

static void Binding::SetWindowSize @ setWindowSizeWithCond(
	string name,
	Vec2 size,
	string setCond);

static void Binding::SetWindowCollapsed @ setWindowCollapsed(
	string name,
	bool collapsed);

static void Binding::SetWindowCollapsed @ setWindowCollapsedWithCond(
	string name,
	bool collapsed,
	string setCond);

static void Binding::SetColorEditOptions @ setColorEditOptions(string colorEditMode);

static bool Binding::InputText @ inputText(
	string label,
	Buffer* buffer);

static bool Binding::InputText @ inputTextOpts(
	string label,
	Buffer* buffer,
	VecStr inputTextFlags);

static bool Binding::InputTextMultiline @ inputTextMultiline(
	string label,
	Buffer* buffer);

static bool Binding::InputTextMultiline @ inputTextMultilineOpts(
	string label,
	Buffer* buffer,
	Vec2 size,
	VecStr inputTextFlags);

static bool Binding::TreeNodeEx @ treeNodeEx(string label);

static bool Binding::TreeNodeEx @ treeNodeExOpts(
	string label,
	VecStr treeNodeFlags);

static bool Binding::TreeNodeEx @ treeNodeExWith_id(
	string str_id,
	string text);

static bool Binding::TreeNodeEx @ treeNodeExWith_idOpts(
	string str_id,
	string text,
	VecStr treeNodeFlags);

static void Binding::SetNextItemOpen @ setNextItemOpen(bool is_open);

static void Binding::SetNextItemOpen @ setNextItemOpenWithCond(
	bool is_open,
	string setCond);

static bool Binding::CollapsingHeader @ collapsingHeader(string label);

static bool Binding::CollapsingHeader @ collapsingHeaderOpts(
	string label,
	VecStr treeNodeFlags);

static bool Binding::Selectable @ selectable(string label);

static bool Binding::Selectable @ selectableOpts(
	string label,
	VecStr selectableFlags);

static bool Binding::BeginPopupModal @ beginPopupModal(string name);

static bool Binding::BeginPopupModal @ beginPopupModalOpts(
	string name,
	VecStr windowsFlags);

static bool Binding::BeginPopupContextItem @ beginPopupContextItem(string name);

static bool Binding::BeginPopupContextItem @ beginPopupContextItemOpts(
	string name,
	VecStr popupFlags);

static bool Binding::BeginPopupContextWindow @ beginPopupContextWindow(string name);

static bool Binding::BeginPopupContextWindow @ beginPopupContextWindowOpts(
	string name,
	VecStr popupFlags);

static bool Binding::BeginPopupContextVoid @ beginPopupContextVoid(string name);

static bool Binding::BeginPopupContextVoid @ beginPopupContextVoidOpts(
	string name,
	VecStr popupFlags);

static void Binding::PushStyleColor @ bushStyleColor(string name, Color color);
static void Binding::PushStyleVar @ pushStyleFloat(string name, float val);
static void Binding::PushStyleVar @ pushStyleVec2(string name, Vec2 val);

static void Binding::Text @ text(string text);
static void Binding::TextColored @ textColored(Color color, string text);
static void Binding::TextDisabled @ textDisabled(string text);
static void Binding::TextWrapped @ textWrapped(string text);

static void Binding::LabelText @ labelText(string label, string text);
static void Binding::BulletText @ bulletText(string text);
static bool Binding::TreeNode @ treeNode(string str_id, string text);
static void Binding::SetTooltip @ setTooltip(string text);

static void Binding::Image @ image(
	string clipStr,
	Vec2 size);

static void Binding::Image @ imageOpts(
	string clipStr,
	Vec2 size,
	Color tint_col,
	Color border_col);

static bool Binding::ImageButton @ imageButton(
	string str_id,
	string clipStr,
	Vec2 size);

static bool Binding::ImageButton @ imageButtonOpts(
	string str_id,
	string clipStr,
	Vec2 size,
	Color bg_col,
	Color tint_col);

static bool Binding::ColorButton @ colorButton(
	string desc_id,
	Color col);

static bool Binding::ColorButton @ colorButtonOpts(
	string desc_id,
	Color col,
	string flags,
	Vec2 size);

static void Binding::Columns @ columns(int count);

static void Binding::Columns @ columnsOpts(
	int count,
	bool border,
	string str_id);

static bool Binding::BeginTable @ beginTable(string str_id, int column);

static bool Binding::BeginTable @ beginTableOpts(
	string str_id,
	int column,
	Vec2 outer_size,
	float inner_width,
	VecStr tableFlags);

static void Binding::TableNextRow @ tableNextRow();

static void Binding::TableNextRow @ tableNextRowOpts(
	float min_row_height,
	string tableRowFlag);

static void Binding::TableSetupColumn @ tableSetupColumn(string label);

static void Binding::TableSetupColumn @ tableSetupColumnOpts(
	string label,
	float init_width_or_weight,
	uint32_t user_id,
	VecStr tableColumnFlags);

static void Binding::SetStyleVar @ setStyleBool(string name, bool var);
static void Binding::SetStyleVar @ setStyleFloat(string name, float var);
static void Binding::SetStyleVar @ setStyleVec2(string name, Vec2 var);
static void Binding::SetStyleColor @ setStyleColor(string name, Color color);

static bool Binding::Begin @ _begin(
	string name,
	CallStack* stack);

static bool Binding::Begin @ _beginOpts(
	string name,
	CallStack* stack,
	VecStr windowsFlags);

static bool Binding::CollapsingHeader @ _collapsingHeader(
	string label,
	CallStack* stack);

static bool Binding::CollapsingHeader @ _collapsingHeaderOpts(
	string label,
	CallStack* stack,
	VecStr treeNodeFlags);

static bool Binding::Selectable @ _selectable(
	string label,
	CallStack* stack);

static bool Binding::Selectable @ _selectableOpts(
	string label,
	CallStack* stack,
	Vec2 size,
	VecStr selectableFlags);

static bool Binding::BeginPopupModal @ _beginPopupModal(
	string name,
	CallStack* stack);

static bool Binding::BeginPopupModal @ _beginPopupModalOpts(
	string name,
	CallStack* stack,
	VecStr windowsFlags);

static bool Binding::Combo @ _combo(
	string label,
	CallStack* stack,
	VecStr items);

static bool Binding::Combo @ _comboOpts(
	string label,
	CallStack* stack,
	VecStr items,
	int height_in_items);

static bool Binding::DragFloat @ _dragFloat(
	string label,
	CallStack* stack,
	float v_speed,
	float v_min,
	float v_max);

static bool Binding::DragFloat @ _dragFloatOpts(
	string label,
	CallStack* stack,
	float v_speed,
	float v_min,
	float v_max,
	string display_format,
	VecStr sliderFlags);

static bool Binding::DragFloat2 @ _dragFloat2(
	string label,
	CallStack* stack,
	float v_speed,
	float v_min,
	float v_max);

static bool Binding::DragFloat2 @ _dragFloat2Opts(
	string label,
	CallStack* stack,
	float v_speed,
	float v_min,
	float v_max,
	string display_format,
	VecStr sliderFlags);

static bool Binding::DragInt @ _dragInt(
	string label,
	CallStack* stack,
	float v_speed,
	int v_min,
	int v_max);

static bool Binding::DragInt @ _dragIntOpts(
	string label,
	CallStack* stack,
	float v_speed,
	int v_min,
	int v_max,
	string display_format,
	VecStr sliderFlags);

static bool Binding::DragInt2 @ _dragInt2(
	string label,
	CallStack* stack,
	float v_speed,
	int v_min,
	int v_max);

static bool Binding::DragInt2 @ _dragInt2Opts(
	string label,
	CallStack* stack,
	float v_speed,
	int v_min,
	int v_max,
	string display_format,
	VecStr sliderFlags);

static bool Binding::InputFloat @ _inputFloat(
	string label,
	CallStack* stack);

static bool Binding::InputFloat @ _inputFloatOpts(
	string label,
	CallStack* stack,
	float step,
	float step_fast,
	string display_format,
	VecStr inputTextFlags);

static bool Binding::InputFloat2 @ _inputFloat2(
	string label,
	CallStack* stack);

static bool Binding::InputFloat2 @ _inputFloat2Opts(
	string label,
	CallStack* stack,
	string display_format,
	VecStr inputTextFlags);

static bool Binding::InputInt @ _inputInt(
	string label,
	CallStack* stack);

static bool Binding::InputInt @ _inputIntOpts(
	string label,
	CallStack* stack,
	int step,
	int step_fast,
	VecStr inputTextFlags);

static bool Binding::InputInt2 @ _inputInt2(
	string label,
	CallStack* stack);

static bool Binding::InputInt2 @ _inputInt2Opts(
	string label,
	CallStack* stack,
	VecStr inputTextFlags);

static bool Binding::SliderFloat @ _sliderFloat(
	string label,
	CallStack* stack,
	float v_min,
	float v_max);

static bool Binding::SliderFloat @ _sliderFloatOpts(
	string label,
	CallStack* stack,
	float v_min,
	float v_max,
	string display_format,
	VecStr sliderFlags);

static bool Binding::SliderFloat2 @ _sliderFloat2(
	string label,
	CallStack* stack,
	float v_min,
	float v_max);

static bool Binding::SliderFloat2 @ _sliderFloat2Opts(
	string label,
	CallStack* stack,
	float v_min,
	float v_max,
	string display_format,
	VecStr sliderFlags);

static bool Binding::SliderInt @ _sliderInt(
	string label,
	CallStack* stack,
	int v_min,
	int v_max);

static bool Binding::SliderInt @ _sliderIntOpts(
	string label,
	CallStack* stack,
	int v_min,
	int v_max,
	string format,
	VecStr sliderFlags);

static bool Binding::SliderInt2 @ _sliderInt2(
	string label,
	CallStack* stack,
	int v_min,
	int v_max);

static bool Binding::SliderInt2 @ _sliderInt2Opts(
	string label,
	CallStack* stack,
	int v_min,
	int v_max,
	string display_format,
	VecStr sliderFlags);

static bool Binding::DragFloatRange2 @ _dragFloatRange2(
	string label,
	CallStack* stack,
	float v_speed,
	float v_min,
	float v_max);

static bool Binding::DragFloatRange2 @ _dragFloatRange2Opts(
	string label,
	CallStack* stack,
	float v_speed,
	float v_min,
	float v_max,
	string format,
	string format_max,
	VecStr sliderFlags);

static bool Binding::DragIntRange2 @ _dragIntRange2(
	string label,
	CallStack* stack,
	float v_speed,
	int v_min,
	int v_max);

static bool Binding::DragIntRange2 @ _dragIntRange2Opts(
	string label,
	CallStack* stack,
	float v_speed,
	int v_min,
	int v_max,
	string format,
	string format_max,
	VecStr sliderFlags);

static bool Binding::VSliderFloat @ _vSliderFloat(
	string label,
	Vec2 size,
	CallStack* stack,
	float v_min,
	float v_max);

static bool Binding::VSliderFloat @ _vSliderFloatOpts(
	string label,
	Vec2 size,
	CallStack* stack,
	float v_min,
	float v_max,
	string format,
	VecStr sliderFlags);

static bool Binding::VSliderInt @ _vSliderInt(
	string label,
	Vec2 size,
	CallStack* stack,
	int v_min,
	int v_max);

static bool Binding::VSliderInt @ _vSliderIntOpts(
	string label,
	Vec2 size,
	CallStack* stack,
	int v_min,
	int v_max,
	string format,
	VecStr sliderFlags);

static bool Binding::ColorEdit3 @ _colorEdit3(string label, CallStack* stack);

static bool Binding::ColorEdit4 @ _colorEdit4(string label, CallStack* stack, bool show_alpha);
};
