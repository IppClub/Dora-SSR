/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
	fn platformer_data_get_group_first_player() -> i32;
	fn platformer_data_get_group_last_player() -> i32;
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
/// An interface that provides a centralized location for storing and accessing game-related data.
pub struct Data { }
impl Data {
	/// Gets the group key representing the first index for a player group.
	pub fn get_group_first_player() -> i32 {
		return unsafe { platformer_data_get_group_first_player() };
	}
	/// Gets the group key representing the last index for a player group.
	pub fn get_group_last_player() -> i32 {
		return unsafe { platformer_data_get_group_last_player() };
	}
	/// Gets the group key that won't have any contact with other groups by default.
	pub fn get_group_hide() -> i32 {
		return unsafe { platformer_data_get_group_hide() };
	}
	/// Gets the group key that will have contacts with player groups by default.
	pub fn get_group_detect_player() -> i32 {
		return unsafe { platformer_data_get_group_detect_player() };
	}
	/// Gets the group key representing terrain that will have contacts with other groups by default.
	pub fn get_group_terrain() -> i32 {
		return unsafe { platformer_data_get_group_terrain() };
	}
	/// Gets the group key that will have contacts with other groups by default.
	pub fn get_group_detection() -> i32 {
		return unsafe { platformer_data_get_group_detection() };
	}
	/// Gets the dictionary that can be used to store arbitrary data associated with string keys and various values globally.
	pub fn get_store() -> crate::dora::Dictionary {
		return unsafe { crate::dora::Dictionary::from(platformer_data_get_store()).unwrap() };
	}
	/// Sets a boolean value indicating whether two groups should be in contact or not.
	///
	/// # Arguments
	///
	/// * `group_a` - An integer representing the first group.
	/// * `group_b` - An integer representing the second group.
	/// * `contact` - A boolean indicating whether the two groups should be in contact.
	pub fn set_should_contact(group_a: i32, group_b: i32, contact: bool) {
		unsafe { platformer_data_set_should_contact(group_a, group_b, if contact { 1 } else { 0 }); }
	}
	/// Gets a boolean value indicating whether two groups should be in contact or not.
	///
	/// # Arguments
	///
	/// * `group_a` - An integer representing the first group.
	/// * `group_b` - An integer representing the second group.
	///
	/// # Returns
	///
	/// * A boolean indicating whether the two groups should be in contact.
	pub fn get_should_contact(group_a: i32, group_b: i32) -> bool {
		unsafe { return platformer_data_get_should_contact(group_a, group_b) != 0; }
	}
	/// Sets the relation between two groups.
	///
	/// # Arguments
	///
	/// * `group_a` - An integer representing the first group.
	/// * `group_b` - An integer representing the second group.
	/// * `relation` - The relation between the two groups.
	pub fn set_relation(group_a: i32, group_b: i32, relation: crate::dora::platformer::Relation) {
		unsafe { platformer_data_set_relation(group_a, group_b, relation as i32); }
	}
	/// Gets the relation between two groups.
	///
	/// # Arguments
	///
	/// * `group_a` - An integer representing the first group.
	/// * `group_b` - An integer representing the second group.
	///
	/// # Returns
	///
	/// * The relation between the two groups.
	pub fn get_relation_by_group(group_a: i32, group_b: i32) -> crate::dora::platformer::Relation {
		unsafe { return core::mem::transmute(platformer_data_get_relation_by_group(group_a, group_b)); }
	}
	/// A function that can be used to get the relation between two bodies.
	///
	/// # Arguments
	///
	/// * `body_a` - The first body.
	/// * `body_b` - The second body.
	///
	/// # Returns
	///
	/// * The relation between the two bodies.
	pub fn get_relation(body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody) -> crate::dora::platformer::Relation {
		unsafe { return core::mem::transmute(platformer_data_get_relation(body_a.raw(), body_b.raw())); }
	}
	/// A function that returns whether two groups have an "Enemy" relation.
	///
	/// # Arguments
	///
	/// * `group_a` - An integer representing the first group.
	/// * `group_b` - An integer representing the second group.
	///
	/// # Returns
	///
	/// * A boolean indicating whether the two groups have an "Enemy" relation.
	pub fn is_enemy_group(group_a: i32, group_b: i32) -> bool {
		unsafe { return platformer_data_is_enemy_group(group_a, group_b) != 0; }
	}
	/// A function that returns whether two bodies have an "Enemy" relation.
	///
	/// # Arguments
	///
	/// * `body_a` - The first body.
	/// * `body_b` - The second body.
	///
	/// # Returns
	///
	/// * A boolean indicating whether the two bodies have an "Enemy" relation.
	pub fn is_enemy(body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody) -> bool {
		unsafe { return platformer_data_is_enemy(body_a.raw(), body_b.raw()) != 0; }
	}
	/// A function that returns whether two groups have a "Friend" relation.
	///
	/// # Arguments
	///
	/// * `group_a` - An integer representing the first group.
	/// * `group_b` - An integer representing the second group.
	///
	/// # Returns
	///
	/// * A boolean indicating whether the two groups have a "Friend" relation.
	pub fn is_friend_group(group_a: i32, group_b: i32) -> bool {
		unsafe { return platformer_data_is_friend_group(group_a, group_b) != 0; }
	}
	/// A function that returns whether two bodies have a "Friend" relation.
	///
	/// # Arguments
	///
	/// * `body_a` - The first body.
	/// * `body_b` - The second body.
	///
	/// # Returns
	///
	/// * A boolean indicating whether the two bodies have a "Friend" relation.
	pub fn is_friend(body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody) -> bool {
		unsafe { return platformer_data_is_friend(body_a.raw(), body_b.raw()) != 0; }
	}
	/// A function that returns whether two groups have a "Neutral" relation.
	///
	/// # Arguments
	///
	/// * `group_a` - An integer representing the first group.
	/// * `group_b` - An integer representing the second group.
	///
	/// # Returns
	///
	/// * A boolean indicating whether the two groups have a "Neutral" relation.
	pub fn is_neutral_group(group_a: i32, group_b: i32) -> bool {
		unsafe { return platformer_data_is_neutral_group(group_a, group_b) != 0; }
	}
	/// A function that returns whether two bodies have a "Neutral" relation.
	///
	/// # Arguments
	///
	/// * `body_a` - The first body.
	/// * `body_b` - The second body.
	///
	/// # Returns
	///
	/// * A boolean indicating whether the two bodies have a "Neutral" relation.
	pub fn is_neutral(body_a: &dyn crate::dora::IBody, body_b: &dyn crate::dora::IBody) -> bool {
		unsafe { return platformer_data_is_neutral(body_a.raw(), body_b.raw()) != 0; }
	}
	/// Sets the bonus factor for a particular type of damage against a particular type of defence.
	///
	/// The builtin "MeleeAttack" and "RangeAttack" actions use a simple formula of `finalDamage = damage * bonus`.
	///
	/// # Arguments
	///
	/// * `damage_type` - An integer representing the type of damage.
	/// * `defence_type` - An integer representing the type of defence.
	/// * `bonus` - A number representing the bonus.
	pub fn set_damage_factor(damage_type: i32, defence_type: i32, bounus: f32) {
		unsafe { platformer_data_set_damage_factor(damage_type, defence_type, bounus); }
	}
	/// Gets the bonus factor for a particular type of damage against a particular type of defence.
	///
	/// # Arguments
	///
	/// * `damage_type` - An integer representing the type of damage.
	/// * `defence_type` - An integer representing the type of defence.
	///
	/// # Returns
	///
	/// * A number representing the bonus factor.
	pub fn get_damage_factor(damage_type: i32, defence_type: i32) -> f32 {
		unsafe { return platformer_data_get_damage_factor(damage_type, defence_type); }
	}
	/// A function that returns whether a body is a player or not.
	///
	/// This works the same as `Data::get_group_first_player() <= body.group and body.group <= Data::get_group_last_player()`.
	///
	/// # Arguments
	///
	/// * `body` - The body to check.
	///
	/// # Returns
	///
	/// * A boolean indicating whether the body is a player.
	pub fn is_player(body: &dyn crate::dora::IBody) -> bool {
		unsafe { return platformer_data_is_player(body.raw()) != 0; }
	}
	/// A function that returns whether a body is terrain or not.
	///
	/// This works the same as `body.group == Data::get_group_terrain()`.
	///
	/// # Arguments
	///
	/// * `body` - The body to check.
	///
	/// # Returns
	///
	/// * A boolean indicating whether the body is terrain.
	pub fn is_terrain(body: &dyn crate::dora::IBody) -> bool {
		unsafe { return platformer_data_is_terrain(body.raw()) != 0; }
	}
	/// Clears all data stored in the "Data" object, including user data in Data.store field. And reset some data to default values.
	pub fn clear() {
		unsafe { platformer_data_clear(); }
	}
}