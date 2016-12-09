class CCObject
{
	tolua_readonly tolua_property__common int objectId @ id;
	tolua_readonly tolua_property__common int luaRef @ ref;
	static tolua_readonly tolua_property__common unsigned int objectCount @ count;
	static tolua_readonly tolua_property__common unsigned int maxObjectCount @ maxCount;
	static tolua_readonly tolua_property__common unsigned int luaRefCount;
	static tolua_readonly tolua_property__common unsigned int maxLuaRefCount;
	static tolua_outside tolua_readonly tolua_property__qt int  toluafix_get_callback_ref_count @ callRefCount;
	static tolua_outside tolua_readonly tolua_property__qt int  toluafix_get_max_callback_ref_count @ maxCallRefCount;
};
