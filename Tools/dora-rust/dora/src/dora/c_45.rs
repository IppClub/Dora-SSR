extern "C" {
	fn c45_build_decision_tree_async(data: i64, max_depth: i32, func: i32, stack: i64);
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
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			tree_visitor(stack.pop_f64().unwrap(), stack.pop_str().unwrap().as_str(), stack.pop_str().unwrap().as_str(), stack.pop_str().unwrap().as_str())
		}));
		unsafe { c45_build_decision_tree_async(crate::dora::from_string(data), max_depth, func_id, stack_raw); }
	}
}