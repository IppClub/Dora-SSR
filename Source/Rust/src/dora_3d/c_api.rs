use super::camera3d;
use super::model_loader;
use super::node3d;
use super::renderer3d;
use super::types::{mat4_from_bgfx_array, mat4_to_bgfx_array, Mat4, Quaternion, Vec3};
use super::visual3d;
use super::Dora3DHandle;
use std::ffi::CStr;
use std::os::raw::c_char;

#[repr(C)]
pub struct Node3D {
    handle: Dora3DHandle,
}

#[repr(C)]
pub struct Camera3D {
    handle: Dora3DHandle,
}

#[repr(C)]
pub struct Visual3D {
    handle: Dora3DHandle,
}

#[repr(C)]
pub struct Model3D {
    handle: Dora3DHandle,
    visuals: Vec<*mut Visual3D>,
}

fn opt_str<'a>(ptr: *const c_char) -> Option<&'a str> {
    if ptr.is_null() {
        return None;
    }
    unsafe { CStr::from_ptr(ptr).to_str().ok() }
}

fn write_vec3(out: *mut f32, value: Vec3) -> bool {
    if out.is_null() {
        return false;
    }
    unsafe {
        let data = [value.x, value.y, value.z];
        std::ptr::copy_nonoverlapping(data.as_ptr(), out, data.len());
    }
    true
}

fn write_mat4(out: *mut f32, matrix: Mat4) -> bool {
    if out.is_null() {
        return false;
    }
    unsafe {
        let packed = mat4_to_bgfx_array(&matrix);
        std::ptr::copy_nonoverlapping(packed.as_ptr(), out, packed.len());
    }
    true
}

fn node_handle(node: *const Node3D) -> Option<Dora3DHandle> {
    if node.is_null() {
        return None;
    }
    Some(unsafe { (*node).handle })
}

fn camera_handle(camera: *const Camera3D) -> Option<Dora3DHandle> {
    if camera.is_null() {
        return None;
    }
    Some(unsafe { (*camera).handle })
}

fn visual_handle(visual: *const Visual3D) -> Option<Dora3DHandle> {
    if visual.is_null() {
        return None;
    }
    Some(unsafe { (*visual).handle })
}

#[no_mangle]
pub extern "C" fn dora_3d_cleanup() {
    renderer3d::clear_queue();
    model_loader::clear_registry();
    visual3d::clear_registry();
    super::material::clear_registry();
    super::mesh::clear_registry();
    super::texture::clear_registry();
    camera3d::clear_registry();
    node3d::clear_registry();
}

