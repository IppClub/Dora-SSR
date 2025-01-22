/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Platformer/Define.h"

#include "Platformer/AINode.h"

#include "Platformer/AI.h"
#include "Platformer/Unit.h"
#include "Platformer/UnitAction.h"

NS_DORA_PLATFORMER_BEGIN

NS_DECISION_BEGIN

/* BaseNode */

BaseNode* BaseNode::add(Leaf* node) {
	_children.push_back(node);
	return this;
}

bool BaseNode::remove(Leaf* node) {
	return _children.remove(node);
}

void BaseNode::clear() {
	_children.clear();
}

const RefVector<Leaf>& BaseNode::getChildren() const {
	return _children;
}

/* SelNode */

bool SelNode::doAction(Unit* self) {
	if (self->isReceivingDecisionTrace()) {
		auto& decisionNodes = SharedAI.getDecisionNodes();
		size_t oldSize = decisionNodes.size();
		bool result = false;
		for (Leaf* node : _children) {
			if (node->doAction(self)) {
				result = true;
				break;
			}
		}
		if (!result) {
			if (oldSize == 0)
				decisionNodes.clear();
			else {
				size_t newSize = decisionNodes.size();
				while (newSize > oldSize) {
					decisionNodes.pop_back();
					newSize--;
				}
			}
		}
		return result;
	} else {
		for (Leaf* node : _children) {
			if (node->doAction(self)) {
				return true;
			}
		}
		return false;
	}
}

/* SeqNode */

bool SeqNode::doAction(Unit* self) {
	if (self->isReceivingDecisionTrace()) {
		auto& decisionNodes = SharedAI.getDecisionNodes();
		size_t oldSize = decisionNodes.size();
		bool result = true;
		for (Leaf* node : _children) {
			if (!node->doAction(self)) {
				result = false;
				break;
			}
		}
		if (!result) {
			if (oldSize == 0)
				decisionNodes.clear();
			else {
				size_t newSize = decisionNodes.size();
				while (newSize > oldSize) {
					decisionNodes.pop_back();
					newSize--;
				}
			}
		}
		return result;
	} else {
		for (Leaf* node : _children) {
			if (!node->doAction(self)) {
				return false;
			}
		}
		return true;
	}
}

/* ConNode */

bool ConNode::doAction(Unit* self) {
	if (_handler && _handler(self)) {
		if (self->isReceivingDecisionTrace() && !_name.empty()) {
			SharedAI.getDecisionNodes().push_back(_name);
		}
		return true;
	}
	return false;
}

ConNode::ConNode(String name, const std::function<bool(Unit*)>& handler)
	: _name(name)
	, _handler(handler) { }

/* ActNode */

bool ActNode::doAction(Unit* self) {
	if (self->start(_actionName)) {
		if (self->isReceivingDecisionTrace() && !_actionName.empty()) {
			SharedAI.getDecisionNodes().push_back(_actionName);
		}
		return true;
	}
	return false;
}

ActNode::ActNode(String actionName)
	: _actionName(actionName) { }

/* DynamicActNode */

bool DynamicActNode::doAction(Unit* self) {
	auto actionName = _handler(self);
	if (self->start(actionName)) {
		if (self->isReceivingDecisionTrace()) {
			SharedAI.getDecisionNodes().push_back("[dynamic] "s + (actionName.empty() ? "none"s : actionName));
		}
		return true;
	}
	return false;
}

DynamicActNode::DynamicActNode(const std::function<std::string(Unit*)>& handler)
	: _handler(handler) { }

/* AcceptNode */

bool AcceptNode::doAction(Unit* self) {
	DORA_UNUSED_PARAM(self);
	return true;
}

/* RejectNode */

bool RejectNode::doAction(Unit* self) {
	DORA_UNUSED_PARAM(self);
	return false;
}

/* BehaviorNode */

bool BehaviorNode::doAction(Unit* self) {
	self->setBehaviorTree(_root);
	if (self->isReceivingDecisionTrace()) {
		SharedAI.getDecisionNodes().push_back(_name);
	}
	return true;
}

BehaviorNode::BehaviorNode(String name, NotNull<Behavior::Leaf, 2> root)
	: _root(root)
	, _name(name) { }

