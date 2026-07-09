use super::animation::{AnimationClipData, ChannelProperty, Keyframe, KeyframeValue, SkeletonData};
use super::node3d;
use super::types::{Mat4, Quaternion, Vec3};
use super::Dora3DHandle;

fn normalized_time(clip: &AnimationClipData, time: f32) -> f32 {
	if clip.duration > 0.0 {
		time.rem_euclid(clip.duration)
	} else {
		time.max(0.0)
	}
}

fn sample_segment(keyframes: &[Keyframe], time: f32) -> Option<(&Keyframe, &Keyframe, f32)> {
	let first = keyframes.first()?;
	let last = keyframes.last()?;
	if time <= first.time {
		return Some((first, first, 0.0));
	}
	if time >= last.time {
		return Some((last, last, 0.0));
	}
	for window in keyframes.windows(2) {
		let current = &window[0];
		let next = &window[1];
		if time >= current.time && time <= next.time {
			let span = (next.time - current.time).max(f32::EPSILON);
			let factor = ((time - current.time) / span).clamp(0.0, 1.0);
			return Some((current, next, factor));
		}
	}
	Some((last, last, 0.0))
}

pub fn compute_joint_matrices(skeleton: &SkeletonData, mesh_world_inverse: Mat4) -> Vec<Mat4> {
	skeleton
		.joints
		.iter()
		.enumerate()
		.map(|(index, joint_handle)| {
			let joint_world = node3d::world_matrix(*joint_handle).unwrap_or(Mat4::IDENTITY);
			let inverse_bind = skeleton
				.inverse_bind_matrices
				.get(index)
				.copied()
				.unwrap_or(Mat4::IDENTITY);
			mesh_world_inverse * joint_world * inverse_bind
		})
		.collect()
}

pub fn evaluate_animation(
	clip: &AnimationClipData,
	time: f32,
	node_handles: &[Dora3DHandle],
	skeleton: &SkeletonData,
) -> Vec<(Dora3DHandle, Option<Vec3>, Option<Quaternion>, Option<Vec3>)> {
	let mut result = Vec::new();
	evaluate_animation_into(clip, time, node_handles, skeleton, &mut result);
	result
}

pub fn evaluate_animation_into(
	clip: &AnimationClipData,
	time: f32,
	node_handles: &[Dora3DHandle],
	skeleton: &SkeletonData,
	result: &mut Vec<(Dora3DHandle, Option<Vec3>, Option<Quaternion>, Option<Vec3>)>,
) {
	result.clear();
	let sample_time = normalized_time(clip, time);
	for channel in &clip.channels {
		let joint_handle = skeleton
			.joints
			.get(channel.joint_index)
			.copied()
			.or_else(|| node_handles.get(channel.joint_index).copied());
		let Some(node_handle) = joint_handle else {
			continue;
		};
		let Some((current, next, factor)) = sample_segment(&channel.keyframes, sample_time) else {
			continue;
		};
		let entry_index =
			if let Some(index) = result.iter().position(|entry| entry.0 == node_handle) {
				index
			} else {
				result.push((node_handle, None, None, None));
				result.len() - 1
			};
		let entry = &mut result[entry_index];
		match channel.property {
			ChannelProperty::Translation => {
				let current = match &current.value {
					KeyframeValue::Translation(value) => *value,
					_ => continue,
				};
				let next = match &next.value {
					KeyframeValue::Translation(value) => *value,
					_ => continue,
				};
				entry.1 = Some(current.lerp(next, factor));
			}
			ChannelProperty::Rotation => {
				let current = match &current.value {
					KeyframeValue::Rotation(value) => *value,
					_ => continue,
				};
				let next = match &next.value {
					KeyframeValue::Rotation(value) => *value,
					_ => continue,
				};
				entry.2 = Some(current.slerp(next, factor));
			}
			ChannelProperty::Scale => {
				let current = match &current.value {
					KeyframeValue::Scale(value) => *value,
					_ => continue,
				};
				let next = match &next.value {
					KeyframeValue::Scale(value) => *value,
					_ => continue,
				};
				entry.3 = Some(current.lerp(next, factor));
			}
		}
	}
}
