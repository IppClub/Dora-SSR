class oAction
{
	float reaction;
	float recovery;
	tolua_readonly tolua_property__common string name;
	tolua_readonly tolua_property__common int priority;
	tolua_readonly tolua_property__bool bool doing;
	tolua_readonly tolua_property__common oUnit* owner;
	static void add(
		const char* name,
		int priority,
		float reaction,
		float recovery,
		tolua_function available,
		tolua_function create,
		tolua_function stop);
	static void clear();
};
