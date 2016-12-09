class oUnit: public oBody
{
	float sensity;
	float move;
	float moveSpeed;
	float jump;
	float maxHp;
	float attackBase;
	float attackBonus;
	float attackFactor;
	float attackSpeed;
	oVec2 attackPower;
	oAttackType attackType;
	oAttackTarget attackTarget;
	oTargetAllow targetAllow;
	unsigned short damageType;
	unsigned short defenceType;
	
	tolua_property__common oModel* model;
	tolua_property__common float detectDistance;
	tolua_property__common CCSize attackRange;
	tolua_property__bool bool faceRight;
	tolua_property__common oBulletDef* bulletDef;
	tolua_property__common string reflexArc;
	
	tolua_readonly tolua_property__bool bool onSurface;
	
	tolua_readonly tolua_property__common oSensor* groundSensor;
	tolua_readonly tolua_property__common oSensor* detectSensor;
	tolua_readonly tolua_property__common oSensor* attackSensor;

	tolua_readonly tolua_property__common oUnitDef* unitDef;
	tolua_readonly tolua_property__common oAction* currentAction;
	
	tolua_readonly tolua_property__common float width;
	tolua_readonly tolua_property__common float height;
	
	oAction* attachAction(const char* name);
	void removeAction(const char* name);
	void removeAllActions();
	oAction* getAction(const char* name);

	bool start(const char* name);
	void stop();
	bool isDoing(const char* name);
	
	void attachInstinct(int id);
	void removeInstinct(int id);
	void removeAllInstincts();
	
	void set(const char* name, float value);
	float get(const char* name);
	void remove(const char* name);
	void clear();
	
	static tolua_outside oUnit* oUnit_create @ create(oUnitDef* unitDef, oWorld* world, oVec2 pos = oVec2::zero, float rot = 0);
};
