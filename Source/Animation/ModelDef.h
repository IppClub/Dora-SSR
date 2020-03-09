/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Support/Geometry.h"

NS_DOROTHY_BEGIN

class AnimationDef;
class Action;
class ResetAction;
class ActionDuration;
class Sprite;
class ClipDef;
class Node;

class SpriteDef
{
public:
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
	string name;
	string clip;

	OwnVector<SpriteDef> children;
	OwnVector<AnimationDef> animationDefs;
	vector<int> looks;

	SpriteDef();
	void restore(Sprite* sprite);
	/**
	 @brief get a new reset animation to restore a node before playing a new animation
	 returns an animation of Spawn with an array of
	 [KeyPos,KeyScale,KeyRoll,KeySkew,KeyOpacity] instances that compose the Spawn instance.
	 or returns an animation of Hide with nullptr.
	*/
	std::tuple<Action*,ResetAction*> toResetAction();
	Sprite* toSprite(ClipDef* clipDef);
	string toXml();

	void restoreResetAnimation(Node* target, ActionDuration* action);

	template<typename NodeFunc>
	static void traverse(SpriteDef* root, const NodeFunc& func)
	{
		func(root);
		const OwnVector<SpriteDef>& childrenDef = root->children;
		for (const auto& childDef : childrenDef)
		{
			SpriteDef::traverse(childDef.get(), func);
		}
	}
};

class Model;

/** @brief Data define for a 2D model. */
class ModelDef : public Object
{
public:
	ModelDef();
	ModelDef(
		bool isFaceRight,
		const Size& size,
		String clipFile,
		Own<SpriteDef>&& root,
		const unordered_map<string,Vec2>& keys,
		const unordered_map<string,int>& animationIndex,
		const unordered_map<string,int>& lookIndex);
	const string& getClipFile() const;
	SpriteDef* getRoot();
	void addKeyPoint(String key, const Vec2& point);
	Vec2 getKeyPoint(String key) const;
	unordered_map<string,Vec2>& getKeyPoints();
	bool isFaceRight() const;
	const Size& getSize() const;
	void setActionName(int index, String name);
	void setLookName(int index, String name);
	int getAnimationIndexByName(String name);
	const string& getAnimationNameByIndex(int index);
	int getLookIndexByName(String name);
	const unordered_map<string, int>& getAnimationIndexMap() const;
	const unordered_map<string, int>& getLookIndexMap() const;
	vector<string> getLookNames() const;
	vector<string> getAnimationNames() const;
	string getTextureFile() const;
	string toXml();
	static ModelDef* create();
private:
	void setRoot(Own<SpriteDef>&& root);
	bool _isFaceRight;
	Size _size;
	Own<SpriteDef> _root;
	string _clip;
	unordered_map<string,int> _animationIndex;
	unordered_map<string,int> _lookIndex;
	unordered_map<string,Vec2> _keys;
	friend class ModelCache;
};

NS_DOROTHY_END
