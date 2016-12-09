enum tCCImageFormat{};

class CCRenderTexture @ CCRenderTarget: public CCNode
{
	tolua_property__bool bool autoDraw;
	void beginWithClear @ beginDraw(ccColor4& color = ccColor4());
	void render @ draw(CCNode* target);
	void end @ endDraw();
	bool saveToFile @ save(char* filename);
	static tolua_outside CCRenderTexture* CCRenderTexture_create @ create(int w, int h, bool withDepthStencil = false);
};
