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
	static readonly qt Rect zero;
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
	static EntityGroup* create(VecStr components);
};

object class EntityObserver @ Observer
{
};

singleton class Director
{
	boolean bool displayStats @ statsDisplay;
	readonly common Node* uI @ ui;
	readonly common Node* uI3D @ ui3d;
	readonly common Node* entry;
	readonly common Node* postNode;
	readonly common double deltaTime;
	void popCamera();
	void clearCamera();
	void cleanup();
};

singleton class Content
{
	common VecStr searchPaths;
};

