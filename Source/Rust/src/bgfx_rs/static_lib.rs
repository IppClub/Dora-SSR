use core::ffi::c_void;
use std::mem::MaybeUninit;

use crate::bgfx_rs::bgfx_sys;

/// Fatal error enum.
#[repr(u32)]
#[derive(Clone, Copy, PartialEq, Debug)]
pub enum Fatal {
	DebugCheck,
	InvalidShader,
	UnableToInitialize,
	UnableToCreateTexture,
	DeviceLost,
	/// Number of entries in the enum
	Count,
}

/// Renderer backend type enum.
#[repr(u32)]
#[derive(Clone, Copy, PartialEq, Debug)]
pub enum RendererType {
	/// No rendering.
	Noop,
	/// AGC
	Agc,
	/// Direct3D 11.0
	Direct3D11,
	/// Direct3D 12.0
	Direct3D12,
	/// GNM
	Gnm,
	/// Metal
	Metal,
	/// NVN
	Nvn,
	/// OpenGL ES 2.0+
	OpenGLES,
	/// OpenGL 2.1+
	OpenGL,
	/// Vulkan
	Vulkan,
	/// Number of entries in the enum
	Count,
}

/// Access mode enum.
#[repr(u32)]
#[derive(Clone, Copy, PartialEq, Debug)]
pub enum Access {
	/// Read.
	Read,
	/// Write.
	Write,
	/// Read and write.
	ReadWrite,
	/// Number of entries in the enum
	Count,
}

/// Vertex attribute enum.
#[repr(u32)]
#[derive(Clone, Copy, PartialEq, Debug)]
pub enum Attrib {
	/// a_position
	Position,
	/// a_normal
	Normal,
	/// a_tangent
	Tangent,
	/// a_bitangent
	Bitangent,
	/// a_color0
	Color0,
	/// a_color1
	Color1,
	/// a_color2
	Color2,
	/// a_color3
	Color3,
	/// a_indices
	Indices,
	/// a_weight
	Weight,
	/// a_texcoord0
	TexCoord0,
	/// a_texcoord1
	TexCoord1,
	/// a_texcoord2
	TexCoord2,
	/// a_texcoord3
	TexCoord3,
	/// a_texcoord4
	TexCoord4,
	/// a_texcoord5
	TexCoord5,
	/// a_texcoord6
	TexCoord6,
	/// a_texcoord7
	TexCoord7,
	/// Number of entries in the enum
	Count,
}

/// Vertex attribute type enum.
#[repr(u32)]
#[derive(Clone, Copy, PartialEq, Debug)]
pub enum AttribType {
	/// Uint8
	Uint8,
	/// Uint10, availability depends on: `BGFX_CAPS_VERTEX_ATTRIB_UINT10`.
	Uint10,
	/// Int16
	Int16,
	/// Half, availability depends on: `BGFX_CAPS_VERTEX_ATTRIB_HALF`.
	Half,
	/// Float
	Float,
	/// Number of entries in the enum
	Count,
}

/// Texture format enum.
///
/// Notation:
///
///	   RGBA16S
///	   ^   ^ ^
///	   |   | +-- [ ]Unorm
///	   |   |	 [F]loat
///	   |   |	 [S]norm
///	   |   |	 [I]nt
///	   |   |	 [U]int
///	   |   +---- Number of bits per component
///	   +-------- Components
///
/// @attention Availability depends on Caps (see: formats).
#[repr(u32)]
#[derive(Clone, Copy, PartialEq, Debug)]
pub enum TextureFormat {
	/// DXT1 R5G6B5A1
	BC1,
	/// DXT3 R5G6B5A4
	BC2,
	/// DXT5 R5G6B5A8
	BC3,
	/// LATC1/ATI1 R8
	BC4,
	/// LATC2/ATI2 RG8
	BC5,
	/// BC6H RGB16F
	BC6H,
	/// BC7 RGB 4-7 bits per color channel, 0-8 bits alpha
	BC7,
	/// ETC1 RGB8
	ETC1,
	/// ETC2 RGB8
	ETC2,
	/// ETC2 RGBA8
	ETC2A,
	/// ETC2 RGB8A1
	ETC2A1,
	/// PVRTC1 RGB 2BPP
	PTC12,
	/// PVRTC1 RGB 4BPP
	PTC14,
	/// PVRTC1 RGBA 2BPP
	PTC12A,
	/// PVRTC1 RGBA 4BPP
	PTC14A,
	/// PVRTC2 RGBA 2BPP
	PTC22,
	/// PVRTC2 RGBA 4BPP
	PTC24,
	/// ATC RGB 4BPP
	ATC,
	/// ATCE RGBA 8 BPP explicit alpha
	ATCE,
	/// ATCI RGBA 8 BPP interpolated alpha
	ATCI,
	/// ASTC 4x4 8.0 BPP
	ASTC4x4,
	/// ASTC 5x4 6.40 BPP
	ASTC5x4,
	/// ASTC 5x5 5.12 BPP
	ASTC5x5,
	/// ASTC 6x5 4.27 BPP
	ASTC6x5,
	/// ASTC 6x6 3.56 BPP
	ASTC6x6,
	/// ASTC 8x5 3.20 BPP
	ASTC8x5,
	/// ASTC 8x6 2.67 BPP
	ASTC8x6,
	/// ASTC 8x8 2.00 BPP
	ASTC8x8,
	/// ASTC 10x5 2.56 BPP
	ASTC10x5,
	/// ASTC 10x6 2.13 BPP
	ASTC10x6,
	/// ASTC 10x8 1.60 BPP
	ASTC10x8,
	/// ASTC 10x10 1.28 BPP
	ASTC10x10,
	/// ASTC 12x10 1.07 BPP
	ASTC12x10,
	/// ASTC 12x12 0.89 BPP
	ASTC12x12,
	/// Compressed formats above.
	Unknown,
	R1,
	A8,
	R8,
	R8I,
	R8U,
	R8S,
	R16,
	R16I,
	R16U,
	R16F,
	R16S,
	R32I,
	R32U,
	R32F,
	RG8,
	RG8I,
	RG8U,
	RG8S,
	RG16,
	RG16I,
	RG16U,
	RG16F,
	RG16S,
	RG32I,
	RG32U,
	RG32F,
	RGB8,
	RGB8I,
	RGB8U,
	RGB8S,
	RGB9E5F,
	BGRA8,
	RGBA8,
	RGBA8I,
	RGBA8U,
	RGBA8S,
	RGBA16,
	RGBA16I,
	RGBA16U,
	RGBA16F,
	RGBA16S,
	RGBA32I,
	RGBA32U,
	RGBA32F,
	B5G6R5,
	R5G6B5,
	BGRA4,
	RGBA4,
	BGR5A1,
	RGB5A1,
	RGB10A2,
	RG11B10F,
	/// Depth formats below.
	UnknownDepth,
	D16,
	D24,
	D24S8,
	D32,
	D16F,
	D24F,
	D32F,
	D0S8,
	/// Number of entries in the enum
	Count,
}

/// Uniform type enum.
#[repr(u32)]
#[derive(Clone, Copy, PartialEq, Debug)]
pub enum UniformType {
	/// Sampler.
	Sampler,
	/// Reserved, do not use.
	End,
	/// 4 floats vector.
	Vec4,
	/// 3x3 matrix.
	Mat3,
	/// 4x4 matrix.
	Mat4,
	/// Number of entries in the enum
	Count,
}

/// Backbuffer ratio enum.
#[repr(u32)]
#[derive(Clone, Copy, PartialEq, Debug)]
pub enum BackbufferRatio {
	/// Equal to backbuffer.
	Equal,
	/// One half size of backbuffer.
	Half,
	/// One quarter size of backbuffer.
	Quarter,
	/// One eighth size of backbuffer.
	Eighth,
	/// One sixteenth size of backbuffer.
	Sixteenth,
	/// Double size of backbuffer.
	Double,
	/// Number of entries in the enum
	Count,
}

/// Occlusion query result.
#[repr(u32)]
#[derive(Clone, Copy, PartialEq, Debug)]
pub enum OcclusionQueryResult {
	/// Query failed test.
	Invisible,
	/// Query passed test.
	Visible,
	/// Query result is not available yet.
	NoResult,
	/// Number of entries in the enum
	Count,
}

/// Primitive topology.
#[repr(u32)]
#[derive(Clone, Copy, PartialEq, Debug)]
pub enum Topology {
	/// Triangle list.
	TriList,
	/// Triangle strip.
	TriStrip,
	/// Line list.
	LineList,
	/// Line strip.
	LineStrip,
	/// Point list.
	PointList,
	/// Number of entries in the enum
	Count,
}

/// Topology conversion function.
#[repr(u32)]
#[derive(Clone, Copy, PartialEq, Debug)]
pub enum TopologyConvert {
	/// Flip winding order of triangle list.
	TriListFlipWinding,
	/// Flip winding order of triangle strip.
	TriStripFlipWinding,
	/// Convert triangle list to line list.
	TriListToLineList,
	/// Convert triangle strip to triangle list.
	TriStripToTriList,
	/// Convert line strip to line list.
	LineStripToLineList,
	/// Number of entries in the enum
	Count,
}

/// Topology sort order.
#[repr(u32)]
#[derive(Clone, Copy, PartialEq, Debug)]
pub enum TopologySort {
	DirectionFrontToBackMin,
	DirectionFrontToBackAvg,
	DirectionFrontToBackMax,
	DirectionBackToFrontMin,
	DirectionBackToFrontAvg,
	DirectionBackToFrontMax,
	DistanceFrontToBackMin,
	DistanceFrontToBackAvg,
	DistanceFrontToBackMax,
	DistanceBackToFrontMin,
	DistanceBackToFrontAvg,
	DistanceBackToFrontMax,
	/// Number of entries in the enum
	Count,
}

/// View mode sets draw call sort order.
#[repr(u32)]
#[derive(Clone, Copy, PartialEq, Debug)]
pub enum ViewMode {
	/// Default sort order.
	Default,
	/// Sort in the same order in which submit calls were called.
	Sequential,
	/// Sort draw call depth in ascending order.
	DepthAscending,
	/// Sort draw call depth in descending order.
	DepthDescending,
	/// Number of entries in the enum
	Count,
}

/// Native window handle type.
#[repr(u32)]
#[derive(Clone, Copy, PartialEq, Debug)]
pub enum NativeWindowHandleType {
	/// Platform default handle type (X11 on Linux).
	Default,
	/// Wayland.
	Wayland,
	/// Number of entries in the enum
	Count,
}

/// Render frame enum.
#[repr(u32)]
#[derive(Clone, Copy, PartialEq, Debug)]
pub enum RenderFrame {
	/// Renderer context is not created yet.
	NoContext,
	/// Renderer context is created and rendering.
	Render,
	/// Renderer context wait for main thread signal timed out without rendering.
	Timeout,
	/// Renderer context is getting destroyed.
	Exiting,
	/// Number of entries in the enum
	Count,
}

bitflags! {
/// Color RGB/alpha/depth write. When it's not specified write will be disabled.
	pub struct StateWriteFlags : u64 {
		/// Enable R write.
		const R = bgfx_sys::BGFX_STATE_WRITE_R as _;
		/// Enable G write.
		const G = bgfx_sys::BGFX_STATE_WRITE_G as _;
		/// Enable B write.
		const B = bgfx_sys::BGFX_STATE_WRITE_B as _;
		/// Enable alpha write.
		const A = bgfx_sys::BGFX_STATE_WRITE_A as _;
		/// Enable depth write.
		const Z = bgfx_sys::BGFX_STATE_WRITE_Z as _;
		/// Enable RGB write.
		const RGB = bgfx_sys::BGFX_STATE_WRITE_RGB as _;
		/// Write all channels mask.
		const MASK = bgfx_sys::BGFX_STATE_WRITE_MASK as _;
	}
}

bitflags! {
/// Depth test state. When [StateFlags::DEPTH_] is not specified depth test will be disabled.
	pub struct StateDepthTestFlags : u64 {
		/// Enable depth test, less.
		const LESS = bgfx_sys::BGFX_STATE_DEPTH_TEST_LESS as _;
		/// Enable depth test, less or equal.
		const LEQUAL = bgfx_sys::BGFX_STATE_DEPTH_TEST_LEQUAL as _;
		/// Enable depth test, equal.
		const EQUAL = bgfx_sys::BGFX_STATE_DEPTH_TEST_EQUAL as _;
		/// Enable depth test, greater or equal.
		const GEQUAL = bgfx_sys::BGFX_STATE_DEPTH_TEST_GEQUAL as _;
		/// Enable depth test, greater.
		const GREATER = bgfx_sys::BGFX_STATE_DEPTH_TEST_GREATER as _;
		/// Enable depth test, not equal.
		const NOTEQUAL = bgfx_sys::BGFX_STATE_DEPTH_TEST_NOTEQUAL as _;
		/// Enable depth test, never.
		const NEVER = bgfx_sys::BGFX_STATE_DEPTH_TEST_NEVER as _;
		/// Enable depth test, always.
		const ALWAYS = bgfx_sys::BGFX_STATE_DEPTH_TEST_ALWAYS as _;
	}
}

bitflags! {
/// Use [state_blend_func] or [state_blend_func_separate]
/// helper macros.
	pub struct StateBlendFlags : u64 {
		/// 0, 0, 0, 0
		const ZERO = bgfx_sys::BGFX_STATE_BLEND_ZERO as _;
		/// 1, 1, 1, 1
		const ONE = bgfx_sys::BGFX_STATE_BLEND_ONE as _;
		/// Rs, Gs, Bs, As
		const SRC_COLOR = bgfx_sys::BGFX_STATE_BLEND_SRC_COLOR as _;
		/// 1-Rs, 1-Gs, 1-Bs, 1-As
		const INV_SRC_COLOR = bgfx_sys::BGFX_STATE_BLEND_INV_SRC_COLOR as _;
		/// As, As, As, As
		const SRC_ALPHA = bgfx_sys::BGFX_STATE_BLEND_SRC_ALPHA as _;
		/// 1-As, 1-As, 1-As, 1-As
		const INV_SRC_ALPHA = bgfx_sys::BGFX_STATE_BLEND_INV_SRC_ALPHA as _;
		/// Ad, Ad, Ad, Ad
		const DST_ALPHA = bgfx_sys::BGFX_STATE_BLEND_DST_ALPHA as _;
		/// 1-Ad, 1-Ad, 1-Ad ,1-Ad
		const INV_DST_ALPHA = bgfx_sys::BGFX_STATE_BLEND_INV_DST_ALPHA as _;
		/// Rd, Gd, Bd, Ad
		const DST_COLOR = bgfx_sys::BGFX_STATE_BLEND_DST_COLOR as _;
		/// 1-Rd, 1-Gd, 1-Bd, 1-Ad
		const INV_DST_COLOR = bgfx_sys::BGFX_STATE_BLEND_INV_DST_COLOR as _;
		/// f, f, f, 1; f = min(As, 1-Ad)
		const SRC_ALPHA_SAT = bgfx_sys::BGFX_STATE_BLEND_SRC_ALPHA_SAT as _;
		/// Blend factor
		const FACTOR = bgfx_sys::BGFX_STATE_BLEND_FACTOR as _;
		/// 1-Blend factor
		const INV_FACTOR = bgfx_sys::BGFX_STATE_BLEND_INV_FACTOR as _;
	}
}

bitflags! {
/// Use [state_blend_equation] or [state_blend_equation_separate]
/// helper macros.
	pub struct StateBlendEquationFlags : u64 {
		/// Blend add: src + dst.
		const ADD = bgfx_sys::BGFX_STATE_BLEND_EQUATION_ADD as _;
		/// Blend subtract: src - dst.
		const SUB = bgfx_sys::BGFX_STATE_BLEND_EQUATION_SUB as _;
		/// Blend reverse subtract: dst - src.
		const REVSUB = bgfx_sys::BGFX_STATE_BLEND_EQUATION_REVSUB as _;
		/// Blend min: min(src, dst).
		const MIN = bgfx_sys::BGFX_STATE_BLEND_EQUATION_MIN as _;
		/// Blend max: max(src, dst).
		const MAX = bgfx_sys::BGFX_STATE_BLEND_EQUATION_MAX as _;
	}
}

bitflags! {
/// Cull state. When [StateCullFlags] is not specified culling will be disabled.
	pub struct StateCullFlags : u64 {
		/// Cull clockwise triangles.
		const CW = bgfx_sys::BGFX_STATE_CULL_CW as _;
		/// Cull counter-clockwise triangles.
		const CCW = bgfx_sys::BGFX_STATE_CULL_CCW as _;
	}
}

bitflags! {
	pub struct StatePtFlags : u64 {
		/// Tristrip.
		const TRISTRIP = bgfx_sys::BGFX_STATE_PT_TRISTRIP as _;
		/// Lines.
		const LINES = bgfx_sys::BGFX_STATE_PT_LINES as _;
		/// Line strip.
		const LINESTRIP = bgfx_sys::BGFX_STATE_PT_LINESTRIP as _;
		/// Points.
		const POINTS = bgfx_sys::BGFX_STATE_PT_POINTS as _;
	}
}

bitflags! {
/// Enable MSAA write when writing into MSAA frame buffer.
/// This flag is ignored when not writing into MSAA frame buffer.
	pub struct StateFlags : u64 {
		/// Enable MSAA rasterization.
		const MSAA = bgfx_sys::BGFX_STATE_MSAA as _;
		/// Enable line AA rasterization.
		const LINEAA = bgfx_sys::BGFX_STATE_LINEAA as _;
		/// Enable conservative rasterization.
		const CONSERVATIVE_RASTER = bgfx_sys::BGFX_STATE_CONSERVATIVE_RASTER as _;
		/// No state.
		const NONE = bgfx_sys::BGFX_STATE_NONE as _;
		/// Front counter-clockwise (default is clockwise).
		const FRONT_CCW = bgfx_sys::BGFX_STATE_FRONT_CCW as _;
		/// Enable blend independent.
		const BLEND_INDEPENDENT = bgfx_sys::BGFX_STATE_BLEND_INDEPENDENT as _;
		/// Enable alpha to coverage.
		const BLEND_ALPHA_TO_COVERAGE = bgfx_sys::BGFX_STATE_BLEND_ALPHA_TO_COVERAGE as _;
		/// Default state is write to RGB, alpha, and depth with depth test less enabled, with clockwise
		/// culling and MSAA (when writing into MSAA frame buffer, otherwise this flag is ignored).
		const DEFAULT = bgfx_sys::BGFX_STATE_DEFAULT as _;
	}
}

bitflags! {
	pub struct StencilFlags : u32 {
		const NONE = bgfx_sys::BGFX_STENCIL_NONE as _;
		const MASK = bgfx_sys::BGFX_STENCIL_MASK as _;
		const DEFAULT = bgfx_sys::BGFX_STENCIL_DEFAULT as _;
	}
}

bitflags! {
	pub struct StencilTestFlags : u32 {
		/// Enable stencil test, less.
		const LESS = bgfx_sys::BGFX_STENCIL_TEST_LESS as _;
		/// Enable stencil test, less or equal.
		const LEQUAL = bgfx_sys::BGFX_STENCIL_TEST_LEQUAL as _;
		/// Enable stencil test, equal.
		const EQUAL = bgfx_sys::BGFX_STENCIL_TEST_EQUAL as _;
		/// Enable stencil test, greater or equal.
		const GEQUAL = bgfx_sys::BGFX_STENCIL_TEST_GEQUAL as _;
		/// Enable stencil test, greater.
		const GREATER = bgfx_sys::BGFX_STENCIL_TEST_GREATER as _;
		/// Enable stencil test, not equal.
		const NOTEQUAL = bgfx_sys::BGFX_STENCIL_TEST_NOTEQUAL as _;
		/// Enable stencil test, never.
		const NEVER = bgfx_sys::BGFX_STENCIL_TEST_NEVER as _;
		/// Enable stencil test, always.
		const ALWAYS = bgfx_sys::BGFX_STENCIL_TEST_ALWAYS as _;
	}
}

bitflags! {
	pub struct StencilOpFailSFlags : u32 {
		/// Zero.
		const ZERO = bgfx_sys::BGFX_STENCIL_OP_FAIL_S_ZERO as _;
		/// Keep.
		const KEEP = bgfx_sys::BGFX_STENCIL_OP_FAIL_S_KEEP as _;
		/// Replace.
		const REPLACE = bgfx_sys::BGFX_STENCIL_OP_FAIL_S_REPLACE as _;
		/// Increment and wrap.
		const INCR = bgfx_sys::BGFX_STENCIL_OP_FAIL_S_INCR as _;
		/// Increment and clamp.
		const INCRSAT = bgfx_sys::BGFX_STENCIL_OP_FAIL_S_INCRSAT as _;
		/// Decrement and wrap.
		const DECR = bgfx_sys::BGFX_STENCIL_OP_FAIL_S_DECR as _;
		/// Decrement and clamp.
		const DECRSAT = bgfx_sys::BGFX_STENCIL_OP_FAIL_S_DECRSAT as _;
		/// Invert.
		const INVERT = bgfx_sys::BGFX_STENCIL_OP_FAIL_S_INVERT as _;
	}
}

bitflags! {
	pub struct StencilOpFailZFlags : u32 {
		/// Zero.
		const ZERO = bgfx_sys::BGFX_STENCIL_OP_FAIL_Z_ZERO as _;
		/// Keep.
		const KEEP = bgfx_sys::BGFX_STENCIL_OP_FAIL_Z_KEEP as _;
		/// Replace.
		const REPLACE = bgfx_sys::BGFX_STENCIL_OP_FAIL_Z_REPLACE as _;
		/// Increment and wrap.
		const INCR = bgfx_sys::BGFX_STENCIL_OP_FAIL_Z_INCR as _;
		/// Increment and clamp.
		const INCRSAT = bgfx_sys::BGFX_STENCIL_OP_FAIL_Z_INCRSAT as _;
		/// Decrement and wrap.
		const DECR = bgfx_sys::BGFX_STENCIL_OP_FAIL_Z_DECR as _;
		/// Decrement and clamp.
		const DECRSAT = bgfx_sys::BGFX_STENCIL_OP_FAIL_Z_DECRSAT as _;
		/// Invert.
		const INVERT = bgfx_sys::BGFX_STENCIL_OP_FAIL_Z_INVERT as _;
	}
}

bitflags! {
	pub struct StencilOpPassZFlags : u32 {
		/// Zero.
		const ZERO = bgfx_sys::BGFX_STENCIL_OP_PASS_Z_ZERO as _;
		/// Keep.
		const KEEP = bgfx_sys::BGFX_STENCIL_OP_PASS_Z_KEEP as _;
		/// Replace.
		const REPLACE = bgfx_sys::BGFX_STENCIL_OP_PASS_Z_REPLACE as _;
		/// Increment and wrap.
		const INCR = bgfx_sys::BGFX_STENCIL_OP_PASS_Z_INCR as _;
		/// Increment and clamp.
		const INCRSAT = bgfx_sys::BGFX_STENCIL_OP_PASS_Z_INCRSAT as _;
		/// Decrement and wrap.
		const DECR = bgfx_sys::BGFX_STENCIL_OP_PASS_Z_DECR as _;
		/// Decrement and clamp.
		const DECRSAT = bgfx_sys::BGFX_STENCIL_OP_PASS_Z_DECRSAT as _;
		/// Invert.
		const INVERT = bgfx_sys::BGFX_STENCIL_OP_PASS_Z_INVERT as _;
	}
}

bitflags! {
	pub struct ClearFlags : u16 {
		/// No clear flags.
		const NONE = bgfx_sys::BGFX_CLEAR_NONE as _;
		/// Clear color.
		const COLOR = bgfx_sys::BGFX_CLEAR_COLOR as _;
		/// Clear depth.
		const DEPTH = bgfx_sys::BGFX_CLEAR_DEPTH as _;
		/// Clear stencil.
		const STENCIL = bgfx_sys::BGFX_CLEAR_STENCIL as _;
		/// Discard frame buffer attachment 0.
		const DISCARD_COLOR_0 = bgfx_sys::BGFX_CLEAR_DISCARD_COLOR_0 as _;
		/// Discard frame buffer attachment 1.
		const DISCARD_COLOR_1 = bgfx_sys::BGFX_CLEAR_DISCARD_COLOR_1 as _;
		/// Discard frame buffer attachment 2.
		const DISCARD_COLOR_2 = bgfx_sys::BGFX_CLEAR_DISCARD_COLOR_2 as _;
		/// Discard frame buffer attachment 3.
		const DISCARD_COLOR_3 = bgfx_sys::BGFX_CLEAR_DISCARD_COLOR_3 as _;
		/// Discard frame buffer attachment 4.
		const DISCARD_COLOR_4 = bgfx_sys::BGFX_CLEAR_DISCARD_COLOR_4 as _;
		/// Discard frame buffer attachment 5.
		const DISCARD_COLOR_5 = bgfx_sys::BGFX_CLEAR_DISCARD_COLOR_5 as _;
		/// Discard frame buffer attachment 6.
		const DISCARD_COLOR_6 = bgfx_sys::BGFX_CLEAR_DISCARD_COLOR_6 as _;
		/// Discard frame buffer attachment 7.
		const DISCARD_COLOR_7 = bgfx_sys::BGFX_CLEAR_DISCARD_COLOR_7 as _;
		/// Discard frame buffer depth attachment.
		const DISCARD_DEPTH = bgfx_sys::BGFX_CLEAR_DISCARD_DEPTH as _;
		/// Discard frame buffer stencil attachment.
		const DISCARD_STENCIL = bgfx_sys::BGFX_CLEAR_DISCARD_STENCIL as _;
		const DISCARD_COLOR_MASK = bgfx_sys::BGFX_CLEAR_DISCARD_COLOR_MASK as _;
		const DISCARD_MASK = bgfx_sys::BGFX_CLEAR_DISCARD_MASK as _;
	}
}

