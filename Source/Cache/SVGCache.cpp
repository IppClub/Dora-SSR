/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Cache/SVGCache.h"

NS_DORA_BEGIN

const SVGDef::GradientMap& SVGDef::getGradients() const noexcept {
	return _gradients;
}

const SVGDef::CommandList& SVGDef::getCommands() const noexcept {
	return _commands;
}

float SVGDef::getWidth() const noexcept {
	return _width;
}

float SVGDef::getHeight() const noexcept {
	return _height;
}

void SVGDef::render() {
	SVGDef::Context ctx{nvg::Context(), this};
	for (const auto& cmd : _commands) {
		cmd(&ctx);
	}
}

SVGDef* SVGDef::from(String filename) {
	return SharedSVGCache.load(filename);
}

static void get(String value, Rect& rect) {
	auto tokens = value.split(" ");
	AssertUnless(tokens.size() == 4, "invalid vec4 str for: \"{}\"", value.toString());
	auto it = tokens.begin();
	rect.origin.x = it->toFloat();
	rect.origin.y = (++it)->toFloat();
	rect.size.width = (++it)->toFloat();
	rect.size.height = (++it)->toFloat();
}

static void get(String value, Color& color) {
	Slice str = value;
	if (str.front() == '#') {
		str.skip(1);
		uint32_t rgb = 0;
		try {
			if (str.size() == 3) {
				rgb = Slice("0x"s + str[0] + str[0] + str[1] + str[1] + str[2] + str[2]).toInt(16);
			} else {
				rgb = Slice("0x"s + str.toString()).toInt(16);
			}
		} catch (std::invalid_argument&) {
			Error("got invalid color string for VG render: {}", str.toString());
			return;
		}
		Color c(rgb);
		color.r = c.r;
		color.g = c.g;
		color.b = c.b;
	} else if (str.left(4) == "rgb("_slice) {
		str.skip(4);
		auto coms = str.left(str.size() - 1).split(","_slice);
		if (coms.size() == 3) {
			auto it = coms.begin();
			try {
				color.r = s_cast<uint8_t>(it->toInt());
				++it;
				color.g = s_cast<uint8_t>(it->toInt());
				++it;
				color.b = s_cast<uint8_t>(it->toInt());
			} catch (std::invalid_argument&) {
				Error("got invalid color string for VG render: {}", str.toString());
				return;
			}
		}
	} else if (str == "white"_slice) {
		color = Color::White;
	}
}

#define ATTR_START \
	for (int i = 0; !attrs[i].empty(); i++) { \
		Slice k = attrs[i]; \
		Slice v = attrs[++i]; \
		switch (Switch::hash(k)) {

#define ATTR_STOP \
	} \
	}

std::shared_ptr<XmlParser<SVGDef>> SVGCache::prepareParser(String filename) {
	return std::shared_ptr<XmlParser<SVGDef>>(new Parser(SVGDef::create()));
}

void SVGCache::Parser::xmlSAX2Text(std::string_view text) { }

static int getLineCap(String value) {
	switch (Switch::hash(value)) {
		case "butt"_hash:
			return NVG_BUTT;
		case "round"_hash:
			return NVG_ROUND;
		case "square"_hash:
			return NVG_SQUARE;
		case "bevel"_hash:
			return NVG_BEVEL;
		default:
			return NVG_BUTT;
	}
}

struct FillStrokeData {
	Color color = 0xff000000;
	std::optional<std::string> definition;
	std::optional<Color> strokeColor;
	std::optional<int> lineCap, lineJoin;
	std::optional<float> miterLimit, strokeWidth;
};

