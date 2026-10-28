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
// Private complete framebuffer for Godot auxiliary draws (0 on native drawables).
uint32_t dora_gl_framebuffer(void *transport);
// Producer context, host GPU drained. IDs are borrowed, never deleted here.
int dora_gl_bind_targets(void *transport,uint32_t width,uint32_t height,const uint32_t *textures,uint32_t count);
void dora_gl_clear_targets(void *transport);
uint32_t dora_gl_texture(void *transport, uint32_t slot);
int dora_gl_can_produce(void *transport, uint32_t slot, uint64_t last_read);
int dora_gl_can_advance(void *transport, uint32_t slot, uint64_t last_read);
uint64_t dora_gl_copy(void *transport, uint32_t source, uint32_t slot, uint64_t last_read);
uint64_t dora_gl_copy_async(void *transport, uint32_t source, uint32_t slot, uint64_t last_read);
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
