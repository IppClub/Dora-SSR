class oUnitDef: public CCObject
{
	enum
	{
		GroundSensorTag = 0,
		DetectSensorTag = 1,
		AttackSensorTag = 2
	};
	tolua_readonly static const char* BulletKey;
	tolua_readonly static const char* AttackKey;
	tolua_readonly static const char* HitKey;
	tolua_readonly tolua_property__common oBodyDef* bodyDef;

	tolua_property__bool bool static;
	tolua_property__common float scale;
	tolua_property__common float density;
	tolua_property__common float friction;
	tolua_property__common float restitution;
	tolua_property__common string model;
	tolua_property__common CCSize size;

	int tag;
	float sensity;
	float move;
	float jump;
	float detectDistance;
	float maxHp;
	float attackBase;
	float attackDelay;
	float attackEffectDelay;
	CCSize attackRange;
	oVec2 attackPower;
	oAttackType attackType;
	oAttackTarget attackTarget;
	oTargetAllow targetAllow;
	unsigned short damageType;
	unsigned short defenceType;
	string bulletType;
	string attackEffect;
	string hitEffect;
	string name;
	string desc;
	string sndAttack;
	string sndDeath;
	string reflexArc;

	tolua_outside void oUnitDef_setActions @ setActions(const char* actions[tolua_len]);
	tolua_outside void oUnitDef_setInstincts @ setInstincts(int instincts[tolua_len]);
	
	static bool usePreciseHit;
	static oUnitDef* create();
};
