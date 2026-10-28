// Copyright (c) 2026 Dora SSR contributors. MIT license (see repository LICENSE).
#pragma once
#include <algorithm>
#include <array>
#include <atomic>
#include <cstdint>

namespace Dora {
// One Godot-owner producer and one host mixer consumer. Interleaved storage,
// planar output matching SoLoud. No allocation, locks, or Godot calls in read.
class GodotAudioQueue {
public:
    static constexpr uint32_t Capacity=8192;
    static_assert(std::atomic<uint32_t>::is_always_lock_free);
    static_assert((Capacity&(Capacity-1))==0); // Cursor wrap preserves slot indices.
    // Producer-thread query; the consumer can only increase available space.
    uint32_t available() const {
        const auto read=_read.load(std::memory_order_acquire);
        const auto write=_write.load(std::memory_order_acquire);
        return uint32_t(write-read);
    }
    uint32_t push(const float *interleaved,uint32_t frames) {
        const auto write=_write.load(std::memory_order_relaxed);
        const auto read=_read.load(std::memory_order_acquire);
        const auto count=std::min<uint32_t>(frames,Capacity-uint32_t(write-read));
        for (uint32_t i=0;i<count;++i) {
            const auto slot=(write+i)%Capacity;
            _samples[slot*2]=interleaved[i*2]; _samples[slot*2+1]=interleaved[i*2+1];
        }
        _write.store(write+count,std::memory_order_release);
        return count;
    }
    uint32_t read(float *planar,uint32_t frames,uint32_t stride) {
        const auto read=_read.load(std::memory_order_relaxed);
        const auto write=_write.load(std::memory_order_acquire);
        const auto count=std::min<uint32_t>(frames,uint32_t(write-read));
        for (uint32_t i=0;i<count;++i) {
            const auto slot=(read+i)%Capacity;
            planar[i]=_samples[slot*2]; planar[stride+i]=_samples[slot*2+1];
        }
        std::fill(planar+count,planar+frames,0.0f);
        std::fill(planar+stride+count,planar+stride+frames,0.0f);
        _read.store(read+count,std::memory_order_release);
        return count;
    }
    // Reset only while both endpoints are quiescent, before starting a client.
    void resetQuiescent() {
        _read.store(0,std::memory_order_relaxed); _write.store(0,std::memory_order_relaxed);
    }
    uint32_t readInterleaved(float *output,uint32_t frames) {
        const auto read=_read.load(std::memory_order_relaxed);
        const auto write=_write.load(std::memory_order_acquire);
        const auto count=std::min<uint32_t>(frames,uint32_t(write-read));
        for (uint32_t i=0;i<count;++i) {
            const auto slot=(read+i)%Capacity;
            output[i*2]=_samples[slot*2]; output[i*2+1]=_samples[slot*2+1];
        }
        _read.store(read+count,std::memory_order_release);
        return count;
    }
private:
    std::array<float,Capacity*2> _samples{};
    alignas(64) std::atomic<uint32_t> _read{0};
    alignas(64) std::atomic<uint32_t> _write{0};
};
}
