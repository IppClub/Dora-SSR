class CCMotionStreak: public CCNode
{
	tolua_property__common CCTexture2D* texture;
	tolua_property__common ccBlendFunc blendFunc;
	
	tolua_property__bool bool fastMode;
	tolua_property__bool bool startingPositionInitialized @ startPosInit;
	
	void tintWithColor(ccColor3 colors);
	void reset();
	
	static CCMotionStreak* create(float fade, float minSeg, float stroke, ccColor3 color, const char* path);
	static CCMotionStreak* create(float fade, float minSeg, float stroke, ccColor3 color, CCTexture2D* texture);
};
