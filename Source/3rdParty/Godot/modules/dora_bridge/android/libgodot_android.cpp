// Android retains upstream OS_Android and Java services. Dora owns EGL/present.
#include "../GodotBridgeAndroid.h"
#include "embedded.h"
#include "core/extension/libgodot.h"
#include "core/extension/godot_instance.h"
#include "core/io/dir_access.h"
#include "drivers/unix/dir_access_unix.h"
#include "drivers/unix/file_access_unix.h"
#include "platform/android/os_android.h"
namespace DoraGodotAndroid { bool prepared=false; bool host_filesystem=false; }
namespace {
GodotInstance *instance=nullptr;
DoraGodotAndroidPrepare prepare=nullptr;
void *userdata=nullptr;
bool terminated=false;
int configure(DoraGodotAndroidPrepare callback,void *context) {
    if (!callback || prepare || instance || terminated) return 0;
    prepare=callback;userdata=context;return 1;
}
}
extern "C" DORA_GODOT_EXPORT int dora_godot_get_android_api(uint32_t version,DoraGodotAndroidAPI *api) {
    if (version!=DORA_GODOT_ANDROID_ABI_VERSION || !api || api->size<sizeof(*api)) return 0;
    *api={sizeof(*api),DORA_GODOT_ANDROID_ABI_VERSION,configure};return 1;
}
GDExtensionObjectPtr libgodot_create_godot_instance(int argc,char *argv[],GDExtensionInitializationFunction init) {
    ERR_FAIL_COND_V(instance || terminated || !prepare || argc<1 || !argv,nullptr);
    ERR_FAIL_COND_V(!prepare(userdata,uint32_t(argc),argv) || !DoraGodotAndroid::prepared || !OS::get_singleton(),nullptr);
    // The embedded project is a real host filesystem directory or PCK. APK
    // asset access remains initialized for upstream Android platform services.
    FileAccess::make_default<FileAccessUnix>(FileAccess::ACCESS_RESOURCES);
    DirAccess::make_default<DirAccessUnix>(DirAccess::ACCESS_RESOURCES);
    instance=memnew(GodotInstance);
    if (!instance->initialize(init)) { memdelete(instance);instance=nullptr;return nullptr; }
    return (GDExtensionObjectPtr)instance;
}
void libgodot_destroy_godot_instance(GDExtensionObjectPtr object) {
    if (!instance || object!=(GDExtensionObjectPtr)instance) return;
    instance->stop();memdelete(instance);instance=nullptr;terminated=true;
    DoraGodotAndroid::cleanup();
}
