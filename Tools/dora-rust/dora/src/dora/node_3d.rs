/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn node3d_type() -> i32;
	fn node3d_set_visible(slf: i64, val: i32);
	fn node3d_is_visible(slf: i64) -> i32;
	fn node3d_get_parent(slf: i64) -> i64;
	fn node3d_has_children(slf: i64) -> i32;
	fn node3d_set_position(slf: i64, val: i64);
	fn node3d_get_position(slf: i64) -> i64;
	fn node3d_set_scale(slf: i64, val: i64);
	fn node3d_get_scale(slf: i64) -> i64;
	fn node3d_set_euler_angles(slf: i64, val: i64);
	fn node3d_get_euler_angles(slf: i64) -> i64;
	fn node3d_set_x(slf: i64, val: f32);
	fn node3d_get_x(slf: i64) -> f32;
	fn node3d_set_y(slf: i64, val: f32);
	fn node3d_get_y(slf: i64) -> f32;
	fn node3d_set_z(slf: i64, val: f32);
	fn node3d_get_z(slf: i64) -> f32;
	fn node3d_set_angle_x(slf: i64, val: f32);
	fn node3d_get_angle_x(slf: i64) -> f32;
	fn node3d_set_angle_y(slf: i64, val: f32);
	fn node3d_get_angle_y(slf: i64) -> f32;
	fn node3d_set_angle_z(slf: i64, val: f32);
	fn node3d_get_angle_z(slf: i64) -> f32;
	fn node3d_set_scale_x(slf: i64, val: f32);
	fn node3d_get_scale_x(slf: i64) -> f32;
	fn node3d_set_scale_y(slf: i64, val: f32);
	fn node3d_get_scale_y(slf: i64) -> f32;
	fn node3d_set_scale_z(slf: i64, val: f32);
	fn node3d_get_scale_z(slf: i64) -> f32;
	fn node3d_add_child(slf: i64, child: i64);
	fn node3d_remove_child(slf: i64, child: i64, cleanup: i32);
	fn node3d_remove_all_children(slf: i64, cleanup: i32);
	fn node3d_remove_from_parent(slf: i64, cleanup: i32);
	fn node3d_cleanup(slf: i64);
	fn node3d_convert_to_world_space(slf: i64, local_point: i64) -> i64;
	fn node3d_convert_to_node_space(slf: i64, world_point: i64) -> i64;
	fn node3d_new() -> i64;
}
use crate::dora::IObject;
/// A 3D scene node with transform and hierarchy support.
pub struct Node3D { raw: i64 }
crate::dora_object!(Node3D);
impl INode3D for Node3D { }
pub trait INode3D: IObject {
	/// Sets whether the node is visible.
	fn set_visible(&mut self, val: bool) {
		unsafe { node3d_set_visible(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether the node is visible.
	fn is_visible(&self) -> bool {
		return unsafe { node3d_is_visible(self.raw()) != 0 };
	}
	/// Gets the parent 3D node.
	fn get_parent(&self) -> Option<crate::dora::Node3D> {
		return unsafe { crate::dora::Node3D::from(node3d_get_parent(self.raw())) };
	}
	/// Returns whether the node has child 3D nodes.
	fn has_children(&mut self) -> bool {
		unsafe { return node3d_has_children(self.raw()) != 0; }
	}
	/// Sets the node position in 3D space.
	fn set_position(&mut self, val: &crate::dora::Vec3) {
		unsafe { node3d_set_position(self.raw(), val.raw()) };
	}
	/// Gets the node position in 3D space.
	fn get_position(&self) -> crate::dora::Vec3 {
		return unsafe { crate::dora::Vec3::from(node3d_get_position(self.raw())) };
	}
	/// Sets the node scale in 3D space.
	fn set_scale(&mut self, val: &crate::dora::Vec3) {
		unsafe { node3d_set_scale(self.raw(), val.raw()) };
	}
	/// Gets the node scale in 3D space.
	fn get_scale(&self) -> crate::dora::Vec3 {
		return unsafe { crate::dora::Vec3::from(node3d_get_scale(self.raw())) };
	}
	/// Sets the node Euler angles in degrees.
	fn set_euler_angles(&mut self, val: &crate::dora::Vec3) {
		unsafe { node3d_set_euler_angles(self.raw(), val.raw()) };
	}
	/// Gets the node Euler angles in degrees.
	fn get_euler_angles(&self) -> crate::dora::Vec3 {
		return unsafe { crate::dora::Vec3::from(node3d_get_euler_angles(self.raw())) };
	}
	/// Sets the x-axis position of the node.
	fn set_x(&mut self, val: f32) {
		unsafe { node3d_set_x(self.raw(), val) };
	}
	/// Gets the x-axis position of the node.
	fn get_x(&self) -> f32 {
		return unsafe { node3d_get_x(self.raw()) };
	}
	/// Sets the y-axis position of the node.
	fn set_y(&mut self, val: f32) {
		unsafe { node3d_set_y(self.raw(), val) };
	}
	/// Gets the y-axis position of the node.
	fn get_y(&self) -> f32 {
		return unsafe { node3d_get_y(self.raw()) };
	}
	/// Sets the z-axis position of the node.
	fn set_z(&mut self, val: f32) {
		unsafe { node3d_set_z(self.raw(), val) };
	}
	/// Gets the z-axis position of the node.
	fn get_z(&self) -> f32 {
		return unsafe { node3d_get_z(self.raw()) };
	}
	/// Sets the x-axis Euler angle of the node in degrees.
	fn set_angle_x(&mut self, val: f32) {
		unsafe { node3d_set_angle_x(self.raw(), val) };
	}
	/// Gets the x-axis Euler angle of the node in degrees.
	fn get_angle_x(&self) -> f32 {
		return unsafe { node3d_get_angle_x(self.raw()) };
	}
	/// Sets the y-axis Euler angle of the node in degrees.
	fn set_angle_y(&mut self, val: f32) {
		unsafe { node3d_set_angle_y(self.raw(), val) };
	}
	/// Gets the y-axis Euler angle of the node in degrees.
	fn get_angle_y(&self) -> f32 {
		return unsafe { node3d_get_angle_y(self.raw()) };
	}
	/// Sets the z-axis Euler angle of the node in degrees.
	fn set_angle_z(&mut self, val: f32) {
		unsafe { node3d_set_angle_z(self.raw(), val) };
	}
	/// Gets the z-axis Euler angle of the node in degrees.
	fn get_angle_z(&self) -> f32 {
		return unsafe { node3d_get_angle_z(self.raw()) };
	}
	/// Sets the x-axis scale factor of the node.
	fn set_scale_x(&mut self, val: f32) {
		unsafe { node3d_set_scale_x(self.raw(), val) };
	}
	/// Gets the x-axis scale factor of the node.
	fn get_scale_x(&self) -> f32 {
		return unsafe { node3d_get_scale_x(self.raw()) };
	}
	/// Sets the y-axis scale factor of the node.
	fn set_scale_y(&mut self, val: f32) {
		unsafe { node3d_set_scale_y(self.raw(), val) };
	}
	/// Gets the y-axis scale factor of the node.
	fn get_scale_y(&self) -> f32 {
		return unsafe { node3d_get_scale_y(self.raw()) };
	}
	/// Sets the z-axis scale factor of the node.
	fn set_scale_z(&mut self, val: f32) {
		unsafe { node3d_set_scale_z(self.raw(), val) };
	}
	/// Gets the z-axis scale factor of the node.
	fn get_scale_z(&self) -> f32 {
		return unsafe { node3d_get_scale_z(self.raw()) };
	}
	/// Adds a child node to this node.
	fn add_child(&mut self, child: &dyn crate::dora::INode3D) {
		unsafe { node3d_add_child(self.raw(), child.raw()); }
	}
	/// Removes a child node from this node.
	fn remove_child(&mut self, child: &dyn crate::dora::INode3D, cleanup: bool) {
		unsafe { node3d_remove_child(self.raw(), child.raw(), if cleanup { 1 } else { 0 }); }
	}
	/// Removes all child nodes from this node.
	fn remove_all_children(&mut self, cleanup: bool) {
		unsafe { node3d_remove_all_children(self.raw(), if cleanup { 1 } else { 0 }); }
	}
	/// Removes this node from its parent.
	fn remove_from_parent(&mut self, cleanup: bool) {
		unsafe { node3d_remove_from_parent(self.raw(), if cleanup { 1 } else { 0 }); }
	}
	/// Cleans up this node and its children.
	fn cleanup(&mut self) {
		unsafe { node3d_cleanup(self.raw()); }
	}
	/// Converts a local point to world space.
	fn convert_to_world_space(&mut self, local_point: &crate::dora::Vec3) -> crate::dora::Vec3 {
		unsafe { return crate::dora::Vec3::from(node3d_convert_to_world_space(self.raw(), local_point.raw())); }
	}
	/// Converts a world point to local space.
	fn convert_to_node_space(&mut self, world_point: &crate::dora::Vec3) -> crate::dora::Vec3 {
		unsafe { return crate::dora::Vec3::from(node3d_convert_to_node_space(self.raw(), world_point.raw())); }
	}
}
impl Node3D {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { node3d_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Node3D { raw: raw }))
			}
		})
	}
	/// Creates a new 3D node.
	pub fn new() -> Node3D {
		unsafe { return Node3D { raw: node3d_new() }; }
	}
}