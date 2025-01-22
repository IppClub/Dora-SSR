/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Basic/Object.h"

#include "Basic/AutoreleasePool.h"
#include "Lua/ToLua/tolua++.h"

NS_DORA_BEGIN

class ObjectBase : public NonCopyable {
public:
	ObjectBase()
		: maxIdCount(0)
		, maxLuaRefCount(0)
		, luaRefCount(0) { }
	virtual ~ObjectBase() {
		int count = s_cast<int>(maxIdCount) - s_cast<int>(availableIds.size());
		if (count > 0) {
			Warn("{} C++ objects leaks.", count);
		}
	}
	uint32_t maxIdCount;
	uint32_t maxLuaRefCount;
	uint32_t luaRefCount;
	std::stack<uint32_t> availableLuaRefs;
	std::stack<uint32_t> availableIds;
	SINGLETON_REF(ObjectBase, AsyncLogThread, Logger);
};

#define SharedObjectBase \
	Singleton<ObjectBase>::shared()

Weak::Weak(Object* target)
	: target(target)
	, _refCount(1) { }

void Weak::release() {
	--_refCount;
	if (_refCount == 0) {
		delete this;
	}
}

void Weak::retain() {
	++_refCount;
}

Object::Object()
	: _refCount(0)
	, _luaRef(0)
	, _weak(nullptr) {
	auto& info = SharedObjectBase;
	if (info.availableIds.empty()) {
		_id = ++info.maxIdCount;
	} else {
		_id = info.availableIds.top();
		info.availableIds.pop();
	}
}

Object::~Object() {
	auto& info = SharedObjectBase;
	assert(_refCount == 0); // object should not be referenced when destroyed
	info.availableIds.push(_id);
	if (_luaRef != 0) {
		info.availableLuaRefs.push(_luaRef);
	}
}

bool Object::init() {
	// Info("{}", typeid(*this).name());
	return true;
}

void Object::release() {
	AssertUnless(_refCount > 0, "reference count should be greater than 0.");
	--_refCount;
	if (_refCount == 0) {
		if (_weak) {
			_weak->target = nullptr;
			_weak->release();
		}
		delete this;
	}
}

void Object::retain() {
	AssertUnless(_refCount >= 0, "reference count should not be negtive value.");
	++_refCount;
}

void Object::autorelease() {
	SharedPoolManager.addObject(this);
}

bool Object::isSingleReferenced() const noexcept {
	return _refCount == 1;
}

uint32_t Object::getRefCount() const noexcept {
	return _refCount;
}

void Object::cleanup() {
	if (_weak) _weak->target = nullptr;
}

uint32_t Object::getId() const noexcept {
	return _id;
}

uint32_t Object::getCount() {
	auto& info = SharedObjectBase;
	return info.maxIdCount - s_cast<uint32_t>(info.availableIds.size());
}

uint32_t Object::getMaxCount() {
	return SharedObjectBase.maxIdCount;
}

uint32_t Object::getLuaRefCount() {
	return SharedObjectBase.luaRefCount;
}

uint32_t Object::getMaxLuaRefCount() {
	return SharedObjectBase.maxLuaRefCount;
}

uint32_t Object::getLuaCallbackCount() {
	return tolua_get_callback_ref_count();
}

uint32_t Object::getMaxLuaCallbackCount() {
	return tolua_get_max_callback_ref_count();
}

Weak* Object::getWeakRef() {
	if (!_weak) {
		_weak = new Weak(this);
		return _weak;
	}
	return _weak;
}

uint32_t Object::getLuaRef() {
	if (_luaRef == 0) {
		auto& info = SharedObjectBase;
		if (info.availableLuaRefs.empty()) {
			_luaRef = ++info.maxLuaRefCount;
		} else {
			_luaRef = info.availableLuaRefs.top();
			info.availableLuaRefs.pop();
		}
	}
	return _luaRef;
}

bool Object::isLuaReferenced() const noexcept {
	return _luaRef != 0;
}

void Object::incLuaRefCount() {
	++SharedObjectBase.luaRefCount;
}

void Object::decLuaRefCount() {
	--SharedObjectBase.luaRefCount;
}

NS_DORA_END
