enum CCTexture2DPixelFormat{};

class CCTexture2D: public CCObject
{
	#define kCCTexture2DPixelFormat_RGB888 @ RGB888
	#define kCCTexture2DPixelFormat_RGB565 @ RGB565
	#define kCCTexture2DPixelFormat_A8 @ A8
	#define kCCTexture2DPixelFormat_I8 @ I8
	#define kCCTexture2DPixelFormat_AI88 @ AI88
	#define kCCTexture2DPixelFormat_RGBA4444 @ RGBA4444
	#define kCCTexture2DPixelFormat_RGB5A1 @ RGB5A1
	#define kCCTexture2DPixelFormat_PVRTC4 @ PVRTC4
	#define kCCTexture2DPixelFormat_PVRTC2 @ PVRTC2
	#define kCCTexture2DPixelFormat_Default @ Default
	#define kCCTexture2DPixelFormat_RGBA8888 @ RGBA8888

	tolua_readonly tolua_property__common CCSize contentSizeInPixels @ size;
	tolua_readonly tolua_property__qt bool hasMipmaps;

	tolua_property__bool bool antiAlias;
	tolua_property__bool bool repeatX;
	tolua_property__bool bool repeatY;

	static tolua_property__common CCTexture2DPixelFormat defaultAlphaPixelFormat @ pixelFormat;
	
	void generateMipmap();
};
