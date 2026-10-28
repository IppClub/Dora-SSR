// Experimental host bridge, compiled into the pinned LibGodot build.
#include "register_types.h"
#include "bridge.h"
#include "core/io/resource_loader.h"
#include "modules/gdscript/gdscript.h"
#include <atomic>
#include "core/extension/libgodot.h"
#include "core/extension/godot_instance.h"
#include "core/os/os.h"
#include "scene/main/scene_tree.h"
#include "scene/main/viewport.h"
#include "scene/main/window.h"
#include "scene/gui/color_rect.h"
#include "scene/3d/camera_3d.h"
#include "scene/3d/light_3d.h"
#include "scene/3d/mesh_instance_3d.h"
#include "scene/resources/3d/primitive_meshes.h"
#include "scene/resources/material.h"
#include "servers/rendering/rendering_device.h"
#include "servers/rendering/rendering_server.h"
#import <Metal/Metal.h>
#include <cstdio>

void initialize_dora_metal_probe_module(ModuleInitializationLevel) {}
void uninitialize_dora_metal_probe_module(ModuleInitializationLevel) {}
static GodotInstance *instance;
static SubViewport *viewport;
static MeshInstance3D *cube;
static constexpr int MaxBuffers = 4;
struct Slot {
    id<MTLTexture> texture;
    id<MTLSharedEvent> ready, consumed;
    uint64_t last_read = 0;
};
static Slot slots[MaxBuffers];
static int buffer_count;
static id<MTLTexture> source_texture;
static id<MTLCommandQueue> producer_queue;
static ColorRect *stamps[2][16];
static uint64_t produced, reuse_waits;
static std::atomic<uint64_t> completed{0}, gpu_errors{0};

extern "C" __attribute__((visibility("default"))) uint64_t dora_godot_probe_advance(int slot, uint64_t last_read) {
    if (!instance || slot < 0 || slot >= buffer_count || last_read < slots[slot].last_read) return 0;
    auto &target = slots[slot];
    target.last_read = last_read;
    const uint64_t sequence = ++produced;
    for (int row = 0; row < 2; ++row)
        for (int bit = 0; bit < 16; ++bit)
            stamps[row][bit]->set_color((sequence & (1ull << bit)) ? Color(1,1,1) : Color(0,0,0));
    // Flush ColorRect queue_redraw in this iteration, not the next frame.
    instance->iteration(); // Executes the GDScript _process animation.
    RenderingServer::get_singleton()->draw(false, 1.0 / 60.0);
    RenderingServer::get_singleton()->sync();
    RID current_texture = RenderingServer::get_singleton()->viewport_get_texture(viewport->get_viewport_rid());
    if ((uintptr_t)RenderingServer::get_singleton()->texture_get_native_handle(current_texture) != (uintptr_t)(__bridge void*)source_texture) return 0;
    // Godot has committed this frame on producer_queue. The source Viewport and
    // this blit use that SAME queue, so next-frame rendering cannot race the copy.
    id<MTLCommandBuffer> copy = [producer_queue commandBuffer];
    copy.label = @"Godot -> shared ring buffer";
    if (last_read) {
        if (target.consumed.signaledValue < last_read) ++reuse_waits;
        [copy encodeWaitForEvent:target.consumed value:last_read];
    }
    id<MTLBlitCommandEncoder> blit = [copy blitCommandEncoder];
    [blit copyFromTexture:source_texture sourceSlice:0 sourceLevel:0 sourceOrigin:MTLOriginMake(0,0,0)
        sourceSize:MTLSizeMake(source_texture.width, source_texture.height, 1)
        toTexture:target.texture destinationSlice:0 destinationLevel:0 destinationOrigin:MTLOriginMake(0,0,0)];
    [blit endEncoding];
    [copy encodeSignalEvent:target.ready value:sequence];
    [copy addCompletedHandler:^(id<MTLCommandBuffer> command) {
        if (command.status == MTLCommandBufferStatusError) {
            ++gpu_errors;
            fprintf(stderr, "GODOT_METAL_PROBE FAIL: producer GPU %s\n", command.error.description.UTF8String);
        }
        ++completed;
    }];
    [copy commit]; // No CPU wait or pixel readback on the frame path.
    return sequence;
}

