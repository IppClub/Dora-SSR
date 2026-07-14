use super::types::{transform_aabb, Aabb, Mat4, Vec3};
use super::{next_handle, Dora3DHandle};
use crate::bgfx_rs::bgfx_sys;
use std::collections::HashMap;
use std::mem::MaybeUninit;
use std::sync::{Mutex, OnceLock};

#[repr(C)]
#[derive(Debug, Clone, Copy, Default)]
pub struct Vertex {
	pub position: [f32; 3],
	pub normal: [f32; 3],
	pub tangent: [f32; 4],
	pub uv0: [f32; 2],
	pub uv1: [f32; 2],
	pub color: u32,
	pub joint_indices: [u16; 4],
	pub joint_weights: [f32; 4],
}

#[derive(Debug, Clone)]
pub struct SubMesh {
	pub start_index: u32,
	pub index_count: u32,
	pub material_slot: u32,
}

#[derive(Debug)]
pub struct JointBounds {
	pub joint_index: usize,
	pub bounds: Aabb,
}

#[derive(Debug)]
pub struct MeshData {
	pub handle: Dora3DHandle,
	pub vertex_count: u32,
	pub index_count: u32,
	pub resident_bytes: u64,
	pub joint_bounds: Vec<JointBounds>,
	pub sub_meshes: Vec<SubMesh>,
	pub bounds: Aabb,
	pub vertex_layout: bgfx_sys::bgfx_vertex_layout_t,
	vertex_buffer: VertexBuffer,
	index_buffer: IndexBuffer,
}

#[derive(Debug, Clone, Copy)]
enum VertexBuffer {
	Static(bgfx_sys::bgfx_vertex_buffer_handle_t),
	Dynamic(bgfx_sys::bgfx_dynamic_vertex_buffer_handle_t),
}

#[derive(Debug, Clone, Copy)]
enum IndexBuffer {
	Static(bgfx_sys::bgfx_index_buffer_handle_t),
	Dynamic(bgfx_sys::bgfx_dynamic_index_buffer_handle_t),
}

impl Drop for MeshData {
	fn drop(&mut self) {
		unsafe {
			match self.vertex_buffer {
				VertexBuffer::Static(handle) if handle.idx != u16::MAX => {
					bgfx_sys::bgfx_destroy_vertex_buffer(handle);
				}
				VertexBuffer::Dynamic(handle) if handle.idx != u16::MAX => {
					bgfx_sys::bgfx_destroy_dynamic_vertex_buffer(handle);
				}
				_ => {}
			}
			match self.index_buffer {
				IndexBuffer::Static(handle) if handle.idx != u16::MAX => {
					bgfx_sys::bgfx_destroy_index_buffer(handle);
				}
				IndexBuffer::Dynamic(handle) if handle.idx != u16::MAX => {
					bgfx_sys::bgfx_destroy_dynamic_index_buffer(handle);
				}
				_ => {}
			}
		}
	}
}

fn registry() -> &'static Mutex<HashMap<Dora3DHandle, MeshData>> {
	static REGISTRY: OnceLock<Mutex<HashMap<Dora3DHandle, MeshData>>> = OnceLock::new();
	REGISTRY.get_or_init(|| Mutex::new(HashMap::new()))
}