static void attribFillStroke(FillStrokeData& data, String name, String value) {
	switch (Switch::hash(name)) {
		case "fill"_hash: {
			Slice v = value;
			v.trimSpace();
			if (v.size() > 5 && v.left(4) == "url("_slice && v.right(1) == ")"_slice) {
				v.skip(4);
				v.skipRight(1);
				v.trimSpace();
				data.definition = v.toString();
			} else {
				get(value, data.color);
			}
			break;
		}
		case "fill-opacity"_hash: {
			float opacity = value.toFloat();
			data.color.setOpacity(opacity * data.color.getOpacity());
			break;
		}
		case "opacity"_hash: {
			float opacity = value.toFloat();
			data.color.setOpacity(opacity * data.color.getOpacity());
			break;
		}
		case "stroke"_hash: {
			if (value != "none"_slice && value != "transparent"_slice) {
				Color c(0xff000000);
				get(value, c);
				data.strokeColor = c;
			}
			break;
		}
		case "stroke-opacity"_hash: {
			float opacity = value.toFloat();
			if (!data.strokeColor) data.strokeColor = Color(0x0);
			data.strokeColor.value().setOpacity(opacity);
			break;
		}
		case "stroke-linecap"_hash: data.lineCap = getLineCap(value); break;
		case "stroke-linejoin"_hash: data.lineJoin = getLineCap(value); break;
		case "stroke-miterlimit"_hash: data.miterLimit = value.toFloat(); break;
		case "stroke-width"_hash: data.strokeWidth = value.toFloat(); break;
	}
}

static void attribStyle(FillStrokeData& data, String style) {
	auto attrs = style.split(";"sv);
	for (const auto& attr : attrs) {
		if (attr.empty()) continue;
		auto tokens = attr.split(":"sv);
		if (tokens.size() != 2) continue;
		attribFillStroke(data, tokens.front(), tokens.back());
	}
};

static void drawFillStroke(SVGDef::Context* ctx, const FillStrokeData& data) {
	if (data.definition) {
		const auto& gradients = ctx->def->getGradients();
		auto it = gradients.find(data.definition.value());
		if (it != gradients.end()) {
			it->second(ctx);
		}
	} else {
		nvgFillColor(ctx->nvg, nvgColor(data.color));
		nvgFill(ctx->nvg);
	}
	if (data.strokeColor) {
		nvgStrokeColor(ctx->nvg, nvgColor(data.strokeColor.value()));
		if (data.lineCap) {
			nvgLineCap(ctx->nvg, data.lineCap.value());
		}
		if (data.lineJoin) {
			nvgLineJoin(ctx->nvg, data.lineJoin.value());
		}
		if (data.miterLimit) {
			nvgMiterLimit(ctx->nvg, data.miterLimit.value());
		}
		if (data.strokeWidth) {
			nvgStrokeWidth(ctx->nvg, data.strokeWidth.value());
		}
		nvgStroke(ctx->nvg);
	}
}

static void drawBegin(SVGDef::Context* ctx) {
	nvgBeginPath(ctx->nvg);
	ctx->previousPathXY.push_back(Vec2::zero);
	ctx->transformCounts.push_back(0);
}

static void drawEnd(SVGDef::Context* ctx, const FillStrokeData& data) {
	drawFillStroke(ctx, data);
	for (int i = 0; i < ctx->transformCounts.back(); i++) {
		nvgRestore(ctx->nvg);
	}
	ctx->previousPathXY.pop_back();
	ctx->transformCounts.pop_back();
}

struct CircleData {
	float cx = 0.0f, cy = 0.0f, r = 0.0f;
	FillStrokeData fillStroke;
};

struct EllipseData {
	float cx = 0.0f, cy = 0.0f, rx = 0.0f, ry = 0.0f;
	FillStrokeData fillStroke;
};

struct LineData {
	float x1 = 0.0f, y1 = 0.0f, x2 = 0.0f, y2 = 0.0f;
	FillStrokeData fillStroke;
};

struct StopData {
	float x = 0.0f;
	float y = 0.0f;
	Color color = 0xff000000;
};

struct LinearGradientData {
	std::list<StopData> stops;
	std::optional<nvg::Transform> transform;
};

struct PolygonData {
	bool closePath = true;
	std::vector<Vec2> points;
	FillStrokeData fillStroke;
};

struct RectData {
	float x = 0.0f, y = 0.0f, width = 0.0f, height = 0.0f;
	std::optional<nvg::Transform> transform;
	FillStrokeData fillStroke;
};

struct CommandData {
	char command;
	std::vector<float> args;
};

struct PathData {
	std::list<CommandData> commands;
	FillStrokeData fillStroke;
};

