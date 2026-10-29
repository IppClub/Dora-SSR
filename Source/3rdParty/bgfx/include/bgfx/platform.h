/*
 * Copyright 2011-2025 Branimir Karadzic. All rights reserved.
 * License: https://github.com/bkaradzic/bgfx/blob/master/LICENSE
 */

#ifndef BGFX_PLATFORM_H_HEADER_GUARD
#define BGFX_PLATFORM_H_HEADER_GUARD

// NOTICE:
// This header file contains platform specific interfaces. It is only
// necessary to use this header in conjunction with creating windows.

#include "bgfx.h"

#if !BGFX_IDL_CPP

namespace bgfx
{
	/// Render frame enum.
	///
	/// @attention C99's equivalent binding is `bgfx_render_frame_t`.
	///
	struct RenderFrame
	{
		enum Enum
		{
			NoContext,
			Render,
			Timeout,
			Exiting,

			Count
		};
	};

	/// Render frame.
	///
	/// @param _msecs Timeout in milliseconds.
	///
	/// @returns Current renderer state. See: `bgfx::RenderFrame`.
	///
	/// @attention `bgfx::renderFrame` is blocking call. It waits for
	///   `bgfx::frame` to be called from API thread to process frame.
	///   If timeout value is passed call will timeout and return even
	///   if `bgfx::frame` is not called.
	///
	/// @warning This call should be only used on platforms that don't
	///   allow creating separate rendering thread. If it is called before
	///   to bgfx::init, render thread won't be created by bgfx::init call.
	///
	/// @attention C99's equivalent binding is `bgfx_render_frame`.
	///
	RenderFrame::Enum renderFrame(int32_t _msecs = -1);

    /// Native GPU frame interop. Install/remove only on the render thread.
    /// Called before draw encoding and after all draw encoders have ended.
    /// Metal: _commandBuffer is id<MTLCommandBuffer>. Other backends must
    /// document their native payload before enabling this callback.
    /// OpenGL/OpenGLES: payload is null; the host EGL context is current.
    typedef void (*NativeFrameCallback)(RendererType::Enum _renderer, uint32_t _frame,
        void* _commandBuffer, bool _end, void* _userData);
    void setNativeFrameCallback(NativeFrameCallback _callback, void* _userData);
    void encodeNativeFrame(RendererType::Enum _renderer, uint32_t _frame,
        void* _commandBuffer, bool _end);
    /// Render thread only, between frame encodings (never inside a native
    /// callback). Submit/present an already encoded Metal or GL frame through
    /// the normal renderer flip (including its configured swap interval).
    /// The normal later flip becomes a no-op for that frame. Returns
    /// false for unsupported renderers or callback reentrancy.
    bool submitNativeFrame();

    /// Called on the render thread before the native renderer/context is torn
    /// down. Interop clients must release context-dependent resources here.
    typedef void (*NativeShutdownCallback)(RendererType::Enum _renderer, void* _userData);
    void setNativeShutdownCallback(NativeShutdownCallback _callback, void* _userData);
    void shutdownNativeInterop(RendererType::Enum _renderer);

	/// Set platform data.
	///
	/// @warning Must be called before `bgfx::init`.
	///
	/// @attention C99's equivalent binding is `bgfx_set_platform_data`.
	///
	void setPlatformData(const PlatformData& _data);

	/// Internal data.
	///
	/// @attention C99's equivalent binding is `bgfx_internal_data_t`.
	///
	struct InternalData
	{
		const struct Caps* caps; //!< Renderer capabilities.
		void* context;           //!< GL context, or D3D device.
	};

	/// Get internal data for interop.
	///
	/// @attention It's expected you understand some bgfx internals before you
	///   use this call.
	///
	/// @warning Must be called only on render thread.
	///
	/// @attention C99's equivalent binding is `bgfx_get_internal_data`.
	///
	const InternalData* getInternalData();

	/// Override internal texture with externally created texture. Previously
	/// created internal texture will released.
	///
	/// @attention It's expected you understand some bgfx internals before you
	///   use this call.
	///
	/// @param[in] _handle Texture handle.
	/// @param[in] _ptr Native API pointer to texture.
	///
	/// @returns Native API pointer to texture. If result is 0, texture is not created yet from the
	///   main thread.
	///
	/// @warning Must be called only on render thread.
	///
	/// @attention C99's equivalent binding is `bgfx_override_internal_texture_ptr`.
	///
	uintptr_t overrideInternal(TextureHandle _handle, uintptr_t _ptr);

	/// Query the renderer's native texture pointer/name without changing ownership.
	/// Returns 0 before resource creation. Render thread only.
	uintptr_t getNativeTexture(TextureHandle _handle);

	/// Override internal texture by creating new texture. Previously created
	/// internal texture will released.
	///
	/// @attention It's expected you understand some bgfx internals before you
	///   use this call.
	///
	/// @param[in] _handle Texture handle.
	/// @param[in] _width Width.
	/// @param[in] _height Height.
	/// @param[in] _numMips Number of mip-maps.
	/// @param[in] _format Texture format. See: `TextureFormat::Enum`.
	/// @param[in] _flags Default texture sampling mode is linear, and wrap mode
	///   is repeat.
	///   - `BGFX_SAMPLER_[U/V/W]_[MIRROR/CLAMP]` - Mirror or clamp to edge wrap
	///     mode.
	///   - `BGFX_SAMPLER_[MIN/MAG/MIP]_[POINT/ANISOTROPIC]` - Point or anisotropic
	///     sampling.
	///
	/// @returns Native API pointer to texture. If result is 0, texture is not created yet from the
	///   main thread.
	///
	/// @warning Must be called only on render thread.
	///
	/// @attention C99's equivalent binding is `bgfx_override_internal_texture`.
	///
	uintptr_t overrideInternal(
		  TextureHandle _handle
		, uint16_t _width
		, uint16_t _height
		, uint8_t _numMips
		, TextureFormat::Enum _format
		, uint64_t _flags = BGFX_TEXTURE_NONE|BGFX_SAMPLER_NONE
		);

} // namespace bgfx

#endif // BGFX_IDL_CPP

#endif // BGFX_PLATFORM_H_HEADER_GUARD
