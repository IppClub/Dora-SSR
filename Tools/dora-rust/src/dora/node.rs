extern "C" {
	fn node_type() -> i32;
	fn node_set_order(slf: i64, var: i32);
	fn node_get_order(slf: i64) -> i32;
	fn node_set_angle(slf: i64, var: f32);
	fn node_get_angle(slf: i64) -> f32;
	fn node_set_angle_x(slf: i64, var: f32);
	fn node_get_angle_x(slf: i64) -> f32;
	fn node_set_angle_y(slf: i64, var: f32);
	fn node_get_angle_y(slf: i64) -> f32;
	fn node_set_scale_x(slf: i64, var: f32);
	fn node_get_scale_x(slf: i64) -> f32;
	fn node_set_scale_y(slf: i64, var: f32);
	fn node_get_scale_y(slf: i64) -> f32;
	fn node_set_x(slf: i64, var: f32);
	fn node_get_x(slf: i64) -> f32;
	fn node_set_y(slf: i64, var: f32);
	fn node_get_y(slf: i64) -> f32;
	fn node_set_z(slf: i64, var: f32);
	fn node_get_z(slf: i64) -> f32;
	fn node_set_position(slf: i64, var: i64);
	fn node_get_position(slf: i64) -> i64;
	fn node_set_skew_x(slf: i64, var: f32);
	fn node_get_skew_x(slf: i64) -> f32;
	fn node_set_skew_y(slf: i64, var: f32);
	fn node_get_skew_y(slf: i64) -> f32;
	fn node_set_visible(slf: i64, var: i32);
	fn node_is_visible(slf: i64) -> i32;
	fn node_set_anchor(slf: i64, var: i64);
	fn node_get_anchor(slf: i64) -> i64;
	fn node_set_width(slf: i64, var: f32);
	fn node_get_width(slf: i64) -> f32;
	fn node_set_height(slf: i64, var: f32);
	fn node_get_height(slf: i64) -> f32;
	fn node_set_size(slf: i64, var: i64);
	fn node_get_size(slf: i64) -> i64;
	fn node_set_tag(slf: i64, var: i64);
	fn node_get_tag(slf: i64) -> i64;
	fn node_set_opacity(slf: i64, var: f32);
	fn node_get_opacity(slf: i64) -> f32;
	fn node_set_color(slf: i64, var: i32);
	fn node_get_color(slf: i64) -> i32;
	fn node_set_color3(slf: i64, var: i32);
	fn node_get_color3(slf: i64) -> i32;
	fn node_set_pass_opacity(slf: i64, var: i32);
	fn node_is_pass_opacity(slf: i64) -> i32;
	fn node_set_pass_color3(slf: i64, var: i32);
	fn node_is_pass_color3(slf: i64) -> i32;
	fn node_set_transform_target(slf: i64, var: i64);
	fn node_get_transform_target(slf: i64) -> i64;
	fn node_set_scheduler(slf: i64, var: i64);
	fn node_get_scheduler(slf: i64) -> i64;
	fn node_get_children(slf: i64) -> i64;
	fn node_get_parent(slf: i64) -> i64;
	fn node_get_bounding_box(slf: i64) -> i64;
	fn node_is_running(slf: i64) -> i32;
	fn node_is_updating(slf: i64) -> i32;
	fn node_is_scheduled(slf: i64) -> i32;
	fn node_get_action_count(slf: i64) -> i32;
	fn node_get_data(slf: i64) -> i64;
	fn node_set_touch_enabled(slf: i64, var: i32);
	fn node_is_touch_enabled(slf: i64) -> i32;
	fn node_set_swallow_touches(slf: i64, var: i32);
	fn node_is_swallow_touches(slf: i64) -> i32;
	fn node_set_swallow_mouse_wheel(slf: i64, var: i32);
	fn node_is_swallow_mouse_wheel(slf: i64) -> i32;
	fn node_set_keyboard_enabled(slf: i64, var: i32);
	fn node_is_keyboard_enabled(slf: i64) -> i32;
	fn node_set_render_group(slf: i64, var: i32);
	fn node_is_render_group(slf: i64) -> i32;
	fn node_set_render_order(slf: i64, var: i32);
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
	fn node_schedule(slf: i64, func: i32, stack: i64);
	fn node_unschedule(slf: i64);
	fn node_convert_to_node_space(slf: i64, world_point: i64) -> i64;
	fn node_convert_to_world_space(slf: i64, node_point: i64) -> i64;
	fn node_convert_to_window_space(slf: i64, node_point: i64, func: i32, stack: i64);
	fn node_each_child(slf: i64, func: i32, stack: i64) -> i32;
	fn node_traverse(slf: i64, func: i32, stack: i64) -> i32;
	fn node_traverse_all(slf: i64, func: i32, stack: i64) -> i32;
	fn node_run_action(slf: i64, action: i64);
	fn node_stop_all_actions(slf: i64);
	fn node_perform(slf: i64, action: i64);
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
	fn node_slot(slf: i64, name: i64, func: i32, stack: i64) -> i32;
	fn node_gslot(slf: i64, name: i64, func: i32, stack: i64) -> i32;
	fn node_new() -> i64;
}
use crate::dora::Object;
pub struct Node { raw: i64 }
crate::dora_object!(Node);
impl INode for Node { }
pub trait INode: Object {
	fn set_order(&mut self, var: i32) {
		unsafe { node_set_order(self.raw(), var) };
	}
	fn get_order(&self) -> i32 {
		return unsafe { node_get_order(self.raw()) };
	}
	fn set_angle(&mut self, var: f32) {
		unsafe { node_set_angle(self.raw(), var) };
	}
	fn get_angle(&self) -> f32 {
		return unsafe { node_get_angle(self.raw()) };
	}
	fn set_angle_x(&mut self, var: f32) {
		unsafe { node_set_angle_x(self.raw(), var) };
	}
	fn get_angle_x(&self) -> f32 {
		return unsafe { node_get_angle_x(self.raw()) };
	}
	fn set_angle_y(&mut self, var: f32) {
		unsafe { node_set_angle_y(self.raw(), var) };
	}
	fn get_angle_y(&self) -> f32 {
		return unsafe { node_get_angle_y(self.raw()) };
	}
	fn set_scale_x(&mut self, var: f32) {
		unsafe { node_set_scale_x(self.raw(), var) };
	}
	fn get_scale_x(&self) -> f32 {
		return unsafe { node_get_scale_x(self.raw()) };
	}
	fn set_scale_y(&mut self, var: f32) {
		unsafe { node_set_scale_y(self.raw(), var) };
	}
	fn get_scale_y(&self) -> f32 {
		return unsafe { node_get_scale_y(self.raw()) };
	}
	fn set_x(&mut self, var: f32) {
		unsafe { node_set_x(self.raw(), var) };
	}
	fn get_x(&self) -> f32 {
		return unsafe { node_get_x(self.raw()) };
	}
	fn set_y(&mut self, var: f32) {
		unsafe { node_set_y(self.raw(), var) };
	}
	fn get_y(&self) -> f32 {
		return unsafe { node_get_y(self.raw()) };
	}
	fn set_z(&mut self, var: f32) {
		unsafe { node_set_z(self.raw(), var) };
	}
	fn get_z(&self) -> f32 {
		return unsafe { node_get_z(self.raw()) };
	}
	fn set_position(&mut self, var: &crate::dora::Vec2) {
		unsafe { node_set_position(self.raw(), var.into_i64()) };
	}
	fn get_position(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(node_get_position(self.raw())) };
	}
	fn set_skew_x(&mut self, var: f32) {
		unsafe { node_set_skew_x(self.raw(), var) };
	}
	fn get_skew_x(&self) -> f32 {
		return unsafe { node_get_skew_x(self.raw()) };
	}
	fn set_skew_y(&mut self, var: f32) {
		unsafe { node_set_skew_y(self.raw(), var) };
	}
	fn get_skew_y(&self) -> f32 {
		return unsafe { node_get_skew_y(self.raw()) };
	}
	fn set_visible(&mut self, var: bool) {
		unsafe { node_set_visible(self.raw(), if var { 1 } else { 0 }) };
	}
	fn is_visible(&self) -> bool {
		return unsafe { node_is_visible(self.raw()) != 0 };
	}
	fn set_anchor(&mut self, var: &crate::dora::Vec2) {
		unsafe { node_set_anchor(self.raw(), var.into_i64()) };
	}
	fn get_anchor(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(node_get_anchor(self.raw())) };
	}
	fn set_width(&mut self, var: f32) {
		unsafe { node_set_width(self.raw(), var) };
	}
	fn get_width(&self) -> f32 {
		return unsafe { node_get_width(self.raw()) };
	}
	fn set_height(&mut self, var: f32) {
		unsafe { node_set_height(self.raw(), var) };
	}
	fn get_height(&self) -> f32 {
		return unsafe { node_get_height(self.raw()) };
	}
	fn set_size(&mut self, var: &crate::dora::Size) {
		unsafe { node_set_size(self.raw(), var.into_i64()) };
	}
	fn get_size(&self) -> crate::dora::Size {
		return unsafe { crate::dora::Size::from(node_get_size(self.raw())) };
	}
	fn set_tag(&mut self, var: &str) {
		unsafe { node_set_tag(self.raw(), crate::dora::from_string(var)) };
	}
	fn get_tag(&self) -> String {
		return unsafe { crate::dora::to_string(node_get_tag(self.raw())) };
	}
	fn set_opacity(&mut self, var: f32) {
		unsafe { node_set_opacity(self.raw(), var) };
	}
	fn get_opacity(&self) -> f32 {
		return unsafe { node_get_opacity(self.raw()) };
	}
	fn set_color(&mut self, var: &crate::dora::Color) {
		unsafe { node_set_color(self.raw(), var.to_argb() as i32) };
	}
	fn get_color(&self) -> crate::dora::Color {
		return unsafe { crate::dora::Color::from(node_get_color(self.raw())) };
	}
	fn set_color3(&mut self, var: &crate::dora::Color3) {
		unsafe { node_set_color3(self.raw(), var.to_rgb() as i32) };
	}
	fn get_color3(&self) -> crate::dora::Color3 {
		return unsafe { crate::dora::Color3::from(node_get_color3(self.raw())) };
	}
	fn set_pass_opacity(&mut self, var: bool) {
		unsafe { node_set_pass_opacity(self.raw(), if var { 1 } else { 0 }) };
	}
	fn is_pass_opacity(&self) -> bool {
		return unsafe { node_is_pass_opacity(self.raw()) != 0 };
	}
	fn set_pass_color3(&mut self, var: bool) {
		unsafe { node_set_pass_color3(self.raw(), if var { 1 } else { 0 }) };
	}
	fn is_pass_color3(&self) -> bool {
		return unsafe { node_is_pass_color3(self.raw()) != 0 };
	}
	fn set_transform_target(&mut self, var: &dyn crate::dora::INode) {
		unsafe { node_set_transform_target(self.raw(), var.raw()) };
	}
	fn get_transform_target(&self) -> Option<crate::dora::Node> {
		return unsafe { crate::dora::Node::from(node_get_transform_target(self.raw())) };
	}
	fn set_scheduler(&mut self, var: &crate::dora::Scheduler) {
		unsafe { node_set_scheduler(self.raw(), var.raw()) };
	}
	fn get_scheduler(&self) -> crate::dora::Scheduler {
		return unsafe { crate::dora::Scheduler::from(node_get_scheduler(self.raw())).unwrap() };
	}
	fn get_children(&self) -> Option<crate::dora::Array> {
		return unsafe { crate::dora::Array::from(node_get_children(self.raw())) };
	}
	fn get_parent(&self) -> Option<crate::dora::Node> {
		return unsafe { crate::dora::Node::from(node_get_parent(self.raw())) };
	}
	fn get_bounding_box(&self) -> crate::dora::Rect {
		return unsafe { crate::dora::Rect::from(node_get_bounding_box(self.raw())) };
	}
	fn is_running(&self) -> bool {
		return unsafe { node_is_running(self.raw()) != 0 };
	}
	fn is_updating(&self) -> bool {
		return unsafe { node_is_updating(self.raw()) != 0 };
	}
	fn is_scheduled(&self) -> bool {
		return unsafe { node_is_scheduled(self.raw()) != 0 };
	}
	fn get_action_count(&self) -> i32 {
		return unsafe { node_get_action_count(self.raw()) };
	}
	fn get_data(&self) -> crate::dora::Dictionary {
		return unsafe { crate::dora::Dictionary::from(node_get_data(self.raw())).unwrap() };
	}
	fn set_touch_enabled(&mut self, var: bool) {
		unsafe { node_set_touch_enabled(self.raw(), if var { 1 } else { 0 }) };
	}
	fn is_touch_enabled(&self) -> bool {
		return unsafe { node_is_touch_enabled(self.raw()) != 0 };
	}
	fn set_swallow_touches(&mut self, var: bool) {
		unsafe { node_set_swallow_touches(self.raw(), if var { 1 } else { 0 }) };
	}
	fn is_swallow_touches(&self) -> bool {
		return unsafe { node_is_swallow_touches(self.raw()) != 0 };
	}
	fn set_swallow_mouse_wheel(&mut self, var: bool) {
		unsafe { node_set_swallow_mouse_wheel(self.raw(), if var { 1 } else { 0 }) };
	}
	fn is_swallow_mouse_wheel(&self) -> bool {
		return unsafe { node_is_swallow_mouse_wheel(self.raw()) != 0 };
	}
	fn set_keyboard_enabled(&mut self, var: bool) {
		unsafe { node_set_keyboard_enabled(self.raw(), if var { 1 } else { 0 }) };
	}
	fn is_keyboard_enabled(&self) -> bool {
		return unsafe { node_is_keyboard_enabled(self.raw()) != 0 };
	}
	fn set_render_group(&mut self, var: bool) {
		unsafe { node_set_render_group(self.raw(), if var { 1 } else { 0 }) };
	}
	fn is_render_group(&self) -> bool {
		return unsafe { node_is_render_group(self.raw()) != 0 };
	}
	fn set_render_order(&mut self, var: i32) {
		unsafe { node_set_render_order(self.raw(), var) };
	}
	fn get_render_order(&self) -> i32 {
		return unsafe { node_get_render_order(self.raw()) };
	}
	fn add_child_with_order_tag(&mut self, child: &dyn crate::dora::INode, order: i32, tag: &str) {
		unsafe { node_add_child_with_order_tag(self.raw(), child.raw(), order, crate::dora::from_string(tag)) };
	}
	fn add_child_with_order(&mut self, child: &dyn crate::dora::INode, order: i32) {
		unsafe { node_add_child_with_order(self.raw(), child.raw(), order) };
	}
	fn add_child(&mut self, child: &dyn crate::dora::INode) {
		unsafe { node_add_child(self.raw(), child.raw()) };
	}
	fn add_to_with_order_tag(&mut self, parent: &dyn crate::dora::INode, order: i32, tag: &str) -> crate::dora::Node {
		return crate::dora::Node::from(unsafe { node_add_to_with_order_tag(self.raw(), parent.raw(), order, crate::dora::from_string(tag)) }).unwrap();
	}
	fn add_to_with_order(&mut self, parent: &dyn crate::dora::INode, order: i32) -> crate::dora::Node {
		return crate::dora::Node::from(unsafe { node_add_to_with_order(self.raw(), parent.raw(), order) }).unwrap();
	}
	fn add_to(&mut self, parent: &dyn crate::dora::INode) -> crate::dora::Node {
		return crate::dora::Node::from(unsafe { node_add_to(self.raw(), parent.raw()) }).unwrap();
	}
	fn remove_child(&mut self, child: &dyn crate::dora::INode, cleanup: bool) {
		unsafe { node_remove_child(self.raw(), child.raw(), if cleanup { 1 } else { 0 }) };
	}
	fn remove_child_by_tag(&mut self, tag: &str, cleanup: bool) {
		unsafe { node_remove_child_by_tag(self.raw(), crate::dora::from_string(tag), if cleanup { 1 } else { 0 }) };
	}
	fn remove_all_children(&mut self, cleanup: bool) {
		unsafe { node_remove_all_children(self.raw(), if cleanup { 1 } else { 0 }) };
	}
	fn remove_from_parent(&mut self, cleanup: bool) {
		unsafe { node_remove_from_parent(self.raw(), if cleanup { 1 } else { 0 }) };
	}
	fn move_to_parent(&mut self, parent: &dyn crate::dora::INode) {
		unsafe { node_move_to_parent(self.raw(), parent.raw()) };
	}
	fn cleanup(&mut self) {
		unsafe { node_cleanup(self.raw()) };
	}
	fn get_child_by_tag(&mut self, tag: &str) -> Option<crate::dora::Node> {
		return crate::dora::Node::from(unsafe { node_get_child_by_tag(self.raw(), crate::dora::from_string(tag)) });
	}
	fn schedule(&mut self, mut func: Box<dyn FnMut(f64) -> bool>) {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			let result = func(stack.pop_f64().unwrap());
			stack.push_bool(result);
		}));
		unsafe { node_schedule(self.raw(), func_id, stack_raw) };
	}
	fn unschedule(&mut self) {
		unsafe { node_unschedule(self.raw()) };
	}
	fn convert_to_node_space(&mut self, world_point: &crate::dora::Vec2) -> crate::dora::Vec2 {
		return crate::dora::Vec2::from(unsafe { node_convert_to_node_space(self.raw(), world_point.into_i64()) });
	}
	fn convert_to_world_space(&mut self, node_point: &crate::dora::Vec2) -> crate::dora::Vec2 {
		return crate::dora::Vec2::from(unsafe { node_convert_to_world_space(self.raw(), node_point.into_i64()) });
	}
	fn convert_to_window_space(&mut self, node_point: &crate::dora::Vec2, mut callback: Box<dyn FnMut(&crate::dora::Vec2)>) {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			callback(&stack.pop_vec2().unwrap())
		}));
		unsafe { node_convert_to_window_space(self.raw(), node_point.into_i64(), func_id, stack_raw) };
	}
	fn each_child(&mut self, mut func: Box<dyn FnMut(&dyn crate::dora::INode) -> bool>) -> bool {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			let result = func(&stack.pop_cast::<crate::dora::Node>().unwrap());
			stack.push_bool(result);
		}));
		return unsafe { node_each_child(self.raw(), func_id, stack_raw) } != 0;
	}
	fn traverse(&mut self, mut func: Box<dyn FnMut(&dyn crate::dora::INode) -> bool>) -> bool {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			let result = func(&stack.pop_cast::<crate::dora::Node>().unwrap());
			stack.push_bool(result);
		}));
		return unsafe { node_traverse(self.raw(), func_id, stack_raw) } != 0;
	}
	fn traverse_all(&mut self, mut func: Box<dyn FnMut(&dyn crate::dora::INode) -> bool>) -> bool {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			let result = func(&stack.pop_cast::<crate::dora::Node>().unwrap());
			stack.push_bool(result);
		}));
		return unsafe { node_traverse_all(self.raw(), func_id, stack_raw) } != 0;
	}
	fn run_action(&mut self, action: &crate::dora::Action) {
		unsafe { node_run_action(self.raw(), action.raw()) };
	}
	fn stop_all_actions(&mut self) {
		unsafe { node_stop_all_actions(self.raw()) };
	}
	fn perform(&mut self, action: &crate::dora::Action) {
		unsafe { node_perform(self.raw(), action.raw()) };
	}
	fn stop_action(&mut self, action: &crate::dora::Action) {
		unsafe { node_stop_action(self.raw(), action.raw()) };
	}
	fn align_items_vertically(&mut self, padding: f32) -> crate::dora::Size {
		return crate::dora::Size::from(unsafe { node_align_items_vertically(self.raw(), padding) });
	}
	fn align_items_vertically_with_size(&mut self, size: &crate::dora::Size, padding: f32) -> crate::dora::Size {
		return crate::dora::Size::from(unsafe { node_align_items_vertically_with_size(self.raw(), size.into_i64(), padding) });
	}
	fn align_items_horizontally(&mut self, padding: f32) -> crate::dora::Size {
		return crate::dora::Size::from(unsafe { node_align_items_horizontally(self.raw(), padding) });
	}
	fn align_items_horizontally_with_size(&mut self, size: &crate::dora::Size, padding: f32) -> crate::dora::Size {
		return crate::dora::Size::from(unsafe { node_align_items_horizontally_with_size(self.raw(), size.into_i64(), padding) });
	}
	fn align_items(&mut self, padding: f32) -> crate::dora::Size {
		return crate::dora::Size::from(unsafe { node_align_items(self.raw(), padding) });
	}
	fn align_items_with_size(&mut self, size: &crate::dora::Size, padding: f32) -> crate::dora::Size {
		return crate::dora::Size::from(unsafe { node_align_items_with_size(self.raw(), size.into_i64(), padding) });
	}
	fn move_and_cull_items(&mut self, delta: &crate::dora::Vec2) {
		unsafe { node_move_and_cull_items(self.raw(), delta.into_i64()) };
	}
	fn attach_ime(&mut self) {
		unsafe { node_attach_ime(self.raw()) };
	}
	fn detach_ime(&mut self) {
		unsafe { node_detach_ime(self.raw()) };
	}
	fn grab(&mut self) -> crate::dora::Grabber {
		return crate::dora::Grabber::from(unsafe { node_grab(self.raw()) }).unwrap();
	}
	fn grab_with_size(&mut self, grid_x: i32, grid_y: i32) -> crate::dora::Grabber {
		return crate::dora::Grabber::from(unsafe { node_grab_with_size(self.raw(), grid_x, grid_y) }).unwrap();
	}
	fn stop_grab(&mut self) {
		unsafe { node_stop_grab(self.raw()) };
	}
	fn slot(&mut self, name: &str, mut func: Box<dyn FnMut(&mut crate::dora::CallStack)>) -> bool {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			func(&mut stack)
		}));
		return unsafe { node_slot(self.raw(), crate::dora::from_string(name), func_id, stack_raw) } != 0;
	}
	fn gslot(&mut self, name: &str, mut func: Box<dyn FnMut(&mut crate::dora::CallStack)>) -> bool {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			func(&mut stack)
		}));
		return unsafe { node_gslot(self.raw(), crate::dora::from_string(name), func_id, stack_raw) } != 0;
	}
}
impl Node {
	pub fn new() -> Node {
		return Node { raw: unsafe { node_new() } };
	}
}