class CCTouch: public CCObject
{
	tolua_readonly tolua_property__common oVec2 location;
    tolua_readonly tolua_property__common oVec2 previousLocation @ preLocation;
    tolua_readonly tolua_property__common oVec2 delta;
    tolua_readonly tolua_property__common int iD @ id;
};
