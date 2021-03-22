/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Basic/Object.h"
#include "Basic/AutoreleasePool.h"
#include "Lua/ToLua/tolua++.h"

NS_DOROTHY_BEGIN

class ObjectBase
{
public:
	ObjectBase():
	maxIdCount(0),
	maxLuaRefCount(0),
	luaRefCount(0)
	{ }
	virtual ~ObjectBase()
	{
#if DORA_DEBUG
		int count = s_cast<int>(maxIdCount) - s_cast<int>(availableIds.size());
		if (count > 0)
		{
			Warn("{} C++ objects leaks.", count);
		}
#endif // DORA_DEBUG
	}
	Uint32 maxIdCount;
	Uint32 maxLuaRefCount;
	Uint32 luaRefCount;
	stack<Uint32> availableLuaRefs;
	stack<Uint32> availableIds;
	SINGLETON_REF(ObjectBase, AsyncLogThread);
};

#define SharedObjectBase \
	Singleton<ObjectBase>::shared()

Weak::Weak(Object* target):
target(target),
_refCount(1)
{ }

void Weak::release()
{
	--_refCount;
	if (_refCount == 0)
	{
		delete this;
	}
}

void Weak::retain()
{
	++_refCount;
}

Object::Object():
_managed(false),
_refCount(1),
_luaRef(0),
_weak(nullptr)
{
	auto& info = SharedObjectBase;
	if (info.availableIds.empty())
	{
		_id = ++info.maxIdCount;
	}
	else
	{
		_id = info.availableIds.top();
		info.availableIds.pop();
	}
}

Object::~Object()
{
	auto& info = SharedObjectBase;
	assert(!_managed); // object is still managed when destroyed
	info.availableIds.push(_id);
	if (_luaRef != 0)
	{
		info.availableLuaRefs.push(_luaRef);
	}
}

bool Object::init()
{
	// Info("{}", typeid(*this).name());
	return true;
}

void Object::release()
{
	AssertUnless(_refCount > 0, "reference count should be greater than 0.");
	--_refCount;
	if (_refCount == 0)
	{
		if (_weak)
		{
			_weak->target = nullptr;
			_weak->release();
		}
		delete this;
	}
}

void Object::retain()
{
	AssertUnless(_refCount > 0, "reference count should be greater than 0.");
	++_refCount;
}

void Object::autorelease()
{
	AssertIf(_managed, "object is already managed.");
	SharedPoolManager.addObject(this);
}

void Object::autoretain()
{
	if (!_managed)
	{
		retain();
		autorelease();
	}
}

bool Object::isSingleReferenced() const
{
	return _refCount == 1;
}

Uint32 Object::getRefCount() const
{
	return _refCount;
}

bool Object::update(double deltaTime)
{
	DORA_UNUSED_PARAM(deltaTime);
	return true;
}

bool Object::fixedUpdate(double deltaTime)
{
	DORA_UNUSED_PARAM(deltaTime);
	return true;
}

bool Object::equals(Object* other) const
{
	return this == other;
}

void Object::cleanup()
{
	if (_weak) _weak->target = nullptr;
}

Uint32 Object::getId() const
{
	return _id;
}

Uint32 Object::getCount()
{
	auto& info = SharedObjectBase;
	return info.maxIdCount - s_cast<Uint32>(info.availableIds.size());
}

Uint32 Object::getMaxCount()
{
	return SharedObjectBase.maxIdCount;
}

Uint32 Object::getLuaRefCount()
{
	return SharedObjectBase.luaRefCount;
}

Uint32 Object::getMaxLuaRefCount()
{
	return SharedObjectBase.maxLuaRefCount;
}

Uint32 Object::getLuaCallbackCount()
{
	return tolua_get_callback_ref_count();
}

Uint32 Object::getMaxLuaCallbackCount()
{
	return tolua_get_max_callback_ref_count();
}

Weak* Object::getWeakRef()
{
	if (!_weak)
	{
		_weak = new Weak(this);
		return _weak;
	}
	return _weak;
}

void Object::addLuaRef()
{
	++SharedObjectBase.luaRefCount;
}

void Object::removeLuaRef()
{
	--SharedObjectBase.luaRefCount;
}

Uint32 Object::getLuaRef()
{
	if (_luaRef == 0)
	{
		auto& info = SharedObjectBase;
		if (info.availableLuaRefs.empty())
		{
			_luaRef = ++info.maxLuaRefCount;
		}
		else
		{
			_luaRef = info.availableLuaRefs.top();
			info.availableLuaRefs.pop();
		}
	}
	return _luaRef;
}

bool Object::isLuaReferenced() const
{
	return _luaRef != 0;
}

NS_DOROTHY_END
