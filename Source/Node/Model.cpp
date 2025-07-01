/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/Model.h"

#include "Animation/Animation.h"
#include "Animation/ModelDef.h"
#include "Cache/ClipCache.h"
#include "Cache/ModelCache.h"
#include "Node/Sprite.h"

NS_DORA_BEGIN

void Look::add(Node* node) {
	_nodes.push_back(node);
}

void Look::apply() {
	for (Node* node : _nodes) {
		node->setVisible(false);
	}
}

void Look::unApply() {
	for (Node* node : _nodes) {
		node->setVisible(true);
	}
}

Model::Model(ModelDef* def)
	: _isRecovering(false)
	, _reversed(false)
	, _isPlaying(false)
	, _isPaused(false)
	, _loop(false)
	, _currentLook(-1)
	, _currentAnimation(-1)
	, _modelDef(def) {
	_flags.setOff(Node::TraverseEnabled);
}

Model::Model(String filename)
	: Model(SharedModelCache.load(
		  Path::getExt(filename.toString()).empty() ? filename.toString() + ".model"s : filename.toString())) { }

bool Model::init() {
	if (!Playable::init()) return false;
	if (!_modelDef) {
		setAsManaged();
		return false;
	}
	_resetAnimation.end = std::make_pair(this, &Model::onResetAnimationEnd);
	_root = Node::create(false);
	const std::string& clipFile = _modelDef->getClipFile();
	if (!clipFile.empty()) {
		ClipDef* clipDef = SharedClipCache.load(_modelDef->getClipFile());
		Model::visit(_modelDef->getRoot(), _root, clipDef);
		Model::setupCallback();
		for (int i = 0; i < s_cast<int>(_animationGroups.size()); i++) {
			const std::string& name = _modelDef->getAnimationNameByIndex(i);
			_animationGroups[i]->animationEnd = [this, name](Model* model) {
				emit("AnimationEnd"_slice, name, s_cast<Playable*>(model));
				_lastCompletedAnimationName = name;
			};
		}
	}
	Size size = _modelDef->getSize();
	Model::setSize(size);
	_root->setPosition(Vec2{size.width * 0.5f, size.height * 0.5f});
	addChild(_root);
	handlers(this);
	return true;
}

bool Model::hasAnimation(String name) const {
	return _modelDef->getAnimationIndexByName(name) != Animation::None;
}

void Model::addLook(int index, Node* node) {
	for (int n = s_cast<int>(_looks.size()); n < index + 1; _looks.push_back(New<Look>()), n++);
	_looks[index]->add(node);
}

void Model::setLook(int index) {
	if (_looks.empty()) return;
	if (index < Look::None || index >= s_cast<int>(_looks.size())) {
		if (_looks.empty() && Look::None < index && _currentLook == Look::None) {
			_currentLook = index;
		}
		return;
	}
	if (_currentLook != index) {
		if (_currentLook != Look::None) {
			_looks[_currentLook]->unApply();
		}
		_currentLook = index;
		if (_currentLook != Look::None) {
			_looks[_currentLook]->apply();
		}
	}
}

void Model::setLook(String name) {
	int index = _modelDef->getLookIndexByName(name);
	if (index != Look::None) {
		Model::setLook(index);
		Playable::setLook(name);
	}
}

void Model::setFliped(bool var) {
	_root->setScaleX(var ? -1.0f : 1.0f);
	Playable::setFliped(var);
}

float Model::play(uint32_t index, bool loop) {
	Model::stop();
	if (index == Animation::None || index >= _animationGroups.size()) {
		return 0;
	}
	_loop = loop;
	_isPlaying = true;
	_currentAnimation = index;
	if (_recoveryTime > 0.0f) {
		_isRecovering = true;
		_resetAnimation.run(_recoveryTime / std::max(_speed, FLT_EPSILON), _currentAnimation);
	} else {
		Model::resetActions();
		Model::onResetAnimationEnd();
	}
	return (_animationGroups[_currentAnimation]->duration + _recoveryTime) / std::max(_speed, FLT_EPSILON);
}

float Model::play(String name, bool loop) {
	int index = _modelDef->getAnimationIndexByName(name);
	return Model::play(index, loop);
}

