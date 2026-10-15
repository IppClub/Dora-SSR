/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Node/AlignNode.h"

#include "Basic/Application.h"

#include "yoga/Yoga.h"

#include <charconv>
#include <map>
#include <ranges>
#include <string_view>
#include <system_error>

NS_DORA_BEGIN

static std::map<std::string_view, std::string_view> parseCssStyle(std::string_view css) {
	std::map<std::string_view, std::string_view> styles;
	auto pairs = css | std::ranges::views::split(';');
	for (auto&& pair : pairs) {
		auto keyValue = pair | std::ranges::views::split(':') | std::ranges::views::transform([](auto&& range) {
			return Slice{&*range.begin(), s_cast<size_t>(std::ranges::distance(range))}.trimSpace().toView();
		});
		auto it = keyValue.begin();
		if (it != keyValue.end()) {
			std::string_view key = *it;
			++it;
			if (it != keyValue.end()) {
				std::string_view value = *it;
				styles[key] = value;
			}
		}
	}
	return styles;
}

std::optional<YGDirection> mapDirection(std::string_view dir) {
	switch (Switch::hash(dir)) {
		case "ltr"_hash: return YGDirectionLTR;
		case "rtl"_hash: return YGDirectionRTL;
		case "inherit"_hash: return YGDirectionInherit;
	}
	Warn("invalid CSS Direction: \"{}\", should be one of \"ltr\", \"rtl\" and \"inherit\"", dir);
	return std::nullopt;
}

std::optional<YGAlign> mapAlign(std::string_view align) {
	switch (Switch::hash(align)) {
		case "flex-start"_hash: return YGAlignFlexStart;
		case "center"_hash: return YGAlignCenter;
		case "flex-end"_hash: return YGAlignFlexEnd;
		case "stretch"_hash: return YGAlignStretch;
		case "auto"_hash: return YGAlignAuto;
	}
	Warn("invalid CSS Align: \"{}\", should be one of \"flex-start\", \"center\", \"flex-end\", \"stretch\" and \"auto\"", align);
	return std::nullopt;
}

std::optional<YGFlexDirection> mapFlexDirection(std::string_view flexDirection) {
	switch (Switch::hash(flexDirection)) {
		case "column"_hash: return YGFlexDirectionColumn;
		case "row"_hash: return YGFlexDirectionRow;
		case "column-reverse"_hash: return YGFlexDirectionColumnReverse;
		case "row-reverse"_hash: return YGFlexDirectionRowReverse;
	}
	Warn("invalid CSS FlexDirection: \"{}\", should be one of \"column\", \"row\", \"column-reverse\" and \"row-reverse\"", flexDirection);
	return std::nullopt;
}

std::optional<YGJustify> mapJustifyContent(std::string_view justifyContent) {
	switch (Switch::hash(justifyContent)) {
		case "flex-start"_hash: return YGJustifyFlexStart;
		case "center"_hash: return YGJustifyCenter;
		case "flex-end"_hash: return YGJustifyFlexEnd;
		case "space-between"_hash: return YGJustifySpaceBetween;
		case "space-around"_hash: return YGJustifySpaceAround;
		case "space-evenly"_hash: return YGJustifySpaceEvenly;
	}
	Warn("invalid CSS JustifyContent: \"{}\", should be one of \"flex-start\", \"center\", \"flex-end\", \"space-between\", \"space-around\" and \"space-evenly\"", justifyContent);
	return std::nullopt;
}

std::optional<YGPositionType> mapPositionType(std::string_view positionType) {
	switch (Switch::hash(positionType)) {
		case "absolute"_hash: return YGPositionTypeAbsolute;
		case "relative"_hash: return YGPositionTypeRelative;
		case "static"_hash: return YGPositionTypeStatic;
	}
	Warn("invalid CSS PositionType: \"{}\", should be one of \"absolute\", \"relative\" and \"static\"", positionType);
	return std::nullopt;
}

