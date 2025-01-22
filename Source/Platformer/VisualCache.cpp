/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Platformer/Define.h"

#include "Platformer/VisualCache.h"

#include "Animation/Animation.h"
#include "Cache/FrameCache.h"
#include "Cache/ParticleCache.h"
#include "Cache/TextureCache.h"
#include "Const/XmlTag.h"
#include "Node/Particle.h"

NS_DORA_PLATFORMER_BEGIN

// VisualType

VisualType::VisualType(String filename)
	: _file(filename.toString())
	, _type(VisualType::Unkown) {
	if (SharedFrameCache.isFrame(filename)) {
		_type = VisualType::Frame;
	} else if (Path::getExt(filename.toString()) == "par"_slice) {
		_type = VisualType::Particle;
	} else {
		Error("got invalid visual file str: \"{}\".", filename.toString());
	}
}

Visual* VisualType::toVisual() const {
	switch (_type) {
		case VisualType::Particle:
			return ParticleVisual::create(_file);
		case VisualType::Frame:
			return SpriteVisual::create(_file);
	}
	return nullptr;
}

const std::string& VisualType::getFilename() const {
	return _file;
}

// VisualCache

VisualCache::VisualCache()
	: _parser(this) { }

VisualCache::~VisualCache() {
	VisualCache::unload();
}

bool VisualCache::load(String filename) {
	if (!_visuals.empty()) {
		VisualCache::unload();
	}
	auto data = SharedContent.load(filename);
	if (!data.first) {
		return false;
	}
	std::string fullPath = SharedContent.getFullPath(filename);
	_path = Path::getPath(fullPath);
	try {
		_parser.parse(r_cast<char*>(data.first.get()), s_cast<int>(data.second));
		return true;
	} catch (rapidxml::parse_error error) {
		Error("xml parse error: {}, at: {}, ", error.what(), error.where<char>() - r_cast<char*>(data.first.get()));
		return false;
	}
}

bool VisualCache::update(String content) {
	if (!_visuals.empty()) {
		VisualCache::unload();
	}
	size_t size = content.size() + 1;
	auto data = MakeOwnArray(new char[size]);
	content.copyTo(data.get());
	try {
		_parser.parse(r_cast<char*>(data.get()), s_cast<int>(size));
		return true;
	} catch (rapidxml::parse_error error) {
		Error("xml parse error: {}, at: {}", error.what(), error.where<char>() - r_cast<char*>(data.get()));
		return false;
	}
}

bool VisualCache::unload() {
	if (_visuals.empty()) {
		return false;
	} else {
		_visuals.clear();
		return true;
	}
}

Visual* VisualCache::create(String name) {
	auto it = _visuals.find(name);
	if (it != _visuals.end()) {
		return it->second->toVisual();
	}
	if (SharedFrameCache.isFrame(name)) {
		return SpriteVisual::create(name);
	} else if (Path::getExt(name.toString()) == "par"_slice) {
		return ParticleVisual::create(name);
	}
	return nullptr;
}

const std::string& VisualCache::getFileByName(String name) {
	auto it = _visuals.find(name);
	if (it != _visuals.end()) {
		return it->second->getFilename();
	}
	return Slice::Empty;
}

void VisualCache::xmlSAX2Text(std::string_view text) { }

void VisualCache::xmlSAX2StartElement(std::string_view name, const std::vector<std::string_view>& attrs) {
	switch (Xml::Visual::Element(name[0])) {
		case Xml::Visual::Element::Dorothy:
			break;
		case Xml::Visual::Element::Visual: {
			std::string name, file;
			for (int i = 0; !attrs[i].empty(); i++) {
				switch (Xml::Visual::Visual(attrs[i][0])) {
					case Xml::Visual::Visual::Name:
						name = Slice(attrs[++i]).toString();
						break;
					case Xml::Visual::Visual::File:
						file = _path + Slice(attrs[++i]);
						break;
				}
			}
			_visuals[name] = New<VisualType>(file);
		} break;
	}
}

void VisualCache::xmlSAX2EndElement(std::string_view name) { }

// ParticleVisual

void ParticleVisual::start() {
	if (_particle) _particle->start();
}

void ParticleVisual::stop() {
	if (_particle) _particle->stop();
}

Visual* ParticleVisual::autoRemove() {
	if (_particle) {
		WRef<ParticleNode> par(_particle);
		WRef<Node> self(this);
		_particle->slot("Finished"_slice, [par, self](Event*) {
			if (self) self->removeFromParent(true);
		});
	}
	return this;
}

ParticleVisual::ParticleVisual(String filename)
	: _particle(ParticleNode::create(filename)) { }

bool ParticleVisual::init() {
	if (!Visual::init()) return false;
	if (!_particle) {
		setAsManaged();
		return false;
	}
	addChild(_particle);
	return true;
}

bool ParticleVisual::isPlaying() {
	if (_particle) return _particle->isActive();
	return false;
}

ParticleNode* ParticleVisual::getParticle() const {
	return _particle;
}

// SpriteVisual

void SpriteVisual::start() {
	if (!_action->isRunning()) {
		_sprite->setVisible(true);
		_sprite->perform(_action);
	}
}

void SpriteVisual::stop() {
	if (_action->isRunning()) {
		_sprite->setVisible(false);
		_sprite->stopAllActions();
	}
	if (_isAutoRemoved) {
		_sprite->stopAllActions();
		removeFromParent(true);
	}
}

Visual* SpriteVisual::autoRemove() {
	_isAutoRemoved = true;
	return this;
}

SpriteVisual::SpriteVisual(String filename)
	: _isAutoRemoved(false)
	, _sprite(nullptr)
	, _action(nullptr) {
	if (FrameActionDef* frameActionDef = SharedFrameCache.loadFrame(filename)) {
		if (Texture2D* tex = SharedTextureCache.load(frameActionDef->clipStr)) {
			_sprite = Sprite::create(tex, *frameActionDef->rects[0]);
			Action* action = Action::create(FrameAction::alloc(frameActionDef));
			WRef<SpriteVisual> self{this};
			_sprite->slot("ActionEnd"_slice, [self, action](Event* event) {
				Action* eventAction = nullptr;
				Node* target = nullptr;
				if (event->get(eventAction, target) && action == eventAction) {
					if (self) {
						self->_sprite->setVisible(false);
						if (self->_isAutoRemoved) {
							self->removeFromParent(true);
						}
					}
				}
			});
			_action = action;
		}
	}
}

bool SpriteVisual::init() {
	if (!Visual::init()) return false;
	if (!_sprite || !_action) {
		setAsManaged();
		return false;
	}
	addChild(_sprite);
	return true;
}

bool SpriteVisual::isPlaying() {
	return _action->isRunning();
}

Sprite* SpriteVisual::getSprite() const {
	return _sprite;
}

class DummyVisual : public Visual {
public:
	DummyVisual()
		: _node(Node::create())
		, _isAutoRemoved(false) { }
	virtual void start() override { stop(); }
	virtual bool isPlaying() override { return false; }
	virtual void stop() override {
		if (_isAutoRemoved) {
			Node* parent = Node::getParent();
			if (parent) parent->removeChild(this, true);
		}
	}
	virtual Visual* autoRemove() override {
		_isAutoRemoved = true;
		return this;
	}
	CREATE_FUNC_NOT_NULL(DummyVisual);

private:
	bool _isAutoRemoved;
	Ref<Node> _node;
};

Visual* Visual::create(String name) {
	Visual* visual = SharedVisualCache.create(name);
	if (!visual) visual = DummyVisual::create();
	return visual;
}

NS_DORA_PLATFORMER_END
