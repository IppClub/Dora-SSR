class CCLabelTTF: public CCSprite
{
	tolua_property__common char* text;
	tolua_property__common CCTextAlignment horizontalAlignment;
	tolua_property__common CCVerticalTextAlignment verticalAlignment;
	tolua_property__common CCSize dimensions;
	tolua_property__common float fontSize;
	tolua_property__common char* fontName;

	static CCLabelTTF* create();
	static CCLabelTTF* create(const char* str, const char* fontName, float fontSize);
};
