use super::node3d;
use super::types::{Aabb, Vec3};
use super::Dora3DHandle;
use std::collections::{HashMap, HashSet};
use std::sync::{Mutex, OnceLock};

const MAX_DIRECT_POINT_LIGHTS: usize = 4;
const SELECTION_HYSTERESIS: f32 = 1.1;

#[derive(Debug, Clone, Copy)]
struct DirectionalLightData {
	node: Dora3DHandle,
	color: Vec3,
	intensity: f32,
	cast_shadow: bool,
	shadow_bias: f32,
	shadow_normal_bias: f32,
}

#[derive(Debug, Clone, Copy)]
struct PointLightData {
	node: Dora3DHandle,
	color: Vec3,
	intensity: f32,
	range: f32,
}

#[derive(Debug, Clone, Copy)]
pub struct DirectionalLight {
	pub handle: Dora3DHandle,
	pub direction: Vec3,
	pub radiance: Vec3,
	pub cast_shadow: bool,
	pub shadow_bias: f32,
	pub shadow_normal_bias: f32,
}

#[derive(Debug, Clone, Copy)]
pub struct PointLight {
	pub handle: Dora3DHandle,
	pub position: Vec3,
	pub radiance: Vec3,
	pub range: f32,
}

#[derive(Debug, Clone, Default)]
pub struct SceneLights {
	pub directional: Option<DirectionalLight>,
	pub points: Vec<PointLight>,
}

#[derive(Debug, Clone, Copy)]
pub struct DrawLights {
	pub directional_direction: [f32; 4],
	pub directional_color: [f32; 4],
	pub point_position_range: [[f32; 4]; MAX_DIRECT_POINT_LIGHTS],
	pub point_color_intensity: [[f32; 4]; MAX_DIRECT_POINT_LIGHTS],
	pub overflow_sh: [[f32; 4]; 4],
}

impl Default for DrawLights {
	fn default() -> Self {
		Self {
			directional_direction: [0.0; 4],
			directional_color: [0.0; 4],
			point_position_range: [[0.0; 4]; MAX_DIRECT_POINT_LIGHTS],
			point_color_intensity: [[0.0; 4]; MAX_DIRECT_POINT_LIGHTS],
			overflow_sh: [[0.0; 4]; 4],
		}
	}
}

#[derive(Debug, Default)]
struct LightRegistry {
	directional: HashMap<Dora3DHandle, DirectionalLightData>,
	points: HashMap<Dora3DHandle, PointLightData>,
	selected_by_visual: HashMap<Dora3DHandle, [Dora3DHandle; MAX_DIRECT_POINT_LIGHTS]>,
}

fn registry() -> &'static Mutex<LightRegistry> {
	static REGISTRY: OnceLock<Mutex<LightRegistry>> = OnceLock::new();
	REGISTRY.get_or_init(|| Mutex::new(LightRegistry::default()))
}

fn srgb_to_linear_component(value: f32) -> f32 {
	let value = value.clamp(0.0, 1.0);
	if value <= 0.04045 {
		value / 12.92
	} else {
		((value + 0.055) / 1.055).powf(2.4)
	}
}

fn linear_color(color: Vec3) -> Vec3 {
	Vec3::new(
		srgb_to_linear_component(color.x),
		srgb_to_linear_component(color.y),
		srgb_to_linear_component(color.z),
	)
}

fn luminance(color: Vec3) -> f32 {
	color.dot(Vec3::new(0.2126, 0.7152, 0.0722))
}

pub fn create_directional(node: Dora3DHandle) -> bool {
	if !node3d::exists(node) {
		return false;
	}
	registry().lock().unwrap().directional.insert(
		node,
		DirectionalLightData {
			node,
			color: Vec3::ONE,
			intensity: 1.0,
			cast_shadow: false,
			shadow_bias: 0.004,
			shadow_normal_bias: 0.02,
		},
	);
	true
}

pub fn create_point(node: Dora3DHandle) -> bool {
	if !node3d::exists(node) {
		return false;
	}
	registry().lock().unwrap().points.insert(
		node,
		PointLightData {
			node,
			color: Vec3::ONE,
			intensity: 1.0,
			range: 10.0,
		},
	);
	true
}

