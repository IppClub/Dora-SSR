use super::animation::{
	self, AnimationChannel, AnimationClipData, AnimationData, ChannelProperty, Interpolation,
	Keyframe, KeyframeValue, SkeletonData,
};
use super::material::{self, AlphaMode, MaterialType};
use super::mesh::{self, SubMesh, Vertex};
use super::node3d;
use super::profile3d;
use super::skinning;
use super::texture;
use super::types::{transform_aabb, Aabb, Mat4, Quaternion, Vec3, Vec4};
use super::visual3d;
use super::{next_handle, Dora3DHandle};
use crate::Texture2D;
use crate::{print_error, Content};
use gltf::buffer::Data as BufferData;
use gltf::buffer::Source as BufferSource;
use gltf::image::{Data as ImageData, Format as ImageFormat, Source as ImageSource};
use gltf::mesh::util::{ReadJoints, ReadWeights};
use gltf::{
	animation::util::ReadOutputs, animation::Interpolation as GltfInterpolation,
	animation::Property as GltfProperty,
};
use gltf::{Document, Node};
use serde_json::Value;
use std::collections::{HashMap, HashSet, VecDeque};
use std::path::{Path, PathBuf};
use std::sync::{Arc, Mutex, OnceLock};
use std::time::Instant;

#[derive(Debug, Clone)]
pub struct LoadedModel {
	pub handle: Dora3DHandle,
	pub root: Dora3DHandle,
	pub nodes: Vec<Dora3DHandle>,
	pub visuals: Vec<Dora3DHandle>,
	pub meshes: Vec<Dora3DHandle>,
	pub materials: Vec<Dora3DHandle>,
	pub textures: Vec<Dora3DHandle>,
	pub skeleton: Option<Dora3DHandle>,
	pub skeletons: Vec<Dora3DHandle>,
	pub animations: Vec<Dora3DHandle>,
	pub visual_skins: HashMap<Dora3DHandle, usize>,
	pub skin_skeletons: HashMap<usize, Dora3DHandle>,
	pub morph_meshes: HashMap<Dora3DHandle, Arc<MorphMeshData>>,
}

fn registry() -> &'static Mutex<HashMap<Dora3DHandle, LoadedModel>> {
	static REGISTRY: OnceLock<Mutex<HashMap<Dora3DHandle, LoadedModel>>> = OnceLock::new();
	REGISTRY.get_or_init(|| Mutex::new(HashMap::new()))
}

#[derive(Debug)]
struct PreparedModel {
	path: PathBuf,
	document: Document,
	images: Vec<ImageData>,
	textures: Vec<PreparedTexture>,
	nodes: Vec<PreparedNode>,
	primitives: Vec<PreparedPrimitive>,
	skeletons: Vec<PreparedSkeleton>,
	animations: Vec<PreparedAnimation>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
enum TextureCacheKey {
	Source {
		image_index: usize,
		sampler_flags: u64,
		mipmapped: bool,
	},
	ThicknessSheen {
		thickness_image: usize,
		sheen_roughness_image: usize,
		sampler_flags: u64,
	},
	MetallicRoughnessAnisotropy {
		metallic_roughness_image: Option<usize>,
		anisotropy_image: usize,
		sampler_flags: u64,
	},
}

#[derive(Debug)]
struct PreparedTexture {
	key: TextureCacheKey,
	width: u16,
	height: u16,
	pixels: Vec<u8>,
	sampler_flags: u64,
	has_mips: bool,
	label: String,
}

#[derive(Debug)]
struct TextureUploadState {
	prepared: PreparedTexture,
	handle: Dora3DHandle,
	mip: u8,
	x: u16,
	y: u16,
	offset: usize,
}

#[derive(Debug)]
struct PreparedNode {
	source_index: usize,
	parent_source_index: Option<usize>,
	name: Option<String>,
	position: Vec3,
	rotation: Quaternion,
	scale: Vec3,
}

#[derive(Debug)]
struct PreparedMesh {
	vertices: Vec<Vertex>,
	indices: Vec<u32>,
	sub_meshes: Vec<SubMesh>,
	morph_targets: Vec<MorphTargetData>,
	default_weights: Vec<f32>,
}

#[derive(Debug, Clone)]
pub struct MorphTargetData {
	position_deltas: Vec<[f32; 3]>,
	normal_deltas: Vec<[f32; 3]>,
	tangent_deltas: Vec<[f32; 3]>,
}

#[derive(Debug, Clone)]
pub struct MorphMeshData {
	base_vertices: Arc<Vec<Vertex>>,
	indices: Arc<Vec<u32>>,
	sub_meshes: Arc<Vec<SubMesh>>,
	targets: Arc<Vec<MorphTargetData>>,
	default_weights: Vec<f32>,
}

impl MorphMeshData {
	fn resident_bytes(&self) -> u64 {
		std::mem::size_of_val(self.base_vertices.as_slice()) as u64
			+ std::mem::size_of_val(self.indices.as_slice()) as u64
			+ std::mem::size_of_val(self.sub_meshes.as_slice()) as u64
			+ std::mem::size_of_val(self.default_weights.as_slice()) as u64
			+ self
				.targets
				.iter()
				.map(|target| {
					(std::mem::size_of_val(target.position_deltas.as_slice())
						+ std::mem::size_of_val(target.normal_deltas.as_slice())
						+ std::mem::size_of_val(target.tangent_deltas.as_slice())) as u64
				})
				.sum::<u64>()
	}
}

fn apply_morph_targets(
	base_vertices: &[Vertex],
	targets: &[MorphTargetData],
	weights: &[f32],
	output: &mut Vec<Vertex>,
) {
	output.clear();
	output.extend_from_slice(base_vertices);
	for (vertex_index, vertex) in output.iter_mut().enumerate() {
		let mut position = Vec3::from_array(vertex.position);
		let mut normal = Vec3::from_array(vertex.normal);
		let mut tangent = Vec3::new(vertex.tangent[0], vertex.tangent[1], vertex.tangent[2]);
		for (target_index, target) in targets.iter().enumerate() {
			let weight = weights.get(target_index).copied().unwrap_or(0.0);
			if weight.abs() <= f32::EPSILON {
				continue;
			}
			position += Vec3::from_array(target.position_deltas[vertex_index]) * weight;
			normal += Vec3::from_array(target.normal_deltas[vertex_index]) * weight;
			tangent += Vec3::from_array(target.tangent_deltas[vertex_index]) * weight;
		}
		vertex.position = position.to_array();
		vertex.normal = normal.normalize_or_zero().to_array();
		let tangent = tangent.normalize_or_zero();
		vertex.tangent[0] = tangent.x;
		vertex.tangent[1] = tangent.y;
		vertex.tangent[2] = tangent.z;
	}
}

#[derive(Debug)]
struct MeshUploadState {
	handle: Dora3DHandle,
	vertices: Vec<Vertex>,
	indices: Vec<u32>,
	vertex_cursor: usize,
	index_cursor: usize,
	morph_data: Option<Arc<MorphMeshData>>,
}

#[derive(Debug)]
struct PreparedPrimitive {
	source_node_index: usize,
	primitive_index: usize,
	skin_index: Option<usize>,
	mesh: Option<PreparedMesh>,
}

#[derive(Debug)]
struct PreparedSkeleton {
	skin_index: usize,
	joint_source_indices: Vec<usize>,
	inverse_bind_matrices: Vec<Mat4>,
}

#[derive(Debug)]
struct PreparedAnimationChannel {
	target_source_index: usize,
	property: ChannelProperty,
	interpolation: Interpolation,
	keyframes: Vec<Keyframe>,
}

#[derive(Debug)]
struct PreparedAnimation {
	name: String,
	duration: f32,
	channels: Vec<PreparedAnimationChannel>,
}

#[repr(u8)]
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum UploadPhase {
	Textures,
	Initialize,
	Nodes,
	Meshes,
	Materials,
	Visuals,
	Skeletons,
	Animations,
	Finalize,
}

#[derive(Debug)]
struct UploadJob {
	prepared: Option<PreparedModel>,
	textures: VecDeque<PreparedTexture>,
	texture_cache: HashMap<TextureCacheKey, Dora3DHandle>,
	uploaded_textures: Vec<Dora3DHandle>,
	phase: UploadPhase,
	streaming: bool,
	loaded: Option<LoadedModel>,
	node_handles: HashMap<usize, Dora3DHandle>,
	node_cursor: usize,
	primitive_cursor: usize,
	skin_cursor: usize,
	animation_cursor: usize,
	active_texture: Option<TextureUploadState>,
	active_mesh: Option<MeshUploadState>,
	pending_mesh: Option<Dora3DHandle>,
	pending_material: Option<Dora3DHandle>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum UploadStep {
	Pending,
	Complete(Dora3DHandle),
	Failed,
}

fn prepared_registry() -> &'static Mutex<HashMap<Dora3DHandle, PreparedModel>> {
	static REGISTRY: OnceLock<Mutex<HashMap<Dora3DHandle, PreparedModel>>> = OnceLock::new();
	REGISTRY.get_or_init(|| Mutex::new(HashMap::new()))
}

fn upload_job_registry() -> &'static Mutex<HashMap<Dora3DHandle, UploadJob>> {
	static REGISTRY: OnceLock<Mutex<HashMap<Dora3DHandle, UploadJob>>> = OnceLock::new();
	REGISTRY.get_or_init(|| Mutex::new(HashMap::new()))
}

#[derive(Debug, Clone)]
pub struct InstanceMaterialSlot {
	pub material: Dora3DHandle,
	pub owned: bool,
	pub visuals: Vec<Dora3DHandle>,
}

#[derive(Debug, Clone)]
pub struct ModelInstance {
	pub handle: Dora3DHandle,
	pub model: Dora3DHandle,
	pub root: Dora3DHandle,
	pub nodes: Vec<Dora3DHandle>,
	pub visuals: Vec<Dora3DHandle>,
	pub skeletons: Vec<Dora3DHandle>,
	pub animations: Vec<Dora3DHandle>,
	pub material_slots: Vec<InstanceMaterialSlot>,
	pub node_map: HashMap<Dora3DHandle, Dora3DHandle>,
	pub initial_node_transforms: Vec<(Dora3DHandle, Vec3, Quaternion, Vec3)>,
	pub playing: bool,
	pub paused: bool,
	pub looping: bool,
	pub elapsed: f32,
	pub speed: f32,
	pub current_clip: Option<Dora3DHandle>,
	pub sample_buffer: Vec<(Dora3DHandle, Option<Vec3>, Option<Quaternion>, Option<Vec3>)>,
	pub morph_sample_buffer: Vec<(Dora3DHandle, Vec<f32>)>,
	pub owned_meshes: Vec<Dora3DHandle>,
	morph_instances: Vec<MorphInstanceData>,
	morphs_by_node: HashMap<Dora3DHandle, Vec<usize>>,
}

#[derive(Debug, Clone)]
struct MorphInstanceData {
	mesh: Dora3DHandle,
	data: Arc<MorphMeshData>,
	weights: Vec<f32>,
	vertices: Vec<Vertex>,
}

fn instance_registry() -> &'static Mutex<HashMap<Dora3DHandle, ModelInstance>> {
	static REGISTRY: OnceLock<Mutex<HashMap<Dora3DHandle, ModelInstance>>> = OnceLock::new();
	REGISTRY.get_or_init(|| Mutex::new(HashMap::new()))
}

#[derive(Debug, Clone, Copy)]
struct VisualSkeletonBinding {
	skeleton: Dora3DHandle,
}

fn visual_skeletons() -> &'static Mutex<HashMap<Dora3DHandle, VisualSkeletonBinding>> {
	static REGISTRY: OnceLock<Mutex<HashMap<Dora3DHandle, VisualSkeletonBinding>>> =
		OnceLock::new();
	REGISTRY.get_or_init(|| Mutex::new(HashMap::new()))
}

fn register_visual_skeleton(visual: Dora3DHandle, skeleton: Dora3DHandle) {
	visual_skeletons()
		.lock()
		.unwrap()
		.insert(visual, VisualSkeletonBinding { skeleton });
}

fn unregister_visual_skeletons(visuals: &[Dora3DHandle]) {
	let mut bindings = visual_skeletons().lock().unwrap();
	for visual in visuals {
		bindings.remove(visual);
	}
}

fn image_to_rgba8(image: &ImageData) -> Option<(u16, u16, Vec<u8>)> {
	let width = u16::try_from(image.width).ok()?;
	let height = u16::try_from(image.height).ok()?;
	let rgba = match image.format {
		ImageFormat::R8 => image
			.pixels
			.iter()
			.flat_map(|value| [*value, *value, *value, u8::MAX])
			.collect(),
		ImageFormat::R8G8 => image
			.pixels
			.chunks_exact(2)
			.flat_map(|value| [value[0], value[1], 0, u8::MAX])
			.collect(),
		ImageFormat::R8G8B8 => image
			.pixels
			.chunks_exact(3)
			.flat_map(|value| [value[0], value[1], value[2], u8::MAX])
			.collect(),
		ImageFormat::R8G8B8A8 => image.pixels.clone(),
		_ => return None,
	};
	Some((width, height, rgba))
}

fn sampler_flags(texture_ref: &gltf::Texture<'_>) -> u64 {
	let sampler = texture_ref.sampler();
	let mut flags =
		bgfx_wrap_flags(sampler.wrap_s(), true) | bgfx_wrap_flags(sampler.wrap_t(), false);
	if matches!(
		sampler.min_filter(),
		Some(gltf::texture::MinFilter::Nearest)
			| Some(gltf::texture::MinFilter::NearestMipmapNearest)
			| Some(gltf::texture::MinFilter::NearestMipmapLinear)
	) {
		flags |= crate::bgfx_rs::bgfx_sys::BGFX_SAMPLER_MIN_POINT as u64;
	}
	if matches!(
		sampler.mag_filter(),
		Some(gltf::texture::MagFilter::Nearest)
	) {
		flags |= crate::bgfx_rs::bgfx_sys::BGFX_SAMPLER_MAG_POINT as u64;
	}
	if matches!(
		sampler.min_filter(),
		Some(gltf::texture::MinFilter::LinearMipmapNearest)
			| Some(gltf::texture::MinFilter::NearestMipmapNearest)
	) {
		flags |= crate::bgfx_rs::bgfx_sys::BGFX_SAMPLER_MIP_POINT as u64;
	}
	flags
}

fn sampler_uses_mips(texture_ref: &gltf::Texture<'_>) -> bool {
	matches!(
		texture_ref.sampler().min_filter(),
		Some(gltf::texture::MinFilter::NearestMipmapNearest)
			| Some(gltf::texture::MinFilter::LinearMipmapNearest)
			| Some(gltf::texture::MinFilter::NearestMipmapLinear)
			| Some(gltf::texture::MinFilter::LinearMipmapLinear)
	)
}

fn prepare_textures(document: &Document, images: &[ImageData]) -> Vec<PreparedTexture> {
	let mut prepared = HashMap::new();
	for texture_ref in document.textures() {
		let image_index = texture_ref.source().index();
		let sampler_flags = sampler_flags(&texture_ref);
		let has_mips = sampler_uses_mips(&texture_ref);
		let key = TextureCacheKey::Source {
			image_index,
			sampler_flags,
			mipmapped: has_mips,
		};
		if prepared.contains_key(&key) {
			continue;
		}
		let Some((width, height, rgba)) = images.get(image_index).and_then(image_to_rgba8) else {
			continue;
		};
		let pixels = if has_mips && (width > 1 || height > 1) {
			match texture::prepare_rgba8_mip_chain(width, height, &rgba) {
				Some(pixels) => pixels,
				None => continue,
			}
		} else {
			rgba
		};
		prepared.insert(
			key,
			PreparedTexture {
				key,
				width,
				height,
				pixels,
				sampler_flags,
				has_mips: has_mips && (width > 1 || height > 1),
				label: format!("gltf-image-{image_index}"),
			},
		);
	}
	prepare_packed_textures(document, images, &mut prepared);
	let mut prepared: Vec<_> = prepared.into_values().collect();
	prepared.sort_by_key(|texture| texture.key);
	prepared
}

