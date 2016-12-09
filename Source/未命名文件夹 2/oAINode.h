class oAILeaf: public CCObject
{};

class oInstinct
{
	static void add(int id, string& propName, oAILeaf* node);
	static void clear();
};

oAILeaf* oSel(oAILeaf* nodes[tolua_len]);
oAILeaf* oSeq(oAILeaf* nodes[tolua_len]);
oAILeaf* oParSel(oAILeaf* nodes[tolua_len]);
oAILeaf* oParSeq(oAILeaf* nodes[tolua_len]);
oAILeaf* oCon(tolua_function handler);
oAILeaf* oAct(const char* actionId);
