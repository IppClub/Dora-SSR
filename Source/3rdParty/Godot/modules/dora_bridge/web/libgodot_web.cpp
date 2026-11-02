// Copyright (c) 2026 Dora SSR contributors. MIT license (see repository LICENSE).
// Retain upstream Web OS/resources; the host owns the canvas and frame loop.
#include "core/extension/libgodot.h"
#include "core/extension/godot_instance.h"
#include "core/profiling/profiling.h"
#include "main/main.h"
#include "platform/web/os_web.h"
#include "../gl/display_server_dora_gl.h"
namespace {
OS_Web *os=nullptr;
GodotInstance *instance=nullptr;
bool terminated=false;
}
GDExtensionObjectPtr libgodot_create_godot_instance(int argc,char *argv[],GDExtensionInitializationFunction init) {
    ERR_FAIL_COND_V(instance || terminated || os || argc<1 || !argv,nullptr);
    os=new OS_Web;
    DisplayServer::register_create_function("dora-gl",DisplayServerDoraGL::create,DisplayServerDoraGL::drivers);
    godot_init_profiler();
    if (Main::setup(argv[0],argc-1,argc>1?argv+1:nullptr,false)!=OK) {terminated=true;return nullptr;}
    instance=memnew(GodotInstance);
    if (!instance->initialize(init)) {memdelete(instance);instance=nullptr;terminated=true;return nullptr;}
    return (GDExtensionObjectPtr)instance;
}
void libgodot_destroy_godot_instance(GDExtensionObjectPtr object) {
    if (!instance || object!=(GDExtensionObjectPtr)instance) return;
    instance->stop();memdelete(instance);instance=nullptr;
    Main::cleanup();godot_cleanup_profiler();delete os;os=nullptr;terminated=true;
}
