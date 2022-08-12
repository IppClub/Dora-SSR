extern "C" {
	fn qlearner_type() -> i32;
	fn mlqlearner_update(slf: i64, state: i64, action: i32, reward: f64);
	fn mlqlearner_get_best_action(slf: i64, state: i64) -> i32;
	fn mlqlearner_visit_matrix(slf: i64, func: i32, stack: i64);
	fn mlqlearner_pack(hints: i64, values: i64) -> i64;
	fn mlqlearner_unpack(hints: i64, state: i64) -> i64;
	fn mlqlearner_new(gamma: f64, alpha: f64, max_q: f64) -> i64;
}
use crate::dora::IObject;
pub struct QLearner { raw: i64 }
crate::dora_object!(QLearner);
impl QLearner {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { qlearner_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(QLearner { raw: raw }))
			}
		})
	}
	pub fn update(&mut self, state: u64, action: u32, reward: f64) {
		unsafe { mlqlearner_update(self.raw(), state as i64, action as i32, reward); }
	}
	pub fn get_best_action(&mut self, state: u64) -> i32 {
		unsafe { return mlqlearner_get_best_action(self.raw(), state as i64); }
	}
	pub fn visit_matrix(&mut self, mut handler: Box<dyn FnMut(u64, u32, f64)>) {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			handler(stack.pop_i64().unwrap() as u64, stack.pop_i32().unwrap() as u32, stack.pop_f64().unwrap())
		}));
		unsafe { mlqlearner_visit_matrix(self.raw(), func_id, stack_raw); }
	}
	pub fn pack(hints: &Vec<i32>, values: &Vec<i32>) -> u64 {
		unsafe { return mlqlearner_pack(crate::dora::Vector::from_i32(hints), crate::dora::Vector::from_i32(values)) as u64; }
	}
	pub fn unpack(hints: &Vec<i32>, state: u64) -> Vec<i32> {
		unsafe { return crate::dora::Vector::to_i32(mlqlearner_unpack(crate::dora::Vector::from_i32(hints), state as i64)); }
	}
	pub fn new(gamma: f64, alpha: f64, max_q: f64) -> QLearner {
		unsafe { return QLearner { raw: mlqlearner_new(gamma, alpha, max_q) }; }
	}
}