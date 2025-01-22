/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Platformer/AINode.h"

NS_DORA_BEGIN
class Array;
NS_DORA_END

NS_DORA_PLATFORMER_BEGIN
class Unit;

NS_DECISION_BEGIN
class AI : public NonCopyable {
public:
	PROPERTY_READONLY_CALL(std::vector<Slice>&, DecisionNodes);
	bool runDecisionTree(Unit* unit);
	Unit* getSelf() const;
	Array* getUnitsByRelation(Relation relation) const;
	Array* getDetectedUnits() const;
	Array* getDetectedBodies() const;
	Unit* getNearestUnit(Relation relation) const;
	Array* getUnitsInAttackRange() const;
	Array* getBodiesInAttackRange() const;
	float getNearestUnitDistance(Relation relation) const;
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
	Ref<Array> _attackUnits;
	float _nearestUnitDistance;
	float _nearestFriendDistance;
	float _nearestEnemyDistance;
	float _nearestNeutralDistance;
	std::vector<Slice> _decisionNodes;
	friend class Instinct;
};

#define SharedAI \
	Dora::Singleton<Dora::Platformer::Decision::AI>::shared()

NS_DECISION_END

NS_DORA_PLATFORMER_END
