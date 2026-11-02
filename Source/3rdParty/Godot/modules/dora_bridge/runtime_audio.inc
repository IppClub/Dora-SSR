// Included inside the runtime namespace in both native backends.
// Native device callbacks use a bounded producer queue. Web mixes on demand
// on the window thread below, so browser callback bursts cannot starve it.
#ifdef WEB_ENABLED
constexpr uint32_t audio_target_frames=8192;
#elif defined(ANDROID_ENABLED)
// Cover observed mixer bursts plus producer scheduling jitter at 48 kHz.
// 128 ms bounded lookahead, 42.67 ms more than the previous 4096 frames.
constexpr uint32_t audio_target_frames=6144;
#else
constexpr uint32_t audio_target_frames=4096;
#endif
static_assert(audio_target_frames<=Dora::GodotAudioQueue::Capacity);
struct AudioCapture {
    Dora::GodotAudioQueue queue;
    Thread thread;
    // Opt-in test evidence: written by producer, inspected only after join.
    struct ProducerEvent { uint64_t at, gap, mix, produced; uint32_t queued; };
    std::array<ProducerEvent,64> producerEvents{};
    uint32_t producerEventCount=0;
    uint64_t producerLoops=0,producerStart=0,maxProducerGap=0,maxMixTime=0;
    bool traceProducer=false;
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
#ifdef ANDROID_ENABLED
    // Match the host SDL audio consumer without using realtime scheduling.
    JNIEnv *jni=get_jni_env();
    jclass process=jni->FindClass("android/os/Process");
    int tid=-1,before=0,after=0,failed=0;
    if (process) {
        jmethodID my_tid=jni->GetStaticMethodID(process,"myTid","()I");
        jmethodID get_priority=jni->GetStaticMethodID(process,"getThreadPriority","(I)I");
        jmethodID set_priority=jni->GetStaticMethodID(process,"setThreadPriority","(I)V");
        if (my_tid && get_priority && set_priority && !jni->ExceptionCheck()) {
            tid=jni->CallStaticIntMethod(process,my_tid);
            before=jni->CallStaticIntMethod(process,get_priority,tid);
            jni->CallStaticVoidMethod(process,set_priority,-16); // THREAD_PRIORITY_AUDIO
            if (jni->ExceptionCheck()) { jni->ExceptionClear();failed=1; }
            after=jni->CallStaticIntMethod(process,get_priority,tid);
        } else failed=1;
        jni->DeleteLocalRef(process);
    } else failed=1;
    if (jni->ExceptionCheck()) { jni->ExceptionClear();failed=1; }
    if (audio_capture.traceProducer) print_line(vformat("DORA_PCM_PRIORITY tid=%d before=%d after=%d failed=%d",tid,before,after,failed));
#endif
    uint64_t last=0;
    while (!audio_capture.stop.load(std::memory_order_acquire)) {
        const auto begin=audio_capture.traceProducer?OS::get_singleton()->get_ticks_usec():0;
        const auto queued=audio_capture.queue.available();
        const auto produced=audio_capture.produced.load(std::memory_order_relaxed);
        if (queued<audio_target_frames) produce_audio(MIN(512u,audio_target_frames-queued));
        const auto end=audio_capture.traceProducer?OS::get_singleton()->get_ticks_usec():0;
        if (audio_capture.traceProducer) {
            const auto gap=last?begin-last:0;
            const auto mix=queued<audio_target_frames?end-begin:0;
            audio_capture.maxProducerGap=MAX(audio_capture.maxProducerGap,gap);
            audio_capture.maxMixTime=MAX(audio_capture.maxMixTime,mix);
            ++audio_capture.producerLoops;
            if ((gap>8000 || mix>8000) && audio_capture.producerEventCount<audio_capture.producerEvents.size())
                audio_capture.producerEvents[audio_capture.producerEventCount++]={begin-audio_capture.producerStart,gap,mix,produced,queued};
            last=end;
        }
        if (queued>=audio_target_frames) OS::get_singleton()->delay_usec(1000);
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
    audio_capture.traceProducer=OS::get_singleton()->get_environment("DORA_GODOT_TEST_AUDIO")=="1";
    audio_capture.producerEventCount=0;audio_capture.producerLoops=0;audio_capture.maxProducerGap=0;audio_capture.maxMixTime=0;
    audio_capture.producerStart=OS::get_singleton()->get_ticks_usec();
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
    if (audio_capture.traceProducer) {
        print_line(vformat("DORA_PCM_PRODUCER loops=%d maxGapUs=%d maxMixUs=%d events=%d targetFrames=%d",audio_capture.producerLoops,audio_capture.maxProducerGap,audio_capture.maxMixTime,audio_capture.producerEventCount,audio_target_frames));
        for (uint32_t i=0;i<audio_capture.producerEventCount;++i) {
            const auto &e=audio_capture.producerEvents[i];
            print_line(vformat("DORA_PCM_PRODUCER_EVENT atUs=%d gapUs=%d mixUs=%d produced=%d queued=%d",e.at,e.gap,e.mix,e.produced,e.queued));
        }
        audio_capture.traceProducer=false;
    }
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
