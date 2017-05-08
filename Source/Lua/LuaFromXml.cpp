/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"
#include "Lua/LuaFromXml.h"
#include "tinyxml2/SAXParser.h"
#include "fmt/format.h"

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
#define toEase(x) (isVal(x) ? string("Ease.")+Val(x) : Val(x))
#define toBlendFunc(x) (isVal(x) ? string("BlendFunc.")+toVal(x,"Zero") : Val(x))
#define toTextAlign(x) (isVal(x) ? string("TextAlign.")+toVal(x,"Center") : Val(x))
#define toText(x) (isVal(x) ? string("\"")+Val(x)+"\"" : Val(x))

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
	items.push(string("Vec2(")+toVal(x,"0")+","+toVal(y,"0")+")");

// Object
#define Object_Define \
	string self;\
	bool hasSelf = false;\
	bool ref = false;
#define Object_Check \
	CASE_STR(Name) { hasSelf = true; self = atts[++i]; break; }\
	CASE_STR(Ref) { ref = strcmp(atts[++i],"True") == 0; break; }

// Delay
#define Delay_Define \
	Object_Define\
	const char* time = nullptr;
#define Delay_Check \
	Object_Check\
	CASE_STR(Time) { time = atts[++i]; break; }
#define Delay_Create
#define Delay_Handle \
	oFunc func = {string("Delay(")+toVal(time,"0")+")",""};\
	funcs.push(func);
#define Delay_Finish

// Scale
#define Scale_Define \
	Object_Define\
	const char* time = nullptr;\
	const char* start = nullptr;\
	const char* stop = nullptr;\
	const char* ease = nullptr;
#define Scale_Check \
	Object_Check\
	CASE_STR(Time) { time = atts[++i]; break; }\
	CASE_STR(Start) { start = atts[++i]; break; }\
	CASE_STR(Stop) { stop = atts[++i]; break; }\
	CASE_STR(Ease) { ease = atts[++i]; break; }
#define Scale_Create
#define Scale_Handle \
	oFunc func = {string("Scale(")+toVal(time,"0")+","+Val(start)+","+Val(stop)+(ease ? string(",")+toEase(ease) : "")+")",""};\
	funcs.push(func);
#define Scale_Finish

// Move
#define Move_Define \
	Object_Define\
	const char* time = nullptr;\
	const char* startX = nullptr;\
	const char* startY = nullptr;\
	const char* stopX = nullptr;\
	const char* stopY = nullptr;\
	const char* ease = nullptr;
#define Move_Check \
	Object_Check\
	CASE_STR(Time) { time = atts[++i]; break; }\
	CASE_STR(StartX) { startX = atts[++i]; break; }\
	CASE_STR(StartY) { startY = atts[++i]; break; }\
	CASE_STR(StopX) { stopX = atts[++i]; break; }\
	CASE_STR(StopY) { stopY = atts[++i]; break; }\
	CASE_STR(Ease) { ease = atts[++i]; break; }
#define Move_Create
#define Move_Handle \
	oFunc func = {string("Move(")+toVal(time,"0")+",Vec2("+Val(startX)+","+Val(startY)+"),Vec2("+Val(stopX)+","+Val(stopY)+")"+(ease ? string(",")+toEase(ease) : "")+")",""};\
	funcs.push(func);
#define Move_Finish

// Angle
#define Angle_Define \
	Object_Define\
	const char* time = nullptr;\
	const char* start = nullptr;\
	const char* stop = nullptr;\
	const char* ease = nullptr;
#define Angle_Check \
	Object_Check\
	CASE_STR(Time) { time = atts[++i]; break; }\
	CASE_STR(Start) { start = atts[++i]; break; }\
	CASE_STR(Stop) { stop = atts[++i]; break; }\
	CASE_STR(Ease) { ease = atts[++i]; break; }
#define Angle_Create
#define Angle_Handle \
	oFunc func = {string("Angle(")+toVal(time,"0")+","+Val(start)+","+Val(stop)+(ease ? string(",")+toEase(ease) : "")+")",""};\
	funcs.push(func);