fn bgfx_wrap_flags(mode: gltf::texture::WrappingMode, u_axis: bool) -> u64 {
	use crate::bgfx_rs::bgfx_sys::{
		BGFX_SAMPLER_U_CLAMP, BGFX_SAMPLER_U_MIRROR, BGFX_SAMPLER_V_CLAMP, BGFX_SAMPLER_V_MIRROR,
	};
	match (mode, u_axis) {
		(gltf::texture::WrappingMode::MirroredRepeat, true) => BGFX_SAMPLER_U_MIRROR as u64,
		(gltf::texture::WrappingMode::ClampToEdge, true) => BGFX_SAMPLER_U_CLAMP as u64,
		(gltf::texture::WrappingMode::MirroredRepeat, false) => BGFX_SAMPLER_V_MIRROR as u64,
		(gltf::texture::WrappingMode::ClampToEdge, false) => BGFX_SAMPLER_V_CLAMP as u64,
		_ => 0,
	}
}

fn load_texture(
	textures: &mut HashMap<TextureCacheKey, Dora3DHandle>,
	document: &Document,
	base_path: &Path,
	image_index: usize,
	image_data: &ImageData,
	sampler_flags: u64,
	mipmapped: bool,
	label: &str,
	loaded: &mut LoadedModel,
) -> Option<Dora3DHandle> {
	let cache_key = TextureCacheKey::Source {
		image_index,
		sampler_flags,
		mipmapped,
	};
	if let Some(handle) = textures.get(&cache_key) {
		return Some(*handle);
	}
	if let Some(texture_handle) = load_external_texture(document, base_path, image_index) {
		textures.insert(cache_key, texture_handle);
		loaded.textures.push(texture_handle);
		return Some(texture_handle);
	}
	let (width, height, rgba) = image_to_rgba8(image_data)?;
	let texture_handle = if mipmapped {
		texture::create_rgba8_mipmapped(width, height, &rgba, sampler_flags, Some(label))?
	} else {
		texture::create_rgba8(width, height, &rgba, sampler_flags, Some(label))?
	};
	textures.insert(cache_key, texture_handle);
	loaded.textures.push(texture_handle);
	Some(texture_handle)
}

fn load_external_texture(
	document: &Document,
	base_path: &Path,
	image_index: usize,
) -> Option<Dora3DHandle> {
	let image = document.images().nth(image_index)?;
	let ImageSource::Uri { uri, .. } = image.source() else {
		return None;
	};
	if uri.starts_with("data:") {
		return None;
	}
	let image_path = if Path::new(uri).is_absolute() {
		PathBuf::from(uri)
	} else {
		base_path.join(uri)
	};
	let image_path = image_path.to_str()?;
	let texture = Texture2D::with_file(image_path)?;
	texture::from_dora_texture(texture)
}

fn json_f32(value: &Value, key: &str, default: f32) -> f32 {
	value
		.get(key)
		.and_then(Value::as_f64)
		.map(|value| value as f32)
		.unwrap_or(default)
}

fn json_texture_index(value: &Value, key: &str) -> Option<usize> {
	value
		.get(key)?
		.get("index")?
		.as_u64()
		.and_then(|index| usize::try_from(index).ok())
}

fn json_texture_scale(value: &Value, key: &str, default: f32) -> f32 {
	value
		.get(key)
		.and_then(|texture| texture.get("scale"))
		.and_then(Value::as_f64)
		.map(|value| value as f32)
		.unwrap_or(default)
}

fn json_texture_tex_coord(value: &Value, key: &str, default: u32) -> u32 {
	let Some(texture) = value.get(key) else {
		return default;
	};
	let base_tex_coord = texture
		.get("texCoord")
		.and_then(Value::as_u64)
		.and_then(|value| u32::try_from(value).ok())
		.unwrap_or(default);
	texture
		.get("extensions")
		.and_then(|extensions| extensions.get("KHR_texture_transform"))
		.and_then(|transform| transform.get("texCoord"))
		.and_then(Value::as_u64)
		.and_then(|value| u32::try_from(value).ok())
		.unwrap_or(base_tex_coord)
}

fn json_vec2(value: &Value, key: &str, default: [f32; 2]) -> [f32; 2] {
	let Some(values) = value.get(key).and_then(Value::as_array) else {
		return default;
	};
	if values.len() < 2 {
		return default;
	}
	[
		values[0]
			.as_f64()
			.map(|value| value as f32)
			.unwrap_or(default[0]),
		values[1]
			.as_f64()
			.map(|value| value as f32)
			.unwrap_or(default[1]),
	]
}

fn json_vec3(value: &Value, key: &str, default: [f32; 3]) -> [f32; 3] {
	let Some(values) = value.get(key).and_then(Value::as_array) else {
		return default;
	};
	if values.len() < 3 {
		return default;
	}
	[
		values[0]
			.as_f64()
			.map(|value| value as f32)
			.unwrap_or(default[0]),
		values[1]
			.as_f64()
			.map(|value| value as f32)
			.unwrap_or(default[1]),
		values[2]
			.as_f64()
			.map(|value| value as f32)
			.unwrap_or(default[2]),
	]
}

fn apply_texture_transform_values(
	material_handle: Dora3DHandle,
	transform_names: (&str, &str),
	offset: [f32; 2],
	scale: [f32; 2],
	rotation: f32,
	tex_coord: u32,
) {
	let sin_rotation = rotation.sin();
	let cos_rotation = rotation.cos();
	let _ = material::set_uv_transform(
		material_handle,
		transform_names.0,
		transform_names.1,
		Vec4::new(
			cos_rotation * scale[0],
			sin_rotation * scale[0],
			-sin_rotation * scale[1],
			cos_rotation * scale[1],
		),
		Vec4::new(offset[0], offset[1], tex_coord.min(1) as f32, 0.0),
	);
}

fn apply_json_texture_transform(
	material_handle: Dora3DHandle,
	transform_names: (&str, &str),
	transform_or_texture_info: Option<&Value>,
) {
	apply_json_texture_transform_with_tex_coord(
		material_handle,
		transform_names,
		transform_or_texture_info,
		0,
	);
}

fn apply_json_texture_transform_with_tex_coord(
	material_handle: Dora3DHandle,
	transform_names: (&str, &str),
	transform_or_texture_info: Option<&Value>,
	fallback_tex_coord: u32,
) {
	let Some(value) = transform_or_texture_info else {
		apply_texture_transform_values(
			material_handle,
			transform_names,
			[0.0, 0.0],
			[1.0, 1.0],
			0.0,
			fallback_tex_coord,
		);
		return;
	};
	let base_tex_coord = value
		.get("texCoord")
		.and_then(Value::as_u64)
		.and_then(|value| u32::try_from(value).ok())
		.unwrap_or(fallback_tex_coord);
	let transform = value
		.get("extensions")
		.and_then(|extensions| extensions.get("KHR_texture_transform"))
		.unwrap_or(value);
	let offset = json_vec2(transform, "offset", [0.0, 0.0]);
	let scale = json_vec2(transform, "scale", [1.0, 1.0]);
	let rotation = json_f32(transform, "rotation", 0.0);
	let tex_coord = transform
		.get("texCoord")
		.and_then(Value::as_u64)
		.and_then(|value| u32::try_from(value).ok())
		.unwrap_or(base_tex_coord);
	if tex_coord > 1 {
		print_error(
            "Only TEXCOORD_0 and TEXCOORD_1 are supported for glTF texture UV sets; clamping to TEXCOORD_1.",
        );
	}
	apply_texture_transform_values(
		material_handle,
		transform_names,
		offset,
		scale,
		rotation,
		tex_coord,
	);
}

fn apply_texture_info_transform(
	material_handle: Dora3DHandle,
	transform_names: (&str, &str),
	info: &gltf::texture::Info<'_>,
) {
	let Some(transform) = info.texture_transform() else {
		apply_texture_transform_values(
			material_handle,
			transform_names,
			[0.0, 0.0],
			[1.0, 1.0],
			0.0,
			info.tex_coord(),
		);
		return;
	};
	let tex_coord = transform.tex_coord().unwrap_or_else(|| info.tex_coord());
	if tex_coord > 1 {
		print_error(
            "Only TEXCOORD_0 and TEXCOORD_1 are supported for glTF texture UV sets; clamping to TEXCOORD_1.",
        );
	}
	apply_texture_transform_values(
		material_handle,
		transform_names,
		transform.offset(),
		transform.scale(),
		transform.rotation(),
		tex_coord,
	);
}

fn load_texture_by_gltf_index(
	document: &Document,
	base_path: &Path,
	images: &[ImageData],
	texture_cache: &mut HashMap<TextureCacheKey, Dora3DHandle>,
	texture_index: usize,
	label: &str,
	loaded: &mut LoadedModel,
) -> Option<(Dora3DHandle, u64)> {
	let texture_ref = document.textures().nth(texture_index)?;
	let image_index = texture_ref.source().index();
	let flags = sampler_flags(&texture_ref);
	let mipmapped = sampler_uses_mips(&texture_ref);
	let texture_handle = load_texture(
		texture_cache,
		document,
		base_path,
		image_index,
		images.get(image_index)?,
		flags,
		mipmapped,
		label,
		loaded,
	)?;
	Some((texture_handle, flags))
}

fn pack_thickness_sheen_texture(
	images: &[ImageData],
	thickness_image: usize,
	sheen_roughness_image: usize,
) -> Option<(u16, u16, Vec<u8>)> {
	let (thickness_width, thickness_height, thickness_pixels) =
		image_to_rgba8(images.get(thickness_image)?)?;
	let (sheen_width, sheen_height, sheen_pixels) =
		image_to_rgba8(images.get(sheen_roughness_image)?)?;
	let width = thickness_width.max(sheen_width);
	let height = thickness_height.max(sheen_height);
	if width == 0 || height == 0 {
		return None;
	}
	let mut pixels = Vec::with_capacity(width as usize * height as usize * 4);
	for y in 0..height {
		let thickness_y = (y as u32 * thickness_height as u32 / height as u32) as usize;
		let sheen_y = (y as u32 * sheen_height as u32 / height as u32) as usize;
		for x in 0..width {
			let thickness_x = (x as u32 * thickness_width as u32 / width as u32) as usize;
			let sheen_x = (x as u32 * sheen_width as u32 / width as u32) as usize;
			let thickness_index = (thickness_y * thickness_width as usize + thickness_x) * 4;
			let sheen_index = (sheen_y * sheen_width as usize + sheen_x) * 4;
			pixels.extend_from_slice(&[
				u8::MAX,
				thickness_pixels[thickness_index + 1],
				u8::MAX,
				sheen_pixels[sheen_index + 3],
			]);
		}
	}
	Some((width, height, pixels))
}

fn pack_metallic_roughness_anisotropy_texture(
	images: &[ImageData],
	metallic_roughness_image: Option<usize>,
	anisotropy_image: usize,
) -> Option<(u16, u16, Vec<u8>)> {
	let metallic_roughness_pixels =
		metallic_roughness_image.and_then(|image| image_to_rgba8(images.get(image)?));
	let (anisotropy_width, anisotropy_height, anisotropy_pixels) =
		image_to_rgba8(images.get(anisotropy_image)?)?;
	let (width, height) = if let Some((metallic_roughness_width, metallic_roughness_height, _)) =
		metallic_roughness_pixels.as_ref()
	{
		(
			(*metallic_roughness_width).max(anisotropy_width),
			(*metallic_roughness_height).max(anisotropy_height),
		)
	} else {
		(anisotropy_width, anisotropy_height)
	};
	if width == 0 || height == 0 {
		return None;
	}

	let mut pixels = Vec::with_capacity(width as usize * height as usize * 4);
	for y in 0..height {
		let anisotropy_y = (y as u32 * anisotropy_height as u32 / height as u32) as usize;
		let metallic_roughness_y =
			metallic_roughness_pixels
				.as_ref()
				.map(|(_, metallic_roughness_height, _)| {
					(y as u32 * *metallic_roughness_height as u32 / height as u32) as usize
				});
		for x in 0..width {
			let anisotropy_x = (x as u32 * anisotropy_width as u32 / width as u32) as usize;
			let anisotropy_index = (anisotropy_y * anisotropy_width as usize + anisotropy_x) * 4;
			let anisotropy_direction_x =
				anisotropy_pixels[anisotropy_index] as f32 / 255.0 * 2.0 - 1.0;
			let anisotropy_direction_y =
				anisotropy_pixels[anisotropy_index + 1] as f32 / 255.0 * 2.0 - 1.0;
			let anisotropy_angle = if anisotropy_direction_x * anisotropy_direction_x
				+ anisotropy_direction_y * anisotropy_direction_y
				> 0.000001
			{
				anisotropy_direction_y.atan2(anisotropy_direction_x)
			} else {
				0.0
			};
			let encoded_angle =
				((anisotropy_angle + std::f32::consts::PI) / (std::f32::consts::PI * 2.0) * 255.0)
					.round()
					.clamp(0.0, 255.0) as u8;
			let (roughness, metallic) = if let (
				Some((metallic_roughness_width, _, metallic_roughness_pixels)),
				Some(metallic_roughness_y),
			) =
				(metallic_roughness_pixels.as_ref(), metallic_roughness_y)
			{
				let metallic_roughness_x =
					(x as u32 * *metallic_roughness_width as u32 / width as u32) as usize;
				let metallic_roughness_index = (metallic_roughness_y
					* *metallic_roughness_width as usize
					+ metallic_roughness_x)
					* 4;
				(
					metallic_roughness_pixels[metallic_roughness_index + 1],
					metallic_roughness_pixels[metallic_roughness_index + 2],
				)
			} else {
				(u8::MAX, u8::MAX)
			};
			pixels.extend_from_slice(&[
				encoded_angle,
				roughness,
				metallic,
				anisotropy_pixels[anisotropy_index + 2],
			]);
		}
	}
	Some((width, height, pixels))
}

fn prepare_packed_textures(
	document: &Document,
	images: &[ImageData],
	prepared: &mut HashMap<TextureCacheKey, PreparedTexture>,
) {
	for source_material in document.materials() {
		let thickness_source = source_material.volume().and_then(|volume| {
			let texture = volume.thickness_texture()?.texture();
			Some((texture.source().index(), sampler_flags(&texture)))
		});
		let sheen_source = source_material
			.extension_value("KHR_materials_sheen")
			.and_then(|sheen| json_texture_index(sheen, "sheenRoughnessTexture"))
			.and_then(|texture_index| document.textures().nth(texture_index))
			.map(|texture| (texture.source().index(), sampler_flags(&texture)));
		if let (Some((thickness_image, thickness_flags)), Some((sheen_image, sheen_flags))) =
			(thickness_source, sheen_source)
		{
			let sampler_flags = thickness_flags | sheen_flags;
			let key = TextureCacheKey::ThicknessSheen {
				thickness_image,
				sheen_roughness_image: sheen_image,
				sampler_flags,
			};
			if !prepared.contains_key(&key) {
				if let Some((width, height, pixels)) =
					pack_thickness_sheen_texture(images, thickness_image, sheen_image)
				{
					prepared.insert(
						key,
						PreparedTexture {
							key,
							width,
							height,
							pixels,
							sampler_flags,
							has_mips: false,
							label: "gltf-thickness-sheen".to_owned(),
						},
					);
				}
			}
		}

		let anisotropy_texture = source_material
			.extension_value("KHR_materials_anisotropy")
			.and_then(|anisotropy| json_texture_index(anisotropy, "anisotropyTexture"))
			.and_then(|texture_index| document.textures().nth(texture_index));
		if let Some(anisotropy_texture) = anisotropy_texture {
			let anisotropy_image = anisotropy_texture.source().index();
			let metallic_roughness = source_material
				.pbr_metallic_roughness()
				.metallic_roughness_texture();
			let metallic_roughness_image = metallic_roughness
				.as_ref()
				.map(|info| info.texture().source().index());
			let sampler_flags = metallic_roughness
				.as_ref()
				.map(|info| sampler_flags(&info.texture()))
				.unwrap_or(0)
				| sampler_flags(&anisotropy_texture);
			let key = TextureCacheKey::MetallicRoughnessAnisotropy {
				metallic_roughness_image,
				anisotropy_image,
				sampler_flags,
			};
			if !prepared.contains_key(&key) {
				if let Some((width, height, pixels)) = pack_metallic_roughness_anisotropy_texture(
					images,
					metallic_roughness_image,
					anisotropy_image,
				) {
					prepared.insert(
						key,
						PreparedTexture {
							key,
							width,
							height,
							pixels,
							sampler_flags,
							has_mips: false,
							label: "gltf-metallic-roughness-anisotropy".to_owned(),
						},
					);
				}
			}
		}
	}
}

