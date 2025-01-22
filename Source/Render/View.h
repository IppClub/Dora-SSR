/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Support/Geometry.h"

NS_DORA_BEGIN

class SpriteEffect;

class View : public NonCopyable {
public:
	enum {
		MaxViews = 256
	};
	PROPERTY_READONLY(Size, Size);
	PROPERTY_READONLY(float, StandardDistance);
	PROPERTY_READONLY(float, AspectRatio);
	PROPERTY_READONLY_CREF(Matrix, Projection);
	PROPERTY(float, NearPlaneDistance);
	PROPERTY(float, FarPlaneDistance);
	PROPERTY(float, FieldOfView);
	PROPERTY(float, Scale);
	PROPERTY(SpriteEffect*, PostEffect);
	PROPERTY_BOOL(VSync);
	PROPERTY_READONLY_BOOL(PostProcessNeeded);
	PROPERTY_READONLY_EXCEPT(bgfx::ViewId, Id);
	PROPERTY_READONLY_CREF_EXCEPT(std::string, Name);
	void clear();
	void reset();

	template <typename Func>
	inline void pushFront(String viewName, const Func& workHere) {
		pushFront(viewName);
		workHere();
		pop();
	}
	template <typename Func>
	inline void pushBack(String viewName, const Func& workHere) {
		pushBack(viewName);
		workHere();
		pop();
	}
	template <typename Func>
	inline void pushInsertionMode(bool inserting, const Func& workHere) {
		pushInsertionMode(inserting);
		workHere();
		popInsertionMode();
	}

	std::pair<bgfx::ViewId*, uint16_t> getOrders();

protected:
	View();
	void updateProjection();
	void pushFront(String viewName);
	void pushBack(String viewName);
	void pop();
	void pushInsertionMode(bool inserting);
	void popInsertionMode();

private:
	void pushInner(String viewName);
	int _id;
	std::stack<std::pair<bgfx::ViewId, std::string>> _views;
	uint32_t _flag;
	float _nearPlaneDistance;
	float _farPlaneDistance;
	float _fieldOfView;
	float _scale;
	Size _size;
	Matrix _projection;
	std::list<int> _orders;
	struct InsertionMode {
		bool inserting;
		std::list<int>::iterator front;
		std::list<int>::iterator back;
	};
	std::stack<InsertionMode> _insertionModes;
	Ref<SpriteEffect> _effect;
	bgfx::ViewId _idOrders[MaxViews];
	SINGLETON_REF(View, Director);
};

#define SharedView \
	Dora::Singleton<Dora::View>::shared()

NS_DORA_END
