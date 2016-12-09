class CCDirector
{
	tolua_readonly tolua_property__common CCScene* runningScene @ currentScene;
	tolua_readonly tolua_property__common double animationInterval;
	tolua_readonly tolua_property__common unsigned int numberOfDraws;
	tolua_readonly tolua_property__common float deltaTime;
	tolua_readonly tolua_property__common float updateInterval;
	tolua_readonly tolua_property__common float drawInterval;
	tolua_readonly tolua_property__common float eclapsedInterval;
	tolua_readonly tolua_property__bool bool paused;
	tolua_readonly tolua_property__common CCSize winSize;
	tolua_readonly tolua_property__common CCSize visibleSize;
	tolua_readonly tolua_property__common oVec2 visibleOrigin;
	tolua_readonly tolua_property__common int sceneStackSize;

	tolua_property__bool bool displayStats;
	tolua_property__common float contentScaleFactor;
	tolua_property__common CCNode* notificationNode;
	tolua_property__common CCScheduler* scheduler;

	//oVec2 convertToGL(oVec2 point);
	//oVec2 convertToUI(oVec2 point);

	void runWithScene @ run(CCScene *scene);
	void pause();
	void resume();
	void end @ stop();
	
	void purgeCachedData @ purge();

	//void pushScene(CCScene* scene);
	void popScene(bool cleanup = true);
	void popToRootScene();
	void replaceScene(CCScene* scene, bool cleanup = true);

	void setDepthTest(bool var);
	
	void scheduleUpdateLua @ schedule(tolua_function handler);
	void unscheduleUpdateLua @ unschedule();

	static CCDirector* sharedDirector @ create();
};
