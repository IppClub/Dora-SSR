extern "C" {
	fn bodydef_type() -> i32;
	fn bodydef_set_position(slf: i64, var: i64);
	fn bodydef_get_position(slf: i64) -> i64;
	fn bodydef_set_angle(slf: i64, var: f32);
	fn bodydef_get_angle(slf: i64) -> f32;
	fn bodydef_set_face(slf: i64, var: i64);
	fn bodydef_get_face(slf: i64) -> i64;
	fn bodydef_set_face_pos(slf: i64, var: i64);
	fn bodydef_get_face_pos(slf: i64) -> i64;
	fn bodydef_set_linear_damping(slf: i64, var: f32);
	fn bodydef_get_linear_damping(slf: i64) -> f32;
	fn bodydef_set_angular_damping(slf: i64, var: f32);
	fn bodydef_get_angular_damping(slf: i64) -> f32;
	fn bodydef_set_linear_acceleration(slf: i64, var: i64);
	fn bodydef_get_linear_acceleration(slf: i64) -> i64;
	fn bodydef_set_fixed_rotation(slf: i64, var: i32);
	fn bodydef_is_fixed_rotation(slf: i64) -> i32;
	fn bodydef_set_bullet(slf: i64, var: i32);
	fn bodydef_is_bullet(slf: i64) -> i32;
	fn bodydef_polygon_with_center(center: i64, width: f32, height: f32, angle: f32, density: f32, friction: f32, restitution: f32) -> i64;
	fn bodydef_polygon(width: f32, height: f32, density: f32, friction: f32, restitution: f32) -> i64;
	fn bodydef_polygon_with_vertices(vertices: i64, density: f32, friction: f32, restitution: f32) -> i64;
	fn bodydef_attach_polygon_center(slf: i64, center: i64, width: f32, height: f32, angle: f32, density: f32, friction: f32, restitution: f32);
	fn bodydef_attach_polygon(slf: i64, width: f32, height: f32, density: f32, friction: f32, restitution: f32);
	fn bodydef_attach_polygon_with_vertices(slf: i64, vertices: i64, density: f32, friction: f32, restitution: f32);
	fn bodydef_multi(vertices: i64, density: f32, friction: f32, restitution: f32) -> i64;
	fn bodydef_attach_multi(slf: i64, vertices: i64, density: f32, friction: f32, restitution: f32);
	fn bodydef_disk_with_center(center: i64, radius: f32, density: f32, friction: f32, restitution: f32) -> i64;
	fn bodydef_disk(radius: f32, density: f32, friction: f32, restitution: f32) -> i64;
	fn bodydef_attach_disk_with_center(slf: i64, center: i64, radius: f32, density: f32, friction: f32, restitution: f32);
	fn bodydef_attach_disk(slf: i64, radius: f32, density: f32, friction: f32, restitution: f32);
	fn bodydef_chain(vertices: i64, friction: f32, restitution: f32) -> i64;
	fn bodydef_attach_chain(slf: i64, vertices: i64, friction: f32, restitution: f32);
	fn bodydef_attach_polygon_sensor(slf: i64, tag: i32, width: f32, height: f32);
	fn bodydef_attach_polygon_sensor_with_center(slf: i64, tag: i32, center: i64, width: f32, height: f32, angle: f32);
	fn bodydef_attach_polygon_sensor_with_vertices(slf: i64, tag: i32, vertices: i64);
	fn bodydef_attach_disk_sensor_with_center(slf: i64, tag: i32, center: i64, radius: f32);
	fn bodydef_attach_disk_sensor(slf: i64, tag: i32, radius: f32);
	fn bodydef_new() -> i64;
}
use crate::dora::IObject;
pub struct BodyDef { raw: i64 }
crate::dora_object!(BodyDef);
impl BodyDef {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { bodydef_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(BodyDef { raw: raw }))
			}
		})
	}
	pub fn set_position(&mut self, var: &crate::dora::Vec2) {
		unsafe { bodydef_set_position(self.raw(), var.into_i64()) };
	}
	pub fn get_position(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(bodydef_get_position(self.raw())) };
	}
	pub fn set_angle(&mut self, var: f32) {
		unsafe { bodydef_set_angle(self.raw(), var) };
	}
	pub fn get_angle(&self) -> f32 {
		return unsafe { bodydef_get_angle(self.raw()) };
	}
	pub fn set_face(&mut self, var: &str) {
		unsafe { bodydef_set_face(self.raw(), crate::dora::from_string(var)) };
	}
	pub fn get_face(&self) -> String {
		return unsafe { crate::dora::to_string(bodydef_get_face(self.raw())) };
	}
	pub fn set_face_pos(&mut self, var: &crate::dora::Vec2) {
		unsafe { bodydef_set_face_pos(self.raw(), var.into_i64()) };
	}
	pub fn get_face_pos(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(bodydef_get_face_pos(self.raw())) };
	}
	pub fn set_linear_damping(&mut self, var: f32) {
		unsafe { bodydef_set_linear_damping(self.raw(), var) };
	}
	pub fn get_linear_damping(&self) -> f32 {
		return unsafe { bodydef_get_linear_damping(self.raw()) };
	}
	pub fn set_angular_damping(&mut self, var: f32) {
		unsafe { bodydef_set_angular_damping(self.raw(), var) };
	}
	pub fn get_angular_damping(&self) -> f32 {
		return unsafe { bodydef_get_angular_damping(self.raw()) };
	}
	pub fn set_linear_acceleration(&mut self, var: &crate::dora::Vec2) {
		unsafe { bodydef_set_linear_acceleration(self.raw(), var.into_i64()) };
	}
	pub fn get_linear_acceleration(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(bodydef_get_linear_acceleration(self.raw())) };
	}
	pub fn set_fixed_rotation(&mut self, var: bool) {
		unsafe { bodydef_set_fixed_rotation(self.raw(), if var { 1 } else { 0 }) };
	}
	pub fn is_fixed_rotation(&self) -> bool {
		return unsafe { bodydef_is_fixed_rotation(self.raw()) != 0 };
	}
	pub fn set_bullet(&mut self, var: bool) {
		unsafe { bodydef_set_bullet(self.raw(), if var { 1 } else { 0 }) };
	}
	pub fn is_bullet(&self) -> bool {
		return unsafe { bodydef_is_bullet(self.raw()) != 0 };
	}
	pub fn polygon_with_center(center: &crate::dora::Vec2, width: f32, height: f32, angle: f32, density: f32, friction: f32, restitution: f32) -> crate::dora::FixtureDef {
		unsafe { return crate::dora::FixtureDef::from(bodydef_polygon_with_center(center.into_i64(), width, height, angle, density, friction, restitution)).unwrap(); }
	}
	pub fn polygon(width: f32, height: f32, density: f32, friction: f32, restitution: f32) -> crate::dora::FixtureDef {
		unsafe { return crate::dora::FixtureDef::from(bodydef_polygon(width, height, density, friction, restitution)).unwrap(); }
	}
	pub fn polygon_with_vertices(vertices: &Vec<crate::dora::Vec2>, density: f32, friction: f32, restitution: f32) -> crate::dora::FixtureDef {
		unsafe { return crate::dora::FixtureDef::from(bodydef_polygon_with_vertices(crate::dora::Vector::from_vec2(vertices), density, friction, restitution)).unwrap(); }
	}
	pub fn attach_polygon_center(&mut self, center: &crate::dora::Vec2, width: f32, height: f32, angle: f32, density: f32, friction: f32, restitution: f32) {
		unsafe { bodydef_attach_polygon_center(self.raw(), center.into_i64(), width, height, angle, density, friction, restitution); }
	}
	pub fn attach_polygon(&mut self, width: f32, height: f32, density: f32, friction: f32, restitution: f32) {
		unsafe { bodydef_attach_polygon(self.raw(), width, height, density, friction, restitution); }
	}
	pub fn attach_polygon_with_vertices(&mut self, vertices: &Vec<crate::dora::Vec2>, density: f32, friction: f32, restitution: f32) {
		unsafe { bodydef_attach_polygon_with_vertices(self.raw(), crate::dora::Vector::from_vec2(vertices), density, friction, restitution); }
	}
	pub fn multi(vertices: &Vec<crate::dora::Vec2>, density: f32, friction: f32, restitution: f32) -> crate::dora::FixtureDef {
		unsafe { return crate::dora::FixtureDef::from(bodydef_multi(crate::dora::Vector::from_vec2(vertices), density, friction, restitution)).unwrap(); }
	}
	pub fn attach_multi(&mut self, vertices: &Vec<crate::dora::Vec2>, density: f32, friction: f32, restitution: f32) {
		unsafe { bodydef_attach_multi(self.raw(), crate::dora::Vector::from_vec2(vertices), density, friction, restitution); }
	}
	pub fn disk_with_center(center: &crate::dora::Vec2, radius: f32, density: f32, friction: f32, restitution: f32) -> crate::dora::FixtureDef {
		unsafe { return crate::dora::FixtureDef::from(bodydef_disk_with_center(center.into_i64(), radius, density, friction, restitution)).unwrap(); }
	}
	pub fn disk(radius: f32, density: f32, friction: f32, restitution: f32) -> crate::dora::FixtureDef {
		unsafe { return crate::dora::FixtureDef::from(bodydef_disk(radius, density, friction, restitution)).unwrap(); }
	}
	pub fn attach_disk_with_center(&mut self, center: &crate::dora::Vec2, radius: f32, density: f32, friction: f32, restitution: f32) {
		unsafe { bodydef_attach_disk_with_center(self.raw(), center.into_i64(), radius, density, friction, restitution); }
	}
	pub fn attach_disk(&mut self, radius: f32, density: f32, friction: f32, restitution: f32) {
		unsafe { bodydef_attach_disk(self.raw(), radius, density, friction, restitution); }
	}
	pub fn chain(vertices: &Vec<crate::dora::Vec2>, friction: f32, restitution: f32) -> crate::dora::FixtureDef {
		unsafe { return crate::dora::FixtureDef::from(bodydef_chain(crate::dora::Vector::from_vec2(vertices), friction, restitution)).unwrap(); }
	}
	pub fn attach_chain(&mut self, vertices: &Vec<crate::dora::Vec2>, friction: f32, restitution: f32) {
		unsafe { bodydef_attach_chain(self.raw(), crate::dora::Vector::from_vec2(vertices), friction, restitution); }
	}
	pub fn attach_polygon_sensor(&mut self, tag: i32, width: f32, height: f32) {
		unsafe { bodydef_attach_polygon_sensor(self.raw(), tag, width, height); }
	}
	pub fn attach_polygon_sensor_with_center(&mut self, tag: i32, center: &crate::dora::Vec2, width: f32, height: f32, angle: f32) {
		unsafe { bodydef_attach_polygon_sensor_with_center(self.raw(), tag, center.into_i64(), width, height, angle); }
	}
	pub fn attach_polygon_sensor_with_vertices(&mut self, tag: i32, vertices: &Vec<crate::dora::Vec2>) {
		unsafe { bodydef_attach_polygon_sensor_with_vertices(self.raw(), tag, crate::dora::Vector::from_vec2(vertices)); }
	}
	pub fn attach_disk_sensor_with_center(&mut self, tag: i32, center: &crate::dora::Vec2, radius: f32) {
		unsafe { bodydef_attach_disk_sensor_with_center(self.raw(), tag, center.into_i64(), radius); }
	}
	pub fn attach_disk_sensor(&mut self, tag: i32, radius: f32) {
		unsafe { bodydef_attach_disk_sensor(self.raw(), tag, radius); }
	}
	pub fn new() -> BodyDef {
		unsafe { return BodyDef { raw: bodydef_new() }; }
	}
}