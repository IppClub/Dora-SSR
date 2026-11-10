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
#if defined(LINUXBSD_ENABLED) || defined(WINDOWS_ENABLED) || defined(ANDROID_ENABLED) || defined(WEB_ENABLED)
#define DORA_GODOT_GL_PROJECT_LIFECYCLE
#endif
#ifdef DORA_GODOT_GL_PROJECT_LIFECYCLE
#include "runtime_project.h"
#include "GodotBridgeProject.h"
#endif
#include "GodotBridgeOutput.h"
#include "GodotBridgeIME.h"
#include "runtime_ime.h"
#include "core/config/engine.h"
#include "servers/audio/audio_driver_dummy.h"
#include "gl/gl_transport.h"
#include "gl/target_policy.h"
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
#include <cstdlib>
#include <cstring>
#include <cstdio>
#ifdef WINDOWS_ENABLED
#include "core/os/semaphore.h"
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>
#endif

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
    uint64_t sequence=0,direct_frames=0,blit_base=0,direct_base=0;
    uint64_t blit_gpu_time_base=0,blit_gpu_samples_base=0,blit_gpu_rejected_base=0;
    RID direct_render_target;
    uint32_t direct_original_color=0;
    bool active=false,paused=false,terminated=false,external_targets=false,direct_targets=false;
    DoraGodotGLTargetPolicy::Decision target_policy{DoraGodotGLTargetPolicy::Mode::Blit,"unbound","not-bound"};
} runtime;
DoraGodotOutput output;
bool output_pending=false;
void log_transport(const char *phase,uint32_t buffers,uint32_t width,uint32_t height) {
    char line[512];
    const auto blits=dora_gl_blits(runtime.transport)-runtime.blit_base;
    const auto direct=dora_gl_direct_publications(runtime.transport)-runtime.direct_base;
    const auto blit_gpu_time=dora_gl_blit_gpu_time_ns(runtime.transport)-runtime.blit_gpu_time_base;
    const auto blit_gpu_samples=dora_gl_blit_gpu_samples(runtime.transport)-runtime.blit_gpu_samples_base;
    const auto blit_gpu_rejected=dora_gl_blit_gpu_rejected(runtime.transport)-runtime.blit_gpu_rejected_base;
    std::snprintf(line,sizeof(line),
        "DORA_GODOT_GL_TRANSPORT phase=%s mode=%s policy=%s capability=%d reason=%s buffers=%u size=%ux%u blits=%llu direct_publications=%llu gpu_timer=%d gpu_timer_reliable=%d blit_gpu_time_ns=%llu blit_gpu_samples=%llu blit_gpu_rejected=%llu",
        phase,DoraGodotGLTargetPolicy::name(runtime.target_policy.mode),runtime.target_policy.policy,
        dora_gl_supports_direct_targets(runtime.transport),runtime.target_policy.reason,buffers,width,height,
        (unsigned long long)blits,(unsigned long long)direct,dora_gl_gpu_timer_supported(runtime.transport),
        dora_gl_gpu_timer_reliable(runtime.transport),(unsigned long long)blit_gpu_time,
        (unsigned long long)blit_gpu_samples,(unsigned long long)blit_gpu_rejected);
#if defined(ANDROID_ENABLED)
    print_line(String::utf8(line));
#elif defined(WEB_ENABLED)
    std::printf("%s\n",line);
#else
    std::fprintf(stderr,"%s\n",line);
#endif
}
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
    return "Godot 4.7.2-stable / Dora bridge WebGL2 ABI 1";
#elif defined(WINDOWS_ENABLED)
    return "Godot 4.7.2-stable / Dora bridge WGL ABI 1";
#else
    return "Godot 4.7.2-stable / Dora bridge EGL ABI 1";
#endif
}
const char *last_error(void *) {
    const char *fallback = runtime.error.empty() ? dora_gl_error() : runtime.error.c_str();
    return DoraGodotDiagnostics::get(fallback ? fallback : "");
}
bool valid(void *handle) { return handle==&runtime && runtime.active; }
#include "runtime_audio.inc"
bool attach_direct_color(RID target,uint32_t texture) {
    auto *storage=GLES3::TextureStorage::get_singleton();
    const GLuint fbo=storage->render_target_get_fbo(target);
    if (!fbo || !texture) return false;
    GLint previous=0; glGetIntegerv(GL_FRAMEBUFFER_BINDING,&previous);
    glBindFramebuffer(GL_FRAMEBUFFER,fbo);
#ifdef WINDOWS_ENABLED
    // Invalidate the old attachment before replacing it. Some WGL drivers
    // otherwise report the new texture while leaving its pixels unchanged.
    glFramebufferTexture2D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,0,0);
