use super::animation;
use super::light3d::{self, SceneLights};
use super::material;
use super::model_loader;
use super::node3d;
use super::shader;
use super::skinning;
use super::types::{transform_aabb, Aabb, Frustum, Mat4, Vec3, Vec4};
use super::visual3d;
use super::Dora3DHandle;
use crate::bgfx_rs::bgfx_sys;
use std::collections::{HashMap, HashSet, VecDeque};
use std::sync::{Arc, Mutex, OnceLock};
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
	pub show_aabb: bool,
	pub shadow_map_size: u16,
}

const DEFAULT_SHADOW_MAP_SIZE: u16 = 1024;

#[derive(Debug, Clone, Copy)]
enum PhysicsDebugShape {
	Bounds(Aabb),
	Primitive {
		kind: u8,
		size: Vec3,
		transform: Mat4,
	},
}

#[derive(Debug, Clone, Copy)]
struct PhysicsDebugItem {
	root: Dora3DHandle,
	shape: PhysicsDebugShape,
	color: Vec4,
}

fn physics_debug_items() -> &'static Mutex<Vec<PhysicsDebugItem>> {
	static BOUNDS: OnceLock<Mutex<Vec<PhysicsDebugItem>>> = OnceLock::new();
	BOUNDS.get_or_init(|| Mutex::new(Vec::new()))
}

pub fn queue_physics_debug_bounds(root: Dora3DHandle, bounds: Aabb, color: Vec4) {
	if bounds.is_valid() {
		physics_debug_items()
			.lock()
			.unwrap()
			.push(PhysicsDebugItem {
				root,
				shape: PhysicsDebugShape::Bounds(bounds),
				color,
			});
	}
}

pub fn queue_physics_debug_shape(
	root: Dora3DHandle,
	kind: u8,
	size: Vec3,
	transform: Mat4,
	color: Vec4,
) {
	if kind <= 3 && size.is_finite() && transform.is_finite() {
		physics_debug_items()
			.lock()
			.unwrap()
			.push(PhysicsDebugItem {
				root,
				shape: PhysicsDebugShape::Primitive {
					kind,
					size,
					transform,
				},
				color,
			});
	}
}

fn take_physics_debug_items(root: Dora3DHandle) -> Vec<PhysicsDebugItem> {
	let mut queued = physics_debug_items().lock().unwrap();
	let mut selected = Vec::new();
	let mut index = 0;
	while index < queued.len() {
		if queued[index].root == root {
			selected.push(queued.swap_remove(index));
		} else {
			index += 1;
		}
	}
	selected
}

#[derive(Debug, Clone)]
struct RenderVisualItem {
	visual: Dora3DHandle,
	mesh: Dora3DHandle,
	material: Dora3DHandle,
	frustum_culling: bool,
	transparent: bool,
	distance_to_camera_sq: f32,
	sort_key: u64,
	world_bounds: Aabb,
	world_matrix: Mat4,
	joint_matrices: Option<Vec<Mat4>>,
}

#[derive(Debug, Default)]
struct RenderWorkspace {
	nodes: Vec<Dora3DHandle>,
	traversal_stack: Vec<Dora3DHandle>,
	visuals: Vec<visual3d::Visual3DData>,
	visual_handles: Vec<Dora3DHandle>,
	seen_visuals: HashSet<Dora3DHandle>,
	skeletons: HashMap<Dora3DHandle, Dora3DHandle>,
	skeleton_handles: Vec<Dora3DHandle>,
	skeleton_data: HashMap<Dora3DHandle, Arc<animation::SkeletonData>>,
	world_matrices: HashMap<Dora3DHandle, Mat4>,
}

pub const RENDER_STATS_VALUE_COUNT: usize = 32;

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
	pub static_mesh_count: u32,
	pub dynamic_mesh_count: u32,
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
			self.static_mesh_count as u64,
			self.dynamic_mesh_count as u64,
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