pub fn create_vertex_layout() -> bgfx_sys::bgfx_vertex_layout_t {
	let mut layout = MaybeUninit::<bgfx_sys::bgfx_vertex_layout_t>::zeroed();
	unsafe {
		let layout_ptr = layout.as_mut_ptr();
		bgfx_sys::bgfx_vertex_layout_begin(layout_ptr, bgfx_sys::bgfx_get_renderer_type());
		bgfx_sys::bgfx_vertex_layout_add(
			layout_ptr,
			bgfx_sys::BGFX_ATTRIB_POSITION as _,
			3,
			bgfx_sys::BGFX_ATTRIB_TYPE_FLOAT as _,
			false,
			false,
		);
		bgfx_sys::bgfx_vertex_layout_add(
			layout_ptr,
			bgfx_sys::BGFX_ATTRIB_NORMAL as _,
			3,
			bgfx_sys::BGFX_ATTRIB_TYPE_FLOAT as _,
			false,
			false,
		);
		bgfx_sys::bgfx_vertex_layout_add(
			layout_ptr,
			bgfx_sys::BGFX_ATTRIB_TANGENT as _,
			4,
			bgfx_sys::BGFX_ATTRIB_TYPE_FLOAT as _,
			false,
			false,
		);
		bgfx_sys::bgfx_vertex_layout_add(
			layout_ptr,
			bgfx_sys::BGFX_ATTRIB_TEXCOORD0 as _,
			2,
			bgfx_sys::BGFX_ATTRIB_TYPE_FLOAT as _,
			false,
			false,
		);
		bgfx_sys::bgfx_vertex_layout_add(
			layout_ptr,
			bgfx_sys::BGFX_ATTRIB_TEXCOORD1 as _,
			2,
			bgfx_sys::BGFX_ATTRIB_TYPE_FLOAT as _,
			false,
			false,
		);
		bgfx_sys::bgfx_vertex_layout_add(
			layout_ptr,
			bgfx_sys::BGFX_ATTRIB_COLOR0 as _,
			4,
			bgfx_sys::BGFX_ATTRIB_TYPE_UINT8 as _,
			true,
			false,
		);
		bgfx_sys::bgfx_vertex_layout_add(
			layout_ptr,
			bgfx_sys::BGFX_ATTRIB_INDICES as _,
			4,
			bgfx_sys::BGFX_ATTRIB_TYPE_INT16 as _,
			false,
			false,
		);
		bgfx_sys::bgfx_vertex_layout_add(
			layout_ptr,
			bgfx_sys::BGFX_ATTRIB_WEIGHT as _,
			4,
			bgfx_sys::BGFX_ATTRIB_TYPE_FLOAT as _,
			false,
			false,
		);
		bgfx_sys::bgfx_vertex_layout_end(layout_ptr);
		layout.assume_init()
	}
}

fn create_vertex_buffer(
	vertices: &[Vertex],
	layout: &bgfx_sys::bgfx_vertex_layout_t,
) -> bgfx_sys::bgfx_vertex_buffer_handle_t {
	unsafe {
		let memory = bgfx_sys::bgfx_copy(
			vertices.as_ptr() as *const _,
			std::mem::size_of_val(vertices) as u32,
		);
		bgfx_sys::bgfx_create_vertex_buffer(memory, layout, bgfx_sys::BGFX_BUFFER_NONE as u16)
	}
}

fn create_index_buffer(indices: &[u32]) -> bgfx_sys::bgfx_index_buffer_handle_t {
	unsafe {
		let memory = bgfx_sys::bgfx_copy(
			indices.as_ptr() as *const _,
			std::mem::size_of_val(indices) as u32,
		);
		bgfx_sys::bgfx_create_index_buffer(memory, bgfx_sys::BGFX_BUFFER_INDEX32 as u16)
	}
}

fn build_bounds(vertices: &[Vertex]) -> Aabb {
	let Some(first) = vertices.first() else {
		return Aabb::zero();
	};
	let mut min = Vec3::from_array(first.position);
	let mut max = min;
	for vertex in &vertices[1..] {
		let point = Vec3::from_array(vertex.position);
		min = min.min(point);
		max = max.max(point);
	}
	Aabb { min, max }
}

fn build_joint_bounds(vertices: &[Vertex]) -> Vec<JointBounds> {
	let mut bounds = HashMap::<usize, Aabb>::new();
	for vertex in vertices {
		let position = Vec3::from_array(vertex.position);
		for influence in 0..4 {
			if vertex.joint_weights[influence] <= f32::EPSILON {
				continue;
			}
			bounds
				.entry(vertex.joint_indices[influence] as usize)
				.or_insert_with(Aabb::empty)
				.include(position);
		}
	}
	let mut result: Vec<_> = bounds
		.into_iter()
		.map(|(joint_index, bounds)| JointBounds {
			joint_index,
			bounds,
		})
		.collect();
	result.sort_by_key(|bounds| bounds.joint_index);
	result
}

