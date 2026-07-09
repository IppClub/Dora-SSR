use super::animation;
use super::material;
use super::model_loader;
use super::node3d;
use super::shader;
use super::skinning;
use super::types::{Aabb, Frustum, Mat4, Vec3};
use super::visual3d;
use super::Dora3DHandle;
use crate::bgfx_rs::bgfx_sys;
use std::collections::{HashMap, HashSet, VecDeque};
use std::sync::{Mutex, OnceLock};

#[derive(Debug, Clone)]
pub struct QueuedRenderItem3D {
	pub visual: Dora3DHandle,
	pub view_id: bgfx_sys::bgfx_view_id_t,
	pub sort_key: u64,
}

#[derive(Debug, Clone, Copy)]
pub struct ViewRenderState {
	pub view_proj: Mat4,
	pub view_pos: Vec3,
	pub frustum: Frustum,
	pub frustum_culling: bool,
}

#[derive(Debug, Clone, Copy)]
struct RenderVisualItem {
	visual: Dora3DHandle,
	mesh: Dora3DHandle,
	material: Dora3DHandle,
	node: Dora3DHandle,
	transparent: bool,
	distance_to_camera_sq: f32,
	sort_key: u64,
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
	view_id: bgfx_sys::bgfx_view_id_t,
	sort_key: u64,
) -> bool {
	if visual3d::with_visual(visual, |_| ()).is_none() {
		return false;
	}
	queue().lock().unwrap().push_back(QueuedRenderItem3D {
		visual,
		view_id,
		sort_key,
	});
	true
}

pub fn set_view_state(view_id: bgfx_sys::bgfx_view_id_t, view_proj: Mat4, view_pos: Vec3) {
	let frustum = Frustum::from_view_projection(&view_proj);
	let mut states = view_states().lock().unwrap();
	let frustum_culling = states
		.get(&view_id)
		.map(|state| state.frustum_culling)
		.unwrap_or(true);
	states.insert(
		view_id,
		ViewRenderState {
			view_proj,
			view_pos,
			frustum,
			frustum_culling,
		},
	);
}

pub fn set_view_frustum_culling(view_id: bgfx_sys::bgfx_view_id_t, enabled: bool) {
	let mut states = view_states().lock().unwrap();
	if let Some(state) = states.get_mut(&view_id) {
		state.frustum_culling = enabled;
	} else {
		states.insert(
			view_id,
			ViewRenderState {
				view_proj: Mat4::IDENTITY,
				view_pos: Vec3::ZERO,
				frustum: Frustum::from_view_projection(&Mat4::IDENTITY),
				frustum_culling: enabled,
			},
		);
	}
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

	let view_state = view_state(view_id);
	let render_items: Vec<_> = queued_items
		.into_iter()
		.filter_map(|item| collect_visual_item(item.visual, item.sort_key, &view_state))
		.collect();
	render_items_sorted(view_id, render_items, &view_state)
}

pub fn render_node(view_id: bgfx_sys::bgfx_view_id_t, root: Dora3DHandle) -> bool {
	if !node3d::exists(root) {
		return false;
	}
	let view_state = view_state(view_id);
	let mut render_items = Vec::new();
	let mut seen_visuals = HashSet::new();
	for node_handle in node3d::traverse(root) {
		for visual in visual3d::visuals_for_node(node_handle) {
			if visual.enabled && seen_visuals.insert(visual.handle) {
				if let Some(item) = collect_visual_item_from_parts(
					visual.handle,
					visual.mesh,
					visual.material,
					visual.node,
					visual.frustum_culling,
					default_sort_key(visual.material, visual.mesh),
					&view_state,
				) {
					render_items.push(item);
				}
			}
		}
	}
	render_items_sorted(view_id, render_items, &view_state)
}

fn view_state(view_id: bgfx_sys::bgfx_view_id_t) -> ViewRenderState {
	view_states()
		.lock()
		.unwrap()
		.get(&view_id)
		.copied()
		.unwrap_or(ViewRenderState {
			view_proj: Mat4::IDENTITY,
			view_pos: Vec3::ZERO,
			frustum: Frustum::from_view_projection(&Mat4::IDENTITY),
			frustum_culling: true,
		})
}

fn collect_visual_item(
	visual_handle: Dora3DHandle,
	sort_key: u64,
	view_state: &ViewRenderState,
) -> Option<RenderVisualItem> {
	let (mesh_handle, material_handle, node_handle, enabled, frustum_culling) =
		visual3d::with_visual(visual_handle, |visual| {
			(
				visual.mesh,
				visual.material,
				visual.node,
				visual.enabled,
				visual.frustum_culling,
			)
		})?;
	if !enabled {
		return None;
	}
	collect_visual_item_from_parts(
		visual_handle,
		mesh_handle,
		material_handle,
		node_handle,
		frustum_culling,
		sort_key,
		view_state,
	)
}

fn collect_visual_item_from_parts(
	visual_handle: Dora3DHandle,
	mesh_handle: Dora3DHandle,
	material_handle: Dora3DHandle,
	node_handle: Dora3DHandle,
	frustum_culling: bool,
	sort_key: u64,
	view_state: &ViewRenderState,
) -> Option<RenderVisualItem> {
	if view_state.frustum_culling && frustum_culling {
		let bounds = visual3d::world_bounds(visual_handle)?;
		if !should_render_bounds(view_state, frustum_culling, &bounds) {
			return None;
		}
	}
	let world = node3d::world_matrix(node_handle)?;
	let origin = world.transform_point3(Vec3::ZERO);
	let distance_to_camera_sq = origin.distance_squared(view_state.view_pos);
	Some(RenderVisualItem {
		visual: visual_handle,
		mesh: mesh_handle,
		material: material_handle,
		node: node_handle,
		transparent: material::is_transparent(material_handle),
		distance_to_camera_sq,
		sort_key,
	})
}

