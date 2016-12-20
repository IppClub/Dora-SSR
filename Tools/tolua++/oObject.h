class oObject
{
	tolua_readonly tolua_property__common unsigned int id;
	tolua_readonly tolua_property__common unsigned int luaRef @ ref;
	static tolua_readonly tolua_property__common unsigned int objectCount @ count;
	static tolua_readonly tolua_property__common unsigned int maxObjectCount @ maxCount;
	static tolua_readonly tolua_property__common unsigned int luaRefCount;
	static tolua_readonly tolua_property__common unsigned int maxLuaRefCount;
	static tolua_readonly tolua_property__common unsigned int luaCallbackCount @ callRefCount;
	static tolua_readonly tolua_property__common unsigned int maxLuaCallbackCount @ maxCallRefCount;
};
