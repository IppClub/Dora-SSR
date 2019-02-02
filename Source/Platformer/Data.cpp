/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Platformer/Define.h"
#include "Platformer/Unit.h"
#include "Platformer/UnitAction.h"
#include "Platformer/Data.h"
#include "Physics/PhysicsWorld.h"
#include "Physics/Body.h"
#include "Support/Dictionary.h"
#include "Basic/Application.h"

NS_DOROTHY_PLATFORMER_BEGIN

Data::Data():
_store(Dictionary::create())
{
	SharedApplication.quitHandler += [this]()
	{
		clear();
		UnitAction::clear();
	};
}

//Group [0] for hide
//Group [1 - 28] for player
//Group [29] for player sensor
//Group [30] for terrain
//Group [31] for sense all
#define Hide 0
#define P1 1
#define P28 28
#define PSensor 29
#define Terrain 30
#define SenseAll 31

void Data::apply(PhysicsWorld* world)
{
	for (int p = P1; p <= P28; p++)
	{
		world->setShouldContact(PSensor, p, true);
		world->setShouldContact(Terrain, p, true);
		world->setShouldContact(SenseAll, p, true);
		world->setShouldContact(Hide, p, false);
	}
	world->setShouldContact(Hide, PSensor, false);
	world->setShouldContact(Hide, SenseAll, false);
	world->setShouldContact(Hide, Terrain, true);
	world->setShouldContact(PSensor, Terrain, true);
	world->setShouldContact(Terrain, Terrain, true);
	world->setShouldContact(SenseAll, Terrain, true);
	for (auto it : _contactMap)
	{
		Uint8 groupA = it.first >> 8;
		Uint8 groupB = it.first & 0xff;
		world->setShouldContact(groupA, groupB, it.second);
	}
}

void Data::setRelation(Uint8 groupA, Uint8 groupB, Relation relation)
{
	Uint16 key = groupA<<8 | groupB;
	_relationMap[key] = relation;
	key = groupA | groupB<<8;
	_relationMap[key] = relation;
}

Relation Data::getRelation(Uint8 groupA, Uint8 groupB) const
{
	if (groupA == groupB) return Relation::Friend;
	Uint16 key = groupA<<8 | groupB;
	auto it = _relationMap.find(key);
	return it != _relationMap.end() ? it->second : Relation::Unkown;
}

Relation Data::getRelation(Body* bodyA, Body* bodyB) const
{
	return Data::getRelation(bodyA->getGroup(), bodyB->getGroup());
}

void Data::setShouldContact(Uint8 groupA, Uint8 groupB, bool contact)
{
	Uint16 key = groupA<<8 | groupB;
	_contactMap[key] = contact;
	key = groupA | groupB<<8;
	_contactMap[key] = contact;
}

bool Data::getShouldContact(Uint8 groupA, Uint8 groupB) const
{
	Uint16 key = groupA<<8 | groupB;
	auto it = _contactMap.find(key);
	return it != _contactMap.end() ? it->second : false;
}

Uint8 Data::getGroupDetectPlayer() const
{
	return PSensor;
}

Uint8 Data::getGroupTerrain() const
{
	return Terrain;
}

Uint8 Data::getGroupDetection() const
{
	return SenseAll;
}

Uint8 Data::getGroupHide() const
{
	return Hide;
}

void Data::setDamageFactor(Uint16 damageType, Uint16 defenceType, float bounus)
{
	Uint32 key = damageType | defenceType<<16;
	_damageBounusMap[key] = bounus;
}

float Data::getDamageFactor(Uint16 damageType, Uint16 defenceType) const
{
	Uint32 key = damageType | defenceType<<16;
	unordered_map<Uint32, float>::const_iterator it = _damageBounusMap.find(key);
	if (it != _damageBounusMap.end())
	{
		return it->second;
	}
	return 0.0f;
}

bool Data::isPlayer(Body* body)
{
	Sint16 index = body->getGroup();
	return P1 <= index && index <= P28;
}

bool Data::isTerrain(Body* body)
{
	return body->getGroup() == Data::getGroupTerrain();
}

Dictionary* Data::getStore() const
{
	return _store;
}

void Data::clear()
{
	_contactMap.clear();
	_relationMap.clear();
	_damageBounusMap.clear();
	_store->clear();
}

NS_DOROTHY_PLATFORMER_END
