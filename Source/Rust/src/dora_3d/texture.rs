use super::{next_handle, Dora3DHandle};
use crate::bgfx_rs::bgfx_sys;
use crate::Texture2D;
use std::collections::HashMap;
use std::ffi::CString;
use std::sync::{Mutex, OnceLock};

pub struct TextureData {
    pub handle: Dora3DHandle,
    pub width: u16,
    pub height: u16,
    pub texture: bgfx_sys::bgfx_texture_handle_t,
    owner: TextureOwner,
}

enum TextureOwner {
    Bgfx,
    Dora { _texture: Texture2D },
}

impl Drop for TextureData {
    fn drop(&mut self) {
        if !matches!(self.owner, TextureOwner::Bgfx) {
            return;
        }
        unsafe {
            if self.texture.idx != u16::MAX {
                bgfx_sys::bgfx_destroy_texture(self.texture);
            }
        }
    }
}

fn registry() -> &'static Mutex<HashMap<Dora3DHandle, TextureData>> {
    static REGISTRY: OnceLock<Mutex<HashMap<Dora3DHandle, TextureData>>> = OnceLock::new();
    REGISTRY.get_or_init(|| Mutex::new(HashMap::new()))
}

fn invalid_texture() -> bgfx_sys::bgfx_texture_handle_t {
    bgfx_sys::bgfx_texture_handle_t { idx: u16::MAX }
}

pub fn create_rgba8(
    width: u16,
    height: u16,
    pixels: &[u8],
    sampler_flags: u64,
    debug_name: Option<&str>,
) -> Option<Dora3DHandle> {
    create_rgba8_internal(width, height, pixels, sampler_flags, false, debug_name)
}

pub fn create_rgba8_mipmapped(
    width: u16,
    height: u16,
    pixels: &[u8],
    sampler_flags: u64,
    debug_name: Option<&str>,
) -> Option<Dora3DHandle> {
    create_rgba8_internal(width, height, pixels, sampler_flags, true, debug_name)
}

fn create_rgba8_internal(
    width: u16,
    height: u16,
    pixels: &[u8],
    sampler_flags: u64,
    mipmapped: bool,
    debug_name: Option<&str>,
) -> Option<Dora3DHandle> {
    if width == 0 || height == 0 || pixels.is_empty() {
        return None;
    }
    let mip_pixels;
    let (source, has_mips) = if mipmapped && (width > 1 || height > 1) {
        mip_pixels = build_rgba8_mip_chain(width as usize, height as usize, pixels)?;
        (mip_pixels.as_slice(), true)
    } else {
        (pixels, false)
    };
    let texture = unsafe {
        let memory = bgfx_sys::bgfx_copy(source.as_ptr() as *const _, source.len() as u32);
        bgfx_sys::bgfx_create_texture_2d(
            width,
            height,
            has_mips,
            1,
            bgfx_sys::BGFX_TEXTURE_FORMAT_RGBA8,
            sampler_flags,
            memory,
        )
    };
    if texture.idx == u16::MAX {
        return None;
    }
    if let Some(name) = debug_name.and_then(|value| CString::new(value).ok()) {
        unsafe {
            bgfx_sys::bgfx_set_texture_name(texture, name.as_ptr(), i32::MAX);
        }
    }
    let handle = next_handle();
    registry().lock().unwrap().insert(
        handle,
        TextureData {
            handle,
            width,
            height,
            texture,
            owner: TextureOwner::Bgfx,
        },
    );
    Some(handle)
}