fn create_material(
	document: &Document,
	base_path: &Path,
	primitive: &gltf::Primitive<'_>,
	images: &[ImageData],
	texture_cache: &mut HashMap<TextureCacheKey, Dora3DHandle>,
	loaded: &mut LoadedModel,
) -> Dora3DHandle {
	let material_handle = material::create();
	let source_material = primitive.material();
	let pbr = source_material.pbr_metallic_roughness();
	let base_color = Vec4::from_array(pbr.base_color_factor());
	let _ = material::ensure_default_pbr_material(material_handle);
	let material_type = if source_material.unlit() {
		MaterialType::Unlit
	} else {
		MaterialType::PbrMetallicRoughness
	};
	let _ = material::set_type(material_handle, material_type);
	let _ = material::set_base_color(material_handle, base_color);
	let emissive_strength = source_material.emissive_strength().unwrap_or(1.0);
	let _ = material::set_emissive_factor(
		material_handle,
		Vec3::from_array(source_material.emissive_factor()) * emissive_strength,
	);
	let _ = material::set_pbr(
		material_handle,
		pbr.metallic_factor(),
		pbr.roughness_factor(),
		source_material.alpha_cutoff().unwrap_or(0.5),
	);
	let alpha_cutoff = source_material.alpha_cutoff().unwrap_or(0.5);
	let alpha_mode = match source_material.alpha_mode() {
		gltf::material::AlphaMode::Opaque => AlphaMode::Opaque,
		gltf::material::AlphaMode::Mask => AlphaMode::Mask,
		gltf::material::AlphaMode::Blend => AlphaMode::Blend,
	};
	let _ = material::set_alpha_mode(material_handle, alpha_mode, alpha_cutoff);
	let _ = material::set_flags(
		material_handle,
		alpha_mode == AlphaMode::Blend,
		source_material.double_sided(),
		true,
		alpha_mode != AlphaMode::Blend,
	);
	let specular = source_material.specular();
	let specular_factor = specular
		.as_ref()
		.map(|specular| specular.specular_factor())
		.unwrap_or(1.0);
	let specular_color = specular
		.as_ref()
		.map(|specular| Vec3::from_array(specular.specular_color_factor()))
		.unwrap_or(Vec3::ONE);
	let ior = source_material.ior().unwrap_or(1.5);
	let _ = material::set_material_ext(material_handle, specular_factor, specular_color, ior);
	let mut thickness_pack_source: Option<(usize, u64)> = None;
	let mut sheen_roughness_pack_source: Option<(usize, u64)> = None;
	let mut anisotropy_texture_index: Option<usize> = None;

	if let Some(anisotropy) = source_material.extension_value("KHR_materials_anisotropy") {
		let strength = json_f32(anisotropy, "anisotropyStrength", 0.0);
		let rotation = json_f32(anisotropy, "anisotropyRotation", 0.0);
		let _ = material::set_anisotropy(material_handle, strength, rotation);
		anisotropy_texture_index = json_texture_index(anisotropy, "anisotropyTexture");
		if anisotropy_texture_index.is_some() {
			let _ = material::set_anisotropy_texture(material_handle, true);
		}
	}

	if let Some(transmission) = source_material.transmission() {
		let _ = material::set_transmission(material_handle, transmission.transmission_factor());
		if let Some(info) = transmission.transmission_texture() {
			let texture_ref = info.texture();
			let image_index = texture_ref.source().index();
			let flags = sampler_flags(&texture_ref);
			apply_texture_info_transform(
				material_handle,
				material::default_transmission_uv_transform(),
				&info,
			);
			if let Some(texture_handle) = load_texture(
				texture_cache,
				document,
				base_path,
				image_index,
				&images[image_index],
				flags,
				sampler_uses_mips(&texture_ref),
				"gltf-transmission",
				loaded,
			) {
				let _ = material::set_texture_with_flags(
					material_handle,
					material::default_transmission_slot(),
					texture_handle,
					13,
					flags as u32,
				);
			}
		}
	}

	if let Some(volume) = source_material.volume() {
		let _ = material::set_volume(
			material_handle,
			volume.thickness_factor(),
			volume.attenuation_distance(),
			Vec3::from_array(volume.attenuation_color()),
		);
		if let Some(info) = volume.thickness_texture() {
			let texture_ref = info.texture();
			let image_index = texture_ref.source().index();
			let flags = sampler_flags(&texture_ref);
			thickness_pack_source = Some((image_index, flags));
			apply_texture_info_transform(
				material_handle,
				material::default_thickness_uv_transform(),
				&info,
			);
			if let Some(texture_handle) = load_texture(
				texture_cache,
				document,
				base_path,
				image_index,
				&images[image_index],
				flags,
				sampler_uses_mips(&texture_ref),
				"gltf-thickness",
				loaded,
			) {
				let _ = material::set_texture_with_flags(
					material_handle,
					material::default_thickness_slot(),
					texture_handle,
					14,
					flags as u32,
				);
			}
		}
	}

	if let Some(sheen) = source_material.extension_value("KHR_materials_sheen") {
		let sheen_color = Vec3::from_array(json_vec3(sheen, "sheenColorFactor", [0.0, 0.0, 0.0]));
		let sheen_roughness = json_f32(sheen, "sheenRoughnessFactor", 0.0);
		let _ = material::set_sheen(material_handle, sheen_color, sheen_roughness);
		if let Some(texture_index) = json_texture_index(sheen, "sheenColorTexture") {
			apply_json_texture_transform(
				material_handle,
				material::default_sheen_color_uv_transform(),
				sheen.get("sheenColorTexture"),
			);
			if let Some((texture_handle, flags)) = load_texture_by_gltf_index(
				document,
				base_path,
				images,
				texture_cache,
				texture_index,
				"gltf-sheen-color",
				loaded,
			) {
				let _ = material::set_texture_with_flags(
					material_handle,
					material::default_sheen_color_slot(),
					texture_handle,
					15,
					flags as u32,
				);
			}
		}
		if let Some(texture_index) = json_texture_index(sheen, "sheenRoughnessTexture") {
			apply_json_texture_transform(
				material_handle,
				material::default_sheen_roughness_uv_transform(),
				sheen.get("sheenRoughnessTexture"),
			);
			if let Some(texture_ref) = document.textures().nth(texture_index) {
				sheen_roughness_pack_source =
					Some((texture_ref.source().index(), sampler_flags(&texture_ref)));
			}
			if let Some((texture_handle, flags)) = load_texture_by_gltf_index(
				document,
				base_path,
				images,
				texture_cache,
				texture_index,
				"gltf-sheen-roughness",
				loaded,
			) {
				let _ = material::set_texture_with_flags(
					material_handle,
					material::default_sheen_roughness_slot(),
					texture_handle,
					14,
					flags as u32,
				);
			}
		}
	}
	if let (Some((thickness_image, thickness_flags)), Some((sheen_image, sheen_flags))) =
		(thickness_pack_source, sheen_roughness_pack_source)
	{
		let flags = thickness_flags | sheen_flags;
		let key = TextureCacheKey::ThicknessSheen {
			thickness_image,
			sheen_roughness_image: sheen_image,
			sampler_flags: flags,
		};
		if let Some(texture_handle) = texture_cache.get(&key).copied() {
			let _ = material::set_texture_with_flags(
				material_handle,
				material::default_thickness_sheen_slot(),
				texture_handle,
				14,
				flags as u32,
			);
		}
	}

	if let Some(specular) = specular.as_ref() {
		if let Some(info) = specular.specular_texture() {
			let texture_ref = info.texture();
			let image_index = texture_ref.source().index();
			let flags = sampler_flags(&texture_ref);
			apply_texture_info_transform(
				material_handle,
				material::default_specular_uv_transform(),
				&info,
			);
			if let Some(texture_handle) = load_texture(
				texture_cache,
				document,
				base_path,
				image_index,
				&images[image_index],
				flags,
				sampler_uses_mips(&texture_ref),
				"gltf-specular",
				loaded,
			) {
				let _ = material::set_texture_with_flags(
					material_handle,
					material::default_specular_slot(),
					texture_handle,
					11,
					flags as u32,
				);
			}
		}
		if let Some(info) = specular.specular_color_texture() {
			let texture_ref = info.texture();
			let image_index = texture_ref.source().index();
			let flags = sampler_flags(&texture_ref);
			apply_texture_info_transform(
				material_handle,
				material::default_specular_color_uv_transform(),
				&info,
			);
			if let Some(texture_handle) = load_texture(
				texture_cache,
				document,
				base_path,
				image_index,
				&images[image_index],
				flags,
				sampler_uses_mips(&texture_ref),
				"gltf-specular-color",
				loaded,
			) {
				let _ = material::set_texture_with_flags(
					material_handle,
					material::default_specular_color_slot(),
					texture_handle,
					12,
					flags as u32,
				);
			}
		}
	}

	if let Some(info) = pbr.base_color_texture() {
		let image_index = info.texture().source().index();
		let flags = sampler_flags(&info.texture());
		apply_texture_info_transform(
			material_handle,
			material::default_base_color_uv_transform(),
			&info,
		);
		if let Some(texture_handle) = load_texture(
			texture_cache,
			document,
			base_path,
			image_index,
			&images[image_index],
			flags,
			sampler_uses_mips(&info.texture()),
			"gltf-base-color",
			loaded,
		) {
			let _ = material::set_texture_with_flags(
				material_handle,
				material::default_base_color_slot(),
				texture_handle,
				0,
				flags as u32,
			);
		}
	}
	let metallic_roughness_info = pbr.metallic_roughness_texture();
	if let Some(anisotropy_texture_index) = anisotropy_texture_index {
		if let Some(anisotropy_texture) = document.textures().nth(anisotropy_texture_index) {
			let anisotropy_image = anisotropy_texture.source().index();
			let metallic_roughness_image = metallic_roughness_info
				.as_ref()
				.map(|info| info.texture().source().index());
			let flags = metallic_roughness_info
				.as_ref()
				.map(|info| sampler_flags(&info.texture()))
				.unwrap_or(0)
				| sampler_flags(&anisotropy_texture);
			if let Some(info) = metallic_roughness_info.as_ref() {
				apply_texture_info_transform(
					material_handle,
					material::default_metallic_roughness_uv_transform(),
					info,
				);
			} else if let Some(anisotropy) =
				source_material.extension_value("KHR_materials_anisotropy")
			{
				apply_json_texture_transform(
					material_handle,
					material::default_metallic_roughness_uv_transform(),
					anisotropy.get("anisotropyTexture"),
				);
			}
			let key = TextureCacheKey::MetallicRoughnessAnisotropy {
				metallic_roughness_image,
				anisotropy_image,
				sampler_flags: flags,
			};
			if let Some(texture_handle) = texture_cache.get(&key).copied() {
				let _ = material::set_texture_with_flags(
					material_handle,
					material::default_metallic_roughness_slot(),
					texture_handle,
					1,
					flags as u32,
				);
			}
		}
	} else if let Some(info) = metallic_roughness_info {
		let image_index = info.texture().source().index();
		let flags = sampler_flags(&info.texture());
		apply_texture_info_transform(
			material_handle,
			material::default_metallic_roughness_uv_transform(),
			&info,
		);
		if let Some(texture_handle) = load_texture(
			texture_cache,
			document,
			base_path,
			image_index,
			&images[image_index],
			flags,
			sampler_uses_mips(&info.texture()),
			"gltf-metallic-roughness",
			loaded,
		) {
			let _ = material::set_texture_with_flags(
				material_handle,
				material::default_metallic_roughness_slot(),
				texture_handle,
				1,
				flags as u32,
			);
		}
	}
	if let Some(info) = source_material.normal_texture() {
		let image_index = info.texture().source().index();
		let flags = sampler_flags(&info.texture());
		let _ = material::set_normal_scale(material_handle, info.scale());
		apply_json_texture_transform_with_tex_coord(
			material_handle,
			material::default_normal_uv_transform(),
			info.extension_value("KHR_texture_transform"),
			info.tex_coord(),
		);
		if let Some(texture_handle) = load_texture(
			texture_cache,
			document,
			base_path,
			image_index,
			&images[image_index],
			flags,
			sampler_uses_mips(&info.texture()),
			"gltf-normal",
			loaded,
		) {
			let _ = material::set_texture_with_flags(
				material_handle,
				material::default_normal_slot(),
				texture_handle,
				2,
				flags as u32,
			);
		}
	}
	if let Some(info) = source_material.emissive_texture() {
		let image_index = info.texture().source().index();
		let flags = sampler_flags(&info.texture());
		apply_texture_info_transform(
			material_handle,
			material::default_emissive_uv_transform(),
			&info,
		);
		if let Some(texture_handle) = load_texture(
			texture_cache,
			document,
			base_path,
			image_index,
			&images[image_index],
			flags,
			sampler_uses_mips(&info.texture()),
			"gltf-emissive",
			loaded,
		) {
			let _ = material::set_texture_with_flags(
				material_handle,
				material::default_emissive_slot(),
				texture_handle,
				3,
				flags as u32,
			);
		}
	}
	if let Some(info) = source_material.occlusion_texture() {
		let image_index = info.texture().source().index();
		let flags = sampler_flags(&info.texture());
		let _ = material::set_occlusion_strength(material_handle, info.strength());
		apply_json_texture_transform_with_tex_coord(
			material_handle,
			material::default_occlusion_uv_transform(),
			info.extension_value("KHR_texture_transform"),
			info.tex_coord(),
		);
		if let Some(texture_handle) = load_texture(
			texture_cache,
			document,
			base_path,
			image_index,
			&images[image_index],
			flags,
			sampler_uses_mips(&info.texture()),
			"gltf-occlusion",
			loaded,
		) {
			let _ = material::set_texture_with_flags(
				material_handle,
				material::default_occlusion_slot(),
				texture_handle,
				4,
				flags as u32,
			);
		}
	}
	if let Some(clearcoat) = source_material.extension_value("KHR_materials_clearcoat") {
		let clearcoat_factor = json_f32(clearcoat, "clearcoatFactor", 0.0);
		let clearcoat_roughness = json_f32(clearcoat, "clearcoatRoughnessFactor", 0.0);
		let clearcoat_normal_scale = json_texture_scale(clearcoat, "clearcoatNormalTexture", 1.0);
		let _ = material::set_clearcoat(
			material_handle,
			clearcoat_factor,
			clearcoat_roughness,
			clearcoat_normal_scale,
		);
		if let Some(texture_index) = json_texture_index(clearcoat, "clearcoatTexture") {
			apply_json_texture_transform(
				material_handle,
				material::default_clearcoat_uv_transform(),
				clearcoat.get("clearcoatTexture"),
			);
			if let Some((texture_handle, flags)) = load_texture_by_gltf_index(
				document,
				base_path,
				images,
				texture_cache,
				texture_index,
				"gltf-clearcoat",
				loaded,
			) {
				let _ = material::set_texture_with_flags(
					material_handle,
					material::default_clearcoat_slot(),
					texture_handle,
					5,
					flags as u32,
				);
			}
		}
		if let Some(texture_index) = json_texture_index(clearcoat, "clearcoatRoughnessTexture") {
			apply_json_texture_transform(
				material_handle,
				material::default_clearcoat_roughness_uv_transform(),
				clearcoat.get("clearcoatRoughnessTexture"),
			);
			if let Some((texture_handle, flags)) = load_texture_by_gltf_index(
				document,
				base_path,
				images,
				texture_cache,
				texture_index,
				"gltf-clearcoat-roughness",
				loaded,
			) {
				let _ = material::set_texture_with_flags(
					material_handle,
					material::default_clearcoat_roughness_slot(),
					texture_handle,
					6,
					flags as u32,
				);
			}
		}
		if let Some(texture_index) = json_texture_index(clearcoat, "clearcoatNormalTexture") {
			apply_json_texture_transform(
				material_handle,
				material::default_clearcoat_normal_uv_transform(),
				clearcoat.get("clearcoatNormalTexture"),
			);
			if let Some((texture_handle, flags)) = load_texture_by_gltf_index(
				document,
				base_path,
				images,
				texture_cache,
				texture_index,
				"gltf-clearcoat-normal",
				loaded,
			) {
				let _ = material::set_texture_with_flags(
					material_handle,
					material::default_clearcoat_normal_slot(),
					texture_handle,
					7,
					flags as u32,
				);
			}
		}
	}
	material_handle
}

