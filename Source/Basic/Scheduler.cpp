/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Basic/Scheduler.h"

#include "Animation/Action.h"
#include "Basic/Director.h"
#include "Node/Node.h"
#include "Support/Array.h"

NS_DORA_BEGIN

/* Scheduler */

class FuncWrapperBase : public Object {
public:
	FuncWrapperBase(const std::function<bool(double)>& func)
		: func(func) { }
	bool update(double deltaTime) {
		return func(deltaTime);
	}
	std::function<bool(double)> func;
};

class FuncWrapper : public FuncWrapperBase {
public:
	FuncWrapper(const std::function<bool(double)>& func)
		: FuncWrapperBase(func)
		, item(this) { }
	ScheduledItemWrapper<FuncWrapperBase> item;
	CREATE_FUNC_NOT_NULL(FuncWrapper);
	DORA_TYPE_OVERRIDE(FuncWrapper);
};

Scheduler::Scheduler()
	: _fixedFPS(60)
	, _deltaTime(0.0)
	, _leftTime(0.0)
	, _timeScale(1.0f)
	, _actionList(Array::create()) { }

Scheduler::~Scheduler() {
	for (auto item : _updateList) {
		item->target->release();
	}
	for (auto item : _fixedUpdateList) {
		item->target->release();
	}
}

void Scheduler::setFixedFPS(int var) {
	_fixedFPS = var;
}

int Scheduler::getFixedFPS() const noexcept {
	return _fixedFPS;
}

void Scheduler::setTimeScale(float value) {
	_timeScale = std::max(0.0f, value);
}

float Scheduler::getTimeScale() const noexcept {
	return _timeScale;
}

double Scheduler::getDeltaTime() const noexcept {
	return _deltaTime;
}

void Scheduler::schedule(NotNull<ScheduledItem, 1> item) {
	AssertIf(item->iter, "target item is already scheduled");
	item->target->retain();
	item->iter = _updateList.emplace(_updateList.end(), item);
}

void Scheduler::scheduleFixed(NotNull<FixedScheduledItem, 1> item) {
	AssertIf(item->iter, "target item is already scheduled");
	item->target->retain();
	item->iter = _fixedUpdateList.emplace(_fixedUpdateList.end(), item);
}

void Scheduler::schedule(const std::function<bool(double)>& handler) {
	FuncWrapper* func = FuncWrapper::create(handler);
	func->retain();
	func->item.iter = _updateList.emplace(_updateList.end(), &func->item);
}

void Scheduler::unschedule(ScheduledItem* item) {
	if (item && item->iter) {
		_updateList.erase(item->iter.value());
		item->target->release();
		item->iter = std::nullopt;
	}
}

void Scheduler::unscheduleFixed(FixedScheduledItem* item) {
	if (item && item->iter) {
		_fixedUpdateList.erase(item->iter.value());
		item->target->release();
		item->iter = std::nullopt;
	}
}

void Scheduler::schedule(NotNull<Action, 1> action) {
	if (action->_target && !action->isRunning()) {
		action->_order = s_cast<int>(_actionList->getCount());
		_actionList->add(Value::alloc(action.get()));
		if (action->updateProgress() && !action->_looped) {
			Ref<Action> actionRef(action);
			Ref<Node> targetRef(action->_target);
			unschedule(actionRef);
			targetRef->removeAction(actionRef);
			targetRef->emit("ActionEnd"_slice, actionRef.get(), targetRef.get());
		}
	}
}

void Scheduler::unschedule(Action* action) {
	BLOCK_START
	BREAK_UNLESS(action && action->_target && action->isRunning());
	BREAK_UNLESS(s_cast<size_t>(action->_order) < _actionList->getCount());
	auto temp = _actionList->get(action->_order).get();
	BREAK_UNLESS(temp);
	BREAK_UNLESS(temp->as<Action>() == action);
	Ref<> ref(action);
	_actionList->set(action->_order, nullptr);
	action->_order = Action::InvalidOrder;
	BLOCK_END
}

bool Scheduler::update(double deltaTime) {
	// not save _deltaTime on the stack memory
	_deltaTime = deltaTime * _timeScale;
	_leftTime += deltaTime;

	double fixedDelta = 1.0 / _fixedFPS;
	double fixedDeltaTime = fixedDelta * _timeScale;
	while (_leftTime > fixedDelta) {
		_fixedUpdateObjects.reserve(_fixedUpdateList.size());
		for (auto item : _fixedUpdateList) {
			_fixedUpdateObjects.emplace_back(item->target, item);
		}
		for (const auto& fixedUpdateObject : _fixedUpdateObjects) {
			if (fixedUpdateObject.second->fixedUpdate(fixedDeltaTime)) {
				unscheduleFixed(fixedUpdateObject.second);
			}
		}
		_fixedUpdateObjects.clear();
		_leftTime -= fixedDelta;
	}

	/* update actions */
	int i = 0, count = s_cast<int>(_actionList->getCount());
	while (i < count) {
		auto temp = _actionList->get(i).get();
		if (temp) {
			Ref<Action> action(temp->as<Action>());
			if (!action->isPaused()) {
				int lastIndex = action->_order;
				action->_elapsed += s_cast<float>(_deltaTime) * action->_speed;
				if (action->updateProgress()) {
					if (action->_order == lastIndex) {
						Ref<Node> target(action->_target);
						unschedule(action);
						target->removeAction(action);
						target->emit("ActionEnd"_slice, action.get(), target.get());
						if (action->_looped) {
							target->runAction(action, true);
						}
					}
				}
			}
		} else {
			_actionList->fastRemoveAt(i);
			if (i < s_cast<int>(_actionList->getCount())) {
				const auto& item = _actionList->get(i);
				if (item) {
					if (Action* action = item->as<Action>()) {
						action->_order = i;
					}
				}
			}
			i--;
			count--;
		}
		i++;
	}

	/* update scheduled items */
	_updateObjects.reserve(_updateList.size());
	for (auto item : _updateList) {
		_updateObjects.emplace_back(item->target, item);
	}
	for (const auto& updateObject : _updateObjects) {
		if (updateObject.second->update(deltaTime)) {
			unschedule(updateObject.second);
		}
	}
	_updateObjects.clear();
	return false;
}

/* SystemTimer */

SystemTimerBase::SystemTimerBase()
	: _time(0)
	, _duration(0) { }

bool SystemTimerBase::isRunning() const noexcept {
	return _time < _duration;
}

bool SystemTimerBase::update(double deltaTime) {
	_time += s_cast<float>(deltaTime);
	if (_time >= _duration) {
		if (_callback) {
			_callback();
		}
		stop();
		return true;
	}
	return false;
}

void SystemTimer::start(float duration, const std::function<void()>& callback) {
	_time = 0.0f;
	_duration = std::max(0.0f, duration);
	_callback = callback;
	SharedDirector.getSystemScheduler()->schedule(&_scheduledItem);
}

void SystemTimerBase::stop() {
	_time = _duration = 0.0f;
	_callback = nullptr;
}

NS_DORA_END
