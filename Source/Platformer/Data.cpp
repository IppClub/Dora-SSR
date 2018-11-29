/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Platformer/Define.h"
#include "Platformer/Unit.h"
#include "Platformer/Data.h"
#include "Physics/PhysicsWorld.h"
#include "Physics/Body.h"
#include "Support/Dictionary.h"

NS_DOROTHY_PLATFORMER_BEGIN

Data::Data():
_cache(Dictionary::create())
{ }

//Group [0] for hide
//Group [1,2,3,4,5,6,7,8,9,10,11,12] for player
//Group [13] for player sensor
//Group [14] for terrain
//Group [15] for sense all
#define Hide 0
#define P1 1
#define P12 12
#define PSensor 13
#define Terrain 14
#define SenseAll 15

void Data::apply(PhysicsWorld* world)
{
	for (int p = P1;p <= P12;p++)
	{
		world->setShouldContact(PSensor, p, true);
		world->setShouldContact(Terrain, p, true);
		world->setShouldContact(SenseAll, p, true);
		world->setShouldContact(Hide, p, false);
	}
	world->setShouldContact(Hide, PSensor, false);
	world->setShouldContact(Hide, SenseAll, false);
	world->setShouldContact(Hide, Terrain, true);
	world->setShouldContact(SenseAll, Terrain, true);
}

void Data::setRelation(int groupA, int groupB, Relation relation)
{
	int key = groupA<<16 | groupB;
	_relationMap[key] = relation;
	key = groupB | groupA<<16;
	_relationMap[key] = relation;
}

Relation Data::getRelation(int groupA, int groupB) const
{
	if (groupA == groupB) return Relation::Friend;
	int key = groupA<<16 | groupB;
	auto it = _relationMap.find(key);
	return it != _relationMap.end() ? it->second : Relation::Unkown;
}

Relation Data::getRelation(Unit* unitA, Unit* unitB) const
{
	return Data::getRelation(unitA->getGroup(), unitB->getGroup());
}

int Data::getGroupDetectPlayer() const
{
	return PSensor;
}

int Data::getGroupTerrain() const
{
	return Terrain;
}

int Data::getGroupDetection() const
{
	return SenseAll;
}

int Data::getGroupHide() const
{
	return Hide;
}

void Data::setDamageFactor(Uint16 damageType, Uint16 defenceType, float bounus)
{
	uint32 key = damageType | defenceType<<16;
	_damageBounusMap[key] = bounus;
}

float Data::getDamageFactor(Uint16 damageType, Uint16 defenceType) const
{
	uint32 key = damageType | defenceType<<16;
	unordered_map<uint32, float>::const_iterator it = _damageBounusMap.find(key);
	if (it != _damageBounusMap.end())
	{
		return it->second;
	}
	return 0.0f;
}

bool Data::isPlayer(Body* body)
{
	int16 index = body->getGroup();
	return P1 <= index && index <= P12;
}

bool Data::isTerrain(Body* body)
{
	return body->getGroup() == Data::getGroupTerrain();
}

Dictionary* Data::getCache() const
{
	return _cache;
}

NS_DOROTHY_PLATFORMER_END
