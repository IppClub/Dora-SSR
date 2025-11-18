/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/Particle.h"

#include "Basic/Director.h"
#include "Basic/Scheduler.h"
#include "Cache/ClipCache.h"
#include "Cache/ParticleCache.h"
#include "Cache/TextureCache.h"
#include "Const/XmlTag.h"
#include "Effect/Effect.h"

NS_DORA_BEGIN

static const uint8_t __defaultParticleTexturePng[] = {
	0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
	0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x20, 0x08, 0x06, 0x00, 0x00, 0x00, 0x73, 0x7A, 0x7A,
	0xF4, 0x00, 0x00, 0x00, 0x04, 0x67, 0x41, 0x4D, 0x41, 0x00, 0x00, 0xAF, 0xC8, 0x37, 0x05, 0x8A,
	0xE9, 0x00, 0x00, 0x00, 0x19, 0x74, 0x45, 0x58, 0x74, 0x53, 0x6F, 0x66, 0x74, 0x77, 0x61, 0x72,
	0x65, 0x00, 0x41, 0x64, 0x6F, 0x62, 0x65, 0x20, 0x49, 0x6D, 0x61, 0x67, 0x65, 0x52, 0x65, 0x61,
	0x64, 0x79, 0x71, 0xC9, 0x65, 0x3C, 0x00, 0x00, 0x02, 0x64, 0x49, 0x44, 0x41, 0x54, 0x78, 0xDA,
	0xC4, 0x97, 0x89, 0x6E, 0xEB, 0x20, 0x10, 0x45, 0xBD, 0xE1, 0x2D, 0x4B, 0xFF, 0xFF, 0x37, 0x5F,
	0x5F, 0x0C, 0xD8, 0xC4, 0xAE, 0x2D, 0xDD, 0xA9, 0x6E, 0xA7, 0x38, 0xC1, 0x91, 0xAA, 0x44, 0xBA,
	0xCA, 0x06, 0xCC, 0x99, 0x85, 0x01, 0xE7, 0xCB, 0xB2, 0x64, 0xEF, 0x7C, 0x55, 0x2F, 0xCC, 0x69,
	0x56, 0x15, 0xAB, 0x72, 0x68, 0x81, 0xE6, 0x55, 0xFE, 0xE8, 0x62, 0x79, 0x62, 0x04, 0x36, 0xA3,
	0x06, 0xC0, 0x9B, 0xCA, 0x08, 0xC0, 0x7D, 0x55, 0x80, 0xA6, 0x54, 0x98, 0x67, 0x11, 0xA8, 0xA1,
	0x86, 0x3E, 0x0B, 0x44, 0x41, 0x00, 0x33, 0x19, 0x1F, 0x21, 0x43, 0x9F, 0x5F, 0x02, 0x68, 0x49,
	0x1D, 0x20, 0x1A, 0x82, 0x28, 0x09, 0xE0, 0x4E, 0xC6, 0x3D, 0x64, 0x57, 0x39, 0x80, 0xBA, 0xA3,
	0x00, 0x1D, 0xD4, 0x93, 0x3A, 0xC0, 0x34, 0x0F, 0x00, 0x3C, 0x8C, 0x59, 0x4A, 0x99, 0x44, 0xCA,
	0xA6, 0x02, 0x88, 0xC7, 0xA7, 0x55, 0x67, 0xE8, 0x44, 0x10, 0x12, 0x05, 0x0D, 0x30, 0x92, 0xE7,
	0x52, 0x33, 0x32, 0x26, 0xC3, 0x38, 0xF7, 0x0C, 0xA0, 0x06, 0x40, 0x0F, 0xC3, 0xD7, 0x55, 0x17,
	0x05, 0xD1, 0x92, 0x77, 0x02, 0x20, 0x85, 0xB7, 0x19, 0x18, 0x28, 0x4D, 0x05, 0x19, 0x9F, 0xA1,
	0xF1, 0x08, 0xC0, 0x05, 0x10, 0x57, 0x7C, 0x4F, 0x01, 0x10, 0xEF, 0xC5, 0xF8, 0xAC, 0x76, 0xC8,
	0x2E, 0x80, 0x14, 0x99, 0xE4, 0xFE, 0x44, 0x51, 0xB8, 0x52, 0x14, 0x3A, 0x32, 0x22, 0x00, 0x13,
	0x85, 0xBF, 0x52, 0xC6, 0x05, 0x8E, 0xE5, 0x63, 0x00, 0x86, 0xB6, 0x9C, 0x86, 0x38, 0xAB, 0x54,
	0x74, 0x18, 0x5B, 0x50, 0x58, 0x6D, 0xC4, 0xF3, 0x89, 0x6A, 0xC3, 0x61, 0x8E, 0xD9, 0x03, 0xA8,
	0x08, 0xA0, 0x55, 0xBB, 0x40, 0x40, 0x3E, 0x00, 0xD2, 0x53, 0x47, 0x94, 0x0E, 0x38, 0xD0, 0x7A,
	0x73, 0x64, 0x57, 0xF0, 0x16, 0xFE, 0x95, 0x82, 0x86, 0x1A, 0x4C, 0x4D, 0xE9, 0x68, 0xD5, 0xAE,
	0xB8, 0x00, 0xE2, 0x8C, 0xDF, 0x4B, 0xE4, 0xD7, 0xC1, 0xB3, 0x4C, 0x75, 0xC2, 0x36, 0xD2, 0x3F,
	0x2A, 0x7C, 0xF7, 0x0C, 0x50, 0x60, 0xB1, 0x4A, 0x81, 0x18, 0x88, 0xD3, 0x22, 0x75, 0xD1, 0x63,
	0x5C, 0x80, 0xF7, 0x19, 0x15, 0xA2, 0xA5, 0xB9, 0xB5, 0x5A, 0xB7, 0xA4, 0x34, 0x7D, 0x03, 0x48,
	0x5F, 0x17, 0x90, 0x52, 0x01, 0x19, 0x95, 0x9E, 0x1E, 0xD1, 0x30, 0x30, 0x9A, 0x21, 0xD7, 0x0D,
	0x81, 0xB3, 0xC1, 0x92, 0x0C, 0xE7, 0xD4, 0x1B, 0xBE, 0x49, 0xF2, 0x04, 0x15, 0x2A, 0x52, 0x06,
	0x69, 0x31, 0xCA, 0xB3, 0x22, 0x71, 0xBD, 0x1F, 0x00, 0x4B, 0x82, 0x66, 0xB5, 0xA7, 0x37, 0xCF,
	0x6F, 0x78, 0x0F, 0xF8, 0x5D, 0xC6, 0xA4, 0xAC, 0xF7, 0x23, 0x05, 0x6C, 0xE4, 0x4E, 0xE2, 0xE3,
	0x95, 0xB7, 0xD3, 0x40, 0xF3, 0xA5, 0x06, 0x1C, 0xFE, 0x1F, 0x09, 0x2A, 0xA8, 0xF5, 0xE6, 0x3D,
	0x00, 0xDD, 0xAD, 0x02, 0x2D, 0xC4, 0x4D, 0x66, 0xA0, 0x6A, 0x1F, 0xD5, 0x2E, 0xF8, 0x8F, 0xFF,
	0x2D, 0xC6, 0x4F, 0x04, 0x1E, 0x14, 0xD0, 0xAC, 0x01, 0x3C, 0xAA, 0x5C, 0x1F, 0xA9, 0x2E, 0x72,
	0xBA, 0x49, 0xB5, 0xC7, 0xFA, 0xC0, 0x27, 0xD2, 0x62, 0x69, 0xAE, 0xA7, 0xC8, 0x04, 0xEA, 0x0F,
	0xBF, 0x1A, 0x51, 0x50, 0x61, 0x16, 0x8F, 0x1B, 0xD5, 0x5E, 0x03, 0x75, 0x35, 0xDD, 0x09, 0x6F,
	0x88, 0xC4, 0x0D, 0x73, 0x07, 0x82, 0x61, 0x88, 0xE8, 0x59, 0x30, 0x45, 0x8E, 0xD4, 0x7A, 0xA7,
	0xBD, 0xDA, 0x07, 0x67, 0x81, 0x40, 0x30, 0x88, 0x55, 0xF5, 0x11, 0x05, 0xF0, 0x58, 0x94, 0x9B,
	0x48, 0xEC, 0x60, 0xF1, 0x09, 0xC7, 0xF1, 0x66, 0xFC, 0xDF, 0x0E, 0x84, 0x7F, 0x74, 0x1C, 0x8F,
	0x58, 0x44, 0x77, 0xAC, 0x59, 0xB5, 0xD7, 0x67, 0x00, 0x12, 0x85, 0x4F, 0x2A, 0x4E, 0x17, 0xBB,
	0x1F, 0xC6, 0x00, 0xB8, 0x99, 0xB0, 0xE7, 0x23, 0x9D, 0xF7, 0xCF, 0x6E, 0x44, 0x83, 0x4A, 0x45,
	0x32, 0x40, 0x86, 0x81, 0x7C, 0x8D, 0xBA, 0xAB, 0x1C, 0xA7, 0xDE, 0x09, 0x87, 0x48, 0x21, 0x26,
	0x5F, 0x4A, 0xAD, 0xBA, 0x6E, 0x4F, 0xCA, 0xFB, 0x23, 0xB7, 0x62, 0xF7, 0xCA, 0xAD, 0x58, 0x22,
	0xC1, 0x00, 0x47, 0x9F, 0x0B, 0x7C, 0xCA, 0x73, 0xC1, 0xDB, 0x9F, 0x8C, 0xF2, 0x17, 0x1E, 0x4E,
	0xDF, 0xF2, 0x6C, 0xF8, 0x67, 0xAF, 0x22, 0x7B, 0xF3, 0xEB, 0x4B, 0x80, 0x01, 0x00, 0xB8, 0x21,
	0x72, 0x89, 0x08, 0x10, 0x07, 0x7D, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
	0x60, 0x82};

