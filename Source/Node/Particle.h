/* Copyright (c) 2020 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node.h"
#include "Node/Sprite.h"

NS_DOROTHY_BEGIN

enum struct EmitterMode
{
	Gravity,
	Radius
};

class ParticleDef : public Object
{
public:
	float angle;
	float angleVariance;
	Uint32 blendFuncDestination;
	Uint32 blendFuncSource;
	float duration;
	float emissionRate;
	Vec4 finishColor;
	Vec4 finishColorVariance;
	float rotationStart;
	float rotationStartVariance;
	float rotationEnd;
	float rotationEndVariance;
	float finishParticleSize;
	float finishParticleSizeVariance;
	Uint32 maxParticles;
	float particleLifespan;
	float particleLifespanVariance;
	Vec2 startPosition;
	Vec2 startPositionVariance;
	Vec4 startColor;
	Vec4 startColorVariance;
	float startParticleSize;
	float startParticleSizeVariance;
	EmitterMode emitterMode;
	union
	{
		struct
		{
			bool rotationIsDir;
			Vec2 gravity;
			float speed;
			float speedVariance;
			float radialAcceleration;
			float radialAccelVariance;
			float tangentialAcceleration;
			float tangentialAccelVariance;
		} gravity;
		struct
		{
			float startRadius;
			float startRadiusVariance;
			float finishRadius;
			float finishRadiusVariance;
			float rotatePerSecond;
			float rotatePerSecondVariance;
		} radius;
	} mode;
	string textureName;
	Rect textureRect;
	string toXml() const;
	static ParticleDef* fire();
	CREATE_FUNC(ParticleDef);
protected:
	ParticleDef();
};

struct Particle
{
	Vec3 pos;
	Vec4 color;
	Vec4 deltaColor;
	float size;
	float deltaSize;
	float rotation;
	float deltaRotation;
	float timeToLive;
	union
	{
		struct
		{
			Vec2 dir;
			float radialAccel;
			float tangentialAccel;
		} gravity;
		struct
		{
			float angle;
			float degreesPerSecond;
			float radius;
			float deltaRadius;
		} radius;
	} mode;
};

class ParticleNode : public Node
{
public:
	PROPERTY_READONLY_BOOL(Active);
	PROPERTY_READONLY(Texture2D*, Texture);
	PROPERTY_BOOL(DepthWrite);
	virtual ~ParticleNode();
	virtual bool init() override;
	virtual void visit() override;
	virtual bool update(double deltaTime) override;
	virtual void render() override;
	void start();
	void stop();
	CREATE_FUNC(ParticleNode);
protected:
	ParticleNode(ParticleDef* def);
	ParticleNode(String filename);
	void addParticle();
	void addQuad(const Particle& particle, float scale, float angleX, float angleY);
private:
	double _elapsed;
	float _emitCounter;
	float _texLeft;
	float _texTop;
	float _texRight;
	float _texBottom;
	Ref<Texture2D> _texture;
	Ref<SpriteEffect> _effect;
	Uint64 _renderState;
	Ref<ParticleDef> _particleDef;
	vector<SpriteQuad> _quads;
	vector<Particle> _particles;
	enum
	{
		Active = Node::UserFlag,
		Emitting = Node::UserFlag << 1,
		DepthWrite = Node::UserFlag << 2,
		Finished = Node::UserFlag << 3
	};
};

NS_DOROTHY_END