fn render_workspaces() -> &'static Mutex<HashMap<bgfx_sys::bgfx_view_id_t, RenderWorkspace>> {
	static WORKSPACES: OnceLock<Mutex<HashMap<bgfx_sys::bgfx_view_id_t, RenderWorkspace>>> =
		OnceLock::new();
	WORKSPACES.get_or_init(|| Mutex::new(HashMap::new()))
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
	let (static_meshes, dynamic_meshes) = super::mesh::buffer_counts();
	stats.static_mesh_count = static_meshes as u32;
	stats.dynamic_mesh_count = dynamic_meshes as u32;
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
	let show_aabb = states
		.get(&view_id)
		.map(|state| state.show_aabb)
		.unwrap_or(false);
	let shadow_map_size = states
		.get(&view_id)
		.map(|state| state.shadow_map_size)
		.unwrap_or(DEFAULT_SHADOW_MAP_SIZE);
	states.insert(
		view_id,
		ViewRenderState {
			view_proj,
			view_pos,
			frustum,
			frustum_culling,
			show_aabb,
			shadow_map_size,
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
				show_aabb: false,
				shadow_map_size: DEFAULT_SHADOW_MAP_SIZE,
			},
		);
	}
}

pub fn set_view_show_aabb(view_id: bgfx_sys::bgfx_view_id_t, enabled: bool) {
	let mut states = view_states().lock().unwrap();
	if let Some(state) = states.get_mut(&view_id) {
		state.show_aabb = enabled;
	} else {
		states.insert(
			view_id,
			ViewRenderState {
				view_proj: Mat4::IDENTITY,
				view_pos: Vec3::ZERO,
				frustum: Frustum::from_view_projection(&Mat4::IDENTITY),
				frustum_culling: true,
				show_aabb: enabled,
				shadow_map_size: DEFAULT_SHADOW_MAP_SIZE,
			},
		);
	}
}