ParticleDef::ParticleDef()
	: angle()
	, angleVariance()
	, blendFuncDestination()
	, blendFuncSource()
	, duration()
	, emissionRate()
	, finishColor{}
	, finishColorVariance{}
	, rotationStart()
	, rotationStartVariance()
	, rotationEnd()
	, rotationEndVariance()
	, finishParticleSize()
	, finishParticleSizeVariance()
	, maxParticles()
	, particleLifespan()
	, particleLifespanVariance()
	, startPosition()
	, startPositionVariance()
	, startColor()
	, startColorVariance()
	, startParticleSize()
	, startParticleSizeVariance()
	, emitterMode()
	, mode()
	, textureName()
	, textureRect() { }

std::string ParticleDef::toXml() const {
	fmt::memory_buffer out;
	fmt::format_to(std::back_inserter(out), "<{}>"sv, char(Xml::Particle::Dorothy));
	fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::Angle), angle);
	fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::AngleVariance), angleVariance);
	fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::BlendFuncDestination), blendFuncDestination);
	fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::BlendFuncSource), blendFuncSource);
	fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::Duration), duration);
	fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::EmissionRate), emissionRate);
	fmt::format_to(std::back_inserter(out), "<{} A=\"{},{},{},{}\"/>"sv, char(Xml::Particle::FinishColor), finishColor.x, finishColor.y, finishColor.z, finishColor.w);
	fmt::format_to(std::back_inserter(out), "<{} A=\"{},{},{},{}\"/>"sv, char(Xml::Particle::FinishColorVariance), finishColorVariance.x, finishColorVariance.y, finishColorVariance.z, finishColorVariance.w);
	fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::RotationStart), rotationStart);
	fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::RotationStartVariance), rotationStartVariance);
	fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::RotationEnd), rotationEnd);
	fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::RotationEndVariance), rotationEndVariance);
	fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::FinishParticleSize), finishParticleSize);
	fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::FinishParticleSizeVariance), finishParticleSizeVariance);
	fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::MaxParticles), maxParticles);
	fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::ParticleLifespan), particleLifespan);
	fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::ParticleLifespanVariance), particleLifespanVariance);
	fmt::format_to(std::back_inserter(out), "<{} A=\"{},{}\"/>"sv, char(Xml::Particle::StartPosition), startPosition.x, startPosition.y);
	fmt::format_to(std::back_inserter(out), "<{} A=\"{},{}\"/>"sv, char(Xml::Particle::StartPositionVariance), startPositionVariance.x, startPositionVariance.y);
	fmt::format_to(std::back_inserter(out), "<{} A=\"{},{},{},{}\"/>"sv, char(Xml::Particle::StartColor), startColor.x, startColor.y, startColor.z, startColor.w);
	fmt::format_to(std::back_inserter(out), "<{} A=\"{},{},{},{}\"/>"sv, char(Xml::Particle::StartColorVariance), startColorVariance.x, startColorVariance.y, startColorVariance.z, startColorVariance.w);
	fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::StartParticleSize), startParticleSize);
	fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::StartParticleSizeVariance), startParticleSizeVariance);
	fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::EmitterMode), s_cast<int>(emitterMode));
	fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::TextureName), textureName);
	fmt::format_to(std::back_inserter(out), "<{} A=\"{},{},{},{}\"/>"sv, char(Xml::Particle::TextureRect), textureRect.getX(), textureRect.getY(), textureRect.getWidth(), textureRect.getHeight());
	switch (emitterMode) {
		case EmitterMode::Gravity:
			fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::RotationIsDir), mode.gravity.rotationIsDir ? 1 : 0);
			fmt::format_to(std::back_inserter(out), "<{} A=\"{},{}\"/>"sv, char(Xml::Particle::Gravity), mode.gravity.gravity.x, mode.gravity.gravity.y);
			fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::Speed), mode.gravity.speed);
			fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::SpeedVariance), mode.gravity.speedVariance);
			fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::RadialAcceleration), mode.gravity.radialAcceleration);
			fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::RadialAccelVariance), mode.gravity.radialAccelVariance);
			fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::TangentialAcceleration), mode.gravity.tangentialAcceleration);
			fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::TangentialAccelVariance), mode.gravity.tangentialAccelVariance);
			break;
		case EmitterMode::Radius:
			fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::StartRadius), mode.radius.startRadius);
			fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::StartRadiusVariance), mode.radius.startRadiusVariance);
			fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::FinishRadius), mode.radius.finishRadius);
			fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::FinishRadiusVariance), mode.radius.finishRadiusVariance);
			fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::RotatePerSecond), mode.radius.rotatePerSecond);
			fmt::format_to(std::back_inserter(out), "<{} A=\"{}\"/>"sv, char(Xml::Particle::RotatePerSecondVariance), mode.radius.rotatePerSecondVariance);
			break;
	}
	fmt::format_to(std::back_inserter(out), "</{}>\n"sv, char(Xml::Particle::Dorothy));
	return fmt::to_string(out);
}

