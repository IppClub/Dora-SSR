class CCClippingNode @ CCClipNode: public CCNode
{
	tolua_property__common CCNode* stencil;
	tolua_property__common float alphaThreshold;
	tolua_property__bool bool inverted;
	
	static CCClippingNode* create();
	static CCClippingNode* create(CCNode *pStencil);
};
