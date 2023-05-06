extern "C" {
	fn platformer_bulletdef_type() -> i32;
	fn platformer_bulletdef_set_tag(slf: i64, var: i64);
	fn platformer_bulletdef_get_tag(slf: i64) -> i64;
	fn platformer_bulletdef_set_end_effect(slf: i64, var: i64);
	fn platformer_bulletdef_get_end_effect(slf: i64) -> i64;
	fn platformer_bulletdef_set_life_time(slf: i64, var: f32);
	fn platformer_bulletdef_get_life_time(slf: i64) -> f32;
	fn platformer_bulletdef_set_damage_radius(slf: i64, var: f32);
	fn platformer_bulletdef_get_damage_radius(slf: i64) -> f32;
	fn platformer_bulletdef_set_high_speed_fix(slf: i64, var: i32);
	fn platformer_bulletdef_is_high_speed_fix(slf: i64) -> i32;
	fn platformer_bulletdef_set_gravity(slf: i64, var: i64);
	fn platformer_bulletdef_get_gravity(slf: i64) -> i64;
	fn platformer_bulletdef_set_face(slf: i64, var: i64);
	fn platformer_bulletdef_get_face(slf: i64) -> i64;
	fn platformer_bulletdef_get_body_def(slf: i64) -> i64;
	fn platformer_bulletdef_get_velocity(slf: i64) -> i64;
	fn platformer_bulletdef_set_as_circle(slf: i64, radius: f32);
	fn platformer_bulletdef_set_velocity(slf: i64, angle: f32, speed: f32);
	fn platformer_bulletdef_new() -> i64;
}
use crate::dora::IObject;
pub struct BulletDef { raw: i64 }
crate::dora_object!(BulletDef);
impl BulletDef {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { platformer_bulletdef_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(BulletDef { raw: raw }))
			}
		})
	}
	pub fn set_tag(&mut self, var: &str) {
		unsafe { platformer_bulletdef_set_tag(self.raw(), crate::dora::from_string(var)) };
	}
	pub fn get_tag(&self) -> String {
		return unsafe { crate::dora::to_string(platformer_bulletdef_get_tag(self.raw())) };
	}
	pub fn set_end_effect(&mut self, var: &str) {
		unsafe { platformer_bulletdef_set_end_effect(self.raw(), crate::dora::from_string(var)) };
	}
	pub fn get_end_effect(&self) -> String {
		return unsafe { crate::dora::to_string(platformer_bulletdef_get_end_effect(self.raw())) };
	}
	pub fn set_life_time(&mut self, var: f32) {
		unsafe { platformer_bulletdef_set_life_time(self.raw(), var) };
	}
	pub fn get_life_time(&self) -> f32 {
		return unsafe { platformer_bulletdef_get_life_time(self.raw()) };
	}
	pub fn set_damage_radius(&mut self, var: f32) {
		unsafe { platformer_bulletdef_set_damage_radius(self.raw(), var) };
	}
	pub fn get_damage_radius(&self) -> f32 {
		return unsafe { platformer_bulletdef_get_damage_radius(self.raw()) };
	}
	pub fn set_high_speed_fix(&mut self, var: bool) {
		unsafe { platformer_bulletdef_set_high_speed_fix(self.raw(), if var { 1 } else { 0 }) };
	}
	pub fn is_high_speed_fix(&self) -> bool {
		return unsafe { platformer_bulletdef_is_high_speed_fix(self.raw()) != 0 };
	}
	pub fn set_gravity(&mut self, var: &crate::dora::Vec2) {
		unsafe { platformer_bulletdef_set_gravity(self.raw(), var.into_i64()) };
	}
	pub fn get_gravity(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(platformer_bulletdef_get_gravity(self.raw())) };
	}
	pub fn set_face(&mut self, var: &crate::dora::platformer::Face) {
		unsafe { platformer_bulletdef_set_face(self.raw(), var.raw()) };
	}
	pub fn get_face(&self) -> crate::dora::platformer::Face {
		return unsafe { crate::dora::platformer::Face::from(platformer_bulletdef_get_face(self.raw())).unwrap() };
	}
	pub fn get_body_def(&self) -> crate::dora::BodyDef {
		return unsafe { crate::dora::BodyDef::from(platformer_bulletdef_get_body_def(self.raw())).unwrap() };
	}
	pub fn get_velocity(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(platformer_bulletdef_get_velocity(self.raw())) };
	}
	pub fn set_as_circle(&mut self, radius: f32) {
		unsafe { platformer_bulletdef_set_as_circle(self.raw(), radius); }
	}
	pub fn set_velocity(&mut self, angle: f32, speed: f32) {
		unsafe { platformer_bulletdef_set_velocity(self.raw(), angle, speed); }
	}
	pub fn new() -> BulletDef {
		unsafe { return BulletDef { raw: platformer_bulletdef_new() }; }
	}
}