ParticleDef* ParticleDef::fire() {
	ParticleDef* def = ParticleDef::create();
	def->duration = -1;

	def->emitterMode = EmitterMode::Gravity;
	def->mode.gravity.gravity = Vec2::zero;
	def->mode.gravity.radialAcceleration = 0;
	def->mode.gravity.radialAccelVariance = 0;
	def->mode.gravity.speed = 20;
	def->mode.gravity.speedVariance = 5;

	def->angle = 90;
	def->angleVariance = 360;

	def->startPosition = Vec2::zero;

	def->particleLifespan = 1;
	def->particleLifespanVariance = 0.5f;

	def->startParticleSize = 30.0f;
	def->startParticleSizeVariance = 10.0f;

	def->finishParticleSize = -1;

	def->maxParticles = 100;
	def->emissionRate = 350;

	def->startColor = {0.76f, 0.25f, 0.12f, 1.0f};
	def->finishColor = {0.0f, 0.0f, 0.0f, 1.0f};

	def->blendFuncSource = BlendFunc::SrcAlpha;
	def->blendFuncDestination = BlendFunc::One;

	return def;
}

ParticleNode::ParticleNode(ParticleDef* def)
	: _particleDef(def)
	, _elapsed(0)
	, _emitCounter(0)
	, _texLeft(0)
	, _texTop(0)
	, _texRight(0)
	, _texBottom(0)
	, _renderState(BGFX_STATE_NONE)
	, _effect(SharedSpriteRenderer.getDefaultEffect()) { }

