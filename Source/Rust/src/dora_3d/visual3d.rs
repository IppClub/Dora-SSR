use super::mesh;
use super::node3d;
use super::types::{transform_aabb, Aabb, Mat4};
use super::{next_handle, Dora3DHandle};
use std::collections::HashMap;
use std::sync::{Mutex, OnceLock};

#[derive(Debug, Clone)]
pub struct Visual3DData {
    pub handle: Dora3DHandle,
    pub node: Dora3DHandle,
    pub mesh: Dora3DHandle,
    pub material: Dora3DHandle,
    pub frustum_culling: bool,
    pub enabled: bool,
}

fn registry() -> &'static Mutex<HashMap<Dora3DHandle, Visual3DData>> {
    static REGISTRY: OnceLock<Mutex<HashMap<Dora3DHandle, Visual3DData>>> = OnceLock::new();
    REGISTRY.get_or_init(|| Mutex::new(HashMap::new()))
}

pub fn create(node: Dora3DHandle, mesh: Dora3DHandle, material: Dora3DHandle) -> Dora3DHandle {
    let handle = next_handle();
    registry().lock().unwrap().insert(
        handle,
        Visual3DData {
            handle,
            node,
            mesh,
            material,
            frustum_culling: true,
            enabled: true,
        },
    );
    handle
}

pub fn destroy(handle: Dora3DHandle) -> bool {
    registry().lock().unwrap().remove(&handle).is_some()
}

pub fn set_mesh(handle: Dora3DHandle, mesh_handle: Dora3DHandle) -> bool {
    let mut visuals = registry().lock().unwrap();
    let Some(visual) = visuals.get_mut(&handle) else {
        return false;
    };
    visual.mesh = mesh_handle;
    true
}

pub fn set_material(handle: Dora3DHandle, material_handle: Dora3DHandle) -> bool {
    let mut visuals = registry().lock().unwrap();
    let Some(visual) = visuals.get_mut(&handle) else {
        return false;
    };
    visual.material = material_handle;
    true
}

pub fn set_node(handle: Dora3DHandle, node_handle: Dora3DHandle) -> bool {
    let mut visuals = registry().lock().unwrap();
    let Some(visual) = visuals.get_mut(&handle) else {
        return false;
    };
    visual.node = node_handle;
    true
}

pub fn set_enabled(handle: Dora3DHandle, enabled: bool) -> bool {
    let mut visuals = registry().lock().unwrap();
    let Some(visual) = visuals.get_mut(&handle) else {
        return false;
    };
    visual.enabled = enabled;
    true
}

pub fn visuals_for_node(node_handle: Dora3DHandle) -> Vec<Visual3DData> {
    registry()
        .lock()
        .unwrap()
        .values()
        .filter(|visual| visual.node == node_handle)
        .cloned()
        .collect()
}

pub fn with_visual<R>(handle: Dora3DHandle, f: impl FnOnce(&Visual3DData) -> R) -> Option<R> {
    let visuals = registry().lock().unwrap();
    visuals.get(&handle).map(f)
}

pub fn world_bounds(handle: Dora3DHandle) -> Option<Aabb> {
    with_visual(handle, |visual| (visual.node, visual.mesh)).and_then(
        |(node_handle, mesh_handle)| {
            let bounds = mesh::bounds(mesh_handle)?;
            let world = node3d::world_matrix(node_handle)?;
            Some(transform_aabb(&world, &bounds))
        },
    )
}

pub fn world_matrix(handle: Dora3DHandle) -> Option<Mat4> {
    with_visual(handle, |visual| visual.node).and_then(node3d::world_matrix)
}

pub fn clear_registry() {
    registry().lock().unwrap().clear();
}
