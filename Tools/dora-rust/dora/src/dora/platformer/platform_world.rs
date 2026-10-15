/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

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
/// A struct representing a 2D platformer game world with physics simulations.
pub struct PlatformWorld { raw: i64 }
crate::dora_object!(PlatformWorld);
impl PlatformWorld {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { platformer_platformworld_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(PlatformWorld { raw: raw }))
			}
		})
	}
	/// Gets the camera used to control the view of the game world.
	pub fn get_camera(&self) -> crate::dora::platformer::PlatformCamera {
		return unsafe { crate::dora::platformer::PlatformCamera::from(platformer_platformworld_get_camera(self.raw())).unwrap() };
	}
	/// Moves a child node to a new order for a different layer.
	///
	/// # Arguments
	///
	/// * `child` - The child node to be moved.
	/// * `new_order` - The new order of the child node.
	pub fn move_child(&mut self, child: &dyn crate::dora::INode, new_order: i32) {
		unsafe { platformer_platformworld_move_child(self.raw(), child.raw(), new_order); }
	}
	/// Gets the layer node at a given order.
	///
	/// # Arguments
	///
	/// * `order` - The order of the layer node to get.
	///
	/// # Returns
	///
	/// * The layer node at the given order.
	pub fn get_layer(&mut self, order: i32) -> crate::dora::Node {
		unsafe { return crate::dora::Node::from(platformer_platformworld_get_layer(self.raw(), order)).unwrap(); }
	}
	/// Sets the parallax moving ratio for a given layer to simulate 3D projection effect.
	///
	/// # Arguments
	///
	/// * `order` - The order of the layer to set the ratio for.
	/// * `ratio` - The new parallax ratio for the layer.
	pub fn set_layer_ratio(&mut self, order: i32, ratio: &crate::dora::Vec2) {
		unsafe { platformer_platformworld_set_layer_ratio(self.raw(), order, ratio.into_i64()); }
	}
	/// Gets the parallax moving ratio for a given layer.
	///
	/// # Arguments
	///
	/// * `order` - The order of the layer to get the ratio for.
	///
	/// # Returns
	///
	/// * A `Vec2` representing the parallax ratio for the layer.
	pub fn get_layer_ratio(&mut self, order: i32) -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(platformer_platformworld_get_layer_ratio(self.raw(), order)); }
	}
	/// Sets the position offset for a given layer.
	///
	/// # Arguments
	///
	/// * `order` - The order of the layer to set the offset for.
	/// * `offset` - A `Vec2` representing the new position offset for the layer.
	pub fn set_layer_offset(&mut self, order: i32, offset: &crate::dora::Vec2) {
		unsafe { platformer_platformworld_set_layer_offset(self.raw(), order, offset.into_i64()); }
	}
	/// Gets the position offset for a given layer.
	///
	/// # Arguments
	///
	/// * `order` - The order of the layer to get the offset for.
	///
	/// # Returns
	///
	/// * A `Vec2` representing the position offset for the layer.
	pub fn get_layer_offset(&mut self, order: i32) -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(platformer_platformworld_get_layer_offset(self.raw(), order)); }
	}
	/// Swaps the positions of two layers.
	///
	/// # Arguments
	///
	/// * `order_a` - The order of the first layer to swap.
	/// * `order_b` - The order of the second layer to swap.
	pub fn swap_layer(&mut self, order_a: i32, order_b: i32) {
		unsafe { platformer_platformworld_swap_layer(self.raw(), order_a, order_b); }
	}
	/// Removes a layer from the game world.
	///
	/// # Arguments
	///
	/// * `order` - The order of the layer to remove.
	pub fn remove_layer(&mut self, order: i32) {
		unsafe { platformer_platformworld_remove_layer(self.raw(), order); }
	}
	/// Removes all layers from the game world.
	pub fn remove_all_layers(&mut self) {
		unsafe { platformer_platformworld_remove_all_layers(self.raw()); }
	}
	/// The method to create a new instance of `PlatformWorld`.
	///
	/// # Returns
	///
	/// * A new instance of `PlatformWorld`.
	pub fn new() -> PlatformWorld {
		unsafe { return PlatformWorld { raw: platformer_platformworld_new() }; }
	}
}