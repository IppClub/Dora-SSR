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

// Altered for Dora: this unit retains LOVE 11.5's Type and enum maps; the
// concrete simulation and renderer storage live in Dora's state-local object.

#include "ParticleSystem.h"

namespace love::graphics
{

love::Type ParticleSystem::type("ParticleSystem", &Drawable::type);

StringMap<ParticleSystem::AreaSpreadDistribution,
	ParticleSystem::DISTRIBUTION_MAX_ENUM>::Entry ParticleSystem::distributionEntries[] = {
	{"none", DISTRIBUTION_NONE},
	{"uniform", DISTRIBUTION_UNIFORM},
	{"normal", DISTRIBUTION_NORMAL},
	{"ellipse", DISTRIBUTION_ELLIPSE},
	{"borderellipse", DISTRIBUTION_BORDER_ELLIPSE},
	{"borderrectangle", DISTRIBUTION_BORDER_RECTANGLE},
};

StringMap<ParticleSystem::AreaSpreadDistribution,
	ParticleSystem::DISTRIBUTION_MAX_ENUM> ParticleSystem::distributions(
	ParticleSystem::distributionEntries, sizeof(ParticleSystem::distributionEntries));

StringMap<ParticleSystem::InsertMode,
	ParticleSystem::INSERT_MODE_MAX_ENUM>::Entry ParticleSystem::insertModeEntries[] = {
	{"top", INSERT_MODE_TOP},
	{"bottom", INSERT_MODE_BOTTOM},
	{"random", INSERT_MODE_RANDOM},
};

StringMap<ParticleSystem::InsertMode,
	ParticleSystem::INSERT_MODE_MAX_ENUM> ParticleSystem::insertModes(
	ParticleSystem::insertModeEntries, sizeof(ParticleSystem::insertModeEntries));

bool ParticleSystem::getConstant(const char *in, AreaSpreadDistribution &out)
{
	return distributions.find(in, out);
}

bool ParticleSystem::getConstant(AreaSpreadDistribution in, const char *&out)
{
	return distributions.find(in, out);
}

std::vector<std::string> ParticleSystem::getConstants(AreaSpreadDistribution)
{
	return distributions.getNames();
}

bool ParticleSystem::getConstant(const char *in, InsertMode &out)
{
	return insertModes.find(in, out);
}

bool ParticleSystem::getConstant(InsertMode in, const char *&out)
{
	return insertModes.find(in, out);
}

std::vector<std::string> ParticleSystem::getConstants(InsertMode)
{
	return insertModes.getNames();
}

} // namespace love::graphics
