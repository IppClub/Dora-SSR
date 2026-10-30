#pragma once
#include "servers/display/display_server_headless.h"
#include "drivers/gles3/rasterizer_gles3.h"
#include "drivers/gles3/storage/texture_storage.h"
#include "gl_transport.h"
#include "../runtime_ime.h"
// The host/module owns the shared EGL context; this virtual display never
// creates a window, changes contexts, swaps, or owns the host event loop.
class DisplayServerDoraGL : public DisplayServerHeadless {
    Size2i virtual_size{640,360};
public:
    static bool desktop;
    static void *transport;
    bool has_feature(Feature feature) const override { return feature==FEATURE_IME || feature==FEATURE_VIRTUAL_KEYBOARD; }
    int get_screen_count() const override { return 1; }
    Size2i screen_get_size(int=SCREEN_OF_MAIN_WINDOW) const override { return virtual_size; }
    Rect2i screen_get_usable_rect(int=SCREEN_OF_MAIN_WINDOW) const override { return Rect2i(Point2i(),virtual_size); }
    Size2i window_get_size(WindowID=MAIN_WINDOW_ID) const override { return virtual_size; }
    void window_set_size(const Size2i size,WindowID=MAIN_WINDOW_ID) override { virtual_size=size; }
    WindowMode window_get_mode(WindowID=MAIN_WINDOW_ID) const override { return WINDOW_MODE_WINDOWED; }
    void window_set_ime_active(const bool active,WindowID=MAIN_WINDOW_ID) override { DoraGodotIME::set_active(active); }
    void window_set_ime_position(const Point2i &position,WindowID=MAIN_WINDOW_ID) override { DoraGodotIME::set_position(position.x,position.y); }
    void virtual_keyboard_show(const String &,const Rect2 &rect=Rect2(),VirtualKeyboardType=KEYBOARD_TYPE_DEFAULT,int=-1,int=-1,int=-1) override {
        DoraGodotIME::set_position(int(rect.position.x),int(rect.position.y));DoraGodotIME::set_active(true);
    }
    void virtual_keyboard_hide() override { DoraGodotIME::set_active(false); }
    String get_name() const override { return "dora-gl"; }
    static Vector<String> drivers() { Vector<String> r; r.push_back("opengl3"); r.push_back("opengl3_es"); return r; }
    static DisplayServer *create(const String &,WindowMode,VSyncMode,uint32_t,const Vector2i *,const Vector2i &resolution,int,Context,int64_t,Error &error) {
        // Unlike an OS-owned EGLManager, our host already initialized EGL.
        // Initialize Godot's private GLAD dispatch table for that existing display.
#if defined(EGL_ENABLED) && !defined(WINDOWS_ENABLED)
        if (!gladLoaderLoadEGL((EGLDisplay)dora_gl_display(transport))) {
            error=ERR_UNAVAILABLE; return nullptr;
        }
#endif
        auto *server=memnew(DisplayServerDoraGL);
        if (resolution.x>0 && resolution.y>0) server->virtual_size=resolution;
        GLES3::TextureStorage::system_fbo=dora_gl_framebuffer(transport);
        RasterizerGLES3::make_current(desktop); error=OK; return server;
    }
};
