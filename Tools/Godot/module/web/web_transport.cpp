// Same WebGL2 command queue, independent Emscripten name tables. No CPU pixels.
#include "../gl/gl_transport.h"
#include <GLES3/gl3.h>
#include <emscripten.h>
#include <emscripten/html5.h>
#include <array>
#include <string>
namespace {
thread_local std::string error;
struct Slot {
    GLuint texture=0;bool owned=true;
    GLsync ready=nullptr,consumed=nullptr;
    uint64_t sequence=0,read=0;
};
struct Transport {
    uint32_t width=0,height=0,buffers=0;
    GLuint source_fbo=0,target_fbo=0,auxiliary_fbo=0,auxiliary_color=0;
    uint64_t sequence=0,completed=0,deferred=0,errors=0;
    std::array<Slot,4> slots;
};
Transport *get(void *p){return static_cast<Transport*>(p);}
bool check(Transport *t){const auto code=glGetError();if(code==GL_NO_ERROR)return true;++t->errors;error="WebGL transport error code="+std::to_string(code);return false;}
EM_JS(int,enter_boundary,(),{
    if(!Module['doraBoundary'])throw new Error('Dora WebGL boundary is required');
    const previous=Module['doraBoundary'].enter('godot');
    if(!previous)return 0;
    (Module['doraBoundaryStack'] ||= []).push(previous);return 1;
});
EM_JS(int,leave_boundary,(),{
    const stack=Module['doraBoundaryStack'];
    if(!stack || !stack.length)throw new Error('Unbalanced Dora WebGL boundary');
    Module['doraBoundary'].leave(stack.pop());return 1;
});
// WebGL has no server-side waitSync. Both engines append to exactly the same
// context/queue, so earlier consumer/producer commands already precede this call.
// The can_advance/can_produce polls still yield to the host while fences are pending.
void ordered_wait(GLsync,GLbitfield,GLuint64) {}
}
extern "C" {
const char *dora_gl_error(){return error.c_str();}
int dora_gl_enter(void *p){return p && enter_boundary();}
int dora_gl_leave(void *p){return p && leave_boundary();}
void *dora_gl_display(void *){return nullptr;}
int dora_gl_desktop(void *){return 0;}
uint32_t dora_gl_framebuffer(void *p){return get(p)?get(p)->auxiliary_fbo:0;}
void *dora_gl_create(void *host,uint32_t width,uint32_t height,uint32_t buffers){
    error.clear();
    if(!host || (uintptr_t)host!=(uintptr_t)emscripten_webgl_get_current_context() || !width || !height || width>8192 || height>8192 || buffers<2 || buffers>4){error="invalid/current WebGL2 context";return nullptr;}
    auto *t=new Transport;t->width=width;t->height=height;t->buffers=buffers;
    if(!dora_gl_enter(t)){delete t;return nullptr;}
    glGenRenderbuffers(1,&t->auxiliary_color);glBindRenderbuffer(GL_RENDERBUFFER,t->auxiliary_color);glRenderbufferStorage(GL_RENDERBUFFER,GL_RGBA8,1,1);
    glGenFramebuffers(1,&t->auxiliary_fbo);glBindFramebuffer(GL_FRAMEBUFFER,t->auxiliary_fbo);glFramebufferRenderbuffer(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_RENDERBUFFER,t->auxiliary_color);
    glGenFramebuffers(1,&t->source_fbo);glGenFramebuffers(1,&t->target_fbo);
    glActiveTexture(GL_TEXTURE0);glBindBuffer(GL_PIXEL_UNPACK_BUFFER,0);
    for(uint32_t i=0;i<buffers;++i){auto &s=t->slots[i];glGenTextures(1,&s.texture);glBindTexture(GL_TEXTURE_2D,s.texture);glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA8,width,height,0,GL_RGBA,GL_UNSIGNED_BYTE,nullptr);glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);}
    bool ok=check(t);dora_gl_leave(t);if(!ok){dora_gl_destroy(t);return nullptr;}return t;
}
#define glWaitSync ordered_wait
#include "../gl/texture_ring.inc"
#undef glWaitSync
void dora_gl_destroy(void *p){
    auto *t=get(p);if(!t)return;
    if(dora_gl_enter(t)){
        glFinish();
        for(auto &s:t->slots){if(s.ready)glDeleteSync(s.ready);if(s.consumed)glDeleteSync(s.consumed);if(s.texture&&s.owned)glDeleteTextures(1,&s.texture);}
        glDeleteFramebuffers(1,&t->source_fbo);glDeleteFramebuffers(1,&t->target_fbo);glDeleteFramebuffers(1,&t->auxiliary_fbo);glDeleteRenderbuffers(1,&t->auxiliary_color);
        dora_gl_leave(t);
    }
    delete t;
}
}
