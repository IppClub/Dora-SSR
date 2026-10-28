#import <Metal/Metal.h>
#include <bgfx/platform.h>
#include <cstdint>
extern "C" int64_t dora_godot_test_metal_bytes() {
    const auto *internal=bgfx::getInternalData();
    if (!internal || !internal->context) return -1;
    id<MTLDevice> device=(__bridge id<MTLDevice>)internal->context;
    return static_cast<int64_t>(device.currentAllocatedSize);
}
