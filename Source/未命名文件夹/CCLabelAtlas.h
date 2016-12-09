class CCLabelAtlas: public CCNode//CCAtlasNode
{
    tolua_property__common char* text;
    tolua_property__common CCTexture2D* texture;

    static CCLabelAtlas* create(const char* label, const char* charMapFile, unsigned int itemWidth, unsigned int itemHeight, unsigned int startCharMap);
    static CCLabelAtlas* create(const char* sring, const char* fntFile);
};