bitflags! {
/// Rendering state discard. When state is preserved in submit, rendering states can be discarded
/// on a finer grain.
	pub struct DiscardFlags : u8 {
		/// Preserve everything.
		const NONE = bgfx_sys::BGFX_DISCARD_NONE as _;
		/// Discard texture sampler and buffer bindings.
		const BINDINGS = bgfx_sys::BGFX_DISCARD_BINDINGS as _;
		/// Discard index buffer.
		const INDEX_BUFFER = bgfx_sys::BGFX_DISCARD_INDEX_BUFFER as _;
		/// Discard instance data.
		const INSTANCE_DATA = bgfx_sys::BGFX_DISCARD_INSTANCE_DATA as _;
		/// Discard state and uniform bindings.
		const STATE = bgfx_sys::BGFX_DISCARD_STATE as _;
		/// Discard transform.
		const TRANSFORM = bgfx_sys::BGFX_DISCARD_TRANSFORM as _;
		/// Discard vertex streams.
		const VERTEX_STREAMS = bgfx_sys::BGFX_DISCARD_VERTEX_STREAMS as _;
		/// Discard all states.
		const ALL = bgfx_sys::BGFX_DISCARD_ALL as _;
	}
}

bitflags! {
	pub struct DebugFlags : u32 {
		/// No debug.
		const NONE = bgfx_sys::BGFX_DEBUG_NONE as _;
		/// Enable wireframe for all primitives.
		const WIREFRAME = bgfx_sys::BGFX_DEBUG_WIREFRAME as _;
		/// Enable infinitely fast hardware test. No draw calls will be submitted to driver.
		/// It's useful when profiling to quickly assess bottleneck between CPU and GPU.
		const IFH = bgfx_sys::BGFX_DEBUG_IFH as _;
		/// Enable statistics display.
		const STATS = bgfx_sys::BGFX_DEBUG_STATS as _;
		/// Enable debug text display.
		const TEXT = bgfx_sys::BGFX_DEBUG_TEXT as _;
		/// Enable profiler. This causes per-view statistics to be collected, available through `bgfx::Stats::ViewStats`. This is unrelated to the profiler functions in `bgfx::CallbackI`.
		const PROFILER = bgfx_sys::BGFX_DEBUG_PROFILER as _;
	}
}

bitflags! {
	pub struct BufferComputeFormatFlags : u16 {
		/// 1 8-bit value
		const F8_X_1 = bgfx_sys::BGFX_BUFFER_COMPUTE_FORMAT_8X1 as _;
		/// 2 8-bit values
		const F8_X_2 = bgfx_sys::BGFX_BUFFER_COMPUTE_FORMAT_8X2 as _;
		/// 4 8-bit values
		const F8_X_4 = bgfx_sys::BGFX_BUFFER_COMPUTE_FORMAT_8X4 as _;
		/// 1 16-bit value
		const F16_X_1 = bgfx_sys::BGFX_BUFFER_COMPUTE_FORMAT_16X1 as _;
		/// 2 F16-bit values
		const F16_X_2 = bgfx_sys::BGFX_BUFFER_COMPUTE_FORMAT_16X2 as _;
		/// 4 16-bit values
		const F16_X_4 = bgfx_sys::BGFX_BUFFER_COMPUTE_FORMAT_16X4 as _;
		/// 1 32-bit value
		const F32_X_1 = bgfx_sys::BGFX_BUFFER_COMPUTE_FORMAT_32X1 as _;
		/// 2 32-bit values
		const F32_X_2 = bgfx_sys::BGFX_BUFFER_COMPUTE_FORMAT_32X2 as _;
		/// 4 32-bit values
		const F32_X_4 = bgfx_sys::BGFX_BUFFER_COMPUTE_FORMAT_32X4 as _;
	}
}

bitflags! {
	pub struct BufferComputeTypeFlags : u16 {
		/// Type `int`.
		const INT = bgfx_sys::BGFX_BUFFER_COMPUTE_TYPE_INT as _;
		/// Type `uint`.
		const UINT = bgfx_sys::BGFX_BUFFER_COMPUTE_TYPE_UINT as _;
		/// Type `float`.
		const FLOAT = bgfx_sys::BGFX_BUFFER_COMPUTE_TYPE_FLOAT as _;
	}
}

bitflags! {
	pub struct BufferFlags : u16 {
		const NONE = bgfx_sys::BGFX_BUFFER_NONE as _;
		/// Buffer will be read by shader.
		const COMPUTE_READ = bgfx_sys::BGFX_BUFFER_COMPUTE_READ as _;
		/// Buffer will be used for writing.
		const COMPUTE_WRITE = bgfx_sys::BGFX_BUFFER_COMPUTE_WRITE as _;
		/// Buffer will be used for storing draw indirect commands.
		const DRAW_INDIRECT = bgfx_sys::BGFX_BUFFER_DRAW_INDIRECT as _;
		/// Allow dynamic index/vertex buffer resize during update.
		const ALLOW_RESIZE = bgfx_sys::BGFX_BUFFER_ALLOW_RESIZE as _;
		/// Index buffer contains 32-bit indices.
		const INDEX_32 = bgfx_sys::BGFX_BUFFER_INDEX32 as _;
		const COMPUTE_READ_WRITE = bgfx_sys::BGFX_BUFFER_COMPUTE_READ_WRITE as _;
	}
}

bitflags! {
	pub struct TextureFlags : u64 {
		const NONE = bgfx_sys::BGFX_TEXTURE_NONE as _;
		/// Texture will be used for MSAA sampling.
		const MSAA_SAMPLE = bgfx_sys::BGFX_TEXTURE_MSAA_SAMPLE as _;
		/// Render target no MSAA.
		const RT = bgfx_sys::BGFX_TEXTURE_RT as _;
		/// Texture will be used for compute write.
		const COMPUTE_WRITE = bgfx_sys::BGFX_TEXTURE_COMPUTE_WRITE as _;
		/// Sample texture as sRGB.
		const SRGB = bgfx_sys::BGFX_TEXTURE_SRGB as _;
		/// Texture will be used as blit destination.
		const BLIT_DST = bgfx_sys::BGFX_TEXTURE_BLIT_DST as _;
		/// Texture will be used for read back from GPU.
		const READ_BACK = bgfx_sys::BGFX_TEXTURE_READ_BACK as _;
	}
}

bitflags! {
	pub struct TextureRtMsaaFlags : u64 {
		/// Render target MSAAx2 mode.
		const X_2 = bgfx_sys::BGFX_TEXTURE_RT_MSAA_X2 as _;
		/// Render target MSAAx4 mode.
		const X_4 = bgfx_sys::BGFX_TEXTURE_RT_MSAA_X4 as _;
		/// Render target MSAAx8 mode.
		const X_8 = bgfx_sys::BGFX_TEXTURE_RT_MSAA_X8 as _;
		/// Render target MSAAx16 mode.
		const X_16 = bgfx_sys::BGFX_TEXTURE_RT_MSAA_X16 as _;
	}
}

bitflags! {
	pub struct TextureRtFlags : u64 {
		/// Render target will be used for writing
		const WRITE_ONLY = bgfx_sys::BGFX_TEXTURE_RT_WRITE_ONLY as _;
	}
}

bitflags! {
/// Sampler flags.
	pub struct SamplerUFlags : u32 {
		/// Wrap U mode: Mirror
		const MIRROR = bgfx_sys::BGFX_SAMPLER_U_MIRROR as _;
		/// Wrap U mode: Clamp
		const CLAMP = bgfx_sys::BGFX_SAMPLER_U_CLAMP as _;
		/// Wrap U mode: Border
		const BORDER = bgfx_sys::BGFX_SAMPLER_U_BORDER as _;
	}
}

bitflags! {
	pub struct SamplerVFlags : u32 {
		/// Wrap V mode: Mirror
		const MIRROR = bgfx_sys::BGFX_SAMPLER_V_MIRROR as _;
		/// Wrap V mode: Clamp
		const CLAMP = bgfx_sys::BGFX_SAMPLER_V_CLAMP as _;
		/// Wrap V mode: Border
		const BORDER = bgfx_sys::BGFX_SAMPLER_V_BORDER as _;
	}
}

bitflags! {
	pub struct SamplerWFlags : u32 {
		/// Wrap W mode: Mirror
		const MIRROR = bgfx_sys::BGFX_SAMPLER_W_MIRROR as _;
		/// Wrap W mode: Clamp
		const CLAMP = bgfx_sys::BGFX_SAMPLER_W_CLAMP as _;
		/// Wrap W mode: Border
		const BORDER = bgfx_sys::BGFX_SAMPLER_W_BORDER as _;
	}
}

bitflags! {
	pub struct SamplerMinFlags : u32 {
		/// Min sampling mode: Point
		const POINT = bgfx_sys::BGFX_SAMPLER_MIN_POINT as _;
		/// Min sampling mode: Anisotropic
		const ANISOTROPIC = bgfx_sys::BGFX_SAMPLER_MIN_ANISOTROPIC as _;
	}
}

bitflags! {
	pub struct SamplerMagFlags : u32 {
		/// Mag sampling mode: Point
		const POINT = bgfx_sys::BGFX_SAMPLER_MAG_POINT as _;
		/// Mag sampling mode: Anisotropic
		const ANISOTROPIC = bgfx_sys::BGFX_SAMPLER_MAG_ANISOTROPIC as _;
	}
}

bitflags! {
	pub struct SamplerMipFlags : u32 {
		/// Mip sampling mode: Point
		const POINT = bgfx_sys::BGFX_SAMPLER_MIP_POINT as _;
	}
}

bitflags! {
	pub struct SamplerCompareFlags : u32 {
		/// Compare when sampling depth texture: less.
		const LESS = bgfx_sys::BGFX_SAMPLER_COMPARE_LESS as _;
		/// Compare when sampling depth texture: less or equal.
		const LEQUAL = bgfx_sys::BGFX_SAMPLER_COMPARE_LEQUAL as _;
		/// Compare when sampling depth texture: equal.
		const EQUAL = bgfx_sys::BGFX_SAMPLER_COMPARE_EQUAL as _;
		/// Compare when sampling depth texture: greater or equal.
		const GEQUAL = bgfx_sys::BGFX_SAMPLER_COMPARE_GEQUAL as _;
		/// Compare when sampling depth texture: greater.
		const GREATER = bgfx_sys::BGFX_SAMPLER_COMPARE_GREATER as _;
		/// Compare when sampling depth texture: not equal.
		const NOTEQUAL = bgfx_sys::BGFX_SAMPLER_COMPARE_NOTEQUAL as _;
		/// Compare when sampling depth texture: never.
		const NEVER = bgfx_sys::BGFX_SAMPLER_COMPARE_NEVER as _;
		/// Compare when sampling depth texture: always.
		const ALWAYS = bgfx_sys::BGFX_SAMPLER_COMPARE_ALWAYS as _;
	}
}

bitflags! {
	pub struct SamplerFlags : u32 {
		const NONE = bgfx_sys::BGFX_SAMPLER_NONE as _;
		/// Sample stencil instead of depth.
		const SAMPLE_STENCIL = bgfx_sys::BGFX_SAMPLER_SAMPLE_STENCIL as _;
		const POINT = bgfx_sys::BGFX_SAMPLER_POINT as _;
		const UVW_MIRROR = bgfx_sys::BGFX_SAMPLER_UVW_MIRROR as _;
		const UVW_CLAMP = bgfx_sys::BGFX_SAMPLER_UVW_CLAMP as _;
		const UVW_BORDER = bgfx_sys::BGFX_SAMPLER_UVW_BORDER as _;
		const BITS_MASK = bgfx_sys::BGFX_SAMPLER_BITS_MASK as _;
	}
}

bitflags! {
	pub struct ResetMsaaFlags : u32 {
		/// Enable 2x MSAA.
		const X_2 = bgfx_sys::BGFX_RESET_MSAA_X2 as _;
		/// Enable 4x MSAA.
		const X_4 = bgfx_sys::BGFX_RESET_MSAA_X4 as _;
		/// Enable 8x MSAA.
		const X_8 = bgfx_sys::BGFX_RESET_MSAA_X8 as _;
		/// Enable 16x MSAA.
		const X_16 = bgfx_sys::BGFX_RESET_MSAA_X16 as _;
	}
}

bitflags! {
	pub struct ResetFlags : u32 {
		/// No reset flags.
		const NONE = bgfx_sys::BGFX_RESET_NONE as _;
		/// Not supported yet.
		const FULLSCREEN = bgfx_sys::BGFX_RESET_FULLSCREEN as _;
		/// Enable V-Sync.
		const VSYNC = bgfx_sys::BGFX_RESET_VSYNC as _;
		/// Turn on/off max anisotropy.
		const MAXANISOTROPY = bgfx_sys::BGFX_RESET_MAXANISOTROPY as _;
		/// Begin screen capture.
		const CAPTURE = bgfx_sys::BGFX_RESET_CAPTURE as _;
		/// Flush rendering after submitting to GPU.
		const FLUSH_AFTER_RENDER = bgfx_sys::BGFX_RESET_FLUSH_AFTER_RENDER as _;
		/// This flag specifies where flip occurs. Default behaviour is that flip occurs
		/// before rendering new frame. This flag only has effect when `BGFX_CONFIG_MULTITHREADED=0`.
		const FLIP_AFTER_RENDER = bgfx_sys::BGFX_RESET_FLIP_AFTER_RENDER as _;
		/// Enable sRGB backbuffer.
		const SRGB_BACKBUFFER = bgfx_sys::BGFX_RESET_SRGB_BACKBUFFER as _;
		/// Enable HDR10 rendering.
		const HDR_10 = bgfx_sys::BGFX_RESET_HDR10 as _;
		/// Enable HiDPI rendering.
		const HIDPI = bgfx_sys::BGFX_RESET_HIDPI as _;
		/// Enable depth clamp.
		const DEPTH_CLAMP = bgfx_sys::BGFX_RESET_DEPTH_CLAMP as _;
		/// Suspend rendering.
		const SUSPEND = bgfx_sys::BGFX_RESET_SUSPEND as _;
		/// Transparent backbuffer. Availability depends on: [CapsFlags::TRANSPARENT_BACKBUFFER].
		const TRANSPARENT_BACKBUFFER = bgfx_sys::BGFX_RESET_TRANSPARENT_BACKBUFFER as _;
	}
}

bitflags! {
	pub struct CapsFlags : u64 {
		/// Alpha to coverage is supported.
		const ALPHA_TO_COVERAGE = bgfx_sys::BGFX_CAPS_ALPHA_TO_COVERAGE as _;
		/// Blend independent is supported.
		const BLEND_INDEPENDENT = bgfx_sys::BGFX_CAPS_BLEND_INDEPENDENT as _;
		/// Compute shaders are supported.
		const COMPUTE = bgfx_sys::BGFX_CAPS_COMPUTE as _;
		/// Conservative rasterization is supported.
		const CONSERVATIVE_RASTER = bgfx_sys::BGFX_CAPS_CONSERVATIVE_RASTER as _;
		/// Draw indirect is supported.
		const DRAW_INDIRECT = bgfx_sys::BGFX_CAPS_DRAW_INDIRECT as _;
		/// Draw indirect with indirect count is supported.
		const DRAW_INDIRECT_COUNT = bgfx_sys::BGFX_CAPS_DRAW_INDIRECT_COUNT as _;
		/// Fragment depth is available in fragment shader.
		const FRAGMENT_DEPTH = bgfx_sys::BGFX_CAPS_FRAGMENT_DEPTH as _;
		/// Fragment ordering is available in fragment shader.
		const FRAGMENT_ORDERING = bgfx_sys::BGFX_CAPS_FRAGMENT_ORDERING as _;
		/// Graphics debugger is present.
		const GRAPHICS_DEBUGGER = bgfx_sys::BGFX_CAPS_GRAPHICS_DEBUGGER as _;
		/// HDR10 rendering is supported.
		const HDR_10 = bgfx_sys::BGFX_CAPS_HDR10 as _;
		/// HiDPI rendering is supported.
		const HIDPI = bgfx_sys::BGFX_CAPS_HIDPI as _;
		/// Image Read/Write is supported.
		const IMAGE_RW = bgfx_sys::BGFX_CAPS_IMAGE_RW as _;
		/// 32-bit indices are supported.
		const INDEX_32 = bgfx_sys::BGFX_CAPS_INDEX32 as _;
		/// Instancing is supported.
		const INSTANCING = bgfx_sys::BGFX_CAPS_INSTANCING as _;
		/// Occlusion query is supported.
		const OCCLUSION_QUERY = bgfx_sys::BGFX_CAPS_OCCLUSION_QUERY as _;
		/// PrimitiveID is available in fragment shader.
		const PRIMITIVE_ID = bgfx_sys::BGFX_CAPS_PRIMITIVE_ID as _;
		/// Renderer is on separate thread.
		const RENDERER_MULTITHREADED = bgfx_sys::BGFX_CAPS_RENDERER_MULTITHREADED as _;
		/// Multiple windows are supported.
		const SWAP_CHAIN = bgfx_sys::BGFX_CAPS_SWAP_CHAIN as _;
		/// Texture blit is supported.
		const TEXTURE_BLIT = bgfx_sys::BGFX_CAPS_TEXTURE_BLIT as _;
		/// Texture compare less equal mode is supported.
		const TEXTURE_COMPARE_LEQUAL = bgfx_sys::BGFX_CAPS_TEXTURE_COMPARE_LEQUAL as _;
		const TEXTURE_COMPARE_RESERVED = bgfx_sys::BGFX_CAPS_TEXTURE_COMPARE_RESERVED as _;
		/// Cubemap texture array is supported.
		const TEXTURE_CUBE_ARRAY = bgfx_sys::BGFX_CAPS_TEXTURE_CUBE_ARRAY as _;
		/// CPU direct access to GPU texture memory.
		const TEXTURE_DIRECT_ACCESS = bgfx_sys::BGFX_CAPS_TEXTURE_DIRECT_ACCESS as _;
		/// Read-back texture is supported.
		const TEXTURE_READ_BACK = bgfx_sys::BGFX_CAPS_TEXTURE_READ_BACK as _;
		/// 2D texture array is supported.
		const TEXTURE_2_D_ARRAY = bgfx_sys::BGFX_CAPS_TEXTURE_2D_ARRAY as _;
		/// 3D textures are supported.
		const TEXTURE_3_D = bgfx_sys::BGFX_CAPS_TEXTURE_3D as _;
		/// Transparent back buffer supported.
		const TRANSPARENT_BACKBUFFER = bgfx_sys::BGFX_CAPS_TRANSPARENT_BACKBUFFER as _;
		/// Vertex attribute half-float is supported.
		const VERTEX_ATTRIB_HALF = bgfx_sys::BGFX_CAPS_VERTEX_ATTRIB_HALF as _;
		/// Vertex attribute 10_10_10_2 is supported.
		const VERTEX_ATTRIB_UINT_10 = bgfx_sys::BGFX_CAPS_VERTEX_ATTRIB_UINT10 as _;
		/// Rendering with VertexID only is supported.
		const VERTEX_ID = bgfx_sys::BGFX_CAPS_VERTEX_ID as _;
		/// Viewport layer is available in vertex shader.
		const VIEWPORT_LAYER_ARRAY = bgfx_sys::BGFX_CAPS_VIEWPORT_LAYER_ARRAY as _;
		/// All texture compare modes are supported.
		const TEXTURE_COMPARE_ALL = bgfx_sys::BGFX_CAPS_TEXTURE_COMPARE_ALL as _;
	}
}

bitflags! {
	pub struct CapsFormatFlags : u32 {
		/// Texture format is not supported.
		const TEXTURE_NONE = bgfx_sys::BGFX_CAPS_FORMAT_TEXTURE_NONE as _;
		/// Texture format is supported.
		const TEXTURE_2_D = bgfx_sys::BGFX_CAPS_FORMAT_TEXTURE_2D as _;
		/// Texture as sRGB format is supported.
		const TEXTURE_2_D_SRGB = bgfx_sys::BGFX_CAPS_FORMAT_TEXTURE_2D_SRGB as _;
		/// Texture format is emulated.
		const TEXTURE_2_D_EMULATED = bgfx_sys::BGFX_CAPS_FORMAT_TEXTURE_2D_EMULATED as _;
		/// Texture format is supported.
		const TEXTURE_3_D = bgfx_sys::BGFX_CAPS_FORMAT_TEXTURE_3D as _;
		/// Texture as sRGB format is supported.
		const TEXTURE_3_D_SRGB = bgfx_sys::BGFX_CAPS_FORMAT_TEXTURE_3D_SRGB as _;
		/// Texture format is emulated.
		const TEXTURE_3_D_EMULATED = bgfx_sys::BGFX_CAPS_FORMAT_TEXTURE_3D_EMULATED as _;
		/// Texture format is supported.
		const TEXTURE_CUBE = bgfx_sys::BGFX_CAPS_FORMAT_TEXTURE_CUBE as _;
		/// Texture as sRGB format is supported.
		const TEXTURE_CUBE_SRGB = bgfx_sys::BGFX_CAPS_FORMAT_TEXTURE_CUBE_SRGB as _;
		/// Texture format is emulated.
		const TEXTURE_CUBE_EMULATED = bgfx_sys::BGFX_CAPS_FORMAT_TEXTURE_CUBE_EMULATED as _;
		/// Texture format can be used from vertex shader.
		const TEXTURE_VERTEX = bgfx_sys::BGFX_CAPS_FORMAT_TEXTURE_VERTEX as _;
		/// Texture format can be used as image and read from.
		const TEXTURE_IMAGE_READ = bgfx_sys::BGFX_CAPS_FORMAT_TEXTURE_IMAGE_READ as _;
		/// Texture format can be used as image and written to.
		const TEXTURE_IMAGE_WRITE = bgfx_sys::BGFX_CAPS_FORMAT_TEXTURE_IMAGE_WRITE as _;
		/// Texture format can be used as frame buffer.
		const TEXTURE_FRAMEBUFFER = bgfx_sys::BGFX_CAPS_FORMAT_TEXTURE_FRAMEBUFFER as _;
		/// Texture format can be used as MSAA frame buffer.
		const TEXTURE_FRAMEBUFFER_MSAA = bgfx_sys::BGFX_CAPS_FORMAT_TEXTURE_FRAMEBUFFER_MSAA as _;
		/// Texture can be sampled as MSAA.
		const TEXTURE_MSAA = bgfx_sys::BGFX_CAPS_FORMAT_TEXTURE_MSAA as _;
		/// Texture format supports auto-generated mips.
		const TEXTURE_MIP_AUTOGEN = bgfx_sys::BGFX_CAPS_FORMAT_TEXTURE_MIP_AUTOGEN as _;
	}
}

bitflags! {
	pub struct ResolveFlags : u8 {
		/// No resolve flags.
		const NONE = bgfx_sys::BGFX_RESOLVE_NONE as _;
		/// Auto-generate mip maps on resolve.
		const AUTO_GEN_MIPS = bgfx_sys::BGFX_RESOLVE_AUTO_GEN_MIPS as _;
	}
}

bitflags! {
	pub struct PciIdFlags : u16 {
		/// Autoselect adapter.
		const NONE = bgfx_sys::BGFX_PCI_ID_NONE as _;
		/// Software rasterizer.
		const SOFTWARE_RASTERIZER = bgfx_sys::BGFX_PCI_ID_SOFTWARE_RASTERIZER as _;
		/// AMD adapter.
		const AMD = bgfx_sys::BGFX_PCI_ID_AMD as _;
		/// Apple adapter.
		const APPLE = bgfx_sys::BGFX_PCI_ID_APPLE as _;
		/// Intel adapter.
		const INTEL = bgfx_sys::BGFX_PCI_ID_INTEL as _;
		/// nVidia adapter.
		const NVIDIA = bgfx_sys::BGFX_PCI_ID_NVIDIA as _;
		/// Microsoft adapter.
		const MICROSOFT = bgfx_sys::BGFX_PCI_ID_MICROSOFT as _;
		/// ARM adapter.
		const ARM = bgfx_sys::BGFX_PCI_ID_ARM as _;
	}
}

bitflags! {
	pub struct CubeMapFlags : u8 {
		/// Cubemap +x.
		const POSITIVE_X = bgfx_sys::BGFX_CUBE_MAP_POSITIVE_X as _;
		/// Cubemap -x.
		const NEGATIVE_X = bgfx_sys::BGFX_CUBE_MAP_NEGATIVE_X as _;
		/// Cubemap +y.
		const POSITIVE_Y = bgfx_sys::BGFX_CUBE_MAP_POSITIVE_Y as _;
		/// Cubemap -y.
		const NEGATIVE_Y = bgfx_sys::BGFX_CUBE_MAP_NEGATIVE_Y as _;
		/// Cubemap +z.
		const POSITIVE_Z = bgfx_sys::BGFX_CUBE_MAP_POSITIVE_Z as _;
		/// Cubemap -z.
		const NEGATIVE_Z = bgfx_sys::BGFX_CUBE_MAP_NEGATIVE_Z as _;
	}
}

#[derive(Clone, Debug)]
pub struct DynamicIndexBuffer {
	handle: bgfx_sys::bgfx_dynamic_index_buffer_handle_t,
}

#[derive(Clone, Debug)]
pub struct DynamicVertexBuffer {
	handle: bgfx_sys::bgfx_dynamic_vertex_buffer_handle_t,
}

#[derive(Clone, Debug)]
pub struct FrameBuffer {
	handle: bgfx_sys::bgfx_frame_buffer_handle_t,
}

#[derive(Clone, Debug)]
pub struct IndexBuffer {
	handle: bgfx_sys::bgfx_index_buffer_handle_t,
}

#[derive(Clone, Debug)]
pub struct IndirectBuffer {
	handle: bgfx_sys::bgfx_indirect_buffer_handle_t,
}

#[derive(Clone, Debug)]
pub struct OcclusionQuery {
	handle: bgfx_sys::bgfx_occlusion_query_handle_t,
}

#[derive(Clone, Debug)]
pub struct Program {
	handle: bgfx_sys::bgfx_program_handle_t,
}

#[derive(Clone, Debug)]
pub struct Shader {
	handle: bgfx_sys::bgfx_shader_handle_t,
}

#[derive(Clone, Debug)]
pub struct Texture {
	handle: bgfx_sys::bgfx_texture_handle_t,
}

#[derive(Clone, Debug)]
pub struct Uniform {
	handle: bgfx_sys::bgfx_uniform_handle_t,
}

#[derive(Clone, Debug)]
pub struct VertexBuffer {
	handle: bgfx_sys::bgfx_vertex_buffer_handle_t,
}

#[derive(Clone, Debug)]
pub struct VertexLayout {
	handle: bgfx_sys::bgfx_vertex_layout_handle_t,
}

