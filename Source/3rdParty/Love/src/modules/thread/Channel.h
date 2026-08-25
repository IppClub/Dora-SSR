/**
 * Copyright (c) 2006-2023 LOVE Development Team
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. See the LOVE license for the complete terms.
 *
 * Altered for Dora: the public LOVE Channel contract is retained while the
 * queue and synchronization implementation is supplied by the owning Dora
 * LoveRuntime.
 */

#ifndef LOVE_THREAD_CHANNEL_H
#define LOVE_THREAD_CHANNEL_H

#include "common/Object.h"
#include "common/Variant.h"
#include "common/int.h"

namespace love
{
namespace thread
{

class Channel : public love::Object
{
friend int w_Channel_performAtomic(lua_State *);

public:
	static love::Type type;
	~Channel() override = default;

	virtual uint64 push(const Variant &var) = 0;
	virtual bool supply(const Variant &var) = 0;
	virtual bool supply(const Variant &var, double timeout) = 0;
	virtual bool pop(Variant *var) = 0;
	virtual bool demand(Variant *var) = 0;
	virtual bool demand(Variant *var, double timeout) = 0;
	virtual bool peek(Variant *var) = 0;
	virtual int getCount() const = 0;
	virtual bool hasRead(uint64 id) const = 0;
	virtual void clear() = 0;

private:
	virtual void lockMutex() = 0;
	virtual void unlockMutex() = 0;
};

} // thread
} // love

#endif // LOVE_THREAD_CHANNEL_H
