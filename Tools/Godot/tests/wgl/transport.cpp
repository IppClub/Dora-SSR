#include "Tools/Godot/tests/wgl/context.h"
#include "Tools/Godot/module/gl/gl_transport.h"
#include "Source/Godot/GodotFrameRing.h"
#include <cassert>
#include <cstdlib>
int main() {
    WGLTestContext environment;
    if (!environment.create()) { fprintf(stderr,"WGL_TRANSPORT FAIL: OpenGL 3.3 context unavailable (Win32 %lu)\n",GetLastError());return 2; }
    HGLRC host=environment.context;
    printf("WGL_TRANSPORT renderer=%s version=%s\n",glGetString(GL_RENDERER),glGetString(GL_VERSION));
    unsigned total=0,samples=0; uint64_t deferred=0;
    for (unsigned buffers=2;buffers<=4;++buffers) {
        void *transport=dora_gl_create(host,64,64,buffers);
        if (!transport) { fprintf(stderr,"%s\n",dora_gl_error()); return 2; }
        assert(wglGetCurrentContext()==host);
        assert(dora_gl_enter(transport)); assert(wglGetCurrentContext()!=host);
        GLuint source,fbo; glGenTextures(1,&source); glBindTexture(GL_TEXTURE_2D,source);
        glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA8,64,64,0,GL_RGBA,GL_UNSIGNED_BYTE,nullptr);
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
        assert(wglGetCurrentContext()==host);
        printf("WGL_TRANSPORT buffers=%u produced=%llu consumers=1200 errors=0\n",buffers,(unsigned long long)sequence);
    }
    assert(glGetError()==GL_NO_ERROR);
    printf("WGL_TRANSPORT PASS consumers=%u sampled_frames=%u deferred=%llu cpu_pixel_transport=0\n",total,samples,(unsigned long long)deferred);
    return 0;
}
