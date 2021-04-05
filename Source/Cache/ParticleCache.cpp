/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Cache/ParticleCache.h"
#include "Const/XmlTag.h"
#include "Cache/TextureCache.h"
#include "Node/Particle.h"

NS_DOROTHY_BEGIN

std::shared_ptr<XmlParser<ParticleDef>> ParticleCache::prepareParser(String filename)
{
	return std::shared_ptr<XmlParser<ParticleDef>>(new Parser(ParticleDef::create()));
}

void ParticleCache::Parser::xmlSAX2Text(const char *s, size_t len)
{ }

void ParticleCache::Parser::xmlSAX2StartElement(const char* name, size_t len, const std::vector<AttrSlice>& attrs)
{
	if (Xml::Particle(name[0]) != Xml::Particle::Dorothy && attrs.size() <= 1)
	{
		throw rapidxml::parse_error("invalid particle file", r_cast<void*>(c_cast<char*>(name)));
	}
	switch (Xml::Particle(name[0]))
	{
		case Xml::Particle::Dorothy:
			break;
		case Xml::Particle::Angle:
			_item->angle = s_cast<float>(std::atof(attrs[1].first));
			break;
		case Xml::Particle::AngleVariance:
			_item->angleVariance = s_cast<float>(std::atof(attrs[1].first));
			break;
		case Xml::Particle::BlendFuncDestination:
			_item->blendFuncDestination = s_cast<Uint32>(std::atoi(attrs[1].first));
			break;
		case Xml::Particle::BlendFuncSource:
			_item->blendFuncSource = s_cast<Uint32>(std::atoi(attrs[1].first));
			break;
		case Xml::Particle::Duration:
			_item->duration = s_cast<float>(std::atof(attrs[1].first));
			break;
		case Xml::Particle::EmissionRate:
			_item->emissionRate = s_cast<float>(std::atof(attrs[1].first));
			break;
		case Xml::Particle::FinishColor:
			get(attrs[1], _item->finishColor);
			break;
		case Xml::Particle::FinishColorVariance:
			get(attrs[1], _item->finishColorVariance);
			break;
		case Xml::Particle::RotationStart:
			_item->rotationStart = s_cast<float>(std::atof(attrs[1].first));
			break;
		case Xml::Particle::RotationStartVariance:
			_item->rotationStartVariance = s_cast<float>(std::atof(attrs[1].first));
			break;
		case Xml::Particle::RotationEnd:
			_item->rotationEnd = s_cast<float>(std::atof(attrs[1].first));
			break;
		case Xml::Particle::RotationEndVariance:
			_item->rotationEndVariance = s_cast<float>(std::atof(attrs[1].first));
			break;
		case Xml::Particle::FinishParticleSize:
			_item->finishParticleSize = s_cast<float>(std::atof(attrs[1].first));
			break;
		case Xml::Particle::FinishParticleSizeVariance:
			_item->finishParticleSizeVariance = s_cast<float>(std::atof(attrs[1].first));
			break;
		case Xml::Particle::MaxParticles:
			_item->maxParticles = s_cast<Uint32>(std::atoi(attrs[1].first));
			break;
		case Xml::Particle::ParticleLifespan:
			_item->particleLifespan = s_cast<float>(std::atof(attrs[1].first));
			break;
		case Xml::Particle::ParticleLifespanVariance:
			_item->particleLifespanVariance = s_cast<float>(std::atof(attrs[1].first));
			break;
		case Xml::Particle::StartPosition:
			get(attrs[1], _item->startPosition);
			break;
		case Xml::Particle::StartPositionVariance:
			get(attrs[1], _item->startPositionVariance);
			break;
		case Xml::Particle::StartColor:
			get(attrs[1], _item->startColor);
			break;
		case Xml::Particle::StartColorVariance:
			get(attrs[1], _item->startColorVariance);
			break;
		case Xml::Particle::StartParticleSize:
			_item->startParticleSize = s_cast<float>(std::atof(attrs[1].first));
			break;
		case Xml::Particle::StartParticleSizeVariance:
			_item->startParticleSizeVariance = s_cast<float>(std::atof(attrs[1].first));
			break;
		case Xml::Particle::TextureName:
			_item->textureName = Slice(attrs[1]).toString();
			break;
		case Xml::Particle::TextureRect:
			get(attrs[1], _item->textureRect);
			break;
		case Xml::Particle::EmitterMode:
			_item->emitterMode = EmitterMode(s_cast<int>(std::atoi(attrs[1].first)));
			break;
		case Xml::Particle::RotationIsDir:
			_item->mode.gravity.rotationIsDir = s_cast<int>(std::atoi(attrs[1].first)) != 0;
			break;
		case Xml::Particle::Gravity:
			get(attrs[1], _item->mode.gravity.gravity);
			break;
		case Xml::Particle::Speed:
			_item->mode.gravity.speed = s_cast<float>(std::atoi(attrs[1].first));
			break;
		case Xml::Particle::SpeedVariance:
			_item->mode.gravity.speedVariance = s_cast<float>(std::atoi(attrs[1].first));
			break;
		case Xml::Particle::RadialAcceleration:
			_item->mode.gravity.radialAcceleration = s_cast<float>(std::atoi(attrs[1].first));
			break;
		case Xml::Particle::RadialAccelVariance:
			_item->mode.gravity.radialAccelVariance = s_cast<float>(std::atoi(attrs[1].first));
			break;
		case Xml::Particle::TangentialAcceleration:
			_item->mode.gravity.tangentialAcceleration = s_cast<float>(std::atoi(attrs[1].first));
			break;
		case Xml::Particle::TangentialAccelVariance:
			_item->mode.gravity.tangentialAccelVariance = s_cast<float>(std::atoi(attrs[1].first));
			break;
		case Xml::Particle::StartRadius:
			_item->mode.radius.startRadius = s_cast<float>(std::atoi(attrs[1].first));
			break;
		case Xml::Particle::StartRadiusVariance:
			_item->mode.radius.startRadiusVariance = s_cast<float>(std::atoi(attrs[1].first));
			break;
		case Xml::Particle::FinishRadius:
			_item->mode.radius.finishRadius = s_cast<float>(std::atoi(attrs[1].first));
			break;
		case Xml::Particle::FinishRadiusVariance:
			_item->mode.radius.finishRadiusVariance = s_cast<float>(std::atoi(attrs[1].first));
			break;
		case Xml::Particle::RotatePerSecond:
			_item->mode.radius.rotatePerSecond = s_cast<float>(std::atoi(attrs[1].first));
			break;
		case Xml::Particle::RotatePerSecondVariance:
			_item->mode.radius.rotatePerSecondVariance = s_cast<float>(std::atoi(attrs[1].first));
			break;
	}
}

