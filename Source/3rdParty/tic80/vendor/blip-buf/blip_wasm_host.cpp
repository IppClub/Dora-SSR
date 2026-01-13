/* blip_wasm_host.cpp
 *
 * This file provides a host implementation for blip_buf using WebAssembly (wasm3).
 * It satisfies the LGPL requirement by allowing users to link against a dynamically
 * loaded WASM module instead of statically linking the LGPL-licensed blip_buf library.
 *
 * Usage:
 * - First tries to load blip_buf.wasm from the filesystem
 * - Falls back to using the embedded blip_buf.inl if external file is not available
 *
 * Copyright (c) 2024
 * This wrapper code is provided under your project's license.
 * The blip_buf library itself is licensed under LGPL v2.1 or later.
 */

#include "Const/Header.h"

#include "tic80/vendor/blip-buf/blip_buf.h"
#include "tic80/vendor/blip-buf/blip_buf.inl"

#include "wasm3_cpp.h"
#include "tic80/tic80.h"

#include "Basic/Content.h"
#include "Common/Debug.h"

#include <cstring>
#include <memory>
#include <mutex>

NS_DORA_BEGIN

// WASM runtime wrapper
class BlipBufWasmRuntime {
public:
	static BlipBufWasmRuntime& instance() {
		static BlipBufWasmRuntime runtime;
		return runtime;
	}

	bool initialize() {
		if (_initialized) {
			return true;
		}

		try {
			bool loaded = false;

			// Try to load external WASM file first
			const auto wasmPath = "blip_buf.wasm"sv;
			if (SharedContent.exist(wasmPath)) {
				auto [data, size] = SharedContent.load(wasmPath);
				if (data && size > 0) {
					try {
						_env = New<wasm3::environment>();
						_runtime = New<wasm3::runtime>(_env->new_runtime(8192));
						auto mod = _env->parse_module(data.get(), size);
						_runtime->load(mod);
						mod.link_default();
						loaded = true;
						Info("Loaded blip_buf.wasm from external file ({} bytes)", size);
					} catch (const std::exception& e) {
						Warn("Failed to load external blip_buf.wasm: {}, falling back to embedded version", e.what());
						_env.reset();
						_runtime.reset();
					}
				}
			}

			// Fall back to embedded WASM
			if (!loaded) {
				_env = New<wasm3::environment>();
				_runtime = New<wasm3::runtime>(_env->new_runtime(1024 * 4));
				auto mod = _env->parse_module(blip_buf_wasm, blip_buf_wasm_len);
				_runtime->load(mod);
				mod.link_default();
				Info("Using embedded blip_buf.wasm ({} bytes)", blip_buf_wasm_len);
			}

			// Get function handles
			auto fn_malloc = New<wasm3::function>(_runtime->find_function("bb_malloc"));
			_fn_new = New<wasm3::function>(_runtime->find_function("bb_new"));
			_fn_delete = New<wasm3::function>(_runtime->find_function("bb_delete"));
			_fn_set_rates = New<wasm3::function>(_runtime->find_function("bb_set_rates"));
			_fn_clear = New<wasm3::function>(_runtime->find_function("bb_clear"));
			_fn_clocks_needed = New<wasm3::function>(_runtime->find_function("bb_clocks_needed"));
			_fn_end_frame = New<wasm3::function>(_runtime->find_function("bb_end_frame"));
			_fn_samples_avail = New<wasm3::function>(_runtime->find_function("bb_samples_avail"));
			_fn_read_samples = New<wasm3::function>(_runtime->find_function("bb_read_samples"));
			_fn_add_delta = New<wasm3::function>(_runtime->find_function("bb_add_delta"));
			_fn_add_delta_fast = New<wasm3::function>(_runtime->find_function("bb_add_delta_fast"));

			_sample_read_size = DORA_SAMPLERATE / TIC80_FRAMERATE * TIC80_SAMPLE_CHANNELS * sizeof(short);
			_sample_read_buffer = fn_malloc->call<uint32_t>(_sample_read_size);
			if (!_sample_read_buffer) {
				Error("bb_read_samples: failed to allocate WASM memory");
				return false;
			}

			_initialized = true;
			return true;
		} catch (const std::exception& e) {
			Error("Failed to initialize blip_buf WASM runtime: {}", e.what());
			_initialized = false;
			return false;
		}
	}

