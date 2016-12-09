enum oAttackType{};
module oAttackType
{
	#define oAttackType::Melee @ Melee
	#define oAttackType::Range @ Range
};

enum oAttackTarget{};
module oAttackTarget
{
	#define oAttackTarget::Single @ Single
	#define oAttackTarget::Multi @ Multi
};

enum oRelation{};
module oRelation
{
	#define oRelation::Unkown @ Unkown
	#define oRelation::Friend @ Friend
	#define oRelation::Neutral @ Neutral
	#define oRelation::Enemy @ Enemy
	#define oRelation::Any @ Any
};

class oTargetAllow
{
	tolua_property__bool bool terrainAllowed;
	void allow(oRelation flag, bool allow);
	bool isAllow(oRelation flag);
};
