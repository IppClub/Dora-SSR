/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Physics/Body.h"

NS_DOROTHY_BEGIN
class World;
NS_DOROTHY_END

NS_DOROTHY_PLATFORMER_BEGIN

class Unit;
class BulletDef;
class Bullet;

typedef Delegate<bool (Bullet* bullet, Unit* target, Vec2 point)> BulletHandler;

class Bullet : public Body
{
public:
	PROPERTY_READONLY(Unit*, Owner);
	PROPERTY_BOOL(FaceRight);
	PROPERTY_BOOL(HitStop);
	PROPERTY(Node*, Face);
	virtual bool init() override;
	virtual bool update(double deltaTime) override;
	void onBodyContact(Body* body, Vec2 point, Vec2 normal);
	BulletDef* getBulletDef();
	TargetAllow targetAllow;
	BulletHandler hitTarget;
	void destroy();
	CREATE_FUNC(Bullet);
	struct Def
	{
		static const Slice BulletKey;
	};
protected:
	Bullet(BulletDef* def, Unit* unit);
	virtual void updatePhysics() override;
private:
	enum
	{
		FaceRight = BodyUserFlag,
		HitStop = BodyUserFlag << 1,
	};
	Node* _face;
	Ref<BulletDef> _bulletDef;
	Ref<Unit> _owner;
	float _lifeTime;
	float _current;
	DORA_TYPE_OVERRIDE(Bullet)
};

NS_DOROTHY_PLATFORMER_END
