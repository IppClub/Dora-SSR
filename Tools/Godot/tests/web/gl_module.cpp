// A real WebGL2 interop probe, not a Godot runtime substitute.
#include <GLES3/gl3.h>
#include <emscripten.h>
#include <emscripten/html5.h>
#include <cstdio>
namespace {
GLuint framebuffer=0,output=0,program=0,vao=0,poisonVAO=0,poisonBuffer=0,sampler=0;
unsigned char pixels[20];
GLuint shader(GLenum kind,const char *text) {
 auto s=glCreateShader(kind);glShaderSource(s,1,&text,nullptr);glCompileShader(s);
 GLint ok=0;glGetShaderiv(s,GL_COMPILE_STATUS,&ok);
 if (!ok) {char text[4096];glGetShaderInfoLog(s,sizeof(text),nullptr,text);std::printf("SHADER_ERROR %s\n",text);return 0;}return s;
}
}
extern "C" {
EMSCRIPTEN_KEEPALIVE int boot() {
 EmscriptenWebGLContextAttributes a;emscripten_webgl_init_context_attributes(&a);
 a.majorVersion=2;a.minorVersion=0;a.antialias=false;a.alpha=false;
 auto c=emscripten_webgl_create_context("#canvas",&a);
 return c>0 && emscripten_webgl_make_context_current(c)==EMSCRIPTEN_RESULT_SUCCESS;
}
EMSCRIPTEN_KEEPALIVE unsigned texture_create() {
 glBindBuffer(GL_PIXEL_UNPACK_BUFFER,0);
 GLuint tex;glGenTextures(1,&tex);glBindTexture(GL_TEXTURE_2D,tex);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
 glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
 glTexImage2D(GL_TEXTURE_2D,0,GL_RGBA8,64,64,0,GL_RGBA,GL_UNSIGNED_BYTE,nullptr);return tex;
}
EMSCRIPTEN_KEEPALIVE int setup() {
 glGenFramebuffers(1,&framebuffer);output=texture_create();
 glGenVertexArrays(1,&vao);glBindVertexArray(vao);
 const char *v="#version 300 es\nout vec2 uv;void main(){vec2 p=vec2((gl_VertexID==1)?3.0:-1.0,(gl_VertexID==2)?3.0:-1.0);uv=(p+1.0)*0.5;gl_Position=vec4(p,0,1);}";
 const char *f="#version 300 es\nprecision highp float;in vec2 uv;uniform sampler2D image;out vec4 color;void main(){color=texture(image,uv);}";
 auto vs=shader(GL_VERTEX_SHADER,v),fs=shader(GL_FRAGMENT_SHADER,f);if(!vs||!fs)return 0;
 program=glCreateProgram();glAttachShader(program,vs);glAttachShader(program,fs);glLinkProgram(program);glDeleteShader(vs);glDeleteShader(fs);
 GLint ok=0;glGetProgramiv(program,GL_LINK_STATUS,&ok);if(!ok)return 0;
 glGenVertexArrays(1,&poisonVAO);glGenBuffers(1,&poisonBuffer);glBindBuffer(GL_UNIFORM_BUFFER,poisonBuffer);glBufferData(GL_UNIFORM_BUFFER,256,nullptr,GL_STATIC_DRAW);
 glGenSamplers(1,&sampler);return glGetError()==GL_NO_ERROR;
}
EMSCRIPTEN_KEEPALIVE int produce(unsigned tex,int frame,int buffers) {
 glUseProgram(program);glBindBuffer(GL_PIXEL_PACK_BUFFER,poisonBuffer);glBindBuffer(GL_PIXEL_UNPACK_BUFFER,poisonBuffer);
 glBindTexture(GL_TEXTURE_2D,tex);GLint bound=0;glGetIntegerv(GL_TEXTURE_BINDING_2D,&bound);if(unsigned(bound)!=tex)return 0;
 glBindFramebuffer(GL_FRAMEBUFFER,framebuffer);glFramebufferTexture2D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,tex,0);
 if(glCheckFramebufferStatus(GL_FRAMEBUFFER)!=GL_FRAMEBUFFER_COMPLETE)return 0;
 glViewport(0,0,64,64);glDisable(GL_SCISSOR_TEST);glColorMask(true,true,true,true);
 glClearColor(float(frame%256)/255,float((frame*3)%256)/255,float(buffers*37)/255,1);glClear(GL_COLOR_BUFFER_BIT);
 glEnable(GL_SCISSOR_TEST);
 for(int i=0;i<4;++i){glScissor((i&1)?56:0,(i&2)?56:0,8,8);glClearColor(i==0||i==3,i==1||i==3,i==2||i==3,1);glClear(GL_COLOR_BUFFER_BIT);}
 return glGetError()==GL_NO_ERROR;
}
EMSCRIPTEN_KEEPALIVE int consume(unsigned tex,int capture) {
 glBindFramebuffer(GL_FRAMEBUFFER,framebuffer);glFramebufferTexture2D(GL_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,output,0);
 if(glCheckFramebufferStatus(GL_FRAMEBUFFER)!=GL_FRAMEBUFFER_COMPLETE)return 0;
 glViewport(0,0,64,64);glDisable(GL_SCISSOR_TEST);glDisable(GL_DEPTH_TEST);glDisable(GL_STENCIL_TEST);glDisable(GL_CULL_FACE);glDisable(GL_BLEND);glDisable(GL_RASTERIZER_DISCARD);
 // Deliberately reuse the program restored by the boundary, as a renderer
 // with its own state cache does. Rebinding here would hide JS cache pollution.
 glColorMask(true,true,true,true);glBindVertexArray(vao);glActiveTexture(GL_TEXTURE0);glBindTexture(GL_TEXTURE_2D,tex);glBindSampler(0,0);glUniform1i(glGetUniformLocation(program,"image"),0);glDrawArrays(GL_TRIANGLES,0,3);
 glBindBuffer(GL_PIXEL_PACK_BUFFER,0);glPixelStorei(GL_PACK_ALIGNMENT,1);glPixelStorei(GL_PACK_ROW_LENGTH,0);glPixelStorei(GL_PACK_SKIP_PIXELS,0);glPixelStorei(GL_PACK_SKIP_ROWS,0);
 if(capture)for(int i=0;i<5;++i)glReadPixels(i==4?32:((i&1)?60:4),i==4?32:((i&2)?60:4),1,1,GL_RGBA,GL_UNSIGNED_BYTE,pixels+i*4);
 return glGetError()==GL_NO_ERROR;
}
EMSCRIPTEN_KEEPALIVE unsigned bound_texture(){GLint value=0;glGetIntegerv(GL_TEXTURE_BINDING_2D,&value);return value;}
EMSCRIPTEN_KEEPALIVE unsigned result() {return (unsigned)(uintptr_t)pixels;}
EMSCRIPTEN_KEEPALIVE void poison() {
 glUseProgram(program);glBindVertexArray(poisonVAO);glBindBuffer(GL_ARRAY_BUFFER,poisonBuffer);
 glBindBufferRange(GL_UNIFORM_BUFFER,0,poisonBuffer,0,256);glActiveTexture(GL_TEXTURE3);glBindTexture(GL_TEXTURE_2D,output);glBindSampler(3,sampler);
 glEnable(GL_BLEND);glBlendFuncSeparate(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA,GL_ONE,GL_ZERO);glBlendEquationSeparate(GL_FUNC_SUBTRACT,GL_FUNC_REVERSE_SUBTRACT);
 glEnable(GL_SCISSOR_TEST);glScissor(3,5,7,9);glViewport(1,2,61,59);glColorMask(false,true,false,true);glDepthMask(false);glEnable(GL_DEPTH_TEST);glDepthFunc(GL_GEQUAL);
 glPixelStorei(GL_UNPACK_ALIGNMENT,8);glPixelStorei(GL_UNPACK_ROW_LENGTH,17);glPixelStorei(GL_UNPACK_SKIP_PIXELS,2);
}
EMSCRIPTEN_KEEPALIVE void release_texture(unsigned tex){glDeleteTextures(1,&tex);}
}
