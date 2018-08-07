/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Entity/Entity.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Basic/Application.h"

NS_DOROTHY_BEGIN

class EntityPool
{
public:
	void update()
	{
		for (auto& nextValue : nextValues)
		{
			Entity* entity = entities[nextValue.entity];
			if (entity)
			{
				if (DoraCast<ComNone>(nextValue.value.get()))
				{
					entity->remove(nextValue.component);
				}
				else
				{
					entity->set(nextValue.component, std::move(nextValue.value));
				}
			}
		}
		nextValues.clear();
		for (const auto& trigger : triggers)
		{
			trigger();
		}
		for (auto& it : observers)
		{
			it.second->clear();
		}
		for (Entity* entity : updatedEntities)
		{
			if (entity)
			{
				entity->clearComCache();
			}
		}
		updatedEntities.clear();
	}
	int tryGetIndex(String name) const
	{
		auto it = comIndices.find(name);
		return it == comIndices.end() ? -1 : it->second;
	}
	int getIndex(String name)
	{
		auto it = comIndices.find(name);
		if (it == comIndices.end())
		{
			int index = s_cast<int>(comIndices.size());
			comIndices[name] = index;
			return index;
		}
		return it->second;
	}
	struct NextValue
	{
		int entity;
		int component;
		Own<Com> value;
	};
	stack<Own<Entity>> availableEntities;
	OwnVector<Entity> entities;
	vector<Delegate<void()>> triggers;
	unordered_set<int> usedIndices;
	unordered_map<string, int> comIndices;
	unordered_set<Entity*> updatedEntities;
	vector<EntityHandler> addHandlers;
	vector<EntityHandler> changeHandlers;
	vector<EntityHandler> removeHandlers;
	vector<NextValue> nextValues;
	unordered_map<string, Own<EntityGroup>> groups;
	unordered_map<string, Own<EntityObserver>> observers;
	EntityHandler& getAddHandler(int index)
	{
		while (s_cast<int>(addHandlers.size()) <= index) addHandlers.emplace_back();
		return addHandlers[index];
	}
	EntityHandler& getChangeHandler(int index)
	{
		while (s_cast<int>(changeHandlers.size()) <= index) changeHandlers.emplace_back();
		return changeHandlers[index];
	}
	EntityHandler& getRemoveHandler(int index)
	{
		while (s_cast<int>(removeHandlers.size()) <= index) removeHandlers.emplace_back();
		return removeHandlers[index];
	}
	bool eachEntity(const function<bool(Entity*)>& func)
	{
		vector<Entity*> allEntities;
		allEntities.reserve(usedIndices.size());
		for (auto index : usedIndices)
		{
			allEntities.push_back(entities[index]);
		}
		for (Entity* entity : entities)
		{
			if (entity && func(entity))
			{
				return true;
			}
		}
		return false;
	}
	void clear()
	{
		eachEntity([](Entity* entity)
		{
			entity->destroy();
			return false;
		});
		stack<Own<Entity>> empty;
		comIndices.clear();
		availableEntities.swap(empty);
		entities.clear();
		usedIndices.clear();
		groups.clear();
		observers.clear();
		triggers.clear();
		nextValues.clear();
		addHandlers.clear();
		changeHandlers.clear();
		removeHandlers.clear();
	}
};

class EntityWorldCache
{
public:
	EntityWorldCache()
	{
		SharedApplication.quitHandler += []() { EntityWorld::removeAll(); };
	}
	unordered_map<string, Ref<EntityWorld>> worlds;
	SINGLETON_REF(EntityWorldCache, Director);
};

#define SharedEntityWorldCache \
	Dorothy::Singleton<EntityWorldCache>::shared()

EntityWorld* EntityWorld::create(String name)
{
	auto& worlds = SharedEntityWorldCache.worlds;
	auto it = worlds.find(name);
	if (it != worlds.end())
	{
		return it->second;
	}
	EntityWorld* world = new EntityWorld();
	if (!world->init())
	{
		delete world;
		return nullptr;
	}
	world->autorelease();
	worlds[name] = world;
	return world;
}

