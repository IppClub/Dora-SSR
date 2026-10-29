#pragma once
#include "GodotBridgeIME.h"

// The custom display server and bridge API can live in different translation
// units. C++17 inline storage gives the loaded LibGodot image one shared state.
namespace DoraGodotIME {
inline DoraGodotIMEState state{sizeof(DoraGodotIMEState),0,0,0,1};
inline void set_active(bool active) {
    const uint32_t value=active?1u:0u;
    if (state.active!=value) { state.active=value; ++state.revision; }
}
inline void set_position(int x,int y) {
    if (state.x!=x || state.y!=y) { state.x=x;state.y=y;++state.revision; }
}
inline void reset() {
    state.active=0;state.x=0;state.y=0;++state.revision;
}
inline void snapshot(DoraGodotIMEState *output) {
    *output=state;output->size=sizeof(*output);
}
}