static bool getTransform(std::optional<nvg::Transform>& transform, Slice v) {
	v.trimSpace();
	std::vector<float> result;
	if (v.left(7) == "matrix("_slice && v.right(1) == ")"_slice) {
		v.skip(7);
		v.skipRight(1);
		auto tokens = v.split(" "_slice);
		if (tokens.size() == 6) {
			nvg::Transform trans = {};
			int i = 0;
			for (const auto& token : tokens) {
				trans.t[i] = token.toFloat();
				++i;
			}
			transform = trans;
			return true;
		}
	}
	return false;
}

void SVGCache::Parser::xmlSAX2StartElement(std::string_view name, const std::vector<std::string_view>& selfAttrs) {
	auto def = getItem();
	auto attrs = selfAttrs;
	if (!_attrStack.empty()) {
		attrs.insert(--attrs.end(),
			_attrStack.top().begin(), _attrStack.top().end());
	}
	switch (Switch::hash(name)) {
		case "svg"_hash: {
			ATTR_START
			case "width"_hash: def->_width = v.toFloat(); break;
			case "height"_hash: def->_height = v.toFloat(); break;
			case "viewBox"_hash: {
				Rect rc;
				get(v, rc);
				def->_width = rc.getWidth();
				def->_height = rc.getHeight();
				break;
			}
				ATTR_STOP
				break;
		}
		case "circle"_hash: {
			CircleData data;
			ATTR_START
			case "cx"_hash: data.cx = v.toFloat(); break;
			case "cy"_hash: data.cy = v.toFloat(); break;
			case "r"_hash: data.r = v.toFloat(); break;
			case "style"_hash: attribStyle(data.fillStroke, v); break;
			default:
				attribFillStroke(data.fillStroke, k, v);
				break;
				ATTR_STOP
				def->_commands.push_back([data](SVGDef::Context* ctx) {
					drawBegin(ctx);
					nvgCircle(ctx->nvg, data.cx, data.cy, data.r);
					drawEnd(ctx, data.fillStroke);
				});
				break;
		}
		case "ellipse"_hash: {
			EllipseData data;
			ATTR_START
			case "cx"_hash: data.cx = v.toFloat(); break;
			case "cy"_hash: data.cy = v.toFloat(); break;
			case "rx"_hash: data.rx = v.toFloat(); break;
			case "ry"_hash: data.ry = v.toFloat(); break;
			case "style"_hash: attribStyle(data.fillStroke, v); break;
			default:
				attribFillStroke(data.fillStroke, k, v);
				break;
				ATTR_STOP
				def->_commands.push_back([data](SVGDef::Context* ctx) {
					drawBegin(ctx);
					nvgEllipse(ctx->nvg, data.cx, data.cy, data.rx, data.ry);
					drawEnd(ctx, data.fillStroke);
				});
				break;
		}
		case "g"_hash: {
			auto& attrGroup = _attrStack.emplace();
			for (int i = 0; !attrs[i].empty(); i++) {
				attrGroup.push_back(attrs[i]);
			}
			break;
		}
		case "line"_hash: {
			LineData data;
			ATTR_START
			case "x1"_hash: data.x1 = v.toFloat(); break;
			case "y1"_hash: data.y1 = v.toFloat(); break;
			case "x2"_hash: data.x2 = v.toFloat(); break;
			case "y2"_hash: data.y2 = v.toFloat(); break;
			case "style"_hash: attribStyle(data.fillStroke, v); break;
			default:
				attribFillStroke(data.fillStroke, k, v);
				break;
				ATTR_STOP
				def->_commands.push_back([data](SVGDef::Context* ctx) {
					drawBegin(ctx);
					nvgMoveTo(ctx->nvg, data.x1, data.y1);
					nvgLineTo(ctx->nvg, data.x2, data.y2);
					drawEnd(ctx, data.fillStroke);
				});
				break;
		}
		case "lineargradient"_hash: {
			ATTR_START
			case "x1"_hash: _currentLinearGradient.x1 = v.toFloat(); break;
			case "y1"_hash: _currentLinearGradient.y1 = v.toFloat(); break;
			case "x2"_hash: _currentLinearGradient.x2 = v.toFloat(); break;
			case "y2"_hash: _currentLinearGradient.y2 = v.toFloat(); break;
			case "id"_hash: _currentLinearGradient.id = v.toString(); break;
			case "gradientTransform"_hash: {
				if (!getTransform(_currentLinearGradient.transform, v)) {
					throw rapidxml::parse_error("transform is not supported", r_cast<void*>(c_cast<char*>(name.data())));
				}
				break;
			}
				ATTR_STOP
				break;
		}
		case "stop"_hash: {
			float offset = 0.0f;
			Color stopColor;
			ATTR_START
			case "offset"_hash: offset = v.toFloat(); break;
			case "stop-color"_hash: get(v, stopColor); break;
			case "stop-opacity"_hash:
				stopColor.setOpacity(v.toFloat());
				break;
				ATTR_STOP
				_currentLinearGradient.stops.emplace_back(offset, stopColor);
				break;
		}
		case "polygon"_hash:
		case "polyline"_hash: {
			PolygonData data;
			data.closePath = name != "polyline"_slice;
			ATTR_START
			case "points"_hash: {
				for (const auto& p : v.split(" "_slice)) {
					auto tokens = p.split(","_slice);
					if (tokens.size() != 2) {
						throw rapidxml::parse_error("<polygon> points format is invalid", r_cast<void*>(c_cast<char*>(name.data())));
					}
					float x = tokens.front().toFloat();
					float y = tokens.back().toFloat();
					data.points.push_back({x, y});
				}
				break;
			}
			case "style"_hash: attribStyle(data.fillStroke, v); break;
			default:
				attribFillStroke(data.fillStroke, k, v);
				break;
				ATTR_STOP
				def->_commands.push_back([data = std::move(data)](SVGDef::Context* ctx) {
					drawBegin(ctx);
					auto it = data.points.begin();
					nvgMoveTo(ctx->nvg, it->x, it->y);
					for (++it; it != data.points.end(); ++it) {
						nvgLineTo(ctx->nvg, it->x, it->y);
					}
					if (data.closePath) {
						nvgClosePath(ctx->nvg);
					}
					drawEnd(ctx, data.fillStroke);
				});
		}
		case "rect"_hash: {
			RectData data;
			ATTR_START
			case "x"_hash: data.x = v.toFloat(); break;
			case "y"_hash: data.y = v.toFloat(); break;
			case "width"_hash: data.width = v.toFloat(); break;
			case "height"_hash: data.height = v.toFloat(); break;
			case "transform"_hash: {
				if (!getTransform(data.transform, v)) {
					throw rapidxml::parse_error("transform is not supported", r_cast<void*>(c_cast<char*>(name.data())));
				}
				break;
			}
			case "style"_hash: attribStyle(data.fillStroke, v); break;
			default:
				attribFillStroke(data.fillStroke, k, v);
				break;
				ATTR_STOP
				def->_commands.push_back([data](SVGDef::Context* ctx) {
					drawBegin(ctx);
					if (data.transform) {
						nvgSave(ctx->nvg);
						const float* t = data.transform->t;
						nvgTransform(ctx->nvg, t[0], t[1], t[2], t[3], t[4], t[5]);
						ctx->transformCounts.back() += 1;
					}
					nvgRect(ctx->nvg, data.x, data.y, data.width, data.height);
					drawEnd(ctx, data.fillStroke);
				});
				break;
		}
		case "path"_hash: {
			PathData data;
			ATTR_START
			case "d"_hash: {
				std::string parameterString;
				std::list<std::string> parameters;
				std::optional<char> command;
				bool foundDecimalSeparator = false;
				auto executeCommand = [&]() {
					if (!command) return;
					int parameterCount = _params[std::toupper(command.value())];
					if (parameterCount == 0) {
						if (parameters.empty()) {
							data.commands.push_back({command.value()});
						} else
							throw rapidxml::parse_error(
								fmt::format("Path command {} should not take parameters: {}", command.value(), parameters.size()).c_str(),
								r_cast<void*>(c_cast<char*>(name.data())));
					} else {
						if (parameters.size() % parameterCount != 0) {
							throw rapidxml::parse_error(
								fmt::format("Path command {} should take {} parameters instead of {}", command.value(), parameterCount, parameters.size()).c_str(),
								r_cast<void*>(c_cast<char*>(name.data())));
						}
						while (!parameters.empty()) {
							std::vector<float> args;
							for (int i = 0; i < parameterCount; ++i) {
								args.push_back(Slice(parameters.front()).toFloat());
								parameters.pop_front();
							}
							data.commands.push_back({command.value(), std::move(args)});
						}
					}
				};
				for (auto ch : v) {
					if (ch == '\n' || ch == '\t') continue;
					switch (ch) {
						case 'a':
						case 't':
							throw rapidxml::parse_error(
								fmt::format("Path command {} is not implemeneted", command.value()).c_str(),
								r_cast<void*>(c_cast<char*>(name.data())));
							break;
						case 'c':
						case 'h':
						case 'l':
						case 'm':
						case 's':
						case 'q':
						case 'v':
						case 'z':
						case 'A':
						case 'C':
						case 'H':
						case 'L':
						case 'M':
						case 'S':
						case 'Q':
						case 'T':
						case 'V':
						case 'Z': {
							if (!parameterString.empty()) {
								parameters.push_back(parameterString);
								parameterString.clear();
							}
							executeCommand();
							command = ch;
							parameters.clear();
							foundDecimalSeparator = false;
							break;
						}
						case ' ':
						case ',':
						case '-': {
							if (!parameterString.empty()) {
								parameters.push_back(parameterString);
								parameterString.clear();
								foundDecimalSeparator = false;
							}
							if (ch == '-') {
								parameterString += ch;
								foundDecimalSeparator = false;
							}
							break;
						}
						case '.': {
							if (foundDecimalSeparator) {
								parameters.push_back(parameterString);
								parameterString.clear();
								parameterString += ch;
							} else {
								foundDecimalSeparator = true;
								parameterString += ch;
							}
							break;
						}
						default: {
							if (command && std::isdigit(ch)) {
								parameterString += ch;
							}
							break;
						}
					}
				}
				if (!parameterString.empty()) {
					parameters.push_back(parameterString);
					parameterString.clear();
				}
				executeCommand();
				break;
			}
			case "style"_hash: attribStyle(data.fillStroke, v); break;
			default:
				attribFillStroke(data.fillStroke, k, v);
				break;
				ATTR_STOP
				def->_commands.push_back([data = std::move(data)](SVGDef::Context* ctx) {
					drawBegin(ctx);
					std::optional<CommandData> previousPath;
					std::optional<Vec2> previousMovePoint;
					std::optional<char> previousCommand;
					std::vector<float> previousParameters;
					int subPathCount = 0;
					for (const auto& cmd : data.commands) {
						// Converts relative coordinates to absolute coordinates.
						std::vector<float> args = cmd.args;
						if (std::islower(cmd.command)) {
							auto previous = ctx->previousPathXY.back();
							switch (cmd.command) {
								case 'c':
								case 'h':
								case 'l':
								case 'm':
								case 's':
								case 'q': {
									for (size_t i = 0; i < cmd.args.size(); ++i) {
										args[i] += (&previous.x)[i % 2];
									}
									break;
								}
								case 'v': {
									args = {previous.y + args[0]};
									break;
								}
								default: break;
							}
						}
						char command = std::toupper(cmd.command);
						// Converts 'H', 'S' and 'V' commands to other generic commands.
						switch (command) {
							case 'H':
								command = 'L';
								args = {args[0], ctx->previousPathXY.back().y};
								break;
							case 'S':
								if (!previousPath) {
									previousCommand.reset();
								} else {
									previousCommand = previousPath->command;
									previousParameters = previousPath->args;
								}
								if (previousCommand == 'C') {
									float previousX = previousParameters[4];
									float previousY = previousParameters[5];
									float previousX2 = previousParameters[2];
									float previousY2 = previousParameters[3];
									float x1 = 2.0f * previousX - previousX2;
									float y1 = 2.0f * previousY - previousY2;
									command = 'C';
									args.insert(args.begin(), y1);
									args.insert(args.begin(), x1);
								} else {
									size_t last = previousParameters.size() - 1;
									float x = previousParameters[last];
									float y = previousParameters[last - 1];
									command = 'C';
									args.insert(args.begin(), y);
									args.insert(args.begin(), x);
								}
								break;
							case 'V':
								command = 'L';
								args = {ctx->previousPathXY.back().x, args[0]};
								break;
						}
						// Moves to the previous move point if the previous command is closepath.
						if (previousPath
							&& previousMovePoint
							&& previousPath->command == 'Z'
							&& command != 'M') {
							subPathCount++;
							nvgMoveTo(ctx->nvg, previousMovePoint->x, previousMovePoint->y);
						}
						// Handles generic commands.
						switch (command) {
							case 'C':
								nvgBezierTo(ctx->nvg, args[0], args[1], args[2], args[3], args[4], args[5]);
								ctx->previousPathXY.back() = {args[4], args[5]};
								previousPath = {command, args};
								break;
							case 'L': {
								if ((previousPath->command == 'M'
										|| previousPath->command == 'L')
									&& args[0] == ctx->previousPathXY.back().x
									&& args[1] == ctx->previousPathXY.back().y) {
									break;
								}
								nvgLineTo(ctx->nvg, args[0], args[1]);
								ctx->previousPathXY.back() = {args[0], args[1]};
								previousPath = {command, args};
								break;
							}
							case 'M':
								subPathCount++;
								nvgMoveTo(ctx->nvg, args[0], args[1]);
								ctx->previousPathXY.back() = {args[0], args[1]};
								previousMovePoint = {args[0], args[1]};
								previousPath = {command, args};
								break;
							case 'Q':
								nvgQuadTo(ctx->nvg, args[0], args[1], args[2], args[3]);
								ctx->previousPathXY.back() = {args[2], args[3]};
								previousPath = {command, args};
								break;
							case 'Z':
								if (previousPath->command == 'M') {
									break;
								}
								nvgClosePath(ctx->nvg);
								if (subPathCount > 1) {
									nvgPathWinding(ctx->nvg, subPathCount % 2 == 0 ? NVG_HOLE : NVG_SOLID);
								}
								previousPath = {command, args};
								break;
							default:
								Error("Path command {} is not implemented", command);
								break;
						}
					}
					drawEnd(ctx, data.fillStroke);
				});
				break;
		}
		case "comment"_hash:
		case "desc"_hash:
		case "title"_hash:
		case "namedview"_hash:
			// ignored
			break;
	}
}