pub struct InitArgs {
	/// Access. See [Access].
	pub access: Access,
	/// Cubemap side or depth layer/slice to use.
	pub layer: u16,
	/// Number of texture layer/slice(s) in array to use.
	pub num_layers: u16,
	/// Mip level.
	pub mip: u16,
	/// Resolve flags. See: [ResolveFlags]
	pub resolve: u8,
}

impl Default for InitArgs {
	fn default() -> InitArgs {
		InitArgs {
			access: Access::Write,
			layer: 0,
			num_layers: 1,
			mip: 0,
			resolve: ResolveFlags::AUTO_GEN_MIPS.bits(),
		}
	}
}

pub struct AddArgs {
	/// When using fixed point AttribType (f.e. Uint8)
	/// value will be normalized for vertex shader usage. When normalized
	/// is set to true, AttribType::Uint8 value in range 0-255 will be
	/// in range 0.0-1.0 in vertex shader.
	pub normalized: bool,
	/// Packaging rule for vertexPack, vertexUnpack, and
	/// vertexConvert for AttribType::Uint8 and AttribType::Int16.
	/// Unpacking code must be implemented inside vertex shader.
	pub as_int: bool,
}

impl Default for AddArgs {
	fn default() -> AddArgs {
		AddArgs {
			normalized: false,
			as_int: false,
		}
	}
}

pub struct ResetArgs {
	/// See: [ResetFlags] for more info.
	///   - [ResetFlags::NONE] - No reset flags.
	///   - [ResetFlags::FULLSCREEN] - Not supported yet.
	///   - [ResetMsaaFlags::X[2/4/8/16]] - Enable 2, 4, 8 or 16 x MSAA.
	///   - [ResetFlags::VSYNC] - Enable V-Sync.
	///   - [ResetFlags::MAXANISOTROPY] - Turn on/off max anisotropy.
	///   - [ResetFlags::CAPTURE] - Begin screen capture.
	///   - [ResetFlags::FLUSH_AFTER_RENDER] - Flush rendering after submitting to GPU.
	///   - [ResetFlags::FLIP_AFTER_RENDER] - This flag  specifies where flip
	///	 occurs. Default behaviour is that flip occurs before rendering new
	///	 frame. This flag only has effect when `BGFX_CONFIG_MULTITHREADED=0`.
	///   - [ResetFlags::SRGB_BACKBUFFER] - Enable sRGB back-buffer.
	pub flags: u32,
	/// Texture format. See: [TextureFormat].
	pub format: TextureFormat,
}

impl Default for ResetArgs {
	fn default() -> ResetArgs {
		ResetArgs {
			flags: ResetFlags::NONE.bits(),
			format: TextureFormat::Count,
		}
	}
}

pub struct DbgTextClearArgs {
	/// Background color.
	pub attr: u8,
	/// Default 8x16 or 8x8 font.
	pub small: bool,
}

impl Default for DbgTextClearArgs {
	fn default() -> DbgTextClearArgs {
		DbgTextClearArgs {
			attr: 0,
			small: false,
		}
	}
}

pub struct CreateTextureArgs {
	/// Texture creation (see [TextureFlags].), and sampler (see [SamplerFlags])
	/// flags. Default texture sampling mode is linear, and wrap mode is repeat.
	/// - [SamplerFlags::[U/V/W]_[MIRROR/CLAMP]] - Mirror or clamp to edge wrap
	///   mode.
	/// - [SamplerFlags::[MIN/MAG/MIP]_[POINT/ANISOTROPIC]] - Point or anisotropic
	///   sampling.
	pub flags: u64,
	/// Skip top level mips when parsing texture.
	pub skip: u8,
}

impl Default for CreateTextureArgs {
	fn default() -> CreateTextureArgs {
		CreateTextureArgs {
			flags: TextureFlags::NONE.bits() as u64 | SamplerFlags::NONE.bits() as u64,
			skip: 0,
		}
	}
}

pub struct CreateTexture2DArgs {
	/// Texture creation (see [TextureFlags].), and sampler (see [SamplerFlags])
	/// flags. Default texture sampling mode is linear, and wrap mode is repeat.
	/// - [SamplerFlags::[U/V/W]_[MIRROR/CLAMP]] - Mirror or clamp to edge wrap
	///   mode.
	/// - [SamplerFlags::[MIN/MAG/MIP]_[POINT/ANISOTROPIC]] - Point or anisotropic
	///   sampling.
	pub flags: u64,
	/// Texture data. If `_mem` is non-NULL, created texture will be immutable. If
	/// `_mem` is NULL content of the texture is uninitialized. When `_numLayers` is more than
	/// 1, expected memory layout is texture and all mips together for each array element.
	pub mem: Option<Memory>,
}

impl Default for CreateTexture2DArgs {
	fn default() -> CreateTexture2DArgs {
		CreateTexture2DArgs {
			flags: TextureFlags::NONE.bits() as u64 | SamplerFlags::NONE.bits() as u64,
			mem: None,
		}
	}
}

pub struct CreateTexture3DArgs {
	/// Texture creation (see [TextureFlags].), and sampler (see [SamplerFlags])
	/// flags. Default texture sampling mode is linear, and wrap mode is repeat.
	/// - [SamplerFlags::[U/V/W]_[MIRROR/CLAMP]] - Mirror or clamp to edge wrap
	///   mode.
	/// - [SamplerFlags::[MIN/MAG/MIP]_[POINT/ANISOTROPIC]] - Point or anisotropic
	///   sampling.
	pub flags: u64,
	/// Texture data. If `_mem` is non-NULL, created texture will be immutable. If
	/// `_mem` is NULL content of the texture is uninitialized. When `_numLayers` is more than
	/// 1, expected memory layout is texture and all mips together for each array element.
	pub mem: Option<Memory>,
}

impl Default for CreateTexture3DArgs {
	fn default() -> CreateTexture3DArgs {
		CreateTexture3DArgs {
			flags: TextureFlags::NONE.bits() as u64 | SamplerFlags::NONE.bits() as u64,
			mem: None,
		}
	}
}

pub struct CreateTextureCubeArgs {
	/// Texture creation (see [TextureFlags].), and sampler (see [SamplerFlags])
	/// flags. Default texture sampling mode is linear, and wrap mode is repeat.
	/// - [SamplerFlags::[U/V/W]_[MIRROR/CLAMP]] - Mirror or clamp to edge wrap
	///   mode.
	/// - [SamplerFlags::[MIN/MAG/MIP]_[POINT/ANISOTROPIC]] - Point or anisotropic
	///   sampling.
	pub flags: u64,
	/// Texture data. If `_mem` is non-NULL, created texture will be immutable. If
	/// `_mem` is NULL content of the texture is uninitialized. When `_numLayers` is more than
	/// 1, expected memory layout is texture and all mips together for each array element.
	pub mem: Option<Memory>,
}

impl Default for CreateTextureCubeArgs {
	fn default() -> CreateTextureCubeArgs {
		CreateTextureCubeArgs {
			flags: TextureFlags::NONE.bits() as u64 | SamplerFlags::NONE.bits() as u64,
			mem: None,
		}
	}
}

pub struct CreateFrameBufferFromNwhArgs {
	/// Window back buffer color format.
	pub format: TextureFormat,
	/// Window back buffer depth format.
	pub depth_format: TextureFormat,
}

impl Default for CreateFrameBufferFromNwhArgs {
	fn default() -> CreateFrameBufferFromNwhArgs {
		CreateFrameBufferFromNwhArgs {
			format: TextureFormat::Count,
			depth_format: TextureFormat::Count,
		}
	}
}

pub struct SetViewScissorArgs {
	/// Position x from the left corner of the window.
	pub x: u16,
	/// Position y from the top corner of the window.
	pub y: u16,
	/// Width of view scissor region.
	pub width: u16,
	/// Height of view scissor region.
	pub height: u16,
}

impl Default for SetViewScissorArgs {
	fn default() -> SetViewScissorArgs {
		SetViewScissorArgs {
			x: 0,
			y: 0,
			width: 0,
			height: 0,
		}
	}
}

pub struct SetViewClearArgs {
	/// Color clear value.
	pub rgba: u32,
	/// Depth clear value.
	pub depth: f32,
	/// Stencil clear value.
	pub stencil: u8,
}

impl Default for SetViewClearArgs {
	fn default() -> SetViewClearArgs {
		SetViewClearArgs {
			rgba: 0x000000ff,
			depth: 1.0,
			stencil: 0,
		}
	}
}

pub struct SetViewClearMrtArgs {
	/// Palette index for frame buffer attachment 0.
	pub c_0: u8,
	/// Palette index for frame buffer attachment 1.
	pub c_1: u8,
	/// Palette index for frame buffer attachment 2.
	pub c_2: u8,
	/// Palette index for frame buffer attachment 3.
	pub c_3: u8,
	/// Palette index for frame buffer attachment 4.
	pub c_4: u8,
	/// Palette index for frame buffer attachment 5.
	pub c_5: u8,
	/// Palette index for frame buffer attachment 6.
	pub c_6: u8,
	/// Palette index for frame buffer attachment 7.
	pub c_7: u8,
}

impl Default for SetViewClearMrtArgs {
	fn default() -> SetViewClearMrtArgs {
		SetViewClearMrtArgs {
			c_0: std::u8::MAX,
			c_1: std::u8::MAX,
			c_2: std::u8::MAX,
			c_3: std::u8::MAX,
			c_4: std::u8::MAX,
			c_5: std::u8::MAX,
			c_6: std::u8::MAX,
			c_7: std::u8::MAX,
		}
	}
}

pub struct SubmitArgs {
	/// Depth for sorting.
	pub depth: u32,
	/// Discard or preserve states. See [DiscardFlags].
	pub flags: u8,
}

impl Default for SubmitArgs {
	fn default() -> SubmitArgs {
		SubmitArgs {
			depth: 0,
			flags: DiscardFlags::ALL.bits(),
		}
	}
}

pub struct SubmitOcclusionQueryArgs {
	/// Depth for sorting.
	pub depth: u32,
	/// Discard or preserve states. See [DiscardFlags].
	pub flags: u8,
}

impl Default for SubmitOcclusionQueryArgs {
	fn default() -> SubmitOcclusionQueryArgs {
		SubmitOcclusionQueryArgs {
			depth: 0,
			flags: DiscardFlags::ALL.bits(),
		}
	}
}

pub struct SubmitIndirectArgs {
	/// First element in indirect buffer.
	pub start: u32,
	/// Number of draws.
	pub num: u32,
	/// Depth for sorting.
	pub depth: u32,
	/// Discard or preserve states. See [DiscardFlags].
	pub flags: u8,
}

impl Default for SubmitIndirectArgs {
	fn default() -> SubmitIndirectArgs {
		SubmitIndirectArgs {
			start: 0,
			num: 1,
			depth: 0,
			flags: DiscardFlags::ALL.bits(),
		}
	}
}

pub struct SubmitIndirectCountArgs {
	/// Element in number buffer.
	pub num_index: u32,
	/// Max number of draws.
	pub num_max: u32,
	/// Depth for sorting.
	pub depth: u32,
	/// Discard or preserve states. See [DiscardFlags].
	pub flags: u8,
}

impl Default for SubmitIndirectCountArgs {
	fn default() -> SubmitIndirectCountArgs {
		SubmitIndirectCountArgs {
			num_index: 0,
			num_max: bgfx_sys::UINT32_MAX,
			depth: 0,
			flags: DiscardFlags::ALL.bits(),
		}
	}
}

pub struct DispatchArgs {
	/// Number of groups X.
	pub num_x: u32,
	/// Number of groups Y.
	pub num_y: u32,
	/// Number of groups Z.
	pub num_z: u32,
	/// Discard or preserve states. See [DiscardFlags].
	pub flags: u8,
}

impl Default for DispatchArgs {
	fn default() -> DispatchArgs {
		DispatchArgs {
			num_x: 1,
			num_y: 1,
			num_z: 1,
			flags: DiscardFlags::ALL.bits(),
		}
	}
}

pub struct DispatchIndirectArgs {
	/// First element in indirect buffer.
	pub start: u32,
	/// Number of dispatches.
	pub num: u32,
	/// Discard or preserve states. See [DiscardFlags].
	pub flags: u8,
}

impl Default for DispatchIndirectArgs {
	fn default() -> DispatchIndirectArgs {
		DispatchIndirectArgs {
			start: 0,
			num: 1,
			flags: DiscardFlags::ALL.bits(),
		}
	}
}

pub struct BlitArgs {
	/// Source texture mip level.
	pub src_mip: u8,
	/// Source texture X position.
	pub src_x: u16,
	/// Source texture Y position.
	pub src_y: u16,
	/// If texture is 2D this argument should be 0. If source texture is cube
	/// this argument represents source texture cube face. For 3D texture this argument
	/// represents source texture Z position.
	pub src_z: u16,
	/// Width of region.
	pub width: u16,
	/// Height of region.
	pub height: u16,
	/// If texture is 3D this argument represents depth of region, otherwise it's
	/// unused.
	pub depth: u16,
}

impl Default for BlitArgs {
	fn default() -> BlitArgs {
		BlitArgs {
			src_mip: 0,
			src_x: 0,
			src_y: 0,
			src_z: 0,
			width: std::u16::MAX,
			height: std::u16::MAX,
			depth: std::u16::MAX,
		}
	}
}

/// GPU info.
#[repr(C)]
pub struct CapsGPU {
	/// Vendor PCI id. See [PciIdFlags].
	pub vendor_id: u16,
	/// Device id.
	pub device_id: u16,
}
/// Renderer runtime limits.
#[repr(C)]
pub struct CapsLimits {
	/// Maximum number of draw calls.
	pub max_draw_calls: u32,
	/// Maximum number of blit calls.
	pub max_blits: u32,
	/// Maximum texture size.
	pub max_texture_size: u32,
	/// Maximum texture layers.
	pub max_texture_layers: u32,
	/// Maximum number of views.
	pub max_views: u32,
	/// Maximum number of frame buffer handles.
	pub max_frame_buffers: u32,
	/// Maximum number of frame buffer attachments.
	pub max_fb_attachments: u32,
	/// Maximum number of program handles.
	pub max_programs: u32,
	/// Maximum number of shader handles.
	pub max_shaders: u32,
	/// Maximum number of texture handles.
	pub max_textures: u32,
	/// Maximum number of texture samplers.
	pub max_texture_samplers: u32,
	/// Maximum number of compute bindings.
	pub max_compute_bindings: u32,
	/// Maximum number of vertex format layouts.
	pub max_vertex_layouts: u32,
	/// Maximum number of vertex streams.
	pub max_vertex_streams: u32,
	/// Maximum number of index buffer handles.
	pub max_index_buffers: u32,
	/// Maximum number of vertex buffer handles.
	pub max_vertex_buffers: u32,
	/// Maximum number of dynamic index buffer handles.
	pub max_dynamic_index_buffers: u32,
	/// Maximum number of dynamic vertex buffer handles.
	pub max_dynamic_vertex_buffers: u32,
	/// Maximum number of uniform handles.
	pub max_uniforms: u32,
	/// Maximum number of occlusion query handles.
	pub max_occlusion_queries: u32,
	/// Maximum number of encoder threads.
	pub max_encoders: u32,
	/// Minimum resource command buffer size.
	pub min_resource_cb_size: u32,
	/// Maximum transient vertex buffer size.
	pub transient_vb_size: u32,
	/// Maximum transient index buffer size.
	pub transient_ib_size: u32,
}
/// Renderer capabilities.
#[repr(C)]
pub struct Caps {
	/// Renderer backend type. See: `bgfx::RendererType`
	pub renderer_type: RendererType,
	/// Supported functionality.
	///   @attention See [CapsFlags] flags at https://bkaradzic.github.io/bgfx/bgfx.html#available-caps
	pub supported: u64,
	/// Selected GPU vendor PCI id.
	pub vendor_id: u16,
	/// Selected GPU device id.
	pub device_id: u16,
	/// True when NDC depth is in [-1, 1] range, otherwise its [0, 1].
	pub homogeneous_depth: bool,
	/// True when NDC origin is at bottom left.
	pub origin_bottom_left: bool,
	/// Number of enumerated GPUs.
	pub num_gp_us: u8,
	/// Enumerated GPUs.
	pub gpu: [CapsGPU; 4usize],
	/// Renderer runtime limits.
	pub limits: CapsLimits,
	/// Supported texture format capabilities flags:
	///   - [CapsFormatFlags::TEXTURE_NONE] - Texture format is not supported.
	///   - [CapsFormatFlags::TEXTURE_2D] - Texture format is supported.
	///   - [CapsFormatFlags::TEXTURE_2D_SRGB] - Texture as sRGB format is supported.
	///   - [CapsFormatFlags::TEXTURE_2D_EMULATED] - Texture format is emulated.
	///   - [CapsFormatFlags::TEXTURE_3D] - Texture format is supported.
	///   - [CapsFormatFlags::TEXTURE_3D_SRGB] - Texture as sRGB format is supported.
	///   - [CapsFormatFlags::TEXTURE_3D_EMULATED] - Texture format is emulated.
	///   - [CapsFormatFlags::TEXTURE_CUBE] - Texture format is supported.
	///   - [CapsFormatFlags::TEXTURE_CUBE_SRGB] - Texture as sRGB format is supported.
	///   - [CapsFormatFlags::TEXTURE_CUBE_EMULATED] - Texture format is emulated.
	///   - [CapsFormatFlags::TEXTURE_VERTEX] - Texture format can be used from vertex shader.
	///   - [CapsFormatFlags::TEXTURE_IMAGE_READ] - Texture format can be used as image
	///	 and read from.
	///   - [CapsFormatFlags::TEXTURE_IMAGE_WRITE] - Texture format can be used as image
	///	 and written to.
	///   - [CapsFormatFlags::TEXTURE_FRAMEBUFFER] - Texture format can be used as frame
	///	 buffer.
	///   - [CapsFormatFlags::TEXTURE_FRAMEBUFFER_MSAA] - Texture format can be used as MSAA
	///	 frame buffer.
	///   - [CapsFormatFlags::TEXTURE_MSAA] - Texture can be sampled as MSAA.
	///   - [CapsFormatFlags::TEXTURE_MIP_AUTOGEN] - Texture format supports auto-generated
	///	 mips.
	pub formats: [u16; 96usize],
}
/// Internal data.
#[repr(C)]
pub struct InternalData {
	/// Renderer capabilities.
	pub caps: *const Caps,
	/// GL context, or D3D device.
	pub context: *const c_void,
}
/// Platform data.
#[repr(C)]
pub struct PlatformData {
	/// Native display type (*nix specific).
	pub ndt: *const c_void,
	/// Native window handle. If `NULL`, bgfx will create a headless
	/// context/device, provided the rendering API supports it.
	pub nwh: *const c_void,
	/// GL context, D3D device, or Vulkan device. If `NULL`, bgfx
	/// will create context/device.
	pub context: *const c_void,
	/// GL back-buffer, or D3D render target view. If `NULL` bgfx will
	/// create back-buffer color surface.
	pub back_buffer: *const c_void,
	/// Backbuffer depth/stencil. If `NULL`, bgfx will create a back-buffer
	/// depth/stencil surface.
	pub back_buffer_ds: *const c_void,
	/// Handle type. Needed for platforms having more than one option.
	pub type_r: NativeWindowHandleType,
}
/// Backbuffer resolution and reset parameters.
#[repr(C)]
pub struct Resolution {
	/// Backbuffer format.
	pub format: TextureFormat,
	/// Backbuffer width.
	pub width: u32,
	/// Backbuffer height.
	pub height: u32,
	/// Reset parameters.
	pub reset: u32,
	/// Number of back buffers.
	pub num_back_buffers: u8,
	/// Maximum frame latency.
	pub max_frame_latency: u8,
	/// Scale factor for debug text.
	pub debug_text_scale: u8,
}
/// Configurable runtime limits parameters.
#[repr(C)]
pub struct InitLimits {
	/// Maximum number of encoder threads.
	pub max_encoders: u16,
	/// Minimum resource command buffer size.
	pub min_resource_cb_size: u32,
	/// Maximum transient vertex buffer size.
	pub transient_vb_size: u32,
	/// Maximum transient index buffer size.
	pub transient_ib_size: u32,
}
/// Initialization parameters used by `bgfx::init`.
#[repr(C)]
pub struct Init {
	/// Select rendering backend. When set to RendererType::Count
	/// a default rendering backend will be selected appropriate to the platform.
	/// See: `bgfx::RendererType`
	pub type_r: RendererType,
	/// Vendor PCI ID. If set to [PciIdFlags::NONE], discrete and integrated
	/// GPUs will be prioritised.
	///   - [PciIdFlags::NONE] - Autoselect adapter.
	///   - [PciIdFlags::SOFTWARE_RASTERIZER] - Software rasterizer.
	///   - [PciIdFlags::AMD] - AMD adapter.
	///   - [PciIdFlags::APPLE] - Apple adapter.
	///   - [PciIdFlags::INTEL] - Intel adapter.
	///   - [PciIdFlags::NVIDIA] - NVIDIA adapter.
	///   - [PciIdFlags::MICROSOFT] - Microsoft adapter.
	pub vendor_id: u16,
	/// Device ID. If set to 0 it will select first device, or device with
	/// matching ID.
	pub device_id: u16,
	/// Capabilities initialization mask (default: UINT64_MAX).
	pub capabilities: u64,
	/// Enable device for debugging.
	pub debug: bool,
	/// Enable device for profiling.
	pub profile: bool,
	/// Platform data.
	pub platform_data: PlatformData,
	/// Backbuffer resolution and reset parameters. See: `bgfx::Resolution`.
	pub resolution: Resolution,
	/// Configurable runtime limits parameters.
	pub limits: CapsLimits,
	/// Provide application specific callback interface.
	/// See: `bgfx::CallbackI`
	pub callback: *const u8,
	/// Custom allocator. When a custom allocator is not
	/// specified, bgfx uses the CRT allocator. Bgfx assumes
	/// custom allocator is thread safe.
	pub allocator: *const u8,
}
/// Transient index buffer.
#[repr(C)]
pub struct TransientIndexBuffer {
	/// Pointer to data.
	pub data: *const u8,
	/// Data size.
	pub size: u32,
	/// First index.
	pub start_index: u32,
	/// Index buffer handle.
	pub handle: IndexBuffer,
	/// Index buffer format is 16-bits if true, otherwise it is 32-bit.
	pub is_index_16: bool,
}
/// Transient vertex buffer.
#[repr(C)]
pub struct TransientVertexBuffer {
	/// Pointer to data.
	pub data: *const u8,
	/// Data size.
	pub size: u32,
	/// First vertex.
	pub start_vertex: u32,
	/// Vertex stride.
	pub stride: u16,
	/// Vertex buffer handle.
	pub handle: VertexBuffer,
	/// Vertex layout handle.
	pub layout_handle: VertexLayout,
}
/// Instance data buffer info.
#[repr(C)]
pub struct InstanceDataBuffer {
	/// Pointer to data.
	pub data: *const u8,
	/// Data size.
	pub size: u32,
	/// Offset in vertex buffer.
	pub offset: u32,
	/// Number of instances.
	pub num: u32,
	/// Vertex buffer stride.
	pub stride: u16,
	/// Vertex buffer object handle.
	pub handle: VertexBuffer,
}
pub type TextureInfo = bgfx_sys::bgfx_texture_info_s;
/// Uniform info.
#[repr(C)]
pub struct UniformInfo {
	/// Uniform name.
	pub name: [i8; 256usize],
	/// Uniform type.
	pub type_r: UniformType,
	/// Number of elements in array.
	pub num: u16,
}
/// Frame buffer texture attachment info.
#[repr(C)]
pub struct Attachment {
	/// Attachment access. See [Access].
	pub access: Access,
	/// Render target texture handle.
	pub handle: Texture,
	/// Mip level.
	pub mip: u16,
	/// Cubemap side or depth layer/slice to use.
	pub layer: u16,
	/// Number of texture layer/slice(s) in array to use.
	pub num_layers: u16,
	/// Resolve flags. See: [ResolveFlags]
	pub resolve: u8,
}
/// Transform data.
#[repr(C)]
pub struct Transform {
	/// Pointer to first 4x4 matrix.
	pub data: *const f32,
	/// Number of matrices.
	pub num: u16,
}
/// View stats.
#[repr(C)]
pub struct ViewStats {
	/// View name.
	pub name: [i8; 256usize],
	/// View id.
	pub view: ViewId,
	/// CPU (submit) begin time.
	pub cpu_time_begin: i64,
	/// CPU (submit) end time.
	pub cpu_time_end: i64,
	/// GPU begin time.
	pub gpu_time_begin: i64,
	/// GPU end time.
	pub gpu_time_end: i64,
	/// Frame which generated gpuTimeBegin, gpuTimeEnd.
	pub gpu_frame_num: u32,
}
/// Encoder stats.
#[repr(C)]
pub struct EncoderStats {
	/// Encoder thread CPU submit begin time.
	pub cpu_time_begin: i64,
	/// Encoder thread CPU submit end time.
	pub cpu_time_end: i64,
}
/// Renderer statistics data.
///
/// @remarks All time values are high-resolution timestamps, while
/// time frequencies define timestamps-per-second for that hardware.
#[repr(C)]
pub struct Stats {
	/// CPU time between two `bgfx::frame` calls.
	pub cpu_time_frame: i64,
	/// Render thread CPU submit begin time.
	pub cpu_time_begin: i64,
	/// Render thread CPU submit end time.
	pub cpu_time_end: i64,
	/// CPU timer frequency. Timestamps-per-second
	pub cpu_timer_freq: i64,
	/// GPU frame begin time.
	pub gpu_time_begin: i64,
	/// GPU frame end time.
	pub gpu_time_end: i64,
	/// GPU timer frequency.
	pub gpu_timer_freq: i64,
	/// Time spent waiting for render backend thread to finish issuing draw commands to underlying graphics API.
	pub wait_render: i64,
	/// Time spent waiting for submit thread to advance to next frame.
	pub wait_submit: i64,
	/// Number of draw calls submitted.
	pub num_draw: u32,
	/// Number of compute calls submitted.
	pub num_compute: u32,
	/// Number of blit calls submitted.
	pub num_blit: u32,
	/// GPU driver latency.
	pub max_gpu_latency: u32,
	/// Frame which generated gpuTimeBegin, gpuTimeEnd.
	pub gpu_frame_num: u32,
	/// Number of used dynamic index buffers.
	pub num_dynamic_index_buffers: u16,
	/// Number of used dynamic vertex buffers.
	pub num_dynamic_vertex_buffers: u16,
	/// Number of used frame buffers.
	pub num_frame_buffers: u16,
	/// Number of used index buffers.
	pub num_index_buffers: u16,
	/// Number of used occlusion queries.
	pub num_occlusion_queries: u16,
	/// Number of used programs.
	pub num_programs: u16,
	/// Number of used shaders.
	pub num_shaders: u16,
	/// Number of used textures.
	pub num_textures: u16,
	/// Number of used uniforms.
	pub num_uniforms: u16,
	/// Number of used vertex buffers.
	pub num_vertex_buffers: u16,
	/// Number of used vertex layouts.
	pub num_vertex_layouts: u16,
	/// Estimate of texture memory used.
	pub texture_memory_used: i64,
	/// Estimate of render target memory used.
	pub rt_memory_used: i64,
	/// Amount of transient vertex buffer used.
	pub transient_vb_used: i32,
	/// Amount of transient index buffer used.
	pub transient_ib_used: i32,
	/// Number of primitives rendered.
	pub num_prims: [u32; 5usize],
	/// Maximum available GPU memory for application.
	pub gpu_memory_max: i64,
	/// Amount of GPU memory used by the application.
	pub gpu_memory_used: i64,
	/// Backbuffer width in pixels.
	pub width: u16,
	/// Backbuffer height in pixels.
	pub height: u16,
	/// Debug text width in characters.
	pub text_width: u16,
	/// Debug text height in characters.
	pub text_height: u16,
	/// Number of view stats.
	pub num_views: u16,
	/// Array of View stats.
	pub view_stats: *const ViewStats,
	/// Number of encoders used during frame.
	pub num_encoders: u8,
	/// Array of encoder stats.
	pub encoder_stats: *const EncoderStats,
}
/// Vertex layout.
#[repr(C)]
pub struct VertexLayoutBuilder {
	/// Hash.
	pub hash: u32,
	/// Stride.
	pub stride: u16,
	/// Attribute offsets.
	pub offset: [u16; 18usize],
	/// Used attributes.
	pub attributes: [u16; 18usize],
}
/// Encoders are used for submitting draw calls from multiple threads. Only one encoder
/// per thread should be used. Use `bgfx::begin()` to obtain an encoder for a thread.
#[repr(C)]
pub struct Encoder {}
impl DynamicIndexBuffer {
	/// * `num`:
	/// Number of indices.
	/// * `flags`:
	/// Buffer creation flags.
	///   - [BufferFlags::NONE] - No flags.
	///   - [BufferFlags::COMPUTE_READ] - Buffer will be read from by compute shader.
	///   - [BufferFlags::COMPUTE_WRITE] - Buffer will be written into by compute shader. When buffer
	///	   is created with [BufferFlags::COMPUTE_WRITE] flag it cannot be updated from CPU.
	///   - [BufferFlags::COMPUTE_READ_WRITE] - Buffer will be used for read/write by compute shader.
	///   - [BufferFlags::ALLOW_RESIZE] - Buffer will resize on buffer update if a different amount of
	///	   data is passed. If this flag is not specified, and more data is passed on update, the buffer
	///	   will be trimmed to fit the existing buffer size. This flag has effect only on dynamic
	///	   buffers.
	///   - [BufferFlags::INDEX32] - Buffer is using 32-bit indices. This flag has effect only on
	///	   index buffers.
	pub fn create_dynamic_index_buffer(num: u32, flags: u16) -> DynamicIndexBuffer {
		unsafe {
			let _ret = bgfx_sys::bgfx_create_dynamic_index_buffer(num, flags);
			DynamicIndexBuffer { handle: _ret }
		}
	}
	/// * `mem`:
	/// Index buffer data.
	/// * `flags`:
	/// Buffer creation flags.
	///   - [BufferFlags::NONE] - No flags.
	///   - [BufferFlags::COMPUTE_READ] - Buffer will be read from by compute shader.
	///   - [BufferFlags::COMPUTE_WRITE] - Buffer will be written into by compute shader. When buffer
	///	   is created with [BufferFlags::COMPUTE_WRITE] flag it cannot be updated from CPU.
	///   - [BufferFlags::COMPUTE_READ_WRITE] - Buffer will be used for read/write by compute shader.
	///   - [BufferFlags::ALLOW_RESIZE] - Buffer will resize on buffer update if a different amount of
	///	   data is passed. If this flag is not specified, and more data is passed on update, the buffer
	///	   will be trimmed to fit the existing buffer size. This flag has effect only on dynamic
	///	   buffers.
	///   - [BufferFlags::INDEX32] - Buffer is using 32-bit indices. This flag has effect only on
	///	   index buffers.
	pub fn create_dynamic_index_buffer_mem(mem: &Memory, flags: u16) -> DynamicIndexBuffer {
		unsafe {
			let _ret = bgfx_sys::bgfx_create_dynamic_index_buffer_mem(mem.handle, flags);
			DynamicIndexBuffer { handle: _ret }
		}
	}
	/// * `handle`:
	/// Dynamic index buffer handle.
	/// * `start_index`:
	/// Start index.
	/// * `mem`:
	/// Index buffer data.
	pub fn update_dynamic_index_buffer(&self, start_index: u32, mem: &Memory) {
		unsafe {
			bgfx_sys::bgfx_update_dynamic_index_buffer(self.handle, start_index, mem.handle);
		}
	}
	/// * `handle`:
	/// Dynamic index buffer.
	/// * `first_index`:
	/// First index to render.
	/// * `num_indices`:
	/// Number of indices to render.
	pub fn set_dynamic_index_buffer(&self, first_index: u32, num_indices: u32) {
		unsafe {
			bgfx_sys::bgfx_set_dynamic_index_buffer(self.handle, first_index, num_indices);
		}
	}
}