fn generate_tangents(
	positions: &[[f32; 3]],
	normals: &[[f32; 3]],
	uvs: &[[f32; 2]],
	indices: &[u32],
) -> Vec<[f32; 4]> {
	let mut tangent_accum = vec![Vec3::ZERO; positions.len()];
	let mut bitangent_accum = vec![Vec3::ZERO; positions.len()];

	for triangle in indices.chunks_exact(3) {
		let i0 = triangle[0] as usize;
		let i1 = triangle[1] as usize;
		let i2 = triangle[2] as usize;
		if i0 >= positions.len() || i1 >= positions.len() || i2 >= positions.len() {
			continue;
		}

		let p0 = Vec3::from_array(positions[i0]);
		let p1 = Vec3::from_array(positions[i1]);
		let p2 = Vec3::from_array(positions[i2]);
		let uv0 = uvs.get(i0).copied().unwrap_or([0.0, 0.0]);
		let uv1 = uvs.get(i1).copied().unwrap_or([0.0, 0.0]);
		let uv2 = uvs.get(i2).copied().unwrap_or([0.0, 0.0]);

		let edge1 = p1 - p0;
		let edge2 = p2 - p0;
		let duv1 = [uv1[0] - uv0[0], uv1[1] - uv0[1]];
		let duv2 = [uv2[0] - uv0[0], uv2[1] - uv0[1]];
		let determinant = duv1[0] * duv2[1] - duv2[0] * duv1[1];
		if determinant.abs() <= f32::EPSILON {
			continue;
		}

		let inv = 1.0 / determinant;
		let tangent = (edge1 * duv2[1] - edge2 * duv1[1]) * inv;
		let bitangent = (edge2 * duv1[0] - edge1 * duv2[0]) * inv;
		for index in [i0, i1, i2] {
			tangent_accum[index] += tangent;
			bitangent_accum[index] += bitangent;
		}
	}

	positions
		.iter()
		.enumerate()
		.map(|(index, _)| {
			let normal = Vec3::from_array(normals.get(index).copied().unwrap_or([0.0, 1.0, 0.0]))
				.normalize_or_zero();
			let tangent = tangent_accum[index];
			let tangent = (tangent - normal * normal.dot(tangent)).normalize_or_zero();
			if tangent.length_squared() <= f32::EPSILON {
				return [1.0, 0.0, 0.0, 1.0];
			}
			let bitangent = bitangent_accum[index];
			let handedness = if normal.cross(tangent).dot(bitangent) < 0.0 {
				-1.0
			} else {
				1.0
			};
			[tangent.x, tangent.y, tangent.z, handedness]
		})
		.collect()
}

fn generate_normals(positions: &[[f32; 3]], indices: &[u32]) -> Vec<[f32; 3]> {
	let mut normal_accum = vec![Vec3::ZERO; positions.len()];
	for triangle in indices.chunks_exact(3) {
		let i0 = triangle[0] as usize;
		let i1 = triangle[1] as usize;
		let i2 = triangle[2] as usize;
		if i0 >= positions.len() || i1 >= positions.len() || i2 >= positions.len() {
			continue;
		}

		let p0 = Vec3::from_array(positions[i0]);
		let p1 = Vec3::from_array(positions[i1]);
		let p2 = Vec3::from_array(positions[i2]);
		let face_normal = (p1 - p0).cross(p2 - p0);
		if face_normal.length_squared() <= f32::EPSILON {
			continue;
		}

		normal_accum[i0] += face_normal;
		normal_accum[i1] += face_normal;
		normal_accum[i2] += face_normal;
	}

	normal_accum
		.into_iter()
		.map(|normal| {
			let normal = normal.normalize_or_zero();
			if normal.length_squared() <= f32::EPSILON {
				[0.0, 1.0, 0.0]
			} else {
				normal.to_array()
			}
		})
		.collect()
}

fn primitive_needs_tangents(primitive: &gltf::Primitive<'_>) -> bool {
	let material = primitive.material();
	material.normal_texture().is_some()
		|| material
			.extension_value("KHR_materials_clearcoat")
			.and_then(|clearcoat| clearcoat.get("clearcoatNormalTexture"))
			.is_some()
		|| material
			.extension_value("KHR_materials_anisotropy")
			.is_some()
}

fn primitive_tangent_tex_coord(primitive: &gltf::Primitive<'_>) -> u32 {
	let material = primitive.material();
	if let Some(info) = material.normal_texture() {
		let tex_coord = info
			.extension_value("KHR_texture_transform")
			.and_then(|transform| transform.get("texCoord"))
			.and_then(Value::as_u64)
			.and_then(|value| u32::try_from(value).ok())
			.unwrap_or_else(|| info.tex_coord());
		return tex_coord.min(1);
	}
	material
		.extension_value("KHR_materials_clearcoat")
		.map(|clearcoat| json_texture_tex_coord(clearcoat, "clearcoatNormalTexture", 0).min(1))
		.unwrap_or(0)
}

fn prepare_primitive_mesh(
	primitive: &gltf::Primitive<'_>,
	buffers: &[BufferData],
	default_weights: &[f32],
) -> Option<PreparedMesh> {
	let reader = primitive.reader(|buffer| Some(&buffers[buffer.index()]));
	let positions: Vec<[f32; 3]> = reader.read_positions()?.collect();
	let uvs: Option<Vec<[f32; 2]>> = reader
		.read_tex_coords(0)
		.map(|coords| coords.into_f32().collect());
	let uv1s: Option<Vec<[f32; 2]>> = reader
		.read_tex_coords(1)
		.map(|coords| coords.into_f32().collect());
	let indices: Vec<u32> = reader
		.read_indices()
		.map(|indices| indices.into_u32().collect())
		.unwrap_or_else(|| (0..positions.len() as u32).collect());
	let normals: Vec<[f32; 3]> = reader
		.read_normals()
		.map(|values| values.collect())
		.unwrap_or_else(|| generate_normals(&positions, &indices));
	let tangents: Option<Vec<[f32; 4]>> = reader
		.read_tangents()
		.map(|values| values.collect())
		.or_else(|| {
			if primitive_needs_tangents(primitive) {
				let tangent_uvs = if primitive_tangent_tex_coord(primitive) > 0 {
					uv1s.as_deref().or(uvs.as_deref()).unwrap_or(&[])
				} else {
					uvs.as_deref().unwrap_or(&[])
				};
				Some(generate_tangents(
					&positions,
					&normals,
					tangent_uvs,
					&indices,
				))
			} else {
				None
			}
		});
	let colors: Option<Vec<u32>> = reader.read_colors(0).map(|colors| {
		colors
			.into_rgba_f32()
			.map(|rgba| {
				let r = (rgba[0].clamp(0.0, 1.0) * 255.0).round() as u32;
				let g = (rgba[1].clamp(0.0, 1.0) * 255.0).round() as u32;
				let b = (rgba[2].clamp(0.0, 1.0) * 255.0).round() as u32;
				let a = (rgba[3].clamp(0.0, 1.0) * 255.0).round() as u32;
				(a << 24) | (b << 16) | (g << 8) | r
			})
			.collect()
	});
	let joints: Option<Vec<[u16; 4]>> = reader.read_joints(0).map(|joints| match joints {
		ReadJoints::U8(values) => values
			.map(|joint| {
				[
					joint[0] as u16,
					joint[1] as u16,
					joint[2] as u16,
					joint[3] as u16,
				]
			})
			.collect(),
		ReadJoints::U16(values) => values.collect(),
	});
	let weights: Option<Vec<[f32; 4]>> = reader.read_weights(0).map(|weights| match weights {
		ReadWeights::U8(values) => values
			.map(|weight| {
				[
					weight[0] as f32 / 255.0,
					weight[1] as f32 / 255.0,
					weight[2] as f32 / 255.0,
					weight[3] as f32 / 255.0,
				]
			})
			.collect(),
		ReadWeights::U16(values) => values
			.map(|weight| {
				[
					weight[0] as f32 / 65535.0,
					weight[1] as f32 / 65535.0,
					weight[2] as f32 / 65535.0,
					weight[3] as f32 / 65535.0,
				]
			})
			.collect(),
		ReadWeights::F32(values) => values.collect(),
	});
	let morph_targets: Vec<_> = reader
		.read_morph_targets()
		.map(
			|(morph_positions, morph_normals, morph_tangents)| MorphTargetData {
				position_deltas: morph_positions
					.map(Iterator::collect)
					.unwrap_or_else(|| vec![[0.0; 3]; positions.len()]),
				normal_deltas: morph_normals
					.map(Iterator::collect)
					.unwrap_or_else(|| vec![[0.0; 3]; positions.len()]),
				tangent_deltas: morph_tangents
					.map(Iterator::collect)
					.unwrap_or_else(|| vec![[0.0; 3]; positions.len()]),
			},
		)
		.collect();
	if morph_targets.iter().any(|target| {
		target.position_deltas.len() != positions.len()
			|| target.normal_deltas.len() != positions.len()
			|| target.tangent_deltas.len() != positions.len()
	}) {
		return None;
	}
	let vertices = positions
		.iter()
		.enumerate()
		.map(|(index, position)| {
			let uv0 = uvs
				.as_ref()
				.and_then(|values| values.get(index))
				.copied()
				.unwrap_or([0.0, 0.0]);
			let uv1 = uv1s
				.as_ref()
				.or(uvs.as_ref())
				.and_then(|values| values.get(index))
				.copied()
				.unwrap_or([0.0, 0.0]);
			Vertex {
				position: *position,
				normal: normals.get(index).copied().unwrap_or([0.0, 1.0, 0.0]),
				tangent: tangents
					.as_ref()
					.and_then(|values| values.get(index))
					.copied()
					.unwrap_or([1.0, 0.0, 0.0, 1.0]),
				uv0,
				uv1,
				color: colors
					.as_ref()
					.and_then(|values| values.get(index))
					.copied()
					.unwrap_or(0xffff_ffff),
				joint_indices: joints
					.as_ref()
					.and_then(|values| values.get(index))
					.copied()
					.unwrap_or([0, 0, 0, 0]),
				joint_weights: weights
					.as_ref()
					.and_then(|values| values.get(index))
					.copied()
					.unwrap_or([0.0, 0.0, 0.0, 0.0]),
			}
		})
		.collect();
	let sub_meshes = vec![SubMesh {
		start_index: 0,
		index_count: indices.len() as u32,
		material_slot: primitive.material().index().unwrap_or(0) as u32,
	}];
	Some(PreparedMesh {
		vertices,
		indices,
		sub_meshes,
		default_weights: (0..morph_targets.len())
			.map(|index| default_weights.get(index).copied().unwrap_or(0.0))
			.collect(),
		morph_targets,
	})
}

fn prepare_node(
	node: Node<'_>,
	parent_source_index: Option<usize>,
	buffers: &[BufferData],
	nodes: &mut Vec<PreparedNode>,
	primitives: &mut Vec<PreparedPrimitive>,
) {
	let (translation, rotation, scale) = node.transform().decomposed();
	let source_index = node.index();
	let skin_index = node.skin().map(|skin| skin.index());
	if let Some(mesh_ref) = node.mesh() {
		let default_weights = node.weights().or_else(|| mesh_ref.weights()).unwrap_or(&[]);
		for (primitive_index, primitive) in mesh_ref.primitives().enumerate() {
			if let Some(mesh) = prepare_primitive_mesh(&primitive, buffers, default_weights) {
				primitives.push(PreparedPrimitive {
					source_node_index: source_index,
					primitive_index,
					skin_index,
					mesh: Some(mesh),
				});
			}
		}
	}
	nodes.push(PreparedNode {
		source_index,
		parent_source_index,
		name: node.name().map(str::to_owned),
		position: Vec3::from_array(translation),
		rotation: Quaternion::from_array(rotation),
		scale: Vec3::from_array(scale),
	});
	for child in node.children() {
		prepare_node(child, Some(source_index), buffers, nodes, primitives);
	}
}

fn scene_root(document: &Document) -> Option<gltf::Scene<'_>> {
	document
		.default_scene()
		.or_else(|| document.scenes().next())
}

fn prepare_scene(
	document: &Document,
	buffers: &[BufferData],
) -> (Vec<PreparedNode>, Vec<PreparedPrimitive>) {
	let mut nodes = Vec::new();
	let mut primitives = Vec::new();
	if let Some(scene) = scene_root(document) {
		for node in scene.nodes() {
			prepare_node(node, None, buffers, &mut nodes, &mut primitives);
		}
	}
	(nodes, primitives)
}

fn prepare_skeletons(document: &Document, buffers: &[BufferData]) -> Vec<PreparedSkeleton> {
	let mut skeletons = Vec::new();
	for skin in document.skins() {
		let joint_source_indices: Vec<usize> = skin.joints().map(|joint| joint.index()).collect();
		if joint_source_indices.is_empty() {
			continue;
		}
		let mut inverse_bind_matrices: Vec<Mat4> = skin
			.reader(|buffer| Some(&buffers[buffer.index()]))
			.read_inverse_bind_matrices()
			.map(|matrices| {
				matrices
					.map(|matrix| Mat4::from_cols_array_2d(&matrix))
					.collect()
			})
			.unwrap_or_else(|| vec![Mat4::IDENTITY; joint_source_indices.len()]);
		if inverse_bind_matrices.len() < joint_source_indices.len() {
			inverse_bind_matrices.resize(joint_source_indices.len(), Mat4::IDENTITY);
		} else if inverse_bind_matrices.len() > joint_source_indices.len() {
			inverse_bind_matrices.truncate(joint_source_indices.len());
		}
		skeletons.push(PreparedSkeleton {
			skin_index: skin.index(),
			joint_source_indices,
			inverse_bind_matrices,
		});
	}
	skeletons
}

fn build_vec3_keyframes(
	times: &[f32],
	values: Vec<Vec3>,
	property: ChannelProperty,
	interpolation: Interpolation,
) -> Vec<Keyframe> {
	let make_value = |value| match property {
		ChannelProperty::Translation => KeyframeValue::Translation(value),
		ChannelProperty::Scale => KeyframeValue::Scale(value),
		ChannelProperty::Rotation | ChannelProperty::MorphWeights => unreachable!(),
	};
	if interpolation == Interpolation::CubicSpline {
		return times
			.iter()
			.copied()
			.zip(values.chunks_exact(3))
			.map(|(time, values)| Keyframe {
				time,
				value: make_value(values[1]),
				in_tangent: Some(values[0].extend(0.0)),
				out_tangent: Some(values[2].extend(0.0)),
				in_weights_tangent: None,
				out_weights_tangent: None,
			})
			.collect();
	}
	times
		.iter()
		.copied()
		.zip(values)
		.map(|(time, value)| Keyframe {
			time,
			value: make_value(value),
			in_tangent: None,
			out_tangent: None,
			in_weights_tangent: None,
			out_weights_tangent: None,
		})
		.collect()
}

fn build_rotation_keyframes(
	times: &[f32],
	values: Vec<[f32; 4]>,
	interpolation: Interpolation,
) -> Vec<Keyframe> {
	if interpolation == Interpolation::CubicSpline {
		return times
			.iter()
			.copied()
			.zip(values.chunks_exact(3))
			.map(|(time, values)| Keyframe {
				time,
				value: KeyframeValue::Rotation(Quaternion::from_array(values[1]).normalize()),
				in_tangent: Some(Vec4::from_array(values[0])),
				out_tangent: Some(Vec4::from_array(values[2])),
				in_weights_tangent: None,
				out_weights_tangent: None,
			})
			.collect();
	}
	times
		.iter()
		.copied()
		.zip(values)
		.map(|(time, value)| Keyframe {
			time,
			value: KeyframeValue::Rotation(Quaternion::from_array(value).normalize()),
			in_tangent: None,
			out_tangent: None,
			in_weights_tangent: None,
			out_weights_tangent: None,
		})
		.collect()
}

