class oEvent
{
	tolua_readonly tolua_property__common string name;
};
void oEvent::send @ emit(oSlice name);

class oListener @ oSlot : public oObject
{
	tolua_readonly tolua_property__common string name;
	tolua_property__bool bool enabled;
};
