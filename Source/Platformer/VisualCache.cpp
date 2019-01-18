/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Platformer/Define.h"
#include "Platformer/VisualCache.h"
#include "Node/Particle.h"
#include "Cache/TextureCache.h"
#include "Cache/ParticleCache.h"
#include "Cache/FrameCache.h"
#include "Animation/Animation.h"
#include "Const/XmlTag.h"

NS_DOROTHY_PLATFORMER_BEGIN

// VisualType

VisualType::VisualType(String filename):
_file(filename),
_type(VisualType::Unkown)
{
	if (SharedFrameCache.isFrame(filename))
	{
		_type = VisualType::Frame;
	}
	else if (filename.getFileExtension() == "par"_slice)
	{
		_type = VisualType::Particle;
	}
	else Warn("got invalid visual file str: \"{}\".", filename);
}

Visual* VisualType::toVisual() const
{
	switch (_type)
	{
		case VisualType::Particle:
			return ParticleVisual::create(_file);
		case VisualType::Frame:
			return SpriteVisual::create(_file);
	}
	return nullptr;
}

const string& VisualType::getFilename() const
{
	return _file;
}

// VisualCache

VisualCache::VisualCache():
_parser(this)
{ }

VisualCache::~VisualCache()
{
	VisualCache::unload();
}

bool VisualCache::load(String filename)
{
	if (!_visuals.empty())
	{
		VisualCache::unload();
	}
	auto data = SharedContent.loadFile(filename);
	if (!data)
	{
		return false;
	}
	string fullPath = SharedContent.getFullPath(filename);
	_path = Slice(fullPath).getFilePath();
	try
	{
		_parser.parse(r_cast<char*>(data.get()), s_cast<int>(data.size()));
		return true;
	}
	catch (rapidxml::parse_error error)
	{
		Warn("xml parse error: {}, at: {}, ", error.what(), error.where<char>() - r_cast<char*>(data.get()));
		return false;
	}
}

bool VisualCache::update(String content)
{
	if (!_visuals.empty())
	{
		VisualCache::unload();
	}
	size_t size = content.size() + 1;
	auto data = MakeOwnArray(new char[size], size);
	content.copyTo(data);
	try
	{
		_parser.parse(r_cast<char*>(data.get()), s_cast<int>(data.size()));
		return true;
	}
	catch (rapidxml::parse_error error)
	{
		Warn("xml parse error: {}, at: {}", error.what(), error.where<char>() - r_cast<char*>(data.get()));
		return false;
	}
}

bool VisualCache::unload()
{
	if (_visuals.empty())
	{
		return false;
	}
	else
	{
		_visuals.clear();
		return true;
	}
}

Visual* VisualCache::create(String name)
{
	auto it = _visuals.find(name);
	if (it != _visuals.end())
	{
		return it->second->toVisual();
	}
	if (SharedFrameCache.isFrame(name))
	{
		return SpriteVisual::create(name);
	}
	else if (name.getFileExtension() == "par"_slice)
	{
		return ParticleVisual::create(name);
	}
	return nullptr;
}

const string& VisualCache::getFileByName(String name)
{
	auto it = _visuals.find(name);
	if (it != _visuals.end())
	{
		return it->second->getFilename();
	}
	return Slice::Empty;
}

void VisualCache::xmlSAX2Text(const char* s, size_t len)
{ }

void VisualCache::xmlSAX2StartElement(const char* name, size_t len, const vector<AttrSlice>& attrs)
{
	switch (Xml::Visual::Element(name[0]))
	{
		case Xml::Visual::Element::Dorothy:
			break;
		case Xml::Visual::Element::Visual:
		{
			string name, file;
			for (int i = 0; attrs[i].first != nullptr; i++)
			{
				switch (Xml::Visual::Visual(attrs[i].first[0]))
				{
					case Xml::Visual::Visual::Name:
						name = Slice(attrs[++i]);
						break;
					case Xml::Visual::Visual::File:
						file = _path + Slice(attrs[++i]);
						break;
				}
			}
			_visuals[name] = New<VisualType>(file);
		}
		break;
	}
}

void VisualCache::xmlSAX2EndElement(const char* name, size_t len)
{ }

// ParticleVisual

void ParticleVisual::start()
{
	if (_particle) _particle->start();
}

void ParticleVisual::stop()
{
	if (_particle) _particle->stop();
}

Visual* ParticleVisual::autoRemove()
{
	if (_particle)
	{
		WRef<ParticleNode> par(_particle);
		WRef<Node> self(this);
		_particle->slot("Finished"_slice, [par, self](Event*)
		{
			if (self) self->removeFromParent(true);
		});
	}
	return this;
}

ParticleVisual::ParticleVisual(String filename):
_particle(ParticleNode::create(filename))
{ }

bool ParticleVisual::init()
{
	if (!Visual::init()) return false;
	addChild(_particle);
	return true;
}

bool ParticleVisual::isPlaying()
{
	if (_particle) return _particle->isActive();
	return false;
}

ParticleNode* ParticleVisual::getParticle() const
{
	return _particle;
}

// SpriteVisual

void SpriteVisual::start()
{
	if (!_action->isRunning())
	{
		_sprite->setVisible(true);
		_sprite->perform(_action);
	}
}

void SpriteVisual::stop()
{
	if (_action->isRunning())
	{	
		_sprite->setVisible(false);
		_sprite->stopAllActions();
	}
	if (_isAutoRemoved)
	{
		_sprite->stopAllActions();
		removeFromParent(true);
	}
}

Visual* SpriteVisual::autoRemove()
{
	_isAutoRemoved = true;
	return this;
}

SpriteVisual::SpriteVisual(String filename):
_isAutoRemoved(false)
{
	WRef<SpriteVisual> self(this);
	FrameActionDef* frameActionDef = SharedFrameCache.loadFrame(filename);
	_sprite = Sprite::create(
		SharedTextureCache.load(frameActionDef->clipStr),
		*frameActionDef->rects[0]);
	_action = Action::create(Sequence::alloc(FrameAction::alloc(frameActionDef), Call::alloc([self]()
	{
		if (self)
		{
			self->_sprite->setVisible(false);
			if (self->_isAutoRemoved)
			{
				self->removeFromParent(true);
			}
		}
	})));
}

bool SpriteVisual::init()
{
	if (!Visual::init()) return false;
	addChild(_sprite);
	return true;
}

bool SpriteVisual::isPlaying()
{
	return _action->isRunning();
}

Sprite* SpriteVisual::getSprite() const
{
	return _sprite;
}

class DummyVisual : public Visual
{
public:
	DummyVisual()
	: _node(Node::create())
	, _isAutoRemoved(false)
	{ }
	virtual void start() override { stop(); }
	virtual bool isPlaying() override { return false; }
	virtual void stop() override
	{
		if (_isAutoRemoved)
		{
			Node* parent = Node::getParent();
			if (parent) parent->removeChild(this, true);
		}
	}
	virtual Visual* autoRemove() override
	{
		_isAutoRemoved = true;
		return this;
	}
	static DummyVisual* create()
	{
		DummyVisual* visual = new DummyVisual();
		visual->autorelease();
		return visual;
	}
private:
	bool _isAutoRemoved;
	Ref<Node> _node;
};

Visual* Visual::create(String name)
{
	Visual* visual = SharedVisualCache.create(name);
	if (!visual) visual = DummyVisual::create();
	return visual;
}

NS_DOROTHY_PLATFORMER_END