#endif
    glFramebufferTexture2D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,texture,0);
    const bool complete=glCheckFramebufferStatus(GL_FRAMEBUFFER)==GL_FRAMEBUFFER_COMPLETE;
    glBindFramebuffer(GL_FRAMEBUFFER,GLuint(previous)); return complete;
}
void detach_direct_target() {
    if (runtime.direct_render_target.is_valid() && runtime.direct_original_color)
        attach_direct_color(runtime.direct_render_target,runtime.direct_original_color);
    runtime.direct_render_target=RID(); runtime.direct_original_color=0;
}
void clear_direct_targets() {
    detach_direct_target(); runtime.direct_targets=false;
}
bool select_direct_target(uint32_t slot) {
    if (!runtime.direct_targets || slot>=runtime.buffers) return false;
    const RID target=output.render_target(runtime.root);
    if (!target.is_valid()) return false;
    if (runtime.direct_render_target.is_valid() && runtime.direct_render_target!=target)
        detach_direct_target();
    auto *storage=GLES3::TextureStorage::get_singleton();
    const uint32_t original=storage->render_target_get_color(target);
    const uint32_t shared=dora_gl_texture(runtime.transport,slot);
    if (!original || !attach_direct_color(target,shared)) return false;
    runtime.direct_render_target=target; runtime.direct_original_color=original; return true;
}
bool draw(int direct_slot=-1) {
    auto *rs=RenderingServer::get_singleton(); RID viewport=runtime.root->get_viewport_rid();
    rs->viewport_set_render_direct_to_screen(viewport,false);
    rs->viewport_attach_to_screen(viewport,Rect2(),DisplayServerEnums::INVALID_WINDOW_ID);
    rs->viewport_set_update_mode(viewport,RSE::VIEWPORT_UPDATE_ALWAYS);
    output.prepare(runtime.root);
    if (direct_slot>=0 && !select_direct_target(uint32_t(direct_slot))) return false;
    rs->draw(false,DoraGodotRenderTiming::consume());
    Engine::get_singleton()->increment_frames_drawn(); rs->sync(); return true;
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
    if (runtime.active || runtime.terminated
#ifndef DORA_GODOT_GL_PROJECT_LIFECYCLE
        || (runtime.instance && !runtime.tree)
#endif
    ) {
        runtime.error="Godot runtime is active, terminated or startup failed"; return nullptr;
    }
#ifndef DORA_GODOT_GL_PROJECT_LIFECYCLE
    if (runtime.instance && (runtime.project!=config->project_path || ((!runtime.external_targets) && (runtime.width!=config->width
        || runtime.height!=config->height)) || runtime.buffers!=config->buffer_count)) {
        runtime.error="GL runtime reopen requires the same project, dimensions and buffer count"; return nullptr;
    }
#endif
    runtime.scene=config->scene_path?config->scene_path:"";
    DoraGodotIME::reset();
    if (!runtime.transport) {
        runtime.transport=dora_gl_create(config->native_device,config->width,config->height,config->buffer_count);
        if (!runtime.transport) return nullptr;
        runtime.width=config->width; runtime.height=config->height; runtime.buffers=config->buffer_count;
    }
    runtime.width=config->width; runtime.height=config->height;
    ProducerScope scope; if (!scope.ok) { runtime.error="cannot activate Godot GL context"; return nullptr; }
#ifdef DORA_GODOT_GL_PROJECT_LIFECYCLE
    if (runtime.instance) {
        // The renderer and its context-local objects survive. Only the drained
        // texture ring changes dimensions/count between project lifetimes.
        if (!dora_gl_reset_targets(runtime.transport,config->width,config->height,config->buffer_count)) {
            runtime.error="cannot reset drained GL texture ring"; return nullptr;
        }
        runtime.buffers=config->buffer_count;
    }
#endif
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
            (char*)"--accessibility-driver",(char*)"dummy",
            (char*)"--render-thread",(char*)"safe",(char*)"--disable-render-loop",(char*)"--disable-crash-handler",
            (char*)"--resolution",(char*)resolution.c_str()};
        runtime.instance=(GodotInstance*)libgodot_create_godot_instance(sizeof(args)/sizeof(args[0]),args,extension_init);
        if (!runtime.instance) { runtime.error="LibGodot GL initialization failed"; return nullptr; }
