// EGL/OpenGL transport shared by the LibGodot module and the native GL test.
#include "gl_transport.h"
#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <GLES3/gl3.h>
#include <GLES2/gl2ext.h>
#include <array>
#include <string>
#include <cstring>
#include <cstdlib>
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
    uint64_t sequence=0,completed=0,deferred=0,errors=0,blits=0,direct_publications=0;
    bool gpu_timer_supported=false,gpu_timer_reliable=false,gpu_timer_active=false;
    uint32_t gpu_timer_index=0;
    uint64_t blit_gpu_time_ns=0,blit_gpu_samples=0,blit_gpu_rejected=0;
    std::array<GLuint,8> gpu_timer_queries{};
    std::array<bool,8> gpu_timer_pending{};
    PFNGLGENQUERIESEXTPROC gen_queries=nullptr;
    PFNGLDELETEQUERIESEXTPROC delete_queries=nullptr;
    PFNGLBEGINQUERYEXTPROC begin_query=nullptr;
    PFNGLENDQUERYEXTPROC end_query=nullptr;
    PFNGLGETQUERYOBJECTUIVEXTPROC get_query_uiv=nullptr;
    PFNGLGETQUERYOBJECTUI64VEXTPROC get_query_ui64v=nullptr;
    std::array<Slot,4> slots;
};
Transport *get(void *p) { return static_cast<Transport*>(p); }
bool check(Transport *t) {
    const auto code=glGetError();
    if (code==GL_NO_ERROR) return true;
    ++t->errors; error="OpenGL transport error code="+std::to_string(code); return false;
}
bool has_extension(Transport *t,const char *name) {
    if (t->api==EGL_OPENGL_ES_API) {
        const auto *extensions=reinterpret_cast<const char*>(glGetString(GL_EXTENSIONS));
        return extensions && std::strstr(extensions,name);
    }
    GLint count=0; glGetIntegerv(GL_NUM_EXTENSIONS,&count);
    for (GLint i=0;i<count;++i) {
        const auto *extension=reinterpret_cast<const char*>(glGetStringi(GL_EXTENSIONS,GLuint(i)));
        if (extension && std::strcmp(extension,name)==0) return true;
    }
    return false;
}
template <class T> T load_timer(const char *name) { return reinterpret_cast<T>(eglGetProcAddress(name)); }
void timer_init(Transport *t) {
    if (!std::getenv("DORA_GODOT_GL_METRICS") || std::strcmp(std::getenv("DORA_GODOT_GL_METRICS"),"1")!=0
        || !has_extension(t,"GL_EXT_disjoint_timer_query")) return;
    t->gen_queries=load_timer<PFNGLGENQUERIESEXTPROC>("glGenQueriesEXT");
    t->delete_queries=load_timer<PFNGLDELETEQUERIESEXTPROC>("glDeleteQueriesEXT");
    t->begin_query=load_timer<PFNGLBEGINQUERYEXTPROC>("glBeginQueryEXT");
    t->end_query=load_timer<PFNGLENDQUERYEXTPROC>("glEndQueryEXT");
    t->get_query_uiv=load_timer<PFNGLGETQUERYOBJECTUIVEXTPROC>("glGetQueryObjectuivEXT");
    t->get_query_ui64v=load_timer<PFNGLGETQUERYOBJECTUI64VEXTPROC>("glGetQueryObjectui64vEXT");
    if (!t->gen_queries || !t->delete_queries || !t->begin_query || !t->end_query
        || !t->get_query_uiv || !t->get_query_ui64v) return;
    t->gen_queries(GLsizei(t->gpu_timer_queries.size()),t->gpu_timer_queries.data());
    t->gpu_timer_supported=check(t);
    t->gpu_timer_reliable=t->gpu_timer_supported;
}
void timer_poll(Transport *t) {
    if (!t || !t->gpu_timer_supported) return;
    GLint disjoint=0; glGetIntegerv(GL_GPU_DISJOINT_EXT,&disjoint);
    for (size_t i=0;i<t->gpu_timer_queries.size();++i) {
        if (!t->gpu_timer_pending[i]) continue;
        GLuint available=0;
        t->get_query_uiv(t->gpu_timer_queries[i],GL_QUERY_RESULT_AVAILABLE_EXT,&available);
        if (!available) continue;
        GLuint64 elapsed=0;
        t->get_query_ui64v(t->gpu_timer_queries[i],GL_QUERY_RESULT_EXT,&elapsed);
        // GL_EXT_disjoint_timer_query reports nanoseconds. Some virtual GL
        // drivers advertise the extension but return an absolute timestamp for
        // TIME_ELAPSED (several seconds for a single 512x512 blit). Reject that
        // driver rather than publishing a plausible-looking bogus GPU metric.
        constexpr GLuint64 max_plausible_blit_ns=1000000000ULL;
        // Some virtual drivers expose the query extension but return only
        // zero-duration copies. These are not usable GPU timing measurements.
        const bool invalid_elapsed=elapsed==0 || elapsed>max_plausible_blit_ns;
        if (disjoint || invalid_elapsed || !t->gpu_timer_reliable) {
            ++t->blit_gpu_rejected;
            if (invalid_elapsed) t->gpu_timer_reliable=false;
        } else {
            t->blit_gpu_time_ns+=elapsed; ++t->blit_gpu_samples;
        }
        t->gpu_timer_pending[i]=false;
    }
}
void timer_begin(Transport *t) {
    if (!t || !t->gpu_timer_supported || !t->gpu_timer_reliable) return;
    timer_poll(t);
    if (!t->gpu_timer_reliable) return;
    if (t->gpu_timer_pending[t->gpu_timer_index]) return;
    t->begin_query(GL_TIME_ELAPSED_EXT,t->gpu_timer_queries[t->gpu_timer_index]);
    t->gpu_timer_active=true;
}
void timer_end(Transport *t) {
    if (!t || !t->gpu_timer_active) return;
    t->end_query(GL_TIME_ELAPSED_EXT);
    t->gpu_timer_pending[t->gpu_timer_index]=true;
    t->gpu_timer_index=(t->gpu_timer_index+1)%t->gpu_timer_queries.size();
    t->gpu_timer_active=false;
}
}
extern "C" {
const char *dora_gl_error() { return error.c_str(); }
int dora_gl_enter(void *p) {
    auto *t=get(p);
    if (!t) return 0;
    const auto current=eglGetCurrentContext();
    if (current==t->host) {
        const auto display=eglGetCurrentDisplay();
        const auto draw=eglGetCurrentSurface(EGL_DRAW);
        const auto read=eglGetCurrentSurface(EGL_READ);
        if (display==EGL_NO_DISPLAY || draw==EGL_NO_SURFACE || read==EGL_NO_SURFACE) {
            error="current EGL host context has no drawable surface"; return 0;
        }
        if (display!=t->display) { error="EGL host display changed"; return 0; }
        // Android destroys and recreates its window surface across Home/resume
        // while retaining the host context and share group. Never restore the
        // producer to the stale surface captured during initial creation.
        t->draw=draw; t->read=read;
    } else if (current!=t->producer && current!=EGL_NO_CONTEXT) {
        error="unexpected current EGL context"; return 0;
    }
    if (!eglMakeCurrent(t->display,t->surface,t->surface,t->producer)) {
        error="cannot activate EGL producer context"; return 0;
    }
    return 1;
}
int dora_gl_leave(void *p) {
    auto *t=get(p);
    if (!t || !eglMakeCurrent(t->display,t->draw,t->read,t->host)) {
        error="cannot restore EGL host context"; return 0;
    }
    return 1;
}
void *dora_gl_display(void *p) { return get(p)->display; }
uint32_t dora_gl_framebuffer(void *p) { return get(p)?get(p)->auxiliary_fbo:0; }
int dora_gl_desktop(void *p) { return get(p)->api==EGL_OPENGL_API; }
int dora_gl_supports_direct_targets(void *p) { return get(p)!=nullptr; }
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
    timer_init(t);
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
        glFinish(); timer_poll(t);
        for (auto &s:t->slots) {
            if (s.ready) glDeleteSync(s.ready);
            if (s.consumed) glDeleteSync(s.consumed);
            if (s.texture && s.owned) glDeleteTextures(1,&s.texture);
        }
        if (t->auxiliary_fbo) glDeleteFramebuffers(1,&t->auxiliary_fbo);
        if (t->auxiliary_color) glDeleteRenderbuffers(1,&t->auxiliary_color);
        if (t->source_fbo) glDeleteFramebuffers(1,&t->source_fbo);
        if (t->target_fbo) glDeleteFramebuffers(1,&t->target_fbo);
        if (t->gpu_timer_supported) t->delete_queries(GLsizei(t->gpu_timer_queries.size()),t->gpu_timer_queries.data());
    }
    dora_gl_leave(t);
    if (t->surface!=EGL_NO_SURFACE) eglDestroySurface(t->display,t->surface);
    if (t->producer!=EGL_NO_CONTEXT) eglDestroyContext(t->display,t->producer);
    delete t;
}
}
