#include "Tools/Godot/module/gl/gl_transport.h"
#include "Source/Godot/GodotFrameRing.h"
#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <GLES3/gl3.h>
#include <cassert>
#include <cstdio>
#include <cstdlib>

int main() {
#ifdef __ANDROID__
    // Android's EGL loader exposes a default display. MESA's platform enum is
    // not an Android EGL platform even when eglGetPlatformDisplayEXT exists.
    EGLDisplay display=eglGetDisplay(EGL_DEFAULT_DISPLAY);
#else
    auto platform=reinterpret_cast<PFNEGLGETPLATFORMDISPLAYEXTPROC>(eglGetProcAddress("eglGetPlatformDisplayEXT"));
    EGLDisplay display=platform?platform(EGL_PLATFORM_SURFACELESS_MESA,EGL_DEFAULT_DISPLAY,nullptr):eglGetDisplay(EGL_DEFAULT_DISPLAY);
#endif
    EGLint major=0,minor=0; assert(eglInitialize(display,&major,&minor));
    assert(eglBindAPI(EGL_OPENGL_ES_API));
    EGLConfig config; EGLint count;
    const EGLint attrs[]={EGL_SURFACE_TYPE,EGL_PBUFFER_BIT,EGL_RENDERABLE_TYPE,EGL_OPENGL_ES3_BIT_KHR,
        EGL_RED_SIZE,8,EGL_GREEN_SIZE,8,EGL_BLUE_SIZE,8,EGL_ALPHA_SIZE,8,EGL_NONE};
    assert(eglChooseConfig(display,attrs,&config,1,&count) && count);
    const EGLint ctx[]={EGL_CONTEXT_CLIENT_VERSION,3,EGL_NONE};
    EGLContext host=eglCreateContext(display,config,EGL_NO_CONTEXT,ctx); assert(host);
    const EGLint pb[]={EGL_WIDTH,64,EGL_HEIGHT,64,EGL_NONE};
    EGLSurface surface=eglCreatePbufferSurface(display,config,pb); assert(surface);
    assert(eglMakeCurrent(display,surface,surface,host));
    printf("EGL_TRANSPORT renderer=%s version=%s\n",glGetString(GL_RENDERER),glGetString(GL_VERSION));
    unsigned total=0,samples=0; uint64_t deferred=0;
    for (unsigned buffers=2;buffers<=4;++buffers) {
        void *transport=dora_gl_create(host,64,64,buffers);
        if (!transport) { fprintf(stderr,"%s\n",dora_gl_error()); return 2; }
        assert(eglGetCurrentContext()==host);
        assert(dora_gl_enter(transport)); assert(eglGetCurrentContext()!=host);
        GLuint source,fbo; glGenTextures(1,&source); glBindTexture(GL_TEXTURE_2D,source);
        glTexStorage2D(GL_TEXTURE_2D,1,GL_RGBA8,64,64);
        glGenFramebuffers(1,&fbo); glBindFramebuffer(GL_FRAMEBUFFER,fbo);
        glFramebufferTexture2D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,source,0);
        assert(glCheckFramebufferStatus(GL_FRAMEBUFFER)==GL_FRAMEBUFFER_COMPLETE);
        auto produce=[&](unsigned slot,uint64_t read,uint64_t sequence) {
            glBindFramebuffer(GL_FRAMEBUFFER,fbo); glDisable(GL_SCISSOR_TEST);
            glClearColor((sequence&255)/255.0f,((sequence>>8)&255)/255.0f,0.5f,1); glClear(GL_COLOR_BUFFER_BIT);
            glEnable(GL_SCISSOR_TEST); glScissor(1,1,2,2);
            uint64_t result=dora_gl_copy(transport,source,slot,read);
            GLint binding=0; glGetIntegerv(GL_FRAMEBUFFER_BINDING,&binding);
            assert(GLuint(binding)==fbo && glIsEnabled(GL_SCISSOR_TEST));
            assert(result==sequence); return result;
        };
        Dora::GodotFrameRing ring; assert(ring.configure(buffers));
        uint64_t sequence=produce(0,0,1); assert(ring.seed(0,sequence));
        assert(dora_gl_leave(transport));
        GLuint consumer; glGenFramebuffers(1,&consumer);
        for (uint64_t frame=1;frame<=1200;++frame) {
            auto read=ring.read(frame); assert(read);
            assert(dora_gl_consumer_begin(transport,read->slot,read->sequence));
            glBindFramebuffer(GL_FRAMEBUFFER,consumer);
            glFramebufferTexture2D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,dora_gl_texture(transport,read->slot),0);
            assert(glCheckFramebufferStatus(GL_FRAMEBUFFER)==GL_FRAMEBUFFER_COMPLETE);
            if (frame%37==0 || frame==1200) {
                // Read back only final consumer verification samples, never transport pixels.
                for (unsigned y: {0u,32u,63u}) {
                    unsigned char pixel[4]{}; glReadPixels(32,y,1,1,GL_RGBA,GL_UNSIGNED_BYTE,pixel);
                    assert(pixel[0]==(read->sequence&255) && pixel[1]==((read->sequence>>8)&255) && pixel[2]==128);
                }
                ++samples;
            }
            // Simulate several consumers displaying one producer snapshot.
            assert(dora_gl_consumer_end(transport,read->slot,frame)); ++total;
            auto reservation=ring.reserve(); assert(reservation);
            if (frame%3==0 || !dora_gl_can_produce(transport,reservation->slot,reservation->last_read)) {
                assert(ring.defer(*reservation)); continue;
            }
            assert(dora_gl_enter(transport));
            ++sequence; produce(reservation->slot,reservation->last_read,sequence);
            assert(dora_gl_leave(transport)); assert(ring.publish(*reservation,sequence));
        }
        glFinish(); glDeleteFramebuffers(1,&consumer);
        assert(dora_gl_enter(transport)); glFinish();
        assert(dora_gl_completed(transport)==sequence && dora_gl_errors(transport)==0);
        deferred+=dora_gl_deferred(transport);
        glDeleteFramebuffers(1,&fbo); glDeleteTextures(1,&source);
        assert(dora_gl_leave(transport)); dora_gl_destroy(transport);
        assert(eglGetCurrentContext()==host);
        printf("EGL_TRANSPORT buffers=%u produced=%llu consumers=1200 errors=0\n",buffers,(unsigned long long)sequence);
    }
    assert(glGetError()==GL_NO_ERROR);
    printf("EGL_TRANSPORT PASS consumers=%u sampled_frames=%u deferred=%llu cpu_pixel_transport=0\n",total,samples,(unsigned long long)deferred);
    eglMakeCurrent(display,EGL_NO_SURFACE,EGL_NO_SURFACE,EGL_NO_CONTEXT);
    eglDestroySurface(display,surface); eglDestroyContext(display,host); eglTerminate(display);
}