#ifdef DORA_GODOT_GL_PROJECT_LIFECYCLE
        const String cache=OS::get_singleton()->get_cache_path().path_join(
#ifdef WINDOWS_ENABLED
            "Dora/LibGodot-4.7.2/wgl"
#else
            "Dora/LibGodot-4.7.2/egl"
#endif
        );
        if (DirAccess::make_dir_recursive_absolute(cache)!=OK) {
            runtime.error="cannot create process-owned Godot shader cache";runtime.terminated=true;return nullptr;
        }
        Engine::get_singleton()->set_shader_cache_path(cache);
        print_line("DORA_GODOT_PROJECT_CACHE "+cache);
#endif
        if (!runtime.scene.empty()) ProjectSettings::get_singleton()->set("application/run/main_scene",String::utf8(runtime.scene.c_str()));
#ifdef WEB_ENABLED
        // The embedded host owns audio. Web's default Sample shortcut bypasses
        // the Godot mixer and cannot feed the selected Dummy/PCM capture driver.
        ProjectSettings::get_singleton()->set("audio/general/default_playback_type",0);
        ProjectSettings::get_singleton()->set("audio/general/default_playback_type.web",0);
#endif
#ifdef DORA_GODOT_GL_PROJECT_LIFECYCLE
        const bool started=DoraGodotProject::start(runtime.instance);
#else
        const bool started=runtime.instance->start();
#endif
        if (!started) { runtime.error="Godot project startup failed"; runtime.terminated=true; return nullptr; }
#ifdef DORA_GODOT_GL_PROJECT_LIFECYCLE
        if (!DoraGodotProject::supported(runtime.error)) { runtime.terminated=true; return nullptr; }
#endif
        runtime.tree=Object::cast_to<SceneTree>(OS::get_singleton()->get_main_loop());
        if (!runtime.tree) { runtime.error="project does not use SceneTree"; return nullptr; }
        runtime.root=runtime.tree->get_root();
#ifdef DORA_GODOT_GL_PROJECT_LIFECYCLE
    } else {
        if (!DoraGodotProject::load(runtime.instance,config->project_path,config->scene_path,config->width,config->height,runtime.error)) {
            DoraGodotProject::unload(runtime.instance);
            runtime.tree=nullptr; runtime.root=nullptr;
            return nullptr;
        }
        runtime.project=config->project_path;
        runtime.tree=Object::cast_to<SceneTree>(OS::get_singleton()->get_main_loop());
        runtime.root=runtime.tree->get_root();
#else
    } else {
        runtime.root->set_size(Size2i(runtime.width,runtime.height));
        const String scene=runtime.scene.empty()?String(ProjectSettings::get_singleton()->get("application/run/main_scene")):String::utf8(runtime.scene.c_str());
        if (runtime.tree->change_scene_to_file(scene)!=OK) { runtime.error="cannot load Godot scene"; return nullptr; }
#endif
    }
#ifdef DORA_GODOT_GL_PROJECT_LIFECYCLE
    print_line(vformat("DORA_GODOT_PROJECT_ID instance=%d tree=%d",uint64_t(runtime.instance->get_instance_id()),uint64_t(runtime.tree->get_instance_id())));
