/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Physics/Body.h"

NS_DORA_BEGIN
class World;
NS_DORA_END

NS_DORA_PLATFORMER_BEGIN
class Unit;
class BulletDef;
class Bullet;

typedef Acf::Delegate<bool(Bullet* bullet, Unit* target, Vec2 point, Vec2 normal)> BulletHandler;

class Bullet : public Body {
public:
	PROPERTY_READONLY(Unit*, Emitter);
	PROPERTY(uint32_t, TargetAllow);
	PROPERTY_BOOL(FaceRight);
	PROPERTY_BOOL(HitStop);
	PROPERTY(Node*, Face);
	virtual bool init() override;
	virtual bool update(double deltaTime) override;
	void onBodyContact(Body* body, Vec2 point, Vec2 normal, bool enabled);
	BulletDef* getBulletDef();
	TargetAllow targetAllow;
	BulletHandler hitTarget;
	void destroy();
	CREATE_FUNC_NOT_NULL(Bullet);
	struct Def {
		static const Slice BulletKey;
	};

protected:
	Bullet(NotNull<BulletDef, 1> def, NotNull<Unit, 2> unit);
	virtual void updatePhysics() override;

private:
	enum : Flag::ValueType {
		FaceRight = BodyUserFlag,
		HitStop = BodyUserFlag << 1,
	};
	Node* _face;
	Ref<BulletDef> _bulletDef;
	Ref<Unit> _emitter;
	float _lifeTime;
	float _current;
	DORA_TYPE_OVERRIDE(Bullet)
};

NS_DORA_PLATFORMER_END
