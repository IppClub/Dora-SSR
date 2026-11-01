// Windows D3D12 prototype: host-owned shared textures, Godot direct rendering,
// and deliberately conservative CPU fence waits before bgfx samples a slot.
#include "Const/Header.h"
#include "Godot/GodotNode.h"
#include "Godot/GodotAudio.h"
#include "Godot/GodotBridgeD3D12.h"
#include "Godot/GodotBridgeOutput.h"
#include "Godot/GodotBridgeIME.h"
#include "Godot/GodotRenderBootQueue.h"
#include "Basic/Application.h"
#include "Basic/Content.h"
#include "Other/utf8.h"
#include <d3d12.h>
#include <dxgi1_4.h>
#include <windows.h>
#include <atomic>

NS_DORA_BEGIN
namespace {
class D3D12Session;
std::shared_ptr<D3D12Session> activeSession;
GodotRenderBootQueue bootQueue;
DoraGodotAPI api{};
DoraGodotD3D12TargetsAPI targetsAPI{};
DoraGodotAudioAPI audioAPI{};
DoraGodotOutputAPI outputAPI{};
DoraGodotIMEAPI imeAPI{};
HMODULE library=nullptr;
void *activeHandle=nullptr;
std::atomic<bool> clientReserved{false};
std::string loaderError;
std::vector<ID3D12Resource *> retiredResources;

void encodeFrame(bgfx::RendererType::Enum,uint32_t,void *,bool,void *);
void shutdownInterop(bgfx::RendererType::Enum,void *);

template <class T> bool loadExtension(HMODULE module,const char *name,uint32_t abi,T &result) {
    using Getter=int (*)(uint32_t,T *);
    auto getter=reinterpret_cast<Getter>(GetProcAddress(module,name));
    result={};result.size=sizeof(result);
    return getter && getter(abi,&result) && result.size>=sizeof(result) && result.abi_version==abi;
}
bool loadAPI() {
    if (api.open) return true;
    SetLastError(ERROR_SUCCESS);
    const DWORD length=GetEnvironmentVariableW(L"DORA_GODOT_LIBRARY",nullptr,0);
    std::wstring path;
    if (length) {
        path.resize(length);
        const DWORD copied=GetEnvironmentVariableW(L"DORA_GODOT_LIBRARY",path.data(),length);
        if (!copied || copied>=length) { loaderError="cannot read DORA_GODOT_LIBRARY consistently";return false; }
        path.resize(copied);
    } else if (GetLastError()==ERROR_ENVVAR_NOT_FOUND) {
        const auto utf16=CodeCvt::utf8to16(Path::concat({SharedContent.getAssetPath(),"dora_godot.dll"_slice}));
        path.assign(utf16.begin(),utf16.end());
    } else { loaderError="DORA_GODOT_LIBRARY is empty or unreadable";return false; }
    library=LoadLibraryW(path.c_str());
    if (!library) { loaderError="cannot load Dora/Godot D3D12 runtime DLL, Win32 error "+std::to_string(GetLastError());return false; }
    auto getAPI=reinterpret_cast<DoraGodotGetAPI>(GetProcAddress(library,"dora_godot_get_api"));
    DoraGodotAPI candidate{};candidate.size=sizeof(candidate);
    if (!getAPI || !getAPI(DORA_GODOT_ABI_VERSION,&candidate) || candidate.size<sizeof(candidate)
        || candidate.abi_version!=DORA_GODOT_ABI_VERSION || !candidate.open || !candidate.last_error
        || !candidate.get_slot || !candidate.advance || !candidate.input || !candidate.set_paused
        || !candidate.restart_scene || !candidate.close || !candidate.shutdown
        || !loadExtension(library,"dora_godot_get_d3d12_targets_api",DORA_GODOT_D3D12_TARGETS_ABI_VERSION,targetsAPI)
        || !targetsAPI.bind) {
        loaderError="incompatible or incomplete Dora/Godot D3D12 ABI";return false;
    }
    api=candidate;
    loadExtension(library,"dora_godot_get_audio_api",DORA_GODOT_AUDIO_ABI_VERSION,audioAPI);
    loadExtension(library,"dora_godot_get_output_api",DORA_GODOT_OUTPUT_ABI_VERSION,outputAPI);
    loadExtension(library,"dora_godot_get_ime_api",DORA_GODOT_IME_ABI_VERSION,imeAPI);
    bgfx::setNativeFrameCallback(encodeFrame,nullptr);
    bgfx::setNativeShutdownCallback(shutdownInterop,nullptr);
    return true;
}

struct SharedSlot {
    ID3D12Resource *resource=nullptr;
    HANDLE handle=nullptr;
    bgfx::TextureHandle wrapper=BGFX_INVALID_HANDLE;
};

class D3D12Session final : public GodotSession,public std::enable_shared_from_this<D3D12Session> {
    GodotAudioStream _audio;
    std::vector<SharedSlot> _slots;
    std::vector<Ref<Texture2D>> _textures;
    void *_handle=nullptr;
    uint32_t _width=0,_height=0,_buffers=0,_next=0,_generation=0;
    bool _ownsReservation=false,_ready=false,_started=false,_closeRequested=false;
    std::atomic<bool> _closing{false},_paused{false};

