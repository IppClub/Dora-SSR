/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Support/Value.h"

NS_DOROTHY_PLATFORMER_BEGIN
class Unit;

NS_BEHAVIOR_BEGIN
class Leaf;
NS_BEHAVIOR_END

NS_DECISION_BEGIN
class Leaf : public Object
{
public:
	virtual bool doAction(Unit* self) = 0;
	DORA_TYPE_OVERRIDE(Leaf);
};

class BaseNode : public Leaf
{
public:
	BaseNode* add(Leaf* node);
	bool remove(Leaf* node);
	void clear();
	const RefVector<Leaf>& getChildren() const;
protected:
	RefVector<Leaf> _children;
};

class SelNode : public BaseNode
{
public:
	virtual bool doAction(Unit* self) override;
	CREATE_FUNC(SelNode);
protected:
	SelNode() { }
};

class SeqNode : public BaseNode
{
public:
	virtual bool doAction(Unit* self) override;
	CREATE_FUNC(SeqNode);
protected:
	SeqNode() { }
};

class ConNode : public Leaf
{
public:
	virtual bool doAction(Unit* self) override;
	CREATE_FUNC(ConNode);
protected:
	ConNode(String name, const function<bool(Unit*)>& handler);
private:
	string _name;
	function<bool(Unit*)> _handler;
};

class ActNode : public Leaf
{
public:
	virtual bool doAction(Unit* self) override;
	CREATE_FUNC(ActNode);
protected:
	ActNode(String actionName);
private:
	string _actionName;
};

class DynamicActNode : public Leaf
{
public:
	virtual bool doAction(Unit* self) override;
	CREATE_FUNC(DynamicActNode);
protected:
	DynamicActNode(const function<string(Unit*)>& handler);
private:
	string _actionName;
	function<string(Unit*)> _handler;
};

class PassNode : public Leaf
{
public:
	virtual bool doAction(Unit* self) override;
	CREATE_FUNC(PassNode);
protected:
	PassNode() { }
};

class RejectNode : public Leaf
{
public:
	virtual bool doAction(Unit* self) override;
	CREATE_FUNC(RejectNode);
protected:
	RejectNode() { }
};

class BehaviorNode : public Leaf
{
public:
	virtual bool doAction(Unit* self) override;
	CREATE_FUNC(BehaviorNode);
protected:
	BehaviorNode(String name, Behavior::Leaf* root);
private:
	Ref<Behavior::Leaf> _root;
	string _name;
};

Leaf* Sel(Leaf* nodes[], int count);
Leaf* Seq(Leaf* nodes[], int count);
Leaf* Con(String name, const function<bool(Unit*)>& handler);
Leaf* Act(String actionName);
Leaf* Act(const function<string(Unit*)>& handler);
Leaf* Pass();
Leaf* Reject();
Leaf* Behave(String name, Behavior::Leaf* root);

NS_DECISION_END

NS_BEHAVIOR_BEGIN
class Blackboard
{
public:
	PROPERTY(double, DeltaTime);
	PROPERTY_READONLY(Unit*, Owner);
	int getNode(Uint32 objId) const;
	void setNode(Uint32 objId, int index);
	void set(String name, Own<Value>&& value);
	Value* get(String name);
	void remove(String name);
	void clear();
	Own<Blackboard> clone() const;
	void copy(const Blackboard* blackboard);
public:
	Blackboard(Unit* owner);
private:
	Unit* _owner;
	double _deltaTime = 0.0;
	unordered_map<Uint32, int> _nodeIds;
	unordered_map<string, Own<Value>> _values;
	DORA_TYPE_BASE(Blackboard);
};

enum class Status
{
	Success,
	Failure,
	Running
};

class Leaf : public Object
{
public:
	virtual ~Leaf() { }
	virtual Status tick(Blackboard* board) = 0;
	DORA_TYPE_OVERRIDE(Leaf);
};

class BaseNode : public Leaf
{
public:
	BaseNode* add(Leaf* node);
	bool remove(Leaf* node);
	void clear();
	const RefVector<Leaf>& getChildren() const;
protected:
	RefVector<Leaf> _children;
};

class SeqNode : public BaseNode
{
public:
	virtual Status tick(Blackboard* board) override;
	CREATE_FUNC(SeqNode);
protected:
	SeqNode() { }
};

class SelNode : public BaseNode
{
public:
	virtual Status tick(Blackboard* board) override;
	CREATE_FUNC(SelNode);
protected:
	SelNode() { }
};

class ConNode : public Leaf
{
public:
	virtual Status tick(Blackboard* board) override;
	CREATE_FUNC(ConNode);
protected:
	ConNode(String name, const function<bool(Blackboard*)>& handler);
private:
	string _name;
	function<bool(Blackboard*)> _handler;
};

class ActNode : public Leaf
{
public:
	virtual Status tick(Blackboard* board) override;
	CREATE_FUNC(ActNode);
protected:
	ActNode(String actionName);
private:
	string _actionName;
	string _key;
};

class CommandNode : public Leaf
{
public:
	virtual Status tick(Blackboard* board) override;
	CREATE_FUNC(CommandNode);
protected:
	CommandNode(String actionName);
private:
	string _actionName;
};

class CountDownNode : public Leaf
{
public:
	virtual Status tick(Blackboard* board) override;
	CREATE_FUNC(CountDownNode);
protected:
	CountDownNode(double time, Leaf* node);
private:
	double _time;
	Ref<Leaf> _node;
	string _key;
};

class WaitNode : public Leaf
{
public:
	virtual Status tick(Blackboard* board) override;
	CREATE_FUNC(WaitNode);
protected:
	WaitNode(double duration);
private:
	double _duration;
	string _key;
};

Leaf* Sel(Leaf* nodes[], int count);
Leaf* Seq(Leaf* nodes[], int count);
Leaf* Con(String name, const function<bool(Blackboard*)>& handler);
Leaf* Act(String actionName);
Leaf* CountDown(double time, Leaf* node);
Leaf* Command(String actionName);
Leaf* Wait(double duration);

NS_BEHAVIOR_END

NS_DOROTHY_PLATFORMER_END