pub fn destroy_node(node: Dora3DHandle) {
	let mut lights = registry().lock().unwrap();
	lights.directional.remove(&node);
	lights.points.remove(&node);
}

pub fn remove_visual_selection(visual: Dora3DHandle) {
	registry()
		.lock()
		.unwrap()
		.selected_by_visual
		.remove(&visual);
}

pub fn set_directional_color(node: Dora3DHandle, color: Vec3) -> bool {
	let mut lights = registry().lock().unwrap();
	let Some(light) = lights.directional.get_mut(&node) else {
		return false;
	};
	light.color = color.clamp(Vec3::ZERO, Vec3::ONE);
	true
}

pub fn directional_color(node: Dora3DHandle) -> Option<Vec3> {
	registry()
		.lock()
		.unwrap()
		.directional
		.get(&node)
		.map(|light| light.color)
}

pub fn set_directional_intensity(node: Dora3DHandle, intensity: f32) -> bool {
	let mut lights = registry().lock().unwrap();
	let Some(light) = lights.directional.get_mut(&node) else {
		return false;
	};
	light.intensity = intensity.max(0.0);
	true
}

pub fn directional_intensity(node: Dora3DHandle) -> Option<f32> {
	registry()
		.lock()
		.unwrap()
		.directional
		.get(&node)
		.map(|light| light.intensity)
}

pub fn set_directional_cast_shadow(node: Dora3DHandle, enabled: bool) -> bool {
	let mut lights = registry().lock().unwrap();
	let Some(light) = lights.directional.get_mut(&node) else {
		return false;
	};
	light.cast_shadow = enabled;
	true
}

pub fn directional_cast_shadow(node: Dora3DHandle) -> Option<bool> {
	registry()
		.lock()
		.unwrap()
		.directional
		.get(&node)
		.map(|light| light.cast_shadow)
}

pub fn set_directional_shadow_bias(node: Dora3DHandle, bias: f32) -> bool {
	let mut lights = registry().lock().unwrap();
	let Some(light) = lights.directional.get_mut(&node) else {
		return false;
	};
	light.shadow_bias = bias.max(0.0);
	true
}

pub fn directional_shadow_bias(node: Dora3DHandle) -> Option<f32> {
	registry()
		.lock()
		.unwrap()
		.directional
		.get(&node)
		.map(|light| light.shadow_bias)
}

pub fn set_directional_shadow_normal_bias(node: Dora3DHandle, bias: f32) -> bool {
	let mut lights = registry().lock().unwrap();
	let Some(light) = lights.directional.get_mut(&node) else {
		return false;
	};
	light.shadow_normal_bias = bias.max(0.0);
	true
}

pub fn directional_shadow_normal_bias(node: Dora3DHandle) -> Option<f32> {
	registry()
		.lock()
		.unwrap()
		.directional
		.get(&node)
		.map(|light| light.shadow_normal_bias)
}

pub fn scene_has_shadow_light(root: Dora3DHandle) -> bool {
	let lights = registry().lock().unwrap();
	for light in lights.directional.values() {
		if !light.cast_shadow || light.intensity <= 0.0 {
			continue;
		}
		let mut node = Some(light.node);
		while let Some(handle) = node {
			if handle == root {
				return true;
			}
			node = node3d::parent(handle);
		}
	}
	false
}

pub fn set_point_color(node: Dora3DHandle, color: Vec3) -> bool {
	let mut lights = registry().lock().unwrap();
	let Some(light) = lights.points.get_mut(&node) else {
		return false;
	};
	light.color = color.clamp(Vec3::ZERO, Vec3::ONE);
	true
}

pub fn point_color(node: Dora3DHandle) -> Option<Vec3> {
	registry()
		.lock()
		.unwrap()
		.points
		.get(&node)
		.map(|light| light.color)
}

pub fn set_point_intensity(node: Dora3DHandle, intensity: f32) -> bool {
	let mut lights = registry().lock().unwrap();
	let Some(light) = lights.points.get_mut(&node) else {
		return false;
	};
	light.intensity = intensity.max(0.0);
	true
}

