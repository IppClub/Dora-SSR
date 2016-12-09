class oFixtureDef {};
enum b2BodyType {};

class oBodyDef: public CCObject
{
public:
	#define b2_staticBody @ Static
	#define b2_dynamicBody @ Dynamic
	#define b2_kinematicBody @ Kinematic
	b2BodyType type;
	float linearDamping;
	float angularDamping;
	bool fixedRotation;
	bool bullet @ isBullet;
	float gravityScale;
	oVec2 offset @ position;
	float angleOffset @ angle;
	string face;
	oVec2 facePos;
	static oFixtureDef* polygon(
		oVec2& center,
		float width,
		float height,
		float angle = 0.0f,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	static oFixtureDef* polygon(
		float width,
		float height,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	static oFixtureDef* polygon(
		oVec2 vertices[tolua_len],
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	void attachPolygon(
		oVec2& center,
		float width,
		float height,
		float angle = 0.0f,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	void attachPolygon(
		float width,
		float height,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	void attachPolygon(
		oVec2 vertices[tolua_len],
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	static oFixtureDef* loop(
		oVec2 vertices[tolua_len],
		float friction = 0.4f,
		float restitution = 0.0f);
	void attachLoop(
		oVec2 vertices[tolua_len],
		float friction = 0.4f,
		float restitution = 0.0f);
	static oFixtureDef* circle(
		oVec2& center,
		float radius,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	static oFixtureDef* circle(
		float radius,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	void attachCircle(
		oVec2& center,
		float radius,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	void attachCircle(
		float radius,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	static oFixtureDef* chain(
		oVec2 vertices[tolua_len],
		float friction = 0.4f,
		float restitution = 0.0f);
	void attachChain(
		oVec2 vertices[tolua_len],
		float friction = 0.4f,
		float restitution = 0.0f);
	void attachPolygonSensor(
		int tag,
		float width,
		float height);
	void attachPolygonSensor(
		int tag,
		float width,
		float height,
		oVec2& center,
		float angle = 0.0f);
	void attachPolygonSensor(
		int tag,
		oVec2 vertices[tolua_len]);
	void attachCircleSensor(
		int tag,
		oVec2& center,
		float radius);
	void attachCircleSensor(
		int tag,
		float radius);
	static oBodyDef* create();
};