void Model::reset() {
	Model::stop();
	Model::resetActions();
}

void Model::addAnimation(int index, Node* node, Action* action) {
	for (int n = s_cast<int>(_animationGroups.size()); n < index + 1; _animationGroups.push_back(New<AnimationGroup>()), n++);
	_animationGroups[index]->animations.push_back(New<Animation>(node, action));
}

void Model::stop() {
	_isPlaying = false;
	_lastCompletedAnimationName.clear();
	Model::resume();
	if (_isRecovering) {
		_resetAnimation.stop();
	} else {
		if (_currentAnimation != Animation::None) {
			for (const auto& animation : _animationGroups[_currentAnimation]->animations) {
				animation->stop();
			}
		}
	}
}

void Model::setSlot(String name, Node* item) {
	if (auto slot = getNodeByName(name)) {
		slot->addChild(item, 0, name);
	}
}

Node* Model::getSlot(String name) {
	if (auto slot = getNodeByName(name)) {
		return slot->getChildByTag(name);
	}
	return nullptr;
}

bool Model::isPlaying() const noexcept {
	return _isPlaying;
}

void Model::resetActions() {
	for (auto it = _spritePairs.begin(); it != _spritePairs.end(); ++it) {
		it->second->restore(it->first);
	}
}

void Model::onActionEnd() {
	if (_isPaused) {
		return;
	}
	AnimationGroup* group = _animationGroups[_currentAnimation].get();
	group->animationEnd(this);
	if (_loop && group->duration > 0.0f) {
		if (!_isRecovering) {
			for (const auto& animation : group->animations) {
				animation->stop();
				animation->run();
			}
		}
	} else {
		_isPlaying = false;
	}
}

int Model::getCurrentAnimationIndex() const {
	if (_isPlaying) {
		return _currentAnimation;
	}
	return Animation::None;
}

void Model::resume(uint32_t index, bool loop) {
	Model::resume();
	if (!_isPlaying || _currentAnimation != index) {
		Model::play(index, loop);
	} else if (_isPlaying) {
		if (!_animationGroups[_currentAnimation]->animations.empty()) {
			Animation* animation = _animationGroups[_currentAnimation]->animations[0].get();
			if (animation->getElapsed() >= animation->getDuration()) {
				Model::play(index, loop);
			}
		} else {
			_loop = loop;
		}
	}
}

void Model::resume(String name, bool loop) {
	int index = _modelDef->getAnimationIndexByName(name);
	Model::resume(index, loop);
}

void Model::resume() {
	if (_isPaused) {
		_isPaused = false;
		if (!_isRecovering) {
			for (const auto& animation : _animationGroups[_currentAnimation]->animations) {
				animation->resume();
			}
		}
	}
}

ModelDef* Model::getModelDef() const {
	return _modelDef;
}

bool Model::isPaused() const noexcept {
	return _isPaused;
}

void Model::pause() {
	if (_isPlaying && !_isPaused) {
		_isPaused = true;
		for (const auto& animation : _animationGroups[_currentAnimation]->animations) {
			animation->pause();
		}
	}
}

void Model::setSpeed(float speed) {
	if (_speed != speed) {
		_speed = std::max(speed, 0.0f);
		for (const auto& animationGroup : _animationGroups) {
			for (const auto& animation : animationGroup->animations) {
				animation->setSpeed(_speed);
			}
		}
		Playable::setSpeed(speed);
	}
}

void Model::setReversed(bool var) {
	if (_reversed != var) {
		_reversed = var;
		for (const auto& animationGroup : _animationGroups) {
			for (const auto& animation : animationGroup->animations) {
				animation->setReversed(var);
			}
		}
	}
}

bool Model::isReversed() const noexcept {
	return _reversed;
}

void Model::updateTo(float elapsed, bool reversed) {
	if (_isPlaying) {
		for (const auto& animation : _animationGroups[_currentAnimation]->animations) {
			animation->updateTo(elapsed, reversed);
		}
	}
}

void Model::setRecovery(float var) {
	if (var < 0.0f) {
		var = 0.0f;
	}
	Playable::setRecovery(var);
}

