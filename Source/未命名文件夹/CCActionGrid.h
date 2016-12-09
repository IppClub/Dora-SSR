module CCGrid
{
	static tolua_outside CCFiniteTimeAction* CCStopGrid::create @ stop();

	static tolua_outside CCFiniteTimeAction* CCReuseGrid::create @ reuse(int times);

	static tolua_outside CCActionInterval* CCWaves3D::create @ waves3D(float duration, CCSize gridSize, unsigned int waves, float amplitude);

	static tolua_outside CCActionInterval* CCFlipX3D::create @ flipX3D(float duration);

	static tolua_outside CCActionInterval* CCFlipY3D::create @ flipY3D(float duration);

	static tolua_outside CCActionInterval* CCLens3D::create @ lens3D(float duration, CCSize gridSize, oVec2 position, float radius);

	static tolua_outside CCActionInterval* CCRipple3D::create @ ripple3D(float duration, CCSize gridSize, oVec2 position, float radius, unsigned int waves, float amplitude);

	static tolua_outside CCActionInterval* CCShaky3D::create @ shaky3D(float duration, CCSize gridSize, int range, bool shakeZ);

	static tolua_outside CCActionInterval* CCLiquid::create @ liquid(float duration, CCSize gridSize, unsigned int waves, float amplitude);

	static tolua_outside CCActionInterval* CCWaves::create @ waves(float duration, CCSize gridSize, unsigned int waves, float amplitude, bool horizontal, bool vertical);

	static tolua_outside CCActionInterval* CCTwirl::create @ twirl(float duration, CCSize gridSize, oVec2 position, unsigned int twirls, float amplitude);
}