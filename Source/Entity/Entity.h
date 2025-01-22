/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once
#include "Support/Value.h"

NS_DORA_BEGIN

class Dictionary;
class Entity;

typedef std::function<bool(Entity*)> EntityHandler;

class Entity : public Object {
public:
	enum {
		Add = 1,
		Change = 2,
		AddOrChange = 3,
		Remove = 4
	};
	Entity(int index);
	PROPERTY_READONLY(int, Index);
	PROPERTY_READONLY_CLASS(uint32_t, Count);
	void destroy();
	bool has(String name) const;
	void remove(String name);
	static Entity* create();
	static int getComIndex(String name);
	static int tryGetComIndex(String name);
	static bool each(const std::function<bool(Entity*)>& func);
	static void clear();
	Value* getComponent(String name) const;
	Value* getOldCom(String name) const;
	void clearOldComs();

public:
	template <typename T>
	void set(String name, const T& value);
	template <typename T>
	std::enable_if_t<!std::is_null_pointer_v<T>> set(int name, const T& value);
	template <typename T>
	T get(String name) const;
	template <typename T>
	T get(String name, const T& def) const;

public:
	int getIndex(String name);
	bool has(int index) const;
	bool hasOld(int index) const;
	void remove(int index);
	void set(int index, Own<Value>&& value);
	void set(String name, Own<Value>&& value);
	Value* getComponent(int index) const;
	Value* getOldCom(int index) const;

protected:
	void registerAddEvent(int index);
	void registerUpdateEvent(int index, Own<Value>&& old);
	void registerRemoveEvent(int index, Own<Value>&& old);

private:
	int _index;
	std::vector<Own<Value>> _components;
	std::vector<Own<Value>> _oldComs;
	friend class EntityPool;
	friend class Object;
	DORA_TYPE_OVERRIDE(Entity);
};

struct WRefEntityHasher {
	std::hash<Entity*> hash;
	inline size_t operator()(const WRef<Entity>& entity) const {
		return hash(entity.get());
	}
};

class EntityGroup : public Object {
public:
	PROPERTY_READONLY_CREF(std::vector<int>, Components);
	PROPERTY_READONLY(int, Count);
	PROPERTY_READONLY(Entity*, First);
	EntityGroup(const std::vector<std::string>& components);
	virtual ~EntityGroup();
	virtual bool init() override;
	static EntityGroup* create(const std::vector<std::string>& components);
	static EntityGroup* create(Slice components[], int count);

public:
	template <typename Func>
	bool each(const Func& func);
	template <typename Func>
	Entity* find(const Func& func);
	EntityGroup* watch(const EntityHandler& handler);
	EntityGroup* watch(LuaHandler* handler);

protected:
	void onAdd(Entity* entity);
	void onRemove(Entity* entity);

private:
	std::unordered_set<WRef<Entity>, WRefEntityHasher> _entities;
	std::vector<int> _components;
	friend class Object;
	DORA_TYPE_OVERRIDE(EntityGroup);
};

class EntityObserver : public Object {
public:
	PROPERTY_READONLY_CREF(std::vector<int>, Components);
	PROPERTY_READONLY(int, EventType);
	EntityObserver(int eventType, const std::vector<std::string>& components);
	virtual ~EntityObserver();
	virtual bool init() override;
	static EntityObserver* create(int eventType, const std::vector<std::string>& components);
	static EntityObserver* create(int eventType, Slice components[], int count);

public:
	void clear();
	EntityObserver* watch(const EntityHandler& handler);
	EntityObserver* watch(LuaHandler* handler);

protected:
	void onEvent(Entity* entity);
	template <typename Func>
	bool each(const Func& func);

private:
	int _eventType;
	std::unordered_set<WRef<Entity>, WRefEntityHasher> _entities;
	std::vector<int> _components;
	friend class Object;
	DORA_TYPE_OVERRIDE(EntityObserver);
};

template <typename T>
void Entity::set(String name, const T& value) {
	Entity::set(name, Value::alloc(value));
}

template <typename T>
std::enable_if_t<!std::is_null_pointer_v<T>> Entity::set(int index, const T& value) {
	Entity::set(index, Value::alloc(value));
}

template <typename T>
T Entity::get(String key) const {
	auto com = getComponent(key);
	AssertIf(com == nullptr, "access non-exist component \"{}\".", key.toString());
	using Type = std::remove_pointer_t<T>;
	if constexpr (std::is_base_of_v<Object, Type>) {
		return com->to<std::remove_pointer_t<special_decay_t<T>>>();
	} else {
		return com->toVal<Type>();
	}
}

template <typename T>
T Entity::get(String key, const T& def) const {
	auto com = getComponent(key);
	if (!com) return def;
	using Type = std::remove_pointer_t<T>;
	if constexpr (std::is_base_of_v<Object, Type>) {
		return com->as<std::remove_pointer_t<special_decay_t<T>>>();
	} else {
		if (auto item = com->asVal<Type>()) {
			return *item;
		}
	}
	return def;
}

template <typename Func>
bool EntityGroup::each(const Func& func) {
	decltype(_entities) entities = _entities;
	for (Entity* entity : entities) {
		if (entity && func(entity)) return true;
	}
	return false;
}

template <typename Func>
Entity* EntityGroup::find(const Func& func) {
	decltype(_entities) entities;
	entities = _entities;
	for (Entity* entity : entities) {
		if (entity && func(entity)) return entity;
	}
	return nullptr;
}

template <typename Func>
bool EntityObserver::each(const Func& func) {
	decltype(_entities) entities;
	entities = _entities;
	for (Entity* entity : entities) {
		if (entity && func(entity)) return true;
	}
	return false;
}

NS_DORA_END
