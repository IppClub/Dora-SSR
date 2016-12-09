class CCSize
{
    CCSize();
    CCSize(float width, float height);
	~CCSize();
	
    float width;
    float height;
    
	bool operator==(CCSize & target);
	
	static tolua_readonly CCSize zero;
};

class CCRect
{
	CCRect();
	CCRect(oVec2& origin, CCSize& size);
    CCRect(float x, float y, float width, float height);
	~CCRect();
	
    oVec2 origin;
    CCSize size;
	tolua_property__common float x;
	tolua_property__common float y;
	tolua_property__common float width;
	tolua_property__common float height;
	tolua_property__common float left;
	tolua_property__common float right;
	tolua_property__common float bottom;
	tolua_property__common float top;
	tolua_property__common float centerX;
	tolua_property__common float centerY;

	bool operator==(CCRect& rect);
	bool containsPoint(oVec2& point);
	bool intersectsRect(CCRect& rect);
	void set(float x, float y, float width, float height);

	static tolua_readonly CCRect zero;
};
