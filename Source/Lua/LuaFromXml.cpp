/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Lua/LuaFromXml.h"

#include "Basic/Content.h"
#include "Lua/LuaEngine.h"
#include "tinyxml2/SAXParser.h"
#include "yuescript/yue_compiler.h"

// clang-format off

NS_DORA_BEGIN

#define SWITCH_STR_START(str) switch (Switch::hash(str))
#define CASE_STR(str) case #str##_hash:
#define CASE_STR_DOT(prename, name) case #prename "." #name##_hash:
#define SWITCH_STR_END

static void Handler(tinyxml2::XMLDocument* doc, const char* begin, const char* end) {
#define CHECK_CDATA(name) \
	if (strncmp(begin, #name, sizeof(#name) / sizeof(char) - 1) == 0) { \
		doc->SetCDataHeader("</" #name ">"); \
		return; \
	}
	if (begin < end && *(begin - 1) != '/') {
		CHECK_CDATA(Lua)
		CHECK_CDATA(Yue)
	}
}

static bool isVal(const char* value) {
	if (value && value[0] == '{') return false;
	return true;
}

#if DORA_DEBUG
#define toVal(s, def) (oVal(s, def, element, #s).c_str())
#define Val(s) (oVal(s, nullptr, element, #s).c_str())
#else
#define toVal(s, def) (oVal(s, def).c_str())
#define Val(s) (oVal(s, nullptr).c_str())
#endif

static const char* _toBoolean(const char* str) {
	if (strcmp(str, "True") == 0) return "true";
	if (strcmp(str, "False") == 0) return "false";
	return str;
}

#define toBoolean(x) (_toBoolean(toVal(x, "False")))
#define toEase(x) (isVal(x) ? std::string("Ease.") + Val(x) : Val(x))
#define toBlendFunc(x) (isVal(x) ? toVal(x, "Zero") : Val(x))
#define toTextAlign(x) (isVal(x) ? std::string("\"") + toVal(x, "Center") + '\"' : Val(x))
#define toText(x) (isVal(x) ? std::string("\"") + Val(x) + '\"' : Val(x))

#define Self_Check(name) \
	if (self.empty()) { \
		self = getUsableName(#name); \
		names.insert(self); \
	} \
	if (firstItem.empty()) firstItem = self;

// Vec2
#define Vec2_Define \
	const char* x = nullptr; \
	const char* y = nullptr;
#define Vec2_Check \
	CASE_STR(X) { \
		x = atts[++i]; \
		break; \
	} \
	CASE_STR(Y) { \
		y = atts[++i]; \
		break; \
	}
#define Vec2_Handle \
	items.push(std::string("Vec2(") + toVal(x, "0") + "," + toVal(y, "0") + ")");

// Object
#define Object_Define \
	std::string self; \
	bool hasSelf = false; \
	bool ref = false;
#define Object_Check \
	CASE_STR(Name) { \
		hasSelf = true; \
		self = atts[++i]; \
		break; \
	} \
	CASE_STR(Ref) { \
		ref = strcmp(atts[++i], "True") == 0; \
		break; \
	}

// ActionBase
#define ActionBase_Define \
	Object_Define bool def = false;
#define ActionBase_Check \
	Object_Check \
	CASE_STR(Def) { \
		def = strcmp(atts[++i], "True") == 0; \
		break; \
	}

// Delay
#define Delay_Define \
	ActionBase_Define const char* time = nullptr;
#define Delay_Check \
	ActionBase_Check \
	CASE_STR(Time) { \
		time = atts[++i]; \
		break; \
	}
#define Delay_Create
#define Delay_Handle \
	oFunc func = {std::string("Delay(") + toVal(time, "0") + ")", "", def ? oFuncType::ActionDef : oFuncType::Action}; \
	funcs.push(func);
#define Delay_Finish

// Scale
#define Scale_Define \
	ActionBase_Define const char* time = nullptr; \
	const char* start = nullptr; \
	const char* stop = nullptr; \
	const char* ease = nullptr;
#define Scale_Check \
	ActionBase_Check \
	CASE_STR(Time) { \
		time = atts[++i]; \
		break; \
	} \
	CASE_STR(Start) { \
		start = atts[++i]; \
		break; \
	} \
	CASE_STR(Stop) { \
		stop = atts[++i]; \
		break; \
	} \
	CASE_STR(Ease) { \
		ease = atts[++i]; \
		break; \
	}
#define Scale_Create
#define Scale_Handle \
	if (!stop) stop = start; \
	oFunc func = {std::string("Scale(") + toVal(time, "0") + "," + Val(start) + "," + Val(stop) + (ease ? std::string(",") + toEase(ease) : "") + ")", "", def ? oFuncType::ActionDef : oFuncType::Action}; \
	funcs.push(func);
#define Scale_Finish

// Move
#define Move_Define \
	ActionBase_Define const char* time = nullptr; \
	const char* startX = nullptr; \
	const char* startY = nullptr; \
	const char* stopX = nullptr; \
	const char* stopY = nullptr; \
	const char* ease = nullptr;
#define Move_Check \
	ActionBase_Check \
	CASE_STR(Time) { \
		time = atts[++i]; \
		break; \
	} \
	CASE_STR(StartX) { \
		startX = atts[++i]; \
		break; \
	} \
	CASE_STR(StartY) { \
		startY = atts[++i]; \
		break; \
	} \
	CASE_STR(StopX) { \
		stopX = atts[++i]; \
		break; \
	} \
	CASE_STR(StopY) { \
		stopY = atts[++i]; \
		break; \
	} \
	CASE_STR(Ease) { \
		ease = atts[++i]; \
		break; \
	}
#define Move_Create
#define Move_Handle \
	oFunc func = {std::string("Move(") + toVal(time, "0") + ",Vec2(" + Val(startX) + "," + Val(startY) + "),Vec2(" + Val(stopX) + "," + Val(stopY) + ")" + (ease ? std::string(",") + toEase(ease) : "") + ")", "", def ? oFuncType::ActionDef : oFuncType::Action}; \
	funcs.push(func);
#define Move_Finish

// Angle
#define Angle_Define \
	ActionBase_Define const char* time = nullptr; \
	const char* start = nullptr; \
	const char* stop = nullptr; \
	const char* ease = nullptr;
#define Angle_Check \
	ActionBase_Check \
	CASE_STR(Time) { \
		time = atts[++i]; \
		break; \
	} \
	CASE_STR(Start) { \
		start = atts[++i]; \
		break; \
	} \
	CASE_STR(Stop) { \
		stop = atts[++i]; \
		break; \
	} \
	CASE_STR(Ease) { \
		ease = atts[++i]; \
		break; \
	}
#define Angle_Create
#define Angle_Handle \
	if (!stop) stop = start; \
	oFunc func = {std::string("Angle(") + toVal(time, "0") + "," + Val(start) + "," + Val(stop) + (ease ? std::string(",") + toEase(ease) : "") + ")", "", def ? oFuncType::ActionDef : oFuncType::Action}; \
	funcs.push(func);
#define Angle_Finish

// AngleX
#define AngleX_Define \
	ActionBase_Define const char* time = nullptr; \
	const char* start = nullptr; \
	const char* stop = nullptr; \
	const char* ease = nullptr;
#define AngleX_Check \
	ActionBase_Check \
	CASE_STR(Time) { \
		time = atts[++i]; \
		break; \
	} \
	CASE_STR(Start) { \
		start = atts[++i]; \
		break; \
	} \
	CASE_STR(Stop) { \
		stop = atts[++i]; \
		break; \
	} \
	CASE_STR(Ease) { \
		ease = atts[++i]; \
		break; \
	}
#define AngleX_Create
#define AngleX_Handle \
	if (!stop) stop = start; \
	oFunc func = {std::string("AngleX(") + toVal(time, "0") + "," + Val(start) + "," + Val(stop) + (ease ? std::string(",") + toEase(ease) : "") + ")", "", def ? oFuncType::ActionDef : oFuncType::Action}; \
	funcs.push(func);
#define AngleX_Finish

// AngleY
#define AngleY_Define \
	ActionBase_Define const char* time = nullptr; \
	const char* start = nullptr; \
	const char* stop = nullptr; \
	const char* ease = nullptr;
#define AngleY_Check \
	ActionBase_Check \
	CASE_STR(Time) { \
		time = atts[++i]; \
		break; \
	} \
	CASE_STR(Start) { \
		start = atts[++i]; \
		break; \
	} \
	CASE_STR(Stop) { \
		stop = atts[++i]; \
		break; \
	} \
	CASE_STR(Ease) { \
		ease = atts[++i]; \
		break; \
	}
#define AngleY_Create
#define AngleY_Handle \
	if (!stop) stop = start; \
	oFunc func = {std::string("AngleY(") + toVal(time, "0") + "," + Val(start) + "," + Val(stop) + (ease ? std::string(",") + toEase(ease) : "") + ")", "", def ? oFuncType::ActionDef : oFuncType::Action}; \
	funcs.push(func);
#define AngleY_Finish

// Opacity
#define Opacity_Define \
	ActionBase_Define const char* time = nullptr; \
	const char* start = nullptr; \
	const char* stop = nullptr; \
	const char* ease = nullptr;
#define Opacity_Check \
	ActionBase_Check \
	CASE_STR(Time) { \
		time = atts[++i]; \
		break; \
	} \
	CASE_STR(Start) { \
		start = atts[++i]; \
		break; \
	} \
	CASE_STR(Stop) { \
		stop = atts[++i]; \
		break; \
	} \
	CASE_STR(Ease) { \
		ease = atts[++i]; \
		break; \
	}
#define Opacity_Create
#define Opacity_Handle \
	if (!stop) stop = start; \
	oFunc func = {std::string("Opacity(") + toVal(time, "0") + "," + Val(start) + "," + Val(stop) + (ease ? std::string(",") + toEase(ease) : "") + ")", "", def ? oFuncType::ActionDef : oFuncType::Action}; \
	funcs.push(func);
#define Opacity_Finish

// SkewX
#define SkewX_Define \
	ActionBase_Define const char* time = nullptr; \
	const char* start = nullptr; \
	const char* stop = nullptr; \
	const char* ease = nullptr;
#define SkewX_Check \
	ActionBase_Check \
	CASE_STR(Time) { \
		time = atts[++i]; \
		break; \
	} \
	CASE_STR(Start) { \
		start = atts[++i]; \
		break; \
	} \
	CASE_STR(Stop) { \
		stop = atts[++i]; \
		break; \
	} \
	CASE_STR(Ease) { \
		ease = atts[++i]; \
		break; \
	}
#define SkewX_Create
#define SkewX_Handle \
	if (!stop) stop = start; \
	oFunc func = {std::string("SkewX(") + toVal(time, "0") + "," + Val(start) + "," + Val(stop) + (ease ? std::string(",") + toEase(ease) : "") + ")", "", def ? oFuncType::ActionDef : oFuncType::Action}; \
	funcs.push(func);
#define SkewX_Finish

// SkewY
#define SkewY_Define \
	ActionBase_Define const char* time = nullptr; \
	const char* start = nullptr; \
	const char* stop = nullptr; \
	const char* ease = nullptr;
#define SkewY_Check \
	ActionBase_Check \
	CASE_STR(Time) { \
		time = atts[++i]; \
		break; \
	} \
	CASE_STR(Start) { \
		start = atts[++i]; \
		break; \
	} \
	CASE_STR(Stop) { \
		stop = atts[++i]; \
		break; \
	} \
	CASE_STR(Ease) { \
		ease = atts[++i]; \
		break; \
	}
#define SkewY_Create
#define SkewY_Handle \
	if (!stop) stop = start; \
	oFunc func = {std::string("SkewY(") + toVal(time, "0") + "," + Val(start) + "," + Val(stop) + (ease ? std::string(",") + toEase(ease) : "") + ")", "", def ? oFuncType::ActionDef : oFuncType::Action}; \
	funcs.push(func);
#define SkewY_Finish

// Tint
#define Tint_Define \
	ActionBase_Define const char* time = nullptr; \
	const char* start = nullptr; \
	const char* stop = nullptr; \
	const char* ease = nullptr;
#define Tint_Check \
	ActionBase_Check \
	CASE_STR(Time) { \
		time = atts[++i]; \
		break; \
	} \
	CASE_STR(Start) { \
		start = atts[++i]; \
		break; \
	} \
	CASE_STR(Stop) { \
		stop = atts[++i]; \
		break; \
	} \
	CASE_STR(Ease) { \
		ease = atts[++i]; \
		break; \
	}
#define Tint_Create
#define Tint_Handle \
	if (!stop) stop = start; \
	oFunc func = {std::string("Tint(") + toVal(time, "0") + "," + Val(start) + "," + Val(stop) + (ease ? std::string(",") + toEase(ease) : "") + ")", "", def ? oFuncType::ActionDef : oFuncType::Action}; \
	funcs.push(func);
#define Tint_Finish

// Show
#define Show_Define \
	ActionBase_Define
#define Show_Check \
	ActionBase_Check
#define Show_Create
#define Show_Handle \
	oFunc func = {"Show()", "", def ? oFuncType::ActionDef : oFuncType::Action}; \
	funcs.push(func);
#define Show_Finish

// Hide
#define Hide_Define \
	ActionBase_Define
#define Hide_Check \
	ActionBase_Check
#define Hide_Create
#define Hide_Handle \
	oFunc func = {"Hide()", "", def ? oFuncType::ActionDef : oFuncType::Action}; \
	funcs.push(func);
#define Hide_Finish

// Event
#define Event_Define \
	ActionBase_Define const char* type = nullptr;
#define Event_Check \
	ActionBase_Check \
	CASE_STR(Type) { \
		type = atts[++i]; \
		break; \
	}
#define Event_Create
#define Event_Handle \
	oFunc func = {"Event(\"" + (type ? std::string(type) : Slice::Empty) + "\")", ")", def ? oFuncType::ActionDef : oFuncType::Action}; \
	funcs.push(func);
#define Event_Finish

// Sequence
#define Sequence_Define \
	ActionBase_Define
#define Sequence_Check \
	ActionBase_Check
#define Sequence_Create
#define Sequence_Handle \
	items.push("Sequence"); \
	funcs.push({"", "", def ? oFuncType::ActionDef : oFuncType::Action})
#define Sequence_Finish

// Spawn
#define Spawn_Define \
	ActionBase_Define
#define Spawn_Check \
	ActionBase_Check
#define Spawn_Create
#define Spawn_Handle \
	items.push("Spawn"); \
	funcs.push({"", "", def ? oFuncType::ActionDef : oFuncType::Action})
#define Spawn_Finish

#define Add_To_Parent \
	if (!elementStack.empty()) { \
		const oItem& parent = elementStack.top(); \
		if (!parent.name.empty()) { \
			fmt::format_to(std::back_inserter(stream), "{}:addChild({}){}"sv, parent.name, self, nl()); \
		} else if (strcmp(parent.type, "Stencil") == 0) { \
			elementStack.pop(); \
			if (!elementStack.empty()) { \
				const oItem& newParent = elementStack.top(); \
				fmt::format_to(std::back_inserter(stream), "{}.stencil = {}{}"sv, newParent.name, self, nl()); \
			} \
		} \
		if (hasSelf && ref) { \
			fmt::format_to(std::back_inserter(stream), "{}.{} = {}{}"sv, firstItem, self, self, nl()); \
		} \
	}

// Node
#define Node_Define \
	Object_Define const char* width = nullptr; \
	const char* height = nullptr; \
	const char* x = nullptr; \
	const char* y = nullptr; \
	const char* z = nullptr; \
	const char* anchorX = nullptr; \
	const char* anchorY = nullptr; \
	const char* passColor = nullptr; \
	const char* passOpacity = nullptr; \
	const char* color3 = nullptr; \
	const char* opacity = nullptr; \
	const char* angle = nullptr; \
	const char* angleX = nullptr; \
	const char* angleY = nullptr; \
	const char* scaleX = nullptr; \
	const char* scaleY = nullptr; \
	const char* skewX = nullptr; \
	const char* skewY = nullptr; \
	const char* order = nullptr; \
	const char* tag = nullptr; \
	const char* transformTarget = nullptr; \
	const char* visible = nullptr; \
	const char* touchEnabled = nullptr; \
	const char* controllerEnabled = nullptr; \
	const char* swallowTouches = nullptr; \
	const char* swallowMouseWheel = nullptr; \
	const char* renderGroup = nullptr; \
	const char* renderOrder = nullptr;
#define Node_Check \
	Object_Check \
	CASE_STR(Width) { \
		width = atts[++i]; \
		break; \
	} \
	CASE_STR(Height) { \
		height = atts[++i]; \
		break; \
	} \
	CASE_STR(X) { \
		x = atts[++i]; \
		break; \
	} \
	CASE_STR(Y) { \
		y = atts[++i]; \
		break; \
	} \
	CASE_STR(Z) { \
		z = atts[++i]; \
		break; \
	} \
	CASE_STR(AnchorX) { \
		anchorX = atts[++i]; \
		break; \
	} \
	CASE_STR(AnchorY) { \
		anchorY = atts[++i]; \
		break; \
	} \
	CASE_STR(PassColor) { \
		passColor = atts[++i]; \
		break; \
	} \
	CASE_STR(PassOpacity) { \
		passOpacity = atts[++i]; \
		break; \
	} \
	CASE_STR(Color3) { \
		color3 = atts[++i]; \
		break; \
	} \
	CASE_STR(Opacity) { \
		opacity = atts[++i]; \
		break; \
	} \
	CASE_STR(Angle) { \
		angle = atts[++i]; \
		break; \
	} \
	CASE_STR(AngleX) { \
		angleX = atts[++i]; \
		break; \
	} \
	CASE_STR(AngleY) { \
		angleY = atts[++i]; \
		break; \
	} \
	CASE_STR(ScaleX) { \
		scaleX = atts[++i]; \
		break; \
	} \
	CASE_STR(ScaleY) { \
		scaleY = atts[++i]; \
		break; \
	} \
	CASE_STR(SkewX) { \
		skewX = atts[++i]; \
		break; \
	} \
	CASE_STR(SkewY) { \
		skewY = atts[++i]; \
		break; \
	} \
	CASE_STR(Order) { \
		order = atts[++i]; \
		break; \
	} \
	CASE_STR(Tag) { \
		tag = atts[++i]; \
		break; \
	} \
	CASE_STR(TransformTarget) { \
		transformTarget = atts[++i]; \
		break; \
	} \
	CASE_STR(Visible) { \
		visible = atts[++i]; \
		break; \
	} \
	CASE_STR(TouchEnabled) { \
		touchEnabled = atts[++i]; \
		break; \
	} \
	CASE_STR(ControllerEnabled) { \
		controllerEnabled = atts[++i]; \
		break; \
	} \
	CASE_STR(SwallowTouches) { \
		swallowTouches = atts[++i]; \
		break; \
	} \
	CASE_STR(SwallowMouseWheel) { \
		swallowMouseWheel = atts[++i]; \
		break; \
	} \
	CASE_STR(RenderGroup) { \
		renderGroup = atts[++i]; \
		break; \
	} \
	CASE_STR(RenderOrder) { \
		renderOrder = atts[++i]; \
		break; \
	}
#define Node_Create \
	fmt::format_to(std::back_inserter(stream), "local {} = Node(){}"sv, self, nl());
#define Node_Handle \
	if (anchorX && anchorY) \
		fmt::format_to(std::back_inserter(stream), "{}.anchor = Vec2({},{}){}"sv, self, Val(anchorX), Val(anchorY), nl()); \
	else if (anchorX && !anchorY) \
		fmt::format_to(std::back_inserter(stream), "{}.anchor = Vec2({},{}.anchor.y){}"sv, self, Val(anchorX), self, nl()); \
	else if (!anchorX && anchorY) \
		fmt::format_to(std::back_inserter(stream), "{}.anchor = Vec2({}.anchor.x,{}){}"sv, self, self, Val(anchorY), nl()); \
	if (x) fmt::format_to(std::back_inserter(stream), "{}.x = {}{}"sv, self, Val(x), nl()); \
	if (y) fmt::format_to(std::back_inserter(stream), "{}.y = {}{}"sv, self, Val(y), nl()); \
	if (z) fmt::format_to(std::back_inserter(stream), "{}.z = {}{}"sv, self, Val(z), nl()); \
	if (passColor) fmt::format_to(std::back_inserter(stream), "{}.passColor3 = {}{}"sv, self, toBoolean(passColor), nl()); \
	if (passOpacity) fmt::format_to(std::back_inserter(stream), "{}.passOpacity = {}{}"sv, self, toBoolean(passOpacity), nl()); \
	if (color3) fmt::format_to(std::back_inserter(stream), "{}.color3 = Color3({}){}"sv, self, Val(color3), nl()); \
	if (opacity) fmt::format_to(std::back_inserter(stream), "{}.opacity = {}{}"sv, self, Val(opacity), nl()); \
	if (angle) fmt::format_to(std::back_inserter(stream), "{}.angle = {}{}"sv, self, Val(angle), nl()); \
	if (angleX) fmt::format_to(std::back_inserter(stream), "{}.angleX = {}{}"sv, self, Val(angleX), nl()); \
	if (angleY) fmt::format_to(std::back_inserter(stream), "{}.angleY = {}{}"sv, self, Val(angleY), nl()); \
	if (scaleX) fmt::format_to(std::back_inserter(stream), "{}.scaleX = {}{}"sv, self, Val(scaleX), nl()); \
	if (scaleY) fmt::format_to(std::back_inserter(stream), "{}.scaleY = {}{}"sv, self, Val(scaleY), nl()); \
	if (skewX) fmt::format_to(std::back_inserter(stream), "{}.skewX = {}{}"sv, self, Val(skewX), nl()); \
	if (skewY) fmt::format_to(std::back_inserter(stream), "{}.skewY = {}{}"sv, self, Val(skewY), nl()); \
	if (transformTarget) fmt::format_to(std::back_inserter(stream), "{}.transformTarget = {}{}"sv, self, Val(transformTarget), nl()); \
	if (visible) fmt::format_to(std::back_inserter(stream), "{}.visible = {}{}"sv, self, toBoolean(visible), nl()); \
	if (order) fmt::format_to(std::back_inserter(stream), "{}.order = {}{}"sv, self, Val(order), nl()); \
	if (tag) fmt::format_to(std::back_inserter(stream), "{}.tag = {}{}"sv, self, toText(tag), nl()); \
	if (width && height) \
		fmt::format_to(std::back_inserter(stream), "{}.size = Size({},{}){}"sv, self, Val(width), Val(height), nl()); \
	else if (width && !height) \
		fmt::format_to(std::back_inserter(stream), "{}.width = {}{}"sv, self, Val(width), nl()); \
	else if (!width && height) \
		fmt::format_to(std::back_inserter(stream), "{}.height = {}{}"sv, self, Val(height), nl()); \
	if (touchEnabled) fmt::format_to(std::back_inserter(stream), "{}.touchEnabled = {}{}"sv, self, toBoolean(touchEnabled), nl()); \
	if (controllerEnabled) fmt::format_to(std::back_inserter(stream), "{}.controllerEnabled = {}{}"sv, self, toBoolean(controllerEnabled), nl()); \
	if (swallowTouches) fmt::format_to(std::back_inserter(stream), "{}.swallowTouches = {}{}"sv, self, toBoolean(swallowTouches), nl()); \
	if (swallowMouseWheel) fmt::format_to(std::back_inserter(stream), "{}.swallowMouseWheel = {}{}"sv, self, toBoolean(swallowMouseWheel), nl()); \
	if (renderGroup) fmt::format_to(std::back_inserter(stream), "{}.renderGroup = {}{}"sv, self, toBoolean(renderGroup), nl()); \
	if (renderOrder) fmt::format_to(std::back_inserter(stream), "{}.renderOrder = {}{}"sv, self, Val(renderOrder), nl());
#define Node_Finish \
	Add_To_Parent

// DrawNode
#define DrawNode_Define \
	Node_Define
#define DrawNode_Check \
	Node_Check
#define DrawNode_Create \
	fmt::format_to(std::back_inserter(stream), "local {} = DrawNode(){}"sv, self, nl());
#define DrawNode_Handle \
	Node_Handle
#define DrawNode_Finish \
	Add_To_Parent

// DrawNode.Dot
#define Dot_Define \
	const char* x = nullptr; \
	const char* y = nullptr; \
	const char* radius = nullptr; \
	const char* color = nullptr;
#define Dot_Check \
	CASE_STR(X) { \
		x = atts[++i]; \
		break; \
	} \
	CASE_STR(Y) { \
		y = atts[++i]; \
		break; \
	} \
	CASE_STR(Radius) { \
		radius = atts[++i]; \
		break; \
	} \
	CASE_STR(Color) { \
		color = atts[++i]; \
		break; \
	}
#define Dot_Finish \
	if (!elementStack.empty()) { \
		fmt::format_to(std::back_inserter(stream), \
			"{}:drawDot(Vec2({},{}),{},Color({})){}"sv, \
			elementStack.top().name, toVal(x, "0"), toVal(y, "0"), toVal(radius, "0.5"), Val(color), nl()); \
	}

// DrawNode.Polygon
#define Polygon_Define \
	const char* fillColor = nullptr; \
	const char* borderWidth = nullptr; \
	const char* borderColor = nullptr;
#define Polygon_Check \
	CASE_STR(FillColor) { \
		fillColor = atts[++i]; \
		break; \
	} \
	CASE_STR(BorderWidth) { \
		borderWidth = atts[++i]; \
		break; \
	} \
	CASE_STR(BorderColor) { \
		borderColor = atts[++i]; \
		break; \
	}
#define Polygon_Finish \
	if (!elementStack.empty()) { \
		oFunc func = {elementStack.top().name + ":drawPolygon({"s, \
			"},Color("s + Val(fillColor) + "),"s + toVal(borderWidth, "0") + ",Color("s + toVal(borderColor, "") + "))"s + nl(), oFuncType::Polygon}; \
		funcs.push(func); \
		items.push("Polygon"); \
	}

// DrawNode.Segment
#define Segment_Define \
	const char* beginX = nullptr; \
	const char* beginY = nullptr; \
	const char* endX = nullptr; \
	const char* endY = nullptr; \
	const char* radius = nullptr; \
	const char* color = nullptr;
#define Segment_Check \
	CASE_STR(BeginX) { \
		beginX = atts[++i]; \
		break; \
	} \
	CASE_STR(BeginY) { \
		beginY = atts[++i]; \
		break; \
	} \
	CASE_STR(EndX) { \
		endX = atts[++i]; \
		break; \
	} \
	CASE_STR(EndY) { \
		endY = atts[++i]; \
		break; \
	} \
	CASE_STR(Radius) { \
		radius = atts[++i]; \
		break; \
	} \
	CASE_STR(Color) { \
		color = atts[++i]; \
		break; \
	}
#define Segment_Finish \
	if (!elementStack.empty()) { \
		fmt::format_to(std::back_inserter(stream), \
			"{}:drawSegment(Vec2({},{}),Vec2({},{}),{},Color({})){}"sv, \
			elementStack.top().name, toVal(beginX, "0"), toVal(beginY, "0"), \
			toVal(endX, "0"), toVal(endY, "0"), toVal(radius, "0.5"), toVal(color, ""), nl()); \
	}

// Line
#define Line_Define \
	Node_Define
#define Line_Check \
	Node_Check
#define Line_Create \
	fmt::format_to(std::back_inserter(stream), "local {} = Line(){}"sv, self, nl());
#define Line_Handle \
	Node_Handle
#define Line_Finish \
	Add_To_Parent \
		oFunc func \
		= {std::string(self) + ":set({"s, "},Color(0xffffffff))"s + nl(), oFuncType::Line}; \
	funcs.push(func); \
	items.push("Line");

// ClipNode
#define ClipNode_Define \
	Node_Define const char* alphaThreshold = nullptr; \
	const char* inverted = nullptr;
#define ClipNode_Check \
	Node_Check \
	CASE_STR(AlphaThreshold) { \
		alphaThreshold = atts[++i]; \
		break; \
	} \
	CASE_STR(Inverted) { \
		inverted = atts[++i]; \
		break; \
	}
#define ClipNode_Create \
	fmt::format_to(std::back_inserter(stream), "local {} = ClipNode(){}"sv, self, nl());
#define ClipNode_Handle \
	Node_Handle if (alphaThreshold) fmt::format_to(std::back_inserter(stream), "{}.alphaThreshold = {}{}"sv, self, Val(alphaThreshold), nl()); \
	if (inverted) fmt::format_to(std::back_inserter(stream), "{}.inverted = {}{}"sv, self, toBoolean(inverted), nl());
#define ClipNode_Finish \
	Add_To_Parent

// Label
#define Label_Define \
	Node_Define const char* text = nullptr; \
	const char* fontName = nullptr; \
	const char* fontSize = nullptr; \
	const char* textWidth = nullptr; \
	const char* spacing = nullptr; \
	const char* lineGap = nullptr; \
	const char* alignment = nullptr;
#define Label_Check \
	Node_Check \
	CASE_STR(Text) { \
		text = atts[++i]; \
		break; \
	} \
	CASE_STR(FontName) { \
		fontName = atts[++i]; \
		break; \
	} \
	CASE_STR(FontSize) { \
		fontSize = atts[++i]; \
		break; \
	} \
	CASE_STR(TextAlign) { \
		alignment = atts[++i]; \
		break; \
	} \
	CASE_STR(TextWidth) { \
		textWidth = atts[++i]; \
		break; \
	} \
	CASE_STR(Spacing) { \
		spacing = atts[++i]; \
		break; \
	} \
	CASE_STR(LineGap) { \
		lineGap = atts[++i]; \
		break; \
	}
#define Label_Create \
	fmt::format_to(std::back_inserter(stream), "local {} = Label({},{}){}"sv, self, toText(fontName), Val(fontSize), nl());
#define Label_Handle \
	Node_Handle if (alignment) fmt::format_to(std::back_inserter(stream), "{}.alignment = {}{}"sv, self, toTextAlign(alignment), nl()); \
	if (textWidth) fmt::format_to(std::back_inserter(stream), "{}.textWidth = {}{}"sv, self, strcmp(textWidth, "Auto") == 0 ? "Label.AutomaticWidth"s : Val(textWidth), nl()); \
	if (lineGap) fmt::format_to(std::back_inserter(stream), "{}.lineGap = {}{}"sv, self, Val(lineGap), nl()); \
	if (spacing) fmt::format_to(std::back_inserter(stream), "{}.spacing = {}{}"sv, self, Val(spacing), nl()); \
	if (text && text[0]) fmt::format_to(std::back_inserter(stream), "{}.text = {}{}"sv, self, toText(text), nl());
#define Label_Finish \
	Add_To_Parent

// Sprite
#define Sprite_Define \
	Node_Define const char* file = nullptr; \
	const char* blendSrc = nullptr; \
	const char* blendDst = nullptr;
#define Sprite_Check \
	Node_Check \
	CASE_STR(File) { \
		file = atts[++i]; \
		break; \
	} \
	CASE_STR(BlendSrc) { \
		blendSrc = atts[++i]; \
		break; \
	} \
	CASE_STR(BlendDst) { \
		blendDst = atts[++i]; \
		break; \
	}
#define Sprite_Create \
	fmt::format_to(std::back_inserter(stream), "local {} = Sprite({}){}"sv, self, file ? toText(file) : std::string(), nl());
#define Sprite_Handle \
	Node_Handle if (blendSrc && blendDst) fmt::format_to(std::back_inserter(stream), "{}.blendFunc = BlendFunc(\"{}\",\"{}\"){}"sv, self, toBlendFunc(blendSrc), toBlendFunc(blendDst), nl()); \
	else if (blendSrc && !blendDst) fmt::format_to(std::back_inserter(stream), "{}.blendFunc = BlendFunc(\"{}\",\"Zero\"){}"sv, self, toBlendFunc(blendSrc), nl()); \
	else if (!blendSrc && blendDst) fmt::format_to(std::back_inserter(stream), "{}.blendFunc = BlendFunc(\"Zero\",\"{}\"){}"sv, self, toBlendFunc(blendDst), nl());
#define Sprite_Finish \
	Add_To_Parent

// Grid
#define Grid_Define \
	Node_Define const char* file = nullptr; \
	const char* blendSrc = nullptr; \
	const char* blendDst = nullptr; \
	const char* gridX = nullptr; \
	const char* gridY = nullptr;
#define Grid_Check \
	Node_Check \
	CASE_STR(File) { \
		file = atts[++i]; \
		break; \
	} \
	CASE_STR(BlendSrc) { \
		blendSrc = atts[++i]; \
		break; \
	} \
	CASE_STR(BlendDst) { \
		blendDst = atts[++i]; \
		break; \
	} \
	CASE_STR(GridX) { \
		gridX = atts[++i]; \
		break; \
	} \
	CASE_STR(GridY) { \
		gridY = atts[++i]; \
		break; \
	}
#define Grid_Create \
	fmt::format_to(std::back_inserter(stream), "local {} = Grid({}, {}, {}){}"sv, self, file ? toText(file) : std::string(), Val(gridX), Val(gridY), nl());
#define Grid_Handle \
	Node_Handle if (blendSrc && blendDst) fmt::format_to(std::back_inserter(stream), "{}.blendFunc = BlendFunc(\"{}\",\"{}\"){}"sv, self, toBlendFunc(blendSrc), toBlendFunc(blendDst), nl()); \
	else if (blendSrc && !blendDst) fmt::format_to(std::back_inserter(stream), "{}.blendFunc = BlendFunc(\"{}\",\"Zero\"){}"sv, self, toBlendFunc(blendSrc), nl()); \
	else if (!blendSrc && blendDst) fmt::format_to(std::back_inserter(stream), "{}.blendFunc = BlendFunc(\"Zero\",\"{}\"){}"sv, self, toBlendFunc(blendDst), nl());
#define Grid_Finish \
	Add_To_Parent

// Playable
#define Playable_Define \
	Node_Define const char* filename = nullptr; \
	const char* look = nullptr; \
	const char* loop = nullptr; \
	const char* play = nullptr; \
	const char* fliped = nullptr; \
	const char* speed = nullptr;
#define Playable_Check \
	Node_Check \
	CASE_STR(File) { \
		filename = atts[++i]; \
		break; \
	} \
	CASE_STR(Look) { \
		look = atts[++i]; \
		break; \
	} \
	CASE_STR(Loop) { \
		loop = atts[++i]; \
		break; \
	} \
	CASE_STR(Play) { \
		play = atts[++i]; \
		break; \
	} \
	CASE_STR(Fliped) { \
		fliped = atts[++i]; \
		break; \
	} \
	CASE_STR(Speed) { \
		speed = atts[++i]; \
		break; \
	}
#define Playable_Create \
	fmt::format_to(std::back_inserter(stream), "local {} = Playable({}){}"sv, self, toText(filename), nl());
#define Playable_Handle \
	Node_Handle if (look) fmt::format_to(std::back_inserter(stream), "{}.look = {}{}"sv, self, toText(look), nl()); \
	if (fliped) fmt::format_to(std::back_inserter(stream), "{}.fliped = {}{}"sv, self, toBoolean(fliped), nl()); \
	if (speed) fmt::format_to(std::back_inserter(stream), "{}.speed = {}{}"sv, self, Val(speed), nl()); \
	if (play) fmt::format_to(std::back_inserter(stream), "{}:play({}{}){}"sv, self, toText(play), loop ? std::string(",") + toBoolean(loop) : std::string(), nl());
#define Playable_Finish \
	Add_To_Parent

// Menu
#define Menu_Define \
	Node_Define const char* enabled = nullptr;
#define Menu_Check \
	Node_Check \
	CASE_STR(Enabled) { \
		enabled = atts[++i]; \
		break; \
	}
#define Menu_Create \
	fmt::format_to(std::back_inserter(stream), "local {} = Menu(){}"sv, self, nl());
#define Menu_Handle \
	Node_Handle if (enabled) fmt::format_to(std::back_inserter(stream), "{}.enabled = {}{}"sv, self, toBoolean(enabled), nl());
#define Menu_Finish \
	Add_To_Parent

// ModuleNode
#define ModuleNode_Define \
	Object_Define
#define ModuleNode_Check \
	Object_Check default : { \
		int index = i; \
		attributes[atts[index]] = Slice(atts[++i]).trimSpace().toString(); \
		break; \
	}
#define ModuleNode_Create \
	fmt::format_to(std::back_inserter(stream), "local {} = {}{{"sv, self, element);
#define ModuleNode_Handle \
	auto it = attributes.begin(); \
	while (it != attributes.end()) { \
		std::string str = std::string() + (char)tolower(it->first[0]) + it->first.substr(1) + " = "s; \
		char* p; \
		strtod(it->second.c_str(), &p); \
		if (*p == 0) \
			str += it->second; \
		else { \
			if (it->second == "True"_slice) \
				str += "true"s; \
			else if (it->second == "False"_slice) \
				str += "false"s; \
			else \
				str += toText(it->second.c_str()); \
		} \
		++it; \
		if (it != attributes.end()) { \
			str += ", "s; \
		} \
		fmt::format_to(std::back_inserter(stream), "{}"sv, str); \
	} \
	attributes.clear(); \
	fmt::format_to(std::back_inserter(stream), "}}{}"sv, nl());
#define ModuleNode_Finish \
	if (!elementStack.empty()) { \
		const oItem& parent = elementStack.top(); \
		if (!parent.name.empty()) { \
			fmt::format_to(std::back_inserter(stream), "{}:addChild({}){}"sv, parent.name, self, nl()); \
			if (hasSelf && ref) { \
				fmt::format_to(std::back_inserter(stream), "{}.{} = {}{}"sv, firstItem, self, self, nl()); \
			} \
		} else if (strcmp(parent.type, "Stencil") == 0) { \
			elementStack.pop(); \
			if (!elementStack.empty()) { \
				const oItem& newParent = elementStack.top(); \
				fmt::format_to(std::back_inserter(stream), "{}.stencil = {}{}"sv, newParent.name, self, nl()); \
			} \
		} \
	}

// Import
#define Import_Define \
	const char* module = nullptr; \
	const char* name = nullptr;
#define Import_Check \
	CASE_STR(Module) { \
		module = atts[++i]; \
		break; \
	} \
	CASE_STR(Name) { \
		name = atts[++i]; \
		break; \
	}
#define Import_Create \
	if (module) { \
		std::string mod(module); \
		size_t pos = mod.rfind('.'); \
		std::string modStr = (name ? name : (pos == std::string::npos ? std::string(module) : mod.substr(pos + 1))); \
		imported.insert(modStr); \
		fmt::format_to(std::back_inserter(imports), "local {} = require(\"{}\"){}"sv, modStr, module, nl()); \
	}

// Item
#define NodeItem_Define \
	bool ref = false; \
	const char* self = nullptr; \
	const char* width = nullptr; \
	const char* height = nullptr; \
	const char* x = nullptr; \
	const char* y = nullptr; \
	const char* z = nullptr; \
	const char* anchorX = nullptr; \
	const char* anchorY = nullptr; \
	const char* passColor = nullptr; \
	const char* passOpacity = nullptr; \
	const char* color3 = nullptr; \
	const char* opacity = nullptr; \
	const char* angle = nullptr; \
	const char* angleX = nullptr; \
	const char* angleY = nullptr; \
	const char* scaleX = nullptr; \
	const char* scaleY = nullptr; \
	const char* skewX = nullptr; \
	const char* skewY = nullptr; \
	const char* order = nullptr; \
	const char* tag = nullptr; \
	const char* transformTarget = nullptr; \
	const char* visible = nullptr; \
	const char* touchEnabled = nullptr; \
	const char* swallowTouches = nullptr; \
	const char* swallowMouseWheel = nullptr; \
	const char* renderGroup = nullptr; \
	const char* renderOrder = nullptr;
#define NodeItem_Check \
	CASE_STR(Ref) { \
		ref = strcmp(atts[++i], "True") == 0; \
		break; \
	} \
	CASE_STR(Name) { \
		self = atts[++i]; \
		break; \
	} \
	CASE_STR(Width) { \
		width = atts[++i]; \
		break; \
	} \
	CASE_STR(Height) { \
		height = atts[++i]; \
		break; \
	} \
	CASE_STR(X) { \
		x = atts[++i]; \
		break; \
	} \
	CASE_STR(Y) { \
		y = atts[++i]; \
		break; \
	} \
	CASE_STR(Z) { \
		z = atts[++i]; \
		break; \
	} \
	CASE_STR(AnchorX) { \
		anchorX = atts[++i]; \
		break; \
	} \
	CASE_STR(AnchorY) { \
		anchorY = atts[++i]; \
		break; \
	} \
	CASE_STR(PassColor) { \
		passColor = atts[++i]; \
		break; \
	} \
	CASE_STR(PassOpacity) { \
		passOpacity = atts[++i]; \
		break; \
	} \
	CASE_STR(Color3) { \
		color3 = atts[++i]; \
		break; \
	} \
	CASE_STR(Opacity) { \
		opacity = atts[++i]; \
		break; \
	} \
	CASE_STR(Angle) { \
		angle = atts[++i]; \
		break; \
	} \
	CASE_STR(AngleX) { \
		angleX = atts[++i]; \
		break; \
	} \
	CASE_STR(AngleY) { \
		angleY = atts[++i]; \
		break; \
	} \
	CASE_STR(ScaleX) { \
		scaleX = atts[++i]; \
		break; \
	} \
	CASE_STR(ScaleY) { \
		scaleY = atts[++i]; \
		break; \
	} \
	CASE_STR(SkewX) { \
		skewX = atts[++i]; \
		break; \
	} \
	CASE_STR(SkewY) { \
		skewY = atts[++i]; \
		break; \
	} \
	CASE_STR(Order) { \
		order = atts[++i]; \
		break; \
	} \
	CASE_STR(Tag) { \
		tag = atts[++i]; \
		break; \
	} \
	CASE_STR(TransformTarget) { \
		transformTarget = atts[++i]; \
		break; \
	} \
	CASE_STR(Visible) { \
		visible = atts[++i]; \
		break; \
	} \
	CASE_STR(TouchEnabled) { \
		touchEnabled = atts[++i]; \
		break; \
	} \
	CASE_STR(SwallowTouches) { \
		swallowTouches = atts[++i]; \
		break; \
	} \
	CASE_STR(SwallowMouseWheel) { \
		swallowMouseWheel = atts[++i]; \
		break; \
	} \
	CASE_STR(RenderGroup) { \
		renderGroup = atts[++i]; \
		break; \
	} \
	CASE_STR(RenderOrder) { \
		renderOrder = atts[++i]; \
		break; \
	}
#define NodeItem_Create \
	if (tag) { \
		if (!self) self = tag; \
		fmt::format_to(std::back_inserter(stream), "local {} = {}:getChildByTag({}){}"sv, Val(self), elementStack.top().name, toText(tag), nl()); \
	} else { \
		fmt::format_to(std::back_inserter(stream), "local {} = {}.{}{}"sv, Val(self), elementStack.top().name, Val(self), nl()); \
	} \
	if (self && self[0]) { \
		if (ref) { \
			fmt::format_to(std::back_inserter(stream), "{}.{} = {}{}"sv, firstItem, self, self, nl()); \
		} \
		oItem item = {"Item", self}; \
		elementStack.push(item); \
	}
#define NodeItem_Handle \
	if (anchorX && anchorY) \
		fmt::format_to(std::back_inserter(stream), "{}.anchor = Vec2({},{}){}"sv, self, Val(anchorX), Val(anchorY), nl()); \
	else if (anchorX && !anchorY) \
		fmt::format_to(std::back_inserter(stream), "{}.anchor = Vec2({},{}.anchor.y){}"sv, self, Val(anchorX), self, nl()); \
	else if (!anchorX && anchorY) \
		fmt::format_to(std::back_inserter(stream), "{}.anchor = Vec2({}.anchor.x,{}){}"sv, self, self, Val(anchorY), nl()); \
	if (x) fmt::format_to(std::back_inserter(stream), "{}.x = {}{}"sv, self, Val(x), nl()); \
	if (y) fmt::format_to(std::back_inserter(stream), "{}.y = {}{}"sv, self, Val(y), nl()); \
	if (z) fmt::format_to(std::back_inserter(stream), "{}.z = {}{}"sv, self, Val(z), nl()); \
	if (passColor) fmt::format_to(std::back_inserter(stream), "{}.passColor = {}{}"sv, self, toBoolean(passColor), nl()); \
	if (passOpacity) fmt::format_to(std::back_inserter(stream), "{}.passOpacity = {}{}"sv, self, toBoolean(passOpacity), nl()); \
	if (color3) fmt::format_to(std::back_inserter(stream), "{}.color3 = Color3({}){}"sv, self, Val(color3), nl()); \
	if (opacity) fmt::format_to(std::back_inserter(stream), "{}.opacity = {}{}"sv, self, Val(opacity), nl()); \
	if (angle) fmt::format_to(std::back_inserter(stream), "{}.angle = {}{}"sv, self, Val(angle), nl()); \
	if (angleX) fmt::format_to(std::back_inserter(stream), "{}.angleX = {}{}"sv, self, Val(angleX), nl()); \
	if (angleY) fmt::format_to(std::back_inserter(stream), "{}.angleY = {}{}"sv, self, Val(angleY), nl()); \
	if (scaleX) fmt::format_to(std::back_inserter(stream), "{}.scaleX = {}{}"sv, self, Val(scaleX), nl()); \
	if (scaleY) fmt::format_to(std::back_inserter(stream), "{}.scaleY = {}{}"sv, self, Val(scaleY), nl()); \
	if (skewX) fmt::format_to(std::back_inserter(stream), "{}.skewX = {}{}"sv, self, Val(skewX), nl()); \
	if (skewY) fmt::format_to(std::back_inserter(stream), "{}.skewY = {}{}"sv, self, Val(skewY), nl()); \
	if (transformTarget) fmt::format_to(std::back_inserter(stream), "{}.transformTarget = {}{}"sv, self, Val(transformTarget), nl()); \
	if (visible) fmt::format_to(std::back_inserter(stream), "{}.visible = {}{}"sv, self, toBoolean(visible), nl()); \
	if (order) fmt::format_to(std::back_inserter(stream), "{}.order = {}{}"sv, self, Val(order), nl()); \
	if (width && height) \
		fmt::format_to(std::back_inserter(stream), "{}.size = Size({},{}){}"sv, self, Val(width), Val(height), nl()); \
	else if (width && !height) \
		fmt::format_to(std::back_inserter(stream), "{}.width = {}{}"sv, self, Val(width), nl()); \
	else if (!width && height) \
		fmt::format_to(std::back_inserter(stream), "{}.height = {}{}"sv, self, Val(height), nl()); \
	if (touchEnabled) fmt::format_to(std::back_inserter(stream), "{}.touchEnabled = {}{}"sv, self, toBoolean(touchEnabled), nl()); \
	if (swallowTouches) fmt::format_to(std::back_inserter(stream), "{}.swallowTouches = {}{}"sv, self, toBoolean(swallowTouches), nl()); \
	if (swallowMouseWheel) fmt::format_to(std::back_inserter(stream), "{}.swallowMouseWheel = {}{}"sv, self, toBoolean(swallowMouseWheel), nl()); \
	if (renderGroup) fmt::format_to(std::back_inserter(stream), "{}.renderGroup = {}{}"sv, self, toBoolean(renderGroup), nl()); \
	if (renderOrder) fmt::format_to(std::back_inserter(stream), "{}.renderOrder = {}{}"sv, self, Val(renderOrder), nl());

// Slot
#define Slot_Define \
	const char* name = nullptr; \
	const char* args = nullptr; \
	const char* perform = nullptr; \
	const char* loop = nullptr; \
	const char* target = nullptr;
#define Slot_Check \
	CASE_STR(Name) { \
		name = atts[++i]; \
		break; \
	} \
	CASE_STR(Args) { \
		args = atts[++i]; \
		break; \
	} \
	CASE_STR(Target) { \
		target = atts[++i]; \
		break; \
	} \
	CASE_STR(Perform) { \
		perform = atts[++i]; \
		break; \
	} \
	CASE_STR(Loop) { \
		loop = atts[++i]; \
		break; \
	}
#define Slot_Create \
	std::string targetName; \
	std::string performAction; \
	if (perform) { \
		targetName = target ? std::string(target) : elementStack.top().name; \
		performAction = targetName + ":perform("s + perform + ')' + nl(); \
	} \
	std::string loopAction; \
	if ("True"_slice == loop) { \
		loopAction = fmt::format("{}:slot(\"ActionEnd\",function(_action_) if _action_ == {} then {}:perform({}) end end){}", targetName, Val(perform), targetName, Val(perform), nl()); \
	} \
	oFunc func = {elementStack.top().name + ":slot("s + toText(name) + ",function("s + (args ? args : "") + ')' + nl() + performAction + loopAction, "end)"s, oFuncType::Slot}; \
	funcs.push(func);

#define Item_Define(name) name##_Define
#define Item_Loop(name) \
	for (int i = 0; atts[i] != nullptr; i++) { \
		SWITCH_STR_START(atts[i]){ \
			name##_Check} SWITCH_STR_END \
	}
#define Item_Create(name) name##_Create
#define Item_Handle(name) name##_Handle
#define Item_Push(name) \
	name##_Finish; \
	oItem item = {#name, self, ref}; \
	elementStack.push(item);

#define Item(name, var) \
	CASE_STR(name) { \
		Item_Define(name) \
		Item_Loop(name) \
		Self_Check(var) \
		Item_Create(name) \
		Item_Handle(name) \
		Item_Push(name) break; \
	}

#define ItemDot_Push(prename, name) \
	prename##_##name##_Finish; \
	oItem item = {#prename "." #name, self, ref}; \
	elementStack.push(item);
#define ItemDot(prename, name, var) \
	CASE_STR_DOT(prename, name) { \
		Item_Define(prename##_##name) \
		Item_Loop(prename##_##name) \
		Self_Check(var) \
		Item_Create(prename##_##name) \
		Item_Handle(prename##_##name) \
		ItemDot_Push(prename, name) break; \
	}

class XmlDelegator : public SAXDelegator {
public:
	XmlDelegator(SAXParser* parser)
		: codes(nullptr)
		, currentLine(1)
		, currentLinePos(nullptr)
		, currentLineStr(" -- 1\n"s)
		, parser(parser) { }
	virtual void startElement(const char* name, const char** atts);
	virtual void endElement(const char* name);
	virtual void textHandler(const char* s, int len);
	std::string oVal(const char* value, const char* def = nullptr, const char* element = nullptr, const char* attr = nullptr);
	std::string compileYueCodes(const char* codes);

public:
	std::string originalXml;
	int getLineNumber(const char* name, const char* start = nullptr);
	void updateLineNumber(const char* pos);
	std::string nl();
	void begin() {
		errors.clear();
		fmt::format_to(std::back_inserter(stream), "{}"sv,
			"return function(args)"s + nl() + "local _ENV = Dora(args)"s + nl());
	}
	void end() {
		fmt::format_to(std::back_inserter(stream), "return {}{}end"sv, firstItem, nl());
	}
	std::string getResult() {
		if (errors.empty()) {
			std::string importStr = fmt::to_string(imports);
			return importStr + fmt::to_string(stream);
		}
		return std::string();
	}
	struct XmlError {
		int line;
		std::string message;
	};
	const std::list<XmlError>& getErrors() const {
		return errors;
	}

private:
	std::string getUsableName(const char* baseName) {
		int index = 1;
		std::string base(baseName);
		std::string name;
		do {
			name = fmt::format("{}{}", base, index);
			auto it = names.find(name);
			if (it == names.end())
				break;
			else
				index++;
		} while (true);
		return name;
	}

private:
	struct oItem {
		const char* type;
		std::string name;
		bool ref;
	};
	enum class oFuncType {
		Action,
		ActionDef,
		Polygon,
		Line,
		Slot
	};
	struct oFunc {
		std::string begin;
		std::string end;
		oFuncType type;
	};
	SAXParser* parser;
	int currentLine;
	const char* currentLinePos;
	std::string currentLineStr;
	// Script
	const char* codes;
	// Loader
	bool isInCodeElement = false;
	std::string firstItem;
	std::list<XmlError> errors;
	std::stack<oFunc> funcs;
	std::stack<std::string> items;
	std::stack<oItem> elementStack;
	std::unordered_set<std::string> names;
	std::unordered_set<std::string> imported;
	StringMap<std::string> attributes;
	fmt::memory_buffer stream;
	fmt::memory_buffer imports;
};

int XmlDelegator::getLineNumber(const char* name, const char* start) {
	const char* xml = parser->getBuffer();
	int startIndex = start ? start - xml : 0;
	int stopIndex = name - xml;
	int line = 1;
	const char* str = originalXml.c_str();
	for (int i = startIndex; i < stopIndex; i++) {
		if (str[i] == '\n') {
			line++;
		}
	}
	return line;
}

std::string XmlDelegator::oVal(const char* value, const char* def, const char* element, const char* attr) {
	if (!value || !value[0]) {
		if (def)
			return std::string(def);
		else if (attr && element) {
			int line = getLineNumber(element);
			std::string message = "missing attribute "s + s_cast<char>(toupper(attr[0])) + std::string(attr).substr(1) + " for <"s + element + '>';
			errors.push_back({line, message});
		}
		return std::string();
	}
	if (value[0] == '{') {
		std::string valStr(value);
		if (valStr.back() != '}') return valStr;
		size_t start = 1;
		for (; valStr[start] == ' ' || valStr[start] == '\t'; ++start)
			;
		size_t end = valStr.size() - 2;
		for (; valStr[end] == ' ' || valStr[end] == '\t'; --end)
			;
		if (end < start) {
			if (attr && element) {
				int line = getLineNumber(element);
				std::string message = "missing attribute "s + s_cast<char>(toupper(attr[0])) + std::string(attr).substr(1) + " for <"s + element + '>';
				errors.push_back({line, message});
			}
			return std::string();
		}
		valStr = valStr.substr(start, end - start + 1);
		std::string newStr;
		start = 0;
		size_t i = 0;
		while (i < valStr.size()) {
			if ((valStr[i] == '$' || valStr[i] == '@') && i < valStr.size() - 1) {
				if (valStr[i] == '$') {
					std::string parent;
					if (!elementStack.empty()) {
						oItem top = elementStack.top();
						if (!top.name.empty()) {
							parent = top.name;
						} else if (strcmp(top.type, "Stencil") == 0) {
							elementStack.pop();
							if (!elementStack.empty()) {
								const oItem& newTop = elementStack.top();
								parent = newTop.name;
							}
							elementStack.push(top);
						}
					}
					if (parent.empty() && element) {
						int line = getLineNumber(element);
						std::string message = "the $ expression can`t be used in tag"s;
						errors.push_back({line, message});
					}
					newStr += valStr.substr(start, i - start);
					i++;
					start = i + 1;
					switch (valStr[i]) {
						case 'L':
							newStr += "0";
							break;
						case 'W':
						case 'R':
							newStr += parent + ".width";
							break;
						case 'H':
						case 'T':
							newStr += parent + ".height";
							break;
						case 'B':
							newStr += "0";
							break;
						case 'X':
							newStr += parent + ".width*0.5";
							break;
						case 'Y':
							newStr += parent + ".height*0.5";
							break;
						default:
							if (element) {
								int line = getLineNumber(element);
								std::string message = "invalid expression $"s + valStr[i];
								errors.push_back({line, message});
							}
							break;
					}
				} else {
					newStr += valStr.substr(start, i - start);
					i++;
					start = i + 1;
					switch (valStr[i]) {
						case 'L':
							newStr += "0";
							break;
						case 'W':
						case 'R':
							newStr += "View.size.width";
							break;
						case 'H':
						case 'T':
							newStr += "View.size.height";
							break;
						case 'B':
							newStr += "0";
							break;
						case 'X':
							newStr += "View.size.width*0.5";
							break;
						case 'Y':
							newStr += "View.size.height*0.5";
							break;
						default:
							if (element) {
								int line = getLineNumber(element);
								std::string message = "invalid expression @"s + valStr[i];
								errors.push_back({line, message});
							}
							break;
					}
				}
			}
			i++;
		}
		if (0 < start) {
			if (start < valStr.size()) newStr += valStr.substr(start);
			return newStr;
		} else
			return valStr;
	} else
		return std::string(value);
}

void XmlDelegator::updateLineNumber(const char* pos) {
	if (pos > currentLinePos) {
		int line = getLineNumber(pos, currentLinePos);
		if (line > 1) {
			currentLine += line - 1;
			currentLineStr = " -- "s + std::to_string(currentLine) + '\n';
		}
		currentLinePos = pos;
	}
}

std::string XmlDelegator::nl() {
	return currentLineStr;
}

void XmlDelegator::startElement(const char* element, const char** atts) {
	SWITCH_STR_START(element) {
		CASE_STR(Delay)
		CASE_STR(Scale)
		CASE_STR(Move)
		CASE_STR(Angle)
		CASE_STR(Opacity)
		CASE_STR(SkewX)
		CASE_STR(SkewY)
		CASE_STR(Tint)
		CASE_STR(Show)
		CASE_STR(Hide)
		CASE_STR(Event)
		CASE_STR(Sequence)
		CASE_STR(Spawn) {
			bool parentIsAction = !elementStack.empty()
				&& strcmp(elementStack.top().type, "Action") == 0;
			if (parentIsAction) {
				updateLineNumber(element);
			}
			break;
		}
		default: {
			updateLineNumber(element);
			break;
		}
	}
	SWITCH_STR_END

	SWITCH_STR_START(element) {
		CASE_STR(Dora) {
			break;
		}
		Item(Node, node)
		Item(DrawNode, drawNode)
		Item(Line, line)
		Item(Sprite, sprite)
		Item(Grid, grid)
		Item(ClipNode, clipNode)
		Item(Label, label)

		Item(Playable, playable)
		Item(Menu, menu)

		Item(Delay, delay)
		Item(Scale, scale)
		Item(Move, move)
		Item(Angle, angle)
		Item(Opacity, opacity)
		Item(SkewX, skewX)
		Item(SkewY, skewY)
		Item(Tint, tint)

		Item(Show, show)
		Item(Hide, hide)
		Item(Event, event)

		Item(Sequence, sequence)
		Item(Spawn, spawn)

		CASE_STR(Vec2) {
			Item_Define(Vec2)
			Item_Loop(Vec2)
			Item_Handle(Vec2) break;
		}
		CASE_STR(Dot) {
			Item_Define(Dot)
			Item_Loop(Dot)
			Dot_Finish break;
		}
		CASE_STR(Polygon) {
			Item_Define(Polygon)
			Item_Loop(Polygon)
			Polygon_Finish break;
		}
		CASE_STR(Segment) {
			Item_Define(Segment)
			Item_Loop(Segment)
			Segment_Finish break;
		}
		CASE_STR(Stencil) {
			oItem item = {"Stencil"};
			elementStack.push(item);
			break;
		}
		CASE_STR(Import) {
			Item_Define(Import)
			Item_Loop(Import)
			Import_Create break;
		}
		CASE_STR(Action) {
			oItem item = {"Action"};
			elementStack.push(item);
			break;
		}
		CASE_STR(Item) {
			Item_Define(NodeItem)
			Item_Loop(NodeItem)
			Item_Create(NodeItem)
			Item_Handle(NodeItem) break;
		}
		CASE_STR(Slot) {
			Item_Define(Slot)
			Item_Loop(Slot)
			Item_Create(Slot) break;
		}
		CASE_STR(Lua)
		CASE_STR(Yue) {
			isInCodeElement = true;
			break;
		}
		default: {
			Item_Define(ModuleNode)
			Item_Loop(ModuleNode)
			Self_Check(item)
			Item_Create(ModuleNode)
			Item_Handle(ModuleNode)
			ModuleNode_Finish;
			oItem item = {element, self, ref};
			elementStack.push(item);
			break;
		}
	}
	SWITCH_STR_END
}

std::string XmlDelegator::compileYueCodes(const char* codes) {
	yue::YueConfig config;
	config.lineOffset = currentLine - 2;
	config.reserveLineNumber = true;
	config.implicitReturnRoot = false;
	auto result = yue::YueCompiler{nullptr, dora_open_threaded_compiler}.compile(fmt::format("do{}{}", nl(), codes), config);
	if (result.codes.empty() && result.error) {
		int line = result.error.value().line;
		std::string message = std::move(result.error.value().msg);
		errors.push_back({line, message});
	}
	return std::move(result.codes);
}

void XmlDelegator::endElement(const char* name) {
	SWITCH_STR_START(name) {
		CASE_STR(Yue) {
			isInCodeElement = false;
			std::string codeStr;
			if (codes) codeStr = compileYueCodes(codes);
			codes = nullptr;
			if (!funcs.empty() && funcs.top().type == oFuncType::Slot) {
				funcs.top().begin += codeStr;
			} else {
				fmt::format_to(std::back_inserter(elementStack.empty() ? imports : stream), "{}"sv, codeStr);
			}
			return;
		}
		CASE_STR(Lua) {
			isInCodeElement = false;
			if (codes) {
				Slice luaCodes(codes);
				luaCodes.trimSpace();
				std::string_view lcodes(luaCodes.begin(), luaCodes.size());
				auto pos = lcodes.find("[["sv);
				if (pos == std::string::npos) {
					pos = lcodes.find("[="sv);
				}
				if (pos != std::string::npos) {
					int line = getLineNumber(luaCodes.begin() + pos);
					std::string message = "Lua multiline string is not supported"s;
					errors.push_back({line, message});
				}
				auto lines = luaCodes.split("\n");
				fmt::memory_buffer buf;
				std::string codeStr;
				if (!lines.empty()) {
					if (lines.size() == 1) {
						updateLineNumber(lines.begin()->begin());
						codeStr = lines.front().toString() + nl();
					} else {
						if (!lines.begin()->empty()) {
							updateLineNumber(lines.begin()->begin());
							fmt::format_to(std::back_inserter(buf), "{}{}"sv, lines.front().toString(), nl());
						}
						for (auto it = ++lines.begin(); it != lines.end(); ++it) {
							if (!it->empty()) {
								updateLineNumber(it->begin());
								fmt::format_to(std::back_inserter(buf), "{}{}"sv, it->toString(), nl());
							}
						}
						codeStr = fmt::to_string(buf);
					}
				}
				if (!funcs.empty() && funcs.top().type == oFuncType::Slot) {
					funcs.top().begin += codeStr;
				} else {
					fmt::format_to(std::back_inserter(elementStack.empty() ? imports : stream), "{}"sv, codeStr);
				}
			}
			codes = nullptr;
			return;
		}
	}
	SWITCH_STR_END

	if (elementStack.empty()) return;
	oItem currentData = elementStack.top();
	if (strcmp(name, elementStack.top().type) == 0) elementStack.pop();
	bool parentIsAction = !elementStack.empty() && strcmp(elementStack.top().type, "Action") == 0;

	SWITCH_STR_START(name) {
		CASE_STR(Slot) {
			oFunc func = funcs.top();
			funcs.pop();
			fmt::format_to(std::back_inserter(stream), "{}{}{}"sv, func.begin, func.end, nl());
			break;
		}
		// Action
		CASE_STR(Delay)
		CASE_STR(Scale)
		CASE_STR(Move)
		CASE_STR(Angle)
		CASE_STR(Opacity)
		CASE_STR(SkewX)
		CASE_STR(SkewY)
		CASE_STR(Tint)
		CASE_STR(Show)
		CASE_STR(Hide)
		CASE_STR(Event) {
			oFunc func = funcs.top();
			funcs.pop();
			if (parentIsAction) {
				if (func.type == oFuncType::ActionDef) {
					fmt::format_to(std::back_inserter(stream), "local {} = {}{}"sv, currentData.name, func.begin, nl());
				} else {
					fmt::format_to(std::back_inserter(stream), "local {} = Action({}){}"sv, currentData.name, func.begin, nl());
				}
			} else {
				items.push(func.begin);
				auto it = names.find(currentData.name);
				if (it != names.end()) names.erase(it);
			}
			break;
		}
		CASE_STR(Sequence)
		CASE_STR(Spawn) {
			oFunc func = funcs.top();
			funcs.pop();
			std::string tempItem = std::string(name) + "(";
			std::stack<std::string> tempStack;
			while (items.top() != name) {
				tempStack.push(items.top());
				items.pop();
			}
			items.pop();
			while (!tempStack.empty()) {
				tempItem += tempStack.top();
				tempStack.pop();
				if (!tempStack.empty()) tempItem += ",";
			}
			tempItem += ")";
			if (parentIsAction) {
				if (func.type == oFuncType::ActionDef) {
					fmt::format_to(std::back_inserter(stream), "local {} = {}{}"sv, currentData.name, tempItem, nl());
				} else {
					fmt::format_to(std::back_inserter(stream), "local {} = Action({}){}"sv, currentData.name, tempItem, nl());
				}
			} else {
				items.push(tempItem);
				auto it = names.find(currentData.name);
				if (it != names.end()) names.erase(it);
			}
			break;
		}
		CASE_STR(Polygon)
		CASE_STR(Line) {
			oFunc func = funcs.top();
			funcs.pop();
			fmt::format_to(std::back_inserter(stream), "{}"sv, func.begin);
			std::stack<std::string> tempStack;
			while (items.top() != name) {
				tempStack.push(items.top());
				items.pop();
			}
			items.pop();
			while (!tempStack.empty()) {
				fmt::format_to(std::back_inserter(stream), "{}"sv, tempStack.top());
				tempStack.pop();
				if (!tempStack.empty()) fmt::format_to(std::back_inserter(stream), ","sv);
			}
			fmt::format_to(std::back_inserter(stream), "{}"sv, func.end);
			break;
		}
		// Builtin node
		CASE_STR(Action)
		CASE_STR(Node)
		CASE_STR(DrawNode)
		CASE_STR(Sprite)
		CASE_STR(Grid)
		CASE_STR(ClipNode)
		CASE_STR(Label)
		CASE_STR(Playable)
		CASE_STR(Menu)
		CASE_STR(Vec2)
		CASE_STR(Dot)
		CASE_STR(Segment)
		CASE_STR(Stencil)
		CASE_STR(Import)
		CASE_STR(Item) {
			break;
		}
		default: {
			auto it = imported.find(name);
			if (it == imported.end()) {
				int line = getLineNumber(name);
				std::string message = fmt::format("tag <{}> not imported", name);
				errors.push_back({line, message});
			}
			break;
		}
	}
	SWITCH_STR_END

	if (parentIsAction && currentData.ref) {
		fmt::format_to(std::back_inserter(stream), "{}.{} = {}{}"sv, firstItem, currentData.name, currentData.name, nl());
	}
}

void XmlDelegator::textHandler(const char* s, int len) {
	updateLineNumber(s);
	if (isInCodeElement) {
		codes = s;
	} else {
		int line = getLineNumber(s);
		errors.push_back({line, "invalid text content"s});
	}
}

XmlLoader::XmlLoader()
	: _delegator(nullptr)
	, _parser(nullptr) {
}

XmlLoader::~XmlLoader() { }

std::variant<std::string, XmlLoader::XmlErrors> XmlLoader::loadFile(String filename) {
	auto data = SharedContent.load(filename);
	auto xmlData = Slice(r_cast<char*>(data.first.get()), data.second);
	if (xmlData.empty()) {
		XmlLoader::XmlError error{0, "failed to load xml file"s};
		return XmlLoader::XmlErrors{error};
	}
	return loadXml(xmlData);
}

std::variant<std::string, XmlLoader::XmlErrors> XmlLoader::loadXml(String xmlData) {
	_parser = New<SAXParser>();
	_delegator = New<XmlDelegator>(_parser.get());
	_parser->setDelegator(_delegator.get());
	_delegator->originalXml = xmlData.toString();
	_delegator->begin();
	_parser->setHeaderHandler(Handler);
	auto error = _parser->parse(_delegator->originalXml);
	_delegator->end();
	XmlLoader::XmlErrors errors;
	if (error) {
		const auto& err = error.value();
		errors.push_back({err.line, err.message});
	}
	if (!_delegator->getErrors().empty()) {
		for (const auto& err : _delegator->getErrors()) {
			errors.push_back({err.line, err.message});
		}
	}
	std::string codes = errors.empty() ? _delegator->getResult() : std::string();
	_delegator = nullptr;
	_parser = nullptr;
	if (errors.empty()) {
		return codes;
	} else {
		return errors;
	}
}

NS_DORA_END
