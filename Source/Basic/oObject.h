/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#ifndef __DOROTHY_BASIC_OOBJECT_H__
#define __DOROTHY_BASIC_OOBJECT_H__

NS_DOROTHY_BEGIN

class oObject;
class oWeak
{
public:
	oWeak(oObject* target);
	void release();
	void retain();
	oObject* target;
private:
	int _refCount;
};

class oObject
{
public:
	PROPERTY_READONLY(Uint32, Id);
	PROPERTY_READONLY_CALL(Uint32, LuaRef);
	PROPERTY_READONLY_BOOL(LuaReferenced);
	PROPERTY_READONLY_BOOL(SingleReferenced);
	PROPERTY_READONLY_CLASS(Uint32, ObjectCount);
	PROPERTY_READONLY_CLASS(Uint32, MaxObjectCount);
	PROPERTY_READONLY_CLASS(Uint32, LuaRefCount);
	PROPERTY_READONLY_CLASS(Uint32, MaxLuaRefCount);
	PROPERTY_READONLY(Uint32, RefCount);
	PROPERTY_READONLY_CALL(oWeak*, WeakRef);
	oObject();
	virtual ~oObject();
	virtual bool init();
	void addLuaRef();
	void removeLuaRef();
	void release();
	void retain();
	oObject* autorelease();
	virtual void update(float dt);
private:
	bool _managed;
	Uint32 _id; // object id, each object has unique one
	Uint32 _refCount; // count of C++ references
	Uint32 _luaRef; // lua reference id
	oWeak* _weak; // weak ref object
	static Uint32 _maxIdCount;
	static stack<Uint32> _availableIds;
	static Uint32 _maxLuaRefCount;
	static stack<Uint32> _availableLuaRefs;
	static Uint32 _luaRefCount;
	friend class oAutoreleasePool;
	LUA_TYPE(oObject)
};

NS_DOROTHY_END

#endif // __DOROTHY_BASIC_OOBJECT_H__
