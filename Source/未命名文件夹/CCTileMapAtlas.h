class CCTileMapAtlas: public CCNode
{
	void setTile(ccColor3 tile, oVec2 position);
	ccColor3 tileAt @ getTile(oVec2& pos);

	static CCTileMapAtlas* create(const char* tile, const char* mapFile, int tileWidth, int tileHeight);
};
