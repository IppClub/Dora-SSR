/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn joint_type() -> i32;
	fn joint_distance(collision: i32, body_a: i64, body_b: i64, anchor_a: i64, anchor_b: i64, frequency: f32, damping: f32) -> i64;
	fn joint_friction(collision: i32, body_a: i64, body_b: i64, world_pos: i64, max_force: f32, max_torque: f32) -> i64;
	fn joint_gear(collision: i32, joint_a: i64, joint_b: i64, ratio: f32) -> i64;
	fn joint_spring(collision: i32, body_a: i64, body_b: i64, linear_offset: i64, angular_offset: f32, max_force: f32, max_torque: f32, correction_factor: f32) -> i64;
	fn joint_move_target(collision: i32, body: i64, target_pos: i64, max_force: f32, frequency: f32, damping: f32) -> i64;
	fn joint_prismatic(collision: i32, body_a: i64, body_b: i64, world_pos: i64, axis_angle: f32, lower_translation: f32, upper_translation: f32, max_motor_force: f32, motor_speed: f32) -> i64;
	fn joint_pulley(collision: i32, body_a: i64, body_b: i64, anchor_a: i64, anchor_b: i64, ground_anchor_a: i64, ground_anchor_b: i64, ratio: f32) -> i64;
	fn joint_revolute(collision: i32, body_a: i64, body_b: i64, world_pos: i64, lower_angle: f32, upper_angle: f32, max_motor_torque: f32, motor_speed: f32) -> i64;
	fn joint_rope(collision: i32, body_a: i64, body_b: i64, anchor_a: i64, anchor_b: i64, max_length: f32) -> i64;
	fn joint_weld(collision: i32, body_a: i64, body_b: i64, world_pos: i64, frequency: f32, damping: f32) -> i64;
	fn joint_wheel(collision: i32, body_a: i64, body_b: i64, world_pos: i64, axis_angle: f32, max_motor_torque: f32, motor_speed: f32, frequency: f32, damping: f32) -> i64;
	fn joint_get_world(slf: i64) -> i64;
	fn joint_destroy(slf: i64);
	fn joint_new(def: i64, item_dict: i64) -> i64;
}
use crate::dora::IObject;
/// A struct that can be used to connect physics bodies together.
pub struct Joint { raw: i64 }
crate::dora_object!(Joint);
impl IJoint for Joint { }
pub trait IJoint: IObject {
	/// Gets the physics world that the joint belongs to.
	fn get_world(&self) -> crate::dora::PhysicsWorld {
		return unsafe { crate::dora::PhysicsWorld::from(joint_get_world(self.raw())).unwrap() };
	}
	/// Destroys the joint and removes it from the physics simulation.
	fn destroy(&mut self) {
		unsafe { joint_destroy(self.raw()); }
	}
}
impl Joint {
	pub(crate) fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { joint_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Joint { raw: raw }))
			}
		})
	}
	/// Creates a distance joint between two physics bodies.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the physics body connected to joint will collide with each other.
	/// * `body_a` - The first physics body to connect with the joint.
	/// * `body_b` - The second physics body to connect with the joint.
	/// * `anchor_a` - The position of the joint on the first physics body.
	/// * `anchor_b` - The position of the joint on the second physics body.
	/// * `frequency` - The frequency of the joint, in Hertz.
	/// * `damping` - The damping ratio of the joint.
	///
	/// # Returns
	///
	/// * `Joint` - The new distance joint.
	pub fn distance(collision: bool, body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody, anchor_a: &crate::dora::Vec2, anchor_b: &crate::dora::Vec2, frequency: f32, damping: f32) -> crate::dora::Joint {
		unsafe { return crate::dora::Joint::from(joint_distance(if collision { 1 } else { 0 }, body_a.raw(), body_b.raw(), anchor_a.into_i64(), anchor_b.into_i64(), frequency, damping)).unwrap(); }
	}
	/// Creates a friction joint between two physics bodies.
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
	/// * `Joint` - The new friction joint.
	pub fn friction(collision: bool, body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody, world_pos: &crate::dora::Vec2, max_force: f32, max_torque: f32) -> crate::dora::Joint {
		unsafe { return crate::dora::Joint::from(joint_friction(if collision { 1 } else { 0 }, body_a.raw(), body_b.raw(), world_pos.into_i64(), max_force, max_torque)).unwrap(); }
	}
	/// Creates a gear joint between two other joints.
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
	/// * `Joint` - The new gear joint.
	pub fn gear(collision: bool, joint_a: &dyn crate::dora::IJoint, joint_b: &dyn crate::dora::IJoint, ratio: f32) -> crate::dora::Joint {
		unsafe { return crate::dora::Joint::from(joint_gear(if collision { 1 } else { 0 }, joint_a.raw(), joint_b.raw(), ratio)).unwrap(); }
	}
	/// Creates a new spring joint between the two specified bodies.
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
	/// * `Joint` - The created joint.
	pub fn spring(collision: bool, body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody, linear_offset: &crate::dora::Vec2, angular_offset: f32, max_force: f32, max_torque: f32, correction_factor: f32) -> crate::dora::Joint {
		unsafe { return crate::dora::Joint::from(joint_spring(if collision { 1 } else { 0 }, body_a.raw(), body_b.raw(), linear_offset.into_i64(), angular_offset, max_force, max_torque, correction_factor)).unwrap(); }
	}
	/// Creates a new move joint for the specified body.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether the body can collide with other bodies.
	/// * `body` - The body that the joint is attached to.
	/// * `target_pos` - The target position that the body should move towards.
	/// * `max_force` - The maximum force the joint can exert.
	/// * `frequency` - Frequency ratio.
	/// * `damping` - Damping ratio.
	///
	/// # Returns
	///
	/// * `MoveJoint` - The created move joint.
	pub fn move_target(collision: bool, body: &dyn crate::dora::IBody, target_pos: &crate::dora::Vec2, max_force: f32, frequency: f32, damping: f32) -> crate::dora::MoveJoint {
		unsafe { return crate::dora::MoveJoint::from(joint_move_target(if collision { 1 } else { 0 }, body.raw(), target_pos.into_i64(), max_force, frequency, damping)).unwrap(); }
	}
	/// Creates a new prismatic joint between the two specified bodies.
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
	/// * `MotorJoint` - The created prismatic joint.
	pub fn prismatic(collision: bool, body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody, world_pos: &crate::dora::Vec2, axis_angle: f32, lower_translation: f32, upper_translation: f32, max_motor_force: f32, motor_speed: f32) -> crate::dora::MotorJoint {
		unsafe { return crate::dora::MotorJoint::from(joint_prismatic(if collision { 1 } else { 0 }, body_a.raw(), body_b.raw(), world_pos.into_i64(), axis_angle, lower_translation, upper_translation, max_motor_force, motor_speed)).unwrap(); }
	}
	/// Creates a pulley joint between two physics bodies.
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
	/// * `Joint` - The pulley joint.
	pub fn pulley(collision: bool, body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody, anchor_a: &crate::dora::Vec2, anchor_b: &crate::dora::Vec2, ground_anchor_a: &crate::dora::Vec2, ground_anchor_b: &crate::dora::Vec2, ratio: f32) -> crate::dora::Joint {
		unsafe { return crate::dora::Joint::from(joint_pulley(if collision { 1 } else { 0 }, body_a.raw(), body_b.raw(), anchor_a.into_i64(), anchor_b.into_i64(), ground_anchor_a.into_i64(), ground_anchor_b.into_i64(), ratio)).unwrap(); }
	}
	/// Creates a revolute joint between two physics bodies.
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
	/// * `MotorJoint` - The revolute joint.
	pub fn revolute(collision: bool, body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody, world_pos: &crate::dora::Vec2, lower_angle: f32, upper_angle: f32, max_motor_torque: f32, motor_speed: f32) -> crate::dora::MotorJoint {
		unsafe { return crate::dora::MotorJoint::from(joint_revolute(if collision { 1 } else { 0 }, body_a.raw(), body_b.raw(), world_pos.into_i64(), lower_angle, upper_angle, max_motor_torque, motor_speed)).unwrap(); }
	}
	/// Creates a rope joint between two physics bodies.
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
	/// * `Joint` - The rope joint.
	pub fn rope(collision: bool, body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody, anchor_a: &crate::dora::Vec2, anchor_b: &crate::dora::Vec2, max_length: f32) -> crate::dora::Joint {
		unsafe { return crate::dora::Joint::from(joint_rope(if collision { 1 } else { 0 }, body_a.raw(), body_b.raw(), anchor_a.into_i64(), anchor_b.into_i64(), max_length)).unwrap(); }
	}
	/// Creates a weld joint between two bodies.
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
	/// * `Joint` - The newly created weld joint.
	pub fn weld(collision: bool, body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody, world_pos: &crate::dora::Vec2, frequency: f32, damping: f32) -> crate::dora::Joint {
		unsafe { return crate::dora::Joint::from(joint_weld(if collision { 1 } else { 0 }, body_a.raw(), body_b.raw(), world_pos.into_i64(), frequency, damping)).unwrap(); }
	}
	/// Creates a wheel joint between two bodies.
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
	/// * `MotorJoint` - The newly created wheel joint.
	pub fn wheel(collision: bool, body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody, world_pos: &crate::dora::Vec2, axis_angle: f32, max_motor_torque: f32, motor_speed: f32, frequency: f32, damping: f32) -> crate::dora::MotorJoint {
		unsafe { return crate::dora::MotorJoint::from(joint_wheel(if collision { 1 } else { 0 }, body_a.raw(), body_b.raw(), world_pos.into_i64(), axis_angle, max_motor_torque, motor_speed, frequency, damping)).unwrap(); }
	}
	/// Creates a joint instance based on the given joint definition and item dictionary containing physics bodies to be connected by joint.
	///
	/// # Arguments
	///
	/// * `def` - The joint definition.
	/// * `item_dict` - The dictionary containing all the bodies and other required items.
	///
	/// # Returns
	///
	/// * `Joint` - The newly created joint.
	pub fn new(def: &crate::dora::JointDef, item_dict: &crate::dora::Dictionary) -> Joint {
		unsafe { return Joint { raw: joint_new(def.raw(), item_dict.raw()) }; }
	}
}