fn build_rgba8_mip_chain(width: usize, height: usize, pixels: &[u8]) -> Option<Vec<u8>> {
    if pixels.len() != width.checked_mul(height)?.checked_mul(4)? {
        return None;
    }
    let mut chain = Vec::with_capacity(pixels.len() + pixels.len() / 3);
    chain.extend_from_slice(pixels);

    let mut src_width = width;
    let mut src_height = height;
    let mut src = pixels.to_vec();
    while src_width > 1 || src_height > 1 {
        let dst_width = (src_width / 2).max(1);
        let dst_height = (src_height / 2).max(1);
        let mut dst = vec![0u8; dst_width * dst_height * 4];
        for y in 0..dst_height {
            for x in 0..dst_width {
                let mut sum = [0u32; 4];
                for yy in 0..2 {
                    for xx in 0..2 {
                        let sx = (x * 2 + xx).min(src_width - 1);
                        let sy = (y * 2 + yy).min(src_height - 1);
                        let index = (sy * src_width + sx) * 4;
                        sum[0] += src[index] as u32;
                        sum[1] += src[index + 1] as u32;
                        sum[2] += src[index + 2] as u32;
                        sum[3] += src[index + 3] as u32;
                    }
                }
                let index = (y * dst_width + x) * 4;
                dst[index] = (sum[0] / 4) as u8;
                dst[index + 1] = (sum[1] / 4) as u8;
                dst[index + 2] = (sum[2] / 4) as u8;
                dst[index + 3] = (sum[3] / 4) as u8;
            }
        }
        chain.extend_from_slice(&dst);
        src = dst;
        src_width = dst_width;
        src_height = dst_height;
    }
    Some(chain)
}

pub fn from_dora_texture(texture: Texture2D) -> Option<Dora3DHandle> {
    let width = u16::try_from(texture.get_width()).ok()?;
    let height = u16::try_from(texture.get_height()).ok()?;
    if width == 0 || height == 0 {
        return None;
    }
    let texture_handle = bgfx_sys::bgfx_texture_handle_t {
        idx: u16::try_from(texture.get_handle()).ok()?,
    };
    if texture_handle.idx == u16::MAX {
        return None;
    }
    let handle = next_handle();
    registry().lock().unwrap().insert(
        handle,
        TextureData {
            handle,
            width,
            height,
            texture: texture_handle,
            owner: TextureOwner::Dora { _texture: texture },
        },
    );
    Some(handle)
}

fn float_to_half_bits(value: f32) -> u16 {
    let bits = value.to_bits();
    let sign = ((bits >> 16) & 0x8000) as u16;
    let exponent = ((bits >> 23) & 0xff) as i32 - 127 + 15;
    let mantissa = bits & 0x7f_ffff;
    if exponent <= 0 {
        if exponent < -10 {
            return sign;
        }
        let mantissa = mantissa | 0x80_0000;
        let shift = (14 - exponent) as u32;
        let mut half = (mantissa >> shift) as u16;
        if ((mantissa >> (shift - 1)) & 1) != 0 {
            half = half.saturating_add(1);
        }
        return sign | half;
    }
    if exponent >= 31 {
        return sign | 0x7c00;
    }
    let mut half = sign | ((exponent as u16) << 10) | ((mantissa >> 13) as u16);
    if (mantissa & 0x1000) != 0 {
        half = half.saturating_add(1);
    }
    half
}

pub fn create_rgba16f(
    width: u16,
    height: u16,
    pixels: &[[f32; 4]],
    sampler_flags: u64,
    debug_name: Option<&str>,
) -> Option<Dora3DHandle> {
    if width == 0 || height == 0 || pixels.len() != width as usize * height as usize {
        return None;
    }
    let mut bytes = Vec::with_capacity(pixels.len() * 8);
    for pixel in pixels {
        for component in pixel {
            bytes.extend_from_slice(&float_to_half_bits(*component).to_le_bytes());
        }
    }
    let texture = unsafe {
        let memory = bgfx_sys::bgfx_copy(bytes.as_ptr() as *const _, bytes.len() as u32);
        bgfx_sys::bgfx_create_texture_2d(
            width,
            height,
            false,
            1,
            bgfx_sys::BGFX_TEXTURE_FORMAT_RGBA16F,
            sampler_flags,
            memory,
        )
    };
    if texture.idx == u16::MAX {
        return None;
    }
    if let Some(name) = debug_name.and_then(|value| CString::new(value).ok()) {
        unsafe {
            bgfx_sys::bgfx_set_texture_name(texture, name.as_ptr(), i32::MAX);
        }
    }
    let handle = next_handle();
    registry().lock().unwrap().insert(
        handle,
        TextureData {
            handle,
            width,
            height,
            texture,
            owner: TextureOwner::Bgfx,
        },
    );
    Some(handle)
}

