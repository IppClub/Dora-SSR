extern "C" {
	fn platformer_behavior_tree_type() -> i32;
	fn platformer_behavior_leaf_seq(nodes: i64) -> i64;
	fn platformer_behavior_leaf_sel(nodes: i64) -> i64;
	fn platformer_behavior_leaf_con(name: i64, func: i32, stack: i64) -> i64;
	fn platformer_behavior_leaf_act(action_name: i64) -> i64;
	fn platformer_behavior_leaf_command(action_name: i64) -> i64;
	fn platformer_behavior_leaf_wait(duration: f64) -> i64;
	fn platformer_behavior_leaf_countdown(time: f64, node: i64) -> i64;
	fn platformer_behavior_leaf_timeout(time: f64, node: i64) -> i64;
	fn platformer_behavior_leaf_repeat(times: i32, node: i64) -> i64;
	fn platformer_behavior_leaf_repeat_forever(node: i64) -> i64;
	fn platformer_behavior_leaf_retry(times: i32, node: i64) -> i64;
	fn platformer_behavior_leaf_retry_until_pass(node: i64) -> i64;
}
use crate::dora::IObject;
/// A behavior tree framework for creating game AI structures.
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
	/// Creates a new sequence node that executes an array of child nodes in order.
	///
	/// # Arguments
	///
	/// * `nodes` - A vector of child nodes.
	///
	/// # Returns
	///
	/// * `Leaf` - A new sequence node.
	pub fn seq(nodes: &Vec<crate::dora::platformer::behavior::Tree>) -> crate::dora::platformer::behavior::Tree {
		unsafe { return crate::dora::platformer::behavior::Tree::from(platformer_behavior_leaf_seq(crate::dora::Vector::from_btree(nodes))).unwrap(); }
	}
	/// Creates a new selector node that selects and executes one of its child nodes that will succeed.
	///
	/// # Arguments
	///
	/// * `nodes` - A vector of child nodes.
	///
	/// # Returns
	///
	/// * `Leaf` - A new selector node.
	pub fn sel(nodes: &Vec<crate::dora::platformer::behavior::Tree>) -> crate::dora::platformer::behavior::Tree {
		unsafe { return crate::dora::platformer::behavior::Tree::from(platformer_behavior_leaf_sel(crate::dora::Vector::from_btree(nodes))).unwrap(); }
	}
	/// Creates a new condition node that executes a check handler function when executed.
	///
	/// # Arguments
	///
	/// * `name` - The name of the condition.
	/// * `check` - A function that takes a blackboard object and returns a boolean value.
	///
	/// # Returns
	///
	/// * `Leaf` - A new condition node.
	pub fn con(name: &str, mut handler: Box<dyn FnMut(&crate::dora::platformer::behavior::Blackboard) -> bool>) -> crate::dora::platformer::behavior::Tree {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			let result = handler(&crate::dora::platformer::behavior::Blackboard::from(stack.pop_i64().unwrap()).unwrap());
			stack.push_bool(result);
		}));
		unsafe { return crate::dora::platformer::behavior::Tree::from(platformer_behavior_leaf_con(crate::dora::from_string(name), func_id, stack_raw)).unwrap(); }
	}
	/// Creates a new action node that executes an action when executed.
	/// This node will block the execution until the action finishes.
	///
	/// # Arguments
	///
	/// * `action_name` - The name of the action to execute.
	///
	/// # Returns
	///
	/// * `Leaf` - A new action node.
	pub fn act(action_name: &str) -> crate::dora::platformer::behavior::Tree {
		unsafe { return crate::dora::platformer::behavior::Tree::from(platformer_behavior_leaf_act(crate::dora::from_string(action_name))).unwrap(); }
	}
	/// Creates a new command node that executes a command when executed.
	/// This node will return right after the action starts.
	///
	/// # Arguments
	///
	/// * `action_name` - The name of the command to execute.
	///
	/// # Returns
	///
	/// * `Leaf` - A new command node.
	pub fn command(action_name: &str) -> crate::dora::platformer::behavior::Tree {
		unsafe { return crate::dora::platformer::behavior::Tree::from(platformer_behavior_leaf_command(crate::dora::from_string(action_name))).unwrap(); }
	}
	/// Creates a new wait node that waits for a specified duration when executed.
	///
	/// # Arguments
	///
	/// * `duration` - The duration to wait in seconds.
	///
	/// # Returns
	///
	/// * A new wait node of type `Leaf`.
	pub fn wait(duration: f64) -> crate::dora::platformer::behavior::Tree {
		unsafe { return crate::dora::platformer::behavior::Tree::from(platformer_behavior_leaf_wait(duration)).unwrap(); }
	}
	/// Creates a new countdown node that executes a child node continuously until a timer runs out.
	///
	/// # Arguments
	///
	/// * `time` - The time limit in seconds.
	/// * `node` - The child node to execute.
	///
	/// # Returns
	///
	/// * A new countdown node of type `Leaf`.
	pub fn countdown(time: f64, node: &crate::dora::platformer::behavior::Tree) -> crate::dora::platformer::behavior::Tree {
		unsafe { return crate::dora::platformer::behavior::Tree::from(platformer_behavior_leaf_countdown(time, node.raw())).unwrap(); }
	}
	/// Creates a new timeout node that executes a child node until a timer runs out.
	///
	/// # Arguments
	///
	/// * `time` - The time limit in seconds.
	/// * `node` - The child node to execute.
	///
	/// # Returns
	///
	/// * A new timeout node of type `Leaf`.
	pub fn timeout(time: f64, node: &crate::dora::platformer::behavior::Tree) -> crate::dora::platformer::behavior::Tree {
		unsafe { return crate::dora::platformer::behavior::Tree::from(platformer_behavior_leaf_timeout(time, node.raw())).unwrap(); }
	}
	/// Creates a new repeat node that executes a child node a specified number of times.
	///
	/// # Arguments
	///
	/// * `times` - The number of times to execute the child node.
	/// * `node` - The child node to execute.
	///
	/// # Returns
	///
	/// * A new repeat node of type `Leaf`.
	pub fn repeat(times: i32, node: &crate::dora::platformer::behavior::Tree) -> crate::dora::platformer::behavior::Tree {
		unsafe { return crate::dora::platformer::behavior::Tree::from(platformer_behavior_leaf_repeat(times, node.raw())).unwrap(); }
	}
	/// Creates a new repeat node that executes a child node repeatedly.
	///
	/// # Arguments
	///
	/// * `node` - The child node to execute.
	///
	/// # Returns
	///
	/// * A new repeat node of type `Leaf`.
	pub fn repeat_forever(node: &crate::dora::platformer::behavior::Tree) -> crate::dora::platformer::behavior::Tree {
		unsafe { return crate::dora::platformer::behavior::Tree::from(platformer_behavior_leaf_repeat_forever(node.raw())).unwrap(); }
	}
	/// Creates a new retry node that executes a child node repeatedly until it succeeds or a maximum number of retries is reached.
	///
	/// # Arguments
	///
	/// * `times` - The maximum number of retries.
	/// * `node` - The child node to execute.
	///
	/// # Returns
	///
	/// * A new retry node of type `Leaf`.
	pub fn retry(times: i32, node: &crate::dora::platformer::behavior::Tree) -> crate::dora::platformer::behavior::Tree {
		unsafe { return crate::dora::platformer::behavior::Tree::from(platformer_behavior_leaf_retry(times, node.raw())).unwrap(); }
	}
	/// Creates a new retry node that executes a child node repeatedly until it succeeds.
	///
	/// # Arguments
	///
	/// * `node` - The child node to execute.
	///
	/// # Returns
	///
	/// * A new retry node of type `Leaf`.
	pub fn retry_until_pass(node: &crate::dora::platformer::behavior::Tree) -> crate::dora::platformer::behavior::Tree {
		unsafe { return crate::dora::platformer::behavior::Tree::from(platformer_behavior_leaf_retry_until_pass(node.raw())).unwrap(); }
	}
}