void EntityWorld::removeAll()
{
	auto& worlds = SharedEntityWorldCache.worlds;
	for (auto& it : worlds)
	{
		it.second->destroy();
	}
	worlds.clear();
}

void EntityWorld::remove(String name)
{
	auto& worlds = SharedEntityWorldCache.worlds;
	auto it = worlds.find(name);
	if (it != worlds.end())
	{
		it->second->destroy();
		worlds.erase(it);
	}
}

EntityWorld::EntityWorld():
_pool(new EntityPool())
{ }

bool EntityWorld::init()
{
	if (Object::init())
	{
		SharedDirector.getSystemScheduler()->schedule(this);
		return true;
	}
	return false;
}

bool EntityWorld::update(double deltaTime)
{
	_pool->update();
	return false;
}

EntityPool* EntityWorld::getPool() const
{
	return _pool;
}

Entity* EntityWorld::entity()
{
	auto& entities = _pool->entities;
	auto& usedIndices = _pool->usedIndices;
	auto& availableEntities = _pool->availableEntities;
	if (!availableEntities.empty())
	{
		Entity* entity = availableEntities.top();
		int id = entity->getId();
		entities[id] = std::move(availableEntities.top());
		availableEntities.pop();
		usedIndices.insert(id);
		return entity;
	}
	Entity* entity = new Entity(this, s_cast<int>(entities.size()));
	entities.push_back(MakeOwn(entity));
	usedIndices.insert(entity->getId());
	return entity;
}

EntityGroup* EntityWorld::group(const vector<string>& components, const EntityHandler& handler)
{
	vector<string> coms = components;
	std::sort(coms.begin(), coms.end());
	string name;
	for (const auto& com : coms)
	{
		name += com;
	}
	auto& groups = _pool->groups;
	EntityGroup* entityGroup = nullptr;
	auto it = groups.find(name);
	if (it != groups.end())
	{
		entityGroup = it->second;
	}
	else
	{
		entityGroup = new EntityGroup(this, coms);
		groups[name] = MakeOwn(entityGroup);
	}
	if (handler.IsEmpty()) return entityGroup;
	return entityGroup->every(handler);
}

EntityGroup* EntityWorld::group(Slice components[], int count, const EntityHandler& handler)
{
	vector<string> coms;
	coms.resize(count);
	for (int i = 0; i < count; i++)
	{
		coms[i] = components[i];
	}
	return group(coms, handler);
}

EntityObserver* EntityWorld::observe(int option, const vector<string>& components, const EntityHandler& handler)
{
	vector<string> coms = components;
	std::sort(coms.begin(), coms.end());
	fmt::memory_buffer out;
	fmt::format_to(out, "{}", option);
	for (const auto& com : coms)
	{
		fmt::format_to(out, "{}", com);
	}
	string name = fmt::to_string(out);
	auto& observers = _pool->observers;
	EntityObserver* entityObserver = nullptr;
	auto it = observers.find(name);
	if (it != observers.end())
	{
		entityObserver = it->second;
	}
	else
	{
		entityObserver = new EntityObserver(this, option, coms);
		observers[name] = MakeOwn(entityObserver);
	}
	if (handler.IsEmpty()) return entityObserver;
	return entityObserver->every(handler);
}

EntityObserver* EntityWorld::observe(int option, Slice components[], int count, const EntityHandler& handler)
{
	vector<string> coms;
	coms.resize(count);
	for (int i = 0; i < count; i++)
	{
		coms[i] = components[i];
	}
	return observe(option, coms, handler);
}

Uint32 EntityWorld::getCount() const
{
	return s_cast<Uint32>(_pool->usedIndices.size());
}

bool EntityWorld::each(const function<bool(Entity*)>& func)
{
	return _pool->eachEntity(func);
}

void EntityWorld::clear()
{
	_pool->clear();
}

void EntityWorld::destroy()
{
	SharedDirector.getSystemScheduler()->unschedule(this);
	clear();
}

