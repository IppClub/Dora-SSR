/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DORA_BEGIN

class Object;
class Weak {
public:
	Weak(Object* target);
	void release();
	void retain();
	Object* target;

private:
	int _refCount;
};

class Object : public NonCopyable {
public:
	PROPERTY_READONLY(uint32_t, Id);
	PROPERTY_READONLY_CALL(uint32_t, LuaRef);
	PROPERTY_READONLY_BOOL(LuaReferenced);
	PROPERTY_READONLY_BOOL(SingleReferenced);
	PROPERTY_READONLY(uint32_t, RefCount);
	PROPERTY_READONLY_CALL(Weak*, WeakRef);
	PROPERTY_READONLY_CLASS(uint32_t, Count);
	PROPERTY_READONLY_CLASS(uint32_t, MaxCount);
	PROPERTY_READONLY_CLASS(uint32_t, LuaRefCount);
	PROPERTY_READONLY_CLASS(uint32_t, MaxLuaRefCount);
	PROPERTY_READONLY_CLASS(uint32_t, LuaCallbackCount);
	PROPERTY_READONLY_CLASS(uint32_t, MaxLuaCallbackCount);
	virtual ~Object();
	virtual bool init();
	virtual void cleanup();
	void release();
	void retain();
	void autorelease();

	static void incLuaRefCount();
	static void decLuaRefCount();

	template <class T, class... Args>
	static T* create(Args&&... args) {
		static_assert(std::is_base_of<Object, T>::value, "T must be a subclass of Object");
		T* item = new T(std::forward<Args>(args)...);
		if (item && item->init()) {
			item->autorelease();
		} else if (item->getRefCount() == 0) {
			delete item;
			item = nullptr;
		} else {
			item = nullptr;
		}
		return item;
	}

	template <class T, class... Args>
	static T* createNotNull(Args&&... args) {
		T* item = Object::create<T>(std::forward<Args>(args)...);
		AssertUnless(item, "failed to create an instance.");
		return item;
	}

protected:
	Object();

private:
	uint32_t _id; // object id, each object has unique one
	uint32_t _refCount; // count of C++ references
	uint32_t _luaRef; // lua reference id
	Weak* _weak; // weak ref object
	friend class PoolManager;
	DORA_TYPE_BASE(Object);
};

NS_DORA_END
