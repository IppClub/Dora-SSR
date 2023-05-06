extern "C" {
	fn platformer_platformworld_type() -> i32;
	fn platformer_platformworld_get_camera(slf: i64) -> i64;
	fn platformer_platformworld_move_child(slf: i64, child: i64, new_order: i32);
	fn platformer_platformworld_get_layer(slf: i64, order: i32) -> i64;
	fn platformer_platformworld_set_layer_ratio(slf: i64, order: i32, ratio: i64);
	fn platformer_platformworld_get_layer_ratio(slf: i64, order: i32) -> i64;
	fn platformer_platformworld_set_layer_offset(slf: i64, order: i32, offset: i64);
	fn platformer_platformworld_get_layer_offset(slf: i64, order: i32) -> i64;
	fn platformer_platformworld_swap_layer(slf: i64, order_a: i32, order_b: i32);
	fn platformer_platformworld_remove_layer(slf: i64, order: i32);
	fn platformer_platformworld_remove_all_layers(slf: i64);
	fn platformer_platformworld_new() -> i64;
}
use crate::dora::IObject;
use crate::dora::IPhysicsWorld;
impl IPhysicsWorld for PlatformWorld { }
use crate::dora::INode;
impl INode for PlatformWorld { }
pub struct PlatformWorld { raw: i64 }
crate::dora_object!(PlatformWorld);
impl PlatformWorld {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { platformer_platformworld_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(PlatformWorld { raw: raw }))
			}
		})
	}
	pub fn get_camera(&self) -> crate::dora::platformer::PlatformCamera {
		return unsafe { crate::dora::platformer::PlatformCamera::from(platformer_platformworld_get_camera(self.raw())).unwrap() };
	}
	pub fn move_child(&mut self, child: &dyn crate::dora::INode, new_order: i32) {
		unsafe { platformer_platformworld_move_child(self.raw(), child.raw(), new_order); }
	}
	pub fn get_layer(&mut self, order: i32) -> crate::dora::Node {
		unsafe { return crate::dora::Node::from(platformer_platformworld_get_layer(self.raw(), order)).unwrap(); }
	}
	pub fn set_layer_ratio(&mut self, order: i32, ratio: &crate::dora::Vec2) {
		unsafe { platformer_platformworld_set_layer_ratio(self.raw(), order, ratio.into_i64()); }
	}
	pub fn get_layer_ratio(&mut self, order: i32) -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(platformer_platformworld_get_layer_ratio(self.raw(), order)); }
	}
	pub fn set_layer_offset(&mut self, order: i32, offset: &crate::dora::Vec2) {
		unsafe { platformer_platformworld_set_layer_offset(self.raw(), order, offset.into_i64()); }
	}
	pub fn get_layer_offset(&mut self, order: i32) -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(platformer_platformworld_get_layer_offset(self.raw(), order)); }
	}
	pub fn swap_layer(&mut self, order_a: i32, order_b: i32) {
		unsafe { platformer_platformworld_swap_layer(self.raw(), order_a, order_b); }
	}
	pub fn remove_layer(&mut self, order: i32) {
		unsafe { platformer_platformworld_remove_layer(self.raw(), order); }
	}
	pub fn remove_all_layers(&mut self) {
		unsafe { platformer_platformworld_remove_all_layers(self.raw()); }
	}
	pub fn new() -> PlatformWorld {
		unsafe { return PlatformWorld { raw: platformer_platformworld_new() }; }
	}
}