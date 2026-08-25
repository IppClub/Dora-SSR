/** Copyright (c) 2006-2023 LOVE Development Team.
 * Altered for Dora: timing values come from the owning LoveRuntime. */
#pragma once

#include "common/Module.h"

struct lua_State;

namespace love::timer
{

class Timer : public Module
{
public:
	~Timer() override = default;
	ModuleType getModuleType() const override { return M_TIMER; }
	const char *getName() const override { return "love.timer"; }
	virtual double step() = 0;
	virtual void sleep(double seconds) const = 0;
	virtual double getDelta() const = 0;
	virtual int getFPS() const = 0;
	virtual double getAverageDelta() const = 0;
	virtual double getTime() const = 0;
};

Timer *newDoraTimer(lua_State *L);

}
