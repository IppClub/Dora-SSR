class oModel: public CCNode
{
	tolua_property__common string look;
	tolua_property__common float speed;
	tolua_property__bool bool loop;
	tolua_property__common float time;
	tolua_readonly tolua_property__common float duration;
	tolua_property__common float recovery;
	tolua_property__bool bool faceRight;
	tolua_readonly tolua_property__bool bool playing;
	tolua_readonly tolua_property__bool bool paused;
	tolua_readonly tolua_property__common string currentAnimationName @ currentAnimation;
	tolua_outside oVec2 oModel_getKey @ getKey(const char* key);
	float play(const char* name);
	void pause();
	void resume();
	void resume(const char* name);
	void stop();
	void reset();
	CCNode* getNodeByName @ getChildByName(const char* name);
	static tolua_outside oModel* oModel_create @ create(const char* filename);
	static oModel* none();
};