Entity::Entity(EntityWorld* world, int id):
_id(id),
_world(world)
{ }

Entity::~Entity()
{ }

int Entity::getId() const
{
	return _id;
}

void Entity::destroy()
{
	for (int i = 0; i < s_cast<int>(_components.size()); i++)
	{
		if (_components[i] != nullptr)
		{
			remove(i);
		}
	}
	EntityPool* pool = _world->getPool();
	pool->availableEntities.push(std::move(pool->entities[_id]));
	pool->usedIndices.erase(_id);
}

int Entity::getIndex(String name)
{
	return _world->getPool()->getIndex(name);
}

bool Entity::has(String name) const
{
	auto& comIndices = _world->getPool()->comIndices;
	auto it = comIndices.find(name);
	if (it != comIndices.end())
	{
		return has(it->second);
	}
	return false;
}

bool Entity::has(int index) const
{
	return 0 <= index && index < s_cast<int>(_components.size()) && _components[index] != nullptr;
}

bool Entity::hasCache(int index) const
{
	return 0 <= index && index < s_cast<int>(_comCache.size()) && _comCache[index] != nullptr;
}

void Entity::remove(String name)
{
	int index = _world->getPool()->tryGetIndex(name);
	AssertIf(!has(index), "removing non-exist component \"{}\"", name);
	remove(index);
}

void Entity::remove(int index)
{
	if (!has(index)) return;
	auto& removeHandler = _world->getPool()->getRemoveHandler(index);
	if (!removeHandler.IsEmpty())
	{
		if (!_comCache[index])
		{
			_comCache[index] = _components[index]->clone();
			_world->getPool()->updatedEntities.insert(this);
		}
		removeHandler(this);
	}
	_components[index] = nullptr;
}

void Entity::removeNext(int index)
{
	if (!has(index)) return;
	setNext(index, Com::none());
}

void Entity::set(int index, Own<Com>&& value)
{
	Com* com = getComponent(index);
	if (com)
	{
		updateComponent(index, com->clone(), false);
		_components[index] = std::move(value);
	}
	else
	{
		updateComponent(index, std::move(value), true);
	}
}

void Entity::setNext(int index, Own<Com>&& value)
{
	int id = getId();
	_world->getPool()->nextValues.push_back({id,index,std::move(value)});
}

void Entity::updateComponent(int index, Own<Com>&& com, bool add)
{
	EntityHandler* handler;
	if (add)
	{
		while (s_cast<int>(_components.size()) <= index) _components.emplace_back();
		while (s_cast<int>(_comCache.size()) <= index) _comCache.emplace_back();
		_components[index] = std::move(com);
		handler = &_world->getPool()->getAddHandler(index);
	}
	else
	{
		handler = &_world->getPool()->getChangeHandler(index);
	}
	if (!handler->IsEmpty())
	{
		if (!_comCache[index])
		{
			_comCache[index] = add ? Own<Com>() : std::move(com);
			_world->getPool()->updatedEntities.insert(this);
		}
		(*handler)(this);
	}
}

Com* Entity::getComponent(String name) const
{
	int index = _world->getPool()->tryGetIndex(name);
	return has(index) ? _components[index].get() : nullptr;
}

Com* Entity::getComponent(int index) const
{
	return has(index) ? _components[index].get() : nullptr;
}

Com* Entity::getCachedCom(String name) const
{
	int index = _world->getPool()->tryGetIndex(name);
	return hasCache(index) ? _comCache[index].get() : nullptr;
}

Com* Entity::getCachedCom(int index) const
{
	return has(index) ? _comCache[index].get() : nullptr;
}

void Entity::clearComCache()
{
	std::fill(_comCache.begin(), _comCache.end(), nullptr);
}

