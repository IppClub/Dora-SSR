/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

extern "C" {
using namespace Dora;
DORA_EXPORT int32_t platformer_data_get_group_first_player() {
	return s_cast<int32_t>(SharedData.getGroupFirstPlayer());
}
DORA_EXPORT int32_t platformer_data_get_group_last_player() {
	return s_cast<int32_t>(SharedData.getGroupLastPlayer());
}
DORA_EXPORT int32_t platformer_data_get_group_hide() {
	return s_cast<int32_t>(SharedData.getGroupHide());
}
DORA_EXPORT int32_t platformer_data_get_group_detect_player() {
	return s_cast<int32_t>(SharedData.getGroupDetectPlayer());
}
DORA_EXPORT int32_t platformer_data_get_group_terrain() {
	return s_cast<int32_t>(SharedData.getGroupTerrain());
}
DORA_EXPORT int32_t platformer_data_get_group_detection() {
	return s_cast<int32_t>(SharedData.getGroupDetection());
}
DORA_EXPORT int64_t platformer_data_get_store() {
	return Object_From(SharedData.getStore());
}
DORA_EXPORT void platformer_data_set_should_contact(int32_t group_a, int32_t group_b, int32_t contact) {
	SharedData.setShouldContact(s_cast<uint8_t>(group_a), s_cast<uint8_t>(group_b), contact != 0);
}
DORA_EXPORT int32_t platformer_data_get_should_contact(int32_t group_a, int32_t group_b) {
	return SharedData.getShouldContact(s_cast<uint8_t>(group_a), s_cast<uint8_t>(group_b)) ? 1 : 0;
}
DORA_EXPORT void platformer_data_set_relation(int32_t group_a, int32_t group_b, int32_t relation) {
	SharedData.setRelation(s_cast<uint8_t>(group_a), s_cast<uint8_t>(group_b), s_cast<Platformer::Relation>(relation));
}
DORA_EXPORT int32_t platformer_data_get_relation_by_group(int32_t group_a, int32_t group_b) {
	return s_cast<int32_t>(SharedData.getRelation(s_cast<uint8_t>(group_a), s_cast<uint8_t>(group_b)));
}
DORA_EXPORT int32_t platformer_data_get_relation(int64_t body_a, int64_t body_b) {
	return s_cast<int32_t>(SharedData.getRelation(r_cast<Body*>(body_a), r_cast<Body*>(body_b)));
}
DORA_EXPORT int32_t platformer_data_is_enemy_group(int32_t group_a, int32_t group_b) {
	return SharedData.isEnemy(s_cast<uint8_t>(group_a), s_cast<uint8_t>(group_b)) ? 1 : 0;
}
DORA_EXPORT int32_t platformer_data_is_enemy(int64_t body_a, int64_t body_b) {
	return SharedData.isEnemy(r_cast<Body*>(body_a), r_cast<Body*>(body_b)) ? 1 : 0;
}
DORA_EXPORT int32_t platformer_data_is_friend_group(int32_t group_a, int32_t group_b) {
	return SharedData.isFriend(s_cast<uint8_t>(group_a), s_cast<uint8_t>(group_b)) ? 1 : 0;
}
DORA_EXPORT int32_t platformer_data_is_friend(int64_t body_a, int64_t body_b) {
	return SharedData.isFriend(r_cast<Body*>(body_a), r_cast<Body*>(body_b)) ? 1 : 0;
}
DORA_EXPORT int32_t platformer_data_is_neutral_group(int32_t group_a, int32_t group_b) {
	return SharedData.isNeutral(s_cast<uint8_t>(group_a), s_cast<uint8_t>(group_b)) ? 1 : 0;
}
DORA_EXPORT int32_t platformer_data_is_neutral(int64_t body_a, int64_t body_b) {
	return SharedData.isNeutral(r_cast<Body*>(body_a), r_cast<Body*>(body_b)) ? 1 : 0;
}
DORA_EXPORT void platformer_data_set_damage_factor(int32_t damage_type, int32_t defence_type, float bounus) {
	SharedData.setDamageFactor(s_cast<uint16_t>(damage_type), s_cast<uint16_t>(defence_type), bounus);
}
DORA_EXPORT float platformer_data_get_damage_factor(int32_t damage_type, int32_t defence_type) {
	return SharedData.getDamageFactor(s_cast<uint16_t>(damage_type), s_cast<uint16_t>(defence_type));
}
DORA_EXPORT int32_t platformer_data_is_player(int64_t body) {
	return SharedData.isPlayer(r_cast<Body*>(body)) ? 1 : 0;
}
DORA_EXPORT int32_t platformer_data_is_terrain(int64_t body) {
	return SharedData.isTerrain(r_cast<Body*>(body)) ? 1 : 0;
}
DORA_EXPORT void platformer_data_clear() {
	SharedData.clear();
}
} // extern "C"

static void linkPlatformerData(wasm3::module3& mod) {
	mod.link_optional("*", "platformer_data_get_group_first_player", platformer_data_get_group_first_player);
	mod.link_optional("*", "platformer_data_get_group_last_player", platformer_data_get_group_last_player);
	mod.link_optional("*", "platformer_data_get_group_hide", platformer_data_get_group_hide);
	mod.link_optional("*", "platformer_data_get_group_detect_player", platformer_data_get_group_detect_player);
	mod.link_optional("*", "platformer_data_get_group_terrain", platformer_data_get_group_terrain);
	mod.link_optional("*", "platformer_data_get_group_detection", platformer_data_get_group_detection);
	mod.link_optional("*", "platformer_data_get_store", platformer_data_get_store);
	mod.link_optional("*", "platformer_data_set_should_contact", platformer_data_set_should_contact);
	mod.link_optional("*", "platformer_data_get_should_contact", platformer_data_get_should_contact);
	mod.link_optional("*", "platformer_data_set_relation", platformer_data_set_relation);
	mod.link_optional("*", "platformer_data_get_relation_by_group", platformer_data_get_relation_by_group);
	mod.link_optional("*", "platformer_data_get_relation", platformer_data_get_relation);
	mod.link_optional("*", "platformer_data_is_enemy_group", platformer_data_is_enemy_group);
	mod.link_optional("*", "platformer_data_is_enemy", platformer_data_is_enemy);
	mod.link_optional("*", "platformer_data_is_friend_group", platformer_data_is_friend_group);
	mod.link_optional("*", "platformer_data_is_friend", platformer_data_is_friend);
	mod.link_optional("*", "platformer_data_is_neutral_group", platformer_data_is_neutral_group);
	mod.link_optional("*", "platformer_data_is_neutral", platformer_data_is_neutral);
	mod.link_optional("*", "platformer_data_set_damage_factor", platformer_data_set_damage_factor);
	mod.link_optional("*", "platformer_data_get_damage_factor", platformer_data_get_damage_factor);
	mod.link_optional("*", "platformer_data_is_player", platformer_data_is_player);
	mod.link_optional("*", "platformer_data_is_terrain", platformer_data_is_terrain);
	mod.link_optional("*", "platformer_data_clear", platformer_data_clear);
}