#define Angle_Finish

// AngleX
#define AngleX_Define \
	Object_Define\
	const char* time = nullptr;\
	const char* start = nullptr;\
	const char* stop = nullptr;\
	const char* ease = nullptr;
#define AngleX_Check \
	Object_Check\
	CASE_STR(Time) { time = atts[++i]; break; }\
	CASE_STR(Start) { start = atts[++i]; break; }\
	CASE_STR(Stop) { stop = atts[++i]; break; }\
	CASE_STR(Ease) { ease = atts[++i]; break; }
#define AngleX_Create
#define AngleX_Handle \
	oFunc func = {string("AngleX(")+toVal(time,"0")+","+Val(start)+","+Val(stop)+(ease ? string(",")+toEase(ease) : "")+")",""};\
	funcs.push(func);
#define AngleX_Finish

// AngleY
#define AngleY_Define \
	Object_Define\
	const char* time = nullptr;\
	const char* start = nullptr;\
	const char* stop = nullptr;\
	const char* ease = nullptr;
#define AngleY_Check \
	Object_Check\
	CASE_STR(Time) { time = atts[++i]; break; }\
	CASE_STR(Start) { start = atts[++i]; break; }\
	CASE_STR(Stop) { stop = atts[++i]; break; }\
	CASE_STR(Ease) { ease = atts[++i]; break; }
#define AngleY_Create
#define AngleY_Handle \
	oFunc func = {string("AngleY(")+toVal(time,"0")+","+Val(start)+","+Val(stop)+(ease ? string(",")+toEase(ease) : "")+")",""};\
	funcs.push(func);
#define AngleY_Finish

// Opacity
#define Opacity_Define \
	Object_Define\
	const char* time = nullptr;\
	const char* start = nullptr;\
	const char* stop = nullptr;\
	const char* ease = nullptr;
#define Opacity_Check \
	Object_Check\
	CASE_STR(Time) { time = atts[++i]; break; }\
	CASE_STR(Start) { start = atts[++i]; break; }\
	CASE_STR(Stop) { stop = atts[++i]; break; }\
	CASE_STR(Ease) { ease = atts[++i]; break; }
#define Opacity_Create
#define Opacity_Handle \
	oFunc func = {string("Opacity(")+toVal(time,"0")+","+Val(start)+","+Val(stop)+(ease ? string(",")+toEase(ease) : "")+")",""};\
	funcs.push(func);
#define Opacity_Finish

// SkewX
#define SkewX_Define \
	Object_Define\
	const char* time = nullptr;\
	const char* start = nullptr;\
	const char* stop = nullptr;\
	const char* ease = nullptr;
#define SkewX_Check \
	Object_Check\
	CASE_STR(Time) { time = atts[++i]; break; }\
	CASE_STR(Start) { start = atts[++i]; break; }\
	CASE_STR(Stop) { stop = atts[++i]; break; }\
	CASE_STR(Ease) { ease = atts[++i]; break; }
#define SkewX_Create
#define SkewX_Handle \
	oFunc func = {string("SkewX(")+toVal(time,"0")+","+Val(start)+","+Val(stop)+(ease ? string(",")+toEase(ease) : "")+")",""};\
	funcs.push(func);
#define SkewX_Finish

// SkewY
#define SkewY_Define \
	Object_Define\
	const char* time = nullptr;\
	const char* start = nullptr;\
	const char* stop = nullptr;\
	const char* ease = nullptr;
#define SkewY_Check \
	Object_Check\
	CASE_STR(Time) { time = atts[++i]; break; }\
	CASE_STR(Start) { start = atts[++i]; break; }\
	CASE_STR(Stop) { stop = atts[++i]; break; }\
	CASE_STR(Ease) { ease = atts[++i]; break; }
#define SkewY_Create
#define SkewY_Handle \
	oFunc func = {string("SkewY(")+toVal(time,"0")+","+Val(start)+","+Val(stop)+(ease ? string(",")+toEase(ease) : "")+")",""};\
	funcs.push(func);
#define SkewY_Finish

