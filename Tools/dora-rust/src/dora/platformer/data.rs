extern "C" {
	fn platformer_data_get_group_hide() -> i32;
	fn platformer_data_get_group_detect_player() -> i32;
	fn platformer_data_get_group_terrain() -> i32;
	fn platformer_data_get_group_detection() -> i32;
	fn platformer_data_get_store() -> i64;
	fn platformer_data_set_should_contact(group_a: i32, group_b: i32, contact: i32);
	fn platformer_data_get_should_contact(group_a: i32, group_b: i32) -> i32;
	fn platformer_data_set_relation(group_a: i32, group_b: i32, relation: i32);
	fn platformer_data_get_relation_by_group(group_a: i32, group_b: i32) -> i32;
	fn platformer_data_get_relation(body_a: i64, body_b: i64) -> i32;
	fn platformer_data_is_enemy_group(group_a: i32, group_b: i32) -> i32;
	fn platformer_data_is_enemy(body_a: i64, body_b: i64) -> i32;
	fn platformer_data_is_friend_group(group_a: i32, group_b: i32) -> i32;
	fn platformer_data_is_friend(body_a: i64, body_b: i64) -> i32;
	fn platformer_data_is_neutral_group(group_a: i32, group_b: i32) -> i32;
	fn platformer_data_is_neutral(body_a: i64, body_b: i64) -> i32;
	fn platformer_data_set_damage_factor(damage_type: i32, defence_type: i32, bounus: f32);
	fn platformer_data_get_damage_factor(damage_type: i32, defence_type: i32) -> f32;
	fn platformer_data_is_player(body: i64) -> i32;
	fn platformer_data_is_terrain(body: i64) -> i32;
	fn platformer_data_clear();
}
pub struct Data { }
impl Data {
	pub fn get_group_hide() -> i32 {
		return unsafe { platformer_data_get_group_hide() };
	}
	pub fn get_group_detect_player() -> i32 {
		return unsafe { platformer_data_get_group_detect_player() };
	}
	pub fn get_group_terrain() -> i32 {
		return unsafe { platformer_data_get_group_terrain() };
	}
	pub fn get_group_detection() -> i32 {
		return unsafe { platformer_data_get_group_detection() };
	}
	pub fn get_store() -> crate::dora::Dictionary {
		return unsafe { crate::dora::Dictionary::from(platformer_data_get_store()).unwrap() };
	}
	pub fn set_should_contact(group_a: i32, group_b: i32, contact: bool) {
		unsafe { platformer_data_set_should_contact(group_a, group_b, if contact { 1 } else { 0 }); }
	}
	pub fn get_should_contact(group_a: i32, group_b: i32) -> bool {
		unsafe { return platformer_data_get_should_contact(group_a, group_b) != 0; }
	}
	pub fn set_relation(group_a: i32, group_b: i32, relation: crate::dora::platformer::Relation) {
		unsafe { platformer_data_set_relation(group_a, group_b, relation as i32); }
	}
	pub fn get_relation_by_group(group_a: i32, group_b: i32) -> crate::dora::platformer::Relation {
		unsafe { return core::mem::transmute(platformer_data_get_relation_by_group(group_a, group_b)); }
	}
	pub fn get_relation(body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody) -> crate::dora::platformer::Relation {
		unsafe { return core::mem::transmute(platformer_data_get_relation(body_a.raw(), body_b.raw())); }
	}
	pub fn is_enemy_group(group_a: i32, group_b: i32) -> bool {
		unsafe { return platformer_data_is_enemy_group(group_a, group_b) != 0; }
	}
	pub fn is_enemy(body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody) -> bool {
		unsafe { return platformer_data_is_enemy(body_a.raw(), body_b.raw()) != 0; }
	}
	pub fn is_friend_group(group_a: i32, group_b: i32) -> bool {
		unsafe { return platformer_data_is_friend_group(group_a, group_b) != 0; }
	}
	pub fn is_friend(body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody) -> bool {
		unsafe { return platformer_data_is_friend(body_a.raw(), body_b.raw()) != 0; }
	}
	pub fn is_neutral_group(group_a: i32, group_b: i32) -> bool {
		unsafe { return platformer_data_is_neutral_group(group_a, group_b) != 0; }
	}
	pub fn is_neutral(body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody) -> bool {
		unsafe { return platformer_data_is_neutral(body_a.raw(), body_b.raw()) != 0; }
	}
	pub fn set_damage_factor(damage_type: i32, defence_type: i32, bounus: f32) {
		unsafe { platformer_data_set_damage_factor(damage_type, defence_type, bounus); }
	}
	pub fn get_damage_factor(damage_type: i32, defence_type: i32) -> f32 {
		unsafe { return platformer_data_get_damage_factor(damage_type, defence_type); }
	}
	pub fn is_player(body: &dyn crate::dora::IBody) -> bool {
		unsafe { return platformer_data_is_player(body.raw()) != 0; }
	}
	pub fn is_terrain(body: &dyn crate::dora::IBody) -> bool {
		unsafe { return platformer_data_is_terrain(body.raw()) != 0; }
	}
	pub fn clear() {
		unsafe { platformer_data_clear(); }
	}
}