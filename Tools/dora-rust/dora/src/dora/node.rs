/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn node_type() -> i32;
	fn node_set_order(slf: i64, val: i32);
	fn node_get_order(slf: i64) -> i32;
	fn node_set_angle(slf: i64, val: f32);
	fn node_get_angle(slf: i64) -> f32;
	fn node_set_angle_x(slf: i64, val: f32);
	fn node_get_angle_x(slf: i64) -> f32;
	fn node_set_angle_y(slf: i64, val: f32);
	fn node_get_angle_y(slf: i64) -> f32;
	fn node_set_scale_x(slf: i64, val: f32);
	fn node_get_scale_x(slf: i64) -> f32;
	fn node_set_scale_y(slf: i64, val: f32);
	fn node_get_scale_y(slf: i64) -> f32;
	fn node_set_x(slf: i64, val: f32);
	fn node_get_x(slf: i64) -> f32;
	fn node_set_y(slf: i64, val: f32);
	fn node_get_y(slf: i64) -> f32;
	fn node_set_z(slf: i64, val: f32);
	fn node_get_z(slf: i64) -> f32;
	fn node_set_position(slf: i64, val: i64);
	fn node_get_position(slf: i64) -> i64;
	fn node_set_skew_x(slf: i64, val: f32);
	fn node_get_skew_x(slf: i64) -> f32;
	fn node_set_skew_y(slf: i64, val: f32);
	fn node_get_skew_y(slf: i64) -> f32;
	fn node_set_visible(slf: i64, val: i32);
	fn node_is_visible(slf: i64) -> i32;
	fn node_set_anchor(slf: i64, val: i64);
	fn node_get_anchor(slf: i64) -> i64;
	fn node_set_width(slf: i64, val: f32);
	fn node_get_width(slf: i64) -> f32;
	fn node_set_height(slf: i64, val: f32);
	fn node_get_height(slf: i64) -> f32;
	fn node_set_size(slf: i64, val: i64);
	fn node_get_size(slf: i64) -> i64;
	fn node_set_tag(slf: i64, val: i64);
	fn node_get_tag(slf: i64) -> i64;
	fn node_set_opacity(slf: i64, val: f32);
	fn node_get_opacity(slf: i64) -> f32;
	fn node_set_color(slf: i64, val: i32);
	fn node_get_color(slf: i64) -> i32;
	fn node_set_color3(slf: i64, val: i32);
	fn node_get_color3(slf: i64) -> i32;
	fn node_set_pass_opacity(slf: i64, val: i32);
	fn node_is_pass_opacity(slf: i64) -> i32;
	fn node_set_pass_color3(slf: i64, val: i32);
	fn node_is_pass_color3(slf: i64) -> i32;
	fn node_set_transform_target(slf: i64, val: i64);
	fn node_get_transform_target(slf: i64) -> i64;
	fn node_set_scheduler(slf: i64, val: i64);
	fn node_get_scheduler(slf: i64) -> i64;
	fn node_get_children(slf: i64) -> i64;
	fn node_get_parent(slf: i64) -> i64;
	fn node_is_running(slf: i64) -> i32;
	fn node_is_scheduled(slf: i64) -> i32;
	fn node_get_action_count(slf: i64) -> i32;
	fn node_get_data(slf: i64) -> i64;
	fn node_set_touch_enabled(slf: i64, val: i32);
	fn node_is_touch_enabled(slf: i64) -> i32;
	fn node_set_swallow_touches(slf: i64, val: i32);
	fn node_is_swallow_touches(slf: i64) -> i32;
	fn node_set_swallow_mouse_wheel(slf: i64, val: i32);
	fn node_is_swallow_mouse_wheel(slf: i64) -> i32;
	fn node_set_keyboard_enabled(slf: i64, val: i32);
	fn node_is_keyboard_enabled(slf: i64) -> i32;
	fn node_set_controller_enabled(slf: i64, val: i32);
	fn node_is_controller_enabled(slf: i64) -> i32;
	fn node_set_render_group(slf: i64, val: i32);
	fn node_is_render_group(slf: i64) -> i32;
	fn node_set_show_debug(slf: i64, val: i32);
	fn node_is_show_debug(slf: i64) -> i32;
	fn node_set_render_order(slf: i64, val: i32);
	fn node_get_render_order(slf: i64) -> i32;
	fn node_add_child_with_order_tag(slf: i64, child: i64, order: i32, tag: i64);
	fn node_add_child_with_order(slf: i64, child: i64, order: i32);
	fn node_add_child(slf: i64, child: i64);
	fn node_add_to_with_order_tag(slf: i64, parent: i64, order: i32, tag: i64) -> i64;
	fn node_add_to_with_order(slf: i64, parent: i64, order: i32) -> i64;
	fn node_add_to(slf: i64, parent: i64) -> i64;
	fn node_remove_child(slf: i64, child: i64, cleanup: i32);
	fn node_remove_child_by_tag(slf: i64, tag: i64, cleanup: i32);
	fn node_remove_all_children(slf: i64, cleanup: i32);
	fn node_remove_from_parent(slf: i64, cleanup: i32);
	fn node_move_to_parent(slf: i64, parent: i64);
	fn node_cleanup(slf: i64);
	fn node_get_child_by_tag(slf: i64, tag: i64) -> i64;
	fn node_schedule(slf: i64, func0: i32, stack0: i64);
	fn node_unschedule(slf: i64);
	fn node_convert_to_node_space(slf: i64, world_point: i64) -> i64;
	fn node_convert_to_world_space(slf: i64, node_point: i64) -> i64;
	fn node_convert_to_window_space(slf: i64, node_point: i64, func0: i32, stack0: i64);
	fn node_each_child(slf: i64, func0: i32, stack0: i64) -> i32;
	fn node_traverse(slf: i64, func0: i32, stack0: i64) -> i32;
	fn node_traverse_all(slf: i64, func0: i32, stack0: i64) -> i32;
	fn node_run_action_def(slf: i64, def: i64, looped: i32) -> f32;
	fn node_run_action(slf: i64, action: i64, looped: i32) -> f32;
	fn node_stop_all_actions(slf: i64);
	fn node_perform_def(slf: i64, action_def: i64, looped: i32) -> f32;
	fn node_perform(slf: i64, action: i64, looped: i32) -> f32;
	fn node_stop_action(slf: i64, action: i64);
	fn node_align_items_vertically(slf: i64, padding: f32) -> i64;
	fn node_align_items_vertically_with_size(slf: i64, size: i64, padding: f32) -> i64;
	fn node_align_items_horizontally(slf: i64, padding: f32) -> i64;
	fn node_align_items_horizontally_with_size(slf: i64, size: i64, padding: f32) -> i64;
	fn node_align_items(slf: i64, padding: f32) -> i64;
	fn node_align_items_with_size(slf: i64, size: i64, padding: f32) -> i64;
	fn node_move_and_cull_items(slf: i64, delta: i64);
	fn node_attach_ime(slf: i64);
	fn node_detach_ime(slf: i64);
	fn node_grab(slf: i64) -> i64;
	fn node_grab_with_size(slf: i64, grid_x: i32, grid_y: i32) -> i64;
	fn node_stop_grab(slf: i64);
	fn node_set_transform_target_null(slf: i64);
	fn node_slot(slf: i64, event_name: i64, func0: i32, stack0: i64);
	fn node_gslot(slf: i64, event_name: i64, func0: i32, stack0: i64);
	fn node_emit(slf: i64, name: i64, stack: i64);
	fn node_on_update(slf: i64, func0: i32, stack0: i64);
	fn node_on_render(slf: i64, func0: i32, stack0: i64);
	fn node_new() -> i64;
}
use crate::dora::IObject;
/// Struct used for building a hierarchical tree structure of game objects.
pub struct Node { raw: i64 }
crate::dora_object!(Node);
impl INode for Node { }
pub trait INode: IObject {
	/// Sets the order of the node in the parent's children array.
	fn set_order(&mut self, val: i32) {
		unsafe { node_set_order(self.raw(), val) };
	}
	/// Gets the order of the node in the parent's children array.
	fn get_order(&self) -> i32 {
		return unsafe { node_get_order(self.raw()) };
	}
	/// Sets the rotation angle of the node in degrees.
	fn set_angle(&mut self, val: f32) {
		unsafe { node_set_angle(self.raw(), val) };
	}
	/// Gets the rotation angle of the node in degrees.
	fn get_angle(&self) -> f32 {
		return unsafe { node_get_angle(self.raw()) };
	}
	/// Sets the X-axis rotation angle of the node in degrees.
	fn set_angle_x(&mut self, val: f32) {
		unsafe { node_set_angle_x(self.raw(), val) };
	}
	/// Gets the X-axis rotation angle of the node in degrees.
	fn get_angle_x(&self) -> f32 {
		return unsafe { node_get_angle_x(self.raw()) };
	}
	/// Sets the Y-axis rotation angle of the node in degrees.
	fn set_angle_y(&mut self, val: f32) {
		unsafe { node_set_angle_y(self.raw(), val) };
	}
	/// Gets the Y-axis rotation angle of the node in degrees.
	fn get_angle_y(&self) -> f32 {
		return unsafe { node_get_angle_y(self.raw()) };
	}
	/// Sets the X-axis scale factor of the node.
	fn set_scale_x(&mut self, val: f32) {
		unsafe { node_set_scale_x(self.raw(), val) };
	}
	/// Gets the X-axis scale factor of the node.
	fn get_scale_x(&self) -> f32 {
		return unsafe { node_get_scale_x(self.raw()) };
	}
	/// Sets the Y-axis scale factor of the node.
	fn set_scale_y(&mut self, val: f32) {
		unsafe { node_set_scale_y(self.raw(), val) };
	}
	/// Gets the Y-axis scale factor of the node.
	fn get_scale_y(&self) -> f32 {
		return unsafe { node_get_scale_y(self.raw()) };
	}
	/// Sets the X-axis position of the node.
	fn set_x(&mut self, val: f32) {
		unsafe { node_set_x(self.raw(), val) };
	}
	/// Gets the X-axis position of the node.
	fn get_x(&self) -> f32 {
		return unsafe { node_get_x(self.raw()) };
	}
	/// Sets the Y-axis position of the node.
	fn set_y(&mut self, val: f32) {
		unsafe { node_set_y(self.raw(), val) };
	}
	/// Gets the Y-axis position of the node.
	fn get_y(&self) -> f32 {
		return unsafe { node_get_y(self.raw()) };
	}
	/// Sets the Z-axis position of the node.
	fn set_z(&mut self, val: f32) {
		unsafe { node_set_z(self.raw(), val) };
	}
	/// Gets the Z-axis position of the node.
	fn get_z(&self) -> f32 {
		return unsafe { node_get_z(self.raw()) };
	}
	/// Sets the position of the node as a Vec2 object.
	fn set_position(&mut self, val: &crate::dora::Vec2) {
		unsafe { node_set_position(self.raw(), val.into_i64()) };
	}
	/// Gets the position of the node as a Vec2 object.
	fn get_position(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(node_get_position(self.raw())) };
	}
	/// Sets the X-axis skew angle of the node in degrees.
	fn set_skew_x(&mut self, val: f32) {
		unsafe { node_set_skew_x(self.raw(), val) };
	}
	/// Gets the X-axis skew angle of the node in degrees.
	fn get_skew_x(&self) -> f32 {
		return unsafe { node_get_skew_x(self.raw()) };
	}
	/// Sets the Y-axis skew angle of the node in degrees.
	fn set_skew_y(&mut self, val: f32) {
		unsafe { node_set_skew_y(self.raw(), val) };
	}
	/// Gets the Y-axis skew angle of the node in degrees.
	fn get_skew_y(&self) -> f32 {
		return unsafe { node_get_skew_y(self.raw()) };
	}
	/// Sets whether the node is visible.
	fn set_visible(&mut self, val: bool) {
		unsafe { node_set_visible(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether the node is visible.
	fn is_visible(&self) -> bool {
		return unsafe { node_is_visible(self.raw()) != 0 };
	}
	/// Sets the anchor point of the node as a Vec2 object.
	fn set_anchor(&mut self, val: &crate::dora::Vec2) {
		unsafe { node_set_anchor(self.raw(), val.into_i64()) };
	}
	/// Gets the anchor point of the node as a Vec2 object.
	fn get_anchor(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(node_get_anchor(self.raw())) };
	}
	/// Sets the width of the node.
	fn set_width(&mut self, val: f32) {
		unsafe { node_set_width(self.raw(), val) };
	}
	/// Gets the width of the node.
	fn get_width(&self) -> f32 {
		return unsafe { node_get_width(self.raw()) };
	}
	/// Sets the height of the node.
	fn set_height(&mut self, val: f32) {
		unsafe { node_set_height(self.raw(), val) };
	}
	/// Gets the height of the node.
	fn get_height(&self) -> f32 {
		return unsafe { node_get_height(self.raw()) };
	}
	/// Sets the size of the node as a Size object.
	fn set_size(&mut self, val: &crate::dora::Size) {
		unsafe { node_set_size(self.raw(), val.into_i64()) };
	}
	/// Gets the size of the node as a Size object.
	fn get_size(&self) -> crate::dora::Size {
		return unsafe { crate::dora::Size::from(node_get_size(self.raw())) };
	}
	/// Sets the tag of the node as a string.
	fn set_tag(&mut self, val: &str) {
		unsafe { node_set_tag(self.raw(), crate::dora::from_string(val)) };
	}
	/// Gets the tag of the node as a string.
	fn get_tag(&self) -> String {
		return unsafe { crate::dora::to_string(node_get_tag(self.raw())) };
	}
	/// Sets the opacity of the node, should be 0 to 1.0.
	fn set_opacity(&mut self, val: f32) {
		unsafe { node_set_opacity(self.raw(), val) };
	}
	/// Gets the opacity of the node, should be 0 to 1.0.
	fn get_opacity(&self) -> f32 {
		return unsafe { node_get_opacity(self.raw()) };
	}
	/// Sets the color of the node as a Color object.
	fn set_color(&mut self, val: &crate::dora::Color) {
		unsafe { node_set_color(self.raw(), val.to_argb() as i32) };
	}
	/// Gets the color of the node as a Color object.
	fn get_color(&self) -> crate::dora::Color {
		return unsafe { crate::dora::Color::from(node_get_color(self.raw())) };
	}
	/// Sets the color of the node as a Color3 object.
	fn set_color3(&mut self, val: &crate::dora::Color3) {
		unsafe { node_set_color3(self.raw(), val.to_rgb() as i32) };
	}
	/// Gets the color of the node as a Color3 object.
	fn get_color3(&self) -> crate::dora::Color3 {
		return unsafe { crate::dora::Color3::from(node_get_color3(self.raw())) };
	}
	/// Sets whether to pass the opacity value to child nodes.
	fn set_pass_opacity(&mut self, val: bool) {
		unsafe { node_set_pass_opacity(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether to pass the opacity value to child nodes.
	fn is_pass_opacity(&self) -> bool {
		return unsafe { node_is_pass_opacity(self.raw()) != 0 };
	}
	/// Sets whether to pass the color value to child nodes.
	fn set_pass_color3(&mut self, val: bool) {
		unsafe { node_set_pass_color3(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether to pass the color value to child nodes.
	fn is_pass_color3(&self) -> bool {
		return unsafe { node_is_pass_color3(self.raw()) != 0 };
	}
	/// Sets the target node acts as a parent node for transforming this node.
	fn set_transform_target(&mut self, val: &dyn crate::dora::INode) {
		unsafe { node_set_transform_target(self.raw(), val.raw()) };
	}
	/// Gets the target node acts as a parent node for transforming this node.
	fn get_transform_target(&self) -> Option<crate::dora::Node> {
		return unsafe { crate::dora::Node::from(node_get_transform_target(self.raw())) };
	}
	/// Sets the scheduler used for scheduling update and action callbacks.
	fn set_scheduler(&mut self, val: &crate::dora::Scheduler) {
		unsafe { node_set_scheduler(self.raw(), val.raw()) };
	}
	/// Gets the scheduler used for scheduling update and action callbacks.
	fn get_scheduler(&self) -> crate::dora::Scheduler {
		return unsafe { crate::dora::Scheduler::from(node_get_scheduler(self.raw())).unwrap() };
	}
	/// Gets the children of the node as an Array object, could be None.
	fn get_children(&self) -> Option<crate::dora::Array> {
		return unsafe { crate::dora::Array::from(node_get_children(self.raw())) };
	}
	/// Gets the parent of the node, could be None.
	fn get_parent(&self) -> Option<crate::dora::Node> {
		return unsafe { crate::dora::Node::from(node_get_parent(self.raw())) };
	}
	/// Gets whether the node is currently running in a scene tree.
	fn is_running(&self) -> bool {
		return unsafe { node_is_running(self.raw()) != 0 };
	}
	/// Gets whether the node is currently scheduling a function for updates.
	fn is_scheduled(&self) -> bool {
		return unsafe { node_is_scheduled(self.raw()) != 0 };
	}
	/// Gets the number of actions currently running on the node.
	fn get_action_count(&self) -> i32 {
		return unsafe { node_get_action_count(self.raw()) };
	}
	/// Gets additional data stored on the node as a Dictionary object.
	fn get_data(&self) -> crate::dora::Dictionary {
		return unsafe { crate::dora::Dictionary::from(node_get_data(self.raw())).unwrap() };
	}
	/// Sets whether touch events are enabled on the node.
	fn set_touch_enabled(&mut self, val: bool) {
		unsafe { node_set_touch_enabled(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether touch events are enabled on the node.
	fn is_touch_enabled(&self) -> bool {
		return unsafe { node_is_touch_enabled(self.raw()) != 0 };
	}
	/// Sets whether the node should swallow touch events.
	fn set_swallow_touches(&mut self, val: bool) {
		unsafe { node_set_swallow_touches(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether the node should swallow touch events.
	fn is_swallow_touches(&self) -> bool {
		return unsafe { node_is_swallow_touches(self.raw()) != 0 };
	}
	/// Sets whether the node should swallow mouse wheel events.
	fn set_swallow_mouse_wheel(&mut self, val: bool) {
		unsafe { node_set_swallow_mouse_wheel(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether the node should swallow mouse wheel events.
	fn is_swallow_mouse_wheel(&self) -> bool {
		return unsafe { node_is_swallow_mouse_wheel(self.raw()) != 0 };
	}
	/// Sets whether keyboard events are enabled on the node.
	fn set_keyboard_enabled(&mut self, val: bool) {
		unsafe { node_set_keyboard_enabled(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether keyboard events are enabled on the node.
	fn is_keyboard_enabled(&self) -> bool {
		return unsafe { node_is_keyboard_enabled(self.raw()) != 0 };
	}
	/// Sets whether controller events are enabled on the node.
	fn set_controller_enabled(&mut self, val: bool) {
		unsafe { node_set_controller_enabled(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether controller events are enabled on the node.
	fn is_controller_enabled(&self) -> bool {
		return unsafe { node_is_controller_enabled(self.raw()) != 0 };
	}
	/// Sets whether to group the node's rendering with all its recursive children.
	fn set_render_group(&mut self, val: bool) {
		unsafe { node_set_render_group(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether to group the node's rendering with all its recursive children.
	fn is_render_group(&self) -> bool {
		return unsafe { node_is_render_group(self.raw()) != 0 };
	}
	/// Sets whether debug graphic should be displayed for the node.
	fn set_show_debug(&mut self, val: bool) {
		unsafe { node_set_show_debug(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether debug graphic should be displayed for the node.
	fn is_show_debug(&self) -> bool {
		return unsafe { node_is_show_debug(self.raw()) != 0 };
	}
	/// Sets the rendering order number for group rendering. Nodes with lower rendering orders are rendered earlier.
	fn set_render_order(&mut self, val: i32) {
		unsafe { node_set_render_order(self.raw(), val) };
	}
	/// Gets the rendering order number for group rendering. Nodes with lower rendering orders are rendered earlier.
	fn get_render_order(&self) -> i32 {
		return unsafe { node_get_render_order(self.raw()) };
	}
	/// Adds a child node to the current node.
	///
	/// # Arguments
	///
	/// * `child` - The child node to add.
	/// * `order` - The drawing order of the child node.
	/// * `tag` - The tag of the child node.
	fn add_child_with_order_tag(&mut self, child: &dyn crate::dora::INode, order: i32, tag: &str) {
		unsafe { node_add_child_with_order_tag(self.raw(), child.raw(), order, crate::dora::from_string(tag)); }
	}
	/// Adds a child node to the current node.
	///
	/// # Arguments
	///
	/// * `child` - The child node to add.
	/// * `order` - The drawing order of the child node.
	fn add_child_with_order(&mut self, child: &dyn crate::dora::INode, order: i32) {
		unsafe { node_add_child_with_order(self.raw(), child.raw(), order); }
	}
	/// Adds a child node to the current node.
	///
	/// # Arguments
	///
	/// * `child` - The child node to add.
	fn add_child(&mut self, child: &dyn crate::dora::INode) {
		unsafe { node_add_child(self.raw(), child.raw()); }
	}
	/// Adds the current node to a parent node.
	///
	/// # Arguments
	///
	/// * `parent` - The parent node to add the current node to.
	/// * `order` - The drawing order of the current node.
	/// * `tag` - The tag of the current node.
	///
	/// # Returns
	///
	/// * `Node` - The current node.
	fn add_to_with_order_tag(&mut self, parent: &dyn crate::dora::INode, order: i32, tag: &str) -> crate::dora::Node {
		unsafe { return crate::dora::Node::from(node_add_to_with_order_tag(self.raw(), parent.raw(), order, crate::dora::from_string(tag))).unwrap(); }
	}
	/// Adds the current node to a parent node.
	///
	/// # Arguments
	///
	/// * `parent` - The parent node to add the current node to.
	/// * `order` - The drawing order of the current node.
	///
	/// # Returns
	///
	/// * `Node` - The current node.
	fn add_to_with_order(&mut self, parent: &dyn crate::dora::INode, order: i32) -> crate::dora::Node {
		unsafe { return crate::dora::Node::from(node_add_to_with_order(self.raw(), parent.raw(), order)).unwrap(); }
	}
	/// Adds the current node to a parent node.
	///
	/// # Arguments
	///
	/// * `parent` - The parent node to add the current node to.
	///
	/// # Returns
	///
	/// * `Node` - The current node.
	fn add_to(&mut self, parent: &dyn crate::dora::INode) -> crate::dora::Node {
		unsafe { return crate::dora::Node::from(node_add_to(self.raw(), parent.raw())).unwrap(); }
	}
	/// Removes a child node from the current node.
	///
	/// # Arguments
	///
	/// * `child` - The child node to remove.
	/// * `cleanup` - Whether to cleanup the child node.
	fn remove_child(&mut self, child: &dyn crate::dora::INode, cleanup: bool) {
		unsafe { node_remove_child(self.raw(), child.raw(), if cleanup { 1 } else { 0 }); }
	}
	/// Removes a child node from the current node by tag.
	///
	/// # Arguments
	///
	/// * `tag` - The tag of the child node to remove.
	/// * `cleanup` - Whether to cleanup the child node.
	fn remove_child_by_tag(&mut self, tag: &str, cleanup: bool) {
		unsafe { node_remove_child_by_tag(self.raw(), crate::dora::from_string(tag), if cleanup { 1 } else { 0 }); }
	}
	/// Removes all child nodes from the current node.
	///
	/// # Arguments
	///
	/// * `cleanup` - Whether to cleanup the child nodes.
	fn remove_all_children(&mut self, cleanup: bool) {
		unsafe { node_remove_all_children(self.raw(), if cleanup { 1 } else { 0 }); }
	}
	/// Removes the current node from its parent node.
	///
	/// # Arguments
	///
	/// * `cleanup` - Whether to cleanup the current node.
	fn remove_from_parent(&mut self, cleanup: bool) {
		unsafe { node_remove_from_parent(self.raw(), if cleanup { 1 } else { 0 }); }
	}
	/// Moves the current node to a new parent node without triggering node events.
	///
	/// # Arguments
	///
	/// * `parent` - The new parent node to move the current node to.
	fn move_to_parent(&mut self, parent: &dyn crate::dora::INode) {
		unsafe { node_move_to_parent(self.raw(), parent.raw()); }
	}
	/// Cleans up the current node.
	fn cleanup(&mut self) {
		unsafe { node_cleanup(self.raw()); }
	}
	/// Gets a child node by tag.
	///
	/// # Arguments
	///
	/// * `tag` - The tag of the child node to get.
	///
	/// # Returns
	///
	/// * `Option<Node>` - The child node, or `None` if not found.
	fn get_child_by_tag(&mut self, tag: &str) -> Option<crate::dora::Node> {
		unsafe { return crate::dora::Node::from(node_get_child_by_tag(self.raw(), crate::dora::from_string(tag))); }
	}
	/// Schedules a main function to run every frame. Call this function again to replace the previous scheduled main function or coroutine.
	///
	/// # Arguments
	///
	/// * `updateFunc` - The function to be called. If the function returns `true`, it will not be called again.
	fn schedule(&mut self, mut update_func: Box<dyn FnMut(f64) -> bool>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			let result = update_func(stack0.pop_f64().unwrap());
			stack0.push_bool(result);
		}));
		unsafe { node_schedule(self.raw(), func_id0, stack_raw0); }
	}
	/// Unschedules the current node's scheduled main function.
	fn unschedule(&mut self) {
		unsafe { node_unschedule(self.raw()); }
	}
	/// Converts a point from world space to node space.
	///
	/// # Arguments
	///
	/// * `world_point` - The point in world space, represented by a Vec2 object.
	///
	/// # Returns
	///
	/// * `Vec2` - The converted point in world space.
	fn convert_to_node_space(&mut self, world_point: &crate::dora::Vec2) -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(node_convert_to_node_space(self.raw(), world_point.into_i64())); }
	}
	/// Converts a point from node space to world space.
	///
	/// # Arguments
	///
	/// * `node_point` - The point in node space, represented by a Vec2 object.
	///
	/// # Returns
	///
	/// * `Vec2` - The converted point in world space.
	fn convert_to_world_space(&mut self, node_point: &crate::dora::Vec2) -> crate::dora::Vec2 {
		unsafe { return crate::dora::Vec2::from(node_convert_to_world_space(self.raw(), node_point.into_i64())); }
	}
	/// Converts a point from node space to world space.
	///
	/// # Arguments
	///
	/// * `node_point` - The point in node space, represented by a Vec2 object.
	/// * `callback` - The function to call with the converted point in world space.
	///
	/// # Returns
	///
	/// * `Vec2` - The converted point in world space.
	fn convert_to_window_space(&mut self, node_point: &crate::dora::Vec2, mut callback: Box<dyn FnMut(&crate::dora::Vec2)>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			callback(&stack0.pop_vec2().unwrap())
		}));
		unsafe { node_convert_to_window_space(self.raw(), node_point.into_i64(), func_id0, stack_raw0); }
	}
	/// Calls the given function for each child node of this node.
	///
	/// # Arguments
	///
	/// * `visitorFunc` - The function to call for each child node. The function should return a boolean value indicating whether to continue the iteration. Return true to stop iteration.
	///
	/// # Returns
	///
	/// * `bool` - `false` if all children have been visited, `true` if the iteration was interrupted by the function.
	fn each_child(&mut self, mut visitor_func: Box<dyn FnMut(&dyn crate::dora::INode) -> bool>) -> bool {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			let result = visitor_func(&stack0.pop_cast::<crate::dora::Node>().unwrap());
			stack0.push_bool(result);
		}));
		unsafe { return node_each_child(self.raw(), func_id0, stack_raw0) != 0; }
	}
	/// Traverses the node hierarchy starting from this node and calls the given function for each visited node. The nodes without `TraverseEnabled` flag are not visited.
	///
	/// # Arguments
	///
	/// * `visitorFunc` - The function to call for each visited node. The function should return a boolean value indicating whether to continue the traversal. Return true to stop iteration.
	///
	/// # Returns
	///
	/// * `bool` - `false` if all nodes have been visited, `true` if the traversal was interrupted by the function.
	fn traverse(&mut self, mut visitor_func: Box<dyn FnMut(&dyn crate::dora::INode) -> bool>) -> bool {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			let result = visitor_func(&stack0.pop_cast::<crate::dora::Node>().unwrap());
			stack0.push_bool(result);
		}));
		unsafe { return node_traverse(self.raw(), func_id0, stack_raw0) != 0; }
	}
	/// Traverses the entire node hierarchy starting from this node and calls the given function for each visited node.
	///
	/// # Arguments
	///
	/// * `visitorFunc` - The function to call for each visited node. The function should return a boolean value indicating whether to continue the traversal.
	///
	/// # Returns
	///
	/// * `bool` - `false` if all nodes have been visited, `true` if the traversal was interrupted by the function.
	fn traverse_all(&mut self, mut visitor_func: Box<dyn FnMut(&dyn crate::dora::INode) -> bool>) -> bool {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			let result = visitor_func(&stack0.pop_cast::<crate::dora::Node>().unwrap());
			stack0.push_bool(result);
		}));
		unsafe { return node_traverse_all(self.raw(), func_id0, stack_raw0) != 0; }
	}
	/// Runs an action defined by the given action definition on this node.
	///
	/// # Arguments
	///
	/// * `action_def` - The action definition to run.
	/// * `looped` - Whether to loop the action.
	///
	/// # Returns
	///
	/// * `f32` - The duration of the newly running action in seconds.
	fn run_action_def(&mut self, def: crate::dora::ActionDef, looped: bool) -> f32 {
		unsafe { return node_run_action_def(self.raw(), def.raw(), if looped { 1 } else { 0 }); }
	}
	/// Runs an action on this node.
	///
	/// # Arguments
	///
	/// * `action` - The action to run.
	/// * `looped` - Whether to loop the action.
	///
	/// # Returns
	///
	/// * `f32` - The duration of the newly running action in seconds.
	fn run_action(&mut self, action: &crate::dora::Action, looped: bool) -> f32 {
		unsafe { return node_run_action(self.raw(), action.raw(), if looped { 1 } else { 0 }); }
	}
	/// Stops all actions running on this node.
	fn stop_all_actions(&mut self) {
		unsafe { node_stop_all_actions(self.raw()); }
	}
	/// Runs an action defined by the given action definition right after clearing all the previous running actions.
	///
	/// # Arguments
	///
	/// * `action_def` - The action definition to run.
	/// * `looped` - Whether to loop the action.
	///
	/// # Returns
	///
	/// * `f32` - The duration of the newly running action in seconds.
	fn perform_def(&mut self, action_def: crate::dora::ActionDef, looped: bool) -> f32 {
		unsafe { return node_perform_def(self.raw(), action_def.raw(), if looped { 1 } else { 0 }); }
	}
	/// Runs an action on this node right after clearing all the previous running actions.
	///
	/// # Arguments
	///
	/// * `action` - The action to run.
	/// * `looped` - Whether to loop the action.
	///
	/// # Returns
	///
	/// * `f32` - The duration of the newly running action in seconds.
	fn perform(&mut self, action: &crate::dora::Action, looped: bool) -> f32 {
		unsafe { return node_perform(self.raw(), action.raw(), if looped { 1 } else { 0 }); }
	}
	/// Stops the given action running on this node.
	///
	/// # Arguments
	///
	/// * `action` - The action to stop.
	fn stop_action(&mut self, action: &crate::dora::Action) {
		unsafe { node_stop_action(self.raw(), action.raw()); }
	}
	/// Vertically aligns all child nodes within the node using the given size and padding.
	///
	/// # Arguments
	///
	/// * `padding` - The amount of padding to use between each child node.
	///
	/// # Returns
	///
	/// * `Size` - The size of the node after alignment.
	fn align_items_vertically(&mut self, padding: f32) -> crate::dora::Size {
		unsafe { return crate::dora::Size::from(node_align_items_vertically(self.raw(), padding)); }
	}
	/// Vertically aligns all child nodes within the node using the given size and padding.
	///
	/// # Arguments
	///
	/// * `size` - The size to use for alignment.
	/// * `padding` - The amount of padding to use between each child node.
	///
	/// # Returns
	///
	/// * `Size` - The size of the node after alignment.
	fn align_items_vertically_with_size(&mut self, size: &crate::dora::Size, padding: f32) -> crate::dora::Size {
		unsafe { return crate::dora::Size::from(node_align_items_vertically_with_size(self.raw(), size.into_i64(), padding)); }
	}
	/// Horizontally aligns all child nodes within the node using the given size and padding.
	///
	/// # Arguments
	///
	/// * `padding` - The amount of padding to use between each child node.
	///
	/// # Returns
	///
	/// * `Size` - The size of the node after alignment.
	fn align_items_horizontally(&mut self, padding: f32) -> crate::dora::Size {
		unsafe { return crate::dora::Size::from(node_align_items_horizontally(self.raw(), padding)); }
	}
	/// Horizontally aligns all child nodes within the node using the given size and padding.
	///
	/// # Arguments
	///
	/// * `size` - The size to hint for alignment.
	/// * `padding` - The amount of padding to use between each child node.
	///
	/// # Returns
	///
	/// * `Size` - The size of the node after alignment.
	fn align_items_horizontally_with_size(&mut self, size: &crate::dora::Size, padding: f32) -> crate::dora::Size {
		unsafe { return crate::dora::Size::from(node_align_items_horizontally_with_size(self.raw(), size.into_i64(), padding)); }
	}
	/// Aligns all child nodes within the node using the given size and padding.
	///
	/// # Arguments
	///
	/// * `padding` - The amount of padding to use between each child node.
	///
	/// # Returns
	///
	/// * `Size` - The size of the node after alignment.
	fn align_items(&mut self, padding: f32) -> crate::dora::Size {
		unsafe { return crate::dora::Size::from(node_align_items(self.raw(), padding)); }
	}
	/// Aligns all child nodes within the node using the given size and padding.
	///
	/// # Arguments
	///
	/// * `size` - The size to use for alignment.
	/// * `padding` - The amount of padding to use between each child node.
	///
	/// # Returns
	///
	/// * `Size` - The size of the node after alignment.
	fn align_items_with_size(&mut self, size: &crate::dora::Size, padding: f32) -> crate::dora::Size {
		unsafe { return crate::dora::Size::from(node_align_items_with_size(self.raw(), size.into_i64(), padding)); }
	}
	/// Moves and changes child nodes' visibility based on their position in parent's area.
	///
	/// # Arguments
	///
	/// * `delta` - The distance to move its children, represented by a Vec2 object.
	fn move_and_cull_items(&mut self, delta: &crate::dora::Vec2) {
		unsafe { node_move_and_cull_items(self.raw(), delta.into_i64()); }
	}
	/// Attaches the input method editor (IME) to the node.
	/// Makes node recieving "AttachIME", "DetachIME", "TextInput", "TextEditing" events.
	fn attach_ime(&mut self) {
		unsafe { node_attach_ime(self.raw()); }
	}
	/// Detaches the input method editor (IME) from the node.
	fn detach_ime(&mut self) {
		unsafe { node_detach_ime(self.raw()); }
	}
	/// Creates a texture grabber for the specified node.
	///
	/// # Returns
	///
	/// * `Grabber` - A Grabber object with gridX == 1 and gridY == 1.
	fn grab(&mut self) -> crate::dora::Grabber {
		unsafe { return crate::dora::Grabber::from(node_grab(self.raw())).unwrap(); }
	}
	/// Creates a texture grabber for the specified node with a specified grid size.
	///
	/// # Arguments
	///
	/// * `grid_x` - The number of horizontal grid cells to divide the grabber into.
	/// * `grid_y` - The number of vertical grid cells to divide the grabber into.
	///
	/// # Returns
	///
	/// * `Grabber` - A Grabber object.
	fn grab_with_size(&mut self, grid_x: i32, grid_y: i32) -> crate::dora::Grabber {
		unsafe { return crate::dora::Grabber::from(node_grab_with_size(self.raw(), grid_x, grid_y)).unwrap(); }
	}
	/// Removes the texture grabber for the specified node.
	fn stop_grab(&mut self) {
		unsafe { node_stop_grab(self.raw()); }
	}
	/// Removes the transform target for the specified node.
	fn set_transform_target_null(&mut self) {
		unsafe { node_set_transform_target_null(self.raw()); }
	}
	/// Associates the given handler function with the node event.
	///
	/// # Arguments
	///
	/// * `event_name` - The name of the node event.
	/// * `handler` - The handler function to associate with the node event.
	fn slot(&mut self, event_name: &str, mut handler: Box<dyn FnMut(&mut crate::dora::CallStack)>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			handler(&mut stack0)
		}));
		unsafe { node_slot(self.raw(), crate::dora::from_string(event_name), func_id0, stack_raw0); }
	}
	/// Associates the given handler function with a global event.
	///
	/// # Arguments
	///
	/// * `event_name` - The name of the global event.
	/// * `handler` - The handler function to associate with the event.
	fn gslot(&mut self, event_name: &str, mut handler: Box<dyn FnMut(&mut crate::dora::CallStack)>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			handler(&mut stack0)
		}));
		unsafe { node_gslot(self.raw(), crate::dora::from_string(event_name), func_id0, stack_raw0); }
	}
	/// Emits an event to a node, triggering the event handler associated with the event name.
	///
	/// # Arguments
	///
	/// * `name` - The name of the event.
	/// * `stack` - The argument stack to be passed to the event handler.
	fn emit(&mut self, name: &str, stack: &crate::dora::CallStack) {
		unsafe { node_emit(self.raw(), crate::dora::from_string(name), stack.raw()); }
	}
	/// Schedules a function to run every frame. Call this function again to schedule multiple functions.
	///
	/// # Arguments
	///
	/// * `updateFunc` - The function to run every frame. If the function returns `true`, it will not be called again.
	fn on_update(&mut self, mut update_func: Box<dyn FnMut(f64) -> bool>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			let result = update_func(stack0.pop_f64().unwrap());
			stack0.push_bool(result);
		}));
		unsafe { node_on_update(self.raw(), func_id0, stack_raw0); }
	}
	/// Registers a callback for event triggered when the node is entering the rendering phase. The callback is called every frame, and ensures that its call order is consistent with the rendering order of the scene tree, such as rendering child nodes after their parent nodes. Recommended for calling vector drawing functions.
	///
	/// # Arguments
	///
	/// * `func` - The function to call when the node is entering the rendering phase, returns true to stop.
	///
	/// # Returns
	///
	/// * `void` - True to stop the function from running.
	fn on_render(&mut self, mut render_func: Box<dyn FnMut(f64) -> bool>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			let result = render_func(stack0.pop_f64().unwrap());
			stack0.push_bool(result);
		}));
		unsafe { node_on_render(self.raw(), func_id0, stack_raw0); }
	}
}
impl Node {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { node_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Node { raw: raw }))
			}
		})
	}
	/// Creates a new instance of the `Node` struct.
	pub fn new() -> Node {
		unsafe { return Node { raw: node_new() }; }
	}
}