class oEffect: public CCNode
{
	tolua_readonly tolua_property__bool bool playing;
	void start();
	void stop();
	void autoRemove();
	static oEffect* create(const char* name);
	static tolua_outside void oEffect_update @ update(oEffect* effect, tolua_table table_idx);
};
