// blip_wasm_wrapper.c
#include "blip_buf.h"
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

static blip_t** g_instances = NULL;
static uint32_t g_capacity = 0;

static int bb_ensure_capacity(uint32_t need) {
	if (need < g_capacity) {
		return 1;
	}

	uint32_t new_cap = g_capacity ? g_capacity : 8;
	while (new_cap <= need) {
		new_cap *= 2;
	}

	blip_t** p = (blip_t**)realloc(g_instances, new_cap * sizeof(blip_t*));
	if (!p) {
		return 0;
	}

	// 清空新区域
	for (uint32_t i = g_capacity; i < new_cap; i++) {
		p[i] = NULL;
	}

	g_instances = p;
	g_capacity = new_cap;
	return 1;
}

static int bb_alloc_slot(void) {
	// 从 1 开始，0 作为无效句柄
	for (uint32_t i = 1; i < g_capacity; i++) {
		if (!g_instances[i]) {
			return (int)i;
		}
	}

	// 没找到空位，扩容
	// 保存旧容量
	uint32_t old_cap = g_capacity;
	// 如果是第一次分配（g_capacity == 0），需要确保至少容量为 2（索引 1 可用）
	uint32_t need_cap = old_cap > 0 ? old_cap + 1 : 2;
	if (!bb_ensure_capacity(need_cap)) {
		return 0;
	}

	// 返回第一个可用索引（首次分配返回 1，否则返回旧的容量值）
	uint32_t idx = old_cap > 0 ? old_cap : 1;
	return (int)idx;
}

static blip_t* bb_get(int h) {
	if (h <= 0 || (uint32_t)h >= g_capacity) {
		return NULL;
	}
	return g_instances[h];
}

// ---- 导出符号（C ABI）----
// clang/wasm-ld 通常会把非 static 的函数导出；也可配合 -Wl,--export=xxx 明确导出

// wasm 内存分配给宿主使用（宿主传入 wasm 指针）
uint32_t bb_malloc(uint32_t size) {
	void* p = malloc((size_t)size);
	return (uint32_t)(uintptr_t)p;
}

int bb_new(int size) {
	int h = bb_alloc_slot();
	if (!h) return 0;

	blip_t* b = blip_new(size);
	if (!b) return 0;

	g_instances[h] = b;
	return h;
}

void bb_delete(int h) {
	blip_t* b = bb_get(h);
	if (!b) return;
	blip_delete(b);
	g_instances[h] = NULL;
}

void bb_set_rates(int h, double clock_rate, double sample_rate) {
	blip_t* b = bb_get(h);
	if (!b) return;
	blip_set_rates(b, clock_rate, sample_rate);
}

void bb_clear(int h) {
	blip_t* b = bb_get(h);
	if (!b) return;
	blip_clear(b);
}

int bb_clocks_needed(int h, int samples) {
	blip_t* b = bb_get(h);
	if (!b) return 0;
	return blip_clocks_needed(b, samples);
}

void bb_end_frame(int h, uint32_t t) {
	blip_t* b = bb_get(h);
	if (!b) return;
	blip_end_frame(b, (unsigned)t);
}

int bb_samples_avail(int h) {
	blip_t* b = bb_get(h);
	if (!b) return 0;
	return blip_samples_avail(b);
}

// out_ptr 是 wasm 内存地址（uint32_t），由宿主用 bb_malloc 分配
int bb_read_samples(int h, uint32_t out_ptr, int count, int stereo) {
	blip_t* b = bb_get(h);
	if (!b || !out_ptr) return 0;
	short* out = (short*)(uintptr_t)out_ptr;
	return blip_read_samples(b, out, count, stereo);
}

void bb_add_delta(int h, uint32_t time, int delta) {
	blip_t* b = bb_get(h);
	if (!b) return;
	blip_add_delta(b, (unsigned)time, delta);
}

void bb_add_delta_fast(int h, uint32_t time, int delta) {
	blip_t* b = bb_get(h);
	if (!b) return;
	blip_add_delta_fast(b, (unsigned)time, delta);
}
