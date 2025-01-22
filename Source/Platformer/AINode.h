/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Support/Value.h"

NS_DORA_PLATFORMER_BEGIN
class Unit;

NS_BEHAVIOR_BEGIN
class Leaf;
NS_BEHAVIOR_END

NS_DECISION_BEGIN
class Leaf : public Object {
public:
	virtual bool doAction(Unit* self) = 0;
	DORA_TYPE_OVERRIDE(Leaf);
};

class BaseNode : public Leaf {
public:
	BaseNode* add(Leaf* node);
	bool remove(Leaf* node);
	void clear();
	const RefVector<Leaf>& getChildren() const;

protected:
	RefVector<Leaf> _children;
};

class SelNode : public BaseNode {
public:
	virtual bool doAction(Unit* self) override;
	CREATE_FUNC_NOT_NULL(SelNode);

protected:
	SelNode() { }
};

class SeqNode : public BaseNode {
public:
	virtual bool doAction(Unit* self) override;
	CREATE_FUNC_NOT_NULL(SeqNode);

protected:
	SeqNode() { }
};

class ConNode : public Leaf {
public:
	virtual bool doAction(Unit* self) override;
	CREATE_FUNC_NOT_NULL(ConNode);

protected:
	ConNode(String name, const std::function<bool(Unit*)>& handler);

private:
	std::string _name;
	std::function<bool(Unit*)> _handler;
};

class ActNode : public Leaf {
public:
	virtual bool doAction(Unit* self) override;
	CREATE_FUNC_NOT_NULL(ActNode);

protected:
	ActNode(String actionName);

private:
	std::string _actionName;
};

class DynamicActNode : public Leaf {
public:
	virtual bool doAction(Unit* self) override;
	CREATE_FUNC_NOT_NULL(DynamicActNode);

protected:
	DynamicActNode(const std::function<std::string(Unit*)>& handler);

private:
	std::string _actionName;
	std::function<std::string(Unit*)> _handler;
};

class AcceptNode : public Leaf {
public:
	virtual bool doAction(Unit* self) override;
	CREATE_FUNC_NOT_NULL(AcceptNode);

protected:
	AcceptNode() { }
};

class RejectNode : public Leaf {
public:
	virtual bool doAction(Unit* self) override;
	CREATE_FUNC_NOT_NULL(RejectNode);

protected:
	RejectNode() { }
};

class BehaviorNode : public Leaf {
public:
	virtual bool doAction(Unit* self) override;
	CREATE_FUNC_NOT_NULL(BehaviorNode);

protected:
	BehaviorNode(String name, NotNull<Behavior::Leaf, 2> root);

private:
	Ref<Behavior::Leaf> _root;
	std::string _name;
};

Leaf* Sel(Leaf* nodes[], int count);
Leaf* Sel(const std::vector<Leaf*>& nodes);
Leaf* Seq(Leaf* nodes[], int count);
Leaf* Seq(const std::vector<Leaf*>& nodes);
Leaf* Con(String name, const std::function<bool(Unit*)>& handler);
Leaf* Act(String actionName);
Leaf* Act(const std::function<std::string(Unit*)>& handler);
Leaf* Accept();
Leaf* Reject();
Leaf* Behave(String name, NotNull<Behavior::Leaf, 2> root);

NS_DECISION_END

NS_BEHAVIOR_BEGIN
class Blackboard {
public:
	PROPERTY(double, DeltaTime);
	PROPERTY_READONLY(Unit*, Owner);
	void set(String name, Own<Value>&& value);
	void set(uint32_t key, Own<Value>&& value);
	Value* get(String name);
	Value* get(uint32_t key);
	void remove(String name);
	void remove(uint32_t key);
	void clear();
	Own<Blackboard> clone() const;
	void copy(const Blackboard* blackboard);

public:
	Blackboard(Unit* owner);

private:
	Unit* _owner;
	double _deltaTime = 0.0;
	std::unordered_map<uint32_t, Own<Value>> _nodeValues;
	StringMap<Own<Value>> _values;
	DORA_TYPE_BASE(Blackboard);
};

enum class Status {
	Success,
	Failure,
	Running
};