impl Drop for DynamicIndexBuffer {
	fn drop(&mut self) {
		unsafe {
			bgfx_sys::bgfx_destroy_dynamic_index_buffer(self.handle);
		}
	}
}

impl DynamicVertexBuffer {
	/// * `num`:
	/// Number of vertices.
	/// * `layout`:
	/// Vertex layout.
	/// * `flags`:
	/// Buffer creation flags.
	///   - [BufferFlags::NONE] - No flags.
	///   - [BufferFlags::COMPUTE_READ] - Buffer will be read from by compute shader.
	///   - [BufferFlags::COMPUTE_WRITE] - Buffer will be written into by compute shader. When buffer
	///	   is created with [BufferFlags::COMPUTE_WRITE] flag it cannot be updated from CPU.
	///   - [BufferFlags::COMPUTE_READ_WRITE] - Buffer will be used for read/write by compute shader.
	///   - [BufferFlags::ALLOW_RESIZE] - Buffer will resize on buffer update if a different amount of
	///	   data is passed. If this flag is not specified, and more data is passed on update, the buffer
	///	   will be trimmed to fit the existing buffer size. This flag has effect only on dynamic
	///	   buffers.
	///   - [BufferFlags::INDEX32] - Buffer is using 32-bit indices. This flag has effect only on
	///	   index buffers.
	pub fn create_dynamic_vertex_buffer(
		num: u32,
		layout: &BuiltVertexLayout,
		flags: u16,
	) -> DynamicVertexBuffer {
		unsafe {
			let _layout = std::mem::transmute(layout);
			let _ret = bgfx_sys::bgfx_create_dynamic_vertex_buffer(num, _layout, flags);
			DynamicVertexBuffer { handle: _ret }
		}
	}
	/// * `mem`:
	/// Vertex buffer data.
	/// * `layout`:
	/// Vertex layout.
	/// * `flags`:
	/// Buffer creation flags.
	///   - [BufferFlags::NONE] - No flags.
	///   - [BufferFlags::COMPUTE_READ] - Buffer will be read from by compute shader.
	///   - [BufferFlags::COMPUTE_WRITE] - Buffer will be written into by compute shader. When buffer
	///	   is created with [BufferFlags::COMPUTE_WRITE] flag it cannot be updated from CPU.
	///   - [BufferFlags::COMPUTE_READ_WRITE] - Buffer will be used for read/write by compute shader.
	///   - [BufferFlags::ALLOW_RESIZE] - Buffer will resize on buffer update if a different amount of
	///	   data is passed. If this flag is not specified, and more data is passed on update, the buffer
	///	   will be trimmed to fit the existing buffer size. This flag has effect only on dynamic
	///	   buffers.
	///   - [BufferFlags::INDEX32] - Buffer is using 32-bit indices. This flag has effect only on
	///	   index buffers.
	pub fn create_dynamic_vertex_buffer_mem(
		mem: &Memory,
		layout: &BuiltVertexLayout,
		flags: u16,
	) -> DynamicVertexBuffer {
		unsafe {
			let _layout = std::mem::transmute(layout);
			let _ret = bgfx_sys::bgfx_create_dynamic_vertex_buffer_mem(mem.handle, _layout, flags);
			DynamicVertexBuffer { handle: _ret }
		}
	}
	/// * `handle`:
	/// Dynamic vertex buffer handle.
	/// * `start_vertex`:
	/// Start vertex.
	/// * `mem`:
	/// Vertex buffer data.
	pub fn update_dynamic_vertex_buffer(&self, start_vertex: u32, mem: &Memory) {
		unsafe {
			bgfx_sys::bgfx_update_dynamic_vertex_buffer(self.handle, start_vertex, mem.handle);
		}
	}
	/// * `handle`:
	/// Dynamic vertex buffer.
	/// * `start_vertex`:
	/// First instance data.
	/// * `num`:
	/// Number of data instances.
	pub fn set_instance_data_from_dynamic_vertex_buffer(&self, start_vertex: u32, num: u32) {
		unsafe {
			bgfx_sys::bgfx_set_instance_data_from_dynamic_vertex_buffer(
				self.handle,
				start_vertex,
				num,
			);
		}
	}
}

impl Drop for DynamicVertexBuffer {
	fn drop(&mut self) {
		unsafe {
			bgfx_sys::bgfx_destroy_dynamic_vertex_buffer(self.handle);
		}
	}
}

impl FrameBuffer {
	/// * `width`:
	/// Texture width.
	/// * `height`:
	/// Texture height.
	/// * `format`:
	/// Texture format. See: [TextureFormat].
	/// * `texture_flags`:
	/// Texture creation (see [TextureFlags].), and sampler (see [SamplerFlags])
	/// flags. Default texture sampling mode is linear, and wrap mode is repeat.
	/// - [SamplerFlags::[U/V/W]_[MIRROR/CLAMP]] - Mirror or clamp to edge wrap
	///   mode.
	/// - [SamplerFlags::[MIN/MAG/MIP]_[POINT/ANISOTROPIC]] - Point or anisotropic
	///   sampling.
	pub fn create_frame_buffer(
		width: u16,
		height: u16,
		format: TextureFormat,
		texture_flags: u64,
	) -> FrameBuffer {
		unsafe {
			let _ret =
				bgfx_sys::bgfx_create_frame_buffer(width, height, format as _, texture_flags);
			FrameBuffer { handle: _ret }
		}
	}
	/// * `ratio`:
	/// Frame buffer size in respect to back-buffer size. See:
	/// [BackbufferRatio].
	/// * `format`:
	/// Texture format. See: [TextureFormat].
	/// * `texture_flags`:
	/// Texture creation (see [TextureFlags].), and sampler (see [SamplerFlags])
	/// flags. Default texture sampling mode is linear, and wrap mode is repeat.
	/// - [SamplerFlags::[U/V/W]_[MIRROR/CLAMP]] - Mirror or clamp to edge wrap
	///   mode.
	/// - [SamplerFlags::[MIN/MAG/MIP]_[POINT/ANISOTROPIC]] - Point or anisotropic
	///   sampling.
	pub fn create_frame_buffer_scaled(
		ratio: BackbufferRatio,
		format: TextureFormat,
		texture_flags: u64,
	) -> FrameBuffer {
		unsafe {
			let _ret =
				bgfx_sys::bgfx_create_frame_buffer_scaled(ratio as _, format as _, texture_flags);
			FrameBuffer { handle: _ret }
		}
	}
	/// * `num`:
	/// Number of texture handles.
	/// * `handles`:
	/// Texture attachments.
	/// * `destroy_texture`:
	/// If true, textures will be destroyed when
	/// frame buffer is destroyed.
	pub fn create_frame_buffer_from_handles(
		num: u8,
		handles: &Texture,
		destroy_texture: bool,
	) -> FrameBuffer {
		unsafe {
			let _ret = bgfx_sys::bgfx_create_frame_buffer_from_handles(
				num,
				&handles.handle,
				destroy_texture,
			);
			FrameBuffer { handle: _ret }
		}
	}
	/// * `num`:
	/// Number of attachments.
	/// * `attachment`:
	/// Attachment texture info. See: `bgfx::Attachment`.
	/// * `destroy_texture`:
	/// If true, textures will be destroyed when
	/// frame buffer is destroyed.
	pub fn create_frame_buffer_from_attachment(
		num: u8,
		attachment: &Attachment,
		destroy_texture: bool,
	) -> FrameBuffer {
		unsafe {
			let _attachment = std::mem::transmute(attachment);
			let _ret = bgfx_sys::bgfx_create_frame_buffer_from_attachment(
				num,
				_attachment,
				destroy_texture,
			);
			FrameBuffer { handle: _ret }
		}
	}
	/// * `nwh`:
	/// OS' target native window handle.
	/// * `width`:
	/// Window back buffer width.
	/// * `height`:
	/// Window back buffer height.
	/// * `format`:
	/// Window back buffer color format.
	/// * `depth_format`:
	/// Window back buffer depth format.
	pub fn create_frame_buffer_from_nwh(
		nwh: &mut c_void,
		width: u16,
		height: u16,
		params: CreateFrameBufferFromNwhArgs,
	) -> FrameBuffer {
		unsafe {
			let _ret = bgfx_sys::bgfx_create_frame_buffer_from_nwh(
				nwh,
				width,
				height,
				params.format as _,
				params.depth_format as _,
			);
			FrameBuffer { handle: _ret }
		}
	}
	/// * `handle`:
	/// Frame buffer handle.
	/// * `name`:
	/// Frame buffer name.
	/// * `len`:
	/// Frame buffer name length (if length is INT32_MAX, it's expected
	/// that _name is zero terminated string.
	pub fn set_name(&self, name: &str) {
		unsafe {
			bgfx_sys::bgfx_set_frame_buffer_name(self.handle, name.as_ptr() as _, name.len() as i32)
		}
	}
	/// * `handle`:
	/// Frame buffer handle.
	/// * `attachment`:
	pub fn get_texture(&self, attachment: u8) -> Texture {
		unsafe {
			let _ret = bgfx_sys::bgfx_get_texture(self.handle, attachment);
			Texture { handle: _ret }
		}
	}
	/// * `handle`:
	/// Frame buffer handle. If handle is ]BGFX_INVALID_HANDLE] request will be
	/// made for main window back buffer.
	/// * `file_path`:
	/// Will be passed to `bgfx::CallbackI::screenShot` callback.
	pub fn request_screen_shot(&self, file_path: &i8) {
		unsafe {
			bgfx_sys::bgfx_request_screen_shot(self.handle, file_path as *const i8 as *const ::std::os::raw::c_char);
		}
	}
}

impl Drop for FrameBuffer {
	fn drop(&mut self) {
		unsafe {
			bgfx_sys::bgfx_destroy_frame_buffer(self.handle);
		}
	}
}

impl IndexBuffer {
	/// * `mem`:
	/// Index buffer data.
	/// * `flags`:
	/// Buffer creation flags.
	///   - [BufferFlags::NONE] - No flags.
	///   - [BufferFlags::COMPUTE_READ] - Buffer will be read from by compute shader.
	///   - [BufferFlags::COMPUTE_WRITE] - Buffer will be written into by compute shader. When buffer
	///	   is created with [BufferFlags::COMPUTE_WRITE] flag it cannot be updated from CPU.
	///   - [BufferFlags::COMPUTE_READ_WRITE] - Buffer will be used for read/write by compute shader.
	///   - [BufferFlags::ALLOW_RESIZE] - Buffer will resize on buffer update if a different amount of
	///	   data is passed. If this flag is not specified, and more data is passed on update, the buffer
	///	   will be trimmed to fit the existing buffer size. This flag has effect only on dynamic
	///	   buffers.
	///   - [BufferFlags::INDEX32] - Buffer is using 32-bit indices. This flag has effect only on
	///	   index buffers.
	pub fn create_index_buffer(mem: &Memory, flags: u16) -> IndexBuffer {
		unsafe {
			let _ret = bgfx_sys::bgfx_create_index_buffer(mem.handle, flags);
			IndexBuffer { handle: _ret }
		}
	}
	/// * `handle`:
	/// Static index buffer handle.
	/// * `name`:
	/// Static index buffer name.
	/// * `len`:
	/// Static index buffer name length (if length is INT32_MAX, it's expected
	/// that _name is zero terminated string.
	pub fn set_name(&self, name: &str) {
		unsafe {
			bgfx_sys::bgfx_set_index_buffer_name(self.handle, name.as_ptr() as _, name.len() as i32)
		}
	}
	/// * `handle`:
	/// Index buffer.
	/// * `first_index`:
	/// First index to render.
	/// * `num_indices`:
	/// Number of indices to render.
	pub fn set_index_buffer(&self, first_index: u32, num_indices: u32) {
		unsafe {
			bgfx_sys::bgfx_set_index_buffer(self.handle, first_index, num_indices);
		}
	}
}

impl Drop for IndexBuffer {
	fn drop(&mut self) {
		unsafe {
			bgfx_sys::bgfx_destroy_index_buffer(self.handle);
		}
	}
}

impl IndirectBuffer {
	/// * `num`:
	/// Number of indirect calls.
	pub fn create_indirect_buffer(num: u32) -> IndirectBuffer {
		unsafe {
			let _ret = bgfx_sys::bgfx_create_indirect_buffer(num);
			IndirectBuffer { handle: _ret }
		}
	}
}

impl Drop for IndirectBuffer {
	fn drop(&mut self) {
		unsafe {
			bgfx_sys::bgfx_destroy_indirect_buffer(self.handle);
		}
	}
}

impl OcclusionQuery {
	pub fn create_occlusion_query() -> OcclusionQuery {
		unsafe {
			let _ret = bgfx_sys::bgfx_create_occlusion_query();
			OcclusionQuery { handle: _ret }
		}
	}
	/// * `handle`:
	/// Handle to occlusion query object.
	/// * `result`:
	/// Number of pixels that passed test. This argument
	/// can be `NULL` if result of occlusion query is not needed.
	pub fn get_result(&self, result: &mut i32) -> OcclusionQueryResult {
		unsafe {
			let _ret = bgfx_sys::bgfx_get_result(self.handle, result);
			std::mem::transmute(_ret)
		}
	}
	/// * `handle`:
	/// Occlusion query handle.
	/// * `visible`:
	/// Render if occlusion query is visible.
	pub fn set_condition(&self, visible: bool) {
		unsafe {
			bgfx_sys::bgfx_set_condition(self.handle, visible);
		}
	}
}

impl Drop for OcclusionQuery {
	fn drop(&mut self) {
		unsafe {
			bgfx_sys::bgfx_destroy_occlusion_query(self.handle);
		}
	}
}

impl Program {
	/// * `vsh`:
	/// Vertex shader.
	/// * `fsh`:
	/// Fragment shader.
	/// * `destroy_shaders`:
	/// If true, shaders will be destroyed when program is destroyed.
	pub fn create_program(vsh: &Shader, fsh: &Shader, destroy_shaders: bool) -> Program {
		unsafe {
			let _ret = bgfx_sys::bgfx_create_program(vsh.handle, fsh.handle, destroy_shaders);
			Program { handle: _ret }
		}
	}
	/// * `csh`:
	/// Compute shader.
	/// * `destroy_shaders`:
	/// If true, shaders will be destroyed when program is destroyed.
	pub fn create_compute_program(csh: &Shader, destroy_shaders: bool) -> Program {
		unsafe {
			let _ret = bgfx_sys::bgfx_create_compute_program(csh.handle, destroy_shaders);
			Program { handle: _ret }
		}
	}
}

impl Drop for Program {
	fn drop(&mut self) {
		unsafe {
			bgfx_sys::bgfx_destroy_program(self.handle);
		}
	}
}

impl Shader {
	/// * `mem`:
	/// Shader binary.
	pub fn create_shader(mem: &Memory) -> Shader {
		unsafe {
			let _ret = bgfx_sys::bgfx_create_shader(mem.handle);
			Shader { handle: _ret }
		}
	}
	/// * `handle`:
	/// Shader handle.
	/// * `name`:
	/// Shader name.
	/// * `len`:
	/// Shader name length (if length is INT32_MAX, it's expected
	/// that _name is zero terminated string).
	pub fn set_name(&self, name: &str) {
		unsafe {
			bgfx_sys::bgfx_set_shader_name(self.handle, name.as_ptr() as _, name.len() as i32)
		}
	}
	/// * `vsh`:
	/// Vertex shader.
	/// * `fsh`:
	/// Fragment shader.
	/// * `destroy_shaders`:
	/// If true, shaders will be destroyed when program is destroyed.
	pub fn create_program(&self, fsh: &Shader, destroy_shaders: bool) -> Program {
		unsafe {
			let _ret = bgfx_sys::bgfx_create_program(self.handle, fsh.handle, destroy_shaders);
			Program { handle: _ret }
		}
	}
	/// * `csh`:
	/// Compute shader.
	/// * `destroy_shaders`:
	/// If true, shaders will be destroyed when program is destroyed.
	pub fn create_compute_program(&self, destroy_shaders: bool) -> Program {
		unsafe {
			let _ret = bgfx_sys::bgfx_create_compute_program(self.handle, destroy_shaders);
			Program { handle: _ret }
		}
	}
}

impl Drop for Shader {
	fn drop(&mut self) {
		unsafe {
			bgfx_sys::bgfx_destroy_shader(self.handle);
		}
	}
}

