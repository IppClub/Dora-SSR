// Native GL backend: Linux/Android EGL / Windows WGL. The module owns a shared context.
#include "Const/Header.h"
#include "Godot/GodotNode.h"
#include "Godot/GodotAudio.h"
#include "Godot/GodotBridgeOutput.h"
#include "Godot/GodotBridgeIME.h"
#include "Godot/GodotFrameRing.h"
#include "Godot/GodotGpuReads.h"
#include "Godot/GodotRenderBootQueue.h"
#include "Godot/GodotBridgeGL.h"
#include "Godot/GodotBridgeGLTargets.h"
#include "Basic/Application.h"
#include "Basic/Content.h"
#if BX_PLATFORM_WINDOWS
#include "Other/utf8.h"
#include <windows.h>
#include <GL/gl.h>
#else
#include <GLES3/gl3.h>
#if !BX_PLATFORM_EMSCRIPTEN
#include <dlfcn.h>
#endif
#endif
#if BX_PLATFORM_ANDROID
#include "Godot/GodotBridgeAndroid.h"
#include "Godot/GodotAndroidPlatform.h"
#endif
#if BX_PLATFORM_EMSCRIPTEN
#include "Godot/GodotWebAPI.h"
#endif
#include <atomic>
NS_DORA_BEGIN
namespace {
class GLSession;
std::shared_ptr<GLSession> activeSession;
GodotRenderBootQueue bootQueue;
DoraGodotAPI api{}; DoraGodotGLAPI glAPI{};
DoraGodotAudioAPI audioAPI{};
DoraGodotOutputAPI outputAPI{};
DoraGodotIMEAPI imeAPI{};
DoraGodotGLTargetsAPI targetsAPI{};
void *library=nullptr,*activeHandle=nullptr;
std::atomic<bool> clientReserved{false};
std::string loaderError;
void encodeFrame(bgfx::RendererType::Enum,uint32_t,void *,bool,void *);
void shutdownInterop(bgfx::RendererType::Enum,void *);
bool loadAPI() {
    if (api.open) return true;
#if BX_PLATFORM_EMSCRIPTEN
    if(!loadGodotWebAPI(api,glAPI,audioAPI,targetsAPI,outputAPI,imeAPI,loaderError))return false;
#else
#if BX_PLATFORM_WINDOWS
    // Read the OS Unicode environment directly; CRT getenv may use a local
    // code page and cannot represent every DLL path supplied by the host.
    SetLastError(ERROR_SUCCESS);
    const DWORD length=GetEnvironmentVariableW(L"DORA_GODOT_LIBRARY",nullptr,0);
    std::wstring nativePath;
    if (length) {
        nativePath.resize(length);
        const DWORD copied=GetEnvironmentVariableW(L"DORA_GODOT_LIBRARY",nativePath.data(),length);
        if (!copied || copied>=length) { loaderError="cannot read DORA_GODOT_LIBRARY consistently"; return false; }
        nativePath.resize(copied);
    } else if (GetLastError()==ERROR_ENVVAR_NOT_FOUND) {
        const auto utf16=CodeCvt::utf8to16(Path::concat({SharedContent.getAssetPath(),"dora_godot.dll"_slice}));
        nativePath.assign(utf16.begin(),utf16.end());
    } else { loaderError="DORA_GODOT_LIBRARY is empty or unreadable"; return false; }
    auto module=LoadLibraryW(nativePath.c_str());
    library=module;
    if (!library) { loaderError="cannot load Dora/Godot runtime DLL, Win32 error "+std::to_string(GetLastError()); return false; }
    auto getAPI=reinterpret_cast<DoraGodotGetAPI>(GetProcAddress(module,"dora_godot_get_api"));
    auto getGL=reinterpret_cast<DoraGodotGetGLAPI>(GetProcAddress(module,"dora_godot_get_gl_api"));
#else
    const char *configured=std::getenv("DORA_GODOT_LIBRARY");
#if BX_PLATFORM_ANDROID
    std::string path=configured?configured:"libgodot_android.so";
#else
    std::string path=configured?configured:Path::concat({SharedContent.getAssetPath(),"libdora_godot.so"_slice});
#endif
    library=dlopen(path.c_str(),RTLD_NOW|RTLD_LOCAL);
    if (!library) { loaderError=dlerror(); return false; }
    auto getAPI=reinterpret_cast<DoraGodotGetAPI>(dlsym(library,"dora_godot_get_api"));
    auto getGL=reinterpret_cast<DoraGodotGetGLAPI>(dlsym(library,"dora_godot_get_gl_api"));
#endif
    DoraGodotAPI candidate{}; candidate.size=sizeof(candidate);
    DoraGodotGLAPI extension{}; extension.size=sizeof(extension);
    if (!getAPI || !getGL || !getAPI(DORA_GODOT_ABI_VERSION,&candidate)
        || candidate.size<sizeof(candidate) || candidate.abi_version!=DORA_GODOT_ABI_VERSION
        || !candidate.version || !candidate.open || !candidate.last_error || !candidate.get_slot || !candidate.advance
        || !candidate.input || !candidate.set_paused || !candidate.restart_scene || !candidate.close || !candidate.shutdown
        || !getGL(DORA_GODOT_GL_ABI_VERSION,&extension) || extension.size<sizeof(extension)
        || extension.abi_version!=DORA_GODOT_GL_ABI_VERSION || !extension.can_produce || !extension.consumer_begin || !extension.consumer_end
        || !extension.can_advance || !extension.advance_async) {
        loaderError="incompatible or incomplete Dora/Godot GL ABI"; return false;
    }
#if BX_PLATFORM_WINDOWS
    auto getAudio=reinterpret_cast<DoraGodotGetAudioAPI>(GetProcAddress(module,"dora_godot_get_audio_api"));
#else
    auto getAudio=reinterpret_cast<DoraGodotGetAudioAPI>(dlsym(library,"dora_godot_get_audio_api"));
#endif
    if (getAudio) {
        audioAPI.size=sizeof(audioAPI);
        if (!getAudio(DORA_GODOT_AUDIO_ABI_VERSION,&audioAPI) || audioAPI.size<sizeof(audioAPI)
            || audioAPI.abi_version!=DORA_GODOT_AUDIO_ABI_VERSION || !audioAPI.get_format || !audioAPI.read_pcm || !audioAPI.start_capture || !audioAPI.get_stats) {
            loaderError="incompatible Dora/Godot audio extension"; return false;
        }
    }
#if BX_PLATFORM_WINDOWS
    auto getTargets=reinterpret_cast<DoraGodotGetGLTargetsAPI>(GetProcAddress(module,"dora_godot_get_gl_targets_api"));
#else
    auto getTargets=reinterpret_cast<DoraGodotGetGLTargetsAPI>(dlsym(library,"dora_godot_get_gl_targets_api"));
#endif
    if (getTargets) {
        targetsAPI.size=sizeof(targetsAPI);
        if (!getTargets(DORA_GODOT_GL_TARGETS_ABI_VERSION,&targetsAPI) || targetsAPI.size<sizeof(targetsAPI)
            || targetsAPI.abi_version!=DORA_GODOT_GL_TARGETS_ABI_VERSION || !targetsAPI.bind) {
            loaderError="incompatible Dora/Godot GL targets extension"; return false;
        }
    }
#if BX_PLATFORM_WINDOWS
    auto getOutput=reinterpret_cast<DoraGodotGetOutputAPI>(GetProcAddress(module,"dora_godot_get_output_api"));
#else
    auto getOutput=reinterpret_cast<DoraGodotGetOutputAPI>(dlsym(library,"dora_godot_get_output_api"));
#endif
    if (getOutput) {
        outputAPI.size=sizeof(outputAPI);
        if (!getOutput(DORA_GODOT_OUTPUT_ABI_VERSION,&outputAPI) || outputAPI.size<sizeof(outputAPI)
            || outputAPI.abi_version!=DORA_GODOT_OUTPUT_ABI_VERSION || !outputAPI.get_size) {
            loaderError="incompatible Dora/Godot output extension"; return false;
        }
    }
#if BX_PLATFORM_WINDOWS
    auto getIME=reinterpret_cast<DoraGodotGetIMEAPI>(GetProcAddress(module,"dora_godot_get_ime_api"));
#else
    auto getIME=reinterpret_cast<DoraGodotGetIMEAPI>(dlsym(library,"dora_godot_get_ime_api"));
#endif
    if (getIME) {
        imeAPI.size=sizeof(imeAPI);
        if (!getIME(DORA_GODOT_IME_ABI_VERSION,&imeAPI) || imeAPI.size<sizeof(imeAPI)
            || imeAPI.abi_version!=DORA_GODOT_IME_ABI_VERSION || !imeAPI.get_state) {
            loaderError="incompatible Dora/Godot IME extension";return false;
        }
    }
#if BX_PLATFORM_ANDROID
    auto getAndroid=reinterpret_cast<DoraGodotGetAndroidAPI>(dlsym(library,"dora_godot_get_android_api"));
    DoraGodotAndroidAPI android{};android.size=sizeof(android);
    if (!getAndroid || !getAndroid(DORA_GODOT_ANDROID_ABI_VERSION,&android) || android.size<sizeof(android)
        || android.abi_version!=DORA_GODOT_ANDROID_ABI_VERSION || !android.configure
        || !android.configure(prepareGodotAndroidJava,nullptr)) {
        loaderError="incompatible or unconfigured Dora/Godot Android platform bridge";return false;
    }
#endif
    api=candidate; glAPI=extension;
#endif // !BX_PLATFORM_EMSCRIPTEN
    bgfx::setNativeFrameCallback(encodeFrame,nullptr);
    bgfx::setNativeShutdownCallback(shutdownInterop,nullptr);
    return true;
}
class GLSession final : public GodotSession,public std::enable_shared_from_this<GLSession> {
    GodotFrameRing _ring;
    GodotGpuReads _reads;
    GodotAudioStream _audio;
    std::vector<Ref<Texture2D>> _textures;
    std::vector<bgfx::TextureHandle> _pendingHandles;
    void *_handle=nullptr;
    bool _ownsReservation=false;
    int _width=0,_height=0;
    uint32_t _buffers=0;
    std::atomic<uint32_t> _generation{0};
    bool _ready=false,_started=false,_closeRequested=false;
    std::atomic<bool> _closing{false}, _requestedPaused{false};
    bool queryIME(DoraGodotIMEState &state) {
        state={sizeof(state),0,0,0,0};
        return imeAPI.get_state && imeAPI.get_state(_handle,&state) && acceptIMEState(state);
    }
    void fail(std::string message) {
        if (message.empty()) message="Godot operation failed without a runtime diagnostic";
        auto self=shared_from_this();
        SharedApplication.invokeInLogic([self,message=std::move(message)] {
            self->error(message); Error("GodotNode: {}",message); self->close();
        });
    }
    bool bindTargets(const std::vector<bgfx::TextureHandle> &handles,int width,int height) {
        uint32_t ids[DORA_GODOT_MAX_BUFFERS]{};
        for (uint32_t i=0;i<_buffers;++i) {
            const auto native=bgfx::getNativeTexture(handles[i]);
            if (!native || native>UINT32_MAX) return false;
            ids[i]=uint32_t(native);
        }
        glFlush(); // Publish host storage creation to the shared producer context.
        if (!targetsAPI.bind(_handle,width,height,ids,_buffers)) return false;
        for (uint32_t i=0;i<_buffers;++i) {
            DoraGodotSlot slot{}; slot.size=sizeof(slot);
            if (!api.get_slot(_handle,i,&slot) || slot.width!=uint32_t(width) || slot.height!=uint32_t(height)
                || slot.format!=DORA_GODOT_RGBA8 || uintptr_t(slot.texture)!=ids[i]) return false;
        }
        return true;
    }
    void boot(const std::string &project,const std::string &scene,int width,int height,int buffers,
        const std::vector<bgfx::TextureHandle> &handles) {
        auto self=shared_from_this();
        if (self->_closing) return;
        DoraGodotConfig config{sizeof(config),
#if BX_PLATFORM_EMSCRIPTEN
            DORA_GODOT_WEBGL2,
#else
            DORA_GODOT_OPENGL,
#endif
            (uint32_t)width,(uint32_t)height,(uint32_t)buffers,
            project.c_str(),scene.c_str(),bgfx::getInternalData()->context};
        self->_handle=api.open(&config);
        if (!self->_handle) { self->fail(api.last_error(nullptr)); return; }
        activeHandle=self->_handle;
        if (self->_closing) return;
        if (targetsAPI.bind) {
            if (!self->bindTargets(handles,width,height)) { self->fail("host-owned GL target binding failed: "+std::string(api.last_error(self->_handle))); return; }
        } else for (int i=0;i<buffers;++i) {
            DoraGodotSlot slot{}; slot.size=sizeof(slot);
            if (!api.get_slot(self->_handle,i,&slot) || slot.format!=DORA_GODOT_RGBA8 || !slot.texture
                || bgfx::overrideInternal(handles[i],(uintptr_t)slot.texture)!=(uintptr_t)slot.texture) {
                self->fail("external GL texture import failed"); return;
            }
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
        if (first && !self->_reads.produced(0,first)) { self->fail("invalid initial Godot GL production"); return; }
        activeSession=self;
        if (audioAPI.read_pcm && !self->_audio.configure(audioAPI,self->_handle)) { self->fail("Godot audio stream configuration failed"); return; }
        SharedApplication.invokeInLogic([self,width,height,first,initialOutput,initialIME,hasInitialIME] {
            if (self->_closing) return;
            auto *node=self->node(); if (!node) { self->close(); return; }
            if (hasInitialIME) self->applyIME(initialIME);
            bgfx::TextureInfo info{}; bgfx::calcTextureSize(info,width,height,1,false,false,1,bgfx::TextureFormat::RGBA8);
            for (auto handle:self->_pendingHandles) self->_textures.emplace_back(Texture2D::create(handle,info,BGFX_SAMPLER_U_CLAMP|BGFX_SAMPLER_V_CLAMP));
            self->_pendingHandles.clear();
            if (!first) {
                self->_ready=true;
                if (!self->resizeImpl(initialOutput.width,initialOutput.height,true)) self->fail("initial Godot source output resize failed");
                return;
            }
            self->_ring.seed(0,first); self->_ready=true;
            if (!self->_audio.start()) { self->fail("Dora host audio mixer could not start Godot stream"); return; }
            self->_started=true;
            node->setTexture(self->_textures[0]); node->setTextureRect({0,0,(float)width,(float)height}); self->running(true);
        });
    }
public:
    void finishAudio() { _audio.finish(); }
    void reportReads() {
        Info("GodotRuntime readers: buffers={}, frames={}, waits={}, signals={}, pending={}, completed={}, gpuErrors={}",
            _reads.buffers(),_reads.frames(),_reads.waits(),_reads.signals(),int(_reads.pending()),_reads.frames(),0);
    }
    explicit GLSession(GodotNode *node):GodotSession(node) {}
    bool start(const std::string &project,const std::string &scene,int width,int height,int buffers) override {
        bool free=false;
        if (!clientReserved.compare_exchange_strong(free,true)) { error("Godot already has an active node"); return false; }
        const auto renderer=bgfx::getRendererType();
        if (renderer!=bgfx::RendererType::OpenGLES && renderer!=bgfx::RendererType::OpenGL) {
            clientReserved=false; error("Godot GL requires OpenGL/OpenGLES"); return false;
        }
        _ownsReservation=true;
        _width=width; _height=height; _buffers=buffers;
        _ring.configure(buffers); _reads.configure(buffers);
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
        auto self=shared_from_this(); const uint32_t frame=SharedApplication.getFrame()+1;
        auto read=_ring.read(frame); if (!read) { fail("invalid Godot GL consumer frame"); return; }
        const auto generation=_generation.load();
        auto reservation=_ring.reserve(); if (!reservation) return;
        SharedApplication.invokeInRender([self,reservation=*reservation,generation] {
            if (self->_closing || self->_generation!=generation) return;
            if (!bgfx::submitNativeFrame()) { self->fail("cannot submit pending GL host frame"); return; }
            // GL fence queries require a current context; perform the nonblocking
            // backpressure check on this render thread, not the logic thread.
            const auto lastRead=self->_reads.lastRead();
            if (!self->_reads.canProduce() || !glAPI.can_advance(self->_handle,reservation.slot,lastRead)) {
                SharedApplication.invokeInLogic([self,reservation,generation] { if (!self->_closing && self->_generation==generation) self->_ring.defer(reservation); }); return;
            }
            uint64_t sequence=glAPI.advance_async(self->_handle,reservation.slot,lastRead);
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
            if (!self->_reads.produced(reservation.slot,sequence)) { self->fail("invalid Godot GL production"); return; }
            DoraGodotIMEState ime{};const bool imeChanged=self->queryIME(ime);
            SharedApplication.invokeInLogic([self,reservation,sequence,generation,ime,imeChanged] {
                if (self->_closing || self->_generation!=generation) return;
                if (imeChanged) self->applyIME(ime);
                if (!self->_ring.publish(reservation,sequence)) { self->fail("stale Godot GL publication"); return; }
                if (auto *node=self->node()) node->setTexture(self->_textures[reservation.slot]);
            });
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
        if (!_ready || _closing || !targetsAPI.bind) return false;
        if (!force && width==_width && height==_height) return true;
        _ready=false; _ring.close(); const auto generation=++_generation;
        std::vector<bgfx::TextureHandle> handles;
        for (uint32_t i=0;i<_buffers;++i) {
            auto handle=bgfx::createTexture2D(width,height,false,1,bgfx::TextureFormat::RGBA8,BGFX_SAMPLER_U_CLAMP|BGFX_SAMPLER_V_CLAMP);
            if (!bgfx::isValid(handle)) { fail("cannot allocate resized GL wrapper"); return false; }
            handles.push_back(handle); _pendingHandles.push_back(handle);
        }
        const auto resourceFrame=SharedApplication.getFrame()+1;
        auto self=shared_from_this();
        SharedApplication.invokeInRender([self,handles,width,height,generation,resourceFrame,sourceOwned] {
            bootQueue.schedule(resourceFrame,[self,handles,width,height,generation,sourceOwned] {
                SharedApplication.invokeInLogic([self,handles,width,height,generation,sourceOwned] {
                    if (self->_closing) return;
                    SharedApplication.invokeInRender([self,handles,width,height,generation,sourceOwned] {
                        if (self->_closing || self->_generation!=generation) return;
                        if (!bgfx::submitNativeFrame()) { self->fail("cannot submit GL frame before resize"); return; }
                        DoraGodotOutputSize latest{};
                        if (sourceOwned && self->pendingOutput(latest,width,height,false)) {
                            self->retrySourceResize(latest,generation);return;
                        }
                        glFinish();
                        if (!self->_reads.canProduce() || !self->bindTargets(handles,width,height) || !self->_reads.replaceSlots()) {
                            self->fail("GL viewport target replacement failed"); return;
                        }
                        const auto sequence=api.advance(self->_handle,0,0);
                        if (!sequence && self->pendingOutput(latest,width,height,true)) {
                            self->retrySourceResize(latest,generation);return;
                        }
                        if (!sequence || !self->_reads.produced(0,sequence)) { self->fail("resized GL first frame failed"); return; }
                        SharedApplication.invokeInLogic([self,width,height,sequence,generation] {
                            if (self->_closing || self->_generation!=generation) return;
                            auto *target=self->node(); if (!target) { self->close(); return; }
                            bgfx::TextureInfo info{}; bgfx::calcTextureSize(info,width,height,1,false,false,1,bgfx::TextureFormat::RGBA8);
                            self->_textures.clear();
                            for (auto handle:self->_pendingHandles) self->_textures.emplace_back(Texture2D::create(handle,info,BGFX_SAMPLER_U_CLAMP|BGFX_SAMPLER_V_CLAMP));
                            self->_pendingHandles.clear(); self->_ring.configure(self->_buffers);
                            if (!self->_ring.seed(0,sequence)) { self->fail("cannot seed resized GL ring"); return; }
                            target->setTexture(self->_textures[0]); self->resized(width,height);
                            self->_width=width; self->_height=height; self->_ready=true;
                            if (!self->_started) {
                                if (!self->_audio.start()) { self->fail("Dora host audio mixer could not start Godot stream"); return; }
                                self->_started=true;self->running(true);
                            }
                            Info("GodotRuntime resized: width={}, height={}, generation={}",width,height,generation);
                        });
                    });
                });
            });
        });
        return true;
    }
    void tryClose() {
        if (!_closeRequested) return;
        if (_reads.pending()) return;
        _audio.finish();
        if (_handle && activeHandle==_handle) {
            glFinish(); DoraGodotStats stats{}; stats.size=sizeof(stats); api.close(_handle,&stats);
            reportReads();
            Info("GodotRuntime client closed: produced={}, completed={}, gpuErrors={}",stats.produced,stats.completed,stats.gpu_errors);
            activeHandle=nullptr;
            activeSession.reset();
        }
        _handle=nullptr; clientReserved=false;
    }
    void encode(uint32_t frame,bool end) {
        if (!end) {
            if (!_reads.begin(frame)) { fail("invalid Godot GL consumer begin"); return; }
            for (uint32_t slot=0;slot<_reads.buffers();++slot) {
                const auto sequence=_reads.sequence(slot);
                if (sequence && !glAPI.consumer_begin(_handle,slot,sequence)) { fail(api.last_error(_handle)); return; }
            }
        } else {
            if (!_reads.end(frame)) { fail("invalid Godot GL consumer end"); return; }
            for (uint32_t slot=0;slot<_reads.buffers();++slot)
                if (!glAPI.consumer_end(_handle,slot,frame)) { fail(api.last_error(_handle)); return; }
            tryClose();
        }
    }
    void close() override {
        if (_closing.exchange(true) || !_ownsReservation) return;
        releaseIME();
        _audio.stop();
        running(false); _ring.close(); _textures.clear();
        for (auto handle:_pendingHandles) bgfx::destroy(handle);
        _pendingHandles.clear(); auto self=shared_from_this();
        SharedApplication.invokeInRender([self] { self->_closeRequested=true; self->tryClose(); });
    }
    void pause(bool value) override {
        _requestedPaused=value;
        auto self=shared_from_this(); SharedApplication.invokeInRender([self,value] { if (!self->_closing && self->_handle) api.set_paused(self->_handle,value); });
    }
    bool restart(const std::string &scene) override {
        if (!_ready || _closing) return false;
        auto self=shared_from_this(); SharedApplication.invokeInRender([self,scene] {
            if (!self->_closing && !api.restart_scene(self->_handle,scene.c_str())) self->fail(api.last_error(self->_handle));
        }); return true;
    }
    void input(DoraGodotInput event,std::string text) override {
        auto self=shared_from_this(); SharedApplication.invokeInRender([self,event,text=std::move(text)]() mutable {
            event.text=text.c_str(); if (!self->_closing && self->_handle) api.input(self->_handle,&event);
        });
    }
};
void encodeFrame(bgfx::RendererType::Enum renderer,uint32_t frame,void *,bool end,void *) {
    if (renderer!=bgfx::RendererType::OpenGL && renderer!=bgfx::RendererType::OpenGLES) return;
    if (!end) bootQueue.drain(frame);
    if (activeSession) activeSession->encode(frame,end);
}
void shutdownInterop(bgfx::RendererType::Enum,void *) {
    bootQueue.clear();
    // Native GL objects must be released before bgfx destroys its GL context.
    bgfx::setNativeFrameCallback(nullptr,nullptr); bgfx::setNativeShutdownCallback(nullptr,nullptr);
    if (api.shutdown) {
        glFinish();
        if (activeHandle) {
            if (activeSession) activeSession->finishAudio();
            DoraGodotStats stats{}; stats.size=sizeof(stats); api.close(activeHandle,&stats);
            if (activeSession) activeSession->reportReads();
            Info("GodotRuntime shutdown: produced={}, completed={}, gpuErrors={}",stats.produced,stats.completed,stats.gpu_errors);
            activeHandle=nullptr;
        }
        api.shutdown(); api={}; glAPI={};
        activeSession.reset(); audioAPI={}; targetsAPI={}; outputAPI={}; imeAPI={};
    }
    clientReserved=false;
}
}
std::shared_ptr<GodotSession> createGodotGLSession(GodotNode *node) { return std::make_shared<GLSession>(node); }
void shutdownGodotGLRuntime() { /* Native GL teardown runs before the host context is destroyed. */ }
NS_DORA_END
