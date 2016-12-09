class CCTextureCache
{
	tolua_outside CCTexture2D* CCTextureCache_add @ add(CCRenderTexture* renderTexture, const char* key);
	
	CCTexture2D* addImage @ load(const char* fileimage);
	void removeUnusedTextures @ removeUnused();
	void removeAllTextures @ unload();
	void removeTexture @ unload(CCTexture2D* texture);
	void removeTextureForKey @ unload(const char* textureKeyName);
	
	void dumpCachedTextureInfo @ dumpInfo();
	static CCTextureCache* sharedTextureCache @ create();
};
