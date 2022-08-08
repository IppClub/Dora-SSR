static int32_t clipnode_type()
{
	return DoraType<ClipNode>();
}
static void clipnode_set_stencil(int64_t self, int64_t var)
{
	r_cast<ClipNode*>(self)->setStencil(r_cast<Node*>(var));
}
static int64_t clipnode_get_stencil(int64_t self)
{
	return from_object(r_cast<ClipNode*>(self)->getStencil());
}
static void clipnode_set_alpha_threshold(int64_t self, float var)
{
	r_cast<ClipNode*>(self)->setAlphaThreshold(var);
}
static float clipnode_get_alpha_threshold(int64_t self)
{
	return r_cast<ClipNode*>(self)->getAlphaThreshold();
}
static void clipnode_set_inverted(int64_t self, int32_t var)
{
	r_cast<ClipNode*>(self)->setInverted(var != 0);
}
static int32_t clipnode_is_inverted(int64_t self)
{
	return r_cast<ClipNode*>(self)->isInverted() ? 1 : 0;
}
static int64_t clipnode_new(int64_t stencil)
{
	return from_object(ClipNode::create(r_cast<Node*>(stencil)));
}
static void linkClipNode(wasm3::module& mod)
{
	mod.link_optional("*", "clipnode_type", clipnode_type);
	mod.link_optional("*", "clipnode_set_stencil", clipnode_set_stencil);
	mod.link_optional("*", "clipnode_get_stencil", clipnode_get_stencil);
	mod.link_optional("*", "clipnode_set_alpha_threshold", clipnode_set_alpha_threshold);
	mod.link_optional("*", "clipnode_get_alpha_threshold", clipnode_get_alpha_threshold);
	mod.link_optional("*", "clipnode_set_inverted", clipnode_set_inverted);
	mod.link_optional("*", "clipnode_is_inverted", clipnode_is_inverted);
	mod.link_optional("*", "clipnode_new", clipnode_new);
}