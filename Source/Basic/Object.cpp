/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Basic/Object.h"
#include "Basic/AutoreleasePool.h"
#include "Lua/tolua_fix.h"

NS_DOROTHY_BEGIN

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

Uint32 Object::_maxIdCount;
Uint32 Object::_maxLuaRefCount;
Uint32 Object::_luaRefCount;

stack<Uint32> Object::_availableIds;
stack<Uint32> Object::_availableLuaRefs;

Object::Object():
_managed(false),
_refCount(1),
_luaRef(0),
_weak(nullptr)
{
	if (_availableIds.empty())
	{
		_id = ++_maxIdCount;
	}
	else
	{
		_id = _availableIds.top();
		_availableIds.pop();
	}
}

Object::~Object()
{
	AssertIf(_managed, "object is still managed when destroyed.");
	_availableIds.push(_id);
	if (_luaRef != 0)
	{
		_availableLuaRefs.push(_luaRef);
	}
}

bool Object::init()
{
	// Log("%s", typeid(*this).name());
	return true;
}

void Object::release()
{
	AssertUnless(_refCount > 0, "reference count should greater than 0.");
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
	AssertUnless(_refCount > 0, "reference count should greater than 0.");
    ++_refCount;
}

Object* Object::autorelease()
{
	AssertIf(_managed, "object is already managed.");
	SharedPoolManager.addObject(this);
	return this;
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

Uint32 Object::getId() const
{
	return _id;
}

Uint32 Object::getObjectCount()
{
	return _maxIdCount - (Uint32)_availableIds.size();
}

Uint32 Object::getMaxObjectCount()
{
	return _maxIdCount;
}

Uint32 Object::getLuaRefCount()
{
	return _luaRefCount;
}

Uint32 Object::getMaxLuaRefCount()
{
	return _maxLuaRefCount;
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
	++_luaRefCount;
}

void Object::removeLuaRef()
{
	--_luaRefCount;
}

Uint32 Object::getLuaRef()
{
	if (_luaRef == 0)
	{
		if (_availableLuaRefs.empty())
		{
			_luaRef = ++_maxLuaRefCount;
		}
		else
		{
			_luaRef = _availableLuaRefs.top();
			_availableLuaRefs.pop();
		}
	}
	return _luaRef;
}

bool Object::isLuaReferenced() const
{
	return _luaRef != 0;
}

NS_DOROTHY_END
