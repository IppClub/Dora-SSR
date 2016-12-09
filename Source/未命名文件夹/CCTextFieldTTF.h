class CCTextFieldTTF: public CCLabelTTF
{
	bool attachWithIME();
	bool detachWithIME();

	tolua_property__common ccColor3 colorSpaceHolder @ colorPlaceHolder;
	tolua_property__common char* text;
	tolua_property__common char* placeHolder;

	static tolua_outside CCTextFieldTTF* CCTextFieldTTF_create @ create(const char* placeholder, const char* fontName, float fontSize);
};
