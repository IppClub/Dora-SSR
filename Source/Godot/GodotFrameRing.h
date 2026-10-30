// Copyright (c) 2026 Dora SSR contributors. MIT license (see repository LICENSE).
#pragma once
#include "GodotBridge.h"
#include <array>
#include <optional>

namespace Dora {
// Logic-thread display publication protocol. This records the node's logical
// reads; GPU backends additionally use GodotGpuReads to protect every actual
// host frame, including independent aliases of previously displayed textures.
class GodotFrameRing {
public:
    struct Read { uint32_t slot; uint64_t sequence, frame; };
    struct Reservation { uint32_t slot; uint64_t last_read, token; };
    bool configure(uint32_t buffers) {
        if (buffers < 2 || buffers > DORA_GODOT_MAX_BUFFERS) return false;
        _buffers=buffers; _current=0; _sequence=0; _lastFrame=0; _pending.reset();
        _lastReads.fill(0); _active=true;
        return true;
    }
    bool seed(uint32_t slot, uint64_t sequence) {
        if (!_active || _sequence || slot>=_buffers || !sequence) return false;
        _current=slot; _sequence=sequence; return true;
    }
    std::optional<Read> read(uint64_t frame) {
        if (!_active || !_sequence || frame<=_lastFrame) return std::nullopt;
        _lastFrame=frame; _lastReads[_current]=frame;
        return Read{_current,_sequence,frame};
    }
    std::optional<Reservation> reserve() {
        if (!_active || !_sequence || _pending) return std::nullopt;
        const uint32_t slot=(_current+1)%_buffers;
        _pending=Reservation{slot,_lastReads[slot],++_token};
        return _pending;
    }
    bool publish(const Reservation &reservation, uint64_t sequence) {
        if (!_active || !_pending || reservation.token!=_pending->token
            || reservation.slot!=_pending->slot || reservation.last_read!=_pending->last_read
            || sequence<=_sequence) return false;
        _current=reservation.slot; _sequence=sequence; _pending.reset(); return true;
    }
    bool defer(const Reservation &reservation) {
        if (!_active || !_pending || reservation.token!=_pending->token
            || reservation.slot!=_pending->slot || reservation.last_read!=_pending->last_read) return false;
        _pending.reset(); return true;
    }
    void close() { _active=false; _pending.reset(); }
private:
    std::array<uint64_t,DORA_GODOT_MAX_BUFFERS> _lastReads{};
    std::optional<Reservation> _pending;
    uint32_t _buffers=0, _current=0;
    uint64_t _sequence=0, _lastFrame=0, _token=0;
    bool _active=false;
};
}
