// Opt-in macOS experiment. Godot and Dora communicate only through this C ABI.
#include "Const/Header.h"
#include "Basic/Application.h"
#include "Basic/Director.h"
#include "Node/Sprite.h"
#include "Node/Label.h"
#include "Node/DrawNode.h"
#include "Cache/TextureCache.h"
#include "godot_module/bridge.h"
#import <Metal/Metal.h>
#include <dlfcn.h>
#include <atomic>
#include <cstdio>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <map>

namespace {
using Start = void *(*)(const char *, int, int, int);
using Stop = void (*)(DoraGodotProbeStats *);
using Advance = uint64_t (*)(int, uint64_t);
using GetSlot = int (*)(int, DoraGodotProbeSlot *);
void *library;
Stop stop;
Advance advance;
struct Slot { id<MTLTexture> texture; id<MTLSharedEvent> ready, consumed; };
Slot slots[4];
struct Ticket { int slot; uint64_t sequence, read; };
struct Trace { uint32_t frame; int slot; uint64_t sequence, ready_at_encode; };
std::mutex ticketMutex;
std::map<uint32_t, Ticket> tickets;
std::vector<Trace> trace;
std::vector<Dora::Ref<Dora::Texture2D>> textures;
Dora::WRef<Dora::Sprite> sprite;
std::vector<bgfx::TextureHandle> pendingTextures;
uint64_t lastReads[4]{}, sequences[4]{1,0,0,0};
int current, bufferCount, frameLimit, captures, captureRequests;
bool pending;
std::atomic<bool> stopping{false};
std::atomic<int> result{1};
std::atomic<uint64_t> waitsEncoded{0}, signalsEncoded{0}, consumerCompleted{0}, gpuErrors{0}, pendingReadyWaits{0};
std::string output;
std::ofstream captureIndex;
id<MTLComputePipelineState> stressPipeline;
id<MTLBuffer> stressOutput;
uint32_t gpuWork;
uint64_t deferredProductions=0;

int setting(const char *name, int fallback, int low, int high) {
    const char *value = std::getenv(name);
    if (!value) return fallback;
    char *end;
    long parsed = std::strtol(value, &end, 10);
    if (*end || parsed < low || parsed > high) return -1;
    return static_cast<int>(parsed);
}
void fail(const char *message) {
    result = 2;
    fprintf(stderr, "GODOT_METAL_PROBE FAIL: %s\n", message);
    SharedApplication.invokeInLogic([] { SharedApplication.shutdown(); });
}
void capture(int tick, bool transformed) {
    const std::string name = transformed ? "dora-transformed-frame.png" : "animation-" + std::to_string(tick) + ".png";
    captureIndex << name << ',' << sequences[current] << ',' << current << ',' << SharedApplication.getFrame() + 1 << ',' << transformed << '\n';
    ++captureRequests;
    if (!SharedDirector.captureGameAsync(output + "/" + name, [name](bool success, double, Dora::Size) {
        fprintf(stderr, "GODOT_METAL_PROBE capture=%s success=%d\n", name.c_str(), success);
        if (success) ++captures;
        else result = 2;
    })) fail("capture request failed");
}
void installNode(bgfx::TextureFormat::Enum format) {
    using namespace Dora;
    bgfx::TextureInfo info{};
    bgfx::calcTextureSize(info, 640, 360, 1, false, false, 1, format);
    for (auto handle : pendingTextures) textures.emplace_back(Texture2D::create(handle, info, BGFX_SAMPLER_U_CLAMP | BGFX_SAMPLER_V_CLAMP));
    pendingTextures.clear();
    auto *node = Sprite::create(textures[0]);
    sprite = node;
    const auto buffer = SharedApplication.getBufferSize();
    auto *stage = Node::create();
    const float scale = std::min(buffer.width / 1280, buffer.height / 720);
    stage->setScaleX(scale); stage->setScaleY(scale);
    SharedDirector.getUI()->addChild(stage);
    SharedDirector.setClearColor(Color(0xff192331));
    SharedDirector.beginGameCapture();
    auto *background = DrawNode::create();
    background->drawPolygon({{-640,-360}, {640,-360}, {640,360}, {-640,360}}, Color(0xff192331), 0, Color(0));
    stage->addChild(background);
    node->setScaleX(1.25f); node->setScaleY(1.25f);
    stage->addChild(node);
    auto label = [&](const std::string &text, float y, uint32_t fontSize) {
        auto *labelNode = Label::create("sarasa-mono-sc-regular", fontSize);
        if (labelNode) { labelNode->setText(text); labelNode->setPosition({0,y}); stage->addChild(labelNode); }
    };
    label("Live LibGodot / Metal -> bgfx -> Dora Sprite", 295, 24);
    label(std::to_string(bufferCount) + " GPU buffers | ready / consumed events | live GDScript animation", -285, 17);
    label("GPU blit only | frame stamps check stale frames and tearing", -315, 17);
    captureIndex.open(output + "/captures.csv");
    captureIndex << "file,sequence,slot,bgfx_frame,transformed\n";
    auto tick = std::make_shared<int>(0);
    node->schedule([node, tick](double) {
        if (stopping) return true;
        ++*tick;
        // Every submitted consumer frame gets its own monotonically increasing
        // read token, including frames that display the same producer snapshot.
        const uint32_t frame = SharedApplication.getFrame() + 1;
        {
            std::lock_guard lock(ticketMutex);
            if (!tickets.emplace(frame, Ticket{current, sequences[current], frame}).second) { fail("duplicate bgfx frame token"); return true; }
        }
        lastReads[current] = frame;
        if (*tick <= frameLimit - 150 && (*tick == 120 || *tick == 150 || *tick == 180 || *tick % 300 == 0)) capture(*tick, false);
        if (*tick == frameLimit - 120) {
            node->setAngle(12); node->setScaleX(1); node->setScaleY(1); node->setOpacity(0.8f);
        }
        if (*tick == frameLimit - 60) capture(*tick, true);
        if (*tick == frameLimit) {
            fprintf(stderr, "GODOT_METAL_PROBE sampled_frames=%d captures=%d/%d\n", *tick, captures, captureRequests);
            if (captures != captureRequests) result = 2;
            if (!std::getenv("DORA_GODOT_PROBE_KEEP_OPEN")) { stopping = true; SharedApplication.shutdown(); return false; }
        }
        // Reserve a non-displayed slot. No future logic frame can read it until
        // this publication completes. Its lastReads value is therefore final.
        if (!pending) {
            const int target = (current + 1) % bufferCount;
            const uint64_t wait = lastReads[target];
            // Avoid putting a future consumer dependency in Godot's queue:
            // Godot may synchronously wait for that queue on its next iteration.
            if (slots[target].consumed.signaledValue < wait) {
                ++deferredProductions;
                return false;
            }
            pending = true;
            SharedApplication.invokeInRender([target, wait] {
                if (stopping) return;
                const uint64_t sequence = advance(target, wait);
                if (!sequence) { fail("Godot advance failed"); return; }
                SharedApplication.invokeInLogic([target, sequence] {
                    if (stopping) return;
                    current = target; sequences[target] = sequence;
                    if (auto *node = sprite.get()) node->setTexture(textures[target]);
                    pending = false;
                });
            });
        }
        return false;
    });
}
}