Leaf* Sel(Leaf* nodes[], int count) {
	SelNode* sel = SelNode::create();
	for (int i = 0; i < count; i++) {
		sel->add(nodes[i]);
	}
	return sel;
}

Leaf* Sel(const std::vector<Leaf*>& nodes) {
	SelNode* sel = SelNode::create();
	for (auto node : nodes) {
		sel->add(node);
	}
	return sel;
}

Leaf* Seq(Leaf* nodes[], int count) {
	SeqNode* seq = SeqNode::create();
	for (int i = 0; i < count; i++) {
		seq->add(nodes[i]);
	}
	return seq;
}

Leaf* Seq(const std::vector<Leaf*>& nodes) {
	SeqNode* seq = SeqNode::create();
	for (auto node : nodes) {
		seq->add(node);
	}
	return seq;
}

Leaf* Con(String name, const std::function<bool(Unit*)>& handler) {
	return ConNode::create(name, handler);
}

Leaf* Act(String actionName) {
	return ActNode::create(actionName);
}

Leaf* Act(const std::function<std::string(Unit*)>& handler) {
	return DynamicActNode::create(handler);
}

Leaf* Accept() {
	return AcceptNode::create();
}

Leaf* Reject() {
	return RejectNode::create();
}

Leaf* Behave(String name, NotNull<Behavior::Leaf, 2> root) {
	return BehaviorNode::create(name, root);
}

NS_DECISION_END

NS_BEHAVIOR_BEGIN

/* Blackboard */

Blackboard::Blackboard(Unit* owner)
	: _owner(owner) { }

Unit* Blackboard::getOwner() const noexcept {
	return _owner;
}

void Blackboard::setDeltaTime(double var) {
	_deltaTime = var;
}

double Blackboard::getDeltaTime() const noexcept {
	return _deltaTime;
}

void Blackboard::set(String name, Own<Value>&& value) {
	_values[name.toString()] = std::move(value);
}

void Blackboard::set(uint32_t key, Own<Value>&& value) {
	_nodeValues[key] = std::move(value);
}

Value* Blackboard::get(String name) {
	auto it = _values.find(name);
	if (it != _values.end()) {
		return it->second.get();
	}
	return nullptr;
}

Value* Blackboard::get(uint32_t key) {
	auto it = _nodeValues.find(key);
	if (it != _nodeValues.end()) {
		return it->second.get();
	}
	return nullptr;
}

void Blackboard::remove(String name) {
	auto it = _values.find(name);
	if (it != _values.end()) {
		_values.erase(it);
	}
}

void Blackboard::remove(uint32_t key) {
	auto it = _nodeValues.find(key);
	if (it != _nodeValues.end()) {
		_nodeValues.erase(it);
	}
}

void Blackboard::clear() {
	_deltaTime = 0.0;
	_nodeValues.clear();
	_values.clear();
}

Own<Blackboard> Blackboard::clone() const {
	auto blackboard = New<Blackboard>(_owner);
	blackboard->copy(this);
	return blackboard;
}

void Blackboard::copy(const Blackboard* blackboard) {
	_nodeValues.clear();
	for (const auto& pair : blackboard->_nodeValues) {
		_nodeValues[pair.first] = pair.second->clone();
	}
	_values.clear();
	for (const auto& pair : blackboard->_values) {
		_values[pair.first] = pair.second->clone();
	}
}

/* BaseNode */

BaseNode* BaseNode::add(Leaf* node) {
	_children.push_back(node);
	return this;
}

bool BaseNode::remove(Leaf* node) {
	return _children.remove(node);
}

void BaseNode::clear() {
	_children.clear();
}

const RefVector<Leaf>& BaseNode::getChildren() const {
	return _children;
}

/* SeqNode */

