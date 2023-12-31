extern "C" {
	fn platformer_unitaction_set_reaction(slf: i64, var: f32);
	fn platformer_unitaction_get_reaction(slf: i64) -> f32;
	fn platformer_unitaction_set_recovery(slf: i64, var: f32);
	fn platformer_unitaction_get_recovery(slf: i64) -> f32;
	fn platformer_unitaction_get_name(slf: i64) -> i64;
	fn platformer_unitaction_is_doing(slf: i64) -> i32;
	fn platformer_unitaction_get_owner(slf: i64) -> i64;
	fn platformer_unitaction_get_elapsed_time(slf: i64) -> f32;
	fn platformer_unitaction_clear();
	fn platformer_unitaction_add(name: i64, priority: i32, reaction: f32, recovery: f32, queued: i32, func: i32, stack: i64, func1: i32, stack1: i64, func2: i32, stack2: i64);
}
pub struct UnitAction { raw: i64 }
impl UnitAction {
	pub fn from(raw: i64) -> Option<UnitAction> {
		match raw {
			0 => None,
			_ => Some(UnitAction { raw: raw })
		}
	}
	pub fn raw(&self) -> i64 { self.raw }
	pub fn set_reaction(&mut self, var: f32) {
		unsafe { platformer_unitaction_set_reaction(self.raw(), var) };
	}
	pub fn get_reaction(&self) -> f32 {
		return unsafe { platformer_unitaction_get_reaction(self.raw()) };
	}
	pub fn set_recovery(&mut self, var: f32) {
		unsafe { platformer_unitaction_set_recovery(self.raw(), var) };
	}
	pub fn get_recovery(&self) -> f32 {
		return unsafe { platformer_unitaction_get_recovery(self.raw()) };
	}
	pub fn get_name(&self) -> String {
		return unsafe { crate::dora::to_string(platformer_unitaction_get_name(self.raw())) };
	}
	pub fn is_doing(&self) -> bool {
		return unsafe { platformer_unitaction_is_doing(self.raw()) != 0 };
	}
	pub fn get_owner(&self) -> crate::dora::platformer::Unit {
		return unsafe { crate::dora::platformer::Unit::from(platformer_unitaction_get_owner(self.raw())).unwrap() };
	}
	pub fn get_elapsed_time(&self) -> f32 {
		return unsafe { platformer_unitaction_get_elapsed_time(self.raw()) };
	}
	pub fn clear() {
		unsafe { platformer_unitaction_clear(); }
	}
	pub fn add(name: &str, priority: i32, reaction: f32, recovery: f32, queued: bool, mut available: Box<dyn FnMut(&crate::dora::platformer::Unit, &crate::dora::platformer::UnitAction) -> bool>, mut create: Box<dyn FnMut(&crate::dora::platformer::Unit, &crate::dora::platformer::UnitAction) -> crate::dora::platformer::ActionUpdate>, mut stop: Box<dyn FnMut(&crate::dora::platformer::Unit, &crate::dora::platformer::UnitAction)>) {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			let result = available(&stack.pop_cast::<crate::dora::platformer::Unit>().unwrap(), &crate::dora::platformer::UnitAction::from(stack.pop_i64().unwrap()).unwrap());
			stack.push_bool(result);
		}));
		let mut stack1 = crate::dora::CallStack::new();
		let stack_raw1 = stack1.raw();
		let func_id1 = crate::dora::push_function(Box::new(move || {
			let result = create(&stack1.pop_cast::<crate::dora::platformer::Unit>().unwrap(), &crate::dora::platformer::UnitAction::from(stack1.pop_i64().unwrap()).unwrap());
			stack1.push_i64(result.raw());
		}));
		let mut stack2 = crate::dora::CallStack::new();
		let stack_raw2 = stack2.raw();
		let func_id2 = crate::dora::push_function(Box::new(move || {
			stop(&stack2.pop_cast::<crate::dora::platformer::Unit>().unwrap(), &crate::dora::platformer::UnitAction::from(stack2.pop_i64().unwrap()).unwrap())
		}));
		unsafe { platformer_unitaction_add(crate::dora::from_string(name), priority, reaction, recovery, if queued { 1 } else { 0 }, func_id, stack_raw, func_id1, stack_raw1, func_id2, stack_raw2); }
	}
}