fn build_weight_keyframes(
	times: &[f32],
	values: Vec<f32>,
	target_count: usize,
	interpolation: Interpolation,
) -> Vec<Keyframe> {
	if target_count == 0 {
		return Vec::new();
	}
	if interpolation == Interpolation::CubicSpline {
		if values.len() != times.len() * target_count * 3 {
			return Vec::new();
		}
		return times
			.iter()
			.copied()
			.zip(values.chunks_exact(target_count * 3))
			.map(|(time, values)| Keyframe {
				time,
				value: KeyframeValue::Weights(values[target_count..target_count * 2].to_vec()),
				in_tangent: None,
				out_tangent: None,
				in_weights_tangent: Some(values[..target_count].to_vec()),
				out_weights_tangent: Some(values[target_count * 2..].to_vec()),
			})
			.collect();
	}
	if values.len() != times.len() * target_count {
		return Vec::new();
	}
	times
		.iter()
		.copied()
		.zip(values.chunks_exact(target_count))
		.map(|(time, values)| Keyframe {
			time,
			value: KeyframeValue::Weights(values.to_vec()),
			in_tangent: None,
			out_tangent: None,
			in_weights_tangent: None,
			out_weights_tangent: None,
		})
		.collect()
}

fn prepare_animation_clips(document: &Document, buffers: &[BufferData]) -> Vec<PreparedAnimation> {
	let mut animations = Vec::new();
	for animation_ref in document.animations() {
		let mut duration = 0.0f32;
		let mut channels = Vec::new();
		for channel in animation_ref.channels() {
			let target = channel.target();
			let property = match target.property() {
				GltfProperty::Translation => ChannelProperty::Translation,
				GltfProperty::Rotation => ChannelProperty::Rotation,
				GltfProperty::Scale => ChannelProperty::Scale,
				GltfProperty::MorphTargetWeights => ChannelProperty::MorphWeights,
			};
			let morph_target_count = target
				.node()
				.mesh()
				.and_then(|mesh| mesh.primitives().next())
				.map(|primitive| primitive.morph_targets().count())
				.unwrap_or(0);
			let target_source_index = target.node().index();
			let reader = channel.reader(|buffer| Some(&buffers[buffer.index()]));
			let Some(inputs) = reader.read_inputs() else {
				continue;
			};
			let times: Vec<f32> = inputs.collect();
			if times.is_empty() {
				continue;
			}
			if let Some(last_time) = times.last().copied() {
				duration = duration.max(last_time);
			}
			let Some(outputs) = reader.read_outputs() else {
				continue;
			};
			let interpolation = match channel.sampler().interpolation() {
				GltfInterpolation::Step => Interpolation::Step,
				GltfInterpolation::Linear => Interpolation::Linear,
				GltfInterpolation::CubicSpline => Interpolation::CubicSpline,
			};
			let keyframes: Vec<Keyframe> = match (property, outputs) {
				(ChannelProperty::Translation, ReadOutputs::Translations(values)) => {
					build_vec3_keyframes(
						&times,
						values.map(Vec3::from_array).collect(),
						property,
						interpolation,
					)
				}
				(ChannelProperty::Rotation, ReadOutputs::Rotations(values)) => {
					build_rotation_keyframes(&times, values.into_f32().collect(), interpolation)
				}
				(ChannelProperty::Scale, ReadOutputs::Scales(values)) => build_vec3_keyframes(
					&times,
					values.map(Vec3::from_array).collect(),
					property,
					interpolation,
				),
				(ChannelProperty::MorphWeights, ReadOutputs::MorphTargetWeights(values)) => {
					build_weight_keyframes(
						&times,
						values.into_f32().collect(),
						morph_target_count,
						interpolation,
					)
				}
				_ => continue,
			};
			if keyframes.is_empty() {
				continue;
			}
			channels.push(PreparedAnimationChannel {
				target_source_index,
				property,
				interpolation,
				keyframes,
			});
		}
		if channels.is_empty() {
			continue;
		}
		let name = animation_ref
			.name()
			.map(str::to_owned)
			.unwrap_or_else(|| format!("animation_{}", animation_ref.index()));
		animations.push(PreparedAnimation {
			name,
			duration,
			channels,
		});
	}
	animations
}

enum ResourceUri {
	Data(Vec<u8>),
	Path(PathBuf),
}

fn resolve_resource_uri(model_path: &Path, uri: &str) -> Option<ResourceUri> {
	if let Some(data) = uri.strip_prefix("data:") {
		let (_, encoded) = data.split_once(',')?;
		return base64::decode(encoded).ok().map(ResourceUri::Data);
	}
	let decoded = if let Some(path) = uri.strip_prefix("file://") {
		urlencoding::decode(path).ok()?
	} else if let Some(path) = uri.strip_prefix("file:") {
		urlencoding::decode(path).ok()?
	} else {
		if uri.contains(':') {
			return None;
		}
		urlencoding::decode(uri).ok()?
	};
	let resource_path = if Path::new(decoded.as_ref()).is_absolute() {
		PathBuf::from(decoded.as_ref())
	} else {
		model_path
			.parent()
			.unwrap_or_else(|| Path::new(""))
			.join(decoded.as_ref())
	};
	Some(ResourceUri::Path(resource_path))
}

fn load_resource_uri<F>(model_path: &Path, uri: &str, loader: &mut F) -> Option<Vec<u8>>
where
	F: FnMut(&Path) -> Option<Vec<u8>>,
{
	match resolve_resource_uri(model_path, uri)? {
		ResourceUri::Data(bytes) => Some(bytes),
		ResourceUri::Path(path) => loader(&path),
	}
}

fn import_buffers_with<F>(
	document: &Document,
	model_path: &Path,
	mut blob: Option<Vec<u8>>,
	loader: &mut F,
) -> Option<Vec<BufferData>>
where
	F: FnMut(&Path) -> Option<Vec<u8>>,
{
	let mut buffers = Vec::with_capacity(document.buffers().len());
	for buffer in document.buffers() {
		let mut bytes = match buffer.source() {
			BufferSource::Bin => blob.take()?,
			BufferSource::Uri(uri) => load_resource_uri(model_path, uri, loader)?,
		};
		if bytes.len() < buffer.length() {
			print_error(&format!(
				"glTF buffer {} in '{}' is shorter than declared: {} < {}",
				buffer.index(),
				model_path.display(),
				bytes.len(),
				buffer.length()
			));
			return None;
		}
		while bytes.len() % 4 != 0 {
			bytes.push(0);
		}
		buffers.push(BufferData(bytes));
	}
	Some(buffers)
}

fn decode_image(bytes: &[u8]) -> Option<ImageData> {
	let image = image::load_from_memory(bytes).ok()?.into_rgba8();
	let (width, height) = image.dimensions();
	Some(ImageData {
		pixels: image.into_raw(),
		format: ImageFormat::R8G8B8A8,
		width,
		height,
	})
}

fn import_images_with<F>(
	document: &Document,
	model_path: &Path,
	buffers: &[BufferData],
	loader: &mut F,
) -> Option<Vec<ImageData>>
where
	F: FnMut(&Path) -> Option<Vec<u8>>,
{
	let mut images = Vec::with_capacity(document.images().len());
	for image in document.images() {
		let encoded = match image.source() {
			ImageSource::Uri { uri, .. } => load_resource_uri(model_path, uri, loader)?,
			ImageSource::View { view, .. } => {
				let buffer = buffers.get(view.buffer().index())?;
				let begin = view.offset();
				let end = begin.checked_add(view.length())?;
				buffer.get(begin..end)?.to_vec()
			}
		};
		images.push(decode_image(&encoded)?);
	}
	Some(images)
}

fn parse_gltf_bytes(path: &Path, bytes: &[u8]) -> Option<gltf::Gltf> {
	let gltf = match gltf::Gltf::from_slice(&bytes) {
		Ok(gltf) => gltf,
		Err(error) => {
			print_error(&format!(
				"Failed to import glTF '{}': {}. Retrying without extension validation.",
				path.display(),
				error
			));
			gltf::Gltf::from_slice_without_validation(&bytes).ok()?
		}
	};
	Some(gltf)
}

fn import_gltf_bytes<F>(
	path: &Path,
	bytes: &[u8],
	mut loader: F,
) -> Option<(Document, Vec<BufferData>, Vec<ImageData>)>
where
	F: FnMut(&Path) -> Option<Vec<u8>>,
{
	let gltf = parse_gltf_bytes(path, bytes)?;
	let gltf::Gltf { document, blob } = gltf;
	let buffers = import_buffers_with(&document, path, blob, &mut loader)?;
	let images = import_images_with(&document, path, &buffers, &mut loader)?;
	Some((document, buffers, images))
}

fn import_gltf(path: &Path) -> Option<(Document, Vec<BufferData>, Vec<ImageData>)> {
	let path_string = path.to_str()?;
	let bytes = Content::load_bytes(path_string).or_else(|| {
		print_error(&format!(
			"Failed to read glTF '{}' through Content",
			path.display()
		));
		None
	})?;
	import_gltf_bytes(path, &bytes, |resource| {
		Content::load_bytes(resource.to_str()?)
	})
}

pub fn collect_gltf_dependencies(path: &str, bytes: &[u8]) -> Option<Vec<String>> {
	let model_path = Path::new(path);
	let gltf = parse_gltf_bytes(model_path, bytes)?;
	let mut dependencies = HashSet::new();
	for buffer in gltf.document.buffers() {
		if let BufferSource::Uri(uri) = buffer.source() {
			if let ResourceUri::Path(resource_path) = resolve_resource_uri(model_path, uri)? {
				dependencies.insert(resource_path.to_str()?.to_owned());
			}
		}
	}
	for image in gltf.document.images() {
		if let ImageSource::Uri { uri, .. } = image.source() {
			if let ResourceUri::Path(resource_path) = resolve_resource_uri(model_path, uri)? {
				dependencies.insert(resource_path.to_str()?.to_owned());
			}
		}
	}
	let mut dependencies: Vec<_> = dependencies.into_iter().collect();
	dependencies.sort();
	Some(dependencies)
}

pub fn collect_gltf_buffer_dependencies(path: &str, bytes: &[u8]) -> Option<Vec<String>> {
	let model_path = Path::new(path);
	let gltf = parse_gltf_bytes(model_path, bytes)?;
	let mut dependencies = HashSet::new();
	for buffer in gltf.document.buffers() {
		if let BufferSource::Uri(uri) = buffer.source() {
			if let ResourceUri::Path(resource_path) = resolve_resource_uri(model_path, uri)? {
				dependencies.insert(resource_path.to_str()?.to_owned());
			}
		}
	}
	let mut dependencies: Vec<_> = dependencies.into_iter().collect();
	dependencies.sort();
	Some(dependencies)
}

fn collect_mesh_triangles(
	node: Node<'_>,
	parent_transform: Mat4,
	buffers: &[BufferData],
	vertices: &mut Vec<[f32; 3]>,
	indices: &mut Vec<u32>,
) -> Option<()> {
	let local_transform = Mat4::from_cols_array_2d(&node.transform().matrix());
	let world_transform = parent_transform * local_transform;
	if let Some(mesh) = node.mesh() {
		for primitive in mesh.primitives() {
			if primitive.mode() != gltf::mesh::Mode::Triangles {
				continue;
			}
			let reader = primitive.reader(|buffer| Some(&buffers[buffer.index()]));
			let primitive_vertices: Vec<_> = reader
				.read_positions()?
				.map(|position| {
					world_transform
						.transform_point3(Vec3::from_array(position))
						.to_array()
				})
				.collect();
			if primitive_vertices.len() > u32::MAX as usize {
				return None;
			}
			let base = u32::try_from(vertices.len()).ok()?;
			let mut primitive_indices: Vec<u32> = reader
				.read_indices()
				.map(|values| values.into_u32().collect())
				.unwrap_or_else(|| (0..primitive_vertices.len() as u32).collect());
			if primitive_indices.len() < 3 || !primitive_indices.len().is_multiple_of(3) {
				continue;
			}
			if primitive_indices
				.iter()
				.any(|index| *index >= primitive_vertices.len() as u32)
			{
				return None;
			}
			if world_transform.determinant() < 0.0 {
				for triangle in primitive_indices.chunks_exact_mut(3) {
					triangle.swap(1, 2);
				}
			}
			if vertices
				.len()
				.checked_add(primitive_vertices.len())
				.is_none_or(|count| count > u32::MAX as usize)
			{
				return None;
			}
			vertices.extend(primitive_vertices);
			indices.extend(primitive_indices.into_iter().map(|index| base + index));
		}
	}
	for child in node.children() {
		collect_mesh_triangles(child, world_transform, buffers, vertices, indices)?;
	}
	Some(())
}

pub fn parse_mesh_collider_data<F>(
	path: &str,
	bytes: &[u8],
	mut loader: F,
) -> Option<(Vec<[f32; 3]>, Vec<u32>)>
where
	F: FnMut(&Path) -> Option<Vec<u8>>,
{
	let model_path = Path::new(path);
	let gltf = parse_gltf_bytes(model_path, bytes)?;
	let gltf::Gltf { document, blob } = gltf;
	let buffers = import_buffers_with(&document, model_path, blob, &mut loader)?;
	let scene = scene_root(&document)?;
	let mut vertices = Vec::new();
	let mut indices = Vec::new();
	for node in scene.nodes() {
		collect_mesh_triangles(node, Mat4::IDENTITY, &buffers, &mut vertices, &mut indices)?;
	}
	(!vertices.is_empty() && !indices.is_empty()).then_some((vertices, indices))
}

pub fn parse_convex_hull_data<F>(path: &str, bytes: &[u8], loader: F) -> Option<Vec<[f32; 3]>>
where
	F: FnMut(&Path) -> Option<Vec<u8>>,
{
	let (vertices, indices) = parse_mesh_collider_data(path, bytes, loader)?;
	let mut unique = HashSet::new();
	let mut points = Vec::new();
	for index in indices {
		let point = *vertices.get(index as usize)?;
		let key = point.map(|value| if value == 0.0 { 0 } else { value.to_bits() });
		if unique.insert(key) {
			points.push(point);
		}
	}
	(points.len() >= 4).then_some(points)
}

pub fn parse_gltf_data<F>(path: &str, bytes: &[u8], loader: F) -> Option<Dora3DHandle>
where
	F: FnMut(&Path) -> Option<Vec<u8>>,
{
	let path = PathBuf::from(path);
	let (document, buffers, images) = import_gltf_bytes(&path, bytes, loader)?;
	prepare_gltf(path, document, buffers, images)
}

pub fn parse_gltf(path: &str) -> Option<Dora3DHandle> {
	let path = PathBuf::from(path);
	let (document, buffers, images) = import_gltf(&path)?;
	prepare_gltf(path, document, buffers, images)
}

fn prepare_gltf(
	path: PathBuf,
	document: Document,
	buffers: Vec<BufferData>,
	images: Vec<ImageData>,
) -> Option<Dora3DHandle> {
	let textures = prepare_textures(&document, &images);
	let (nodes, primitives) = prepare_scene(&document, &buffers);
	let skeletons = prepare_skeletons(&document, &buffers);
	let animations = prepare_animation_clips(&document, &buffers);
	let handle = next_handle();
	prepared_registry().lock().unwrap().insert(
		handle,
		PreparedModel {
			path,
			document,
			images,
			textures,
			nodes,
			primitives,
			skeletons,
			animations,
		},
	);
	Some(handle)
}

pub fn upload_gltf(prepared: Dora3DHandle) -> Option<Dora3DHandle> {
	let job = begin_upload_gltf_with_mode(prepared, false)?;
	loop {
		match step_upload_gltf(job, u64::MAX).0 {
			UploadStep::Pending => continue,
			UploadStep::Complete(model) => return Some(model),
			UploadStep::Failed => return None,
		}
	}
}

pub fn begin_upload_gltf(prepared: Dora3DHandle) -> Option<Dora3DHandle> {
	begin_upload_gltf_with_mode(prepared, true)
}

