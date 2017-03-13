/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

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
	typedef list<Ref<Object>> UpdateList;
	typedef unordered_map<Object*, UpdateList::iterator> UpdateMap;
public:
	PROPERTY(float, TimeScale);
	void schedule(Object* object);
	void schedule(const function<bool (double)>& handler);
	void schedule(Action* action);
	void unschedule(Object* object);
	void unschedule(Action* action);
	virtual bool update(double deltaTime) override;
	CREATE_FUNC(Scheduler);
protected:
	Scheduler();
	void doUpdate();
private:
	float _timeScale;
	double _deltaTime;
	UpdateList::reverse_iterator _it;
	UpdateList _updateList;
	UpdateMap _updateMap;
	Ref<Array> _actionList;
	DORA_TYPE_OVERRIDE(Scheduler);
};

NS_DOROTHY_END