pub fn set_view_shadow_map_size(view_id: bgfx_sys::bgfx_view_id_t, size: u16) {
	let mut states = view_states().lock().unwrap();
	if let Some(state) = states.get_mut(&view_id) {
		state.shadow_map_size = size;
	} else {
		states.insert(
			view_id,
			ViewRenderState {
				view_proj: Mat4::IDENTITY,
				view_pos: Vec3::ZERO,
				frustum: Frustum::from_view_projection(&Mat4::IDENTITY),
				frustum_culling: true,
				show_aabb: false,
				shadow_map_size: size,
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
		None,
		stats,
		collect_start.elapsed().as_micros() as u64,
	)
}

pub fn render_node(view_id: bgfx_sys::bgfx_view_id_t, root: Dora3DHandle) -> bool {
	render_node_internal(view_id, None, root)
}

pub fn render_node_with_shadow(
	view_id: bgfx_sys::bgfx_view_id_t,
	shadow_view_id: bgfx_sys::bgfx_view_id_t,
	root: Dora3DHandle,
) -> bool {
	render_node_internal(view_id, Some(shadow_view_id), root)
}

fn render_node_internal(
	view_id: bgfx_sys::bgfx_view_id_t,
	shadow_view_id: Option<bgfx_sys::bgfx_view_id_t>,
	root: Dora3DHandle,
) -> bool {
	let collect_start = Instant::now();
	if !node3d::exists(root) {
		shader::remove_shadow_map(root);
		return false;
	}
	if shadow_view_id.is_none() {
		shader::remove_shadow_map(root);
	}
	let view_state = view_state(view_id);
	let mut scene_items = Vec::new();
	let mut stats = RenderStats3D::default();
	let mut workspace = render_workspaces()
		.lock()
		.unwrap()
		.remove(&view_id)
		.unwrap_or_default();
	node3d::traverse_into(root, &mut workspace.nodes, &mut workspace.traversal_stack);
	stats.scene_nodes = workspace.nodes.len() as u32;
	let scene_lights = light3d::collect_scene(&workspace.nodes);
	visual3d::visuals_for_nodes_into(&workspace.nodes, &mut workspace.visuals);
	workspace.visual_handles.clear();
	workspace
		.visual_handles
		.extend(workspace.visuals.iter().map(|visual| visual.handle));
	model_loader::skeletons_for_visuals_into(&workspace.visual_handles, &mut workspace.skeletons);
	workspace.skeleton_handles.clear();
	workspace
		.skeleton_handles
		.extend(workspace.skeletons.values().copied());
	workspace.skeleton_handles.sort_unstable();
	workspace.skeleton_handles.dedup();
	animation::skeletons_into(&workspace.skeleton_handles, &mut workspace.skeleton_data);
	for skeleton in workspace.skeleton_data.values() {
		workspace.nodes.extend(skeleton.joints.iter().copied());
	}
	workspace.nodes.sort_unstable();
	workspace.nodes.dedup();
	node3d::world_matrices_into(&workspace.nodes, &mut workspace.world_matrices);
	workspace.seen_visuals.clear();
	for visual in &workspace.visuals {
		if visual.enabled && workspace.seen_visuals.insert(visual.handle) {
			let Some(world) = workspace.world_matrices.get(&visual.node).copied() else {
				continue;
			};
			let joint_matrices = workspace
				.skeletons
				.get(&visual.handle)
				.and_then(|handle| workspace.skeleton_data.get(handle))
				.map(|skeleton| {
					skinning::compute_joint_matrices_from_world(
						skeleton,
						world.inverse(),
						&workspace.world_matrices,
					)
				});
			if let Some(item) = prepare_visual_item(
				visual.handle,
				visual.mesh,
				visual.material,
				visual.frustum_culling,
				default_sort_key(visual.material, visual.mesh),
				world,
				joint_matrices,
				&view_state,
			) {
				scene_items.push(item);
			}
		}
	}
	let shadow = shadow_view_id.and_then(|shadow_view_id| {
		prepare_shadow_pass(
			root,
			shadow_view_id,
			&scene_items,
			&view_state,
			&scene_lights,
		)
	});
	let render_items = scene_items
		.into_iter()
		.filter(|item| {
			if should_render_bounds(&view_state, item.frustum_culling, &item.world_bounds) {
				stats.visible_visuals += 1;
				true
			} else {
				stats.culled_visuals += 1;
				false
			}
		})
		.collect();
	let mut result = render_items_sorted(
		view_id,
		render_items,
		&view_state,
		&scene_lights,
		shadow.as_ref(),
		stats,
		collect_start.elapsed().as_micros() as u64,
	);
	let debug_items = take_physics_debug_items(root);
	if !debug_items.is_empty() {
		let debug_material = debug_bounds_material();
		for debug in debug_items {
			result |= match debug.shape {
				PhysicsDebugShape::Bounds(bounds) => shader::submit_debug_bounds_colored(
					view_id,
					&bounds,
					debug.color,
					debug_material,
				),
				PhysicsDebugShape::Primitive {
					kind,
					size,
					transform,
				} => shader::submit_debug_shape_colored(
					view_id,
					kind,
					size,
					transform,
					debug.color,
					debug_material,
				),
			};
		}
	}
	render_workspaces()
		.lock()
		.unwrap()
		.insert(view_id, workspace);
	result
}

fn prepare_shadow_pass(
	root: Dora3DHandle,
	view_id: bgfx_sys::bgfx_view_id_t,
	items: &[RenderVisualItem],
	view_state: &ViewRenderState,
	scene_lights: &SceneLights,
) -> Option<shader::ShadowDrawState> {
	let light = scene_lights.directional.filter(|light| light.cast_shadow)?;
	if items.is_empty() {
		return None;
	}
	// A single shadow map cannot preserve useful texel density over the camera's
	// entire far plane. Keep the first-person gameplay region sharp; larger
	// worlds should move to cascades instead of stretching this projection.
	const SHADOW_DISTANCE: f32 = 20.0;
	let shadow_size = view_state.shadow_map_size;
	let texture = shader::prepare_shadow_map(root, view_id, shadow_size)?;
	let caps = unsafe { &*bgfx_sys::bgfx_get_caps() };
	let frustum_corners =
		shadow_frustum_corners(view_state.view_proj, caps.homogeneousDepth, SHADOW_DISTANCE)?;
	let center = frustum_corners.iter().copied().sum::<Vec3>() / frustum_corners.len() as f32;
	let direction = light.direction.normalize_or_zero();
	if direction.length_squared() <= f32::EPSILON {
		return None;
	}
	let up = if direction.dot(Vec3::Y).abs() > 0.95 {
		Vec3::X
	} else {
		Vec3::Y
	};
	let eye = center + direction * (SHADOW_DISTANCE + 1.0);
	let light_view = Mat4::look_at_rh(eye, center, up);
	let mut receiver_bounds = Aabb::empty();
	for corner in frustum_corners {
		receiver_bounds.include(light_view.transform_point3(corner));
	}
	if !receiver_bounds.is_valid() {
		return None;
	}
	let mut caster_bounds = Aabb::empty();
	let padding = ((receiver_bounds.max.x - receiver_bounds.min.x)
		.max(receiver_bounds.max.y - receiver_bounds.min.y)
		* 0.05)
		.max(0.1);
	let mut shadow_items = Vec::new();
	for item in items {
		let mut light_bounds = Aabb::empty();
		for corner in item.world_bounds.corners() {
			light_bounds.include(light_view.transform_point3(corner));
		}
		if shadow_caster_overlaps_receiver(&light_bounds, &receiver_bounds, padding) {
			for corner in light_bounds.corners() {
				caster_bounds.include(corner);
			}
			shadow_items.push(item);
		}
	}
	if !caster_bounds.is_valid() || shadow_items.is_empty() {
		return None;
	}
	let half_extent = ((receiver_bounds.max.x - receiver_bounds.min.x)
		.max(receiver_bounds.max.y - receiver_bounds.min.y)
		* 0.5 + padding)
		.max(0.1);
	let world_units_per_texel = half_extent * 2.0 / shadow_size as f32;
	let center_x = ((receiver_bounds.min.x + receiver_bounds.max.x) * 0.5 / world_units_per_texel)
		.round()
		* world_units_per_texel;
	let center_y = ((receiver_bounds.min.y + receiver_bounds.max.y) * 0.5 / world_units_per_texel)
		.round()
		* world_units_per_texel;
	let left = center_x - half_extent;
	let right = center_x + half_extent;
	let bottom = center_y - half_extent;
	let top = center_y + half_extent;
	let near = (-caster_bounds.max.z - padding).max(0.01);
	let far = (-caster_bounds.min.z + padding).max(near + 0.1);
	let light_projection = if caps.homogeneousDepth {
		Mat4::orthographic_rh_gl(left, right, bottom, top, near, far)
	} else {
		Mat4::orthographic_rh(left, right, bottom, top, near, far)
	};
	let light_view_proj = light_projection * light_view;
	let texture_bias = shadow_texture_bias(caps.originBottomLeft, caps.homogeneousDepth);
	shader::set_shadow_view(view_id, &light_view_proj);
	for item in shadow_items {
		let _ = shader::submit_shadow_mesh(
			view_id,
			item.mesh,
			item.material,
			&item.world_matrix,
			item.joint_matrices.as_deref(),
		);
	}
	Some(shader::ShadowDrawState {
		matrix: texture_bias * light_view_proj,
		texture,
		bias: light.shadow_bias,
		normal_bias: light.shadow_normal_bias,
		filter_step: shadow_filter_step(shadow_size, light.shadow_softness),
	})
}

fn shadow_filter_step(shadow_size: u16, softness: f32) -> f32 {
	if shadow_size == 0 {
		return 0.0;
	}
	softness.max(0.0) / 1.5 / shadow_size as f32
}

fn shadow_caster_overlaps_receiver(caster: &Aabb, receiver: &Aabb, padding: f32) -> bool {
	caster.is_valid()
		&& receiver.is_valid()
		&& caster.max.x >= receiver.min.x - padding
		&& caster.min.x <= receiver.max.x + padding
		&& caster.max.y >= receiver.min.y - padding
		&& caster.min.y <= receiver.max.y + padding
}

fn shadow_frustum_corners(
	view_projection: Mat4,
	homogeneous_depth: bool,
	max_distance: f32,
) -> Option<[Vec3; 8]> {
	let inverse = view_projection.inverse();
	if !inverse.is_finite() || max_distance <= 0.0 {
		return None;
	}
	let near_z = if homogeneous_depth { -1.0 } else { 0.0 };
	let mut corners = [Vec3::ZERO; 8];
	for (index, (x, y)) in [(-1.0, -1.0), (1.0, -1.0), (1.0, 1.0), (-1.0, 1.0)]
		.into_iter()
		.enumerate()
	{
		let near_clip = inverse * Vec4::new(x, y, near_z, 1.0);
		let far_clip = inverse * Vec4::new(x, y, 1.0, 1.0);
		if near_clip.w.abs() <= f32::EPSILON || far_clip.w.abs() <= f32::EPSILON {
			return None;
		}
		let near = near_clip.truncate() / near_clip.w;
		let far = far_clip.truncate() / far_clip.w;
		let ray = far - near;
		let distance = ray.length();
		if !near.is_finite() || !far.is_finite() || distance <= f32::EPSILON {
			return None;
		}
		corners[index] = near;
		corners[index + 4] = near + ray * (max_distance.min(distance) / distance);
	}
	Some(corners)
}

fn shadow_texture_bias(origin_bottom_left: bool, homogeneous_depth: bool) -> Mat4 {
	// Match bgfx's shadow-map crop matrix: X is never mirrored, while texture Y
	// depends on the backend origin reported by bgfx.
	let sy = if origin_bottom_left { 0.5 } else { -0.5 };
	let depth_scale = if homogeneous_depth { 0.5 } else { 1.0 };
	let depth_offset = if homogeneous_depth { 0.5 } else { 0.0 };
	Mat4::from_cols(
		Vec4::new(0.5, 0.0, 0.0, 0.0),
		Vec4::new(0.0, sy, 0.0, 0.0),
		Vec4::new(0.0, 0.0, depth_scale, 0.0),
		Vec4::new(0.5, 0.5, depth_offset, 1.0),
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
			show_aabb: false,
			shadow_map_size: DEFAULT_SHADOW_MAP_SIZE,
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
	let item = prepare_visual_item(
		visual_handle,
		mesh_handle,
		material_handle,
		frustum_culling,
		sort_key,
		world,
		joint_matrices,
		view_state,
	)?;
	if !should_render_bounds(view_state, item.frustum_culling, &item.world_bounds) {
		stats.culled_visuals += 1;
		return None;
	}
	stats.visible_visuals += 1;
	Some(item)
}

fn prepare_visual_item(
	visual_handle: Dora3DHandle,
	mesh_handle: Dora3DHandle,
	material_handle: Dora3DHandle,
	frustum_culling: bool,
	sort_key: u64,
	world: Mat4,
	joint_matrices: Option<Vec<Mat4>>,
	view_state: &ViewRenderState,
) -> Option<RenderVisualItem> {
	let local_bounds = if let Some(joints) = joint_matrices.as_deref() {
		super::mesh::skinned_bounds(mesh_handle, joints)?
	} else {
		super::mesh::bounds(mesh_handle)?
	};
	let bounds = transform_aabb(&world, &local_bounds);
	let origin = world.transform_point3(Vec3::ZERO);
	let distance_to_camera_sq = origin.distance_squared(view_state.view_pos);
	Some(RenderVisualItem {
		visual: visual_handle,
		mesh: mesh_handle,
		material: material_handle,
		frustum_culling,
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
	shadow: Option<&shader::ShadowDrawState>,
	mut stats: RenderStats3D,
	collect_micros: u64,
) -> bool {
	let debug_bounds = if view_state.show_aabb {
		render_items
			.iter()
			.map(|item| (item.world_bounds, item.mesh))
			.collect::<Vec<_>>()
	} else {
		Vec::new()
	};
	stats.collect_micros = collect_micros;
	let sort_start = Instant::now();
	let (opaque_items, transparent_items) = sort_render_items(render_items);
	stats.sort_micros = sort_start.elapsed().as_micros() as u64;
	stats.opaque_items = opaque_items.len() as u32;
	stats.transparent_items = transparent_items.len() as u32;
	shader::set_view_transforms(view_id, &view_state.view_proj, view_state.view_pos);
	let submit_start = Instant::now();
	let mut submitted = render_items_in_order_with_state(
		view_id,
		opaque_items.into_iter().chain(transparent_items),
		scene_lights,
		shadow,
		&mut stats,
	);
	if view_state.show_aabb && !debug_bounds.is_empty() {
		let debug_material = debug_bounds_material();
		for (bounds, mesh) in debug_bounds {
			submitted |= shader::submit_debug_bounds(view_id, &bounds, mesh, debug_material);
		}
	}
	stats.submit_micros = submit_start.elapsed().as_micros() as u64;
	render_stats().lock().unwrap().insert(view_id, stats);
	submitted
}

fn debug_bounds_material() -> Dora3DHandle {
	static MATERIAL: OnceLock<Mutex<Option<Dora3DHandle>>> = OnceLock::new();
	let mut cached = MATERIAL.get_or_init(|| Mutex::new(None)).lock().unwrap();
	if let Some(handle) = *cached {
		if material::with_material(handle, |_| ()).is_some() {
			material::set_base_color(handle, Vec4::new(1.0, 0.75, 0.05, 1.0));
			return handle;
		}
	}
	let handle = material::create();
	material::set_type(handle, material::MaterialType::Unlit);
	material::set_base_color(handle, Vec4::new(1.0, 0.75, 0.05, 1.0));
	*cached = Some(handle);
	handle
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
	shadow: Option<&shader::ShadowDrawState>,
	stats: &mut RenderStats3D,
) -> bool {
	let mut submitted = false;
	let mut previous_program = None;
	let mut previous_material = None;
	let mut previous_mesh = None;
	let mut previous_textures: Option<Vec<(u8, u16)>> = None;
	for item in items {
		let material_changed = previous_material != Some(item.material);
		if render_visual_item(view_id, &item, scene_lights, shadow, material_changed) {
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
	shadow: Option<&shader::ShadowDrawState>,
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
		shadow,
		apply_material,
	)
}

pub fn clear_queue() {
	queue().lock().unwrap().clear();
	view_states().lock().unwrap().clear();
	render_workspaces().lock().unwrap().clear();
	render_stats().lock().unwrap().clear();
	shader::clear_shadow_maps();
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
			frustum_culling: true,
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
			show_aabb: false,
			shadow_map_size: DEFAULT_SHADOW_MAP_SIZE,
		}
	}

	#[test]
	fn shadow_texture_bias_maps_ndc_without_mirroring_x() {
		let bottom_left = shadow_texture_bias(true, true);
		let min = bottom_left * Vec4::new(-1.0, -1.0, -1.0, 1.0);
		let max = bottom_left * Vec4::new(1.0, 1.0, 1.0, 1.0);
		assert!((min.x - 0.0).abs() < 1.0e-6);
		assert!((max.x - 1.0).abs() < 1.0e-6);
		assert!((min.y - 0.0).abs() < 1.0e-6);
		assert!((max.y - 1.0).abs() < 1.0e-6);
		assert!((min.z - 0.0).abs() < 1.0e-6);
		assert!((max.z - 1.0).abs() < 1.0e-6);

		let top_left = shadow_texture_bias(false, false);
		let min = top_left * Vec4::new(-1.0, -1.0, 0.0, 1.0);
		let max = top_left * Vec4::new(1.0, 1.0, 1.0, 1.0);
		assert!((min.x - 0.0).abs() < 1.0e-6);
		assert!((max.x - 1.0).abs() < 1.0e-6);
		assert!((min.y - 1.0).abs() < 1.0e-6);
		assert!((max.y - 0.0).abs() < 1.0e-6);
		assert!((min.z - 0.0).abs() < 1.0e-6);
		assert!((max.z - 1.0).abs() < 1.0e-6);
	}

	#[test]
	fn shadow_projection_keeps_points_on_a_light_ray_at_the_same_uv() {
		let direction = Vec3::new(-0.4, 0.75, 0.52).normalize();
		let view = Mat4::look_at_rh(direction * 10.0, Vec3::ZERO, Vec3::Y);
		let projection = Mat4::orthographic_rh_gl(-8.0, 8.0, -8.0, 8.0, 0.1, 24.0);
		let shadow = shadow_texture_bias(false, true) * projection * view;
		let receiver = Vec3::new(1.5, 0.0, -2.0);
		let caster = receiver + direction * 3.0;
		let receiver_coord = shadow * receiver.extend(1.0);
		let caster_coord = shadow * caster.extend(1.0);
		let receiver_uv = receiver_coord.truncate() / receiver_coord.w;
		let caster_uv = caster_coord.truncate() / caster_coord.w;
		assert!((receiver_uv.x - caster_uv.x).abs() < 1.0e-6);
		assert!((receiver_uv.y - caster_uv.y).abs() < 1.0e-6);
	}

	#[test]
	fn shadow_frustum_corners_limit_gl_depth_range() {
		let view = Mat4::look_at_rh(Vec3::new(0.0, 0.0, 5.0), Vec3::ZERO, Vec3::Y);
		let projection = Mat4::perspective_rh_gl(60.0_f32.to_radians(), 1.0, 0.1, 100.0);
		let corners = shadow_frustum_corners(projection * view, true, 25.0).unwrap();
		for index in 0..4 {
			assert!(((corners[index + 4] - corners[index]).length() - 25.0).abs() < 1.0e-3);
		}
	}

	#[test]
	fn shadow_frustum_corners_limit_zero_to_one_depth_range() {
		let view = Mat4::look_at_rh(Vec3::new(0.0, 0.0, 5.0), Vec3::ZERO, Vec3::Y);
		let projection = Mat4::perspective_rh(60.0_f32.to_radians(), 1.0, 0.1, 100.0);
		let corners = shadow_frustum_corners(projection * view, false, 25.0).unwrap();
		for index in 0..4 {
			assert!(((corners[index + 4] - corners[index]).length() - 25.0).abs() < 1.0e-3);
		}
	}

	#[test]
	fn shadow_caster_selection_uses_light_space_overlap() {
		let receiver = Aabb {
			min: Vec3::new(-2.0, -1.0, -10.0),
			max: Vec3::new(2.0, 1.0, -2.0),
		};
		let off_camera_caster = Aabb {
			min: Vec3::new(1.5, -0.5, -1.0),
			max: Vec3::new(2.5, 0.5, 0.0),
		};
		let unrelated_caster = Aabb {
			min: Vec3::new(4.0, 3.0, -1.0),
			max: Vec3::new(5.0, 4.0, 0.0),
		};

		assert!(shadow_caster_overlaps_receiver(
			&off_camera_caster,
			&receiver,
			0.1
		));
		assert!(!shadow_caster_overlaps_receiver(
			&unrelated_caster,
			&receiver,
			0.1
		));
	}

	#[test]
	fn shadow_filter_radius_is_measured_in_shadow_texels() {
		assert!((shadow_filter_step(1024, 1.5) - 1.0 / 1024.0).abs() < f32::EPSILON);
		assert!((shadow_filter_step(2048, 3.0) - 1.0 / 1024.0).abs() < f32::EPSILON);
		assert_eq!(shadow_filter_step(1024, 0.0), 0.0);
		assert_eq!(shadow_filter_step(0, 1.5), 0.0);
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
			static_mesh_count: 17,
			dynamic_mesh_count: 18,
			material_count: 19,
			texture_count: 20,
			animation_count: 21,
			environment_count: 22,
			model_resident_bytes: 23,
			mesh_resident_bytes: 24,
			texture_resident_bytes: 25,
			collect_micros: 26,
			sort_micros: 27,
			submit_micros: 28,
			upload_commands: 29,
			upload_bytes: 30,
			upload_micros: 31,
			upload_max_command_micros: 32,
		};
		assert_eq!(
			stats.to_values(),
			[
				1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
				24, 25, 26, 27, 28, 29, 30, 31, 32,
			]
		);
	}
}
