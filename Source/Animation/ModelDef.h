/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Support/Geometry.h"

NS_DORA_BEGIN

class AnimationDef;
class Action;
class ResetAction;
class ActionDuration;
class Sprite;
class ClipDef;
class Node;

class SpriteDef {
public:
	bool emittingEvent;
	bool front;
	float x;
	float y;
	float rotation;
	float anchorX;
	float anchorY;
	float scaleX;
	float scaleY;
	float skewX;
	float skewY;
	float opacity;
	std::string name;
	std::string clip;

	OwnVector<SpriteDef> children;
	OwnVector<AnimationDef> animationDefs;
	std::vector<int> looks;

	SpriteDef();
	void restore(Sprite* sprite);
	/**
	 @brief get a new reset animation to restore a node before playing a new animation
	 returns an animation of Spawn with an array of
	 [KeyPos,KeyScale,KeyRoll,KeySkew,KeyOpacity] instances that compose the Spawn instance.
	 or returns an animation of Hide with nullptr.
	*/
	std::tuple<Action*, ResetAction*> toResetAction();
	Sprite* toSprite(ClipDef* clipDef);
	std::string toXml();

	void restoreResetAnimation(Node* target, ActionDuration* action);

	template <typename NodeFunc>
	static void traverse(SpriteDef* root, const NodeFunc& func) {
		func(root);
		const OwnVector<SpriteDef>& childrenDef = root->children;
		for (const auto& childDef : childrenDef) {
			SpriteDef::traverse(childDef.get(), func);
		}
	}
};

class Model;

/** @brief Data define for a 2D model. */
class ModelDef : public Object {
public:
	ModelDef();
	ModelDef(
		const Size& size,
		String clipFile,
		Own<SpriteDef>&& root,
		const StringMap<Vec2>& keys,
		const StringMap<int>& animationIndex,
		const StringMap<int>& lookIndex);
	const std::string& getClipFile() const;
	SpriteDef* getRoot();
	void addKeyPoint(String key, const Vec2& point);
	Vec2 getKeyPoint(String key) const;
	StringMap<Vec2>& getKeyPoints();
	const Size& getSize() const;
	void setActionName(int index, String name);
	void setLookName(int index, String name);
	int getAnimationIndexByName(String name);
	const std::string& getAnimationNameByIndex(int index);
	int getLookIndexByName(String name);
	const StringMap<int>& getAnimationIndexMap() const;
	const StringMap<int>& getLookIndexMap() const;
	std::vector<std::string> getLookNames() const;
	std::vector<std::string> getAnimationNames() const;
	std::string getTextureFile() const;
	std::string toXml();
	CREATE_FUNC_NOT_NULL(ModelDef);

private:
	void setRoot(Own<SpriteDef>&& root);
	Size _size;
	Own<SpriteDef> _root;
	std::string _clip;
	StringMap<int> _animationIndex;
	StringMap<int> _lookIndex;
	StringMap<Vec2> _keys;
	friend class ModelCache;
};

NS_DORA_END