ParticleNode::ParticleNode(String filename)
	: ParticleNode(SharedParticleCache.load(filename)) { }

ParticleNode::~ParticleNode() { }

bool ParticleNode::init() {
	if (!Node::init()) return false;
	if (!_particleDef) {
		setAsManaged();
		return false;
	}
	_particles.reserve(_particleDef->maxParticles);
	_quads.reserve(_particleDef->maxParticles);
	Rect textureRect = _particleDef->textureRect;
	if (!_particleDef->textureName.empty()) {
		if (SharedClipCache.isClip(_particleDef->textureName) && SharedClipCache.isFileExist(_particleDef->textureName)) {
			Texture2D* tex = nullptr;
			Rect rect;
			std::tie(tex, rect) = SharedClipCache.loadTexture(_particleDef->textureName);
			if (tex) {
				_texture = tex;
				textureRect = rect;
			}
		} else if (SharedContent.exist(_particleDef->textureName) && !SharedContent.isFolder(_particleDef->textureName)) {
			_texture = SharedTextureCache.load(_particleDef->textureName);
		}
	}
	if (!_texture) {
		textureRect = Rect::zero;
		_texture = SharedTextureCache.get("__defaultParticleTexture.png");
		if (!_texture) {
			_texture = SharedTextureCache.update(
				"__defaultParticleTexture.png",
				__defaultParticleTexturePng,
				sizeof(__defaultParticleTexturePng));
		}
	}
	if (textureRect != Rect::zero) {
		const bgfx::TextureInfo& info = _texture->getInfo();
		_texLeft = textureRect.getX() / info.width;
		_texTop = textureRect.getY() / info.height;
		_texRight = (textureRect.getX() + textureRect.getWidth()) / info.width;
		_texBottom = (textureRect.getY() + textureRect.getHeight()) / info.height;
	} else {
		_texRight = 1.0f;
		_texBottom = 1.0f;
	}
	return true;
}

