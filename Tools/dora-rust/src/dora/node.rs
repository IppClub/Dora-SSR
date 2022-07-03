use std::any::Any;
use dora::object_macro;
use crate::dora::{Object, Vec2, Array, Dictionary, CallStack, from_string, to_string, push_function, object_release};

extern "C" {
	fn node_type() -> i32;
	fn node_create() -> i64;
	fn node_set_x(node: i64, var: f32);
	fn node_get_x(node: i64) -> f32;
	fn node_set_position(node: i64, var: i64);
	fn node_get_position(node: i64) -> i64;
	fn node_set_tag(node: i64, var: i64);
	fn node_get_tag(node: i64) -> i64;
	fn node_get_children(node: i64) -> i64;
	fn node_get_userdata(node: i64) -> i64;
	fn node_add_child(node: i64, child: i64);
	fn node_schedule(node: i64, func: i32, stack: i64);
	fn node_emit(node: i64, name: i64, stack: i64);
	fn node_slot(node: i64, name: i64, func: i32, stack: i64);
	fn node_gslot(node: i64, name: i64, func: i32, stack: i64);
}

pub trait INode: Object {
	fn set_x(&mut self, var: f32) {
		unsafe { node_set_x(self.raw(), var); }
	}
	fn get_x(&self)-> f32 {
		unsafe { node_get_x(self.raw()) }
	}
	fn set_position(&mut self, var: &Vec2) {
		unsafe { node_set_position(self.raw(), var.into_i64()); }
	}
	fn get_position(&self)-> Vec2 {
		Vec2::from(unsafe { node_get_position(self.raw()) })
	}
	fn set_tag(&mut self, var: &str) {
		unsafe { node_set_tag(self.raw(), from_string(var)); }
	}
	fn get_tag(&self)-> String {
		to_string(unsafe { node_get_tag(self.raw()) })
	}
	fn get_children(&self) -> Option<Array> {
		Array::from(unsafe { node_get_children(self.raw()) } )
	}
	fn get_userdata(&self) -> Dictionary {
		Dictionary::from(unsafe { node_get_userdata(self.raw()) } ).unwrap()
	}
	fn add_child(&mut self, child: &dyn INode) {
		unsafe { node_add_child(self.raw(), child.raw()); }
	}
	fn schedule(&mut self, mut func: Box<dyn FnMut(f64) -> bool>) {
		let mut stack = CallStack::new();
		let stack_raw = stack.raw();
		let func_id = push_function(Box::new(move || {
			let delta_time = stack.pop_f64().unwrap();
			let result = func(delta_time);
			stack.push_bool(result);
		}));
		unsafe { node_schedule(self.raw(), func_id, stack_raw); }
	}
	fn emit(&mut self, name: &str, stack: &CallStack) {
		unsafe { node_emit(self.raw(), from_string(name), stack.raw()); }
	}
	fn slot(&mut self, name: &str, mut func: Box<dyn FnMut(&mut CallStack)>) {
		let mut stack = CallStack::new();
		let stack_raw = stack.raw();
		let func_id = push_function(Box::new(move || { func(&mut stack); }));
		unsafe { node_slot(self.raw(), from_string(name), func_id, stack_raw); }
	}
	fn gslot(&mut self, name: &str, mut func: Box<dyn FnMut(&mut CallStack)>) {
		let mut stack = CallStack::new();
		let stack_raw = stack.raw();
		let func_id = push_function(Box::new(move || { func(&mut stack); }));
		unsafe { node_gslot(self.raw(), from_string(name), func_id, stack_raw); }
	}
}

#[derive(object_macro)]
pub struct Node { raw: i64 }

impl Node {
	pub fn new() -> Node {
		Node { raw: unsafe { node_create() } }
	}
}

impl INode for Node { }
