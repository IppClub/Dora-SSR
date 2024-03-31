static int32_t bodydef_type() {
	return DoraType<BodyDef>();
}
static void bodydef__set_type(int64_t self, int32_t var) {
	body_def_set_type_enum(r_cast<BodyDef*>(self), s_cast<int>(var));
}
static int32_t bodydef__get_type(int64_t self) {
	return body_def_get_type_enum(r_cast<BodyDef*>(self));
}
static void bodydef_set_position(int64_t self, int64_t var) {
	r_cast<BodyDef*>(self)->offset = vec2_from(var);
}
static int64_t bodydef_get_position(int64_t self) {
	return vec2_retain(r_cast<BodyDef*>(self)->offset);
}
static void bodydef_set_angle(int64_t self, float var) {
	r_cast<BodyDef*>(self)->angleOffset = s_cast<float>(var);
}
static float bodydef_get_angle(int64_t self) {
	return r_cast<BodyDef*>(self)->angleOffset;
}
static void bodydef_set_face(int64_t self, int64_t var) {
	r_cast<BodyDef*>(self)->face = *str_from(var);
}
static int64_t bodydef_get_face(int64_t self) {
	return str_retain(r_cast<BodyDef*>(self)->face);
}
static void bodydef_set_face_pos(int64_t self, int64_t var) {
	r_cast<BodyDef*>(self)->facePos = vec2_from(var);
}
static int64_t bodydef_get_face_pos(int64_t self) {
	return vec2_retain(r_cast<BodyDef*>(self)->facePos);
}
static void bodydef_set_linear_damping(int64_t self, float var) {
	r_cast<BodyDef*>(self)->setLinearDamping(var);
}
static float bodydef_get_linear_damping(int64_t self) {
	return r_cast<BodyDef*>(self)->getLinearDamping();
}
static void bodydef_set_angular_damping(int64_t self, float var) {
	r_cast<BodyDef*>(self)->setAngularDamping(var);
}
static float bodydef_get_angular_damping(int64_t self) {
	return r_cast<BodyDef*>(self)->getAngularDamping();
}
static void bodydef_set_linear_acceleration(int64_t self, int64_t var) {
	r_cast<BodyDef*>(self)->setLinearAcceleration(vec2_from(var));
}
static int64_t bodydef_get_linear_acceleration(int64_t self) {
	return vec2_retain(r_cast<BodyDef*>(self)->getLinearAcceleration());
}
static void bodydef_set_fixed_rotation(int64_t self, int32_t var) {
	r_cast<BodyDef*>(self)->setFixedRotation(var != 0);
}
static int32_t bodydef_is_fixed_rotation(int64_t self) {
	return r_cast<BodyDef*>(self)->isFixedRotation() ? 1 : 0;
}
static void bodydef_set_bullet(int64_t self, int32_t var) {
	r_cast<BodyDef*>(self)->setBullet(var != 0);
}
static int32_t bodydef_is_bullet(int64_t self) {
	return r_cast<BodyDef*>(self)->isBullet() ? 1 : 0;
}
static int64_t bodydef_polygon_with_center(int64_t center, float width, float height, float angle, float density, float friction, float restitution) {
	return r_cast<int64_t>(BodyDef::polygon(vec2_from(center), width, height, angle, density, friction, restitution));
}
static int64_t bodydef_polygon(float width, float height, float density, float friction, float restitution) {
	return r_cast<int64_t>(BodyDef::polygon(width, height, density, friction, restitution));
}
static int64_t bodydef_polygon_with_vertices(int64_t vertices, float density, float friction, float restitution) {
	return r_cast<int64_t>(BodyDef::polygon(from_vec2_vec(vertices), density, friction, restitution));
}
static void bodydef_attach_polygon_center(int64_t self, int64_t center, float width, float height, float angle, float density, float friction, float restitution) {
	r_cast<BodyDef*>(self)->attachPolygon(vec2_from(center), width, height, angle, density, friction, restitution);
}
static void bodydef_attach_polygon(int64_t self, float width, float height, float density, float friction, float restitution) {
	r_cast<BodyDef*>(self)->attachPolygon(width, height, density, friction, restitution);
}
static void bodydef_attach_polygon_with_vertices(int64_t self, int64_t vertices, float density, float friction, float restitution) {
	r_cast<BodyDef*>(self)->attachPolygon(from_vec2_vec(vertices), density, friction, restitution);
}
static int64_t bodydef_multi(int64_t vertices, float density, float friction, float restitution) {
	return r_cast<int64_t>(BodyDef::multi(from_vec2_vec(vertices), density, friction, restitution));
}
static void bodydef_attach_multi(int64_t self, int64_t vertices, float density, float friction, float restitution) {
	r_cast<BodyDef*>(self)->attachMulti(from_vec2_vec(vertices), density, friction, restitution);
}
static int64_t bodydef_disk_with_center(int64_t center, float radius, float density, float friction, float restitution) {
	return r_cast<int64_t>(BodyDef::disk(vec2_from(center), radius, density, friction, restitution));
}
static int64_t bodydef_disk(float radius, float density, float friction, float restitution) {
	return r_cast<int64_t>(BodyDef::disk(radius, density, friction, restitution));
}
static void bodydef_attach_disk_with_center(int64_t self, int64_t center, float radius, float density, float friction, float restitution) {
	r_cast<BodyDef*>(self)->attachDisk(vec2_from(center), radius, density, friction, restitution);
}
static void bodydef_attach_disk(int64_t self, float radius, float density, float friction, float restitution) {
	r_cast<BodyDef*>(self)->attachDisk(radius, density, friction, restitution);
}
static int64_t bodydef_chain(int64_t vertices, float friction, float restitution) {
	return r_cast<int64_t>(BodyDef::chain(from_vec2_vec(vertices), friction, restitution));
}
static void bodydef_attach_chain(int64_t self, int64_t vertices, float friction, float restitution) {
	r_cast<BodyDef*>(self)->attachChain(from_vec2_vec(vertices), friction, restitution);
}
static void bodydef_attach_polygon_sensor(int64_t self, int32_t tag, float width, float height) {
	r_cast<BodyDef*>(self)->attachPolygonSensor(s_cast<int>(tag), width, height);
}
static void bodydef_attach_polygon_sensor_with_center(int64_t self, int32_t tag, int64_t center, float width, float height, float angle) {
	r_cast<BodyDef*>(self)->attachPolygonSensor(s_cast<int>(tag), vec2_from(center), width, height, angle);
}
static void bodydef_attach_polygon_sensor_with_vertices(int64_t self, int32_t tag, int64_t vertices) {
	r_cast<BodyDef*>(self)->attachPolygonSensor(s_cast<int>(tag), from_vec2_vec(vertices));
}
static void bodydef_attach_disk_sensor_with_center(int64_t self, int32_t tag, int64_t center, float radius) {
	r_cast<BodyDef*>(self)->attachDiskSensor(s_cast<int>(tag), vec2_from(center), radius);
}
static void bodydef_attach_disk_sensor(int64_t self, int32_t tag, float radius) {
	r_cast<BodyDef*>(self)->attachDiskSensor(s_cast<int>(tag), radius);
}
static int64_t bodydef_new() {
	return from_object(BodyDef::create());
}
static void linkBodyDef(wasm3::module3& mod) {
	mod.link_optional("*", "bodydef_type", bodydef_type);
	mod.link_optional("*", "bodydef__set_type", bodydef__set_type);
	mod.link_optional("*", "bodydef__get_type", bodydef__get_type);
	mod.link_optional("*", "bodydef_set_position", bodydef_set_position);
	mod.link_optional("*", "bodydef_get_position", bodydef_get_position);
	mod.link_optional("*", "bodydef_set_angle", bodydef_set_angle);
	mod.link_optional("*", "bodydef_get_angle", bodydef_get_angle);
	mod.link_optional("*", "bodydef_set_face", bodydef_set_face);
	mod.link_optional("*", "bodydef_get_face", bodydef_get_face);
	mod.link_optional("*", "bodydef_set_face_pos", bodydef_set_face_pos);
	mod.link_optional("*", "bodydef_get_face_pos", bodydef_get_face_pos);
	mod.link_optional("*", "bodydef_set_linear_damping", bodydef_set_linear_damping);
	mod.link_optional("*", "bodydef_get_linear_damping", bodydef_get_linear_damping);
	mod.link_optional("*", "bodydef_set_angular_damping", bodydef_set_angular_damping);
	mod.link_optional("*", "bodydef_get_angular_damping", bodydef_get_angular_damping);
	mod.link_optional("*", "bodydef_set_linear_acceleration", bodydef_set_linear_acceleration);
	mod.link_optional("*", "bodydef_get_linear_acceleration", bodydef_get_linear_acceleration);
	mod.link_optional("*", "bodydef_set_fixed_rotation", bodydef_set_fixed_rotation);
	mod.link_optional("*", "bodydef_is_fixed_rotation", bodydef_is_fixed_rotation);
	mod.link_optional("*", "bodydef_set_bullet", bodydef_set_bullet);
	mod.link_optional("*", "bodydef_is_bullet", bodydef_is_bullet);
	mod.link_optional("*", "bodydef_polygon_with_center", bodydef_polygon_with_center);
	mod.link_optional("*", "bodydef_polygon", bodydef_polygon);
	mod.link_optional("*", "bodydef_polygon_with_vertices", bodydef_polygon_with_vertices);
	mod.link_optional("*", "bodydef_attach_polygon_center", bodydef_attach_polygon_center);
	mod.link_optional("*", "bodydef_attach_polygon", bodydef_attach_polygon);
	mod.link_optional("*", "bodydef_attach_polygon_with_vertices", bodydef_attach_polygon_with_vertices);
	mod.link_optional("*", "bodydef_multi", bodydef_multi);
	mod.link_optional("*", "bodydef_attach_multi", bodydef_attach_multi);
	mod.link_optional("*", "bodydef_disk_with_center", bodydef_disk_with_center);
	mod.link_optional("*", "bodydef_disk", bodydef_disk);
	mod.link_optional("*", "bodydef_attach_disk_with_center", bodydef_attach_disk_with_center);
	mod.link_optional("*", "bodydef_attach_disk", bodydef_attach_disk);
	mod.link_optional("*", "bodydef_chain", bodydef_chain);
	mod.link_optional("*", "bodydef_attach_chain", bodydef_attach_chain);
	mod.link_optional("*", "bodydef_attach_polygon_sensor", bodydef_attach_polygon_sensor);
	mod.link_optional("*", "bodydef_attach_polygon_sensor_with_center", bodydef_attach_polygon_sensor_with_center);
	mod.link_optional("*", "bodydef_attach_polygon_sensor_with_vertices", bodydef_attach_polygon_sensor_with_vertices);
	mod.link_optional("*", "bodydef_attach_disk_sensor_with_center", bodydef_attach_disk_sensor_with_center);
	mod.link_optional("*", "bodydef_attach_disk_sensor", bodydef_attach_disk_sensor);
	mod.link_optional("*", "bodydef_new", bodydef_new);
}