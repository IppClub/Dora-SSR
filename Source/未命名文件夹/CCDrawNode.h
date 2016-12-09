class CCDrawNode: public CCNode
{
	void drawDot(oVec2& pos, float radius, ccColor4& color);
	void drawSegment(oVec2& from, oVec2& to, float radius, ccColor4& color);
	tolua_outside void CCDrawNode_drawPolygon @ drawPolygon(oVec2 verts[tolua_len], ccColor4& fillColor);
	tolua_outside void CCDrawNode_drawPolygon @ drawPolygon(oVec2 verts[tolua_len], ccColor4& fillColor, float borderWidth, ccColor4 borderColor);
	void clear();
	
	static CCDrawNode* create();
}
