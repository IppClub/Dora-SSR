/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN

class Node;
class Action;
class Array;

class Scheduler : public Object
{
	typedef std::list<Ref<Object>> UpdateList;
	typedef std::unordered_map<Object*, UpdateList::iterator> UpdateMap;
	typedef std::unordered_set<Object*> FixedUpdateSet;
public:
	PROPERTY(float, TimeScale);
	PROPERTY(int, FixedFPS);
	PROPERTY_READONLY(double, DeltaTime);
	void schedule(Object* object);
	void scheduleFixed(Object* object);
	void schedule(const std::function<bool (double)>& handler);
	void schedule(Action* action);
	void unschedule(Object* object);
	void unschedule(Action* action);
	virtual bool update(double deltaTime) override;
	CREATE_FUNC(Scheduler);
protected:
	Scheduler();
private:
	int _fixedFPS;
	float _timeScale;
	double _deltaTime;
	double _leftTime;
	UpdateList _updateList;
	UpdateMap _updateMap;
	FixedUpdateSet _fixedUpdate;
	Ref<Array> _actionList;
private:
	static std::vector<Ref<Object>> _updateItems;
	DORA_TYPE_OVERRIDE(Scheduler);
};

class Timer : public Object
{
public:
	PROPERTY_BOOL(Running);
	virtual bool update(double deltaTime) override;
	void start(float duration, const std::function<void()>& callback);
	void stop();
	CREATE_FUNC(Timer);
protected:
	Timer();
private:
	float _time;
	float _duration;
	std::function<void()> _callback;
	DORA_TYPE_OVERRIDE(Timer);
};

NS_DOROTHY_END
