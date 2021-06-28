/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Lua/LuaFromXml.h"
#include "tinyxml2/SAXParser.h"
#include "Lua/LuaEngine.h"
#include "yuescript/yue_compiler.h"

NS_DOROTHY_BEGIN

#define SWITCH_STR_START(str) switch (Switch::hash(str))
#define CASE_STR(str) case #str##_hash:
#define CASE_STR_DOT(prename,name) case #prename"."#name##_hash:
#define SWITCH_STR_END

static void Handler(const char* begin, const char* end)
{
#define CHECK_CDATA(name) \
	if (strncmp(begin, #name, sizeof(#name) / sizeof(char) - 1) == 0)\
	{\
		SAXParser::placeCDataHeader("</"#name">");\
		return;\
	}
	if (begin < end && *(begin-1) != '/')
	{
		CHECK_CDATA(Call)
		CHECK_CDATA(Script)
		CHECK_CDATA(Slot)
	}
}

static bool isVal(const char* value)
{
	if (value && value[0] == '{') return false;
	return true;
}

#if DORA_DEBUG
	#define toVal(s,def) (oVal(s,def,element,#s).c_str())
	#define Val(s) (oVal(s,nullptr,element,#s).c_str())
#else
	#define toVal(s,def) (oVal(s,def).c_str())
	#define Val(s) (oVal(s,nullptr).c_str())
#endif

static const char* _toBoolean(const char* str)
{
	if (strcmp(str,"True") == 0) return "true";
	if (strcmp(str,"False") == 0) return "false";
	return str;
}

#define toBoolean(x) (_toBoolean(toVal(x,"False")))
#define toEase(x) (isVal(x) ? std::string("Ease.")+Val(x) : Val(x))
#define toBlendFunc(x) (isVal(x) ? toVal(x,"Zero") : Val(x))
#define toTextAlign(x) (isVal(x) ? std::string("\"")+toVal(x,"Center")+'\"' : Val(x))
#define toText(x) (isVal(x) ? std::string("\"")+Val(x)+'\"' : Val(x))

#define Self_Check(name) \
	if (self.empty()) { self = getUsableName(#name); names.insert(self); }\
	if (firstItem.empty()) firstItem = self;

// Vec2
#define Vec2_Define \
	const char* x = nullptr;\
	const char* y = nullptr;
#define Vec2_Check \
	CASE_STR(X) { x = atts[++i]; break; }\
	CASE_STR(Y) { y = atts[++i]; break; }
#define Vec2_Handle \
	items.push(std::string("Vec2(")+toVal(x,"0")+","+toVal(y,"0")+")");

// Object
#define Object_Define \
	std::string self;\
	bool hasSelf = false;\
	bool ref = false;
#define Object_Check \
	CASE_STR(Name) { hasSelf = true; self = atts[++i]; break; }\
	CASE_STR(Ref) { ref = strcmp(atts[++i],"True") == 0; break; }

// ActionBase
#define ActionBase_Define \
	Object_Define\
	bool def = false;
#define ActionBase_Check \
	Object_Check\
	CASE_STR(Def) { def = strcmp(atts[++i],"True") == 0; break; }

// Delay
#define Delay_Define \
	ActionBase_Define\
	const char* time = nullptr;
#define Delay_Check \
	ActionBase_Check\
	CASE_STR(Time) { time = atts[++i]; break; }
#define Delay_Create
#define Delay_Handle \
	oFunc func = {std::string("Delay(")+toVal(time,"0")+")","",def};\
	funcs.push(func);
#define Delay_Finish

// Scale
#define Scale_Define \
	ActionBase_Define\
	const char* time = nullptr;\
	const char* start = nullptr;\
	const char* stop = nullptr;\
	const char* ease = nullptr;
#define Scale_Check \
	ActionBase_Check\
	CASE_STR(Time) { time = atts[++i]; break; }\
	CASE_STR(Start) { start = atts[++i]; break; }\
	CASE_STR(Stop) { stop = atts[++i]; break; }\
	CASE_STR(Ease) { ease = atts[++i]; break; }
#define Scale_Create
#define Scale_Handle \
	oFunc func = {std::string("Scale(")+toVal(time,"0")+","+Val(start)+","+Val(stop)+(ease ? std::string(",")+toEase(ease) : "")+")","",def};\
	funcs.push(func);
#define Scale_Finish

// Move
#define Move_Define \
	ActionBase_Define\
	const char* time = nullptr;\
	const char* startX = nullptr;\
	const char* startY = nullptr;\
	const char* stopX = nullptr;\
	const char* stopY = nullptr;\
	const char* ease = nullptr;
#define Move_Check \
	ActionBase_Check\
	CASE_STR(Time) { time = atts[++i]; break; }\
	CASE_STR(StartX) { startX = atts[++i]; break; }\
	CASE_STR(StartY) { startY = atts[++i]; break; }\
	CASE_STR(StopX) { stopX = atts[++i]; break; }\
	CASE_STR(StopY) { stopY = atts[++i]; break; }\
	CASE_STR(Ease) { ease = atts[++i]; break; }
#define Move_Create
#define Move_Handle \
	oFunc func = {std::string("Move(")+toVal(time,"0")+",Vec2("+Val(startX)+","+Val(startY)+"),Vec2("+Val(stopX)+","+Val(stopY)+")"+(ease ? std::string(",")+toEase(ease) : "")+")","",def};\
	funcs.push(func);
#define Move_Finish

// Angle
#define Angle_Define \
	ActionBase_Define\
	const char* time = nullptr;\
	const char* start = nullptr;\
	const char* stop = nullptr;\
	const char* ease = nullptr;
#define Angle_Check \
	ActionBase_Check\
	CASE_STR(Time) { time = atts[++i]; break; }\
	CASE_STR(Start) { start = atts[++i]; break; }\
	CASE_STR(Stop) { stop = atts[++i]; break; }\
	CASE_STR(Ease) { ease = atts[++i]; break; }
#define Angle_Create
#define Angle_Handle \
	oFunc func = {std::string("Angle(")+toVal(time,"0")+","+Val(start)+","+Val(stop)+(ease ? std::string(",")+toEase(ease) : "")+")","",def};\
	funcs.push(func);
#define Angle_Finish

// AngleX
#define AngleX_Define \
	ActionBase_Define\
	const char* time = nullptr;\
	const char* start = nullptr;\
	const char* stop = nullptr;\
	const char* ease = nullptr;
#define AngleX_Check \
	ActionBase_Check\
	CASE_STR(Time) { time = atts[++i]; break; }\
	CASE_STR(Start) { start = atts[++i]; break; }\
	CASE_STR(Stop) { stop = atts[++i]; break; }\
	CASE_STR(Ease) { ease = atts[++i]; break; }
#define AngleX_Create
#define AngleX_Handle \
	oFunc func = {std::string("AngleX(")+toVal(time,"0")+","+Val(start)+","+Val(stop)+(ease ? std::string(",")+toEase(ease) : "")+")","",def};\
	funcs.push(func);
#define AngleX_Finish

// AngleY
#define AngleY_Define \
	ActionBase_Define\
	const char* time = nullptr;\
	const char* start = nullptr;\
	const char* stop = nullptr;\
	const char* ease = nullptr;
#define AngleY_Check \
	ActionBase_Check\
	CASE_STR(Time) { time = atts[++i]; break; }\
	CASE_STR(Start) { start = atts[++i]; break; }\
	CASE_STR(Stop) { stop = atts[++i]; break; }\
	CASE_STR(Ease) { ease = atts[++i]; break; }
#define AngleY_Create
#define AngleY_Handle \
	oFunc func = {std::string("AngleY(")+toVal(time,"0")+","+Val(start)+","+Val(stop)+(ease ? std::string(",")+toEase(ease) : "")+")","",def};\
	funcs.push(func);
#define AngleY_Finish

// Opacity
#define Opacity_Define \
	ActionBase_Define\
	const char* time = nullptr;\
	const char* start = nullptr;\
	const char* stop = nullptr;\
	const char* ease = nullptr;
#define Opacity_Check \
	ActionBase_Check\
	CASE_STR(Time) { time = atts[++i]; break; }\
	CASE_STR(Start) { start = atts[++i]; break; }\
	CASE_STR(Stop) { stop = atts[++i]; break; }\
	CASE_STR(Ease) { ease = atts[++i]; break; }
#define Opacity_Create
#define Opacity_Handle \
	oFunc func = {std::string("Opacity(")+toVal(time,"0")+","+Val(start)+","+Val(stop)+(ease ? std::string(",")+toEase(ease) : "")+")","",def};\
	funcs.push(func);
#define Opacity_Finish

// SkewX
#define SkewX_Define \
	ActionBase_Define\
	const char* time = nullptr;\
	const char* start = nullptr;\
	const char* stop = nullptr;\
	const char* ease = nullptr;
#define SkewX_Check \
	ActionBase_Check\
	CASE_STR(Time) { time = atts[++i]; break; }\
	CASE_STR(Start) { start = atts[++i]; break; }\
	CASE_STR(Stop) { stop = atts[++i]; break; }\
	CASE_STR(Ease) { ease = atts[++i]; break; }
#define SkewX_Create
#define SkewX_Handle \
	oFunc func = {std::string("SkewX(")+toVal(time,"0")+","+Val(start)+","+Val(stop)+(ease ? std::string(",")+toEase(ease) : "")+")","",def};\
	funcs.push(func);
#define SkewX_Finish

// SkewY
#define SkewY_Define \
	ActionBase_Define\
	const char* time = nullptr;\
	const char* start = nullptr;\
	const char* stop = nullptr;\
	const char* ease = nullptr;
#define SkewY_Check \
	ActionBase_Check\
	CASE_STR(Time) { time = atts[++i]; break; }\
	CASE_STR(Start) { start = atts[++i]; break; }\
	CASE_STR(Stop) { stop = atts[++i]; break; }\
	CASE_STR(Ease) { ease = atts[++i]; break; }
#define SkewY_Create
#define SkewY_Handle \
	oFunc func = {std::string("SkewY(")+toVal(time,"0")+","+Val(start)+","+Val(stop)+(ease ? std::string(",")+toEase(ease) : "")+")","",def};\
	funcs.push(func);
#define SkewY_Finish

// Show
#define Show_Define \
	ActionBase_Define
#define Show_Check \
	ActionBase_Check
#define Show_Create
#define Show_Handle \
	oFunc func = {"Show()","",def};\
	funcs.push(func);
#define Show_Finish

// Hide
#define Hide_Define \
	ActionBase_Define
#define Hide_Check \
	ActionBase_Check
#define Hide_Create
#define Hide_Handle \
	oFunc func = {"Hide()","",def};\
	funcs.push(func);
#define Hide_Finish

// Emit
#define Emit_Define \
	ActionBase_Define\
	const char* event = nullptr;
#define Emit_Check \
	ActionBase_Check\
	CASE_STR(Event) { event = atts[++i]; break; }
#define Emit_Create
#define Emit_Handle \
	oFunc func = {"Emit(\""+(event ? std::string(event) : Slice::Empty)+"\")",")",def};\
	funcs.push(func);
#define Emit_Finish

// Sequence
#define Sequence_Define \
	ActionBase_Define
#define Sequence_Check \
	ActionBase_Check
#define Sequence_Create
#define Sequence_Handle \
	items.push("Sequence");\
	funcs.push({"","",def})
#define Sequence_Finish

// Spawn
#define Spawn_Define \
	ActionBase_Define
#define Spawn_Check \
	ActionBase_Check
#define Spawn_Create
#define Spawn_Handle \
	items.push("Spawn");\
	funcs.push({"","",def})
#define Spawn_Finish

#define Add_To_Parent \
	if (!elementStack.empty()) {\
		const oItem& parent = elementStack.top();\
		if (!parent.name.empty())\
		{\
			fmt::format_to(std::back_inserter(stream), "{}:addChild({})\n"sv, parent.name, self);\
			if (hasSelf && ref)\
			{\
				fmt::format_to(std::back_inserter(stream), "{}.{} = {}\n"sv, firstItem, self, self);\
			}\
			fmt::format_to(std::back_inserter(stream), "\n"sv);\
		}\
		else if (strcmp(parent.type,"Stencil") == 0)\
		{\
			elementStack.pop();\
			if (!elementStack.empty())\
			{\
				const oItem& newParent = elementStack.top();\
				fmt::format_to(std::back_inserter(stream), "{}.stencil = {}\n\n"sv, newParent.name, self);\
			}\
		}\
	}\
	else fmt::format_to(std::back_inserter(stream), "\n"sv);

// Node
#define Node_Define \
	Object_Define\
	const char* width = nullptr;\
	const char* height = nullptr;\
	const char* x = nullptr;\
	const char* y = nullptr;\
	const char* z = nullptr;\
	const char* anchorX = nullptr;\
	const char* anchorY = nullptr;\
	const char* passColor = nullptr;\
	const char* passOpacity = nullptr;\
	const char* color3 = nullptr;\
	const char* opacity = nullptr;\
	const char* angle = nullptr;\
	const char* angleX = nullptr;\
	const char* angleY = nullptr;\
	const char* scaleX = nullptr;\
	const char* scaleY = nullptr;\
	const char* skewX = nullptr;\
	const char* skewY = nullptr;\
	const char* order = nullptr;\
	const char* tag = nullptr;\
	const char* transformTarget = nullptr;\
	const char* visible = nullptr;\
	const char* touchEnabled = nullptr;\
	const char* swallowTouches = nullptr;\
	const char* swallowMouseWheel = nullptr;\
	const char* renderGroup = nullptr;\
	const char* renderOrder = nullptr;
#define Node_Check \
	Object_Check\
	CASE_STR(Width) { width = atts[++i]; break; }\
	CASE_STR(Height) { height = atts[++i]; break; }\
	CASE_STR(X) { x = atts[++i]; break; }\
	CASE_STR(Y) { y = atts[++i]; break; }\
	CASE_STR(Z) { z = atts[++i]; break; }\
	CASE_STR(AnchorX) { anchorX = atts[++i]; break; }\
	CASE_STR(AnchorY) { anchorY = atts[++i]; break; }\
	CASE_STR(PassColor) { passColor = atts[++i]; break; }\
	CASE_STR(PassOpacity) { passOpacity = atts[++i]; break; }\
	CASE_STR(Color3) { color3 = atts[++i]; break; }\
	CASE_STR(Opacity) { opacity = atts[++i]; break; }\
	CASE_STR(Angle) { angle = atts[++i]; break; }\
	CASE_STR(AngleX) { angleX = atts[++i]; break; }\
	CASE_STR(AngleY) { angleY = atts[++i]; break; }\
	CASE_STR(ScaleX) { scaleX = atts[++i]; break; }\
	CASE_STR(ScaleY) { scaleY = atts[++i]; break; }\
	CASE_STR(SkewX) { skewX = atts[++i]; break; }\
	CASE_STR(SkewY) { skewY = atts[++i]; break; }\
	CASE_STR(Order) { order = atts[++i]; break; }\
	CASE_STR(Tag) { tag = atts[++i]; break; }\
	CASE_STR(TransformTarget) { transformTarget = atts[++i]; break; }\
	CASE_STR(Visible) { visible = atts[++i]; break; }\
	CASE_STR(TouchEnabled) { touchEnabled = atts[++i]; break; }\
	CASE_STR(SwallowTouches) { swallowTouches = atts[++i]; break; }\
	CASE_STR(SwallowMouseWheel) { swallowMouseWheel = atts[++i]; break; }\
	CASE_STR(RenderGroup) { renderGroup = atts[++i]; break; }\
	CASE_STR(RenderOrder) { renderOrder = atts[++i]; break; }
#define Node_Create \
	fmt::format_to(std::back_inserter(stream), "local {} = Node()\n"sv, self);
#define Node_Handle \
	if (anchorX && anchorY) fmt::format_to(std::back_inserter(stream), "{}.anchor = Vec2({},{})\n"sv, self, Val(anchorX), Val(anchorY));\
	else if (anchorX && !anchorY) fmt::format_to(std::back_inserter(stream), "{}.anchor = Vec2({},{}.anchor.y)\n"sv, self, Val(anchorX), self);\
	else if (!anchorX && anchorY) fmt::format_to(std::back_inserter(stream), "{}.anchor = Vec2({}.anchor.x,{})\n"sv, self, Val(anchorY), self);\
	if (x) fmt::format_to(std::back_inserter(stream), "{}.x = {}\n"sv, self, Val(x));\
	if (y) fmt::format_to(std::back_inserter(stream), "{}.y = {}\n"sv, self, Val(y));\
	if (z) fmt::format_to(std::back_inserter(stream), "{}.z = {}\n"sv, self, Val(z));\
	if (passColor) fmt::format_to(std::back_inserter(stream), "{}.passColor = {}\n"sv, self, toBoolean(passColor));\
	if (passOpacity) fmt::format_to(std::back_inserter(stream), "{}.passOpacity = {}\n"sv, self, toBoolean(passOpacity));\
	if (color3) fmt::format_to(std::back_inserter(stream), "{}.color3 = Color3({})\n"sv, self, Val(color3));\
	if (opacity) fmt::format_to(std::back_inserter(stream), "{}.opacity = {}\n"sv, self, Val(opacity));\
	if (angle) fmt::format_to(std::back_inserter(stream), "{}.angle = {}\n"sv, self, Val(angle));\
	if (angleX) fmt::format_to(std::back_inserter(stream), "{}.angleX = {}\n"sv, self, Val(angleX));\
	if (angleY) fmt::format_to(std::back_inserter(stream), "{}.angleY = {}\n"sv, self, Val(angleY));\
	if (scaleX) fmt::format_to(std::back_inserter(stream), "{}.scaleX = {}\n"sv, self, Val(scaleX));\
	if (scaleY) fmt::format_to(std::back_inserter(stream), "{}.scaleY = {}\n"sv, self, Val(scaleY));\
	if (skewX) fmt::format_to(std::back_inserter(stream), "{}.skewX = {}\n"sv, self, Val(skewX));\
	if (skewY) fmt::format_to(std::back_inserter(stream), "{}.skewY = {}\n"sv, self, Val(skewY));\
	if (transformTarget) fmt::format_to(std::back_inserter(stream), "{}.transformTarget = {}\n"sv, self, Val(transformTarget));\
	if (visible) fmt::format_to(std::back_inserter(stream), "{}.visible = {}\n"sv, self, toBoolean(visible));\
	if (order) fmt::format_to(std::back_inserter(stream), "{}.order = {}\n"sv, self, Val(order));\
	if (tag) fmt::format_to(std::back_inserter(stream), "{}.tag = {}\n"sv, self, toText(tag));\
	if (width && height) fmt::format_to(std::back_inserter(stream), "{}.size = Size({},{})\n"sv, self, Val(width), Val(height));\
	else if (width && !height) fmt::format_to(std::back_inserter(stream), "{}.width = {}\n"sv, self, Val(width));\
	else if (!width && height) fmt::format_to(std::back_inserter(stream), "{}.height = {}\n"sv, self, Val(height));\
	if (touchEnabled) fmt::format_to(std::back_inserter(stream), "{}.touchEnabled = {}\n"sv, self, toBoolean(touchEnabled));\
	if (swallowTouches) fmt::format_to(std::back_inserter(stream), "{}.swallowTouches = {}\n"sv, self, toBoolean(swallowTouches));\
	if (swallowMouseWheel) fmt::format_to(std::back_inserter(stream), "{}.swallowMouseWheel = {}\n"sv, self, toBoolean(swallowMouseWheel));\
	if (renderGroup) fmt::format_to(std::back_inserter(stream), "{}.renderGroup = {}\n"sv, self, toBoolean(renderGroup));\
	if (renderOrder) fmt::format_to(std::back_inserter(stream), "{}.renderOrder = {}\n"sv, self, Val(renderOrder));
#define Node_Finish \
	Add_To_Parent

// DrawNode
#define DrawNode_Define \
	Node_Define
#define DrawNode_Check \
	Node_Check
#define DrawNode_Create \
	fmt::format_to(std::back_inserter(stream), "local {} = DrawNode()\n"sv, self);
#define DrawNode_Handle \
	Node_Handle
#define DrawNode_Finish \
	Add_To_Parent

// DrawNode.Dot
#define Dot_Define \
	const char* x = nullptr;\
	const char* y = nullptr;\
	const char* radius = nullptr;\
	const char* color = nullptr;
#define Dot_Check \
	CASE_STR(X) { x = atts[++i]; break; }\
	CASE_STR(Y) { y = atts[++i]; break; }\
	CASE_STR(Radius) { radius = atts[++i]; break; }\
	CASE_STR(Color) { color = atts[++i]; break; }
#define Dot_Finish \
	if (!elementStack.empty())\
	{\
		fmt::format_to(std::back_inserter(stream),\
			"{}:drawDot(Vec2({},{}),{},Color({}))\n\n"sv,\
			elementStack.top().name, toVal(x,"0"), toVal(y,"0"), toVal(radius,"0.5"), Val(color)\
		);\
	}

// DrawNode.Polygon
#define Polygon_Define \
	const char* fillColor = nullptr;\
	const char* borderWidth = nullptr;\
	const char* borderColor = nullptr;
#define Polygon_Check \
	CASE_STR(FillColor) { fillColor = atts[++i]; break; }\
	CASE_STR(BorderWidth) { borderWidth = atts[++i]; break; }\
	CASE_STR(BorderColor) { borderColor = atts[++i]; break; }
#define Polygon_Finish \
	if (!elementStack.empty())\
	{\
		oFunc func = {elementStack.top().name+":drawPolygon({"s,\
		"},Color("s+Val(fillColor)+"),"s+toVal(borderWidth,"0")+",Color("s+toVal(borderColor,"")+"))\n\n"s};\
		funcs.push(func);\
		items.push("Polygon");\
	}

// DrawNode.Segment
#define Segment_Define \
	const char* beginX = nullptr;\
	const char* beginY = nullptr;\
	const char* endX = nullptr;\
	const char* endY = nullptr;\
	const char* radius = nullptr;\
	const char* color = nullptr;
#define Segment_Check \
	CASE_STR(BeginX) { beginX = atts[++i]; break; }\
	CASE_STR(BeginY) { beginY = atts[++i]; break; }\
	CASE_STR(EndX) { endX = atts[++i]; break; }\
	CASE_STR(EndY) { endY = atts[++i]; break; }\
	CASE_STR(Radius) { radius = atts[++i]; break; }\
	CASE_STR(Color) { color = atts[++i]; break; }
#define Segment_Finish \
	if (!elementStack.empty())\
	{\
		fmt::format_to(std::back_inserter(stream),\
			"{}:drawSegment(Vec2({},{}),Vec2({},{}),{},Color({}))\n\n"sv,\
			elementStack.top().name, toVal(beginX,"0"), toVal(beginY,"0"),\
			toVal(endX,"0"), toVal(endY,"0"), toVal(radius,"0.5"), toVal(color,"")\
		);\
	}

// Line
#define Line_Define \
	Node_Define
#define Line_Check \
	Node_Check
#define Line_Create \
	fmt::format_to(std::back_inserter(stream), "local {} = Line()\n"sv, self);
#define Line_Handle \
	Node_Handle
#define Line_Finish \
	Add_To_Parent\
	oFunc func = {std::string(self)+":set({"s, "},Color(0xffffffff))\n"s};\
	funcs.push(func);\
	items.push("Line");

// ClipNode
#define ClipNode_Define \
	Node_Define\
	const char* alphaThreshold = nullptr;\
	const char* inverted = nullptr;
#define ClipNode_Check \
	Node_Check\
	CASE_STR(AlphaThreshold) { alphaThreshold = atts[++i]; break; }\
	CASE_STR(Inverted) { inverted = atts[++i]; break; }
#define ClipNode_Create \
	fmt::format_to(std::back_inserter(stream), "local {} = ClipNode()\n"sv, self);
#define ClipNode_Handle \
	Node_Handle\
	if (alphaThreshold) fmt::format_to(std::back_inserter(stream), "{}.alphaThreshold = {}\n"sv, self, Val(alphaThreshold));\
	if (inverted) fmt::format_to(std::back_inserter(stream), "{}.inverted = {}\n"sv, toBoolean(inverted));
#define ClipNode_Finish \
	Add_To_Parent

// Label
#define Label_Define \
	Node_Define\
	const char* text = nullptr;\
	const char* fontName = nullptr;\
	const char* fontSize = nullptr;\
	const char* textWidth = nullptr;\
	const char* lineGap = nullptr;\
	const char* alignment = nullptr;
#define Label_Check \
	Node_Check\
	CASE_STR(Text) { text = atts[++i]; break; }\
	CASE_STR(FontName) { fontName = atts[++i]; break; }\
	CASE_STR(FontSize) { fontSize = atts[++i]; break; }\
	CASE_STR(TextAlign) { alignment = atts[++i]; break; }\
	CASE_STR(TextWidth) { textWidth = atts[++i]; break; }\
	CASE_STR(LineGap) { lineGap = atts[++i]; break; }
#define Label_Create \
	fmt::format_to(std::back_inserter(stream), "local {} = Label({},{})\n"sv, self, toText(fontName), Val(fontSize));
#define Label_Handle \
	Node_Handle\
	if (text && text[0]) fmt::format_to(std::back_inserter(stream), "{}.text = {}\n"sv, self, toText(text));\
	if (alignment) fmt::format_to(std::back_inserter(stream), "{}.alignment = {}\n"sv, self, toTextAlign(alignment));\
	if (textWidth) fmt::format_to(std::back_inserter(stream), "{}.textWidth = {}\n"sv,self, strcmp(textWidth,"Auto") == 0 ? "Label.AutomaticWidth"s : Val(textWidth));\
	if (lineGap) fmt::format_to(std::back_inserter(stream), "{}.lineGap = {}\n"sv, self, Val(lineGap));
#define Label_Finish \
	Add_To_Parent

// Sprite
#define Sprite_Define \
	Node_Define\
	const char* file = nullptr;\
	const char* blendSrc = nullptr;\
	const char* blendDst = nullptr;
#define Sprite_Check \
	Node_Check\
	CASE_STR(File) { file = atts[++i]; break; }\
	CASE_STR(BlendSrc) { blendSrc = atts[++i]; break; }\
	CASE_STR(BlendDst) { blendDst = atts[++i]; break; }
#define Sprite_Create \
	fmt::format_to(std::back_inserter(stream), "local {} = Sprite({})\n"sv, self, file ? toText(file) : std::string());
#define Sprite_Handle \
	Node_Handle\
	if (blendSrc && blendDst) fmt::format_to(std::back_inserter(stream), "{}.blendFunc = BlendFunc(\"{}\",\"{}\")\n"sv, self, toBlendFunc(blendSrc), toBlendFunc(blendDst));\
	else if (blendSrc && !blendDst) fmt::format_to(std::back_inserter(stream), "{}.blendFunc = BlendFunc(\"{}\",\"Zero\")\n"sv, self, toBlendFunc(blendSrc));\
	else if (!blendSrc && blendDst) fmt::format_to(std::back_inserter(stream), "{}.blendFunc = BlendFunc(\"Zero\",\"{}\")\n"sv, self, toBlendFunc(blendDst));
#define Sprite_Finish \
	Add_To_Parent

// Model
#define Model_Define \
	Node_Define\
	const char* filename = nullptr;\
	const char* look = nullptr;\
	const char* loop = nullptr;\
	const char* reversed = nullptr;\
	const char* play = nullptr;\
	const char* faceRight = nullptr;\
	const char* speed = nullptr;
#define Model_Check \
	Node_Check\
	CASE_STR(File) { filename = atts[++i]; break; }\
	CASE_STR(Look) { look = atts[++i]; break; }\
	CASE_STR(Loop) { loop = atts[++i]; break; }\
	CASE_STR(Reversed) { reversed = atts[++i]; break; }\
	CASE_STR(Play) { play = atts[++i]; break; }\
	CASE_STR(FaceRight) { faceRight = atts[++i]; break; }\
	CASE_STR(Speed) { speed = atts[++i]; break; }
#define Model_Create \
	fmt::format_to(std::back_inserter(stream), "local {} = Model({})\n"sv, self, toText(filename));
#define Model_Handle \
	Node_Handle\
	if (look) fmt::format_to(std::back_inserter(stream), "{}.look = \"{}\"\n"sv, self, Val(look));\
	if (reversed) fmt::format_to(std::back_inserter(stream), "{}.reversed = {}\n"sv, self, toBoolean(reversed));\
	if (faceRight) fmt::format_to(std::back_inserter(stream), "{}.faceRight = {}\n"sv, self, toBoolean(faceRight));\
	if (speed) fmt::format_to(std::back_inserter(stream), "{}.speed = {}\n"sv, self, Val(speed));\
	if (play) fmt::format_to(std::back_inserter(stream), "{}:play(\"{}\"{})\n"sv, self, Val(play), loop ? std::string(",") + toBoolean(loop) : std::string());
#define Model_Finish \
	Add_To_Parent

// Menu
#define Menu_Define \
	Node_Define\
	const char* enabled = nullptr;
#define Menu_Check \
	Node_Check\
	CASE_STR(Enabled) { enabled = atts[++i]; break; }
#define Menu_Create \
	fmt::format_to(std::back_inserter(stream), "local {} = Menu()\n"sv, self);
#define Menu_Handle \
	Node_Handle\
	if (enabled) fmt::format_to(std::back_inserter(stream), "{}.enabled = {}\n"sv, self, toBoolean(enabled));
#define Menu_Finish \
	Add_To_Parent

// ModuleNode
#define ModuleNode_Define \
	Object_Define
#define ModuleNode_Check \
	Object_Check\
	default: { int index = i;attributes[atts[index]] = atts[++i]; break; }
#define ModuleNode_Create \
	fmt::format_to(std::back_inserter(stream), "local {} = {}{{"sv, self, element);
#define ModuleNode_Handle \
	auto it = attributes.begin();\
	while (it != attributes.end())\
	{\
		std::string str = std::string() + (char)tolower(it->first[0]) + it->first.substr(1) + " = "s;\
		char* p;\
		strtod(it->second.c_str(), &p);\
		if (*p == 0) str += it->second;\
		else str += toText(it->second.c_str());\
		++it;\
		if (it != attributes.end())\
		{\
			str += ", "s;\
		}\
		fmt::format_to(std::back_inserter(stream), "{}"sv, str);\
	}\
	attributes.clear();\
	fmt::format_to(std::back_inserter(stream), "}}\n"sv);
#define ModuleNode_Finish \
	if (!elementStack.empty())\
	{\
		const oItem& parent = elementStack.top();\
		if (!parent.name.empty())\
		{\
			fmt::format_to(std::back_inserter(stream), "{}:addChild({})\n"sv, parent.name, self);\
			if (hasSelf && ref)\
			{\
				fmt::format_to(std::back_inserter(stream), "{}.{} = {}\n"sv, firstItem, self, self);\
			}\
			fmt::format_to(std::back_inserter(stream), "\n"sv);\
		}\
		else if (strcmp(parent.type,"Stencil") == 0)\
		{\
			elementStack.pop();\
			if (!elementStack.empty())\
			{\
				const oItem& newParent = elementStack.top();\
				fmt::format_to(std::back_inserter(stream), "{}.stencil = {}\n\n"sv, newParent.name, self);\
			}\
		}\
	}\
	else fmt::format_to(std::back_inserter(stream), "\n"sv);

// Import
#define Import_Define \
	const char* module = nullptr;\
	const char* name = nullptr;
#define Import_Check \
	CASE_STR(Module) { module = atts[++i]; break; }\
	CASE_STR(Name) { name = atts[++i]; break; }
#define Import_Create \
	if (module) {\
		std::string mod(module);\
		size_t pos = mod.rfind('.');\
		std::string modStr = (name ? name : (pos == std::string::npos ? std::string(module) : mod.substr(pos+1)));\
		imported.insert(modStr);\
		fmt::format_to(std::back_inserter(requires), "local {} = require(\"{}\")\n"sv, modStr, module);\
	}

// Item
#define NodeItem_Define \
	const char* name = nullptr;
#define NodeItem_Check \
	CASE_STR(Name) { name = atts[++i]; break; }
#define NodeItem_Create \
	fmt::format_to(std::back_inserter(stream), "local {} = {}.{}\n\n"sv, Val(name), elementStack.top().name, Val(name));\
	if (name && name[0])\
	{\
		oItem item = { "Item", name };\
		elementStack.push(item);\
	}

// Slot
#define Slot_Define \
	const char* name = nullptr;\
	const char* args = nullptr;\
	const char* perform = nullptr;\
	const char* target = nullptr;\
	const char* type = nullptr;
#define Slot_Check \
	CASE_STR(Name) { name = atts[++i]; break; }\
	CASE_STR(Args) { args = atts[++i]; break; }\
	CASE_STR(Target) { target = atts[++i]; break; }\
	CASE_STR(Perform) { perform = atts[++i]; break; }\
	CASE_STR(Type) { type = atts[++i]; break; }
#define Slot_Create \
	isYue = type && std::string(type) == "Yue"sv;\
	oFunc func = {elementStack.top().name+":slot("s+toText(name)+",function("s+(args ? args : "")+')'+(perform ? "\n"s+(target ? std::string(target) : elementStack.top().name)+":perform("s+perform+")\n"s : Slice::Empty), "end)"s};\
	funcs.push(func);

// Script
#define Script_Define \
	const char* type = nullptr;
#define Script_Check \
	CASE_STR(Type) { type = atts[++i]; break; }
#define Script_Create \
	isYue = type && std::string(type) == "Yue"sv;

#define Item_Define(name) name##_Define
#define Item_Loop(name) \
	for (int i = 0; atts[i] != nullptr; i++)\
	{\
		SWITCH_STR_START(atts[i])\
		{\
			name##_Check\
		}\
		SWITCH_STR_END\
	}
#define Item_Create(name) name##_Create
#define Item_Handle(name) name##_Handle
#define Item_Push(name) name##_Finish;oItem item = {#name,self,ref};elementStack.push(item);

#define Item(name,var) \
	CASE_STR(name)\
	{\
		Item_Define(name)\
		Item_Loop(name)\
		Self_Check(var)\
		Item_Create(name)\
		Item_Handle(name)\
		Item_Push(name)\
		break;\
	}

#define ItemDot_Push(prename,name) prename##_##name##_Finish;oItem item = {#prename"."#name,self,ref};elementStack.push(item);
#define ItemDot(prename,name,var) \
	CASE_STR_DOT(prename,name)\
	{\
		Item_Define(prename##_##name)\
		Item_Loop(prename##_##name)\
		Self_Check(var)\
		Item_Create(prename##_##name)\
		Item_Handle(prename##_##name)\
		ItemDot_Push(prename,name)\
		break;\
	}

class XmlDelegator : public SAXDelegator
{
public:
	XmlDelegator(SAXParser* parser):
	isYue(false),
	codes(nullptr),
	parser(parser)
	{ }
	virtual void startElement(const char* name, const char** atts);
	virtual void endElement(const char* name);
	virtual void textHandler(const char* s, int len);
	std::string oVal(const char* value, const char* def = nullptr, const char* element = nullptr, const char* attr = nullptr);
	std::string compileYueCodes(const char* codes);
public:
	void clear()
	{
		codes = nullptr;
		for (; !elementStack.empty(); elementStack.pop());
		for (; !funcs.empty(); funcs.pop());
		for (; !items.empty(); items.pop());
		stream = fmt::memory_buffer();
		requires = fmt::memory_buffer();
		names.clear();
		imported.clear();
		firstItem.clear();
		lastError.clear();
	}
	void begin()
	{
		XmlDelegator::clear();
		fmt::format_to(std::back_inserter(stream),
			"return function(args)\n"
			"local _ENV = Dorothy(args)\n\n"sv);
	}
	void end()
	{
		fmt::format_to(std::back_inserter(stream), "return {}\nend"sv, firstItem);
	}
	std::string getResult()
	{
		if (lastError.empty())
		{
			std::string requireStr = fmt::to_string(requires);
			return requireStr + (requireStr.empty() ? "" : "\n") + fmt::to_string(stream);
		}
		return std::string();
	}
	const std::string& getLastError()
	{
		return lastError;
	}
private:
	std::string getUsableName(const char* baseName)
	{
		int index = 1;
		std::string base(baseName);
		std::string name;
		do
		{
			name = fmt::format("{}{}", base, index);
			auto it = names.find(name);
			if (it == names.end()) break;
			else index++;
		} 
		while (true);
		return name;
	}
private:
	struct oItem
	{
		const char* type;
		std::string name;
		bool ref;
	};
	struct oFunc
	{
		std::string begin;
		std::string end;
		bool flag;
	};
	SAXParser* parser;
	// Script
	bool isYue;
	const char* codes;
	// Loader
	std::string firstItem;
	std::string lastError;
	std::stack<oFunc> funcs;
	std::stack<std::string> items;
	std::stack<oItem> elementStack;
	std::unordered_set<std::string> names;
	std::unordered_set<std::string> imported;
	std::unordered_map<std::string, std::string> attributes;
	fmt::memory_buffer stream;
	fmt::memory_buffer requires;
};

std::string XmlDelegator::oVal(const char* value, const char* def, const char* element, const char* attr)
{
	if (!value || !value[0])
	{
		if (def) return std::string(def);
		else if (attr && element)
		{
			std::string num = fmt::format("%d", parser->getLineNumber(element));
			lastError += std::string("Missing attribute ") + (char)toupper(attr[0]) + std::string(attr).substr(1) + " for " + element + ", at line " + num + "\n";
		}
		return std::string();
	}
	if (value[0] == '{')
	{
		std::string valStr(value);
		if (valStr.back() != '}') return valStr;
		size_t start = 1;
		for (; valStr[start] == ' ' || valStr[start] == '\t'; ++start);
		size_t end = valStr.size() - 2;
		for (; valStr[end] == ' ' || valStr[end] == '\t'; --end);
		if (end < start)
		{
			if (attr && element)
			{
				std::string num = fmt::format("%d", parser->getLineNumber(element));
				lastError += std::string("Missing attribute ") + (char)toupper(attr[0]) + std::string(attr).substr(1) + " for " + element + ", at line " + num + "\n";
			}
			return std::string();
		}
		valStr = valStr.substr(start, end - start + 1);
		std::string newStr;
		start = 0;
		size_t i = 0;
		while (i < valStr.size())
		{
			if ((valStr[i] == '$' || valStr[i] == '@') && i < valStr.size() - 1)
			{
				if (valStr[i] == '$')
				{
					std::string parent;
					if (!elementStack.empty())
					{
						oItem top = elementStack.top();
						if (!top.name.empty())
						{
							parent = top.name;
						}
						else if (strcmp(top.type, "Stencil") == 0)
						{
							elementStack.pop();
							if (!elementStack.empty())
							{
								const oItem& newTop = elementStack.top();
								parent = newTop.name;
							}
							elementStack.push(top);
						}
					}
					if (parent.empty() && element)
					{
						std::string num = fmt::format("%d", parser->getLineNumber(element));
						lastError += std::string("The $ expression can`t be used in tag at line ") + num + "\n";
					}
					newStr += valStr.substr(start, i - start);
					i++;
					start = i + 1;
					switch (valStr[i])
					{
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
						if (element)
						{
							std::string num = fmt::format("%d", parser->getLineNumber(element));
							lastError += std::string("Invalid expression $") + valStr[i] + " at line " + num + "\n";
						}
						break;
					}
				}
				else
				{
					newStr += valStr.substr(start, i - start);
					i++;
					start = i + 1;
					switch (valStr[i])
					{
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
						if (element)
						{
							std::string num = fmt::format("%d", parser->getLineNumber(element));
							lastError += std::string("Invalid expression @") + valStr[i] + " at line " + num + "\n";
						}
						break;
					}
				}
			}
			i++;
		}
		if (0 < start)
		{
			if (start < valStr.size()) newStr += valStr.substr(start);
			return newStr;
		}
		else return valStr;
	}
	else return std::string(value);
}

void XmlDelegator::startElement(const char* element, const char** atts)
{
	SWITCH_STR_START(element)
	{
		CASE_STR(Dorothy)
		{
			break;
		}

		Item(Node, node)
		Item(DrawNode, drawNode)
		Item(Line, line)
		Item(Sprite, sprite)
		Item(ClipNode, clipNode)
		Item(Label, label)

		Item(Model, model)
		Item(Menu, menu)

		Item(Delay, delay)
		Item(Scale, scale)
		Item(Move, move)
		Item(Angle, angle)
		Item(Opacity, opacity)
		Item(SkewX, skewX)
		Item(SkewY, skewY)

		Item(Show, show)
		Item(Hide, hide)
		Item(Emit, emit)

		Item(Sequence, sequence)
		Item(Spawn, spawn)

		CASE_STR(Vec2)
		{
			Item_Define(Vec2)
			Item_Loop(Vec2)
			Item_Handle(Vec2)
			break;
		}
		CASE_STR(Dot)
		{
			Item_Define(Dot)
			Item_Loop(Dot)
			Dot_Finish
			break;
		}
		CASE_STR(Polygon)
		{
			Item_Define(Polygon)
			Item_Loop(Polygon)
			Polygon_Finish
			break;
		}
		CASE_STR(Segment)
		{
			Item_Define(Segment)
			Item_Loop(Segment)
			Segment_Finish
			break;
		}
		CASE_STR(Stencil)
		{
			oItem item = { "Stencil" };
			elementStack.push(item);
			break;
		}
		CASE_STR(Import)
		{
			Item_Define(Import)
			Item_Loop(Import)
			Import_Create
			break;
		}
		CASE_STR(Action)
		{
			oItem item = { "Action" };
			elementStack.push(item);
			break;
		}
		CASE_STR(Item)
		{
			Item_Define(NodeItem)
			Item_Loop(NodeItem)
			Item_Create(NodeItem)
			break;
		}
		CASE_STR(Slot)
		{
			Item_Define(Slot)
			Item_Loop(Slot)
			Item_Create(Slot)
			break;
		}
		CASE_STR(Script)
		{
			Item_Define(Script)
			Item_Loop(Script)
			Item_Create(Script)
			break;
		}
		default:
		{
			Item_Define(ModuleNode)
			Item_Loop(ModuleNode)
			Self_Check(item)
			Item_Create(ModuleNode)
			Item_Handle(ModuleNode)
			ModuleNode_Finish;
			oItem item = { element, self, ref };
			elementStack.push(item);
			break;
		}
	}
	SWITCH_STR_END
}

std::string XmlDelegator::compileYueCodes(const char* codes)
{
	yue::YueConfig config;
	config.reserveLineNumber = false;
	config.implicitReturnRoot = false;
	auto result = yue::YueCompiler{}.compile(fmt::format("do\n{}", codes), config);
	if (result.codes.empty())
	{
		lastError += fmt::format("failed to compile yue codes started at line {}\n{}", parser->getLineNumber(codes), result.error);
	}
	return std::move(result.codes);
}

void XmlDelegator::endElement(const char *name)
{
	if (elementStack.empty()) return;
	oItem currentData = elementStack.top();
	if (strcmp(name, elementStack.top().type) == 0) elementStack.pop();
	bool parentIsAction = !elementStack.empty() && strcmp(elementStack.top().type, "Action") == 0;

	SWITCH_STR_START(name)
	{
		CASE_STR(Script)
		{
			if (codes)
			{
				if (isYue) fmt::format_to(std::back_inserter(stream), "{}\n"sv, compileYueCodes(codes));
				else fmt::format_to(std::back_inserter(stream), "{}\n"sv, codes);
			}
			codes = nullptr;
			isYue = false;
			break;
		}
		CASE_STR(Slot)
		{
			oFunc func = funcs.top();
			funcs.pop();
			fmt::format_to(std::back_inserter(stream), "{}{}{}\n"sv, func.begin, (codes ? (isYue ? compileYueCodes(codes) : std::string(codes)) : Slice::Empty), func.end);
			codes = nullptr;
			isYue = false;
			break;
		}
		#define CaseAction(x) CASE_STR(x)
		#define CaseActionDot(x1,x2) CASE_STR_DOT(x1,x2)
		CaseAction(Delay)
		CaseAction(Scale)
		CaseAction(Move)
		CaseAction(Angle)
		CaseAction(Opacity)
		CaseAction(SkewX)
		CaseAction(SkewY)
		CaseAction(Show)
		CaseAction(Hide)
		CaseAction(Emit)
		{
			oFunc func = funcs.top();
			funcs.pop();
			if (parentIsAction)
			{
				fmt::format_to(std::back_inserter(stream), func.flag ? "local {} = {}\n"sv : "local {} = Action({})\n"sv, currentData.name, func.begin);
			}
			else
			{
				items.push(func.begin);
				auto it = names.find(currentData.name);
				if (it != names.end()) names.erase(it);
			}
			break;
		}
		CASE_STR(Sequence)
		CASE_STR(Spawn)
		{
			oFunc func = funcs.top();
			funcs.pop();
			std::string tempItem = std::string(name) + "(";
			std::stack<std::string> tempStack;
			while (items.top() != name)
			{
				tempStack.push(items.top());
				items.pop();
			}
			items.pop();
			while (!tempStack.empty())
			{
				tempItem += tempStack.top();
				tempStack.pop();
				if (!tempStack.empty()) tempItem += ",";
			}
			tempItem += ")";
			if (parentIsAction)
			{
				fmt::format_to(std::back_inserter(stream), func.flag ? "local {} = {}\n"sv : "local {} = Action({})\n"sv, currentData.name, tempItem);
			}
			else
			{
				items.push(tempItem);
				auto it = names.find(currentData.name);
				if (it != names.end()) names.erase(it);
			}
			break;
		}
		CASE_STR(Polygon)
		CASE_STR(Line)
		{
			oFunc func = funcs.top();
			funcs.pop();
			fmt::format_to(std::back_inserter(stream), "{}"sv, func.begin);
			std::stack<std::string> tempStack;
			while (items.top() != name)
			{
				tempStack.push(items.top());
				items.pop();
			}
			items.pop();
			while (!tempStack.empty())
			{
				fmt::format_to(std::back_inserter(stream), "{}"sv, tempStack.top());
				tempStack.pop();
				if (!tempStack.empty()) fmt::format_to(std::back_inserter(stream), ","sv);
			}
			fmt::format_to(std::back_inserter(stream), "{}"sv, func.end);
			break;
		}
		CASE_STR(Action)
		{
			fmt::format_to(std::back_inserter(stream), "\n"sv);
			break;
		}
		#define CaseBuiltin(x) CASE_STR(x)
		CaseBuiltin(Node)
		CaseBuiltin(DrawNode)
		CaseBuiltin(Sprite)
		CaseBuiltin(ClipNode)
		CaseBuiltin(Label)
		CaseBuiltin(Model)
		CaseBuiltin(Menu)
		CaseBuiltin(Vec2)
		CaseBuiltin(Dot)
		CaseBuiltin(Segment)
		CaseBuiltin(Stencil)
		CaseBuiltin(Import)
		CaseBuiltin(Item)
		{
			break;
		}
		default:
		{
			auto it = imported.find(name);
			if (it == imported.end())
			{
				lastError += fmt::format("Tag <{}> not imported, closed at line {}.\n", name, parser->getLineNumber(name));
			}
			break;
		}
	}
	SWITCH_STR_END

	if (parentIsAction && currentData.ref)
	{
		fmt::format_to(std::back_inserter(stream), "{}.{} = {}\n"sv, firstItem, currentData.name, currentData.name);
	}
}

void XmlDelegator::textHandler(const char* s, int len)
{
	codes = s;
}

XmlLoader::XmlLoader():_delegator(new XmlDelegator(&_parser))
{
	_parser.setDelegator(_delegator.get());
}

XmlLoader::~XmlLoader()
{ }

std::string XmlLoader::load(String filename)
{
	_delegator->begin();
	SAXParser::setHeaderHandler(Handler);
	bool result = _parser.parse(filename);
	SAXParser::setHeaderHandler(nullptr);
	_delegator->end();
	return result ? _delegator->getResult() : std::string();
}

std::string XmlLoader::loadXml(String xml)
{
	_delegator->begin();
	SAXParser::setHeaderHandler(Handler);
	bool result = _parser.parseXml(xml);
	SAXParser::setHeaderHandler(nullptr);
	_delegator->end();
	return result ? _delegator->getResult() : std::string();
}

std::string XmlLoader::getLastError()
{
	const std::string& parserError = _parser.getLastError();
	const std::string& dorothyError = _delegator->getLastError();
	if (parserError.empty() && !dorothyError.empty())
	{
		return std::string("Xml document error\n") + dorothyError;
	}
	return parserError + dorothyError;
}

NS_DOROTHY_END
