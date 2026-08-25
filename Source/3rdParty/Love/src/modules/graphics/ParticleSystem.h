/**
 * Copyright (c) 2006-2023 LOVE Development Team
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 **/

// Altered for Dora: the public LOVE 11.5 object contract is retained while
// simulation storage and rendering are supplied by the embedded backend.

#pragma once

#include "common/Color.h"
#include "common/Vector.h"
#include "common/int.h"
#include "Drawable.h"
#include "Quad.h"
#include "Texture.h"

#include <vector>

namespace love::graphics
{

class ParticleSystem : public Drawable
{
public:
	static love::Type type;

	enum AreaSpreadDistribution
	{
		DISTRIBUTION_NONE,
		DISTRIBUTION_UNIFORM,
		DISTRIBUTION_NORMAL,
		DISTRIBUTION_ELLIPSE,
		DISTRIBUTION_BORDER_ELLIPSE,
		DISTRIBUTION_BORDER_RECTANGLE,
		DISTRIBUTION_MAX_ENUM
	};

	enum InsertMode
	{
		INSERT_MODE_TOP,
		INSERT_MODE_BOTTOM,
		INSERT_MODE_RANDOM,
		INSERT_MODE_MAX_ENUM
	};

	static constexpr uint32 MAX_PARTICLES = LOVE_INT32_MAX / 4;

	~ParticleSystem() override = default;

	virtual ParticleSystem *clone() = 0;
	virtual void setTexture(Texture *texture) = 0;
	virtual Texture *getTexture() const = 0;
	virtual void setBufferSize(uint32 size) = 0;
	virtual uint32 getBufferSize() const = 0;
	virtual void setInsertMode(InsertMode mode) = 0;
	virtual InsertMode getInsertMode() const = 0;
	virtual void setEmissionRate(float rate) = 0;
	virtual float getEmissionRate() const = 0;
	virtual void setEmitterLifetime(float life) = 0;
	virtual float getEmitterLifetime() const = 0;
	virtual void setParticleLifetime(float min, float max = 0) = 0;
	virtual void getParticleLifetime(float &min, float &max) const = 0;
	virtual void setPosition(float x, float y) = 0;
	virtual const love::Vector2 &getPosition() const = 0;
	virtual void moveTo(float x, float y) = 0;
	virtual void setEmissionArea(AreaSpreadDistribution distribution, float x, float y,
		float angle, bool directionRelativeToCenter) = 0;
	virtual AreaSpreadDistribution getEmissionArea(love::Vector2 &params, float &angle,
		bool &directionRelativeToCenter) const = 0;
	virtual void setDirection(float direction) = 0;
	virtual float getDirection() const = 0;
	virtual void setSpread(float spread) = 0;
	virtual float getSpread() const = 0;
	virtual void setSpeed(float speed) = 0;
	virtual void setSpeed(float min, float max) = 0;
	virtual void getSpeed(float &min, float &max) const = 0;
	virtual void setLinearAcceleration(float x, float y) = 0;
	virtual void setLinearAcceleration(float xmin, float ymin, float xmax, float ymax) = 0;
	virtual void getLinearAcceleration(love::Vector2 &min, love::Vector2 &max) const = 0;
	virtual void setRadialAcceleration(float acceleration) = 0;
	virtual void setRadialAcceleration(float min, float max) = 0;
	virtual void getRadialAcceleration(float &min, float &max) const = 0;
	virtual void setTangentialAcceleration(float acceleration) = 0;
	virtual void setTangentialAcceleration(float min, float max) = 0;
	virtual void getTangentialAcceleration(float &min, float &max) const = 0;
	virtual void setLinearDamping(float min, float max) = 0;
	virtual void getLinearDamping(float &min, float &max) const = 0;
	virtual void setSize(float size) = 0;
	virtual void setSizes(const std::vector<float> &sizes) = 0;
	virtual const std::vector<float> &getSizes() const = 0;
	virtual void setSizeVariation(float variation) = 0;
	virtual float getSizeVariation() const = 0;
	virtual void setRotation(float rotation) = 0;
	virtual void setRotation(float min, float max) = 0;
	virtual void getRotation(float &min, float &max) const = 0;
	virtual void setSpin(float spin) = 0;
	virtual void setSpin(float start, float end) = 0;
	virtual void getSpin(float &start, float &end) const = 0;
	virtual void setSpinVariation(float variation) = 0;
	virtual float getSpinVariation() const = 0;
	virtual void setOffset(float x, float y) = 0;
	virtual love::Vector2 getOffset() const = 0;
	virtual void setColor(const std::vector<Colorf> &colors) = 0;
	virtual std::vector<Colorf> getColor() const = 0;
	virtual void setQuads(const std::vector<Quad *> &quads) = 0;
	virtual void setQuads() = 0;
	virtual std::vector<Quad *> getQuads() const = 0;
	virtual void setRelativeRotation(bool enable) = 0;
	virtual bool hasRelativeRotation() const = 0;
	virtual uint32 getCount() const = 0;
	virtual void start() = 0;
	virtual void stop() = 0;
	virtual void pause() = 0;
	virtual void reset() = 0;
	virtual void emit(uint32 count) = 0;
	virtual bool isActive() const = 0;
	virtual bool isPaused() const = 0;
	virtual bool isStopped() const = 0;
	virtual bool isEmpty() const = 0;
	virtual bool isFull() const = 0;
	virtual void update(float dt) = 0;

	static bool getConstant(const char *in, AreaSpreadDistribution &out);
	static bool getConstant(AreaSpreadDistribution in, const char *&out);
	static std::vector<std::string> getConstants(AreaSpreadDistribution);
	static bool getConstant(const char *in, InsertMode &out);
	static bool getConstant(InsertMode in, const char *&out);
	static std::vector<std::string> getConstants(InsertMode);

private:
	static StringMap<AreaSpreadDistribution, DISTRIBUTION_MAX_ENUM>::Entry distributionEntries[];
	static StringMap<AreaSpreadDistribution, DISTRIBUTION_MAX_ENUM> distributions;
	static StringMap<InsertMode, INSERT_MODE_MAX_ENUM>::Entry insertModeEntries[];
	static StringMap<InsertMode, INSERT_MODE_MAX_ENUM> insertModes;
};

} // namespace love::graphics
