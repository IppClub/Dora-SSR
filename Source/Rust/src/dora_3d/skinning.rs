use super::animation::{AnimationClipData, ChannelProperty, Keyframe, KeyframeValue, SkeletonData};
use super::types::{Mat4, Quaternion, Vec3};
use super::Dora3DHandle;
use std::collections::HashMap;

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

pub fn compute_joint_matrices(
    skeleton: &SkeletonData,
    node_world_transforms: &HashMap<Dora3DHandle, Mat4>,
) -> Vec<Mat4> {
    skeleton
        .joints
        .iter()
        .enumerate()
        .map(|(index, joint_handle)| {
            let joint_world = node_world_transforms
                .get(joint_handle)
                .copied()
                .unwrap_or(Mat4::IDENTITY);
            let inverse_bind = skeleton
                .inverse_bind_matrices
                .get(index)
                .copied()
                .unwrap_or(Mat4::IDENTITY);
            joint_world * inverse_bind
        })
        .collect()
}

pub fn evaluate_animation(
    clip: &AnimationClipData,
    time: f32,
    node_handles: &[Dora3DHandle],
    skeleton: &SkeletonData,
) -> HashMap<Dora3DHandle, (Option<Vec3>, Option<Quaternion>, Option<Vec3>)> {
    let mut result = HashMap::new();
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
        let entry = result.entry(node_handle).or_insert((None, None, None));
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
                entry.0 = Some(current.lerp(next, factor));
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
                entry.1 = Some(current.slerp(next, factor));
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
                entry.2 = Some(current.lerp(next, factor));
            }
        }
    }
    result
}