#endif
    runtime.tree->set_pause(false);
    runtime.root->set_transparent_background(true); runtime.root->set_disable_input(false);
    for (int i=0;i<3;++i) { runtime.instance->iteration(); if (!draw()) { runtime.error="Godot warmup draw failed"; return nullptr; } }
    RID texture=output.texture(runtime.root);
    runtime.source=(uint32_t)RenderingServer::get_singleton()->texture_get_native_handle(texture);
    if (!runtime.source) { runtime.error="Godot viewport has no GL texture"; return nullptr; }
    runtime.direct_frames=0;
    runtime.blit_base=dora_gl_blits(runtime.transport);
    runtime.direct_base=dora_gl_direct_publications(runtime.transport);
    runtime.blit_gpu_time_base=dora_gl_blit_gpu_time_ns(runtime.transport);
    runtime.blit_gpu_samples_base=dora_gl_blit_gpu_samples(runtime.transport);
    runtime.blit_gpu_rejected_base=dora_gl_blit_gpu_rejected(runtime.transport);
    runtime.target_policy={DoraGodotGLTargetPolicy::Mode::Blit,"unbound","not-bound"};
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
    clear_direct_targets();
    const bool direct_capable=dora_gl_supports_direct_targets(runtime.transport)!=0;
    runtime.target_policy=DoraGodotGLTargetPolicy::decide(std::getenv("DORA_GODOT_GL_DIRECT"),direct_capable);
    if (runtime.target_policy.mode==DoraGodotGLTargetPolicy::Mode::Error) {
        log_transport("bind-error",count,width,height);
        runtime.error=std::string(runtime.target_policy.reason)+"; use DORA_GODOT_GL_DIRECT=0, 1 or auto";
        return 0;
    }
    runtime.direct_targets=runtime.target_policy.mode==DoraGodotGLTargetPolicy::Mode::Direct;
    if (width!=runtime.width || height!=runtime.height) {
        runtime.root->set_size(Size2i(width,height));
        if (!draw()) { runtime.error="Godot resize draw failed"; return 0; }
    }
    const RID texture=output.texture(runtime.root);
    const auto source=(uint32_t)RenderingServer::get_singleton()->texture_get_native_handle(texture);
    if (!source || !dora_gl_bind_targets(runtime.transport,width,height,textures,count)) {
        runtime.error="GL viewport target replacement failed: "+std::string(dora_gl_error()); return 0;
    }
    log_transport("bind",count,width,height);
    if (runtime.direct_targets) {
#if defined(ANDROID_ENABLED)
        print_line(vformat("DORA_GODOT_GL_DIRECT enabled buffers=%d size=%dx%d blits=0",count,width,height));
#elif defined(WEB_ENABLED)
        std::printf("DORA_GODOT_GL_DIRECT enabled buffers=%u size=%ux%u blits=0\n",count,width,height);
#else
        std::fprintf(stderr,"DORA_GODOT_GL_DIRECT enabled buffers=%u size=%ux%u blits=0\n",count,width,height);
#endif
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
    if (runtime.direct_targets && !dora_gl_begin_direct(runtime.transport,index,last_read,int(queued))) {
        runtime.error="Godot direct target consumer wait failed: "+std::string(dora_gl_error()); return 0;
    }
    if (runtime.instance->iteration()) { runtime.error="Godot project requested quit"; return 0; }
    if (!draw(runtime.direct_targets?int(index):-1)) { runtime.error="Godot direct target selection failed"; return 0; }
    RID texture=output.texture(runtime.root);
    if (runtime.root->get_size()!=Size2i(runtime.width,runtime.height)) { output_pending=true; return 0; }
    if (runtime.direct_targets) {
        const uint64_t published=queued?dora_gl_publish_async(runtime.transport,index,last_read):dora_gl_publish(runtime.transport,index,last_read);
        if (published) ++runtime.direct_frames;
        return runtime.sequence=published;
    }
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
    if (runtime.external_targets) log_transport("close",runtime.buffers,runtime.width,runtime.height);
    if (runtime.direct_targets) {
#if defined(ANDROID_ENABLED)
        print_line(vformat("DORA_GODOT_GL_DIRECT completed frames=%d blits=0",runtime.direct_frames));
#elif defined(WEB_ENABLED)
        std::printf("DORA_GODOT_GL_DIRECT completed frames=%llu blits=0\n",(unsigned long long)runtime.direct_frames);
#else
        std::fprintf(stderr,"DORA_GODOT_GL_DIRECT completed frames=%llu blits=0\n",(unsigned long long)runtime.direct_frames);
#endif
    }
    clear_direct_targets();
    if (runtime.external_targets) dora_gl_clear_targets(runtime.transport);
    release_inputs();
    runtime.tree->set_pause(true); runtime.active=false; DoraGodotRenderTiming::reset();DoraGodotIME::reset();
#ifdef DORA_GODOT_GL_PROJECT_LIFECYCLE
    runtime.external_targets=false; runtime.source=0;
    if (!DoraGodotProject::supported(runtime.error)) {
        runtime.terminated=true;
        ERR_PRINT(runtime.error.c_str());
    } else {
        output.close(runtime.root);
        DoraGodotProject::unload(runtime.instance);
        runtime.tree=nullptr; runtime.root=nullptr;
    }
#endif
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

#ifdef DORA_GODOT_GL_PROJECT_LIFECYCLE
extern "C" DORA_GODOT_EXPORT int dora_godot_get_project_api(uint32_t requested,DoraGodotProjectAPI *api) {
    if (requested!=DORA_GODOT_PROJECT_ABI_VERSION || !api || api->size<sizeof(*api)) return 0;
    *api={sizeof(*api),DORA_GODOT_PROJECT_ABI_VERSION,[]()->uint32_t {
        if (runtime.terminated) return DORA_GODOT_PROJECT_TERMINATED;
        if (runtime.active || runtime.tree) return DORA_GODOT_PROJECT_ACTIVE;
        return DORA_GODOT_PROJECT_UNLOADED;
    }};return 1;
}
#endif
