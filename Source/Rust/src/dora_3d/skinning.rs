use super::animation::{
	AnimationClipData, ChannelProperty, Interpolation, Keyframe, KeyframeValue, SkeletonData,
};
use super::node3d;
use super::types::{Mat4, Quaternion, Vec3, Vec4};
use super::Dora3DHandle;
use std::collections::HashMap;

fn normalized_time(clip: &AnimationClipData, time: f32) -> f32 {
	if clip.duration > 0.0 {
		time.clamp(0.0, clip.duration)
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
		if time >= current.time && time < next.time {
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

pub fn compute_joint_matrices_from_world(
	skeleton: &SkeletonData,
	mesh_world_inverse: Mat4,
	world_matrices: &HashMap<Dora3DHandle, Mat4>,
) -> Vec<Mat4> {
	skeleton
		.joints
		.iter()
		.enumerate()
		.map(|(index, joint_handle)| {
			let joint_world = world_matrices
				.get(joint_handle)
				.copied()
				.unwrap_or(Mat4::IDENTITY);
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
	node_map: &HashMap<Dora3DHandle, Dora3DHandle>,
) -> Vec<(Dora3DHandle, Option<Vec3>, Option<Quaternion>, Option<Vec3>)> {
	let mut result = Vec::new();
	evaluate_animation_into(clip, time, node_map, &mut result);
	result
}

pub fn evaluate_animation_into(
	clip: &AnimationClipData,
	time: f32,
	node_map: &HashMap<Dora3DHandle, Dora3DHandle>,
	result: &mut Vec<(Dora3DHandle, Option<Vec3>, Option<Quaternion>, Option<Vec3>)>,
) {
	result.clear();
	let sample_time = normalized_time(clip, time);
	for channel in &clip.channels {
		let Some(node_handle) = node_map.get(&channel.target_node).copied() else {
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
				entry.1 = sample_vec3(current, next, factor, channel.interpolation, true);
			}
			ChannelProperty::Rotation => {
				entry.2 = sample_rotation(current, next, factor, channel.interpolation);
			}
			ChannelProperty::Scale => {
				entry.3 = sample_vec3(current, next, factor, channel.interpolation, false);
			}
		}
	}
}

fn hermite(current: Vec4, current_tangent: Vec4, next: Vec4, next_tangent: Vec4, t: f32) -> Vec4 {
	let t2 = t * t;
	let t3 = t2 * t;
	current * (2.0 * t3 - 3.0 * t2 + 1.0)
		+ current_tangent * (t3 - 2.0 * t2 + t)
		+ next * (-2.0 * t3 + 3.0 * t2)
		+ next_tangent * (t3 - t2)
}

fn sample_vec3(
	current: &Keyframe,
	next: &Keyframe,
	factor: f32,
	interpolation: Interpolation,
	translation: bool,
) -> Option<Vec3> {
	let value = |keyframe: &Keyframe| match (&keyframe.value, translation) {
		(KeyframeValue::Translation(value), true) | (KeyframeValue::Scale(value), false) => {
			Some(*value)
		}
		_ => None,
	};
	let current_value = value(current)?;
	let next_value = value(next)?;
	match interpolation {
		Interpolation::Step => Some(current_value),
		Interpolation::Linear => Some(current_value.lerp(next_value, factor)),
		Interpolation::CubicSpline => {
			let span = (next.time - current.time).max(0.0);
			let current_tangent = current.out_tangent.unwrap_or(Vec4::ZERO) * span;
			let next_tangent = next.in_tangent.unwrap_or(Vec4::ZERO) * span;
			Some(
				hermite(
					current_value.extend(0.0),
					current_tangent,
					next_value.extend(0.0),
					next_tangent,
					factor,
				)
				.truncate(),
			)
		}
	}
}

fn sample_rotation(
	current: &Keyframe,
	next: &Keyframe,
	factor: f32,
	interpolation: Interpolation,
) -> Option<Quaternion> {
	let KeyframeValue::Rotation(current_value) = current.value else {
		return None;
	};
	let KeyframeValue::Rotation(next_value) = next.value else {
		return None;
	};
	match interpolation {
		Interpolation::Step => Some(current_value),
		Interpolation::Linear => Some(current_value.slerp(next_value, factor).normalize()),
		Interpolation::CubicSpline => {
			let span = (next.time - current.time).max(0.0);
			let current_tangent = current.out_tangent.unwrap_or(Vec4::ZERO) * span;
			let next_tangent = next.in_tangent.unwrap_or(Vec4::ZERO) * span;
			let value = hermite(
				Vec4::from_array(current_value.to_array()),
				current_tangent,
				Vec4::from_array(next_value.to_array()),
				next_tangent,
				factor,
			);
			Some(Quaternion::from_array(value.to_array()).normalize())
		}
	}
}

#[cfg(test)]
mod tests {
	use super::*;
	use crate::dora_3d::animation::{AnimationChannel, AnimationClipData};

	fn translation_keyframe(
		time: f32,
		value: f32,
		in_tangent: Option<f32>,
		out_tangent: Option<f32>,
	) -> Keyframe {
		Keyframe {
			time,
			value: KeyframeValue::Translation(Vec3::new(value, 0.0, 0.0)),
			in_tangent: in_tangent.map(|value| Vec4::new(value, 0.0, 0.0, 0.0)),
			out_tangent: out_tangent.map(|value| Vec4::new(value, 0.0, 0.0, 0.0)),
		}
	}

	fn translation_clip(
		interpolation: Interpolation,
		keyframes: Vec<Keyframe>,
	) -> AnimationClipData {
		AnimationClipData {
			handle: 0,
			name: "test".to_owned(),
			duration: 1.0,
			channels: vec![AnimationChannel {
				target_node: 10,
				property: ChannelProperty::Translation,
				interpolation,
				keyframes,
			}],
		}
	}

	fn sampled_x(clip: &AnimationClipData, time: f32) -> f32 {
		let node_map = HashMap::from([(10, 20)]);
		let result = evaluate_animation(clip, time, &node_map);
		assert_eq!(result[0].0, 20);
		result[0].1.unwrap().x
	}

	#[test]
	fn step_switches_at_exact_keyframe() {
		let clip = translation_clip(
			Interpolation::Step,
			vec![
				translation_keyframe(0.0, 1.0, None, None),
				translation_keyframe(0.5, 2.0, None, None),
				translation_keyframe(1.0, 3.0, None, None),
			],
		);
		assert_eq!(sampled_x(&clip, 0.49), 1.0);
		assert_eq!(sampled_x(&clip, 0.5), 2.0);
		assert_eq!(sampled_x(&clip, 1.0), 3.0);
	}

	#[test]
	fn linear_samples_midpoint_and_preserves_last_frame() {
		let clip = translation_clip(
			Interpolation::Linear,
			vec![
				translation_keyframe(0.0, 0.0, None, None),
				translation_keyframe(1.0, 10.0, None, None),
			],
		);
		assert_eq!(sampled_x(&clip, 0.5), 5.0);
		assert_eq!(sampled_x(&clip, 1.0), 10.0);
	}

	#[test]
	fn cubic_spline_uses_scaled_tangents() {
		let clip = translation_clip(
			Interpolation::CubicSpline,
			vec![
				translation_keyframe(0.0, 0.0, None, Some(4.0)),
				translation_keyframe(1.0, 1.0, Some(0.0), None),
			],
		);
		assert!((sampled_x(&clip, 0.5) - 1.0).abs() < 0.0001);
	}
}
