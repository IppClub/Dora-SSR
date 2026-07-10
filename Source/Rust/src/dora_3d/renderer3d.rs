use super::animation;
use super::light3d::{self, SceneLights};
use super::material;
use super::model_loader;
use super::node3d;
use super::shader;
use super::skinning;
use super::types::{transform_aabb, Aabb, Frustum, Mat4, Vec3};
use super::visual3d;
use super::Dora3DHandle;
use crate::bgfx_rs::bgfx_sys;
use std::collections::{HashMap, HashSet, VecDeque};
use std::sync::{Mutex, OnceLock};
use std::time::Instant;

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

#[derive(Debug, Clone)]
struct RenderVisualItem {
	visual: Dora3DHandle,
	mesh: Dora3DHandle,
	material: Dora3DHandle,
	transparent: bool,
	distance_to_camera_sq: f32,
	sort_key: u64,
	world_bounds: Aabb,
	world_matrix: Mat4,
	joint_matrices: Option<Vec<Mat4>>,
}

pub const RENDER_STATS_VALUE_COUNT: usize = 30;

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct RenderStats3D {
	pub scene_nodes: u32,
	pub visible_visuals: u32,
	pub culled_visuals: u32,
	pub opaque_items: u32,
	pub transparent_items: u32,
	pub draw_calls: u32,
	pub triangles: u64,
	pub program_switches: u32,
	pub material_switches: u32,
	pub texture_switches: u32,
	pub mesh_switches: u32,
	pub node_count: u32,
	pub visual_count: u32,
	pub model_count: u32,
	pub model_instance_count: u32,
	pub mesh_count: u32,
	pub material_count: u32,
	pub texture_count: u32,
	pub animation_count: u32,
	pub environment_count: u32,
	pub model_resident_bytes: u64,
	pub mesh_resident_bytes: u64,
	pub texture_resident_bytes: u64,
	pub collect_micros: u64,
	pub sort_micros: u64,
	pub submit_micros: u64,
	pub upload_commands: u64,
	pub upload_bytes: u64,
	pub upload_micros: u64,
	pub upload_max_command_micros: u64,
}

impl RenderStats3D {
	pub fn to_values(self) -> [u64; RENDER_STATS_VALUE_COUNT] {
		[
			self.scene_nodes as u64,
			self.visible_visuals as u64,
			self.culled_visuals as u64,
			self.opaque_items as u64,
			self.transparent_items as u64,
			self.draw_calls as u64,
			self.triangles,
			self.program_switches as u64,
			self.material_switches as u64,
			self.texture_switches as u64,
			self.mesh_switches as u64,
			self.node_count as u64,
			self.visual_count as u64,
			self.model_count as u64,
			self.model_instance_count as u64,
			self.mesh_count as u64,
			self.material_count as u64,
			self.texture_count as u64,
			self.animation_count as u64,
			self.environment_count as u64,
			self.model_resident_bytes,
			self.mesh_resident_bytes,
			self.texture_resident_bytes,
			self.collect_micros,
			self.sort_micros,
			self.submit_micros,
			self.upload_commands,
			self.upload_bytes,
			self.upload_micros,
			self.upload_max_command_micros,
		]
	}
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

fn render_stats() -> &'static Mutex<HashMap<bgfx_sys::bgfx_view_id_t, RenderStats3D>> {
	static STATS: OnceLock<Mutex<HashMap<bgfx_sys::bgfx_view_id_t, RenderStats3D>>> =
		OnceLock::new();
	STATS.get_or_init(|| Mutex::new(HashMap::new()))
}

fn with_registry_counts(mut stats: RenderStats3D) -> RenderStats3D {
	stats.node_count = node3d::count() as u32;
	stats.visual_count = visual3d::count() as u32;
	stats.model_count = model_loader::model_count() as u32;
	stats.model_instance_count = model_loader::instance_count() as u32;
	stats.mesh_count = super::mesh::count() as u32;
	stats.material_count = material::count() as u32;
	stats.texture_count = super::texture::count() as u32;
	stats.animation_count = animation::count() as u32;
	stats.environment_count = shader::environment_count() as u32;
	stats.model_resident_bytes = model_loader::total_resident_bytes();
	stats.mesh_resident_bytes = super::mesh::total_resident_bytes();
	stats.texture_resident_bytes = super::texture::total_resident_bytes();
	let upload = super::profile3d::upload_totals();
	stats.upload_commands = upload.commands;
	stats.upload_bytes = upload.bytes;
	stats.upload_micros = upload.elapsed_micros;
	stats.upload_max_command_micros = upload.max_command_micros;
	stats
}