// Show
#define Show_Define \
	Object_Define
#define Show_Check \
	Object_Check
#define Show_Create
#define Show_Handle \
	oFunc func = {"Show()",""};\
	funcs.push(func);
#define Show_Finish

// Hide
#define Hide_Define \
	Object_Define
#define Hide_Check \
	Object_Check
#define Hide_Create
#define Hide_Handle \
	oFunc func = {"Hide()",""};\
	funcs.push(func);
#define Hide_Finish

// Call
#define Call_Define \
	Object_Define
#define Call_Check \
	Object_Check
#define Call_Create
#define Call_Handle \
	oFunc func = {"Call(",")"};\
	funcs.push(func);
#define Call_Finish

// Sequence
#define Sequence_Define \
	Object_Define
#define Sequence_Check \
	Object_Check
#define Sequence_Create
#define Sequence_Handle \
	items.push("Sequence");
#define Sequence_Finish

// Spawn
#define Spawn_Define \
	Object_Define
#define Spawn_Check \
	Object_Check
#define Spawn_Create
#define Spawn_Handle \
	items.push("Spawn");
#define Spawn_Finish

#define Add_To_Parent \
	if (!elementStack.empty()) {\
		const oItem& parent = elementStack.top();\
		if (!parent.name.empty())\
		{\
			stream << parent.name << ":addChild(" << self << ")\n";\
			if (hasSelf && ref)\
			{\
				stream << firstItem << "." << self << " = " << self << "\n";\
			}\
			stream << "\n";\
		}\
		else if (strcmp(parent.type,"Stencil") == 0)\
		{\
			elementStack.pop();\
			if (!elementStack.empty())\
			{\
				const oItem& newParent = elementStack.top();\
				stream << newParent.name << ".stencil = " << self << "\n\n";\
			}\
		}\
	}\
	else stream << "\n";

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
	const char* color = nullptr;\
	const char* opacity = nullptr;\
	const char* angle = nullptr;\
	const char* angleX = nullptr;\
	const char* angleY = nullptr;\
	const char* scaleX = nullptr;\
	const char* scaleY = nullptr;\
	const char* scheduler = nullptr;\
	const char* skewX = nullptr;\
	const char* skewY = nullptr;\
	const char* order = nullptr;\
	const char* tag = nullptr;\
	const char* transformTarget = nullptr;\
	const char* visible = nullptr;\
	const char* touchEnabled = nullptr;\
	const char* swallowTouches = nullptr;
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
	CASE_STR(Color) { color = atts[++i]; break; }\
	CASE_STR(Opacity) { opacity = atts[++i]; break; }\
	CASE_STR(Angle) { angle = atts[++i]; break; }\
	CASE_STR(AngleX) { angleX = atts[++i]; break; }\
	CASE_STR(AngleY) { angleY = atts[++i]; break; }\
	CASE_STR(ScaleX) { scaleX = atts[++i]; break; }\
	CASE_STR(ScaleY) { scaleY = atts[++i]; break; }\
	CASE_STR(Scheduler) { scheduler = atts[++i]; break; }\
	CASE_STR(SkewX) { skewX = atts[++i]; break; }\
	CASE_STR(SkewY) { skewY = atts[++i]; break; }\
	CASE_STR(Order) { order = atts[++i]; break; }\
	CASE_STR(Tag) { tag = atts[++i]; break; }\
	CASE_STR(TransformTarget) { transformTarget = atts[++i]; break; }\
	CASE_STR(Visible) { visible = atts[++i]; break; }\
	CASE_STR(TouchEnabled) { touchEnabled = atts[++i]; break; }\
	CASE_STR(SwallowTouches) { swallowTouches = atts[++i]; break; }
#define Node_Create \
	stream << "local " << self << " = Node()\n";
