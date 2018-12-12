/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Platformer/AINode.h"

NS_DOROTHY_BEGIN
class Array;
NS_DOROTHY_END

NS_DOROTHY_PLATFORMER_BEGIN

class Unit;

class AI
{
public:
	PROPERTY_READONLY_CALL(vector<Slice>&, DecisionNodes);
	bool runDecisionTree(Unit* unit);
	Unit* getSelf();
	Array* getUnitsByRelation(Relation relation);
	Array* getDetectedUnits();
	Unit* getNearestUnit(Relation relation);
	Array* getUnitsInAttackRange() const;
	float getNearestUnitDistance(Relation relation);
	SINGLETON_REF(AI, Data, Director);
protected:
	AI();
private:
	Ref<Unit> _self;
	Unit* _nearestUnit;
	Unit* _nearestFriend;
	Unit* _nearestEnemy;
	Unit* _nearestNeutral;
	Ref<Array> _friends;
	Ref<Array> _enemies;
	Ref<Array> _neutrals;
	Ref<Array> _detectedUnits;
	float _nearestUnitDistance;
	float _nearestFriendDistance;
	float _nearestEnemyDistance;
	float _nearestNeutralDistance;
	unordered_map<string, Ref<AILeaf>> _decisionTrees;
	vector<Slice> _decisionNodes;
	friend class Instinct;
};

#define SharedAI \
	Dorothy::Singleton<Dorothy::Platformer::AI>::shared()

NS_DOROTHY_PLATFORMER_END