float Model::getDuration() const noexcept {
	if (_currentAnimation != Animation::None && !_animationGroups[_currentAnimation]->animations.empty()) {
		return _animationGroups[_currentAnimation]->animations[0]->getDuration();
	}
	return 0;
}

void Model::cleanup() {
	if (_flags.isOff(Node::Cleanup)) {
		Node::cleanup();
		for (const auto& animationGroup : _animationGroups) {
			animationGroup->animationEnd.Clear();
		}
	}
}

Model* Model::dummy() {
	return Model::create(ModelDef::create());
}

void Model::onResetAnimationEnd() {
	_isRecovering = false;
	for (const auto& animation : _animationGroups[_currentAnimation]->animations) {
		animation->run();
	}
}

void Model::visit(SpriteDef* parentDef, Node* parentNode, ClipDef* clipDef) {
	if (!parentDef) {
		return;
	}
	const OwnVector<SpriteDef>& childrenDefs = parentDef->children;
	for (size_t n = 0; n < childrenDefs.size(); n++) {
		SpriteDef* nodeDef = childrenDefs[n].get();
		Sprite* node = nodeDef->toSprite(clipDef);
		if (nodeDef->emittingEvent) {
			node->slot("ModelEvent"_slice, [this](Event* e) {
				emit(e);
			});
		}
		_spritePairs.push_back(std::make_pair(node, nodeDef));

		Model::visit(nodeDef, node, clipDef);

		if (!nodeDef->name.empty()) {
			Model::nodeMap()[nodeDef->name] = node;
		}

		Action* animation;
		ResetAction* resetAction;
		std::tie(animation, resetAction) = nodeDef->toResetAction();
		_resetAnimation.add(nodeDef, node, animation, resetAction);

		parentNode->addChild(node, nodeDef->front ? 0 : -1);
		// Look
		if (!nodeDef->looks.empty()) {
			for (int lookIndex : nodeDef->looks) {
				Model::addLook(lookIndex, node);
			}
		}
		// Animation
		const OwnVector<AnimationDef>& animationDefs = nodeDef->animationDefs;
		for (size_t i = 0; i < animationDefs.size(); i++) {
			AnimationDef* animationDef = animationDefs[i].get();
			if (animationDef) {
				Model::addAnimation(s_cast<int>(i), node, animationDef->toAction());
			}
		}
	}
}

Model::NodeMap& Model::nodeMap() {
	if (!_nodeMap) {
		_nodeMap = New<NodeMap>();
	}
	return *_nodeMap;
}

Node* Model::getNodeByName(String name) const {
	if (!_nodeMap) {
		return nullptr;
	} else {
		auto it = _nodeMap->find(name);
		if (it != _nodeMap->end()) {
			return it->second;
		}
		return nullptr;
	}
}

bool Model::eachNode(std::function<bool(Node* node)> handler) const {
	if (!_nodeMap) {
		return false;
	} else {
		for (const auto& it : *_nodeMap) {
			if (handler(it.second)) return true;
		}
		return false;
	}
}

const std::string& Model::getCurrent() const {
	return _modelDef->getAnimationNameByIndex(_currentAnimation);
}

const std::string& Model::getLastCompleted() const {
	return _lastCompletedAnimationName;
}

Vec2 Model::getKeyPoint(String name) {
	auto& keyPoints = _modelDef->getKeyPoints();
	auto it = keyPoints.find(name);
	if (it != keyPoints.end()) {
		auto keyPoint = it->second;
		if (isFliped()) {
			keyPoint.x = -keyPoint.x;
		}
		return keyPoint * Vec2{getScaleX(), getScaleY()};
	}
	if (auto node = getNodeByName(name)) {
		auto target = node->convertToWorldSpace(Vec2::zero);
		Vec3 origin = Vec3::from(bx::mul(bx::Vec3{0.0f, 0.0f, 0.0f}, getWorld().m));
		return target - origin.toVec2();
	}
	return Vec2::zero;
}

Animation::Animation(Node* node, Action* action)
	: _node(node)
	, _action(action) { }

void Animation::run() {
	_node->runAction(_action);
}