#define Node_Handle \
	if (anchorX && anchorY) stream << self << ".anchor = Vec2(" << Val(anchorX) << ',' << Val(anchorY) << ")\n";\
	else if (anchorX && !anchorY) stream << self << ".anchor = Vec2(" << Val(anchorX) << ',' << self << ".anchor.y)\n";\
	else if (!anchorX && anchorY) stream << self << ".anchor = Vec2(" << self << ".anchor.x," << Val(anchorY) << ")\n";\
	if (x) stream << self << ".x = " << Val(x) << '\n';\
	if (y) stream << self << ".y = " << Val(y) << '\n';\
	if (z) stream << self << ".z = " << Val(z) << '\n';\
	if (passColor) stream << self << ".passColor = " << toBoolean(passColor) << '\n';\
	if (passOpacity) stream << self << ".passOpacity = " << toBoolean(passOpacity) << '\n';\
	if (color) stream << self << ".color3 = Color3(" << Val(color) << ")\n";\
	if (opacity) stream << self << ".opacity = " << Val(opacity) << '\n';\
	if (angle) stream << self << ".angle = " << Val(angle) << '\n';\
	if (angleX) stream << self << ".angleX = " << Val(angleX) << '\n';\
	if (angleY) stream << self << ".angleY = " << Val(angleY) << '\n';\
	if (scaleX) stream << self << ".scaleX = " << Val(scaleX) << '\n';\
	if (scaleY) stream << self << ".scaleY = " << Val(scaleY) << '\n';\
	if (scheduler) stream << self << ".scheduler = " << Val(scheduler) << '\n';\
	if (skewX) stream << self << ".skewX = " << Val(skewX) << '\n';\
	if (skewY) stream << self << ".skewY = " << Val(skewY) << '\n';\
	if (transformTarget) stream << self << ".transformTarget = " << Val(transformTarget) << '\n';\
	if (visible) stream << self << ".visible = " << toBoolean(visible) << '\n';\
	if (order) stream << self << ".order = " << Val(order) << '\n';\
	if (tag) stream << self << ".tag = " << toText(tag) << '\n';\
	if (width && height) stream << self << ".size = Size(" << Val(width) << ',' << Val(height) << ")\n";\
	else if (width && !height) stream << self << ".width = " << Val(width) << '\n';\
	else if (!width && height) stream << self << ".height = " << Val(height) << '\n';\
	if (touchEnabled) stream << self << ".touchEnabled = " << toBoolean(touchEnabled) << '\n';\
	if (swallowTouches) stream << self << ".swallowTouches = " << toBoolean(swallowTouches) << '\n';
#define Node_Finish \
	Add_To_Parent

// DrawNode
#define DrawNode_Define \
	Node_Define
#define DrawNode_Check \
	Node_Check
#define DrawNode_Create \
	stream << "local " << self << " = DrawNode()\n";
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
		stream << elementStack.top().name <<\
		":drawDot(Vec2(" << toVal(x,"0") << ',' << toVal(y,"0") << ")," <<\
		toVal(radius,"0.5") << ",Color(" << Val(color) << "))\n\n";\
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
		oFunc func = {elementStack.top().name+":drawPolygon({",\
		string("},Color(")+Val(fillColor)+"),"+toVal(borderWidth,"0")+",Color("+toVal(borderColor,"")+"))\n\n"};\
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
		stream << elementStack.top().name <<\
		":drawSegment(Vec2(" << toVal(beginX,"0") << ',' << toVal(beginY,"0") << "),Vec2(" <<\
		toVal(endX,"0") << ',' << toVal(endY,"0") << ")," << toVal(radius,"0.5") << ",Color(" << toVal(color,"") << "))\n\n";\
	}

// Line
#define Line_Define \
	Node_Define
#define Line_Check \
	Node_Check
#define Line_Create \
	stream << "local " << self << " = Line()\n";
#define Line_Handle \
	Node_Handle
#define Line_Finish \
	Add_To_Parent\
	oFunc func = {string(self)+":set({","},Color(0xffffffff))\n"};\
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
	stream << "local " << self << " = ClipNode()\n";
#define ClipNode_Handle \
	Node_Handle\
	if (alphaThreshold) stream << self << ".alphaThreshold = " << Val(alphaThreshold) << '\n';\
	if (inverted) stream << self << ".inverted = " << toBoolean(inverted) << '\n';
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
	stream << "local " << self << " = Label(" << toText(fontName) << ',' << Val(fontSize) << ")\n";
