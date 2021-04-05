/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

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
		SharedDirector.getPostSystemScheduler()->schedule([this](double deltaTime)
		{
			DORA_UNUSED_PARAM(deltaTime);
			for (auto& nextValue : nextValues)
			{
				Entity* entity = entities[nextValue.entity];
				if (entity)
				{
					if (!nextValue.value)
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
					entity->clearOldComs();
				}
			}
			updatedEntities.clear();
			return false;
		});
		SharedApplication.quitHandler += [this]() { clear(); };
	}
	virtual ~EntityPool() { }
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
		Own<Value> value;
	};
	std::stack<Ref<Entity>> availableEntities;
	RefVector<Entity> entities;
	std::vector<Delegate<void()>> triggers;
	std::unordered_set<int> usedIndices;
	std::unordered_map<std::string, int> comIndices;
	std::unordered_set<WRef<Entity>, WRefEntityHasher> updatedEntities;
	std::vector<EntityHandler> addHandlers;
	std::vector<EntityHandler> changeHandlers;
	std::vector<EntityHandler> removeHandlers;
	std::vector<NextValue> nextValues;
	std::unordered_map<std::string, Ref<EntityGroup>> groups;
	std::unordered_map<std::string, Ref<EntityObserver>> observers;
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
	bool eachEntity(const std::function<bool(Entity*)>& func)
	{
		WRefVector<Entity> allEntities;
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
		std::stack<Ref<Entity>> empty;
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

#define SharedEntityPool \
	Singleton<EntityPool>::shared()

Entity::Entity(int index):
_index(index)
{ }

int Entity::getIndex() const
{
	return _index;
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
	SharedEntityPool.availableEntities.push(MakeRef(this));
	SharedEntityPool.entities[_index] = nullptr;
	SharedEntityPool.usedIndices.erase(_index);
}

int Entity::getIndex(String name)
{
	return SharedEntityPool.getIndex(name);
}

bool Entity::has(String name) const
{
	auto& comIndices = SharedEntityPool.comIndices;
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

bool Entity::hasOld(int index) const
{
	return 0 <= index && index < s_cast<int>(_oldComs.size()) && _oldComs[index] != nullptr;
}

void Entity::remove(String name)
{
	int index = SharedEntityPool.tryGetIndex(name);
	remove(index);
}

void Entity::remove(int index)
{
	if (!has(index)) return;
	auto& removeHandler = SharedEntityPool.getRemoveHandler(index);
	if (!removeHandler.IsEmpty())
	{
		if (!_oldComs[index])
		{
			_oldComs[index] = _components[index]->clone();
			SharedEntityPool.updatedEntities.insert(MakeWRef(this));
		}
		removeHandler(this);
	}
	_components[index] = nullptr;
}

void Entity::removeNext(int index)
{
	if (!has(index)) return;
	setNext(index, Own<Value>());
}

bool Entity::each(const std::function<bool(Entity*)>& func)
{
	return SharedEntityPool.eachEntity(func);
}

void Entity::clear()
{
	SharedEntityPool.clear();
}

Uint32 Entity::getCount()
{
	return s_cast<Uint32>(SharedEntityPool.usedIndices.size());
}

void Entity::set(int index, Own<Value>&& value)
{
	Value* com = getComponent(index);
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

void Entity::setNext(int index, Own<Value>&& value)
{
	int id = getIndex();
	SharedEntityPool.nextValues.push_back({id,index,std::move(value)});
}

float Entity::get(String key, float def) const
{
	Value* com = getComponent(key);
	if (com)
	{
		return com->toFloat();
	}
	return def;
}

void Entity::updateComponent(int index, Own<Value>&& com, bool add)
{
	EntityHandler* handler;
	if (add)
	{
		while (s_cast<int>(_components.size()) <= index) _components.emplace_back();
		while (s_cast<int>(_oldComs.size()) <= index) _oldComs.emplace_back();
		_components[index] = std::move(com);
		handler = &SharedEntityPool.getAddHandler(index);
	}
	else
	{
		handler = &SharedEntityPool.getChangeHandler(index);
	}
	if (!handler->IsEmpty())
	{
		if (!_oldComs[index])
		{
			_oldComs[index] = add ? nullptr : std::move(com);
			SharedEntityPool.updatedEntities.insert(MakeWRef(this));
		}
		(*handler)(this);
	}
}

Value* Entity::getComponent(String name) const
{
	int index = SharedEntityPool.tryGetIndex(name);
	return has(index) ? _components[index].get() : nullptr;
}

Value* Entity::getComponent(int index) const
{
	return has(index) ? _components[index].get() : nullptr;
}

Value* Entity::getOldCom(String name) const
{
	int index = SharedEntityPool.tryGetIndex(name);
	return hasOld(index) ? _oldComs[index].get() : nullptr;
}

Value* Entity::getOldCom(int index) const
{
	return has(index) ? _oldComs[index].get() : nullptr;
}

void Entity::clearOldComs()
{
	std::fill(_oldComs.begin(), _oldComs.end(), nullptr);
}

Entity* Entity::create()
{
	auto& entities = SharedEntityPool.entities;
	auto& usedIndices = SharedEntityPool.usedIndices;
	auto& availableEntities = SharedEntityPool.availableEntities;
	if (!availableEntities.empty())
	{
		Ref<Entity> entity = availableEntities.top();
		availableEntities.pop();
		entities[entity->getIndex()] = entity;
		usedIndices.insert(entity->getIndex());
		return entity;
	}
	Entity* entity = new Entity(s_cast<int>(entities.size()));
	if (!entity->init())
	{
		delete entity;
		return nullptr;
	}
	entity->autorelease();
	entities.push_back(entity);
	usedIndices.insert(entity->getIndex());
	return entity;
}

EntityGroup::EntityGroup(const std::vector<std::string>& components)
{
	_components.resize(components.size());
	for (int i = 0; i < s_cast<int>(components.size()); i++)
	{
		_components[i] = SharedEntityPool.getIndex(components[i]);
	}
}

EntityGroup::~EntityGroup()
{
	if (Singleton<EntityPool>::isDisposed()) return;
	for (const auto& index : _components)
	{
		SharedEntityPool.getAddHandler(index) -= std::make_pair(this, &EntityGroup::onAdd);
		SharedEntityPool.getRemoveHandler(index) -= std::make_pair(this, &EntityGroup::onRemove);
	}
}

int EntityGroup::getCount() const
{
	return s_cast<int>(_entities.size());
}

bool EntityGroup::init()
{
	Object::init();
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
			_entities.insert(MakeWRef(entity));
		}
		return false;
	});
	for (int index : _components)
	{
		SharedEntityPool.getAddHandler(index) += std::make_pair(this, &EntityGroup::onAdd);
		SharedEntityPool.getRemoveHandler(index) += std::make_pair(this, &EntityGroup::onRemove);
	}
	return true;
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
		_entities.insert(MakeWRef(entity));
	}
}

