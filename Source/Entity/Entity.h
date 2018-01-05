#pragma once
#include "Basic/Object.h"
#include "Support/Value.h"

NS_DOROTHY_BEGIN

class Entity : public Object
{
public:
	enum
	{
		Add,
		Change,
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
	Value* getComponent(String name) const;
public:
	template<typename T>
	void set(String name, const T& value, bool rawFlag = false);
	void set(String name, Object* value, bool rawFlag = false);

	template<typename T>
	const T& get(String name) const;

	template<typename T>
	typename std::enable_if<std::is_same<Object, T>::value>::type* get(String name) const;
protected:
	void addComponent(String name, Value* value);
private:
	int _index;
	unordered_map<string, Ref<Value>> _components;
	DORA_TYPE_OVERRIDE(Entity);
};

class EntityGroup : public Object
{
public:
	EntityGroup(const vector<string>& components);
	EntityGroup(Slice components[], int count);
	virtual ~EntityGroup();
	virtual bool init() override;
	CREATE_FUNC(EntityGroup);
public:
	template<typename Func>
	bool each(const Func& func);
public:
	void onAdd(Entity* entity);
	void onRemove(Entity* entity);
private:
	struct WRefEntityHasher
	{
		std::hash<Entity*> hash;
		inline size_t operator () (const WRef<Entity>& entity) const
		{
			return hash(entity.get());
		}
	};
	unordered_set<WRef<Entity>, WRefEntityHasher> _entities;
	vector<string> _components;
	DORA_TYPE_OVERRIDE(EntityGroup);
};

class EntityObserver : public Object
{
public:
	EntityObserver(int option, const vector<string>& components);
	EntityObserver(int option, Slice components[], int count);
	virtual ~EntityObserver();
	virtual bool init() override;
	void clear();
	CREATE_FUNC(EntityObserver);
public:
	template<typename Func>
	bool each(const Func& func);
public:
	void onEvent(Entity* entity);
private:
	int _option;
	vector<WRef<Entity>> _entities;
	vector<string> _components;
	DORA_TYPE_OVERRIDE(EntityObserver);
};

template<typename T>
void Entity::set(String name, const T& value, bool rawFlag)
{
	Value* valueItem = getComponent(name);
	if (rawFlag)
	{
		Value* valueItem = getComponent(name);
		AssertIf(valueItem == nullptr, "raw set non-exist component \"{}\"", name);
		auto content = valueItem->as<T>();
		AssertIf(content == nullptr, "assign non-exist component \"{}\".", name);
		content->set(value);
		return;
	}
	if (valueItem)
	{
		auto content = valueItem->as<T>();
		AssertIf(content == nullptr, "assign non-exist component \"{}\".", name);
		content->set(value);
		addComponent(name, nullptr);
	}
	else
	{
		addComponent(name, Value::create(value));
	}
}

template<typename T>
const T& Entity::get(String name) const
{
	Value* value = getComponent(name);
	AssertIf(value == nullptr, "access non-exist component \"{}\".", name);
	return value->to<T>();
}

template<typename T>
typename std::enable_if<std::is_same<Object, T>::value>::type* Entity::get(String name) const
{
	Value* value = getComponent(name);
	AssertIf(value == nullptr, "access non-exist component \"{}\".", name);
	return value->to<Ref<>>();
}

template<typename Func>
bool EntityGroup::each(const Func& func)
{
	for (Entity* entity : _entities)
	{
		if (entity && func(entity)) return true;
	}
	return false;
}

template<typename Func>
bool EntityObserver::each(const Func& func)
{
	for (Entity* entity : _entities)
	{
		if (entity && func(entity)) return true;
	}
	return false;
}

NS_DOROTHY_END
