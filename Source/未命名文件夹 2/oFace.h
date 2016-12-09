class oFace: public CCObject
{
	void addChild(oFace* face);
	bool removeChild(oFace* face);
	CCNode* toNode();
	static oFace* create(string& faceStr, oVec2& point);
};
