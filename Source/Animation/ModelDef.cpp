/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Animation/ModelDef.h"
#include "Node/Sprite.h"
#include "Cache/ClipCache.h"
#include "Cache/TextureCache.h"
#include "Const/XmlTag.h"
#include "Animation/Animation.h"
#include "Animation/Model.h"
#include "fmt/format.h"

NS_DOROTHY_BEGIN

/* SpriteDef */

Sprite* SpriteDef::toSprite(ClipDef* clipDef)
{
	Sprite* sprite = clipDef->toSprite(clip);
	if (!sprite) sprite = Sprite::create();
	sprite->setAnchor(Vec2{anchorX, anchorY});
	SpriteDef::restore(sprite);
	return sprite;
}

void SpriteDef::restore(Sprite* sprite)
{
	sprite->setPosition(Vec2{x, y});
	sprite->setScaleX(scaleX);
	sprite->setScaleY(scaleY);
	sprite->setAngle(rotation);
	sprite->setSkewX(skewX);
	sprite->setSkewY(skewY);
	sprite->setOpacity(opacity);
}

SpriteDef::SpriteDef():
front(true),
x(0.0f),
y(0.0f),
rotation(0.0f),
anchorX(0.5f),
anchorY(0.5f),
scaleX(1.0f),
scaleY(1.0f),
skewX(0.0f),
skewY(0.0f),
opacity(1.0f)
{ }

string SpriteDef::toXml()
{
	fmt::MemoryWriter writer;
	writer << '<' << char(Xml::Model::Element::Sprite);
	if (x != 0.0f || y != 0.0f)
	{
		writer << ' ' << char(Xml::Model::Sprite::Position) << '=';
		writer.write("\"%.2f,%.2f\"", x, y);
	}
	if (rotation != 0.0f)
	{
		writer << ' ' << char(Xml::Model::Sprite::Rotation) << '=';
		writer.write("\"%.2f\"", rotation);
	}
	if (anchorX != 0.5f || anchorY != 0.5f)
	{
		writer << ' ' << char(Xml::Model::Sprite::Key) << '=';
		writer.write("\"%.2f,%.2f\"", anchorX, anchorY);
	}
	if (scaleX != 1.0f || scaleY != 1.0f)
	{
		writer << ' ' << char(Xml::Model::Sprite::Scale) << '=';
		writer.write("\"%.2f,%.2f\"", scaleX, scaleY);
	}
	if (skewX != 0.0f || skewY != 0.0f)
	{
		writer << ' ' << char(Xml::Model::Sprite::Skew) << '=';
		writer.write("\"%.2f,%.2f\"", skewX, skewY);
	}
	if (!name.empty())
	{
		writer << ' ' << char(Xml::Model::Sprite::Name) << "=\"" << name << '\"';
	}
	if (!clip.empty())
	{
		writer << ' ' << char(Xml::Model::Sprite::Clip) << "=\"" << clip << '\"';
	}
	if (!front)
	{
		writer << ' ' << char(Xml::Model::Sprite::Front) << "=\"0\"";
	}
	writer << '>';
	for (AnimationDef* actionDef : animationDefs)
	{
		if (actionDef)
		{
			writer << actionDef->toXml();
		}
		else
		{
			writer << '<' << char(Xml::Model::Element::KeyAnimation) << "/>";
		}
	}
	if (!looks.empty())
	{
		writer << '<' << char(Xml::Model::Element::Look) << ' '
			<< char(Xml::Model::Look::Name) << "=\"";
		int lookSize = s_cast<int>(looks.size());
		int last = lookSize - 1;
		for (int i = 0; i < lookSize; i++)
		{
			writer << looks[i];
			if (i != last)
			{
				writer << ',';
			}
		}
		writer << "\"/>";
	}
	for (SpriteDef* spriteDef : children)
	{
		writer << spriteDef->toXml();
	}
	writer << "</" << char(Xml::Model::Element::Sprite) << '>';
	return writer.str();
}

std::tuple<Action*, ResetAction*> SpriteDef::toResetAction()
{
	Own<ActionDuration> resetAction = ResetAction::alloc(1.0f, this, Ease::InOutQuad);
	ResetAction* action = s_cast<ResetAction*>(resetAction.get());
	return std::make_tuple(Action::create(std::move(resetAction)), action);
}

void SpriteDef::restoreResetAnimation(Node* target, ActionDuration* action)
{
	ResetAction* resetAction = DoraCast<ResetAction>(action);
	if (resetAction)
	{
		resetAction->prepareWith(target);
		resetAction->updateEndValues(this);
	}
}

/* ModelDef */

ModelDef::ModelDef():
_isFaceRight(false)
{ }

