/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Platformer/Define.h"

#include "Platformer/PlatformWorld.h"

#include "Basic/Director.h"
#include "Platformer/Data.h"
#include "Platformer/PlatformCamera.h"

NS_DORA_PLATFORMER_BEGIN

/* Layer */

void PlatformWorld::Layer::setOffset(const Vec2& offset) {
	float deltaX = Node::getPosition().x - _offset.x;
	float deltaY = Node::getPosition().y - _offset.y;
	Node::setPosition(Vec2{deltaX + offset.x, deltaY + offset.y});
	_offset = offset;
}

const Vec2& PlatformWorld::Layer::getOffset() const noexcept {
	return _offset;
}

void PlatformWorld::Layer::markReorder() noexcept {
	Node::markReorder();
	if (_parent) {
		_parent->markReorder();
	}
}

/* PlatformWorld */

void PlatformWorld::addChild(Node* child, int order, String tag) {
	Node* layer = PlatformWorld::getLayer(order);
	layer->addChild(child, order, tag);
}

void PlatformWorld::removeChild(Node* child, bool cleanup) {
	Node* layer = PlatformWorld::getLayer(child->getOrder());
	if (layer == child)
		PhysicsWorld::removeChild(child, cleanup);
	else
		layer->removeChild(child, cleanup);
}

Node* PlatformWorld::getLayer(int order) {
	auto it = _layers.find(order);
	if (it != _layers.end() && it->second) {
		return it->second;
	} else {
		Layer* newLayer = Layer::create();
		Node::addChild(newLayer, order, newLayer->getTag());
		_layers[order] = newLayer;
		return newLayer;
	}
}

void PlatformWorld::setLayerRatio(int order, const Vec2& ratio) {
	s_cast<Layer*>(PlatformWorld::getLayer(order))->ratio = ratio;
}

const Vec2& PlatformWorld::getLayerRatio(int order) {
	return s_cast<Layer*>(PlatformWorld::getLayer(order))->ratio;
}

void PlatformWorld::setLayerOffset(int order, const Vec2& offset) {
	s_cast<Layer*>(PlatformWorld::getLayer(order))->setOffset(offset);
}

const Vec2& PlatformWorld::getLayerOffset(int order) {
	return s_cast<Layer*>(PlatformWorld::getLayer(order))->getOffset();
}

void PlatformWorld::swapLayer(int orderA, int orderB) {
	Layer* layerA = s_cast<Layer*>(PlatformWorld::getLayer(orderA));
	Layer* layerB = s_cast<Layer*>(PlatformWorld::getLayer(orderB));
	_layers[orderA] = layerB;
	_layers[orderB] = layerA;
	layerA->setOrder(orderB);
	layerA->eachChild([orderB](Node* child) {
		child->setOrder(orderB);
		return false;
	});
	layerB->setOrder(orderA);
	layerB->eachChild([orderA](Node* child) {
		child->setOrder(orderA);
		return false;
	});
}

bool PlatformWorld::init() {
	if (!PhysicsWorld::init()) return false;
	_camera = PlatformCamera::create("Platformer"_slice);
	_camera->moved += std::make_pair(this, &PlatformWorld::onCameraMoved);
	_camera->reset += std::make_pair(this, &PlatformWorld::onCameraReset);
	return true;
}

void PlatformWorld::onEnter() {
	if (_camera) {
		SharedDirector.pushCamera(_camera.get());
	}
	SharedData.apply(this);
	Node::onEnter();
}

void PlatformWorld::onExit() {
	if (_camera) {
		SharedDirector.removeCamera(_camera.get());
	}
	Node::onExit();
}

void PlatformWorld::cleanup() {
	if (_flags.isOff(Node::Cleanup)) {
		_camera = nullptr;
		PhysicsWorld::cleanup();
	}
}

void PlatformWorld::sortAllChildren() {
	if (_flags.isOn(Node::Reorder)) {
		Node::sortAllChildren();
		ARRAY_START(Layer, layer, _children) {
			std::vector<Node*> nodes;
			ARRAY_START(Node, child, layer->getChildren()) {
				if (child->getOrder() != layer->getOrder()) {
					nodes.push_back(child);
				}
			}
			ARRAY_END
			for (Node* node : nodes) {
				moveChild(node, node->getOrder());
			}
		}
		ARRAY_END
	}
}

void PlatformWorld::moveChild(Node* child, int newOrder) {
	Node* layer = child->getParent();
	if (layer && layer->getOrder() != newOrder) {
		Node* newLayer = getLayer(newOrder);
		child->moveToParent(newLayer);
	}
}

PlatformCamera* PlatformWorld::getCamera() const noexcept {
	return _camera;
}

void PlatformWorld::onCameraMoved(float deltaX, float deltaY) {
	for (auto it : _layers) {
		if (Layer* layer = it.second) {
			Vec2 pos = {
				deltaX * layer->ratio.x + layer->getX(),
				deltaY * layer->ratio.y + layer->getY()};
			layer->setPosition(pos);
		}
	}
}

void PlatformWorld::onCameraReset() {
	for (auto it : _layers) {
		if (Layer* layer = it.second) {
			layer->setPosition(layer->getOffset());
		}
	}
}

void PlatformWorld::removeLayer(int order) {
	auto it = _layers.find(order);
	if (it != _layers.end()) {
		if (it->second) it->second->removeFromParent(true);
		_layers.erase(it);
	}
}

void PlatformWorld::removeAllLayers() {
	for (const auto& item : _layers) {
		if (item.second) item.second->removeFromParent(true);
	}
	_layers.clear();
}

NS_DORA_PLATFORMER_END
