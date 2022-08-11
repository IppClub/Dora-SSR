static int32_t sensor_type()
{
	return DoraType<Sensor>();
}
static void sensor_set_enabled(int64_t self, int32_t var)
{
	r_cast<Sensor*>(self)->setEnabled(var != 0);
}
static int32_t sensor_is_enabled(int64_t self)
{
	return r_cast<Sensor*>(self)->isEnabled() ? 1 : 0;
}
static int32_t sensor_get_tag(int64_t self)
{
	return s_cast<int32_t>(r_cast<Sensor*>(self)->getTag());
}
static int64_t sensor_get_owner(int64_t self)
{
	return from_object(r_cast<Sensor*>(self)->getOwner());
}
static int32_t sensor_is_sensed(int64_t self)
{
	return r_cast<Sensor*>(self)->isSensed() ? 1 : 0;
}
static int64_t sensor_get_sensed_bodies(int64_t self)
{
	return from_object(r_cast<Sensor*>(self)->getSensedBodies());
}
static int32_t sensor_contains(int64_t self, int64_t body)
{
	return r_cast<Sensor*>(self)->contains(r_cast<Body*>(body)) ? 1 : 0;
}
static void linkSensor(wasm3::module& mod)
{
	mod.link_optional("*", "sensor_type", sensor_type);
	mod.link_optional("*", "sensor_set_enabled", sensor_set_enabled);
	mod.link_optional("*", "sensor_is_enabled", sensor_is_enabled);
	mod.link_optional("*", "sensor_get_tag", sensor_get_tag);
	mod.link_optional("*", "sensor_get_owner", sensor_get_owner);
	mod.link_optional("*", "sensor_is_sensed", sensor_is_sensed);
	mod.link_optional("*", "sensor_get_sensed_bodies", sensor_get_sensed_bodies);
	mod.link_optional("*", "sensor_contains", sensor_contains);
}