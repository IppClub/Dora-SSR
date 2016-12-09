class oSensor: public CCObject
{
	tolua_property__bool bool enabled;
	tolua_readonly tolua_property__common int tag;
	tolua_readonly tolua_property__common oBody* owner;
	tolua_readonly tolua_property__bool bool sensed;
	tolua_readonly tolua_property__common CCArray* sensedBodies;
	bool contains(oBody* body);
};
