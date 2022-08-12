extern "C" {
	fn platformer_actionupdate_release(raw: i64);
	fn platformer_wasmactionupdate_new(func: i32, stack: i64) -> i64;
}
pub struct ActionUpdate { raw: i64 }
impl Drop for ActionUpdate {
	fn drop(&mut self) { unsafe { platformer_actionupdate_release(self.raw); } }
}
impl ActionUpdate {
	pub fn raw(&self) -> i64 {
		self.raw
	}
	pub fn from(raw: i64) -> ActionUpdate {
		ActionUpdate { raw: raw }
	}
	pub fn new(mut update: Box<dyn FnMut(&crate::dora::platformer::Unit, &crate::dora::platformer::UnitAction, f32) -> bool>) -> crate::dora::platformer::ActionUpdate {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			let result = update(&stack.pop_cast::<crate::dora::platformer::Unit>().unwrap(), &crate::dora::platformer::UnitAction::from(stack.pop_i64().unwrap()).unwrap(), stack.pop_f32().unwrap());
			stack.push_bool(result);
		}));
		unsafe { return crate::dora::platformer::ActionUpdate::from(platformer_wasmactionupdate_new(func_id, stack_raw)); }
	}
}