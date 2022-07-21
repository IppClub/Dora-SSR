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

class Entity
{
	static readonly common uint32_t count;
	readonly common int index;
	static void clear();
	void destroy();
	static Entity* create();
};

class EntityGroup @ Group
{
	readonly common int count;
	bool each(function<bool (Entity* e)> func);
	Entity* find(function<bool (Entity* e)> func);
	static EntityGroup* create(vector<string> components);
};

class EntityObserver @ Observer
{
	static outside EntityObserver* EntityObserver_create @ create(String option, vector<string> components);
};
