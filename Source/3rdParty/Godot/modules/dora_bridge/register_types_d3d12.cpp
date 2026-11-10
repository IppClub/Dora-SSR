// Windows D3D12 LibGodot prototype. Godot imports host-owned shared resources,
// renders directly into them, and CPU-waits a queue fence before publication.
#include "register_types.h"
#include "GodotBridgeD3D12.h"
#include "GodotBridgeAudio.h"
#include "GodotBridgeOutput.h"
#include "GodotBridgeProject.h"
#include "GodotBridgeIME.h"
#include "GodotAudioQueue.h"
#include "runtime_timing.h"
#include "runtime_output.h"
#include "runtime_ime.h"
#include "core/config/engine.h"
#include "core/config/project_settings.h"
#include "core/extension/libgodot.h"
#include "core/extension/godot_instance.h"
#include "core/input/input.h"
#include "core/input/input_event.h"
#include "core/os/keyboard.h"
#include "core/os/os.h"
#include "core/os/semaphore.h"
#include "core/string/print_string.h"
#include "scene/main/scene_tree.h"
#include "scene/main/window.h"
#include "servers/audio/audio_driver_dummy.h"
#include "servers/rendering/rendering_device.h"
#include "servers/rendering/rendering_server.h"
#include "servers/rendering/rendering_server_globals.h"
#include "servers/rendering/storage/texture_storage.h"
#include <d3d12.h>
#include <windows.h>
#include <array>
#include <cstdio>
#include <cstring>
#include <filesystem>
#include <set>
#include <string>

void initialize_dora_bridge_module(ModuleInitializationLevel) {}
void uninitialize_dora_bridge_module(ModuleInitializationLevel) {}

#include "runtime_project.h"
#include "runtime_check.h"
#include "runtime_import.h"
#include "runtime_scene.h"
#include "runtime_check_boot.h"