std::optional<YGWrap> mapWrap(std::string_view wrap) {
	switch (Switch::hash(wrap)) {
		case "nowrap"_hash: return YGWrapNoWrap;
		case "wrap"_hash: return YGWrapWrap;
		case "wrap-reverse"_hash: return YGWrapWrapReverse;
	}
	Warn("invalid CSS Wrap: \"{}\", should be one of \"no-wrap\", \"wrap\" and \"wrap-reverse\"", wrap);
	return std::nullopt;
}

std::optional<YGOverflow> mapOverflow(std::string_view overflow) {
	switch (Switch::hash(overflow)) {
		case "visible"_hash: return YGOverflowVisible;
		case "hidden"_hash: return YGOverflowHidden;
		case "scroll"_hash: return YGOverflowScroll;
	}
	Warn("invalid CSS Overflow: \"{}\", should be one of \"visible\", \"hidden\" and \"scroll\"", overflow);
	return std::nullopt;
}

std::optional<YGDisplay> mapDisplay(std::string_view display) {
	switch (Switch::hash(display)) {
		case "flex"_hash: return YGDisplayFlex;
		case "none"_hash: return YGDisplayNone;
		case "contents"_hash: return YGDisplayContents;
	}
	Warn("invalid CSS Display: \"{}\", should be one of \"flex\", \"none\" and \"contents\"", display);
	return std::nullopt;
}

std::optional<YGBoxSizing> mapBoxSizing(std::string_view boxSizing) {
	switch (Switch::hash(boxSizing)) {
		case "border-box"_hash: return YGBoxSizingBorderBox;
		case "content-box"_hash: return YGBoxSizingContentBox;
	}
	Warn("invalid CSS BoxSizing: \"{}\", should be one of \"border-box\" and \"content-box\"", boxSizing);
	return std::nullopt;
}

static std::optional<float> safeStringToFloat(std::string_view str) {
	try {
		std::string strValue(str);
		return std::stof(strValue);
	} catch (const std::invalid_argument&) {
		return std::nullopt;
	} catch (const std::out_of_range&) {
		return std::nullopt;
	}
	return std::nullopt;
}

enum class CSSValue {
	Number,
	Percentage,
	Auto
};

static std::vector<std::pair<CSSValue, float>> parseCommaSeparatedValues(std::string_view values, bool allowPercent = false, bool allowAuto = false) {
	std::vector<std::pair<CSSValue, float>> result;
	auto parts = values | std::ranges::views::split(',');
	for (auto&& part : parts) {
		auto partStr = Slice{&*part.begin(), static_cast<size_t>(std::ranges::distance(part))}.trimSpace();
		if (allowAuto && partStr == "auto") {
			result.push_back({CSSValue::Auto, 0});
		} else if (allowPercent && !partStr.empty() && partStr.back() == '%') {
			std::string str(partStr);
			if (auto num = safeStringToFloat(str)) {
				result.push_back({CSSValue::Percentage, num.value()});
			} else {
				return {};
			}
		} else {
			std::string str(partStr);
			if (auto num = safeStringToFloat(str)) {
				result.push_back({CSSValue::Number, num.value()});
			} else {
				return {};
			}
		}
	}
	return result;
}

