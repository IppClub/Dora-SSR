class CCMenuItem: public CCNode
{
	tolua_readonly tolua_property__qt CCRect rect @ hitArea;
	tolua_property__bool bool enabled;
	static CCMenuItem* create();
};