// Called only by the opt-in bgfx Metal submit hooks, on its render thread.
extern "C" void dora_libgodot_metal_probe_encode(void *native, uint32_t frame, bool end) {
    Ticket ticket;
    {
        std::lock_guard lock(ticketMutex);
        auto found = tickets.find(frame);
        if (found == tickets.end()) return; // Startup, resource-only, or shutdown frame.
        ticket = found->second;
        if (end) tickets.erase(found);
    }
    id<MTLCommandBuffer> command = (__bridge id<MTLCommandBuffer>)native;
    auto &slot = slots[ticket.slot];
    if (!end) {
        const uint64_t ready = slot.ready.signaledValue;
        if (ready < ticket.sequence) ++pendingReadyWaits;
        [command encodeWaitForEvent:slot.ready value:ticket.sequence];
        ++waitsEncoded;
        trace.push_back({frame, ticket.slot, ticket.sequence, ready});
        if (gpuWork) {
            id<MTLComputeCommandEncoder> compute = [command computeCommandEncoder];
            [compute setComputePipelineState:stressPipeline];
            [compute setBuffer:stressOutput offset:0 atIndex:0];
            [compute setBytes:&gpuWork length:sizeof(gpuWork) atIndex:1];
            [compute dispatchThreads:MTLSizeMake(256,1,1) threadsPerThreadgroup:MTLSizeMake(64,1,1)];
            [compute endEncoding];
        }
    } else {
        // All sampling encoders are closed. This signal protects reuse even if
        // the GPU remains several command buffers behind the API/render threads.
        [command encodeSignalEvent:slot.consumed value:ticket.read];
        ++signalsEncoded;
        [command addCompletedHandler:^(id<MTLCommandBuffer> completed) {
            if (completed.status == MTLCommandBufferStatusError) {
                ++gpuErrors;
                fprintf(stderr, "GODOT_METAL_PROBE FAIL: consumer GPU %s\n", completed.error.description.UTF8String);
            }
            ++consumerCompleted;
        }];
    }
}