extern "C" __attribute__((visibility("default"))) int dora_godot_probe_slot(int index, DoraGodotProbeSlot *out) {
    if (!out || index < 0 || index >= buffer_count) return 0;
    *out = {(__bridge void*)slots[index].texture, (__bridge void*)slots[index].ready, (__bridge void*)slots[index].consumed};
    return 1;
}
static void extension_level(void *, GDExtensionInitializationLevel) {}
static GDExtensionBool extension_init(GDExtensionInterfaceGetProcAddress, GDExtensionClassLibraryPtr, GDExtensionInitialization *init) {
    init->minimum_initialization_level = GDEXTENSION_INITIALIZATION_CORE;
    init->userdata = nullptr;
    init->initialize = extension_level;
    init->deinitialize = extension_level;
    return true;
}
extern "C" __attribute__((visibility("default"))) void *dora_godot_probe_start(const char *project, int width, int height, int buffers) {
    if (buffers < 2 || buffers > MaxBuffers) return nullptr;
    buffer_count = buffers;
    char executable[] = "Dora-LibGodot-Metal-Probe";
    char *args[] = {executable, (char*)"--path", const_cast<char*>(project), (char*)"--display-driver", (char*)"dora-metal", (char*)"--rendering-driver", (char*)"metal", (char*)"--rendering-method", (char*)"mobile", (char*)"--audio-driver", (char*)"Dummy", (char*)"--disable-render-loop", (char*)"--disable-crash-handler"};
    instance = (GodotInstance*)libgodot_create_godot_instance(sizeof(args)/sizeof(args[0]), args, extension_init);
    if (!instance || !instance->start()) return nullptr;
    SceneTree *tree = Object::cast_to<SceneTree>(OS::get_singleton()->get_main_loop());
    if (!tree || !RenderingDevice::get_singleton()) return nullptr;
    viewport = memnew(SubViewport);
    viewport->set_size(Size2i(width, height));
    viewport->set_update_mode(SubViewport::UPDATE_ALWAYS);
    viewport->set_use_own_world_3d(true);
    viewport->set_transparent_background(true);
    tree->get_root()->add_child(viewport);
    cube = memnew(MeshInstance3D);
    Ref<BoxMesh> mesh; mesh.instantiate();
    mesh->set_size(Vector3(1.8, 1.8, 1.8));
    cube->set_mesh(mesh);
    Ref<StandardMaterial3D> material; material.instantiate();
    material->set_albedo(Color(0.12, 0.7, 0.95));
    material->set_roughness(0.4);
    cube->set_material_override(material);
    cube->set_rotation(Vector3(0.4, 0.65, 0.1));
    Ref<GDScript> animation = ResourceLoader::load("res://spin.gd");
    if (animation.is_null()) return nullptr;
    cube->set_script(animation);
    viewport->add_child(cube);
    Camera3D *camera = memnew(Camera3D);
    viewport->add_child(camera);
    camera->set_position(Vector3(0, 0, 5));
    camera->set_current(true);
    DirectionalLight3D *light = memnew(DirectionalLight3D);
    viewport->add_child(light);
    light->set_rotation(Vector3(-0.5, -0.6, 0));
    light->set_param(Light3D::PARAM_ENERGY, 2.0);
    // Godot-rendered corner markers identify orientation and alpha compositing.
    const Color colors[] = {Color(1, 0.2, 0.15), Color(0.2, 1, 0.25), Color(0.2, 0.45, 1), Color(1, 0.85, 0.15)};
    for (int i = 0; i < 4; ++i) {
        ColorRect *marker = memnew(ColorRect);
        marker->set_color(colors[i]);
        marker->set_position(Vector2((i % 2) ? width - 42 : 10, (i / 2) ? height - 42 : 10));
        marker->set_size(Vector2(32, 32));
        viewport->add_child(marker);
    }
    // Redundant frame stamps allow final-output screenshots to detect torn copies.
    for (int row = 0; row < 2; ++row) {
        for (int bit = 0; bit < 16; ++bit) {
            auto *stamp = memnew(ColorRect);
            stamp->set_position(Vector2(224 + bit * 12, row == 0 ? 12 : height - 24));
            stamp->set_size(Vector2(10, 12));
            viewport->add_child(stamp);
            stamps[row][bit] = stamp;
        }
    }
    // Warm up the viewport before obtaining its stable native output texture.
    for (int i = 0; i < 8; ++i) {
        instance->iteration();
        RenderingServer::get_singleton()->draw(false, 1.0 / 60.0);
    }
    RenderingServer::get_singleton()->sync();
    auto *rd = RenderingDevice::get_singleton();
    producer_queue = (__bridge id<MTLCommandQueue>)(void*)(uintptr_t)rd->get_driver_resource(RenderingDevice::DRIVER_RESOURCE_COMMAND_QUEUE);
    RID texture = RenderingServer::get_singleton()->viewport_get_texture(viewport->get_viewport_rid());
    source_texture = (__bridge id<MTLTexture>)(void*)(uintptr_t)RenderingServer::get_singleton()->texture_get_native_handle(texture);
    if (!source_texture || !producer_queue) return nullptr;
    for (int i = 0; i < buffer_count; ++i) {
        MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:source_texture.pixelFormat width:width height:height mipmapped:NO];
        desc.storageMode = MTLStorageModePrivate;
        desc.usage = MTLTextureUsageShaderRead;
        slots[i].texture = [source_texture.device newTextureWithDescriptor:desc];
        slots[i].ready = [source_texture.device newSharedEvent];
        slots[i].consumed = [source_texture.device newSharedEvent];
        if (!slots[i].texture || !slots[i].ready || !slots[i].consumed) return nullptr;
    }
    if (!dora_godot_probe_advance(0, 0)) return nullptr;
    fprintf(stderr, "GODOT_METAL_PROBE producer device=%s size=%dx%d buffers=%d dynamic_gdscript=1 gpu_blit=1\n", source_texture.device.name.UTF8String, width, height, buffer_count);
    return (__bridge void*)slots[0].texture;
}
extern "C" __attribute__((visibility("default"))) void dora_godot_probe_stop(DoraGodotProbeStats *stats) {
    // Called after bgfx shutdown; every consumed event has now been signaled.
    if (producer_queue) {
        id<MTLCommandBuffer> drain = [producer_queue commandBuffer];
        [drain commit]; [drain waitUntilCompleted];
        if (drain.status == MTLCommandBufferStatusError) ++gpu_errors;
    }
    if (stats) *stats = {produced, completed.load(), gpu_errors.load(), reuse_waits, (uint64_t)buffer_count};
    for (auto &slot : slots) { slot.texture = nil; slot.ready = nil; slot.consumed = nil; }
    source_texture = nil; producer_queue = nil;
    if (instance) libgodot_destroy_godot_instance(instance);
    instance = nullptr; viewport = nullptr; cube = nullptr;
}
