extern "C" {
	fn playable_type() -> i32;
	fn playable_set_look(slf: i64, var: i64);
	fn playable_get_look(slf: i64) -> i64;
	fn playable_set_speed(slf: i64, var: f32);
	fn playable_get_speed(slf: i64) -> f32;
	fn playable_set_recovery(slf: i64, var: f32);
	fn playable_get_recovery(slf: i64) -> f32;
	fn playable_set_fliped(slf: i64, var: i32);
	fn playable_is_fliped(slf: i64) -> i32;
	fn playable_get_current(slf: i64) -> i64;
	fn playable_get_last_completed(slf: i64) -> i64;
	fn playable_get_key(slf: i64, name: i64) -> i64;
	fn playable_play(slf: i64, name: i64, looping: i32) -> f32;
	fn playable_stop(slf: i64);
	fn playable_set_slot(slf: i64, name: i64, item: i64);
	fn playable_get_slot(slf: i64, name: i64) -> i64;
	fn playable_new(filename: i64) -> i64;
}
use crate::dora::Object;
use crate::dora::INode;
impl INode for Playable { }
pub struct Playable { raw: i64 }
crate::dora_object!(Playable);
impl IPlayable for Playable { }
pub trait IPlayable: INode {
	fn set_look(&mut self, var: &str) {
		unsafe { playable_set_look(self.raw(), crate::dora::from_string(var)) };
	}
	fn get_look(&self) -> String {
		return unsafe { crate::dora::to_string(playable_get_look(self.raw())) };
	}
	fn set_speed(&mut self, var: f32) {
		unsafe { playable_set_speed(self.raw(), var) };
	}
	fn get_speed(&self) -> f32 {
		return unsafe { playable_get_speed(self.raw()) };
	}
	fn set_recovery(&mut self, var: f32) {
		unsafe { playable_set_recovery(self.raw(), var) };
	}
	fn get_recovery(&self) -> f32 {
		return unsafe { playable_get_recovery(self.raw()) };
	}
	fn set_fliped(&mut self, var: bool) {
		unsafe { playable_set_fliped(self.raw(), if var { 1 } else { 0 }) };
	}
	fn is_fliped(&self) -> bool {
		return unsafe { playable_is_fliped(self.raw()) != 0 };
	}
	fn get_current(&self) -> String {
		return unsafe { crate::dora::to_string(playable_get_current(self.raw())) };
	}
	fn get_last_completed(&self) -> String {
		return unsafe { crate::dora::to_string(playable_get_last_completed(self.raw())) };
	}
	fn get_key(&mut self, name: &str) -> crate::dora::Vec2 {
		return crate::dora::Vec2::from(unsafe { playable_get_key(self.raw(), crate::dora::from_string(name)) });
	}
	fn play(&mut self, name: &str, looping: bool) -> f32 {
		return unsafe { playable_play(self.raw(), crate::dora::from_string(name), if looping { 1 } else { 0 }) };
	}
	fn stop(&mut self) {
		unsafe { playable_stop(self.raw()) };
	}
	fn set_slot(&mut self, name: &str, item: &dyn crate::dora::INode) {
		unsafe { playable_set_slot(self.raw(), crate::dora::from_string(name), item.raw()) };
	}
	fn get_slot(&mut self, name: &str) -> Option<crate::dora::Node> {
		return crate::dora::Node::from(unsafe { playable_get_slot(self.raw(), crate::dora::from_string(name)) });
	}
}
impl Playable {
	pub fn new(filename: &str) -> Option<Playable> {
		return Playable::from(unsafe { playable_new(crate::dora::from_string(filename)) });
	}
}