#define Label_Handle \
	Node_Handle\
	if (text && text[0]) stream << self << ".text = " << toText(text) << '\n';\
	if (alignment) stream << self << ".alignment = " << toTextAlign(alignment) << '\n';\
	if (textWidth) stream << self << ".textWidth = " << (strcmp(textWidth,"Auto")==0 ? "Label.AutomaticWidth" : Val(textWidth)) << '\n';\
	if (lineGap) stream << self << ".lineGap = " << Val(lineGap) << '\n';
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
	stream << "local " << self << " = Sprite(";\
	if (file) stream << toText(file) << ")\n";\
	else stream << ")\n";
#define Sprite_Handle \
	Node_Handle\
	if (blendSrc && blendDst) stream << self << ".blendFunc = BlendFunc("\
									<< toBlendFunc(blendSrc) << "," << toBlendFunc(blendDst) << ")\n";\
	else if (blendSrc && !blendDst) stream << self << ".blendFunc = BlendFunc("\
									<< toBlendFunc(blendSrc) << ',' << self << ".blendFunc.dst)\n";\
	else if (!blendSrc && blendDst) stream << self << ".blendFunc = BlendFunc(" << self\
									<< ".blendFunc.src," << toBlendFunc(blendDst) << ")\n";
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
	stream << "local " << self << " = Model(" << toText(filename) << ")\n";
#define Model_Handle \
	Node_Handle\
	if (look) stream << self << ".look = \"" << Val(look) << "\"\n";\
	if (loop) stream << self << ".loop = " << toBoolean(loop) << '\n';\
	if (reversed) stream << self << ".reversed = " << toBoolean(reversed) << '\n';\
	if (faceRight) stream << self << ".faceRight = " << toBoolean(faceRight) << '\n';\
	if (speed) stream << self << ".speed = " << Val(speed) << '\n';\
	if (play) stream << self << ":play(\"" << Val(play) << "\")\n";
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
	stream << "local " << self << " = Menu()\n";
#define Menu_Handle \
	Node_Handle\
	if (enabled) stream << self << ".enabled = " << toBoolean(enabled) << '\n';
#define Menu_Finish \
	Add_To_Parent

// ModuleNode
#define ModuleNode_Define \
	Object_Define
#define ModuleNode_Check \
	Object_Check\
	default: { int index = i;attributes[atts[index]] = atts[++i]; break; }
#define ModuleNode_Create \
	stream << "local " << self << " = " << element << "{";
#define ModuleNode_Handle \
	auto it = attributes.begin();\
	while (it != attributes.end())\
	{\
		stream << (char)tolower(it->first[0]) << it->first.substr(1) << " = ";\
		char* p;\
		strtod(it->second.c_str(), &p);\
		if (*p == 0) stream << it->second;\
		else stream << toText(it->second.c_str());\
		++it;\
		if (it != attributes.end())\
		{\
			stream << ", ";\
		}\
	}\
	attributes.clear();\
	stream << "}\n";
#define ModuleNode_Finish \
	if (!elementStack.empty())\
	{\
		const oItem& parent = elementStack.top();\
		if (!parent.name.empty())\
		{\
			stream << parent.name << ":addChild(" << self << ")\n";\
			if (hasSelf && ref)\
			{\
				stream << firstItem << "." << self << " = " << self << "\n";\
			}\
			stream << "\n";\
		}\
		else if (strcmp(parent.type,"Stencil") == 0)\
		{\
			elementStack.pop();\
			if (!elementStack.empty())\
			{\
				const oItem& newParent = elementStack.top();\
				stream << newParent.name << ".stencil = " << self << "\n\n";\
			}\
		}\
	}\
	else stream << "\n";

// Import
#define Import_Define \
	const char* module = nullptr;\
	const char* name = nullptr;
#define Import_Check \
	CASE_STR(Module) { module = atts[++i]; break; }\
	CASE_STR(Name) { name = atts[++i]; break; }
