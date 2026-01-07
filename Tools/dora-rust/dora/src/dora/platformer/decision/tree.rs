/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn platformer_decision_tree_type() -> i32;
	fn platformer_decision_leaf_sel(nodes: i64) -> i64;
	fn platformer_decision_leaf_seq(nodes: i64) -> i64;
	fn platformer_decision_leaf_con(name: i64, func0: i32, stack0: i64) -> i64;
	fn platformer_decision_leaf_act(action_name: i64) -> i64;
	fn platformer_decision_leaf_act_dynamic(func0: i32, stack0: i64) -> i64;
	fn platformer_decision_leaf_accept() -> i64;
	fn platformer_decision_leaf_reject() -> i64;
	fn platformer_decision_leaf_behave(name: i64, root: i64) -> i64;
}
use crate::dora::IObject;
/// A decision tree framework for creating game AI structures.
pub struct Tree { raw: i64 }
crate::dora_object!(Tree);
impl Tree {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { platformer_decision_tree_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Tree { raw: raw }))
			}
		})
	}
	/// Creates a selector node with the specified child nodes.
	///
	/// A selector node will go through the child nodes until one succeeds.
	///
	/// # Arguments
	///
	/// * `nodes` - An array of `Leaf` nodes.
	///
	/// # Returns
	///
	/// * A `Leaf` node that represents a selector.
	pub fn sel(nodes: &Vec<crate::dora::platformer::decision::Tree>) -> crate::dora::platformer::decision::Tree {
		unsafe { return crate::dora::platformer::decision::Tree::from(platformer_decision_leaf_sel(crate::dora::Vector::from_dtree(nodes))).unwrap(); }
	}
	/// Creates a sequence node with the specified child nodes.
	///
	/// A sequence node will go through the child nodes until all nodes succeed.
	///
	/// # Arguments
	///
	/// * `nodes` - An array of `Leaf` nodes.
	///
	/// # Returns
	///
	/// * A `Leaf` node that represents a sequence.
	pub fn seq(nodes: &Vec<crate::dora::platformer::decision::Tree>) -> crate::dora::platformer::decision::Tree {
		unsafe { return crate::dora::platformer::decision::Tree::from(platformer_decision_leaf_seq(crate::dora::Vector::from_dtree(nodes))).unwrap(); }
	}
	/// Creates a condition node with the specified name and handler function.
	///
	/// # Arguments
	///
	/// * `name` - The name of the condition.
	/// * `check` - The check function that takes a `Unit` parameter and returns a boolean result.
	///
	/// # Returns
	///
	/// * A `Leaf` node that represents a condition check.
	pub fn con(name: &str, mut handler: Box<dyn FnMut(&crate::dora::platformer::Unit) -> bool>) -> crate::dora::platformer::decision::Tree {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			let result = handler(&stack0.pop_cast::<crate::dora::platformer::Unit>().unwrap());
			stack0.push_bool(result);
		}));
		unsafe { return crate::dora::platformer::decision::Tree::from(platformer_decision_leaf_con(crate::dora::from_string(name), func_id0, stack_raw0)).unwrap(); }
	}
	/// Creates an action node with the specified action name.
	///
	/// # Arguments
	///
	/// * `action_name` - The name of the action to perform.
	///
	/// # Returns
	///
	/// * A `Leaf` node that represents an action.
	pub fn act(action_name: &str) -> crate::dora::platformer::decision::Tree {
		unsafe { return crate::dora::platformer::decision::Tree::from(platformer_decision_leaf_act(crate::dora::from_string(action_name))).unwrap(); }
	}
	/// Creates an action node with the specified handler function.
	///
	/// # Arguments
	///
	/// * `handler` - The handler function that takes a `Unit` parameter which is the running AI agent and returns an action.
	///
	/// # Returns
	///
	/// * A `Leaf` node that represents an action.
	pub fn act_dynamic(mut handler: Box<dyn FnMut(&crate::dora::platformer::Unit) -> String>) -> crate::dora::platformer::decision::Tree {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			let result = handler(&stack0.pop_cast::<crate::dora::platformer::Unit>().unwrap());
			stack0.push_str(result.as_str());
		}));
		unsafe { return crate::dora::platformer::decision::Tree::from(platformer_decision_leaf_act_dynamic(func_id0, stack_raw0)).unwrap(); }
	}
	/// Creates a leaf node that represents accepting the current behavior tree.
	///
	/// Always get success result from this node.
	///
	/// # Returns
	///
	/// * A `Leaf` node.
	pub fn accept() -> crate::dora::platformer::decision::Tree {
		unsafe { return crate::dora::platformer::decision::Tree::from(platformer_decision_leaf_accept()).unwrap(); }
	}
	/// Creates a leaf node that represents rejecting the current behavior tree.
	///
	/// Always get failure result from this node.
	///
	/// # Returns
	///
	/// * A `Leaf` node.
	pub fn reject() -> crate::dora::platformer::decision::Tree {
		unsafe { return crate::dora::platformer::decision::Tree::from(platformer_decision_leaf_reject()).unwrap(); }
	}
	/// Creates a leaf node with the specified behavior tree as its root.
	///
	/// It is possible to include a Behavior Tree as a node in a Decision Tree by using the Behave() function. This allows the AI to use a combination of decision-making and behavior execution to achieve its goals.
	///
	/// # Arguments
	///
	/// * `name` - The name of the behavior tree.
	/// * `root` - The root node of the behavior tree.
	///
	/// # Returns
	///
	/// * A `Leaf` node.
	pub fn behave(name: &str, root: &crate::dora::platformer::behavior::Tree) -> crate::dora::platformer::decision::Tree {
		unsafe { return crate::dora::platformer::decision::Tree::from(platformer_decision_leaf_behave(crate::dora::from_string(name), root.raw())).unwrap(); }
	}
}