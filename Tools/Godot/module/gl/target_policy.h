#pragma once
#include <cstring>

namespace DoraGodotGLTargetPolicy {
enum class Mode { Direct, Blit, Error };
struct Decision { Mode mode; const char *policy; const char *reason; };

// The unset option intentionally keeps the established compatibility default
// until comparable performance evidence exists, but is always diagnosed.
inline Decision decide(const char *requested,bool direct_capable) {
    if (!requested || !*requested)
        return {Mode::Blit,"legacy-default","performance-baseline-pending"};
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
