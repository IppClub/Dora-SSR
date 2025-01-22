/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Platformer/Define.h"

#include "Platformer/Data.h"

#include "Basic/Application.h"
#include "Physics/Body.h"
#include "Physics/PhysicsWorld.h"
#include "Platformer/Unit.h"
#include "Platformer/UnitAction.h"
#include "Support/Dictionary.h"

NS_DORA_PLATFORMER_BEGIN

Data::Data()
	: _store(Dictionary::create()) {
	SharedApplication.quitHandler += [this]() {
		clear();
		UnitAction::clear();
	};
}

Data::~Data() {
	clear();
}

#define Hide 0
#define FP 1
#define LP PhysicsWorld::TotalGroups - 4
#define PSensor PhysicsWorld::TotalGroups - 3
#define Terrain PhysicsWorld::TotalGroups - 2
#define SenseAll PhysicsWorld::TotalGroups - 1

void Data::apply(PhysicsWorld* world) {
	for (int p = FP; p <= LP; p++) {
		world->setShouldContact(PSensor, p, true);
		world->setShouldContact(Terrain, p, true);
		world->setShouldContact(SenseAll, p, true);
		world->setShouldContact(Hide, p, false);
		world->setShouldContact(p, p, false);
	}
	world->setShouldContact(Hide, Hide, false);
	world->setShouldContact(Hide, PSensor, false);
	world->setShouldContact(Hide, SenseAll, false);
	world->setShouldContact(Hide, Terrain, true);
	world->setShouldContact(PSensor, Terrain, true);
	world->setShouldContact(Terrain, Terrain, true);
	world->setShouldContact(SenseAll, Terrain, true);
	for (auto it : _contactMap) {
		uint8_t groupA = it.first >> 8;
		uint8_t groupB = it.first & 0xff;
		world->setShouldContact(groupA, groupB, it.second);
	}
}

void Data::setRelation(uint8_t groupA, uint8_t groupB, Relation relation) {
	uint16_t key = groupA << 8 | groupB;
	_relationMap[key] = relation;
	key = groupA | groupB << 8;
	_relationMap[key] = relation;
}

Relation Data::getRelation(uint8_t groupA, uint8_t groupB) const {
	if (groupA == groupB) return Relation::Friend;
	uint16_t key = groupA << 8 | groupB;
	auto it = _relationMap.find(key);
	return it != _relationMap.end() ? it->second : Relation::Unknown;
}

Relation Data::getRelation(Body* bodyA, Body* bodyB) const {
	if (!bodyA || !bodyB) return Relation::Unknown;
	return Data::getRelation(bodyA->getGroup(), bodyB->getGroup());
}

bool Data::isEnemy(uint8_t groupA, uint8_t groupB) const {
	return getRelation(groupA, groupB) == Relation::Enemy;
}

bool Data::isEnemy(Body* bodyA, Body* bodyB) const {
	return getRelation(bodyA, bodyB) == Relation::Enemy;
}

bool Data::isFriend(uint8_t groupA, uint8_t groupB) const {
	return getRelation(groupA, groupB) == Relation::Enemy;
}

bool Data::isFriend(Body* bodyA, Body* bodyB) const {
	return getRelation(bodyA, bodyB) == Relation::Friend;
}

bool Data::isNeutral(uint8_t groupA, uint8_t groupB) const {
	return getRelation(groupA, groupB) == Relation::Neutral;
}

bool Data::isNeutral(Body* bodyA, Body* bodyB) const {
	return getRelation(bodyA, bodyB) == Relation::Neutral;
}

void Data::setShouldContact(uint8_t groupA, uint8_t groupB, bool contact) {
	uint16_t key = groupA << 8 | groupB;
	_contactMap[key] = contact;
	key = groupA | groupB << 8;
	_contactMap[key] = contact;
}

bool Data::getShouldContact(uint8_t groupA, uint8_t groupB) const {
	uint16_t key = groupA << 8 | groupB;
	auto it = _contactMap.find(key);
	return it != _contactMap.end() ? it->second : false;
}

uint8_t Data::getGroupFirstPlayer() const noexcept {
	return FP;
}

uint8_t Data::getGroupLastPlayer() const noexcept {
	return LP;
}

uint8_t Data::getGroupDetectPlayer() const noexcept {
	return PSensor;
}

uint8_t Data::getGroupTerrain() const noexcept {
	return Terrain;
}

uint8_t Data::getGroupDetection() const noexcept {
	return SenseAll;
}

uint8_t Data::getGroupHide() const noexcept {
	return Hide;
}

void Data::setDamageFactor(uint16_t damageType, uint16_t defenceType, float bounus) {
	uint32_t key = damageType | defenceType << 16;
	_damageBounusMap[key] = bounus;
}

float Data::getDamageFactor(uint16_t damageType, uint16_t defenceType) const {
	uint32_t key = damageType | defenceType << 16;
	std::unordered_map<uint32_t, float>::const_iterator it = _damageBounusMap.find(key);
	if (it != _damageBounusMap.end()) {
		return it->second;
	}
	return 0.0f;
}

bool Data::isPlayer(Body* body) {
	if (!body) return false;
	int16_t index = body->getGroup();
	return FP <= index && index <= LP;
}

bool Data::isTerrain(Body* body) {
	if (!body) return false;
	return body->getGroup() == Data::getGroupTerrain();
}

Dictionary* Data::getStore() const noexcept {
	return _store;
}

void Data::clear() {
	_contactMap.clear();
	_relationMap.clear();
	_damageBounusMap.clear();
	_store->each([](Value* value, const std::string& key) {
		if (auto dict = value->as<Dictionary>()) {
			dict->clear();
		}
		return false;
	});
	_store->clear();
}

NS_DORA_PLATFORMER_END