fn begin_upload_gltf_with_mode(prepared: Dora3DHandle, streaming: bool) -> Option<Dora3DHandle> {
	let mut prepared = prepared_registry().lock().unwrap().remove(&prepared)?;
	let textures = std::mem::take(&mut prepared.textures).into();
	let handle = next_handle();
	upload_job_registry().lock().unwrap().insert(
		handle,
		UploadJob {
			prepared: Some(prepared),
			textures,
			texture_cache: HashMap::new(),
			uploaded_textures: Vec::new(),
			phase: UploadPhase::Textures,
			streaming,
			loaded: None,
			node_handles: HashMap::new(),
			node_cursor: 0,
			primitive_cursor: 0,
			skin_cursor: 0,
			animation_cursor: 0,
			active_texture: None,
			active_mesh: None,
			pending_mesh: None,
			pending_material: None,
		},
	);
	Some(handle)
}

pub fn step_upload_gltf(job: Dora3DHandle, max_bytes: u64) -> (UploadStep, u64) {
	let Some(mut upload) = upload_job_registry().lock().unwrap().remove(&job) else {
		return (UploadStep::Failed, 0);
	};
	let phase = upload.phase as u8;
	let started = Instant::now();
	let (result, bytes) = step_upload_job(&mut upload, max_bytes);
	profile3d::record_upload(0, phase, started.elapsed().as_micros() as u64, bytes);
	match result {
		UploadStep::Pending => {
			upload_job_registry().lock().unwrap().insert(job, upload);
			(UploadStep::Pending, bytes)
		}
		UploadStep::Complete(model) => (UploadStep::Complete(model), bytes),
		UploadStep::Failed => {
			cleanup_upload_job(upload);
			(UploadStep::Failed, bytes)
		}
	}
}

pub fn cancel_upload_gltf(job: Dora3DHandle) -> bool {
	let Some(job) = upload_job_registry().lock().unwrap().remove(&job) else {
		return false;
	};
	cleanup_upload_job(job);
	true
}

pub fn discard_prepared_gltf(prepared: Dora3DHandle) -> bool {
	prepared_registry()
		.lock()
		.unwrap()
		.remove(&prepared)
		.is_some()
}

fn step_upload_job(job: &mut UploadJob, max_bytes: u64) -> (UploadStep, u64) {
	match job.phase {
		UploadPhase::Textures => step_upload_texture(job, max_bytes),
		UploadPhase::Initialize => (initialize_upload(job), 0),
		UploadPhase::Nodes => (step_upload_node(job), 0),
		UploadPhase::Meshes => step_upload_mesh(job, max_bytes),
		UploadPhase::Materials => (step_upload_material(job), 0),
		UploadPhase::Visuals => (step_upload_visual(job), 0),
		UploadPhase::Skeletons => (step_upload_skeleton(job), 0),
		UploadPhase::Animations => (step_upload_animation(job), 0),
		UploadPhase::Finalize => (finalize_upload(job), 0),
	}
}

fn rgba8_upload_size(width: u16, height: u16, has_mips: bool) -> Option<usize> {
	let mut width = width as usize;
	let mut height = height as usize;
	let mut bytes = 0usize;
	loop {
		bytes = bytes.checked_add(width.checked_mul(height)?.checked_mul(4)?)?;
		if !has_mips || (width == 1 && height == 1) {
			return Some(bytes);
		}
		width = (width / 2).max(1);
		height = (height / 2).max(1);
	}
}

fn step_upload_texture(job: &mut UploadJob, max_bytes: u64) -> (UploadStep, u64) {
	if job.active_texture.is_none() {
		let Some(prepared) = job.textures.pop_front() else {
			job.phase = UploadPhase::Initialize;
			return (UploadStep::Pending, 0);
		};
		if rgba8_upload_size(prepared.width, prepared.height, prepared.has_mips)
			!= Some(prepared.pixels.len())
		{
			return (UploadStep::Failed, 0);
		}
		let Some(handle) = texture::create_empty_rgba8(
			prepared.width,
			prepared.height,
			prepared.sampler_flags,
			prepared.has_mips,
			prepared.pixels.len() as u64,
			Some(&prepared.label),
		) else {
			return (UploadStep::Failed, 0);
		};
		job.active_texture = Some(TextureUploadState {
			prepared,
			handle,
			mip: 0,
			x: 0,
			y: 0,
			offset: 0,
		});
		return (UploadStep::Pending, 0);
	}
	if max_bytes < 4 {
		return (UploadStep::Pending, 0);
	}
	let state = job.active_texture.as_mut().unwrap();
	let mip_width = (state.prepared.width >> state.mip).max(1);
	let mip_height = (state.prepared.height >> state.mip).max(1);
	let max_pixels = (max_bytes / 4).min(u32::MAX as u64) as usize;
	let Some((upload_width, upload_height)) =
		texture::upload_region_size(mip_width, mip_height, state.x, state.y, max_pixels)
	else {
		return (UploadStep::Failed, 0);
	};
	let bytes = upload_width as usize * upload_height as usize * 4;
	let Some(pixels) = state
		.prepared
		.pixels
		.get(state.offset..state.offset.saturating_add(bytes))
	else {
		return (UploadStep::Failed, 0);
	};
	if !texture::update_rgba8_region(
		state.handle,
		state.mip,
		state.x,
		state.y,
		upload_width,
		upload_height,
		pixels,
	) {
		return (UploadStep::Failed, 0);
	}
	state.offset += bytes;
	if upload_height > 1 || upload_width == mip_width - state.x {
		state.x = 0;
		state.y += upload_height;
	} else {
		state.x += upload_width;
	}
	if state.y == mip_height {
		state.mip += 1;
		state.y = 0;
	}
	if state.offset == state.prepared.pixels.len() {
		let state = job.active_texture.take().unwrap();
		job.texture_cache.insert(state.prepared.key, state.handle);
		job.uploaded_textures.push(state.handle);
	}
	(UploadStep::Pending, bytes as u64)
}

fn initialize_upload(job: &mut UploadJob) -> UploadStep {
	if job.prepared.is_none() || job.loaded.is_some() {
		return UploadStep::Failed;
	}
	let root = node3d::create();
	let handle = next_handle();
	job.loaded = Some(LoadedModel {
		handle,
		root,
		nodes: vec![root],
		visuals: Vec::new(),
		meshes: Vec::new(),
		materials: Vec::new(),
		textures: std::mem::take(&mut job.uploaded_textures),
		skeleton: None,
		skeletons: Vec::new(),
		animations: Vec::new(),
		visual_skins: HashMap::new(),
		skin_skeletons: HashMap::new(),
		morph_meshes: HashMap::new(),
	});
	job.phase = UploadPhase::Nodes;
	UploadStep::Pending
}

fn step_upload_node(job: &mut UploadJob) -> UploadStep {
	let Some(prepared) = job.prepared.as_ref() else {
		return UploadStep::Failed;
	};
	let Some(node) = prepared.nodes.get(job.node_cursor) else {
		job.phase = UploadPhase::Meshes;
		return UploadStep::Pending;
	};
	let Some(loaded) = job.loaded.as_mut() else {
		return UploadStep::Failed;
	};
	let parent = match node.parent_source_index {
		Some(parent) => match job.node_handles.get(&parent).copied() {
			Some(parent) => parent,
			None => return UploadStep::Failed,
		},
		None => loaded.root,
	};
	let handle = node3d::create();
	if !node3d::add_child(parent, handle, 0, node.name.as_deref()) {
		let _ = node3d::destroy(handle);
		return UploadStep::Failed;
	}
	let _ = node3d::set_position(handle, node.position);
	let _ = node3d::set_rotation(handle, node.rotation);
	let _ = node3d::set_scale(handle, node.scale);
	job.node_handles.insert(node.source_index, handle);
	loaded.nodes.push(handle);
	job.node_cursor += 1;
	UploadStep::Pending
}

fn step_upload_mesh(job: &mut UploadJob, max_bytes: u64) -> (UploadStep, u64) {
	if job.active_mesh.is_none() {
		let Some(prepared) = job.prepared.as_mut() else {
			return (UploadStep::Failed, 0);
		};
		let Some(primitive) = prepared.primitives.get_mut(job.primitive_cursor) else {
			job.phase = UploadPhase::Skeletons;
			return (UploadStep::Pending, 0);
		};
		let Some(prepared_mesh) = primitive.mesh.take() else {
			return (UploadStep::Failed, 0);
		};
		let morph_data = (!prepared_mesh.morph_targets.is_empty()).then(|| {
			Arc::new(MorphMeshData {
				base_vertices: Arc::new(prepared_mesh.vertices.clone()),
				indices: Arc::new(prepared_mesh.indices.clone()),
				sub_meshes: Arc::new(prepared_mesh.sub_meshes.clone()),
				targets: Arc::new(prepared_mesh.morph_targets),
				default_weights: prepared_mesh.default_weights,
			})
		});
		let vertices = if let Some(data) = &morph_data {
			let mut vertices = Vec::with_capacity(data.base_vertices.len());
			apply_morph_targets(
				&data.base_vertices,
				&data.targets,
				&data.default_weights,
				&mut vertices,
			);
			vertices
		} else {
			prepared_mesh.vertices
		};
		if !job.streaming {
			let bytes = std::mem::size_of_val(vertices.as_slice()) as u64
				+ std::mem::size_of_val(prepared_mesh.indices.as_slice()) as u64;
			let handle = mesh::create(
				vertices,
				prepared_mesh.indices,
				Some(prepared_mesh.sub_meshes),
			);
			let Some(loaded) = job.loaded.as_mut() else {
				let _ = mesh::destroy(handle);
				return (UploadStep::Failed, 0);
			};
			loaded.meshes.push(handle);
			if let Some(data) = morph_data {
				loaded.morph_meshes.insert(handle, data);
			}
			job.pending_mesh = Some(handle);
			job.phase = UploadPhase::Materials;
			return (UploadStep::Pending, bytes);
		}
		let Some(handle) = mesh::create_streaming(
			&vertices,
			&prepared_mesh.indices,
			Some(prepared_mesh.sub_meshes),
		) else {
			return (UploadStep::Failed, 0);
		};
		job.active_mesh = Some(MeshUploadState {
			handle,
			vertices,
			indices: prepared_mesh.indices,
			vertex_cursor: 0,
			index_cursor: 0,
			morph_data,
		});
		return (UploadStep::Pending, 0);
	}

	let state = job.active_mesh.as_mut().unwrap();
	if state.vertex_cursor < state.vertices.len() {
		let element_size = std::mem::size_of::<Vertex>();
		let count =
			(max_bytes as usize / element_size).min(state.vertices.len() - state.vertex_cursor);
		if count == 0 {
			return (UploadStep::Pending, 0);
		}
		let end = state.vertex_cursor + count;
		if !mesh::update_streaming_vertices(
			state.handle,
			state.vertex_cursor as u32,
			&state.vertices[state.vertex_cursor..end],
		) {
			return (UploadStep::Failed, 0);
		}
		state.vertex_cursor = end;
		return (UploadStep::Pending, (count * element_size) as u64);
	}
	if state.index_cursor < state.indices.len() {
		let element_size = std::mem::size_of::<u32>();
		let count =
			(max_bytes as usize / element_size).min(state.indices.len() - state.index_cursor);
		if count == 0 {
			return (UploadStep::Pending, 0);
		}
		let end = state.index_cursor + count;
		if !mesh::update_streaming_indices(
			state.handle,
			state.index_cursor as u32,
			&state.indices[state.index_cursor..end],
		) {
			return (UploadStep::Failed, 0);
		}
		state.index_cursor = end;
		return (UploadStep::Pending, (count * element_size) as u64);
	}

	let state = job.active_mesh.take().unwrap();
	let Some(loaded) = job.loaded.as_mut() else {
		let _ = mesh::destroy(state.handle);
		return (UploadStep::Failed, 0);
	};
	loaded.meshes.push(state.handle);
	if let Some(data) = state.morph_data {
		loaded.morph_meshes.insert(state.handle, data);
	}
	job.pending_mesh = Some(state.handle);
	job.phase = UploadPhase::Materials;
	(UploadStep::Pending, 0)
}

fn step_upload_material(job: &mut UploadJob) -> UploadStep {
	let Some(prepared) = job.prepared.as_ref() else {
		return UploadStep::Failed;
	};
	let Some(prepared_primitive) = prepared.primitives.get(job.primitive_cursor) else {
		return UploadStep::Failed;
	};
	let Some(source_node) = prepared
		.document
		.nodes()
		.find(|node| node.index() == prepared_primitive.source_node_index)
	else {
		return UploadStep::Failed;
	};
	let Some(source_mesh) = source_node.mesh() else {
		return UploadStep::Failed;
	};
	let Some(source_primitive) = source_mesh
		.primitives()
		.nth(prepared_primitive.primitive_index)
	else {
		return UploadStep::Failed;
	};
	let Some(loaded) = job.loaded.as_mut() else {
		return UploadStep::Failed;
	};
	let base_path = prepared.path.parent().unwrap_or_else(|| Path::new("./"));
	let material_handle = create_material(
		&prepared.document,
		base_path,
		&source_primitive,
		&prepared.images,
		&mut job.texture_cache,
		loaded,
	);
	loaded.materials.push(material_handle);
	job.pending_material = Some(material_handle);
	job.phase = UploadPhase::Visuals;
	UploadStep::Pending
}

fn step_upload_visual(job: &mut UploadJob) -> UploadStep {
	let Some(prepared) = job.prepared.as_ref() else {
		return UploadStep::Failed;
	};
	let Some(primitive) = prepared.primitives.get(job.primitive_cursor) else {
		return UploadStep::Failed;
	};
	let Some(node) = job.node_handles.get(&primitive.source_node_index).copied() else {
		return UploadStep::Failed;
	};
	let (Some(mesh), Some(material)) = (job.pending_mesh.take(), job.pending_material.take())
	else {
		return UploadStep::Failed;
	};
	let visual = visual3d::create(node, mesh, material);
	let Some(loaded) = job.loaded.as_mut() else {
		let _ = visual3d::destroy(visual);
		return UploadStep::Failed;
	};
	loaded.visuals.push(visual);
	if let Some(skin_index) = primitive.skin_index {
		loaded.visual_skins.insert(visual, skin_index);
	}
	job.primitive_cursor += 1;
	job.phase = UploadPhase::Meshes;
	UploadStep::Pending
}

fn step_upload_skeleton(job: &mut UploadJob) -> UploadStep {
	let Some(prepared) = job.prepared.as_mut() else {
		return UploadStep::Failed;
	};
	let Some(skeleton) = prepared.skeletons.get_mut(job.skin_cursor) else {
		job.phase = UploadPhase::Animations;
		return UploadStep::Pending;
	};
	let joints: Vec<_> = skeleton
		.joint_source_indices
		.iter()
		.filter_map(|joint| job.node_handles.get(joint).copied())
		.collect();
	if !joints.is_empty() {
		let skeleton_handle = animation::create(AnimationData::Skeleton(SkeletonData {
			handle: 0,
			joints,
			inverse_bind_matrices: std::mem::take(&mut skeleton.inverse_bind_matrices),
		}));
		let Some(loaded) = job.loaded.as_mut() else {
			let _ = animation::destroy(skeleton_handle);
			return UploadStep::Failed;
		};
		if loaded.skeleton.is_none() {
			loaded.skeleton = Some(skeleton_handle);
		}
		loaded
			.skin_skeletons
			.insert(skeleton.skin_index, skeleton_handle);
		loaded.skeletons.push(skeleton_handle);
	}
	job.skin_cursor += 1;
	UploadStep::Pending
}

fn step_upload_animation(job: &mut UploadJob) -> UploadStep {
	let Some(prepared) = job.prepared.as_mut() else {
		return UploadStep::Failed;
	};
	let Some(animation) = prepared.animations.get_mut(job.animation_cursor) else {
		job.phase = UploadPhase::Finalize;
		return UploadStep::Pending;
	};
	let channels: Vec<_> = std::mem::take(&mut animation.channels)
		.into_iter()
		.filter_map(|channel| {
			let target_node = job
				.node_handles
				.get(&channel.target_source_index)
				.copied()?;
			Some(AnimationChannel {
				target_node,
				property: channel.property,
				interpolation: channel.interpolation,
				keyframes: channel.keyframes,
			})
		})
		.collect();
	if !channels.is_empty() {
		let clip = animation::create(AnimationData::Clip(AnimationClipData {
			handle: 0,
			name: std::mem::take(&mut animation.name),
			duration: animation.duration,
			channels,
		}));
		let Some(loaded) = job.loaded.as_mut() else {
			let _ = animation::destroy(clip);
			return UploadStep::Failed;
		};
		loaded.animations.push(clip);
	}
	job.animation_cursor += 1;
	UploadStep::Pending
}

