extern "C" {
	fn scheduler_type() -> i32;
	fn scheduler_set_time_scale(slf: i64, var: f32);
	fn scheduler_get_time_scale(slf: i64) -> f32;
	fn scheduler_schedule(slf: i64, func: i32, stack: i64);
	fn scheduler_new() -> i64;
}
use crate::dora::IObject;
pub struct Scheduler { raw: i64 }
crate::dora_object!(Scheduler);
impl Scheduler {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { scheduler_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Scheduler { raw: raw }))
			}
		})
	}
	pub fn set_time_scale(&mut self, var: f32) {
		unsafe { scheduler_set_time_scale(self.raw(), var) };
	}
	pub fn get_time_scale(&self) -> f32 {
		return unsafe { scheduler_get_time_scale(self.raw()) };
	}
	pub fn schedule(&mut self, mut func: Box<dyn FnMut(f64) -> bool>) {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			let result = func(stack.pop_f64().unwrap());
			stack.push_bool(result);
		}));
		unsafe { scheduler_schedule(self.raw(), func_id, stack_raw); }
	}
	pub fn new() -> Scheduler {
		unsafe { return Scheduler { raw: scheduler_new() }; }
	}
}