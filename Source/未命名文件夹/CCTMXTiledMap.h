class CCTMXTiledMap: public CCNode
{
	#define CCTMXOrientationOrtho @ Ortho
	#define CCTMXOrientationHex @ Hex
	#define CCTMXOrientationIso @ Iso

	tolua_readonly tolua_property__common CCSize mapSize;
	tolua_readonly tolua_property__common CCSize tileSize;
	tolua_readonly tolua_property__common int mapOrientation;

	CCTMXLayer* layerNamed @ getLayer(const char* layerName);

	static CCTMXTiledMap* create(const char* tmxFile);
	static CCTMXTiledMap* createWithXML(const char* tmxString, const char* resourcePath);
};