static void setEdges(YGNodeRef node, const std::vector<std::pair<CSSValue, float>>& values, void (*setter)(YGNodeRef, YGEdge, float), void (*percentSetter)(YGNodeRef, YGEdge, float) = nullptr, void (*autoSetter)(YGNodeRef, YGEdge) = nullptr) {
	auto setValue = [&](YGEdge edge, const std::pair<CSSValue, float>& value) {
		switch (value.first) {
			case CSSValue::Number: setter(node, edge, value.second); break;
			case CSSValue::Percentage: percentSetter(node, edge, value.second); break;
			case CSSValue::Auto: autoSetter(node, edge); break;
			default: break;
		}
	};
	switch (values.size()) {
		case 1:
			// 单个值，设置所有四个边
			setValue(YGEdgeAll, values[0]);
			break;
		case 2:
			// 两个值，垂直和水平
			setValue(YGEdgeVertical, values[0]);
			setValue(YGEdgeHorizontal, values[1]);
			break;
		case 3:
			// 三个值，上，水平，下
			setValue(YGEdgeTop, values[0]);
			setValue(YGEdgeHorizontal, values[1]);
			setValue(YGEdgeBottom, values[2]);
			break;
		case 4:
			// 四个值，上，右，下，左
			setValue(YGEdgeTop, values[0]);
			setValue(YGEdgeRight, values[1]);
			setValue(YGEdgeBottom, values[2]);
			setValue(YGEdgeLeft, values[3]);
			break;
		default:
			Warn("invalid number of edge values in CSS, should be 1 for all, 2 for vertical and horizontal, 3 for top, horizontal and bottom, 4 for top, right, bottom and left.");
			break;
	}
}

void setGap(YGNodeRef node, const std::vector<std::pair<CSSValue, float>>& values) {
	auto setValue = [&](YGGutter gutter, const std::pair<CSSValue, float>& value) {
		switch (value.first) {
			case CSSValue::Number:
				YGNodeStyleSetGap(node, gutter, value.second);
				break;
			case CSSValue::Percentage:
				YGNodeStyleSetGapPercent(node, gutter, value.second);
				break;
			default: break;
		}
	};
	switch (values.size()) {
		case 1:
			// 单个值，应用到所有 gutter
			setValue(YGGutterAll, values[0]);
			break;
		case 2:
			// 两个值，依次为行和列
			setValue(YGGutterRow, values[0]);
			setValue(YGGutterColumn, values[1]);
			break;
		default:
			Warn("invalid number of gap values in CSS, should be 1 for all, 2 for row and column.");
			break;
	}
}

AlignNode::AlignNode(bool isWindowRoot) {
	if (isWindowRoot) {
		setSize(SharedApplication.getVisualSize());
		float scale = SharedApplication.getDevicePixelRatio();
		setScaleX(scale);
		setScaleY(scale);
		gslot("AppChange"_slice, [this](Event* e) {
			std::string settingName;
			if (!e->get(settingName)) return;
			if (settingName != "Size"sv) return;
			setSize(SharedApplication.getVisualSize());
			float scale = SharedApplication.getDevicePixelRatio();
			setScaleX(scale);
			setScaleY(scale);
			YGNodeStyleSetWidth(_yogaNode, getWidth());
			YGNodeStyleSetHeight(_yogaNode, getHeight());
			YGNodeCalculateLayout(_yogaNode, YGUndefined, YGUndefined, YGDirectionLTR);
			alignLayout();
		});
	}
}

bool AlignNode::init() {
	if (!Node::init()) return false;
	_yogaNode = YGNodeNewWithConfig(getConfig());
	YGNodeSetContext(_yogaNode, this);
	if (getWidth() > 0.0f) {
		YGNodeStyleSetWidth(_yogaNode, getWidth());
	}
	if (getHeight() > 0.0f) {
		YGNodeStyleSetHeight(_yogaNode, getHeight());
	}
	return true;
}

void AlignNode::addChild(Node* child, int order, String tag) {
	AssertUnless(_yogaNode, "Yoga node is destroyed");
	if (auto alignChild = DoraAs<AlignNode>(child)) {
		if (!YGNodeGetParent(alignChild->_yogaNode)) {
			YGNodeInsertChild(_yogaNode, alignChild->_yogaNode, YGNodeGetChildCount(_yogaNode));
		}
	}
	Node::addChild(child, order, tag);
}

void AlignNode::removeChild(Node* child, bool cleanup) {
	AssertUnless(_yogaNode, "Yoga node is destroyed");
	if (auto alignChild = DoraAs<AlignNode>(child)) {
		YGNodeRemoveChild(_yogaNode, alignChild->_yogaNode);
	}
	Node::removeChild(child, cleanup);
}