Status SeqNode::tick(Blackboard* board) {
	if (_children.empty()) return Status::Success;
	int index = 0;
	uint32_t key = getId();
	if (auto value = board->get(key)) {
		index = value->toVal<int>();
	} else
		board->set(key, Value::alloc(index));
	auto status = Status::Running;
	do {
		status = _children[index]->tick(board);
		switch (status) {
			case Status::Running:
				return Status::Running;
			case Status::Success: {
				index++;
				if (index >= s_cast<int>(_children.size())) {
					board->remove(key);
					return Status::Success;
				}
				board->set(key, Value::alloc(index));
				break;
			}
			case Status::Failure:
				board->remove(key);
				return Status::Failure;
		}
	} while (status == Status::Success);
	return Status::Running;
}

/* SelNode */

Status SelNode::tick(Blackboard* board) {
	if (_children.empty()) return Status::Failure;
	int index = 0;
	uint32_t key = getId();
	if (auto value = board->get(key)) {
		index = value->toVal<int>();
	} else
		board->set(key, Value::alloc(index));
	auto status = Status::Running;
	do {
		status = _children[index]->tick(board);
		switch (status) {
			case Status::Running:
				return Status::Running;
			case Status::Success:
				board->remove(key);
				return Status::Success;
			case Status::Failure: {
				index++;
				if (index >= s_cast<int>(_children.size())) {
					board->remove(key);
					return Status::Failure;
				}
				board->set(key, Value::alloc(index));
				break;
			}
		}
	} while (status == Status::Failure);
	return Status::Running;
}

/* ConNode */

Status ConNode::tick(Blackboard* board) {
	if (_handler && _handler(board)) {
		return Status::Success;
	}
	return Status::Failure;
}

ConNode::ConNode(String name, const std::function<bool(Blackboard*)>& handler)
	: _name(name)
	, _handler(handler) { }

/* ActNode */

Status ActNode::tick(Blackboard* board) {
	uint32_t key = getId();
	if (!board->get(key)) {
		board->getOwner()->start(_actionName);
		board->set(key, Value::alloc(true));
	}
	Status status = Status::Failure;
	if (auto action = board->getOwner()->getAction(_actionName)) {
		status = action->getStatus();
	}
	if (status != Status::Running) {
		board->remove(key);
	}
	return status;
}

ActNode::ActNode(String actionName)
	: _actionName(actionName) { }

/* CommandNode */

Status CommandNode::tick(Blackboard* board) {
	auto result = board->getOwner()->start(_actionName);
	return result ? Status::Success : Status::Failure;
}

CommandNode::CommandNode(String actionName)
	: _actionName(actionName) { }

/* CountdownNode */

Status CountdownNode::tick(Blackboard* board) {
	uint32_t key = getId();
	Status status = _node->tick(board);
	if (status != Status::Running) {
		board->remove(key);
		return Status::Failure;
	}
	if (auto value = board->get(key)) {
		auto time = value->toVal<double>();
		time += board->getDeltaTime();
		if (time >= _time) {
			board->remove(key);
			return Status::Success;
		}
		board->set(key, Value::alloc(time));
		return Status::Running;
	} else {
		board->set(key, Value::alloc(double(0.0)));
		return Status::Running;
	}
}

CountdownNode::CountdownNode(double time, NotNull<Leaf, 2> node)
	: _time(time)
	, _node(node) { }

/* TimeoutNode */

Status TimeoutNode::tick(Blackboard* board) {
	uint32_t key = getId();
	Status status = _node->tick(board);
	if (status != Status::Running) {
		board->remove(key);
		return status;
	}
	if (auto value = board->get(key)) {
		auto time = value->toVal<double>();
		time += board->getDeltaTime();
		if (time >= _time) {
			board->remove(key);
			return Status::Failure;
		}
		board->set(key, Value::alloc(time));
		return Status::Running;
	} else {
		board->set(key, Value::alloc(double(0.0)));
		return Status::Running;
	}
}

TimeoutNode::TimeoutNode(double time, NotNull<Leaf, 2> node)
	: _time(time)
	, _node(node) { }

/* WaitNode */

Status WaitNode::tick(Blackboard* board) {
	uint32_t key = getId();
	if (auto value = board->get(key)) {
		auto time = value->toVal<double>();
		time += board->getDeltaTime();
		if (time >= _duration) {
			board->remove(key);
			return Status::Success;
		}
		board->set(key, Value::alloc(time));
		return Status::Running;
	} else {
		board->set(key, Value::alloc(double(0.0)));
		return Status::Running;
	}
}

