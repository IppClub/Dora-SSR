/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Basic/AutoreleasePool.h"

NS_DOROTHY_BEGIN

PoolManager::~PoolManager()
{
	clear();
}

void PoolManager::clear()
{
	std::stack<Ref<AutoreleasePool>> emptyStack;
	_releasePoolStack.swap(emptyStack);
}

void PoolManager::push()
{
	AutoreleasePool* pool = new AutoreleasePool();
	_releasePoolStack.push(MakeRef(pool));
	pool->release();
}

void PoolManager::pop()
{
	if (!_releasePoolStack.empty())
	{
		_releasePoolStack.pop();
	}
}

void PoolManager::removeObject(Object* object)
{
	AssertIf(_releasePoolStack.empty(), "current auto release pool stack should not be empty.");
	_releasePoolStack.top()->removeObject(object);
}

void PoolManager::addObject(Object* object)
{
	AssertIf(_releasePoolStack.empty(), "current auto release pool stack should not be empty.");
	_releasePoolStack.top()->addObject(object);
}

PoolManager::AutoreleasePool::~AutoreleasePool()
{
	AutoreleasePool::clear();
}

void PoolManager::AutoreleasePool::addObject(Object* object)
{
	_managedObjects.push_back(object);
	AssertUnless(object->getRefCount() > 1, "reference count should be greater than 1.");
	object->_managed = true;
	object->release();
}

void PoolManager::AutoreleasePool::removeObject(Object* object)
{
	Ref<Object> objectRef(object);
	if (_managedObjects.fast_remove(object))
	{
		object->_managed = false;
		object->retain();
	}
}

void PoolManager::AutoreleasePool::clear()
{
	for (Object* object : _managedObjects)
	{
		object->_managed = false;
	}
	_managedObjects.clear();
}

NS_DOROTHY_END
