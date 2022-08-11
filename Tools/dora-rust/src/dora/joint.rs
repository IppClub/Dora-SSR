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
pub struct Joint { raw: i64 }
crate::dora_object!(Joint);
impl IJoint for Joint { }
pub trait IJoint: IObject {
	fn get_world(&self) -> crate::dora::PhysicsWorld {
		return unsafe { crate::dora::PhysicsWorld::from(joint_get_world(self.raw())).unwrap() };
	}
	fn destroy(&mut self) {
		unsafe { joint_destroy(self.raw()); }
	}
}
impl Joint {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { joint_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(Joint { raw: raw }))
			}
		})
	}
	pub fn distance(collision: bool, body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody, anchor_a: &crate::dora::Vec2, anchor_b: &crate::dora::Vec2, frequency: f32, damping: f32) -> crate::dora::Joint {
		unsafe { return crate::dora::Joint::from(joint_distance(if collision { 1 } else { 0 }, body_a.raw(), body_b.raw(), anchor_a.into_i64(), anchor_b.into_i64(), frequency, damping)).unwrap(); }
	}
	pub fn friction(collision: bool, body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody, world_pos: &crate::dora::Vec2, max_force: f32, max_torque: f32) -> crate::dora::Joint {
		unsafe { return crate::dora::Joint::from(joint_friction(if collision { 1 } else { 0 }, body_a.raw(), body_b.raw(), world_pos.into_i64(), max_force, max_torque)).unwrap(); }
	}
	pub fn gear(collision: bool, joint_a: &dyn crate::dora::IJoint, joint_b: &dyn crate::dora::IJoint, ratio: f32) -> crate::dora::Joint {
		unsafe { return crate::dora::Joint::from(joint_gear(if collision { 1 } else { 0 }, joint_a.raw(), joint_b.raw(), ratio)).unwrap(); }
	}
	pub fn spring(collision: bool, body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody, linear_offset: &crate::dora::Vec2, angular_offset: f32, max_force: f32, max_torque: f32, correction_factor: f32) -> crate::dora::Joint {
		unsafe { return crate::dora::Joint::from(joint_spring(if collision { 1 } else { 0 }, body_a.raw(), body_b.raw(), linear_offset.into_i64(), angular_offset, max_force, max_torque, correction_factor)).unwrap(); }
	}
	pub fn move_target(collision: bool, body: &dyn crate::dora::IBody, target_pos: &crate::dora::Vec2, max_force: f32, frequency: f32, damping: f32) -> crate::dora::MoveJoint {
		unsafe { return crate::dora::MoveJoint::from(joint_move_target(if collision { 1 } else { 0 }, body.raw(), target_pos.into_i64(), max_force, frequency, damping)).unwrap(); }
	}
	pub fn prismatic(collision: bool, body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody, world_pos: &crate::dora::Vec2, axis_angle: f32, lower_translation: f32, upper_translation: f32, max_motor_force: f32, motor_speed: f32) -> crate::dora::MotorJoint {
		unsafe { return crate::dora::MotorJoint::from(joint_prismatic(if collision { 1 } else { 0 }, body_a.raw(), body_b.raw(), world_pos.into_i64(), axis_angle, lower_translation, upper_translation, max_motor_force, motor_speed)).unwrap(); }
	}
	pub fn pulley(collision: bool, body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody, anchor_a: &crate::dora::Vec2, anchor_b: &crate::dora::Vec2, ground_anchor_a: &crate::dora::Vec2, ground_anchor_b: &crate::dora::Vec2, ratio: f32) -> crate::dora::Joint {
		unsafe { return crate::dora::Joint::from(joint_pulley(if collision { 1 } else { 0 }, body_a.raw(), body_b.raw(), anchor_a.into_i64(), anchor_b.into_i64(), ground_anchor_a.into_i64(), ground_anchor_b.into_i64(), ratio)).unwrap(); }
	}
	pub fn revolute(collision: bool, body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody, world_pos: &crate::dora::Vec2, lower_angle: f32, upper_angle: f32, max_motor_torque: f32, motor_speed: f32) -> crate::dora::MotorJoint {
		unsafe { return crate::dora::MotorJoint::from(joint_revolute(if collision { 1 } else { 0 }, body_a.raw(), body_b.raw(), world_pos.into_i64(), lower_angle, upper_angle, max_motor_torque, motor_speed)).unwrap(); }
	}
	pub fn rope(collision: bool, body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody, anchor_a: &crate::dora::Vec2, anchor_b: &crate::dora::Vec2, max_length: f32) -> crate::dora::Joint {
		unsafe { return crate::dora::Joint::from(joint_rope(if collision { 1 } else { 0 }, body_a.raw(), body_b.raw(), anchor_a.into_i64(), anchor_b.into_i64(), max_length)).unwrap(); }
	}
	pub fn weld(collision: bool, body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody, world_pos: &crate::dora::Vec2, frequency: f32, damping: f32) -> crate::dora::Joint {
		unsafe { return crate::dora::Joint::from(joint_weld(if collision { 1 } else { 0 }, body_a.raw(), body_b.raw(), world_pos.into_i64(), frequency, damping)).unwrap(); }
	}
	pub fn wheel(collision: bool, body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody, world_pos: &crate::dora::Vec2, axis_angle: f32, max_motor_torque: f32, motor_speed: f32, frequency: f32, damping: f32) -> crate::dora::MotorJoint {
		unsafe { return crate::dora::MotorJoint::from(joint_wheel(if collision { 1 } else { 0 }, body_a.raw(), body_b.raw(), world_pos.into_i64(), axis_angle, max_motor_torque, motor_speed, frequency, damping)).unwrap(); }
	}
	pub fn new(def: &crate::dora::JointDef, item_dict: &crate::dora::Dictionary) -> Joint {
		unsafe { return Joint { raw: joint_new(def.raw(), item_dict.raw()) }; }
	}
}