/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Basic/Scheduler.h"
#include "Animation/Action.h"
#include "Support/Array.h"
#include "Node/Node.h"
#include "Basic/Director.h"

NS_DOROTHY_BEGIN

/* Scheduler */

class FuncWrapper : public Object
{
public:
	virtual bool update(double deltaTime) override
	{
		return func(deltaTime);
	}
	std::function<bool (double)> func;
	std::list<Ref<Object>>::iterator it;
	CREATE_FUNC(FuncWrapper);
protected:
	FuncWrapper(const std::function<bool (double)>& func):func(func) { }
	DORA_TYPE_OVERRIDE(FuncWrapper);
};

std::vector<Ref<Object>> Scheduler::_updateItems;

Scheduler::Scheduler():
_fixedFPS(60),
_deltaTime(0.0),
_leftTime(0.0),
_timeScale(1.0f),
_actionList(Array::create())
{ }

void Scheduler::setFixedFPS(int var)
{
	_fixedFPS = var;
}

int Scheduler::getFixedFPS() const
{
	return _fixedFPS;
}

void Scheduler::setTimeScale(float value)
{
	_timeScale = std::max(0.0f, value);
}

float Scheduler::getTimeScale() const
{
	return _timeScale;
}

double Scheduler::getDeltaTime() const
{
	return _deltaTime;
}

void Scheduler::schedule(Object* object)
{
	// O(1) insert operation
	_updateMap[object] = _updateList.insert(_updateList.end(), MakeRef(object));
}

void Scheduler::scheduleFixed(Object* object)
{
	schedule(object);
	_fixedUpdate.insert(object);
}

void Scheduler::schedule(const std::function<bool (double)>& handler)
{
	FuncWrapper* func = FuncWrapper::create(handler);
	func->it = _updateList.insert(_updateList.end(), Ref<Object>(func));
}

void Scheduler::unschedule(Object* object)
{
	auto it = _updateMap.find(object);
	if (it != _updateMap.end())
	{
		// O(1) remove operation
		_updateList.erase(it->second);
		_updateMap.erase(it);
		_fixedUpdate.erase(object);
	}
}

void Scheduler::schedule(Action* action)
{
	if (action && action->_target && !action->isRunning())
	{
		action->_order = s_cast<int>(_actionList->getCount());
		_actionList->add(Value::alloc(action));
		if (action->updateProgress())
		{
			Ref<Action> actionRef(action);
			Ref<Node> targetRef(action->_target);
			unschedule(actionRef);
			targetRef->removeAction(actionRef);
			targetRef->emit("ActionEnd"_slice, actionRef.get(), targetRef.get());
		}
	}
}

void Scheduler::unschedule(Action* action)
{
	Ref<> ref(action);
	if (action && action->_target && action->isRunning()
		&& _actionList->get(action->_order)->as<Action>() == action)
	{
		_actionList->set(action->_order, nullptr);
		action->_order = Action::InvalidOrder;
	}
}

bool Scheduler::update(double deltaTime)
{
	// not save _deltaTime on the stack memory
	_deltaTime = deltaTime * _timeScale;
	_leftTime += deltaTime;

	double fixedDelta = 1.0 / _fixedFPS;
	while (_leftTime > fixedDelta)
	{
		std::list<Object*> stopedItems;
		for (Object* item : _fixedUpdate)
		{
			if (item->fixedUpdate(fixedDelta * _timeScale))
			{
				stopedItems.push_back(item);
			}
		}
		for (Object* item : stopedItems)
		{
			_fixedUpdate.erase(item);
		}
		_leftTime -= fixedDelta;
	}

	/* update actions */
	int i = 0, count = s_cast<int>(_actionList->getCount());
	while (i < count)
	{
		Ref<Action> action(_actionList->get(i)->as<Action>());
		if (action)
		{
			if (!action->isPaused())
			{
				int lastIndex = action->_order;
				action->_eclapsed += s_cast<float>(_deltaTime) * action->_speed;
				if (action->updateProgress())
				{
					if (action->_order == lastIndex)
					{
						Ref<Node> target(action->_target);
						unschedule(action);
						target->removeAction(action);
						target->emit("ActionEnd"_slice, action.get(), target.get());
					}
				}
			}
		}
		else
		{
			_actionList->fastRemoveAt(i);
			if (i < s_cast<int>(_actionList->getCount()))
			{
				Action* action = _actionList->get(i)->as<Action>();
				if (action)
				{
					action->_order = i;
				}
			}
			i--;
			count--;
		}
		i++;
	}

	/* update scheduled items */
	_updateItems.reserve(_updateList.size());
	_updateItems.insert(_updateItems.begin(), _updateList.begin(), _updateList.end());
	for (const auto& item : _updateItems)
	{
		if (item->update(_deltaTime))
		{
			if (FuncWrapper* func = DoraAs<FuncWrapper>(item.get()))
			{
				_updateList.erase(func->it);
			}
			else unschedule(item);
		}
	}
	_updateItems.clear();
	return false;
}

/* Timer */
Timer::Timer():
_time(0),
_duration(0)
{ }

bool Timer::isRunning() const
{
	return _time < _duration;
}

bool Timer::update(double deltaTime)
{
	_time += s_cast<float>(deltaTime);
	if (_time >= _duration)
	{
		if (_callback)
		{
			_callback();
		}
		stop();
		return true;
	}
	return false;
}

void Timer::start(float duration, const std::function<void()>& callback)
{
	_time = 0.0f;
	_duration = std::max(0.0f, duration);
	_callback = callback;
	SharedDirector.getSystemScheduler()->schedule(this);
}

void Timer::stop()
{
	_time = _duration = 0.0f;
	_callback = nullptr;
}

NS_DOROTHY_END
