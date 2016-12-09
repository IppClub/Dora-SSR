class oEvent
{
	tolua_readonly tolua_property__common string name;
};

void oEvent::send @ emit(string& name);