impl Texture {
	/// * `mem`:
	/// DDS, KTX or PVR texture binary data.
	/// * `flags`:
	/// Texture creation (see [TextureFlags].), and sampler (see [SamplerFlags])
	/// flags. Default texture sampling mode is linear, and wrap mode is repeat.
	/// - [SamplerFlags::[U/V/W]_[MIRROR/CLAMP]] - Mirror or clamp to edge wrap
	///   mode.
	/// - [SamplerFlags::[MIN/MAG/MIP]_[POINT/ANISOTROPIC]] - Point or anisotropic
	///   sampling.
	/// * `skip`:
	/// Skip top level mips when parsing texture.
	/// * `info`:
	/// When non-`NULL` is specified it returns parsed texture information.
	pub fn create_texture(mem: &Memory, flags: u64, skip: u8, info: &mut TextureInfo) -> Texture {
		unsafe {
			let _ret =
				bgfx_sys::bgfx_create_texture(mem.handle, flags, skip, info);
			Texture { handle: _ret }
		}
	}
	/// * `width`:
	/// Width.
	/// * `height`:
	/// Height.
	/// * `has_mips`:
	/// Indicates that texture contains full mip-map chain.
	/// * `num_layers`:
	/// Number of layers in texture array. Must be 1 if caps
	/// [CapsFlags::TEXTURE_2D_ARRAY] flag is not set.
	/// * `format`:
	/// Texture format. See: [TextureFormat].
	/// * `flags`:
	/// Texture creation (see [TextureFlags].), and sampler (see [SamplerFlags])
	/// flags. Default texture sampling mode is linear, and wrap mode is repeat.
	/// - [SamplerFlags::[U/V/W]_[MIRROR/CLAMP]] - Mirror or clamp to edge wrap
	///   mode.
	/// - [SamplerFlags::[MIN/MAG/MIP]_[POINT/ANISOTROPIC]] - Point or anisotropic
	///   sampling.
	/// * `mem`:
	/// Texture data. If `_mem` is non-NULL, created texture will be immutable. If
	/// `_mem` is NULL content of the texture is uninitialized. When `_numLayers` is more than
	/// 1, expected memory layout is texture and all mips together for each array element.
	pub fn create_texture_2d(
		width: u16,
		height: u16,
		has_mips: bool,
		num_layers: u16,
		format: TextureFormat,
		params: CreateTexture2DArgs,
	) -> Texture {
		unsafe {
			let _mem = if let Some(h) = params.mem {
				h.handle
			} else {
				std::ptr::null()
			};
			let _ret = bgfx_sys::bgfx_create_texture_2d(
				width,
				height,
				has_mips,
				num_layers,
				format as _,
				params.flags,
				_mem,
			);
			Texture { handle: _ret }
		}
	}
	/// * `ratio`:
	/// Texture size in respect to back-buffer size. See: [BackbufferRatio].
	/// * `has_mips`:
	/// Indicates that texture contains full mip-map chain.
	/// * `num_layers`:
	/// Number of layers in texture array. Must be 1 if caps
	/// [CapsFlags::TEXTURE_2D_ARRAY] flag is not set.
	/// * `format`:
	/// Texture format. See: [TextureFormat].
	/// * `flags`:
	/// Texture creation (see [TextureFlags].), and sampler (see [SamplerFlags])
	/// flags. Default texture sampling mode is linear, and wrap mode is repeat.
	/// - [SamplerFlags::[U/V/W]_[MIRROR/CLAMP]] - Mirror or clamp to edge wrap
	///   mode.
	/// - [SamplerFlags::[MIN/MAG/MIP]_[POINT/ANISOTROPIC]] - Point or anisotropic
	///   sampling.
	pub fn create_texture_2d_scaled(
		ratio: BackbufferRatio,
		has_mips: bool,
		num_layers: u16,
		format: TextureFormat,
		flags: u64,
	) -> Texture {
		unsafe {
			let _ret = bgfx_sys::bgfx_create_texture_2d_scaled(
				ratio as _,
				has_mips,
				num_layers,
				format as _,
				flags,
			);
			Texture { handle: _ret }
		}
	}
	/// * `width`:
	/// Width.
	/// * `height`:
	/// Height.
	/// * `depth`:
	/// Depth.
	/// * `has_mips`:
	/// Indicates that texture contains full mip-map chain.
	/// * `format`:
	/// Texture format. See: [TextureFormat].
	/// * `flags`:
	/// Texture creation (see [TextureFlags].), and sampler (see [SamplerFlags])
	/// flags. Default texture sampling mode is linear, and wrap mode is repeat.
	/// - [SamplerFlags::[U/V/W]_[MIRROR/CLAMP]] - Mirror or clamp to edge wrap
	///   mode.
	/// - [SamplerFlags::[MIN/MAG/MIP]_[POINT/ANISOTROPIC]] - Point or anisotropic
	///   sampling.
	/// * `mem`:
	/// Texture data. If `_mem` is non-NULL, created texture will be immutable. If
	/// `_mem` is NULL content of the texture is uninitialized. When `_numLayers` is more than
	/// 1, expected memory layout is texture and all mips together for each array element.
	pub fn create_texture_3d(
		width: u16,
		height: u16,
		depth: u16,
		has_mips: bool,
		format: TextureFormat,
		params: CreateTexture3DArgs,
	) -> Texture {
		unsafe {
			let _mem = if let Some(h) = params.mem {
				h.handle
			} else {
				std::ptr::null()
			};
			let _ret = bgfx_sys::bgfx_create_texture_3d(
				width,
				height,
				depth,
				has_mips,
				format as _,
				params.flags,
				_mem,
			);
			Texture { handle: _ret }
		}
	}
	/// * `size`:
	/// Cube side size.
	/// * `has_mips`:
	/// Indicates that texture contains full mip-map chain.
	/// * `num_layers`:
	/// Number of layers in texture array. Must be 1 if caps
	/// [CapsFlags::TEXTURE_2D_ARRAY] flag is not set.
	/// * `format`:
	/// Texture format. See: [TextureFormat].
	/// * `flags`:
	/// Texture creation (see [TextureFlags].), and sampler (see [SamplerFlags])
	/// flags. Default texture sampling mode is linear, and wrap mode is repeat.
	/// - [SamplerFlags::[U/V/W]_[MIRROR/CLAMP]] - Mirror or clamp to edge wrap
	///   mode.
	/// - [SamplerFlags::[MIN/MAG/MIP]_[POINT/ANISOTROPIC]] - Point or anisotropic
	///   sampling.
	/// * `mem`:
	/// Texture data. If `_mem` is non-NULL, created texture will be immutable. If
	/// `_mem` is NULL content of the texture is uninitialized. When `_numLayers` is more than
	/// 1, expected memory layout is texture and all mips together for each array element.
	pub fn create_texture_cube(
		size: u16,
		has_mips: bool,
		num_layers: u16,
		format: TextureFormat,
		params: CreateTextureCubeArgs,
	) -> Texture {
		unsafe {
			let _mem = if let Some(h) = params.mem {
				h.handle
			} else {
				std::ptr::null()
			};
			let _ret = bgfx_sys::bgfx_create_texture_cube(
				size,
				has_mips,
				num_layers,
				format as _,
				params.flags,
				_mem,
			);
			Texture { handle: _ret }
		}
	}
	/// * `handle`:
	/// Texture handle.
	/// * `layer`:
	/// Layer in texture array.
	/// * `mip`:
	/// Mip level.
	/// * `x`:
	/// X offset in texture.
	/// * `y`:
	/// Y offset in texture.
	/// * `width`:
	/// Width of texture block.
	/// * `height`:
	/// Height of texture block.
	/// * `mem`:
	/// Texture update data.
	/// * `pitch`:
	/// Pitch of input image (bytes). When _pitch is set to
	/// UINT16_MAX, it will be calculated internally based on _width.
	pub fn update_texture_2d(
		&self,
		layer: u16,
		mip: u8,
		x: u16,
		y: u16,
		width: u16,
		height: u16,
		mem: &Memory,
		pitch: u16,
	) {
		unsafe {
			bgfx_sys::bgfx_update_texture_2d(
				self.handle,
				layer,
				mip,
				x,
				y,
				width,
				height,
				mem.handle,
				pitch,
			);
		}
	}
	/// * `handle`:
	/// Texture handle.
	/// * `mip`:
	/// Mip level.
	/// * `x`:
	/// X offset in texture.
	/// * `y`:
	/// Y offset in texture.
	/// * `z`:
	/// Z offset in texture.
	/// * `width`:
	/// Width of texture block.
	/// * `height`:
	/// Height of texture block.
	/// * `depth`:
	/// Depth of texture block.
	/// * `mem`:
	/// Texture update data.
	pub fn update_texture_3d(
		&self,
		mip: u8,
		x: u16,
		y: u16,
		z: u16,
		width: u16,
		height: u16,
		depth: u16,
		mem: &Memory,
	) {
		unsafe {
			bgfx_sys::bgfx_update_texture_3d(
				self.handle,
				mip,
				x,
				y,
				z,
				width,
				height,
				depth,
				mem.handle,
			);
		}
	}
	/// * `handle`:
	/// Texture handle.
	/// * `layer`:
	/// Layer in texture array.
	/// * `side`:
	/// Cubemap side [CubeMapFlags::<POSITIVE or NEGATIVE>_<X, Y or Z>],
	///   where 0 is +X, 1 is -X, 2 is +Y, 3 is -Y, 4 is +Z, and 5 is -Z.
	///
	///				  +----------+
	///				  |-z	   2|
	///				  | ^  +y	|
	///				  | |		|	Unfolded cube:
	///				  | +---->+x |
	///	   +----------+----------+----------+----------+
	///	   |+y	   1|+y	   4|+y	   0|+y	   5|
	///	   | ^  -x	| ^  +z	| ^  +x	| ^  -z	|
	///	   | |		| |		| |		| |		|
	///	   | +---->+z | +---->+x | +---->-z | +---->-x |
	///	   +----------+----------+----------+----------+
	///				  |+z	   3|
	///				  | ^  -y	|
	///				  | |		|
	///				  | +---->+x |
	///				  +----------+
	/// * `mip`:
	/// Mip level.
	/// * `x`:
	/// X offset in texture.
	/// * `y`:
	/// Y offset in texture.
	/// * `width`:
	/// Width of texture block.
	/// * `height`:
	/// Height of texture block.
	/// * `mem`:
	/// Texture update data.
	/// * `pitch`:
	/// Pitch of input image (bytes). When _pitch is set to
	/// UINT16_MAX, it will be calculated internally based on _width.
	pub fn update_texture_cube(
		&self,
		layer: u16,
		side: u8,
		mip: u8,
		x: u16,
		y: u16,
		width: u16,
		height: u16,
		mem: &Memory,
		pitch: u16,
	) {
		unsafe {
			bgfx_sys::bgfx_update_texture_cube(
				self.handle,
				layer,
				side,
				mip,
				x,
				y,
				width,
				height,
				mem.handle,
				pitch,
			);
		}
	}
	/// * `handle`:
	/// Texture handle.
	/// * `name`:
	/// Texture name.
	/// * `len`:
	/// Texture name length (if length is INT32_MAX, it's expected
	/// that _name is zero terminated string.
	pub fn set_name(&self, name: &str) {
		unsafe {
			bgfx_sys::bgfx_set_texture_name(self.handle, name.as_ptr() as _, name.len() as i32)
		}
	}
	/// * `handle`:
	/// Frame buffer handle.
	/// * `attachment`:
	pub fn get_texture(handle: &FrameBuffer, attachment: u8) -> Texture {
		unsafe {
			let _ret = bgfx_sys::bgfx_get_texture(handle.handle, attachment);
			Texture { handle: _ret }
		}
	}
}

impl Drop for Texture {
	fn drop(&mut self) {
		unsafe {
			bgfx_sys::bgfx_destroy_texture(self.handle);
		}
	}
}

impl Uniform {
	/// * `name`:
	/// Uniform name in shader.
	/// * `type_r`:
	/// Type of uniform (See: `bgfx::UniformType`).
	/// * `num`:
	/// Number of elements in array.
	pub fn create_uniform(name: &i8, type_r: UniformType, num: u16) -> Uniform {
		unsafe {
			let _ret = bgfx_sys::bgfx_create_uniform(name as *const i8 as *const ::std::os::raw::c_char, type_r as _, num);
			Uniform { handle: _ret }
		}
	}
	/// * `handle`:
	/// Handle to uniform object.
	/// * `info`:
	/// Uniform info.
	pub fn get_uniform_info(&self, info: &mut UniformInfo) {
		unsafe {
			let _info = std::mem::transmute(info);
			bgfx_sys::bgfx_get_uniform_info(self.handle, _info);
		}
	}
	/// * `handle`:
	/// Uniform.
	/// * `value`:
	/// Pointer to uniform data.
	/// * `num`:
	/// Number of elements. Passing `UINT16_MAX` will
	/// use the _num passed on uniform creation.
	pub fn set_uniform(&self, value: &c_void, num: u16) {
		unsafe {
			bgfx_sys::bgfx_set_uniform(self.handle, value, num);
		}
	}
}

impl Drop for Uniform {
	fn drop(&mut self) {
		unsafe {
			bgfx_sys::bgfx_destroy_uniform(self.handle);
		}
	}
}

impl VertexBuffer {
	/// * `mem`:
	/// Vertex buffer data.
	/// * `layout`:
	/// Vertex layout.
	/// * `flags`:
	/// Buffer creation flags.
	///  - [BufferFlags::NONE] - No flags.
	///  - [BufferFlags::COMPUTE_READ] - Buffer will be read from by compute shader.
	///  - [BufferFlags::COMPUTE_WRITE] - Buffer will be written into by compute shader. When buffer
	///	  is created with [BufferFlags::COMPUTE_WRITE] flag it cannot be updated from CPU.
	///  - [BufferFlags::COMPUTE_READ_WRITE] - Buffer will be used for read/write by compute shader.
	///  - [BufferFlags::ALLOW_RESIZE] - Buffer will resize on buffer update if a different amount of
	///	  data is passed. If this flag is not specified, and more data is passed on update, the buffer
	///	  will be trimmed to fit the existing buffer size. This flag has effect only on dynamic buffers.
	///  - [BufferFlags::INDEX32] - Buffer is using 32-bit indices. This flag has effect only on index buffers.
	pub fn create_vertex_buffer(
		mem: &Memory,
		layout: &BuiltVertexLayout,
		flags: u16,
	) -> VertexBuffer {
		unsafe {
			let _layout = std::mem::transmute(layout);
			let _ret = bgfx_sys::bgfx_create_vertex_buffer(mem.handle, _layout, flags);
			VertexBuffer { handle: _ret }
		}
	}
	/// * `handle`:
	/// Static vertex buffer handle.
	/// * `name`:
	/// Static vertex buffer name.
	/// * `len`:
	/// Static vertex buffer name length (if length is INT32_MAX, it's expected
	/// that _name is zero terminated string.
	pub fn set_name(&self, name: &str) {
		unsafe {
			bgfx_sys::bgfx_set_vertex_buffer_name(
				self.handle,
				name.as_ptr() as _,
				name.len() as i32,
			)
		}
	}
	/// * `handle`:
	/// Vertex buffer.
	/// * `start_vertex`:
	/// First instance data.
	/// * `num`:
	/// Number of data instances.
	pub fn set_instance_data_from_vertex_buffer(&self, start_vertex: u32, num: u32) {
		unsafe {
			bgfx_sys::bgfx_set_instance_data_from_vertex_buffer(self.handle, start_vertex, num);
		}
	}
}

impl Drop for VertexBuffer {
	fn drop(&mut self) {
		unsafe {
			bgfx_sys::bgfx_destroy_vertex_buffer(self.handle);
		}
	}
}

#[allow(dead_code)]
pub struct BuiltVertexLayout(VertexLayoutBuilder);

impl VertexLayout {
	/// * `layout`:
	/// Vertex layout.
	pub fn create_vertex_layout(layout: &BuiltVertexLayout) -> VertexLayout {
		unsafe {
			let _layout = std::mem::transmute(layout);
			let _ret = bgfx_sys::bgfx_create_vertex_layout(_layout);
			VertexLayout { handle: _ret }
		}
	}
}

impl Drop for VertexLayout {
	fn drop(&mut self) {
		unsafe {
			bgfx_sys::bgfx_destroy_vertex_layout(self.handle);
		}
	}
}

impl CapsGPU {
	pub fn new() -> CapsGPU {
		let t = MaybeUninit::<CapsGPU>::zeroed();
		let t = unsafe { t.assume_init() };
		t
	}
}

impl CapsLimits {
	pub fn new() -> CapsLimits {
		let t = MaybeUninit::<CapsLimits>::zeroed();
		let t = unsafe { t.assume_init() };
		t
	}
}

impl Caps {
	pub fn new() -> Caps {
		let t = MaybeUninit::<Caps>::zeroed();
		let t = unsafe { t.assume_init() };
		t
	}
}

impl InternalData {
	pub fn new() -> InternalData {
		let t = MaybeUninit::<InternalData>::zeroed();
		let t = unsafe { t.assume_init() };
		t
	}
}

impl PlatformData {
	pub fn new() -> PlatformData {
		let t = MaybeUninit::<PlatformData>::zeroed();
		let t = unsafe { t.assume_init() };
		t
	}
}

impl Resolution {
	pub fn new() -> Resolution {
		let t = MaybeUninit::<Resolution>::zeroed();
		let t = unsafe { t.assume_init() };
		t
	}
}

impl InitLimits {
	pub fn new() -> InitLimits {
		let t = MaybeUninit::<InitLimits>::zeroed();
		let t = unsafe { t.assume_init() };
		t
	}
}

impl Init {
	pub fn new() -> Init {
		let t = MaybeUninit::<Init>::zeroed();
		let t = unsafe { t.assume_init() };
		unsafe {
			let _init = std::mem::transmute(&t);
			bgfx_sys::bgfx_init_ctor(_init);
		}
		t
	}
}

impl Memory {
	pub fn new() -> Memory {
		let t = MaybeUninit::<Memory>::zeroed();
		let t = unsafe { t.assume_init() };
		t
	}
}

impl TransientIndexBuffer {
	pub fn new() -> TransientIndexBuffer {
		let t = MaybeUninit::<TransientIndexBuffer>::zeroed();
		let t = unsafe { t.assume_init() };
		t
	}
}

impl TransientVertexBuffer {
	pub fn new() -> TransientVertexBuffer {
		let t = MaybeUninit::<TransientVertexBuffer>::zeroed();
		let t = unsafe { t.assume_init() };
		t
	}
}

impl InstanceDataBuffer {
	pub fn new() -> InstanceDataBuffer {
		let t = MaybeUninit::<InstanceDataBuffer>::zeroed();
		let t = unsafe { t.assume_init() };
		t
	}
}

impl TextureInfo {
	pub fn new() -> TextureInfo {
		let t = MaybeUninit::<TextureInfo>::zeroed();
		let t = unsafe { t.assume_init() };
		t
	}
}

impl UniformInfo {
	pub fn new() -> UniformInfo {
		let t = MaybeUninit::<UniformInfo>::zeroed();
		let t = unsafe { t.assume_init() };
		t
	}
}

impl Attachment {
	pub fn new() -> Attachment {
		let t = MaybeUninit::<Attachment>::zeroed();
		let t = unsafe { t.assume_init() };
		t
	}

	/// * `handle`:
	/// Render target texture handle.
	/// * `access`:
	/// Access. See [Access].
	/// * `layer`:
	/// Cubemap side or depth layer/slice to use.
	/// * `num_layers`:
	/// Number of texture layer/slice(s) in array to use.
	/// * `mip`:
	/// Mip level.
	/// * `resolve`:
	/// Resolve flags. See: [ResolveFlags]
	pub fn init(&self, handle: &Texture, params: InitArgs) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_attachment_init(
				_self,
				handle.handle,
				params.access as _,
				params.layer,
				params.num_layers,
				params.mip,
				params.resolve,
			);
		}
	}
}

impl Transform {
	pub fn new() -> Transform {
		let t = MaybeUninit::<Transform>::zeroed();
		let t = unsafe { t.assume_init() };
		t
	}
}

impl ViewStats {
	pub fn new() -> ViewStats {
		let t = MaybeUninit::<ViewStats>::zeroed();
		let t = unsafe { t.assume_init() };
		t
	}
}

impl EncoderStats {
	pub fn new() -> EncoderStats {
		let t = MaybeUninit::<EncoderStats>::zeroed();
		let t = unsafe { t.assume_init() };
		t
	}
}

impl Stats {
	pub fn new() -> Stats {
		let t = MaybeUninit::<Stats>::zeroed();
		let t = unsafe { t.assume_init() };
		t
	}
}

impl VertexLayoutBuilder {
	pub fn new() -> VertexLayoutBuilder {
		let t = MaybeUninit::<VertexLayoutBuilder>::zeroed();
		let t = unsafe { t.assume_init() };
		t
	}

	/// * `renderer_type`:
	/// Renderer backend type. See: `bgfx::RendererType`
	pub fn begin(&self, renderer_type: RendererType) -> &'static VertexLayout {
		unsafe {
			let _self = std::mem::transmute(self);
			let _ret = bgfx_sys::bgfx_vertex_layout_begin(_self, renderer_type as _);
			std::mem::transmute(_ret)
		}
	}
	/// * `attrib`:
	/// Attribute semantics. See: `bgfx::Attrib`
	/// * `num`:
	/// Number of elements 1, 2, 3 or 4.
	/// * `type_r`:
	/// Element type.
	/// * `normalized`:
	/// When using fixed point AttribType (f.e. Uint8)
	/// value will be normalized for vertex shader usage. When normalized
	/// is set to true, AttribType::Uint8 value in range 0-255 will be
	/// in range 0.0-1.0 in vertex shader.
	/// * `as_int`:
	/// Packaging rule for vertexPack, vertexUnpack, and
	/// vertexConvert for AttribType::Uint8 and AttribType::Int16.
	/// Unpacking code must be implemented inside vertex shader.
	pub fn add(
		&self,
		attrib: Attrib,
		num: u8,
		type_r: AttribType,
		params: AddArgs,
	) -> &'static VertexLayout {
		unsafe {
			let _self = std::mem::transmute(self);
			let _ret = bgfx_sys::bgfx_vertex_layout_add(
				_self,
				attrib as _,
				num,
				type_r as _,
				params.normalized,
				params.as_int,
			);
			std::mem::transmute(_ret)
		}
	}
	/// * `attrib`:
	/// Attribute semantics. See: `bgfx::Attrib`
	pub fn has(&self, attrib: Attrib) -> bool {
		unsafe {
			let _self = std::mem::transmute(self);
			let _ret = bgfx_sys::bgfx_vertex_layout_has(_self, attrib as _);
			_ret
		}
	}
	/// * `num`:
	/// Number of bytes to skip.
	pub fn skip(&self, num: u8) -> &'static VertexLayout {
		unsafe {
			let _self = std::mem::transmute(self);
			let _ret = bgfx_sys::bgfx_vertex_layout_skip(_self, num);
			std::mem::transmute(_ret)
		}
	}
	pub fn end(&self) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_vertex_layout_end(_self);
		}
	}
	/// * `attrib`:
	/// Attribute semantics. See: `bgfx::Attrib`
	pub fn get_offset(&self, attrib: Attrib) -> u16 {
		unsafe {
			let _self = std::mem::transmute(self);
			let _ret = bgfx_sys::bgfx_vertex_layout_get_offset(_self, attrib as _);
			_ret
		}
	}
	pub fn get_stride(&self) -> u16 {
		unsafe {
			let _self = std::mem::transmute(self);
			let _ret = bgfx_sys::bgfx_vertex_layout_get_stride(_self);
			_ret
		}
	}
	/// * `num`:
	/// Number of vertices.
	pub fn get_size(&self, num: u32) -> u32 {
		unsafe {
			let _self = std::mem::transmute(self);
			let _ret = bgfx_sys::bgfx_vertex_layout_get_size(_self, num);
			_ret
		}
	}
}

impl Encoder {
	pub fn new() -> Encoder {
		let t = MaybeUninit::<Encoder>::zeroed();
		let t = unsafe { t.assume_init() };
		t
	}

