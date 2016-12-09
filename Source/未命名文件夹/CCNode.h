class CCNode: public CCObject
{
	tolua_property__common int zOrder;
	tolua_property__common float rotation @ angle;
	tolua_property__common float scaleX;
	tolua_property__common float scaleY;
	tolua_property__common oVec2 position;
	tolua_property__common float positionX;
	tolua_property__common float positionY;
	tolua_property__common float positionZ;
	tolua_property__common float skewX;
	tolua_property__common float skewY;
	tolua_property__bool bool visible;
	tolua_property__common oVec2 anchorPoint @ anchor;
	tolua_property__common CCSize contentSize;
	tolua_property__common float width;
	tolua_property__common float height;
	tolua_property__common int tag;
	tolua_property__common ccColor3 color;
	tolua_property__common float opacity;
	tolua_property__bool bool cascadeOpacity;
	tolua_property__bool bool cascadeColor;
	tolua_property__common CCNode* transformTarget;
	//tolua_property__common CCGLProgram* shaderProgram;
	tolua_property__common CCScheduler* scheduler;
	tolua_property__common CCObject* userObject @ data;
	tolua_readonly tolua_property__common CCNode* parent;
	tolua_readonly tolua_property__common CCArray* children;
	tolua_readonly tolua_property__common CCRect boundingBox;
	tolua_readonly tolua_property__qt const char* description;
	tolua_readonly tolua_property__qt int numberOfRunningActions;
	tolua_readonly tolua_property__bool bool running;

	CCNode* addTo(CCNode* child, int zOrder, int tag);
	CCNode* addTo(CCNode* child, int zOrder);
	CCNode* addTo(CCNode* child);

	void addChild(CCNode* child, int zOrder, int tag);
	void addChild(CCNode* child, int zOrder);
	void addChild(CCNode* child);
	void removeChild(CCNode* child, bool cleanup = true);
	void removeChildByTag(int tag, bool cleanup = true);
	void removeAllChildrenWithCleanup(bool cleanup = true);
	void runAction(CCAction* action);
	void stopAllActions();
	void perform(CCAction* action);
	void stopAction(CCAction* action);
	void cleanup();

	CCNode* getChildByTag(int tag);

	void scheduleUpdateWithPriorityLua @ schedule(tolua_function nHandler, int priority = 0);
	void unscheduleUpdate @ unschedule();
	tolua_readonly tolua_property__bool bool updateScheduled @ scheduled;

	oVec2 convertToNodeSpaceAR @ convertToNodeSpace(oVec2& worldPoint);
	oVec2 convertToWorldSpaceAR @ convertToWorldSpace(oVec2& nodePoint);
	oVec2 convertToGameSpace(oVec2& nodePoint);

	static CCNode* create();
};