bool ParticleNode::isActive() const noexcept {
	return _flags.isOn(ParticleNode::Active);
}

Texture2D* ParticleNode::getTexture() const noexcept {
	return _texture;
}

void ParticleNode::setDepthWrite(bool var) {
	_flags.set(ParticleNode::DepthWrite, var);
}

bool ParticleNode::isDepthWrite() const noexcept {
	return _flags.isOn(ParticleNode::DepthWrite);
}

void ParticleNode::addParticle() {
	if (s_cast<uint32_t>(_particles.size()) >= _particleDef->maxParticles) {
		return;
	}

	const ParticleDef& def = *_particleDef;
	Particle particle{};

	particle.timeToLive = def.particleLifespan + def.particleLifespanVariance * Math::rand1to1();
	particle.timeToLive = std::max(FLT_EPSILON, particle.timeToLive);

	Vec3 worldPos = convertToWorldSpace3(Vec3{});
	Vec2 pos = worldPos.toVec2() + def.startPosition + def.startPositionVariance * Vec2{Math::rand1to1(), Math::rand1to1()};
	particle.pos = {pos.x, pos.y, worldPos.z};

	Vec4 start{
		Math::clamp(def.startColor.x + def.startColorVariance.x * Math::rand1to1(), 0.0f, 1.0f),
		Math::clamp(def.startColor.y + def.startColorVariance.y * Math::rand1to1(), 0.0f, 1.0f),
		Math::clamp(def.startColor.z + def.startColorVariance.z * Math::rand1to1(), 0.0f, 1.0f),
		Math::clamp(def.startColor.w + def.startColorVariance.w * Math::rand1to1(), 0.0f, 1.0f)};
	Vec4 end{
		Math::clamp(def.finishColor.x + def.finishColorVariance.x * Math::rand1to1(), 0.0f, 1.0f),
		Math::clamp(def.finishColor.y + def.finishColorVariance.y * Math::rand1to1(), 0.0f, 1.0f),
		Math::clamp(def.finishColor.z + def.finishColorVariance.z * Math::rand1to1(), 0.0f, 1.0f),
		Math::clamp(def.finishColor.w + def.finishColorVariance.w * Math::rand1to1(), 0.0f, 1.0f)};
	particle.color = start;
	particle.deltaColor = {
		(end.x - start.x) / particle.timeToLive,
		(end.y - start.y) / particle.timeToLive,
		(end.z - start.z) / particle.timeToLive,
		(end.w - start.w) / particle.timeToLive};

	float startSize = def.startParticleSize + def.startParticleSizeVariance * Math::rand1to1();
	startSize = std::max(0.0f, startSize);
	particle.size = startSize;

	if (def.finishParticleSize < 0) {
		particle.deltaSize = 0;
	} else {
		float endSize = def.finishParticleSize + def.finishParticleSizeVariance * Math::rand1to1();
		endSize = std::max(0.0f, endSize);
		particle.deltaSize = (endSize - startSize) / particle.timeToLive;
	}

	float startAngle = def.rotationStart + def.rotationStartVariance * Math::rand1to1();
	float endAngle = def.rotationEnd + def.rotationEndVariance * Math::rand1to1();
	particle.rotation = startAngle;
	particle.deltaRotation = (endAngle - startAngle) / particle.timeToLive;

	float angle = bx::toRad(def.angle + def.angleVariance * Math::rand1to1());

	switch (def.emitterMode) {
		case EmitterMode::Gravity: {
			Vec2 dir{std::cos(angle), std::sin(angle)};
			float speed = def.mode.gravity.speed + def.mode.gravity.speedVariance * Math::rand1to1();
			particle.mode.gravity.dir = dir * speed;
			particle.mode.gravity.radialAccel = def.mode.gravity.radialAcceleration + def.mode.gravity.radialAccelVariance * Math::rand1to1();
			particle.mode.gravity.tangentialAccel = def.mode.gravity.tangentialAcceleration + def.mode.gravity.tangentialAccelVariance * Math::rand1to1();
			if (def.mode.gravity.rotationIsDir) {
				particle.rotation = -bx::toDeg(particle.mode.gravity.dir.angle());
			}
			break;
		}
		case EmitterMode::Radius: {
			float startRadius = def.mode.radius.startRadius + def.mode.radius.startRadiusVariance * Math::rand1to1();
			particle.mode.radius.radius = startRadius;
			if (def.mode.radius.finishRadius < 0) {
				particle.mode.radius.deltaRadius = 0;
			} else {
				float endRadius = def.mode.radius.finishRadius + def.mode.radius.finishRadiusVariance * Math::rand1to1();
				particle.mode.radius.deltaRadius = (endRadius - startRadius) / particle.timeToLive;
			}
			particle.mode.radius.angle = angle;
			particle.mode.radius.degreesPerSecond = bx::toRad(def.mode.radius.rotatePerSecond + def.mode.radius.rotatePerSecondVariance * Math::rand1to1());
			break;
		}
	}
	_particles.push_back(particle);
}