	/// * `name`:
	/// Marker name.
	/// * `len`:
	/// Marker name length (if length is INT32_MAX, it's expected
	/// that _name is zero terminated string.
	pub fn set_marker(&self, name: &i8, len: i32) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_set_marker(_self, name as *const i8 as *const ::std::os::raw::c_char, len);
		}
	}
	/// * `state`:
	/// State flags. Default state for primitive type is
	///   triangles. See: [StateFlags::DEFAULT].
	///   - [StateDepthTestFlags] - Depth test function.
	///   - [StateBlendFlags] - See remark 1 about BGFX_STATE_BLEND_FUNC.
	///   - [StateBlendEquationFlags] - See remark 2.
	///   - [StateCullFlags] - Backface culling mode.
	///   - [StateWriteFlags] - Enable R, G, B, A or Z write.
	///   - [StateFlags::MSAA] - Enable hardware multisample antialiasing.
	///   - [StatePtFlags::[TRISTRIP/LINES/POINTS]] - Primitive type.
	/// * `rgba`:
	/// Sets blend factor used by [StateBlendFlags::FACTOR] and
	///   [StateBlendFlags::INV_FACTOR] blend modes.
	pub fn set_state(&self, state: u64, rgba: u32) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_set_state(_self, state, rgba);
		}
	}
	/// * `handle`:
	/// Occlusion query handle.
	/// * `visible`:
	/// Render if occlusion query is visible.
	pub fn set_condition(&self, handle: &OcclusionQuery, visible: bool) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_set_condition(_self, handle.handle, visible);
		}
	}
	/// * `fstencil`:
	/// Front stencil state.
	/// * `bstencil`:
	/// Back stencil state. If back is set to [StencilFlags::NONE]
	/// _fstencil is applied to both front and back facing primitives.
	pub fn set_stencil(&self, fstencil: u32, bstencil: u32) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_set_stencil(_self, fstencil, bstencil);
		}
	}
	/// * `x`:
	/// Position x from the left corner of the window.
	/// * `y`:
	/// Position y from the top corner of the window.
	/// * `width`:
	/// Width of view scissor region.
	/// * `height`:
	/// Height of view scissor region.
	pub fn set_scissor(&self, x: u16, y: u16, width: u16, height: u16) -> u16 {
		unsafe {
			let _self = std::mem::transmute(self);
			let _ret = bgfx_sys::bgfx_encoder_set_scissor(_self, x, y, width, height);
			_ret
		}
	}
	/// * `cache`:
	/// Index in scissor cache.
	pub fn set_scissor_cached(&self, cache: u16) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_set_scissor_cached(_self, cache);
		}
	}
	/// * `transform`:
	/// Pointer to `Transform` structure.
	/// * `num`:
	/// Number of matrices.
	pub fn alloc_transform(&self, transform: &mut Transform, num: u16) -> u32 {
		unsafe {
			let _self = std::mem::transmute(self);
			let _transform = std::mem::transmute(transform);
			let _ret = bgfx_sys::bgfx_encoder_alloc_transform(_self, _transform, num);
			_ret
		}
	}
	/// * `handle`:
	/// Uniform.
	/// * `value`:
	/// Pointer to uniform data.
	/// * `num`:
	/// Number of elements. Passing `UINT16_MAX` will
	/// use the _num passed on uniform creation.
	pub fn set_uniform(&self, handle: &Uniform, value: &c_void, num: u16) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_set_uniform(_self, handle.handle, value, num);
		}
	}
	/// * `handle`:
	/// Index buffer.
	/// * `first_index`:
	/// First index to render.
	/// * `num_indices`:
	/// Number of indices to render.
	pub fn set_index_buffer(&self, handle: &IndexBuffer, first_index: u32, num_indices: u32) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_set_index_buffer(_self, handle.handle, first_index, num_indices);
		}
	}
	/// * `handle`:
	/// Dynamic index buffer.
	/// * `first_index`:
	/// First index to render.
	/// * `num_indices`:
	/// Number of indices to render.
	pub fn set_dynamic_index_buffer(
		&self,
		handle: &DynamicIndexBuffer,
		first_index: u32,
		num_indices: u32,
	) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_set_dynamic_index_buffer(
				_self,
				handle.handle,
				first_index,
				num_indices,
			);
		}
	}
	/// * `tib`:
	/// Transient index buffer.
	/// * `first_index`:
	/// First index to render.
	/// * `num_indices`:
	/// Number of indices to render.
	pub fn set_transient_index_buffer(
		&self,
		tib: &TransientIndexBuffer,
		first_index: u32,
		num_indices: u32,
	) {
		unsafe {
			let _self = std::mem::transmute(self);
			let _tib = std::mem::transmute(tib);
			bgfx_sys::bgfx_encoder_set_transient_index_buffer(
				_self,
				_tib,
				first_index,
				num_indices,
			);
		}
	}
	/// * `stream`:
	/// Vertex stream.
	/// * `handle`:
	/// Vertex buffer.
	/// * `start_vertex`:
	/// First vertex to render.
	/// * `num_vertices`:
	/// Number of vertices to render.
	pub fn set_vertex_buffer(
		&self,
		stream: u8,
		handle: &VertexBuffer,
		start_vertex: u32,
		num_vertices: u32,
	) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_set_vertex_buffer(
				_self,
				stream,
				handle.handle,
				start_vertex,
				num_vertices,
			);
		}
	}
	/// * `stream`:
	/// Vertex stream.
	/// * `handle`:
	/// Vertex buffer.
	/// * `start_vertex`:
	/// First vertex to render.
	/// * `num_vertices`:
	/// Number of vertices to render.
	/// * `layout_handle`:
	/// Vertex layout for aliasing vertex buffer. If invalid
	/// handle is used, vertex layout used for creation
	/// of vertex buffer will be used.
	pub fn set_vertex_buffer_with_layout(
		&self,
		stream: u8,
		handle: &VertexBuffer,
		start_vertex: u32,
		num_vertices: u32,
		layout_handle: &VertexLayout,
	) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_set_vertex_buffer_with_layout(
				_self,
				stream,
				handle.handle,
				start_vertex,
				num_vertices,
				layout_handle.handle,
			);
		}
	}
	/// * `stream`:
	/// Vertex stream.
	/// * `handle`:
	/// Dynamic vertex buffer.
	/// * `start_vertex`:
	/// First vertex to render.
	/// * `num_vertices`:
	/// Number of vertices to render.
	/// Vertex stream.
	/// Dynamic vertex buffer.
	/// First vertex to render.
	/// Number of vertices to render.
	/// Vertex layout for aliasing vertex buffer. If invalid
	/// handle is used, vertex layout used for creation
	/// of vertex buffer will be used.
	pub fn set_dynamic_vertex_buffer(
		&self,
		stream: u8,
		handle: &DynamicVertexBuffer,
		start_vertex: u32,
		num_vertices: u32,
	) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_set_dynamic_vertex_buffer(
				_self,
				stream,
				handle.handle,
				start_vertex,
				num_vertices,
			);
		}
	}
	/// * `stream`:
	/// Vertex stream.
	/// * `handle`:
	/// Dynamic vertex buffer.
	/// * `start_vertex`:
	/// First vertex to render.
	/// * `num_vertices`:
	/// Number of vertices to render.
	/// * `layout_handle`:
	/// Vertex layout for aliasing vertex buffer. If invalid
	/// handle is used, vertex layout used for creation
	/// of vertex buffer will be used.
	pub fn set_dynamic_vertex_buffer_with_layout(
		&self,
		stream: u8,
		handle: &DynamicVertexBuffer,
		start_vertex: u32,
		num_vertices: u32,
		layout_handle: &VertexLayout,
	) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_set_dynamic_vertex_buffer_with_layout(
				_self,
				stream,
				handle.handle,
				start_vertex,
				num_vertices,
				layout_handle.handle,
			);
		}
	}
	/// * `stream`:
	/// Vertex stream.
	/// * `tvb`:
	/// Transient vertex buffer.
	/// * `start_vertex`:
	/// First vertex to render.
	/// * `num_vertices`:
	/// Number of vertices to render.
	pub fn set_transient_vertex_buffer(
		&self,
		stream: u8,
		tvb: &TransientVertexBuffer,
		start_vertex: u32,
		num_vertices: u32,
	) {
		unsafe {
			let _self = std::mem::transmute(self);
			let _tvb = std::mem::transmute(tvb);
			bgfx_sys::bgfx_encoder_set_transient_vertex_buffer(
				_self,
				stream,
				_tvb,
				start_vertex,
				num_vertices,
			);
		}
	}
	/// * `stream`:
	/// Vertex stream.
	/// * `tvb`:
	/// Transient vertex buffer.
	/// * `start_vertex`:
	/// First vertex to render.
	/// * `num_vertices`:
	/// Number of vertices to render.
	/// * `layout_handle`:
	/// Vertex layout for aliasing vertex buffer. If invalid
	/// handle is used, vertex layout used for creation
	/// of vertex buffer will be used.
	pub fn set_transient_vertex_buffer_with_layout(
		&self,
		stream: u8,
		tvb: &TransientVertexBuffer,
		start_vertex: u32,
		num_vertices: u32,
		layout_handle: &VertexLayout,
	) {
		unsafe {
			let _self = std::mem::transmute(self);
			let _tvb = std::mem::transmute(tvb);
			bgfx_sys::bgfx_encoder_set_transient_vertex_buffer_with_layout(
				_self,
				stream,
				_tvb,
				start_vertex,
				num_vertices,
				layout_handle.handle,
			);
		}
	}
	/// * `num_vertices`:
	/// Number of vertices.
	pub fn set_vertex_count(&self, num_vertices: u32) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_set_vertex_count(_self, num_vertices);
		}
	}
	/// * `idb`:
	/// Transient instance data buffer.
	/// * `start`:
	/// First instance data.
	/// * `num`:
	/// Number of data instances.
	pub fn set_instance_data_buffer(&self, idb: &InstanceDataBuffer, start: u32, num: u32) {
		unsafe {
			let _self = std::mem::transmute(self);
			let _idb = std::mem::transmute(idb);
			bgfx_sys::bgfx_encoder_set_instance_data_buffer(_self, _idb, start, num);
		}
	}
	/// * `handle`:
	/// Vertex buffer.
	/// * `start_vertex`:
	/// First instance data.
	/// * `num`:
	/// Number of data instances.
	pub fn set_instance_data_from_vertex_buffer(
		&self,
		handle: &VertexBuffer,
		start_vertex: u32,
		num: u32,
	) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_set_instance_data_from_vertex_buffer(
				_self,
				handle.handle,
				start_vertex,
				num,
			);
		}
	}
	/// * `handle`:
	/// Dynamic vertex buffer.
	/// * `start_vertex`:
	/// First instance data.
	/// * `num`:
	/// Number of data instances.
	pub fn set_instance_data_from_dynamic_vertex_buffer(
		&self,
		handle: &DynamicVertexBuffer,
		start_vertex: u32,
		num: u32,
	) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_set_instance_data_from_dynamic_vertex_buffer(
				_self,
				handle.handle,
				start_vertex,
				num,
			);
		}
	}
	/// * `num_instances`:
	pub fn set_instance_count(&self, num_instances: u32) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_set_instance_count(_self, num_instances);
		}
	}
	/// * `stage`:
	/// Texture unit.
	/// * `sampler`:
	/// Program sampler.
	/// * `handle`:
	/// Texture handle.
	/// * `flags`:
	/// Texture sampling mode. Default value UINT32_MAX uses
	///   texture sampling settings from the texture.
	///   - [SamplerFlags::[U/V/W]_[MIRROR/CLAMP]] - Mirror or clamp to edge wrap
	///	 mode.
	///   - [SamplerFlags::[MIN/MAG/MIP]_[POINT/ANISOTROPIC]] - Point or anisotropic
	///	 sampling.
	pub fn set_texture(&self, stage: u8, sampler: &Uniform, handle: &Texture, flags: u32) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_set_texture(_self, stage, sampler.handle, handle.handle, flags);
		}
	}
	/// * `id`:
	/// View id.
	pub fn touch(&self, id: ViewId) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_touch(_self, id);
		}
	}
	/// * `id`:
	/// View id.
	/// * `program`:
	/// Program.
	/// * `depth`:
	/// Depth for sorting.
	/// * `flags`:
	/// Discard or preserve states. See [DiscardFlags].
	pub fn submit(&self, id: ViewId, program: &Program, params: SubmitArgs) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_submit(_self, id, program.handle, params.depth, params.flags);
		}
	}
	/// * `id`:
	/// View id.
	/// * `program`:
	/// Program.
	/// * `occlusion_query`:
	/// Occlusion query.
	/// * `depth`:
	/// Depth for sorting.
	/// * `flags`:
	/// Discard or preserve states. See [DiscardFlags].
	pub fn submit_occlusion_query(
		&self,
		id: ViewId,
		program: &Program,
		occlusion_query: &OcclusionQuery,
		params: SubmitOcclusionQueryArgs,
	) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_submit_occlusion_query(
				_self,
				id,
				program.handle,
				occlusion_query.handle,
				params.depth,
				params.flags,
			);
		}
	}
	/// * `id`:
	/// View id.
	/// * `program`:
	/// Program.
	/// * `indirect_handle`:
	/// Indirect buffer.
	/// * `start`:
	/// First element in indirect buffer.
	/// * `num`:
	/// Number of draws.
	/// * `depth`:
	/// Depth for sorting.
	/// * `flags`:
	/// Discard or preserve states. See [DiscardFlags].
	pub fn submit_indirect(
		&self,
		id: ViewId,
		program: &Program,
		indirect_handle: &IndirectBuffer,
		params: SubmitIndirectArgs,
	) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_submit_indirect(
				_self,
				id,
				program.handle,
				indirect_handle.handle,
				params.start,
				params.num,
				params.depth,
				params.flags,
			);
		}
	}
	/// * `id`:
	/// View id.
	/// * `program`:
	/// Program.
	/// * `indirect_handle`:
	/// Indirect buffer.
	/// * `start`:
	/// First element in indirect buffer.
	/// * `num_handle`:
	/// Buffer for number of draws. Must be
	///   created with [BufferFlags::INDEX32] and [BufferFlags::DRAW_INDIRECT].
	/// * `num_index`:
	/// Element in number buffer.
	/// * `num_max`:
	/// Max number of draws.
	/// * `depth`:
	/// Depth for sorting.
	/// * `flags`:
	/// Discard or preserve states. See [DiscardFlags].
	pub fn submit_indirect_count(
		&self,
		id: ViewId,
		program: &Program,
		indirect_handle: &IndirectBuffer,
		start: u32,
		num_handle: &IndexBuffer,
		params: SubmitIndirectCountArgs,
	) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_submit_indirect_count(
				_self,
				id,
				program.handle,
				indirect_handle.handle,
				start,
				num_handle.handle,
				params.num_index,
				params.num_max,
				params.depth,
				params.flags,
			);
		}
	}
	/// * `stage`:
	/// Compute stage.
	/// * `handle`:
	/// Index buffer handle.
	/// * `access`:
	/// Buffer access. See [Access].
	pub fn set_compute_index_buffer(&self, stage: u8, handle: &IndexBuffer, access: Access) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_set_compute_index_buffer(
				_self,
				stage,
				handle.handle,
				access as _,
			);
		}
	}
	/// * `stage`:
	/// Compute stage.
	/// * `handle`:
	/// Vertex buffer handle.
	/// * `access`:
	/// Buffer access. See [Access].
	pub fn set_compute_vertex_buffer(&self, stage: u8, handle: &VertexBuffer, access: Access) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_set_compute_vertex_buffer(
				_self,
				stage,
				handle.handle,
				access as _,
			);
		}
	}
	/// * `stage`:
	/// Compute stage.
	/// * `handle`:
	/// Dynamic index buffer handle.
	/// * `access`:
	/// Buffer access. See [Access].
	pub fn set_compute_dynamic_index_buffer(
		&self,
		stage: u8,
		handle: &DynamicIndexBuffer,
		access: Access,
	) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_set_compute_dynamic_index_buffer(
				_self,
				stage,
				handle.handle,
				access as _,
			);
		}
	}
	/// * `stage`:
	/// Compute stage.
	/// * `handle`:
	/// Dynamic vertex buffer handle.
	/// * `access`:
	/// Buffer access. See [Access].
	pub fn set_compute_dynamic_vertex_buffer(
		&self,
		stage: u8,
		handle: &DynamicVertexBuffer,
		access: Access,
	) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_set_compute_dynamic_vertex_buffer(
				_self,
				stage,
				handle.handle,
				access as _,
			);
		}
	}
	/// * `stage`:
	/// Compute stage.
	/// * `handle`:
	/// Indirect buffer handle.
	/// * `access`:
	/// Buffer access. See [Access].
	pub fn set_compute_indirect_buffer(&self, stage: u8, handle: &IndirectBuffer, access: Access) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_set_compute_indirect_buffer(
				_self,
				stage,
				handle.handle,
				access as _,
			);
		}
	}
	/// * `stage`:
	/// Compute stage.
	/// * `handle`:
	/// Texture handle.
	/// * `mip`:
	/// Mip level.
	/// * `access`:
	/// Image access. See [Access].
	/// * `format`:
	/// Texture format. See: [TextureFormat].
	pub fn set_image(
		&self,
		stage: u8,
		handle: &Texture,
		mip: u8,
		access: Access,
		format: TextureFormat,
	) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_set_image(
				_self,
				stage,
				handle.handle,
				mip,
				access as _,
				format as _,
			);
		}
	}
	/// * `id`:
	/// View id.
	/// * `program`:
	/// Compute program.
	/// * `num_x`:
	/// Number of groups X.
	/// * `num_y`:
	/// Number of groups Y.
	/// * `num_z`:
	/// Number of groups Z.
	/// * `flags`:
	/// Discard or preserve states. See [DiscardFlags].
	pub fn dispatch(&self, id: ViewId, program: &Program, params: DispatchArgs) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_dispatch(
				_self,
				id,
				program.handle,
				params.num_x,
				params.num_y,
				params.num_z,
				params.flags,
			);
		}
	}
	/// * `id`:
	/// View id.
	/// * `program`:
	/// Compute program.
	/// * `indirect_handle`:
	/// Indirect buffer.
	/// * `start`:
	/// First element in indirect buffer.
	/// * `num`:
	/// Number of dispatches.
	/// * `flags`:
	/// Discard or preserve states. See [DiscardFlags].
	pub fn dispatch_indirect(
		&self,
		id: ViewId,
		program: &Program,
		indirect_handle: &IndirectBuffer,
		params: DispatchIndirectArgs,
	) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_dispatch_indirect(
				_self,
				id,
				program.handle,
				indirect_handle.handle,
				params.start,
				params.num,
				params.flags,
			);
		}
	}
	/// * `flags`:
	/// Discard or preserve states. See [DiscardFlags].
	pub fn discard(&self, flags: u8) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_discard(_self, flags);
		}
	}
	/// * `id`:
	/// View id.
	/// * `dst`:
	/// Destination texture handle.
	/// * `dst_mip`:
	/// Destination texture mip level.
	/// * `dst_x`:
	/// Destination texture X position.
	/// * `dst_y`:
	/// Destination texture Y position.
	/// * `dst_z`:
	/// If texture is 2D this argument should be 0. If destination texture is cube
	/// this argument represents destination texture cube face. For 3D texture this argument
	/// represents destination texture Z position.
	/// * `src`:
	/// Source texture handle.
	/// * `src_mip`:
	/// Source texture mip level.
	/// * `src_x`:
	/// Source texture X position.
	/// * `src_y`:
	/// Source texture Y position.
	/// * `src_z`:
	/// If texture is 2D this argument should be 0. If source texture is cube
	/// this argument represents source texture cube face. For 3D texture this argument
	/// represents source texture Z position.
	/// * `width`:
	/// Width of region.
	/// * `height`:
	/// Height of region.
	/// * `depth`:
	/// If texture is 3D this argument represents depth of region, otherwise it's
	/// unused.
	pub fn blit(
		&self,
		id: ViewId,
		dst: &Texture,
		dst_mip: u8,
		dst_x: u16,
		dst_y: u16,
		dst_z: u16,
		src: &Texture,
		params: BlitArgs,
	) {
		unsafe {
			let _self = std::mem::transmute(self);
			bgfx_sys::bgfx_encoder_blit(
				_self,
				id,
				dst.handle,
				dst_mip,
				dst_x,
				dst_y,
				dst_z,
				src.handle,
				params.src_mip,
				params.src_x,
				params.src_y,
				params.src_z,
				params.width,
				params.height,
				params.depth,
			);
		}
	}
}

