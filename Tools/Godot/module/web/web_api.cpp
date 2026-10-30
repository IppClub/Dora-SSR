// Scalar entry points marshal into this runtime's own heap/C ABI. No C++/WASM
// table pointers cross the two independently linked Emscripten modules.
#include "../GodotBridgeGL.h"
#include "../GodotBridgeGLTargets.h"
#include "../GodotBridgeAudio.h"
#include "../GodotBridgeOutput.h"
#include "../GodotBridgeIME.h"
#include <emscripten.h>
#include <emscripten/html5.h>
namespace {
DoraGodotAPI api{};DoraGodotGLAPI gl{};DoraGodotGLTargetsAPI targets{};
DoraGodotAudioAPI audio{};DoraGodotOutputAPI output{};DoraGodotIMEAPI ime{};
void *runtime=nullptr;
DoraGodotStats stats{};
bool load(){
    api.size=sizeof(api);gl.size=sizeof(gl);targets.size=sizeof(targets);audio.size=sizeof(audio);output.size=sizeof(output);ime.size=sizeof(ime);
    return dora_godot_get_api(DORA_GODOT_ABI_VERSION,&api) && dora_godot_get_gl_api(DORA_GODOT_GL_ABI_VERSION,&gl)
        && dora_godot_get_gl_targets_api(DORA_GODOT_GL_TARGETS_ABI_VERSION,&targets) && dora_godot_get_audio_api(DORA_GODOT_AUDIO_ABI_VERSION,&audio)
        && dora_godot_get_output_api(DORA_GODOT_OUTPUT_ABI_VERSION,&output) && dora_godot_get_ime_api(DORA_GODOT_IME_ABI_VERSION,&ime);
}
}
extern "C" {
EMSCRIPTEN_KEEPALIVE int dora_web_context(){
    EmscriptenWebGLContextAttributes attributes;emscripten_webgl_init_context_attributes(&attributes);
    attributes.majorVersion=2;attributes.minorVersion=0;attributes.antialias=false;attributes.alpha=false;
    const auto context=emscripten_webgl_create_context("#canvas",&attributes);
    if(context<=0 || emscripten_webgl_make_context_current(context)!=EMSCRIPTEN_RESULT_SUCCESS)return 0;
    return context;
}
EMSCRIPTEN_KEEPALIVE int dora_web_open(const char *project,const char *scene,int width,int height,int buffers){
    if(runtime || !load())return 0;
    DoraGodotConfig config{sizeof(config),DORA_GODOT_WEBGL2,(uint32_t)width,(uint32_t)height,(uint32_t)buffers,project,scene,(void*)(uintptr_t)emscripten_webgl_get_current_context()};
    runtime=api.open(&config);return runtime!=nullptr;
}
EMSCRIPTEN_KEEPALIVE const char *dora_web_error(){return api.last_error?api.last_error(runtime):"Web bridge API is unavailable";}
EMSCRIPTEN_KEEPALIVE const char *dora_web_version(){return api.version?api.version():"Web bridge API is unavailable";}
EMSCRIPTEN_KEEPALIVE unsigned dora_web_slot(unsigned index){DoraGodotSlot slot{sizeof(slot)};return runtime && api.get_slot(runtime,index,&slot)?(unsigned)(uintptr_t)slot.texture:0;}
EMSCRIPTEN_KEEPALIVE int dora_web_can_produce(unsigned slot,uint64_t read){return runtime && gl.can_produce(runtime,slot,read);}
EMSCRIPTEN_KEEPALIVE int dora_web_can_advance(unsigned slot,uint64_t read){return runtime && gl.can_advance(runtime,slot,read);}
EMSCRIPTEN_KEEPALIVE uint64_t dora_web_advance(unsigned slot,uint64_t read){return runtime?gl.advance_async(runtime,slot,read):0;}
EMSCRIPTEN_KEEPALIVE int dora_web_consumer_begin(unsigned slot,uint64_t sequence){return runtime && gl.consumer_begin(runtime,slot,sequence);}
EMSCRIPTEN_KEEPALIVE int dora_web_consumer_end(unsigned slot,uint64_t read){return runtime && gl.consumer_end(runtime,slot,read);}
EMSCRIPTEN_KEEPALIVE int dora_web_bind_targets(unsigned width,unsigned height,const unsigned *textures,unsigned count){return runtime && targets.bind(runtime,width,height,textures,count);}
EMSCRIPTEN_KEEPALIVE int dora_web_pause(int paused){return runtime && api.set_paused(runtime,paused);}
EMSCRIPTEN_KEEPALIVE int dora_web_restart(const char *scene){return runtime && api.restart_scene(runtime,scene);}
EMSCRIPTEN_KEEPALIVE int dora_web_input(const DoraGodotInput *event){return runtime && api.input(runtime,event);}
EMSCRIPTEN_KEEPALIVE int dora_web_output(DoraGodotOutputSize *size){return runtime && output.get_size(runtime,size);}
EMSCRIPTEN_KEEPALIVE int dora_web_ime(DoraGodotIMEState *state){return runtime && ime.get_state(runtime,state);}
EMSCRIPTEN_KEEPALIVE int dora_web_audio_format(DoraGodotAudioFormat *format){return runtime && audio.get_format(runtime,format);}
EMSCRIPTEN_KEEPALIVE int dora_web_audio_stats(DoraGodotAudioStats *value){return runtime && audio.get_stats(runtime,value);}
EMSCRIPTEN_KEEPALIVE int dora_web_audio_start(){return runtime && audio.start_capture(runtime);}
EMSCRIPTEN_KEEPALIVE unsigned dora_web_audio_read(float *samples,unsigned frames){return runtime?audio.read_pcm(runtime,samples,frames):0;}
EMSCRIPTEN_KEEPALIVE const DoraGodotStats *dora_web_close(){stats={sizeof(stats)};if(runtime)api.close(runtime,&stats);runtime=nullptr;return &stats;}
EMSCRIPTEN_KEEPALIVE void dora_web_shutdown(){if(api.shutdown)api.shutdown();runtime=nullptr;}
}