	int bb_new(int size) {
		if (!_initialized || !_fn_new) return 0;
		try {
			return _fn_new->call<int>(size);
		} catch (const std::exception& e) {
			Error("bb_new failed: {}", e.what());
			return 0;
		}
	}

	void bb_delete(int h) {
		if (!_initialized || !_fn_delete) return;
		try {
			_fn_delete->call<void>(h);
		} catch (const std::exception& e) {
			Error("bb_delete failed: {}", e.what());
		}
	}

	void bb_set_rates(int h, double clock_rate, double sample_rate) {
		if (!_initialized || !_fn_set_rates) return;
		try {
			_fn_set_rates->call<void>(h, clock_rate, sample_rate);
		} catch (const std::exception& e) {
			Error("bb_set_rates failed: {}", e.what());
		}
	}

	void bb_clear(int h) {
		if (!_initialized || !_fn_clear) return;
		try {
			_fn_clear->call<void>(h);
		} catch (const std::exception& e) {
			Error("bb_clear failed: {}", e.what());
		}
	}

	int bb_clocks_needed(int h, int samples) {
		if (!_initialized || !_fn_clocks_needed) return 0;
		try {
			return _fn_clocks_needed->call<int>(h, samples);
		} catch (const std::exception& e) {
			Error("bb_clocks_needed failed: {}", e.what());
			return 0;
		}
	}

	void bb_end_frame(int h, uint32_t t) {
		if (!_initialized || !_fn_end_frame) return;
		try {
			_fn_end_frame->call<void>(h, t);
		} catch (const std::exception& e) {
			Error("bb_end_frame failed: {}", e.what());
		}
	}

	int bb_samples_avail(int h) {
		if (!_initialized || !_fn_samples_avail) return 0;
		try {
			return _fn_samples_avail->call<int>(h);
		} catch (const std::exception& e) {
			Error("bb_samples_avail failed: {}", e.what());
			return 0;
		}
	}

	int bb_read_samples(int h, short* out, int count, int stereo) {
		if (!_initialized || !_fn_read_samples || !out) return 0;
		try {
			uint8_t* wasm_out = _runtime->get_address(_sample_read_buffer);
			memcpy(wasm_out, out, _sample_read_size);

			// Call WASM function
			int result = _fn_read_samples->call<int>(h, _sample_read_buffer, count, stereo);

			if (result > 0) {
				// Copy data from WASM memory to host memory
				uint8_t* wasm_mem = _runtime->get_address(_sample_read_buffer);
				if (wasm_mem) {
					if (stereo) {
						// For stereo, samples are interleaved
						memcpy(out, wasm_mem, result * 2 * sizeof(short));
					} else {
						// For mono, copy directly
						memcpy(out, wasm_mem, result * sizeof(short));
					}
				} else {
					Error("bb_read_samples: failed to get WASM memory address");
					result = 0;
				}
			}
			return result;
		} catch (const std::exception& e) {
			Error("bb_read_samples failed: {}", e.what());
			return 0;
		}
	}

	void bb_add_delta(int h, uint32_t time, int delta) {
		if (!_initialized || !_fn_add_delta) return;
		try {
			_fn_add_delta->call<void>(h, time, delta);
		} catch (const std::exception& e) {
			Error("bb_add_delta failed: {}", e.what());
		}
	}

	void bb_add_delta_fast(int h, uint32_t time, int delta) {
		if (!_initialized || !_fn_add_delta_fast) return;
		try {
			_fn_add_delta_fast->call<void>(h, time, delta);
		} catch (const std::exception& e) {
			Error("bb_add_delta_fast failed: {}", e.what());
		}
	}

private:
	bool _initialized = false;
	uint32_t _sample_read_buffer = 0;
	uint32_t _sample_read_size = 0;
	Own<wasm3::environment> _env;
	Own<wasm3::runtime> _runtime;

