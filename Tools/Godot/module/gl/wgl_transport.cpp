// WGL context ownership; texture/fence logic is shared with the EGL backend.
#include "gl_transport.h"
#include "wgl_functions.h"
#include <array>
#include <string>
namespace {
thread_local std::string error;
struct Slot {
    GLuint texture=0;
    bool owned=true;
    GLsync ready=nullptr,consumed=nullptr;
    uint64_t sequence=0,read=0;
};
struct Transport {
    HGLRC host=nullptr,producer=nullptr;
    HDC host_dc=nullptr,producer_dc=nullptr;
    HWND window=nullptr;
    uint32_t width=0,height=0,buffers=0;
    GLuint source_fbo=0,target_fbo=0;
    uint64_t sequence=0,completed=0,deferred=0,errors=0;
    std::array<Slot,4> slots;
};
Transport *get(void *p) { return static_cast<Transport*>(p); }
bool check(Transport *t) {
    if (glGetError()==GL_NO_ERROR) return true;
    ++t->errors; error="OpenGL WGL transport error"; return false;
}
}
extern "C" {
const char *dora_gl_error() { return error.c_str(); }
int dora_gl_enter(void *p) {
    auto *t=get(p); return t && t->producer && wglMakeCurrent(t->producer_dc,t->producer);
}
int dora_gl_leave(void *p) {
    auto *t=get(p); return t && wglMakeCurrent(t->host_dc,t->host);
}
void *dora_gl_display(void *) { return nullptr; }
uint32_t dora_gl_framebuffer(void *) { return 0; }
int dora_gl_desktop(void *) { return 1; }
void *dora_gl_create(void *host,uint32_t width,uint32_t height,uint32_t buffers) {
    error.clear();
    if (!host || wglGetCurrentContext()!=host || !width || !height || width>8192 || height>8192 || buffers<2 || buffers>4) {
        error="invalid/current WGL host context"; return nullptr;
    }
    auto *t=new Transport;
    t->host=static_cast<HGLRC>(host);t->host_dc=wglGetCurrentDC();t->width=width;t->height=height;t->buffers=buffers;
    DoraWGL::CreateContextAttribs create=nullptr;
    if (!DoraWGL::load(create,"wglCreateContextAttribsARB") || !DoraWGL::load()) {
        error="WGL host requires OpenGL 3.3 framebuffer/sync entry points"; delete t; return nullptr;
    }
    // A separate hidden drawable provides a context with its own FBO/VAO state.
    // It has the same pixel format and share group as the existing bgfx context.
    RECT location{}; GetWindowRect(WindowFromDC(t->host_dc),&location);
    t->window=CreateWindowExW(0,L"STATIC",L"Dora Godot offscreen WGL",WS_POPUP|WS_DISABLED,
        location.left,location.top,1,1,nullptr,nullptr,GetModuleHandleW(nullptr),nullptr);
    if (!t->window) { error="cannot create WGL offscreen drawable"; dora_gl_destroy(t); return nullptr; }
    t->producer_dc=GetDC(t->window);
    const int pixel_format=GetPixelFormat(t->host_dc);
    PIXELFORMATDESCRIPTOR descriptor{};
    if (!t->producer_dc || !pixel_format || !DescribePixelFormat(t->host_dc,pixel_format,sizeof(descriptor),&descriptor)
        || !SetPixelFormat(t->producer_dc,pixel_format,&descriptor)) {
        error="cannot match host WGL pixel format"; dora_gl_destroy(t); return nullptr;
    }
    const int attrs[]={DoraWGL::ContextMajor,3,DoraWGL::ContextMinor,3,
        DoraWGL::ContextProfileMask,DoraWGL::CoreProfile,0};
    t->producer=create(t->producer_dc,t->host,attrs);
    if (!t->producer || !dora_gl_enter(t)) {
        error="cannot create/activate shared WGL producer"; dora_gl_destroy(t); return nullptr;
    }
    glGenFramebuffers(1,&t->source_fbo);glGenFramebuffers(1,&t->target_fbo);
    for (uint32_t i=0;i<buffers;++i) {
        auto &s=t->slots[i];glGenTextures(1,&s.texture);glBindTexture(GL_TEXTURE_2D,s.texture);
        glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA8,width,height,0,GL_RGBA,GL_UNSIGNED_BYTE,nullptr);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
    }
    bool ok=check(t); dora_gl_leave(t);
    if (!ok) { dora_gl_destroy(t); return nullptr; }
    return t;
}
#include "texture_ring.inc"
void dora_gl_destroy(void *p) {
    auto *t=get(p);if (!t) return;
    if (t->producer && dora_gl_enter(t)) {
        glFinish();
        for (auto &s:t->slots) {
            if (s.ready) glDeleteSync(s.ready);
            if (s.consumed) glDeleteSync(s.consumed);
            if (s.texture && s.owned) glDeleteTextures(1,&s.texture);
        }
        if (t->source_fbo) glDeleteFramebuffers(1,&t->source_fbo);
        if (t->target_fbo) glDeleteFramebuffers(1,&t->target_fbo);
    }
    dora_gl_leave(t);
    if (t->producer) wglDeleteContext(t->producer);
    if (t->producer_dc) ReleaseDC(t->window,t->producer_dc);
    if (t->window) DestroyWindow(t->window);
    delete t;
}
}
