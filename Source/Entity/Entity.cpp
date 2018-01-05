/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Entity/Entity.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Support/Dictionary.h"

NS_DOROTHY_BEGIN

typedef Delegate<void(Entity*)> EntityHandler;

// add class below to make visual C++ compiler happy
struct HandlerItem
{
	HandlerItem():handler(New<EntityHandler>()) { }
	HandlerItem(HandlerItem&& other):handler(std::move(other.handler)) { }
	Own<EntityHandler> handler;
	bool operator==(const HandlerItem& right) const
	{
		return handler.get() == right.handler.get();
	}
};

class EntityPool
{
public:
	EntityPool()
	{
		SharedDirector.getPostSystemScheduler()->schedule([this](double deltaTime)
		{
			DORA_UNUSED_PARAM(deltaTime);
			for (Entity* entity : updatedEntities)
			{
				if (entity)
				{
					entity->clearValueCache();
				}
			}
			return false;
		});
	}
	virtual ~EntityPool() { }
	stack<Ref<Entity>> availableEntities;
	RefVector<Entity> entities;
	unordered_set<int> usedIndices;
	unordered_set<WRef<Entity>, WRefEntityHasher> updatedEntities;
	unordered_map<string, HandlerItem> addHandlers;
	unordered_map<string, HandlerItem> changeHandlers;
	unordered_map<string, HandlerItem> removeHandlers;
	EntityHandler& getAddHandler(String name)
	{
		auto it = addHandlers.find(name);
		if (it == addHandlers.end())
		{
			auto result = addHandlers.emplace(name, HandlerItem());
			it = result.first;
		}
		return *it->second.handler;
	}
	EntityHandler& getChangeHandler(String name)
	{
		auto it = changeHandlers.find(name);
		if (it == changeHandlers.end())
		{
			auto result = changeHandlers.emplace(name, HandlerItem());
			it = result.first;
		}
		return *it->second.handler;
	}
	EntityHandler& getRemoveHandler(String name)
	{
		auto it = removeHandlers.find(name);
		if (it == removeHandlers.end())
		{
			auto result = removeHandlers.emplace(name, HandlerItem());
			it = result.first;
		}
		return *it->second.handler;
	}
	SINGLETON_REF(EntityPool, Director);
};

#define SharedEntityPool \
	Singleton<EntityPool>::shared()

Entity::Entity(int index):
_index(index),
_valueCache(Dictionary::create())
{ }

Entity::~Entity()
{ }

bool Entity::init()
{
	return true;
}

int Entity::getIndex() const
{
	return _index;
}

Dictionary* Entity::getValueCache() const
{
	return _valueCache;
}

void Entity::destroy()
{
	list<string> names;
	for (auto& pair : _components)
	{
		names.push_back(pair.first);
	}
	for (auto& name : names)
	{
		remove(name);
	}
	SharedEntityPool.availableEntities.push(MakeRef(this));
	SharedEntityPool.entities[_index] = nullptr;
	SharedEntityPool.usedIndices.erase(_index);
}

bool Entity::has(String name) const
{
	return _components.find(name) != _components.end();
}

void Entity::remove(String name)
{
	auto it = _components.find(name);
	AssertIf(it == _components.end(), "removing non-exist component \"{}\"", name);
	auto& removeHandlers = SharedEntityPool.removeHandlers;
	auto handlerIt = removeHandlers.find(name);
	if (handlerIt != removeHandlers.end())
	{
		_valueCache->set(name, it->second->clone());
		SharedEntityPool.updatedEntities.insert(MakeWRef(this));
		(*handlerIt->second.handler)(this);
	}
	_components.erase(name);
}