void ParticleCache::Parser::xmlSAX2EndElement(const char *name, size_t len)
{ }

void ParticleCache::Parser::get(String value, Vec4& vec)
{
	auto tokens = value.split(",");
	AssertUnless(tokens.size() == 4, "invalid vec4 str for: \"{}\"", value);
	auto it = tokens.begin();
	vec.x = Slice::stof(*it);
	vec.y = Slice::stof(*++it);
	vec.z = Slice::stof(*++it);
	vec.w = Slice::stof(*++it);
}

void ParticleCache::Parser::get(String value, Vec2& vec)
{
	auto tokens = value.split(",");
	AssertUnless(tokens.size() == 2, "invalid vec2 str for: \"{}\"", value);
	auto it = tokens.begin();
	vec.x = Slice::stof(*it);
	vec.y = Slice::stof(*++it);
}

void ParticleCache::Parser::get(String value, Rect& rect)
{
	auto tokens = value.split(",");
	AssertUnless(tokens.size() == 4, "invalid vec4 str for: \"{}\"", value);
	auto it = tokens.begin();
	rect.origin.x = Slice::stof(*it);
	rect.origin.y = Slice::stof(*++it);
	rect.size.width = Slice::stof(*++it);
	rect.size.height = Slice::stof(*++it);
}

NS_DOROTHY_END
