/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Platformer/Define.h"

#include "Platformer/Face.h"

#include "Animation/Animation.h"
#include "Cache/ClipCache.h"
#include "Cache/FrameCache.h"
#include "Node/Particle.h"
#include "Support/Geometry.h"

NS_DORA_PLATFORMER_BEGIN

Face::Face(String file, const Vec2& point, float scale, float angle)
	: _file(file.toString())
	, _pos(point)
	, _scale(scale)
	, _angle(angle) {
	if (SharedClipCache.isClip(_file)) {
		_type = Face::Clip;
	} else if (SharedFrameCache.isFrame(_file)) {
		_type = Face::Frame;
	} else if (Path::getExt(_file) == "par"_slice) {
		_type = Face::Particle;
	} else {
		switch (Switch::hash(Path::getExt(file.toString()))) {
			case "jpg"_hash:
			case "png"_hash:
			case "dds"_hash:
			case "pvr"_hash:
			case "ktx"_hash:
				_type = Face::Image;
				break;
			default:
				_type = Face::Unknown;
				Error("invalid face str: \"{}\"", file.toString());
				break;
		}
	}
}

Face::Face(const std::function<Node*()>& func, const Vec2& point, float scale, float angle)
	: _file()
	, _userCreateFunc(func)
	, _pos(point)
	, _scale(scale)
	, _angle(angle)
	, _type(Face::Custom) { }

void Face::addChild(Face* face) {
	_children.push_back(face);
}

bool Face::removeChild(Face* face) {
	auto it = _children.begin();
	for (; it != _children.end(); it++) {
		if (*it == face) {
			_children.erase(it);
			return true;
		}
	}
	return false;
}

Node* Face::toNode() const {
	Node* node = nullptr;
	switch (_type) {
		case Face::Clip:
			node = SharedClipCache.loadSprite(_file);
			break;
		case Face::Image:
			node = Sprite::create(SharedTextureCache.load(_file));
			break;
		case Face::Particle:
			node = ParticleNode::create(_file);
			break;
		case Face::Frame: {
			FrameActionDef* def = SharedFrameCache.load(_file);
			Sprite* sprite = SharedClipCache.loadSprite(def->clipStr);
			sprite->setTextureRect(*def->rects[0]);
			sprite->runAction(FrameAction::create(def));
			node = sprite;
			break;
		}
		case Face::Custom:
			node = _userCreateFunc();
			break;
		default:
			node = Node::create();
			break;
	}
	node->setTag("_F"_slice);
	node->setPosition(_pos);
	node->setAngle(_angle);
	node->setScaleX(_scale);
	node->setScaleY(_scale);
	WRef<Node> self(node);
	uint32_t total = 1 + s_cast<uint32_t>(_children.size());
	for (Face* child : _children) {
		node->addChild(child->toNode());
	}
	node->slot("Stop"_slice, [self, total](Event* e) {
		if (self) {
			auto count = std::make_shared<int>(0);
			auto callback = [self, total, count](Event*) {
				(*count)++;
				if (*count == total) {
					self->emit("Stoped"_slice);
				}
			};
			self->slot("__Stoped"_slice, callback);
			if (self->getChildren() && !self->getChildren()->isEmpty()) {
				ARRAY_START(Node, child, self->getChildren()) {
					if (child->getTag() == "_F"_slice) {
						child->slot("Stoped"_slice, callback);
						child->emit("Stop"_slice);
					}
				}
				ARRAY_END
			}
		}
	});
	switch (_type) {
		case Face::Clip:
		case Face::Image:
		case Face::Frame:
		case Face::Custom: {
			WRef<Node> self(node);
			node->slot("Stop"_slice, [self](Event*) {
				if (self) {
					self->setSelfVisible(false);
					self->emit("__Stoped"_slice);
				}
			});
			break;
		}
		case Face::Particle: {
			WRef<ParticleNode> self(s_cast<ParticleNode*>(node));
			node->slot("Stop"_slice, [self](Event*) {
				if (self) {
					if (self->isActive()) {
						self->stop();
						self->slot("Finish"_slice, [self](Event*) {
							self->emit("__Stoped"_slice);
						});
					} else
						self->emit("__Stoped"_slice);
				}
			});
			self->start();
			break;
		}
	}
	return node;
}

uint32_t Face::getType() const {
	return _type;
}

NS_DORA_PLATFORMER_END
