// Copyright (c) 2026 Dora SSR contributors. MIT license (see repository LICENSE).
#pragma once
#include "GodotBridgeAudio.h"
#include <memory>

namespace Dora {
// Construct/start/stop on the logic thread. Configure on the Godot owner
// thread before readiness publication; its registered worker produces PCM.
class GodotAudioStream {
public:
    GodotAudioStream();
    ~GodotAudioStream();
    bool configure(const DoraGodotAudioAPI &api,void *handle);
    bool start();
    void stop();
    void finish(); // Godot render thread, after the host mixer source has stopped.
private:
    struct Impl;
    std::unique_ptr<Impl> _impl;
};
}
