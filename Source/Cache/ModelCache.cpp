/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Cache/ModelCache.h"

#include "Animation/Animation.h"
#include "Animation/ModelDef.h"
#include "Cache/ClipCache.h"
#include "Const/XmlTag.h"

NS_DORA_BEGIN

std::shared_ptr<XmlParser<ModelDef>> ModelCache::prepareParser(String filename) {
	return std::shared_ptr<XmlParser<ModelDef>>(new Parser(ModelDef::create(), Path::getPath(filename.toString())));
}

ModelCache::Parser::Parser(ModelDef* def, String path)
	: XmlParser<ModelDef>(this, def)
	, _path(path)
	, _currentAnimationDef(nullptr) { }

KeyAnimationDef* ModelCache::Parser::getCurrentKeyAnimation() {
	if (!_currentAnimationDef) {
		_currentAnimationDef.reset(new KeyAnimationDef());
	}
	return s_cast<KeyAnimationDef*>(_currentAnimationDef.get());
}

void ModelCache::Parser::getPosFromStr(String str, float& x, float& y) {
	auto tokens = str.split(",");
	AssertUnless(tokens.size() == 2, "invalid pos str for: \"{}\"", str.toString());
	auto it = tokens.begin();
	x = it->toFloat();
	y = (++it)->toFloat();
}

