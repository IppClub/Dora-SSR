#pragma once
#include "servers/display/display_server_headless.h"
#include "drivers/metal/rendering_context_driver_metal.h"
#include "servers/rendering/rendering_device.h"
#include "servers/rendering/renderer_rd/renderer_compositor_rd.h"

// Windowless Metal device. SDL/Dora keeps sole ownership of Cocoa and present.
class DisplayServerDoraMetal : public DisplayServerHeadless {
    RenderingContextDriverMetal *context = nullptr;
    RenderingDevice *device = nullptr;
public:
    String get_name() const override { return "dora-metal"; }
    static Vector<String> drivers() { Vector<String> result; result.push_back("metal"); return result; }
    static DisplayServer *create(const String &, WindowMode, VSyncMode, uint32_t, const Vector2i *, const Vector2i &, int, Context, int64_t, Error &error) {
        auto *server = memnew(DisplayServerDoraMetal);
        server->context = memnew(RenderingContextDriverMetal);
        error = server->context->initialize();
        if (error == OK) {
            server->device = memnew(RenderingDevice);
            error = server->device->initialize(server->context);
        }
        if (error != OK) { memdelete(server); return nullptr; }
        RendererCompositorRD::make_current();
        return server;
    }
    ~DisplayServerDoraMetal() {
        if (device) memdelete(device);
        if (context) memdelete(context);
    }
};