pub fn point_intensity(node: Dora3DHandle) -> Option<f32> {
	registry()
		.lock()
		.unwrap()
		.points
		.get(&node)
		.map(|light| light.intensity)
}

pub fn set_point_range(node: Dora3DHandle, range: f32) -> bool {
	let mut lights = registry().lock().unwrap();
	let Some(light) = lights.points.get_mut(&node) else {
		return false;
	};
	light.range = range.max(0.0);
	true
}

pub fn point_range(node: Dora3DHandle) -> Option<f32> {
	registry()
		.lock()
		.unwrap()
		.points
		.get(&node)
		.map(|light| light.range)
}

pub fn collect_scene(nodes: &[Dora3DHandle]) -> SceneLights {
	let node_set: HashSet<_> = nodes.iter().copied().collect();
	let lights = registry().lock().unwrap();
	let mut directionals = Vec::new();
	for light in lights.directional.values() {
		if !node_set.contains(&light.node) || light.intensity <= 0.0 {
			continue;
		}
		let Some(world) = node3d::world_matrix(light.node) else {
			continue;
		};
		let direction = world.transform_vector3(Vec3::Z).normalize_or_zero();
		let radiance = linear_color(light.color) * light.intensity;
		directionals.push(DirectionalLight {
			handle: light.node,
			direction,
			radiance,
			cast_shadow: light.cast_shadow,
			shadow_bias: light.shadow_bias,
			shadow_normal_bias: light.shadow_normal_bias,
		});
	}
	directionals.sort_by(|a, b| {
		luminance(b.radiance)
			.total_cmp(&luminance(a.radiance))
			.then_with(|| a.handle.cmp(&b.handle))
	});

	let mut points = Vec::new();
	for light in lights.points.values() {
		if !node_set.contains(&light.node) || light.intensity <= 0.0 || light.range <= 0.0 {
			continue;
		}
		let Some(world) = node3d::world_matrix(light.node) else {
			continue;
		};
		points.push(PointLight {
			handle: light.node,
			position: world.transform_point3(Vec3::ZERO),
			radiance: linear_color(light.color) * light.intensity,
			range: light.range,
		});
	}
	points.sort_by_key(|light| light.handle);
	SceneLights {
		directional: directionals.into_iter().next(),
		points,
	}
}

fn distance_to_aabb(point: Vec3, bounds: &Aabb) -> f32 {
	(point - point.clamp(bounds.min, bounds.max)).length()
}

fn attenuation(distance: f32, range: f32) -> f32 {
	if range <= 0.0 || distance >= range {
		return 0.0;
	}
	let normalized = distance / range;
	let cutoff = (1.0 - normalized.powi(4)).clamp(0.0, 1.0);
	cutoff * cutoff / distance.powi(2).max(0.01)
}

