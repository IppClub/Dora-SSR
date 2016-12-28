/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Basic/Scheduler.h"

NS_DOROTHY_BEGIN

// pretend to be a compactible object for AcfDelegate
class FuncWrapper
{
public:
	FuncWrapper(const function<bool (double)>& func):_func(func) { }
	const FuncWrapper& operator*() const { return *this; }
	bool operator==(const FuncWrapper& wrapper) const
	{
		return _func.target<bool(*)(double)>() == wrapper._func.target<bool(*)(double)>();
	}
	void call(double deltaTime, Scheduler* scheduler) const
	{
		if (_func(deltaTime))
		{
			scheduler->unschedule(_func);
		}
	}
private:
	function<bool (double)> _func;
};

// tweak to deal with return value
class ObjectWrapper
{
public:
	ObjectWrapper(Object* object):_object(object) { }
	const ObjectWrapper& operator*() const { return *this; }
	bool operator==(const ObjectWrapper& wrapper) const
	{
		return _object == wrapper._object;
	}
	void call(double deltaTime, Scheduler* scheduler) const
	{
		if (_object->update(deltaTime))
		{
			scheduler->unschedule(_object);
		}
	}
private:
	Ref<Object> _object;
};

Scheduler::Scheduler():
_timeScale(1.0f)
{ }

void Scheduler::setTimeScale(float value)
{
	_timeScale = max(0.0f, value);
}

float Scheduler::getTimeScale() const
{
	return _timeScale;
}

void Scheduler::schedule(Object* object)
{
	_updateHandler += std::make_pair(ObjectWrapper(object), &ObjectWrapper::call);
}

void Scheduler::schedule(const function<bool (double)>& handler)
{
	_updateHandler += std::make_pair(FuncWrapper(handler), &FuncWrapper::call);
}

void Scheduler::unschedule(Object* object)
{
	_updateHandler -= std::make_pair(ObjectWrapper(object), &ObjectWrapper::call);
}

void Scheduler::unschedule(const function<bool (double)>& handler)
{
	_updateHandler -= std::make_pair(FuncWrapper(handler), &FuncWrapper::call);
}

bool Scheduler::update(double deltaTime)
{
	_updateHandler(deltaTime * _timeScale, this);
	return false;
}

NS_DOROTHY_END
