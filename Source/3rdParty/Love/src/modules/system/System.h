/** Copyright (c) 2006-2023 LOVE Development Team.
 * Altered for Dora: platform operations are supplied by a state-local backend. */
#pragma once

#include "common/Module.h"
#include "common/StringMap.h"

#include <string>

struct lua_State;

namespace love::system
{

class System : public Module
{
public:
	enum PowerState
	{
		POWER_UNKNOWN, POWER_BATTERY, POWER_NO_BATTERY, POWER_CHARGING,
		POWER_CHARGED, POWER_MAX_ENUM
	};
	~System() override = default;
	ModuleType getModuleType() const override { return M_SYSTEM; }
	const char *getName() const override { return "love.system"; }
	virtual std::string getOS() const = 0;
	virtual int getProcessorCount() const = 0;
	virtual void setClipboardText(const std::string &text) const = 0;
	virtual std::string getClipboardText() const = 0;
	virtual PowerState getPowerInfo(int &seconds, int &percent) const = 0;
	virtual bool openURL(const std::string &url) const = 0;
	virtual void vibrate(double seconds) const = 0;
	virtual bool hasBackgroundMusic() const = 0;
	static bool getConstant(const char *in, PowerState &out);
	static bool getConstant(PowerState in, const char *&out);
private:
	static StringMap<PowerState, POWER_MAX_ENUM>::Entry powerEntries[];
	static StringMap<PowerState, POWER_MAX_ENUM> powerStates;
};

System *newDoraSystem(lua_State *L);

}