pub fn get_render_stats(view_id: bgfx_sys::bgfx_view_id_t) -> RenderStats3D {
	let stats = render_stats()
		.lock()
		.unwrap()
		.get(&view_id)
		.copied()
		.unwrap_or_default();
	with_registry_counts(stats)
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
	let collect_start = Instant::now();
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
	let mut stats = RenderStats3D::default();
	let render_items: Vec<_> = queued_items
		.into_iter()
		.filter_map(|item| collect_visual_item(item.visual, item.sort_key, &view_state, &mut stats))
		.collect();
	render_items_sorted(
		view_id,
		render_items,
		&view_state,
		&SceneLights::default(),
		stats,
		collect_start.elapsed().as_micros() as u64,
	)
}

pub fn render_node(view_id: bgfx_sys::bgfx_view_id_t, root: Dora3DHandle) -> bool {
	let collect_start = Instant::now();
	if !node3d::exists(root) {
		return false;
	}
	let view_state = view_state(view_id);
	let mut render_items = Vec::new();
	let mut stats = RenderStats3D::default();
	let mut seen_visuals = HashSet::new();
	let nodes = node3d::traverse(root);
	stats.scene_nodes = nodes.len() as u32;
	let scene_lights = light3d::collect_scene(&nodes);
	let visuals = visual3d::visuals_for_nodes(&nodes);
	let visual_handles: Vec<_> = visuals.iter().map(|visual| visual.handle).collect();
	let skeletons = model_loader::skeletons_for_visuals(&visual_handles);
	let skeleton_handles: Vec<_> = skeletons.values().copied().collect();
	let skeleton_data = animation::skeletons(&skeleton_handles);
	let mut matrix_nodes = nodes.clone();
	for skeleton in skeleton_data.values() {
		matrix_nodes.extend(skeleton.joints.iter().copied());
	}
	matrix_nodes.sort_unstable();
	matrix_nodes.dedup();
	let world_matrices = node3d::world_matrices(&matrix_nodes);
	for visual in visuals {
		if visual.enabled && seen_visuals.insert(visual.handle) {
			let Some(world) = world_matrices.get(&visual.node).copied() else {
				continue;
			};
			let joint_matrices = skeletons
				.get(&visual.handle)
				.and_then(|handle| skeleton_data.get(handle))
				.map(|skeleton| {
					skinning::compute_joint_matrices_from_world(
						skeleton,
						world.inverse(),
						&world_matrices,
					)
				});
			if let Some(item) = collect_prepared_visual_item(
				visual.handle,
				visual.mesh,
				visual.material,
				visual.frustum_culling,
				default_sort_key(visual.material, visual.mesh),
				world,
				joint_matrices,
				&view_state,
				&mut stats,
			) {
				render_items.push(item);
			}
		}
	}
	render_items_sorted(
		view_id,
		render_items,
		&view_state,
		&scene_lights,
		stats,
		collect_start.elapsed().as_micros() as u64,
	)
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
	stats: &mut RenderStats3D,
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
		model_loader::skeleton_for_visual(visual_handle),
		sort_key,
		view_state,
		stats,
	)
}

fn collect_visual_item_from_parts(
	visual_handle: Dora3DHandle,
	mesh_handle: Dora3DHandle,
	material_handle: Dora3DHandle,
	node_handle: Dora3DHandle,
	frustum_culling: bool,
	skeleton_handle: Option<Dora3DHandle>,
	sort_key: u64,
	view_state: &ViewRenderState,
	stats: &mut RenderStats3D,
) -> Option<RenderVisualItem> {
	let world = node3d::world_matrix(node_handle)?;
	let mesh_world_inverse = world.inverse();
	let joint_matrices = skeleton_handle.and_then(|skeleton_handle| {
		animation::with_skeleton(skeleton_handle, |skeleton| {
			skinning::compute_joint_matrices(skeleton, mesh_world_inverse)
		})
	});
	collect_prepared_visual_item(
		visual_handle,
		mesh_handle,
		material_handle,
		frustum_culling,
		sort_key,
		world,
		joint_matrices,
		view_state,
		stats,
	)
}

