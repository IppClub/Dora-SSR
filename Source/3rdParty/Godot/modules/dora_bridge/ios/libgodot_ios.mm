// Copyright (c) 2026 Dora SSR contributors. MIT license (see repository LICENSE).
// Keep upstream iOS services; Dora owns UIApplication, rendering and presentation.
#include "core/extension/libgodot.h"
#include "core/extension/godot_instance.h"
#include "core/os/main_loop.h"
#include "core/io/logger.h"
#include "core/profiling/profiling.h"
#include "main/main.h"
#include "platform/ios/os_ios.h"
#include "../display_server_dora_metal.h"

namespace {
class OS_DoraIOS final : public OS_IOS {
public:
    OS_DoraIOS() {
        Vector<Logger *> loggers;loggers.push_back(memnew(StdLogger));
        _set_logger(memnew(CompositeLogger(loggers)));
    }

};
OS_DoraIOS *os=nullptr;
GodotInstance *instance=nullptr;
bool terminated=false;
}
GDExtensionObjectPtr libgodot_create_godot_instance(int argc,char *argv[],GDExtensionInitializationFunction init) {
    ERR_FAIL_COND_V(instance || terminated || os || argc<1 || !argv,nullptr);
    @autoreleasepool {
        os=new OS_DoraIOS;
        DisplayServer::register_create_function("dora-metal",DisplayServerDoraMetal::create,DisplayServerDoraMetal::drivers);
        godot_init_profiler();
        const auto error=Main::setup(argv[0],argc-1,argc>1?argv+1:nullptr,false);
        if (error!=OK) { terminated=true;return nullptr; }
        os->initialize_modules();
        instance=memnew(GodotInstance);
        if (!instance->initialize(init)) { memdelete(instance);instance=nullptr;terminated=true;return nullptr; }
        return (GDExtensionObjectPtr)instance;
    }
}
void libgodot_destroy_godot_instance(GDExtensionObjectPtr object) {
    if (!instance || object!=(GDExtensionObjectPtr)instance) return;
    @autoreleasepool {
        instance->stop();memdelete(instance);instance=nullptr;
        Main::cleanup();godot_cleanup_profiler();delete os;os=nullptr;terminated=true;
    }
}

// Upstream's iOS exporter generates these bodies from its optional native
// export-plugin list. This embedded package has no native iOS export plugins;
// standard Godot modules and GDExtension registration still run normally.
void godot_apple_embedded_plugins_initialize() {}
void godot_apple_embedded_plugins_deinitialize() {}
