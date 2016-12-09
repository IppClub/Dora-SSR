class CCDictionary : public CCObject
{
    tolua_readonly tolua_property__qt unsigned int count;
    tolua_readonly tolua_property__qt CCArray* allKeys @ keys;
    void removeAllObjects @ clear();
    static CCDictionary* create();
    static CCDictionary* createWithDictionary(CCDictionary* srcDict);
	static CCDictionary* createWithContentsOfFile(char* pFileName);
};
