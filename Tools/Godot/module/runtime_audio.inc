// Included inside the runtime namespace in both native backends.
// Native device callbacks use a bounded producer queue. Web mixes on demand
// on the window thread below, so browser callback bursts cannot starve it.
#ifdef WEB_ENABLED
constexpr uint32_t audio_target_frames=8192;
#else
constexpr uint32_t audio_target_frames=4096;
#endif
static_assert(audio_target_frames<=Dora::GodotAudioQueue::Capacity);
struct AudioCapture {
    Dora::GodotAudioQueue queue;
    Thread thread;
    std::atomic<bool> stop{true};
    std::atomic<uint64_t> produced{0},consumed{0},nonzero{0},underruns{0};
} audio_capture;
bool prepare_audio() {
    auto *driver=AudioDriverDummy::get_dummy_singleton();
    if (!driver) { runtime.error="Godot dummy audio driver is unavailable"; return false; }
    driver->set_use_threads(false);
    driver->set_mix_rate(48000);
    driver->set_speaker_mode(AudioDriver::SPEAKER_MODE_STEREO);
    return true;
}
bool audio_ready(void *handle) {
    return valid(handle) && AudioDriver::get_singleton()==AudioDriverDummy::get_dummy_singleton();
}
int audio_format(void *handle,DoraGodotAudioFormat *format) {
    if (!audio_ready(handle) || !format || format->size<sizeof(*format)) return 0;
    auto *driver=AudioDriverDummy::get_dummy_singleton();
    *format={sizeof(*format),(uint32_t)driver->get_mix_rate(),driver->get_channels()};
    return 1;
}
void produce_audio(uint32_t frames) {
    int32_t input[512*2]; float output[512*2];
    AudioDriverDummy::get_dummy_singleton()->mix_audio(frames,input);
    uint64_t nonzero=0;
    for (uint32_t i=0;i<frames*2;++i) {
        output[i]=float(double(input[i])/2147483648.0);
        if (output[i]>0.00001f || output[i]<-0.00001f) ++nonzero;
    }
    const auto written=audio_capture.queue.push(output,frames);
    audio_capture.produced.fetch_add(written,std::memory_order_relaxed);
    audio_capture.nonzero.fetch_add(nonzero,std::memory_order_relaxed);
}
void audio_worker(void *) {
    Thread::set_name("DoraGodotPCM");
    while (!audio_capture.stop.load(std::memory_order_acquire)) {
        const auto queued=audio_capture.queue.available();
        if (queued<audio_target_frames) produce_audio(MIN(512u,audio_target_frames-queued));
        else OS::get_singleton()->delay_usec(1000);
    }
}
int start_audio_capture(void *handle) {
    if (!audio_ready(handle)) return 0;
#ifdef WEB_ENABLED
    // Web host callbacks and Godot iteration share the window thread. Mix on
    // demand there: ScriptProcessor may deliver a backlog in one event turn,
    // faster than an independently scheduled pthread can refill a PCM queue.
    // AudioDriverDummy threading is disabled in prepare_audio().
    audio_capture.queue.resetQuiescent();
    audio_capture.produced=0; audio_capture.consumed=0; audio_capture.nonzero=0; audio_capture.underruns=0;
    audio_capture.stop=false;
    return 1;
#else
    if (audio_capture.thread.is_started()) return 1;
    audio_capture.queue.resetQuiescent();
    audio_capture.produced=0; audio_capture.consumed=0; audio_capture.nonzero=0; audio_capture.underruns=0;
    // Prime after preboot pause was applied, before the host source starts.
    for (uint32_t i=0;i<audio_target_frames/512;++i) produce_audio(512);
    audio_capture.stop.store(false,std::memory_order_release);
    audio_capture.thread.start(audio_worker,nullptr);
    if (!audio_capture.thread.is_started()) {
        audio_capture.stop=true; runtime.error="cannot start Godot PCM worker"; return 0;
    }
    return 1;
#endif
}
void stop_audio_capture() {
    audio_capture.stop.store(true,std::memory_order_release);
    if (audio_capture.thread.is_started()) audio_capture.thread.wait_to_finish();
}
uint32_t read_audio(void *handle,float *output,uint32_t frames) {
    if (!audio_ready(handle) || !output || !frames || frames>DORA_GODOT_AUDIO_MAX_FRAMES) return 0;
#ifdef WEB_ENABLED
    if (audio_capture.stop.load(std::memory_order_acquire)) return 0;
    // Produce exactly the requested samples in bounded blocks; no lookahead
    // buffer, sleeps, extra latency or competing producer on the Web path.
    for (uint32_t left=frames;left;) {
        const uint32_t count=MIN(512u,left);
        produce_audio(count);left-=count;
    }
#endif
    const auto count=audio_capture.queue.readInterleaved(output,frames);
    audio_capture.consumed.fetch_add(count,std::memory_order_relaxed);
    audio_capture.underruns.fetch_add(frames-count,std::memory_order_relaxed);
    return count;
}
int audio_stats(void *handle,DoraGodotAudioStats *stats) {
    if (!audio_ready(handle) || !stats || stats->size<sizeof(*stats)) return 0;
    *stats={sizeof(*stats),audio_capture.produced.load(),audio_capture.consumed.load(),
        audio_capture.nonzero.load(),audio_capture.underruns.load()};
    return 1;
}
