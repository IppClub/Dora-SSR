// EGL/OpenGL transport shared by the LibGodot module and the native GL test.
#include "gl_transport.h"
#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <GLES3/gl3.h>
#include <array>
#include <string>
#include <cstring>
namespace {
thread_local std::string error;
struct Slot {
    GLuint texture=0;
    bool owned=true;
    GLsync ready=nullptr, consumed=nullptr;
    uint64_t sequence=0, read=0;
};
struct Transport {
    EGLDisplay display=EGL_NO_DISPLAY;
    EGLContext host=EGL_NO_CONTEXT, producer=EGL_NO_CONTEXT;
    EGLSurface draw=EGL_NO_SURFACE, read=EGL_NO_SURFACE, surface=EGL_NO_SURFACE;
    EGLenum api=EGL_OPENGL_ES_API;
    uint32_t width=0,height=0,buffers=0;
    GLuint source_fbo=0,target_fbo=0,auxiliary_fbo=0,auxiliary_color=0;
    uint64_t sequence=0,completed=0,deferred=0,errors=0;
    std::array<Slot,4> slots;
};
Transport *get(void *p) { return static_cast<Transport*>(p); }
bool check(Transport *t) {
    const auto code=glGetError();
    if (code==GL_NO_ERROR) return true;
    ++t->errors; error="OpenGL transport error code="+std::to_string(code); return false;
}
}
extern "C" {
const char *dora_gl_error() { return error.c_str(); }
int dora_gl_enter(void *p) {
    auto *t=get(p);
    return t && eglMakeCurrent(t->display,t->surface,t->surface,t->producer);
}
int dora_gl_leave(void *p) {
    auto *t=get(p);
    return t && eglMakeCurrent(t->display,t->draw,t->read,t->host);
}
void *dora_gl_display(void *p) { return get(p)->display; }
uint32_t dora_gl_framebuffer(void *p) { return get(p)?get(p)->auxiliary_fbo:0; }
int dora_gl_desktop(void *p) { return get(p)->api==EGL_OPENGL_API; }
void *dora_gl_create(void *host, uint32_t width, uint32_t height, uint32_t buffers) {
    error.clear();
    if (!width || !height || width>8192 || height>8192 || buffers<2 || buffers>4
        || !host || eglGetCurrentContext()!=host) { error="invalid/current EGL host context"; return nullptr; }
    auto *t=new Transport;
    t->host=static_cast<EGLContext>(host); t->display=eglGetCurrentDisplay();
    t->draw=eglGetCurrentSurface(EGL_DRAW); t->read=eglGetCurrentSurface(EGL_READ);
    t->api=eglQueryAPI(); t->width=width; t->height=height; t->buffers=buffers;
    EGLint config_id=0, count=0; EGLConfig config=nullptr;
    eglQueryContext(t->display,t->host,EGL_CONFIG_ID,&config_id);
    const EGLint match[]={EGL_CONFIG_ID,config_id,EGL_NONE};
    if (!eglChooseConfig(t->display,match,&config,1,&count) || count!=1) {
        error="cannot resolve host EGL config"; delete t; return nullptr;
    }
    const EGLint es[]={EGL_CONTEXT_CLIENT_VERSION,3,EGL_NONE};
    const EGLint desktop[]={EGL_CONTEXT_MAJOR_VERSION_KHR,3,EGL_CONTEXT_MINOR_VERSION_KHR,3,
        EGL_CONTEXT_OPENGL_PROFILE_MASK_KHR,EGL_CONTEXT_OPENGL_CORE_PROFILE_BIT_KHR,EGL_NONE};
    t->producer=eglCreateContext(t->display,config,t->host,t->api==EGL_OPENGL_API?desktop:es);
    if (t->producer==EGL_NO_CONTEXT) { error="cannot create shared EGL context"; delete t; return nullptr; }
    EGLint surfaces=0;
    eglGetConfigAttrib(t->display,config,EGL_SURFACE_TYPE,&surfaces);
    const char *extensions=eglQueryString(t->display,EGL_EXTENSIONS);
    if (surfaces&EGL_PBUFFER_BIT) {
        const EGLint pb[]={EGL_WIDTH,1,EGL_HEIGHT,1,EGL_NONE};
        t->surface=eglCreatePbufferSurface(t->display,config,pb);
        if (t->surface==EGL_NO_SURFACE) { error="cannot create EGL producer pbuffer"; dora_gl_destroy(t); return nullptr; }
    } else if (!extensions || !std::strstr(extensions,"EGL_KHR_surfaceless_context")) {
        error="EGL producer requires pbuffer or surfaceless support"; dora_gl_destroy(t); return nullptr;
    }
    if (!dora_gl_enter(t)) { error="cannot activate EGL producer"; dora_gl_destroy(t); return nullptr; }
    // Wayland EGL configs may only support window surfaces. Godot's particle
    // transform-feedback draw still requires a complete framebuffer on Mesa,
    // even with rasterizer discard. Give its auxiliary passes a private FBO.
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER)!=GL_FRAMEBUFFER_COMPLETE) {
        glGenRenderbuffers(1,&t->auxiliary_color);
        glBindRenderbuffer(GL_RENDERBUFFER,t->auxiliary_color);
        glRenderbufferStorage(GL_RENDERBUFFER,GL_RGBA8,1,1);
        glGenFramebuffers(1,&t->auxiliary_fbo);
        glBindFramebuffer(GL_FRAMEBUFFER,t->auxiliary_fbo);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_RENDERBUFFER,t->auxiliary_color);
        const bool complete=glCheckFramebufferStatus(GL_FRAMEBUFFER)==GL_FRAMEBUFFER_COMPLETE;
        glBindFramebuffer(GL_FRAMEBUFFER,0); glBindRenderbuffer(GL_RENDERBUFFER,0);
        if (!complete) { error="cannot create complete Godot auxiliary framebuffer"; dora_gl_destroy(t); return nullptr; }
    }
    glGenFramebuffers(1,&t->source_fbo); glGenFramebuffers(1,&t->target_fbo);
    for (uint32_t i=0;i<buffers;++i) {
        auto &s=t->slots[i]; glGenTextures(1,&s.texture); glBindTexture(GL_TEXTURE_2D,s.texture);
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
    auto *t=get(p); if (!t) return;
    if (t->producer!=EGL_NO_CONTEXT && dora_gl_enter(t)) {
        glFinish();
        for (auto &s:t->slots) {
            if (s.ready) glDeleteSync(s.ready);
            if (s.consumed) glDeleteSync(s.consumed);
            if (s.texture && s.owned) glDeleteTextures(1,&s.texture);
        }
        if (t->auxiliary_fbo) glDeleteFramebuffers(1,&t->auxiliary_fbo);
        if (t->auxiliary_color) glDeleteRenderbuffers(1,&t->auxiliary_color);
        if (t->source_fbo) glDeleteFramebuffers(1,&t->source_fbo);
        if (t->target_fbo) glDeleteFramebuffers(1,&t->target_fbo);
    }
    dora_gl_leave(t);
    if (t->surface!=EGL_NO_SURFACE) eglDestroySurface(t->display,t->surface);
    if (t->producer!=EGL_NO_CONTEXT) eglDestroyContext(t->display,t->producer);
    delete t;
}
}
