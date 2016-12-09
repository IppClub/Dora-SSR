enum CCProgressTimerType{};

class CCProgressTimer: public CCNode
{
	#define kCCProgressTimerTypeRadial @ Radial
	#define kCCProgressTimerTypeBar @ Bar

	tolua_property__common oVec2 midpoint @ midPoint;
	tolua_property__common CCProgressTimerType type;
	tolua_property__common float percentage;
	tolua_property__common CCSprite* sprite;
	tolua_property__common oVec2 barChangeRate;
	tolua_property__bool bool reverseDirection;

	static CCProgressTimer* create(CCSprite* sp, CCProgressTimerType type = kCCProgressTimerTypeRadial);
};
