class oSlotList : public CCObject
{
	void set(tolua_function handler);
	void add(tolua_function handler);
	bool remove(tolua_function handler);
	void clear();
};
