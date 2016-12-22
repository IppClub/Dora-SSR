/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/oHeader.h"
#include "Basic/oAutoreleasePool.h"

NS_DOROTHY_BEGIN

oAutoreleasePool::~oAutoreleasePool()
{
	clear();
}

void oAutoreleasePool::addObject(oObject* object)
{
	_managedObjects.push_back(object);
	oAssertUnless(object->getRefCount() > 1, "reference count should be greater than 1.");
	object->_managed = true;
	object->release();
}

void oAutoreleasePool::removeObject(oObject* object)
{
	oRef<oObject> objectRef(object);
	if (_managedObjects.fast_remove(object))
	{
		object->_managed = false;
		object->retain();
	}
}

void oAutoreleasePool::clear()
{
	for (oObject* object : _managedObjects)
	{
		object->_managed = false;
	}
	_managedObjects.clear();
}

void oPoolManager::clear()
{
	stack<oRef<oAutoreleasePool>> emptyStack;
	_releasePoolStack.swap(emptyStack);
}

void oPoolManager::push()
{
	oAutoreleasePool* pool = new oAutoreleasePool();
	_releasePoolStack.push(oRefMake(pool));
	pool->release();
}

void oPoolManager::pop()
{
	if (!_releasePoolStack.empty())
	{
		_releasePoolStack.pop();
	}
}

void oPoolManager::removeObject(oObject* object)
{
	oAssertIf(_releasePoolStack.empty(), "current auto release pool stack should not be empty.");
	_releasePoolStack.top()->removeObject(object);
}

void oPoolManager::addObject(oObject* object)
{
	oAssertIf(_releasePoolStack.empty(), "current auto release pool stack should not be empty.");
	_releasePoolStack.top()->addObject(object);
}

NS_DOROTHY_END