/// * `init`:
/// Initialization parameters. See: `bgfx::Init` for more info.
pub fn init(init: &Init) -> bool {
	unsafe {
		let _init = std::mem::transmute(init);
		let _ret = bgfx_sys::bgfx_init(_init);
		_ret
	}
}
pub fn shutdown() {
	unsafe {
		bgfx_sys::bgfx_shutdown();
	}
}
/// * `width`:
/// Back-buffer width.
/// * `height`:
/// Back-buffer height.
/// * `flags`:
/// See: [ResetFlags] for more info.
///   - [ResetFlags::NONE] - No reset flags.
///   - [ResetFlags::FULLSCREEN] - Not supported yet.
///   - [ResetMsaaFlags::X[2/4/8/16]] - Enable 2, 4, 8 or 16 x MSAA.
///   - [ResetFlags::VSYNC] - Enable V-Sync.
///   - [ResetFlags::MAXANISOTROPY] - Turn on/off max anisotropy.
///   - [ResetFlags::CAPTURE] - Begin screen capture.
///   - [ResetFlags::FLUSH_AFTER_RENDER] - Flush rendering after submitting to GPU.
///   - [ResetFlags::FLIP_AFTER_RENDER] - This flag  specifies where flip
///	 occurs. Default behaviour is that flip occurs before rendering new
///	 frame. This flag only has effect when `BGFX_CONFIG_MULTITHREADED=0`.
///   - [ResetFlags::SRGB_BACKBUFFER] - Enable sRGB back-buffer.
/// * `format`:
/// Texture format. See: [TextureFormat].
pub fn reset(width: u32, height: u32, params: ResetArgs) {
	unsafe {
		bgfx_sys::bgfx_reset(width, height, params.flags, params.format as _);
	}
}
/// * `capture`:
/// Capture frame with graphics debugger.
pub fn frame(capture: bool) -> u32 {
	unsafe {
		let _ret = bgfx_sys::bgfx_frame(capture);
		_ret
	}
}
pub fn get_renderer_type() -> RendererType {
	unsafe {
		let _ret = bgfx_sys::bgfx_get_renderer_type();
		std::mem::transmute(_ret)
	}
}
pub fn get_caps() -> &'static Caps {
	unsafe {
		let _ret = bgfx_sys::bgfx_get_caps();
		std::mem::transmute(_ret)
	}
}
pub fn get_stats() -> &'static Stats {
	unsafe {
		let _ret = bgfx_sys::bgfx_get_stats();
		std::mem::transmute(_ret)
	}
}
/// * `debug`:
/// Available flags:
///   - [DebugFlags::IFH] - Infinitely fast hardware. When this flag is set
///	 all rendering calls will be skipped. This is useful when profiling
///	 to quickly assess potential bottlenecks between CPU and GPU.
///   - [DebugFlags::PROFILER] - Enable profiler.
///   - [DebugFlags::STATS] - Display internal statistics.
///   - [DebugFlags::TEXT] - Display debug text.
///   - [DebugFlags::WIREFRAME] - Wireframe rendering. All rendering
///	 primitives will be rendered as lines.
pub fn set_debug(debug: u32) {
	unsafe {
		bgfx_sys::bgfx_set_debug(debug);
	}
}
/// * `attr`:
/// Background color.
/// * `small`:
/// Default 8x16 or 8x8 font.
pub fn dbg_text_clear(params: DbgTextClearArgs) {
	unsafe {
		bgfx_sys::bgfx_dbg_text_clear(params.attr, params.small);
	}
}
/// * `x`:
/// Position x from the left corner of the window.
/// * `y`:
/// Position y from the top corner of the window.
/// * `width`:
/// Image width.
/// * `height`:
/// Image height.
/// * `data`:
/// Raw image data (character/attribute raw encoding).
/// * `pitch`:
/// Image pitch in bytes.
pub fn dbg_text_image(x: u16, y: u16, width: u16, height: u16, data: &c_void, pitch: u16) {
	unsafe {
		bgfx_sys::bgfx_dbg_text_image(x, y, width, height, data, pitch);
	}
}
/// * `mem`:
/// Index buffer data.
/// * `flags`:
/// Buffer creation flags.
///   - [BufferFlags::NONE] - No flags.
///   - [BufferFlags::COMPUTE_READ] - Buffer will be read from by compute shader.
///   - [BufferFlags::COMPUTE_WRITE] - Buffer will be written into by compute shader. When buffer
///	   is created with [BufferFlags::COMPUTE_WRITE] flag it cannot be updated from CPU.
///   - [BufferFlags::COMPUTE_READ_WRITE] - Buffer will be used for read/write by compute shader.
///   - [BufferFlags::ALLOW_RESIZE] - Buffer will resize on buffer update if a different amount of
///	   data is passed. If this flag is not specified, and more data is passed on update, the buffer
///	   will be trimmed to fit the existing buffer size. This flag has effect only on dynamic
///	   buffers.
///   - [BufferFlags::INDEX32] - Buffer is using 32-bit indices. This flag has effect only on
///	   index buffers.
pub fn create_index_buffer(mem: &Memory, flags: u16) -> IndexBuffer {
	unsafe {
		let _ret = bgfx_sys::bgfx_create_index_buffer(mem.handle, flags);
		IndexBuffer { handle: _ret }
	}
}
/// * `layout`:
/// Vertex layout.
pub fn create_vertex_layout(layout: &BuiltVertexLayout) -> VertexLayout {
	unsafe {
		let _layout = std::mem::transmute(layout);
		let _ret = bgfx_sys::bgfx_create_vertex_layout(_layout);
		VertexLayout { handle: _ret }
	}
}
/// * `mem`:
/// Vertex buffer data.
/// * `layout`:
/// Vertex layout.
/// * `flags`:
/// Buffer creation flags.
///  - [BufferFlags::NONE] - No flags.
///  - [BufferFlags::COMPUTE_READ] - Buffer will be read from by compute shader.
///  - [BufferFlags::COMPUTE_WRITE] - Buffer will be written into by compute shader. When buffer
///	  is created with [BufferFlags::COMPUTE_WRITE] flag it cannot be updated from CPU.
///  - [BufferFlags::COMPUTE_READ_WRITE] - Buffer will be used for read/write by compute shader.
///  - [BufferFlags::ALLOW_RESIZE] - Buffer will resize on buffer update if a different amount of
///	  data is passed. If this flag is not specified, and more data is passed on update, the buffer
///	  will be trimmed to fit the existing buffer size. This flag has effect only on dynamic buffers.
///  - [BufferFlags::INDEX32] - Buffer is using 32-bit indices. This flag has effect only on index buffers.
pub fn create_vertex_buffer(mem: &Memory, layout: &BuiltVertexLayout, flags: u16) -> VertexBuffer {
	unsafe {
		let _layout = std::mem::transmute(layout);
		let _ret = bgfx_sys::bgfx_create_vertex_buffer(mem.handle, _layout, flags);
		VertexBuffer { handle: _ret }
	}
}
/// * `num`:
/// Number of indices.
/// * `flags`:
/// Buffer creation flags.
///   - [BufferFlags::NONE] - No flags.
///   - [BufferFlags::COMPUTE_READ] - Buffer will be read from by compute shader.
///   - [BufferFlags::COMPUTE_WRITE] - Buffer will be written into by compute shader. When buffer
///	   is created with [BufferFlags::COMPUTE_WRITE] flag it cannot be updated from CPU.
///   - [BufferFlags::COMPUTE_READ_WRITE] - Buffer will be used for read/write by compute shader.
///   - [BufferFlags::ALLOW_RESIZE] - Buffer will resize on buffer update if a different amount of
///	   data is passed. If this flag is not specified, and more data is passed on update, the buffer
///	   will be trimmed to fit the existing buffer size. This flag has effect only on dynamic
///	   buffers.
///   - [BufferFlags::INDEX32] - Buffer is using 32-bit indices. This flag has effect only on
///	   index buffers.
pub fn create_dynamic_index_buffer(num: u32, flags: u16) -> DynamicIndexBuffer {
	unsafe {
		let _ret = bgfx_sys::bgfx_create_dynamic_index_buffer(num, flags);
		DynamicIndexBuffer { handle: _ret }
	}
}
/// * `mem`:
/// Index buffer data.
/// * `flags`:
/// Buffer creation flags.
///   - [BufferFlags::NONE] - No flags.
///   - [BufferFlags::COMPUTE_READ] - Buffer will be read from by compute shader.
///   - [BufferFlags::COMPUTE_WRITE] - Buffer will be written into by compute shader. When buffer
///	   is created with [BufferFlags::COMPUTE_WRITE] flag it cannot be updated from CPU.
///   - [BufferFlags::COMPUTE_READ_WRITE] - Buffer will be used for read/write by compute shader.
///   - [BufferFlags::ALLOW_RESIZE] - Buffer will resize on buffer update if a different amount of
///	   data is passed. If this flag is not specified, and more data is passed on update, the buffer
///	   will be trimmed to fit the existing buffer size. This flag has effect only on dynamic
///	   buffers.
///   - [BufferFlags::INDEX32] - Buffer is using 32-bit indices. This flag has effect only on
///	   index buffers.
pub fn create_dynamic_index_buffer_mem(mem: &Memory, flags: u16) -> DynamicIndexBuffer {
	unsafe {
		let _ret = bgfx_sys::bgfx_create_dynamic_index_buffer_mem(mem.handle, flags);
		DynamicIndexBuffer { handle: _ret }
	}
}
/// * `handle`:
/// Dynamic index buffer handle.
/// * `start_index`:
/// Start index.
/// * `mem`:
/// Index buffer data.
pub fn update_dynamic_index_buffer(handle: &DynamicIndexBuffer, start_index: u32, mem: &Memory) {
	unsafe {
		bgfx_sys::bgfx_update_dynamic_index_buffer(handle.handle, start_index, mem.handle);
	}
}
/// * `num`:
/// Number of vertices.
/// * `layout`:
/// Vertex layout.
/// * `flags`:
/// Buffer creation flags.
///   - [BufferFlags::NONE] - No flags.
///   - [BufferFlags::COMPUTE_READ] - Buffer will be read from by compute shader.
///   - [BufferFlags::COMPUTE_WRITE] - Buffer will be written into by compute shader. When buffer
///	   is created with [BufferFlags::COMPUTE_WRITE] flag it cannot be updated from CPU.
///   - [BufferFlags::COMPUTE_READ_WRITE] - Buffer will be used for read/write by compute shader.
///   - [BufferFlags::ALLOW_RESIZE] - Buffer will resize on buffer update if a different amount of
///	   data is passed. If this flag is not specified, and more data is passed on update, the buffer
///	   will be trimmed to fit the existing buffer size. This flag has effect only on dynamic
///	   buffers.
///   - [BufferFlags::INDEX32] - Buffer is using 32-bit indices. This flag has effect only on
///	   index buffers.
pub fn create_dynamic_vertex_buffer(
	num: u32,
	layout: &BuiltVertexLayout,
	flags: u16,
) -> DynamicVertexBuffer {
	unsafe {
		let _layout = std::mem::transmute(layout);
		let _ret = bgfx_sys::bgfx_create_dynamic_vertex_buffer(num, _layout, flags);
		DynamicVertexBuffer { handle: _ret }
	}
}
/// * `mem`:
/// Vertex buffer data.
/// * `layout`:
/// Vertex layout.
/// * `flags`:
/// Buffer creation flags.
///   - [BufferFlags::NONE] - No flags.
///   - [BufferFlags::COMPUTE_READ] - Buffer will be read from by compute shader.
///   - [BufferFlags::COMPUTE_WRITE] - Buffer will be written into by compute shader. When buffer
///	   is created with [BufferFlags::COMPUTE_WRITE] flag it cannot be updated from CPU.
///   - [BufferFlags::COMPUTE_READ_WRITE] - Buffer will be used for read/write by compute shader.
///   - [BufferFlags::ALLOW_RESIZE] - Buffer will resize on buffer update if a different amount of
///	   data is passed. If this flag is not specified, and more data is passed on update, the buffer
///	   will be trimmed to fit the existing buffer size. This flag has effect only on dynamic
///	   buffers.
///   - [BufferFlags::INDEX32] - Buffer is using 32-bit indices. This flag has effect only on
///	   index buffers.
pub fn create_dynamic_vertex_buffer_mem(
	mem: &Memory,
	layout: &BuiltVertexLayout,
	flags: u16,
) -> DynamicVertexBuffer {
	unsafe {
		let _layout = std::mem::transmute(layout);
		let _ret = bgfx_sys::bgfx_create_dynamic_vertex_buffer_mem(mem.handle, _layout, flags);
		DynamicVertexBuffer { handle: _ret }
	}
}
/// * `handle`:
/// Dynamic vertex buffer handle.
/// * `start_vertex`:
/// Start vertex.
/// * `mem`:
/// Vertex buffer data.
pub fn update_dynamic_vertex_buffer(handle: &DynamicVertexBuffer, start_vertex: u32, mem: &Memory) {
	unsafe {
		bgfx_sys::bgfx_update_dynamic_vertex_buffer(handle.handle, start_vertex, mem.handle);
	}
}
/// * `num`:
/// Number of required indices.
/// * `index_32`:
/// Set to `true` if input indices will be 32-bit.
pub fn get_avail_transient_index_buffer(num: u32, index_32: bool) -> u32 {
	unsafe {
		let _ret = bgfx_sys::bgfx_get_avail_transient_index_buffer(num, index_32);
		_ret
	}
}
/// * `num`:
/// Number of required vertices.
/// * `layout`:
/// Vertex layout.
pub fn get_avail_transient_vertex_buffer(num: u32, layout: &BuiltVertexLayout) -> u32 {
	unsafe {
		let _layout = std::mem::transmute(layout);
		let _ret = bgfx_sys::bgfx_get_avail_transient_vertex_buffer(num, _layout);
		_ret
	}
}
/// * `num`:
/// Number of required instances.
/// * `stride`:
/// Stride per instance.
pub fn get_avail_instance_data_buffer(num: u32, stride: u16) -> u32 {
	unsafe {
		let _ret = bgfx_sys::bgfx_get_avail_instance_data_buffer(num, stride);
		_ret
	}
}
/// * `tib`:
/// TransientIndexBuffer structure will be filled, and will be valid
/// for the duration of frame, and can be reused for multiple draw
/// calls.
/// * `num`:
/// Number of indices to allocate.
/// * `index_32`:
/// Set to `true` if input indices will be 32-bit.
pub fn alloc_transient_index_buffer(tib: &mut TransientIndexBuffer, num: u32, index_32: bool) {
	unsafe {
		let _tib = std::mem::transmute(tib);
		bgfx_sys::bgfx_alloc_transient_index_buffer(_tib, num, index_32);
	}
}
/// * `tvb`:
/// TransientVertexBuffer structure will be filled, and will be valid
/// for the duration of frame, and can be reused for multiple draw
/// calls.
/// * `num`:
/// Number of vertices to allocate.
/// * `layout`:
/// Vertex layout.
pub fn alloc_transient_vertex_buffer(
	tvb: &mut TransientVertexBuffer,
	num: u32,
	layout: &BuiltVertexLayout,
) {
	unsafe {
		let _tvb = std::mem::transmute(tvb);
		let _layout = std::mem::transmute(layout);
		bgfx_sys::bgfx_alloc_transient_vertex_buffer(_tvb, num, _layout);
	}
}
/// * `tvb`:
/// TransientVertexBuffer structure will be filled, and will be valid
/// for the duration of frame, and can be reused for multiple draw
/// calls.
/// * `layout`:
/// Vertex layout.
/// * `num_vertices`:
/// Number of vertices to allocate.
/// * `tib`:
/// TransientIndexBuffer structure will be filled, and will be valid
/// for the duration of frame, and can be reused for multiple draw
/// calls.
/// * `num_indices`:
/// Number of indices to allocate.
/// * `index_32`:
/// Set to `true` if input indices will be 32-bit.
pub fn alloc_transient_buffers(
	tvb: &mut TransientVertexBuffer,
	layout: &BuiltVertexLayout,
	num_vertices: u32,
	tib: &mut TransientIndexBuffer,
	num_indices: u32,
	index_32: bool,
) -> bool {
	unsafe {
		let _tvb = std::mem::transmute(tvb);
		let _layout = std::mem::transmute(layout);
		let _tib = std::mem::transmute(tib);
		let _ret = bgfx_sys::bgfx_alloc_transient_buffers(
			_tvb,
			_layout,
			num_vertices,
			_tib,
			num_indices,
			index_32,
		);
		_ret
	}
}
/// * `idb`:
/// InstanceDataBuffer structure will be filled, and will be valid
/// for duration of frame, and can be reused for multiple draw
/// calls.
/// * `num`:
/// Number of instances.
/// * `stride`:
/// Instance stride. Must be multiple of 16.
pub fn alloc_instance_data_buffer(idb: &mut InstanceDataBuffer, num: u32, stride: u16) {
	unsafe {
		let _idb = std::mem::transmute(idb);
		bgfx_sys::bgfx_alloc_instance_data_buffer(_idb, num, stride);
	}
}
/// * `num`:
/// Number of indirect calls.
pub fn create_indirect_buffer(num: u32) -> IndirectBuffer {
	unsafe {
		let _ret = bgfx_sys::bgfx_create_indirect_buffer(num);
		IndirectBuffer { handle: _ret }
	}
}
/// * `mem`:
/// Shader binary.
pub fn create_shader(mem: &Memory) -> Shader {
	unsafe {
		let _ret = bgfx_sys::bgfx_create_shader(mem.handle);
		Shader { handle: _ret }
	}
}
/// * `vsh`:
/// Vertex shader.
/// * `fsh`:
/// Fragment shader.
/// * `destroy_shaders`:
/// If true, shaders will be destroyed when program is destroyed.
pub fn create_program(vsh: &Shader, fsh: &Shader, destroy_shaders: bool) -> Program {
	unsafe {
		let _ret = bgfx_sys::bgfx_create_program(vsh.handle, fsh.handle, destroy_shaders);
		Program { handle: _ret }
	}
}
/// * `csh`:
/// Compute shader.
/// * `destroy_shaders`:
/// If true, shaders will be destroyed when program is destroyed.
pub fn create_compute_program(csh: &Shader, destroy_shaders: bool) -> Program {
	unsafe {
		let _ret = bgfx_sys::bgfx_create_compute_program(csh.handle, destroy_shaders);
		Program { handle: _ret }
	}
}
/// * `depth`:
/// Depth dimension of volume texture.
/// * `cube_map`:
/// Indicates that texture contains cubemap.
/// * `num_layers`:
/// Number of layers in texture array.
/// * `format`:
/// Texture format. See: [TextureFormat].
/// * `flags`:
/// Texture flags. See [TextureFlags].
pub fn is_texture_valid(
	depth: u16,
	cube_map: bool,
	num_layers: u16,
	format: TextureFormat,
	flags: u64,
) -> bool {
	unsafe {
		let _ret = bgfx_sys::bgfx_is_texture_valid(depth, cube_map, num_layers, format as _, flags);
		_ret
	}
}
/// * `num`:
/// Number of attachments.
/// * `attachment`:
/// Attachment texture info. See: `bgfx::Attachment`.
pub fn is_frame_buffer_valid(num: u8, attachment: &Attachment) -> bool {
	unsafe {
		let _attachment = std::mem::transmute(attachment);
		let _ret = bgfx_sys::bgfx_is_frame_buffer_valid(num, _attachment);
		_ret
	}
}
/// * `info`:
/// Resulting texture info structure. See: `TextureInfo`.
/// * `width`:
/// Width.
/// * `height`:
/// Height.
/// * `depth`:
/// Depth dimension of volume texture.
/// * `cube_map`:
/// Indicates that texture contains cubemap.
/// * `has_mips`:
/// Indicates that texture contains full mip-map chain.
/// * `num_layers`:
/// Number of layers in texture array.
/// * `format`:
/// Texture format. See: [TextureFormat].
pub fn calc_texture_size(
	info: &mut TextureInfo,
	width: u16,
	height: u16,
	depth: u16,
	cube_map: bool,
	has_mips: bool,
	num_layers: u16,
	format: TextureFormat,
) {
	unsafe {
		let _info = std::mem::transmute(info);
		bgfx_sys::bgfx_calc_texture_size(
			_info,
			width,
			height,
			depth,
			cube_map,
			has_mips,
			num_layers,
			format as _,
		);
	}
}
/// * `mem`:
/// DDS, KTX or PVR texture binary data.
/// * `flags`:
/// Texture creation (see [TextureFlags].), and sampler (see [SamplerFlags])
/// flags. Default texture sampling mode is linear, and wrap mode is repeat.
/// - [SamplerFlags::[U/V/W]_[MIRROR/CLAMP]] - Mirror or clamp to edge wrap
///   mode.
/// - [SamplerFlags::[MIN/MAG/MIP]_[POINT/ANISOTROPIC]] - Point or anisotropic
///   sampling.
/// * `skip`:
/// Skip top level mips when parsing texture.
/// * `info`:
/// When non-`NULL` is specified it returns parsed texture information.
pub fn create_texture(mem: &Memory, flags: u64, skip: u8, info: &mut TextureInfo) -> Texture {
	unsafe {
		let _ret =
			bgfx_sys::bgfx_create_texture(mem.handle, flags, skip, info);
		Texture { handle: _ret }
	}
}
/// * `width`:
/// Width.
/// * `height`:
/// Height.
/// * `has_mips`:
/// Indicates that texture contains full mip-map chain.
/// * `num_layers`:
/// Number of layers in texture array. Must be 1 if caps
/// [CapsFlags::TEXTURE_2D_ARRAY] flag is not set.
/// * `format`:
/// Texture format. See: [TextureFormat].
/// * `flags`:
/// Texture creation (see [TextureFlags].), and sampler (see [SamplerFlags])
/// flags. Default texture sampling mode is linear, and wrap mode is repeat.
/// - [SamplerFlags::[U/V/W]_[MIRROR/CLAMP]] - Mirror or clamp to edge wrap
///   mode.
/// - [SamplerFlags::[MIN/MAG/MIP]_[POINT/ANISOTROPIC]] - Point or anisotropic
///   sampling.
/// * `mem`:
/// Texture data. If `_mem` is non-NULL, created texture will be immutable. If
/// `_mem` is NULL content of the texture is uninitialized. When `_numLayers` is more than
/// 1, expected memory layout is texture and all mips together for each array element.
pub fn create_texture_2d(
	width: u16,
	height: u16,
	has_mips: bool,
	num_layers: u16,
	format: TextureFormat,
	params: CreateTexture2DArgs,
) -> Texture {
	unsafe {
		let _mem = if let Some(h) = params.mem {
			h.handle
		} else {
			std::ptr::null()
		};
		let _ret = bgfx_sys::bgfx_create_texture_2d(
			width,
			height,
			has_mips,
			num_layers,
			format as _,
			params.flags,
			_mem,
		);
		Texture { handle: _ret }
	}
}
/// * `ratio`:
/// Texture size in respect to back-buffer size. See: [BackbufferRatio].
/// * `has_mips`:
/// Indicates that texture contains full mip-map chain.
/// * `num_layers`:
/// Number of layers in texture array. Must be 1 if caps
/// [CapsFlags::TEXTURE_2D_ARRAY] flag is not set.
/// * `format`:
/// Texture format. See: [TextureFormat].
/// * `flags`:
/// Texture creation (see [TextureFlags].), and sampler (see [SamplerFlags])
/// flags. Default texture sampling mode is linear, and wrap mode is repeat.
/// - [SamplerFlags::[U/V/W]_[MIRROR/CLAMP]] - Mirror or clamp to edge wrap
///   mode.
/// - [SamplerFlags::[MIN/MAG/MIP]_[POINT/ANISOTROPIC]] - Point or anisotropic
///   sampling.
pub fn create_texture_2d_scaled(
	ratio: BackbufferRatio,
	has_mips: bool,
	num_layers: u16,
	format: TextureFormat,
	flags: u64,
) -> Texture {
	unsafe {
		let _ret = bgfx_sys::bgfx_create_texture_2d_scaled(
			ratio as _,
			has_mips,
			num_layers,
			format as _,
			flags,
		);
		Texture { handle: _ret }
	}
}
/// * `width`:
/// Width.
/// * `height`:
/// Height.
/// * `depth`:
/// Depth.
/// * `has_mips`:
/// Indicates that texture contains full mip-map chain.
/// * `format`:
/// Texture format. See: [TextureFormat].
/// * `flags`:
/// Texture creation (see [TextureFlags].), and sampler (see [SamplerFlags])
/// flags. Default texture sampling mode is linear, and wrap mode is repeat.
/// - [SamplerFlags::[U/V/W]_[MIRROR/CLAMP]] - Mirror or clamp to edge wrap
///   mode.
/// - [SamplerFlags::[MIN/MAG/MIP]_[POINT/ANISOTROPIC]] - Point or anisotropic
///   sampling.
/// * `mem`:
/// Texture data. If `_mem` is non-NULL, created texture will be immutable. If
/// `_mem` is NULL content of the texture is uninitialized. When `_numLayers` is more than
/// 1, expected memory layout is texture and all mips together for each array element.
pub fn create_texture_3d(
	width: u16,
	height: u16,
	depth: u16,
	has_mips: bool,
	format: TextureFormat,
	params: CreateTexture3DArgs,
) -> Texture {
	unsafe {
		let _mem = if let Some(h) = params.mem {
			h.handle
		} else {
			std::ptr::null()
		};
		let _ret = bgfx_sys::bgfx_create_texture_3d(
			width,
			height,
			depth,
			has_mips,
			format as _,
			params.flags,
			_mem,
		);
		Texture { handle: _ret }
	}
}
/// * `size`:
/// Cube side size.
/// * `has_mips`:
/// Indicates that texture contains full mip-map chain.
/// * `num_layers`:
/// Number of layers in texture array. Must be 1 if caps
/// [CapsFlags::TEXTURE_2D_ARRAY] flag is not set.
/// * `format`:
/// Texture format. See: [TextureFormat].
/// * `flags`:
/// Texture creation (see [TextureFlags].), and sampler (see [SamplerFlags])
/// flags. Default texture sampling mode is linear, and wrap mode is repeat.
/// - [SamplerFlags::[U/V/W]_[MIRROR/CLAMP]] - Mirror or clamp to edge wrap
///   mode.
/// - [SamplerFlags::[MIN/MAG/MIP]_[POINT/ANISOTROPIC]] - Point or anisotropic
///   sampling.
/// * `mem`:
/// Texture data. If `_mem` is non-NULL, created texture will be immutable. If
/// `_mem` is NULL content of the texture is uninitialized. When `_numLayers` is more than
/// 1, expected memory layout is texture and all mips together for each array element.
pub fn create_texture_cube(
	size: u16,
	has_mips: bool,
	num_layers: u16,
	format: TextureFormat,
	params: CreateTextureCubeArgs,
) -> Texture {
	unsafe {
		let _mem = if let Some(h) = params.mem {
			h.handle
		} else {
			std::ptr::null()
		};
		let _ret = bgfx_sys::bgfx_create_texture_cube(
			size,
			has_mips,
			num_layers,
			format as _,
			params.flags,
			_mem,
		);
		Texture { handle: _ret }
	}
}
/// * `handle`:
/// Texture handle.
/// * `layer`:
/// Layer in texture array.
/// * `mip`:
/// Mip level.
/// * `x`:
/// X offset in texture.
/// * `y`:
/// Y offset in texture.
/// * `width`:
/// Width of texture block.
/// * `height`:
/// Height of texture block.
/// * `mem`:
/// Texture update data.
/// * `pitch`:
/// Pitch of input image (bytes). When _pitch is set to
/// UINT16_MAX, it will be calculated internally based on _width.
pub fn update_texture_2d(
	handle: &Texture,
	layer: u16,
	mip: u8,
	x: u16,
	y: u16,
	width: u16,
	height: u16,
	mem: &Memory,
	pitch: u16,
) {
	unsafe {
		bgfx_sys::bgfx_update_texture_2d(
			handle.handle,
			layer,
			mip,
			x,
			y,
			width,
			height,
			mem.handle,
			pitch,
		);
	}
}
/// * `handle`:
/// Texture handle.
/// * `mip`:
/// Mip level.
/// * `x`:
/// X offset in texture.
/// * `y`:
/// Y offset in texture.
/// * `z`:
/// Z offset in texture.
/// * `width`:
/// Width of texture block.
/// * `height`:
/// Height of texture block.
/// * `depth`:
/// Depth of texture block.
/// * `mem`:
/// Texture update data.
pub fn update_texture_3d(
	handle: &Texture,
	mip: u8,
	x: u16,
	y: u16,
	z: u16,
	width: u16,
	height: u16,
	depth: u16,
	mem: &Memory,
) {
	unsafe {
		bgfx_sys::bgfx_update_texture_3d(
			handle.handle,
			mip,
			x,
			y,
			z,
			width,
			height,
			depth,
			mem.handle,
		);
	}
}
/// * `handle`:
/// Texture handle.
/// * `layer`:
/// Layer in texture array.
/// * `side`:
/// Cubemap side [CubeMapFlags::<POSITIVE or NEGATIVE>_<X, Y or Z>],
///   where 0 is +X, 1 is -X, 2 is +Y, 3 is -Y, 4 is +Z, and 5 is -Z.
///
///				  +----------+
///				  |-z	   2|
///				  | ^  +y	|
///				  | |		|	Unfolded cube:
///				  | +---->+x |
///	   +----------+----------+----------+----------+
///	   |+y	   1|+y	   4|+y	   0|+y	   5|
///	   | ^  -x	| ^  +z	| ^  +x	| ^  -z	|
///	   | |		| |		| |		| |		|
///	   | +---->+z | +---->+x | +---->-z | +---->-x |
///	   +----------+----------+----------+----------+
///				  |+z	   3|
///				  | ^  -y	|
///				  | |		|
///				  | +---->+x |
///				  +----------+
/// * `mip`:
/// Mip level.
/// * `x`:
/// X offset in texture.
/// * `y`:
/// Y offset in texture.
/// * `width`:
/// Width of texture block.
/// * `height`:
/// Height of texture block.
/// * `mem`:
/// Texture update data.
/// * `pitch`:
/// Pitch of input image (bytes). When _pitch is set to
/// UINT16_MAX, it will be calculated internally based on _width.
pub fn update_texture_cube(
	handle: &Texture,
	layer: u16,
	side: u8,
	mip: u8,
	x: u16,
	y: u16,
	width: u16,
	height: u16,
	mem: &Memory,
	pitch: u16,
) {
	unsafe {
		bgfx_sys::bgfx_update_texture_cube(
			handle.handle,
			layer,
			side,
			mip,
			x,
			y,
			width,
			height,
			mem.handle,
			pitch,
		);
	}
}
/// * `width`:
/// Texture width.
/// * `height`:
/// Texture height.
/// * `format`:
/// Texture format. See: [TextureFormat].
/// * `texture_flags`:
/// Texture creation (see [TextureFlags].), and sampler (see [SamplerFlags])
/// flags. Default texture sampling mode is linear, and wrap mode is repeat.
/// - [SamplerFlags::[U/V/W]_[MIRROR/CLAMP]] - Mirror or clamp to edge wrap
///   mode.
/// - [SamplerFlags::[MIN/MAG/MIP]_[POINT/ANISOTROPIC]] - Point or anisotropic
///   sampling.
pub fn create_frame_buffer(
	width: u16,
	height: u16,
	format: TextureFormat,
	texture_flags: u64,
) -> FrameBuffer {
	unsafe {
		let _ret = bgfx_sys::bgfx_create_frame_buffer(width, height, format as _, texture_flags);
		FrameBuffer { handle: _ret }
	}
}
/// * `ratio`:
/// Frame buffer size in respect to back-buffer size. See:
/// [BackbufferRatio].
/// * `format`:
/// Texture format. See: [TextureFormat].
/// * `texture_flags`:
/// Texture creation (see [TextureFlags].), and sampler (see [SamplerFlags])
/// flags. Default texture sampling mode is linear, and wrap mode is repeat.
/// - [SamplerFlags::[U/V/W]_[MIRROR/CLAMP]] - Mirror or clamp to edge wrap
///   mode.
/// - [SamplerFlags::[MIN/MAG/MIP]_[POINT/ANISOTROPIC]] - Point or anisotropic
///   sampling.
pub fn create_frame_buffer_scaled(
	ratio: BackbufferRatio,
	format: TextureFormat,
	texture_flags: u64,
) -> FrameBuffer {
	unsafe {
		let _ret =
			bgfx_sys::bgfx_create_frame_buffer_scaled(ratio as _, format as _, texture_flags);
		FrameBuffer { handle: _ret }
	}
}
/// * `num`:
/// Number of texture handles.
/// * `handles`:
/// Texture attachments.
/// * `destroy_texture`:
/// If true, textures will be destroyed when
/// frame buffer is destroyed.
pub fn create_frame_buffer_from_handles(
	num: u8,
	handles: &Texture,
	destroy_texture: bool,
) -> FrameBuffer {
	unsafe {
		let _ret =
			bgfx_sys::bgfx_create_frame_buffer_from_handles(num, &handles.handle, destroy_texture);
		FrameBuffer { handle: _ret }
	}
}
/// * `num`:
/// Number of attachments.
/// * `attachment`:
/// Attachment texture info. See: `bgfx::Attachment`.
/// * `destroy_texture`:
/// If true, textures will be destroyed when
/// frame buffer is destroyed.
pub fn create_frame_buffer_from_attachment(
	num: u8,
	attachment: &Attachment,
	destroy_texture: bool,
) -> FrameBuffer {
	unsafe {
		let _attachment = std::mem::transmute(attachment);
		let _ret =
			bgfx_sys::bgfx_create_frame_buffer_from_attachment(num, _attachment, destroy_texture);
		FrameBuffer { handle: _ret }
	}
}
/// * `nwh`:
/// OS' target native window handle.
/// * `width`:
/// Window back buffer width.
/// * `height`:
/// Window back buffer height.
/// * `format`:
/// Window back buffer color format.
/// * `depth_format`:
/// Window back buffer depth format.
pub fn create_frame_buffer_from_nwh(
	nwh: &mut c_void,
	width: u16,
	height: u16,
	params: CreateFrameBufferFromNwhArgs,
) -> FrameBuffer {
	unsafe {
		let _ret = bgfx_sys::bgfx_create_frame_buffer_from_nwh(
			nwh,
			width,
			height,
			params.format as _,
			params.depth_format as _,
		);
		FrameBuffer { handle: _ret }
	}
}
/// * `handle`:
/// Frame buffer handle.
/// * `attachment`:
pub fn get_texture(handle: &FrameBuffer, attachment: u8) -> Texture {
	unsafe {
		let _ret = bgfx_sys::bgfx_get_texture(handle.handle, attachment);
		Texture { handle: _ret }
	}
}
/// * `name`:
/// Uniform name in shader.
/// * `type_r`:
/// Type of uniform (See: `bgfx::UniformType`).
/// * `num`:
/// Number of elements in array.
pub fn create_uniform(name: &i8, type_r: UniformType, num: u16) -> Uniform {
	unsafe {
		let _ret = bgfx_sys::bgfx_create_uniform(name as *const i8 as *const ::std::os::raw::c_char, type_r as _, num);
		Uniform { handle: _ret }
	}
}
/// * `handle`:
/// Handle to uniform object.
/// * `info`:
/// Uniform info.
pub fn get_uniform_info(handle: &Uniform, info: &mut UniformInfo) {
	unsafe {
		let _info = std::mem::transmute(info);
		bgfx_sys::bgfx_get_uniform_info(handle.handle, _info);
	}
}
pub fn create_occlusion_query() -> OcclusionQuery {
	unsafe {
		let _ret = bgfx_sys::bgfx_create_occlusion_query();
		OcclusionQuery { handle: _ret }
	}
}
/// * `handle`:
/// Handle to occlusion query object.
/// * `result`:
/// Number of pixels that passed test. This argument
/// can be `NULL` if result of occlusion query is not needed.
pub fn get_result(handle: &OcclusionQuery, result: &mut i32) -> OcclusionQueryResult {
	unsafe {
		let _ret = bgfx_sys::bgfx_get_result(handle.handle, result);
		std::mem::transmute(_ret)
	}
}
/// * `id`:
/// View id.
/// * `x`:
/// Position x from the left corner of the window.
/// * `y`:
/// Position y from the top corner of the window.
/// * `width`:
/// Width of view port region.
/// * `height`:
/// Height of view port region.
pub fn set_view_rect(id: ViewId, x: u16, y: u16, width: u16, height: u16) {
	unsafe {
		bgfx_sys::bgfx_set_view_rect(id, x, y, width, height);
	}
}
/// * `id`:
/// View id.
/// * `x`:
/// Position x from the left corner of the window.
/// * `y`:
/// Position y from the top corner of the window.
/// * `ratio`:
/// Width and height will be set in respect to back-buffer size.
/// See: [BackbufferRatio].
pub fn set_view_rect_ratio(id: ViewId, x: u16, y: u16, ratio: BackbufferRatio) {
	unsafe {
		bgfx_sys::bgfx_set_view_rect_ratio(id, x, y, ratio as _);
	}
}
/// * `id`:
/// View id.
/// * `x`:
/// Position x from the left corner of the window.
/// * `y`:
/// Position y from the top corner of the window.
/// * `width`:
/// Width of view scissor region.
/// * `height`:
/// Height of view scissor region.
pub fn set_view_scissor(id: ViewId, params: SetViewScissorArgs) {
	unsafe {
		bgfx_sys::bgfx_set_view_scissor(id, params.x, params.y, params.width, params.height);
	}
}
/// * `id`:
/// View id.
/// * `flags`:
/// Clear flags. Use [ClearFlags::NONE] to remove any clear
/// operation. See: [ClearFlags].
/// * `rgba`:
/// Color clear value.
/// * `depth`:
/// Depth clear value.
/// * `stencil`:
/// Stencil clear value.
pub fn set_view_clear(id: ViewId, flags: u16, params: SetViewClearArgs) {
	unsafe {
		bgfx_sys::bgfx_set_view_clear(id, flags, params.rgba, params.depth, params.stencil);
	}
}
/// * `id`:
/// View id.
/// * `flags`:
/// Clear flags. Use [ClearFlags::NONE] to remove any clear
/// operation. See: [ClearFlags].
/// * `depth`:
/// Depth clear value.
/// * `stencil`:
/// Stencil clear value.
/// * `c_0`:
/// Palette index for frame buffer attachment 0.
/// * `c_1`:
/// Palette index for frame buffer attachment 1.
/// * `c_2`:
/// Palette index for frame buffer attachment 2.
/// * `c_3`:
/// Palette index for frame buffer attachment 3.
/// * `c_4`:
/// Palette index for frame buffer attachment 4.
/// * `c_5`:
/// Palette index for frame buffer attachment 5.
/// * `c_6`:
/// Palette index for frame buffer attachment 6.
/// * `c_7`:
/// Palette index for frame buffer attachment 7.
pub fn set_view_clear_mrt(
	id: ViewId,
	flags: u16,
	depth: f32,
	stencil: u8,
	params: SetViewClearMrtArgs,
) {
	unsafe {
		bgfx_sys::bgfx_set_view_clear_mrt(
			id, flags, depth, stencil, params.c_0, params.c_1, params.c_2, params.c_3, params.c_4,
			params.c_5, params.c_6, params.c_7,
		);
	}
}
/// * `id`:
/// View id.
/// * `mode`:
/// View sort mode. See [ViewMode].
pub fn set_view_mode(id: ViewId, mode: ViewMode) {
	unsafe {
		bgfx_sys::bgfx_set_view_mode(id, mode as _);
	}
}
/// * `id`:
/// View id.
/// * `handle`:
/// Frame buffer handle. Passing ]BGFX_INVALID_HANDLE] as
/// frame buffer handle will draw primitives from this view into
/// default back buffer.
pub fn set_view_frame_buffer(id: ViewId, handle: &FrameBuffer) {
	unsafe {
		bgfx_sys::bgfx_set_view_frame_buffer(id, handle.handle);
	}
}
/// * `id`:
pub fn reset_view(id: ViewId) {
	unsafe {
		bgfx_sys::bgfx_reset_view(id);
	}
}
/// * `for_thread`:
/// Explicitly request an encoder for a worker thread.
pub fn encoder_begin(for_thread: bool) -> &'static Encoder {
	unsafe {
		let _ret = bgfx_sys::bgfx_encoder_begin(for_thread);
		std::mem::transmute(_ret)
	}
}
/// * `encoder`:
/// Encoder.
pub fn encoder_end(encoder: &Encoder) {
	unsafe {
		let _encoder = std::mem::transmute(encoder);
		bgfx_sys::bgfx_encoder_end(_encoder);
	}
}
/// * `handle`:
/// Frame buffer handle. If handle is ]BGFX_INVALID_HANDLE] request will be
/// made for main window back buffer.
/// * `file_path`:
/// Will be passed to `bgfx::CallbackI::screenShot` callback.
pub fn request_screen_shot(handle: &FrameBuffer, file_path: &i8) {
	unsafe {
		bgfx_sys::bgfx_request_screen_shot(handle.handle, file_path as *const i8 as *const ::std::os::raw::c_char);
	}
}
/// * `msecs`:
/// Timeout in milliseconds.
pub fn render_frame(msecs: i32) -> RenderFrame {
	unsafe {
		let _ret = bgfx_sys::bgfx_render_frame(msecs);
		std::mem::transmute(_ret)
	}
}
/// * `data`:
/// Platform data.
pub fn set_platform_data(data: &PlatformData) {
	unsafe {
		let _data = std::mem::transmute(data);
		bgfx_sys::bgfx_set_platform_data(_data);
	}
}
pub fn get_internal_data() -> &'static InternalData {
	unsafe {
		let _ret = bgfx_sys::bgfx_get_internal_data();
		std::mem::transmute(_ret)
	}
}
/// * `name`:
/// Marker name.
/// * `len`:
/// Marker name length (if length is INT32_MAX, it's expected
/// that _name is zero terminated string.
pub fn set_marker(name: &i8, len: i32) {
	unsafe {
		bgfx_sys::bgfx_set_marker(name as *const i8 as *const ::std::os::raw::c_char, len);
	}
}
/// * `state`:
/// State flags. Default state for primitive type is
///   triangles. See: [StateFlags::DEFAULT].
///   - [StateDepthTestFlags] - Depth test function.
///   - [StateBlendFlags] - See remark 1 about BGFX_STATE_BLEND_FUNC.
///   - [StateBlendEquationFlags] - See remark 2.
///   - [StateCullFlags] - Backface culling mode.
///   - [StateWriteFlags] - Enable R, G, B, A or Z write.
///   - [StateFlags::MSAA] - Enable hardware multisample antialiasing.
///   - [StatePtFlags::[TRISTRIP/LINES/POINTS]] - Primitive type.
/// * `rgba`:
/// Sets blend factor used by [StateBlendFlags::FACTOR] and
///   [StateBlendFlags::INV_FACTOR] blend modes.
pub fn set_state(state: u64, rgba: u32) {
	unsafe {
		bgfx_sys::bgfx_set_state(state, rgba);
	}
}
/// * `handle`:
/// Occlusion query handle.
/// * `visible`:
/// Render if occlusion query is visible.
pub fn set_condition(handle: &OcclusionQuery, visible: bool) {
	unsafe {
		bgfx_sys::bgfx_set_condition(handle.handle, visible);
	}
}
/// * `fstencil`:
/// Front stencil state.
/// * `bstencil`:
/// Back stencil state. If back is set to [StencilFlags::NONE]
/// _fstencil is applied to both front and back facing primitives.
pub fn set_stencil(fstencil: u32, bstencil: u32) {
	unsafe {
		bgfx_sys::bgfx_set_stencil(fstencil, bstencil);
	}
}
/// * `x`:
/// Position x from the left corner of the window.
/// * `y`:
/// Position y from the top corner of the window.
/// * `width`:
/// Width of view scissor region.
/// * `height`:
/// Height of view scissor region.
pub fn set_scissor(x: u16, y: u16, width: u16, height: u16) -> u16 {
	unsafe {
		let _ret = bgfx_sys::bgfx_set_scissor(x, y, width, height);
		_ret
	}
}
/// * `cache`:
/// Index in scissor cache.
pub fn set_scissor_cached(cache: u16) {
	unsafe {
		bgfx_sys::bgfx_set_scissor_cached(cache);
	}
}
/// * `transform`:
/// Pointer to `Transform` structure.
/// * `num`:
/// Number of matrices.
pub fn alloc_transform(transform: &mut Transform, num: u16) -> u32 {
	unsafe {
		let _transform = std::mem::transmute(transform);
		let _ret = bgfx_sys::bgfx_alloc_transform(_transform, num);
		_ret
	}
}
/// * `handle`:
/// Uniform.
/// * `value`:
/// Pointer to uniform data.
/// * `num`:
/// Number of elements. Passing `UINT16_MAX` will
/// use the _num passed on uniform creation.
pub fn set_uniform(handle: &Uniform, value: &c_void, num: u16) {
	unsafe {
		bgfx_sys::bgfx_set_uniform(handle.handle, value, num);
	}
}
/// * `handle`:
/// Index buffer.
/// * `first_index`:
/// First index to render.
/// * `num_indices`:
/// Number of indices to render.
pub fn set_index_buffer(handle: &IndexBuffer, first_index: u32, num_indices: u32) {
	unsafe {
		bgfx_sys::bgfx_set_index_buffer(handle.handle, first_index, num_indices);
	}
}
/// * `handle`:
/// Dynamic index buffer.
/// * `first_index`:
/// First index to render.
/// * `num_indices`:
/// Number of indices to render.
pub fn set_dynamic_index_buffer(handle: &DynamicIndexBuffer, first_index: u32, num_indices: u32) {
	unsafe {
		bgfx_sys::bgfx_set_dynamic_index_buffer(handle.handle, first_index, num_indices);
	}
}
/// * `tib`:
/// Transient index buffer.
/// * `first_index`:
/// First index to render.
/// * `num_indices`:
/// Number of indices to render.
pub fn set_transient_index_buffer(tib: &TransientIndexBuffer, first_index: u32, num_indices: u32) {
	unsafe {
		let _tib = std::mem::transmute(tib);
		bgfx_sys::bgfx_set_transient_index_buffer(_tib, first_index, num_indices);
	}
}
/// * `stream`:
/// Vertex stream.
/// * `handle`:
/// Vertex buffer.
/// * `start_vertex`:
/// First vertex to render.
/// * `num_vertices`:
/// Number of vertices to render.
pub fn set_vertex_buffer(stream: u8, handle: &VertexBuffer, start_vertex: u32, num_vertices: u32) {
	unsafe {
		bgfx_sys::bgfx_set_vertex_buffer(stream, handle.handle, start_vertex, num_vertices);
	}
}
/// * `stream`:
/// Vertex stream.
/// * `handle`:
/// Vertex buffer.
/// * `start_vertex`:
/// First vertex to render.
/// * `num_vertices`:
/// Number of vertices to render.
/// * `layout_handle`:
/// Vertex layout for aliasing vertex buffer. If invalid
/// handle is used, vertex layout used for creation
/// of vertex buffer will be used.
pub fn set_vertex_buffer_with_layout(
	stream: u8,
	handle: &VertexBuffer,
	start_vertex: u32,
	num_vertices: u32,
	layout_handle: &VertexLayout,
) {
	unsafe {
		bgfx_sys::bgfx_set_vertex_buffer_with_layout(
			stream,
			handle.handle,
			start_vertex,
			num_vertices,
			layout_handle.handle,
		);
	}
}
/// * `stream`:
/// Vertex stream.
/// * `handle`:
/// Dynamic vertex buffer.
/// * `start_vertex`:
/// First vertex to render.
/// * `num_vertices`:
/// Number of vertices to render.
pub fn set_dynamic_vertex_buffer(
	stream: u8,
	handle: &DynamicVertexBuffer,
	start_vertex: u32,
	num_vertices: u32,
) {
	unsafe {
		bgfx_sys::bgfx_set_dynamic_vertex_buffer(stream, handle.handle, start_vertex, num_vertices);
	}
}
/// * `stream`:
/// Vertex stream.
/// * `handle`:
/// Dynamic vertex buffer.
/// * `start_vertex`:
/// First vertex to render.
/// * `num_vertices`:
/// Number of vertices to render.
/// * `layout_handle`:
/// Vertex layout for aliasing vertex buffer. If invalid
/// handle is used, vertex layout used for creation
/// of vertex buffer will be used.
pub fn set_dynamic_vertex_buffer_with_layout(
	stream: u8,
	handle: &DynamicVertexBuffer,
	start_vertex: u32,
	num_vertices: u32,
	layout_handle: &VertexLayout,
) {
	unsafe {
		bgfx_sys::bgfx_set_dynamic_vertex_buffer_with_layout(
			stream,
			handle.handle,
			start_vertex,
			num_vertices,
			layout_handle.handle,
		);
	}
}
/// * `stream`:
/// Vertex stream.
/// * `tvb`:
/// Transient vertex buffer.
/// * `start_vertex`:
/// First vertex to render.
/// * `num_vertices`:
/// Number of vertices to render.
pub fn set_transient_vertex_buffer(
	stream: u8,
	tvb: &TransientVertexBuffer,
	start_vertex: u32,
	num_vertices: u32,
) {
	unsafe {
		let _tvb = std::mem::transmute(tvb);
		bgfx_sys::bgfx_set_transient_vertex_buffer(stream, _tvb, start_vertex, num_vertices);
	}
}
/// * `stream`:
/// Vertex stream.
/// * `tvb`:
/// Transient vertex buffer.
/// * `start_vertex`:
/// First vertex to render.
/// * `num_vertices`:
/// Number of vertices to render.
/// * `layout_handle`:
/// Vertex layout for aliasing vertex buffer. If invalid
/// handle is used, vertex layout used for creation
/// of vertex buffer will be used.
pub fn set_transient_vertex_buffer_with_layout(
	stream: u8,
	tvb: &TransientVertexBuffer,
	start_vertex: u32,
	num_vertices: u32,
	layout_handle: &VertexLayout,
) {
	unsafe {
		let _tvb = std::mem::transmute(tvb);
		bgfx_sys::bgfx_set_transient_vertex_buffer_with_layout(
			stream,
			_tvb,
			start_vertex,
			num_vertices,
			layout_handle.handle,
		);
	}
}
/// * `num_vertices`:
/// Number of vertices.
pub fn set_vertex_count(num_vertices: u32) {
	unsafe {
		bgfx_sys::bgfx_set_vertex_count(num_vertices);
	}
}
/// * `idb`:
/// Transient instance data buffer.
/// * `start`:
/// First instance data.
/// * `num`:
/// Number of data instances.
pub fn set_instance_data_buffer(idb: &InstanceDataBuffer, start: u32, num: u32) {
	unsafe {
		let _idb = std::mem::transmute(idb);
		bgfx_sys::bgfx_set_instance_data_buffer(_idb, start, num);
	}
}
/// * `handle`:
/// Vertex buffer.
/// * `start_vertex`:
/// First instance data.
/// * `num`:
/// Number of data instances.
pub fn set_instance_data_from_vertex_buffer(handle: &VertexBuffer, start_vertex: u32, num: u32) {
	unsafe {
		bgfx_sys::bgfx_set_instance_data_from_vertex_buffer(handle.handle, start_vertex, num);
	}
}
/// * `handle`:
/// Dynamic vertex buffer.
/// * `start_vertex`:
/// First instance data.
/// * `num`:
/// Number of data instances.
pub fn set_instance_data_from_dynamic_vertex_buffer(
	handle: &DynamicVertexBuffer,
	start_vertex: u32,
	num: u32,
) {
	unsafe {
		bgfx_sys::bgfx_set_instance_data_from_dynamic_vertex_buffer(
			handle.handle,
			start_vertex,
			num,
		);
	}
}
/// * `num_instances`:
pub fn set_instance_count(num_instances: u32) {
	unsafe {
		bgfx_sys::bgfx_set_instance_count(num_instances);
	}
}
/// * `stage`:
/// Texture unit.
/// * `sampler`:
/// Program sampler.
/// * `handle`:
/// Texture handle.
/// * `flags`:
/// Texture sampling mode. Default value UINT32_MAX uses
///   texture sampling settings from the texture.
///   - [SamplerFlags::[U/V/W]_[MIRROR/CLAMP]] - Mirror or clamp to edge wrap
///	 mode.
///   - [SamplerFlags::[MIN/MAG/MIP]_[POINT/ANISOTROPIC]] - Point or anisotropic
///	 sampling.
pub fn set_texture(stage: u8, sampler: &Uniform, handle: &Texture, flags: u32) {
	unsafe {
		bgfx_sys::bgfx_set_texture(stage, sampler.handle, handle.handle, flags);
	}
}
/// * `id`:
/// View id.
pub fn touch(id: ViewId) {
	unsafe {
		bgfx_sys::bgfx_touch(id);
	}
}
/// * `id`:
/// View id.
/// * `program`:
/// Program.
/// * `depth`:
/// Depth for sorting.
/// * `flags`:
/// Which states to discard for next draw. See [DiscardFlags].
pub fn submit(id: ViewId, program: &Program, params: SubmitArgs) {
	unsafe {
		bgfx_sys::bgfx_submit(id, program.handle, params.depth, params.flags);
	}
}
/// * `id`:
/// View id.
/// * `program`:
/// Program.
/// * `occlusion_query`:
/// Occlusion query.
/// * `depth`:
/// Depth for sorting.
/// * `flags`:
/// Which states to discard for next draw. See [DiscardFlags].
pub fn submit_occlusion_query(
	id: ViewId,
	program: &Program,
	occlusion_query: &OcclusionQuery,
	params: SubmitOcclusionQueryArgs,
) {
	unsafe {
		bgfx_sys::bgfx_submit_occlusion_query(
			id,
			program.handle,
			occlusion_query.handle,
			params.depth,
			params.flags,
		);
	}
}
/// * `id`:
/// View id.
/// * `program`:
/// Program.
/// * `indirect_handle`:
/// Indirect buffer.
/// * `start`:
/// First element in indirect buffer.
/// * `num`:
/// Number of draws.
/// * `depth`:
/// Depth for sorting.
/// * `flags`:
/// Which states to discard for next draw. See [DiscardFlags].
pub fn submit_indirect(
	id: ViewId,
	program: &Program,
	indirect_handle: &IndirectBuffer,
	params: SubmitIndirectArgs,
) {
	unsafe {
		bgfx_sys::bgfx_submit_indirect(
			id,
			program.handle,
			indirect_handle.handle,
			params.start,
			params.num,
			params.depth,
			params.flags,
		);
	}
}
/// * `id`:
/// View id.
/// * `program`:
/// Program.
/// * `indirect_handle`:
/// Indirect buffer.
/// * `start`:
/// First element in indirect buffer.
/// * `num_handle`:
/// Buffer for number of draws. Must be
///   created with [BufferFlags::INDEX32] and [BufferFlags::DRAW_INDIRECT].
/// * `num_index`:
/// Element in number buffer.
/// * `num_max`:
/// Max number of draws.
/// * `depth`:
/// Depth for sorting.
/// * `flags`:
/// Which states to discard for next draw. See [DiscardFlags].
pub fn submit_indirect_count(
	id: ViewId,
	program: &Program,
	indirect_handle: &IndirectBuffer,
	start: u32,
	num_handle: &IndexBuffer,
	params: SubmitIndirectCountArgs,
) {
	unsafe {
		bgfx_sys::bgfx_submit_indirect_count(
			id,
			program.handle,
			indirect_handle.handle,
			start,
			num_handle.handle,
			params.num_index,
			params.num_max,
			params.depth,
			params.flags,
		);
	}
}
/// * `stage`:
/// Compute stage.
/// * `handle`:
/// Index buffer handle.
/// * `access`:
/// Buffer access. See [Access].
pub fn set_compute_index_buffer(stage: u8, handle: &IndexBuffer, access: Access) {
	unsafe {
		bgfx_sys::bgfx_set_compute_index_buffer(stage, handle.handle, access as _);
	}
}
/// * `stage`:
/// Compute stage.
/// * `handle`:
/// Vertex buffer handle.
/// * `access`:
/// Buffer access. See [Access].
pub fn set_compute_vertex_buffer(stage: u8, handle: &VertexBuffer, access: Access) {
	unsafe {
		bgfx_sys::bgfx_set_compute_vertex_buffer(stage, handle.handle, access as _);
	}
}
/// * `stage`:
/// Compute stage.
/// * `handle`:
/// Dynamic index buffer handle.
/// * `access`:
/// Buffer access. See [Access].
pub fn set_compute_dynamic_index_buffer(stage: u8, handle: &DynamicIndexBuffer, access: Access) {
	unsafe {
		bgfx_sys::bgfx_set_compute_dynamic_index_buffer(stage, handle.handle, access as _);
	}
}
/// * `stage`:
/// Compute stage.
/// * `handle`:
/// Dynamic vertex buffer handle.
/// * `access`:
/// Buffer access. See [Access].
pub fn set_compute_dynamic_vertex_buffer(stage: u8, handle: &DynamicVertexBuffer, access: Access) {
	unsafe {
		bgfx_sys::bgfx_set_compute_dynamic_vertex_buffer(stage, handle.handle, access as _);
	}
}
/// * `stage`:
/// Compute stage.
/// * `handle`:
/// Indirect buffer handle.
/// * `access`:
/// Buffer access. See [Access].
pub fn set_compute_indirect_buffer(stage: u8, handle: &IndirectBuffer, access: Access) {
	unsafe {
		bgfx_sys::bgfx_set_compute_indirect_buffer(stage, handle.handle, access as _);
	}
}
/// * `stage`:
/// Compute stage.
/// * `handle`:
/// Texture handle.
/// * `mip`:
/// Mip level.
/// * `access`:
/// Image access. See [Access].
/// * `format`:
/// Texture format. See: [TextureFormat].
pub fn set_image(stage: u8, handle: &Texture, mip: u8, access: Access, format: TextureFormat) {
	unsafe {
		bgfx_sys::bgfx_set_image(stage, handle.handle, mip, access as _, format as _);
	}
}
/// * `id`:
/// View id.
/// * `program`:
/// Compute program.
/// * `num_x`:
/// Number of groups X.
/// * `num_y`:
/// Number of groups Y.
/// * `num_z`:
/// Number of groups Z.
/// * `flags`:
/// Discard or preserve states. See [DiscardFlags].
pub fn dispatch(id: ViewId, program: &Program, params: DispatchArgs) {
	unsafe {
		bgfx_sys::bgfx_dispatch(
			id,
			program.handle,
			params.num_x,
			params.num_y,
			params.num_z,
			params.flags,
		);
	}
}
/// * `id`:
/// View id.
/// * `program`:
/// Compute program.
/// * `indirect_handle`:
/// Indirect buffer.
/// * `start`:
/// First element in indirect buffer.
/// * `num`:
/// Number of dispatches.
/// * `flags`:
/// Discard or preserve states. See [DiscardFlags].
pub fn dispatch_indirect(
	id: ViewId,
	program: &Program,
	indirect_handle: &IndirectBuffer,
	params: DispatchIndirectArgs,
) {
	unsafe {
		bgfx_sys::bgfx_dispatch_indirect(
			id,
			program.handle,
			indirect_handle.handle,
			params.start,
			params.num,
			params.flags,
		);
	}
}
/// * `flags`:
/// Draw/compute states to discard.
pub fn discard(flags: u8) {
	unsafe {
		bgfx_sys::bgfx_discard(flags);
	}
}
/// * `id`:
/// View id.
/// * `dst`:
/// Destination texture handle.
/// * `dst_mip`:
/// Destination texture mip level.
/// * `dst_x`:
/// Destination texture X position.
/// * `dst_y`:
/// Destination texture Y position.
/// * `dst_z`:
/// If texture is 2D this argument should be 0. If destination texture is cube
/// this argument represents destination texture cube face. For 3D texture this argument
/// represents destination texture Z position.
/// * `src`:
/// Source texture handle.
/// * `src_mip`:
/// Source texture mip level.
/// * `src_x`:
/// Source texture X position.
/// * `src_y`:
/// Source texture Y position.
/// * `src_z`:
/// If texture is 2D this argument should be 0. If source texture is cube
/// this argument represents source texture cube face. For 3D texture this argument
/// represents source texture Z position.
/// * `width`:
/// Width of region.
/// * `height`:
/// Height of region.
/// * `depth`:
/// If texture is 3D this argument represents depth of region, otherwise it's
/// unused.
pub fn blit(
	id: ViewId,
	dst: &Texture,
	dst_mip: u8,
	dst_x: u16,
	dst_y: u16,
	dst_z: u16,
	src: &Texture,
	params: BlitArgs,
) {
	unsafe {
		bgfx_sys::bgfx_blit(
			id,
			dst.handle,
			dst_mip,
			dst_x,
			dst_y,
			dst_z,
			src.handle,
			params.src_mip,
			params.src_x,
			params.src_y,
			params.src_z,
			params.width,
			params.height,
			params.depth,
		);
	}
}

