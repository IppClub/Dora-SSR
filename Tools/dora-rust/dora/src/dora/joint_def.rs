/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn jointdef_type() -> i32;
	fn jointdef_set_center(slf: i64, val: i64);
	fn jointdef_get_center(slf: i64) -> i64;
	fn jointdef_set_position(slf: i64, val: i64);
	fn jointdef_get_position(slf: i64) -> i64;
	fn jointdef_set_angle(slf: i64, val: f32);
	fn jointdef_get_angle(slf: i64) -> f32;
	fn jointdef_distance(collision: i32, body_a: i64, body_b: i64, anchor_a: i64, anchor_b: i64, frequency: f32, damping: f32) -> i64;
	fn jointdef_friction(collision: i32, body_a: i64, body_b: i64, world_pos: i64, max_force: f32, max_torque: f32) -> i64;
	fn jointdef_gear(collision: i32, joint_a: i64, joint_b: i64, ratio: f32) -> i64;
	fn jointdef_spring(collision: i32, body_a: i64, body_b: i64, linear_offset: i64, angular_offset: f32, max_force: f32, max_torque: f32, correction_factor: f32) -> i64;
	fn jointdef_prismatic(collision: i32, body_a: i64, body_b: i64, world_pos: i64, axis_angle: f32, lower_translation: f32, upper_translation: f32, max_motor_force: f32, motor_speed: f32) -> i64;
	fn jointdef_pulley(collision: i32, body_a: i64, body_b: i64, anchor_a: i64, anchor_b: i64, ground_anchor_a: i64, ground_anchor_b: i64, ratio: f32) -> i64;
	fn jointdef_revolute(collision: i32, body_a: i64, body_b: i64, world_pos: i64, lower_angle: f32, upper_angle: f32, max_motor_torque: f32, motor_speed: f32) -> i64;
	fn jointdef_rope(collision: i32, body_a: i64, body_b: i64, anchor_a: i64, anchor_b: i64, max_length: f32) -> i64;
	fn jointdef_weld(collision: i32, body_a: i64, body_b: i64, world_pos: i64, frequency: f32, damping: f32) -> i64;
	fn jointdef_wheel(collision: i32, body_a: i64, body_b: i64, world_pos: i64, axis_angle: f32, max_motor_torque: f32, motor_speed: f32, frequency: f32, damping: f32) -> i64;
}
use crate::dora::IObject;
/// A struct that defines the properties of a joint to be created.
pub struct JointDef { raw: i64 }
crate::dora_object!(JointDef);
impl JointDef {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { jointdef_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(JointDef { raw: raw }))
			}
		})
	}
	/// Sets the center point of the joint, in local coordinates.
	pub fn set_center(&mut self, val: &crate::dora::Vec2) {
		unsafe { jointdef_set_center(self.raw(), val.into_i64()) };
	}
	/// Gets the center point of the joint, in local coordinates.
	pub fn get_center(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(jointdef_get_center(self.raw())) };
	}
	/// Sets the position of the joint, in world coordinates.
	pub fn set_position(&mut self, val: &crate::dora::Vec2) {
		unsafe { jointdef_set_position(self.raw(), val.into_i64()) };
	}
	/// Gets the position of the joint, in world coordinates.
	pub fn get_position(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(jointdef_get_position(self.raw())) };
	}
	/// Sets the angle of the joint, in degrees.
	pub fn set_angle(&mut self, val: f32) {
		unsafe { jointdef_set_angle(self.raw(), val) };
	}
	/// Gets the angle of the joint, in degrees.
	pub fn get_angle(&self) -> f32 {
		return unsafe { jointdef_get_angle(self.raw()) };
	}
	/// Creates a distance joint definition.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the physics body connected to joint will collide with each other.
	/// * `body_a` - The name of first physics body to connect with the joint.
	/// * `body_b` - The name of second physics body to connect with the joint.
	/// * `anchor_a` - The position of the joint on the first physics body.
	/// * `anchor_b` - The position of the joint on the second physics body.
	/// * `frequency` - The frequency of the joint, in Hertz.
	/// * `damping` - The damping ratio of the joint.
	///
	/// # Returns
	///
	/// * `JointDef` - The new joint definition.
	pub fn distance(collision: bool, body_a: &str, body_b: &str, anchor_a: &crate::dora::Vec2, anchor_b: &crate::dora::Vec2, frequency: f32, damping: f32) -> crate::dora::JointDef {
		unsafe { return crate::dora::JointDef::from(jointdef_distance(if collision { 1 } else { 0 }, crate::dora::from_string(body_a), crate::dora::from_string(body_b), anchor_a.into_i64(), anchor_b.into_i64(), frequency, damping)).unwrap(); }
	}
	/// Creates a friction joint definition.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the physics body connected to joint will collide with each other.
	/// * `body_a` - The first physics body to connect with the joint.
	/// * `body_b` - The second physics body to connect with the joint.
	/// * `world_pos` - The position of the joint in the game world.
	/// * `max_force` - The maximum force that can be applied to the joint.
	/// * `max_torque` - The maximum torque that can be applied to the joint.
	///
	/// # Returns
	///
	/// * `Joint` - The new friction joint definition.
	pub fn friction(collision: bool, body_a: &str, body_b: &str, world_pos: &crate::dora::Vec2, max_force: f32, max_torque: f32) -> crate::dora::JointDef {
		unsafe { return crate::dora::JointDef::from(jointdef_friction(if collision { 1 } else { 0 }, crate::dora::from_string(body_a), crate::dora::from_string(body_b), world_pos.into_i64(), max_force, max_torque)).unwrap(); }
	}
	/// Creates a gear joint definition.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the physics bodies connected to the joint can collide with each other.
	/// * `joint_a` - The first joint to connect with the gear joint.
	/// * `joint_b` - The second joint to connect with the gear joint.
	/// * `ratio` - The gear ratio.
	///
	/// # Returns
	///
	/// * `Joint` - The new gear joint definition.
	pub fn gear(collision: bool, joint_a: &str, joint_b: &str, ratio: f32) -> crate::dora::JointDef {
		unsafe { return crate::dora::JointDef::from(jointdef_gear(if collision { 1 } else { 0 }, crate::dora::from_string(joint_a), crate::dora::from_string(joint_b), ratio)).unwrap(); }
	}
	/// Creates a new spring joint definition.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether the connected bodies should collide with each other.
	/// * `body_a` - The first body connected to the joint.
	/// * `body_b` - The second body connected to the joint.
	/// * `linear_offset` - Position of body-B minus the position of body-A, in body-A's frame.
	/// * `angular_offset` - Angle of body-B minus angle of body-A.
	/// * `max_force` - The maximum force the joint can exert.
	/// * `max_torque` - The maximum torque the joint can exert.
	/// * `correction_factor` - Correction factor. 0.0 = no correction, 1.0 = full correction.
	///
	/// # Returns
	///
	/// * `Joint` - The created joint definition.
	pub fn spring(collision: bool, body_a: &str, body_b: &str, linear_offset: &crate::dora::Vec2, angular_offset: f32, max_force: f32, max_torque: f32, correction_factor: f32) -> crate::dora::JointDef {
		unsafe { return crate::dora::JointDef::from(jointdef_spring(if collision { 1 } else { 0 }, crate::dora::from_string(body_a), crate::dora::from_string(body_b), linear_offset.into_i64(), angular_offset, max_force, max_torque, correction_factor)).unwrap(); }
	}
	/// Creates a new prismatic joint definition.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether the connected bodies should collide with each other.
	/// * `body_a` - The first body connected to the joint.
	/// * `body_b` - The second body connected to the joint.
	/// * `world_pos` - The world position of the joint.
	/// * `axis_angle` - The axis angle of the joint.
	/// * `lower_translation` - Lower translation limit.
	/// * `upper_translation` - Upper translation limit.
	/// * `max_motor_force` - Maximum motor force.
	/// * `motor_speed` - Motor speed.
	///
	/// # Returns
	///
	/// * `MotorJoint` - The created prismatic joint definition.
	pub fn prismatic(collision: bool, body_a: &str, body_b: &str, world_pos: &crate::dora::Vec2, axis_angle: f32, lower_translation: f32, upper_translation: f32, max_motor_force: f32, motor_speed: f32) -> crate::dora::JointDef {
		unsafe { return crate::dora::JointDef::from(jointdef_prismatic(if collision { 1 } else { 0 }, crate::dora::from_string(body_a), crate::dora::from_string(body_b), world_pos.into_i64(), axis_angle, lower_translation, upper_translation, max_motor_force, motor_speed)).unwrap(); }
	}
	/// Creates a pulley joint definition.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the connected bodies will collide with each other.
	/// * `body_a` - The first physics body to connect.
	/// * `body_b` - The second physics body to connect.
	/// * `anchor_a` - The position of the anchor point on the first body.
	/// * `anchor_b` - The position of the anchor point on the second body.
	/// * `ground_anchor_a` - The position of the ground anchor point on the first body in world coordinates.
	/// * `ground_anchor_b` - The position of the ground anchor point on the second body in world coordinates.
	/// * `ratio` - The pulley ratio.
	///
	/// # Returns
	///
	/// * `Joint` - The pulley joint definition.
	pub fn pulley(collision: bool, body_a: &str, body_b: &str, anchor_a: &crate::dora::Vec2, anchor_b: &crate::dora::Vec2, ground_anchor_a: &crate::dora::Vec2, ground_anchor_b: &crate::dora::Vec2, ratio: f32) -> crate::dora::JointDef {
		unsafe { return crate::dora::JointDef::from(jointdef_pulley(if collision { 1 } else { 0 }, crate::dora::from_string(body_a), crate::dora::from_string(body_b), anchor_a.into_i64(), anchor_b.into_i64(), ground_anchor_a.into_i64(), ground_anchor_b.into_i64(), ratio)).unwrap(); }
	}
	/// Creates a revolute joint definition.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the connected bodies will collide with each other.
	/// * `body_a` - The first physics body to connect.
	/// * `body_b` - The second physics body to connect.
	/// * `world_pos` - The position in world coordinates where the joint will be created.
	/// * `lower_angle` - The lower angle limit in radians.
	/// * `upper_angle` - The upper angle limit in radians.
	/// * `max_motor_torque` - The maximum torque that can be applied to the joint to achieve the target speed.
	/// * `motor_speed` - The desired speed of the joint.
	///
	/// # Returns
	///
	/// * `MotorJoint` - The revolute joint definition.
	pub fn revolute(collision: bool, body_a: &str, body_b: &str, world_pos: &crate::dora::Vec2, lower_angle: f32, upper_angle: f32, max_motor_torque: f32, motor_speed: f32) -> crate::dora::JointDef {
		unsafe { return crate::dora::JointDef::from(jointdef_revolute(if collision { 1 } else { 0 }, crate::dora::from_string(body_a), crate::dora::from_string(body_b), world_pos.into_i64(), lower_angle, upper_angle, max_motor_torque, motor_speed)).unwrap(); }
	}
	/// Creates a rope joint definition.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the connected bodies will collide with each other.
	/// * `body_a` - The first physics body to connect.
	/// * `body_b` - The second physics body to connect.
	/// * `anchor_a` - The position of the anchor point on the first body.
	/// * `anchor_b` - The position of the anchor point on the second body.
	/// * `max_length` - The maximum distance between the anchor points.
	///
	/// # Returns
	///
	/// * `Joint` - The rope joint definition.
	pub fn rope(collision: bool, body_a: &str, body_b: &str, anchor_a: &crate::dora::Vec2, anchor_b: &crate::dora::Vec2, max_length: f32) -> crate::dora::JointDef {
		unsafe { return crate::dora::JointDef::from(jointdef_rope(if collision { 1 } else { 0 }, crate::dora::from_string(body_a), crate::dora::from_string(body_b), anchor_a.into_i64(), anchor_b.into_i64(), max_length)).unwrap(); }
	}
	/// Creates a weld joint definition.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the bodies connected to the joint can collide with each other.
	/// * `body_a` - The first body to be connected by the joint.
	/// * `body_b` - The second body to be connected by the joint.
	/// * `world_pos` - The position in the world to connect the bodies together.
	/// * `frequency` - The frequency at which the joint should be stiff.
	/// * `damping` - The damping rate of the joint.
	///
	/// # Returns
	///
	/// * `Joint` - The newly created weld joint definition.
	pub fn weld(collision: bool, body_a: &str, body_b: &str, world_pos: &crate::dora::Vec2, frequency: f32, damping: f32) -> crate::dora::JointDef {
		unsafe { return crate::dora::JointDef::from(jointdef_weld(if collision { 1 } else { 0 }, crate::dora::from_string(body_a), crate::dora::from_string(body_b), world_pos.into_i64(), frequency, damping)).unwrap(); }
	}
	/// Creates a wheel joint definition.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the bodies connected to the joint can collide with each other.
	/// * `body_a` - The first body to be connected by the joint.
	/// * `body_b` - The second body to be connected by the joint.
	/// * `world_pos` - The position in the world to connect the bodies together.
	/// * `axis_angle` - The angle of the joint axis in radians.
	/// * `max_motor_torque` - The maximum torque the joint motor can exert.
	/// * `motor_speed` - The target speed of the joint motor.
	/// * `frequency` - The frequency at which the joint should be stiff.
	/// * `damping` - The damping rate of the joint.
	///
	/// # Returns
	///
	/// * `MotorJoint` - The newly created wheel joint definition.
	pub fn wheel(collision: bool, body_a: &str, body_b: &str, world_pos: &crate::dora::Vec2, axis_angle: f32, max_motor_torque: f32, motor_speed: f32, frequency: f32, damping: f32) -> crate::dora::JointDef {
		unsafe { return crate::dora::JointDef::from(jointdef_wheel(if collision { 1 } else { 0 }, crate::dora::from_string(body_a), crate::dora::from_string(body_b), world_pos.into_i64(), axis_angle, max_motor_torque, motor_speed, frequency, damping)).unwrap(); }
	}
}