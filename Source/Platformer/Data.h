/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN
class PhysicsWorld;
class Dictionary;
NS_DOROTHY_END

NS_DOROTHY_PLATFORMER_BEGIN

class Unit;

class Data
{
public:
	PROPERTY_READONLY(Uint8, GroupHide);
	PROPERTY_READONLY(Uint8, GroupDetectPlayer);
	PROPERTY_READONLY(Uint8, GroupTerrain);
	PROPERTY_READONLY(Uint8, GroupDetection);
	PROPERTY_READONLY(Dictionary*, Store);
	void apply(PhysicsWorld* world);
	void setRelation(Uint8 groupA, Uint8 groupB, Relation relation);
	Relation getRelation(Uint8 groupA, Uint8 groupB) const;
	Relation getRelation(Body* bodyA, Body* bodyB) const;
	bool isEnemy(Uint8 groupA, Uint8 groupB) const;
	bool isEnemy(Body* bodyA, Body* bodyB) const;
	bool isFriend(Uint8 groupA, Uint8 groupB) const;
	bool isFriend(Body* bodyA, Body* bodyB) const;
	bool isNeutral(Uint8 groupA, Uint8 groupB) const;
	bool isNeutral(Body* bodyA, Body* bodyB) const;
	void setShouldContact(Uint8 groupA, Uint8 groupB, bool contact);
	bool getShouldContact(Uint8 groupA, Uint8 groupB) const;
	void setDamageFactor(Uint16 damageType, Uint16 defenceType, float bounus);
	float getDamageFactor(Uint16 damageType, Uint16 defenceType) const;
	bool isPlayer(Body* body);
	bool isTerrain(Body* body);
	void clear();
	SINGLETON_REF(Data, Director);
protected:
	Data();
private:
	unordered_map<Uint16, bool> _contactMap;
	unordered_map<Uint16, Relation> _relationMap;
	unordered_map<Uint32, float> _damageBounusMap;
	Ref<Dictionary> _store;
};

#define SharedData \
	Dorothy::Singleton<Dorothy::Platformer::Data>::shared()

NS_DOROTHY_PLATFORMER_END