ModelDef::ModelDef(
	bool isFaceRight,
	const Size& size,
	String clipFile,
	Own<SpriteDef>&& root,
	const unordered_map<string,Vec2>& keys,
	const unordered_map<string,int>& animationIndex,
	const unordered_map<string,int>& lookIndex):
_clip(clipFile),
_isFaceRight(isFaceRight),
_size(size),
_keys(keys),
_animationIndex(animationIndex),
_lookIndex(lookIndex),
_root(std::move(root))
{ }

const string& ModelDef::getClipFile() const
{
	return _clip;
}

void ModelDef::setRoot(Own<SpriteDef>&& root )
{
	_root = std::move(root);
}

SpriteDef* ModelDef::getRoot()
{
	return _root;
}

string ModelDef::toXml()
{
	fmt::MemoryWriter writer;
	writer << '<' << char(Xml::Model::Element::Dorothy) << ' '
		<< char(Xml::Model::Dorothy::File) << "=\"" << Slice(_clip).getFileName() << "\" ";
	if (_isFaceRight)
	{
		writer << char(Xml::Model::Dorothy::FaceRight) << "=\"1\" ";
	}
	if (_size != Size::zero)
	{
		writer << char(Xml::Model::Dorothy::Size) << '=';
		writer.write("\"%d,%d\"", s_cast<int>(_size.width), s_cast<int>(_size.height));
	}
	writer << '>' << _root->toXml();
	for (const auto& item: _animationIndex)
	{
		writer << '<' << char(Xml::Model::Element::AnimationName) << ' '
			<< char(Xml::Model::AnimationName::Index) << "=\"" << item.second << "\" "
			<< char(Xml::Model::AnimationName::Name) << "=\"" << item.first << "\"/>";
	}
	for (const auto& item: _lookIndex)
	{
		writer << '<' << char(Xml::Model::Element::LookName) << ' '
			<< char(Xml::Model::LookName::Index) << "=\"" << item.second << "\" "
			<< char(Xml::Model::LookName::Name) << "=\"" << item.first << "\"/>";
	}
	for (const auto& it : _keys)
	{
		const Vec2& point = it.second;
		writer << '<' << char(Xml::Model::Element::KeyPoint) << ' '
			<< char(Xml::Model::KeyPoint::Key) << "=\"" << it.first << "\" "
			<< char(Xml::Model::KeyPoint::Position) << '=';
		writer.write("\"%.2f,%.2f\"/>", point.x, point.y);
	}
	writer << "</" << char(Xml::Model::Element::Dorothy) << '>';
	return writer.str();
}

bool ModelDef::isFaceRight() const
{
	return _isFaceRight;
}

int ModelDef::getAnimationIndexByName(String name)
{
	auto it = _animationIndex.find(name);
	if (it != _animationIndex.end())
	{
		return it->second;
	}
	return Animation::None;
}

const string& ModelDef::getAnimationNameByIndex(int index)
{
	for (const auto& item : _animationIndex)
	{
		if (item.second == index)
		{
			return item.first;
		}
	}
	return Slice::Empty;
}

int ModelDef::getLookIndexByName(String name)
{
	auto it = _lookIndex.find(name);
	if (it != _lookIndex.end())
	{
		return it->second;
	}
	return Look::None;
}

const unordered_map<string, int>& ModelDef::getAnimationIndexMap() const
{
	return _animationIndex;
}

const unordered_map<string, int>& ModelDef::getLookIndexMap() const
{
	return _lookIndex;
}

void ModelDef::setActionName(int index, String name)
{
	_animationIndex[name] = index;
}

void ModelDef::setLookName(int index, String name)
{
	_lookIndex[name] = index;
}

void ModelDef::addKeyPoint(String key, const Vec2& point)
{
	ModelDef::getKeyPoints()[key] = point;
}

Vec2 ModelDef::getKeyPoint(String key) const
{
	auto it = _keys.find(key);
	return it != _keys.end() ? it->second : Vec2::zero;
}

unordered_map<string,Vec2>& ModelDef::getKeyPoints()
{
	return _keys;
}

ModelDef* ModelDef::create()
{
	ModelDef* modelDef = new ModelDef();
	modelDef->autorelease();
	return modelDef;
}

const Size& ModelDef::getSize() const
{
	return _size;
}

vector<string> ModelDef::getLookNames() const
{
	vector<string> names(_lookIndex.size());
	for (const auto& it : _lookIndex)
	{
		names[it.second] = it.first;
	}
	return names;
}

vector<string> ModelDef::getAnimationNames() const
{
	vector<string> names(_animationIndex.size());
	for (const auto& it : _animationIndex)
	{
		names[it.second] = it.first;
	}
	return names;
}

string ModelDef::getTextureFile() const
{
	return SharedClipCache.load(_clip)->textureFile;
}

NS_DOROTHY_END
