enum ResolutionPolicy {};

class CCEGLView @ CCView
{
	#define kResolutionExactFit @ ExactFit
	#define kResolutionNoBorder @ NoBorder
	#define kResolutionShowAll @ ShowAll
	#define kResolutionUnKnown @ UnKnown
	tolua_readonly tolua_property__common CCSize visibleSize;
	tolua_readonly tolua_property__common oVec2 visibleOrigin;
	tolua_readonly tolua_property__common float scaleX;
	tolua_readonly tolua_property__common float scaleY;
	tolua_readonly tolua_property__common CCSize designResolutionSize;
	tolua_property__common CCSize frameSize;
	tolua_property__common CCRect viewPortRect @ viewPort;
	tolua_property__common char* viewName;
	void setDesignResolutionSize @ setDesignResolution(float width, float height, ResolutionPolicy resolutionPolicy);	
	void setScissorInPoints @ setScissorRect(float x , float y , float w , float h);
	static CCEGLView* sharedOpenGLView @ create();
};
