extern "C" {
	fn platformer_visual_type() -> i32;
	fn platformer_visual_is_playing(slf: i64) -> i32;
	fn platformer_visual_start(slf: i64);
	fn platformer_visual_stop(slf: i64);
	fn platformer_visual_auto_remove(slf: i64) -> i64;
	fn platformer_visual_new(name: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::INode;
impl INode for Visual { }
pub struct Visual { raw: i64 }
crate::dora_object!(Visual);
impl Visual {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { platformer_visual_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Visual { raw: raw }))
			}
		})
	}
	pub fn is_playing(&self) -> bool {
		return unsafe { platformer_visual_is_playing(self.raw()) != 0 };
	}
	pub fn start(&mut self) {
		unsafe { platformer_visual_start(self.raw()); }
	}
	pub fn stop(&mut self) {
		unsafe { platformer_visual_stop(self.raw()); }
	}
	pub fn auto_remove(&mut self) -> crate::dora::platformer::Visual {
		unsafe { return crate::dora::platformer::Visual::from(platformer_visual_auto_remove(self.raw())).unwrap(); }
	}
	pub fn new(name: &str) -> Visual {
		unsafe { return Visual { raw: platformer_visual_new(crate::dora::from_string(name)) }; }
	}
}