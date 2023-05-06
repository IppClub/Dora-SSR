extern "C" {
	fn clipnode_type() -> i32;
	fn clipnode_set_stencil(slf: i64, var: i64);
	fn clipnode_get_stencil(slf: i64) -> i64;
	fn clipnode_set_alpha_threshold(slf: i64, var: f32);
	fn clipnode_get_alpha_threshold(slf: i64) -> f32;
	fn clipnode_set_inverted(slf: i64, var: i32);
	fn clipnode_is_inverted(slf: i64) -> i32;
	fn clipnode_new(stencil: i64) -> i64;
}
use crate::dora::IObject;
use crate::dora::INode;
impl INode for ClipNode { }
pub struct ClipNode { raw: i64 }
crate::dora_object!(ClipNode);
impl ClipNode {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { clipnode_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(ClipNode { raw: raw }))
			}
		})
	}
	pub fn set_stencil(&mut self, var: &dyn crate::dora::INode) {
		unsafe { clipnode_set_stencil(self.raw(), var.raw()) };
	}
	pub fn get_stencil(&self) -> crate::dora::Node {
		return unsafe { crate::dora::Node::from(clipnode_get_stencil(self.raw())).unwrap() };
	}
	pub fn set_alpha_threshold(&mut self, var: f32) {
		unsafe { clipnode_set_alpha_threshold(self.raw(), var) };
	}
	pub fn get_alpha_threshold(&self) -> f32 {
		return unsafe { clipnode_get_alpha_threshold(self.raw()) };
	}
	pub fn set_inverted(&mut self, var: bool) {
		unsafe { clipnode_set_inverted(self.raw(), if var { 1 } else { 0 }) };
	}
	pub fn is_inverted(&self) -> bool {
		return unsafe { clipnode_is_inverted(self.raw()) != 0 };
	}
	pub fn new(stencil: &dyn crate::dora::INode) -> ClipNode {
		unsafe { return ClipNode { raw: clipnode_new(stencil.raw()) }; }
	}
}