extern "C" {
	fn platformer_behavior_tree_type() -> i32;
	fn platformer_behavior_leaf_seq(nodes: i64) -> i64;
	fn platformer_behavior_leaf_sel(nodes: i64) -> i64;
	fn platformer_behavior_leaf_con(name: i64, func: i32, stack: i64) -> i64;
	fn platformer_behavior_leaf_act(action: i64) -> i64;
	fn platformer_behavior_leaf_command(action: i64) -> i64;
	fn platformer_behavior_leaf_wait(duration: f64) -> i64;
	fn platformer_behavior_leaf_countdown(time: f64, node: i64) -> i64;
	fn platformer_behavior_leaf_timeout(time: f64, node: i64) -> i64;
	fn platformer_behavior_leaf_repeat(times: i32, node: i64) -> i64;
	fn platformer_behavior_leaf_repeat_forever(node: i64) -> i64;
	fn platformer_behavior_leaf_retry(times: i32, node: i64) -> i64;
	fn platformer_behavior_leaf_retry_until_pass(node: i64) -> i64;
}
use crate::dora::IObject;
pub struct Tree { raw: i64 }
crate::dora_object!(Tree);
impl Tree {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { platformer_behavior_tree_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Tree { raw: raw }))
			}
		})
	}
	pub fn seq(nodes: &Vec<crate::dora::platformer::behavior::Tree>) -> crate::dora::platformer::behavior::Tree {
		unsafe { return crate::dora::platformer::behavior::Tree::from(platformer_behavior_leaf_seq(crate::dora::Vector::from_btree(nodes))).unwrap(); }
	}
	pub fn sel(nodes: &Vec<crate::dora::platformer::behavior::Tree>) -> crate::dora::platformer::behavior::Tree {
		unsafe { return crate::dora::platformer::behavior::Tree::from(platformer_behavior_leaf_sel(crate::dora::Vector::from_btree(nodes))).unwrap(); }
	}
	pub fn con(name: &str, mut handler: Box<dyn FnMut(&crate::dora::platformer::behavior::Blackboard) -> bool>) -> crate::dora::platformer::behavior::Tree {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			let result = handler(&crate::dora::platformer::behavior::Blackboard::from(stack.pop_i64().unwrap()).unwrap());
			stack.push_bool(result);
		}));
		unsafe { return crate::dora::platformer::behavior::Tree::from(platformer_behavior_leaf_con(crate::dora::from_string(name), func_id, stack_raw)).unwrap(); }
	}
	pub fn act(action: &str) -> crate::dora::platformer::behavior::Tree {
		unsafe { return crate::dora::platformer::behavior::Tree::from(platformer_behavior_leaf_act(crate::dora::from_string(action))).unwrap(); }
	}
	pub fn command(action: &str) -> crate::dora::platformer::behavior::Tree {
		unsafe { return crate::dora::platformer::behavior::Tree::from(platformer_behavior_leaf_command(crate::dora::from_string(action))).unwrap(); }
	}
	pub fn wait(duration: f64) -> crate::dora::platformer::behavior::Tree {
		unsafe { return crate::dora::platformer::behavior::Tree::from(platformer_behavior_leaf_wait(duration)).unwrap(); }
	}
	pub fn countdown(time: f64, node: &crate::dora::platformer::behavior::Tree) -> crate::dora::platformer::behavior::Tree {
		unsafe { return crate::dora::platformer::behavior::Tree::from(platformer_behavior_leaf_countdown(time, node.raw())).unwrap(); }
	}
	pub fn timeout(time: f64, node: &crate::dora::platformer::behavior::Tree) -> crate::dora::platformer::behavior::Tree {
		unsafe { return crate::dora::platformer::behavior::Tree::from(platformer_behavior_leaf_timeout(time, node.raw())).unwrap(); }
	}
	pub fn repeat(times: i32, node: &crate::dora::platformer::behavior::Tree) -> crate::dora::platformer::behavior::Tree {
		unsafe { return crate::dora::platformer::behavior::Tree::from(platformer_behavior_leaf_repeat(times, node.raw())).unwrap(); }
	}
	pub fn repeat_forever(node: &crate::dora::platformer::behavior::Tree) -> crate::dora::platformer::behavior::Tree {
		unsafe { return crate::dora::platformer::behavior::Tree::from(platformer_behavior_leaf_repeat_forever(node.raw())).unwrap(); }
	}
	pub fn retry(times: i32, node: &crate::dora::platformer::behavior::Tree) -> crate::dora::platformer::behavior::Tree {
		unsafe { return crate::dora::platformer::behavior::Tree::from(platformer_behavior_leaf_retry(times, node.raw())).unwrap(); }
	}
	pub fn retry_until_pass(node: &crate::dora::platformer::behavior::Tree) -> crate::dora::platformer::behavior::Tree {
		unsafe { return crate::dora::platformer::behavior::Tree::from(platformer_behavior_leaf_retry_until_pass(node.raw())).unwrap(); }
	}
}