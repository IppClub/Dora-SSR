// Real LibGodot/WGL shared-texture consumer, independent of the Dora host.
#include "Source/Godot/GodotBridgeGL.h"
#include "Source/Godot/GodotFrameRing.h"
#include "Tools/Godot/tests/wgl/context.h"
#include <cassert>
#include <cstdio>
#include <cstdlib>
#include <filesystem>
#include <vector>
#include <thread>
#include <chrono>
int run_runtime(int argc,char **argv) {
    assert(argc==4); // library, project, output
    auto path=[](const char *text) { return std::filesystem::path(std::u8string(text,text+std::strlen(text))); };
    std::filesystem::create_directories(path(argv[3]));
    WGLTestContext environment;
    if (!environment.create()) { fprintf(stderr,"LIBGODOT_WGL FAIL: OpenGL 3.3 unavailable\n");return 2; }
    HGLRC host=environment.context;
    printf("LIBGODOT_WGL renderer=%s\n",glGetString(GL_RENDERER));
    auto library=LoadLibraryW(path(argv[1]).c_str());
    if (!library) { fprintf(stderr,"LIBGODOT_WGL FAIL DLL Win32 error %lu\n",GetLastError());return 2; }
    auto getAPI=reinterpret_cast<DoraGodotGetAPI>(GetProcAddress(library,"dora_godot_get_api"));
    auto getGL=reinterpret_cast<DoraGodotGetGLAPI>(GetProcAddress(library,"dora_godot_get_gl_api"));
    DoraGodotAPI api{}; api.size=sizeof(api); DoraGodotGLAPI gl{}; gl.size=sizeof(gl);
    assert(getAPI && getGL && getAPI(DORA_GODOT_ABI_VERSION,&api) && getGL(DORA_GODOT_GL_ABI_VERSION,&gl));
    DoraGodotConfig settings{sizeof(settings),DORA_GODOT_OPENGL,640,360,3,argv[2],"res://main.tscn",host};
    void *runtime=api.open(&settings);
    if (!runtime) { fprintf(stderr,"LIBGODOT_WGL FAIL open: %s\n",api.last_error(nullptr)); return 2; }
    assert(wglGetCurrentContext()==host);
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
            FILE *file=_wfopen(std::filesystem::path(std::u8string(path.begin(),path.end())).c_str(),L"wb"); assert(file); fprintf(file,"P6\n640 360\n255\n");
            // Godot viewport texture storage uses v=0 for the logical top.
            for (int y=0;y<360;++y) for (int x=0;x<640;++x)
                assert(fwrite(pixels.data()+(y*640+x)*4,1,3,file)==3);
            fclose(file); printf("LIBGODOT_WGL capture=%llu sequence=%llu\n",(unsigned long long)frame,(unsigned long long)read->sequence);
        }
        assert(gl.consumer_end(runtime,read->slot,frame));
        if (frame==120) assert(api.set_paused(runtime,1));
        if (frame==210) assert(api.set_paused(runtime,0));
        auto reserve=ring.reserve(); assert(reserve);
        if (!gl.can_produce(runtime,reserve->slot,reserve->last_read)) assert(ring.defer(*reserve));
        else {
            uint64_t sequence=api.advance(runtime,reserve->slot,reserve->last_read);
            if (!sequence) { fprintf(stderr,"LIBGODOT_WGL FAIL advance: %s\n",api.last_error(runtime)); return 2; }
            assert(ring.publish(*reserve,sequence));
        }
        assert(wglGetCurrentContext()==host && glGetError()==GL_NO_ERROR);
        std::this_thread::sleep_for(std::chrono::milliseconds(16));
    }
    glFinish(); glDeleteFramebuffers(1,&fbo); DoraGodotStats stats{}; stats.size=sizeof(stats); api.close(runtime,&stats);
    assert(stats.produced==stats.completed && stats.gpu_errors==0);
    api.shutdown(); assert(wglGetCurrentContext()==host);
    printf("LIBGODOT_WGL PASS frames=360 produced=%llu completed=%llu errors=0\n",(unsigned long long)stats.produced,(unsigned long long)stats.completed);
    return 0;
}

int wmain(int argc,wchar_t **wide) {
    std::vector<std::string> storage;storage.reserve(argc);
    for (int i=0;i<argc;++i) {
        int size=WideCharToMultiByte(CP_UTF8,WC_ERR_INVALID_CHARS,wide[i],-1,nullptr,0,nullptr,nullptr);
        if (!size) return 2;
        std::string text(size,'\0');
        if (!WideCharToMultiByte(CP_UTF8,WC_ERR_INVALID_CHARS,wide[i],-1,text.data(),size,nullptr,nullptr)) return 2;
        text.resize(size-1);storage.push_back(std::move(text));
    }
    std::vector<char*> args;for (auto &text:storage) args.push_back(text.data());args.push_back(nullptr);
    return run_runtime(argc,args.data());
}
