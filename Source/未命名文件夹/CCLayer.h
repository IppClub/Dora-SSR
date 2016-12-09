class CCLayer: public CCNode
{
	tolua_property__bool bool touchEnabled;
	tolua_property__bool bool accelerometerEnabled;
	tolua_property__bool bool keypadEnabled;
	tolua_property__bool bool multiTouches;
	tolua_property__bool bool swallowTouches;
	tolua_property__common int touchPriority;
	static CCLayer* create();
};

class CCLayerColor: public CCLayer
{
	tolua_property__common ccBlendFunc blendFunc;
	static CCLayerColor* create(ccColor4 color, float width, float height);
	static CCLayerColor* create(ccColor4 color);
	void resetColor(ccColor4 color1,ccColor4 color2, ccColor4 color3, ccColor4 color4);
};

class CCLayerGradient: public CCLayer
{
	tolua_property__common ccBlendFunc blendFunc;
	tolua_property__common ccColor3 startColor;
	tolua_property__common ccColor3 endColor;
	tolua_property__common float startOpacity;
	tolua_property__common float endOpacity;
	tolua_property__common oVec2 vector;
	tolua_property__bool bool compressedInterpolation;

	static CCLayerGradient* create(ccColor4 start, ccColor4 end, oVec2 v);
	static CCLayerGradient* create(ccColor4 start, ccColor4 end);
	static CCLayerGradient* create();
};
