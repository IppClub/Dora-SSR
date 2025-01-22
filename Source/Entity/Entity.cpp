/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Entity/Entity.h"

#include "Basic/Application.h"
#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Lua/LuaHandler.h"

NS_DORA_BEGIN

typedef Acf::Delegate<void(Entity*)> EntityEventHandler;

class EntityPool : public NonCopyable {
public:
	EntityPool() {
		SharedDirector.getPostScheduler()->schedule([this](double deltaTime) {
			DORA_UNUSED_PARAM(deltaTime);
			for (auto& nextValue : nextValues) {
				NextId nid;
				nid.value = nextValue.first;
				NextEvent event = s_cast<NextEvent>(nid.id.event);
				Entity* entity = entities[nid.id.entity];
				if (entity) {
					switch (event) {
						case NextEvent::Add:
							entity->registerAddEvent(nid.id.component);
							break;
						case NextEvent::Update:
							entity->registerUpdateEvent(nid.id.component, std::move(nextValue.second));
							break;
						case NextEvent::Remove:
							entity->registerRemoveEvent(nid.id.component, std::move(nextValue.second));
							break;
					}
				}
			}
			nextValues.clear();
			triggers.erase(std::remove_if(triggers.begin(), triggers.end(), [](const auto& trigger) {
				return trigger();
			}),
				triggers.end());
			for (auto& it : observers) {
				it.second->clear();
			}
			for (Entity* entity : updatedEntities) {
				if (entity) {
					entity->clearOldComs();
				}
			}
			updatedEntities.clear();
			return false;
		});
		SharedApplication.quitHandler += [this]() {
			clear();
		};
	}
	virtual ~EntityPool() { }
	int tryGetIndex(String name) const {
		auto it = comIndices.find(name);
		return it == comIndices.end() ? -1 : it->second;
	}
	int getIndex(String name) {
		auto it = comIndices.find(name);
		if (it == comIndices.end()) {
			int index = s_cast<int>(comIndices.size());
			comIndices[name.toString()] = index;
			return index;
		}
		return it->second;
	}
	union NextId {
		struct Id {
			int32_t entity;
			int16_t component;
			int16_t event;
		} id;
		uint64_t value;
	};
	enum class NextEvent {
		Add,
		Update,
		Remove
	};
	static_assert(sizeof(NextId) == sizeof(uint64_t), "invalid updated entity id size");
	std::stack<Ref<Entity>> availableEntities;
	RefVector<Entity> entities;
	std::vector<std::function<bool()>> triggers;
	std::unordered_set<int> usedIndices;
	StringMap<int> comIndices;
	std::unordered_set<WRef<Entity>, WRefEntityHasher> updatedEntities;
	std::vector<EntityEventHandler> addHandlers;
	std::vector<EntityEventHandler> changeHandlers;
	std::vector<EntityEventHandler> removeHandlers;
	std::vector<EntityEventHandler> groupAddHandlers;
	std::vector<EntityEventHandler> groupRemoveHandlers;
	std::unordered_map<uint64_t, Own<Value>> nextValues;
	StringMap<Ref<EntityGroup>> groups;
	StringMap<Ref<EntityObserver>> observers;
	EntityEventHandler& getAddHandler(int index) {
		while (s_cast<int>(addHandlers.size()) <= index) addHandlers.emplace_back();
		return addHandlers[index];
	}
	EntityEventHandler& getGroupAddHandler(int index) {
		while (s_cast<int>(groupAddHandlers.size()) <= index) groupAddHandlers.emplace_back();
		return groupAddHandlers[index];
	}
	EntityEventHandler& getChangeHandler(int index) {
		while (s_cast<int>(changeHandlers.size()) <= index) changeHandlers.emplace_back();
		return changeHandlers[index];
	}
	EntityEventHandler& getGroupRemoveHandler(int index) {
		while (s_cast<int>(groupRemoveHandlers.size()) <= index) groupRemoveHandlers.emplace_back();
		return groupRemoveHandlers[index];
	}
	EntityEventHandler& getRemoveHandler(int index) {
		while (s_cast<int>(removeHandlers.size()) <= index) removeHandlers.emplace_back();
		return removeHandlers[index];
	}
	bool eachEntity(const std::function<bool(Entity*)>& func) {
		WRefVector<Entity> allEntities;
		allEntities.reserve(usedIndices.size());
		for (auto index : usedIndices) {
			allEntities.push_back(entities[index]);
		}
		for (Entity* entity : entities) {
			if (entity && func(entity)) {
				return true;
			}
		}
		return false;
	}
	void clear() {
		eachEntity([](Entity* entity) {
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

Entity::Entity(int index)
	: _index(index) { }

int Entity::getIndex() const noexcept {
	return _index;
}

void Entity::destroy() {
	for (int i = 0; i < s_cast<int>(_components.size()); i++) {
		if (_components[i] != nullptr) {
			remove(i);
		}
	}
	if (!SharedEntityPool.entities.empty()) {
		SharedEntityPool.availableEntities.push(MakeRef(this));
		SharedEntityPool.usedIndices.erase(_index);
	}
}

int Entity::getIndex(String name) {
	return SharedEntityPool.getIndex(name);
}

bool Entity::has(String name) const {
	auto& comIndices = SharedEntityPool.comIndices;
	auto it = comIndices.find(name);
	if (it != comIndices.end()) {
		return has(it->second);
	}
	return false;
}

bool Entity::has(int index) const {
	if (0 <= index && index < s_cast<int>(_components.size())) {
		return _components[index] != nullptr;
	}
	return false;
}

bool Entity::hasOld(int index) const {
	if (0 <= index && index < s_cast<int>(_oldComs.size())) {
		return _oldComs[index] != nullptr;
	}
	return false;
}

void Entity::remove(String name) {
	int index = SharedEntityPool.tryGetIndex(name);
	if (index >= 0) set(index, nullptr);
}

void Entity::remove(int index) {
	set(index, nullptr);
}

bool Entity::each(const std::function<bool(Entity*)>& func) {
	return SharedEntityPool.eachEntity(func);
}

void Entity::clear() {
	SharedEntityPool.clear();
}

uint32_t Entity::getCount() {
	return s_cast<uint32_t>(SharedEntityPool.usedIndices.size());
}

void Entity::set(int index, Own<Value>&& value) {
	EntityPool::NextEvent event;
	Own<Value> old;
	Value* com = getComponent(index);
	if (com) {
		old = com->clone();
		if (value) {
			_components[index] = value->clone();
			event = EntityPool::NextEvent::Update;
		} else {
			_components[index] = nullptr;
			event = EntityPool::NextEvent::Remove;
			auto& handler = SharedEntityPool.getGroupRemoveHandler(index);
			if (!handler.IsEmpty()) handler(this);
		}
	} else {
		if (!value) return;
		while (s_cast<int>(_components.size()) <= index) _components.emplace_back();
		while (s_cast<int>(_oldComs.size()) <= index) _oldComs.emplace_back();
		_components[index] = value->clone();
		event = EntityPool::NextEvent::Add;
		auto& handler = SharedEntityPool.getGroupAddHandler(index);
		if (!handler.IsEmpty()) handler(this);
	}
	int id = getIndex();
	EntityPool::NextId nid;
	nid.id.entity = id;
	nid.id.component = s_cast<int16_t>(index);
	nid.id.event = s_cast<int16_t>(event);
	auto& nextValues = SharedEntityPool.nextValues;
	if (value) {
		auto it = nextValues.find(nid.value);
		if (it == nextValues.end()) {
			nextValues[nid.value] = std::move(old);
		}
	} else {
		/* replace Add and Update events with Remove event */
		EntityPool::NextId uid;
		uid.id.entity = id;
		uid.id.component = s_cast<int16_t>(index);
		uid.id.event = s_cast<int16_t>(EntityPool::NextEvent::Add);
		if (auto it = nextValues.find(uid.value); it != nextValues.end()) {
			nextValues.erase(it);
		}
		uid.id.event = s_cast<int16_t>(EntityPool::NextEvent::Update);
		if (auto it = nextValues.find(uid.value); it != nextValues.end()) {
			old = std::move(it->second);
			nextValues.erase(it);
		}
		nextValues[nid.value] = std::move(old);
	}
}

void Entity::set(String name, Own<Value>&& value) {
	int index = getIndex(name);
	Entity::set(index, std::move(value));
}

void Entity::registerAddEvent(int index) {
	auto& handler = SharedEntityPool.getAddHandler(index);
	if (!handler.IsEmpty()) {
		SharedEntityPool.updatedEntities.insert(MakeWRef(this));
		handler(this);
	}
}

void Entity::registerUpdateEvent(int index, Own<Value>&& old) {
	auto& handler = SharedEntityPool.getChangeHandler(index);
	if (!handler.IsEmpty()) {
		_oldComs[index] = std::move(old);
		SharedEntityPool.updatedEntities.insert(MakeWRef(this));
		handler(this);
	}
}

void Entity::registerRemoveEvent(int index, Own<Value>&& old) {
	auto& handler = SharedEntityPool.getRemoveHandler(index);
	if (!handler.IsEmpty()) {
		_oldComs[index] = std::move(old);
		SharedEntityPool.updatedEntities.insert(MakeWRef(this));
		handler(this);
	}
}

Value* Entity::getComponent(String name) const {
	int index = SharedEntityPool.tryGetIndex(name);
	return getComponent(index);
}

Value* Entity::getComponent(int index) const {
	return has(index) ? _components[index].get() : nullptr;
}

Value* Entity::getOldCom(String name) const {
	int index = SharedEntityPool.tryGetIndex(name);
	return getOldCom(index);
}

Value* Entity::getOldCom(int index) const {
	return hasOld(index) ? _oldComs[index].get() : nullptr;
}

void Entity::clearOldComs() {
	std::fill(_oldComs.begin(), _oldComs.end(), nullptr);
}

Entity* Entity::create() {
	auto& entities = SharedEntityPool.entities;
	auto& usedIndices = SharedEntityPool.usedIndices;
	auto& availableEntities = SharedEntityPool.availableEntities;
	if (!availableEntities.empty()) {
		Ref<Entity> entity = availableEntities.top();
		availableEntities.pop();
		entities[entity->getIndex()] = entity;
		usedIndices.insert(entity->getIndex());
		return entity;
	}
	Entity* entity = Object::createNotNull<Entity>(s_cast<int>(entities.size()));
	entities.push_back(entity);
	usedIndices.insert(entity->getIndex());
	return entity;
}

int Entity::getComIndex(String name) {
	return SharedEntityPool.getIndex(name);
}

int Entity::tryGetComIndex(String name) {
	return SharedEntityPool.tryGetIndex(name);
}

EntityGroup::EntityGroup(const std::vector<std::string>& components) {
	_components.resize(components.size());
	for (int i = 0; i < s_cast<int>(components.size()); i++) {
		_components[i] = SharedEntityPool.getIndex(components[i]);
	}
}

EntityGroup::~EntityGroup() {
	if (Singleton<EntityPool>::isDisposed()) return;
	for (const auto& index : _components) {
		SharedEntityPool.getGroupAddHandler(index) -= std::make_pair(this, &EntityGroup::onAdd);
		SharedEntityPool.getGroupRemoveHandler(index) -= std::make_pair(this, &EntityGroup::onRemove);
	}
}

const std::vector<int>& EntityGroup::getComponents() const noexcept {
	return _components;
}

int EntityGroup::getCount() const noexcept {
	return s_cast<int>(_entities.size());
}

Entity* EntityGroup::getFirst() const noexcept {
	if (_entities.empty()) {
		return nullptr;
	}
	return *_entities.begin();
}

bool EntityGroup::init() {
	Object::init();
	Entity::each([this](Entity* entity) {
		bool match = true;
		for (int index : _components) {
			if (!entity->has(index)) {
				match = false;
				break;
			}
		}
		if (match) {
			_entities.insert(MakeWRef(entity));
		}
		return false;
	});
	for (int index : _components) {
		SharedEntityPool.getGroupAddHandler(index) += std::make_pair(this, &EntityGroup::onAdd);
		SharedEntityPool.getGroupRemoveHandler(index) += std::make_pair(this, &EntityGroup::onRemove);
	}
	return true;
}

void EntityGroup::onAdd(Entity* entity) {
	bool match = true;
	for (const auto& name : _components) {
		if (!entity->has(name)) {
			match = false;
			break;
		}
	}
	if (match) {
		_entities.insert(MakeWRef(entity));
	}
}

void EntityGroup::onRemove(Entity* entity) {
	_entities.erase(MakeWRef(entity));
}

EntityGroup* EntityGroup::watch(const EntityHandler& handler) {
	WRef<EntityGroup> self(this);
	SharedEntityPool.triggers.push_back([self, handler]() {
		if (!self) return true;
		return self->each([&handler](Entity* entity) {
			return handler(entity);
		});
	});
	return this;
}

EntityGroup* EntityGroup::watch(LuaHandler* handler) {
	WRef<EntityGroup> self(this);
	Ref<LuaHandler> hRef(handler);
	SharedEntityPool.triggers.push_back([self, hRef]() {
		if (!self) return true;
		return self->each([&](Entity* entity) {
			auto L = SharedLuaEngine.getState();
			tolua_pushobject(L, entity);
			for (int i : self->_components) {
				auto com = entity->getComponent(i);
				if (com)
					com->pushToLua(L);
				else
					lua_pushnil(L);
			}
			return LuaEngine::execute(L, hRef->get(), self->_components.size() + 1);
		});
	});
	return this;
}

EntityGroup* EntityGroup::create(const std::vector<std::string>& components) {
	std::vector<std::string> coms = components;
	std::sort(coms.begin(), coms.end());
	std::string name;
	for (const auto& com : coms) {
		name += com;
	}
	auto& groups = SharedEntityPool.groups;
	auto it = groups.find(name);
	if (it != groups.end()) {
		return it->second;
	}
	EntityGroup* entityGroup = Object::createNotNull<EntityGroup>(components);
	groups[name] = entityGroup;
	return entityGroup;
}

EntityGroup* EntityGroup::create(Slice components[], int count) {
	std::vector<std::string> coms;
	coms.resize(count);
	for (int i = 0; i < count; i++) {
		coms[i] = components[i].toString();
	}
	return EntityGroup::create(coms);
}

/* EntityObserver */

const std::vector<int>& EntityObserver::getComponents() const noexcept {
	return _components;
}

EntityObserver::EntityObserver(int eventType, const std::vector<std::string>& components)
	: _eventType(eventType) {
	_components.resize(components.size());
	for (int i = 0; i < s_cast<int>(components.size()); i++) {
		_components[i] = SharedEntityPool.getIndex(components[i]);
	}
}

EntityObserver::~EntityObserver() {
	if (Singleton<EntityPool>::isDisposed()) return;
	for (int index : _components) {
		switch (_eventType) {
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

bool EntityObserver::init() {
	if (!Object::init()) return false;
	for (int index : _components) {
		switch (_eventType) {
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

void EntityObserver::onEvent(Entity* entity) {
	bool match = true;
	if (_eventType == Entity::Remove) {
		for (int index : _components) {
			if (!entity->has(index) && !entity->hasOld(index)) {
				match = false;
				break;
			}
		}
	} else {
		for (int index : _components) {
			if (!entity->has(index)) {
				match = false;
				break;
			}
		}
	}
	if (match) {
		_entities.insert(MakeWRef(entity));
	}
}

EntityObserver* EntityObserver::watch(const EntityHandler& handler) {
	WRef<EntityObserver> self(this);
	SharedEntityPool.triggers.push_back([self, handler]() {
		if (!self) return true;
		return self->each([&handler](Entity* entity) {
			return handler(entity);
		});
	});
	return this;
}

EntityObserver* EntityObserver::watch(LuaHandler* handler) {
	WRef<EntityObserver> self(this);
	Ref<LuaHandler> hRef(handler);
	SharedEntityPool.triggers.push_back([self, hRef]() {
		if (!self) return true;
		return self->each([&](Entity* entity) {
			auto L = SharedLuaEngine.getState();
			tolua_pushobject(L, entity);
			for (int i : self->_components) {
				auto com = entity->getComponent(i);
				if (com)
					com->pushToLua(L);
				else
					lua_pushnil(L);
			}
			return LuaEngine::execute(L, hRef->get(), self->_components.size() + 1);
		});
	});
	return this;
}

void EntityObserver::clear() {
	_entities.clear();
}

int EntityObserver::getEventType() const noexcept {
	return _eventType;
}

EntityObserver* EntityObserver::create(int option, const std::vector<std::string>& components) {
	fmt::memory_buffer out;
	fmt::format_to(std::back_inserter(out), "{}"sv, option);
	for (const auto& com : components) {
		fmt::format_to(std::back_inserter(out), "{}"sv, com);
	}
	std::string name = fmt::to_string(out);
	auto& observers = SharedEntityPool.observers;
	auto it = observers.find(name);
	if (it != observers.end()) {
		return it->second;
	}
	EntityObserver* entityObserver = Object::createNotNull<EntityObserver>(option, components);
	observers[name] = entityObserver;
	return entityObserver;
}

EntityObserver* EntityObserver::create(int option, Slice components[], int count) {
	std::vector<std::string> coms;
	coms.resize(count);
	for (int i = 0; i < count; i++) {
		coms[i] = components[i].toString();
	}
	return EntityObserver::create(option, coms);
}

NS_DORA_END
