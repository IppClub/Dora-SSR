/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

class Node;

class Touch : public Object
{
public:
	enum
	{
		FromMouse = 1,
		FromTouch = 1<<1,
		FromMouseAndTouch = FromMouse | FromTouch
	};
	PROPERTY_BOOL(Enabled);
	PROPERTY_READONLY(int, Id);
	PROPERTY_READONLY(Vec2, Delta);
	PROPERTY_READONLY_REF(Vec2, Location);
	PROPERTY_READONLY_REF(Vec2, PreLocation);
	static Uint32 source;
	CREATE_FUNC(Touch);
protected:
	Touch(int id);
private:
	Flag _flags;
	int _id;
	Vec2 _location;
	Vec2 _preLocation;
	enum
	{
		Enabled = 1,
		Selected = 1<<1
	};
	friend class TouchHandler;
	DORA_TYPE_OVERRIDE(Touch);
};

class TouchHandler
{
public:
	TouchHandler(Node* target);
	void down(const SDL_Event& event);
	void up(const SDL_Event& event);
	void move(const SDL_Event& event);
protected:
	Touch* alloc(SDL_FingerID fingerId);
	Touch* get(SDL_FingerID fingerId);
	void collect(SDL_FingerID fingerId);
	Vec2 getPos(const SDL_Event& event);
private:
	Node* _target;
	stack<int> _availableTouchIds;
	unordered_map<SDL_FingerID, Ref<Touch>> _touchMap;
};

NS_DOROTHY_END
