#include "System.h"

namespace love::system
{

StringMap<System::PowerState, System::POWER_MAX_ENUM>::Entry System::powerEntries[] =
{
	{"unknown", POWER_UNKNOWN}, {"battery", POWER_BATTERY},
	{"nobattery", POWER_NO_BATTERY}, {"charging", POWER_CHARGING},
	{"charged", POWER_CHARGED},
};

StringMap<System::PowerState, System::POWER_MAX_ENUM> System::powerStates(
	System::powerEntries, sizeof(System::powerEntries));

bool System::getConstant(const char *in, PowerState &out) { return powerStates.find(in, out); }
bool System::getConstant(PowerState in, const char *&out) { return powerStates.find(in, out); }

}
