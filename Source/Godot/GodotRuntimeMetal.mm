// Copyright (c) 2026 Dora SSR contributors. MIT license (see repository LICENSE).
#include "Const/Header.h"
#include "Godot/GodotNode.h"
#include "Godot/GodotAudio.h"
#include "Godot/GodotBridgeOutput.h"
#include "Godot/GodotBridgeIME.h"
#include "Godot/GodotBridgeViewport.h"
#include "Godot/GodotFrameRing.h"
#include "Godot/GodotGpuReads.h"
#include "Godot/GodotRenderBootQueue.h"
#include "Basic/Application.h"
#include "Basic/Content.h"
#import <Metal/Metal.h>
#include <dlfcn.h>
#include <atomic>
#include <filesystem>

NS_DORA_BEGIN
std::string godotMetalUnsupportedReason() {
#if BX_PLATFORM_IOS
    const auto *internal=bgfx::getInternalData();
    id<MTLDevice> device=internal?(__bridge id<MTLDevice>)internal->context:nil;
    if (!device || ![device supportsFamily:MTLGPUFamilyApple4])
        return "Godot requires Apple4 Metal GPU capabilities (including cube-map texture arrays); the current iOS GPU profile does not provide them";
#endif
    return {};
}
namespace {
class MetalSession;
std::shared_ptr<MetalSession> activeSession;
GodotRenderBootQueue bootQueue;
DoraGodotAPI api{};
DoraGodotAudioAPI audioAPI{};
DoraGodotOutputAPI outputAPI{};
DoraGodotIMEAPI imeAPI{};
DoraGodotViewportAPI viewportAPI{};
void *library = nullptr, *activeHandle = nullptr;
std::atomic<bool> clientReserved{false};
std::string loaderError;
void encodeFrame(bgfx::RendererType::Enum, uint32_t, void *, bool, void *);
bool loadAPI() {
    if (api.open) return true;
#if BX_PLATFORM_IOS
    loaderError=godotMetalUnsupportedReason();
    if (!loaderError.empty()) {
        return false;
    }
#endif
    const char *configured = std::getenv("DORA_GODOT_LIBRARY");
#if BX_PLATFORM_IOS
    const auto frameworks=NSBundle.mainBundle.privateFrameworksPath;
    std::string path=configured?configured:Path::concat({frameworks.UTF8String,"DoraGodot.framework/DoraGodot"_slice});
#else
    std::string path = configured ? configured : Path::concat({SharedContent.getAssetPath(), "libdora_godot.dylib"_slice});
#endif
    library = dlopen(path.c_str(), RTLD_NOW | RTLD_LOCAL | RTLD_FIRST);
    if (!library) { loaderError = dlerror(); return false; }
    auto getAPI = reinterpret_cast<DoraGodotGetAPI>(dlsym(library, "dora_godot_get_api"));
    DoraGodotAPI candidate{}; candidate.size=sizeof(candidate);
    if (!getAPI || !getAPI(DORA_GODOT_ABI_VERSION,&candidate) || candidate.size < sizeof(candidate)
        || candidate.abi_version != DORA_GODOT_ABI_VERSION || !candidate.version || !candidate.open || !candidate.last_error || !candidate.get_slot
        || !candidate.advance || !candidate.input || !candidate.set_paused || !candidate.restart_scene || !candidate.close || !candidate.shutdown) {
        loaderError = "incompatible or incomplete Dora/Godot bridge ABI"; return false;
    }
    auto getAudio=reinterpret_cast<DoraGodotGetAudioAPI>(dlsym(library,"dora_godot_get_audio_api"));
    if (getAudio) {
        audioAPI.size=sizeof(audioAPI);
        if (!getAudio(DORA_GODOT_AUDIO_ABI_VERSION,&audioAPI) || audioAPI.size<sizeof(audioAPI)
            || audioAPI.abi_version!=DORA_GODOT_AUDIO_ABI_VERSION || !audioAPI.get_format || !audioAPI.read_pcm || !audioAPI.start_capture || !audioAPI.get_stats) {
            loaderError="incompatible Dora/Godot audio extension"; return false;
        }
    }
    auto getViewport=reinterpret_cast<DoraGodotGetViewportAPI>(dlsym(library,"dora_godot_get_viewport_api"));
    if (getViewport) {
        viewportAPI.size=sizeof(viewportAPI);
        if (!getViewport(DORA_GODOT_VIEWPORT_ABI_VERSION,&viewportAPI) || viewportAPI.size<sizeof(viewportAPI)
            || viewportAPI.abi_version!=DORA_GODOT_VIEWPORT_ABI_VERSION || !viewportAPI.resize) {
            loaderError="incompatible Dora/Godot viewport extension"; return false;
        }
    }
    auto getOutput=reinterpret_cast<DoraGodotGetOutputAPI>(dlsym(library,"dora_godot_get_output_api"));
    if (getOutput) {
        outputAPI.size=sizeof(outputAPI);
        if (!getOutput(DORA_GODOT_OUTPUT_ABI_VERSION,&outputAPI) || outputAPI.size<sizeof(outputAPI)
            || outputAPI.abi_version!=DORA_GODOT_OUTPUT_ABI_VERSION || !outputAPI.get_size) {
            loaderError="incompatible Dora/Godot output extension"; return false;
        }
    }
    auto getIME=reinterpret_cast<DoraGodotGetIMEAPI>(dlsym(library,"dora_godot_get_ime_api"));
    if (getIME) {
        imeAPI.size=sizeof(imeAPI);
        if (!getIME(DORA_GODOT_IME_ABI_VERSION,&imeAPI) || imeAPI.size<sizeof(imeAPI)
            || imeAPI.abi_version!=DORA_GODOT_IME_ABI_VERSION || !imeAPI.get_state) {
            loaderError="incompatible Dora/Godot IME extension";return false;
        }
    }
    api = candidate;
    bgfx::setNativeFrameCallback(encodeFrame, nullptr);
    return true;
}
class MetalSession final : public GodotSession, public std::enable_shared_from_this<MetalSession> {
    struct NativeSlot { id<MTLTexture> texture=nil; id<MTLSharedEvent> ready=nil, consumed=nil; };
    NativeSlot _slots[DORA_GODOT_MAX_BUFFERS];
    GodotFrameRing _ring;
    GodotGpuReads _reads;
    GodotAudioStream _audio;
    std::vector<Ref<Texture2D>> _textures;
    std::vector<bgfx::TextureHandle> _pendingHandles;
    id<MTLCommandQueue> _consumerQueue=nil;
    uint32_t _buffers=0;
    int _width=0,_height=0;
    std::atomic<uint32_t> _generation{0};
    void *_handle=nullptr;
    bool _ownsReservation=false;
    bool _ready=false,_started=false;
    std::atomic<bool> _closing{false}, _requestedPaused{false};
    std::atomic<uint64_t> _consumers{0}, _gpuErrors{0};
    bool queryIME(DoraGodotIMEState &state) {
        state={sizeof(state),0,0,0,0};
        return imeAPI.get_state && imeAPI.get_state(_handle,&state) && acceptIMEState(state);
    }
    void fail(std::string message) {
        if (message.empty()) message="Godot operation failed without a runtime diagnostic";
        auto self=shared_from_this();
        SharedApplication.invokeInLogic([self,message=std::move(message)] {
            self->error(message);
            Error("GodotNode: {}",message);
            self->close();
        });
    }
    void boot(const std::string &project,const std::string &scene,int width,int height,int buffers,
        const std::vector<bgfx::TextureHandle> &handles) {
        auto self=shared_from_this();
        @autoreleasepool {
            if (self->_closing) return;
            DoraGodotConfig config{sizeof(config),DORA_GODOT_METAL,(uint32_t)width,(uint32_t)height,(uint32_t)buffers,
                project.c_str(),scene.c_str(),bgfx::getInternalData()->context};
            self->_handle=api.open(&config);
            if (!self->_handle) { self->fail(api.last_error(nullptr)); return; }
            activeHandle=self->_handle;
            if (self->_closing) return;
            for (int i=0;i<buffers;++i) {
                DoraGodotSlot slot{}; slot.size=sizeof(slot);
                if (!api.get_slot(self->_handle,i,&slot) || slot.format!=DORA_GODOT_RGBA8) { self->fail("invalid shared Metal slot"); return; }
                self->_slots[i]={(__bridge id<MTLTexture>)slot.texture,(__bridge id<MTLSharedEvent>)slot.ready_event,(__bridge id<MTLSharedEvent>)slot.consumed_event};
                if (bgfx::overrideInternal(handles[i],(uintptr_t)slot.texture)!=(uintptr_t)slot.texture) { self->fail("external Metal texture import failed"); return; }
            }
            api.set_paused(self->_handle,self->_requestedPaused.load());
            const uint64_t first=api.advance(self->_handle,0,0);
            DoraGodotIMEState initialIME{};const bool hasInitialIME=self->queryIME(initialIME);
            DoraGodotOutputSize initialOutput{};initialOutput.size=sizeof(initialOutput);
            if (!first && !(outputAPI.get_size && outputAPI.get_size(self->_handle,&initialOutput) && initialOutput.resize_pending
                && initialOutput.width && initialOutput.height && initialOutput.width<=8192 && initialOutput.height<=8192
                && (int(initialOutput.width)!=width || int(initialOutput.height)!=height))) {
                self->fail(api.last_error(self->_handle)); return;
            }
            if (first && !self->_reads.produced(0,first)) { self->fail("invalid initial Godot GPU production"); return; }
            activeSession=self;
            if (audioAPI.read_pcm && !self->_audio.configure(audioAPI,self->_handle)) { self->fail("Godot audio stream configuration failed"); return; }
            SharedApplication.invokeInLogic([self,width,height,first,initialOutput,initialIME,hasInitialIME] {
                if (self->_closing) return;
                auto *node=self->node();
                if (!node) { self->close(); return; }
                if (hasInitialIME) self->applyIME(initialIME);
                bgfx::TextureInfo info{}; bgfx::calcTextureSize(info,width,height,1,false,false,1,bgfx::TextureFormat::RGBA8);
                for (auto handle:self->_pendingHandles) self->_textures.emplace_back(Texture2D::create(handle,info,BGFX_SAMPLER_U_CLAMP|BGFX_SAMPLER_V_CLAMP));
                self->_pendingHandles.clear();
                if (!first) {
                    self->_ready=true;
                    if (!self->resizeImpl(initialOutput.width,initialOutput.height,true)) self->fail("initial Godot source output resize failed");
                    return;
                }
                if (!self->_ring.seed(0,first)) { self->fail("cannot seed Godot frame ring"); return; }
                self->_ready=true;
                if (!self->_audio.start()) { self->fail("Dora host audio mixer could not start Godot stream"); return; }
                self->_started=true;
                node->setTexture(self->_textures[0]);
                node->setTextureRect({0,0,(float)width,(float)height});
                self->running(true);
            });
        }
    }
public:
    void finishAudio() { _audio.finish(); }
    void reportReads() {
        Info("GodotRuntime readers: buffers={}, frames={}, waits={}, signals={}, pending={}, completed={}, gpuErrors={}",
            _reads.buffers(),_reads.frames(),_reads.waits(),_reads.signals(),int(_reads.pending()),_consumers.load(),_gpuErrors.load());
    }
    explicit MetalSession(GodotNode *node) : GodotSession(node) {}
    bool start(const std::string &project, const std::string &scene, int width, int height, int buffers) override {
        bool free=false;
        if (!clientReserved.compare_exchange_strong(free,true)) { error("Godot already has an active node"); return false; }
        if (bgfx::getRendererType()!=bgfx::RendererType::Metal) { clientReserved=false; error("Godot requires the Metal renderer on macOS"); return false; }
        _width=width; _height=height;
        _ownsReservation=true;
        _buffers=buffers; _ring.configure(buffers); _reads.configure(buffers);
        for (int i=0;i<buffers;++i) _pendingHandles.push_back(bgfx::createTexture2D(width,height,false,1,bgfx::TextureFormat::RGBA8,BGFX_SAMPLER_U_CLAMP|BGFX_SAMPLER_V_CLAMP));
        auto self=shared_from_this();
        const uint32_t resourceFrame=SharedApplication.getFrame()+1;
        const auto handles=_pendingHandles;
        SharedApplication.invokeInRender([self,project,scene,width,height,buffers,resourceFrame,handles] {
            if (self->_closing) return;
            if (!loadAPI()) { self->fail(loaderError); return; }
            bootQueue.schedule(resourceFrame,[self,project,scene,width,height,buffers,handles] {
                self->boot(project,scene,width,height,buffers,handles);
            });
        });
        return true;
    }
    void step() override {
        if (_closing || !_ready) return;
        auto self=shared_from_this();
        const uint32_t frame=SharedApplication.getFrame()+1;
        auto read=_ring.read(frame);
        if (!read) { fail("invalid Godot consumer frame"); return; }
        const auto generation=_generation.load();
        auto reservation=_ring.reserve();
        if (!reservation) return;
        SharedApplication.invokeInRender([self,reservation=*reservation,generation] {
            @autoreleasepool {
                if (self->_closing || self->_generation!=generation) return;
                if (!bgfx::submitNativeFrame()) { self->fail("cannot submit pending Metal host frame"); return; }
                // Protect all actual host reads, including aliases of slots
                // that the GodotNode itself is no longer displaying. Query on
                // the render thread so no future/unsubmitted frame is awaited.
                const auto lastRead=self->_reads.lastRead();
                const auto previous=self->_reads.lastSlot();
                if (!self->_reads.canProduce() || self->_slots[previous].ready.signaledValue<self->_reads.sequence(previous)) {
                    SharedApplication.invokeInLogic([self,reservation,generation] { if (!self->_closing && self->_generation==generation) self->_ring.defer(reservation); }); return;
                }
                const uint64_t sequence=api.advance(self->_handle,reservation.slot,lastRead);
                if (!sequence) {
                    DoraGodotOutputSize output{};output.size=sizeof(output);
                    if (outputAPI.get_size && outputAPI.get_size(self->_handle,&output) && output.resize_pending
                        && output.width && output.height && output.width<=8192 && output.height<=8192
                        && (int(output.width)!=self->_width || int(output.height)!=self->_height)) {
                        SharedApplication.invokeInLogic([self,reservation,generation,output] {
                            if (self->_closing || self->_generation!=generation) return;
                            if (!self->_ring.defer(reservation) || !self->resizeImpl(output.width,output.height,true))
                                self->fail("Godot source output resize negotiation failed");
                        });return;
                    }
                    self->fail(api.last_error(self->_handle)); return;
                }
                if (!self->_reads.produced(reservation.slot,sequence)) { self->fail("invalid Godot GPU publication"); return; }
                DoraGodotIMEState ime{};const bool imeChanged=self->queryIME(ime);
                SharedApplication.invokeInLogic([self,reservation,sequence,generation,ime,imeChanged] {
                    if (self->_closing || self->_generation!=generation) return;
                    if (imeChanged) self->applyIME(ime);
                    if (!self->_ring.publish(reservation,sequence)) { self->fail("stale Godot producer publication"); return; }
                    if (auto *node=self->node()) node->setTexture(self->_textures[reservation.slot]);
                });
            }
        });
    }
    bool pendingOutput(DoraGodotOutputSize &output,int width,int height,bool pendingOnly) {
        output={sizeof(output),0,0,0};
        return outputAPI.get_size && outputAPI.get_size(_handle,&output)
            && (!pendingOnly || output.resize_pending) && output.width && output.height
            && output.width<=8192 && output.height<=8192
            && (int(output.width)!=width || int(output.height)!=height);
    }
    void retrySourceResize(DoraGodotOutputSize output,uint32_t generation) {
        auto self=shared_from_this();
        SharedApplication.invokeInLogic([self,output,generation] {
            if (self->_closing || self->_generation!=generation) return;
            // These replacement wrappers have never been published. Prior
            // generation aliases remain owned by their Texture2D references.
            for (auto handle:self->_pendingHandles) bgfx::destroy(handle);
            self->_pendingHandles.clear();self->_ready=true;
            if (!self->resizeImpl(output.width,output.height,true,true)) self->fail("latest Godot output resize retry failed");
        });
    }
    bool resize(int width,int height) override { return resizeImpl(width,height,false); }
    bool resizeImpl(int width,int height,bool sourceOwned,bool force=false) {
        if (!_ready || _closing || !viewportAPI.resize) return false;
        if (!force && width==_width && height==_height) return true;
        _ready=false; _ring.close();
        const auto generation=++_generation;
        std::vector<bgfx::TextureHandle> handles;
        for (uint32_t i=0;i<_buffers;++i) {
            auto handle=bgfx::createTexture2D(width,height,false,1,bgfx::TextureFormat::RGBA8,BGFX_SAMPLER_U_CLAMP|BGFX_SAMPLER_V_CLAMP);
            if (!bgfx::isValid(handle)) { fail("cannot allocate resized Godot texture wrapper"); return false; }
            handles.push_back(handle); _pendingHandles.push_back(handle);
        }
        const auto resourceFrame=SharedApplication.getFrame()+1;
        auto self=shared_from_this();
        SharedApplication.invokeInRender([self,handles,width,height,generation,resourceFrame,sourceOwned] {
            bootQueue.schedule(resourceFrame,[self,handles,width,height,generation,sourceOwned] {
                // The resource callback runs inside bgfx frame encoding. Cross
                // back through logic so submission/draining occurs between frames.
                SharedApplication.invokeInLogic([self,handles,width,height,generation,sourceOwned] {
                    if (self->_closing) return;
                    SharedApplication.invokeInRender([self,handles,width,height,generation,sourceOwned] {
                        @autoreleasepool {
                            if (self->_closing || self->_generation!=generation) return;
                            if (!bgfx::submitNativeFrame()) { self->fail("cannot submit Metal frame before resize"); return; }
                            DoraGodotOutputSize latest{};
                            if (sourceOwned && self->pendingOutput(latest,width,height,false)) {
                                self->retrySourceResize(latest,generation);return;
                            }
                            if (self->_consumerQueue) {
                                id<MTLCommandBuffer> marker=[self->_consumerQueue commandBuffer];
                                [marker commit]; [marker waitUntilCompleted];
                                if (marker.status==MTLCommandBufferStatusError) { self->fail("Metal consumer resize drain failed"); return; }
                            }
                            if (!self->_reads.replaceSlots() || !viewportAPI.resize(self->_handle,width,height)) {
                                self->fail(api.last_error(self->_handle)); return;
                            }
                            for (uint32_t i=0;i<self->_buffers;++i) {
                                DoraGodotSlot slot{}; slot.size=sizeof(slot);
                                if (!api.get_slot(self->_handle,i,&slot) || slot.width!=uint32_t(width) || slot.height!=uint32_t(height)
                                    || slot.format!=DORA_GODOT_RGBA8 || !slot.texture || !slot.ready_event || !slot.consumed_event
                                    || bgfx::overrideInternal(handles[i],(uintptr_t)slot.texture)!=(uintptr_t)slot.texture) {
                                    self->fail("resized Metal texture import failed"); return;
                                }
                                self->_slots[i]={(__bridge id<MTLTexture>)slot.texture,(__bridge id<MTLSharedEvent>)slot.ready_event,(__bridge id<MTLSharedEvent>)slot.consumed_event};
                            }
                            const auto sequence=api.advance(self->_handle,0,0);
                            if (!sequence && self->pendingOutput(latest,width,height,true)) {
                                self->retrySourceResize(latest,generation);return;
                            }
                            if (!sequence || !self->_reads.produced(0,sequence)) { self->fail("resized Metal first frame failed"); return; }
                            SharedApplication.invokeInLogic([self,width,height,sequence,generation] {
                                if (self->_closing || self->_generation!=generation) return;
                                auto *target=self->node(); if (!target) { self->close(); return; }
                                bgfx::TextureInfo info{}; bgfx::calcTextureSize(info,width,height,1,false,false,1,bgfx::TextureFormat::RGBA8);
                                self->_textures.clear();
                                for (auto handle:self->_pendingHandles) self->_textures.emplace_back(Texture2D::create(handle,info,BGFX_SAMPLER_U_CLAMP|BGFX_SAMPLER_V_CLAMP));
                                self->_pendingHandles.clear();
                                self->_ring.configure(self->_buffers);
                                if (!self->_ring.seed(0,sequence)) { self->fail("cannot seed resized Metal ring"); return; }
                                target->setTexture(self->_textures[0]); self->resized(width,height);
                                self->_width=width; self->_height=height; self->_ready=true;
                                if (!self->_started) {
                                    if (!self->_audio.start()) { self->fail("Dora host audio mixer could not start Godot stream"); return; }
                                    self->_started=true;self->running(true);
                                }
                                Info("GodotRuntime resized: width={}, height={}, generation={}",width,height,generation);
                            });
                        }
                    });
                });
            });
        });
        return true;
    }
    void encode(void *native,uint32_t frame,bool end) {
        id<MTLCommandBuffer> command=(__bridge id<MTLCommandBuffer>)native;
        _consumerQueue=command.commandQueue;
        if (!end) {
            if (!_reads.begin(frame)) { fail("invalid Godot GPU consumer begin"); return; }
            for (uint32_t slot=0;slot<_buffers;++slot) if (_reads.sequence(slot))
                [command encodeWaitForEvent:_slots[slot].ready value:_reads.sequence(slot)];
        } else {
            if (!_reads.end(frame)) { fail("invalid Godot GPU consumer end"); return; }
            for (uint32_t slot=0;slot<_buffers;++slot)
                [command encodeSignalEvent:_slots[slot].consumed value:frame];
            auto self=shared_from_this();
            [command addCompletedHandler:^(id<MTLCommandBuffer> done) {
                if (done.status==MTLCommandBufferStatusError) ++self->_gpuErrors;
                ++self->_consumers;
            }];
        }
    }
    void close() override {
        if (_closing.exchange(true) || !_ownsReservation) return;
        releaseIME();
        _audio.stop();
        running(false);
        _ring.close();
        _textures.clear();
        for (auto handle:_pendingHandles) bgfx::destroy(handle);
        _pendingHandles.clear();
        auto self=shared_from_this();
        SharedApplication.invokeInRender([self] {
            @autoreleasepool {
                self->_audio.finish();
                bgfx::submitNativeFrame();
                // Closing is not a steady-state frame path: drain consumer work
                // before releasing the producer's native ring and scene client.
                if (self->_consumerQueue) { id<MTLCommandBuffer> marker=[self->_consumerQueue commandBuffer]; [marker commit]; [marker waitUntilCompleted]; }
                self->reportReads();
                if (self->_handle && activeHandle==self->_handle) {
                    DoraGodotStats stats{}; stats.size=sizeof(stats); api.close(self->_handle,&stats);
                    Info("GodotRuntime client closed: produced={}, completed={}, gpuErrors={}",stats.produced,stats.completed,stats.gpu_errors+self->_gpuErrors.load());
                    activeHandle=nullptr;
                    activeSession.reset();
                }
                self->_handle=nullptr;
                clientReserved=false;
            }
        });
    }
    void pause(bool value) override {
        _requestedPaused=value;
        auto self=shared_from_this();
        SharedApplication.invokeInRender([self,value] { if (!self->_closing && self->_handle) api.set_paused(self->_handle,value); });
    }
    bool restart(const std::string &scene) override {
        if (!_ready || _closing) return false;
        auto self=shared_from_this();
        SharedApplication.invokeInRender([self,scene] { if (!self->_closing && !api.restart_scene(self->_handle,scene.c_str())) self->fail(api.last_error(self->_handle)); });
        return true;
    }
    void input(DoraGodotInput event, std::string text) override {
        auto self=shared_from_this();
        SharedApplication.invokeInRender([self,event,text=std::move(text)]() mutable {
            event.text=text.c_str();
            if (!self->_closing && self->_handle) api.input(self->_handle,&event);
        });
    }
};
void encodeFrame(bgfx::RendererType::Enum renderer,uint32_t frame,void *native,bool end,void *) {
    if (renderer!=bgfx::RendererType::Metal) return;
    if (!end) bootQueue.drain(frame);
    if (activeSession) activeSession->encode(native,frame,end);
}
}
std::shared_ptr<GodotSession> createGodotMetalSession(GodotNode *node) { return std::make_shared<MetalSession>(node); }
void shutdownGodotMetalRuntime() {
    bootQueue.clear();
    bgfx::setNativeFrameCallback(nullptr,nullptr);
    if (api.shutdown) {
        if (activeHandle) {
            if (activeSession) activeSession->finishAudio();
            if (activeSession) activeSession->reportReads();
            DoraGodotStats stats{}; stats.size=sizeof(stats); api.close(activeHandle,&stats);
            Info("GodotRuntime shutdown: produced={}, completed={}, gpuErrors={}",stats.produced,stats.completed,stats.gpu_errors);
            activeHandle=nullptr;
        }
        api.shutdown();
        activeSession.reset();
    }
    clientReserved=false;
    // ObjC classes and Godot singletons stay loaded until process termination.
}
NS_DORA_END
