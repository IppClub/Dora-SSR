use super::mesh;
use super::node3d;
use super::types::{transform_aabb, Aabb, Mat4};
use super::{next_handle, Dora3DHandle};
use std::collections::{HashMap, HashSet};
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

#[derive(Debug, Default)]
struct VisualRegistry {
	visuals: HashMap<Dora3DHandle, Visual3DData>,
	by_node: HashMap<Dora3DHandle, HashSet<Dora3DHandle>>,
}

impl VisualRegistry {
	fn insert(&mut self, visual: Visual3DData) {
		self.by_node
			.entry(visual.node)
			.or_default()
			.insert(visual.handle);
		self.visuals.insert(visual.handle, visual);
	}

	fn remove(&mut self, handle: Dora3DHandle) -> Option<Visual3DData> {
		let visual = self.visuals.remove(&handle)?;
		if let Some(handles) = self.by_node.get_mut(&visual.node) {
			handles.remove(&handle);
			if handles.is_empty() {
				self.by_node.remove(&visual.node);
			}
		}
		Some(visual)
	}

	fn reindex_node(
		&mut self,
		handle: Dora3DHandle,
		old_node: Dora3DHandle,
		new_node: Dora3DHandle,
	) {
		if let Some(handles) = self.by_node.get_mut(&old_node) {
			handles.remove(&handle);
			if handles.is_empty() {
				self.by_node.remove(&old_node);
			}
		}
		self.by_node.entry(new_node).or_default().insert(handle);
	}
}

fn registry() -> &'static Mutex<VisualRegistry> {
	static VISUAL_REGISTRY: OnceLock<Mutex<VisualRegistry>> = OnceLock::new();
	VISUAL_REGISTRY.get_or_init(|| Mutex::new(VisualRegistry::default()))
}

pub fn create(node: Dora3DHandle, mesh: Dora3DHandle, material: Dora3DHandle) -> Dora3DHandle {
	let handle = next_handle();
	registry().lock().unwrap().insert(Visual3DData {
		handle,
		node,
		mesh,
		material,
		frustum_culling: true,
		enabled: true,
	});
	handle
}

pub fn destroy(handle: Dora3DHandle) -> bool {
	let removed = registry().lock().unwrap().remove(handle).is_some();
	if removed {
		super::light3d::remove_visual_selection(handle);
	}
	removed
}

pub fn set_mesh(handle: Dora3DHandle, mesh_handle: Dora3DHandle) -> bool {
	let mut visuals = registry().lock().unwrap();
	let Some(visual) = visuals.visuals.get_mut(&handle) else {
		return false;
	};
	visual.mesh = mesh_handle;
	true
}

pub fn set_material(handle: Dora3DHandle, material_handle: Dora3DHandle) -> bool {
	let mut visuals = registry().lock().unwrap();
	let Some(visual) = visuals.visuals.get_mut(&handle) else {
		return false;
	};
	visual.material = material_handle;
	true
}

pub fn set_node(handle: Dora3DHandle, node_handle: Dora3DHandle) -> bool {
	let mut visuals = registry().lock().unwrap();
	let Some(old_node) = visuals.visuals.get(&handle).map(|visual| visual.node) else {
		return false;
	};
	if old_node != node_handle {
		visuals.reindex_node(handle, old_node, node_handle);
		if let Some(visual) = visuals.visuals.get_mut(&handle) {
			visual.node = node_handle;
		}
	}
	true
}

pub fn set_enabled(handle: Dora3DHandle, enabled: bool) -> bool {
	let mut visuals = registry().lock().unwrap();
	let Some(visual) = visuals.visuals.get_mut(&handle) else {
		return false;
	};
	visual.enabled = enabled;
	true
}

pub fn set_frustum_culling(handle: Dora3DHandle, enabled: bool) -> bool {
	let mut visuals = registry().lock().unwrap();
	let Some(visual) = visuals.visuals.get_mut(&handle) else {
		return false;
	};
	visual.frustum_culling = enabled;
	true
}

pub fn visuals_for_node(node_handle: Dora3DHandle) -> Vec<Visual3DData> {
	let registry = registry().lock().unwrap();
	let mut visuals: Vec<_> = registry
		.by_node
		.get(&node_handle)
		.into_iter()
		.flat_map(|handles| handles.iter())
		.filter_map(|handle| registry.visuals.get(handle))
		.cloned()
		.collect();
	visuals.sort_by_key(|visual| visual.handle);
	visuals
}

pub fn visuals_for_nodes(node_handles: &[Dora3DHandle]) -> Vec<Visual3DData> {
	let registry = registry().lock().unwrap();
	let mut visuals: Vec<_> = node_handles
		.iter()
		.flat_map(|node| registry.by_node.get(node).into_iter().flatten())
		.filter_map(|handle| registry.visuals.get(handle))
		.cloned()
		.collect();
	visuals.sort_by_key(|visual| visual.handle);
	visuals
}

pub fn with_visual<R>(handle: Dora3DHandle, f: impl FnOnce(&Visual3DData) -> R) -> Option<R> {
	let visuals = registry().lock().unwrap();
	visuals.visuals.get(&handle).map(f)
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

pub fn count() -> usize {
	registry().lock().unwrap().visuals.len()
}

pub fn clear_registry() {
	*registry().lock().unwrap() = VisualRegistry::default();
}
