use super::{next_handle, Dora3DHandle};
use crate::bgfx_rs::bgfx_sys;
use std::collections::HashMap;
use std::ffi::CString;
use std::sync::{Mutex, OnceLock};

#[derive(Debug)]
pub struct TextureData {
    pub handle: Dora3DHandle,
    pub width: u16,
    pub height: u16,
    pub texture: bgfx_sys::bgfx_texture_handle_t,
}

impl Drop for TextureData {
    fn drop(&mut self) {
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
    if width == 0 || height == 0 || pixels.is_empty() {
        return None;
    }
    let texture = unsafe {
        let memory = bgfx_sys::bgfx_copy(pixels.as_ptr() as *const _, pixels.len() as u32);
        bgfx_sys::bgfx_create_texture_2d(
            width,
            height,
            false,
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
        },
    );
    Some(handle)
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
