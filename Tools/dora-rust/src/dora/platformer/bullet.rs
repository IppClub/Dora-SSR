extern "C" {
	fn platformer_bullet_type() -> i32;
	fn platformer_bullet_set_target_allow(slf: i64, var: i32);
	fn platformer_bullet_get_target_allow(slf: i64) -> i32;
	fn platformer_bullet_is_face_right(slf: i64) -> i32;
	fn platformer_bullet_set_hit_stop(slf: i64, var: i32);
	fn platformer_bullet_is_hit_stop(slf: i64) -> i32;
	fn platformer_bullet_get_owner(slf: i64) -> i64;
	fn platformer_bullet_get_bullet_def(slf: i64) -> i64;
	fn platformer_bullet_set_face(slf: i64, var: i64);
	fn platformer_bullet_get_face(slf: i64) -> i64;
	fn platformer_bullet_destroy(slf: i64);
	fn platformer_bullet_new(def: i64, owner: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::IBody;
impl IBody for Bullet { }
use crate::dora::INode;
impl INode for Bullet { }
pub struct Bullet { raw: i64 }
crate::dora_object!(Bullet);
impl Bullet {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { platformer_bullet_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Bullet { raw: raw }))
			}
		})
	}
	pub fn set_target_allow(&mut self, var: i32) {
		unsafe { platformer_bullet_set_target_allow(self.raw(), var) };
	}
	pub fn get_target_allow(&self) -> i32 {
		return unsafe { platformer_bullet_get_target_allow(self.raw()) };
	}
	pub fn is_face_right(&self) -> bool {
		return unsafe { platformer_bullet_is_face_right(self.raw()) != 0 };
	}
	pub fn set_hit_stop(&mut self, var: bool) {
		unsafe { platformer_bullet_set_hit_stop(self.raw(), if var { 1 } else { 0 }) };
	}
	pub fn is_hit_stop(&self) -> bool {
		return unsafe { platformer_bullet_is_hit_stop(self.raw()) != 0 };
	}
	pub fn get_owner(&self) -> crate::dora::platformer::Unit {
		return unsafe { crate::dora::platformer::Unit::from(platformer_bullet_get_owner(self.raw())).unwrap() };
	}
	pub fn get_bullet_def(&self) -> crate::dora::platformer::BulletDef {
		return unsafe { crate::dora::platformer::BulletDef::from(platformer_bullet_get_bullet_def(self.raw())).unwrap() };
	}
	pub fn set_face(&mut self, var: &dyn crate::dora::INode) {
		unsafe { platformer_bullet_set_face(self.raw(), var.raw()) };
	}
	pub fn get_face(&self) -> crate::dora::Node {
		return unsafe { crate::dora::Node::from(platformer_bullet_get_face(self.raw())).unwrap() };
	}
	pub fn destroy(&mut self) {
		unsafe { platformer_bullet_destroy(self.raw()); }
	}
	pub fn new(def: &crate::dora::platformer::BulletDef, owner: &crate::dora::platformer::Unit) -> Bullet {
		unsafe { return Bullet { raw: platformer_bullet_new(def.raw(), owner.raw()) }; }
	}
}