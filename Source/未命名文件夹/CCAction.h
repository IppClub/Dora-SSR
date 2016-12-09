class CCAction: public CCObject
{
	tolua_readonly tolua_property__bool bool done;
	tolua_readonly tolua_property__common CCNode* target;
};

class CCFiniteTimeAction: public CCAction
{
	tolua_readonly tolua_property__common float duration;
	CCFiniteTimeAction* reverse();
};

class CCActionInterval: public CCFiniteTimeAction
{
	tolua_readonly tolua_property__common float elapsed;
	CCActionInterval* reverse();
};

class CCSpeed: public CCAction
{
	tolua_property__common float speed @ rate;
	static CCSpeed* create(CCActionInterval *pAction, float fRate);
};

CCAction* CCFollow::create @ CCFollow(CCNode* pFollowedNode);
CCAction* CCFollow::create @ CCFollow(CCNode* pFollowedNode, CCRect rect);

CCActionInterval* CCSequence::create @ CCSequence(CCFiniteTimeAction* actions[tolua_len]);

CCActionInterval* CCRepeat::create @ CCRepeat(CCFiniteTimeAction *pAction, unsigned int times);

CCActionInterval* CCRepeatForever::create @ CCRepeatForever(CCActionInterval* pAction);

CCActionInterval* CCSpawn::create @ CCSpawn(CCFiniteTimeAction* actions[tolua_len]);

CCActionInterval* CCJumpBy::create @ CCJumpBy(float duration, oVec2 position, float height, int jumps);

CCActionInterval* CCJumpTo::create @ CCJumpTo(float duration, oVec2 position, float height, int jumps);

CCActionInterval* CCBezierBy::create @ CCBezierBy(float t, oVec2& deltaPosition, oVec2& deltaControlA, oVec2& deltaControlB);

CCActionInterval* CCBezierTo::create @ CCBezierTo(float t, oVec2& position, oVec2& controlA, oVec2& controlB);

CCActionInterval* CCBlink::create @ CCBlink(float duration, unsigned int uBlinks);

CCActionInterval* CCTintTo::create @ CCTintTo(float duration, unsigned int colorValue);

CCActionInterval* CCTintBy::create @ CCTintBy(float duration, unsigned int colorValue);

CCActionInterval* CCDelayTime::create @ CCDelay(float d);

CCFiniteTimeAction* CCShow::create @ CCShow();

CCFiniteTimeAction* CCHide::create @ CCHide();

CCFiniteTimeAction* CCToggleVisibility::create @ CCToggleVisibility();

CCFiniteTimeAction* CCFlipY::create @ CCFlipY(bool x);

CCFiniteTimeAction* CCFlipY::create @ CCFlipY(bool y);

CCFiniteTimeAction* CCCall::create @ CCCall(tolua_function handler);
