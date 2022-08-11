extern "C" {
	fn jointdef_type() -> i32;
	fn jointdef_set_center(slf: i64, var: i64);
	fn jointdef_get_center(slf: i64) -> i64;
	fn jointdef_set_position(slf: i64, var: i64);
	fn jointdef_get_position(slf: i64) -> i64;
	fn jointdef_set_angle(slf: i64, var: f32);
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
pub struct JointDef { raw: i64 }
crate::dora_object!(JointDef);
impl JointDef {
	pub fn type_info() -> (i32, fn(i64) -> Option<Box<dyn IObject>>) {
		(unsafe { jointdef_type() }, |raw: i64| -> Option<Box<dyn IObject>> {
			match raw {
				0 => None,
				_ => Some(Box::new(JointDef { raw: raw }))
			}
		})
	}
	pub fn set_center(&mut self, var: &crate::dora::Vec2) {
		unsafe { jointdef_set_center(self.raw(), var.into_i64()) };
	}
	pub fn get_center(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(jointdef_get_center(self.raw())) };
	}
	pub fn set_position(&mut self, var: &crate::dora::Vec2) {
		unsafe { jointdef_set_position(self.raw(), var.into_i64()) };
	}
	pub fn get_position(&self) -> crate::dora::Vec2 {
		return unsafe { crate::dora::Vec2::from(jointdef_get_position(self.raw())) };
	}
	pub fn set_angle(&mut self, var: f32) {
		unsafe { jointdef_set_angle(self.raw(), var) };
	}
	pub fn get_angle(&self) -> f32 {
		return unsafe { jointdef_get_angle(self.raw()) };
	}
	pub fn distance(collision: bool, body_a: &str, body_b: &str, anchor_a: &crate::dora::Vec2, anchor_b: &crate::dora::Vec2, frequency: f32, damping: f32) -> crate::dora::JointDef {
		unsafe { return crate::dora::JointDef::from(jointdef_distance(if collision { 1 } else { 0 }, crate::dora::from_string(body_a), crate::dora::from_string(body_b), anchor_a.into_i64(), anchor_b.into_i64(), frequency, damping)).unwrap(); }
	}
	pub fn friction(collision: bool, body_a: &str, body_b: &str, world_pos: &crate::dora::Vec2, max_force: f32, max_torque: f32) -> crate::dora::JointDef {
		unsafe { return crate::dora::JointDef::from(jointdef_friction(if collision { 1 } else { 0 }, crate::dora::from_string(body_a), crate::dora::from_string(body_b), world_pos.into_i64(), max_force, max_torque)).unwrap(); }
	}
	pub fn gear(collision: bool, joint_a: &str, joint_b: &str, ratio: f32) -> crate::dora::JointDef {
		unsafe { return crate::dora::JointDef::from(jointdef_gear(if collision { 1 } else { 0 }, crate::dora::from_string(joint_a), crate::dora::from_string(joint_b), ratio)).unwrap(); }
	}
	pub fn spring(collision: bool, body_a: &str, body_b: &str, linear_offset: &crate::dora::Vec2, angular_offset: f32, max_force: f32, max_torque: f32, correction_factor: f32) -> crate::dora::JointDef {
		unsafe { return crate::dora::JointDef::from(jointdef_spring(if collision { 1 } else { 0 }, crate::dora::from_string(body_a), crate::dora::from_string(body_b), linear_offset.into_i64(), angular_offset, max_force, max_torque, correction_factor)).unwrap(); }
	}
	pub fn prismatic(collision: bool, body_a: &str, body_b: &str, world_pos: &crate::dora::Vec2, axis_angle: f32, lower_translation: f32, upper_translation: f32, max_motor_force: f32, motor_speed: f32) -> crate::dora::JointDef {
		unsafe { return crate::dora::JointDef::from(jointdef_prismatic(if collision { 1 } else { 0 }, crate::dora::from_string(body_a), crate::dora::from_string(body_b), world_pos.into_i64(), axis_angle, lower_translation, upper_translation, max_motor_force, motor_speed)).unwrap(); }
	}
	pub fn pulley(collision: bool, body_a: &str, body_b: &str, anchor_a: &crate::dora::Vec2, anchor_b: &crate::dora::Vec2, ground_anchor_a: &crate::dora::Vec2, ground_anchor_b: &crate::dora::Vec2, ratio: f32) -> crate::dora::JointDef {
		unsafe { return crate::dora::JointDef::from(jointdef_pulley(if collision { 1 } else { 0 }, crate::dora::from_string(body_a), crate::dora::from_string(body_b), anchor_a.into_i64(), anchor_b.into_i64(), ground_anchor_a.into_i64(), ground_anchor_b.into_i64(), ratio)).unwrap(); }
	}
	pub fn revolute(collision: bool, body_a: &str, body_b: &str, world_pos: &crate::dora::Vec2, lower_angle: f32, upper_angle: f32, max_motor_torque: f32, motor_speed: f32) -> crate::dora::JointDef {
		unsafe { return crate::dora::JointDef::from(jointdef_revolute(if collision { 1 } else { 0 }, crate::dora::from_string(body_a), crate::dora::from_string(body_b), world_pos.into_i64(), lower_angle, upper_angle, max_motor_torque, motor_speed)).unwrap(); }
	}
	pub fn rope(collision: bool, body_a: &str, body_b: &str, anchor_a: &crate::dora::Vec2, anchor_b: &crate::dora::Vec2, max_length: f32) -> crate::dora::JointDef {
		unsafe { return crate::dora::JointDef::from(jointdef_rope(if collision { 1 } else { 0 }, crate::dora::from_string(body_a), crate::dora::from_string(body_b), anchor_a.into_i64(), anchor_b.into_i64(), max_length)).unwrap(); }
	}
	pub fn weld(collision: bool, body_a: &str, body_b: &str, world_pos: &crate::dora::Vec2, frequency: f32, damping: f32) -> crate::dora::JointDef {
		unsafe { return crate::dora::JointDef::from(jointdef_weld(if collision { 1 } else { 0 }, crate::dora::from_string(body_a), crate::dora::from_string(body_b), world_pos.into_i64(), frequency, damping)).unwrap(); }
	}
	pub fn wheel(collision: bool, body_a: &str, body_b: &str, world_pos: &crate::dora::Vec2, axis_angle: f32, max_motor_torque: f32, motor_speed: f32, frequency: f32, damping: f32) -> crate::dora::JointDef {
		unsafe { return crate::dora::JointDef::from(jointdef_wheel(if collision { 1 } else { 0 }, crate::dora::from_string(body_a), crate::dora::from_string(body_b), world_pos.into_i64(), axis_angle, max_motor_torque, motor_speed, frequency, damping)).unwrap(); }
	}
}