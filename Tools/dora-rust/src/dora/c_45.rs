extern "C" {
	fn c45_build_decision_tree_async(data: i64, max_depth: i32, func: i32, stack: i64);
}
pub struct C45 { }
impl C45 {
	pub fn build_decision_tree_async(data: &str, max_depth: i32, mut tree_visitor: Box<dyn FnMut(f64, &str, &str, &str)>) {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			tree_visitor(stack.pop_f64().unwrap(), stack.pop_str().unwrap().as_str(), stack.pop_str().unwrap().as_str(), stack.pop_str().unwrap().as_str())
		}));
		unsafe { c45_build_decision_tree_async(crate::dora::from_string(data), max_depth, func_id, stack_raw); }
	}
}