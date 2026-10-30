// Copyright (c) 2026 Dora SSR contributors. MIT license (see repository LICENSE).
// Local C ABI thunks; function pointers never cross the independent WASM tables.
#include "Const/Header.h"
#include "Godot/GodotWebAPI.h"
#include <emscripten.h>
namespace Dora {
namespace {
static_assert(sizeof(void*)==4 && sizeof(DoraGodotConfig)==32);
static_assert(sizeof(DoraGodotInput)==56 && offsetof(DoraGodotInput,text)==32);
static_assert(sizeof(DoraGodotSlot)==28 && sizeof(DoraGodotStats)==40);
static_assert(sizeof(DoraGodotAudioStats)==40 && sizeof(DoraGodotOutputSize)==16);
static_assert(sizeof(DoraGodotIMEState)==24 && offsetof(DoraGodotIMEState,revision)==16);
enum Operation {Init,Version,Error,Open,Slot,Advance,Input,Pause,Restart,Close,Shutdown,CanProduce,ConsumerBegin,ConsumerEnd,CanAdvance,BindTargets,Output,AudioFormat,AudioStart,AudioRead,AudioStats,IME};
EM_JS(int,dispatch,(int operation,void *data,uint32_t a,uint32_t b,uint32_t c,uint32_t d),{
    const bridge=Module['doraGodotBridge'];
    if(!bridge)return 0;
    return bridge.dispatch(operation,data>>>0,a>>>0,b>>>0,c>>>0,d>>>0);
});
bool opened=false;
char versionText[256]{},errorText[4096]{};
bool valid(void *handle){return opened && handle==(void*)1;}
const char *version(){dispatch(Version,versionText,sizeof(versionText),0,0,0);return versionText;}
const char *lastError(void *){dispatch(Error,errorText,sizeof(errorText),0,0,0);return errorText;}
void *open(const DoraGodotConfig *config){
    if(opened || !config || config->size<sizeof(*config) || config->backend!=DORA_GODOT_WEBGL2)return nullptr;
    opened=dispatch(Open,(void*)config,0,0,0,0)!=0;return opened?(void*)1:nullptr;
}
int slot(void *handle,uint32_t index,DoraGodotSlot *value){return valid(handle)&&value&&value->size>=sizeof(*value)&&dispatch(Slot,value,index,0,0,0);}
uint64_t advance(void *handle,uint32_t index,uint64_t read){uint64_t sequence=0;if(valid(handle))dispatch(Advance,&sequence,index,uint32_t(read),uint32_t(read>>32),0);return sequence;}
int input(void *handle,const DoraGodotInput *event){return valid(handle)&&event&&event->size>=sizeof(*event)&&dispatch(Input,(void*)event,0,0,0,0);}
int pause(void *handle,int value){return valid(handle)&&dispatch(Pause,nullptr,value,0,0,0);}
int restart(void *handle,const char *path){return valid(handle)&&dispatch(Restart,(void*)path,0,0,0,0);}
void close(void *handle,DoraGodotStats *stats){if(!valid(handle))return;dispatch(Close,stats&&stats->size>=sizeof(*stats)?stats:nullptr,0,0,0,0);opened=false;}
void shutdown(){dispatch(Shutdown,nullptr,0,0,0,0);opened=false;}
int canProduce(void *handle,uint32_t index,uint64_t read){return valid(handle)&&dispatch(CanProduce,nullptr,index,uint32_t(read),uint32_t(read>>32),0);}
int begin(void *handle,uint32_t index,uint64_t sequence){return valid(handle)&&dispatch(ConsumerBegin,nullptr,index,uint32_t(sequence),uint32_t(sequence>>32),0);}
int end(void *handle,uint32_t index,uint64_t read){return valid(handle)&&dispatch(ConsumerEnd,nullptr,index,uint32_t(read),uint32_t(read>>32),0);}
int canAdvance(void *handle,uint32_t index,uint64_t read){return valid(handle)&&dispatch(CanAdvance,nullptr,index,uint32_t(read),uint32_t(read>>32),0);}
int bind(void *handle,uint32_t width,uint32_t height,const uint32_t *textures,uint32_t count){return valid(handle)&&textures&&count>=2&&count<=4&&dispatch(BindTargets,(void*)textures,width,height,count,0);}
int output(void *handle,DoraGodotOutputSize *value){return valid(handle)&&value&&value->size>=sizeof(*value)&&dispatch(Output,value,0,0,0,0);}
int ime(void *handle,DoraGodotIMEState *value){return valid(handle)&&value&&value->size>=sizeof(*value)&&dispatch(IME,value,0,0,0,0);}
int audioFormat(void *handle,DoraGodotAudioFormat *value){return valid(handle)&&value&&value->size>=sizeof(*value)&&dispatch(AudioFormat,value,0,0,0,0);}
int audioStart(void *handle){return valid(handle)&&dispatch(AudioStart,nullptr,0,0,0,0);}
uint32_t audioRead(void *handle,float *samples,uint32_t frames){return valid(handle)&&samples&&frames&&frames<=DORA_GODOT_AUDIO_MAX_FRAMES?dispatch(AudioRead,samples,frames,0,0,0):0;}
int audioStats(void *handle,DoraGodotAudioStats *value){return valid(handle)&&value&&value->size>=sizeof(*value)&&dispatch(AudioStats,value,0,0,0,0);}
}
bool loadGodotWebAPI(DoraGodotAPI &api,DoraGodotGLAPI &gl,DoraGodotAudioAPI &audio,DoraGodotGLTargetsAPI &targets,DoraGodotOutputAPI &out,DoraGodotIMEAPI &imeAPI,std::string &error){
    if(!dispatch(Init,nullptr,0,0,0,0)){error="Godot Web runtime must be preloaded with a canvas GL boundary: ";dispatch(Error,errorText,sizeof(errorText),0,0,0);error+=errorText;return false;}
    api={sizeof(api),DORA_GODOT_ABI_VERSION,version,open,lastError,slot,advance,input,pause,restart,close,shutdown};
    gl={sizeof(gl),DORA_GODOT_GL_ABI_VERSION,canProduce,begin,end,canAdvance,advance};
    audio={sizeof(audio),DORA_GODOT_AUDIO_ABI_VERSION,audioFormat,audioStart,audioRead,audioStats};
    targets={sizeof(targets),DORA_GODOT_GL_TARGETS_ABI_VERSION,bind};
    out={sizeof(out),DORA_GODOT_OUTPUT_ABI_VERSION,output};
    imeAPI={sizeof(imeAPI),DORA_GODOT_IME_ABI_VERSION,ime};return true;
}
}