void ModelCache::Parser::xmlSAX2StartElement(std::string_view name, const std::vector<std::string_view>& attrs) {
	switch (Xml::Model::Element(name[0])) {
		case Xml::Model::Element::Dorothy: {
			for (int i = 0; !attrs[i].empty(); i++) {
				switch (Xml::Model::Dorothy(attrs[i][0])) {
					case Xml::Model::Dorothy::File: {
						Slice file(attrs[++i]);
						std::string localFile = Path::concat({_path, file});
						_item->_clip = SharedContent.exist(localFile) ? localFile : file.toString();
						break;
					}
					case Xml::Model::Dorothy::Size:
						getPosFromStr(attrs[++i], _item->_size.width, _item->_size.height);
						break;
				}
			}
			break;
		}
		case Xml::Model::Element::Sprite: {
			SpriteDef* spriteDef = new SpriteDef();
			for (int i = 0; !attrs[i].empty(); i++) {
				switch (Xml::Model::Sprite(attrs[i][0])) {
					case Xml::Model::Sprite::Key:
						getPosFromStr(attrs[++i], spriteDef->anchorX, spriteDef->anchorY);
						break;
					case Xml::Model::Sprite::Opacity:
						spriteDef->opacity = s_cast<float>(std::atof(attrs[++i].data()));
						break;
					case Xml::Model::Sprite::Position:
						getPosFromStr(attrs[++i], spriteDef->x, spriteDef->y);
						break;
					case Xml::Model::Sprite::Scale:
						getPosFromStr(attrs[++i], spriteDef->scaleX, spriteDef->scaleY);
						break;
					case Xml::Model::Sprite::Rotation:
						spriteDef->rotation = s_cast<float>(std::atof(attrs[++i].data()));
						break;
					case Xml::Model::Sprite::Skew:
						getPosFromStr(attrs[++i], spriteDef->skewX, spriteDef->skewY);
						break;
					case Xml::Model::Sprite::Name:
						spriteDef->name = Slice(attrs[++i]).toString();
						break;
					case Xml::Model::Sprite::Clip:
						spriteDef->clip = Slice(attrs[++i]).toString();
						break;
					case Xml::Model::Sprite::Front:
						spriteDef->front = std::atoi(attrs[++i].data()) != 0;
						break;
				}
			}
			_nodeStack.push(MakeOwn(spriteDef));
			break;
		}
		case Xml::Model::Element::KeyFrame: {
			auto keyFrameDef = New<KeyFrameDef>();
			KeyAnimationDef* animationDef = getCurrentKeyAnimation();
			Slice duration;
			Slice position;
			Slice rotation;
			Slice scale;
			Slice skew;
			Slice opacity;
			Slice visible;
			for (int i = 0; !attrs[i].empty(); i++) {
				switch (Xml::Model::KeyFrame(attrs[i][0])) {
					case Xml::Model::KeyFrame::Duration:
						duration = attrs[++i];
						break;
					case Xml::Model::KeyFrame::Position:
						position = attrs[++i];
						break;
					case Xml::Model::KeyFrame::Rotation:
						rotation = attrs[++i];
						break;
					case Xml::Model::KeyFrame::Scale:
						scale = attrs[++i];
						break;
					case Xml::Model::KeyFrame::Skew:
						skew = attrs[++i];
						break;
					case Xml::Model::KeyFrame::Opacity:
						opacity = attrs[++i];
						break;
					case Xml::Model::KeyFrame::Visible:
						visible = attrs[++i];
						break;
					case Xml::Model::KeyFrame::EasePos:
						keyFrameDef->easePos = Ease::Enum(std::atoi(attrs[++i].data()));
						break;
					case Xml::Model::KeyFrame::EaseScale:
						keyFrameDef->easeScale = Ease::Enum(std::atoi(attrs[++i].data()));
						break;
					case Xml::Model::KeyFrame::EaseSkew:
						keyFrameDef->easeSkew = Ease::Enum(std::atoi(attrs[++i].data()));
						break;
					case Xml::Model::KeyFrame::EaseRotate:
						keyFrameDef->easeRotation = Ease::Enum(std::atoi(attrs[++i].data()));
						break;
					case Xml::Model::KeyFrame::EaseOpacity:
						keyFrameDef->easeOpacity = Ease::Enum(std::atoi(attrs[++i].data()));
						break;
					case Xml::Model::KeyFrame::Event:
						keyFrameDef->event = Slice(attrs[++i]).toString();
						_nodeStack.top()->emittingEvent = true;
						break;
				}
			}
			KeyFrameDef* lastDef = animationDef->getLastFrameDef();
			if (!duration.empty()) {
				keyFrameDef->duration = std::atoi(duration.c_str()) / 60.0f;
			} else if (lastDef) {
				keyFrameDef->duration = lastDef->duration;
			}
			if (!position.empty()) {
				getPosFromStr(position, keyFrameDef->x, keyFrameDef->y);
			} else if (lastDef) {
				keyFrameDef->x = lastDef->x;
				keyFrameDef->y = lastDef->y;
			}
			if (!rotation.empty()) {
				keyFrameDef->rotation = s_cast<float>(std::atof(rotation.c_str()));
			} else if (lastDef) {
				keyFrameDef->rotation = lastDef->rotation;
			}
			if (!scale.empty()) {
				getPosFromStr(scale, keyFrameDef->scaleX, keyFrameDef->scaleY);
			} else if (lastDef) {
				keyFrameDef->scaleX = lastDef->scaleX;
				keyFrameDef->scaleY = lastDef->scaleY;
			}
			if (!skew.empty()) {
				getPosFromStr(skew, keyFrameDef->skewX, keyFrameDef->skewY);
			} else if (lastDef) {
				keyFrameDef->skewX = lastDef->skewX;
				keyFrameDef->skewY = lastDef->skewY;
			}
			if (!opacity.empty()) {
				keyFrameDef->opacity = Math::clamp(s_cast<float>(std::atof(opacity.c_str())), 0.0f, 1.0f);
			} else if (lastDef) {
				keyFrameDef->opacity = lastDef->opacity;
			}
			if (!visible.empty()) {
				keyFrameDef->visible = std::atoi(visible.c_str()) != 0;
			} else if (lastDef) {
				keyFrameDef->visible = lastDef->visible;
			}
			animationDef->add(std::move(keyFrameDef));
			break;
		}
		case Xml::Model::Element::FrameAnimation: {
			FrameAnimationDef* frameAnimationDef = new FrameAnimationDef();
			for (int i = 0; !attrs[i].empty(); i++) {
				switch (Xml::Model::FrameAnimation(attrs[i][0])) {
					case Xml::Model::FrameAnimation::File: {
						Slice file(attrs[++i]);
						std::string localFile = Path::concat({_path, file});
						frameAnimationDef->setFile(SharedClipCache.isFileExist(localFile) ? localFile : file.toString());
						break;
					}
					case Xml::Model::FrameAnimation::Delay:
						frameAnimationDef->delay = s_cast<float>(std::atof(attrs[++i].data()));
						break;
				}
			}
			SpriteDef* nodeDef = _nodeStack.top().get();
			nodeDef->animationDefs.push_back(Own<AnimationDef>(frameAnimationDef));
			break;
		}
		case Xml::Model::Element::Look: {
			for (int i = 0; !attrs[i].empty(); i++) {
				switch (Xml::Model::Look(attrs[i][0])) {
					case Xml::Model::Look::Name: {
						SpriteDef* nodeDef = _nodeStack.top().get();
						Slice attr(attrs[++i]);
						auto tokens = attr.split(",");
						for (const auto& token : tokens) {
							nodeDef->looks.push_back(token.toInt());
						}
					} break;
				}
			}
			break;
		}
		case Xml::Model::Element::AnimationName: {
			int index = 0;
			Slice name;
			for (int i = 0; !attrs[i].empty(); i++) {
				switch (Xml::Model::AnimationName(attrs[i][0])) {
					case Xml::Model::AnimationName::Index:
						index = std::atoi(attrs[++i].data());
						break;
					case Xml::Model::AnimationName::Name:
						name = attrs[++i];
						break;
				}
			}
			_item->_animationIndex[name.toString()] = index;
			break;
		}
		case Xml::Model::Element::LookName: {
			int index = 0;
			Slice name;
			for (int i = 0; !attrs[i].empty(); i++) {
				switch (Xml::Model::LookName(attrs[i][0])) {
					case Xml::Model::LookName::Index:
						index = std::atoi(attrs[++i].data());
						break;
					case Xml::Model::LookName::Name:
						name = attrs[++i];
						break;
				}
			}
			_item->_lookIndex[name.toString()] = index;
			break;
		}
		case Xml::Model::Element::KeyPoint: {
			Slice key;
			Vec2 keyPoint{};
			for (int i = 0; !attrs[i].empty(); i++) {
				switch (Xml::Model::KeyPoint(attrs[i][0])) {
					case Xml::Model::KeyPoint::Key:
						key = attrs[++i];
						break;
					case Xml::Model::KeyPoint::Position:
						getPosFromStr(attrs[++i], keyPoint.x, keyPoint.y);
						break;
				}
			}
			_item->addKeyPoint(key, keyPoint);
			break;
		}
		case Xml::Model::Element::KeyAnimation:
			break;
	}
}

void ModelCache::Parser::xmlSAX2EndElement(std::string_view name) {
	switch (Xml::Model::Element(name[0])) {
		case Xml::Model::Element::Sprite: {
			Own<SpriteDef> nodeDef = std::move(_nodeStack.top());
			_nodeStack.pop();
			if (_nodeStack.empty()) {
				_item->setRoot(std::move(nodeDef));
			} else {
				SpriteDef* parentDef = _nodeStack.top().get();
				parentDef->children.push_back(std::move(nodeDef));
			}
			break;
		}
		case Xml::Model::Element::KeyAnimation: {
			SpriteDef* nodeDef = _nodeStack.top().get();
			nodeDef->animationDefs.push_back(std::move(_currentAnimationDef));
			break;
		}
		default:
			break;
	}
}

void ModelCache::Parser::xmlSAX2Text(std::string_view text) { }

NS_DORA_END