void AlignNode::cleanup() {
	if (_flags.isOff(Node::Cleanup)) {
		Node::cleanup();
		YGNodeFree(_yogaNode);
		_yogaNode = nullptr;
	}
}

void AlignNode::alignLayout() {
	AssertUnless(_yogaNode, "Yoga node is destroyed");
	if (!YGNodeGetHasNewLayout(_yogaNode)) {
		return;
	}
	YGNodeSetHasNewLayout(_yogaNode, false);
	Size newSize{YGNodeLayoutGetWidth(_yogaNode), YGNodeLayoutGetHeight(_yogaNode)};
	if (getSize() != newSize) {
		setSize(newSize);
		ARRAY_START(Node, child, _children) {
			if (auto alignChild = DoraAs<AlignNode>(child)) {
				alignChild->setX(YGNodeLayoutGetLeft(alignChild->_yogaNode) + alignChild->getWidth() / 2.0f);
				alignChild->setY(getHeight() - (YGNodeLayoutGetTop(alignChild->_yogaNode) + alignChild->getHeight() / 2.0f));
			}
		}
		ARRAY_END
	}
	if (YGNodeGetParent(_yogaNode)) {
		setX(YGNodeLayoutGetLeft(_yogaNode) + getWidth() / 2.0f);
		setY(_parent->getHeight() - (YGNodeLayoutGetTop(_yogaNode) + getHeight() / 2.0f));
	}
	emit("AlignLayout"_slice, getWidth(), getHeight());
	for (size_t i = 0; i < YGNodeGetChildCount(_yogaNode); i++) {
		auto child = YGNodeGetChild(_yogaNode, i);
		auto node = r_cast<AlignNode*>(YGNodeGetContext(child));
		node->alignLayout();
	}
}

void AlignNode::visit() {
	AssertUnless(_yogaNode, "Yoga node is destroyed");
	if (YGNodeIsDirty(_yogaNode)) {
		YGNodeCalculateLayout(_yogaNode, YGUndefined, YGUndefined, YGDirectionLTR);
	}
	alignLayout();
	Node::visit();
}