namespace {
struct Slot {
    uint64_t shared_handle=0;
    ID3D12Resource *resource=nullptr;
    RID rd_texture;
    bool published=false;
};
struct Runtime {
    std::set<Key> held_keys;
    std::set<std::pair<int,JoyButton>> held_joy_buttons;
    std::set<std::pair<int,JoyAxis>> active_joy_axes;
    GodotInstance *instance=nullptr;
    SceneTree *tree=nullptr;
    Window *root=nullptr;
    ID3D12Device *device=nullptr;
    ID3D12CommandQueue *queue=nullptr;
    ID3D12Fence *fence=nullptr;
    HANDLE event_handle=nullptr;
    ID3D12CommandQueue *host_queue=nullptr;
    ID3D12Fence *host_fence=nullptr;
    HANDLE host_event=nullptr;
    std::array<Slot,DORA_GODOT_MAX_BUFFERS> slots{};
    RID direct_render_target;
    std::string project,scene,error;
    uint32_t width=0,height=0,buffers=0;
    uint64_t sequence=0,completed=0,fence_value=0,cpu_waits=0;
    uint64_t host_fence_value=0,host_cpu_waits=0;
    bool active=false,paused=false,terminated=false,targets_bound=false;
} runtime;
DoraGodotOutput output;
bool output_pending=false;
void level(void *,GDExtensionInitializationLevel) {}
GDExtensionBool extension_init(GDExtensionInterfaceGetProcAddress,GDExtensionClassLibraryPtr,GDExtensionInitialization *init) {
    init->minimum_initialization_level=GDEXTENSION_INITIALIZATION_CORE;
    init->initialize=level;init->deinitialize=level;init->userdata=nullptr;return true;
}
const char *version() { return "Godot 4.7.2-stable / Dora bridge D3D12 CPU-fence prototype ABI 1"; }
const char *last_error(void *) { return DoraGodotDiagnostics::get(runtime.error); }
bool valid(void *handle) { return handle==&runtime && runtime.active; }
#include "runtime_audio.inc"

bool wait_queue() {
    const uint64_t value=++runtime.fence_value;
    if (FAILED(runtime.queue->Signal(runtime.fence,value))) {
        runtime.error="Godot D3D12 queue fence signal failed";return false;
    }
    if (runtime.fence->GetCompletedValue()<value) {
        if (FAILED(runtime.fence->SetEventOnCompletion(value,runtime.event_handle))) {
            runtime.error="Godot D3D12 queue fence event failed";return false;
        }
        if (WaitForSingleObject(runtime.event_handle,10000)!=WAIT_OBJECT_0) {
            runtime.error="Godot D3D12 queue fence CPU wait timed out";return false;
        }
    }
    ++runtime.cpu_waits;return true;
}
bool wait_host_queue() {
    if (!runtime.host_queue) return true;
    const uint64_t value=++runtime.host_fence_value;
    if (FAILED(runtime.host_queue->Signal(runtime.host_fence,value)) ||
        (runtime.host_fence->GetCompletedValue()<value &&
            (FAILED(runtime.host_fence->SetEventOnCompletion(value,runtime.host_event)) ||
                WaitForSingleObject(runtime.host_event,10000)!=WAIT_OBJECT_0))) {
        runtime.error="Dora D3D12 consumer queue CPU fence failed";return false;
    }
    ++runtime.host_cpu_waits;return true;
}
void prepare_output() {
    auto *rs=RenderingServer::get_singleton();
    const RID viewport=runtime.root->get_viewport_rid();
    rs->viewport_set_render_direct_to_screen(viewport,false);
    rs->viewport_attach_to_screen(viewport,Rect2(),DisplayServerEnums::INVALID_WINDOW_ID);
    rs->viewport_set_update_mode(viewport,RSE::VIEWPORT_UPDATE_ALWAYS);
    output.prepare(runtime.root);
}
bool draw() {
    auto *rs=RenderingServer::get_singleton();
    prepare_output();
    rs->draw(false,DoraGodotRenderTiming::consume());
    Engine::get_singleton()->increment_frames_drawn();rs->sync();return true;
}
void detach_target() {
    if (runtime.direct_render_target.is_valid())
        RSG::texture_storage->render_target_set_override(runtime.direct_render_target,RID(),RID(),RID(),RID());
    runtime.direct_render_target=RID();
}
void clear_targets() {
    detach_target();
    for (uint32_t i=0;i<runtime.buffers;++i) {
        if (runtime.slots[i].rd_texture.is_valid()) RenderingDevice::get_singleton()->free_rid(runtime.slots[i].rd_texture);
        if (runtime.slots[i].resource) runtime.slots[i].resource->Release();
        runtime.slots[i]=Slot{};
    }
    runtime.targets_bound=false;
}
bool select_target(uint32_t slot) {
    if (!runtime.targets_bound || slot>=runtime.buffers) return false;
    const RID target=output.render_target(runtime.root);
    if (!target.is_valid()) return false;
    if (runtime.direct_render_target.is_valid() && runtime.direct_render_target!=target) detach_target();
    RSG::texture_storage->render_target_set_override(target,runtime.slots[slot].rd_texture,RID(),RID(),RID());
    runtime.direct_render_target=target;return true;
}
bool prepare_device(void *host_device) {
    std::fprintf(stderr,"DORA_GODOT_D3D12_CPU prepare_device begin\n");
    auto *rd=RenderingDevice::get_singleton();
    if (!rd) { runtime.error="Godot D3D12 RenderingDevice is unavailable";return false; }
    runtime.device=reinterpret_cast<ID3D12Device *>(rd->get_driver_resource(RenderingDevice::DRIVER_RESOURCE_LOGICAL_DEVICE));
    runtime.queue=reinterpret_cast<ID3D12CommandQueue *>(rd->get_driver_resource(RenderingDevice::DRIVER_RESOURCE_COMMAND_QUEUE));
    std::fprintf(stderr,"DORA_GODOT_D3D12_CPU prepare_device resources device=%d queue=%d host=%d\n",
        runtime.device!=nullptr,runtime.queue!=nullptr,host_device!=nullptr);
    auto *host=reinterpret_cast<ID3D12Device *>(host_device);
    if (!runtime.device || !runtime.queue || !host) { runtime.error="Godot or Dora D3D12 native device is unavailable";return false; }
    const LUID godot_luid=runtime.device->GetAdapterLuid(),host_luid=host->GetAdapterLuid();
    if (godot_luid.HighPart!=host_luid.HighPart || godot_luid.LowPart!=host_luid.LowPart) {
        runtime.error="Godot and Dora D3D12 devices selected different adapters";return false;
    }
    if (FAILED(runtime.device->CreateFence(0,D3D12_FENCE_FLAG_NONE,IID_PPV_ARGS(&runtime.fence)))) {
        runtime.error="Godot D3D12 bridge synchronization object creation failed";return false;
    }
    runtime.event_handle=CreateEventW(nullptr,FALSE,FALSE,nullptr);
    if (!runtime.event_handle) { runtime.error="Godot D3D12 bridge event creation failed";return false; }
    // Diagnostic isolation of consumer/producer overlap. bgfx publishes its
    // queue on the host device; this remains a conservative CPU wait.
    if (OS::get_singleton()->get_environment("DORA_GODOT_D3D12_CPU_READERS")=="1") {
        UINT size=sizeof(runtime.host_queue);
        if (FAILED(host->GetPrivateData(IID_ID3D12CommandQueue,&size,&runtime.host_queue)) ||
            !runtime.host_queue || size!=sizeof(runtime.host_queue) ||
            FAILED(host->CreateFence(0,D3D12_FENCE_FLAG_NONE,IID_PPV_ARGS(&runtime.host_fence)))) {
            runtime.error="Dora D3D12 consumer synchronization objects unavailable";return false;
        }
        runtime.host_event=CreateEventW(nullptr,FALSE,FALSE,nullptr);
        if (!runtime.host_event) { runtime.error="Dora D3D12 consumer event creation failed";return false; }
        print_line("DORA_GODOT_D3D12_CPU_READERS enabled");
    }
    std::fprintf(stderr,"DORA_GODOT_D3D12_CPU prepare_device ready\n");
    return true;
}
// Retain backend adapter policy when compiler/import boot precedes gameplay.
bool configure_project(std::string &error) {
    if (OS::get_singleton()->get_environment("DORA_GODOT_D3D12_WARP")=="1") {
        const String cache=OS::get_singleton()->get_environment("DORA_GODOT_D3D12_WARP_SHADER_CACHE");
        if (!cache.is_empty()) {
            if (cache!="0" && cache!="1") { error="DORA_GODOT_D3D12_WARP_SHADER_CACHE must be 0 or 1";return false; }
            ProjectSettings::get_singleton()->set("rendering/shader_compiler/shader_cache/enabled",cache=="1");
            print_line(vformat("DORA_GODOT_D3D12_WARP shader_cache=%d",int(cache=="1")));
        }
        // Current Windows 11 ARM64 WARP crashes in Forward Mobile's
        // fragment shadow-receiver path. Keep per-pixel diffuse, specular
        // and ambient lighting, but compile shadows out in the default
        // compatibility tier. Vertex and none remain diagnostic overrides.
        String compat=OS::get_singleton()->get_environment("DORA_GODOT_D3D12_WARP_COMPAT").to_lower();
        if (compat.is_empty()) compat="shadows";
        const bool force_vertex=compat=="vertex";
        const bool force_disable_shadows=compat=="shadows";
        if (compat!="none" && !force_vertex && !force_disable_shadows) {
            error="DORA_GODOT_D3D12_WARP_COMPAT must be shadows, vertex or none";return false;
        }
        if (force_vertex) ProjectSettings::get_singleton()->set("rendering/shading/overrides/force_vertex_shading",true);
        if (force_disable_shadows) ProjectSettings::get_singleton()->set("rendering/shading/overrides/force_disable_shadows",true);
        print_line(vformat("DORA_GODOT_D3D12_WARP compat=%s force_disable_shadows=%d force_vertex_shading=%d",
            compat,int(force_disable_shadows),int(force_vertex)));
    }
    return true;
}
bool boot_check(const DoraGodotConfig *config) {
    if(!prepare_audio()) return false;
    runtime.project=config->project_path;
    return DoraGodotServiceBoot::boot(runtime,extension_init,"dora-d3d12","d3d12","mobile");
}
const char *check_code(const DoraGodotConfig *config,const char *file,const char *source) {
    if(!config || config->backend!=DORA_GODOT_D3D12 || !config->native_device) return DoraGodotCodeCheck::failure(file,"Invalid D3D12 compiler configuration");
    return DoraGodotCodeCheck::check(runtime,config,file,source,boot_check);
}
const char *import_asset(const DoraGodotConfig *config,const char *file,const char *options) {
    return DoraGodotAssetImport::import_asset(runtime,config,file,options,boot_check);
}

const char *inspect_scene(const DoraGodotConfig *config,const char *file,const char *options) {
    if(!config || config->size<sizeof(*config) || config->backend!=DORA_GODOT_D3D12 || !config->native_device) return DoraGodotSceneInspect::failure("","Invalid scene inspection backend configuration");
    return DoraGodotSceneInspect::inspect(runtime,config,file,options,boot_check);
}

void *open(const DoraGodotConfig *config) {
    runtime.error.clear();
    if (!config || config->size<sizeof(*config) || config->backend!=DORA_GODOT_D3D12 || !config->native_device ||
        !config->project_path || !*config->project_path || !config->width || !config->height ||
        config->width>8192 || config->height>8192 || config->buffer_count<2 || config->buffer_count>4) {
        runtime.error="invalid D3D12 Godot configuration";return nullptr;
    }
    if (runtime.active || runtime.terminated) {
        runtime.error="Godot runtime is active, terminated or startup failed";return nullptr;
    }
    runtime.scene=config->scene_path?config->scene_path:"";
    DoraGodotIME::reset();runtime.width=config->width;runtime.height=config->height;runtime.buffers=config->buffer_count;
    if (!runtime.instance) {
        if (!prepare_audio()) return nullptr;
        runtime.project=config->project_path;
        std::string resolution=std::to_string(runtime.width)+"x"+std::to_string(runtime.height);
        std::error_code path_error;
        const char *project_argument=std::filesystem::is_directory(std::filesystem::u8path(runtime.project),path_error)?"--path":"--main-pack";
        char executable[]="Dora-Godot";
        char *args[]={executable,(char*)project_argument,(char*)runtime.project.c_str(),(char*)"--display-driver",(char*)"dora-d3d12",
            (char*)"--rendering-driver",(char*)"d3d12",(char*)"--rendering-method",(char*)"mobile",
            (char*)"--audio-driver",(char*)"Dummy",(char*)"--render-thread",(char*)"safe",
            (char*)"--disable-render-loop",(char*)"--disable-crash-handler",(char*)"--resolution",(char*)resolution.c_str()};
        runtime.instance=(GodotInstance*)libgodot_create_godot_instance(sizeof(args)/sizeof(args[0]),args,extension_init);
        if (!runtime.instance) { runtime.error="LibGodot D3D12 initialization failed";return nullptr; }
        if(!configure_project(runtime.error)) return nullptr;
        if (!runtime.scene.empty()) ProjectSettings::get_singleton()->set("application/run/main_scene",String::utf8(runtime.scene.c_str()));
        if (!DoraGodotProject::start(runtime.instance)) { runtime.error="Godot D3D12 project startup failed";return nullptr; }
        std::fprintf(stderr,"DORA_GODOT_D3D12_CPU open instance_started\n");
        runtime.tree=Object::cast_to<SceneTree>(OS::get_singleton()->get_main_loop());
        std::fprintf(stderr,"DORA_GODOT_D3D12_CPU open tree=%d\n",runtime.tree!=nullptr);
        if (!runtime.tree) { runtime.error="project does not use SceneTree";return nullptr; }
        runtime.root=runtime.tree->get_root();
        std::fprintf(stderr,"DORA_GODOT_D3D12_CPU open root=%d\n",runtime.root!=nullptr);
        std::fprintf(stderr,"DORA_GODOT_D3D12_CPU open scene_ready\n");
    } else {
        if(!DoraGodotProject::load(runtime.instance,config->project_path,config->scene_path,config->width,config->height,runtime.error,true,configure_project)) {
            DoraGodotProject::unload(runtime.instance);runtime.tree=nullptr;runtime.root=nullptr;return nullptr;
        }
        runtime.project=config->project_path;
        runtime.tree=Object::cast_to<SceneTree>(OS::get_singleton()->get_main_loop());runtime.root=runtime.tree->get_root();
    }
    if(!runtime.device && !prepare_device(config->native_device)) return nullptr;
    runtime.tree->set_pause(false);runtime.root->set_transparent_background(true);runtime.root->set_disable_input(false);
    // Do not submit a temporary Windows swap-chain/offscreen draw before the
    // host-owned textures are imported. In particular, ARM64 WARP can execute
    // that queued work asynchronously after open() returns. The scene still
    // gets its startup iterations; the first draw is made into a bound slot.
    for (int i=0;i<3;++i) runtime.instance->iteration();
    std::fprintf(stderr,"DORA_GODOT_D3D12_CPU open warmup_ready\n");
    runtime.active=true;runtime.paused=false;return &runtime;
}
int bind_targets(void *handle,uint32_t width,uint32_t height,const uint64_t *handles,uint32_t count) {
    std::fprintf(stderr,"DORA_GODOT_D3D12_CPU bind begin count=%u\n",count);
    if (!valid(handle) || !handles || !width || !height || width>8192 || height>8192 || count!=runtime.buffers) return 0;
    for (uint32_t i=0;i<count;++i) {
        if (!handles[i]) return 0;
        for (uint32_t j=0;j<i;++j) if (handles[i]==handles[j]) return 0;
    }
    RenderingServer::get_singleton()->sync();clear_targets();
    runtime.root->set_size(Size2i(width,height));prepare_output();
    for (uint32_t i=0;i<count;++i) {
        auto &slot=runtime.slots[i];slot.shared_handle=handles[i];
        std::fprintf(stderr,"DORA_GODOT_D3D12_CPU bind open slot=%u\n",i);
        if (FAILED(runtime.device->OpenSharedHandle((HANDLE)(uintptr_t)handles[i],IID_PPV_ARGS(&slot.resource)))) {
            runtime.error="Godot D3D12 OpenSharedHandle failed";clear_targets();return 0;
        }
        const uint64_t usage=RenderingDevice::TEXTURE_USAGE_SAMPLING_BIT|RenderingDevice::TEXTURE_USAGE_COLOR_ATTACHMENT_BIT;
        slot.rd_texture=RenderingDevice::get_singleton()->texture_create_from_extension(RenderingDevice::TEXTURE_TYPE_2D,
            RenderingDevice::DATA_FORMAT_R8G8B8A8_UNORM,RenderingDevice::TEXTURE_SAMPLES_1,usage,
            (uint64_t)slot.resource,width,height,1,1,1);
        std::fprintf(stderr,"DORA_GODOT_D3D12_CPU bind import slot=%u valid=%d\n",i,slot.rd_texture.is_valid());
        if (!slot.rd_texture.is_valid()) { runtime.error="Godot D3D12 external texture import failed";clear_targets();return 0; }
    }
    runtime.width=width;runtime.height=height;runtime.targets_bound=true;
    print_line(vformat("DORA_GODOT_D3D12_CPU enabled buffers=%d size=%dx%d shared=1",int(count),int(width),int(height)));
    return 1;
}
int output_size(void *handle,DoraGodotOutputSize *size) {
    if (!valid(handle) || !size || size->size<sizeof(*size)) return 0;
    const Size2i physical=runtime.root->get_size();
    *size={sizeof(*size),uint32_t(physical.x),uint32_t(physical.y),uint32_t(output_pending)};return 1;
}
int get_slot(void *handle,uint32_t index,DoraGodotSlot *slot) {
    if (!valid(handle) || !slot || slot->size<sizeof(*slot) || index>=runtime.buffers || !runtime.targets_bound) return 0;
    *slot={sizeof(*slot),runtime.width,runtime.height,DORA_GODOT_RGBA8,runtime.slots[index].resource,nullptr,nullptr};return 1;
}
uint64_t advance(void *handle,uint32_t index,uint64_t) {
    if (!valid(handle) || !runtime.targets_bound || index>=runtime.buffers) return 0;
    if (!wait_host_queue()) return 0;
    auto &slot=runtime.slots[index];
    if (!select_target(index)) return 0;
    output_pending=false;
    if (runtime.instance->iteration()) { runtime.error="Godot project requested quit";return 0; }
    draw();
    // Host-owned resources use ALLOW_SIMULTANEOUS_ACCESS. Let Godot's render
    // list implicitly promote COMMON to RENDER_TARGET and decay it afterwards;
    // explicit cross-device barriers crash the ARM64 WARP worker.
    if (!wait_queue()) return 0;
    slot.published=true;runtime.completed=++runtime.sequence;return runtime.sequence;
}
#include "runtime_input.inc"
void close(void *handle,DoraGodotStats *stats) {
    if (!valid(handle)) return;
    stop_audio_capture();RenderingServer::get_singleton()->sync();
    if (stats && stats->size>=sizeof(*stats)) *stats={sizeof(*stats),runtime.sequence,runtime.completed,0,runtime.cpu_waits};
    std::fprintf(stderr,"DORA_GODOT_D3D12_CPU completed frames=%llu waits=%llu\n",
        (unsigned long long)runtime.sequence,(unsigned long long)runtime.cpu_waits);
    if (runtime.host_queue) print_line(vformat("DORA_GODOT_D3D12_CPU_READERS completed waits=%d",runtime.host_cpu_waits));
    clear_targets();release_inputs();runtime.tree->set_pause(true);runtime.active=false;
    if(!DoraGodotProject::supported(runtime.error)) runtime.terminated=true;
    else { output.close(runtime.root);DoraGodotProject::unload(runtime.instance);runtime.tree=nullptr;runtime.root=nullptr; }
    DoraGodotRenderTiming::reset();DoraGodotIME::reset();
}
void shutdown() {
    stop_audio_capture();if (runtime.active) close(&runtime,nullptr);
    if (runtime.instance) { output.close(runtime.root);libgodot_destroy_godot_instance(runtime.instance); }
    runtime.instance=nullptr;runtime.tree=nullptr;runtime.root=nullptr;
    if (runtime.fence) runtime.fence->Release();if (runtime.event_handle) CloseHandle(runtime.event_handle);
    if (runtime.host_fence) runtime.host_fence->Release();if (runtime.host_event) CloseHandle(runtime.host_event);
    if (runtime.host_queue) runtime.host_queue->Release();
    runtime.host_queue=nullptr;runtime.host_fence=nullptr;runtime.host_event=nullptr;
    runtime.fence=nullptr;runtime.event_handle=nullptr;
    runtime.device=nullptr;runtime.queue=nullptr;runtime.terminated=true;
}
}

