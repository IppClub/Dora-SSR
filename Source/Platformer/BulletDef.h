/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN
class World;
class BodyDef;
NS_DOROTHY_END

NS_DOROTHY_PLATFORMER_BEGIN
class Face;

class BulletDef : public Object
{
public:
	void setVelocity(float angle, float speed);
	PROPERTY_REF(Vec2, Velocity);
	PROPERTY(Vec2, Gravity);
	void setHighSpeedFix(bool var);
	bool isHighSpeedFix() const;
	PROPERTY(Face*, Face);
	string tag;
	float lifeTime;
	float damageRadius;
	string endEffect;
	void setAsCircle(float radius);
	BodyDef* getBodyDef() const;
	CREATE_FUNC(BulletDef);
protected:
	BulletDef();
	Ref<BodyDef> _bodyDef;
	Ref<Face> _face;
private:
	Vec2 _velocity;
	DORA_TYPE_OVERRIDE(BulletDef);
};

NS_DOROTHY_PLATFORMER_END
