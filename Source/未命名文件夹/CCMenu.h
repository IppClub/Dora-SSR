class CCMenu: public CCLayer
{
	#define kCCMenuHandlerPriority @ DefaultHandlerPriority
	
	tolua_property__bool bool enabled;

	CCSize alignItemsVerticallyWithPadding @ alignItemsVertically(float padding = 10);
	CCSize alignItemsHorizontallyWithPadding @ alignItemsHorizontally(float padding = 10);
	CCSize alignItemsWithPadding @ alignItems(float padding = 10);
	void moveAndCullItems(oVec2& delta);

	static CCMenu* create();
};
