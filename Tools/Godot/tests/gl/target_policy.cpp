#include "Source/3rdParty/Godot/modules/dora_bridge/gl/target_policy.h"
#include <cassert>
#include <cstring>
using namespace DoraGodotGLTargetPolicy;
static void expect(const char *requested,bool capable,Mode mode,const char *policy,const char *reason) {
    const auto result=decide(requested,capable);
    assert(result.mode==mode && std::strcmp(result.policy,policy)==0 && std::strcmp(result.reason,reason)==0);
}
int main() {
    expect(nullptr,false,Mode::Blit,"default","direct-target-unsupported");
    expect("",true,Mode::Direct,"default","validated-direct-target");
    expect("0",true,Mode::Blit,"forced","explicit-compatibility-fallback");
    expect("blit",true,Mode::Blit,"forced","explicit-compatibility-fallback");
    expect("auto",true,Mode::Direct,"auto","direct-target-supported");
    expect("auto",false,Mode::Blit,"auto","direct-target-unsupported");
    expect("1",true,Mode::Direct,"forced","explicit-direct");
    expect("direct",true,Mode::Direct,"forced","explicit-direct");
    expect("1",false,Mode::Error,"forced","direct-target-unsupported");
    expect("invalid",true,Mode::Error,"invalid","invalid-DORA_GODOT_GL_DIRECT");
}