fn collect_prepared_visual_item(
	visual_handle: Dora3DHandle,
	mesh_handle: Dora3DHandle,
	material_handle: Dora3DHandle,
	frustum_culling: bool,
	sort_key: u64,
	world: Mat4,
	joint_matrices: Option<Vec<Mat4>>,
	view_state: &ViewRenderState,
	stats: &mut RenderStats3D,
) -> Option<RenderVisualItem> {
	let local_bounds = if let Some(joints) = joint_matrices.as_deref() {
		super::mesh::skinned_bounds(mesh_handle, joints)?
	} else {
		super::mesh::bounds(mesh_handle)?
	};
	let bounds = transform_aabb(&world, &local_bounds);
	if view_state.frustum_culling && frustum_culling {
		if !should_render_bounds(view_state, frustum_culling, &bounds) {
			stats.culled_visuals += 1;
			return None;
		}
	}
	stats.visible_visuals += 1;
	let origin = world.transform_point3(Vec3::ZERO);
	let distance_to_camera_sq = origin.distance_squared(view_state.view_pos);
	Some(RenderVisualItem {
		visual: visual_handle,
		mesh: mesh_handle,
		material: material_handle,
		transparent: material::is_transparent(material_handle),
		distance_to_camera_sq,
		sort_key,
		world_bounds: bounds,
		world_matrix: world,
		joint_matrices,
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
	scene_lights: &SceneLights,
	mut stats: RenderStats3D,
	collect_micros: u64,
) -> bool {
	stats.collect_micros = collect_micros;
	let sort_start = Instant::now();
	let (opaque_items, transparent_items) = sort_render_items(render_items);
	stats.sort_micros = sort_start.elapsed().as_micros() as u64;
	stats.opaque_items = opaque_items.len() as u32;
	stats.transparent_items = transparent_items.len() as u32;
	shader::set_view_transforms(view_id, &view_state.view_proj, view_state.view_pos);
	let submit_start = Instant::now();
	let submitted = render_items_in_order_with_state(
		view_id,
		opaque_items.into_iter().chain(transparent_items),
		scene_lights,
		&mut stats,
	);
	stats.submit_micros = submit_start.elapsed().as_micros() as u64;
	render_stats().lock().unwrap().insert(view_id, stats);
	submitted
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

fn render_items_in_order_with_state(
	view_id: bgfx_sys::bgfx_view_id_t,
	items: impl Iterator<Item = RenderVisualItem>,
	scene_lights: &SceneLights,
	stats: &mut RenderStats3D,
) -> bool {
	let mut submitted = false;
	let mut previous_program = None;
	let mut previous_material = None;
	let mut previous_mesh = None;
	let mut previous_textures: Option<Vec<(u8, u16)>> = None;
	for item in items {
		let material_changed = previous_material != Some(item.material);
		if render_visual_item(view_id, &item, scene_lights, material_changed) {
			submitted = true;
			let program = shader::program_index(item.material);
			if previous_program != Some(program) {
				stats.program_switches += 1;
				previous_program = Some(program);
			}
			if previous_material != Some(item.material) {
				stats.material_switches += 1;
				previous_material = Some(item.material);
			}
			if previous_mesh != Some(item.mesh) {
				stats.mesh_switches += 1;
				previous_mesh = Some(item.mesh);
			}
			let textures = material::texture_bindings(item.material);
			if previous_textures.as_ref() != Some(&textures) {
				stats.texture_switches += 1;
				previous_textures = Some(textures);
			}
			if let Some((draw_calls, triangles)) = super::mesh::submission_counts(item.mesh) {
				stats.draw_calls += draw_calls;
				stats.triangles += triangles;
			}
		}
	}
	submitted
}

fn render_visual_item(
	view_id: bgfx_sys::bgfx_view_id_t,
	item: &RenderVisualItem,
	scene_lights: &SceneLights,
	apply_material: bool,
) -> bool {
	let draw_lights = light3d::prepare_draw(item.visual, &item.world_bounds, scene_lights);
	shader::submit_mesh(
		view_id,
		item.mesh,
		item.material,
		&item.world_matrix,
		item.joint_matrices.as_deref(),
		&draw_lights,
		apply_material,
	)
}

pub fn clear_queue() {
	queue().lock().unwrap().clear();
	view_states().lock().unwrap().clear();
	render_stats().lock().unwrap().clear();
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
			transparent,
			distance_to_camera_sq,
			sort_key,
			world_bounds: Aabb::zero(),
			world_matrix: Mat4::IDENTITY,
			joint_matrices: None,
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

	#[test]
	fn render_stats_values_keep_public_field_order() {
		let stats = RenderStats3D {
			scene_nodes: 1,
			visible_visuals: 2,
			culled_visuals: 3,
			opaque_items: 4,
			transparent_items: 5,
			draw_calls: 6,
			triangles: 7,
			program_switches: 8,
			material_switches: 9,
			texture_switches: 10,
			mesh_switches: 11,
			node_count: 12,
			visual_count: 13,
			model_count: 14,
			model_instance_count: 15,
			mesh_count: 16,
			material_count: 17,
			texture_count: 18,
			animation_count: 19,
			environment_count: 20,
			model_resident_bytes: 21,
			mesh_resident_bytes: 22,
			texture_resident_bytes: 23,
			collect_micros: 24,
			sort_micros: 25,
			submit_micros: 26,
			upload_commands: 27,
			upload_bytes: 28,
			upload_micros: 29,
			upload_max_command_micros: 30,
		};
		assert_eq!(
			stats.to_values(),
			[
				1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
				24, 25, 26, 27, 28, 29, 30,
			]
		);
	}
}
