class CCScheduler: public CCObject
{
	tolua_property__common float timeScale;

	void scheduleUpdateForTarget @ schedule(CCScheduler* pTarget, int nPriority = 0);
	void scheduleScriptFunc @ schedule(tolua_function nHandler, float fInterval = 0);

    void unscheduleUpdateForTarget @ unschedule(CCScheduler* pTarget);
	void unscheduleScriptFunc @ unschedule(tolua_function nHandler);

	static CCScheduler* create();
};
