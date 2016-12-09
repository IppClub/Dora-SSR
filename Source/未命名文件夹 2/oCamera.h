class oCamera: public CCNode
{
	tolua_property__common CCRect boundary;
	tolua_property__common oVec2 followRatio;
	void follow(CCNode* target);
};
