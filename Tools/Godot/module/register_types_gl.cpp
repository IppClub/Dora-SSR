#ifdef ANDROID_ENABLED
#include "platform/android/thread_jandroid.h"
#endif
// Only C ABI tables are exported. GL state lives in a separate shared context.
#include "register_types.h"
#include "GodotBridgeGL.h"
#include "GodotBridgeGLTargets.h"
#include "GodotBridgeAudio.h"
#include "GodotAudioQueue.h"
#include "runtime_timing.h"
#include "runtime_output.h"
#include "GodotBridgeOutput.h"
#include "GodotBridgeIME.h"
#include "runtime_ime.h"
#include "core/config/engine.h"
#include "servers/audio/audio_driver_dummy.h"
#include "gl/gl_transport.h"
#include "gl/display_server_dora_gl.h"
#include "core/extension/libgodot.h"
#include "core/extension/godot_instance.h"
#include "core/config/project_settings.h"
#include "core/input/input_event.h"
#include "core/input/input.h"
#include "core/os/keyboard.h"
#include "core/os/os.h"
#include "scene/main/scene_tree.h"
#include "scene/main/window.h"
#include "servers/rendering/rendering_server.h"
#include <string>
#include <set>
#include <filesystem>
#include <cstring>
bool DisplayServerDoraGL::desktop=false;
void *DisplayServerDoraGL::transport=nullptr;
void initialize_dora_bridge_module(ModuleInitializationLevel) {}
void uninitialize_dora_bridge_module(ModuleInitializationLevel) {}
namespace {
struct Runtime {
    std::set<Key> held_keys;
    std::set<std::pair<int,JoyButton>> held_joy_buttons;
    std::set<std::pair<int,JoyAxis>> active_joy_axes;
    GodotInstance *instance=nullptr;
    SceneTree *tree=nullptr; Window *root=nullptr;
    void *transport=nullptr;
    std::string project,scene,error;
    uint32_t width=0,height=0,buffers=0,source=0;
    uint64_t sequence=0;
    bool active=false,paused=false,terminated=false,external_targets=false;
} runtime;
DoraGodotOutput output;
bool output_pending=false;
struct ProducerScope {
    bool ok;
    ProducerScope():ok(dora_gl_enter(runtime.transport)) {}
    ~ProducerScope() { if (ok) dora_gl_leave(runtime.transport); }
};
void level(void *,GDExtensionInitializationLevel) {}
GDExtensionBool extension_init(GDExtensionInterfaceGetProcAddress,GDExtensionClassLibraryPtr,GDExtensionInitialization *init) {
    init->minimum_initialization_level=GDEXTENSION_INITIALIZATION_CORE;
    init->initialize=level; init->deinitialize=level; init->userdata=nullptr; return true;
}
const char *version() {
#ifdef WEB_ENABLED
    return "Godot 4.6-stable / Dora bridge WebGL2 ABI 1";
#elif defined(WINDOWS_ENABLED)
    return "Godot 4.6-stable / Dora bridge WGL ABI 1";
#else
    return "Godot 4.6-stable / Dora bridge EGL ABI 1";
#endif
}
const char *last_error(void *) { return runtime.error.empty()?dora_gl_error():runtime.error.c_str(); }
bool valid(void *handle) { return handle==&runtime && runtime.active; }
#include "runtime_audio.inc"
void draw() {
    auto *rs=RenderingServer::get_singleton(); RID viewport=runtime.root->get_viewport_rid();
    rs->viewport_set_render_direct_to_screen(viewport,false);
    rs->viewport_attach_to_screen(viewport,Rect2(),DisplayServer::INVALID_WINDOW_ID);
    rs->viewport_set_update_mode(viewport,RS::VIEWPORT_UPDATE_ALWAYS);
    output.prepare(runtime.root);
    rs->draw(false,DoraGodotRenderTiming::consume());
    Engine::get_singleton()->increment_frames_drawn(); rs->sync();
}
void *open(const DoraGodotConfig *config) {
    runtime.error.clear();
    if (!config || config->size<sizeof(*config) || config->backend!=
#ifdef WEB_ENABLED
        DORA_GODOT_WEBGL2
#else
        DORA_GODOT_OPENGL
#endif
        || !config->native_device
        || !config->project_path || !*config->project_path || !config->width || !config->height
        || config->width>8192 || config->height>8192 || config->buffer_count<2 || config->buffer_count>4) {
        runtime.error="invalid GL Godot configuration"; return nullptr;
    }
    if (runtime.active || runtime.terminated || (runtime.instance && !runtime.tree)) {
        runtime.error="Godot runtime is active, terminated or startup failed"; return nullptr;
    }
    if (runtime.instance && (runtime.project!=config->project_path || ((!runtime.external_targets) && (runtime.width!=config->width
        || runtime.height!=config->height)) || runtime.buffers!=config->buffer_count)) {
        runtime.error="GL runtime reopen requires the same project, dimensions and buffer count"; return nullptr;
    }
    runtime.scene=config->scene_path?config->scene_path:"";
    DoraGodotIME::reset();
    if (!runtime.transport) {
        runtime.transport=dora_gl_create(config->native_device,config->width,config->height,config->buffer_count);
        if (!runtime.transport) return nullptr;
        runtime.width=config->width; runtime.height=config->height; runtime.buffers=config->buffer_count;
    }
    runtime.width=config->width; runtime.height=config->height;
    ProducerScope scope; if (!scope.ok) { runtime.error="cannot activate Godot GL context"; return nullptr; }
    if (!runtime.instance) {
        if (!prepare_audio()) return nullptr;
        runtime.project=config->project_path; DisplayServerDoraGL::transport=runtime.transport; DisplayServerDoraGL::desktop=dora_gl_desktop(runtime.transport);
        std::string resolution=std::to_string(runtime.width)+"x"+std::to_string(runtime.height);
        // FileAccess/DirAccess factories do not exist before Main::setup.
        std::error_code path_error;
        const char *project_argument=std::filesystem::is_directory(std::filesystem::u8path(runtime.project),path_error)?"--path":"--main-pack";
        char executable[]="Dora-Godot";
        char *args[]={executable,(char*)project_argument,(char*)runtime.project.c_str(),(char*)"--display-driver",(char*)"dora-gl",
            (char*)"--rendering-driver",(char*)(DisplayServerDoraGL::desktop?"opengl3":"opengl3_es"),
            (char*)"--rendering-method",(char*)"gl_compatibility",(char*)"--audio-driver",(char*)"Dummy",
            (char*)"--render-thread",(char*)"safe",(char*)"--disable-render-loop",(char*)"--disable-crash-handler",
            (char*)"--resolution",(char*)resolution.c_str()};
        runtime.instance=(GodotInstance*)libgodot_create_godot_instance(sizeof(args)/sizeof(args[0]),args,extension_init);
        if (!runtime.instance) { runtime.error="LibGodot GL initialization failed"; return nullptr; }
        if (!runtime.scene.empty()) ProjectSettings::get_singleton()->set("application/run/main_scene",String::utf8(runtime.scene.c_str()));
#ifdef WEB_ENABLED
        // The embedded host owns audio. Web's default Sample shortcut bypasses
        // the Godot mixer and cannot feed the selected Dummy/PCM capture driver.
        ProjectSettings::get_singleton()->set("audio/general/default_playback_type",0);
        ProjectSettings::get_singleton()->set("audio/general/default_playback_type.web",0);
#endif
        if (!runtime.instance->start()) { runtime.error="Godot project startup failed"; return nullptr; }
        runtime.tree=Object::cast_to<SceneTree>(OS::get_singleton()->get_main_loop());
        if (!runtime.tree) { runtime.error="project does not use SceneTree"; return nullptr; }
        runtime.root=runtime.tree->get_root();
    } else {
        runtime.root->set_size(Size2i(runtime.width,runtime.height));
        const String scene=runtime.scene.empty()?String(ProjectSettings::get_singleton()->get("application/run/main_scene")):String::utf8(runtime.scene.c_str());
        if (runtime.tree->change_scene_to_file(scene)!=OK) { runtime.error="cannot load Godot scene"; return nullptr; }
    }
    runtime.tree->set_pause(false);
    runtime.root->set_transparent_background(true); runtime.root->set_disable_input(false);
    for (int i=0;i<3;++i) { runtime.instance->iteration(); draw(); }
    RID texture=output.texture(runtime.root);
    runtime.source=(uint32_t)RenderingServer::get_singleton()->texture_get_native_handle(texture);
    if (!runtime.source) { runtime.error="Godot viewport has no GL texture"; return nullptr; }
    runtime.active=true; runtime.paused=false; return &runtime;
}
int bind_targets(void *handle,uint32_t width,uint32_t height,const uint32_t *textures,uint32_t count) {
    if (!valid(handle) || !textures || !width || !height || width>8192 || height>8192 || count!=runtime.buffers) return 0;
    for (uint32_t i=0;i<count;++i) {
        if (!textures[i] || textures[i]==runtime.source) return 0;
        for (uint32_t j=0;j<i;++j) if (textures[i]==textures[j]) return 0;
    }
    ProducerScope scope; if (!scope.ok) return 0;
    RenderingServer::get_singleton()->sync(); dora_gl_drain(runtime.transport);
    if (width!=runtime.width || height!=runtime.height) {
        runtime.root->set_size(Size2i(width,height)); draw();
    }
    const RID texture=output.texture(runtime.root);
    const auto source=(uint32_t)RenderingServer::get_singleton()->texture_get_native_handle(texture);
    if (!source || !dora_gl_bind_targets(runtime.transport,width,height,textures,count)) {
        runtime.error="GL viewport target replacement failed: "+std::string(dora_gl_error()); return 0;
    }
    runtime.source=source; runtime.width=width; runtime.height=height; runtime.external_targets=true;
    return 1;
}
int output_size(void *handle,DoraGodotOutputSize *size) {
    if (!valid(handle) || !size || size->size<sizeof(*size)) return 0;
    const Size2i physical=runtime.root->get_size();
    if (physical.x<1 || physical.y<1 || physical.x>8192 || physical.y>8192) return 0;
    *size={sizeof(*size),uint32_t(physical.x),uint32_t(physical.y),uint32_t(output_pending)};return 1;
}
int get_slot(void *handle,uint32_t index,DoraGodotSlot *slot) {
    if (!valid(handle) || !slot || slot->size<sizeof(*slot) || index>=runtime.buffers) return 0;
    *slot={sizeof(*slot),runtime.width,runtime.height,DORA_GODOT_RGBA8,
        (void*)(uintptr_t)dora_gl_texture(runtime.transport,index),nullptr,nullptr}; return 1;
}
uint64_t advance_impl(void *handle,uint32_t index,uint64_t last_read,bool queued) {
    if (!valid(handle) || !(queued?dora_gl_can_advance(runtime.transport,index,last_read):dora_gl_can_produce(runtime.transport,index,last_read))) return 0;
    ProducerScope scope; if (!scope.ok) return 0;
    output_pending=false;
    if (runtime.instance->iteration()) { runtime.error="Godot project requested quit"; return 0; }
    draw();
    RID texture=output.texture(runtime.root);
    if (runtime.root->get_size()!=Size2i(runtime.width,runtime.height)) { output_pending=true; return 0; }
    runtime.source=(uint32_t)RenderingServer::get_singleton()->texture_get_native_handle(texture);
    if (!runtime.source) { runtime.error="Godot output has no GL texture"; return 0; }
    return runtime.sequence=(queued?dora_gl_copy_async(runtime.transport,runtime.source,index,last_read):dora_gl_copy(runtime.transport,runtime.source,index,last_read));
}
uint64_t advance(void *handle,uint32_t index,uint64_t last_read) { return advance_impl(handle,index,last_read,false); }
uint64_t advance_async(void *handle,uint32_t index,uint64_t last_read) { return advance_impl(handle,index,last_read,true); }
#define input input_producer
#define set_paused set_paused_producer
#define restart_scene restart_scene_producer
#include "runtime_input.inc"
#undef input
#undef set_paused
#undef restart_scene
int input(void *handle,const DoraGodotInput *event) { ProducerScope scope; return scope.ok && input_producer(handle,event); }
int set_paused(void *handle,int paused) { ProducerScope scope; return scope.ok && set_paused_producer(handle,paused); }
int restart_scene(void *handle,const char *path) { ProducerScope scope; return scope.ok && restart_scene_producer(handle,path); }
void close(void *handle,DoraGodotStats *stats) {
    if (!valid(handle)) return;
    stop_audio_capture();
    // Host must drain consumers before close. Keep context and texture names
    // alive across client removal; Godot VAOs/FBOs are context-local objects.
    ProducerScope scope; if (!scope.ok) return;
    RenderingServer::get_singleton()->sync(); dora_gl_drain(runtime.transport);
    if (stats && stats->size>=sizeof(*stats)) *stats={sizeof(*stats),runtime.sequence,
        dora_gl_completed(runtime.transport),dora_gl_errors(runtime.transport),dora_gl_deferred(runtime.transport)};
    if (runtime.external_targets) dora_gl_clear_targets(runtime.transport);
    release_inputs();
    runtime.tree->set_pause(true); runtime.active=false; DoraGodotRenderTiming::reset();DoraGodotIME::reset();
}
void shutdown() {
    stop_audio_capture();
    if (runtime.active) close(&runtime,nullptr);
    if (runtime.transport) {
        { ProducerScope scope; if (scope.ok && runtime.instance) { output.close(runtime.root); libgodot_destroy_godot_instance(runtime.instance); } }
        dora_gl_destroy(runtime.transport); runtime.transport=nullptr;
    }
    runtime.instance=nullptr; runtime.terminated=true;
}
int can_produce(void *handle,uint32_t slot,uint64_t read) { return valid(handle) && dora_gl_can_produce(runtime.transport,slot,read); }
int can_advance(void *handle,uint32_t slot,uint64_t read) { return valid(handle) && dora_gl_can_advance(runtime.transport,slot,read); }
int consumer_begin(void *handle,uint32_t slot,uint64_t sequence) { return valid(handle) && dora_gl_consumer_begin(runtime.transport,slot,sequence); }
int consumer_end(void *handle,uint32_t slot,uint64_t read) { return valid(handle) && dora_gl_consumer_end(runtime.transport,slot,read); }
}
extern "C" DORA_GODOT_EXPORT int dora_godot_get_api(uint32_t requested,DoraGodotAPI *api) {
    if (requested!=DORA_GODOT_ABI_VERSION || !api || api->size<sizeof(*api)) return 0;
    *api={sizeof(*api),DORA_GODOT_ABI_VERSION,version,open,last_error,get_slot,advance,input,set_paused,restart_scene,close,shutdown}; return 1;
}
extern "C" DORA_GODOT_EXPORT int dora_godot_get_gl_api(uint32_t requested,DoraGodotGLAPI *api) {
    // Preserve the original table and synchronous entry points for ABI-1
    // consumers; the appended queued-production functions require ABI 2.
    struct Legacy { uint32_t size,abi_version; decltype(DoraGodotGLAPI::can_produce) produce;
        decltype(DoraGodotGLAPI::consumer_begin) begin; decltype(DoraGodotGLAPI::consumer_end) end; };
    static_assert(sizeof(Legacy)==offsetof(DoraGodotGLAPI,can_advance));
    if (requested==1 && api && api->size>=sizeof(Legacy)) {
        const Legacy legacy{sizeof(Legacy),1,can_produce,consumer_begin,consumer_end};
        std::memcpy(api,&legacy,sizeof(legacy)); return 1;
    }
    if (requested!=DORA_GODOT_GL_ABI_VERSION || !api || api->size<sizeof(*api)) return 0;
    *api={sizeof(*api),DORA_GODOT_GL_ABI_VERSION,can_produce,consumer_begin,consumer_end,can_advance,advance_async}; return 1;
}
extern "C" DORA_GODOT_EXPORT int dora_godot_get_audio_api(uint32_t requested,DoraGodotAudioAPI *api) {
    if (requested!=DORA_GODOT_AUDIO_ABI_VERSION || !api || api->size<sizeof(*api)) return 0;
    *api={sizeof(*api),DORA_GODOT_AUDIO_ABI_VERSION,audio_format,start_audio_capture,read_audio,audio_stats}; return 1;
}

extern "C" DORA_GODOT_EXPORT int dora_godot_get_gl_targets_api(uint32_t requested,DoraGodotGLTargetsAPI *api) {
    if (requested!=DORA_GODOT_GL_TARGETS_ABI_VERSION || !api || api->size<sizeof(*api)) return 0;
    *api={sizeof(*api),DORA_GODOT_GL_TARGETS_ABI_VERSION,bind_targets}; return 1;
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
