/**
 * Copyright (c) 2006-2023 LOVE Development Team
 *
 * Altered for Dora: module factories are abstract so the state-local Dora
 * adapter can preserve Content and Lua 5.5 worker ownership.
 */

#ifndef LOVE_THREAD_THREADMODULE_H
#define LOVE_THREAD_THREADMODULE_H

#include "common/Data.h"
#include "common/Module.h"
#include "Channel.h"
#include "LuaThread.h"

#include <string>

namespace love
{
namespace thread
{

class ThreadModule : public love::Module
{
public:
	~ThreadModule() override = default;
	virtual LuaThread *newThread(const std::string &name, love::Data *data) = 0;
	virtual Channel *newChannel() = 0;
	virtual Channel *getChannel(const std::string &name) = 0;
	const char *getName() const override { return "love.thread.dora"; }
	ModuleType getModuleType() const override { return M_THREAD; }
};

ThreadModule *newDoraThreadModule(lua_State *L);

} // thread
} // love

#endif // LOVE_THREAD_THREADMODULE_H