void EntityGroup::onRemove(Entity* entity)
{
	_entities.erase(MakeWRef(entity));
}

EntityGroup* EntityGroup::every(const EntityHandler& handler)
{
	WRef<EntityGroup> self(this);
	SharedEntityPool.triggers.push_back([self,handler]()
	{
		if (!self) return;
		self->each([&handler](Entity* entity)
		{
			handler(entity);
			return false;
		});
	});
	return this;
}

EntityGroup* EntityGroup::create(const std::vector<std::string>& components)
{
	std::vector<std::string> coms = components;
	std::sort(coms.begin(), coms.end());
	std::string name;
	for (const auto& com : coms)
	{
		name += com;
	}
	auto& groups = SharedEntityPool.groups;
	auto it = groups.find(name);
	if (it != groups.end())
	{
		return it->second;
	}
	EntityGroup* entityGroup = new EntityGroup(components);
	if (!entityGroup->init())
	{
		delete entityGroup;
		return nullptr;
	}
	entityGroup->autorelease();
	groups[name] = entityGroup;
	return entityGroup;
}

EntityGroup* EntityGroup::create(Slice components[], int count)
{
	std::vector<std::string> coms;
	coms.resize(count);
	for (int i = 0; i < count; i++)
	{
		coms[i] = components[i];
	}
	return EntityGroup::create(coms);
}

