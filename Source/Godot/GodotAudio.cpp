// Copyright (c) 2026 Dora SSR contributors. MIT license (see repository LICENSE).
#include "Const/Header.h"
#include "Godot/GodotAudio.h"
#include "Audio/Audio.h"
#include "soloud.h"
#include "SDL_timer.h"
#include <algorithm>
#include <atomic>
#include <array>
#include <cmath>

namespace Dora {
namespace {
struct AudioState {
    DoraGodotAudioAPI api{};
    void *handle=nullptr;
    std::atomic<uint64_t> consumed{0},underruns{0},nonzero{0};
    std::atomic<bool> ended{false};
    // Opt-in test evidence, allocated on the logic thread. The callback only
    // writes bounded preallocated memory; stop() drains it before inspection.
    std::vector<float> capture;
    uint32_t captured=0;
    struct Underrun {
        uint64_t callback=0,at=0,gap=0,produced=0;
        uint32_t requested=0,received=0;
    };
    std::array<Underrun,64> underrunEvents{};
    uint32_t eventCount=0,maxRequest=0;
    uint64_t callbacks=0,firstCounter=0,lastCounter=0,maxGap=0;
    AudioState() {
        const char *test=std::getenv("DORA_GODOT_TEST_AUDIO");
        if (test && std::string(test)=="1") capture.resize(48000*2);
    }
};
class GodotSource final:public SoLoud::AudioSource {
    std::shared_ptr<AudioState> _state;
    class Instance final:public SoLoud::AudioSourceInstance {
        std::shared_ptr<AudioState> _state;
    public:
        explicit Instance(std::shared_ptr<AudioState> state):_state(std::move(state)) {}
        unsigned int getAudio(float *output,unsigned int frames,unsigned int stride) override {
            uint64_t now=0,gap=0;
            if (!_state->capture.empty()) {
                now=SDL_GetPerformanceCounter();
                if (!_state->callbacks) _state->firstCounter=now;
                else gap=now-_state->lastCounter;
                _state->lastCounter=now;
                _state->maxGap=std::max(_state->maxGap,gap);
                _state->maxRequest=std::max(_state->maxRequest,frames);
                ++_state->callbacks;
            }
            uint32_t count=0;
            float pcm[DORA_GODOT_AUDIO_MAX_FRAMES*2];
            for (uint32_t offset=0;offset<frames;) {
                const auto requested=std::min<uint32_t>(frames-offset,DORA_GODOT_AUDIO_MAX_FRAMES);
                const auto got=_state->api.read_pcm(_state->handle,pcm,requested);
                for (uint32_t i=0;i<requested;++i) {
                    output[offset+i]=i<got ? pcm[i*2] : 0.0f;
                    output[stride+offset+i]=i<got ? pcm[i*2+1] : 0.0f;
                }
                count+=got; offset+=requested;
                if (got<requested) {
                    std::fill(output+offset,output+frames,0.0f);
                    std::fill(output+stride+offset,output+stride+frames,0.0f);
                    break;
                }
            }
            _state->consumed.fetch_add(count,std::memory_order_relaxed);
            _state->underruns.fetch_add(frames-count,std::memory_order_relaxed);
            if (count<frames && !_state->capture.empty() && _state->eventCount<_state->underrunEvents.size()) {
                DoraGodotAudioStats stats{};stats.size=sizeof(stats);
                if (_state->api.get_stats) _state->api.get_stats(_state->handle,&stats);
                _state->underrunEvents[_state->eventCount++]={_state->callbacks,now-_state->firstCounter,gap,stats.produced,frames,count};
            }
            uint64_t nonzero=0;
            for (uint32_t i=0;i<count;++i) {
                if (std::abs(output[i])>0.00001f) ++nonzero;
                if (std::abs(output[stride+i])>0.00001f) ++nonzero;
            }
            _state->nonzero.fetch_add(nonzero,std::memory_order_relaxed);
            if (!_state->capture.empty()) {
                // Ignore preboot/pause silence while collecting the first
                // complete second of the deterministic test tone.
                if (count && !nonzero && _state->captured<48000) _state->captured=0;
                for (uint32_t i=0;i<count && _state->captured<48000;++i) {
                    if (!_state->captured && std::abs(output[i])<0.00001f) continue;
                    const auto sample=_state->captured++;
                    _state->capture[sample*2]=output[i];
                    _state->capture[sample*2+1]=output[stride+i];
                }
            }
            // Keep the source alive across underruns; unavailable samples are
            // already zeroed. The native callback only copies its lock-free PCM queue.
            return frames;
        }
        bool hasEnded() override { return _state->ended.load(std::memory_order_acquire); }
    };
public:
    explicit GodotSource(std::shared_ptr<AudioState> state):_state(std::move(state)) {
        mBaseSamplerate=48000; mChannels=2; setSingleInstance(true);
        setInaudibleBehavior(true,false);
    }
    SoLoud::AudioSourceInstance *createInstance() override { return new Instance(_state); }
};
}
struct GodotAudioStream::Impl {
    std::shared_ptr<AudioState> state=std::make_shared<AudioState>();
    std::unique_ptr<GodotSource> source=std::make_unique<GodotSource>(state);
    DoraGodotAudioAPI api{};
    void *handle=nullptr;
    bool started=false;
};
GodotAudioStream::GodotAudioStream():_impl(std::make_unique<Impl>()) {}
GodotAudioStream::~GodotAudioStream() { stop(); }
bool GodotAudioStream::configure(const DoraGodotAudioAPI &api,void *handle) {
    DoraGodotAudioFormat format{}; format.size=sizeof(format);
    if (!api.get_format || !api.read_pcm || !api.start_capture || !api.get_stats
        || !api.get_format(handle,&format)
        || format.sample_rate!=48000 || format.channels!=2 || !api.start_capture(handle)) return false;
    _impl->api=api; _impl->handle=handle;
    _impl->state->api=api; _impl->state->handle=handle;
    return true;
}
bool GodotAudioStream::start() {
    auto &impl=*_impl;
    if (!impl.api.read_pcm) return true; // Older optional libraries have no audio.
    if (!impl.started && impl.api.read_pcm && !impl.state->ended.load()) {
        auto *mixer=SharedAudio.getSoLoud();
        if (!mixer) return false;
        if (!impl.state->capture.empty()) Info("GodotAudio host device: rate={}, bufferFrames={}",
            mixer->getBackendSamplerate(),mixer->getBackendBufferSize());
        const auto voice=mixer->play(*impl.source);
        if (!voice) return false;
        SharedAudio.addRef(voice,nullptr,nullptr);
        impl.started=true;
    }
    return impl.started;
}
void GodotAudioStream::stop() {
    auto &impl=*_impl;
    if (impl.state->ended.exchange(true,std::memory_order_acq_rel)) return;
    // Destroy on the logic thread while the host mixer is still alive. Queued
    // render work retains only Impl/state, never the SoLoud source.
    impl.source.reset();
    // The owner reports worker counters after this callback is quiescent.
    if (impl.started) Info("GodotAudio stopped: consumed={}, underrunFrames={}",impl.state->consumed.load(),impl.state->underruns.load());
}
void GodotAudioStream::finish() {
    auto &impl=*_impl;
    DoraGodotAudioStats stats{}; stats.size=sizeof(stats);
    if (impl.api.get_stats) impl.api.get_stats(impl.handle,&stats);
    if (impl.api.read_pcm) Info("GodotAudio drained: produced={}, consumed={}, nonzeroProduced={}, nonzeroConsumed={}, underrunFrames={}",
        stats.produced,impl.state->consumed.load(),stats.nonzero_produced,impl.state->nonzero.load(),impl.state->underruns.load());
    if (!impl.state->capture.empty()) {
        const auto frequency=SDL_GetPerformanceFrequency();
        const auto microseconds=[frequency](uint64_t ticks){return frequency?ticks*1000000/frequency:0;};
        Info("GodotAudio callbacks: count={}, maxRequest={}, maxGapUs={}, underrunEvents={}",
            impl.state->callbacks,impl.state->maxRequest,microseconds(impl.state->maxGap),impl.state->eventCount);
        for (uint32_t i=0;i<impl.state->eventCount;++i) {
            const auto &event=impl.state->underrunEvents[i];
            Info("GodotAudio underrun: callback={}, requested={}, received={}, atUs={}, gapUs={}, produced={}",
                event.callback,event.requested,event.received,microseconds(event.at),microseconds(event.gap),event.produced);
        }
        uint32_t crossings[2]{};
        for (uint32_t i=1;i<impl.state->captured;++i) {
            for (uint32_t c=0;c<2;++c) {
                if (impl.state->capture[(i-1)*2+c]<=0 && impl.state->capture[i*2+c]>0) ++crossings[c];
            }
        }
        Info("GodotAudio tone: frames={}, leftCrossings={}, rightCrossings={}",impl.state->captured,crossings[0],crossings[1]);
    }
    impl.api={};
}
}