type ViewId = u16;

/// Returns the number of uniforms and uniform handles used inside a shader.
///
/// Notice that only non-predefined uniforms are returned.

impl Shader {
	//pub fn get_uniforms(&self, uniforms: &mut [Uniform]) -> u16 {
	//	unsafe { bgfx_sys::bgfx_get_shader_uniforms(self.handle, uniforms.as_ptr(), uniforms.len() as u16) }
	//}
}

/// bgfx-managed buffer of memory.
///
/// It can be created by either copying existing data through [`copy(...)`], or by referencing
/// existing memory directly through [`reference(...)`].
///
/// [`copy(...)`]: #method.copy
/// [`reference(...)`]: #method.reference
#[derive(Copy, Clone)]
pub struct Memory {
	handle: *const bgfx_sys::bgfx_memory_t,
}

impl Memory {
	/// Copies the source data into a new bgfx-managed buffer.
	///
	/// **IMPORTANT:** If this buffer is never passed into a bgfx call, the memory will never be
	/// freed, and will leak.
	#[inline]
	pub fn copy<T>(data: &[T]) -> Memory {
		unsafe {
			let handle = bgfx_sys::bgfx_copy(
				data.as_ptr() as *const c_void,
				std::mem::size_of_val(data) as u32,
			);
			Memory { handle }
		}
	}

	/// Creates a reference to the source data for passing into bgfx. When using this constructor
	/// over the `copy` call, no copy will be created. bgfx will read the source memory directly.
	///
	/// *Note* That the data passed to this function must be keep alive during the whole duration
	/// of the program and is only really recommended for static data unless you know you know
	/// what you are doing. Thus this function is marked as unsafe because of this reason.
	#[inline]
	pub unsafe fn reference<T>(data: &[T]) -> Memory {
		let handle = bgfx_sys::bgfx_make_ref(
			data.as_ptr() as *const c_void,
			std::mem::size_of_val(data) as u32,
		);
		Memory { handle }
	}
}

/// * `x`:
/// Position x from the left corner of the window.
/// * `y`:
/// Position y from the top corner of the window.
/// * `attr`:
/// Color palette. Where top 4-bits represent index of background, and bottom
/// 4-bits represent foreground color from standard VGA text palette (ANSI escape codes).
/// * `text`: Text to be displayed
pub fn dbg_text(x: u16, y: u16, attr: u8, text: &str) {
	unsafe {
		let c_text = std::ffi::CString::new(text).unwrap();
		bgfx_sys::bgfx_dbg_text_printf(x, y, attr, c_text.as_ptr());
	}
}

/// * `id`:
/// View id.
/// * `view`:
/// View matrix.
/// * `proj`:
/// Projection matrix.
pub fn set_view_transform(id: ViewId, view: &[f32; 16], proj: &[f32; 16]) {
	unsafe {
		let _view = std::mem::transmute(view);
		let _proj = std::mem::transmute(proj);
		bgfx_sys::bgfx_set_view_transform(id, _view, _proj);
	}
}

/// * `mtx`:
/// Pointer to first matrix in array.
/// * `num`:
/// Number of matrices in array.
pub fn set_transform(mtx: &[f32; 16], num: u16) -> u32 {
	unsafe {
		let _mtx = std::mem::transmute(mtx);
		bgfx_sys::bgfx_set_transform(_mtx, num)
	}
}