fn finalize_upload(job: &mut UploadJob) -> UploadStep {
	let Some(loaded) = job.loaded.take() else {
		return UploadStep::Failed;
	};
	for (visual, skin_index) in &loaded.visual_skins {
		if let Some(skeleton) = loaded.skin_skeletons.get(skin_index) {
			register_visual_skeleton(*visual, *skeleton);
		}
	}
	let handle = loaded.handle;
	registry().lock().unwrap().insert(handle, loaded);
	UploadStep::Complete(handle)
}

fn cleanup_upload_job(mut job: UploadJob) {
	if let Some(texture) = job.active_texture.take() {
		let _ = texture::destroy(texture.handle);
	}
	if let Some(mesh) = job.active_mesh.take() {
		let _ = mesh::destroy(mesh.handle);
	}
	if let Some(loaded) = job.loaded.take() {
		destroy_loaded_model(loaded);
	} else {
		for texture in job.uploaded_textures {
			let _ = texture::destroy(texture);
		}
	}
}

pub fn load_gltf(path: &str) -> Option<Dora3DHandle> {
	let prepared = parse_gltf(path)?;
	upload_gltf(prepared)
}

fn destroy_loaded_model(model: LoadedModel) {
	unregister_visual_skeletons(&model.visuals);
	for visual in model.visuals {
		let _ = visual3d::destroy(visual);
	}
	for material_handle in model.materials {
		let _ = material::destroy(material_handle);
	}
	for mesh_handle in model.meshes {
		let _ = mesh::destroy(mesh_handle);
	}
	for texture_handle in model.textures {
		let _ = texture::destroy(texture_handle);
	}
	for animation_handle in model.animations {
		let _ = animation::destroy(animation_handle);
	}
	for skeleton_handle in model.skeletons {
		let _ = animation::destroy(skeleton_handle);
	}
	for node_handle in model.nodes {
		let _ = node3d::destroy(node_handle);
	}
}

pub fn destroy(handle: Dora3DHandle) -> bool {
	let Some(model) = registry().lock().unwrap().remove(&handle) else {
		return false;
	};
	destroy_loaded_model(model);
	true
}

pub fn instantiate(handle: Dora3DHandle, parent: Dora3DHandle) -> Option<Dora3DHandle> {
	let model = with_model(handle, Clone::clone)?;
	let (root, node_map, nodes) = node3d::clone_subtree(model.root)?;
	if !node3d::add_child(parent, root, 0, None) {
		for node in nodes {
			let _ = node3d::destroy(node);
		}
		return None;
	}
	let mut visuals = Vec::new();
	let mut cloned_visual_sources = Vec::new();
	let mut owned_meshes = Vec::new();
	let mut morph_instances = Vec::new();
	let mut morphs_by_node = HashMap::<Dora3DHandle, Vec<usize>>::new();
	let mut material_slots: Vec<_> = model
		.materials
		.iter()
		.map(|material| InstanceMaterialSlot {
			material: *material,
			owned: false,
			visuals: Vec::new(),
		})
		.collect();
	let material_indices: HashMap<_, _> = model
		.materials
		.iter()
		.enumerate()
		.map(|(index, material)| (*material, index))
		.collect();
	for visual_handle in model.visuals {
		if let Some((node, mesh, material, enabled)) =
			visual3d::with_visual(visual_handle, |visual| {
				(visual.node, visual.mesh, visual.material, visual.enabled)
			}) {
			if let Some(cloned_node) = node_map.get(&node).copied() {
				let cloned_mesh = if let Some(data) = model.morph_meshes.get(&mesh).cloned() {
					let mut vertices = Vec::with_capacity(data.base_vertices.len());
					apply_morph_targets(
						&data.base_vertices,
						&data.targets,
						&data.default_weights,
						&mut vertices,
					);
					let Some(dynamic_mesh) = mesh::create_dynamic(
						&vertices,
						&data.indices,
						Some(data.sub_meshes.as_ref().clone()),
					) else {
						for visual in visuals {
							let _ = visual3d::destroy(visual);
						}
						for mesh in owned_meshes {
							let _ = mesh::destroy(mesh);
						}
						for node in nodes {
							let _ = node3d::destroy(node);
						}
						return None;
					};
					let morph_index = morph_instances.len();
					morph_instances.push(MorphInstanceData {
						mesh: dynamic_mesh,
						weights: data.default_weights.clone(),
						data,
						vertices,
					});
					morphs_by_node
						.entry(cloned_node)
						.or_default()
						.push(morph_index);
					owned_meshes.push(dynamic_mesh);
					dynamic_mesh
				} else {
					mesh
				};
				let cloned_visual = visual3d::create(cloned_node, cloned_mesh, material);
				visual3d::set_enabled(cloned_visual, enabled);
				visuals.push(cloned_visual);
				cloned_visual_sources.push((cloned_visual, visual_handle));
				if let Some(index) = material_indices.get(&material) {
					material_slots[*index].visuals.push(cloned_visual);
				}
			}
		}
	}
	let mut skeletons = Vec::new();
	let mut cloned_skeletons = HashMap::new();
	for source_skeleton in model.skeletons {
		let cloned = animation::with_skeleton(source_skeleton, Clone::clone).and_then(|source| {
			let joints: Option<Vec<Dora3DHandle>> = source
				.joints
				.iter()
				.map(|joint| node_map.get(joint).copied())
				.collect();
			let joints = joints?;
			Some(animation::create(AnimationData::Skeleton(SkeletonData {
				handle: 0,
				joints,
				inverse_bind_matrices: source.inverse_bind_matrices.clone(),
			})))
		});
		if let Some(cloned) = cloned {
			cloned_skeletons.insert(source_skeleton, cloned);
			skeletons.push(cloned);
		}
	}
	for (cloned_visual, source_visual) in cloned_visual_sources {
		if let Some(source_skeleton) = skeleton_for_visual(source_visual) {
			if let Some(cloned_skeleton) = cloned_skeletons.get(&source_skeleton) {
				register_visual_skeleton(cloned_visual, *cloned_skeleton);
			}
		}
	}
	let instance = next_handle();
	let initial_node_transforms = nodes
		.iter()
		.filter_map(|node| {
			Some((
				*node,
				node3d::get_position(*node)?,
				node3d::get_rotation(*node)?,
				node3d::get_scale(*node)?,
			))
		})
		.collect();
	instance_registry().lock().unwrap().insert(
		instance,
		ModelInstance {
			handle: instance,
			model: handle,
			root,
			nodes,
			visuals,
			skeletons,
			animations: model.animations.clone(),
			material_slots,
			node_map,
			initial_node_transforms,
			playing: false,
			paused: false,
			looping: false,
			elapsed: 0.0,
			speed: 1.0,
			current_clip: None,
			sample_buffer: Vec::new(),
			morph_sample_buffer: Vec::new(),
			owned_meshes,
			morph_instances,
			morphs_by_node,
		},
	);
	Some(instance)
}

pub fn destroy_instance(handle: Dora3DHandle) -> bool {
	let Some(instance) = instance_registry().lock().unwrap().remove(&handle) else {
		return false;
	};
	unregister_visual_skeletons(&instance.visuals);
	for visual in instance.visuals {
		let _ = visual3d::destroy(visual);
	}
	for slot in instance.material_slots {
		if slot.owned {
			let _ = material::destroy(slot.material);
		}
	}
	for mesh in instance.owned_meshes {
		let _ = mesh::destroy(mesh);
	}
	for skeleton in instance.skeletons {
		let _ = animation::destroy(skeleton);
	}
	for node in instance.nodes {
		let _ = node3d::destroy(node);
	}
	true
}

pub fn play_instance(handle: Dora3DHandle, name: Option<&str>, looping: bool) -> Option<f32> {
	let (duration, initial_node_transforms) = {
		let mut instances = instance_registry().lock().unwrap();
		let instance = instances.get_mut(&handle)?;
		let clip = instance.animations.iter().copied().find(|clip_handle| {
			animation::with_clip(*clip_handle, |clip| {
				name.map(|name| name.is_empty() || clip.name == name)
					.unwrap_or(true)
			})
			.unwrap_or(false)
		})?;
		let duration = animation::with_clip(clip, |clip| clip.duration).unwrap_or(0.0);
		instance.current_clip = Some(clip);
		instance.elapsed = 0.0;
		instance.looping = looping;
		instance.playing = true;
		instance.paused = false;
		(duration, instance.initial_node_transforms.clone())
	};
	for (node, position, rotation, scale) in initial_node_transforms {
		let _ = node3d::set_position(node, position);
		let _ = node3d::set_rotation(node, rotation);
		let _ = node3d::set_scale(node, scale);
	}
	Some(duration)
}

pub fn stop_instance(handle: Dora3DHandle) -> bool {
	let mut instances = instance_registry().lock().unwrap();
	let Some(instance) = instances.get_mut(&handle) else {
		return false;
	};
	instance.playing = false;
	instance.paused = false;
	instance.current_clip = None;
	instance.elapsed = 0.0;
	true
}

pub fn pause_instance(handle: Dora3DHandle) -> bool {
	let mut instances = instance_registry().lock().unwrap();
	let Some(instance) = instances.get_mut(&handle) else {
		return false;
	};
	if instance.playing {
		instance.paused = true;
	}
	true
}

pub fn resume_instance(handle: Dora3DHandle) -> bool {
	let mut instances = instance_registry().lock().unwrap();
	let Some(instance) = instances.get_mut(&handle) else {
		return false;
	};
	instance.paused = false;
	true
}

pub fn is_paused_instance(handle: Dora3DHandle) -> bool {
	let instances = instance_registry().lock().unwrap();
	instances
		.get(&handle)
		.map(|instance| instance.paused)
		.unwrap_or(false)
}

pub fn set_speed_instance(handle: Dora3DHandle, speed: f32) -> bool {
	let mut instances = instance_registry().lock().unwrap();
	let Some(instance) = instances.get_mut(&handle) else {
		return false;
	};
	instance.speed = speed.max(0.0);
	true
}

pub fn get_speed_instance(handle: Dora3DHandle) -> f32 {
	let instances = instance_registry().lock().unwrap();
	instances
		.get(&handle)
		.map(|instance| instance.speed)
		.unwrap_or(1.0)
}

pub fn get_elapsed_instance(handle: Dora3DHandle) -> f32 {
	let instances = instance_registry().lock().unwrap();
	instances
		.get(&handle)
		.map(|instance| instance.elapsed)
		.unwrap_or(0.0)
}

pub fn get_duration_instance(handle: Dora3DHandle) -> f32 {
	let instances = instance_registry().lock().unwrap();
	let Some(instance) = instances.get(&handle) else {
		return 0.0;
	};
	let Some(clip_handle) = instance.current_clip else {
		return 0.0;
	};
	animation::with_clip(clip_handle, |clip| clip.duration).unwrap_or(0.0)
}

pub fn update_instance(handle: Dora3DHandle, delta_time: f32) -> bool {
	let (still_playing, sample_buffer, morph_sample_buffer) = {
		let mut instances = instance_registry().lock().unwrap();
		let Some(instance) = instances.get_mut(&handle) else {
			return false;
		};
		if !instance.playing {
			return false;
		}
		if instance.paused {
			return true;
		}
		let Some(clip_handle) = instance.current_clip else {
			instance.playing = false;
			return false;
		};
		instance.elapsed += delta_time.max(0.0) * instance.speed;
		let duration = animation::with_clip(clip_handle, |clip| clip.duration).unwrap_or(0.0);
		let mut still_playing = true;
		let sample_time = if instance.looping {
			if duration > 0.0 {
				instance.elapsed.rem_euclid(duration)
			} else {
				instance.elapsed
			}
		} else {
			let clamped = if duration > 0.0 {
				instance.elapsed.min(duration)
			} else {
				instance.elapsed
			};
			if duration > 0.0 && instance.elapsed >= duration {
				instance.playing = false;
				still_playing = false;
			}
			clamped
		};
		let mut sample_buffer = std::mem::take(&mut instance.sample_buffer);
		let mut morph_sample_buffer = std::mem::take(&mut instance.morph_sample_buffer);
		let sampled = animation::with_clip(clip_handle, |clip| {
			skinning::evaluate_animation_into(
				clip,
				sample_time,
				&instance.node_map,
				&mut sample_buffer,
			);
			skinning::evaluate_morph_weights_into(
				clip,
				sample_time,
				&instance.node_map,
				&mut morph_sample_buffer,
			);
		})
		.is_some();
		if !sampled {
			instance.sample_buffer = sample_buffer;
			instance.morph_sample_buffer = morph_sample_buffer;
			return still_playing;
		}
		(still_playing, sample_buffer, morph_sample_buffer)
	};
	for (node, position, rotation, scale) in &sample_buffer {
		if let Some(position) = position {
			let _ = node3d::set_position(*node, *position);
		}
		if let Some(rotation) = rotation {
			let _ = node3d::set_rotation(*node, *rotation);
		}
		if let Some(scale) = scale {
			let _ = node3d::set_scale(*node, *scale);
		}
	}
	if let Some(instance) = instance_registry().lock().unwrap().get_mut(&handle) {
		for (node, weights) in &morph_sample_buffer {
			let Some(indices) = instance.morphs_by_node.get(node) else {
				continue;
			};
			for index in indices {
				let Some(morph) = instance.morph_instances.get_mut(*index) else {
					continue;
				};
				morph.weights.clear();
				morph.weights.extend_from_slice(weights);
				apply_morph_targets(
					&morph.data.base_vertices,
					&morph.data.targets,
					&morph.weights,
					&mut morph.vertices,
				);
				let _ = mesh::update_dynamic_vertices(morph.mesh, &morph.vertices);
			}
		}
		instance.sample_buffer = sample_buffer;
		instance.morph_sample_buffer = morph_sample_buffer;
	}
	still_playing
}

pub fn with_model<R>(handle: Dora3DHandle, f: impl FnOnce(&LoadedModel) -> R) -> Option<R> {
	let models = registry().lock().unwrap();
	models.get(&handle).map(f)
}

pub fn skeleton_for_visual(visual: Dora3DHandle) -> Option<Dora3DHandle> {
	visual_skeletons()
		.lock()
		.unwrap()
		.get(&visual)
		.map(|binding| binding.skeleton)
}

pub fn skeletons_for_visuals(visuals: &[Dora3DHandle]) -> HashMap<Dora3DHandle, Dora3DHandle> {
	let mut result = HashMap::with_capacity(visuals.len());
	skeletons_for_visuals_into(visuals, &mut result);
	result
}

pub fn skeletons_for_visuals_into(
	visuals: &[Dora3DHandle],
	result: &mut HashMap<Dora3DHandle, Dora3DHandle>,
) {
	result.clear();
	let bindings = visual_skeletons().lock().unwrap();
	for visual in visuals {
		if let Some(binding) = bindings.get(visual) {
			result.insert(*visual, binding.skeleton);
		}
	}
}

pub fn get_visual(handle: Dora3DHandle, index: u32) -> Option<Dora3DHandle> {
	with_model(handle, |model| model.visuals.get(index as usize).copied()).flatten()
}

pub fn attach_to_node(handle: Dora3DHandle, parent: Dora3DHandle) -> bool {
	instantiate(handle, parent).is_some()
}

pub fn model_count() -> usize {
	registry().lock().unwrap().len()
}

pub fn instance_count() -> usize {
	instance_registry().lock().unwrap().len()
}

pub fn animation_count_instance(handle: Dora3DHandle) -> usize {
	instance_registry()
		.lock()
		.unwrap()
		.get(&handle)
		.map(|instance| instance.animations.len())
		.unwrap_or(0)
}

pub fn animation_name_instance(handle: Dora3DHandle, index: usize) -> Option<String> {
	let clip = instance_registry()
		.lock()
		.unwrap()
		.get(&handle)?
		.animations
		.get(index)
		.copied()?;
	animation::with_clip(clip, |clip| clip.name.clone())
}

