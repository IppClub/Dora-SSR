/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn body_type() -> i32;
	fn body_get_world(slf: i64) -> i64;
	fn body_get_body_def(slf: i64) -> i64;
	fn body_get_mass(slf: i64) -> f32;
	fn body_is_sensor(slf: i64) -> i32;
	fn body_set_velocity_x(slf: i64, val: f32);
	fn body_get_velocity_x(slf: i64) -> f32;
	fn body_set_velocity_y(slf: i64, val: f32);
	fn body_get_velocity_y(slf: i64) -> f32;
	fn body_set_velocity(slf: i64, val: i64);
	fn body_get_velocity(slf: i64) -> i64;
	fn body_set_angular_rate(slf: i64, val: f32);
	fn body_get_angular_rate(slf: i64) -> f32;
	fn body_set_group(slf: i64, val: i32);
	fn body_get_group(slf: i64) -> i32;
	fn body_set_linear_damping(slf: i64, val: f32);
	fn body_get_linear_damping(slf: i64) -> f32;
	fn body_set_angular_damping(slf: i64, val: f32);
	fn body_get_angular_damping(slf: i64) -> f32;
	fn body_set_owner(slf: i64, val: i64);
	fn body_get_owner(slf: i64) -> i64;
	fn body_set_receiving_contact(slf: i64, val: i32);
	fn body_is_receiving_contact(slf: i64) -> i32;
	fn body_apply_linear_impulse(slf: i64, impulse: i64, pos: i64);
	fn body_apply_angular_impulse(slf: i64, impulse: f32);
	fn body_get_sensor_by_tag(slf: i64, tag: i32) -> i64;
	fn body_remove_sensor_by_tag(slf: i64, tag: i32) -> i32;
	fn body_remove_sensor(slf: i64, sensor: i64) -> i32;
	fn body_attach(slf: i64, fixture_def: i64);
	fn body_attach_sensor(slf: i64, tag: i32, fixture_def: i64) -> i64;
	fn body_on_contact_filter(slf: i64, func0: i32, stack0: i64);
	fn body_new(def: i64, world: i64, pos: i64, rot: f32) -> i64;
}
use crate::dora::IObject;
use crate::dora::INode;
impl INode for Body { }
/// A struct represents a physics body in the world.
pub struct Body { raw: i64 }
crate::dora_object!(Body);
impl IBody for Body { }
pub trait IBody: INode {
	/// Gets the physics world that the body belongs to.
	fn get_world(&self) -> crate::dora::PhysicsWorld {
		return unsafe { crate::dora::PhysicsWorld::from(body_get_world(self.raw())).unwrap() };
	}
	/// Gets the definition of the body.
	fn get_body_def(&self) -> crate::dora::BodyDef {
		return unsafe { crate::dora::BodyDef::from(body_get_body_def(self.raw())).unwrap() };
	}
	/// Gets the mass of the body.
	fn get_mass(&self) -> f32 {
		return unsafe { body_get_mass(self.raw()) };
	}
	/// Gets whether the body is used as a sensor or not.
	fn is_sensor(&self) -> bool {
		return unsafe { body_is_sensor(self.raw()) != 0 };
	}
	/// Sets the x-axis velocity of the body.
	fn set_velocity_x(&mut self, val: f32) {
		unsafe { body_set_velocity_x(self.raw(), val) };
	}
	/// Gets the x-axis velocity of the body.
	fn get_velocity_x(&self) -> f32 {
		return unsafe { body_get_velocity_x(self.raw()) };
	}
	/// Sets the y-axis velocity of the body.
	fn set_velocity_y(&mut self, val: f32) {
		unsafe { body_set_velocity_y(self.raw(), val) };
	}
	/// Gets the y-axis velocity of the body.
	fn get_velocity_y(&self) -> f32 {
		return unsafe { body_get_velocity_y(self.raw()) };
	}
	/// Sets the velocity of the body as a `Vec2`.
	fn set_velocity(&mut self, val: &crate::dora::Vec2) {
		unsafe { body_set_velocity(self.raw(), val.into_i64()) };
	}
	/// Gets the velocity of the body as a `Vec2`.
	fn get_velocity(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(body_get_velocity(self.raw())) };
	}
	/// Sets the angular rate of the body.
	fn set_angular_rate(&mut self, val: f32) {
		unsafe { body_set_angular_rate(self.raw(), val) };
	}
	/// Gets the angular rate of the body.
	fn get_angular_rate(&self) -> f32 {
		return unsafe { body_get_angular_rate(self.raw()) };
	}
	/// Sets the collision group that the body belongs to.
	fn set_group(&mut self, val: i32) {
		unsafe { body_set_group(self.raw(), val) };
	}
	/// Gets the collision group that the body belongs to.
	fn get_group(&self) -> i32 {
		return unsafe { body_get_group(self.raw()) };
	}
	/// Sets the linear damping of the body.
	fn set_linear_damping(&mut self, val: f32) {
		unsafe { body_set_linear_damping(self.raw(), val) };
	}
	/// Gets the linear damping of the body.
	fn get_linear_damping(&self) -> f32 {
		return unsafe { body_get_linear_damping(self.raw()) };
	}
	/// Sets the angular damping of the body.
	fn set_angular_damping(&mut self, val: f32) {
		unsafe { body_set_angular_damping(self.raw(), val) };
	}
	/// Gets the angular damping of the body.
	fn get_angular_damping(&self) -> f32 {
		return unsafe { body_get_angular_damping(self.raw()) };
	}
	/// Sets the reference for an owner of the body.
	fn set_owner(&mut self, val: &dyn crate::dora::IObject) {
		unsafe { body_set_owner(self.raw(), val.raw()) };
	}
	/// Gets the reference for an owner of the body.
	fn get_owner(&self) -> crate::dora::Object {
		return unsafe { crate::dora::Object::from(body_get_owner(self.raw())).unwrap() };
	}
	/// Sets whether the body is currently receiving contact events or not.
	fn set_receiving_contact(&mut self, val: bool) {
		unsafe { body_set_receiving_contact(self.raw(), if val { 1 } else { 0 }) };
	}
	/// Gets whether the body is currently receiving contact events or not.
	fn is_receiving_contact(&self) -> bool {
		return unsafe { body_is_receiving_contact(self.raw()) != 0 };
	}
	/// Applies a linear impulse to the body at a specified position.
	///
	/// # Arguments
	///
	/// * `impulse` - The linear impulse to apply.
	/// * `pos` - The position at which to apply the impulse.
	fn apply_linear_impulse(&mut self, impulse: &crate::dora::Vec2, pos: &crate::dora::Vec2) {
		unsafe { body_apply_linear_impulse(self.raw(), impulse.into_i64(), pos.into_i64()); }
	}
	/// Applies an angular impulse to the body.
	///
	/// # Arguments
	///
	/// * `impulse` - The angular impulse to apply.
	fn apply_angular_impulse(&mut self, impulse: f32) {
		unsafe { body_apply_angular_impulse(self.raw(), impulse); }
	}
	/// Returns the sensor with the given tag.
	///
	/// # Arguments
	///
	/// * `tag` - The tag of the sensor to get.
	///
	/// # Returns
	///
	/// * `Sensor` - The sensor with the given tag.
	fn get_sensor_by_tag(&mut self, tag: i32) -> crate::dora::Sensor {
		unsafe { return crate::dora::Sensor::from(body_get_sensor_by_tag(self.raw(), tag)).unwrap(); }
	}
	/// Removes the sensor with the specified tag from the body.
	///
	/// # Arguments
	///
	/// * `tag` - The tag of the sensor to remove.
	///
	/// # Returns
	///
	/// * `bool` - Whether a sensor with the specified tag was found and removed.
	fn remove_sensor_by_tag(&mut self, tag: i32) -> bool {
		unsafe { return body_remove_sensor_by_tag(self.raw(), tag) != 0; }
	}
	/// Removes the given sensor from the body's sensor list.
	///
	/// # Arguments
	///
	/// * `sensor` - The sensor to remove.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the sensor was successfully removed, `false` otherwise.
	fn remove_sensor(&mut self, sensor: &crate::dora::Sensor) -> bool {
		unsafe { return body_remove_sensor(self.raw(), sensor.raw()) != 0; }
	}
	/// Attaches a fixture to the body.
	///
	/// # Arguments
	///
	/// * `fixture_def` - The fixture definition for the fixture to attach.
	fn attach(&mut self, fixture_def: &crate::dora::FixtureDef) {
		unsafe { body_attach(self.raw(), fixture_def.raw()); }
	}
	/// Attaches a new sensor with the given tag and fixture definition to the body.
	///
	/// # Arguments
	///
	/// * `tag` - The tag of the sensor to attach.
	/// * `fixture_def` - The fixture definition of the sensor.
	///
	/// # Returns
	///
	/// * `Sensor` - The newly attached sensor.
	fn attach_sensor(&mut self, tag: i32, fixture_def: &crate::dora::FixtureDef) -> crate::dora::Sensor {
		unsafe { return crate::dora::Sensor::from(body_attach_sensor(self.raw(), tag, fixture_def.raw())).unwrap(); }
	}
	/// Registers a function to be called when the body begins to receive contact events. Return `false` from this function to prevent colliding.
	///
	/// # Arguments
	///
	/// * `filter` - The filter function to set.
	fn on_contact_filter(&mut self, mut filter: Box<dyn FnMut(&dyn crate::dora::IBody) -> bool>) {
		let mut stack0 = crate::dora::CallStack::new();
		let stack_raw0 = stack0.raw();
		let func_id0 = crate::dora::push_function(Box::new(move || {
			let result = filter(&stack0.pop_cast::<crate::dora::Body>().unwrap());
			stack0.push_bool(result);
		}));
		unsafe { body_on_contact_filter(self.raw(), func_id0, stack_raw0); }
	}
}
impl Body {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { body_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Body { raw: raw }))
			}
		})
	}
	/// Creates a new instance of `Body`.
	///
	/// # Arguments
	///
	/// * `def` - The definition for the body to be created.
	/// * `world` - The physics world where the body belongs.
	/// * `pos` - The initial position of the body.
	/// * `rot` - The initial rotation angle of the body in degrees.
	///
	/// # Returns
	///
	/// * A new `Body` instance.
	pub fn new(def: &crate::dora::BodyDef, world: &dyn crate::dora::IPhysicsWorld, pos: &crate::dora::Vec2, rot: f32) -> Body {
		unsafe { return Body { raw: body_new(def.raw(), world.raw(), pos.into_i64(), rot) }; }
	}
}