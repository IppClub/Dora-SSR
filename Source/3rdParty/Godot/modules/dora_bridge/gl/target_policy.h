#pragma once
#include <cstring>

namespace DoraGodotGLTargetPolicy {
enum class Mode { Direct, Blit, Error };
struct Decision { Mode mode; const char *policy; const char *reason; };

// Validated direct-target transports use zero-copy by default. Explicit blit
// remains available for driver compatibility and diagnostics.
inline Decision decide(const char *requested,bool direct_capable) {
    if (!requested || !*requested)
        return direct_capable ? Decision{Mode::Direct,"default","validated-direct-target"}
                              : Decision{Mode::Blit,"default","direct-target-unsupported"};
    if (std::strcmp(requested,"0")==0 || std::strcmp(requested,"blit")==0)
        return {Mode::Blit,"forced","explicit-compatibility-fallback"};
    if (std::strcmp(requested,"auto")==0)
        return direct_capable ? Decision{Mode::Direct,"auto","direct-target-supported"}
                              : Decision{Mode::Blit,"auto","direct-target-unsupported"};
    if (std::strcmp(requested,"1")==0 || std::strcmp(requested,"direct")==0)
        return direct_capable ? Decision{Mode::Direct,"forced","explicit-direct"}
                              : Decision{Mode::Error,"forced","direct-target-unsupported"};
    return {Mode::Error,"invalid","invalid-DORA_GODOT_GL_DIRECT"};
}
inline const char *name(Mode mode) {
    switch (mode) {
        case Mode::Direct: return "direct";
        case Mode::Blit: return "blit";
        default: return "error";
    }
}
}