EntityGroup::EntityGroup(EntityWorld* world, const vector<string>& components):
_world(world)
{
	_components.resize(components.size());
	EntityPool* pool = world->getPool();
	for (int i = 0; i < s_cast<int>(components.size()); i++)
	{
		_components[i] = pool->getIndex(components[i]);
	}
	world->each([this](Entity* entity)
	{
		bool match = true;
		for (int index : _components)
		{
			if (!entity->has(index))
			{
				match = false;
				break;
			}
		}
		if (match)
		{
			_entities.insert(entity);
		}
		return false;
	});
	for (int index : _components)
	{
		pool->getAddHandler(index) += std::make_pair(this, &EntityGroup::onAdd);
		pool->getRemoveHandler(index) += std::make_pair(this, &EntityGroup::onRemove);
	}
}

EntityGroup::~EntityGroup()
{
	if (Singleton<EntityPool>::isDisposed()) return;
	EntityPool* pool = _world->getPool();
	for (const auto& index : _components)
	{
		pool->getAddHandler(index) -= std::make_pair(this, &EntityGroup::onAdd);
		pool->getRemoveHandler(index) -= std::make_pair(this, &EntityGroup::onRemove);
	}
}

void EntityGroup::onAdd(Entity* entity)
{
	bool match = true;
	for (const auto& name : _components)
	{
		if (!entity->has(name))
		{
			match = false;
			break;
		}
	}
	if (match)
	{
		_entities.insert(entity);
	}
}

void EntityGroup::onRemove(Entity* entity)
{
	_entities.erase(entity);
}

EntityGroup* EntityGroup::every(const EntityHandler& handler)
{
	_world->getPool()->triggers.push_back([this,handler]()
	{
		each([&handler](Entity* entity)
		{
			handler(entity);
			return false;
		});
	});
	return this;
}

EntityObserver::EntityObserver(EntityWorld* world, int option, const vector<string>& components):
_option(option),
_world(world)
{
	_components.resize(components.size());
	EntityPool* pool = _world->getPool();
	for (int i = 0; i < s_cast<int>(components.size()); i++)
	{
		int index = pool->getIndex(components[i]);
		_components[i] = index;
		switch (_option)
		{
			case Entity::Add:
				pool->getAddHandler(index) += std::make_pair(this, &EntityObserver::onEvent);
				break;
			case Entity::Change:
				pool->getChangeHandler(index) += std::make_pair(this, &EntityObserver::onEvent);
				break;
			case Entity::AddOrChange:
				pool->getAddHandler(index) += std::make_pair(this, &EntityObserver::onEvent);
				pool->getChangeHandler(index) += std::make_pair(this, &EntityObserver::onEvent);
				break;
			case Entity::Remove:
				pool->getRemoveHandler(index) += std::make_pair(this, &EntityObserver::onEvent);
				break;
		}
	}
}

EntityObserver::~EntityObserver()
{
	if (Singleton<EntityPool>::isDisposed()) return;
	EntityPool* pool = _world->getPool();
	for (int index : _components)
	{
		switch (_option)
		{
			case Entity::Add:
				pool->getAddHandler(index) -= std::make_pair(this, &EntityObserver::onEvent);
				break;
			case Entity::Change:
				pool->getChangeHandler(index) -= std::make_pair(this, &EntityObserver::onEvent);
				break;
			case Entity::AddOrChange:
				pool->getAddHandler(index) -= std::make_pair(this, &EntityObserver::onEvent);
				pool->getChangeHandler(index) -= std::make_pair(this, &EntityObserver::onEvent);
				break;
			case Entity::Remove:
				pool->getRemoveHandler(index) -= std::make_pair(this, &EntityObserver::onEvent);
				break;
		}
	}
}

void EntityObserver::onEvent(Entity* entity)
{
	bool match = true;
	for (int index : _components)
	{
		if (!entity->has(index))
		{
			match = false;
			break;
		}
	}
	if (match)
	{
		_entities.insert(entity);
	}
}

EntityObserver* EntityObserver::every(const EntityHandler& handler)
{
	EntityPool* pool = _world->getPool();
	pool->triggers.push_back([this,handler]()
	{
		each([&handler](Entity* entity)
		{
			handler(entity);
			return false;
		});
	});
	return this;
}

void EntityObserver::clear()
{
	_entities.clear();
}

NS_DOROTHY_END
