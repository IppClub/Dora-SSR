extern "C" {
	fn body_type() -> i32;
	fn body_get_world(slf: i64) -> i64;
	fn body_get_body_def(slf: i64) -> i64;
	fn body_get_mass(slf: i64) -> f32;
	fn body_is_sensor(slf: i64) -> i32;
	fn body_set_velocity_x(slf: i64, var: f32);
	fn body_get_velocity_x(slf: i64) -> f32;
	fn body_set_velocity_y(slf: i64, var: f32);
	fn body_get_velocity_y(slf: i64) -> f32;
	fn body_set_velocity(slf: i64, var: i64);
	fn body_get_velocity(slf: i64) -> i64;
	fn body_set_angular_rate(slf: i64, var: f32);
	fn body_get_angular_rate(slf: i64) -> f32;
	fn body_set_group(slf: i64, var: i32);
	fn body_get_group(slf: i64) -> i32;
	fn body_set_linear_damping(slf: i64, var: f32);
	fn body_get_linear_damping(slf: i64) -> f32;
	fn body_set_angular_damping(slf: i64, var: f32);
	fn body_get_angular_damping(slf: i64) -> f32;
	fn body_set_owner(slf: i64, var: i64);
	fn body_get_owner(slf: i64) -> i64;
	fn body_set_receiving_contact(slf: i64, var: i32);
	fn body_is_receiving_contact(slf: i64) -> i32;
	fn body_apply_linear_impulse(slf: i64, impulse: i64, pos: i64);
	fn body_apply_angular_impulse(slf: i64, impulse: f32);
	fn body_get_sensor_by_tag(slf: i64, tag: i32) -> i64;
	fn body_remove_sensor_by_tag(slf: i64, tag: i32) -> i32;
	fn body_remove_sensor(slf: i64, sensor: i64) -> i32;
	fn body_attach(slf: i64, fixture_def: i64);
	fn body_attach_sensor(slf: i64, tag: i32, fixture_def: i64) -> i64;
	fn body_on_contact_filter(slf: i64, func: i32, stack: i64);
	fn body_new(def: i64, world: i64, pos: i64, rot: f32) -> i64;
}
use crate::dora::IObject;
use crate::dora::INode;
impl INode for Body { }
pub struct Body { raw: i64 }
crate::dora_object!(Body);
impl IBody for Body { }
pub trait IBody: INode {
	fn get_world(&self) -> crate::dora::PhysicsWorld {
		return unsafe { crate::dora::PhysicsWorld::from(body_get_world(self.raw())).unwrap() };
	}
	fn get_body_def(&self) -> crate::dora::BodyDef {
		return unsafe { crate::dora::BodyDef::from(body_get_body_def(self.raw())).unwrap() };
	}
	fn get_mass(&self) -> f32 {
		return unsafe { body_get_mass(self.raw()) };
	}
	fn is_sensor(&self) -> bool {
		return unsafe { body_is_sensor(self.raw()) != 0 };
	}
	fn set_velocity_x(&mut self, var: f32) {
		unsafe { body_set_velocity_x(self.raw(), var) };
	}
	fn get_velocity_x(&self) -> f32 {
		return unsafe { body_get_velocity_x(self.raw()) };
	}
	fn set_velocity_y(&mut self, var: f32) {
		unsafe { body_set_velocity_y(self.raw(), var) };
	}
	fn get_velocity_y(&self) -> f32 {
		return unsafe { body_get_velocity_y(self.raw()) };
	}
	fn set_velocity(&mut self, var: &crate::dora::Vec2) {
		unsafe { body_set_velocity(self.raw(), var.into_i64()) };
	}
	fn get_velocity(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(body_get_velocity(self.raw())) };
	}
	fn set_angular_rate(&mut self, var: f32) {
		unsafe { body_set_angular_rate(self.raw(), var) };
	}
	fn get_angular_rate(&self) -> f32 {
		return unsafe { body_get_angular_rate(self.raw()) };
	}
	fn set_group(&mut self, var: i32) {
		unsafe { body_set_group(self.raw(), var) };
	}
	fn get_group(&self) -> i32 {
		return unsafe { body_get_group(self.raw()) };
	}
	fn set_linear_damping(&mut self, var: f32) {
		unsafe { body_set_linear_damping(self.raw(), var) };
	}
	fn get_linear_damping(&self) -> f32 {
		return unsafe { body_get_linear_damping(self.raw()) };
	}
	fn set_angular_damping(&mut self, var: f32) {
		unsafe { body_set_angular_damping(self.raw(), var) };
	}
	fn get_angular_damping(&self) -> f32 {
		return unsafe { body_get_angular_damping(self.raw()) };
	}
	fn set_owner(&mut self, var: &dyn crate::dora::IObject) {
		unsafe { body_set_owner(self.raw(), var.raw()) };
	}
	fn get_owner(&self) -> crate::dora::Object {
		return unsafe { crate::dora::Object::from(body_get_owner(self.raw())).unwrap() };
	}
	fn set_receiving_contact(&mut self, var: bool) {
		unsafe { body_set_receiving_contact(self.raw(), if var { 1 } else { 0 }) };
	}
	fn is_receiving_contact(&self) -> bool {
		return unsafe { body_is_receiving_contact(self.raw()) != 0 };
	}
	fn apply_linear_impulse(&mut self, impulse: &crate::dora::Vec2, pos: &crate::dora::Vec2) {
		unsafe { body_apply_linear_impulse(self.raw(), impulse.into_i64(), pos.into_i64()); }
	}
	fn apply_angular_impulse(&mut self, impulse: f32) {
		unsafe { body_apply_angular_impulse(self.raw(), impulse); }
	}
	fn get_sensor_by_tag(&mut self, tag: i32) -> crate::dora::Sensor {
		unsafe { return crate::dora::Sensor::from(body_get_sensor_by_tag(self.raw(), tag)).unwrap(); }
	}
	fn remove_sensor_by_tag(&mut self, tag: i32) -> bool {
		unsafe { return body_remove_sensor_by_tag(self.raw(), tag) != 0; }
	}
	fn remove_sensor(&mut self, sensor: &crate::dora::Sensor) -> bool {
		unsafe { return body_remove_sensor(self.raw(), sensor.raw()) != 0; }
	}
	fn attach(&mut self, fixture_def: &crate::dora::FixtureDef) {
		unsafe { body_attach(self.raw(), fixture_def.raw()); }
	}
	fn attach_sensor(&mut self, tag: i32, fixture_def: &crate::dora::FixtureDef) -> crate::dora::Sensor {
		unsafe { return crate::dora::Sensor::from(body_attach_sensor(self.raw(), tag, fixture_def.raw())).unwrap(); }
	}
	fn on_contact_filter(&mut self, mut filter: Box<dyn FnMut(&dyn crate::dora::IBody) -> bool>) {
		let mut stack = crate::dora::CallStack::new();
		let stack_raw = stack.raw();
		let func_id = crate::dora::push_function(Box::new(move || {
			let result = filter(&stack.pop_cast::<crate::dora::Body>().unwrap());
			stack.push_bool(result);
		}));
		unsafe { body_on_contact_filter(self.raw(), func_id, stack_raw); }
	}
}
impl Body {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { body_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Body { raw: raw }))
			}
		})
	}
	pub fn new(def: &crate::dora::BodyDef, world: &dyn crate::dora::IPhysicsWorld, pos: &crate::dora::Vec2, rot: f32) -> Body {
		unsafe { return Body { raw: body_new(def.raw(), world.raw(), pos.into_i64(), rot) }; }
	}
}