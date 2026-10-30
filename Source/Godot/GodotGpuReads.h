// Copyright (c) 2026 Dora SSR contributors. MIT license (see repository LICENSE).
#pragma once
#include "GodotBridge.h"
#include <array>

namespace Dora {
// Render-thread ledger. Every actual host GPU frame conservatively reads every
// ring slot, covering Texture2D aliases held by arbitrary Sprite/effect users.
// Producers run between host frame encodings, never from inside begin/end.
class GodotGpuReads {
public:
    bool configure(uint32_t buffers) {
        if (buffers<2 || buffers>DORA_GODOT_MAX_BUFFERS) return false;
        _buffers=buffers; _sequences.fill(0); _lastSequence=0; _lastSlot=0;
        _lastRead=0; _lastFrame=0; _encoding=0; _frames=0; _waits=0; _signals=0;
        return true;
    }
    // Quiescent generation switch: counters/monotonic production persist,
    // but replacement events have not consumed any host frame yet.
    bool replaceSlots() {
        if (!canProduce()) return false;
        _sequences.fill(0); _lastRead=0; _lastSlot=0; return true;
    }
    bool canProduce() const { return _buffers && !_encoding; }
    bool produced(uint32_t slot,uint64_t sequence) {
        if (!canProduce() || slot>=_buffers || sequence<=_lastSequence) return false;
        _sequences[slot]=sequence; _lastSequence=sequence; _lastSlot=slot; return true;
    }
    bool begin(uint64_t frame) {
        if (!_buffers || _encoding || frame<=_lastFrame) return false;
        _encoding=frame;
        for (uint32_t i=0;i<_buffers;++i) if (_sequences[i]) ++_waits;
        return true;
    }
    bool end(uint64_t frame) {
        if (!_encoding || _encoding!=frame) return false;
        _lastRead=frame; _lastFrame=frame; _encoding=0; ++_frames; _signals+=_buffers;
        return true;
    }
    uint32_t buffers() const { return _buffers; }
    uint64_t sequence(uint32_t slot) const { return _sequences[slot]; }
    uint64_t lastRead() const { return _lastRead; }
    uint32_t lastSlot() const { return _lastSlot; }
    uint64_t frames() const { return _frames; }
    uint64_t waits() const { return _waits; }
    uint64_t signals() const { return _signals; }
    bool pending() const { return _encoding!=0; }
private:
    std::array<uint64_t,DORA_GODOT_MAX_BUFFERS> _sequences{};
    uint32_t _buffers=0,_lastSlot=0;
    uint64_t _lastSequence=0,_lastRead=0,_lastFrame=0,_encoding=0,_frames=0,_waits=0,_signals=0;
};
}