extern "C" DORA_GODOT_EXPORT int dora_godot_get_api(uint32_t requested,DoraGodotAPI *api) {
    if (requested!=DORA_GODOT_ABI_VERSION || !api || api->size<sizeof(*api)) return 0;
    *api={sizeof(*api),DORA_GODOT_ABI_VERSION,version,open,last_error,get_slot,advance,input,set_paused,restart_scene,close,shutdown};return 1;
}
extern "C" DORA_GODOT_EXPORT int dora_godot_get_d3d12_targets_api(uint32_t requested,DoraGodotD3D12TargetsAPI *api) {
    if (requested!=DORA_GODOT_D3D12_TARGETS_ABI_VERSION || !api || api->size<sizeof(*api)) return 0;
    *api={sizeof(*api),DORA_GODOT_D3D12_TARGETS_ABI_VERSION,bind_targets};return 1;
}
extern "C" DORA_GODOT_EXPORT int dora_godot_get_audio_api(uint32_t requested,DoraGodotAudioAPI *api) {
    if (requested!=DORA_GODOT_AUDIO_ABI_VERSION || !api || api->size<sizeof(*api)) return 0;
    *api={sizeof(*api),DORA_GODOT_AUDIO_ABI_VERSION,audio_format,start_audio_capture,read_audio,audio_stats};return 1;
}
extern "C" DORA_GODOT_EXPORT int dora_godot_get_output_api(uint32_t requested,DoraGodotOutputAPI *api) {
    if (requested!=DORA_GODOT_OUTPUT_ABI_VERSION || !api || api->size<sizeof(*api)) return 0;
    *api={sizeof(*api),DORA_GODOT_OUTPUT_ABI_VERSION,output_size};return 1;
}
extern "C" DORA_GODOT_EXPORT int dora_godot_get_ime_api(uint32_t requested,DoraGodotIMEAPI *api) {
    if (requested!=DORA_GODOT_IME_ABI_VERSION || !api || api->size<sizeof(*api)) return 0;
    *api={sizeof(*api),DORA_GODOT_IME_ABI_VERSION,[](void *handle,DoraGodotIMEState *state) {
        if (!valid(handle) || !state || state->size<sizeof(*state)) return 0;
        DoraGodotIME::snapshot(state);return 1;
    }};return 1;
}
extern "C" DORA_GODOT_EXPORT int dora_godot_get_project_api(uint32_t requested,DoraGodotProjectAPI *api) {
    if(requested!=DORA_GODOT_PROJECT_ABI_VERSION || !api || api->size<sizeof(*api)) return 0;
    *api={sizeof(*api),DORA_GODOT_PROJECT_ABI_VERSION,[]()->uint32_t {
        if(runtime.terminated) return DORA_GODOT_PROJECT_TERMINATED;
        return runtime.active || runtime.tree?DORA_GODOT_PROJECT_ACTIVE:DORA_GODOT_PROJECT_UNLOADED;
    }};return 1;
}
#include "runtime_service_api.inc"
