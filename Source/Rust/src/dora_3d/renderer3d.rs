use super::animation;
use super::model_loader;
use super::node3d;
use super::shader;
use super::skinning;
use super::types::{Mat4, Vec3};
use super::visual3d;
use super::Dora3DHandle;
use crate::bgfx_rs::bgfx_sys;
use std::collections::{HashMap, VecDeque};
use std::sync::{Mutex, OnceLock};

#[derive(Debug, Clone)]
pub struct QueuedRenderItem3D {
    pub visual: Dora3DHandle,
    pub world: Mat4,
    pub view_id: bgfx_sys::bgfx_view_id_t,
}

#[derive(Debug, Clone, Copy)]
pub struct ViewRenderState {
    pub view_proj: Mat4,
    pub view_pos: Vec3,
}

fn queue() -> &'static Mutex<VecDeque<QueuedRenderItem3D>> {
    static QUEUE: OnceLock<Mutex<VecDeque<QueuedRenderItem3D>>> = OnceLock::new();
    QUEUE.get_or_init(|| Mutex::new(VecDeque::new()))
}

fn view_states() -> &'static Mutex<HashMap<bgfx_sys::bgfx_view_id_t, ViewRenderState>> {
    static VIEW_STATES: OnceLock<Mutex<HashMap<bgfx_sys::bgfx_view_id_t, ViewRenderState>>> =
        OnceLock::new();
    VIEW_STATES.get_or_init(|| Mutex::new(HashMap::new()))
}

pub fn queue_visual(
    visual: Dora3DHandle,
    world: Mat4,
    view_id: bgfx_sys::bgfx_view_id_t,
) -> bool {
    if visual3d::with_visual(visual, |_| ()).is_none() {
        return false;
    }
    queue().lock().unwrap().push_back(QueuedRenderItem3D {
        visual,
        world,
        view_id,
    });
    true
}

pub fn set_view_state(
    view_id: bgfx_sys::bgfx_view_id_t,
    view_proj: Mat4,
    view_pos: Vec3,
) {
    view_states()
        .lock()
        .unwrap()
        .insert(view_id, ViewRenderState { view_proj, view_pos });
}

pub fn render_view(view_id: bgfx_sys::bgfx_view_id_t) -> bool {
    let mut queued_items = Vec::new();
    {
        let mut items = queue().lock().unwrap();
        let mut remaining = VecDeque::new();
        while let Some(item) = items.pop_front() {
            if item.view_id == view_id {
                queued_items.push(item);
            } else {
                remaining.push_back(item);
            }
        }
        *items = remaining;
    }

    let view_state = view_states()
        .lock()
        .unwrap()
        .get(&view_id)
        .copied()
        .unwrap_or(ViewRenderState {
            view_proj: Mat4::IDENTITY,
            view_pos: Vec3::ZERO,
        });
    shader::set_view_transforms(view_id, &view_state.view_proj, view_state.view_pos);

    let mut submitted = false;
    for item in queued_items {
        let Some((mesh_handle, material_handle, node_handle)) =
            visual3d::with_visual(item.visual, |visual| (visual.mesh, visual.material, visual.node))
        else {
            continue;
        };
        let joint_matrices = model_loader::skeleton_for_visual(item.visual).and_then(|skeleton_handle| {
            animation::with_skeleton(skeleton_handle, |skeleton| {
                let mut world_transforms = HashMap::new();
                for joint_handle in &skeleton.joints {
                    if let Some(world) = node3d::world_matrix(*joint_handle) {
                        world_transforms.insert(*joint_handle, world);
                    }
                }
                skinning::compute_joint_matrices(skeleton, &world_transforms)
            })
        });
        let world_matrix = node3d::world_matrix(node_handle).unwrap_or(item.world);
        if shader::submit_mesh(
            mesh_handle,
            material_handle,
            &world_matrix,
            &view_state.view_proj,
            view_state.view_pos,
            joint_matrices.as_deref(),
        ) {
            submitted = true;
        }
    }
    submitted
}

pub fn clear_queue() {
    queue().lock().unwrap().clear();
    view_states().lock().unwrap().clear();
}
