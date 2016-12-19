/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/oHeader.h"
#include "Basic/oObject.h"
#include "Basic/oAutoreleasePool.h"

NS_DOROTHY_BEGIN

oWeak::oWeak(oObject* target):
target(target),
_refCount(1)
{ }

void oWeak::release()
{
	--_refCount;
	if (_refCount == 0)
	{
		delete this;
	}
}

void oWeak::retain()
{
	++_refCount;
}

Uint32 oObject::_maxIdCount;
Uint32 oObject::_maxLuaRefCount;
Uint32 oObject::_luaRefCount;

stack<Uint32> oObject::_availableIds;
stack<Uint32> oObject::_availableLuaRefs;

oObject::oObject():
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

oObject::~oObject()
{
	oAssertIf(_managed, "object is still managed when destroyed");
	_availableIds.push(_id);
	if (_luaRef != 0)
	{
		_availableLuaRefs.push(_luaRef);
	}
}

bool oObject::init()
{
	// oLog("%s", typeid(*this).name());
	return true;
}

void oObject::release()
{
	oAssertUnless(_refCount > 0, "reference count should greater than 0");
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

void oObject::retain()
{
	oAssertUnless(_refCount > 0, "reference count should greater than 0");
    ++_refCount;
}

oObject* oObject::autorelease()
{
	oAssertIf(_managed, "object is already managed");
	oSharedPoolManager.addObject(this);
	return this;
}

bool oObject::isSingleReferenced() const
{
    return _refCount == 1;
}

Uint32 oObject::getRefCount() const
{
    return _refCount;
}

void oObject::update(float dt)
{
	DORA_UNUSED_PARAM(dt);
}

Uint32 oObject::getId() const
{
	return _id;
}

Uint32 oObject::getObjectCount()
{
	return _maxIdCount - (Uint32)_availableIds.size();
}

Uint32 oObject::getLuaRefCount()
{
	return _luaRefCount;
}

Uint32 oObject::getMaxObjectCount()
{
	return _maxIdCount;
}

Uint32 oObject::getMaxLuaRefCount()
{
	return _maxLuaRefCount;
}

oWeak* oObject::getWeakRef()
{
	if (!_weak)
	{
		_weak = new oWeak(this);
		return _weak;
	}
	return _weak;
}

void oObject::addLuaRef()
{
	++_luaRefCount;
}

void oObject::removeLuaRef()
{
	--_luaRefCount;
}

Uint32 oObject::getLuaRef()
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

bool oObject::isLuaReferenced() const
{
	return _luaRef != 0;
}

NS_DOROTHY_END
