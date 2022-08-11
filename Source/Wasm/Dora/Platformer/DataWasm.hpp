static int32_t platformer_data_get_group_hide()
{
	return s_cast<int32_t>(SharedData.getGroupHide());
}
static int32_t platformer_data_get_group_detect_player()
{
	return s_cast<int32_t>(SharedData.getGroupDetectPlayer());
}
static int32_t platformer_data_get_group_terrain()
{
	return s_cast<int32_t>(SharedData.getGroupTerrain());
}
static int32_t platformer_data_get_group_detection()
{
	return s_cast<int32_t>(SharedData.getGroupDetection());
}
static int64_t platformer_data_get_store()
{
	return from_object(SharedData.getStore());
}
static void platformer_data_set_should_contact(int32_t group_a, int32_t group_b, int32_t contact)
{
	SharedData.setShouldContact(s_cast<uint8_t>(group_a), s_cast<uint8_t>(group_b), contact != 0);
}
static int32_t platformer_data_get_should_contact(int32_t group_a, int32_t group_b)
{
	return SharedData.getShouldContact(s_cast<uint8_t>(group_a), s_cast<uint8_t>(group_b)) ? 1 : 0;
}
static void platformer_data_set_relation(int32_t group_a, int32_t group_b, int32_t relation)
{
	SharedData.setRelation(s_cast<uint8_t>(group_a), s_cast<uint8_t>(group_b), s_cast<Platformer::Relation>(relation));
}
static int32_t platformer_data_get_relation_by_group(int32_t group_a, int32_t group_b)
{
	return s_cast<int32_t>(SharedData.getRelation(s_cast<uint8_t>(group_a), s_cast<uint8_t>(group_b)));
}
static int32_t platformer_data_get_relation(int64_t body_a, int64_t body_b)
{
	return s_cast<int32_t>(SharedData.getRelation(r_cast<Body*>(body_a), r_cast<Body*>(body_b)));
}
static int32_t platformer_data_is_enemy_group(int32_t group_a, int32_t group_b)
{
	return SharedData.isEnemy(s_cast<uint8_t>(group_a), s_cast<uint8_t>(group_b)) ? 1 : 0;
}
static int32_t platformer_data_is_enemy(int64_t body_a, int64_t body_b)
{
	return SharedData.isEnemy(r_cast<Body*>(body_a), r_cast<Body*>(body_b)) ? 1 : 0;
}
static int32_t platformer_data_is_friend_group(int32_t group_a, int32_t group_b)
{
	return SharedData.isFriend(s_cast<uint8_t>(group_a), s_cast<uint8_t>(group_b)) ? 1 : 0;
}
static int32_t platformer_data_is_friend(int64_t body_a, int64_t body_b)
{
	return SharedData.isFriend(r_cast<Body*>(body_a), r_cast<Body*>(body_b)) ? 1 : 0;
}
static int32_t platformer_data_is_neutral_group(int32_t group_a, int32_t group_b)
{
	return SharedData.isNeutral(s_cast<uint8_t>(group_a), s_cast<uint8_t>(group_b)) ? 1 : 0;
}
static int32_t platformer_data_is_neutral(int64_t body_a, int64_t body_b)
{
	return SharedData.isNeutral(r_cast<Body*>(body_a), r_cast<Body*>(body_b)) ? 1 : 0;
}
static void platformer_data_set_damage_factor(int32_t damage_type, int32_t defence_type, float bounus)
{
	SharedData.setDamageFactor(s_cast<uint16_t>(damage_type), s_cast<uint16_t>(defence_type), bounus);
}
static float platformer_data_get_damage_factor(int32_t damage_type, int32_t defence_type)
{
	return SharedData.getDamageFactor(s_cast<uint16_t>(damage_type), s_cast<uint16_t>(defence_type));
}
static int32_t platformer_data_is_player(int64_t body)
{
	return SharedData.isPlayer(r_cast<Body*>(body)) ? 1 : 0;
}
static int32_t platformer_data_is_terrain(int64_t body)
{
	return SharedData.isTerrain(r_cast<Body*>(body)) ? 1 : 0;
}
static void platformer_data_clear()
{
	SharedData.clear();
}
static void linkPlatformerData(wasm3::module& mod)
{
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