pub fn create(
	vertices: Vec<Vertex>,
	indices: Vec<u32>,
	sub_meshes: Option<Vec<SubMesh>>,
) -> Dora3DHandle {
	let handle = next_handle();
	let layout = create_vertex_layout();
	let vertex_buffer = create_vertex_buffer(&vertices, &layout);
	let index_buffer = create_index_buffer(&indices);
	let bounds = build_bounds(&vertices);
	let joint_bounds = build_joint_bounds(&vertices);
	let vertex_count = vertices.len() as u32;
	let index_count = indices.len() as u32;
	let resident_bytes = std::mem::size_of_val(vertices.as_slice()) as u64
		+ std::mem::size_of_val(indices.as_slice()) as u64;
	let mesh = MeshData {
		handle,
		vertex_count,
		index_count,
		resident_bytes,
		joint_bounds,
		sub_meshes: sub_meshes.unwrap_or_else(|| {
			vec![SubMesh {
				start_index: 0,
				index_count: indices.len() as u32,
				material_slot: 0,
			}]
		}),
		bounds,
		vertex_layout: layout,
		vertex_buffer: VertexBuffer::Static(vertex_buffer),
		index_buffer: IndexBuffer::Static(index_buffer),
	};
	registry().lock().unwrap().insert(handle, mesh);
	handle
}

pub fn create_streaming(
	vertices: &[Vertex],
	indices: &[u32],
	sub_meshes: Option<Vec<SubMesh>>,
) -> Option<Dora3DHandle> {
	if vertices.is_empty() || indices.is_empty() {
		return None;
	}
	let layout = create_vertex_layout();
	let vertex_buffer = unsafe {
		bgfx_sys::bgfx_create_dynamic_vertex_buffer(
			vertices.len() as u32,
			&layout,
			bgfx_sys::BGFX_BUFFER_NONE as u16,
		)
	};
	if vertex_buffer.idx == u16::MAX {
		return None;
	}
	let index_buffer = unsafe {
		bgfx_sys::bgfx_create_dynamic_index_buffer(
			indices.len() as u32,
			bgfx_sys::BGFX_BUFFER_INDEX32 as u16,
		)
	};
	if index_buffer.idx == u16::MAX {
		unsafe { bgfx_sys::bgfx_destroy_dynamic_vertex_buffer(vertex_buffer) };
		return None;
	}
	let handle = next_handle();
	registry().lock().unwrap().insert(
		handle,
		MeshData {
			handle,
			vertex_count: vertices.len() as u32,
			index_count: indices.len() as u32,
			resident_bytes: std::mem::size_of_val(vertices) as u64
				+ std::mem::size_of_val(indices) as u64,
			joint_bounds: build_joint_bounds(vertices),
			sub_meshes: sub_meshes.unwrap_or_else(|| {
				vec![SubMesh {
					start_index: 0,
					index_count: indices.len() as u32,
					material_slot: 0,
				}]
			}),
			bounds: build_bounds(vertices),
			vertex_layout: layout,
			vertex_buffer: VertexBuffer::Dynamic(vertex_buffer),
			index_buffer: IndexBuffer::Dynamic(index_buffer),
		},
	);
	Some(handle)
}

pub fn update_streaming_vertices(handle: Dora3DHandle, start: u32, vertices: &[Vertex]) -> bool {
	if vertices.is_empty() {
		return true;
	}
	with_mesh(handle, |mesh| {
		let VertexBuffer::Dynamic(buffer) = mesh.vertex_buffer else {
			return false;
		};
		let memory = unsafe {
			bgfx_sys::bgfx_copy(
				vertices.as_ptr() as *const _,
				std::mem::size_of_val(vertices) as u32,
			)
		};
		unsafe { bgfx_sys::bgfx_update_dynamic_vertex_buffer(buffer, start, memory) };
		true
	})
	.unwrap_or(false)
}

