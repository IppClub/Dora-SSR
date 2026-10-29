#pragma once
#include "servers/display/display_server_headless.h"
#include "drivers/metal/rendering_context_driver_metal.h"
#include "servers/rendering/rendering_device.h"
#include "servers/rendering/renderer_rd/renderer_compositor_rd.h"
#include "runtime_ime.h"

// Windowless Metal device. SDL/Dora keeps sole ownership of Cocoa and present.
class DisplayServerDoraMetal : public DisplayServerHeadless {
    RenderingContextDriverMetal *context = nullptr;
    RenderingDevice *device = nullptr;
    Size2i virtual_size{640, 360};
public:
    bool has_feature(Feature feature) const override { return feature==FEATURE_IME || feature==FEATURE_VIRTUAL_KEYBOARD; }
    int get_screen_count() const override { return 1; }
    Size2i screen_get_size(int = SCREEN_OF_MAIN_WINDOW) const override { return virtual_size; }
    Rect2i screen_get_usable_rect(int = SCREEN_OF_MAIN_WINDOW) const override { return Rect2i(Point2i(), virtual_size); }
    Size2i window_get_size(WindowID = MAIN_WINDOW_ID) const override { return virtual_size; }
    void window_set_size(const Size2i size, WindowID = MAIN_WINDOW_ID) override { virtual_size = size; }
    WindowMode window_get_mode(WindowID = MAIN_WINDOW_ID) const override { return WINDOW_MODE_WINDOWED; }
    void window_set_ime_active(const bool active, WindowID = MAIN_WINDOW_ID) override { DoraGodotIME::set_active(active); }
    void window_set_ime_position(const Point2i &position, WindowID = MAIN_WINDOW_ID) override { DoraGodotIME::set_position(position.x, position.y); }
    void virtual_keyboard_show(const String &, const Rect2 &rect = Rect2(), VirtualKeyboardType = KEYBOARD_TYPE_DEFAULT, int = -1, int = -1, int = -1) override {
        DoraGodotIME::set_position(int(rect.position.x), int(rect.position.y)); DoraGodotIME::set_active(true);
    }
    void virtual_keyboard_hide() override { DoraGodotIME::set_active(false); }
    String get_name() const override { return "dora-metal"; }
    static Vector<String> drivers() { Vector<String> result; result.push_back("metal"); return result; }
    static DisplayServer *create(const String &, WindowMode, VSyncMode, uint32_t, const Vector2i *, const Vector2i &resolution, int, Context, int64_t, Error &error) {
        auto *server = memnew(DisplayServerDoraMetal);
        if (resolution.x>0 && resolution.y>0) server->virtual_size=resolution;
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