pub fn prepare_draw(visual: Dora3DHandle, bounds: &Aabb, scene: &SceneLights) -> DrawLights {
	let mut draw = DrawLights::default();
	if let Some(light) = scene.directional {
		draw.directional_direction = [light.direction.x, light.direction.y, light.direction.z, 1.0];
		draw.directional_color = [light.radiance.x, light.radiance.y, light.radiance.z, 1.0];
	}

	let previous = registry()
		.lock()
		.unwrap()
		.selected_by_visual
		.get(&visual)
		.copied()
		.unwrap_or([0; MAX_DIRECT_POINT_LIGHTS]);
	let previous: HashSet<_> = previous.into_iter().filter(|handle| *handle != 0).collect();
	let mut candidates: Vec<_> = scene
		.points
		.iter()
		.filter_map(|light| {
			let distance = distance_to_aabb(light.position, bounds);
			let attenuation = attenuation(distance, light.range);
			if attenuation <= 0.0 {
				return None;
			}
			let mut score = luminance(light.radiance) * attenuation;
			if previous.contains(&light.handle) {
				score *= SELECTION_HYSTERESIS;
			}
			Some((*light, score))
		})
		.collect();
	candidates.sort_by(|(a, a_score), (b, b_score)| {
		b_score
			.total_cmp(a_score)
			.then_with(|| a.handle.cmp(&b.handle))
	});

	let mut selected = [0; MAX_DIRECT_POINT_LIGHTS];
	for (index, (light, _)) in candidates.iter().take(MAX_DIRECT_POINT_LIGHTS).enumerate() {
		selected[index] = light.handle;
		draw.point_position_range[index] = [
			light.position.x,
			light.position.y,
			light.position.z,
			light.range,
		];
		draw.point_color_intensity[index] =
			[light.radiance.x, light.radiance.y, light.radiance.z, 1.0];
	}
	registry()
		.lock()
		.unwrap()
		.selected_by_visual
		.insert(visual, selected);

	let center = (bounds.min + bounds.max) * 0.5;
	for (light, _) in candidates.iter().skip(MAX_DIRECT_POINT_LIGHTS) {
		let offset = light.position - center;
		let distance = offset.length();
		let direction = offset.normalize_or_zero();
		let radiance = light.radiance * attenuation(distance, light.range);
		let coefficients = [
			0.25,
			0.5 * direction.x,
			0.5 * direction.y,
			0.5 * direction.z,
		];
		for (index, coefficient) in coefficients.into_iter().enumerate() {
			draw.overflow_sh[index][0] += radiance.x * coefficient;
			draw.overflow_sh[index][1] += radiance.y * coefficient;
			draw.overflow_sh[index][2] += radiance.z * coefficient;
		}
	}
	draw
}

pub fn clear_registry() {
	*registry().lock().unwrap() = LightRegistry::default();
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn attenuation_is_zero_outside_range() {
		assert_eq!(attenuation(10.0, 10.0), 0.0);
		assert_eq!(attenuation(11.0, 10.0), 0.0);
		assert!(attenuation(1.0, 10.0) > attenuation(5.0, 10.0));
	}

	#[test]
	fn distance_to_bounds_uses_closest_point() {
		let bounds = Aabb {
			min: Vec3::splat(-1.0),
			max: Vec3::splat(1.0),
		};
		assert_eq!(distance_to_aabb(Vec3::ZERO, &bounds), 0.0);
		assert_eq!(distance_to_aabb(Vec3::new(3.0, 0.0, 0.0), &bounds), 2.0);
	}

	#[test]
	fn shadow_light_is_scoped_to_its_scene_root() {
		clear_registry();
		let root = node3d::create();
		let other_root = node3d::create();
		let light = node3d::create();
		assert!(node3d::add_child(root, light, 0, None));
		assert!(create_directional(light));
		assert!(!scene_has_shadow_light(root));
		assert!(set_directional_cast_shadow(light, true));
		assert!(scene_has_shadow_light(root));
		assert!(!scene_has_shadow_light(other_root));
		assert!(set_directional_shadow_bias(light, 0.006));
		assert!(set_directional_shadow_normal_bias(light, 0.03));
		assert_eq!(directional_shadow_bias(light), Some(0.006));
		assert_eq!(directional_shadow_normal_bias(light), Some(0.03));
		clear_registry();
		assert!(node3d::destroy(root));
		assert!(node3d::destroy(other_root));
		assert!(node3d::destroy(light));
	}

	#[test]
	fn six_candidates_fill_four_direct_slots_and_overflow_sh() {
		clear_registry();
		let scene = SceneLights {
			directional: None,
			points: (1..=6)
				.map(|handle| PointLight {
					handle,
					position: Vec3::new(handle as f32 * 0.1, 0.0, 1.0),
					radiance: Vec3::ONE,
					range: 10.0,
				})
				.collect(),
		};
		let draw = prepare_draw(
			100,
			&Aabb {
				min: Vec3::splat(-0.5),
				max: Vec3::splat(0.5),
			},
			&scene,
		);
		assert_eq!(
			draw.point_position_range
				.iter()
				.filter(|light| light[3] > 0.0)
				.count(),
			4
		);
		assert!(draw
			.overflow_sh
			.iter()
			.flat_map(|coefficient| coefficient.iter().take(3))
			.any(|value| value.abs() > 0.0));
		remove_visual_selection(100);
	}
}
