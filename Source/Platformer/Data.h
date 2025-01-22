/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DORA_BEGIN
class PhysicsWorld;
class Dictionary;
class Body;
NS_DORA_END

NS_DORA_PLATFORMER_BEGIN

class Unit;

class Data : public NonCopyable {
public:
	PROPERTY_READONLY(uint8_t, GroupFirstPlayer);
	PROPERTY_READONLY(uint8_t, GroupLastPlayer);
	PROPERTY_READONLY(uint8_t, GroupHide);
	PROPERTY_READONLY(uint8_t, GroupDetectPlayer);
	PROPERTY_READONLY(uint8_t, GroupTerrain);
	PROPERTY_READONLY(uint8_t, GroupDetection);
	PROPERTY_READONLY(Dictionary*, Store);
	~Data();
	void apply(PhysicsWorld* world);
	void setRelation(uint8_t groupA, uint8_t groupB, Relation relation);
	Relation getRelation(uint8_t groupA, uint8_t groupB) const;
	Relation getRelation(Body* bodyA, Body* bodyB) const;
	bool isEnemy(uint8_t groupA, uint8_t groupB) const;
	bool isEnemy(Body* bodyA, Body* bodyB) const;
	bool isFriend(uint8_t groupA, uint8_t groupB) const;
	bool isFriend(Body* bodyA, Body* bodyB) const;
	bool isNeutral(uint8_t groupA, uint8_t groupB) const;
	bool isNeutral(Body* bodyA, Body* bodyB) const;
	void setShouldContact(uint8_t groupA, uint8_t groupB, bool contact);
	bool getShouldContact(uint8_t groupA, uint8_t groupB) const;
	void setDamageFactor(uint16_t damageType, uint16_t defenceType, float bounus);
	float getDamageFactor(uint16_t damageType, uint16_t defenceType) const;
	bool isPlayer(Body* body);
	bool isTerrain(Body* body);
	void clear();
	SINGLETON_REF(Data, Director);

protected:
	Data();

private:
	std::unordered_map<uint16_t, bool> _contactMap;
	std::unordered_map<uint16_t, Relation> _relationMap;
	std::unordered_map<uint32_t, float> _damageBounusMap;
	Ref<Dictionary> _store;
};

#define SharedData \
	Dora::Singleton<Dora::Platformer::Data>::shared()

NS_DORA_PLATFORMER_END