void ParticleNode::start() {
	AssertIf(_flags.isOn(Node::Cleanup), "can not operate on an invalid ParticleNode");
	_flags.setOn(ParticleNode::Active);
	_flags.setOn(ParticleNode::Emitting);
	_elapsed = 0;
	_particles.clear();
}

void ParticleNode::stop() {
	AssertIf(_flags.isOn(Node::Cleanup), "can not operate on an invalid ParticleNode");
	_flags.setOff(ParticleNode::Active);
	_elapsed = _particleDef->duration;
	_emitCounter = 0;
}

void ParticleNode::addQuad(const Particle& particle, float scale, float angleX, float angleY) {
	const Vec3& pos = particle.pos;
	SpriteQuad quad = {
		{0, 0, 0, 1, _texRight, _texBottom},
		{0, 0, 0, 1, _texLeft, _texBottom},
		{0, 0, 0, 1, _texLeft, _texTop},
		{0, 0, 0, 1, _texRight, _texTop}};
	quad.rb.abgr = Color(particle.color).toABGR();
	quad.lb.abgr = Color(particle.color).toABGR();
	quad.lt.abgr = Color(particle.color).toABGR();
	quad.rt.abgr = Color(particle.color).toABGR();
	float halfSize = particle.size * 0.5f * scale;
	if (particle.rotation) {
		float x1 = -halfSize;
		float y1 = -halfSize;
		float x2 = halfSize;
		float y2 = halfSize;
		float r = -bx::toRad(particle.rotation);
		float cr = std::cos(r);
		float sr = std::sin(r);
		float ax = x1 * cr - y1 * sr;
		float ay = x1 * sr + y1 * cr;
		float bx = x2 * cr - y1 * sr;
		float by = x2 * sr + y1 * cr;
		float cx = x2 * cr - y2 * sr;
		float cy = x2 * sr + y2 * cr;
		float dx = x1 * cr - y2 * sr;
		float dy = x1 * sr + y2 * cr;
		quad.rb.x = pos.x + bx;
		quad.rb.y = pos.y + by;
		quad.lb.x = pos.x + ax;
		quad.lb.y = pos.y + ay;
		quad.lt.x = pos.x + dx;
		quad.lt.y = pos.y + dy;
		quad.rt.x = pos.x + cx;
		quad.rt.y = pos.y + cy;
	} else {
		quad.rb.x = pos.x + halfSize;
		quad.rb.y = pos.y - halfSize;
		quad.lb.x = pos.x - halfSize;
		quad.lb.y = pos.y - halfSize;
		quad.lt.x = pos.x - halfSize;
		quad.lt.y = pos.y + halfSize;
		quad.rt.x = pos.x + halfSize;
		quad.rt.y = pos.y + halfSize;
	}
	if (angleX || angleY) {
		Matrix rotate;
		bx::mtxRotateXY(rotate.m, -bx::toRad(angleX), -bx::toRad(angleY));
		Vec4 v4 = *r_cast<Vec4*>(&quad.rb.x);
		Matrix::mulVec4(&quad.rb.x, rotate, v4);
		v4 = *r_cast<Vec4*>(&quad.lb.x);
		Matrix::mulVec4(&quad.lb.x, rotate, v4);
		v4 = *r_cast<Vec4*>(&quad.lt.x);
		Matrix::mulVec4(&quad.lt.x, rotate, v4);
		v4 = *r_cast<Vec4*>(&quad.rt.x);
		Matrix::mulVec4(&quad.rt.x, rotate, v4);
	}
	_quads.push_back(quad);
}

