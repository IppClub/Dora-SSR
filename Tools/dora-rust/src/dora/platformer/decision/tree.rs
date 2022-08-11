extern "C" {
	fn platformer_decision_tree_type() -> i32;
	fn platformer_decision_leaf_sel(nodes: i64) -> i64;
	fn platformer_decision_leaf_seq(nodes: i64) -> i64;
	fn platformer_decision_leaf_con(name: i64, func: i32, stack: i64) -> i64;
	fn platformer_decision_leaf_act(action: i64) -> i64;
	fn platformer_decision_leaf_act_dynamic(func: i32, stack: i64) -> i64;
	fn platformer_decision_leaf_accept() -> i64;
	fn platformer_decision_leaf_reject() -> i64;
	fn platformer_decision_leaf_behave(name: i64, root: i64) -> i64;
}
use crate::dora::IObject;
pub struct Tree { raw: i64 }
crate::dora_object!(Tree);
impl Tree {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { platformer_decision_tree_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Tree { raw: raw }))
			}
		})
	}
	pub fn sel(nodes: &Vec<crate::dora::platformer::decision::Tree>) -> crate::dora::platformer::decision::Tree {
		unsafe { return crate::dora::platformer::decision::Tree::from(platformer_decision_leaf_sel(crate::dora::Vector::from_dtree(nodes))).unwrap(); }
	}
	pub fn seq(nodes: &Vec<crate::dora::platformer::decision::Tree>) -> crate::dora::platformer::decision::Tree {
		unsafe { return crate::dora::platformer::decision::Tree::from(platformer_decision_leaf_seq(crate::dora::Vector::from_dtree(nodes))).unwrap(); }
	}
	pub fn con(name: &str, mut handler: Box<dyn FnMut(&crate::dora::platformer::Unit) -> bool>) -> crate::dora::platformer::decision::Tree {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			let result = handler(&stack.pop_cast::<crate::dora::platformer::Unit>().unwrap());
			stack.push_bool(result);
		}));
		unsafe { return crate::dora::platformer::decision::Tree::from(platformer_decision_leaf_con(crate::dora::from_string(name), func_id, stack_raw)).unwrap(); }
	}
	pub fn act(action: &str) -> crate::dora::platformer::decision::Tree {
		unsafe { return crate::dora::platformer::decision::Tree::from(platformer_decision_leaf_act(crate::dora::from_string(action))).unwrap(); }
	}
	pub fn act_dynamic(mut handler: Box<dyn FnMut(&crate::dora::platformer::Unit) -> String>) -> crate::dora::platformer::decision::Tree {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			let result = handler(&stack.pop_cast::<crate::dora::platformer::Unit>().unwrap());
			stack.push_str(result.as_str());
		}));
		unsafe { return crate::dora::platformer::decision::Tree::from(platformer_decision_leaf_act_dynamic(func_id, stack_raw)).unwrap(); }
	}
	pub fn accept() -> crate::dora::platformer::decision::Tree {
		unsafe { return crate::dora::platformer::decision::Tree::from(platformer_decision_leaf_accept()).unwrap(); }
	}
	pub fn reject() -> crate::dora::platformer::decision::Tree {
		unsafe { return crate::dora::platformer::decision::Tree::from(platformer_decision_leaf_reject()).unwrap(); }
	}
	pub fn behave(name: &str, root: &crate::dora::platformer::behavior::Tree) -> crate::dora::platformer::decision::Tree {
		unsafe { return crate::dora::platformer::decision::Tree::from(platformer_decision_leaf_behave(crate::dora::from_string(name), root.raw())).unwrap(); }
	}
}