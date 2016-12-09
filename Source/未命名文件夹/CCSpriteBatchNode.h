class CCSpriteBatchNode: public CCNode
{
	tolua_readonly tolua_property__common CCTexture2D* texture;
	static CCSpriteBatchNode* createWithTexture(CCTexture2D* tex);
	static CCSpriteBatchNode* createWithTexture(CCTexture2D* tex, unsigned int capacity);
	static CCSpriteBatchNode* create(const char* fileImage, unsigned int capacity);
	static CCSpriteBatchNode* create(const char* fileImage);
};
