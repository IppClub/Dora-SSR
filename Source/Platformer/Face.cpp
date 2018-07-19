/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Platformer/Define.h"
#include "Support/Geometry.h"
#include "Platformer/Face.h"
#include "Node/Particle.h"
#include "Animation/Animation.h"
#include "Cache/ClipCache.h"
#include "Cache/FrameCache.h"

NS_DOROTHY_PLATFORMER_BEGIN

Face::Face(String file, const Vec2& point, float angle):
_file(file),
_pos(point),
_angle(0.0f)
{
	if (_file.find('|') != string::npos)
	{
		_type = Face::Clip;
	}
	else
	{
		switch (Switch::hash(Slice(file.toLower()).getFileExtension()))
		{
			case ".frame"_hash:
				_type = Face::Frame;
				break;
			case ".par"_hash:
				_type = Face::Particle;
			default:
				_type = Face::Image;
				break;
		}
	}
}

void Face::addChild(Face* face)
{
	_children.push_back(face);
}

bool Face::removeChild(Face* face)
{
	auto it = _children.begin();
	for (;it != _children.end();it++)
	{
		if (*it == face)
		{
			_children.erase(it);
			return true;
		}
	}
	return false;
}

Node* Face::toNode()
{
	Node* node = nullptr;
	switch (_type)
	{
		case Face::Clip:
			node = SharedClipCache.loadSprite(_file);
			break;
		case Face::Image:
			node = Sprite::create(_file);
			break;
		case Face::Particle:
			node = ParticleNode::create(_file);
			break;
		case Face::Frame:
		{
			FrameActionDef* def = SharedFrameCache.load(_file);
			Sprite* sprite = Sprite::create(def->textureFile);
			sprite->setTextureRect(*def->rects[0]);
			sprite->runAction(FrameAction::create(def));
			node = sprite;
			break;
		}
	}
	if (node)
	{
		switch (_type)
		{
			case Face::Clip:
			case Face::Image:
			case Face::Frame:
			{
				WRef<Node> self(node);
				node->slot("Stop"_slice, [self](Event*)
				{
					if (self)
					{
						self->setSelfVisible(false);
						self->emit("__Stoped"_slice);
					}
				});
				break;
			}
			case Face::Particle:
			{
				WRef<ParticleNode> self(s_cast<ParticleNode*>(node));
				node->slot("Stop"_slice, [self](Event*)
				{
					if (self)
					{
						if (self->isActive())
						{
							self->stop();
							self->slot("Finish"_slice, [self](Event*)
							{
								self->emit("__Stoped"_slice);
							});
						}
						else self->emit("__Stoped"_slice);
					}
				});
				break;
			}
		}
		node->setPosition(_pos);
		node->setAngle(_angle);
		WRef<Node> self(node);
		node->slot("Stop"_slice, [self](Event* e)
		{
			if (self)
			{
				Uint32 total = self->getNodeCount();
				Ref<ValueEx<Uint32>> count(ValueEx<Uint32>::create(0));
				auto callback = [self,total,count](Event*)
				{
					count->set(count->get() + 1);
					if (count->get() == total)
					{
						self->emit("Stoped"_slice);
					}
				};
				self->slot("__Stoped"_slice, callback);
				if (self->getChildren() && !self->getChildren()->isEmpty())
				{
					ARRAY_START(Node, child, self->getChildren())
					{
						child->slot("Stoped"_slice, callback);
						child->emit("Stop"_slice);
					}
					ARRAY_END
				}
				else
				{
					self->emit("Stoped"_slice);
				}
			}
		});
	}
	return node;
}

uint32 Face::getType() const
{
	return _type;
}

NS_DOROTHY_PLATFORMER_END
