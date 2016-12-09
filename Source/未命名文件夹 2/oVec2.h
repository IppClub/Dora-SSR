class oVec2
{
	oVec2(float x = 0.0f, float y = 0.0f);
	oVec2(oVec2& other);
	~oVec2();
	oVec2 operator+(oVec2& vec);
	oVec2 operator-(oVec2& vec);
	oVec2 operator*(float value);
	oVec2 operator*(oVec2& vec);
	oVec2 operator/(float value);
	bool operator==(oVec2& vec);
	float distance(oVec2& vec);
	float distanceSquared(oVec2& vec);
	tolua_readonly tolua_property__qt float length;
	tolua_readonly tolua_property__qt float lengthSquared;
	tolua_readonly tolua_property__qt float angle;
	void normalize();
	void clamp(oVec2& from, oVec2& to);
	float x;
	float y;
	static tolua_readonly oVec2 zero;
};
