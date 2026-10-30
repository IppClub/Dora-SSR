// Dora/Godot library implementation. Only the versioned C table is exported.
#include "register_types.h"
#include "GodotBridge.h"
#include "GodotBridgeAudio.h"
#include "GodotBridgeViewport.h"
#include "GodotAudioQueue.h"
#include "runtime_timing.h"
#include "runtime_output.h"
#include "GodotBridgeOutput.h"
#include "GodotBridgeIME.h"
#include "runtime_ime.h"
#include "core/config/engine.h"
#include "servers/audio/audio_driver_dummy.h"
#include "core/extension/libgodot.h"
#include "core/extension/godot_instance.h"
#include "core/config/project_settings.h"
#include "core/input/input_event.h"
#include "core/input/input.h"
#include "core/os/keyboard.h"
#include "core/os/os.h"
#include "scene/main/scene_tree.h"
#include "scene/main/window.h"
#include "servers/rendering/rendering_device.h"
#include "servers/rendering/rendering_server.h"
#import <Metal/Metal.h>
#include <atomic>
#include <string>
#include <set>
#include <filesystem>

void initialize_dora_bridge_module(ModuleInitializationLevel) {}
void uninitialize_dora_bridge_module(ModuleInitializationLevel) {}
namespace {
struct Slot {
    id<MTLTexture> texture;
    id<MTLSharedEvent> ready, consumed;
    uint64_t last_read = 0;
};
struct Runtime {
    std::set<Key> held_keys;
    std::set<std::pair<int,JoyButton>> held_joy_buttons;
    std::set<std::pair<int,JoyAxis>> active_joy_axes;
    GodotInstance *instance = nullptr;
    SceneTree *tree = nullptr;
    Window *root = nullptr;
    id<MTLCommandQueue> queue;
    id<MTLTexture> source;
    Slot slots[DORA_GODOT_MAX_BUFFERS];
    std::string project, scene, error;
    uint32_t width = 0, height = 0, buffers = 0;
    uint64_t sequence = 0, reuse_waits = 0;
    std::atomic<uint64_t> completed{0}, errors{0};
    bool active = false, paused = false, terminated = false;
} runtime;
DoraGodotOutput output;
bool output_pending=false;
void level(void *, GDExtensionInitializationLevel) {}
GDExtensionBool extension_init(GDExtensionInterfaceGetProcAddress, GDExtensionClassLibraryPtr, GDExtensionInitialization *init) {
    init->minimum_initialization_level = GDEXTENSION_INITIALIZATION_CORE;
    init->initialize = level; init->deinitialize = level; init->userdata = nullptr;
    return true;
}
const char *version() { return "Godot 4.6-stable / Dora bridge ABI 1"; }
const char *last_error(void *) { return runtime.error.c_str(); }
bool valid(void *handle) { return handle == &runtime && runtime.active; }
#include "runtime_audio.inc"
void offscreen() {
    auto *rs = RenderingServer::get_singleton();
    RID viewport = runtime.root->get_viewport_rid();
    rs->viewport_set_render_direct_to_screen(viewport, false);
    rs->viewport_attach_to_screen(viewport, Rect2(), DisplayServer::INVALID_WINDOW_ID);
    rs->viewport_set_update_mode(viewport, RS::VIEWPORT_UPDATE_ALWAYS);
}
void draw() {
    offscreen();
    output.prepare(runtime.root);
    RenderingServer::get_singleton()->draw(false, DoraGodotRenderTiming::consume());
    Engine::get_singleton()->increment_frames_drawn();
    RenderingServer::get_singleton()->sync();
}
void drain() {
    if (runtime.queue) {
        id<MTLCommandBuffer> marker = [runtime.queue commandBuffer];
        [marker commit]; [marker waitUntilCompleted];
        if (marker.status == MTLCommandBufferStatusError) ++runtime.errors;
    }
}
void *open(const DoraGodotConfig *config) {
    runtime.error.clear();
    if (!config || config->size < sizeof(*config) || config->backend != DORA_GODOT_METAL
        || !config->project_path || !*config->project_path || !config->native_device
        || config->width < 1 || config->height < 1 || config->width > 8192 || config->height > 8192
        || config->buffer_count < 2 || config->buffer_count > DORA_GODOT_MAX_BUFFERS) {
        runtime.error = "invalid Godot runtime configuration"; return nullptr;
    }
    if (runtime.active || runtime.terminated || (runtime.instance && !runtime.tree)) {
        runtime.error = "Godot runtime is already active or has terminated"; return nullptr;
    }
    if (runtime.instance && runtime.project != config->project_path) {
        runtime.error = "this process already owns a different Godot project"; return nullptr;
    }
    runtime.width = config->width; runtime.height = config->height; runtime.buffers = config->buffer_count;
    runtime.scene = config->scene_path ? config->scene_path : "";
    DoraGodotIME::reset();
    if (!runtime.instance) {
        if (!prepare_audio()) return nullptr;
        runtime.project = config->project_path;
        std::string resolution = std::to_string(config->width) + "x" + std::to_string(config->height);
        // FileAccess/DirAccess factories do not exist before Main::setup.
        std::error_code path_error;
        const char *project_argument=std::filesystem::is_directory(runtime.project,path_error)?"--path":"--main-pack";
        char executable[] = "Dora-Godot";
        char *args[] = {executable, (char*)project_argument, (char*)runtime.project.c_str(), (char*)"--display-driver", (char*)"dora-metal",
            (char*)"--rendering-driver", (char*)"metal", (char*)"--rendering-method", (char*)"mobile", (char*)"--audio-driver", (char*)"Dummy",
            (char*)"--disable-render-loop", (char*)"--disable-crash-handler", (char*)"--resolution", (char*)resolution.c_str()};
        runtime.instance = (GodotInstance*)libgodot_create_godot_instance(sizeof(args)/sizeof(args[0]), args, extension_init);
        if (!runtime.instance) { runtime.error = "LibGodot initialization failed"; return nullptr; }
        if (!runtime.scene.empty()) ProjectSettings::get_singleton()->set("application/run/main_scene", String::utf8(runtime.scene.c_str()));
        if (!runtime.instance->start()) { runtime.error = "Godot project startup failed"; return nullptr; }
        runtime.tree = Object::cast_to<SceneTree>(OS::get_singleton()->get_main_loop());
        if (!runtime.tree) { runtime.error = "project does not use SceneTree"; return nullptr; }
        runtime.root = runtime.tree->get_root();
        auto *rd = RenderingDevice::get_singleton();
        runtime.queue = (__bridge id<MTLCommandQueue>)(void*)(uintptr_t)rd->get_driver_resource(RenderingDevice::DRIVER_RESOURCE_COMMAND_QUEUE);
    } else {
        runtime.root->set_size(Size2i(config->width,config->height));
        const String scene = runtime.scene.empty() ? String(ProjectSettings::get_singleton()->get("application/run/main_scene")) : String::utf8(runtime.scene.c_str());
        if (runtime.tree->change_scene_to_file(scene) != OK) { runtime.error = "cannot load Godot scene"; return nullptr; }
    }
    runtime.tree->set_pause(false);
    runtime.root->set_transparent_background(true);
    runtime.root->set_disable_input(false);
    for (int i = 0; i < 3; ++i) { runtime.instance->iteration(); draw(); }
    RID texture = output.texture(runtime.root);
    runtime.source = (__bridge id<MTLTexture>)(void*)(uintptr_t)RenderingServer::get_singleton()->texture_get_native_handle(texture);
    if (!runtime.source || (__bridge void*)runtime.source.device != config->native_device || runtime.source.pixelFormat != MTLPixelFormatRGBA8Unorm) {
        runtime.error = "Godot viewport has no compatible RGBA8 Metal output"; return nullptr;
    }
    for (uint32_t i = 0; i < runtime.buffers; ++i) {
        MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:runtime.source.pixelFormat width:config->width height:config->height mipmapped:NO];
        desc.storageMode = MTLStorageModePrivate; desc.usage = MTLTextureUsageShaderRead;
        auto &slot = runtime.slots[i];
        slot.texture = [runtime.source.device newTextureWithDescriptor:desc];
        slot.ready = [runtime.source.device newSharedEvent]; slot.consumed = [runtime.source.device newSharedEvent];
        slot.last_read = 0;
        if (!slot.texture || !slot.ready || !slot.consumed) { runtime.error = "shared Metal buffer allocation failed"; return nullptr; }
    }
    runtime.sequence = 0; runtime.completed = 0; runtime.errors = 0; runtime.reuse_waits = 0;
    runtime.paused = false; runtime.active = true;
    return &runtime;
}
int resize_viewport(void *handle,uint32_t width,uint32_t height) {
    if (!valid(handle) || !width || !height || width>8192 || height>8192) return 0;
    // Resize is a lifecycle boundary; steady-state copies stay asynchronous.
    drain();
    Slot replacement[DORA_GODOT_MAX_BUFFERS];
    for (uint32_t i=0;i<runtime.buffers;++i) {
        auto *desc=[MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm width:width height:height mipmapped:NO];
        desc.storageMode=MTLStorageModePrivate; desc.usage=MTLTextureUsageShaderRead;
        replacement[i].texture=[runtime.source.device newTextureWithDescriptor:desc];
        replacement[i].ready=[runtime.source.device newSharedEvent];
        replacement[i].consumed=[runtime.source.device newSharedEvent];
        if (!replacement[i].texture || !replacement[i].ready || !replacement[i].consumed) {
            runtime.error="Metal viewport resize allocation failed"; return 0;
        }
    }
    runtime.root->set_size(Size2i(width,height));
    draw();
    const RID texture=output.texture(runtime.root);
    id<MTLTexture> source=(__bridge id<MTLTexture>)(void*)(uintptr_t)RenderingServer::get_singleton()->texture_get_native_handle(texture);
    if (!source || source.width!=width || source.height!=height || source.pixelFormat!=MTLPixelFormatRGBA8Unorm) {
        runtime.error="Godot viewport resize returned incompatible Metal texture"; return 0;
    }
    for (uint32_t i=0;i<runtime.buffers;++i) runtime.slots[i]=replacement[i];
    runtime.source=source; runtime.width=width; runtime.height=height;
    return 1;
}
int output_size(void *handle,DoraGodotOutputSize *size) {
    if (!valid(handle) || !size || size->size<sizeof(*size)) return 0;
    const Size2i physical=runtime.root->get_size();
    if (physical.x<1 || physical.y<1 || physical.x>8192 || physical.y>8192) return 0;
    *size={sizeof(*size),uint32_t(physical.x),uint32_t(physical.y),uint32_t(output_pending)};return 1;
}
int get_slot(void *handle, uint32_t index, DoraGodotSlot *out) {
    if (!valid(handle) || !out || out->size < sizeof(*out) || index >= runtime.buffers) return 0;
    auto &slot = runtime.slots[index];
    *out = {sizeof(*out), runtime.width, runtime.height, DORA_GODOT_RGBA8,
        (__bridge void*)slot.texture, (__bridge void*)slot.ready, (__bridge void*)slot.consumed};
    return 1;
}
uint64_t advance(void *handle, uint32_t index, uint64_t last_read) {
    if (!valid(handle) || index >= runtime.buffers || last_read < runtime.slots[index].last_read) return 0;
    output_pending=false;
    auto &slot = runtime.slots[index]; slot.last_read = last_read;
    if (runtime.instance->iteration()) { runtime.error = "Godot project requested quit"; return 0; }
    draw();
    RID current = output.texture(runtime.root);
    if (runtime.root->get_size()!=Size2i(runtime.width,runtime.height)) { output_pending=true; return 0; }
    id<MTLTexture> source=(__bridge id<MTLTexture>)(void*)(uintptr_t)RenderingServer::get_singleton()->texture_get_native_handle(current);
    if (!source || source.width!=runtime.width || source.height!=runtime.height || source.pixelFormat!=MTLPixelFormatRGBA8Unorm) {
        runtime.error="Godot output texture is incompatible with bound Metal slots"; return 0;
    }
    runtime.source=source;
    const uint64_t sequence=++runtime.sequence;
    id<MTLCommandBuffer> copy = [runtime.queue commandBuffer];
    if (last_read) {
        if (slot.consumed.signaledValue < last_read) ++runtime.reuse_waits;
        [copy encodeWaitForEvent:slot.consumed value:last_read];
    }
    id<MTLBlitCommandEncoder> blit = [copy blitCommandEncoder];
    [blit copyFromTexture:runtime.source sourceSlice:0 sourceLevel:0 sourceOrigin:MTLOriginMake(0,0,0)
        sourceSize:MTLSizeMake(runtime.width,runtime.height,1) toTexture:slot.texture destinationSlice:0 destinationLevel:0 destinationOrigin:MTLOriginMake(0,0,0)];
    [blit endEncoding]; [copy encodeSignalEvent:slot.ready value:sequence];
    [copy addCompletedHandler:^(id<MTLCommandBuffer> done) { if (done.status == MTLCommandBufferStatusError) ++runtime.errors; ++runtime.completed; }];
    [copy commit];
    return sequence;
}
#include "runtime_input.inc"
void close(void *handle, DoraGodotStats *stats) {
    if (!valid(handle)) return;
    stop_audio_capture();
    drain();
    if (stats && stats->size >= sizeof(*stats)) *stats = {sizeof(*stats), runtime.sequence, runtime.completed.load(), runtime.errors.load(), runtime.reuse_waits};
    for (auto &slot : runtime.slots) { slot.texture = nil; slot.ready = nil; slot.consumed = nil; }
    runtime.source = nil; runtime.active = false; DoraGodotRenderTiming::reset(); DoraGodotIME::reset();
    release_inputs();
    runtime.tree->set_pause(true);
}
void shutdown() {
    stop_audio_capture();
    if (runtime.active) close(&runtime, nullptr);
    if (runtime.instance) { output.close(runtime.root); libgodot_destroy_godot_instance(runtime.instance); }
    runtime.instance = nullptr; runtime.terminated = true;
}
}
extern "C" DORA_GODOT_EXPORT int dora_godot_get_api(uint32_t requested, DoraGodotAPI *api) {
    if (requested != DORA_GODOT_ABI_VERSION || !api || api->size < sizeof(*api)) return 0;
    *api = {sizeof(*api), DORA_GODOT_ABI_VERSION, version, open, last_error, get_slot, advance, input, set_paused, restart_scene, close, shutdown};
    return 1;
}
extern "C" DORA_GODOT_EXPORT int dora_godot_get_audio_api(uint32_t requested,DoraGodotAudioAPI *api) {
    if (requested!=DORA_GODOT_AUDIO_ABI_VERSION || !api || api->size<sizeof(*api)) return 0;
    *api={sizeof(*api),DORA_GODOT_AUDIO_ABI_VERSION,audio_format,start_audio_capture,read_audio,audio_stats}; return 1;
}

extern "C" DORA_GODOT_EXPORT int dora_godot_get_viewport_api(uint32_t requested,DoraGodotViewportAPI *api) {
    if (requested!=DORA_GODOT_VIEWPORT_ABI_VERSION || !api || api->size<sizeof(*api)) return 0;
    *api={sizeof(*api),DORA_GODOT_VIEWPORT_ABI_VERSION,resize_viewport}; return 1;
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
