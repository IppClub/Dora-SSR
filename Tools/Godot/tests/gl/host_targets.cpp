// Actual EGL share-group ownership test; CPU readback is only a test oracle.
#include "Tools/Godot/module/gl/gl_transport.h"
#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <GLES3/gl3.h>
#include <array>
#include <cassert>
#include <cstdio>
#include <vector>
int main() {
#ifdef __ANDROID__
    // Android's EGL loader exposes a default display. MESA's platform enum is
    // not an Android EGL platform even when eglGetPlatformDisplayEXT exists.
    EGLDisplay display=eglGetDisplay(EGL_DEFAULT_DISPLAY);
#else
    auto platform=reinterpret_cast<PFNEGLGETPLATFORMDISPLAYEXTPROC>(eglGetProcAddress("eglGetPlatformDisplayEXT"));
    auto display=platform?platform(EGL_PLATFORM_SURFACELESS_MESA,EGL_DEFAULT_DISPLAY,nullptr):eglGetDisplay(EGL_DEFAULT_DISPLAY);
#endif
    EGLint major=0,minor=0; assert(eglInitialize(display,&major,&minor) && eglBindAPI(EGL_OPENGL_ES_API));
    EGLConfig config; EGLint count=0;
    const EGLint attrs[]={EGL_SURFACE_TYPE,EGL_PBUFFER_BIT,EGL_RENDERABLE_TYPE,EGL_OPENGL_ES3_BIT_KHR,EGL_RED_SIZE,8,EGL_GREEN_SIZE,8,EGL_BLUE_SIZE,8,EGL_ALPHA_SIZE,8,EGL_NONE};
    assert(eglChooseConfig(display,attrs,&config,1,&count) && count);
    const EGLint ctx[]={EGL_CONTEXT_CLIENT_VERSION,3,EGL_NONE},pb[]={EGL_WIDTH,64,EGL_HEIGHT,64,EGL_NONE};
    auto host=eglCreateContext(display,config,EGL_NO_CONTEXT,ctx);
    auto surface=eglCreatePbufferSurface(display,config,pb);
    assert(host && surface && eglMakeCurrent(display,surface,surface,host));
    printf("GL_TARGETS renderer=%s version=%s\n",glGetString(GL_RENDERER),glGetString(GL_VERSION));
    unsigned samples=0;
    for (uint32_t buffers=2;buffers<=4;++buffers) {
        auto *transport=dora_gl_create(host,64,64,buffers); assert(transport);
        std::vector<std::array<GLuint,4>> generations;
        GLuint consumer=0; glGenFramebuffers(1,&consumer);
        uint64_t sequence=0;
        for (uint32_t size:{64u,96u,32u}) {
            std::array<GLuint,4> targets{};
            glGenTextures(buffers,targets.data());
            for (uint32_t i=0;i<buffers;++i) {
                glBindTexture(GL_TEXTURE_2D,targets[i]); glTexStorage2D(GL_TEXTURE_2D,1,GL_RGBA8,size,size);
            }
            glFinish(); assert(dora_gl_enter(transport));
            assert(!dora_gl_bind_targets(transport,size,size,nullptr,buffers));
            assert(!dora_gl_bind_targets(transport,size,size,targets.data(),buffers+1));
            auto duplicate=targets; duplicate[1]=duplicate[0];
            assert(!dora_gl_bind_targets(transport,size,size,duplicate.data(),buffers));
            auto zero=targets; zero[0]=0;
            assert(!dora_gl_bind_targets(transport,size,size,zero.data(),buffers));
            assert(dora_gl_bind_targets(transport,size,size,targets.data(),buffers));
            GLuint source=0,producer=0; glGenTextures(1,&source); glBindTexture(GL_TEXTURE_2D,source);
            glTexStorage2D(GL_TEXTURE_2D,1,GL_RGBA8,size,size);
            glGenFramebuffers(1,&producer); glBindFramebuffer(GL_FRAMEBUFFER,producer);
            glFramebufferTexture2D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,source,0);
            glClearColor(size/255.0f,0.25f,0.5f,1); glClear(GL_COLOR_BUFFER_BIT);
            for (uint32_t i=0;i<buffers;++i) {
                assert(dora_gl_copy_async(transport,source,i,0)==++sequence); dora_gl_drain(transport);
            }
            dora_gl_drain(transport); assert(dora_gl_completed(transport)==sequence);
            glDeleteFramebuffers(1,&producer); glDeleteTextures(1,&source);
            assert(dora_gl_leave(transport));
            generations.push_back(targets);
            for (size_t generation=0;generation<generations.size();++generation) {
                const unsigned expected[]={64,96,32};
                for (uint32_t i=0;i<buffers;++i) {
                    const auto texture=generations[generation][i]; assert(glIsTexture(texture));
                    glBindFramebuffer(GL_FRAMEBUFFER,consumer);
                    glFramebufferTexture2D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,texture,0);
                    assert(glCheckFramebufferStatus(GL_FRAMEBUFFER)==GL_FRAMEBUFFER_COMPLETE);
                    unsigned char pixel[4]{}; glReadPixels(16,16,1,1,GL_RGBA,GL_UNSIGNED_BYTE,pixel);
                    assert(pixel[0]==expected[generation] && pixel[2]==128 && pixel[3]==255); ++samples;
                }
            }
            glFinish();
        }
        glDeleteFramebuffers(1,&consumer);
        assert(dora_gl_enter(transport)); dora_gl_clear_targets(transport); assert(dora_gl_errors(transport)==0);
        assert(dora_gl_leave(transport)); dora_gl_destroy(transport);
        for (auto &targets:generations) {
            for (uint32_t i=0;i<buffers;++i) assert(glIsTexture(targets[i]));
            glDeleteTextures(buffers,targets.data());
        }
        assert(glGetError()==GL_NO_ERROR);
    }
    printf("GL_TARGETS PASS buffers=2,3,4 generations=3 samples=%u host_ownership_preserved=1\n",samples);
    eglMakeCurrent(display,EGL_NO_SURFACE,EGL_NO_SURFACE,EGL_NO_CONTEXT);
    eglDestroySurface(display,surface); eglDestroyContext(display,host); eglTerminate(display);
}
