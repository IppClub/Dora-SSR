extern "C" {
	fn scheduler_type() -> i32;
	fn scheduler_set_time_scale(slf: i64, var: f32);
	fn scheduler_get_time_scale(slf: i64) -> f32;
	fn scheduler_set_fixed_fps(slf: i64, var: i32);
	fn scheduler_get_fixed_fps(slf: i64) -> i32;
	fn scheduler_schedule(slf: i64, func: i32, stack: i64);
	fn scheduler_new() -> i64;
}
use crate::dora::IObject;
/// A scheduler that manages the execution of scheduled tasks.
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
	/// Sets the time scale factor for the scheduler.
	/// This factor is applied to deltaTime that the scheduled functions will receive.
	pub fn set_time_scale(&mut self, var: f32) {
		unsafe { scheduler_set_time_scale(self.raw(), var) };
	}
	/// Gets the time scale factor for the scheduler.
	/// This factor is applied to deltaTime that the scheduled functions will receive.
	pub fn get_time_scale(&self) -> f32 {
		return unsafe { scheduler_get_time_scale(self.raw()) };
	}
	/// Sets the target frame rate (in frames per second) for a fixed update mode.
	/// The fixed update will ensure a constant frame rate, and the operation handled in a fixed update can use a constant delta time value.
	/// It is used for preventing weird behavior of a physics engine or synchronizing some states via network communications.
	pub fn set_fixed_fps(&mut self, var: i32) {
		unsafe { scheduler_set_fixed_fps(self.raw(), var) };
	}
	/// Gets the target frame rate (in frames per second) for a fixed update mode.
	/// The fixed update will ensure a constant frame rate, and the operation handled in a fixed update can use a constant delta time value.
	/// It is used for preventing weird behavior of a physics engine or synchronizing some states via network communications.
	pub fn get_fixed_fps(&self) -> i32 {
		return unsafe { scheduler_get_fixed_fps(self.raw()) };
	}
	/// Schedules a function to be called every frame.
	///
	/// # Arguments
	///
	/// * `handler` - The function to be called. It should take a single argument of type `f64`, which represents the delta time since the last frame. If the function returns `true`, it will not be called again.
	pub fn schedule(&mut self, mut func: Box<dyn FnMut(f64) -> bool>) {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			let result = func(stack.pop_f64().unwrap());
			stack.push_bool(result);
		}));
		unsafe { scheduler_schedule(self.raw(), func_id, stack_raw); }
	}
	/// Creates a new Scheduler object.
	pub fn new() -> Scheduler {
		unsafe { return Scheduler { raw: scheduler_new() }; }
	}
}