fn default_sort_key(material: Dora3DHandle, mesh: Dora3DHandle) -> u64 {
	((material & 0xffff_ffff) << 32) | (mesh & 0xffff_ffff)
}

fn should_render_bounds(
	view_state: &ViewRenderState,
	visual_frustum_culling: bool,
	bounds: &Aabb,
) -> bool {
	!view_state.frustum_culling
		|| !visual_frustum_culling
		|| view_state.frustum.intersects_aabb(bounds)
}

fn render_items_sorted(
	view_id: bgfx_sys::bgfx_view_id_t,
	render_items: Vec<RenderVisualItem>,
	view_state: &ViewRenderState,
) -> bool {
	let (opaque_items, transparent_items) = sort_render_items(render_items);
	shader::set_view_transforms(view_id, &view_state.view_proj, view_state.view_pos);
	render_items_in_order_with_state(opaque_items.iter().chain(transparent_items.iter()).copied())
}

fn sort_render_items(
	render_items: Vec<RenderVisualItem>,
) -> (Vec<RenderVisualItem>, Vec<RenderVisualItem>) {
	let mut opaque_items = Vec::new();
	let mut transparent_items = Vec::new();
	for item in render_items {
		if item.transparent {
			transparent_items.push(item);
		} else {
			opaque_items.push(item);
		}
	}
	opaque_items.sort_by_key(|item| item.sort_key);
	transparent_items.sort_by(|a, b| {
		b.distance_to_camera_sq
			.total_cmp(&a.distance_to_camera_sq)
			.then_with(|| a.visual.cmp(&b.visual))
	});
	(opaque_items, transparent_items)
}

fn render_items_in_order_with_state(items: impl Iterator<Item = RenderVisualItem>) -> bool {
	let mut submitted = false;
	for item in items {
		if render_visual_item(item) {
			submitted = true;
		}
	}
	submitted
}

fn render_visual_item(item: RenderVisualItem) -> bool {
	let world_matrix = node3d::world_matrix(item.node).unwrap_or(Mat4::IDENTITY);
	let mesh_world_inverse = world_matrix.inverse();
	let joint_matrices =
		model_loader::skeleton_for_visual(item.visual).and_then(|skeleton_handle| {
			animation::with_skeleton(skeleton_handle, |skeleton| {
				skinning::compute_joint_matrices(skeleton, mesh_world_inverse)
			})
		});
	shader::submit_mesh(
		item.mesh,
		item.material,
		&world_matrix,
		joint_matrices.as_deref(),
	)
}

pub fn clear_queue() {
	queue().lock().unwrap().clear();
	view_states().lock().unwrap().clear();
}

#[cfg(test)]
mod tests {
	use super::*;

	fn item(
		visual: Dora3DHandle,
		transparent: bool,
		distance_to_camera_sq: f32,
		sort_key: u64,
	) -> RenderVisualItem {
		RenderVisualItem {
			visual,
			mesh: 0,
			material: 0,
			node: 0,
			transparent,
			distance_to_camera_sq,
			sort_key,
		}
	}

	fn view_state_for_tests() -> ViewRenderState {
		let view = Mat4::look_at_rh(Vec3::new(0.0, 0.0, 5.0), Vec3::ZERO, Vec3::Y);
		let projection = Mat4::perspective_rh_gl(60.0_f32.to_radians(), 1.0, 0.1, 100.0);
		let view_proj = projection * view;
		ViewRenderState {
			view_proj,
			view_pos: Vec3::new(0.0, 0.0, 5.0),
			frustum: Frustum::from_view_projection(&view_proj),
			frustum_culling: true,
		}
	}

	#[test]
	fn sort_render_items_keeps_opaque_by_sort_key() {
		let (opaque, transparent) = sort_render_items(vec![
			item(1, false, 10.0, 30),
			item(2, false, 20.0, 10),
			item(3, false, 30.0, 20),
		]);
		assert!(transparent.is_empty());
		assert_eq!(
			opaque.iter().map(|item| item.sort_key).collect::<Vec<_>>(),
			vec![10, 20, 30]
		);
	}

	#[test]
	fn sort_render_items_keeps_transparent_back_to_front() {
		let (opaque, transparent) = sort_render_items(vec![
			item(1, true, 10.0, 0),
			item(2, true, 30.0, 0),
			item(3, true, 20.0, 0),
		]);
		assert!(opaque.is_empty());
		assert_eq!(
			transparent
				.iter()
				.map(|item| item.visual)
				.collect::<Vec<_>>(),
			vec![2, 3, 1]
		);
	}

	#[test]
	fn should_render_bounds_rejects_outside_when_enabled() {
		let view_state = view_state_for_tests();
		let outside = Aabb {
			min: Vec3::new(100.0, -0.5, -0.5),
			max: Vec3::new(101.0, 0.5, 0.5),
		};
		assert!(!should_render_bounds(&view_state, true, &outside));
	}

	#[test]
	fn should_render_bounds_keeps_outside_when_view_culling_disabled() {
		let mut view_state = view_state_for_tests();
		view_state.frustum_culling = false;
		let outside = Aabb {
			min: Vec3::new(100.0, -0.5, -0.5),
			max: Vec3::new(101.0, 0.5, 0.5),
		};
		assert!(should_render_bounds(&view_state, true, &outside));
	}

	#[test]
	fn should_render_bounds_keeps_outside_when_visual_culling_disabled() {
		let view_state = view_state_for_tests();
		let outside = Aabb {
			min: Vec3::new(100.0, -0.5, -0.5),
			max: Vec3::new(101.0, 0.5, 0.5),
		};
		assert!(should_render_bounds(&view_state, false, &outside));
	}
}
