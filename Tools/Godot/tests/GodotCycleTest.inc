// Repeated clients in one process, with every capture/close fully observed.
#if BX_PLATFORM_OSX || BX_PLATFORM_IOS
extern "C" int64_t dora_godot_test_metal_bytes();
#endif
int startCycleTest(int count) {
    struct State {
        int index=0,phase=0,ticks=0;
        std::atomic<bool> sampled{false};
        std::chrono::steady_clock::time_point boot;
    };
    auto state=std::make_shared<State>();
    std::filesystem::create_directories(std::filesystem::u8path(output));
    SharedDirector.setClearColor(Dora::Color(0xff192331));
    SharedDirector.beginGameCapture();
    auto *controller=Dora::Node::create();SharedDirector.getUI()->addChild(controller);
    controller->schedule([state,count](double) {
        if (capturePending) return false;
        auto fail=[] {result=2;stopGodotTest();return true;};
        if (state->phase==0) {
            godot=Dora::GodotNode::create(project,"res://main.tscn",640,360,testBuffers);
            if (!godot) return fail();
            godot->setScaleX(1.25f);godot->setScaleY(1.25f);
            SharedDirector.getUI()->addChild(godot);
            ++state->index;state->ticks=0;state->phase=1;
            state->boot=std::chrono::steady_clock::now();
            fprintf(stderr,"GODOT_CYCLE_CREATE index=%d\n",state->index);
        } else if (state->phase==1) {
            if (!godot || !godot->getLastError().empty()) return fail();
            if (!godot->isRunning()) {
                if (std::chrono::steady_clock::now()-state->boot>std::chrono::seconds(30)) return fail();
                return false;
            }
            ++state->ticks;
            const auto prefix="cycle-"+std::to_string(state->index);
            if (state->ticks==30) capture(prefix+"-a.png");
            if (state->ticks==60) capture(prefix+"-b.png");
            if (state->ticks==90) {
                godot->removeFromParent();godot=nullptr;state->ticks=0;state->phase=2;
            }
        } else if (state->phase==2) {
            ++state->ticks;
            if (state->ticks==30) capture("cycle-"+std::to_string(state->index)+"-removed.png");
            if (state->ticks==60) {
                state->sampled.store(false,std::memory_order_relaxed);state->phase=3;
                // getStats takes bgfx's resource API lock. Read it on the API
                // thread: the logic thread may hold that lock while frame()
                // waits for the render thread, so querying in its callback
                // can deadlock.
                const auto *stats=bgfx::getStats();
                struct Resources {
                    uint32_t textures,programs,shaders,framebuffers;
                    int64_t textureBytes,rtBytes;
                };
                const Resources resources{stats->numTextures,stats->numPrograms,stats->numShaders,stats->numFrameBuffers,
                    stats->textureMemoryUsed,stats->rtMemoryUsed};
                SharedApplication.invokeInRender([state,resources] {
                    int64_t metal=-1;
#if BX_PLATFORM_OSX || BX_PLATFORM_IOS
                    metal=dora_godot_test_metal_bytes();
#endif
                    fprintf(stderr,"GODOT_CYCLE_IDLE index=%d textures=%u programs=%u shaders=%u framebuffers=%u textureBytes=%lld rtBytes=%lld metalBytes=%lld\n",
                        state->index,resources.textures,resources.programs,resources.shaders,resources.framebuffers,
                        (long long)resources.textureBytes,(long long)resources.rtBytes,(long long)metal);
                    state->sampled.store(true,std::memory_order_release);
                });
            }
        } else if (state->sampled.load(std::memory_order_acquire)) {
            if (state->index==count) {
                if (captures!=count*3) return fail();
                fprintf(stderr,"GODOT_CYCLES_DONE count=%d captures=%d result=%d\n",count,captures,result);
                stopGodotTest();return true;
            }
            state->phase=0;
        }
        return false;
    });
    return 1;
}