pub fn update_streaming_indices(handle: Dora3DHandle, start: u32, indices: &[u32]) -> bool {
	if indices.is_empty() {
		return true;
	}
	with_mesh(handle, |mesh| {
		let IndexBuffer::Dynamic(buffer) = mesh.index_buffer else {
			return false;
		};
		let memory = unsafe {
			bgfx_sys::bgfx_copy(
				indices.as_ptr() as *const _,
				std::mem::size_of_val(indices) as u32,
			)
		};
		unsafe { bgfx_sys::bgfx_update_dynamic_index_buffer(buffer, start, memory) };
		true
	})
	.unwrap_or(false)
}

pub fn create_dynamic(
	vertices: &[Vertex],
	indices: &[u32],
	sub_meshes: Option<Vec<SubMesh>>,
) -> Option<Dora3DHandle> {
	let handle = create_streaming(vertices, indices, sub_meshes)?;
	if update_dynamic_vertices(handle, vertices) && update_streaming_indices(handle, 0, indices) {
		Some(handle)
	} else {
		let _ = destroy(handle);
		None
	}
}

pub fn update_dynamic_vertices(handle: Dora3DHandle, vertices: &[Vertex]) -> bool {
	let mut meshes = registry().lock().unwrap();
	let Some(mesh) = meshes.get_mut(&handle) else {
		return false;
	};
	if vertices.len() != mesh.vertex_count as usize {
		return false;
	}
	let VertexBuffer::Dynamic(buffer) = mesh.vertex_buffer else {
		return false;
	};
	let memory = unsafe {
		bgfx_sys::bgfx_copy(
			vertices.as_ptr() as *const _,
			std::mem::size_of_val(vertices) as u32,
		)
	};
	unsafe { bgfx_sys::bgfx_update_dynamic_vertex_buffer(buffer, 0, memory) };
	mesh.bounds = build_bounds(vertices);
	mesh.joint_bounds = build_joint_bounds(vertices);
	true
}

impl MeshData {
	pub fn bind_vertex_buffer(&self) {
		unsafe {
			match self.vertex_buffer {
				VertexBuffer::Static(handle) => {
					bgfx_sys::bgfx_set_vertex_buffer(0, handle, 0, self.vertex_count)
				}
				VertexBuffer::Dynamic(handle) => {
					bgfx_sys::bgfx_set_dynamic_vertex_buffer(0, handle, 0, self.vertex_count)
				}
			}
		}
	}

	pub fn bind_index_buffer(&self, start: u32, count: u32) {
		unsafe {
			match self.index_buffer {
				IndexBuffer::Static(handle) => {
					bgfx_sys::bgfx_set_index_buffer(handle, start, count)
				}
				IndexBuffer::Dynamic(handle) => {
					bgfx_sys::bgfx_set_dynamic_index_buffer(handle, start, count)
				}
			}
		}
	}
}

pub fn destroy(handle: Dora3DHandle) -> bool {
	registry().lock().unwrap().remove(&handle).is_some()
}

pub fn with_mesh<R>(handle: Dora3DHandle, f: impl FnOnce(&MeshData) -> R) -> Option<R> {
	let meshes = registry().lock().unwrap();
	meshes.get(&handle).map(f)
}

pub fn bounds(handle: Dora3DHandle) -> Option<Aabb> {
	with_mesh(handle, |mesh| mesh.bounds)
}

pub fn skinned_bounds(handle: Dora3DHandle, joint_matrices: &[Mat4]) -> Option<Aabb> {
	with_mesh(handle, |mesh| {
		merge_skinned_bounds(mesh.bounds, &mesh.joint_bounds, joint_matrices)
	})
}

fn merge_skinned_bounds(
	base_bounds: Aabb,
	joint_bounds: &[JointBounds],
	joint_matrices: &[Mat4],
) -> Aabb {
	let mut bounds = transform_joint_bounds(joint_bounds, joint_matrices).unwrap_or(base_bounds);
	bounds.include(base_bounds.min);
	bounds.include(base_bounds.max);
	bounds
}

