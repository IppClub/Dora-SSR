class oJointDef : public CCObject
{
	oVec2 center;
	oVec2 position;
	float angle;
	static oJointDef* distance(
		bool collision,
		char* bodyA,
		char* bodyB,
		oVec2 anchorA,
		oVec2 anchorB,
		float frequency = 0.0f,
		float damping = 0.0f);
	static oJointDef* friction(
		bool collision,
		char* bodyA,
		char* bodyB,
		oVec2 worldPos,
		float maxForce,
		float maxTorque);
	static oJointDef* gear(
		bool collision,
		char* jointA,
		char* jointB,
		float ratio = 1.0f);
	static oJointDef* spring(
		bool collision,
		char* bodyA,
		char* bodyB,
		oVec2 linearOffset,
		float angularOffset,
		float maxForce,
		float maxTorque,
		float correctionFactor = 1.0f);
	static oJointDef* prismatic(
		bool collision,
		char* bodyA,
		char* bodyB,
		oVec2 worldPos,
		oVec2 axis,
		float lowerTranslation = 0.0f,
		float upperTranslation = 0.0f,
		float maxMotorForce = 0.0f,
		float motorSpeed = 0.0f);
	static oJointDef* pulley(
		bool collision,
		char* bodyA,
		char* bodyB,
		oVec2 anchorA,
		oVec2 anchorB,
		oVec2 groundAnchorA,
		oVec2 groundAnchorB,
		float ratio = 1.0f);
	static oJointDef* revolute(
		bool collision,
		char* bodyA,
		char* bodyB,
		oVec2 worldPos,
		float lowerAngle = 0.0f,
		float upperAngle = 0.0f,
		float maxMotorTorque = 0.0f,
		float motorSpeed = 0.0f);
	static oJointDef* rope(
		bool collision,
		char* bodyA,
		char* bodyB,
		oVec2 anchorA,
		oVec2 anchorB,
		float maxLength);
	static oJointDef* weld(
		bool collision,
		char* bodyA,
		char* bodyB,
		oVec2 worldPos,
		float frequency = 0.0f,
		float damping = 0.0f);
	static oJointDef* wheel(
		bool collision,
		char* bodyA,
		char* bodyB,
		oVec2 worldPos,
		oVec2 axis,
		float maxMotorTorque = 0.0f,
		float motorSpeed = 0.0f,
		float frequency = 2.0f,
		float damping = 0.7f);
};

class oJoint: public CCObject
{
	static oJoint* distance(
		bool collision,
		oBody* bodyA,
		oBody* bodyB,
		oVec2 anchorA,
		oVec2 anchorB,
		float frequency = 0.0f,
		float damping = 0.0f);
	static oJoint* friction(
		bool collision,
		oBody* bodyA,
		oBody* bodyB,
		oVec2 worldPos,
		float maxForce,
		float maxTorque);
	static oJoint* gear(
		bool collision,
		oJoint* jointA,
		oJoint* jointB,
		float ratio = 1.0f);
	static oJoint* spring(
		bool collision,
		oBody* bodyA,
		oBody* bodyB,
		oVec2 linearOffset,
		float angularOffset,
		float maxForce,
		float maxTorque,
		float correctionFactor = 1.0f);
	static oMoveJoint* move(
		bool collision,
		oBody* bodyA,
		oBody* bodyB,
		oVec2 targetPos,
		float maxForce,
		float frequency = 5.0f,
		float damping = 0.7f);
	static oMotorJoint* prismatic(
		bool collision,
		oBody* bodyA,
		oBody* bodyB,
		oVec2 worldPos,
		oVec2 axis,
		float lowerTranslation = 0.0f,
		float upperTranslation = 0.0f,
		float maxMotorForce = 0.0f,
		float motorSpeed = 0.0f);
	static oJoint* pulley(
		bool collision,
		oBody* bodyA,
		oBody* bodyB,
		oVec2 anchorA,
		oVec2 anchorB,
		oVec2 groundAnchorA,
		oVec2 groundAnchorB,
		float ratio = 1.0f);
	static oMotorJoint* revolute(
		bool collision,
		oBody* bodyA,
		oBody* bodyB,
		oVec2 worldPos,
		float lowerAngle = 0.0f,
		float upperAngle = 0.0f,
		float maxMotorTorque = 0.0f,
		float motorSpeed = 0.0f);
	static oJoint* rope(
		bool collision,
		oBody* bodyA,
		oBody* bodyB,
		oVec2 anchorA,
		oVec2 anchorB,
		float maxLength);
	static oJoint* weld(
		bool collision,
		oBody* bodyA,
		oBody* bodyB,
		oVec2 worldPos, 
		float frequency = 0.0f,
		float damping = 0.0f);
	static oMotorJoint* wheel(
		bool collision,
		oBody* bodyA,
		oBody* bodyB,
		oVec2 worldPos,
		oVec2 axis,
		float maxMotorTorque = 0.0f,
		float motorSpeed = 0.0f,
		float frequency = 2.0f,
		float damping = 0.7f);
	tolua_readonly tolua_property__common oWorld* world;
	void destroy();
	static oJoint* create(oJointDef* def, CCDictionary* itemDict);
};

class oMoveJoint: public oJoint
{
	tolua_property__common oVec2 position;
};

class oMotorJoint: public oJoint
{
	tolua_property__bool bool enabled;
	tolua_property__common float force;
	tolua_property__common float speed;
};