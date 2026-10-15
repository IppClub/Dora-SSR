#pragma once

namespace DoraWebAudio {
// Versioned together with the content-hashed mixer and processor artifacts.
enum SourceField {
	Mode, Delay, Volume, Pan, Speed, Loop, Protected, LoopPoint,
	X, Y, Z, VX, VY, VZ, DX, DY, DZ, ConeInner, ConeOuter, ConeVolume,
	ConeHighGain, AirAbsorption, MinDistance, MaxDistance, Attenuation,
	Rolloff, Doppler, ListenerRelative, HasVolumeLimits, MinVolume, MaxVolume,
	SourceFields
};
constexpr unsigned ListenerFields = 15;
enum BusOp {
	CreateBus, DestroyBus, BusVolume, BusPan, BusSpeed,
	FadeBusVolume, FadeBusPan, FadeBusSpeed, BusFilter, BusParameter, FadeBusParameter
};
static_assert(SourceFields == 31, "Update the JS wire protocol when adding source fields");
}
