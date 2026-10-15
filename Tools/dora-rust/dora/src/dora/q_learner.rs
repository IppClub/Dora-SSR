/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn qlearner_type() -> i32;
	fn mlqlearner_update(slf: i64, state: i64, action: i32, reward: f64);
	fn mlqlearner_get_best_action(slf: i64, state: i64) -> i32;
	fn mlqlearner_visit_matrix(slf: i64, func0: i32, stack0: i64);
	fn mlqlearner_pack(hints: i64, values: i64) -> i64;
	fn mlqlearner_unpack(hints: i64, state: i64) -> i64;
	fn mlqlearner_new(gamma: f64, alpha: f64, max_q: f64) -> i64;
}
use crate::dora::IObject;
/// A simple reinforcement learning framework that can be used to learn optimal policies for Markov decision processes using Q-learning. Q-learning is a model-free reinforcement learning algorithm that learns an optimal action-value function from experience by repeatedly updating estimates of the Q-value of state-action pairs.
pub struct QLearner { raw: i64 }
crate::dora_object!(QLearner);
impl QLearner {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { qlearner_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(QLearner { raw: raw }))
			}
		})
	}
	/// Updates Q-value for a state-action pair based on received reward.
	///
	/// # Arguments
	///
	/// * `state` - An integer representing the state.
	/// * `action` - An integer representing the action.
	/// * `reward` - A number representing the reward received for the action in the state.
	pub fn update(&mut self, state: u64, action: u32, reward: f64) {
		unsafe { mlqlearner_update(self.raw(), state as i64, action as i32, reward); }
	}
	/// Returns the best action for a given state based on the current Q-values.
	///
	/// # Arguments
	///
	/// * `state` - The current state.
	///
	/// # Returns
	///
	/// * `i32` - The action with the highest Q-value for the given state.
	pub fn get_best_action(&mut self, state: u64) -> i32 {
		unsafe { return mlqlearner_get_best_action(self.raw(), state as i64); }
	}
	/// Visits all state-action pairs and calls the provided handler function for each pair.
	///
	/// # Arguments
	///
	/// * `handler` - A function that is called for each state-action pair.
	pub fn visit_matrix(&mut self, mut handler: Box<dyn FnMut(u64, u32, f64)>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			handler(stack0.pop_i64().unwrap() as u64, stack0.pop_i32().unwrap() as u32, stack0.pop_f64().unwrap())
		}));
		unsafe { mlqlearner_visit_matrix(self.raw(), func_id0, stack_raw0); }
	}
	/// Constructs a state from given hints and condition values.
	///
	/// # Arguments
	///
	/// * `hints` - A vector of integers representing the byte length of provided values.
	/// * `values` - The condition values as discrete values.
	///
	/// # Returns
	///
	/// * `i64` - The packed state value.
	pub fn pack(hints: &Vec<i32>, values: &Vec<i32>) -> u64 {
		unsafe { return mlqlearner_pack(crate::dora::Vector::from_num(hints), crate::dora::Vector::from_num(values)) as u64; }
	}
	/// Deconstructs a state from given hints to get condition values.
	///
	/// # Arguments
	///
	/// * `hints` - A vector of integers representing the byte length of provided values.
	/// * `state` - The state integer to unpack.
	///
	/// # Returns
	///
	/// * `Vec<i32>` - The condition values as discrete values.
	pub fn unpack(hints: &Vec<i32>, state: u64) -> Vec<i32> {
		unsafe { return crate::dora::Vector::to_num(mlqlearner_unpack(crate::dora::Vector::from_num(hints), state as i64)); }
	}
	/// Creates a new QLearner object with optional parameters for gamma, alpha, and maxQ.
	///
	/// # Arguments
	///
	/// * `gamma` - The discount factor for future rewards.
	/// * `alpha` - The learning rate for updating Q-values.
	/// * `maxQ` - The maximum Q-value. Defaults to 100.0.
	///
	/// # Returns
	///
	/// * `QLearner` - The newly created QLearner object.
	pub fn new(gamma: f64, alpha: f64, max_q: f64) -> QLearner {
		unsafe { return QLearner { raw: mlqlearner_new(gamma, alpha, max_q) }; }
	}
}