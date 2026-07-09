use glam::{EulerRot, Mat4 as GlamMat4, Quat as GlamQuat, Vec3 as GlamVec3, Vec4 as GlamVec4};

pub type Vec3 = GlamVec3;
pub type Vec4 = GlamVec4;
pub type Mat4 = GlamMat4;
pub type Quaternion = GlamQuat;
pub type BgfxMat4 = [f32; 16];

#[derive(Debug, Clone, Copy)]
pub struct Aabb {
	pub min: Vec3,
	pub max: Vec3,
}

impl Aabb {
	pub fn empty() -> Self {
		Self {
			min: Vec3::splat(f32::INFINITY),
			max: Vec3::splat(f32::NEG_INFINITY),
		}
	}

	pub fn from_points(points: &[Vec3]) -> Self {
		let mut aabb = Self::empty();
		for point in points {
			aabb.include(*point);
		}
		if !aabb.is_valid() {
			Self::zero()
		} else {
			aabb
		}
	}

	pub fn zero() -> Self {
		Self {
			min: Vec3::ZERO,
			max: Vec3::ZERO,
		}
	}

	pub fn include(&mut self, point: Vec3) {
		self.min = self.min.min(point);
		self.max = self.max.max(point);
	}

	pub fn is_valid(&self) -> bool {
		self.min.x <= self.max.x && self.min.y <= self.max.y && self.min.z <= self.max.z
	}

	pub fn corners(&self) -> [Vec3; 8] {
		let min = self.min;
		let max = self.max;
		[
			Vec3::new(min.x, min.y, min.z),
			Vec3::new(max.x, min.y, min.z),
			Vec3::new(min.x, max.y, min.z),
			Vec3::new(max.x, max.y, min.z),
			Vec3::new(min.x, min.y, max.z),
			Vec3::new(max.x, min.y, max.z),
			Vec3::new(min.x, max.y, max.z),
			Vec3::new(max.x, max.y, max.z),
		]
	}
}

pub fn mat4_to_bgfx_array(matrix: &Mat4) -> BgfxMat4 {
	matrix.to_cols_array()
}

pub fn mat4_from_bgfx_array(matrix: &BgfxMat4) -> Mat4 {
	Mat4::from_cols_array(matrix)
}

pub fn quaternion_from_euler_deg(euler_deg: Vec3) -> Quaternion {
	Quaternion::from_euler(
		EulerRot::XYZ,
		euler_deg.x.to_radians(),
		euler_deg.y.to_radians(),
		euler_deg.z.to_radians(),
	)
}

pub fn euler_deg_from_quaternion(rotation: Quaternion) -> Vec3 {
	let (x, y, z) = rotation.to_euler(EulerRot::XYZ);
	Vec3::new(x.to_degrees(), y.to_degrees(), z.to_degrees())
}

pub fn transform_aabb(matrix: &Mat4, aabb: &Aabb) -> Aabb {
	let mut transformed = Aabb::empty();
	for corner in aabb.corners() {
		transformed.include(matrix.transform_point3(corner));
	}
	if transformed.is_valid() {
		transformed
	} else {
		Aabb::zero()
	}
}