void Animation::stop() {
	_node->stopAction(_action);
}

Node* Animation::getNode() const noexcept {
	return _node;
}

void Animation::setAction(Action* action) {
	_action = action;
}

Action* Animation::getAction() const noexcept {
	return _action;
}

void Animation::pause() {
	_action->pause();
}

void Animation::resume() {
	_action->resume();
}

void Animation::setSpeed(float speed) {
	_action->setSpeed(speed);
}

float Animation::getSpeed() const noexcept {
	return _action->getSpeed();
}

void Animation::setReversed(bool var) {
	_action->setReversed(var);
}

bool Animation::isReversed() const noexcept {
	return _action->isReversed();
}

void Animation::updateTo(float elapsed, bool reversed) {
	_action->updateTo(elapsed, reversed);
}

float Animation::getDuration() const noexcept {
	return _action->getDuration();
}

float Animation::getElapsed() const noexcept {
	return _action->getElapsed();
}

void ResetAnimation::add(SpriteDef* spriteDef, Node* node, Action* action, ActionDuration* resetTarget) {
	AnimationData* data = new AnimationData();
	data->spriteDef = spriteDef;
	data->node = node;
	data->action = action;
	data->resetTarget = resetTarget;
	_group.push_back(MakeOwn(data));
	if (_group.size() == 1) {
		Action* action = _group[0]->action;
		_group[0]->node->slot("ActionEnd"_slice, [this, action](Event* event) {
			Action* eventAction = nullptr;
			Node* target = nullptr;
			if (event->get(eventAction, target) && action == eventAction) {
				onActionEnd();
			}
		});
	}
}

void ResetAnimation::run(float duration, int index) {
	for (const auto& pair : _group) {
		if (pair->resetTarget) {
			AnimationDef* animationDef = nullptr;
			if (index < s_cast<int>(pair->spriteDef->animationDefs.size())) {
				animationDef = pair->spriteDef->animationDefs[index].get();
			}
			if (animationDef) {
				animationDef->restoreResetAnimation(pair->node, pair->resetTarget);
			} else {
				pair->spriteDef->restoreResetAnimation(pair->node, pair->resetTarget);
			}
		}
		pair->node->stopAllActions();
		pair->action->setSpeed(1.0f / std::max(duration, FLT_EPSILON));
		pair->node->runAction(pair->action);
	}
}

void ResetAnimation::stop() {
	for (const auto& pair : _group) {
		pair->node->stopAction(pair->action);
	}
}

void ResetAnimation::onActionEnd() {
	end();
}

void Model::AnimationHandlerGroup::operator()(Model* owner) {
	_owner = owner;
}

AnimationHandler& Model::AnimationHandlerGroup::operator[](int index) {
	return _owner->_animationGroups[index]->animationEnd;
}

AnimationHandler& Model::AnimationHandlerGroup::operator[](String name) {
	int index = _owner->_modelDef->getAnimationIndexByName(name);
	if (index == Animation::None) {
		Warn("try registering callback for non-exist animation named: \"{}\".", name.toString());
		return _unavailableHandler;
	}
	return _owner->_animationGroups[index]->animationEnd;
}

void Model::setupCallback() {
	for (const auto& animationGroup : _animationGroups) {
		if (animationGroup->animations.empty()) {
			continue;
		}
		float duration = 0.0f;
		for (const auto& animation : animationGroup->animations) {
			float d = animation->getDuration();
			if (duration < d) {
				duration = d;
			}
		}
		Action* action = animationGroup->animations[0]->getAction();
		float d = action->getDuration();
		if (d < duration) {
			action = Sequence::create(
				std::move(action->getAction()),
				Delay::alloc(duration - d));
		}
		Node* node = animationGroup->animations[0]->getNode();
		node->slot("ActionEnd"_slice, [this, action](Event* event) {
			Action* eventAction = nullptr;
			Node* target = nullptr;
			if (event->get(eventAction, target) && action == eventAction) {
				onActionEnd();
			}
		});
		animationGroup->duration = action->getDuration();
		animationGroup->animations[0]->setAction(action);
	}
}

NS_DORA_END