pub fn create_cube_rgba8(
    size: u16,
    has_mips: bool,
    sampler_flags: u64,
    debug_name: Option<&str>,
) -> Option<Dora3DHandle> {
    if size == 0 {
        return None;
    }
    let texture = unsafe {
        bgfx_sys::bgfx_create_texture_cube(
            size,
            has_mips,
            1,
            bgfx_sys::BGFX_TEXTURE_FORMAT_RGBA8,
            sampler_flags,
            std::ptr::null(),
        )
    };
    if texture.idx == u16::MAX {
        return None;
    }
    if let Some(name) = debug_name.and_then(|value| CString::new(value).ok()) {
        unsafe {
            bgfx_sys::bgfx_set_texture_name(texture, name.as_ptr(), i32::MAX);
        }
    }
    let handle = next_handle();
    registry().lock().unwrap().insert(
        handle,
        TextureData {
            handle,
            width: size,
            height: size,
            texture,
            owner: TextureOwner::Bgfx,
        },
    );
    Some(handle)
}

pub fn create_cube_rgba16f(
    size: u16,
    has_mips: bool,
    sampler_flags: u64,
    debug_name: Option<&str>,
) -> Option<Dora3DHandle> {
    if size == 0 {
        return None;
    }
    let texture = unsafe {
        bgfx_sys::bgfx_create_texture_cube(
            size,
            has_mips,
            1,
            bgfx_sys::BGFX_TEXTURE_FORMAT_RGBA16F,
            sampler_flags,
            std::ptr::null(),
        )
    };
    if texture.idx == u16::MAX {
        return None;
    }
    if let Some(name) = debug_name.and_then(|value| CString::new(value).ok()) {
        unsafe {
            bgfx_sys::bgfx_set_texture_name(texture, name.as_ptr(), i32::MAX);
        }
    }
    let handle = next_handle();
    registry().lock().unwrap().insert(
        handle,
        TextureData {
            handle,
            width: size,
            height: size,
            texture,
            owner: TextureOwner::Bgfx,
        },
    );
    Some(handle)
}

pub fn update_cube_rgba8(
    handle: Dora3DHandle,
    side: u8,
    mip: u8,
    size: u16,
    pixels: &[u8],
) -> bool {
    if size == 0 || pixels.len() != size as usize * size as usize * 4 {
        return false;
    }
    let Some(texture) = texture_handle(handle) else {
        return false;
    };
    if texture.idx == u16::MAX {
        return false;
    }
    unsafe {
        let memory = bgfx_sys::bgfx_copy(pixels.as_ptr() as *const _, pixels.len() as u32);
        bgfx_sys::bgfx_update_texture_cube(
            texture,
            0,
            side,
            mip,
            0,
            0,
            size,
            size,
            memory,
            u16::MAX,
        );
    }
    true
}

pub fn update_cube_rgba16f(
    handle: Dora3DHandle,
    side: u8,
    mip: u8,
    size: u16,
    pixels: &[[f32; 4]],
) -> bool {
    if size == 0 || pixels.len() != size as usize * size as usize {
        return false;
    }
    let Some(texture) = texture_handle(handle) else {
        return false;
    };
    if texture.idx == u16::MAX {
        return false;
    }
    let mut bytes = Vec::with_capacity(pixels.len() * 8);
    for pixel in pixels {
        for component in pixel {
            bytes.extend_from_slice(&float_to_half_bits(*component).to_le_bytes());
        }
    }
    unsafe {
        let memory = bgfx_sys::bgfx_copy(bytes.as_ptr() as *const _, bytes.len() as u32);
        bgfx_sys::bgfx_update_texture_cube(
            texture,
            0,
            side,
            mip,
            0,
            0,
            size,
            size,
            memory,
            u16::MAX,
        );
    }
    true
}

pub fn destroy(handle: Dora3DHandle) -> bool {
    registry().lock().unwrap().remove(&handle).is_some()
}

pub fn with_texture<R>(handle: Dora3DHandle, f: impl FnOnce(&TextureData) -> R) -> Option<R> {
    let textures = registry().lock().unwrap();
    textures.get(&handle).map(f)
}

pub fn texture_handle(handle: Dora3DHandle) -> Option<bgfx_sys::bgfx_texture_handle_t> {
    with_texture(handle, |texture| texture.texture)
}

pub fn clear_registry() {
    registry().lock().unwrap().clear();
}

pub fn invalid_handle() -> bgfx_sys::bgfx_texture_handle_t {
    invalid_texture()
}
