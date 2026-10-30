// Independent LibGodot/EGL integration check before the Dora application test.
#include "Source/Godot/GodotBridgeGL.h"
#include "Source/Godot/GodotFrameRing.h"
#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <GLES3/gl3.h>
#include <dlfcn.h>
#include <cassert>
#include <cstdio>
#include <cstdlib>
#include <filesystem>
#include <vector>
#include <thread>
#include <chrono>
int main(int argc,char **argv) {
    assert(argc==4); // library, project, output
    std::filesystem::create_directories(argv[3]);
    auto platform=reinterpret_cast<PFNEGLGETPLATFORMDISPLAYEXTPROC>(eglGetProcAddress("eglGetPlatformDisplayEXT"));
    EGLDisplay display=platform?platform(EGL_PLATFORM_SURFACELESS_MESA,EGL_DEFAULT_DISPLAY,nullptr):eglGetDisplay(EGL_DEFAULT_DISPLAY);
    EGLint major,minor,count; assert(eglInitialize(display,&major,&minor)); assert(eglBindAPI(EGL_OPENGL_ES_API));
    EGLConfig config; const EGLint attrs[]={EGL_SURFACE_TYPE,EGL_PBUFFER_BIT,EGL_RENDERABLE_TYPE,EGL_OPENGL_ES3_BIT_KHR,
        EGL_RED_SIZE,8,EGL_GREEN_SIZE,8,EGL_BLUE_SIZE,8,EGL_ALPHA_SIZE,8,EGL_NONE};
    assert(eglChooseConfig(display,attrs,&config,1,&count) && count);
    const EGLint ctx[]={EGL_CONTEXT_CLIENT_VERSION,3,EGL_NONE},pb[]={EGL_WIDTH,1,EGL_HEIGHT,1,EGL_NONE};
    EGLContext host=eglCreateContext(display,config,EGL_NO_CONTEXT,ctx); assert(host);
    EGLSurface surface=eglCreatePbufferSurface(display,config,pb); assert(surface);
    assert(eglMakeCurrent(display,surface,surface,host));
    printf("LIBGODOT_EGL renderer=%s\n",glGetString(GL_RENDERER));
    void *library=dlopen(argv[1],RTLD_NOW|RTLD_LOCAL);
    if (!library) { fprintf(stderr,"%s\n",dlerror()); return 2; }
    auto getAPI=reinterpret_cast<DoraGodotGetAPI>(dlsym(library,"dora_godot_get_api"));
    auto getGL=reinterpret_cast<DoraGodotGetGLAPI>(dlsym(library,"dora_godot_get_gl_api"));
    DoraGodotAPI api{}; api.size=sizeof(api); DoraGodotGLAPI gl{}; gl.size=sizeof(gl);
    assert(getAPI && getGL && getAPI(DORA_GODOT_ABI_VERSION,&api) && getGL(DORA_GODOT_GL_ABI_VERSION,&gl));
    DoraGodotConfig settings{sizeof(settings),DORA_GODOT_OPENGL,640,360,3,argv[2],"res://main.tscn",host};
    void *runtime=api.open(&settings);
    if (!runtime) { fprintf(stderr,"LIBGODOT_EGL FAIL open: %s\n",api.last_error(nullptr)); return 2; }
    assert(eglGetCurrentContext()==host);
    uint32_t textures[4]{};
    for (unsigned i=0;i<3;++i) { DoraGodotSlot slot{}; slot.size=sizeof(slot); assert(api.get_slot(runtime,i,&slot)); textures[i]=(uintptr_t)slot.texture; }
    Dora::GodotFrameRing ring; assert(ring.configure(3)); uint64_t first=api.advance(runtime,0,0); assert(first && ring.seed(0,first));
    GLuint fbo; glGenFramebuffers(1,&fbo);
    for (uint64_t frame=1;frame<=360;++frame) {
        auto read=ring.read(frame); assert(read && gl.consumer_begin(runtime,read->slot,read->sequence));
        glBindFramebuffer(GL_FRAMEBUFFER,fbo);
        glFramebufferTexture2D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,textures[read->slot],0);
        assert(glCheckFramebufferStatus(GL_FRAMEBUFFER)==GL_FRAMEBUFFER_COMPLETE);
        if (frame==60 || frame==90 || frame==150 || frame==180 || frame==270 || frame==330) {
            std::vector<unsigned char> pixels(640*360*4); glPixelStorei(GL_PACK_ALIGNMENT,1);
            glReadPixels(0,0,640,360,GL_RGBA,GL_UNSIGNED_BYTE,pixels.data());
            std::string path=std::string(argv[3])+"/frame-"+std::to_string(frame)+".ppm";
            FILE *file=fopen(path.c_str(),"wb"); assert(file); fprintf(file,"P6\n640 360\n255\n");
            // Godot viewport texture storage uses v=0 for the logical top.
            for (int y=0;y<360;++y) for (int x=0;x<640;++x)
                assert(fwrite(pixels.data()+(y*640+x)*4,1,3,file)==3);
            fclose(file); printf("LIBGODOT_EGL capture=%llu sequence=%llu\n",(unsigned long long)frame,(unsigned long long)read->sequence);
        }
        assert(gl.consumer_end(runtime,read->slot,frame));
        if (frame==120) assert(api.set_paused(runtime,1));
        if (frame==210) assert(api.set_paused(runtime,0));
        auto reserve=ring.reserve(); assert(reserve);
        if (!gl.can_produce(runtime,reserve->slot,reserve->last_read)) assert(ring.defer(*reserve));
        else {
            uint64_t sequence=api.advance(runtime,reserve->slot,reserve->last_read);
            if (!sequence) { fprintf(stderr,"LIBGODOT_EGL FAIL advance: %s\n",api.last_error(runtime)); return 2; }
            assert(ring.publish(*reserve,sequence));
        }
        assert(eglGetCurrentContext()==host && glGetError()==GL_NO_ERROR);
        std::this_thread::sleep_for(std::chrono::milliseconds(16));
    }
    glFinish(); glDeleteFramebuffers(1,&fbo); DoraGodotStats stats{}; stats.size=sizeof(stats); api.close(runtime,&stats);
    assert(stats.produced==stats.completed && stats.gpu_errors==0);
    api.shutdown(); assert(eglGetCurrentContext()==host);
    printf("LIBGODOT_EGL PASS frames=360 produced=%llu completed=%llu errors=0\n",(unsigned long long)stats.produced,(unsigned long long)stats.completed);
    eglMakeCurrent(display,EGL_NO_SURFACE,EGL_NO_SURFACE,EGL_NO_CONTEXT);
    eglDestroySurface(display,surface); eglDestroyContext(display,host); eglTerminate(display);
}