#[no_mangle]
pub extern "C" fn dora_3d_render_with_view(view_id: u16) -> i32 {
    renderer3d::render_view(view_id) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_queue_visual(
    visual: *mut Visual3D,
    world_matrix: *const f32,
    view_id: u16,
) -> i32 {
    let Some(handle) = visual_handle(visual) else {
        return 0;
    };
    if world_matrix.is_null() {
        return 0;
    }
    let packed = unsafe {
        let mut data = [0.0f32; 16];
        std::ptr::copy_nonoverlapping(world_matrix, data.as_mut_ptr(), data.len());
        data
    };
    renderer3d::queue_visual(handle, mat4_from_bgfx_array(&packed), view_id) as i32
}

#[no_mangle]
pub extern "C" fn dora_3d_node_create() -> *mut Node3D {
    Box::into_raw(Box::new(Node3D {
        handle: node3d::create(),
    }))
}

#[no_mangle]
pub extern "C" fn dora_3d_node_destroy(node: *mut Node3D) {
    if node.is_null() {
        return;
    }
    let node = unsafe { Box::from_raw(node) };
    let _ = node3d::destroy(node.handle);
}

#[no_mangle]
pub extern "C" fn dora_3d_node_add_child(parent: *mut Node3D, child: *mut Node3D) {
    let (Some(parent), Some(child)) = (node_handle(parent), node_handle(child)) else {
        return;
    };
    let _ = node3d::add_child(parent, child, 0, None);
}

#[no_mangle]
pub extern "C" fn dora_3d_node_remove_child(parent: *mut Node3D, child: *mut Node3D) {
    let (Some(parent), Some(child)) = (node_handle(parent), node_handle(child)) else {
        return;
    };
    let _ = node3d::remove_child(parent, child);
}

#[no_mangle]
pub extern "C" fn dora_3d_node_set_position(node: *mut Node3D, x: f32, y: f32, z: f32) {
    let Some(handle) = node_handle(node) else {
        return;
    };
    let _ = node3d::set_position(handle, Vec3::new(x, y, z));
}

#[no_mangle]
pub extern "C" fn dora_3d_node_get_position(node: *mut Node3D, out: *mut f32) {
    let Some(handle) = node_handle(node) else {
        return;
    };
    let Some(position) = node3d::get_position(handle) else {
        return;
    };
    let _ = write_vec3(out, position);
}

#[no_mangle]
pub extern "C" fn dora_3d_node_set_rotation(node: *mut Node3D, x: f32, y: f32, z: f32, w: f32) {
    let Some(handle) = node_handle(node) else {
        return;
    };
    let _ = node3d::set_rotation(handle, Quaternion::from_xyzw(x, y, z, w));
}

#[no_mangle]
pub extern "C" fn dora_3d_node_set_scale(node: *mut Node3D, x: f32, y: f32, z: f32) {
    let Some(handle) = node_handle(node) else {
        return;
    };
    let _ = node3d::set_scale(handle, Vec3::new(x, y, z));
}

#[no_mangle]
pub extern "C" fn dora_3d_node_get_world_matrix(node: *mut Node3D, out: *mut f32) {
    let Some(handle) = node_handle(node) else {
        return;
    };
    let Some(matrix) = node3d::world_matrix(handle) else {
        return;
    };
    let _ = write_mat4(out, matrix);
}

#[no_mangle]
pub extern "C" fn dora_3d_camera_create() -> *mut Camera3D {
    Box::into_raw(Box::new(Camera3D {
        handle: camera3d::create(),
    }))
}

#[no_mangle]
pub extern "C" fn dora_3d_camera_set_perspective(
    camera: *mut Camera3D,
    fov: f32,
    aspect: f32,
    near: f32,
    far: f32,
) {
    let Some(handle) = camera_handle(camera) else {
        return;
    };
    let _ = camera3d::set_perspective(handle, fov, aspect, near, far);
}

#[no_mangle]
pub extern "C" fn dora_3d_camera_set_lookat(
    camera: *mut Camera3D,
    ex: f32,
    ey: f32,
    ez: f32,
    tx: f32,
    ty: f32,
    tz: f32,
) {
    let Some(handle) = camera_handle(camera) else {
        return;
    };
    let _ = camera3d::look_at(
        handle,
        Vec3::new(ex, ey, ez),
        Vec3::new(tx, ty, tz),
        Vec3::Y,
    );
}

#[no_mangle]
pub extern "C" fn dora_3d_camera_get_view_proj(camera: *mut Camera3D, out: *mut f32) {
    let Some(handle) = camera_handle(camera) else {
        return;
    };
    let Some(matrix) = camera3d::view_projection_matrix(handle) else {
        return;
    };
    let _ = write_mat4(out, matrix);
}

#[no_mangle]
pub extern "C" fn dora_3d_load_gltf(path: *const c_char) -> *mut Model3D {
    let Some(path) = opt_str(path) else {
        return std::ptr::null_mut();
    };
    let Some(handle) = model_loader::load_gltf(path) else {
        return std::ptr::null_mut();
    };
    let visuals = model_loader::with_model(handle, |model| {
        model
            .visuals
            .iter()
            .copied()
            .map(|visual| Box::into_raw(Box::new(Visual3D { handle: visual })))
            .collect::<Vec<_>>()
    })
    .unwrap_or_default();
    Box::into_raw(Box::new(Model3D { handle, visuals }))
}

#[no_mangle]
pub extern "C" fn dora_3d_model_destroy(model: *mut Model3D) {
    if model.is_null() {
        return;
    }
    let mut model = unsafe { Box::from_raw(model) };
    for visual in model.visuals.drain(..) {
        if !visual.is_null() {
            unsafe {
                drop(Box::from_raw(visual));
            }
        }
    }
    let _ = model_loader::destroy(model.handle);
}

#[no_mangle]
pub extern "C" fn dora_3d_model_get_visual(model: *mut Model3D, index: u32) -> *mut Visual3D {
    if model.is_null() {
        return std::ptr::null_mut();
    }
    unsafe {
        (&(*model).visuals)
            .get(index as usize)
            .copied()
            .unwrap_or(std::ptr::null_mut())
    }
}

#[no_mangle]
pub extern "C" fn dora_3d_visual_add_to_node(visual: *mut Visual3D, node: *mut Node3D) {
    let (Some(visual), Some(node)) = (visual_handle(visual), node_handle(node)) else {
        return;
    };
    let _ = visual3d::set_node(visual, node);
}
