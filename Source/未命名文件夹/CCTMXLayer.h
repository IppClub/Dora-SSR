class CCTMXLayer: public CCSpriteBatchNode
{
	tolua_readonly tolua_property__common CCSize layerSize;
	tolua_readonly tolua_property__common CCSize mapTileSize;
	tolua_readonly tolua_property__common const char* layerName;

	CCSprite* tileAt @ getTile(oVec2 tileCoordinate);
	unsigned int tileGIDAt @ getTileGID(oVec2& tileCoordinate);
	void removeTileAt @ removeTile(oVec2 tileCoordinate);
	oVec2 positionAt @ getPosition(oVec2 tileCoordinate);
};