fn transform_joint_bounds(joint_bounds: &[JointBounds], joint_matrices: &[Mat4]) -> Option<Aabb> {
	let mut bounds = Aabb::empty();
	for joint in joint_bounds {
		let Some(matrix) = joint_matrices.get(joint.joint_index) else {
			continue;
		};
		let transformed = transform_aabb(matrix, &joint.bounds);
		bounds.include(transformed.min);
		bounds.include(transformed.max);
	}
	bounds.is_valid().then_some(bounds)
}

pub fn submission_counts(handle: Dora3DHandle) -> Option<(u32, u64)> {
	with_mesh(handle, |mesh| {
		let draw_calls = mesh.sub_meshes.len() as u32;
		let triangles = mesh
			.sub_meshes
			.iter()
			.map(|sub_mesh| (sub_mesh.index_count / 3) as u64)
			.sum();
		(draw_calls, triangles)
	})
}

pub fn count() -> usize {
	registry().lock().unwrap().len()
}

pub fn buffer_counts() -> (usize, usize) {
	registry()
		.lock()
		.unwrap()
		.values()
		.fold((0, 0), |(static_count, dynamic_count), mesh| {
			match mesh.vertex_buffer {
				VertexBuffer::Static(_) => (static_count + 1, dynamic_count),
				VertexBuffer::Dynamic(_) => (static_count, dynamic_count + 1),
			}
		})
}

pub fn resident_bytes(handle: Dora3DHandle) -> u64 {
	with_mesh(handle, |mesh| mesh.resident_bytes).unwrap_or(0)
}

pub fn total_resident_bytes() -> u64 {
	registry()
		.lock()
		.unwrap()
		.values()
		.map(|mesh| mesh.resident_bytes)
		.sum()
}

pub fn clear_registry() {
	registry().lock().unwrap().clear();
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn skinned_bounds_follow_joint_motion() {
		let joint_bounds = vec![JointBounds {
			joint_index: 0,
			bounds: Aabb {
				min: Vec3::new(-1.0, -1.0, -1.0),
				max: Vec3::new(1.0, 1.0, 1.0),
			},
		}];
		let matrices = vec![Mat4::from_translation(Vec3::new(10.0, 0.0, 0.0))];
		let bounds = transform_joint_bounds(&joint_bounds, &matrices).unwrap();
		assert_eq!(bounds.min, Vec3::new(9.0, -1.0, -1.0));
		assert_eq!(bounds.max, Vec3::new(11.0, 1.0, 1.0));
	}

	#[test]
	fn skinned_bounds_cover_base_and_extreme_pose() {
		let base_bounds = Aabb {
			min: Vec3::new(-2.0, -1.0, -0.5),
			max: Vec3::new(2.0, 1.0, 0.5),
		};
		let joint_bounds = vec![
			JointBounds {
				joint_index: 0,
				bounds: Aabb {
					min: Vec3::new(-0.5, -0.25, -0.25),
					max: Vec3::new(0.5, 0.25, 0.25),
				},
			},
			JointBounds {
				joint_index: 1,
				bounds: Aabb {
					min: Vec3::new(-0.25, -1.0, -0.25),
					max: Vec3::new(0.25, 1.0, 0.25),
				},
			},
		];
		let matrices = vec![
			Mat4::from_translation(Vec3::new(100.0, 40.0, -20.0)),
			Mat4::from_translation(Vec3::new(-80.0, -30.0, 10.0))
				* Mat4::from_rotation_z(std::f32::consts::FRAC_PI_2),
		];

		let bounds = merge_skinned_bounds(base_bounds, &joint_bounds, &matrices);
		assert_eq!(bounds.min, Vec3::new(-81.0, -30.25, -20.25));
		assert_eq!(bounds.max, Vec3::new(100.5, 40.25, 10.25));
	}
}
