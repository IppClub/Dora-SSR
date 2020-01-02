/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Platformer/Define.h"
#include "Support/Array.h"
#include "Physics/Sensor.h"
#include "Platformer/AINode.h"
#include "Platformer/AI.h"
#include "Platformer/Unit.h"
#include "Platformer/Data.h"
#include "Physics/Sensor.h"
#include "Entity/Entity.h"
#include <numeric>

NS_DOROTHY_PLATFORMER_BEGIN

AI::AI():
_nearestUnit(nullptr),
_nearestFriend(nullptr),
_nearestEnemy(nullptr),
_nearestNeutral(nullptr),
_nearestUnitDistance(0),
_nearestFriendDistance(0),
_nearestEnemyDistance(0),
_nearestNeutralDistance(0),
_friends(Array::create()),
_enemies(Array::create()),
_neutrals(Array::create()),
_detectedUnits(Array::create())
{ }

vector<Slice>& AI::getDecisionNodes()
{
	return _decisionNodes;
}

Unit* AI::getSelf()
{
	return _self;
}

bool AI::runDecisionTree(Unit* unit)
{	
	AILeaf* decisionTree = unit->getDecisionTree();
	if (!decisionTree)
	{
		return false;
	}

	_self = unit;

	_nearestUnit = nullptr;
	_nearestFriend = nullptr;
	_nearestEnemy = nullptr;
	_nearestNeutral = nullptr;

	float minUnitDistance = 0;
	float minFriendDistance = 0;
	float minEnemyDistance = 0;
	float minNeutralDistance = 0;

	Sensor* sensor = unit->getDetectSensor();
	if (sensor)
	{
		ARRAY_START(Body, body, sensor->getSensedBodies())
		{
			Unit* aroundUnit = DoraCast<Unit>(body->getOwner());
			if (!aroundUnit) continue;

			_detectedUnits->add(aroundUnit);

			float newDistance = unit->getPosition().distanceSquared(aroundUnit->getPosition());

			if (!_nearestUnit || newDistance < minUnitDistance)
			{
				minUnitDistance = newDistance;
				_nearestUnit = aroundUnit;
			}
			Relation relation = SharedData.getRelation(_self, aroundUnit);
			switch (relation)
			{
			case Relation::Friend:
				_friends->add(aroundUnit);
				if (!_nearestFriend || newDistance < minFriendDistance)
				{
					minFriendDistance = newDistance;
					_nearestFriend = aroundUnit;
				}
				break;
			case Relation::Enemy:
				_enemies->add(aroundUnit);
				if (!_nearestEnemy || newDistance < minEnemyDistance)
				{
					minEnemyDistance = newDistance;
					_nearestEnemy = aroundUnit;
				}
				break;
			case Relation::Neutral:
				_neutrals->add(aroundUnit);
				if (!_nearestNeutral || newDistance < minNeutralDistance)
				{
					minNeutralDistance = newDistance;
					_nearestNeutral = aroundUnit;
				}
				break;
			default:
				break;
			}
		}
		ARRAY_END
		_nearestUnitDistance = std::sqrt(minUnitDistance);
		_nearestFriendDistance = std::sqrt(minFriendDistance);
		_nearestEnemyDistance = std::sqrt(minEnemyDistance);
		_nearestNeutralDistance = std::sqrt(minNeutralDistance);
	}

	bool result = false;
	if (_self->isReceivingDecisionTrace())
	{
		result = decisionTree->doAction(_self);
		if (_decisionNodes.empty())
		{
			_self->getEntity()->set("decisionTrace"_slice, "do nothing"_slice.toString());
		}
		else if (!_decisionNodes.empty())
		{
			_self->getEntity()->set("decisionTrace"_slice,
				std::accumulate(_decisionNodes.begin()+1, _decisionNodes.end(), _decisionNodes.front().toString(),
				[](const string& a, String b) { return a + " -> " + b; }));
			_decisionNodes.clear();
		}
	}
	else result = decisionTree->doAction(_self);

	_friends->clear();
	_enemies->clear();
	_neutrals->clear();
	_detectedUnits->clear();
	_self = nullptr;

	return result;
}

Array* AI::getUnitsByRelation(Relation relation)
{
	Array* units = _detectedUnits;
	switch (relation)
	{
		case Relation::Friend:
			units = _friends;
			break;
		case Relation::Enemy:
			units = _enemies;
			break;
		case Relation::Neutral:
			units = _neutrals;
			break;
		default:
			break;
	}
	return units;
}

Array* AI::getDetectedUnits()
{
	return _detectedUnits;
}

Unit* AI::getNearestUnit(Relation relation)
{
	switch (relation)
	{
		case Relation::Friend:
			return _nearestFriend;
		case Relation::Enemy:
			return _nearestEnemy;
		case Relation::Neutral:
			return _nearestNeutral;
		default:
			return _nearestUnit;
	}
}

float AI::getNearestUnitDistance(Relation relation)
{
	switch (relation)
	{
	case Relation::Friend:
		return _nearestFriendDistance;
	case Relation::Enemy:
		return _nearestEnemyDistance;
	case Relation::Neutral:
		return _nearestNeutralDistance;
	default:
		return _nearestUnitDistance;
	}
}

Array* AI::getUnitsInAttackRange() const
{
	Sensor* sensor = _self->getAttackSensor();
	return sensor ? sensor->getSensedBodies() : nullptr;
}

NS_DOROTHY_PLATFORMER_END