bool Entity::each(const function<bool(Entity*)>& func)
{
	auto& usedIndices = SharedEntityPool.usedIndices;
	auto& allEntities = SharedEntityPool.entities;
	WRefVector<Entity> entities;
	entities.reserve(usedIndices.size());
	for (auto index : usedIndices)
	{
		entities.push_back(allEntities[index]);
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

void Entity::clear()
{
	each([](Entity* entity)
	{
		entity->destroy();
		return false;
	});
	stack<Ref<Entity>> empty;
	SharedEntityPool.availableEntities.swap(empty);
	SharedEntityPool.entities.clear();
	SharedEntityPool.usedIndices.clear();
}

void Entity::updateComponent(String name, Value* value, bool add)
{
	unordered_map<string, HandlerItem>* handlers;
	if (add)
	{
		_components[name] = value;
		handlers = &SharedEntityPool.addHandlers;
	}
	else
	{
		handlers = &SharedEntityPool.changeHandlers;
	}
	auto it = handlers->find(name);
	if (it != handlers->end())
	{
		if (add)
		{
			_valueCache->set(name, nullptr);
		}
		else
		{
			if (!_valueCache->get(name))
			{
				_valueCache->set(name, value->clone());
			}
		}
		SharedEntityPool.updatedEntities.insert(MakeWRef(this));
		(*it->second.handler)(this);
	}
}

Value* Entity::getComponent(String name) const
{
	auto it = _components.find(name);
	if (it != _components.end())
	{
		return it->second;
	}
	return nullptr;
}

void Entity::clearValueCache()
{
	_valueCache->clear();
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
		return entity;
	}
	Entity* entity = new Entity(s_cast<int>(entities.size()));
	entity->autorelease();
	entities.push_back(entity);
	usedIndices.insert(entity->getIndex());
	return entity;
}

void Entity::set(String name, Object* value, bool rawFlag)
{
	Value* valueItem = getComponent(name);
	if (rawFlag)
	{
		AssertIf(valueItem == nullptr, "raw set non-exist component \"{}\"", name);
		auto content = valueItem->as<Ref<>>();
		AssertIf(content == nullptr, "assign non-exist component \"{}\".", name);
		content->set(MakeRef(value));
		return;
	}
	if (valueItem)
	{
		auto content = valueItem->as<Ref<>>();
		AssertIf(content == nullptr, "assign non-exist component \"{}\".", name);
		content->set(MakeRef(value));
		updateComponent(name, content, false);
	}
	else
	{
		updateComponent(name, Value::create(value), true);
	}
}

EntityGroup::EntityGroup(const vector<string>& components)
{
	_components.resize(components.size());
	for (int i = 0; i < s_cast<int>(components.size()); i++)
	{
		_components[i] = components[i];
	}
}

EntityGroup::EntityGroup(Slice components[], int count)
{
	_components.resize(count);
	for (int i = 0; i < count; i++)
	{
		_components[i] = components[i];
	}
}

EntityGroup::~EntityGroup()
{
	for (const auto& name : _components)
	{
		SharedEntityPool.getAddHandler(name) -= std::make_pair(this, &EntityGroup::onAdd);
		SharedEntityPool.getRemoveHandler(name) -= std::make_pair(this, &EntityGroup::onRemove);
	}
}

bool EntityGroup::init()
{
	Entity::each([this](Entity* entity)
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
		return false;
	});
	for (const auto& name : _components)
	{
		SharedEntityPool.getAddHandler(name) += std::make_pair(this, &EntityGroup::onAdd);
		SharedEntityPool.getRemoveHandler(name) += std::make_pair(this, &EntityGroup::onRemove);
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

EntityObserver::EntityObserver(int option, const vector<string>& components):
_option(option)
{
	_components.resize(components.size());
	for (int i = 0; i < s_cast<int>(components.size()); i++)
	{
		_components[i] = components[i];
	}
}

EntityObserver::EntityObserver(int option, Slice components[], int count):
_option(option)
{
	_components.resize(count);
	for (int i = 0; i < count; i++)
	{
		_components[i] = components[i];
	}
}

EntityObserver::~EntityObserver()
{
	for (const auto& name : _components)
	{
		switch (_option)
		{
			case Entity::Add:
				SharedEntityPool.getAddHandler(name) -= std::make_pair(this, &EntityObserver::onEvent);
				break;
			case Entity::Change:
				SharedEntityPool.getChangeHandler(name) -= std::make_pair(this, &EntityObserver::onEvent);
				break;
			case Entity::AddOrChange:
				SharedEntityPool.getAddHandler(name) -= std::make_pair(this, &EntityObserver::onEvent);
				SharedEntityPool.getChangeHandler(name) -= std::make_pair(this, &EntityObserver::onEvent);
				break;
			case Entity::Remove:
				SharedEntityPool.getRemoveHandler(name) -= std::make_pair(this, &EntityObserver::onEvent);
				break;
		}
	}
}

bool EntityObserver::init()
{
	for (const auto& name : _components)
	{
		switch (_option)
		{
			case Entity::Add:
				SharedEntityPool.getAddHandler(name) += std::make_pair(this, &EntityObserver::onEvent);
				break;
			case Entity::Change:
				SharedEntityPool.getChangeHandler(name) += std::make_pair(this, &EntityObserver::onEvent);
				break;
			case Entity::AddOrChange:
				SharedEntityPool.getAddHandler(name) += std::make_pair(this, &EntityObserver::onEvent);
				SharedEntityPool.getChangeHandler(name) += std::make_pair(this, &EntityObserver::onEvent);
				break;
			case Entity::Remove:
				SharedEntityPool.getRemoveHandler(name) += std::make_pair(this, &EntityObserver::onEvent);
				break;
		}
	}
	WRef<EntityObserver> self(this);
	SharedDirector.getPostSystemScheduler()->schedule([self](double deltaTime)
	{
		DORA_UNUSED_PARAM(deltaTime);
		if (self)
		{
			self->_entities.clear();
			return false;
		}
		return true;
	});
	return true;
}

void EntityObserver::onEvent(Entity* entity)
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

NS_DOROTHY_END