void ParticleNode::visit() {
	if (_flags.isOff(ParticleNode::Emitting)) {
		Node::visit();
		return;
	}
	float deltaTime = s_cast<float>(getScheduler()->getDeltaTime());
	if (_flags.isOn(ParticleNode::Active) && _particleDef->emissionRate) {
		float rate = 1.0f / _particleDef->emissionRate;
		if (s_cast<uint32_t>(_particles.size()) < _particleDef->maxParticles) {
			_emitCounter += deltaTime;
		}
		while (s_cast<uint32_t>(_particles.size()) < _particleDef->maxParticles && _emitCounter > rate) {
			addParticle();
			_emitCounter -= rate;
		}
		_elapsed += deltaTime;
		if (_particleDef->duration >= 0 && _particleDef->duration < _elapsed) {
			stop();
		}
	}

	float scaleX = getScaleX(), scaleY = getScaleY(), angleX = getAngleX(), angleY = getAngleY();
	for (Node* parent = Node::getParent(); parent; parent = parent->getParent()) {
		scaleX *= parent->getScaleX();
		scaleY *= parent->getScaleY();
		angleX += parent->getAngleX();
		angleY += parent->getAngleY();
	}
	scaleX = std::abs(scaleX);
	scaleY = std::abs(scaleY);
	float scale = Vec2{scaleX, scaleY}.length() / std::sqrt(2.0f);

	_quads.clear();
	int index = 0;
	while (index < s_cast<int>(_particles.size())) {
		Particle& p = _particles[index];
		p.timeToLive -= deltaTime;
		if (p.timeToLive > 0) {
			switch (_particleDef->emitterMode) {
				case EmitterMode::Gravity: {
					Vec2 tmp, radial, tangential;
					radial = Vec2::zero;

					if (p.pos.x || p.pos.y) {
						radial = p.pos;
						radial.normalize();
					}
					tangential = radial;
					radial *= p.mode.gravity.radialAccel;

					float newy = tangential.x;
					tangential.x = -tangential.y;
					tangential.y = newy;
					tangential *= p.mode.gravity.tangentialAccel;

					tmp = radial + tangential + _particleDef->mode.gravity.gravity;
					tmp *= deltaTime;
					p.mode.gravity.dir += tmp;
					tmp = p.mode.gravity.dir * deltaTime;
					Vec2 pos = p.pos.toVec2() + tmp * scale;
					p.pos = {pos.x, pos.y, p.pos.z};
					break;
				}
				case EmitterMode::Radius: {
					p.mode.radius.angle += p.mode.radius.degreesPerSecond * deltaTime;
					p.mode.radius.radius += p.mode.radius.deltaRadius * deltaTime * scale;
					p.pos.x = -std::cos(p.mode.radius.angle) * p.mode.radius.radius;
					p.pos.y = -std::sin(p.mode.radius.angle) * p.mode.radius.radius;
					break;
				}
			}

			p.color.x += (p.deltaColor.x * deltaTime);
			p.color.y += (p.deltaColor.y * deltaTime);
			p.color.z += (p.deltaColor.z * deltaTime);
			p.color.w += (p.deltaColor.w * deltaTime);

			p.size += (p.deltaSize * deltaTime * scale);
			p.size = std::max(0.0f, p.size);

			p.rotation += (p.deltaRotation * deltaTime);

			addQuad(p, scale, angleX, angleY);

			++index;
		} else // if (life <= 0)
		{
			if (index < s_cast<int>(_particles.size())) {
				_particles[index] = _particles.back();
				_particles.pop_back();
			}
			if (_particles.empty()) {
				_flags.setOff(ParticleNode::Emitting);
				_flags.setOn(ParticleNode::Finished);
				scheduleUpdate();
			}
		}
	} // while end
	Node::visit();
}