#define Import_Create \
	if (module) {\
		string mod(module);\
		size_t pos = mod.rfind('.');\
		string modStr = (name ? name : (pos == string::npos ? string(module) : mod.substr(pos+1)));\
		imported.insert(modStr);\
		requires << "local " << modStr << " = require(\"" << module << "\")\n";}

// Item
#define NodeItem_Define \
	const char* name = nullptr;
#define NodeItem_Check \
	CASE_STR(Name) { name = atts[++i]; break; }
#define NodeItem_Create \
	stream << "local " << Val(name) << " = " << elementStack.top().name << '.' << Val(name) << "\n\n";\
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
	const char* target = nullptr;
#define Slot_Check \
	CASE_STR(Name) { name = atts[++i]; break; }\
	CASE_STR(Args) { args = atts[++i]; break; }\
	CASE_STR(Target) { target = atts[++i]; break; }\
	CASE_STR(Perform) { perform = atts[++i]; break; }
#define Slot_Create \
	oFunc func = {elementStack.top().name+":slot("+toText(name)+",function("+(args ? args : "")+")"+(perform ? string("\n")+(target ? string(target) : elementStack.top().name)+":perform("+perform+")\n" : Slice::Empty), "end)"};\
	funcs.push(func);

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
	codes(nullptr),
	parser(parser)
	{ }
	virtual void startElement(const char* name, const char** atts);
	virtual void endElement(const char* name);
	virtual void textHandler(const char* s, int len);
	string oVal(const char* value, const char* def = nullptr, const char* element = nullptr, const char* attr = nullptr);
public:
	void clear()
	{
		codes = nullptr;
		for (; !elementStack.empty(); elementStack.pop());
		for (; !funcs.empty(); funcs.pop());
		for (; !items.empty(); items.pop());
		stream.clear();
		requires.clear();
		names.clear();
		imported.clear();
		firstItem.clear();
		lastError.clear();
	}
	void begin()
	{
		XmlDelegator::clear();
		stream <<
		"return function(args)\n"
		"Dorothy(args)\n\n";
	}
	void end()
	{
		stream << "return " << firstItem << "\nend";
	}
	string getResult()
	{
		if (lastError.empty())
		{
			string requireStr = requires.str();
			return requireStr + (requireStr.empty() ? "" : "\n") + stream.str();
		}
		return string();
	}
	const string& getLastError()
	{
		return lastError;
	}
private:
	string getUsableName(const char* baseName)
	{
		int index = 1;
		string base(baseName);
		string name;
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
		string name;
		bool ref;
	};
	struct oFunc
	{
		string begin;
		string end;
	};
	SAXParser* parser;
	// Script
	const char* codes;
	// Loader
	string firstItem;
	string lastError;
	stack<oFunc> funcs;
	stack<string> items;
	stack<oItem> elementStack;
	unordered_set<string> names;
	unordered_set<string> imported;
	unordered_map<string, string> attributes;
	fmt::MemoryWriter stream;
	fmt::MemoryWriter requires;
};

