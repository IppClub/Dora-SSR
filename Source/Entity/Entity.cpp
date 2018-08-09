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
	EntityPool()
	{
		SharedApplication.quitHandler += [this]() { clear(); };
		SharedDirector.getSystemScheduler()->schedule([this](double deltaTime)
		{
			DORA_UNUSED_PARAM(deltaTime);
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
			return false;
		});
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
	SINGLETON_REF(EntityPool, AsyncThread);
};

#define Pool \
	Dorothy::Singleton<EntityPool>::shared()

Entity::Entity(int id):
_id(id)
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
	Pool.availableEntities.push(std::move(Pool.entities[_id]));
	Pool.usedIndices.erase(_id);
}

int Entity::getIndex(String name)
{
	return Pool.getIndex(name);
}

bool Entity::has(String name) const
{
	auto& comIndices = Pool.comIndices;
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
	int index = Pool.tryGetIndex(name);
	AssertIf(!has(index), "removing non-exist component \"{}\"", name);
	remove(index);
}

void Entity::remove(int index)
{
	if (!has(index)) return;
	auto& removeHandler = Pool.getRemoveHandler(index);
	if (!removeHandler.IsEmpty())
	{
		if (!_comCache[index])
		{
			_comCache[index] = _components[index]->clone();
			Pool.updatedEntities.insert(this);
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
	Pool.nextValues.push_back({id,index,std::move(value)});
}

void Entity::updateComponent(int index, Own<Com>&& com, bool add)
{
	EntityHandler* handler;
	if (add)
	{
		while (s_cast<int>(_components.size()) <= index) _components.emplace_back();
		while (s_cast<int>(_comCache.size()) <= index) _comCache.emplace_back();
		_components[index] = std::move(com);
		handler = &Pool.getAddHandler(index);
	}
	else
	{
		handler = &Pool.getChangeHandler(index);
	}
	if (!handler->IsEmpty())
	{
		if (!_comCache[index])
		{
			_comCache[index] = add ? Own<Com>() : std::move(com);
			Pool.updatedEntities.insert(this);
		}
		(*handler)(this);
	}
}

Com* Entity::getComponent(String name) const
{
	int index = Pool.tryGetIndex(name);
	return has(index) ? _components[index].get() : nullptr;
}

Com* Entity::getComponent(int index) const
{
	return has(index) ? _components[index].get() : nullptr;
}

Com* Entity::getCachedCom(String name) const
{
	int index = Pool.tryGetIndex(name);
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

void Entity::clear()
{
	Pool.clear();
}

Uint32 Entity::getCount()
{
	return s_cast<Uint32>(Pool.usedIndices.size());
}

bool Entity::each(const function<bool(Entity*)>& func)
{
	return Pool.eachEntity(func);
}

Entity* Entity::create()
{
	auto& entities = Pool.entities;
	auto& usedIndices = Pool.usedIndices;
	auto& availableEntities = Pool.availableEntities;
	if (!availableEntities.empty())
	{
		Entity* entity = availableEntities.top();
		int id = entity->getId();
		entities[id] = std::move(availableEntities.top());
		availableEntities.pop();
		usedIndices.insert(id);
		return entity;
	}
	Entity* entity = new Entity(s_cast<int>(entities.size()));
	entities.push_back(MakeOwn(entity));
	usedIndices.insert(entity->getId());
	return entity;
}

EntityGroup::EntityGroup(const vector<string>& components)
{
	_components.resize(components.size());
	EntityPool* pool = &Pool;
	for (int i = 0; i < s_cast<int>(components.size()); i++)
	{
		_components[i] = pool->getIndex(components[i]);
	}
	Entity::each([this](Entity* entity)
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
	EntityPool* pool = &Pool;
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
	Pool.triggers.push_back([this,handler]()
	{
		each([&handler](Entity* entity)
		{
			handler(entity);
			return false;
		});
	});
	return this;
}

EntityGroup* EntityGroup::create(const vector<string>& components)
{
	vector<string> coms = components;
	std::sort(coms.begin(), coms.end());
	string name;
	for (const auto& com : coms)
	{
		name += com;
	}
	auto& groups = Pool.groups;
	EntityGroup* entityGroup = nullptr;
	auto it = groups.find(name);
	if (it != groups.end())
	{
		entityGroup = it->second;
	}
	else
	{
		entityGroup = new EntityGroup(coms);
		groups[name] = MakeOwn(entityGroup);
	}
	return entityGroup;
}

EntityGroup* EntityGroup::create(Slice components[], int count)
{
	vector<string> coms;
	coms.resize(count);
	for (int i = 0; i < count; i++)
	{
		coms[i] = components[i];
	}
	return create(coms);
}

EntityObserver::EntityObserver(int option, const vector<string>& components):
_option(option)
{
	_components.resize(components.size());
	EntityPool* pool = &Pool;
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
	EntityPool* pool = &Pool;
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
	Pool.triggers.push_back([this,handler]()
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

EntityObserver* EntityObserver::create(int option, const vector<string>& components)
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
	auto& observers = Pool.observers;
	EntityObserver* entityObserver = nullptr;
	auto it = observers.find(name);
	if (it != observers.end())
	{
		entityObserver = it->second;
	}
	else
	{
		entityObserver = new EntityObserver(option, coms);
		observers[name] = MakeOwn(entityObserver);
	}
	return entityObserver;
}

EntityObserver* EntityObserver::create(int option, Slice components[], int count)
{
	vector<string> coms;
	coms.resize(count);
	for (int i = 0; i < count; i++)
	{
		coms[i] = components[i];
	}
	return create(option, coms);
}

NS_DOROTHY_END
