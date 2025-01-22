/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DORA_BEGIN

class Node;
class Action;
class Array;

class ScheduledItem;

using UpdateList = std::list<ScheduledItem*>;
using UpdateIter = std::optional<std::list<ScheduledItem*>::iterator>;

class ScheduledItem {
public:
	ScheduledItem(Object* target)
		: target(target) { }
	virtual ~ScheduledItem() { }
	Object* target;
	UpdateIter iter;

	virtual bool update(double deltaTime) = 0;
};

template <class T>
concept Updatable = requires(T t) {
	std::is_base_of_v<Object, T>;
	{ t.update(double()) } -> std::same_as<bool>;
};

template <Updatable T>
class ScheduledItemWrapper : public ScheduledItem {
public:
	ScheduledItemWrapper(Updatable auto* item)
		: ScheduledItem(item) { }

	virtual bool update(double deltaTime) override {
		return static_cast<T*>(target)->update(deltaTime);
	}
};

class FixedScheduledItem;

using FixedUpdateList = std::list<FixedScheduledItem*>;
using FixedUpdateIter = std::optional<std::list<FixedScheduledItem*>::iterator>;

class FixedScheduledItem {
public:
	FixedScheduledItem(Object* target)
		: target(target) { }
	virtual ~FixedScheduledItem() { }
	Object* target;
	FixedUpdateIter iter;

	virtual bool fixedUpdate(double deltaTime) = 0;
};

template <class T>
concept FixedUpdatable = requires(T t) {
	std::is_base_of_v<Object, T>;
	{ t.fixedUpdate(double()) } -> std::same_as<bool>;
};

template <FixedUpdatable T>
class FixedScheduledItemWrapper : public FixedScheduledItem {
public:
	FixedScheduledItemWrapper(Updatable auto* item)
		: FixedScheduledItem(item) { }

	virtual bool fixedUpdate(double deltaTime) override {
		return static_cast<T*>(target)->fixedUpdate(deltaTime);
	}
};

class Scheduler : public Object {
public:
	virtual ~Scheduler();
	PROPERTY(float, TimeScale);
	PROPERTY(int, FixedFPS);
	PROPERTY_READONLY(double, DeltaTime);
	void schedule(NotNull<ScheduledItem, 1> item);
	void scheduleFixed(NotNull<FixedScheduledItem, 1> item);
	void schedule(const std::function<bool(double)>& handler);
	void schedule(NotNull<Action, 1> action);
	void unschedule(ScheduledItem* item);
	void unscheduleFixed(FixedScheduledItem* item);
	void unschedule(Action* action);
	bool update(double deltaTime);
	CREATE_FUNC_NOT_NULL(Scheduler);

protected:
	Scheduler();

private:
	int _fixedFPS;
	float _timeScale;
	double _deltaTime;
	double _leftTime;
	UpdateList _updateList;
	FixedUpdateList _fixedUpdateList;
	std::vector<std::pair<Ref<Object>, FixedScheduledItem*>> _fixedUpdateObjects;
	std::vector<std::pair<Ref<Object>, ScheduledItem*>> _updateObjects;
	Ref<Array> _actionList;

private:
	DORA_TYPE_OVERRIDE(Scheduler);
};

class SystemTimerBase : public Object {
public:
	PROPERTY_BOOL(Running);
	bool update(double deltaTime);
	void stop();

protected:
	SystemTimerBase();
	float _time;
	float _duration;
	std::function<void()> _callback;
};

class SystemTimer : public SystemTimerBase {
public:
	void start(float duration, const std::function<void()>& callback);
	CREATE_FUNC_NOT_NULL(SystemTimer);

protected:
	SystemTimer()
		: SystemTimerBase()
		, _scheduledItem(this) { }
	ScheduledItemWrapper<SystemTimerBase> _scheduledItem;
	DORA_TYPE_OVERRIDE(SystemTimer);
};

NS_DORA_END
