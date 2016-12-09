class oBullet: public oBody
{
	oTargetAllow targetAllow;
	tolua_readonly tolua_property__bool bool faceRight;
	tolua_readonly tolua_property__common oUnit* owner;
	tolua_readonly tolua_property__common oSensor* detectSensor;
	tolua_readonly tolua_property__common oBulletDef* bulletDef;
	tolua_property__common CCNode* face;

	void destroy();
	static tolua_outside oBullet* oBullet_create @ create(oBulletDef* def, oUnit* owner);
};
