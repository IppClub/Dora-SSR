class oPlatformWorld: public oWorld
{
	tolua_readonly tolua_property__common oCamera* camera;
	tolua_readonly tolua_property__common CCNode* UILayer;
	oNode3D* getLayer(int zOrder);
	void removeLayer(int zOrder);
	void removeAllLayers();
	void swapLayer(int orderA, int orderB);
	void setLayerRatio(int zOrder, oVec2& ratio);
	oVec2& getLayerRatio(int zOrder);
	void setLayerOffset(int zOrder, oVec2& offset);
	oVec2& getLayerOffset(int zOrder);
	
	static tolua_outside oBullet* oPlatformWorld_create @ create();
};