bool ParticleNode::update(double deltaTime) {
	if (_flags.isOn(ParticleNode::Finished)) {
		_flags.setOff(ParticleNode::Finished);
		unscheduleUpdate();
		emit("Finished"_slice);
	}
	return Node::update(deltaTime);
}

void ParticleNode::render() {
	if (_quads.empty()) {
		Node::render();
		return;
	}

	if (SharedDirector.isFrustumCulling()) {
		const auto& firstQuad = _quads[0];
		auto [minX, maxX] = std::minmax({firstQuad.lt.x, firstQuad.lb.x, firstQuad.rt.x, firstQuad.rb.x});
		auto [minY, maxY] = std::minmax({firstQuad.lt.y, firstQuad.lb.y, firstQuad.rt.y, firstQuad.rb.y});
		auto [minZ, maxZ] = std::minmax({firstQuad.lt.z, firstQuad.lb.z, firstQuad.rt.z, firstQuad.rb.z});
		for (size_t i = 1; i < _quads.size(); i++) {
			const auto& quad = _quads[i];
			std::tie(minX, maxX) = std::minmax({minX, maxX, quad.lt.x, quad.lb.x, quad.rt.x, quad.rb.x});
			std::tie(minY, maxY) = std::minmax({minY, maxY, quad.lt.y, quad.lb.y, quad.rt.y, quad.rb.y});
			std::tie(minZ, maxZ) = std::minmax({minZ, maxZ, quad.lt.z, quad.lb.z, quad.rt.z, quad.rb.z});
		}
		AABB aabb{
			{minX, minY, minZ},
			{maxX, maxY, maxZ},
		};
		if (!SharedDirector.isInFrustum(aabb)) {
			return;
		}
	}

	const auto& transform = SharedDirector.getViewProjection();
	for (size_t i = 0; i < _quads.size(); i++) {
		auto& quad = _quads[i];
		Matrix::mulVec4(&quad.lb.x, transform, quad.lb.toVec4());
		Matrix::mulVec4(&quad.rb.x, transform, quad.rb.toVec4());
		Matrix::mulVec4(&quad.lt.x, transform, quad.lt.toVec4());
		Matrix::mulVec4(&quad.rt.x, transform, quad.rt.toVec4());
	}

	BlendFunc blendFunc{_particleDef->blendFuncSource, _particleDef->blendFuncDestination};
	_renderState = (BGFX_STATE_WRITE_RGB | BGFX_STATE_WRITE_A | BGFX_STATE_MSAA | blendFunc.toValue());
	if (_flags.isOn(ParticleNode::DepthWrite)) {
		_renderState |= (BGFX_STATE_WRITE_Z | BGFX_STATE_DEPTH_TEST_LESS);
	}
	SharedRendererManager.setCurrent(SharedSpriteRenderer.getTarget());
	SharedSpriteRenderer.push(_quads[0], _quads.size() * 4, _effect, _texture, _renderState);

	Node::render();
}

void ParticleNode::cleanup() {
	if (_flags.isOff(Node::Cleanup)) {
		Node::cleanup();
		_texture = nullptr;
		_effect = nullptr;
		_particleDef = nullptr;
	}
}

NS_DORA_END
