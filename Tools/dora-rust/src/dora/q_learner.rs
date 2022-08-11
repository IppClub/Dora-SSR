extern "C" {
	fn qlearner_type() -> i32;
	fn mlqlearner_update(slf: i64, state: i64, action: i32, reward: f64);
	fn mlqlearner_get_best_action(slf: i64, state: i64) -> i32;
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
	pub fn update(&mut self, state: i64, action: i32, reward: f64) {
		unsafe { mlqlearner_update(self.raw(), state, action, reward); }
	}
	pub fn get_best_action(&mut self, state: i64) -> i32 {
		unsafe { return mlqlearner_get_best_action(self.raw(), state); }
	}
	pub fn new(gamma: f64, alpha: f64, max_q: f64) -> QLearner {
		unsafe { return QLearner { raw: mlqlearner_new(gamma, alpha, max_q) }; }
	}
}