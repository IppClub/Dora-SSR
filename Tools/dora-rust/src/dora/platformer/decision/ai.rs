extern "C" {
	fn platformer_decision_ai_get_units_by_relation(relation: i32) -> i64;
	fn platformer_decision_ai_get_detected_units() -> i64;
	fn platformer_decision_ai_get_detected_bodies() -> i64;
	fn platformer_decision_ai_get_nearest_unit(relation: i32) -> i64;
	fn platformer_decision_ai_get_nearest_unit_distance(relation: i32) -> f32;
	fn platformer_decision_ai_get_units_in_attack_range() -> i64;
	fn platformer_decision_ai_get_bodies_in_attack_range() -> i64;
}
pub struct AI { }
impl AI {
	pub fn get_units_by_relation(relation: crate::dora::platformer::Relation) -> crate::dora::Array {
		unsafe { return crate::dora::Array::from(platformer_decision_ai_get_units_by_relation(relation as i32)).unwrap(); }
	}
	pub fn get_detected_units() -> crate::dora::Array {
		unsafe { return crate::dora::Array::from(platformer_decision_ai_get_detected_units()).unwrap(); }
	}
	pub fn get_detected_bodies() -> crate::dora::Array {
		unsafe { return crate::dora::Array::from(platformer_decision_ai_get_detected_bodies()).unwrap(); }
	}
	pub fn get_nearest_unit(relation: crate::dora::platformer::Relation) -> crate::dora::platformer::Unit {
		unsafe { return crate::dora::platformer::Unit::from(platformer_decision_ai_get_nearest_unit(relation as i32)).unwrap(); }
	}
	pub fn get_nearest_unit_distance(relation: crate::dora::platformer::Relation) -> f32 {
		unsafe { return platformer_decision_ai_get_nearest_unit_distance(relation as i32); }
	}
	pub fn get_units_in_attack_range() -> crate::dora::Array {
		unsafe { return crate::dora::Array::from(platformer_decision_ai_get_units_in_attack_range()).unwrap(); }
	}
	pub fn get_bodies_in_attack_range() -> crate::dora::Array {
		unsafe { return crate::dora::Array::from(platformer_decision_ai_get_bodies_in_attack_range()).unwrap(); }
	}
}