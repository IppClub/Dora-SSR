class oLine: public CCNode
{
	void set(oVec2 vecs[tolua_len]);
	static oLine* create();
	static oLine* create(oVec2 vecs[tolua_len], ccColor4& color);
};
