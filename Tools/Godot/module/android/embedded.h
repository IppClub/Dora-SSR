#pragma once
namespace DoraGodotAndroid {
extern bool prepared;
extern bool host_filesystem;
// Implemented beside upstream JNI teardown so the same Java services, platform
// threads, resource access and profiler are released in their original order.
void cleanup();
}
