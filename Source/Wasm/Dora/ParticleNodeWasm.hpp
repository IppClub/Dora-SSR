static int32_t particle_type() {
	return DoraType<ParticleNode>();
}
static int32_t particlenode_is_active(int64_t self) {
	return r_cast<ParticleNode*>(self)->isActive() ? 1 : 0;
}
static void particlenode_start(int64_t self) {
	r_cast<ParticleNode*>(self)->start();
}
static void particlenode_stop(int64_t self) {
	r_cast<ParticleNode*>(self)->stop();
}
static int64_t particlenode_new(int64_t filename) {
	return from_object(ParticleNode::create(*str_from(filename)));
}
static void linkParticleNode(wasm3::module& mod) {
	mod.link_optional("*", "particle_type", particle_type);
	mod.link_optional("*", "particlenode_is_active", particlenode_is_active);
	mod.link_optional("*", "particlenode_start", particlenode_start);
	mod.link_optional("*", "particlenode_stop", particlenode_stop);
	mod.link_optional("*", "particlenode_new", particlenode_new);
}