class Leaf : public Object {
public:
	virtual ~Leaf() { }
	virtual Status tick(Blackboard* board) = 0;
	DORA_TYPE_OVERRIDE(Leaf);
};

class BaseNode : public Leaf {
public:
	BaseNode* add(Leaf* node);
	bool remove(Leaf* node);
	void clear();
	const RefVector<Leaf>& getChildren() const;

protected:
	RefVector<Leaf> _children;
};

class SeqNode : public BaseNode {
public:
	virtual Status tick(Blackboard* board) override;
	CREATE_FUNC_NOT_NULL(SeqNode);

protected:
	SeqNode() { }
};

class SelNode : public BaseNode {
public:
	virtual Status tick(Blackboard* board) override;
	CREATE_FUNC_NOT_NULL(SelNode);

protected:
	SelNode() { }
};

class ConNode : public Leaf {
public:
	virtual Status tick(Blackboard* board) override;
	CREATE_FUNC_NOT_NULL(ConNode);

protected:
	ConNode(String name, const std::function<bool(Blackboard*)>& handler);

private:
	std::string _name;
	std::function<bool(Blackboard*)> _handler;
};

class ActNode : public Leaf {
public:
	virtual Status tick(Blackboard* board) override;
	CREATE_FUNC_NOT_NULL(ActNode);

protected:
	ActNode(String actionName);

private:
	std::string _actionName;
};

class CommandNode : public Leaf {
public:
	virtual Status tick(Blackboard* board) override;
	CREATE_FUNC_NOT_NULL(CommandNode);

protected:
	CommandNode(String actionName);

private:
	std::string _actionName;
};

class CountdownNode : public Leaf {
public:
	virtual Status tick(Blackboard* board) override;
	CREATE_FUNC_NOT_NULL(CountdownNode);

protected:
	CountdownNode(double time, NotNull<Leaf, 2> node);

private:
	double _time;
	Ref<Leaf> _node;
};

class TimeoutNode : public Leaf {
public:
	virtual Status tick(Blackboard* board) override;
	CREATE_FUNC_NOT_NULL(TimeoutNode);

protected:
	TimeoutNode(double time, NotNull<Leaf, 2> node);

private:
	double _time;
	Ref<Leaf> _node;
};

class WaitNode : public Leaf {
public:
	virtual Status tick(Blackboard* board) override;
	CREATE_FUNC_NOT_NULL(WaitNode);

protected:
	WaitNode(double duration);

private:
	double _duration;
};

class RepeatInfo : public Object {
public:
	int count = 0;
	Own<Blackboard> boardCache;
	CREATE_FUNC_NOT_NULL(RepeatInfo);
};

class RepeatNode : public Leaf {
public:
	virtual Status tick(Blackboard* board) override;
	CREATE_FUNC_NOT_NULL(RepeatNode);

protected:
	RepeatNode(int times, NotNull<Leaf, 2> node);
	RepeatNode(NotNull<Leaf, 1> node);

private:
	int _times;
	Ref<Leaf> _node;
};

class RetryNode : public Leaf {
public:
	virtual Status tick(Blackboard* board) override;
	CREATE_FUNC_NOT_NULL(RetryNode);

protected:
	RetryNode(int times, NotNull<Leaf, 2> node);
	RetryNode(NotNull<Leaf, 1> node);

private:
	int _times;
	Ref<Leaf> _node;
};

Leaf* Sel(Leaf* nodes[], int count);
Leaf* Sel(const std::vector<Leaf*>& nodes);
Leaf* Seq(Leaf* nodes[], int count);
Leaf* Seq(const std::vector<Leaf*>& nodes);
Leaf* Con(String name, const std::function<bool(Blackboard*)>& handler);
Leaf* Act(String actionName);
Leaf* Countdown(double time, NotNull<Leaf, 2> node);
Leaf* Timeout(double time, NotNull<Leaf, 2> node);
Leaf* Command(String actionName);
Leaf* Wait(double duration);
Leaf* Repeat(int times, NotNull<Leaf, 2> node);
Leaf* Repeat(NotNull<Leaf, 1> node);
Leaf* Retry(int times, NotNull<Leaf, 2> node);
Leaf* Retry(NotNull<Leaf, 1> node);

NS_BEHAVIOR_END

NS_DORA_PLATFORMER_END
