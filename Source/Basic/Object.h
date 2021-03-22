/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

class Object;
class Weak
{
public:
	Weak(Object* target);
	void release();
	void retain();
	Object* target;
private:
	int _refCount;
};

class Object
{
public:
	PROPERTY_READONLY(Uint32, Id);
	PROPERTY_READONLY_CALL(Uint32, LuaRef);
	PROPERTY_READONLY_BOOL(LuaReferenced);
	PROPERTY_READONLY_BOOL(SingleReferenced);
	PROPERTY_READONLY(Uint32, RefCount);
	PROPERTY_READONLY_CALL(Weak*, WeakRef);
	PROPERTY_READONLY_CLASS(Uint32, Count);
	PROPERTY_READONLY_CLASS(Uint32, MaxCount);
	PROPERTY_READONLY_CLASS(Uint32, LuaRefCount);
	PROPERTY_READONLY_CLASS(Uint32, MaxLuaRefCount);
	PROPERTY_READONLY_CLASS(Uint32, LuaCallbackCount);
	PROPERTY_READONLY_CLASS(Uint32, MaxLuaCallbackCount);
	virtual ~Object();
	virtual bool init();
	/** @brief return true to stop updating, false to continue. */
	virtual bool update(double deltaTime);
	virtual bool fixedUpdate(double deltaTime);
	virtual bool equals(Object* other) const;
	virtual void cleanup();
	void addLuaRef();
	void removeLuaRef();
	void release();
	void retain();
	void autorelease();
	void autoretain();
protected:
	Object();
private:
	bool _managed;
	Uint32 _id; // object id, each object has unique one
	Uint32 _refCount; // count of C++ references
	Uint32 _luaRef; // lua reference id
	Weak* _weak; // weak ref object
	friend class PoolManager;
	DORA_TYPE_BASE(Object);
};

NS_DOROTHY_END
