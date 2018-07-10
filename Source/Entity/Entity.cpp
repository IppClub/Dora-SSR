/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Entity/Entity.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Basic/Application.h"
#include "Support/Dictionary.h"

NS_DOROTHY_BEGIN

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
					entity->clearValueCache();
				}
			}
			updatedEntities.clear();
			return false;
		});
		SharedApplication.quitHandler += [this]() { clear(); };
	}
	virtual ~EntityPool() { }
	stack<Ref<Entity>> availableEntities;
	RefVector<Entity> entities;
	vector<Delegate<void()>> triggers;
	unordered_set<int> usedIndices;
	unordered_set<WRef<Entity>, WRefEntityHasher> updatedEntities;
	unordered_map<string, HandlerItem> addHandlers;
	unordered_map<string, HandlerItem> changeHandlers;
	unordered_map<string, HandlerItem> removeHandlers;
	unordered_map<string, Ref<EntityGroup>> groups;
	unordered_map<string, Ref<EntityObserver>> observers;
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
	bool eachEntity(const function<bool(Entity*)>& func)
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
		stack<Ref<Entity>> empty;
		availableEntities.swap(empty);
		entities.clear();
		usedIndices.clear();
		groups.clear();
		observers.clear();
		triggers.clear();
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
		if (!_valueCache->has(name))
		{
			_valueCache->set(name, it->second->clone());
			SharedEntityPool.updatedEntities.insert(MakeWRef(this));
		}
		(*handlerIt->second.handler)(this);
	}
	_components.erase(name);
}

bool Entity::each(const function<bool(Entity*)>& func)
{
	return SharedEntityPool.eachEntity(func);
}

void Entity::clear()
{
	SharedEntityPool.clear();
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
		if (!_valueCache->has(name))
		{
			_valueCache->set(name, add ? nullptr : value->clone());
			SharedEntityPool.updatedEntities.insert(MakeWRef(this));
		}
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

void Entity::set(String name, Object* value, bool rawFlag)
{
	Value* valueItem = getComponent(name);
	if (rawFlag)
	{
		AssertIf(valueItem == nullptr, "raw set non-exist component \"{}\"", name);
		auto content = valueItem->as<Object*>();
		AssertIf(content == nullptr, "assign non-exist component \"{}\".", name);
		content->set(MakeRef(value));
		return;
	}
	if (valueItem)
	{
		auto content = valueItem->as<Object*>();
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

EntityGroup::~EntityGroup()
{
	if (Singleton<EntityPool>::isDisposed()) return;
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

EntityGroup* EntityGroup::create(const vector<string>& components)
{
	vector<string> coms = components;
	std::sort(coms.begin(), coms.end());
	string name;
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
	vector<string> coms;
	coms.reserve(count);
	for (int i = 0; i < count; i++)
	{
		coms.push_back(components[i]);
	}
	return EntityGroup::create(coms);
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

EntityObserver::~EntityObserver()
{
	if (Singleton<EntityPool>::isDisposed()) return;
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
	vector<string> coms;
	coms.reserve(count);
	for (int i = 0; i < count; i++)
	{
		coms.push_back(components[i]);
	}
	return EntityObserver::create(option, coms);
}

NS_DOROTHY_END
