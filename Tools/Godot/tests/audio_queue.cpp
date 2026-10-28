// Concurrency, wraparound, bounded backpressure and planar-silence checks.
#include "Source/Godot/GodotAudioQueue.h"
#include <cassert>
#include <thread>
#include <vector>
#include <cstdio>

int main() {
    Dora::GodotAudioQueue queue;
    constexpr uint32_t total=300000;
    std::vector<float> full((Dora::GodotAudioQueue::Capacity+1)*2,0.5f);
    assert(queue.push(full.data(),Dora::GodotAudioQueue::Capacity+1)==Dora::GodotAudioQueue::Capacity);
    assert(queue.push(full.data(),1)==0);
    std::vector<float> drained((Dora::GodotAudioQueue::Capacity+5)*2,123.0f);
    const uint32_t stride=Dora::GodotAudioQueue::Capacity+5;
    assert(queue.read(drained.data(),stride,stride)==Dora::GodotAudioQueue::Capacity);
    for (uint32_t c=0;c<2;++c) {
        for (uint32_t i=0;i<Dora::GodotAudioQueue::Capacity;++i) assert(drained[c*stride+i]==0.5f);
        for (uint32_t i=Dora::GodotAudioQueue::Capacity;i<stride;++i) assert(drained[c*stride+i]==0.0f);
    }
    assert(queue.available()==0);
    queue.resetQuiescent();
    std::thread producer([&] {
        float pcm[254]; uint32_t written=0;
        while (written<total) {
            const auto count=std::min<uint32_t>(127,total-written);
            for (uint32_t i=0;i<count;++i) { pcm[i*2]=float(written+i+1); pcm[i*2+1]=-pcm[i*2]; }
            written+=queue.push(pcm,count);
            std::this_thread::yield();
        }
    });
    uint32_t consumed=0;
    while (consumed<total) {
        // Use a nontrivial planar stride and leave guard samples in both planes.
        float pcm[274]; std::fill_n(pcm,274,123.0f);
        const auto requested=std::min<uint32_t>(131,total-consumed);
        const bool interleaved=(consumed%2)==0;
        const auto count=interleaved ? queue.readInterleaved(pcm,requested) : queue.read(pcm,requested,137);
        if (interleaved) {
            for (uint32_t i=0;i<count;++i) {
                assert(pcm[i*2]==float(consumed+i+1)); assert(pcm[i*2+1]==-pcm[i*2]);
            }
            for (uint32_t i=count*2;i<274;++i) assert(pcm[i]==123);
            consumed+=count; std::this_thread::yield(); continue;
        }
        for (uint32_t i=0;i<count;++i) {
            assert(pcm[i]==float(consumed+i+1)); assert(pcm[137+i]==-pcm[i]);
        }
        for (uint32_t i=count;i<requested;++i) assert(pcm[i]==0 && pcm[137+i]==0);
        for (uint32_t i=requested;i<137;++i) assert(pcm[i]==123 && pcm[137+i]==123);
        consumed+=count;
        std::this_thread::yield();
    }
    producer.join(); assert(queue.available()==0);
    puts("Godot audio SPSC queue: PASS (300000 stereo frames, GPU/audio device not tested)");
}