WaitNode::WaitNode(double duration)
	: _duration(duration) { }

/* RepeatNode */

Status RepeatNode::tick(Blackboard* board) {
	uint32_t key = getId();
	if (!board->get(key)) {
		auto info = RepeatInfo::create();
		info->boardCache = board->clone();
		board->set(key, Value::alloc(info));
	}
	Status status = _node->tick(board);
	switch (status) {
		case Status::Success: {
			auto value = board->get(key)->to<RepeatInfo>();
			Ref<> ref(value);
			if (_times > 0) value->count++;
			if (value->count > _times) {
				return Status::Success;
			} else {
				board->copy(value->boardCache.get());
				board->set(key, Value::alloc(value));
				return Status::Running;
			}
		}
		case Status::Failure:
			board->remove(key);
			return Status::Failure;
		case Status::Running:
			return Status::Running;
	}
	return Status::Failure;
}

RepeatNode::RepeatNode(NotNull<Leaf, 1> node)
	: _times(0)
	, _node(node) { }

RepeatNode::RepeatNode(int times, NotNull<Leaf, 2> node)
	: _times(times)
	, _node(node) { }

/* RetryNode */

Status RetryNode::tick(Blackboard* board) {
	uint32_t key = getId();
	if (!board->get(key)) {
		auto info = RepeatInfo::create();
		info->boardCache = board->clone();
		board->set(key, Value::alloc(info));
	}
	Status status = _node->tick(board);
	switch (status) {
		case Status::Failure: {
			auto value = board->get(key)->to<RepeatInfo>();
			if (_times > 0) value->count++;
			if (value->count > _times) {
				return Status::Failure;
			} else {
				board->copy(value->boardCache.get());
				board->set(key, Value::alloc(value));
				return Status::Running;
			}
		}
		case Status::Success:
			board->remove(key);
			return Status::Success;
		case Status::Running:
			return Status::Running;
	}
	return Status::Failure;
}

RetryNode::RetryNode(NotNull<Leaf, 1> node)
	: _times(0)
	, _node(node) { }

RetryNode::RetryNode(int times, NotNull<Leaf, 2> node)
	: _times(times)
	, _node(node) { }

Leaf* Sel(Leaf* nodes[], int count) {
	SelNode* sel = SelNode::create();
	for (int i = 0; i < count; i++) {
		sel->add(nodes[i]);
	}
	return sel;
}

Leaf* Sel(const std::vector<Leaf*>& nodes) {
	SelNode* sel = SelNode::create();
	for (auto node : nodes) {
		sel->add(node);
	}
	return sel;
}

Leaf* Seq(Leaf* nodes[], int count) {
	SeqNode* seq = SeqNode::create();
	for (int i = 0; i < count; i++) {
		seq->add(nodes[i]);
	}
	return seq;
}

Leaf* Seq(const std::vector<Leaf*>& nodes) {
	SeqNode* seq = SeqNode::create();
	for (auto node : nodes) {
		seq->add(node);
	}
	return seq;
}

Leaf* Con(String name, const std::function<bool(Blackboard*)>& handler) {
	return ConNode::create(name, handler);
}

Leaf* Act(String actionName) {
	return ActNode::create(actionName);
}

Leaf* Command(String actionName) {
	return CommandNode::create(actionName);
}

Leaf* Countdown(double time, NotNull<Leaf, 2> node) {
	return CountdownNode::create(time, node);
}

Leaf* Timeout(double time, NotNull<Leaf, 2> node) {
	return TimeoutNode::create(time, node);
}

Leaf* Wait(double duration) {
	return WaitNode::create(duration);
}

Leaf* Repeat(int times, NotNull<Leaf, 2> node) {
	return RepeatNode::create(times, node);
}

Leaf* Repeat(NotNull<Leaf, 1> node) {
	return RepeatNode::create(node);
}

Leaf* Retry(int times, NotNull<Leaf, 2> node) {
	return RetryNode::create(times, node);
}

Leaf* Retry(NotNull<Leaf, 1> node) {
	return RetryNode::create(node);
}

NS_BEHAVIOR_END

NS_DORA_PLATFORMER_END