string XmlDelegator::oVal(const char* value, const char* def, const char* element, const char* attr)
{
	if (!value || !value[0])
	{
		if (def) return string(def);
		else if (attr && element)
		{
			string num = fmt::format("%d", parser->getLineNumber(element));
			lastError += string("Missing attribute ") + (char)toupper(attr[0]) + string(attr).substr(1) + " for " + element + ", at line " + num + "\n";
		}
		return string();
	}
	if (value[0] == '{')
	{
		string valStr(value);
		if (valStr.back() != '}') return valStr;
		size_t start = 1;
		for (; valStr[start] == ' ' || valStr[start] == '\t'; ++start);
		size_t end = valStr.size() - 2;
		for (; valStr[end] == ' ' || valStr[end] == '\t'; --end);
		if (end < start)
		{
			if (attr && element)
			{
				string num = fmt::format("%d", parser->getLineNumber(element));
				lastError += string("Missing attribute ") + (char)toupper(attr[0]) + string(attr).substr(1) + " for " + element + ", at line " + num + "\n";
			}
			return string();
		}
		valStr = valStr.substr(start, end - start + 1);
		string newStr;
		start = 0;
		size_t i = 0;
		while (i < valStr.size())
		{
			if ((valStr[i] == '$' || valStr[i] == '@') && i < valStr.size() - 1)
			{
				if (valStr[i] == '$')
				{
					string parent;
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
						string num = fmt::format("%d", parser->getLineNumber(element));
						lastError += string("The $ expression can`t be used in tag at line ") + num + "\n";
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
							string num = fmt::format("%d", parser->getLineNumber(element));
							lastError += string("Invalid expression $") + valStr[i] + " at line " + num + "\n";
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
							string num = fmt::format("%d", parser->getLineNumber(element));
							lastError += string("Invalid expression @") + valStr[i] + " at line " + num + "\n";
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
	else return string(value);
}

void XmlDelegator::startElement(const char* element, const char** atts)
{
	SWITCH_STR_START(element)
	{
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
		Item(Call, call)

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
			stream << (codes ? codes : "") << '\n';
			codes = nullptr;
			break;
		}
		CASE_STR(Call)
		{
			oFunc func = funcs.top();
			funcs.pop();
			string tempItem = func.begin + "function()\n" + (codes ? codes : "") + "\nend" + func.end;
			if (parentIsAction)
			{
				stream << "local " << currentData.name << " = " << tempItem << '\n';
			}
			else
			{
				items.push(tempItem);
				auto it = names.find(currentData.name);
				if (it != names.end()) names.erase(it);
			}
			break;
		}
		CASE_STR(Slot)
		{
			oFunc func = funcs.top();
			funcs.pop();
			stream << func.begin << (codes ? codes : "") << func.end << '\n';
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
		{
			oFunc func = funcs.top();
			funcs.pop();
			if (parentIsAction)
			{
				stream << "local " << currentData.name << " = " << func.begin << '\n';
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
			string tempItem = string(name) + "(";
			stack<string> tempStack;
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
				stream << "local " << currentData.name << " = " << tempItem << '\n';
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
			stream << func.begin;
			stack<string> tempStack;
			while (items.top() != name)
			{
				tempStack.push(items.top());
				items.pop();
			}
			items.pop();
			while (!tempStack.empty())
			{
				stream << tempStack.top();
				tempStack.pop();
				if (!tempStack.empty()) stream << ',';
			}
			stream << func.end;
			break;
		}
		CASE_STR(Action)
		{
			stream << "\n";
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
				string num = fmt::format("%d", parser->getLineNumber(name));
				lastError += string("Tag <") + name + "> not imported, closed at line " + num + "\n";
			}
			break;
		}
	}
	SWITCH_STR_END

	if (parentIsAction && currentData.ref)
	{
		stream << firstItem << '.' << currentData.name << " = " << currentData.name << "\n";
	}
}

void XmlDelegator::textHandler(const char* s, int len)
{
	codes = s;
}

XmlLoader::XmlLoader():_delegator(new XmlDelegator(&_parser))
{
	_parser.setDelegator(_delegator);
}

XmlLoader::~XmlLoader()
{ }

string XmlLoader::load(String filename)
{
	_delegator->begin();
	SAXParser::setHeaderHandler(Handler);
	bool result = _parser.parse(filename);
	SAXParser::setHeaderHandler(nullptr);
	_delegator->end();
	return result ? _delegator->getResult() : string();
}

string XmlLoader::loadXml(String xml)
{
	_delegator->begin();
	SAXParser::setHeaderHandler(Handler);
	bool result = _parser.parseXml(xml);
	SAXParser::setHeaderHandler(nullptr);
	_delegator->end();
	return result ? _delegator->getResult() : string();
}

string XmlLoader::getLastError()
{
	const string& parserError = _parser.getLastError();
	const string& dorothyError = _delegator->getLastError();
	if (parserError.empty() && !dorothyError.empty())
	{
		return string("Xml document error\n") + dorothyError;
	}
	return parserError + dorothyError;
}

NS_DOROTHY_END
