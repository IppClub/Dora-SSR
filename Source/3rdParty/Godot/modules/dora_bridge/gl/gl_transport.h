#pragma once
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
// All calls use the host render thread. Producer context owns its own GL state;
// only texture and sync objects are shared. No pixel transfer crosses the CPU.
void *dora_gl_create(void *host_context, uint32_t width, uint32_t height, uint32_t buffers);
const char *dora_gl_error(void);
int dora_gl_enter(void *transport);
int dora_gl_leave(void *transport);
void *dora_gl_display(void *transport);
int dora_gl_desktop(void *transport);
// True when this transport may attach borrowed host textures directly to the
// Godot final render target. Platform rollout is explicit: unsupported
// transports keep the GPU-blit path and reject a forced direct request.
int dora_gl_supports_direct_targets(void *transport);
// Monotonic transport counters make direct and compatibility paths observable
// without changing the public Godot bridge ABI.
uint64_t dora_gl_blits(void *transport);
uint64_t dora_gl_direct_publications(void *transport);
int dora_gl_gpu_timer_supported(void *transport);
int dora_gl_gpu_timer_reliable(void *transport);
uint64_t dora_gl_blit_gpu_time_ns(void *transport);
uint64_t dora_gl_blit_gpu_samples(void *transport);
uint64_t dora_gl_blit_gpu_rejected(void *transport);
// Private complete framebuffer for Godot auxiliary draws (0 on native drawables).
uint32_t dora_gl_framebuffer(void *transport);
// Producer context, host GPU drained. IDs are borrowed, never deleted here.
int dora_gl_bind_targets(void *transport,uint32_t width,uint32_t height,const uint32_t *textures,uint32_t count);
void dora_gl_clear_targets(void *transport);
#if defined(LINUXBSD_ENABLED) || defined(WINDOWS_ENABLED)
// Project boundary only: producer current, both GPU queues drained. Retains the producer context.
int dora_gl_reset_targets(void *transport,uint32_t width,uint32_t height,uint32_t buffers);
#endif
uint32_t dora_gl_texture(void *transport, uint32_t slot);
int dora_gl_can_produce(void *transport, uint32_t slot, uint64_t last_read);
int dora_gl_can_advance(void *transport, uint32_t slot, uint64_t last_read);
uint64_t dora_gl_copy(void *transport, uint32_t source, uint32_t slot, uint64_t last_read);
uint64_t dora_gl_copy_async(void *transport, uint32_t source, uint32_t slot, uint64_t last_read);
// Producer context: enqueue the last consumer's GPU wait before any write to
// the borrowed slot. queued uses the same admission check as copy_async.
int dora_gl_begin_direct(void *transport, uint32_t slot, uint64_t last_read, int queued);
// After begin_direct and rendering into the borrowed slot texture, publish only
// a completion fence; unlike dora_gl_copy*, this performs no framebuffer blit.
uint64_t dora_gl_publish(void *transport, uint32_t slot, uint64_t last_read);
uint64_t dora_gl_publish_async(void *transport, uint32_t slot, uint64_t last_read);
int dora_gl_consumer_begin(void *transport, uint32_t slot, uint64_t sequence);
int dora_gl_consumer_end(void *transport, uint32_t slot, uint64_t read);
void dora_gl_drain(void *transport);
uint64_t dora_gl_completed(void *transport);
uint64_t dora_gl_deferred(void *transport);
uint64_t dora_gl_errors(void *transport);
void dora_gl_destroy(void *transport);
#ifdef __cplusplus
}
#endif