extern "C" int dora_libgodot_metal_probe_main() {
    const char *path = std::getenv("DORA_GODOT_PROBE_LIBRARY");
    const char *project = std::getenv("DORA_GODOT_PROBE_PROJECT");
    const char *out = std::getenv("DORA_GODOT_PROBE_OUTPUT");
    bufferCount = setting("DORA_GODOT_PROBE_BUFFERS", 3, 2, 4);
    frameLimit = setting("DORA_GODOT_PROBE_FRAMES", 1800, 600, 36000);
    const int work = setting("DORA_GODOT_PROBE_GPU_WORK", 0, 0, 2000000);
    if (!path || !project || !out || bufferCount < 0 || frameLimit < 0 || work < 0) { fail("invalid environment settings"); return 1; }
    gpuWork = work;
    output = out;
    std::filesystem::create_directories(output);
    if (bgfx::getRendererType() != bgfx::RendererType::Metal) { fail("Dora did not select Metal"); return 1; }
    if (std::getenv("DORA_GODOT_PROBE_UNLIMITED")) SharedApplication.setFPSLimited(false);
    SharedApplication.quitHandler += [] {
        stopping = true;
        textures.clear(); // Release bgfx wrappers on its API thread, before shutdown.
        for (auto handle : pendingTextures) bgfx::destroy(handle);
        pendingTextures.clear();
    };
    for (int i = 0; i < bufferCount; ++i)
        pendingTextures.push_back(bgfx::createTexture2D(640, 360, false, 1, bgfx::TextureFormat::RGBA8, BGFX_SAMPLER_U_CLAMP | BGFX_SAMPLER_V_CLAMP));
    SharedApplication.invokeInRender([path = std::string(path), project = std::string(project)] {
        @autoreleasepool {
            library = dlopen(path.c_str(), RTLD_NOW | RTLD_LOCAL | RTLD_FIRST);
            if (!library) { fail(dlerror()); return; }
            auto start = reinterpret_cast<Start>(dlsym(library, "dora_godot_probe_start"));
            stop = reinterpret_cast<Stop>(dlsym(library, "dora_godot_probe_stop"));
            advance = reinterpret_cast<Advance>(dlsym(library, "dora_godot_probe_advance"));
            auto getSlot = reinterpret_cast<GetSlot>(dlsym(library, "dora_godot_probe_slot"));
            if (!start || !stop || !advance || !getSlot) { fail("bridge exports missing"); return; }
            if (!start(project.c_str(), 640, 360, bufferCount)) { fail("Godot start failed"); return; }
            id<MTLDevice> device = (__bridge id<MTLDevice>)bgfx::getInternalData()->context;
            for (int i = 0; i < bufferCount; ++i) {
                DoraGodotProbeSlot bridge{};
                if (!getSlot(i, &bridge)) { fail("missing producer slot"); return; }
                slots[i] = {(__bridge id<MTLTexture>)bridge.texture, (__bridge id<MTLSharedEvent>)bridge.ready, (__bridge id<MTLSharedEvent>)bridge.consumed};
                if (slots[i].texture.device != device || slots[i].texture.pixelFormat != MTLPixelFormatRGBA8Unorm) { fail("incompatible Metal device/format"); return; }
                const auto pointer = bgfx::overrideInternal(pendingTextures[i], reinterpret_cast<uintptr_t>(bridge.texture));
                if (pointer != reinterpret_cast<uintptr_t>(bridge.texture)) { fail("external texture replacement failed"); return; }
            }
            if (gpuWork) {
                NSError *error = nil;
                NSString *source = @"#include <metal_stdlib>\nusing namespace metal;\nkernel void stress(device uint *out [[buffer(0)]], constant uint &n [[buffer(1)]], uint i [[thread_position_in_grid]]) { uint v=i+1; for(uint k=0;k<n;k++) v=(v*1664525u+1013904223u) ^ (v>>13); out[i]=v; }";
                id<MTLLibrary> shader = [device newLibraryWithSource:source options:nil error:&error];
                stressPipeline = [device newComputePipelineStateWithFunction:[shader newFunctionWithName:@"stress"] error:&error];
                stressOutput = [device newBufferWithLength:256 * sizeof(uint32_t) options:MTLResourceStorageModePrivate];
                if (!stressPipeline || !stressOutput) { fail("GPU stress kernel initialization failed"); return; }
            }
            fprintf(stderr, "GODOT_METAL_PROBE same_device=1 imported_same_texture=1 buffers=%d gpu_work=%u cpu_pixel_transfer=0\n", bufferCount, gpuWork);
            SharedApplication.invokeInLogic([] { installNode(bgfx::TextureFormat::RGBA8); });
        }
    });
    return 1;
}
extern "C" int dora_libgodot_metal_probe_finish() {
    // Application::run has drained bgfx. No new frame or producer task is allowed.
    stopping = true;
    DoraGodotProbeStats producer{};
    if (stop) stop(&producer);
    const uint64_t consumed = consumerCompleted.load();
    if (result == 1) result = (trace.size() >= static_cast<size_t>(frameLimit) && waitsEncoded == signalsEncoded && consumed == signalsEncoded
        && gpuErrors == 0 && producer.errors == 0 && producer.produced == producer.completed && producer.produced > 100 && tickets.empty()) ? 0 : 2;
    fprintf(stderr, "GODOT_METAL_PROBE final produced=%llu producer_completed=%llu consumer_completed=%llu waits=%llu signals=%llu pending_ready_waits=%llu reuse_waits=%llu gpu_errors=%llu tickets=%zu result=%d deferred_productions=%llu\n",
        producer.produced, producer.completed, consumed, waitsEncoded.load(), signalsEncoded.load(), pendingReadyWaits.load(), producer.reuse_waits, gpuErrors.load()+producer.errors, tickets.size(), result.load(), deferredProductions);
    std::ofstream csv(output + "/frames.csv");
    csv << "bgfx_frame,slot,sequence,ready_at_encode\n";
    for (auto &record : trace) csv << record.frame << ',' << record.slot << ',' << record.sequence << ',' << record.ready_at_encode << '\n';
    captureIndex.close();
    for (auto &slot : slots) { slot.texture = nil; slot.ready = nil; slot.consumed = nil; }
    stressPipeline = nil; stressOutput = nil;
    return result;
}
