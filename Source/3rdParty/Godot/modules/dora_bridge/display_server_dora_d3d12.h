#pragma once
#include "platform/windows/display_server_windows.h"
#include "runtime_ime.h"

// Preserve the native D3D12 device/surface setup while Dora owns text input.
class DisplayServerDoraD3D12 : public DisplayServerWindows {
public:
    using DisplayServerWindows::DisplayServerWindows;
    String get_name() const override { return "dora-d3d12"; }
    void show_window(DisplayServerEnums::WindowID window) override {
        // Keep the native main surface for D3D12 initialization, while Dora
        // owns the visible window and focus for the offscreen viewport.
        if (window != DisplayServerEnums::MAIN_WINDOW_ID) DisplayServerWindows::show_window(window);
    }
    bool has_feature(DisplayServerEnums::Feature feature) const override {
        return feature == DisplayServerEnums::FEATURE_VIRTUAL_KEYBOARD || DisplayServerWindows::has_feature(feature);
    }
    void window_set_ime_active(const bool active, DisplayServerEnums::WindowID = DisplayServerEnums::MAIN_WINDOW_ID) override { DoraGodotIME::set_active(active); }
    void window_set_ime_position(const Point2i &position, DisplayServerEnums::WindowID = DisplayServerEnums::MAIN_WINDOW_ID) override { DoraGodotIME::set_position(position.x, position.y); }
    void virtual_keyboard_show(const String &, const Rect2 &rect = Rect2(), DisplayServerEnums::VirtualKeyboardType = DisplayServerEnums::KEYBOARD_TYPE_DEFAULT, int = -1, int = -1, int = -1) override {
        DoraGodotIME::set_position(int(rect.position.x), int(rect.position.y));
        DoraGodotIME::set_active(true);
    }
    void virtual_keyboard_hide() override { DoraGodotIME::set_active(false); }
    static Vector<String> drivers() { Vector<String> result; result.push_back("d3d12"); return result; }
    static DisplayServer *create(const String &driver, DisplayServerEnums::WindowMode mode, DisplayServerEnums::VSyncMode vsync, uint32_t flags,
            const Vector2i *position, const Vector2i &resolution, int screen, DisplayServerEnums::Context context, int64_t parent, Error &error) {
        auto *server = memnew(DisplayServerDoraD3D12(driver, mode, vsync, flags, position, resolution, screen, context, parent, error));
        if (error != OK) { memdelete(server); return nullptr; }
        return server;
    }
};
