/**
 * Copyright (c) 2006-2023 LOVE Development Team
 *
 * Altered for Dora: LOVE's public Threadable/LuaThread object contract is
 * retained, while Dora owns thread creation and the Lua 5.5 worker state.
 */

#ifndef LOVE_THREAD_LUATHREAD_H
#define LOVE_THREAD_LUATHREAD_H

#include "common/Data.h"
#include "common/Object.h"
#include "common/Variant.h"
#include "threads.h"

#include <string>
#include <vector>

namespace love
{
namespace thread
{

class LuaThread : public Threadable
{
public:
	static love::Type type;
	~LuaThread() override = default;

	void threadFunction() override { }
	virtual void wait() = 0;
	virtual bool isRunning() const = 0;
	virtual const std::string &getError() const = 0;
	virtual bool hasError() const = 0;
	virtual bool start(const std::vector<Variant> &args) = 0;

protected:
	LuaThread() : Threadable(false) { }
};

} // thread
} // love

#endif // LOVE_THREAD_LUATHREAD_H