    void fail(std::string message) {
        if (message.empty()) message="Godot D3D12 operation failed without a runtime diagnostic";
        auto self=shared_from_this();
        SharedApplication.invokeInLogic([self,message=std::move(message)] {
            self->error(message);Error("GodotNode: {}",message);self->close();
        });
    }
    bool allocateShared(ID3D12Device *device,std::vector<SharedSlot> &slots,uint32_t width,uint32_t height) {
        slots.resize(_buffers);
        D3D12_HEAP_PROPERTIES heap{};heap.Type=D3D12_HEAP_TYPE_DEFAULT;
        D3D12_RESOURCE_DESC desc{};
        desc.Dimension=D3D12_RESOURCE_DIMENSION_TEXTURE2D;
        desc.Width=width;desc.Height=height;desc.DepthOrArraySize=1;desc.MipLevels=1;
        desc.Format=DXGI_FORMAT_R8G8B8A8_UNORM;desc.SampleDesc.Count=1;
        desc.Layout=D3D12_TEXTURE_LAYOUT_UNKNOWN;
        // The allocation is opened by independent bgfx and Godot devices.
        // Simultaneous-access resources can be promoted by either queue and
        // decay back to COMMON after command-list execution.
        desc.Flags=D3D12_RESOURCE_FLAG_ALLOW_RENDER_TARGET|D3D12_RESOURCE_FLAG_ALLOW_SIMULTANEOUS_ACCESS;
        D3D12_CLEAR_VALUE clear{};clear.Format=desc.Format;
        for (auto &slot:slots) {
            if (FAILED(device->CreateCommittedResource(&heap,D3D12_HEAP_FLAG_SHARED,&desc,
                    D3D12_RESOURCE_STATE_COMMON,&clear,IID_PPV_ARGS(&slot.resource)))
                || FAILED(device->CreateSharedHandle(slot.resource,nullptr,GENERIC_ALL,nullptr,&slot.handle))) {
                return false;
            }
        }
        return true;
    }
    void retireSlots(std::vector<SharedSlot> &slots) {
        for (auto &slot:slots) {
            if (slot.handle) CloseHandle(slot.handle);
            if (slot.resource) retiredResources.push_back(slot.resource);
            slot.handle=nullptr;slot.resource=nullptr;
        }
        slots.clear();
    }
    void discardSlots(std::vector<SharedSlot> &slots) {
        for (auto &slot:slots) {
            if (slot.handle) CloseHandle(slot.handle);
            if (slot.resource) slot.resource->Release();
            if (bgfx::isValid(slot.wrapper)) bgfx::destroy(slot.wrapper);
        }
        slots.clear();
    }
    void retireShared() { retireSlots(_slots); }
    bool queryIME(DoraGodotIMEState &state) {
        state={sizeof(state),0,0,0,0};
        return imeAPI.get_state && imeAPI.get_state(_handle,&state) && acceptIMEState(state);
    }
    bool produce(uint32_t slot) {
        const uint64_t sequence=api.advance(_handle,slot,0);
        if (!sequence) return false;
        // The simultaneous-access texture decays to COMMON after Godot's list.
        // Re-applying the pointer resets bgfx's private state tracker.
        if (bgfx::overrideInternal(_slots[slot].wrapper,(uintptr_t)_slots[slot].resource)!=(uintptr_t)_slots[slot].resource)
            return false;
        DoraGodotIMEState ime{};const bool imeChanged=queryIME(ime);
        auto self=shared_from_this();
        SharedApplication.invokeInLogic([self,slot,ime,imeChanged] {
            if (self->_closing || !self->_ready) return;
            if (imeChanged) self->applyIME(ime);
            if (auto *target=self->node()) target->setTexture(self->_textures[slot]);
        });
        return true;
    }
    void boot(const std::string &project,const std::string &scene) {
        if (_closing) return;
        activeSession=shared_from_this();
        auto *device=reinterpret_cast<ID3D12Device *>(bgfx::getInternalData()->context);
        if (!device || !allocateShared(device,_slots,_width,_height)) { fail("Dora D3D12 shared texture allocation failed");return; }
        for (auto &slot:_slots) {
            if (bgfx::overrideInternal(slot.wrapper,(uintptr_t)slot.resource)!=(uintptr_t)slot.resource) {
                fail("bgfx D3D12 shared texture override failed");return;
            }
        }
        DoraGodotConfig config{sizeof(config),DORA_GODOT_D3D12,_width,_height,_buffers,
            project.c_str(),scene.c_str(),device};
        _handle=api.open(&config);
        if (!_handle) { fail(api.last_error(nullptr));return; }
        activeHandle=_handle;
        uint64_t handles[DORA_GODOT_MAX_BUFFERS]{};
        for (uint32_t i=0;i<_buffers;++i) handles[i]=(uint64_t)(uintptr_t)_slots[i].handle;
        if (!targetsAPI.bind(_handle,_width,_height,handles,_buffers)) {
            fail("Godot D3D12 shared resource import failed: "+std::string(api.last_error(_handle)));return;
        }
        api.set_paused(_handle,_paused.load());
        if (!produce(0)) { fail(api.last_error(_handle));return; }
        if (audioAPI.read_pcm && !_audio.configure(audioAPI,_handle)) { fail("Godot D3D12 audio configuration failed");return; }
        auto self=shared_from_this();
        SharedApplication.invokeInLogic([self] {
            if (self->_closing) return;
            auto *target=self->node();if (!target) { self->close();return; }
            bgfx::TextureInfo info{};bgfx::calcTextureSize(info,self->_width,self->_height,1,false,false,1,bgfx::TextureFormat::RGBA8);
            for (auto &slot:self->_slots) self->_textures.emplace_back(Texture2D::create(slot.wrapper,info,BGFX_SAMPLER_U_CLAMP|BGFX_SAMPLER_V_CLAMP));
            self->_ready=true;self->_next=1%self->_buffers;
            target->setTexture(self->_textures[0]);target->setTextureRect({0,0,float(self->_width),float(self->_height)});
            if (!self->_audio.start()) { self->fail("Dora host audio mixer could not start Godot D3D12 stream");return; }
            self->_started=true;self->running(true);
        });
    }
public:
    explicit D3D12Session(GodotNode *node):GodotSession(node) {}
    bool start(const std::string &project,const std::string &scene,int width,int height,int buffers) override {
        bool free=false;
        if (!clientReserved.compare_exchange_strong(free,true)) { error("Godot already has an active node");return false; }
        if (bgfx::getRendererType()!=bgfx::RendererType::Direct3D12) { clientReserved=false;error("Godot D3D12 requires bgfx D3D12");return false; }
        _ownsReservation=true;_width=width;_height=height;_buffers=buffers;
        for (int i=0;i<buffers;++i) {
            auto wrapper=bgfx::createTexture2D(width,height,false,1,bgfx::TextureFormat::RGBA8,BGFX_SAMPLER_U_CLAMP|BGFX_SAMPLER_V_CLAMP);
            if (!bgfx::isValid(wrapper)) { error("cannot allocate D3D12 texture wrapper");return false; }
            _slots.push_back({nullptr,nullptr,wrapper});
        }
        const uint32_t resourceFrame=SharedApplication.getFrame()+1;
        auto self=shared_from_this();
        SharedApplication.invokeInRender([self,project,scene,resourceFrame] {
            if (self->_closing) return;
            if (!loadAPI()) { self->fail(loaderError);return; }
            bootQueue.schedule(resourceFrame,[self,project,scene] { self->boot(project,scene); });
        });
        return true;
    }
    bool resize(int width,int height) override {
        if (!_ready || _closing || width<=0 || height<=0 || width>8192 || height>8192) return false;
        if (uint32_t(width)==_width && uint32_t(height)==_height) return true;
        std::vector<SharedSlot> next;next.reserve(_buffers);
        for (uint32_t i=0;i<_buffers;++i) {
            const auto wrapper=bgfx::createTexture2D(width,height,false,1,bgfx::TextureFormat::RGBA8,
                BGFX_SAMPLER_U_CLAMP|BGFX_SAMPLER_V_CLAMP);
            if (!bgfx::isValid(wrapper)) { discardSlots(next);return false; }
            next.push_back({nullptr,nullptr,wrapper});
        }
        _ready=false;const uint32_t generation=++_generation;
        auto self=shared_from_this();
        SharedApplication.invokeInRender([self,next=std::move(next),width,height,generation]() mutable {
            if (self->_closing || self->_generation!=generation) { self->discardSlots(next);return; }
            auto *device=reinterpret_cast<ID3D12Device *>(bgfx::getInternalData()->context);
            if (!device || !self->allocateShared(device,next,width,height)) {
                self->discardSlots(next);self->fail("resized D3D12 shared texture allocation failed");return;
            }
            for (auto &slot:next) {
                if (bgfx::overrideInternal(slot.wrapper,(uintptr_t)slot.resource)!=(uintptr_t)slot.resource) {
                    self->discardSlots(next);self->fail("resized bgfx D3D12 texture override failed");return;
                }
            }
            auto previous=std::move(self->_slots);
            const uint32_t previousWidth=self->_width,previousHeight=self->_height;
            self->_slots=std::move(next);self->_width=width;self->_height=height;
            uint64_t handles[DORA_GODOT_MAX_BUFFERS]{};
            for (uint32_t i=0;i<self->_buffers;++i) handles[i]=(uint64_t)(uintptr_t)self->_slots[i].handle;
            if (!targetsAPI.bind(self->_handle,width,height,handles,self->_buffers) || !self->produce(0)) {
                auto failed=std::move(self->_slots);self->_slots=std::move(previous);
                self->_width=previousWidth;self->_height=previousHeight;self->discardSlots(failed);
                self->fail("resized Godot D3D12 target binding failed: "+std::string(api.last_error(self->_handle)));return;
            }
            self->retireSlots(previous);
            SharedApplication.invokeInLogic([self,width,height,generation] {
                if (self->_closing || self->_generation!=generation) return;
                bgfx::TextureInfo info{};bgfx::calcTextureSize(info,width,height,1,false,false,1,bgfx::TextureFormat::RGBA8);
                std::vector<Ref<Texture2D>> textures;textures.reserve(self->_buffers);
                for (auto &slot:self->_slots) textures.emplace_back(Texture2D::create(slot.wrapper,info,BGFX_SAMPLER_U_CLAMP|BGFX_SAMPLER_V_CLAMP));
                self->_textures=std::move(textures);self->_next=1%self->_buffers;self->_ready=true;
                if (auto *target=self->node()) {
                    target->setTexture(self->_textures[0]);self->resized(width,height);
                }
                Info("GodotRuntime resized: width={}, height={}, generation={}",width,height,generation);
            });
        });
        return true;
    }
    void step() override {}
    void encode(bool end) {
        if (end) { tryClose();return; }
        if (_ready && !_closing && !_paused && _handle) {
            const uint32_t slot=_next;_next=(_next+1)%_buffers;
            if (!produce(slot)) fail(api.last_error(_handle));
        }
    }
    void tryClose() {
        if (!_closeRequested) return;
        _audio.finish();
        if (_handle && activeHandle==_handle) {
            DoraGodotStats stats{};stats.size=sizeof(stats);api.close(_handle,&stats);
            Info("GodotRuntime D3D12 CPU fence: buffers={}, waits={}, produced={}, completed={}, gpuErrors={}",
                _buffers,stats.reuse_waits,stats.produced,stats.completed,stats.gpu_errors);
            Info("GodotRuntime client closed: produced={}, completed={}, gpuErrors={}",stats.produced,stats.completed,stats.gpu_errors);
            activeHandle=nullptr;activeSession.reset();
        }
        _handle=nullptr;retireShared();clientReserved=false;_closeRequested=false;
    }
    void close() override {
        if (_closing.exchange(true) || !_ownsReservation) return;
        releaseIME();_audio.stop();running(false);_textures.clear();
        auto self=shared_from_this();SharedApplication.invokeInRender([self] { self->_closeRequested=true; });
    }
    void pause(bool value) override {
        _paused=value;auto self=shared_from_this();
        SharedApplication.invokeInRender([self,value] { if (!self->_closing && self->_handle) api.set_paused(self->_handle,value); });
    }
    bool restart(const std::string &scene) override {
        if (!_ready || _closing) return false;
        auto self=shared_from_this();SharedApplication.invokeInRender([self,scene] {
            if (!self->_closing && !api.restart_scene(self->_handle,scene.c_str())) self->fail(api.last_error(self->_handle));
        });return true;
    }
    void input(DoraGodotInput event,std::string text) override {
        auto self=shared_from_this();SharedApplication.invokeInRender([self,event,text=std::move(text)]() mutable {
            event.text=text.c_str();if (!self->_closing && self->_handle) api.input(self->_handle,&event);
        });
    }
    void closeForShutdown() {
        _audio.finish();
        if (!activeHandle) return;
        DoraGodotStats stats{};stats.size=sizeof(stats);api.close(activeHandle,&stats);
        Info("GodotRuntime D3D12 CPU fence: buffers={}, waits={}, produced={}, completed={}, gpuErrors={}",
            _buffers,stats.reuse_waits,stats.produced,stats.completed,stats.gpu_errors);
        Info("GodotRuntime shutdown: produced={}, completed={}, gpuErrors={}",stats.produced,stats.completed,stats.gpu_errors);
        activeHandle=nullptr;
    }
    void retireForShutdown() { retireShared(); }
};

void encodeFrame(bgfx::RendererType::Enum renderer,uint32_t frame,void *,bool end,void *) {
    if (renderer!=bgfx::RendererType::Direct3D12) return;
    if (!end) bootQueue.drain(frame);
    auto session=activeSession;
    if (session) session->encode(end);
}
void shutdownInterop(bgfx::RendererType::Enum renderer,void *) {
    if (renderer!=bgfx::RendererType::Direct3D12) return;
    bootQueue.clear();bgfx::setNativeFrameCallback(nullptr,nullptr);bgfx::setNativeShutdownCallback(nullptr,nullptr);
    if (api.shutdown) {
        if (activeHandle) {
            if (activeSession) activeSession->closeForShutdown();
            else { DoraGodotStats stats{};stats.size=sizeof(stats);api.close(activeHandle,&stats);activeHandle=nullptr; }
        }
        if (activeSession) activeSession->retireForShutdown();
        api.shutdown();
    }
    activeSession.reset();api={};targetsAPI={};audioAPI={};outputAPI={};imeAPI={};clientReserved=false;
    for (auto *resource:retiredResources) resource->Release();
    retiredResources.clear();
    if (library) FreeLibrary(library);
    library=nullptr;
}
}
std::shared_ptr<GodotSession> createGodotD3D12Session(GodotNode *node) { return std::make_shared<D3D12Session>(node); }
void shutdownGodotD3D12Runtime() { /* Native teardown runs through bgfx before its D3D12 device is released. */ }
NS_DORA_END
