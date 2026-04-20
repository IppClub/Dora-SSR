use super::types::{mat4_to_bgfx_array, Mat4, Vec3};
use super::{next_handle, Dora3DHandle};
use std::collections::HashMap;
use std::sync::{Mutex, OnceLock};

#[derive(Debug, Clone, Copy)]
pub enum Projection {
    Perspective {
        fov_y_radians: f32,
        aspect: f32,
        near: f32,
        far: f32,
    },
    Orthographic {
        width: f32,
        height: f32,
        near: f32,
        far: f32,
    },
}

#[derive(Debug, Clone)]
pub struct Camera3DData {
    pub handle: Dora3DHandle,
    pub position: Vec3,
    pub target: Vec3,
    pub up: Vec3,
    pub projection: Projection,
}

impl Camera3DData {
    fn new(handle: Dora3DHandle) -> Self {
        Self {
            handle,
            position: Vec3::new(0.0, 0.0, 10.0),
            target: Vec3::ZERO,
            up: Vec3::Y,
            projection: Projection::Perspective {
                fov_y_radians: 60.0_f32.to_radians(),
                aspect: 16.0 / 9.0,
                near: 0.1,
                far: 1000.0,
            },
        }
    }
}

fn registry() -> &'static Mutex<HashMap<Dora3DHandle, Camera3DData>> {
    static REGISTRY: OnceLock<Mutex<HashMap<Dora3DHandle, Camera3DData>>> = OnceLock::new();
    REGISTRY.get_or_init(|| Mutex::new(HashMap::new()))
}

pub fn create() -> Dora3DHandle {
    let handle = next_handle();
    registry()
        .lock()
        .unwrap()
        .insert(handle, Camera3DData::new(handle));
    handle
}

pub fn destroy(handle: Dora3DHandle) -> bool {
    registry().lock().unwrap().remove(&handle).is_some()
}

pub fn set_perspective(
    handle: Dora3DHandle,
    fov_y_degrees: f32,
    aspect: f32,
    near: f32,
    far: f32,
) -> bool {
    let mut cameras = registry().lock().unwrap();
    let Some(camera) = cameras.get_mut(&handle) else {
        return false;
    };
    camera.projection = Projection::Perspective {
        fov_y_radians: fov_y_degrees.to_radians(),
        aspect,
        near,
        far,
    };
    true
}

pub fn set_orthographic(
    handle: Dora3DHandle,
    width: f32,
    height: f32,
    near: f32,
    far: f32,
) -> bool {
    let mut cameras = registry().lock().unwrap();
    let Some(camera) = cameras.get_mut(&handle) else {
        return false;
    };
    camera.projection = Projection::Orthographic {
        width,
        height,
        near,
        far,
    };
    true
}

pub fn look_at(handle: Dora3DHandle, position: Vec3, target: Vec3, up: Vec3) -> bool {
    let mut cameras = registry().lock().unwrap();
    let Some(camera) = cameras.get_mut(&handle) else {
        return false;
    };
    camera.position = position;
    camera.target = target;
    camera.up = up.normalize_or_zero();
    true
}

pub fn set_position(handle: Dora3DHandle, position: Vec3) -> bool {
    let mut cameras = registry().lock().unwrap();
    let Some(camera) = cameras.get_mut(&handle) else {
        return false;
    };
    camera.position = position;
    true
}

pub fn set_target(handle: Dora3DHandle, target: Vec3) -> bool {
    let mut cameras = registry().lock().unwrap();
    let Some(camera) = cameras.get_mut(&handle) else {
        return false;
    };
    camera.target = target;
    true
}

pub fn set_up(handle: Dora3DHandle, up: Vec3) -> bool {
    let mut cameras = registry().lock().unwrap();
    let Some(camera) = cameras.get_mut(&handle) else {
        return false;
    };
    camera.up = up.normalize_or_zero();
    true
}

pub fn get(handle: Dora3DHandle) -> Option<Camera3DData> {
    registry().lock().unwrap().get(&handle).cloned()
}

pub fn view_matrix(handle: Dora3DHandle) -> Option<Mat4> {
    let camera = get(handle)?;
    Some(Mat4::look_at_rh(camera.position, camera.target, camera.up))
}

pub fn projection_matrix(handle: Dora3DHandle) -> Option<Mat4> {
    let camera = get(handle)?;
    let projection = match camera.projection {
        Projection::Perspective {
            fov_y_radians,
            aspect,
            near,
            far,
        } => Mat4::perspective_rh(fov_y_radians, aspect, near, far),
        Projection::Orthographic {
            width,
            height,
            near,
            far,
        } => {
            let half_width = width * 0.5;
            let half_height = height * 0.5;
            Mat4::orthographic_rh(
                -half_width,
                half_width,
                -half_height,
                half_height,
                near,
                far,
            )
        }
    };
    Some(projection)
}

pub fn view_projection_matrix(handle: Dora3DHandle) -> Option<Mat4> {
    Some(projection_matrix(handle)? * view_matrix(handle)?)
}

pub fn view_matrix_bgfx(handle: Dora3DHandle) -> Option<[f32; 16]> {
    view_matrix(handle).map(|matrix| mat4_to_bgfx_array(&matrix))
}

pub fn projection_matrix_bgfx(handle: Dora3DHandle) -> Option<[f32; 16]> {
    projection_matrix(handle).map(|matrix| mat4_to_bgfx_array(&matrix))
}

pub fn clear_registry() {
    registry().lock().unwrap().clear();
}
