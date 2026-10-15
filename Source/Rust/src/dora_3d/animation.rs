use super::types::{Mat4, Quaternion, Vec3, Vec4};
use super::{next_handle, Dora3DHandle};
use std::collections::HashMap;
use std::sync::{Arc, Mutex, OnceLock};

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
	MorphWeights,
}

#[derive(Debug, Clone)]
pub struct Keyframe {
	pub time: f32,
	pub value: KeyframeValue,
	pub in_tangent: Option<Vec4>,
	pub out_tangent: Option<Vec4>,
	pub in_weights_tangent: Option<Vec<f32>>,
	pub out_weights_tangent: Option<Vec<f32>>,
}

#[derive(Debug, Clone)]
pub enum KeyframeValue {
	Translation(Vec3),
	Rotation(Quaternion),
	Scale(Vec3),
	Weights(Vec<f32>),
}

#[derive(Debug, Clone)]
pub enum AnimationData {
	Skeleton(SkeletonData),
	Clip(AnimationClipData),
}

#[derive(Debug, Clone)]
enum StoredAnimationData {
	Skeleton(Arc<SkeletonData>),
	Clip(Arc<AnimationClipData>),
}

fn registry() -> &'static Mutex<HashMap<Dora3DHandle, StoredAnimationData>> {
	static REGISTRY: OnceLock<Mutex<HashMap<Dora3DHandle, StoredAnimationData>>> = OnceLock::new();
	REGISTRY.get_or_init(|| Mutex::new(HashMap::new()))
}

pub fn create(mut data: AnimationData) -> Dora3DHandle {
	let handle = next_handle();
	match &mut data {
		AnimationData::Skeleton(skeleton) => skeleton.handle = handle,
		AnimationData::Clip(clip) => clip.handle = handle,
	}
	let data = match data {
		AnimationData::Skeleton(skeleton) => StoredAnimationData::Skeleton(Arc::new(skeleton)),
		AnimationData::Clip(clip) => StoredAnimationData::Clip(Arc::new(clip)),
	};
	registry().lock().unwrap().insert(handle, data);
	handle
}

pub fn destroy(handle: Dora3DHandle) -> bool {
	registry().lock().unwrap().remove(&handle).is_some()
}

pub fn with_skeleton<R>(handle: Dora3DHandle, f: impl FnOnce(&SkeletonData) -> R) -> Option<R> {
	let animations = registry().lock().unwrap();
	match animations.get(&handle) {
		Some(StoredAnimationData::Skeleton(skeleton)) => Some(f(skeleton)),
		_ => None,
	}
}

pub fn skeletons(handles: &[Dora3DHandle]) -> HashMap<Dora3DHandle, Arc<SkeletonData>> {
	let mut result = HashMap::with_capacity(handles.len());
	skeletons_into(handles, &mut result);
	result
}

pub fn skeletons_into(
	handles: &[Dora3DHandle],
	result: &mut HashMap<Dora3DHandle, Arc<SkeletonData>>,
) {
	result.clear();
	let animations = registry().lock().unwrap();
	for handle in handles {
		if let Some(StoredAnimationData::Skeleton(skeleton)) = animations.get(handle) {
			result.insert(*handle, Arc::clone(skeleton));
		}
	}
}

pub fn with_clip<R>(handle: Dora3DHandle, f: impl FnOnce(&AnimationClipData) -> R) -> Option<R> {
	let animations = registry().lock().unwrap();
	match animations.get(&handle) {
		Some(StoredAnimationData::Clip(clip)) => Some(f(clip)),
		_ => None,
	}
}

pub fn clear_registry() {
	registry().lock().unwrap().clear();
}

pub fn count() -> usize {
	registry().lock().unwrap().len()
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn skeleton_snapshots_share_immutable_storage() {
		let handle = create(AnimationData::Skeleton(SkeletonData {
			handle: 0,
			joints: vec![11, 12],
			inverse_bind_matrices: vec![Mat4::IDENTITY, Mat4::IDENTITY],
		}));
		let first = skeletons(&[handle]).remove(&handle).unwrap();
		let second = skeletons(&[handle]).remove(&handle).unwrap();

		assert!(Arc::ptr_eq(&first, &second));
		assert_eq!(first.joints, [11, 12]);
		assert!(destroy(handle));
	}
}
