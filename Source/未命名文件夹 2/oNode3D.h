class oNode3D: public CCNode
{
	tolua_property__common float rotationX @ angleX;
	tolua_property__common float rotationY @ angleY;
	static oNode3D* create();
};