void SVGCache::Parser::xmlSAX2EndElement(std::string_view name) {
	switch (Switch::hash(name)) {
		case "g"_hash: {
			_attrStack.pop();
			break;
		}
		case "lineargradient"_hash: {
			if (_currentLinearGradient.stops.size() > 2) {
				throw rapidxml::parse_error("<linearGradient> currently only supports two stops", r_cast<void*>(c_cast<char*>(name.data())));
			}
			LinearGradientData data;
			for (const auto& stop : _currentLinearGradient.stops) {
				float n = stop.first;
				float m = 1.0f - n;
				float x = m * _currentLinearGradient.x2 + n * _currentLinearGradient.x1;
				float y = m * _currentLinearGradient.y2 + n * _currentLinearGradient.y1;
				data.stops.push_back({x, y, stop.second});
			}
			data.transform = _currentLinearGradient.transform;
			auto def = getItem();
			def->_gradients[_currentLinearGradient.id] = [data](SVGDef::Context* ctx) {
				if (data.transform) {
					nvgSave(ctx->nvg);
					const float* t = data.transform->t;
					nvgTransform(ctx->nvg, t[0], t[1], t[2], t[3], t[4], t[5]);
					ctx->transformCounts.back() += 1;
				}
				std::optional<StopData> srcStop;
				for (const auto& dstStop : data.stops) {
					if (!srcStop) {
						srcStop = dstStop;
					} else {
						NVGpaint paint = nvgLinearGradient(ctx->nvg,
							srcStop->x, srcStop->y,
							dstStop.x, dstStop.y,
							nvgColor(srcStop->color),
							nvgColor(dstStop.color));
						nvgFillPaint(ctx->nvg, paint);
					}
				}
			};
			break;
		}
	}
}

NS_DORA_END
