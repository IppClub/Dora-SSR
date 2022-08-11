static int32_t movejoint_type()
{
	return DoraType<MoveJoint>();
}
static void movejoint_set_position(int64_t self, int64_t var)
{
	r_cast<MoveJoint*>(self)->setPosition(vec2_from(var));
}
static int64_t movejoint_get_position(int64_t self)
{
	return vec2_retain(r_cast<MoveJoint*>(self)->getPosition());
}
static void linkMoveJoint(wasm3::module& mod)
{
	mod.link_optional("*", "movejoint_type", movejoint_type);
	mod.link_optional("*", "movejoint_set_position", movejoint_set_position);
	mod.link_optional("*", "movejoint_get_position", movejoint_get_position);
}