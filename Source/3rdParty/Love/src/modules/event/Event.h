/** Copyright (c) 2006-2023 LOVE Development Team.
 * Altered for Dora: queue and platform pumping are state-local backend operations. */
#pragma once

#include "common/Module.h"
#include "common/Variant.h"

#include <string>
#include <vector>

namespace love::event
{

class Message : public Object
{
public:
	Message(const std::string &name, const std::vector<Variant> &args = {});
	int toLua(lua_State *L);
	static Message *fromLua(lua_State *L, int index);
	const std::string name;
	const std::vector<Variant> args;
};

class Event : public Module
{
public:
	~Event() override = default;
	ModuleType getModuleType() const override { return M_EVENT; }
	const char *getName() const override { return "love.event"; }
	virtual void push(Message *message) = 0;
	virtual bool poll(Message *&message) = 0;
	virtual void clear() = 0;
	virtual void pump() = 0;
	virtual Message *wait() = 0;
};

Event *newDoraEvent(lua_State *L);

}