void AlignNode::css(String css) {
	AssertUnless(_yogaNode, "Yoga node is destroyed");
	auto styles = parseCssStyle(css.toView());
	for (const auto& [key, value] : styles) {
		switch (Switch::hash(key)) {
			case "direction"_hash: {
				if (auto var = mapDirection(value)) {
					YGNodeStyleSetDirection(_yogaNode, var.value());
				}
				break;
			}
			case "align-content"_hash: {
				if (auto var = mapAlign(value)) {
					YGNodeStyleSetAlignContent(_yogaNode, var.value());
				}
				break;
			}
			case "align-items"_hash: {
				if (auto var = mapAlign(value)) {
					YGNodeStyleSetAlignItems(_yogaNode, var.value());
				}
				break;
			}
			case "align-self"_hash: {
				if (auto var = mapAlign(value)) {
					YGNodeStyleSetAlignSelf(_yogaNode, var.value());
				}
				break;
			}
			case "flex-direction"_hash: {
				if (auto var = mapFlexDirection(value)) {
					YGNodeStyleSetFlexDirection(_yogaNode, var.value());
				}
				break;
			}
			case "justify-content"_hash: {
				if (auto var = mapJustifyContent(value)) {
					YGNodeStyleSetJustifyContent(_yogaNode, var.value());
				}
				break;
			}
			case "flex-wrap"_hash: {
				if (auto var = mapWrap(value)) {
					YGNodeStyleSetFlexWrap(_yogaNode, var.value());
				}
				break;
			}
			case "flex"_hash: {
				if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetFlex(_yogaNode, num.value());
				} else {
					Warn("invalid CSS Flex: \"{}\", should be a number", value);
				}
				break;
			}
			case "flex-basis"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetFlexBasisPercent(_yogaNode, num.value());
					}
				} else if (value == "auto") {
					YGNodeStyleSetFlexBasisAuto(_yogaNode);
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetFlexBasis(_yogaNode, num.value());
				} else {
					Warn("invalid CSS FlexBasis: \"{}\", should be a number, a percentage or auto", value);
				}
				break;
			}
			case "flex-grow"_hash: {
				if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetFlexGrow(_yogaNode, num.value());
				} else {
					Warn("invalid CSS FlexGrow: \"{}\", should be a number", value);
				}
				break;
			}
			case "flex-shrink"_hash: {
				if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetFlexShrink(_yogaNode, num.value());
				} else {
					Warn("invalid CSS FlexShrink: \"{}\", should be a number", value);
				}
				break;
			}
			case "left"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetPositionPercent(_yogaNode, YGEdgeLeft, num.value());
					}
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetPosition(_yogaNode, YGEdgeLeft, num.value());
				} else {
					Warn("invalid CSS Left: \"{}\", should be a number or a percentage", value);
				}
				break;
			}
			case "top"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetPositionPercent(_yogaNode, YGEdgeTop, num.value());
					}
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetPosition(_yogaNode, YGEdgeTop, num.value());
				} else {
					Warn("invalid CSS Top: \"{}\", should be a number or a percentage", value);
				}
				break;
			}
			case "right"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetPositionPercent(_yogaNode, YGEdgeRight, num.value());
					}
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetPosition(_yogaNode, YGEdgeRight, num.value());
				} else {
					Warn("invalid CSS Right: \"{}\", should be a number or a percentage", value);
				}
				break;
			}
			case "bottom"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetPositionPercent(_yogaNode, YGEdgeBottom, num.value());
					}
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetPosition(_yogaNode, YGEdgeBottom, num.value());
				} else {
					Warn("invalid CSS Bottom: \"{}\", should be a number or a percentage", value);
				}
				break;
			}
			case "start"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetPositionPercent(_yogaNode, YGEdgeStart, num.value());
					}
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetPosition(_yogaNode, YGEdgeStart, num.value());
				} else {
					Warn("invalid CSS Start: \"{}\", should be a number or a percentage", value);
				}
				break;
			}
			case "end"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetPositionPercent(_yogaNode, YGEdgeEnd, num.value());
					}
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetPosition(_yogaNode, YGEdgeEnd, num.value());
				} else {
					Warn("invalid CSS End: \"{}\", should be a number or a percentage", value);
				}
				break;
			}
			case "horizontal"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetPositionPercent(_yogaNode, YGEdgeHorizontal, num.value());
					}
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetPosition(_yogaNode, YGEdgeHorizontal, num.value());
				} else {
					Warn("invalid CSS Horizontal: \"{}\", should be a number or a percentage", value);
				}
				break;
			}
			case "vertical"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetPositionPercent(_yogaNode, YGEdgeVertical, num.value());
					}
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetPosition(_yogaNode, YGEdgeVertical, num.value());
				} else {
					Warn("invalid CSS Vertical: \"{}\", should be a number or a percentage", value);
				}
				break;
			}
			case "position"_hash: {
				if (auto var = mapPositionType(value)) {
					YGNodeStyleSetPositionType(_yogaNode, var.value());
				}
				break;
			}
			case "overflow"_hash: {
				if (auto var = mapOverflow(value)) {
					YGNodeStyleSetOverflow(_yogaNode, var.value());
				}
				break;
			}
			case "display"_hash: {
				if (auto var = mapDisplay(value)) {
					YGNodeStyleSetDisplay(_yogaNode, var.value());
				}
				break;
			}
			case "width"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetWidthPercent(_yogaNode, num.value());
					}
				} else if (value == "auto") {
					YGNodeStyleSetWidthAuto(_yogaNode);
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetWidth(_yogaNode, num.value());
				} else {
					Warn("invalid CSS Width: \"{}\", should be a number or a percentage", value);
				}
				break;
			}
			case "height"_hash: {
				if (value == "auto") {
					YGNodeStyleSetHeightAuto(_yogaNode);
				} else if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetHeightPercent(_yogaNode, num.value());
					}
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetHeight(_yogaNode, num.value());
				} else {
					Warn("invalid CSS Height: \"{}\", should be a number or a percentage", value);
				}
				break;
			}
			case "min-width"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetMinWidthPercent(_yogaNode, num.value());
					}
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetMinWidth(_yogaNode, num.value());
				} else {
					Warn("invalid CSS MinWidth: \"{}\", should be a number or a percentage", value);
				}
				break;
			}
			case "min-height"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetMinHeightPercent(_yogaNode, num.value());
					}
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetMinHeight(_yogaNode, num.value());
				} else {
					Warn("invalid CSS MinHeight: \"{}\", should be a number or a percentage", value);
				}
				break;
			}
			case "max-width"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetMaxWidthPercent(_yogaNode, num.value());
					}
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetMaxWidth(_yogaNode, num.value());
				} else {
					Warn("invalid CSS MaxWidth: \"{}\", should be a number or a percentage", value);
				}
				break;
			}
			case "max-height"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetMaxHeightPercent(_yogaNode, num.value());
					}
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetMaxHeight(_yogaNode, num.value());
				} else {
					Warn("invalid CSS MaxHeight: \"{}\", should be a number or a percentage", value);
				}
				break;
			}
			case "margin"_hash: {
				setEdges(_yogaNode, parseCommaSeparatedValues(value, true, true), YGNodeStyleSetMargin, YGNodeStyleSetMarginPercent, YGNodeStyleSetMarginAuto);
				break;
			}
			case "margin-top"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetMarginPercent(_yogaNode, YGEdgeTop, num.value());
					}
				} else if (value == "auto") {
					YGNodeStyleSetMarginAuto(_yogaNode, YGEdgeTop);
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetMargin(_yogaNode, YGEdgeTop, num.value());
				} else {
					Warn("invalid CSS MarginTop: \"{}\", should be a number, a percentage or auto", value);
				}
				break;
			}
			case "margin-right"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetMarginPercent(_yogaNode, YGEdgeRight, num.value());
					}
				} else if (value == "auto") {
					YGNodeStyleSetMarginAuto(_yogaNode, YGEdgeRight);
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetMargin(_yogaNode, YGEdgeRight, num.value());
				} else {
					Warn("invalid CSS MarginRight: \"{}\", should be a number, a percentage or auto", value);
				}
				break;
			}
			case "margin-bottom"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetMarginPercent(_yogaNode, YGEdgeBottom, num.value());
					}
				} else if (value == "auto") {
					YGNodeStyleSetMarginAuto(_yogaNode, YGEdgeBottom);
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetMargin(_yogaNode, YGEdgeBottom, num.value());
				} else {
					Warn("invalid CSS MarginBottom: \"{}\", should be a number, a percentage or auto", value);
				}
				break;
			}
			case "margin-left"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetMarginPercent(_yogaNode, YGEdgeLeft, num.value());
					}
				} else if (value == "auto") {
					YGNodeStyleSetMarginAuto(_yogaNode, YGEdgeLeft);
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetMargin(_yogaNode, YGEdgeLeft, num.value());
				} else {
					Warn("invalid CSS MarginLeft: \"{}\", should be a number, a percentage or auto", value);
				}
				break;
			}
			case "margin-inline-start"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetMarginPercent(_yogaNode, YGEdgeStart, num.value());
					}
				} else if (value == "auto") {
					YGNodeStyleSetMarginAuto(_yogaNode, YGEdgeStart);
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetMargin(_yogaNode, YGEdgeStart, num.value());
				} else {
					Warn("invalid CSS MarginStart: \"{}\", should be a number, a percentage or auto", value);
				}
				break;
			}
			case "margin-inline-end"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetMarginPercent(_yogaNode, YGEdgeEnd, num.value());
					}
				} else if (value == "auto") {
					YGNodeStyleSetMarginAuto(_yogaNode, YGEdgeEnd);
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetMargin(_yogaNode, YGEdgeEnd, num.value());
				} else {
					Warn("invalid CSS MarginEnd: \"{}\", should be a number, a percentage or auto", value);
				}
				break;
			}
			case "margin-inline"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetMarginPercent(_yogaNode, YGEdgeStart, num.value());
						YGNodeStyleSetMarginPercent(_yogaNode, YGEdgeEnd, num.value());
					}
				} else if (value == "auto") {
					YGNodeStyleSetMarginAuto(_yogaNode, YGEdgeStart);
					YGNodeStyleSetMarginAuto(_yogaNode, YGEdgeEnd);
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetMargin(_yogaNode, YGEdgeStart, num.value());
					YGNodeStyleSetMargin(_yogaNode, YGEdgeEnd, num.value());
				} else {
					Warn("invalid CSS MarginEnd: \"{}\", should be a number, a percentage or auto", value);
				}
				break;
			}
			case "padding"_hash: {
				setEdges(_yogaNode, parseCommaSeparatedValues(value, true), YGNodeStyleSetPadding, YGNodeStyleSetPaddingPercent);
				break;
			}
			case "padding-top"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetPaddingPercent(_yogaNode, YGEdgeTop, num.value());
					}
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetPadding(_yogaNode, YGEdgeTop, num.value());
				} else {
					Warn("invalid CSS PaddingTop: \"{}\", should be a number or a percentage", value);
				}
				break;
			}
			case "padding-right"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetPaddingPercent(_yogaNode, YGEdgeRight, num.value());
					}
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetPadding(_yogaNode, YGEdgeRight, num.value());
				} else {
					Warn("invalid CSS PaddingRight: \"{}\", should be a number or a percentage", value);
				}
				break;
			}
			case "padding-bottom"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetPaddingPercent(_yogaNode, YGEdgeBottom, num.value());
					}
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetPadding(_yogaNode, YGEdgeBottom, num.value());
				} else {
					Warn("invalid CSS PaddingBottom: \"{}\", should be a number or a percentage", value);
				}
				break;
			}
			case "padding-left"_hash: {
				if (!value.empty() && value.back() == '%') {
					Slice numStr{value};
					numStr.skipRight(1);
					if (auto num = safeStringToFloat(numStr.toView())) {
						YGNodeStyleSetPaddingPercent(_yogaNode, YGEdgeLeft, num.value());
					}
				} else if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetPadding(_yogaNode, YGEdgeLeft, num.value());
				} else {
					Warn("invalid CSS PaddingLeft: \"{}\", should be a number or a percentage", value);
				}
				break;
			}
			case "border"_hash: {
				setEdges(_yogaNode, parseCommaSeparatedValues(value), YGNodeStyleSetBorder);
				break;
			}
			case "gap"_hash: {
				setGap(_yogaNode, parseCommaSeparatedValues(value, true));
				break;
			}
			case "aspect-ratio"_hash: {
				if (auto num = safeStringToFloat(value)) {
					YGNodeStyleSetAspectRatio(_yogaNode, num.value());
				} else {
					Warn("invalid CSS AspectRatio: \"{}\", should be a number", value);
				}
				break;
			}
			case "box-sizing"_hash: {
				if (auto var = mapBoxSizing(value)) {
					YGNodeStyleSetBoxSizing(_yogaNode, var.value());
				}
				break;
			}
			default:
				Warn("invalid CSS Style: \"{}\"", key);
				break;
		}
	}
}

struct ConfigDeleter {
	inline void operator()(YGConfigRef ptr) const {
		YGConfigFree(ptr);
	}
};

YGConfigRef AlignNode::getConfig() {
	static std::unique_ptr<YGConfig, ConfigDeleter> config(YGConfigNew());
	static std::once_flag initConfig;
	std::call_once(initConfig, []() {
		YGConfigSetPointScaleFactor(config.get(), 1.0f);
	});
	return config.get();
}

NS_DORA_END
