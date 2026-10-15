/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn c45_build_decision_tree_async(data: i64, max_depth: i32, func0: i32, stack0: i64);
}
/// An interface for machine learning algorithms.
pub struct C45 { }
impl C45 {
	/// A function that takes CSV data as input and applies the C4.5 machine learning algorithm to build a decision tree model asynchronously.
	/// C4.5 is a decision tree algorithm that uses information gain to select the best attribute to split the data at each node of the tree. The resulting decision tree can be used to make predictions on new data.
	///
	/// # Arguments
	///
	/// * `csv_data` - The CSV training data for building the decision tree using delimiter `,`.
	/// * `max_depth` - The maximum depth of the generated decision tree. Set to 0 to prevent limiting the generated tree depth.
	/// * `handler` - The callback function to be called for each node of the generated decision tree.
	///     * `depth` - The learning accuracy value or the depth of the current node in the decision tree.
	///     * `name` - The name of the attribute used for splitting the data at the current node.
	///     * `op` - The comparison operator used for splitting the data at the current node.
	///     * `value` - The value used for splitting the data at the current node.
	pub fn build_decision_tree_async(data: &str, max_depth: i32, mut tree_visitor: Box<dyn FnMut(f64, &str, &str, &str)>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			tree_visitor(stack0.pop_f64().unwrap(), stack0.pop_str().unwrap().as_str(), stack0.pop_str().unwrap().as_str(), stack0.pop_str().unwrap().as_str())
		}));
		unsafe { c45_build_decision_tree_async(crate::dora::from_string(data), max_depth, func_id0, stack_raw0); }
	}
}