	Own<wasm3::function> _fn_new;
	Own<wasm3::function> _fn_delete;
	Own<wasm3::function> _fn_set_rates;
	Own<wasm3::function> _fn_clear;
	Own<wasm3::function> _fn_clocks_needed;
	Own<wasm3::function> _fn_end_frame;
	Own<wasm3::function> _fn_samples_avail;
	Own<wasm3::function> _fn_read_samples;
	Own<wasm3::function> _fn_add_delta;
	Own<wasm3::function> _fn_add_delta_fast;
};

// Simple handle storage - since blip_t* is opaque, we can store the handle in it
// This is a bit of a hack, but it works with the existing interface
struct BlipHandle {
	int handle;
};

NS_DORA_END

// Implementation of blip_buf.h interface

extern "C" {
using namespace Dora;

blip_t* blip_new(int sample_count) {
	if (!BlipBufWasmRuntime::instance().initialize()) {
		return nullptr;
	}

	int handle = BlipBufWasmRuntime::instance().bb_new(sample_count);
	if (handle <= 0) {
		return nullptr;
	}

	// Store handle in a way compatible with blip_t* interface
	// We allocate a small structure to store the handle
	BlipHandle* bh = new BlipHandle;
	bh->handle = handle;
	return reinterpret_cast<blip_t*>(bh);
}

void blip_set_rates(blip_t* m, double clock_rate, double sample_rate) {
	if (!m) return;
	BlipHandle* bh = reinterpret_cast<BlipHandle*>(m);
	BlipBufWasmRuntime::instance().bb_set_rates(bh->handle, clock_rate, sample_rate);
}

void blip_clear(blip_t* m) {
	if (!m) return;
	BlipHandle* bh = reinterpret_cast<BlipHandle*>(m);
	BlipBufWasmRuntime::instance().bb_clear(bh->handle);
}

void blip_add_delta(blip_t* m, unsigned int clock_time, int delta) {
	if (!m) return;
	BlipHandle* bh = reinterpret_cast<BlipHandle*>(m);
	BlipBufWasmRuntime::instance().bb_add_delta(bh->handle, clock_time, delta);
}

void blip_add_delta_fast(blip_t* m, unsigned int clock_time, int delta) {
	if (!m) return;
	BlipHandle* bh = reinterpret_cast<BlipHandle*>(m);
	BlipBufWasmRuntime::instance().bb_add_delta_fast(bh->handle, clock_time, delta);
}

int blip_clocks_needed(const blip_t* m, int sample_count) {
	if (!m) return 0;
	const BlipHandle* bh = reinterpret_cast<const BlipHandle*>(m);
	return BlipBufWasmRuntime::instance().bb_clocks_needed(bh->handle, sample_count);
}

void blip_end_frame(blip_t* m, unsigned int clock_duration) {
	if (!m) return;
	BlipHandle* bh = reinterpret_cast<BlipHandle*>(m);
	BlipBufWasmRuntime::instance().bb_end_frame(bh->handle, clock_duration);
}

int blip_samples_avail(const blip_t* m) {
	if (!m) return 0;
	const BlipHandle* bh = reinterpret_cast<const BlipHandle*>(m);
	return BlipBufWasmRuntime::instance().bb_samples_avail(bh->handle);
}

int blip_read_samples(blip_t* m, short out[], int count, int stereo) {
	if (!m || !out) return 0;
	BlipHandle* bh = reinterpret_cast<BlipHandle*>(m);
	return BlipBufWasmRuntime::instance().bb_read_samples(bh->handle, out, count, stereo);
}

void blip_delete(blip_t* m) {
	if (!m) return;
	BlipHandle* bh = reinterpret_cast<BlipHandle*>(m);
	BlipBufWasmRuntime::instance().bb_delete(bh->handle);
	delete bh;
}

} // extern "C"
