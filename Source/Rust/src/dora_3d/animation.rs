use super::types::{Mat4, Quaternion, Vec3, Vec4};
use super::{next_handle, Dora3DHandle};
use std::collections::HashMap;
use std::sync::{Mutex, OnceLock};

#[derive(Debug, Clone)]
pub struct SkeletonData {
	pub handle: Dora3DHandle,
	pub joints: Vec<Dora3DHandle>,
	pub inverse_bind_matrices: Vec<Mat4>,
}

#[derive(Debug, Clone)]
pub struct AnimationClipData {
	pub handle: Dora3DHandle,
	pub name: String,
	pub duration: f32,
	pub channels: Vec<AnimationChannel>,
}

#[derive(Debug, Clone)]
pub struct AnimationChannel {
	pub target_node: Dora3DHandle,
	pub property: ChannelProperty,
	pub interpolation: Interpolation,
	pub keyframes: Vec<Keyframe>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Interpolation {
	Step,
	Linear,
	CubicSpline,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ChannelProperty {
	Translation,
	Rotation,
	Scale,
}

#[derive(Debug, Clone)]
pub struct Keyframe {
	pub time: f32,
	pub value: KeyframeValue,
	pub in_tangent: Option<Vec4>,
	pub out_tangent: Option<Vec4>,
}

#[derive(Debug, Clone)]
pub enum KeyframeValue {
	Translation(Vec3),
	Rotation(Quaternion),
	Scale(Vec3),
}

#[derive(Debug, Clone)]
pub enum AnimationData {
	Skeleton(SkeletonData),
	Clip(AnimationClipData),
}

fn registry() -> &'static Mutex<HashMap<Dora3DHandle, AnimationData>> {
	static REGISTRY: OnceLock<Mutex<HashMap<Dora3DHandle, AnimationData>>> = OnceLock::new();
	REGISTRY.get_or_init(|| Mutex::new(HashMap::new()))
}

pub fn create(mut data: AnimationData) -> Dora3DHandle {
	let handle = next_handle();
	match &mut data {
		AnimationData::Skeleton(skeleton) => skeleton.handle = handle,
		AnimationData::Clip(clip) => clip.handle = handle,
	}
	registry().lock().unwrap().insert(handle, data);
	handle
}

pub fn destroy(handle: Dora3DHandle) -> bool {
	registry().lock().unwrap().remove(&handle).is_some()
}

pub fn with_skeleton<R>(handle: Dora3DHandle, f: impl FnOnce(&SkeletonData) -> R) -> Option<R> {
	let animations = registry().lock().unwrap();
	match animations.get(&handle) {
		Some(AnimationData::Skeleton(skeleton)) => Some(f(skeleton)),
		_ => None,
	}
}

pub fn skeletons(handles: &[Dora3DHandle]) -> HashMap<Dora3DHandle, SkeletonData> {
	let animations = registry().lock().unwrap();
	handles
		.iter()
		.filter_map(|handle| match animations.get(handle) {
			Some(AnimationData::Skeleton(skeleton)) => Some((*handle, skeleton.clone())),
			_ => None,
		})
		.collect()
}

pub fn with_clip<R>(handle: Dora3DHandle, f: impl FnOnce(&AnimationClipData) -> R) -> Option<R> {
	let animations = registry().lock().unwrap();
	match animations.get(&handle) {
		Some(AnimationData::Clip(clip)) => Some(f(clip)),
		_ => None,
	}
}

pub fn clear_registry() {
	registry().lock().unwrap().clear();
}

pub fn count() -> usize {
	registry().lock().unwrap().len()
}
