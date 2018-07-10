#pragma once
#include "Basic/Object.h"
#include "Entity/Component.h"

NS_DOROTHY_BEGIN

class Dictionary;
class Entity;

typedef Delegate<void(Entity*)> EntityHandler;

class Entity : public Object
{
public:
	enum
	{
		Add,
		Change,
		AddOrChange,
		Remove
	};
	Entity(int index);
	virtual ~Entity();
	virtual bool init() override;
	PROPERTY_READONLY(int, Index);
	void destroy();
	bool has(String name) const;
	void remove(String name);
	static Entity* create();
	static bool each(const function<bool(Entity*)>& func);
	static void clear();
	Com* getComponent(String name) const;
	Com* getCachedCom(String name) const;
	void clearComCache();
public:
	template<typename T>
	void set(String name, const T& value, bool rawFlag = false);
	template<typename T>
	const T& get(String name) const;
protected:
	void updateComponent(String name, Own<Com>&& com, bool add);
private:
	int _index;
	unordered_map<string, Own<Com>> _components;
	unordered_map<string, Own<Com>> _comCache;
	DORA_TYPE_OVERRIDE(Entity);
};

struct WRefEntityHasher
{
	std::hash<Entity*> hash;
	inline size_t operator () (const WRef<Entity>& entity) const
	{
		return hash(entity.get());
	}
};

class EntityGroup : public Object
{
public:
	EntityGroup(const vector<string>& components);
	virtual ~EntityGroup();
	virtual bool init() override;
	static EntityGroup* create(const vector<string>& components);
	static EntityGroup* create(Slice components[], int count);
public:
	template<typename Func>
	bool each(const Func& func);
	EntityGroup* every(const EntityHandler& handler);
public:
	void onAdd(Entity* entity);
	void onRemove(Entity* entity);
private:
	unordered_set<WRef<Entity>, WRefEntityHasher> _entities;
	vector<string> _components;
	DORA_TYPE_OVERRIDE(EntityGroup);
};

class EntityObserver : public Object
{
public:
	EntityObserver(int option, const vector<string>& components);
	virtual ~EntityObserver();
	virtual bool init() override;
	static EntityObserver* create(int option, const vector<string>& components);
	static EntityObserver* create(int option, Slice components[], int count);
public:
	template<typename Func>
	bool each(const Func& func);
	EntityObserver* every(const EntityHandler& handler);
public:
	void onEvent(Entity* entity);
	void clear();
private:
	int _option;
	unordered_set<WRef<Entity>, WRefEntityHasher> _entities;
	vector<string> _components;
	DORA_TYPE_OVERRIDE(EntityObserver);
};

template<typename T>
void Entity::set(String name, const T& value, bool rawFlag)
{
	Com* com = getComponent(name);
	if (rawFlag)
	{
		AssertIf(com == nullptr, "raw set non-exist component \"{}\"", name);
		auto content = com->as<T>();
		AssertIf(content == nullptr, "assign non-exist component \"{}\".", name);
		content->set(value);
		return;
	}
	if (com)
	{
		auto content = com->as<T>();
		AssertIf(content == nullptr, "assign non-exist component \"{}\".", name);
		updateComponent(name, com->clone(), false);
		content->set(value);
	}
	else
	{
		updateComponent(name, Com::create(value), true);
	}
}

template<typename T>
const T& Entity::get(String name) const
{
	Com* com = getComponent(name);
	AssertIf(com == nullptr, "access non-exist component \"{}\".", name);
	return com->to<T>();
}

template<typename Func>
bool EntityGroup::each(const Func& func)
{
	decltype(_entities) entities = _entities;
	for (Entity* entity : entities)
	{
		if (entity && func(entity)) return true;
	}
	return false;
}

template<typename Func>
bool EntityObserver::each(const Func& func)
{
	decltype(_entities) entities = _entities;
	for (Entity* entity : entities)
	{
		if (entity && func(entity)) return true;
	}
	return false;
}

NS_DOROTHY_END