pub fn find_node_instance(handle: Dora3DHandle, name: &str) -> Option<Dora3DHandle> {
	let nodes = instance_registry()
		.lock()
		.unwrap()
		.get(&handle)?
		.nodes
		.clone();
	nodes
		.into_iter()
		.find(|node| node3d::get_tag(*node).as_deref() == Some(name))
}

pub fn attach_to_node_instance(handle: Dora3DHandle, name: &str, child: Dora3DHandle) -> bool {
	let Some(parent) = find_node_instance(handle, name) else {
		return false;
	};
	node3d::add_child(parent, child, 0, None)
}

fn visual_bounds(visual_handle: Dora3DHandle) -> Option<(Aabb, Mat4)> {
	let (node_handle, mesh_handle, enabled) = visual3d::with_visual(visual_handle, |visual| {
		(visual.node, visual.mesh, visual.enabled)
	})?;
	if !enabled || !node3d::is_visible(node_handle) {
		return None;
	}
	let world = node3d::world_matrix(node_handle)?;
	let local_bounds = skeleton_for_visual(visual_handle)
		.and_then(|skeleton_handle| {
			animation::with_skeleton(skeleton_handle, |skeleton| {
				skinning::compute_joint_matrices(skeleton, world.inverse())
			})
		})
		.and_then(|joints| mesh::skinned_bounds(mesh_handle, &joints))
		.or_else(|| mesh::bounds(mesh_handle))?;
	Some((local_bounds, world))
}

pub fn bounds_instance(handle: Dora3DHandle, world_space: bool) -> Option<Aabb> {
	let (root, visuals) = instance_registry()
		.lock()
		.unwrap()
		.get(&handle)
		.map(|instance| (instance.root, instance.visuals.clone()))?;
	let model_world_inverse = if world_space {
		Mat4::IDENTITY
	} else {
		let parent = node3d::parent(root)?;
		node3d::world_matrix(parent)?.inverse()
	};
	let mut result = Aabb::empty();
	for visual in visuals {
		let Some((local_bounds, visual_world)) = visual_bounds(visual) else {
			continue;
		};
		let bounds = transform_aabb(&(model_world_inverse * visual_world), &local_bounds);
		result.include(bounds.min);
		result.include(bounds.max);
	}
	result.is_valid().then_some(result)
}

pub fn material_count_instance(handle: Dora3DHandle) -> usize {
	instance_registry()
		.lock()
		.unwrap()
		.get(&handle)
		.map(|instance| instance.material_slots.len())
		.unwrap_or(0)
}

fn material_handle_instance(
	handle: Dora3DHandle,
	index: usize,
	writable: bool,
) -> Option<Dora3DHandle> {
	let mut instances = instance_registry().lock().unwrap();
	let slot = instances.get_mut(&handle)?.material_slots.get_mut(index)?;
	if writable && !slot.owned {
		let cloned = material::clone_material(slot.material)?;
		for visual in &slot.visuals {
			let _ = visual3d::set_material(*visual, cloned);
		}
		slot.material = cloned;
		slot.owned = true;
	}
	Some(slot.material)
}

pub fn material_base_color_instance(handle: Dora3DHandle, index: usize) -> Option<Vec4> {
	let material = material_handle_instance(handle, index, false)?;
	material::with_material(material, |material| material.base_color)
}

pub fn set_material_base_color_instance(handle: Dora3DHandle, index: usize, color: Vec4) -> bool {
	material_handle_instance(handle, index, true)
		.map(|material| material::set_base_color(material, color))
		.unwrap_or(false)
}

pub fn material_emissive_instance(handle: Dora3DHandle, index: usize) -> Option<Vec3> {
	let material = material_handle_instance(handle, index, false)?;
	material::with_material(material, |material| material.emissive_factor)
}

pub fn set_material_emissive_instance(handle: Dora3DHandle, index: usize, color: Vec3) -> bool {
	material_handle_instance(handle, index, true)
		.map(|material| material::set_emissive_factor(material, color))
		.unwrap_or(false)
}

pub fn material_pbr_instance(handle: Dora3DHandle, index: usize) -> Option<(f32, f32)> {
	let material = material_handle_instance(handle, index, false)?;
	material::with_material(material, |material| (material.metallic, material.roughness))
}

pub fn set_material_pbr_instance(
	handle: Dora3DHandle,
	index: usize,
	metallic: f32,
	roughness: f32,
) -> bool {
	let Some(material_handle) = material_handle_instance(handle, index, true) else {
		return false;
	};
	let alpha_cutoff =
		material::with_material(material_handle, |material| material.alpha_cutoff).unwrap_or(0.5);
	material::set_pbr(material_handle, metallic, roughness, alpha_cutoff)
}

pub fn material_alpha_instance(handle: Dora3DHandle, index: usize) -> Option<(AlphaMode, f32)> {
	let material = material_handle_instance(handle, index, false)?;
	material::with_material(material, |material| {
		(material.alpha_mode, material.alpha_cutoff)
	})
}

pub fn set_material_alpha_instance(
	handle: Dora3DHandle,
	index: usize,
	alpha_mode: AlphaMode,
	alpha_cutoff: f32,
) -> bool {
	material_handle_instance(handle, index, true)
		.map(|material| material::set_alpha_mode(material, alpha_mode, alpha_cutoff))
		.unwrap_or(false)
}

pub fn set_material_texture_instance(
	handle: Dora3DHandle,
	index: usize,
	slot: u8,
	bgfx_texture: u16,
) -> bool {
	let (name, stage) = match slot {
		0 => (material::default_base_color_slot(), 0),
		1 => (material::default_metallic_roughness_slot(), 1),
		2 => (material::default_normal_slot(), 2),
		3 => (material::default_emissive_slot(), 3),
		4 => (material::default_occlusion_slot(), 4),
		_ => return false,
	};
	material_handle_instance(handle, index, true)
		.map(|material| material::set_external_texture(material, name, bgfx_texture, stage))
		.unwrap_or(false)
}

pub fn ray_cast_instance(handle: Dora3DHandle, origin: Vec3, direction: Vec3) -> Option<f32> {
	let visuals = instance_registry()
		.lock()
		.unwrap()
		.get(&handle)
		.map(|instance| instance.visuals.clone())?;
	let mut nearest = f32::INFINITY;
	for visual_handle in visuals {
		let Some((local_bounds, world)) = visual_bounds(visual_handle) else {
			continue;
		};
		let world_bounds = transform_aabb(&world, &local_bounds);
		if let Some(distance) = world_bounds.ray_intersection(origin, direction) {
			nearest = nearest.min(distance);
		}
	}
	nearest.is_finite().then_some(nearest)
}

pub fn total_resident_bytes() -> u64 {
	registry()
		.lock()
		.unwrap()
		.values()
		.map(|model| {
			model
				.meshes
				.iter()
				.map(|handle| mesh::resident_bytes(*handle))
				.sum::<u64>()
				+ model
					.textures
					.iter()
					.map(|handle| texture::resident_bytes(*handle))
					.sum::<u64>()
				+ model
					.morph_meshes
					.values()
					.map(|data| data.resident_bytes())
					.sum::<u64>()
		})
		.sum()
}

pub fn resident_bytes(handle: Dora3DHandle) -> u64 {
	with_model(handle, |model| {
		model
			.meshes
			.iter()
			.map(|handle| mesh::resident_bytes(*handle))
			.sum::<u64>()
			+ model
				.textures
				.iter()
				.map(|handle| texture::resident_bytes(*handle))
				.sum::<u64>()
			+ model
				.morph_meshes
				.values()
				.map(|data| data.resident_bytes())
				.sum::<u64>()
	})
	.unwrap_or(0)
}

pub fn clear_registry() {
	prepared_registry().lock().unwrap().clear();
	let upload_jobs: Vec<Dora3DHandle> = upload_job_registry()
		.lock()
		.unwrap()
		.keys()
		.copied()
		.collect();
	for handle in upload_jobs {
		let _ = cancel_upload_gltf(handle);
	}
	let instance_handles: Vec<Dora3DHandle> = instance_registry()
		.lock()
		.unwrap()
		.keys()
		.copied()
		.collect();
	for handle in instance_handles {
		let _ = destroy_instance(handle);
	}
	let model_handles: Vec<Dora3DHandle> = registry().lock().unwrap().keys().copied().collect();
	for handle in model_handles {
		let _ = destroy(handle);
	}
}

#[cfg(test)]
mod tests {
	use super::*;

	fn rgba_image(pixel: [u8; 4]) -> ImageData {
		ImageData {
			pixels: pixel.to_vec(),
			format: ImageFormat::R8G8B8A8,
			width: 1,
			height: 1,
		}
	}

	fn morph_target(position: [f32; 3], normal: [f32; 3], tangent: [f32; 3]) -> MorphTargetData {
		MorphTargetData {
			position_deltas: vec![position],
			normal_deltas: vec![normal],
			tangent_deltas: vec![tangent],
		}
	}

	fn assert_vec3_near(actual: [f32; 3], expected: Vec3) {
		let actual = Vec3::from_array(actual);
		assert!(
			(actual - expected).length() < 0.0001,
			"{actual:?} != {expected:?}"
		);
	}

	fn weights(value: &KeyframeValue) -> &[f32] {
		let KeyframeValue::Weights(weights) = value else {
			panic!("expected morph weights")
		};
		weights
	}

	#[test]
	fn mesh_collider_extracts_scene_transform_and_triangle_indices() {
		let mut buffer = Vec::new();
		for value in [0.0_f32, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0] {
			buffer.extend_from_slice(&value.to_le_bytes());
		}
		for index in [0_u16, 1, 2] {
			buffer.extend_from_slice(&index.to_le_bytes());
		}
		buffer.extend_from_slice(&[0, 0]);
		let encoded = base64::encode(&buffer);
		let gltf = format!(
			r#"{{
				"asset": {{"version": "2.0"}},
				"buffers": [{{"byteLength": 44, "uri": "data:application/octet-stream;base64,{encoded}"}}],
				"bufferViews": [
					{{"buffer": 0, "byteOffset": 0, "byteLength": 36}},
					{{"buffer": 0, "byteOffset": 36, "byteLength": 6}}
				],
				"accessors": [
					{{"bufferView": 0, "componentType": 5126, "count": 3, "type": "VEC3", "min": [0,0,0], "max": [1,1,0]}},
					{{"bufferView": 1, "componentType": 5123, "count": 3, "type": "SCALAR"}}
				],
				"meshes": [{{"primitives": [{{"attributes": {{"POSITION": 0}}, "indices": 1}}]}}],
				"nodes": [{{"mesh": 0, "translation": [2, 3, 4]}}],
				"scenes": [{{"nodes": [0]}}],
				"scene": 0
			}}"#
		);
		let (vertices, indices) =
			parse_mesh_collider_data("triangle.gltf", gltf.as_bytes(), |_| None).unwrap();
		assert_eq!(indices, [0, 1, 2]);
		assert_eq!(
			vertices,
			[[2.0, 3.0, 4.0], [3.0, 3.0, 4.0], [2.0, 4.0, 4.0]]
		);
	}

	#[test]
	fn convex_hull_extracts_scene_transformed_points() {
		let mut buffer = Vec::new();
		for value in [
			0.0_f32, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0,
		] {
			buffer.extend_from_slice(&value.to_le_bytes());
		}
		for index in [0_u16, 1, 2, 0, 2, 3] {
			buffer.extend_from_slice(&index.to_le_bytes());
		}
		let encoded = base64::encode(&buffer);
		let gltf = format!(
			r#"{{
				"asset": {{"version": "2.0"}},
				"buffers": [{{"byteLength": 60, "uri": "data:application/octet-stream;base64,{encoded}"}}],
				"bufferViews": [
					{{"buffer": 0, "byteOffset": 0, "byteLength": 48}},
					{{"buffer": 0, "byteOffset": 48, "byteLength": 12}}
				],
				"accessors": [
					{{"bufferView": 0, "componentType": 5126, "count": 4, "type": "VEC3", "min": [0,0,0], "max": [1,1,1]}},
					{{"bufferView": 1, "componentType": 5123, "count": 6, "type": "SCALAR"}}
				],
				"meshes": [{{"primitives": [{{"attributes": {{"POSITION": 0}}, "indices": 1}}]}}],
				"nodes": [{{"mesh": 0, "translation": [2, 3, 4]}}],
				"scenes": [{{"nodes": [0]}}],
				"scene": 0
			}}"#
		);
		let points = parse_convex_hull_data("hull.gltf", gltf.as_bytes(), |_| None).unwrap();
		assert_eq!(points.len(), 4);
		assert!(points.contains(&[2.0, 3.0, 4.0]));
		assert!(points.contains(&[2.0, 3.0, 5.0]));
	}

	#[test]
	fn packs_thickness_and_sheen_channels() {
		let images = [rgba_image([1, 37, 3, 4]), rgba_image([5, 6, 7, 91])];
		let (_, _, pixels) = pack_thickness_sheen_texture(&images, 0, 1).unwrap();
		assert_eq!(pixels, [u8::MAX, 37, u8::MAX, 91]);
	}

	#[test]
	fn packs_metallic_roughness_and_anisotropy_channels() {
		let images = [rgba_image([1, 53, 79, 4]), rgba_image([255, 128, 113, 9])];
		let (_, _, pixels) =
			pack_metallic_roughness_anisotropy_texture(&images, Some(0), 1).unwrap();
		assert_eq!(pixels[0], 128);
		assert_eq!(&pixels[1..], &[53, 79, 113]);
	}

	#[test]
	fn calculates_complete_rgba8_mip_chain_size() {
		assert_eq!(rgba8_upload_size(1, 1, false), Some(4));
		assert_eq!(rgba8_upload_size(4, 2, false), Some(32));
		assert_eq!(rgba8_upload_size(4, 2, true), Some(44));
		assert_eq!(rgba8_upload_size(256, 256, true), Some(349_524));
	}

	#[test]
	fn combines_multiple_morph_targets_and_preserves_tangent_handedness() {
		let base = Vertex {
			position: [1.0, 2.0, 3.0],
			normal: [1.0, 0.0, 0.0],
			tangent: [0.0, 1.0, 0.0, -1.0],
			..Default::default()
		};
		let targets = [
			morph_target([2.0, 0.0, 0.0], [0.0, 1.0, 0.0], [1.0, 0.0, 0.0]),
			morph_target([0.0, 4.0, 0.0], [0.0, 0.0, 2.0], [0.0, 0.0, 2.0]),
		];
		let mut output = Vec::new();

		apply_morph_targets(&[base], &targets, &[0.25, 0.5], &mut output);

		assert_vec3_near(output[0].position, Vec3::new(1.5, 4.0, 3.0));
		assert_vec3_near(output[0].normal, Vec3::new(1.0, 0.25, 1.0).normalize());
		assert_vec3_near(
			[
				output[0].tangent[0],
				output[0].tangent[1],
				output[0].tangent[2],
			],
			Vec3::new(0.25, 1.0, 1.0).normalize(),
		);
		assert_eq!(output[0].tangent[3], -1.0);

		apply_morph_targets(&[base], &targets, &[0.25], &mut output);
		assert_vec3_near(output[0].position, Vec3::new(1.5, 2.0, 3.0));
	}

	#[test]
	fn groups_multi_target_weight_keyframes_in_gltf_order() {
		let linear = build_weight_keyframes(
			&[0.0, 1.0],
			vec![0.0, 1.0, 0.25, 0.75],
			2,
			Interpolation::Linear,
		);
		assert_eq!(linear.len(), 2);
		assert_eq!(weights(&linear[0].value), [0.0, 1.0]);
		assert_eq!(weights(&linear[1].value), [0.25, 0.75]);

		let cubic = build_weight_keyframes(
			&[0.0],
			vec![1.0, 2.0, 0.25, 0.75, 3.0, 4.0],
			2,
			Interpolation::CubicSpline,
		);
		assert_eq!(cubic.len(), 1);
		assert_eq!(weights(&cubic[0].value), [0.25, 0.75]);
		assert_eq!(cubic[0].in_weights_tangent, Some(vec![1.0, 2.0]));
		assert_eq!(cubic[0].out_weights_tangent, Some(vec![3.0, 4.0]));
	}
}
