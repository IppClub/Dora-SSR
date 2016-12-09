class oAI
{
	static tolua_readonly tolua_property__common oUnit* self;
	static tolua_readonly tolua_property__common float oldInstinctValue @ oldValue;
	static tolua_readonly tolua_property__common float newInstinctValue @ newValue;
	static CCArray* getUnitsByRelation(oRelation relation);
	static CCArray* getDetectedUnits();
	static oUnit* getNearestUnit(oRelation relation);
	static float getNearestUnitDistance(oRelation relation);

	static void add(const char* name, oAILeaf* leaf);
	static void clear();
};