EntityObserver::EntityObserver(int option, const std::vector<std::string>& components):
_option(option)
{
	_components.resize(components.size());
	for (int i = 0; i < s_cast<int>(components.size()); i++)
	{
		_components[i] = SharedEntityPool.getIndex(components[i]);
	}
}

EntityObserver::~EntityObserver()
{
	if (Singleton<EntityPool>::isDisposed()) return;
	for (int index : _components)
	{
		switch (_option)
		{
			case Entity::Add:
				SharedEntityPool.getAddHandler(index) -= std::make_pair(this, &EntityObserver::onEvent);
				break;
			case Entity::Change:
				SharedEntityPool.getChangeHandler(index) -= std::make_pair(this, &EntityObserver::onEvent);
				break;
			case Entity::AddOrChange:
				SharedEntityPool.getAddHandler(index) -= std::make_pair(this, &EntityObserver::onEvent);
				SharedEntityPool.getChangeHandler(index) -= std::make_pair(this, &EntityObserver::onEvent);
				break;
			case Entity::Remove:
				SharedEntityPool.getRemoveHandler(index) -= std::make_pair(this, &EntityObserver::onEvent);
				break;
		}
	}
}

bool EntityObserver::init()
{
	if (!Object::init()) return false;
	for (int index : _components)
	{
		switch (_option)
		{
			case Entity::Add:
				SharedEntityPool.getAddHandler(index) += std::make_pair(this, &EntityObserver::onEvent);
				break;
			case Entity::Change:
				SharedEntityPool.getChangeHandler(index) += std::make_pair(this, &EntityObserver::onEvent);
				break;
			case Entity::AddOrChange:
				SharedEntityPool.getAddHandler(index) += std::make_pair(this, &EntityObserver::onEvent);
				SharedEntityPool.getChangeHandler(index) += std::make_pair(this, &EntityObserver::onEvent);
				break;
			case Entity::Remove:
				SharedEntityPool.getRemoveHandler(index) += std::make_pair(this, &EntityObserver::onEvent);
				break;
		}
	}
	return true;
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
		_entities.insert(MakeWRef(entity));
	}
}

EntityObserver* EntityObserver::every(const EntityHandler& handler)
{
	WRef<EntityObserver> self(this);
	SharedEntityPool.triggers.push_back([self,handler]()
	{
		if (!self) return;
		self->each([&handler](Entity* entity)
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

EntityObserver* EntityObserver::create(int option, const std::vector<std::string>& components)
{
	std::vector<std::string> coms = components;
	std::sort(coms.begin(), coms.end());
	fmt::memory_buffer out;
	fmt::format_to(out, "{}", option);
	for (const auto& com : coms)
	{
		fmt::format_to(out, "{}", com);
	}
	std::string name = fmt::to_string(out);
	auto& observers = SharedEntityPool.observers;
	auto it = observers.find(name);
	if (it != observers.end())
	{
		return it->second;
	}
	EntityObserver* entityObserver = new EntityObserver(option, coms);
	if (!entityObserver->init())
	{
		delete entityObserver;
		return nullptr;
	}
	entityObserver->autorelease();
	observers[name] = entityObserver;
	return entityObserver;
}

EntityObserver* EntityObserver::create(int option, Slice components[], int count)
{
	std::vector<std::string> coms;
	coms.resize(count);
	for (int i = 0; i < count; i++)
	{
		coms[i] = components[i];
	}
	return EntityObserver::create(option, coms);
}

NS_DOROTHY_END
