module CCTile
{
	static tolua_outside CCActionInterval* CCShakyTiles3D::create @ shaky3D(float duration, CCSize gridSize, int nRange, bool bShakeZ);

	static tolua_outside CCActionInterval* CCShatteredTiles3D::create @ shattered3D(float duration, CCSize gridSize, int nRange, bool bShatterZ);

	static tolua_outside CCActionInterval* CCShuffleTiles::create @ shuffle(float duration, CCSize gridSize);

	static tolua_outside CCActionInterval* CCTile_createFadeOut @ fadeOut(float duration, CCSize gridSize, tOrientation orientation);

	static tolua_outside CCActionInterval* CCTurnOffTiles::create @ turnOff(float duration, CCSize gridSize);

	static tolua_outside CCActionInterval* CCWavesTiles3D::create @ waves3D(float duration, CCSize gridSize, unsigned int waves, float amplitude);

	static tolua_outside CCActionInterval* CCJumpTiles3D::create @ jump3D(float duration, CCSize gridSize, unsigned int numberOfJumps, float amplitude);

	static tolua_outside CCActionInterval* CCSplitRows::create @ splitRows(float duration, unsigned int nRows);

	static tolua_outside CCActionInterval* CCSplitCols::create @ splitCols(float duration, unsigned int nCols);
}
