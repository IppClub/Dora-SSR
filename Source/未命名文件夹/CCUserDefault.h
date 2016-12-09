class CCUserDefault
{
	static tolua_readonly tolua_property__common string& xMLFilePath @ filePath;
	
	bool getBoolForKey @ get(const char* pKey);
	double getDoubleForKey @ get(const char* pKey);
	string getStringForKey @ get(const char* pKey);

	void setBoolForKey @ set(const char* pKey, bool value);
	void setDoubleForKey @ set(const char* pKey, double value);
	void setStringForKey @ set(const char* pKey, string value);

	static CCUserDefault* sharedUserDefault @ create();
};
