class CCSprite: public CCNode//CCNodeRGBA
{
	tolua_property__common CCTexture2D* texture;
	tolua_property__common CCRect textureRect;
	tolua_property__common ccBlendFunc blendFunc;
	
	tolua_property__bool bool flipX;
	tolua_property__bool bool flipY;

	static CCSprite* create();
	static CCSprite* createWithTexture(CCTexture2D* pTexture);
	static CCSprite* createWithTexture(CCTexture2D* pTexture, CCRect rect);
	static tolua_outside CCSprite* CCSprite_createWithClip @ createWithClip(const char* clipStr );
};
